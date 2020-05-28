#!/usr/bin/env python3
import configparser
import requests
import argparse
import json
import re
import yaml
import os
import subprocess
import shutil
from glob import glob

# Get config from user dir

config_file = os.path.expanduser("~/.puzzlecad")
config = configparser.ConfigParser()
config.read(config_file)

client_id = config['puzzlecad']['ClientId']
client_secret = config['puzzlecad']['ClientSecret']
openscad_bin = config['puzzlecad']['OpenscadBin']
access_token = config['puzzlecad']['AccessToken']
thingiverse_timeout = 60

libs_dir = '../src/main/scad'
output_dir = '../out'
os.environ['OPENSCADPATH'] = libs_dir

parser = argparse.ArgumentParser()
parser.add_argument('command')
parser.add_argument('cmdargs', nargs='*')

args = parser.parse_args()

def process_command(args):

	if args.command == 'get-token':
	
		get_access_token()
		
	elif args.command == 'build':
	
		build_stls(args.cmdargs[0])
		
	elif args.command == "bundle-puzzlecad":
	
		bundle_puzzlecad(args.cmdargs[0])

	elif args.command == 'print-thing-description':
	
		print_thing_description(args.cmdargs[0])
		
	elif args.command == 'update-thing':
	
		if access_token == '':
			raise Exception("You must specify an access token. Use the get-token command to obtain one.")
		update_thing(access_token, args.cmdargs[0], '' if (len(args.cmdargs) < 2) else args.cmdargs[1])
		
	elif args.command == 'delete-thing':

		if access_token == '':
			raise Exception("You must specify an access token. Use the get-token command to obtain one.")
		delete_thing(access_token, args.cmdargs[0])
		
	elif args.command == 'test':
	
		run_test(access_token)
		
	else:
	
		raise Exception(f'Unknown command: {args.command}')

def get_access_token():

	print('Go to this URL and get an auth code:')
	print(f'https://www.thingiverse.com/login/oauth/authorize?client_id={client_id}')
	
	code = input('Enter auth code: ')
	
	token_response = requests.post(
        'https://www.thingiverse.com/login/oauth/access_token',
        data = {'client_id': client_id, 'client_secret': client_secret, 'code': code},
        timeout = thingiverse_timeout
        )

	params = dict(x.split('=') for x in token_response.text.split('&'))

	access_token = params['access_token']

	print('Put this line in ~/.puzzlecad:')
	print(f'AccessToken = {access_token}')
	
def print_thing_description(thing_name):

	yaml_path = resolve_thing(thing_name)
	contents = load_yaml_file(yaml_path)
	description = substitute_globals(contents['description'], thing_name)
	print(description)
	
def delete_thing(access_token, thing_id):

	thingiverse_delete(f'things/{thing_id}', access_token)
	
def update_thing(access_token, thing_name, targets_str):

	targets = targets_str.split(',')
	
	yaml_path = resolve_thing(thing_name)
	contents = load_yaml_file(yaml_path)
	name = contents['name']
	thing_id = contents['thing-id']
	description = substitute_globals(contents['description'], thing_name)
	
	print(f'Updating thing "{name}" from file {yaml_path} ...')
		
	if 'files' in targets:
	
		# Build the STLs first before uploading anything
		build_stls(thing_name)
		
	split_name = name.split(" - ")
	description_title = f'## {name}' if len(split_name) <= 1 else f'## {split_name[0]}\n\n### {split_name[1]}'
	
	print(f'Updating thing attributes ...')
	
	attributes = {
		'name': name,
		'license': 'cc-nc-nd',
		'category': 'Puzzles',
		'description': f"## {description_title}\n\n{description}",
		'tags': contents['tags']
	}
	
	thingiverse_patch(f'things/{thing_id}', access_token, attributes)
	
	dir = os.path.dirname(yaml_path)
	
	if 'images' in targets:
	
		# thingiverse_clean(thing_id, 'images')
	
		for image_file in contents['images']:
	
			thingiverse_post_file(thing_id, os.path.join(dir, image_file))
		
	if 'files' in targets:
	
		thingiverse_clean(thing_id, 'files')
	
		root = os.path.splitext(yaml_path)[0]
		scad_path = root + ".scad"
		abs_scad_path = os.path.abspath(scad_path)
		scad_file = os.path.basename(scad_path)
		scad_root = os.path.splitext(scad_file)[0]
		
		thingiverse_post_file(thing_id, scad_path)
		
		configurations = contents['configurations'] if 'configurations' in contents else [{'name': '', 'code': '', 'targets': ''}]
		
		for configuration in configurations:
			configuration_targets = contents['targets'] if configuration['targets'] == '' else configuration['targets']
			for stl_target in configuration_targets:
			
				stl_target_dashes = stl_target.replace("_", "-")
				configuration_name = '' if configuration['name'] == '' else '-' + configuration['name']
				modularized_name = f'{scad_root}{configuration_name}' if stl_target == "--" else f'{scad_root}.{stl_target_dashes}{configuration_name}'
				stl_target_path = f'{output_dir}/{modularized_name}.stl'
				thingiverse_post_file(thing_id, stl_target_path)
				
def resolve_thing(thing_name):

	print(f'../src/main/scad/**/{thing_name}.yaml')
	yaml_path = glob(f'../src/main/scad/**/{thing_name}.yaml', recursive = True)
	
	if len(yaml_path) == 0:
		raise Exception(f'Thing not found: {thing_name}')
		
	return yaml_path[0];

def load_yaml_file(yaml_file):

	file = open(yaml_file, mode = 'r')
	contents = file.read()
	file.close()
	return yaml.load(contents, Loader = yaml.FullLoader)
	
def build_stls(thing_name):
	
	yaml_path = resolve_thing(thing_name)
	contents = load_yaml_file(yaml_path)
	root = os.path.splitext(yaml_path)[0]
	scad_path = root + ".scad"
	
	print(f'Building STLs from source {scad_path} ...')
	
	configurations = contents['configurations'] if 'configurations' in contents else [{'name': '', 'code': '', 'targets': ''}]

	for configuration in configurations:
		configuration_targets = contents['targets'] if configuration['targets'] == '' else configuration['targets']
		for stl_target in configuration_targets:
			build_stl(scad_path, stl_target, configuration)
		
def build_stl(scad_path, stl_target, configuration):

	os.makedirs(output_dir, exist_ok = True)

	abs_scad_path = os.path.abspath(scad_path)
	scad_file = os.path.basename(scad_path)
	scad_root = os.path.splitext(scad_file)[0]
	
	stl_target_dashes = stl_target.replace("_", "-")
	
	configuration_name = '' if configuration['name'] == '' else '-' + configuration['name']
	configuration_code = configuration['code']
	
	modularized_name = f'{scad_root}{configuration_name}' if stl_target == "--" else f'{scad_root}.{stl_target_dashes}{configuration_name}'
	
	stl_target_path = f'{output_dir}/{modularized_name}.stl'
	temp_scad_path = f'{output_dir}/{modularized_name}.scad'
	
	if os.path.exists(stl_target_path) and os.path.getmtime(stl_target_path) >= os.path.getmtime(abs_scad_path):
	
		print(f'  Target {modularized_name} is up to date.')
		
	else:
	
		print(f'  Building target {modularized_name} ...')
		
		target_func = "" if stl_target == "--" else f'{stl_target}();';
	
		script = f'include <{abs_scad_path}>\n\n{configuration_code}\n{target_func}\n'
	
		with open(temp_scad_path, 'w') as file:
			file.write(script)
		
		exit_status = os.system(f'{openscad_bin} -o {stl_target_path} {temp_scad_path}')
	
		if exit_status != 0:
			raise Exception(f'Failed on target {modularized_name}.')

def substitute_globals(description, thing_name):

	# This is somewhat inefficient but should be fine at small scale.
	
	mentioned_globals = re.findall('\$\{(.*?)\}', description)
	for key in mentioned_globals:
		if key == 'name':
			replacement = thing_name
		elif key.startswith('link:'):
			link_name = key[5:]
			link_yaml_path = resolve_thing(link_name)
			link_contents = load_yaml_file(link_yaml_path)
			link_thing_id = link_contents['thing-id']
			link_title = link_contents['name']
			link_split_title = link_title.split(" - ")
			replacement = f'[{link_split_title[0]}](https://www.thingiverse.com/thing:{link_thing_id})'
		elif key in globals:
			replacement = globals[key]
		else:
			raise Exception('Unknown global: ${' + key + '}')
		description = description.replace('${' + key + '}', replacement)

	return description

def bundle_puzzlecad(version):

	# Rudimentary poor-excuse-for-a-build-script,
	# but I'm trying to keep things super simple right now

	exit_status = run_puzzlecad_tests()
	if (exit_status != 0):
	    return
	
	print(f'Bundling puzzlecad version {version} ...')
	
	os.makedirs('../out/dist', exist_ok = True)

	print('Building java components ...')
	os.makedirs('../out/java', exist_ok = True)
	result = subprocess.run(
		['javac', 'org/puzzlecad/XmpuzzleToScad.java', '-d', '../../../out/java', '-source', '1.6', '-target', '1.6'],
		cwd = '../src/main/java'
		)
	if result.returncode != 0:
		print('Failed!')
		return
		
	print('Building jar ...')
	result = subprocess.run(
		['jar', 'cfm', '../dist/bt2scad.jar', '../../src/main/java/manifest', '.'],
		cwd = '../out/java'
		)
	if result.returncode != 0:
		print('Failed!')
		return

	print('Copying to distribution dir ...')
	shutil.copy('../src/main/scad/puzzlecad.scad', '../out/dist')
	shutil.copy('../src/main/scad/puzzlecad-examples.scad', '../out/dist')
	shutil.copy('../src/main/scad/dist/half-hour-example.scad', '../out/dist')
	
	print('Creating archive ...')
	dist_files = [ os.path.relpath(file, '../out/dist') for file in glob('../out/dist/*') ]
	subprocess.run(
		['zip', f'../puzzlecad-{version}.zip'] + dist_files,
		cwd = '../out/dist'
		)
	if result.returncode != 0:
		print('Failed!')
		return

	print('Done!')

def run_puzzlecad_tests():

    print('Running puzzlecad tests ...')
    exit_status = os.system(f'{openscad_bin} -o ../out/puzzlecad-tests.stl ../src/main/scad/puzzlecad-tests.scad')
    if exit_status == 0:
        print('Tests succeeded.')
    else:
        print('Tests failed!')
    return exit_status

def thingiverse_get(endpoint, access_token):

	url = f'https://api.thingiverse.com/{endpoint}'

	response = requests.get(
		url,
		params = { 'access_token': access_token },
		timeout = thingiverse_timeout
		)
		
	if response.status_code != 200:
		raise Exception(f"Call to {url} returned {response.status_code}: {response.text}")
		
	return response.json()
	
def thingiverse_post(endpoint, access_token, data):

	url = f'https://api.thingiverse.com/{endpoint}'

	response = requests.post(
		url,
		params = { 'access_token': access_token },
		json = data,
		timeout = thingiverse_timeout
		)
		
	if response.status_code != 200:
		raise Exception(f"Call to {url} returned {response.status_code}: {response.text}")
		
	return response.json()
	
def thingiverse_patch(endpoint, access_token, data):

	url = f'https://api.thingiverse.com/{endpoint}'

	response = requests.patch(
		url,
		params = { 'access_token': access_token },
		json = data,
		timeout = thingiverse_timeout
		)
		
	if response.status_code != 200:
		raise Exception(f"Call to {url} returned {response.status_code}: {response.text}")
		
	return response.json()
	
def thingiverse_delete(endpoint, access_token):

	url = f'https://api.thingiverse.com/{endpoint}'

	response = requests.delete(
		url,
		params = { 'access_token': access_token },
		timeout = thingiverse_timeout
		)
		
	if response.status_code != 200:
		raise Exception(f"Call to {url} returned {response.status_code}: {response.text}")
		
	return response.json()
	
def thingiverse_get_image_ids(thing_id):

	json_images = thingiverse_get(f'things/{thing_id}/images', access_token)
	return [json_image['id'] for json_image in json_images]
	
def thingiverse_post_file(thing_id, file_path):
		
	dir = os.path.dirname(file_path)
	file_name = os.path.basename(file_path)

	print(f'Uploading {file_name} ...')

	response = thingiverse_post(
		f'things/{thing_id}/files',
		access_token,
		{ 'filename': file_name }
		)

	with open(file_path, 'rb') as obj:
		files = { 'file': (file_path, obj) }
		s3_response = requests.post(
			response['action'],
			data = response['fields'],
			files = files,
			allow_redirects = False,
			timeout = thingiverse_timeout
			)
		finalize_response = requests.post(
			response['fields']['success_action_redirect'],
			params = { 'access_token': access_token },
			timeout = thingiverse_timeout
			)
		print(finalize_response.text)
		
def thingiverse_clean(thing_id, artifact_type):

	for artifact in thingiverse_get(f'things/{thing_id}/{artifact_type}', access_token):
	
		artifact_id = artifact['id']
		artifact_name = artifact['name']
		
		print(f'Deleting {artifact_name} ...')
		thingiverse_delete(f'things/{thing_id}/{artifact_type}/{artifact_id}', access_token)
		
def run_test(access_token):

	thingiverse_delete(f'things/3198014/files/7668891', access_token)

globals = load_yaml_file('../src/main/scad/globals.yaml')

process_command(args)

