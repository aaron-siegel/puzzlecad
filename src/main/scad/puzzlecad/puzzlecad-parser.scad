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

/***** Puzzle specification *****/

// These functions are used to turn various kinds of input (Kaenel numbers and strings) into
// burr_info structs. A "burr_info struct" is the internal representation of a puzzle piece.
// It is a four-dimensional array such that:
// 
// burr_info[x][y][z][0]   gives the subcomponent at location [x,y,z] (0 if none)
// burr_info[x][y][z][1]   is a kv map of annotations (e.g., [["connect", "mz+"], ["clabel, "Ay-"]])

// Converts a flexible burr spec (argument to burr_piece) into a structured vector of information.

function to_burr_info(burr_spec) =
    let (burr_info = to_burr_info_base(burr_spec))
    [ for (x = [0:len(burr_info)-1])
        [ for (y = [0:len(burr_info[x])-1])
            [ for (z = [0:len(burr_info[x][y])-1])
                let (component = burr_info[x][y][z][0], aux = burr_info[x][y][z][1])
                let (new_component = ($unit_beveled && component != 0) ? component + x / 100 + y / 10000 + z / 1000000 : component)
                is_undef(aux) ? [new_component] : [new_component, aux]
            ]
        ]
    ];

function to_burr_info_base(burr_spec) =

    // If burr_spec is a number, then interpret it as a Kaenel number for a six-piece burr stick.
      is_num(burr_spec) ? burr_stick(burr_spec, 6)

    // If it's a single string, parse it.
    : is_string(burr_spec) ? strings_to_burr_info([burr_spec])

    // If it's a list of strings, parse them.
    : is_list(burr_spec) && is_string(burr_spec[0]) ? strings_to_burr_info(burr_spec)

    // Otherwise, assume it's already a burr_info struct.
    : burr_spec;

// Creates a burr_info struct given a Kaenel number.
    
function burr_stick(kaenel_number, length=6) = wrap(zyx_to_xyz(
    [ for (row = num_to_burr_info(kaenel_number-1))
        [ for (wedge = row)
            concat(copies((length-6) / 2, 1), wedge, copies((length-6) / 2, 1))
        ]
    ]));

// Converts a numeric burr id to a burr info vector; here "id" is one less than the burr id.

function num_to_burr_info(id) = [
      [[1, 1, 1-bit_of(id, 8), 1-bit_of(id, 9), 1, 1], [1, 1, 1-bit_of(id, 10), 1-bit_of(id, 11), 1, 1]],
      [[1, 1-bit_of(id,0), 1-bit_of(id, 1), 1-bit_of(id, 2), 1-bit_of(id, 3), 1],
        [1, 1-bit_of(id, 4), 1-bit_of(id, 5), 1-bit_of(id, 6), 1-bit_of(id, 7), 1]]
    ];

// Creates a burr_info struct given a Kaenel number for a board burr piece.

function board_burr(kaenel_number, length=6) = wrap(zyx_to_xyz(
    [ for (row = board_num_to_burr_info(kaenel_number-1))
        [ for (wedge = row)
            concat(copies((length-6) / 2, 1), wedge, copies((length-6) / 2, 1))
        ]
    ]));
        
function board_num_to_burr_info(id) = [
      [[1, 1, 1-bit_of(id, 8), 1-bit_of(id, 9), 1, 1],
        [1, 1-bit_of(id, 0), 1-bit_of(id, 1), 1-bit_of(id, 2), 1-bit_of(id, 3), 1],
        [1, 1-bit_of(id, 4), 1-bit_of(id, 5), 1-bit_of(id, 6), 1-bit_of(id, 7), 1],
        [1, 1, 1-bit_of(id, 10), 1-bit_of(id, 11), 1, 1]]
    ];

// Creates a burr string for a generalized Altekruse piece.

function generalized_altekruse(signature, outer_width = 1) =
    let (outer_str = mkstring(repeat(outer_width, "x")))
    [ str(
        outer_str,
        generalized_altekruse_row(signature, "df"),
        outer_str,
        "|",
        outer_str,
        generalized_altekruse_row(signature, "db"),
        outer_str
      ),
      str(
        outer_str,
        generalized_altekruse_row(signature, "uf"),
        outer_str,
        "|",
        outer_str,
        generalized_altekruse_row(signature, "ub"),
        outer_str
      )
    ];

function generalized_altekruse_row(signature, row_spec) =
    mkstring([ for (n = [0:len(signature)-1])
        if (signature[n] == row_spec[0] || signature[n] == row_spec[1])
            "xx"
        else
            ".."
    ]);

// Now the logic for parsing string arrays into burr_info structs:

function strings_to_burr_info(strings) =
    strings[0][0] == "{" ? strings_to_burr_info_2(substr(strings[0], 1, len(strings[0])-2), remove_from_list(strings, 0))
        : strings_to_burr_info_2(undef, strings);

function strings_to_burr_info_2(globals, strings) = zyx_to_xyz(
    [ for (str = strings)
        [ for (row = strtok(str, "|"))
            string_to_burr_info(globals, row)
        ]
    ]);

// Parse a single string into a 1x1xN substruct.
 
function string_to_burr_info(globals, string, i=0, result=[]) =
    i == len(string) ? result
        : let (component_id = index_of(component_ids, string[i]))
          component_id >= 0 ? string_to_burr_info_opt_suffix(globals, string, i, result, component_id)
        : string[i] == "#" ? string_to_burr_info_sharp(globals, string, i, result, 24)
        : assert(false, "Invalid burr specification.");
         
component_ids = ".abcdefghijklmnopqrstuvwxyz+";

// Parse a single character, with optional annotations.

valid_annotations = [ "connect", "clabel", "components", "label_orient", "label_text", "label_font", "label_hoffset", "label_voffset", "label_scale", "circle" ];

function string_to_burr_info_opt_suffix(globals, string, i, result, value) =
    substr(string, i+1, 1) == "{" ? string_to_burr_info_suffix(globals, string, i + 2, result, value)
        : string_to_burr_info_next(globals, string, i + 1, result, value);
        
function string_to_burr_info_sharp(globals, string, i, result, value) =
    assert(!is_undef(globals), "Invalid burr specification (\"#\" character used with no globals specified).")
    string_to_burr_info_next(globals, string, i + 1, result, value, parse_annotations(globals));
       
function string_to_burr_info_suffix(globals, string, i, result, value) =
    let (suffix_end = find_character(string, "}", i))
      suffix_end >= len(string) ? assert(false, "Invalid burr specification.")   // No closing brace
    : string_to_burr_info_next(globals, string, suffix_end + 1, result, value, parse_annotations(substr(string, i, suffix_end - i)));

function string_to_burr_info_next(globals, string, i, result, value, kvmap = undef) =
    string_to_burr_info(globals, string, i, concat(result, kvmap ? [[value, kvmap]] : [[value]]));

function parse_annotations(string, result = [], i = 0) =
    i >= len(string) ? result
    : let (next_separator = find_character(string, ",", i),
           next_annotation = parse_annotation(substr(string, i, next_separator - i)))
      assert(list_contains(valid_annotations, next_annotation[0]), str("Invalid annotation: ", next_annotation[0]))
      parse_annotations(string, concat(result, [next_annotation]), next_separator + 1);
      
function parse_annotation(string) =
    let (equals_index = find_character(string, "=", 0))
      equals_index == len(string) ? [string, true]     // No value specified; equivalent to key=true
    : let (key = substr(string, 0, equals_index))
        string[equals_index + 1] == "{" ? [key, substr(string, equals_index + 2, len(string) - equals_index - 3)]   // Value enclosed in braces
      : [key, substr(string, equals_index + 1, len(string) - equals_index - 1)]     // Value not enclosed in braces
    ;

function is_valid_connect_annotation(connect, allow_diagonal = true) =
    (
      (connect[0] == "m" || connect[0] == "f") &&
      (len(connect) == 3 && list_contains(cube_face_names, substr(connect, 1, 2)) ||
       len(connect) == 5 && is_valid_orientation(substr(connect, 1, 4)))
    ) || (
      allow_diagonal && connect[0] == "d" && (connect[1] == "m" || connect[1] == "f") &&
      (len(connect) == 6 && is_valid_orientation(substr(connect, 2, 4)) ||
       len(connect) == 7 && connect[6] == "~" && is_valid_orientation(substr(connect, 2, 4)))
    );

function wrap(burr_map) =
    [ for (layer = burr_map) [ for (row = layer) [ for (voxel = row) voxel[0] == undef ? [voxel] : voxel] ] ];
  
function bit_of(n, exponent) = floor(n / pow(2, exponent)) % 2;

function copies(n, burr) = n == 0 ? [] : concat(copies(n-1, burr), [burr]);
    
