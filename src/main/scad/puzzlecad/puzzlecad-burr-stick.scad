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

// Creates a burr_info struct given a Kaenel number.
    
function burr_stick(kaenel_number, stick_length = 6, add_stamp = false) =
    let (unstamped_burr_info =
        wrap(zyx_to_xyz(
            [ for (layer = kaenel_number_to_burr_info(kaenel_number))
                [ for (row = layer)
                    concat(copies((stick_length - 4) / 2, 1), row, copies((stick_length - 4) / 2, 1))
                ]
            ]
        ))
    )
    add_stamp ? add_burr_stick_stamp(unstamped_burr_info, str(kaenel_number)) : unstamped_burr_info;

// Converts a Kaenel number to a three-dimensional bit vector. The bit vector follows the standard
// definition of Kaenel number "carve-outs". For discussion, see:
// http://robspuzzlepage.com/interlocking.htm#identifying

function kaenel_number_to_burr_info(kaenel_number) =
    let (bitmask = kaenel_number - 1)
    [
      [[1 - bit_of(bitmask, 12), 1 - bit_of(bitmask,  8), 1 - bit_of(bitmask,  9), 1 - bit_of(bitmask, 13)],
       [1 - bit_of(bitmask, 14), 1 - bit_of(bitmask, 10), 1 - bit_of(bitmask, 11), 1 - bit_of(bitmask, 15)]],
      [[1 - bit_of(bitmask, 0) , 1 - bit_of(bitmask,  1), 1 - bit_of(bitmask,  2), 1 - bit_of(bitmask, 3) ],
       [1 - bit_of(bitmask, 4) , 1 - bit_of(bitmask,  5), 1 - bit_of(bitmask,  6), 1 - bit_of(bitmask, 7) ]]
    ];

// Stamps the end of a burr stick, inserting a label at the appropriate place in a burr_info struct.

function add_burr_stick_stamp(burr_info, stamp) =
    replace_in_array(burr_info, [0, 0, 0], [1, [
        ["label_text", stamp],
        ["label_orient", "x-y-"],
        ["label_hoffset", "-0.5"],
        ["label_voffset", "0.5"],
        ["label_scale", "0.538"]        // The curious constant 0.538 is for backward compatibility
    ]]);

module burr_stick_plate(ids, stick_length = 6) {

    page = [ for (id = ids)
        [id, opt_split(add_kaenel_number(burr_stick(ids[n], stick_length), ids[n]), auto_joint_letters[n - first_index])]
    ];
    labels = [for (pieces = page, n = [0:len(pieces[1])-1]) n == 0 ? str(pieces[0]) : undef];
    sticks = [for (pieces = page, piece = pieces[1]) piece];
    burr_plate(sticks, $burr_inset = inset, $burr_bevel = 0.5, $burr_outer_x_bevel = 1.75);
    
}

// Logic for custom-splitting a burr stick into printable components. Unlike puzzlecad's
// $auto_layout capability, this will preserve the ends of the stick to ensure a clean
// appearance.

function opt_split_burr_stick(stick, joint_label = " ") =
    is_simply_printable(stick) ? [stick] : [lower_split(stick, joint_label), upper_split(stick, joint_label)];

function is_simply_printable(stick, x = 0, y = 0) =
    y == len(stick[0]) ? true :
    x == len(stick) ? is_simply_printable(stick, 0, y + 1) :
    (stick[x][y][1][0] == 0 || stick[x][y][0][0] > 0) && is_simply_printable(stick, x + 1, y);

function lower_split(stick, joint_label) =
    let (xmin = len(stick) / 2 - 2, xmax = len(stick) / 2 + 2)
    [ for (x = [0:len(stick)-1])
    [ for (y = [0:1])
    [ for (z = [0:1])
          x >= xmin && x < xmax && burr_stick_is_connected_to_overhang(stick, x, y)
        ? (z == 0 && stick[x][y][z][0] == 1 ? [1, [["connect", "mz+y+"], ["clabel", joint_label]]] : [0])
        : stick[x][y][z]
    ]]];
            
function upper_split(stick, joint_label) =
    let (xmin = len(stick) / 2 - 2, xmax = len(stick) / 2 + 2)
    [ for (x = [xmin:xmax-1])
    [ for (y = [0:1])
          burr_stick_is_connected_to_overhang(stick, x, y)
        ? (stick[x][y][0][0] == 1 ? [[1, [["connect", "fz-y+"], ["clabel", joint_label]]]] : [[1]])
        : [[0]]
    ]];

function burr_stick_is_connected_to_overhang(stick, x, y, visited = []) =
      list_contains(visited, [x, y]) || x < len(stick) / 2 - 2 || x > len(stick) / 2 + 2 || y < 0 || y > 1 || stick[x][y][1][0] == 0 ? false
    : stick[x][y][0][0] == 0 ? true
    : let (updated_visited = add_to_list(visited, [x, y]))
         burr_stick_is_connected_to_overhang(stick, x - 1, y, updated_visited)
      || burr_stick_is_connected_to_overhang(stick, x + 1, y, updated_visited)
      || burr_stick_is_connected_to_overhang(stick, x, 1 - y, updated_visited);
