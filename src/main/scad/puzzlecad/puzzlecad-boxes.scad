/* ====================================================================

  This is puzzlecad, an OpenSCAD library for modeling mechanical
  puzzles. It is provided as part of the Printable Puzzle Project:
  https://puzzlehub.org/ppp

  To obtain the latest version of puzzlecad:
  https://www.thingiverse.com/thing:3198014

  Puzzlecad code repository:
  https://github.com/aaron-siegel/puzzlecad

  puzzlecad is (c) 2019-2021 Aaron Siegel and is distributed under
  the MIT license. This means you may use or modify puzzlecad for any
  purposes, including commercial purposes, provided that you include
  the attribution "puzzlecad is (c) 2019-2021 Aaron Siegel" in any
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

$thatch_density = 0.5;
$thatch_fineness = 3;
$thatch_thickness = 2;

module packing_box(box_spec) {
    
    box_info = to_burr_info(box_spec);
    layout_box_infos = $auto_layout ? auto_layout_plate([box_info]) : [box_info];
    
    packing_box_r(layout_box_infos);
    
}

module packing_box_r(layout_box_infos,  i = 0, y = 0, x = 0, row_depth = 0) {
    
    scale_vec = vectorize($burr_scale);
    thickness_vec = vectorize($box_wall_thickness);
    
    if (i < len(layout_box_infos)) {
        
        cur_piece = layout_box_infos[i];
        width = scale_vec.x * (len(cur_piece) - 2) + thickness_vec.x * 2;
        depth = scale_vec.y * (len(cur_piece[0]) - 2) + thickness_vec.y * 2;

        if (x == 0 || x + width < $plate_width) {
            
            translate([x, y, 0])
            packing_box_base(cur_piece);
            
            packing_box_r(
                layout_box_infos, i + 1,
                y, x + width + $plate_sep, max([row_depth, depth])
            );
            
        } else {
            
            packing_box_r(layout_box_infos, i, y + row_depth + $plate_sep, 0, 0);
            
        }
        
    }
    
}

module packing_box_base(box_spec) {
   
    scale_vec = vectorize($burr_scale);
    inset_vec = vectorize($box_inset);
    thickness_vec = vectorize($box_wall_thickness);

    box_info = to_burr_info(box_spec);
    layout = [ for (plane=box_info) [ for (column=plane) [ for (cell=column) cell[0] ]]];
    aux = [ for (plane=box_info) [ for (column=plane) [ for (cell=column) cell[1] ]]];
     
    dim = [ len(box_info), len(box_info[0]), len(box_info[0][0]) ];
    
    interior_dim = cw(scale_vec, dim - [2, 2, 2]);
    
    cell_size = [ for (x = [0:dim.x-1]) [ for (y = [0:dim.y-1]) [ for (z = [0:dim.z-1])
        [ x == 0 || x == dim.x - 1 ? thickness_vec.x : scale_vec.x,
          y == 0 || y == dim.y - 1 ? thickness_vec.y : scale_vec.y,
          z == 0 || z == dim.z - 1 ? thickness_vec.z : scale_vec.z ]
    ] ] ];
    
    cell_offset = [ for (x = [0:dim.x-1]) [ for (y = [0:dim.y-1]) [ for (z = [0:dim.z-1])
        [ x == 0 ? 0 : sum([ for (i = [0:x-1]) cell_size[i][y][z].x ]),
          y == 0 ? 0 : sum([ for (j = [0:y-1]) cell_size[x][j][z].y ]),
          z == 0 ? 0 : sum([ for (k = [0:z-1]) cell_size[x][y][k].z ])
        ]
    ] ] ];
    
    difference() {
        
        // Render the hull of the box
        beveled_cube(interior_dim + thickness_vec * 2, $burr_bevel = $box_bevel);
        
        // Carve out the interior
        translate(thickness_vec - inset_vec)
        cube(interior_dim + inset_vec * 2);
        
        // Carve out the faces
        for (z = [0:dim.z-1], y = [0:dim.y-1], x = [0:dim.x-1]) {
            
            options = aux[x][y][z];
            
            face_axis =
                x == 0 || x == dim.x - 1 ? 0
              : y == 0 || y == dim.y - 1 ? 1
              : z == 0 || z == dim.z - 1 ? 2
              : -1;
            
            if (face_axis >= 0) {
                if (layout[x][y][z] != 24 && layout[x][y][z] != 15 && layout[x][y][z] != 27) {
                    translate(cell_offset[x][y][z] - inset_vec)
                    cube(cell_size[x][y][z] + inset_vec * 2);
                }
                if (layout[x][y][z] == 15) {
                    radius = lookup_kv(options, "radius", 1/3);
                    face_scale = min(scale_vec[(face_axis + 1) % 3], scale_vec[(face_axis + 2) % 3]);
                    translate(cell_offset[x][y][z] + cell_size[x][y][z] / 2)
                    rotate(face_axis == 0 ? [0, 90, 0] : face_axis == 1 ? [90, 0, 0] : [0, 0, 0])
                    cylinder(r = radius * face_scale, h = thickness_vec[face_axis] + 0.01, center = true, $fn = 32);
                }
                if (layout[x][y][z] == 27) {
                    face_scale = [scale_vec[(face_axis + 1) % 3], scale_vec[(face_axis + 2) % 3]];
                    cutout_scale = sqrt(1 - $thatch_density) / ($thatch_fineness * sqrt(2));
                    translate(cell_offset[x][y][z] + cell_size[x][y][z] / 2)
                    rotate(face_axis == 0 ? [0, 90, 0] : face_axis == 1 ? [90, 0, 0] : [0, 0, 0]) {
                        intersection() {
                            cube([face_scale.x + 0.01, face_scale.y + 0.01, thickness_vec[face_axis] + 0.02], center = true);
                            union() {
                                for (i = [-$thatch_fineness:$thatch_fineness], j = [-$thatch_fineness:$thatch_fineness]) {
                                    if ((i + j) % 2 == 0) {
                                        translate([i * face_scale.x / $thatch_fineness / 2, j * face_scale.y / $thatch_fineness / 2])
                                        rotate([0, 0, 45])
                                        cube([cutout_scale * face_scale.x, cutout_scale * face_scale.y, thickness_vec[face_axis] + 0.02], center = true);
                                    }
                                }
                            }
                        }
                        // If thatch_thickness is less than the wall thickness, there's an additional cutout.
                        if ($thatch_thickness < thickness_vec[face_axis]) {
                            translate((x == 0 || y == 0 || z == 0 ? 1 : -1) * [0, 0, $thatch_thickness / 2 + 0.01])
                            cube([face_scale.x + 0.01, face_scale.y + 0.01, thickness_vec[face_axis] - $thatch_thickness], center = true);
                        }
                    }
                }
            }
            
            // Cutouts for female guide pins
            
            connect = lookup_kv(options, "connect");
            
            if (!is_undef(connect)) {
                
                assert(is_valid_connect_annotation(connect, allow_diagonal = false), str("Invalid box connector: ", connect));
                if (connect[0] == "f") {
                    
                    orient = substr(connect, 1, 2);
                    rot = cube_face_rotation(orient);
                    face_axis = orient[0] == "x" ? 0 : orient[0] == "y" ? 1 : 2;
                    cell_scale = min(cell_size[x][y][z][(face_axis + 1) % 3], cell_size[x][y][z][(face_axis + 2) % 3]);
                    radius = min(3, cell_scale / 3, cell_scale / 2 - 1.2) + 0.2;
                    
                    translate(cell_offset[x][y][z] + cell_size[x][y][z] / 2)
                    rotate(rot)
                    translate([0, 0, cell_size[x][y][z][face_axis] / 2 - 2.14])
                    cylinder(r = radius, h = 2.15, $fn = 32);
                    
                }
                
            }
            
        }
        
    }

    // Add male guide pins
    for (z = [0:dim.z-1], y = [0:dim.y-1], x = [0:dim.x-1]) {
        
        options = aux[x][y][z];
        connect = lookup_kv(options, "connect");
        
        if (!is_undef(connect) && connect[0] == "m") {
            
            orient = substr(connect, 1, 2);
            rot = cube_face_rotation(orient);
            face_axis = orient[0] == "x" ? 0 : orient[0] == "y" ? 1 : 2;
            cell_scale = min(cell_size[x][y][z][(face_axis + 1) % 3], cell_size[x][y][z][(face_axis + 2) % 3]);
            radius = min(3, cell_scale / 3, cell_scale / 2 - 1.2);
            
            translate(cell_offset[x][y][z] + cell_size[x][y][z] / 2)
            rotate(rot)
            translate([0, 0, cell_size[x][y][z][face_axis] / 2 - 0.01])
            cylinder(r = radius, h = 2, $fn = 32);
            
        }
        
    }
    
}
