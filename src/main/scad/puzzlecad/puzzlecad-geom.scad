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

/***** Cube Geometry *****/

cube_face_names = ["z-", "y-", "x-", "x+", "y+", "z+"];

directions = [[0, 0, -1], [0, -1, 0], [-1, 0, 0], [1, 0, 0], [0, 1, 0], [0, 0, 1]];

direction_map = [ for (face = [0:5]) [cube_face_names[face], directions[face]] ];

cube_face_rotations = [[180, 0, 0], [90, 0, 0], [0, -90, 0], [0, 90, 0], [-90, 0, 0], [0, 0, 0]];

cube_face_rotation_map = [ for (face = [0:5]) [cube_face_names[face], cube_face_rotations[face]] ];

cube_edge_names = [ ["y-", "x+", "y+", "x-"], ["z+", "x+", "z-", "x-"], ["y+", "z+", "y-", "z-"],
                    ["y+", "z-", "y-", "z+"], ["z-", "x+", "z+", "x-"], ["y+", "x+", "y-", "x-"] ];

unoriented_cube_edge_names = ["y+z+", "x-z+", "z+x+", "y+x-", "y+x+", "z+y-",
                              "z-y-", "x-y-", "z-x-", "x+z-", "x+y-", "y+z-"];

cube_edge_directions = [ for (n=[0:5]) [ for (k=[0:3])
    let (face_index = index_of(cube_face_names, cube_edge_names[n][k]))
    directions[face_index]
] ];

cube_edge_perp_directions = [ for (n=[0:5]) [ for (k=[0:3])
    let (face_index = index_of(cube_face_names, cube_edge_names[n][(k + 1) % 4]))
    directions[face_index]
] ];

cube_edge_pre_rotations = [[0, 0, 0], [0, 0, -90], [0, 0, 180], [0, 0, 90]];
    
edge_directions_map = [ for (n=[0:5], k=[0:3])
    [ str(cube_face_names[n], cube_edge_names[n][k]),
      [ lookup_kv(direction_map, cube_edge_names[n][k]), lookup_kv(direction_map, cube_edge_names[n][(k + 1) % 4]) ]
    ]
];

cube_vertex_names = [ for (n=[0:5]) [ for (k=[0:3])
    [ cube_edge_names[n][(k + 3) % 4], cube_edge_names[n][(k + 1) % 4] ]
] ];

cube_vertex_directions = [ for (n=[0:5]) [ for (k=[0:3]) [ for (vertex=[0:1])
    let (face_index = index_of(cube_face_names, cube_vertex_names[n][k][vertex]))
    directions[face_index]
] ] ];

function is_valid_orientation(string) =
    let (face_index = index_of(cube_face_names, substr(string, 0, 2)))
    len(string) == 4 && !is_undef(face_index) && list_contains(cube_edge_names[face_index], substr(string, 2, 2));

function mirrored_face_name(face_name) =
    cube_face_names[5 - index_of(cube_face_names, face_name)];

function cube_face_rotation(face_name) =
    len(face_name) < 2 ? undef :
    let (face_index = index_of(cube_face_names, substr(face_name, 0, 2)))
    cube_face_rotations[face_index];

function cube_edge_pre_rotation(edge_name) =
    len(edge_name) != 4 ? undef :
    let (face_name = substr(edge_name, 0, 2),
         edge_subname = substr(edge_name, 2, 2),
         face_index = index_of(cube_face_names, face_name),
         edge_index = index_of(cube_edge_names[face_index], edge_subname))
    cube_edge_pre_rotations[edge_index];

// name can be a face, face-edge, or orthoscheme name.
// TODO Pregenerate and cache these?
function bounding_box(name) =
    [ [ is_substr(name, "x+") ? 0 : -1/2,
        is_substr(name, "y+") ? 0 : -1/2,
        is_substr(name, "z+") ? 0 : -1/2 ],
      [ is_substr(name, "x-") ? 0 :  1/2,
        is_substr(name, "y-") ? 0 :  1/2,
        is_substr(name, "z-") ? 0 :  1/2 ] ];

// These are used for determining adjacencies for diagonal geometry.

fe_swaps = [ for (face = [0:5]) [ for (edge = [0:3])
    let (new_face = index_of(cube_face_names, cube_edge_names[face][edge]),
         new_edge = index_of(cube_edge_names[new_face], cube_face_names[face]))
    [new_face, new_edge]
] ];

face_mirrors = [ for (face = [0:5]) [ for (edge = [0:3])
    let (new_face = 5 - face,
         new_edge = index_of(cube_edge_names[new_face], cube_edge_names[face][edge]))
    [new_face, new_edge]
] ];

function cfv_adjacency(fev) =
    let (face = fev[0], edge = fev[1], vertex = fev[2])
    [face, (edge + (vertex == 1 ? 1 : 3)) % 4, 1 - vertex];

function cev_adjacency(fev) =
    let (face = fev[0], edge = fev[1], vertex = fev[2])
    let (swap = fe_swaps[face][edge])
    [ swap[0], swap[1], 1 - vertex];

function fev_mirror(fev) =
    let (face = fev[0], edge = fev[1], vertex = fev[2])
    let (mirror = face_mirrors[face][edge])
    [ mirror[0], mirror[1], 1 - vertex];

/***** Icosahedral Geometry *****/

phi = (1 + sqrt(5)) / 2;
