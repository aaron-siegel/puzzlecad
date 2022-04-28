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

$thatch_density = 0.35;
$thatch_fineness = 2;
$thatch_thickness = 3;
$thatch_boundary_width = 1.5;

module packing_box(box_spec) {

    box_info = to_burr_info(box_spec, $unit_beveled = false);
    layout_box_infos = $auto_layout ? auto_layout_plate([box_info], allowed_rotations = ["z+"]) : [box_info];

    packing_box_r(layout_box_infos);

}

module packing_box_r(layout_box_infos, i = 0, y = 0, x = 0, row_depth = 0) {
    
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
    cutout_inset_vec = is_undef($box_cutout_inset) ? inset_vec : vectorize($box_cutout_inset);
    thickness_vec = vectorize($box_wall_thickness);

    box_info = to_burr_info(box_spec, $unit_beveled = false);
    layout = [ for (plane=box_info) [ for (column=plane) [ for (cell=column) cell[0] ]]];
    aux = [ for (plane=box_info) [ for (column=plane) [ for (cell=column) cell[1] ]]];
     
    dim = [ len(box_info), len(box_info[0]), len(box_info[0][0]) ];
    
    nonempty_layers = [
        for (z = [0:dim.z-1])
        let (count = sum([ for (x = [0:dim.x-1], y = [0:dim.y-1]) layout[x][y][z] > 0 ? 1 : 0 ]))
        if (count > 0)
        z
    ];
    
    has_nonempty_bottom = nonempty_layers[0] == 0;
    has_nonempty_top = nonempty_layers[len(nonempty_layers)-1] == dim.z - 1;
    exterior_z_dim = nonempty_layers[len(nonempty_layers)-1] - nonempty_layers[0] + 1;
    interior_z_dim = exterior_z_dim - (has_nonempty_bottom ? 1 : 0) - (has_nonempty_top ? 1 : 0);
    
    interior_hull = cw(scale_vec, [max(2, dim.x) - 2, max(2, dim.y) - 2, interior_z_dim]);
    
    exterior_hull = interior_hull + cw(thickness_vec, [min(2, dim.x), min(2, dim.y), exterior_z_dim - interior_z_dim]);
    
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
        beveled_cube(exterior_hull, $burr_bevel = $box_bevel);
        
        // Carve out the interior
        if (dim.x > 2 && dim.y > 2 && interior_z_dim > 0) {
            translate(has_nonempty_bottom ? [0, 0, 0] : -[0, 0, thickness_vec.z])
            translate(thickness_vec - cutout_inset_vec)
            cube(interior_hull + cutout_inset_vec * 2);
        }
        
        // Carve out the faces
        translate([0, 0, -cell_offset[0][0][min(nonempty_layers)].z])
        for (z = [min(nonempty_layers):max(nonempty_layers)], y = [0:dim.y-1], x = [0:dim.x-1]) {
            
            cell = [x, y, z];
            options = aux[x][y][z];
            connects = strtok(lookup_kv(options, "connect"), ",");
            circle_radius = atof(lookup_kv(options, "circle"));
            components = strtok(lookup_kv(options, "components"), ",");
            
            face =
                x == 0 ? "x-"
              : y == 0 ? "y-"
              : z == 0 ? "z-"
              : x == dim.x - 1 ? "x+"
              : y == dim.y - 1 ? "y+"
              : z == dim.z - 1 ? "z+"
              : undef;
            
            face_axis =
                x == 0 || x == dim.x - 1 ? 0
              : y == 0 || y == dim.y - 1 ? 1
              : z == 0 || z == dim.z - 1 ? 2
              : -1;
            
            horiz_unit = face_axis == 0 ? [0, 0, 1] : face_axis == 1 ? [1, 0, 0] : [1, 0, 0];
            vert_unit = face_axis == 0 ? [0, 1, 0] : face_axis == 1 ? [0, 0, 1] : [0, 1, 0];
            
            if (face_axis >= 0) {
                if (layout[x][y][z] != 24 && layout[x][y][z] != 15 && layout[x][y][z] != 27) {
                    // Empty cell; cut out the entire voxel
                    translate(cell_offset[x][y][z] - inset_vec)
                    cube(cell_size[x][y][z] + inset_vec * 2);
                }
                if (!is_undef(circle_radius)) {
                    // Cut out a circle
                    face_scale = min(scale_vec[(face_axis + 1) % 3], scale_vec[(face_axis + 2) % 3]);
                    translate(cell_offset[x][y][z] + cell_size[x][y][z] / 2)
                    rotate(face_axis == 0 ? [0, -90, 0] : face_axis == 1 ? [90, 0, 0] : [0, 0, 0])
                    cylinder(r = circle_radius * face_scale, h = thickness_vec[face_axis] + 0.01, center = true, $fn = 64);
                }
                if (!is_undef(components)) {
                    face_index = index_of(cube_face_names, face);
                    for (edge_index = [0:3]) {
                        if (!list_contains(components, cube_edge_names[face_index][edge_index])) {
                            edge_rot = cube_edge_pre_rotations[edge_index];
                            rot = cube_face_rotations[face_index];
                            abs_dir = cw(directions[face_index], directions[face_index]);
                            translate(cell_offset[x][y][z])
                            translate(scale_vec.x * 0.5 * ([1, 1, 1] - abs_dir))
                            translate($box_wall_thickness * 0.5 * abs_dir)
                            rotate(rot)
                            rotate(edge_rot)
                            linear_extrude($box_wall_thickness + iota * 2000, center = true)
                            polygon([
                                [0, -2 * $box_inset],
                                [-scale_vec.x / 2 - $box_inset, scale_vec.x / 2 - $box_inset],
                                [-scale_vec.x / 2 - $box_inset, scale_vec.x / 2 + $box_inset],
                                [scale_vec.x / 2 + $box_inset, scale_vec.x / 2 + $box_inset],
                                [scale_vec.x / 2 + $box_inset, scale_vec.x / 2 - $box_inset]
                            ]);
                        }
                    }
                }
                if (layout[x][y][z] == 27) {
                    // Cut out a thatched pattern
                    face_scale = [scale_vec[(face_axis + 1) % 3], scale_vec[(face_axis + 2) % 3]];
                    cutout_scale = sqrt(1 - $thatch_density) / ($thatch_fineness * sqrt(2));
                    translate(cell_offset[x][y][z] + cell_size[x][y][z] / 2)
                    rotate(face_axis == 0 ? [0, -90, 0] : face_axis == 1 ? [90, 0, 0] : [0, 0, 0]) {
                        render(convexity = 2) intersection() {
                            union() {
                                cube([
                                    face_scale.x - 2 * $thatch_boundary_width,
                                    face_scale.y - 2 * $thatch_boundary_width,
                                    thickness_vec[face_axis] + 0.02
                                ], center = true);
                                for (h = [-1,1]) {
                                    if (lookup3(layout, cell + horiz_unit * h) == 27) {
                                        translate([h * (face_scale.x / 2 - $thatch_boundary_width / 2), 0, 0])
                                        cube([$thatch_boundary_width + 0.01, face_scale.y - 2 * $thatch_boundary_width, thickness_vec[face_axis] + 0.02], center = true);
                                    }
                                }
                                for (v = [-1,1]) {
                                    if (lookup3(layout, cell + vert_unit * v) == 27) {
                                        translate([0, v * (face_scale.y / 2 - $thatch_boundary_width / 2), 0])
                                        cube([face_scale.x - 2 * $thatch_boundary_width, $thatch_boundary_width + 0.01, thickness_vec[face_axis] + 0.02], center = true);
                                    }
                                }
                                for (h = [-1,1], v = [-1,1]) {
                                    if (lookup3(layout, cell + horiz_unit * h) == 27 &&
                                        lookup3(layout, cell + vert_unit * v) == 27 &&
                                        lookup3(layout, cell + horiz_unit * h + vert_unit * v) == 27) {
                                        translate([h * (face_scale.x / 2 - $thatch_boundary_width / 2), v * (face_scale.y / 2 - $thatch_boundary_width / 2), 0])
                                        cube([$thatch_boundary_width + 0.01, $thatch_boundary_width + 0.01, thickness_vec[face_axis] + 0.02], center = true);
                                    }
                                }
                            }
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
                        // If $thatch_thickness is less than the wall thickness, there's an additional cutout.
                        if ($thatch_thickness < thickness_vec[face_axis]) {
                            translate((x == 0 || y == 0 || z == dim.z - 1 ? 1 : -1) * [0, 0, $thatch_thickness / 2 + 0.01])
                            cube([
                                face_scale.x + 2 * inset_vec[(face_axis + 1) % 3] + 0.01,
                                face_scale.y + 2 * inset_vec[(face_axis + 2) % 3] + 0.01,
                                thickness_vec[face_axis] - $thatch_thickness
                            ], center = true);
                        }
                    }
                }
            }
            
            // Cutouts for female guide pins
                        
            for (connect = connects) {
                
                assert(is_valid_connect_annotation(connect, allow_diagonal = false), str("Invalid box connector: ", connect));
                if (connect[0] == "f") {
                    
                    orient = substr(connect, 1, 2);
                    rot = cube_face_rotation(orient);
                    face_axis = orient[0] == "x" ? 0 : orient[0] == "y" ? 1 : 2;
                    cell_scale = min(cell_size[x][y][z][(face_axis + 1) % 3], cell_size[x][y][z][(face_axis + 2) % 3]);
                    
                    translate(cell_offset[x][y][z] + cell_size[x][y][z] / 2)
                    rotate(rot)
                    translate([0, 0, cell_size[x][y][z][face_axis] / 2 - guide_pin_height(cell_scale) - 0.14])
                    cylinder(r = guide_pin_radius(cell_scale) + 0.2, h = guide_pin_height(cell_scale) + 0.15, $fn = 32);
                    
                }
                
            }
            
            // Labels
            
            translate(cell_offset[x][y][z] + cell_size[x][y][z] / 2)
            puzzle_label(options, cell_size[x][y][z]);
            
        }
        
    }

    // Add male guide pins
    translate([0, 0, -cell_offset[0][0][min(nonempty_layers)].z])
    for (z = [0:dim.z-1], y = [0:dim.y-1], x = [0:dim.x-1]) {
        
        options = aux[x][y][z];
        connects = strtok(lookup_kv(options, "connect"), ",");
        circle_radius = atof(lookup_kv(options, "circle"));

        for (connect = connects) {
            if (connect[0] == "m") {
                
                orient = substr(connect, 1, 2);
                rot = cube_face_rotation(orient);
                face_axis = orient[0] == "x" ? 0 : orient[0] == "y" ? 1 : 2;
                cell_scale = min(cell_size[x][y][z][(face_axis + 1) % 3], cell_size[x][y][z][(face_axis + 2) % 3]);
                
                translate(cell_offset[x][y][z] + cell_size[x][y][z] / 2)
                rotate(rot)
                translate([0, 0, cell_size[x][y][z][face_axis] / 2 - 0.01])
                cylinder(r = guide_pin_radius(cell_scale), h = guide_pin_height(cell_scale), $fn = 32);
                
            }
        }
        
        if (layout[x][y][z] > 0 && !is_undef(circle_radius)) {
            
            // Put an annulus around the circular cutout (so it plays nice with patterned surfaces)
            
            face_axis =
                x == 0 || x == dim.x - 1 ? 0
              : y == 0 || y == dim.y - 1 ? 1
              : z == 0 || z == dim.z - 1 ? 2
              : -1;        
            face_scale = min(scale_vec[(face_axis + 1) % 3], scale_vec[(face_axis + 2) % 3]);
            translate([0, 0, -cell_offset[0][0][min(nonempty_layers)].z])
            translate(cell_offset[x][y][z] + cell_size[x][y][z] / 2)
            rotate(face_axis == 0 ? [0, -90, 0] : face_axis == 1 ? [90, 0, 0] : [0, 0, 0])
            render(convexity = 2)
            difference() {
                cylinder(r = circle_radius * face_scale + $thatch_boundary_width, h = thickness_vec[face_axis], center = true, $fn = 64);
                cylinder(r = circle_radius * face_scale, h = thickness_vec[face_axis] + 0.01, center = true, $fn = 64);
            }
            
        }
        
    }
    
    // Render the interior. To do this, we render box_info as an ordinary burr structure and intersect it
    // with the interior hull of the box. For efficiency, we first filter box_info down to a substructure
    // containingly only "relevant" voxels. A voxel is relevant if it is either:
    // - part of the interior, or
    // - a side voxel and face-adjacent to a nonempty interior voxel, or
    // - an edge voxel and edge-adjacent to a nonempty interior voxel, or
    // - a corner voxel and corner-adjacent to a nonempty interior voxel.
    
    burr_info = [
        for (x = [0:dim.x-1]) [
            for (y = [0:dim.y-1]) [
                for (z = [0:dim.z-1])
                    is_relevant_to_interior([x, y, z]) ? box_info[x][y][z] : [0]
            ]
        ]
    ];
    
    translate([0, 0, -cell_offset[0][0][min(nonempty_layers)].z])
    intersection() {
        
        translate(thickness_vec - scale_vec / 2)
        burr_piece_base(burr_info, $burr_inset = is_undef($box_cutout_inset) ? $box_inset : $box_cutout_inset);
        
        translate(has_nonempty_bottom ? [0, 0, 0] : -[0, 0, thickness_vec.z])
        translate(thickness_vec - cutout_inset_vec - iota_vec)
        cube(interior_hull + cutout_inset_vec * 2 + 2 * iota_vec);
        
    }
    
    function is_relevant_to_interior(cell) =
        let (boundary_dirs = [ for (dir = directions) if (is_undef(lookup3(box_info, cell + dir))) dir])
        len(boundary_dirs) == 0 ? true : lookup3(box_info, cell - sum(boundary_dirs))[0] > 0;

}

// In the typical range of cell_scale = 6 (ordinarily equal to $box_wall_thickness), the radius will be
// cell_scale / 3. But we also ensure that it never be larger than 3 (applicable for cell_scale > 9),
// and we also ensure that there is always at least 1 mm of buffer around the hole (applicable for
// cell_scale < 6).
function guide_pin_radius(cell_scale) = min(3, cell_scale / 3, cell_scale / 2 - 1);

// Height of the guide pins is equal to radius, but never more than 2.
function guide_pin_height(cell_scale) = min(2, guide_pin_radius(cell_scale));
