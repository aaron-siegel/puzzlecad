/* ====================================================================

  This is puzzlecad, an OpenSCAD library for modeling mechanical
  puzzles. It is provided as part of the Printable Puzzle Project:
  https://puzzlehub.org/ppp

  To obtain the latest version of puzzlecad:
  https://www.thingiverse.com/thing:3198014

  Puzzlecad code repository:
  https://github.com/aaron-siegel/puzzlecad

  puzzlecad is (c) 2019-2022 Aaron Siegel and is distributed under
  the MIT license. This means you may use or modify puzzlecad for any
  purposes, including commercial purposes, provided that you include
  the attribution "puzzlecad is (c) 2019-2022 Aaron Siegel" in any
  distributions or derivatives of puzzlecad, along with a copy of
  the MIT license.

  For details of this license, please refer to the LICENSE-MIT file
  distributed with puzzlecad, or visit:
  https://opensource.org/licenses/MIT

  NOTE THAT WHILE THE PUZZLECAD LIBRARY IS RELEASED UNDER THE MIT
  LICENSE, INDIVIDUAL PUZZLE DESIGNS (INCLUDING VARIOUS DESIGNS THAT
  ARE STORED IN THE PUZZLECAD GITHUB REPO) ARE SHARED UNDER A MORE
  RESTRICTIVE LICENSE. You may not use copyrighted puzzle designs for
  commercial purposes without explicit permission from the copyright
  holder(s).

==================================================================== */

/******* Auto-layout capabilities *******/

function auto_layout_plate(burr_infos, next_joint_letter = 0, allowed_rotations = layout_rotation_dirs, i = 0, result = []) =
      i >= len(burr_infos) ? result
    : let (
          piece_layout_info = auto_layout(burr_infos[i], next_joint_letter, allowed_rotations),
          piece_layout = piece_layout_info[0],
          new_next_joint_letter = piece_layout_info[1]
      )
      auto_layout_plate(burr_infos, new_next_joint_letter, allowed_rotations, i + 1, concat(result, piece_layout));

// Returns a structure [result, next_joint_letter]

function auto_layout(burr_info, next_joint_letter = 0, allowed_rotations = layout_rotation_dirs) =
    let (
        layers = zyx_to_xyz(burr_info),
        layout = auto_layout_r(layers, next_joint_letter, allowed_rotations),
        new_components = layout[0],
        new_next_joint_letter = layout[1])
    [ [ for (component = new_components) zyx_to_xyz(component) ], new_next_joint_letter ];
        
function auto_layout_r(layers, next_joint_letter, allowed_rotations) =
    let (
        rotated_layers = [ for (dir = allowed_rotations) zyx_to_xyz(rotate_burr_info(zyx_to_xyz(layers), dir)) ],
        layout_components = [ for (rl = rotated_layers) dissect_components(rl, next_joint_letter, allowed_rotations) ],
        badness_scores = [ for (components_info = layout_components) let (components = components_info[0])
            1e6 * sum([ for (component = components) multi_female_joint_count(component) ])
                + 1e4 * len(components)
                + 1e2 * sum([ for (component = components) occupied_layer_count(component) ])
                + sum([ for (component = components) zminus_connector_count(component) ])
        ],
        index_of_optimum = argmin(badness_scores)
    )
    layout_components[index_of_optimum];

function dissect_components(layers, next_joint_letter, allowed_rotations) =
    let (first_occupied_layer = first_occupied_layer(layers))
      first_occupied_layer >= len(layers) ? [[], next_joint_letter]
    : let (first_uncovered_layer = first_uncovered_layer(layers, first_occupied_layer + 1))
      let (base_component = [
          for (z = [0:len(layers)-1])
          if (z < first_uncovered_layer - 1)
              layers[z]
          else if (z == first_uncovered_layer - 1)
              auto_layout_joints(layers, next_joint_letter, z, "m")
          else
              to_blank_layer(layers[z])
          ])
      first_uncovered_layer >= len(layers) ? [[base_component], next_joint_letter]
      : let (new_next_joint_letter = next_joint_letter + joint_location_count(layers, first_uncovered_layer))
        let (remainder = first_uncovered_layer >= len(layers) ? [] : [
            for (z = [0:len(layers)-1])
            if (z < first_uncovered_layer)
                to_blank_layer(layers[z])
            else if (z == first_uncovered_layer)
                auto_layout_joints(layers, next_joint_letter, z, "f")
            else
                layers[z]
            ])
        let (remainder_layout = auto_layout_r(
                remainder,
                new_next_joint_letter,
                list_contains(allowed_rotations, "z-") ? ["z+", "z-"] : ["z+"]
            ))
        [concat([base_component], remainder_layout[0]), remainder_layout[1]];

function first_occupied_layer(layers, z = 0) =
      z >= len(layers) ? z :
      layer_volume(layers[z]) > 0 ? z : first_occupied_layer(layers, z + 1);
            
function occupied_layer_count(layers) =
      sum([ for (z = [0:len(layers)-1]) layer_volume(layers[z]) > 0 ? 1 : 0]);
      
function layer_volume(layer) =
      sum([ for (y = [0:len(layer)-1], x = [0:len(layer[y])-1]) layer[y][x][0] > 0 ? 1 : 0 ]);
    
function first_uncovered_layer(layers, z = 1) =
      z >= len(layers) || overhang_location_count(layers, z) > 0 ? z
    : first_uncovered_layer(layers, z + 1);
      
function overhang_location_count(layers, z) =
    sum([ for (y = [0:len(layers[z])-1], x = [0:len(layers[z][y])-1])
        layers[z][y][x][0] > 0 && !(layers[z-1][y][x][0] > 0) ? 1 : 0
    ]);
      
function joint_location_count(layers, z) =
    sum([ for (y = [0:len(layers[z])-1], x = [0:len(layers[z][y])-1])
        is_joint_location(layers, -1, x, y, z) ? 1 : 0
    ]);

function multi_female_joint_count(layers) =
    sum([ for (layer = layers, yslice = layer, cell = yslice)
          let (connect = lookup_kv(cell[1], "connect"))
          if (female_joint_count(connect, false) > 1)
              1
          else
              0
        ]);

function zminus_connector_count(layers) =
    sum([ for (layer = layers, yslice = layer, cell = yslice)
          let (connect = lookup_kv(cell[1], "connect"))
          female_joint_count(connect, true)
        ]);

function female_joint_count(connect_str, count_zminus_only) =
    is_undef(connect_str) ? 0 :
    let (connects = strtok(connect_str, ","))
    sum([ for (connect = connects)
          if (count_zminus_only && substr(connect, 0, 3) == "fz-" ||
              !count_zminus_only && connect[0] == "f")
              1
          else
              0
        ]);

function auto_layout_joints(layers, next_joint_letter, z, type) =
    type == "f" && z == 0 || type == "m" && z == len(layers)-1 ? layers[z] :
    let (joint_locations =
       [ for (y = [0:len(layers[z])-1], x = [0:len(layers[z][y])-1])
           if (is_joint_location(layers, type == "f" ? -1 : 1, x, y, z))
               [x, y]
       ])
    [ for (y = [0:len(layers[z])-1])
        [ for (x = [0:len(layers[z][y])-1])
            let (joint_index = index_of(joint_locations, [x, y]))
                if (joint_index == -1)
                    layers[z][y][x]
                else
                    let (new_aux = add_connect_to_aux(layers[z][y][x][1], type == "f" ? "fz-y+" : "mz+y+", auto_joint_letters[(next_joint_letter + joint_index) % 50]))
                    [layers[z][y][x][0], new_aux]
        ]
    ];

// Rules for joint placement: add a joint provided that
// (1) [x, y] is a contact point between layer z and layer z + offset; and
// (2) [x, y] is a "contact corner", meaning that both:
//     (a) At least one of [x, y-1] or [x, y+1] is NOT a contact point; and
//     (b) At least one of [x-1, y] or [x+1, y] is NOT a contact point.

function is_joint_location(layers, offset, x, y, z) =
      layers[z][y][x][0] > 0 && layers[z + offset][y][x][0] > 0 &&
    !(is_nonzero(layers[z][y-1][x][0]) && is_nonzero(layers[z][y+1][x][0]) && is_nonzero(layers[z + offset][y-1][x][0]) && is_nonzero(layers[z + offset][y+1][x][0])) &&
    !(is_nonzero(layers[z][y][x-1][0]) && is_nonzero(layers[z][y][x+1][0]) && is_nonzero(layers[z + offset][y][x-1][0]) && is_nonzero(layers[z + offset][y][x+1][0]));

function to_blank_layer(layer) =
    [ for (yslice = layer)
        [ for (cell = yslice)
            len(cell) == 1 ? [0] :
            let (new_aux = clean_aux(cell[1]))
            len(new_aux) == 0 ? [0] : [ 0, new_aux ]
        ]
    ];

function clean_aux(aux, i = 0) =
      i >= len(aux) ? []
    : aux[i][0] == "connect" || aux[i][0] == "clabel" ? clean_aux(aux, i + 1)
    : concat([aux[i]], clean_aux(aux, i + 1));

function add_connect_to_aux(aux, connect, clabel) =
    let (
        cur_connect = lookup_kv(aux, "connect"),
        cur_clabel = lookup_kv(aux, "clabel"),
        new_connect = is_undef(cur_connect) ? connect : str(cur_connect, ",", connect),
        new_clabel = is_undef(cur_clabel) ? clabel : str(cur_clabel, ",", clabel)
    )
    put_kv(put_kv(aux, ["connect", new_connect]), ["clabel", new_clabel]);

function rotate_burr_info(burr_info, orient) =
    rotate_burr_info_markup(rotate_burr_info_geom(burr_info, orient), orient);

function rotate_burr_info_geom(burr_info, orient) =
    let (xlen = len(burr_info), ylen = len(burr_info[0]), zlen = len(burr_info[0][0]))
      orient == "z+" ? burr_info
    : orient == "z-" ? [ for (x = [xlen-1:-1:0]) [ for (y = [0:ylen-1]) [ for (z = [zlen-1:-1:0]) burr_info[x][y][z] ] ] ]
    : orient == "x+" ? [ for (z = [zlen-1:-1:0]) [ for (y = [0:ylen-1]) [ for (x = [0:xlen-1]) burr_info[x][y][z] ] ] ]
    : orient == "x-" ? [ for (z = [0:zlen-1]) [ for (y = [0:ylen-1]) [ for (x = [xlen-1:-1:0]) burr_info[x][y][z] ] ] ]
    : orient == "y+" ? [ for (x = [0:xlen-1]) [ for (z = [zlen-1:-1:0]) [ for (y = [0:ylen-1]) burr_info[x][y][z] ] ] ]
    : orient == "y-" ? [ for (x = [0:xlen-1]) [ for (z = [0:zlen-1]) [ for (y = [ylen-1:-1:0]) burr_info[x][y][z] ] ] ]
    : assert(false, str("Invalid orientation: ", orient));
    
function rotate_burr_info_markup(burr_info, orient) =
    [ for (xslice = burr_info)
        [ for (yslice = xslice)
            [ for (cell = yslice)
                len(cell) == 1 ? cell :
                [ cell[0], [ for (kv = cell[1]) rotate_markup_entry(kv, orient) ] ]
            ]
        ]
    ];

function rotate_markup_entry(kv, orient) =
    [ kv[0],
        kv[0] == "connect" ? rotate_connects(kv[1], orient)
      : kv[0] == "label_orient" ? str(rotate_orient(substr(kv[1], 0, 2), orient), rotate_orient(substr(kv[1], 2, 2), orient))
      : kv[1]
    ];

function rotate_connects(value, orient) =
    let (
        connects = strtok(value, ","),
        rotated_connects = [ for (connect = connects) rotate_connect(connect, orient) ]
    )
    mkstring(rotated_connects, ",");
        
function rotate_connect(value, orient) =
      len(value) == 3 ? str(value[0], rotate_orient(substr(value, 1, 2), orient))
    : len(value) == 5 ? str(value[0], rotate_orient(substr(value, 1, 2), orient), rotate_orient(substr(value, 3, 2), orient))
    : value;

function rotate_orient(dir, orient) =
    lookup_kv(reorient_perm, orient)[
        index_of(layout_rotation_dirs, dir)
    ];

layout_rotation_dirs = ["z+", "z-", "x+", "x-", "y+", "y-"];
                
reorient_perm = [
    [ "z+", ["z+", "z-", "x+", "x-", "y+", "y-"] ],
    [ "z-", ["z-", "z+", "x-", "x+", "y+", "y-"] ],
    [ "x+", ["x-", "x+", "z+", "z-", "y+", "y-"] ],
    [ "x-", ["x+", "x-", "z-", "z+", "y+", "y-"] ],
    [ "y+", ["y-", "y+", "x+", "x-", "z+", "z-"] ],
    [ "y-", ["y+", "y-", "x+", "x-", "z-", "z+"] ]
];

auto_joint_letters = "ABCDEFGHJKLMNOPQRSTUVWXYZabcdefghjklmnopqrstuvwxyz";
