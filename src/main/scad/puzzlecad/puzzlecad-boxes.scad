/* ====================================================================

  This is puzzlecad, an OpenSCAD library for modeling mechanical
  puzzles. It is provided as part of the Printable Puzzle Project:
  https://puzzlehub.org/ppp

  To obtain the latest version of puzzlecad:
  https://www.thingiverse.com/thing:3198014

  Puzzlecad code repository:
  https://github.com/aaron-siegel/puzzlecad

  puzzlecad is (c) 2019-2020 Aaron Siegel and is distributed under
  the MIT license. This means you may use or modify puzzlecad for any
  purposes, including commercial purposes, provided that you include
  the attribution "puzzlecad is (c) 2019-2020 Aaron Siegel" in any
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

$box_thickness = 6;
$box_inset = 0.25;
$box_use_full_perimeter = false;

module packing_box(
    dim,
    bottom = "solid",
    front = "solid",
    left = "solid",
    right = "solid",
    back = "solid",
    top = "empty",
    split_cap = true
    )
    {

    scale_vec = vectorize($burr_scale);
    inset_vec = vectorize($box_inset);
    thickness_vec = vectorize($box_thickness);
    abs_dim = cw(dim, scale_vec);
    abs_outer_dim = abs_dim + cw(thickness_vec, [2, 2, 1]);

    faces = [[bottom, [0, 1]], [front, [0, 2]], [left, [1, 2]], [right, [1, 2]], [back, [0, 2]], [top, [0, 1]]];

    box_face_rotations = [[0, 0, 0], [90, 0, 0], [90, 0, -90], [90, 0, 90], [-90, 180, 0], [0, 0, 0]];
    box_face_translations = [
        [0, 0, 0],
        [0, thickness_vec.y, 0],
        [thickness_vec.x, abs_outer_dim.y, 0],
        [abs_dim.x + thickness_vec.x, 0, 0],
        [abs_outer_dim.x, abs_dim.y + thickness_vec.y, 0],
        [0, 0, abs_dim.z + thickness_vec.z]
    ];
    
    box_infos = [
        for (face = faces)
        let (string = face[0], dims = face[1])
        string_to_box_info(string, row_count = dim[dims.y], col_count = dim[dims.x])
    ];
    
        difference() {
            
            // Render the hull of the box
            beveled_cube(abs_dim + cw(thickness_vec, [2, 2, split_cap ? 1 : 2]));
            
            // Carve out the interior
            translate(thickness_vec - inset_vec)
            cube(abs_dim + cw(inset_vec, [2, 2, split_cap ? 1 : 2]) + [0, 0, split_cap ? iota : 0]);
            
            // Carve out the faces
            for (n = [0:(split_cap ? 4 : 5)]) {
                
                translate(box_face_translations[n])
                rotate(box_face_rotations[n])
                packing_box_carve_out(box_infos[n], [scale_vec[faces[n][1].x], scale_vec[faces[n][1].y]]);
                
            }
            
        }
        
        if (split_cap && top != "empty") {
            
            // Render the alignment pins
            
            
            translate(
                  dim.y < dim.x
                ? [0, abs_outer_dim.y + $plate_sep, 0]
                : [abs_outer_dim.x + $plate_sep, 0, 0]
            )
            difference() {
                
                beveled_cube([abs_outer_dim.x, abs_outer_dim.y, thickness_vec.z], $burr_bevel_adjustments = "z-=0.01");
                packing_box_carve_out(box_infos[5], [scale_vec[faces[5][1].x], scale_vec[faces[5][1].y]]);
                
            }
            
        }

    
}

module packing_box_carve_out(box_info, scale) {
    
    inset_vec = [$box_inset, $box_inset];
    thickness_vec = [$box_thickness, $box_thickness];
    
    for (row = [0:len(box_info)-1], col = [0:len(box_info[row])-1]) {
        
        cell_type = box_info[row][col][0];
        aux = box_info[row][col][1];
        
        if (cell_type == 24) {
            
        } else if (cell_type == 0) {
            
            x1 = col == 0 && !$box_use_full_perimeter ? -thickness_vec.x : -inset_vec.x;
            y1 = row == 0 && !$box_use_full_perimeter ? -thickness_vec.y : -inset_vec.y;
            x2 = col == len(box_info[row]) - 1 && !$box_use_full_perimeter ? scale.x + thickness_vec.x : scale.x + inset_vec.x;
            y2 = row == len(box_info) - 1 && !$box_use_full_perimeter ? scale.y + thickness_vec.y : scale.y + inset_vec.y;
            
            linear_extrude($box_thickness)
            translate(thickness_vec + cw([col, row], scale))
            translate([x1, y1])
            square([x2 - x1, y2 - y1]);
            
        } else if (cell_type == 15) {
            
            linear_extrude($box_thickness)
            translate(thickness_vec)
            translate(cw([col + 0.5, row + 0.5], scale))
            circle(min(scale.x, scale.y) * 0.4, $fn = 64);
            
        }
        
    }
    
}

function string_to_box_info(string, row_count, col_count) =
      string == "solid" ? [ for (row = [1:row_count]) [ for (col = [1:col_count]) [24] ] ]
    : string == "empty" ? [ for (row = [1:row_count]) [ for (col = [1:col_count]) [0] ] ]
    : [ for (row = strtok(string, "|"))
        let (burr_info = string_to_burr_info([], row))
        burr_info
      ];
