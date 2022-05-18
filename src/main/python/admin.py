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
import markdown

from glob import glob

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.remote.webdriver import WebDriver as RemoteWebDriver

# Get config from user dir

config_file = os.path.expanduser("~/.puzzlecad")
config = configparser.ConfigParser()
config.read(config_file)

client_id = config['puzzlecad']['ClientId']
client_secret = config['puzzlecad']['ClientSecret']
openscad_bin = config['puzzlecad']['OpenscadBin']
access_token = config['puzzlecad']['AccessToken']
thingiverse_timeout = 60

libs_dir = '../scad'
output_dir = '../../../out'
os.environ['OPENSCADPATH'] = libs_dir

parser = argparse.ArgumentParser()
parser.add_argument('command')
parser.add_argument('--notests', action="store_true", help='do not run tests when bundling puzzlecad')
parser.add_argument('cmdargs', nargs='*')

args = parser.parse_args()

def process_command(args):

	if args.command == 'get-token':

		get_access_token()

	elif args.command == 'build':
	
		build_stls(args.cmdargs[0])
		
	elif args.command == "bundle-puzzlecad":

		run_tests = not args.notests
		bundle_puzzlecad(args.cmdargs[0], run_tests)

	elif args.command == 'upload-puzzlecad':

		run_tests = not args.notests
		upload_puzzlecad(args.cmdargs[0], run_tests)

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

	elif args.command == 'open-printables-session':

		driver = webdriver.Chrome()
		driver.get("https://www.printables.com/model/171148/edit")
		print(driver.session_id + " " + driver.command_executor._url)
		return driver

	elif args.command == "update-printables-model":

		update_printables_model(args.cmdargs[0], args.cmdargs[1], args.cmdargs[2], '' if (len(args.cmdargs) < 4) else args.cmdargs[3])
		
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
	description = substitute_globals(contents['description'], thing_name, 'thingiverse')
	print(description)
	
def delete_thing(access_token, thing_id):

	thingiverse_delete(f'things/{thing_id}', access_token)

def update_thing(access_token, thing_name, targets_str):

	targets = targets_str.split(',')

	if 'files' in targets:
		# Build the STLs first before uploading anything
		build_stls(thing_name)

	yaml_path = resolve_thing(thing_name)
	contents = load_yaml_file(yaml_path)
	name = contents['name']
	thing_id = contents['thing-id']
	description = substitute_globals(contents['description'], thing_name, 'thingiverse')
	
	print(f'Updating thing "{name}" from file {yaml_path} ...')

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
		dir = os.path.dirname(yaml_path)
		scad_path = root + ".scad"
		abs_scad_path = os.path.abspath(scad_path)
		scad_file = os.path.basename(scad_path)
		scad_root = os.path.splitext(scad_file)[0]
		
		thingiverse_post_file(thing_id, scad_path)

		aux_files = contents['aux_files'] if 'aux_files' in contents else []

		for aux_file in aux_files:

			thingiverse_post_file(thing_id, os.path.join(dir, aux_file))
		
		configurations = contents['configurations'] if 'configurations' in contents else [{'name': '', 'code': '', 'targets': ''}]
		
		for configuration in configurations:
			configuration_targets = contents['targets'] if configuration['targets'] == '' else configuration['targets']
			for stl_target in configuration_targets:
			
				stl_target_dashes = stl_target.replace("_", "-")
				stl_target_suffix = '' if stl_target == "--" else '.' + stl_target.replace("_", "-")
				configuration_suffix = '' if configuration['name'] == '' else '.' + configuration['name'] if stl_target_suffix == '' else '-' + configuration['name']
				modularized_name = f'{scad_root}{stl_target_suffix}{configuration_suffix}'
				extension = 'zip' if 'pages' in configuration else 'stl'
				stl_target_path = f'{output_dir}/{modularized_name}.{extension}'
				thingiverse_post_file(thing_id, stl_target_path)

def resolve_thing(thing_name):

	#print(f'{libs_dir}/**/{thing_name}.yaml')
	yaml_path = glob(f'{libs_dir}/**/{thing_name}.yaml', recursive = True)
	
	if len(yaml_path) == 0:
		raise Exception(f'Thing not found: {thing_name}')
		
	return yaml_path[0]

###### printables.com instrumentation

def create_driver_session(session_id, executor_url):

	# Save the original function, so we can revert our patch
	org_command_execute = RemoteWebDriver.execute

	def new_command_execute(self, command, params=None):
		if command == "newSession":
			# Mock the response
			return {'success': 0, 'value': None, 'sessionId': session_id}
		else:
			return org_command_execute(self, command, params)

	# Patch the function before creating the driver object
	RemoteWebDriver.execute = new_command_execute

	new_driver = webdriver.Remote(command_executor=executor_url, desired_capabilities={})
	new_driver.session_id = session_id

	# Replace the patched function with original function
	RemoteWebDriver.execute = org_command_execute

	return new_driver

def set_element(driver, bySpec, text):
	element = WebDriverWait(driver, 10).until(
		EC.presence_of_element_located(bySpec)
	)
	element.clear()
	element.send_keys(text)

def update_printables_model(session_id, executor_url, thing_name, targets_str):

	targets = targets_str.split(',')

	if 'files' in targets:
		# Build the STLs first before uploading anything
		build_stls(thing_name)

	yaml_path = resolve_thing(thing_name)
	dir = os.path.dirname(yaml_path)
	contents = load_yaml_file(yaml_path)
	name = contents['name']
	model_id = contents['printables-model-id']
	description = substitute_globals(contents['description'], thing_name, 'printables')
	summary = contents['summary'] if 'summary' in contents else description.partition('\n')[0]

	split_name = name.split(" - ")
	description_title = f'## {name}' if len(split_name) <= 1 else f'## {split_name[0]}\n\n### {split_name[1]}'
	expanded_description = f'\n{description_title}\n{description}'
	revised_description = re.sub('\n#', '\n##', expanded_description)

	driver = create_driver_session(session_id, executor_url)
	model_url = f"https://www.printables.com/model/{model_id}"

	print(f'Updating printables model "{name}" from file {yaml_path} at {model_url} ...')

	driver.get(f"{model_url}/edit")

	set_element(driver, (By.ID, "print-name"), name)
	set_element(driver, (By.ID, "summary"), summary)
	category_element = driver.find_element(By.XPATH, "//ng-select[@formcontrolname = 'category']")
	category_element.click()
	WebDriverWait(driver, 2).until(EC.presence_of_element_located((By.XPATH, "//div[@role='option'][normalize-space(.)='Puzzles & Brain-teasers']")))
	item_element = driver.find_element(By.XPATH, "//div[@role='option'][normalize-space(.)='Puzzles & Brain-teasers']")
	item_element.click()
	#license_element = driver.find_element(By.XPATH, "//ng-select[@formcontrolname = 'license']")
	#license_element.click()
	#WebDriverWait(driver, 2).until(EC.presence_of_element_located((By.XPATH, "//span[normalize-space(.)='Creative Commons — Attribution  — Noncommercial  —  NoDerivatives']")))
	#license_item_element = driver.find_element(By.XPATH, "//span[normalize-space(.)='Creative Commons — Attribution  — Noncommercial  —  NoDerivatives']")
	#license_item_element.click()

	script = f"""
	  const domEditableElement = document.querySelector( '.ck-editor__editable' );
	  const editorInstance = domEditableElement.ckeditorInstance;
	  editorInstance.setData(`{markdown_to_html(revised_description)}`);"""
	driver.execute_script(script)

	if 'images' in targets or 'files' in targets:

		images_zip_name = f"~/_images-upload-{thing_name}.zip"
		files_zip_name = f"~/_files-upload-{thing_name}.zip"

		if 'images' in targets:
			images_str = " ".join(os.path.join(dir, filename) for filename in contents['images'])
			os.system(f"zip -j {images_zip_name} {images_str}")

		if 'files' in targets:
			paths = prepare_files(yaml_path, contents)
			paths_str = " ".join(paths)
			os.system(f"zip -j {files_zip_name} {paths_str}")

		print(f'Ready to upload.')
		browse_button = driver.find_element(By.XPATH, "//label[normalize-space(.)='Browse']")
		browse_button.click()
		WebDriverWait(driver, 120).until(EC.presence_of_element_located((By.CLASS_NAME, "processing-info")))
		WebDriverWait(driver, 120).until(EC.invisibility_of_element_located((By.CLASS_NAME, "processing-info")))
		print('Done uploading! Reorganize photos now & publish manually.')

		if 'images' in targets:
			os.system(f"rm {images_zip_name}")

		if 'files' in targets:
			os.system(f"rm {files_zip_name}")

	if not targets:
		# Publish automatically if no images/files specified.
		publish_element = driver.find_element(By.XPATH, "//button[normalize-space(.)='Save draft' or normalize-space(.)='Publish now']")
		publish_element.click()
		WebDriverWait(driver, 30).until(EC.presence_of_element_located((By.XPATH, "//span[normalize-space(.)='Download']")))

def markdown_to_html(text):
	return markdown.markdown(text)

def prepare_files(yaml_path, contents):

	paths = []

	root = os.path.splitext(yaml_path)[0]
	dir = os.path.dirname(yaml_path)
	scad_path = root + ".scad"
	paths.append(scad_path)
	scad_file = os.path.basename(scad_path)
	scad_root = os.path.splitext(scad_file)[0]

	aux_files = contents['aux_files'] if 'aux_files' in contents else []
	for aux_file in aux_files:
		paths.append(os.path.join(dir, aux_file))

	configurations = contents['configurations'] if 'configurations' in contents else [{'name': '', 'code': '', 'targets': ''}]

	for configuration in configurations:
		configuration_targets = contents['targets'] if configuration['targets'] == '' else configuration['targets']
		for stl_target in configuration_targets:

			stl_target_suffix = '' if stl_target == "--" else '.' + stl_target.replace("_", "-")
			configuration_suffix = '' if configuration['name'] == '' else '.' + configuration['name'] if stl_target_suffix == '' else '-' + configuration['name']
			modularized_name = f'{scad_root}{stl_target_suffix}{configuration_suffix}'
			extension = 'zip' if 'pages' in configuration else 'stl'
			stl_target_path = f'{output_dir}/{modularized_name}.{extension}'
			paths.append(stl_target_path)

	return paths

##### Basic utilities

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
			build_stl_target(scad_path, stl_target, configuration)
		
def build_stl_target(scad_path, stl_target, configuration):

	os.makedirs(output_dir, exist_ok = True)

	abs_scad_path = os.path.abspath(scad_path)
	scad_file = os.path.basename(scad_path)
	scad_root = os.path.splitext(scad_file)[0]

	stl_target_suffix = '' if stl_target == "--" else '.' + stl_target.replace("_", "-")
	
	configuration_suffix = '' if configuration['name'] == '' else '.' + configuration['name'] if stl_target_suffix == '' else '-' + configuration['name']
	configuration_code = configuration['code']
	
	target_func = '' if stl_target == '--' else f'{stl_target}();';
	
	modularized_base_name = f'{scad_root}{stl_target_suffix}{configuration_suffix}'
	
	if 'pages' in configuration:
		page_count = configuration['pages']
		for page in range(1, page_count + 1):
			preamble_code = f'{configuration_code}\n$page = {page};\n{target_func}\n'
			build_stl(abs_scad_path, preamble_code, f'{modularized_base_name}.{page}')
		zip_stls(modularized_base_name, page_count)
			
	else:
		preamble_code = f'{configuration_code}\n{target_func}\n'
		build_stl(abs_scad_path, preamble_code, modularized_base_name)

def build_stl(abs_scad_path, preamble_code, modularized_name):
	
	stl_target_path = f'{output_dir}/{modularized_name}.stl'
	temp_scad_path = f'{output_dir}/{modularized_name}.scad'
	
	if os.path.exists(stl_target_path) and os.path.getmtime(stl_target_path) >= os.path.getmtime(abs_scad_path):
	
		print(f'  Target {modularized_name} is up to date.')
		
	else:
	
		print(f'  Building target {modularized_name} ...')
		
		script = f'include <{abs_scad_path}>\n\n{preamble_code}\n'
	
		with open(temp_scad_path, 'w') as file:
			file.write(script)
		
		exit_status = os.system(f'{openscad_bin} -o {stl_target_path} {temp_scad_path}')
	
		if exit_status != 0:
			raise Exception(f'Failed on target {modularized_name}.')

def zip_stls(modularized_base_name, page_count):
	
	zip_target_path = f'{output_dir}/{modularized_base_name}.zip'
	stl_paths = [f'{output_dir}/{modularized_base_name}.{page}.stl' for page in range(1, page_count + 1)]
	
	if os.path.exists(zip_target_path) and all(os.path.getmtime(zip_target_path) >= os.path.getmtime(stl_path) for stl_path in stl_paths):
	
		print(f'  Target {zip_target_path} is up to date.')
		
	else:
	
		os.system(f'rm -f {zip_target_path}')
		stl_paths_str = ' '.join(stl_paths)
		exit_status = os.system(f'zip -j {zip_target_path} {stl_paths_str}')

		if exit_status != 0:
			raise Exception(f'Failed on target {modularized_base_name}.')

def substitute_globals(description, thing_name, site):

	# This is somewhat inefficient but should be fine at small scale.
	
	mentioned_globals = re.findall('\$\{(.*?)\}', description)
	for key in mentioned_globals:
		if key == 'name':
			replacement = thing_name
		elif key.startswith('link:'):
			link_name = key[5:]
			link_yaml_path = resolve_thing(link_name)
			link_contents = load_yaml_file(link_yaml_path)
			link_title = link_contents['name']
			link_split_title = link_title.split(" - ")
			if site == 'thingiverse':
				link_thing_id = link_contents['thing-id']
				replacement = f'[{link_split_title[0]}](https://www.thingiverse.com/thing:{link_thing_id})'
			elif site == 'printables':
				link_model_id = link_contents['printables-model-id']
				replacement = f'[{link_split_title[0]}](https://www.printables.com/model/{link_model_id})'
			else:
				raise Exception(f'Unknown site: {site}')
		elif key in globals:
			replacement = globals[key]
		else:
			raise Exception('Unknown global: ${' + key + '}')
		description = description.replace('${' + key + '}', replacement)

	return description

def bundle_puzzlecad(version, run_tests = True):

	# Rudimentary poor-excuse-for-a-build-script,
	# but I'm trying to keep things super simple right now

	if (run_tests):
		exit_status = run_puzzlecad_tests()
		if (exit_status != 0):
			return
	
	print(f'Bundling puzzlecad version {version} ...')
	
	os.makedirs(f'{output_dir}/dist', exist_ok = True)

	print('Building java components ...')
	os.makedirs(f'{output_dir}/java', exist_ok = True)
	result = subprocess.run(
		['javac', 'org/puzzlecad/XmpuzzleToScad.java', '-d', '../../../out/java', '-source', '1.6', '-target', '1.6'],
		cwd = '../java'
		)
	if result.returncode != 0:
		print('Failed!')
		return
		
	print('Building jar ...')
	result = subprocess.run(
		['jar', 'cfm', '../dist/bt2scad.jar', '../../src/main/java/manifest', '.'],
		cwd = f'{output_dir}/java'
		)
	if result.returncode != 0:
		print('Failed!')
		return

	print('Copying to distribution dir ...')
	shutil.copy2(f'{libs_dir}/puzzlecad.scad', f'{output_dir}/dist')
	shutil.copy2(f'{libs_dir}/puzzlecad-examples.scad', f'{output_dir}/dist')
	shutil.copy2(f'{libs_dir}/dist/half-hour-example.scad', f'{output_dir}/dist')
	if (os.path.exists(f'{output_dir}/dist/puzzlecad')):
		shutil.rmtree(f'{output_dir}/dist/puzzlecad')
	shutil.copytree(
		f'{libs_dir}/puzzlecad',
		f'{output_dir}/dist/puzzlecad',
		ignore = shutil.ignore_patterns('.*')		# Ignore .DS_Store and such cruft
	)
	
	print('Creating archive ...')
	dist_files = [ os.path.relpath(file, f'{output_dir}/dist') for file in glob(f'{output_dir}/dist/*') ]
	if (os.path.exists(f'{output_dir}/puzzlecad-{version}.zip')):
		os.remove(f'{output_dir}/puzzlecad-{version}.zip')
	subprocess.run(
		['zip', '-r', f'../puzzlecad-{version}.zip'] + dist_files,
		cwd = f'{output_dir}/dist'
		)
	if result.returncode != 0:
		print('Failed!')
		return

	print('Done!')

def run_puzzlecad_tests():

	print('Running puzzlecad tests ...')
	exit_status = os.system(f'{openscad_bin} -o {output_dir}/puzzlecad-tests.stl {libs_dir}/puzzlecad-tests.scad')
	if exit_status == 0:
		print('Tests succeeded.')
	else:
		print('Tests failed!')
	return exit_status

def upload_puzzlecad(version, run_tests = True):

	bundle_puzzlecad(version, run_tests)
	thingiverse_post_file(3198014, f'{output_dir}/puzzlecad-{version}.zip')

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

globals = load_yaml_file(f'{libs_dir}/globals.yaml')

result = process_command(args)
