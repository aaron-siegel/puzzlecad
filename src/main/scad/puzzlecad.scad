// This is puzzlecad, an OpenSCAD library for modeling mechanical puzzles.
// To obtain the latest version of puzzlecad: https://www.thingiverse.com/thing:3198014
// Puzzlecad code repository: https://github.com/aaron-siegel/puzzlecad
// For an overview of interlocking puzzles: http://robspuzzlepage.com/interlocking.htm

// Puzzlecad is (c) 2019-2020 Aaron Siegel and is licensed for use under the
// Creative Commons - Attribution license. A copy of this license is available here:
// https://creativecommons.org/licenses/by/3.0/

// Version ID for version check.

puzzlecad_version = "2.1";

// Default values for scale, inset, bevel, etc.:

$burr_scale = 11.15;
$burr_inset = 0.07;
$burr_bevel = 0.5;
$plate_width = 180;
$plate_depth = 180;
$plate_sep = 6;
$joint_inset = 0.015;
$joint_cutout = 0.5;
$diag_joint_scale = 0.4;
$diag_joint_position = 0.1;
$unit_beveled = false;
$auto_layout = false;
$post_rotate = [0, 0, 0];

// Optional parameters that can be used to increase
// the amount of beveling on outer edges of burr pieces:

$burr_outer_x_bevel = undef;
$burr_outer_y_bevel = undef;
$burr_outer_z_bevel = undef;

// Internal parameters used for the modeling and testing algorithms.
// Don't change them unless you know what you're doing!

$poly_err_tolerance = 1e-10;
$unit_test_tolerance = 1e-10;
$puzzlecad_debug = false;
$use_alternate_diag_inset_hack = false;

/* Main module for rendering a burr piece.
 * "burr_spec" can be any of the following:
 *    - a stick number: 975
 *    - a string for a single-layer puzzle piece: "xxxx.|x..x.|x....|xxxxx"
 *    - an array of such strings, one per layer
 */
module burr_piece(burr_spec) {
    
    burr_plate([burr_spec]);
    
}

/* Module for rendering multiple burr pieces on a single plate. The module will prearrange the
 * pieces so that they can be generated into a single STL/OBJ file.
 * "burr_specs" is a vector of burr pieces (specified the same way as when calling burr_piece).
 * The other arguments should be left as defaults (they're used for recursive calls to burr_plate).
 */

module burr_plate(burr_specs) {
    
    burr_infos = [ for (burr_spec = burr_specs) to_burr_info(burr_spec) ];

    if ($auto_layout) {
        
        layout_burr_infos = auto_layout_plate(burr_infos);
        burr_plate_r(layout_burr_infos);
        
    } else {
        
        burr_plate_r(burr_infos);
        
    }
    
}

module burr_plate_r(burr_infos, i = 0, y = 0, x = 0, row_depth = 0) {
    
    scale_vec = vectorize($burr_scale);
    
    if (i < len(burr_infos)) {
        
        cur_piece = burr_infos[i];
        bounding_box = piece_bounding_box(cur_piece);
        piece_width = bounding_box[1].x - bounding_box[0].x;
        piece_depth = bounding_box[1].y - bounding_box[0].y;
        
        if (x == 0 || x + piece_width < $plate_width) {
            
            translate([x, y, 0])
            burr_piece_2(cur_piece, piece_number = i + 1);
            
            burr_plate_r(
                burr_infos, i + 1,
                y, x + piece_width + $plate_sep, max([row_depth, piece_depth])
            );
            
        } else {
            
            burr_plate_r(burr_infos, i, y + row_depth + $plate_sep, 0, 0);
            
        }
        
    }
    
}

/* This module does most of the work. It should seldom be called directly (use burr_piece instead).
 */

iota = 0.00001;
iota_vec = [iota, iota, iota];

module burr_piece_2(burr_spec, center = false, piece_number = undef) {

    scale_vec = vectorize($burr_scale);
    inset_vec = vectorize($burr_inset);
    
    echo(str(
        "Generating piece", piece_number ? str(" #", piece_number) : "",
        " at scale ", $burr_scale,
        " with inset ", $burr_inset,
        ", bevel ", $burr_bevel,
        $joint_inset > 0 ? str(", joint inset ", $joint_inset) : ""
    ));
    
    burr_info = to_burr_info(burr_spec);
    bounding_box = piece_bounding_box(burr_info);

    if (!is_undef(bounding_box)) {
        translate(center ? [0, 0, 0] : -bounding_box[0])
        rotate($post_rotate)
        burr_piece_base(burr_info);
    }
    
}

module burr_piece_base(burr_spec, test_poly = undef) {
  
    // Argument validation
    
    assert(is_num($burr_inset), "$burr_inset must be a scalar.");
    assert(is_num($burr_bevel), "$burr_bevel must be a scalar.");
    assert($burr_bevel >= 0, "$burr_bevel cannot be negative.");
    assert(is_num($joint_inset), "$joint_inset must be a scalar.");
    assert($joint_inset >= 0, "$joint_inset cannot be negative.");
    
    burr_info = to_burr_info(burr_spec);

    scale_vec = vectorize($burr_scale);
    inset_vec = vectorize($burr_inset);
    bevel_vec = vectorize($burr_bevel);
    xlen = len(burr_info);
    ylen = max([ for (plane=burr_info) len(plane) ]);
    zlen = max([ for (plane=burr_info, column=plane) len(column)]);
    burr = [ for (plane=burr_info) [ for (column=plane) [ for (cell=column) cell[0] ]]];
    aux = [ for (plane=burr_info) [ for (column=plane) [ for (cell=column) cell[1] ]]];
        
    // Number of voxels with diagonal components specified
    
    diagonal_component_count = sum([ for (plane = aux, column = plane, cell = column)
        len(strtok(lookup_kv(cell, "components", default = ""), ","))
    ]);
    
    if ($burr_inset > 0 && $burr_inset < 0.01) {
        echo("WARNING: $burr_inset less than 0.01 will be treated as 0 (minimal positive inset is 0.01).");
    }
    
    if (diagonal_component_count == 0 && $burr_inset < 0.01 && $burr_bevel > 0) {
        echo("WARNING: $burr_inset is 0 or negative, but $burr_bevel is nonzero. $burr_bevel parameter will be ignored.");
    }
    
    if (diagonal_component_count > 0 && $auto_layout) {
        assert(false, "$auto_layout does not work with diagonal geometry (that is, you may not set $auto_layout = true with diagonal geometry).");
    }

    // Create a list of all the distinct voxel types (i.e., distinct characters that
    // represent different components of the piece)

    all_voxels = [ for (layer = burr, row = layer, voxel = row) voxel ];
    distinct_voxels = distinct(all_voxels);
    
    difference() {

        union() {
            
            // Render components separately for each distinct voxel type

            for (component_id = distinct_voxels) {
                if (component_id >= 1) {
                    if (diagonal_component_count > 0) {
                        assert($burr_inset >= 0, "Diagonal geometry is only supported with a non-negative inset (for now).");
                        burr_piece_component_diag(burr_info, component_id, test_poly);
                    } else if ($burr_inset < 0.01) {
                        // Inset is very small or negative. Rendering strategy is different
                        // in this case.
                        effective_inset = min($burr_inset, -0.01);
                        burr_piece_component_neg_inset(
                            burr_info, component_id, test_poly,
                            $burr_bevel = 0, $burr_inset = effective_inset
                        );
                    } else {
                        burr_piece_component(burr_info, component_id, test_poly);
                    }
                }
            }
            
        }
        
        // Remove female connectors and cutouts for male connectors.
        
        for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1]) {
            
            connect_str = lookup_kv(aux[x][y][z], "connect");
            connect_list = strtok(connect_str, ",");
            clabel_str = lookup_kv(aux[x][y][z], "clabel");
            clabel_list = strtok(clabel_str, ",");
             
            if (connect_list)
            for (i = [0:len(connect_list)-1]) {
                
                connect = connect_list[i];
                clabel = clabel_list[i];

                is_valid_connect = 
                    (
                      (connect[0] == "m" || connect[0] == "f") &&
                      (len(connect) == 3 && list_contains(cube_face_names, substr(connect, 1, 2)) ||
                       len(connect) == 5 && is_valid_orientation(substr(connect, 1, 4)))
                    ) || (
                      connect[0] == "d" && (connect[1] == "m" || connect[1] == "f") &&
                      (len(connect) == 6 && is_valid_orientation(substr(connect, 2, 4)) ||
                       len(connect) == 7 && connect[6] == "~" && is_valid_orientation(substr(connect, 2, 4)))
                    );
                assert(is_valid_connect, str("Invalid connector: ", connect));
                
                type = connect[0] == "d" ? connect[1] : connect[0];
                orient = connect[0] == "d" ? substr(connect, 2, 4) : substr(connect, 1, 4);
                
                is_valid_clabel =
                    is_undef(clabel) ||
                    len(clabel) == 1 ||
                    len(clabel) == 3 && is_valid_orientation(str(substr(orient, 0, 2), substr(clabel, 1, 2)));
                assert(is_valid_clabel, str("Invalid clabel: ", clabel));
                
                assert(is_undef(clabel) || len(clabel) == 3 || len(orient) == 4, str("No orientation specified for clabel: ", clabel));
                
                if (!is_undef(clabel) && len(clabel) == 3 && len(orient) == 4) {
                    echo(str("WARNING: Redundant orientation in clabel for oriented connector will be ignored (connect=", connect, ", clabel=", clabel, ")"));
                }
                
                translate(cw(scale_vec, [x,y,z])) {
                    
                    if (connect[0] == "m")
                        male_connector_cutout(orient);
                    else if (connect[0] == "f")
                        female_connector(orient, clabel[0], substr(clabel, 1, 2));
                    else if (connect[0] == "d" && connect[1] == "m")
                        male_diag_snap_connector_cutout(orient, twist = connect[6] == "~");
                    else if (connect[0] == "d" && connect[1] == "f")
                        female_diag_snap_connector(orient, clabel, twist = connect[6] == "~");
                    
                }
                
            }

        }
        
        // Remove any labels that are specified.
        
        for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1]) {
            
            options = aux[x][y][z];
            label_orient = lookup_kv(options, "label_orient");
            label_text = lookup_kv(options, "label_text");
            
            if (label_orient && !label_text || !label_orient && label_text) {
                assert(false, "label_orient and label_text must be specified together.");
            }
            
            if (label_orient && label_text) {
                
                face_dir_str = substr(label_orient, 0, 2);
                rot1 = cube_face_rotation(face_dir_str);
                rot2 = cube_edge_pre_rotation(label_orient);
                face_dir = lookup_kv(direction_map, face_dir_str);
                assert(rot1 && rot2 && face_dir, str("Invalid label_orient: ", label_orient));

                hoffset_str = lookup_kv(options, "label_hoffset");
                voffset_str = lookup_kv(options, "label_voffset");
                label_scale_str = lookup_kv(options, "label_scale");
                
                hoffset = is_undef(hoffset_str) ? [0, 0, 0] :
                    let(hoffset = atof(hoffset_str))
                    assert(hoffset, str("Invalid label_hoffset: ", hoffset_str))
                    hoffset * cw(scale_vec, lookup_kv(edge_directions_map, label_orient)[0]);
                
                voffset = is_undef(voffset_str) ? [0, 0, 0] :
                    let(voffset = atof(voffset_str))
                    assert(voffset, str("Invalid label_voffset: ", voffset_str))
                   -atof(voffset_str) * cw(scale_vec, lookup_kv(edge_directions_map, label_orient)[1]);
                
                label_scale = is_undef(label_scale_str) ? 0.4 : atof(label_scale_str);
                assert(label_scale, str("Invalid label_scale: ", label_scale_str));

                // Translate by the explicit offsets
                translate(voffset)
                translate(hoffset)
                // Translate into natural position
                translate(cw(scale_vec, [x, y, z] + 0.5 * face_dir) - cw(face_dir, inset_vec))
                // Rotate into proper orientation
                rotate(rot1)
                rotate(rot2)
                // Extra 90-degree z-rotation is required to ensure that label_orient specifies the
                // flow direction of text (as expected)
                rotate([0, 0, 90])
                translate([0, 0, -1])
                linear_extrude(2)
                text(label_text, halign = "center", valign = "center", size = min(scale_vec) * label_scale, $fn=64);

            }
            
        }
        
    }
        
    // Add space-fillers ("bridges" between components). This ensures that the entire
    // piece remains connected in the final rendering.
    // TODO: Add edge and corner space-fillers
    
    for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1]) {
        cell = [x,y,z];
        if (lookup3(burr, cell) > 0) {
            for (face=[3:5]) {      // Just the positive-directional faces (so we check each face pair just once)
                
                facing_cell = cell + directions[face];
                // If the facing cell *is* defined but is from a different component, then
                // we need to render a space-filler.
                if (lookup3(burr, facing_cell) > 0 && lookup3(burr, facing_cell) != lookup3(burr, cell)) {
                    
                    face_center = cell + 0.5 * directions[face];
                    // Space-filler is 2*insets wide in the facing direction, and (scale - 2*insets - bevel/2)
                    // in the orthogonal directions. This ensures that the corners exactly meet the bevel line
                    // on each face.
                    dim = cw(2 * (inset_vec + iota_vec), directions[face])
                        + cw(scale_vec - 2 * (inset_vec + bevel_vec / sqrt(2)), [1, 1, 1] - directions[face]);
                    translate(cw(scale_vec, face_center))
                    cube(dim, center=true);
                    
                }
                
            }
        }
    }
            
    // Render the male connectors. connect and clabel will have already been validated (above).
    
    for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1]) {
        
            
        connect_str = lookup_kv(aux[x][y][z], "connect");
        connect_list = strtok(connect_str, ",");
        clabel_str = lookup_kv(aux[x][y][z], "clabel");
        clabel_list = strtok(clabel_str, ",");
         
        if (connect_list)
        for (i = [0:len(connect_list)-1]) {
            
            connect = connect_list[i];
            clabel = clabel_list[i];
            
            if (connect[0] == "m") {
                translate(cw(scale_vec, [x, y, z]))
                male_connector(substr(connect, 1, 4), clabel[0], substr(clabel, 1, 2));
            } else if (connect[0] == "d" && connect[1] == "m") {
                translate(cw(scale_vec, [x, y, z]))
                male_diag_snap_connector(substr(connect, 2, 4), clabel[0], twist = connect[6] == "~");
            }
            
        }
        
    }
    
}

// This module renders a single (individually beveled) component of a burr piece.

module burr_piece_component(burr_info, component_id, test_poly = undef) {
    
    scale_vec = vectorize($burr_scale);
    inset_vec = vectorize($burr_inset);
    bevel_vec = vectorize($burr_bevel);
    xlen = len(burr_info);
    ylen = max([ for (plane=burr_info) len(plane) ]);
    zlen = max([ for (plane=burr_info, column=plane) len(column)]);
    burr = [ for (plane=burr_info) [ for (column=plane) [ for (cell=column) cell[0] ]]];
    aux = [ for (plane=burr_info) [ for (column=plane) [ for (cell=column) cell[1] ]]];
        
    // We generate the polyhedron corresponding to this component and pass it to the beveling
    // subroutine. One or more polyhedra will be generated separately for each cell, and then
    // all the constituent faces will be normalized into a single polyhedron before applying
    // beveling.
    
    // First generate faces for all the "unpaired" cell-faces (those without a touching face
    // on the adjacent cell)
    
    faces = flatten( [
    
        for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1])
        let (cell = [x, y, z])
        if (lookup3(burr, cell) == component_id)
        for (face=[0:5])
        let (facing_cell = cell + directions[face])
        
        let (face_center = lookup3(burr, facing_cell) == component_id ? [] : [[
            for (edge=[0:3])
            let (corner = directions[face] + cube_edge_directions[face][edge] + cube_edge_perp_directions[face][edge])
            cw(scale_vec, cell + 0.5 * corner) - cw(inset_vec, corner)
        ]])
            
        let (face_edge_strips = [
            for (edge=[0:3])
            let (edge_direction = cube_edge_directions[face][edge])
            let (perp_edge_direction = cube_edge_perp_directions[face][edge])
            if (lookup3(burr, cell + edge_direction) == component_id)
            if (lookup3(burr, facing_cell) != component_id ||
                lookup3(burr, facing_cell + edge_direction) != component_id)
            let (edge_center = cw(scale_vec, cell + 0.5 * (directions[face] + edge_direction)) - cw(inset_vec, directions[face]))
            let (offset = cw(scale_vec, 0.5 * perp_edge_direction) - cw(inset_vec, perp_edge_direction))
            [ edge_center + offset,
              edge_center + offset - cw(inset_vec, edge_direction),
              edge_center - offset - cw(inset_vec, edge_direction),
              edge_center - offset ]
        ])
            
        let (face_corners = [
            for (edge=[0:3])
            let (corner_direction_1 = cube_edge_directions[face][edge])
            let (corner_direction_2 = cube_edge_perp_directions[face][edge])
            if (lookup3(burr, cell + corner_direction_1) == component_id &&
                lookup3(burr, cell + corner_direction_2) == component_id &&
                lookup3(burr, cell + corner_direction_1 + corner_direction_2) == component_id)
            if (lookup3(burr, facing_cell) != component_id ||
                lookup3(burr, facing_cell + corner_direction_1) != component_id ||
                lookup3(burr, facing_cell + corner_direction_2) != component_id ||
                lookup3(burr, facing_cell + corner_direction_1 + corner_direction_2) != component_id)
            let (corner_point = cw(scale_vec, cell + 0.5 * (directions[face] + corner_direction_1 + corner_direction_2))
                              - cw(inset_vec, directions[face]))
            [ corner_point,
              corner_point - cw(inset_vec, corner_direction_1),
              corner_point - cw(inset_vec, corner_direction_1 + corner_direction_2),
              corner_point - cw(inset_vec, corner_direction_2) ]
        ])
        
        merge_coplanar_faces(concat(face_center, face_edge_strips, face_corners))
        
    ] );
  
    poly = make_beveled_poly(faces);

    if ($puzzlecad_debug) {
        echo("--- Generated Polyhedron ---");
        for (k=[0:len(poly[0])-1]) {
            echo(str("V ", k, ": ", poly[0][k]));
        }
        for (k=[0:len(poly[1])-1]) {
            echo(str("F ", k, ": ", poly[1][k], " -> ", [ for (p=poly[1][k]) poly[0][p] ]));
        }
    }
    
    if (test_poly) {
                
        // Don't render; just test the polyhedron. This is used for unit testing.
        for (i=[0:max(len(poly[0]), len(test_poly[0]))-1]) {
            if (!(norm(poly[0][i] - test_poly[0][i]) < $unit_test_tolerance)) {
                echo(str("EXPECTED: ", test_poly));
                echo(str("ACTUAL: ", poly));
                assert(false, str("Points differ at index ", i, ": ", test_poly[0][i], " != ", poly[0][i]));
            }
        }
        for (i=[0:max(len(poly[1]), len(test_poly[1]))-1]) {
            if (!(poly[1][i] == test_poly[1][i])) {
                echo(str("EXPECTED: ", test_poly));
                echo(str("ACTUAL: ", poly));
                assert(poly[1][i] == test_poly[1][i], str("Faces differ at index ", i));
            }
        }

    } else {
        
        // Render the component.
        
        polyhedron(poly[0], poly[1], convexity = 10);

    }
        
}

module burr_piece_component_diag(burr_info, component_id, test_poly = undef) {
    
    scale_vec = vectorize($burr_scale);
    inset_vec = [0, 0, 0];//vectorize($burr_inset);
    bevel_vec = vectorize($burr_bevel);
    xlen = len(burr_info);
    ylen = max([ for (plane=burr_info) len(plane) ]);
    zlen = max([ for (plane=burr_info, column=plane) len(column)]);
    burr = [ for (plane=burr_info) [ for (column=plane) [ for (cell=column) cell[0] ]]];
    aux = [ for (plane=burr_info) [ for (column=plane) [ for (cell=column) cell[1] ]]];
    
    ortho_geom = [ for (x=[0:xlen-1]) [ for (y=[0:ylen-1]) [ for (z=[0:zlen-1])
        let (components_str = lookup_kv(aux[x][y][z], "components"))
        let (components = strtok(components_str, ","))
        [ for (face=[0:5]) [ for (edge=[0:3]) [ for (vertex=[0:1])
            let (face_name = cube_face_names[face])
            let (edge_name = str(face_name, cube_edge_names[face][edge]))
            let (vertex_name = str(edge_name, cube_vertex_names[face][edge][vertex]))
            is_undef(components_str) ||
                list_contains(components, face_name) ||
                list_contains(components, edge_name) ||
                list_contains(components, vertex_name) ? burr[x][y][z] : 0
        ] ] ]
    ] ] ];
        
    faces = flatten( [
    
        for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1])
        let (cell = [x, y, z])
        let (ortho = lookup3(ortho_geom, cell))
        for (face=[0:5], edge=[0:3], vertex=[0:1])
        let (fev = [face, edge, vertex])
        if (lookup3(ortho, fev) == component_id)
            
        let (
        
            dir1 = directions[face],
            dir2 = cube_edge_directions[face][edge],
            dir3 = cube_vertex_directions[face][edge][vertex],
        
            cube_center = cw(scale_vec, cell),
            face_center = cube_center + cw(scale_vec, 0.5 * dir1),
            edge_center = face_center + cw(scale_vec, 0.5 * dir2),
            vertex_point = edge_center + cw(scale_vec, 0.5 * dir3),
        
            cfe_facing = ortho[face][edge][1 - vertex] == component_id,
            cfv_facing = lookup3(ortho, cfv_adjacency(fev)) == component_id,
            cev_facing = lookup3(ortho, cev_adjacency(fev)) == component_id,
            fev_facing = lookup3(lookup3(ortho_geom, cell + dir1), fev_mirror(fev)) == component_id,
        
            inset_cube_center = cube_center + cw(inset_vec, (1 + 2 * sqrt(2)) * dir1 + (1 + sqrt(2)) * dir2 + dir3),
            inset_face_center = face_center + cw(inset_vec, -dir1 + (1 + sqrt(2)) * dir2 + dir3),
            inset_edge_center = edge_center + cw(inset_vec, -dir1 - (1 + sqrt(2)) * dir2 + dir3),
            inset_vertex = vertex_point + cw(inset_vec, -dir1 - (1 + sqrt(2)) * dir2 - (1 + 2 * sqrt(2)) * dir3)
        
        )
        
        let (face_bodies = flatten([
            !cfe_facing ? [[inset_cube_center, inset_face_center, inset_edge_center]] : [],
            !cfv_facing ? [[inset_cube_center, inset_vertex, inset_face_center]] : [],
            !cev_facing ? [[inset_cube_center, inset_edge_center, inset_vertex]] : [],
            !fev_facing ? [[inset_face_center, inset_vertex, inset_edge_center]] : []
        ]))
        
        merge_coplanar_faces(vertex == 0 ? face_bodies : [ for (face = face_bodies) reverse_list(face) ])
        
    ] );
    
    poly = make_beveled_poly(faces);

    if ($puzzlecad_debug) {
        echo("--- Generated Polyhedron ---");
        for (k=[0:len(poly[0])-1]) {
            echo(str("V ", k, ": ", poly[0][k]));
        }
        for (k=[0:len(poly[1])-1]) {
            echo(str("F ", k, ": ", poly[1][k], " -> ", [ for (p=poly[1][k]) poly[0][p] ]));
        }
    }
    
    if (test_poly) {
                
        // Don't render; just test the polyhedron. This is used for unit testing.
        
        for (i=[0:max(len(poly[0]), len(test_poly[0]))-1]) {
            if (!(norm(poly[0][i] - test_poly[0][i]) < $unit_test_tolerance)) {
                echo(str("EXPECTED: ", test_poly));
                echo(str("ACTUAL: ", poly));
                assert(false, str("Points differ at index ", i, ": ", test_poly[0][i], " != ", poly[0][i]));
            }
        }
        for (i=[0:max(len(poly[1]), len(test_poly[1]))-1]) {
            if (!(poly[1][i] == test_poly[1][i])) {
                echo(str("EXPECTED: ", test_poly));
                echo(str("ACTUAL: ", poly));
                assert(poly[1][i] == test_poly[1][i], str("Faces differ at index ", i));
            }
        }

    } else {
        
        // Render the component.
        render(convexity = 2)
        difference() {
            
            polyhedron(poly[0], poly[1], convexity = 10);
            
            if ($burr_inset > 0) {
                for (x=[-1:xlen], y=[-1:ylen], z=[-1:zlen]) {
                    cell = [x, y, z];
                    if (lookup3(burr, cell) != component_id) {
                        translate(cw(cell, scale_vec)) {
                            if ($use_alternate_diag_inset_hack) {
                                cube(scale_vec + iota_vec * 10 + vectorize(2 * $burr_inset), center = true);
                            } else {
                                cube(scale_vec + iota_vec * 10 + [2 * $burr_inset, 0, 0], center = true);
                                cube(scale_vec + iota_vec * 10 + [0, 2 * $burr_inset, 0], center = true);
                                cube(scale_vec + iota_vec * 10 + [0, 0, 2 * $burr_inset], center = true);
                            }
                        }
                    } else {
                        ortho = lookup3(ortho_geom, cell);
                        for (face=[0:5], edge=[0:3], vertex=[0:1]) {
                            fev = [face, edge, vertex];
                            if (lookup3(ortho, fev) != component_id) {
                                facing_cell = cell + directions[face];
                                if (lookup3(burr, cell) == component_id ||
                                    lookup3(burr, cell + directions[face]) == component_id ||
                                    lookup3(burr, cell + cube_edge_directions[face][edge]) == component_id) {
                                        
                                    translate(cw(cell, scale_vec))
                                    rotate(cube_face_rotations[face])
                                    rotate(cube_edge_pre_rotations[edge])
                                    tetrahedron_cutout();
                                    
                                }
                            }
                        }
                    }
                }
            }
            
        }

    }
    
}

module burr_piece_component_neg_inset(burr_info, component_id, test_poly = undef) {
    
    assert($burr_inset < 0);
    assert($burr_bevel == 0);
    
    scale_vec = vectorize($burr_scale);
    inset_vec = vectorize($burr_inset);
    bevel_vec = vectorize($burr_bevel);
    xlen = len(burr_info);
    ylen = max([ for (plane=burr_info) len(plane) ]);
    zlen = max([ for (plane=burr_info, column=plane) len(column)]);
    burr = [ for (plane=burr_info) [ for (column=plane) [ for (cell=column) cell[0] ]]];
    aux = [ for (plane=burr_info) [ for (column=plane) [ for (cell=column) cell[1] ]]];

    for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1]) {
        
        if (burr[x][y][z] == component_id) {
            translate(cw(scale_vec, [x, y, z]))
            cube(scale_vec - 2 * inset_vec, center=true);
        }
        
    }
    
}

module tetrahedron_cutout() {
    
    vertices = [[0, 0, 0], [0, 0, 0.5], [-0.5, 0.5, 0.5], [0.5, 0.5, 0.5]];
    faces = [[0, 1, 2], [0, 2, 3], [0, 3, 1], [1, 3, 2]];
    
    inset_translate = $burr_inset;
    translate([0, 0, -inset_translate])
    scale(1 + 2 * inset_translate / $burr_scale)
    scale($burr_scale)
    polyhedron(vertices, faces);
    translate([0, -inset_translate, 0])
    scale(1 + 2 * inset_translate / $burr_scale)
    scale($burr_scale)
    polyhedron(vertices, faces);
    
}
 
/** Module for rendering a female snap joint.
  */

module female_connector(orient, label, explicit_label_orient) {
    
    rot = cube_face_rotation(orient);
    taper_rot = cube_edge_pre_rotation(orient);
    size = $burr_scale * 2/3 - $burr_inset * 2 + $joint_inset * 2;
    size3 = vectorize(size);
    
    rotate(rot)
    translate([0, 0, ($burr_scale - size) / 2 + iota])
    union() {
        if (taper_rot) {
            rotate(taper_rot)
            linear_extrude(size, center = true)
            polygon([[-size/2, -size/2], [-size/2, 0], [0, size/2], [size/2, 0], [size/2, -size/2]]);
        } else {
            cube(size3, center = true);
        }
        if (!is_undef(label)) {
            connector_label(1, orient, label, explicit_label_orient);
        }
    }
    
}

/** Module for rendering the cutout for a male snap joint (the volume to subtract from the
  * cell into which it is embedded).
  */

module male_connector_cutout(orient) {
    
    rot = cube_face_rotation(orient);
    taper_rot = cube_edge_pre_rotation(orient);
    size = $burr_scale * 2/3 - $burr_inset * 2 - $joint_inset * 2 + $joint_cutout * 2;
    
    rotate(rot)
    translate([0, 0, $burr_scale / 3 + 0.25 + iota]) {
        if (taper_rot) {
            rotate(taper_rot)
            linear_extrude($burr_scale / 3 - 0.5, center = true)
            polygon([[-size/2, -size/2], [-size/2, 0], [0, size/2], [size/2, 0], [size/2, -size/2]]);
        } else {
            cube([size, size, $burr_scale / 3 - 0.5], center = true);
        }
    }
    
}

/** Module for rendering a male snap joint.
  */

module male_connector(orient, label, explicit_label_orient) {
    
    rot = cube_face_rotation(orient);
    taper_rot = cube_edge_pre_rotation(orient);
    size = $burr_scale * 2/3 - $burr_inset * 2 - $joint_inset * 2;
    // Subtract off an extra 0.35 mm to provide added clearance at the top.
    total_height = size - 0.35 + $burr_scale / 3;
    
    rotate(rot)
    translate([0, 0, total_height / 2 + $burr_scale / 6])
    union() {
        difference() {
            if (taper_rot) {
                rotate(taper_rot)
                tapered_pentagon([size, size, total_height], center = true, clipped = true);
            } else {
                tapered_cube([size, size, total_height], center = true);
            }
            if (!is_undef(label)) {
                translate([0, 0, $burr_scale / 6])
                connector_label(-1, orient, label, explicit_label_orient);
            }
        }
        translate([0, (size + $joint_cutout) / 2 - 0.5, -$burr_scale / 3])
        rotate([90, 0, 0])
        cylinder(h = $joint_cutout + 1 + iota, r = 1, $fn = 32, center = true);
        translate([0, -(size + $joint_cutout) / 2 + 0.5, -$burr_scale / 3])
        rotate([90, 0, 0])
        cylinder(h = $joint_cutout + 1 + iota, r = 1, $fn = 32, center = true);
        translate([(size + $joint_cutout) / 2 - 0.5, 0, -$burr_scale / 3])
        rotate([0, 90, 0])
        cylinder(h = $joint_cutout + 1 + iota, r = 1, $fn = 32, center = true);
        translate([-(size + $joint_cutout) / 2 + 0.5, 0, -$burr_scale / 3])
        rotate([0, 90, 0])
        cylinder(h = $joint_cutout + 1 + iota, r = 1, $fn = 32, center = true);
    }
    
}

module female_diag_snap_connector(orient, label, twist = false) {
    
    rot = cube_face_rotation(orient);
    pre_rot = cube_edge_pre_rotation(orient);
    twist_translate = twist ? [-1/2, -1/2, -1/2] : [0, 0, 0];
    
    theta = atan(sqrt(2));
    eta = atan(sqrt(2)/2);
    
    joint_length = $burr_scale / 5;
    
    scale($burr_scale)
    translate(twist_translate)
    rotate(rot)
    rotate(pre_rot)
    rotate([45, 0, 0])
    translate([0, (1 - $diag_joint_scale - $diag_joint_position) * sqrt(2) / 2, $burr_inset / sqrt(2) / $burr_scale - iota]) {

        linear_extrude((joint_length + 0.3) / $burr_scale)
        scale($diag_joint_scale)
        polygon([
            [0, -$joint_inset / $burr_scale / $diag_joint_scale],
            [-1/2 - sqrt(2) * $joint_inset / $burr_scale/ $diag_joint_scale, sqrt(2)/2 + $joint_inset / $burr_scale / $diag_joint_scale],
            [1/2 + sqrt(2) * $joint_inset / $burr_scale/ $diag_joint_scale, sqrt(2)/2 + $joint_inset / $burr_scale / $diag_joint_scale]
        ]);
        
        if (label) {
            
            label_depth = 0.5 / $burr_scale;
            
            translate([0, sqrt(1/2) * $diag_joint_scale + label_depth / 2 - iota, (-1 + joint_length + 0.3) / 2 / $burr_scale])
            rotate([-90, 0, 180])
            translate([0, 0, -label_depth/2])
            linear_extrude(height=label_depth)
            text(label, halign = "center", valign = "center", size = $burr_scale / 200, $fn = 64);
            
        }
            
    }

}

module male_diag_snap_connector_cutout(orient, twist = false) {
    
    rot = cube_face_rotation(orient);
    pre_rot = cube_edge_pre_rotation(orient);
    twist_translate = twist ? [-1/2, -1/2, -1/2] : [0, 0, 0];
    
    theta = atan(sqrt(2));
    eta = atan(sqrt(2)/2);
    
    joint_length = $burr_scale / 5;
    
    scale($burr_scale)
    translate(twist_translate)
    rotate(rot)
    rotate(pre_rot)
    rotate([45, 0, 0])
    translate([0, (1 - $diag_joint_scale - $diag_joint_position) * sqrt(2) / 2, $burr_inset / sqrt(2) / $burr_scale - iota]) {

        linear_extrude(joint_length / $burr_scale)
        translate([0, -$joint_cutout / $burr_scale])
        scale($diag_joint_scale + (1 + sqrt(2)) * $joint_cutout / $burr_scale)
        polygon([ [0, 0], [-1/2, sqrt(2)/2], [1/2, sqrt(2)/2] ]);
    
    }
    
}

module male_diag_snap_connector(orient, label, twist = false) {
    
    rot = cube_face_rotation(orient);
    pre_rot = cube_edge_pre_rotation(orient);
    twist_translate = twist ? [-1/2, -1/2, -1/2] : [0, 0, 0];
    
    theta = atan(sqrt(2));
    eta = atan(sqrt(2)/2);
    
    joint_length = $burr_scale / 5;
    
    scale($burr_scale)
    translate(twist_translate)
    rotate(rot)
    rotate(pre_rot)
    rotate([45, 0, 0])
    translate([0, (1 - $diag_joint_scale - $diag_joint_position) * sqrt(2) / 2, (-joint_length + $burr_inset / sqrt(2)) / $burr_scale + iota]) {
        
        difference() {
            
            beveled_prism(
                [[0, $joint_inset / $burr_scale / $diag_joint_scale],
                 [-1/2 + sqrt(2) * $joint_inset / $burr_scale / $diag_joint_scale, sqrt(2)/2 - $joint_inset / $burr_scale / $diag_joint_scale],
                 [1/2 - sqrt(2) * $joint_inset / $burr_scale / $diag_joint_scale, sqrt(2)/2 - $joint_inset / $burr_scale / $diag_joint_scale]]             * $diag_joint_scale,
                (joint_length * 2 + 1) / $burr_scale,
                $burr_bevel = 1.5 / $burr_scale,
                $burr_outer_x_bevel = undef,
                $burr_outer_y_bevel = undef,
                $burr_outer_z_bevel = undef
            );
            
            if (label) {
                
                label_depth = 0.5 / $burr_scale;
                
                translate([0, sqrt(1/2) * $diag_joint_scale - label_depth / 2 + iota, joint_length / 2 / $burr_scale])
                rotate([-90, 0, 0])
                translate([0, 0, -label_depth/2])
                linear_extrude(height=label_depth)
                text(label, halign = "center", valign = "center", size = $burr_scale / 300, $fn = 64);
                
            }
            
        }

        translate([0, sqrt(2)/2 * $diag_joint_scale, (joint_length + 1.5) / $burr_scale])
        rotate([-90, 0, 0])
        translate([0, 0, -0.5 / $burr_scale])
        cylinder(h = ($joint_cutout + 1) / $burr_scale, r = 1 / $burr_scale, $fn = 32);
        
        translate([$diag_joint_scale/4, sqrt(2)/4 * $diag_joint_scale, (joint_length + 1.5) / $burr_scale])
        rotate([90, 0, theta])
        translate([0, 0, -0.5 / $burr_scale])
        cylinder(h = ($joint_cutout + 1) / $burr_scale, r = 1 / $burr_scale, $fn = 32);

        translate([-$diag_joint_scale/4, sqrt(2)/4 * $diag_joint_scale, (joint_length + 1.5) / $burr_scale])
        rotate([90, 0, -theta])
        translate([0, 0, -0.5 / $burr_scale])
        cylinder(h = ($joint_cutout + 1) / $burr_scale, r = 1 / $burr_scale, $fn = 32);
    
    }
    
}

module diagonal_strut(inset = 0.015) {
    
    theta = atan(sqrt(2));
    joint_length = 5;
    
    poly = [
        [0, 2 * inset * sin(theta)],
        [-1/2, sqrt(2)/2] * $burr_scale * $diag_joint_scale + [1 / tan(theta / 2), -1] * inset,
        [1/2, sqrt(2)/2] * $burr_scale * $diag_joint_scale + [-1 / tan(theta / 2), -1] * inset
    ];
    
    translate([0, 0, sqrt(2)/2 * $burr_scale * $diag_joint_scale - inset])
    rotate([-90, 0, 0])
    beveled_prism(poly, joint_length * 2, $burr_bevel = 0.75, $burr_outer_z_bevel = 2);
    
}

module female_diag_glue_connector(orient, label) {
    
    rot = cube_face_rotation(orient);
    pre_rot = cube_edge_pre_rotation(orient);
    
    scale($burr_scale)
    rotate(rot)
    rotate(pre_rot)
    rotate([45, 0, 0])
    translate([0, 0, $burr_inset / sqrt(2) / $burr_scale - iota])
    diag_connector_glue_pegs(1.3 / $burr_scale, 1.2 / $burr_scale);
    
}

module male_diag_glue_connector(orient, label) {
    
    rot = cube_face_rotation(orient);
    pre_rot = cube_edge_pre_rotation(orient);
    
    scale($burr_scale)
    rotate(rot)
    rotate(pre_rot)
    rotate([45, 0, 0])
    translate([0, 0, (-1 + $burr_inset / sqrt(2)) / $burr_scale + iota])
    diag_connector_glue_pegs(1 / $burr_scale, 1 / $burr_scale);
    
}

module diag_connector_glue_pegs(depth, radius) {

    theta = atan(sqrt(2));
    eta = atan(sqrt(2)/2);
    $fn = 32;

    translate([0, 0.25, 0])
    linear_extrude(depth)
    circle(radius);
    
    translate([-1/2 + 0.3 * cos(theta/2), sqrt(2)/2 - 0.3 * sin(theta/2)])
    linear_extrude(depth)
    circle(radius);
    
    translate([1/2 - 0.3 * cos(theta/2), sqrt(2)/2 - 0.3 * sin(theta/2)])
    linear_extrude(depth)
    circle(radius);
        
}

module tapered_cube(size, center = false) {
    
    beveled_cube(
        size,
        center,
        $burr_bevel = 0,
        $burr_outer_x_bevel = undef,
        $burr_outer_y_bevel = undef,
        $burr_outer_z_bevel = [0, 1.5]
    );
    
}

module tapered_pentagon(size, center = false, clipped = false) {
    
    pentagon_base = [[size.x / 2, 0], [size.x / 2, -size.y / 2], [-size.x / 2, -size.y / 2], [-size.x / 2, 0]];
    pentagon_tip = clipped ? [[-0.5, size.y / 2 - 0.5], [0.5, size.y / 2 - 0.5]] : [[0, size.y / 2]];
    
    beveled_prism(
        concat(pentagon_base, pentagon_tip),
        size.z,
        center,
        $burr_bevel = 0,
        $burr_outer_x_bevel = undef,
        $burr_outer_y_bevel = undef,
        $burr_outer_z_bevel = [0, 1.5]
    );
    
}

/* Module for rendering a connector label. The connector label will always be rendered
 * in the z+ orientation. The parent module rotates it into the proper place.
 */
module connector_label(parity, orient, label, explicit_label_orient) {

    label_depth = 0.5;
    label_orient = len(orient) == 4 ? mirrored_face_name(substr(orient, 2, 2)) : explicit_label_orient;
    label_rot = cube_edge_pre_rotation(str(substr(orient, 0, 2), label_orient));
    label_translate = $burr_scale / 3 - $burr_inset + (label_depth / 2 + $joint_inset - 10 * iota) * parity;

    assert(!is_undef(label_rot), str("Invalid label orientation: ", orient, label_orient));
    
    // Apply an appropriate rotation to position properly. After this rotation it will be in
    // z+y- or z+x- or z+y+ or z+x+ position.
    rotate(label_rot)
    // Move the label into the z+y+ position with a vertical translation according to parity
    // (The vertical translation is purely for aesthetic reasons)
    rotate([0, 0, 180])
    translate([0, -label_translate, 0.5 * parity])
    // Stand the label upright and facing in the y- direction
    rotate([-90 * parity, 90 + 90 * parity, 0])
    // Create the label, centered at the origin
    translate([0, 0, -label_depth/2])
    linear_extrude(height=label_depth)
    text(label, halign = "center", valign = "center", size = $burr_scale / 3.7, $fn = 64);
    
}

/******* Auto-layout capabilities *******/

function auto_layout_plate(burr_infos, next_joint_letter = 0, i = 0, result = []) =
      i >= len(burr_infos) ? result
    : let (
          piece_layout_info = auto_layout(burr_infos[i], next_joint_letter),
          piece_layout = piece_layout_info[0],
          new_next_joint_letter = piece_layout_info[1]
      )
      auto_layout_plate(burr_infos, new_next_joint_letter, i + 1, concat(result, piece_layout));

// Returns a structure [result, next_joint_letter]

function auto_layout(burr_info, next_joint_letter = 0) =
    let (
        layers = zyx_to_xyz(burr_info),
        layout = auto_layout_r(layers, next_joint_letter, layout_rotation_dirs),
        new_components = layout[0],
        new_next_joint_letter = layout[1])
    [ [ for (component = new_components) zyx_to_xyz(component) ], new_next_joint_letter ];
        
function auto_layout_r(layers, next_joint_letter, allowed_rotations) =
    let (
        rotated_layers = [ for (dir = allowed_rotations) zyx_to_xyz(rotate_burr_info(zyx_to_xyz(layers), dir)) ],
        layout_components = [ for (rl = rotated_layers) dissect_components(rl, next_joint_letter) ],
        badness_scores = [ for (components_info = layout_components) let (components = components_info[0])
            1e6 * sum([ for (component = components) multi_female_joint_count(component) ])
                + 1e4 * len(components)
                + 1e2 * sum([ for (component = components) occupied_layer_count(component) ])
                + sum([ for (component = components) zminus_connector_count(component) ])
        ],
        index_of_optimum = argmin(badness_scores)
    )
    layout_components[index_of_optimum];

function dissect_components(layers, next_joint_letter) =
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
        let (remainder_layout = auto_layout_r(remainder, new_next_joint_letter, ["z+", "z-"]))
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
    !(layers[z][y-1][x][0] > 0 && layers[z][y+1][x][0] > 0 && layers[z + offset][y-1][x][0] > 0 && layers[z + offset][y+1][x][0] > 0) &&
    !(layers[z][y][x-1][0] > 0 && layers[z][y][x+1][0] > 0 && layers[z + offset][y][x-1][0] > 0 && layers[z + offset][y][x+1][0] > 0);

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

/******* Bounding box computation *******/

function piece_bounding_box(burr_info) =
    let (
        scale_vec = vectorize($burr_scale),
        cell_bounding_points =
            [ for (x = [0:len(burr_info)-1])
              for (y = [0:len(burr_info[x])-1])
              for (z = [0:len(burr_info[x][y])-1])
              let (burr_cell = burr_info[x][y][z][0], aux_cell = burr_info[x][y][z][1])
              if (burr_cell > 0 && is_undef(lookup_kv(aux_cell, "components")))
                  for (p = cube_bounding_points())
                      apply_rot($post_rotate, cw(scale_vec, [x, y, z] + p))
              else if (burr_cell > 0)
                  for (component = strtok(lookup_kv(aux_cell, "components"), ","))
                  for (p = component_bounding_points(component))
                      apply_rot($post_rotate, cw(scale_vec, [x, y, z] + p))
            ]
    )
    bounding_box_of_points(cell_bounding_points);

function bounding_box_of_points(points, i = 0, box = undef) =
      i >= len(points) ? box
    : is_undef(box) ? bounding_box_of_points(points, i + 1, [points[i], points[i]])
    : let (
        new_min = [min(box[0].x, points[i].x), min(box[0].y, points[i].y), min(box[0].z, points[i].z)],
        new_max = [max(box[1].x, points[i].x), max(box[1].y, points[i].y), max(box[1].z, points[i].z)]
      )
      bounding_box_of_points(points, i + 1, [new_min, new_max]);

function cube_bounding_points() =
    [ for (i = [-1, 1], j = [-1, 1], k = [-1, 1])
        cw([i, j, k] / 2, [1, 1, 1] - 2 * $burr_inset * cw_inverse(vectorize($burr_scale))) ];

// name can be a face, face-edge, or orthoscheme name.
// TODO Pregenerate and cache these?
function component_bounding_points(name) =
    let (face_rot = cube_face_rotation(name))
    let (scaled_inset = $burr_inset * cw([2, 2, 1], cw_inverse(vectorize($burr_scale))))
    let (pos = [0.5, 0.5, 0.5] - scaled_inset, neg = -[0.5, 0.5, 0.5] + scaled_inset)
    len(name) == 2 ?
        [ for (p = [[0, 0, scaled_inset.z], [pos.x, pos.y, pos.z], [pos.x, neg.y, pos.z], [neg.x, neg.y, pos.z], [neg.x, pos.y, pos.z]])
            apply_rot(face_rot, p) ] :
        let (edge_rot = cube_edge_pre_rotation(name))
        [ for (p = [[0, scaled_inset.y, 2 * scaled_inset.z], [0, scaled_inset.y, pos.z], [pos.x, pos.y, pos.z], [neg.x, pos.y, pos.z]])
            apply_rot(face_rot, apply_rot(edge_rot, p)) ];

/******* Puzzle containers and lids *******/

module packing_box(dim, thickness, insets = 0.25) {
    
    render(convexity = 2)
    difference() {
        beveled_cube(dim + [(thickness + insets) * 2, (thickness + insets) * 2, thickness + insets]);
        translate([thickness, thickness, thickness])
        cube(dim + [insets * 2, insets * 2, insets]);
    }
    
}

$tray_scale = 16;
$tray_padding = 2.5;
$tray_opening_height = 5.6;
$tray_opening_border = 4;
$piece_holder_buf = 0.35;

module packing_tray(opening_width = undef, opening_depth = undef, opening_polygon = undef, opening_polygons = undef,
    piece_holder_spec = [], piece_holder_polygon = undef, piece_holder_x_adj = 0, finger_wedge = undef, finger_wedge_radius = 0.5,
    render_as_lid = false, title = undef, subtitles = undef) {
    
    polys = opening_polygons ? opening_polygons :
        opening_polygon ? [opening_polygon] :
        [[[0, 0], [0, opening_depth], [opening_width, opening_depth], [opening_width, 0]]];
    
    opening_min_x = min([ for (poly = polys, p = poly) p.x ]);
    opening_max_x = max([ for (poly = polys, p = poly) p.x ]);
    opening_min_y = min([ for (poly = polys, p = poly) p.y ]);
    opening_max_y = max([ for (poly = polys, p = poly) p.y ]);
    opening_scaled_dim = [$tray_scale * (opening_max_x - opening_min_x), $tray_scale * (opening_max_y - opening_min_y), $tray_opening_height + $burr_inset];
    
    burr_info = strings_to_burr_info(piece_holder_spec);
    xlen = len(burr_info);
    ylen = xlen == 0 ? 0 : len(burr_info[0]);
    zlen = xlen == 0 ? 0 : len(burr_info[0][0]);
    
    has_piece_holder = xlen != 0 || piece_holder_polygon;
    
    piece_holder_raw_width = piece_holder_polygon ? max(poly_x(piece_holder_polygon)) : xlen;
    piece_holder_width = finger_wedge
        ? max(piece_holder_raw_width, finger_wedge.x + finger_wedge_radius) * $tray_scale
        : piece_holder_raw_width * $tray_scale;
    piece_holder_depth = (piece_holder_polygon ? range(poly_y(piece_holder_polygon)) : ylen) * $tray_scale + 2 * $piece_holder_buf;
    
    piece_holder_loc = [
        opening_scaled_dim.x + $tray_opening_border * 2 + piece_holder_x_adj - $piece_holder_buf,
        $tray_opening_border + (opening_scaled_dim.y - piece_holder_depth) / 2,
        $tray_padding + 0.001
    ];
    
    // Add the opening dimensions to the dimensions of the border and internal padding.
    tray_frame_dim = opening_scaled_dim +
        [piece_holder_width + piece_holder_x_adj + $tray_opening_border * 2 + (has_piece_holder ? $tray_opening_border : 0),
         $tray_opening_border * 2,
         $tray_padding];
    
    if (render_as_lid) {
        
        packing_tray_lid(tray_frame_dim + [0.5, 0.5, $burr_inset], $tray_padding, title, subtitles, min(8.5, tray_frame_dim.z));
        
    } else {
        
        render(convexity = 2)
        difference() {
            
            // Render the tray frame
            beveled_cube(tray_frame_dim);

            // Remove the opening
            translate([$tray_opening_border, $tray_opening_border, $tray_padding + 0.001])
            linear_extrude(opening_scaled_dim.z)
            for (poly = polys) {
                polygon($tray_scale * poly);
            }

            // Remove the spare piece holder
            
            if (piece_holder_polygon) {
                translate(piece_holder_loc)
                linear_extrude(opening_scaled_dim.z)
                polygon(($tray_scale + 2 * $piece_holder_buf) * piece_holder_polygon);
            }
            else if (xlen != 0) {
                translate(piece_holder_loc)
                burr_piece(burr_info, $burr_scale = [$tray_scale, $tray_scale, opening_scaled_dim.z], $burr_inset = -$piece_holder_buf, $burr_bevel = 0);
            }
            
            // Remove the finger wedge
            if (finger_wedge) {
                translate(piece_holder_loc + [finger_wedge.x * $tray_scale, finger_wedge.y * $tray_scale, 0])
                cylinder(h = opening_scaled_dim.z, r = $tray_scale * finger_wedge_radius, $fn = 128);
            }

        }
        
    }
    
}

module packing_tray_lid(lid_cavity_dim, lid_border_dim, title, subtitles, finger_wedge_radius) {

    lid_cavity_dim_vec = vectorize(lid_cavity_dim);
    lid_border_dim_vec = vectorize(lid_border_dim);
    lid_frame_dim_vec = lid_cavity_dim_vec + cw(lid_border_dim_vec, [2, 2, 1]);
    
    render(convexity = 2)
    difference() {
        
        // Render the lid frame

        beveled_cube(lid_frame_dim_vec);
        
        // Remove the cavity

        translate(lid_border_dim_vec + [0, 0, iota])
        cube(lid_cavity_dim_vec);
        
        // Remove the labels
        
        // The spacing of the title and subtitles will be scaled to the lid size.
        // However, if the y dimension of the lid is less than 90, then we pretend it's 90
        // for spacing purposes; otherwise the titles will appear too squished together.
        y_center = lid_frame_dim_vec.y / 2;
        y_for_spacing = max(lid_frame_dim_vec.y, 90);

        if (title) {
            translate([lid_frame_dim_vec.x / 2, y_center + y_for_spacing * 1/8, 0])
            lid_text(title);
        }
        if (subtitles) {
            for (i=[0:len(subtitles)-1]) {
                translate([lid_frame_dim_vec.x / 2, y_center + y_for_spacing * (-1 - 2*i)/16, 0])
                lid_text(subtitles[i], relative_scale = 0.6);
            }
        }
        
        if (finger_wedge_radius) {

            // Remove the finger wedges
            
            translate([lid_frame_dim_vec.x / 2, lid_border_dim_vec.y + 0.001, lid_frame_dim_vec.z])
            rotate([90, 0, 0])
            cylinder(h = lid_border_dim_vec.y + 0.002, r = finger_wedge_radius, $fn = 128);
            
            translate([lid_frame_dim_vec.x / 2, lid_frame_dim_vec.y + 0.001, lid_frame_dim_vec.z])
            rotate([90, 0, 0])
            cylinder(h = lid_border_dim_vec.y + 0.002, r = finger_wedge_radius, $fn = 128);
            
        }
        
    }
    
}

module lid_text(str, relative_scale = 1.0) {
    
    translate([0, 0, 1])
    rotate([0, 180, 0])
    linear_extrude(1)
    scale(relative_scale)
    text(str, halign = "center", valign = "center");

}

/******* Modules for beveled shapes *******/

module beveled_cube(dim, center = false) {

    dim_vec = vectorize(dim);
    
    translate(center ? -dim_vec / 2 : [0, 0, 0])
    beveled_prism([[0, 0], [0, dim_vec.y], [dim_vec.x, dim_vec.y], [dim_vec.x, 0]], dim_vec.z);
    
}

module beveled_prism(polygon, height, center = false) {
    
    top = [ for (p = polygon) [ p.x, p.y, height ] ];
        
    assert(
        norm(unit_vector(polygon_normal(top)) - [0, 0, -1]) < $poly_err_tolerance,
        "beveled_prism: faces of the specified polygon must wind clockwise."
    );

    bottom = [ for (i = [len(polygon)-1:-1:0]) let (p = polygon[i]) [ p.x, p.y, 0] ];
        
    sides = [
        for (i = [0:len(polygon)-1])
        let (p = polygon[i], q = polygon[(i + len(polygon) - 1) % len(polygon)]) [
            [ p.x, p.y, 0 ], [ p.x, p.y, height ], [ q.x, q.y, height ], [q.x, q.y, 0 ]
    ] ];

    poly = make_beveled_poly(concat(sides, [top, bottom]));
        
    translate(center ? [0, 0, -height / 2] : [0, 0, 0])
    polyhedron(poly[0], poly[1]);
    
}

module beveled_polyhedron(points, faces) {
    
    literal_faces = [ for (f = faces) [ for (index = f) points[index] ] ];
    poly = make_beveled_poly(literal_faces);
    polyhedron(poly[0], poly[1]);
    
}

/******* Helper functions *******/

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
         
component_ids = ".abcdefghijklmnopqrstuvwxyz";

// Parse a single character, with optional annotations.

valid_annotations = [ "connect", "clabel", "components", "label_orient", "label_text", "label_hoffset", "label_voffset", "label_scale" ];

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

// Finds a character in a string, accounting for balanced braces.
    
function find_character(string, ch, i, braces_depth = 0) =
      i >= len(string) ? i
    : string[i] == ch && braces_depth == 0 ? i
    : string[i] == "}" && braces_depth > 0 ? find_character(string, ch, i + 1, braces_depth - 1)
    : string[i] == "}" ? assert(false, "Invalid burr specification.")
    : string[i] == "{" ? find_character(string, ch, i + 1, braces_depth + 1)
    : find_character(string, ch, i + 1, braces_depth);

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

function wrap(burr_map) =
    [ for (layer = burr_map) [ for (row = layer) [ for (voxel = row) voxel[0] == undef ? [voxel] : voxel] ] ];
  
function bit_of(n, exponent) = floor(n / pow(2, exponent)) % 2;

function copies(n, burr) = n == 0 ? [] : concat(copies(n-1, burr), [burr]);
    
/***** Polyhedron Simplification *****/

function make_poly(faces) =
    let (merged_faces = merge_coplanar_faces(remove_degeneracies(faces)))
    make_poly_2(remove_degeneracies(merged_faces));
    
function make_poly_2(faces) =
    let (points = flatten(faces))
    let (point_index = make_point_index(quicksort_points(points)))
    let (mapped_faces = [ for (f=faces) [ for (p=f) index_of_point(point_index, p) ] ])
    let (reordered_faces = reorder_faces(mapped_faces))
    let (result = remove_unused_vertices(point_index, reordered_faces))
    let (dummy_var = validate_manifold(result[0], result[1]))
    result;
    
function remove_degeneracies(faces) =
    let (simplified_faces_1 = [ for (f = faces) remove_face_degeneracies(f) ])
    let (simplified_faces_2 = [ for (f = simplified_faces_1) remove_collinear_points(simplified_faces_1, f) ])
    let (simplified_faces_3 = [ for (f = simplified_faces_2) if (len(f) > 0) f ])
      faces == simplified_faces_3 ? faces               // No reductions happened
    : remove_degeneracies(simplified_faces_3);          // Something changed, so iterate
    
function remove_face_degeneracies(face) =
    let (reduced_face = remove_face_degeneracies_once(face))
      len(face) == len(reduced_face) ? reduced_face     // No reductions happened
    : remove_face_degeneracies(reduced_face);           // Something changed, so iterate

function remove_face_degeneracies_once(face) = len(face) == 0 ? [] : [
    for (k=[0:len(face)-1])
    if (norm(face[k] - face[(k+1) % len(face)]) >= $poly_err_tolerance &&
        norm(face[k] - face[(k+2) % len(face)]) >= $poly_err_tolerance &&
        norm(face[(k+len(face)-1) % len(face)] - face[(k+1) % len(face)]) >= $poly_err_tolerance)
    face[k]
];

// We can remove extraneous collinear points, mainly for reasons of efficiency. This has to
// be done carefully in order to preserve manifoldness: we can only shorten a collinear sequence of
// points [a, b, c] from one face *if* the edge pairings of [a, b] and [b, c] are also collinear,
// i.e., *if* the collinear sequence [c, b, a] appears on some other face.

function remove_collinear_points(faces, face) = len(face) == 0 ? [] : [
    for (k=[0:len(face)-1])
    let (a = face[(k-1+len(face)) % len(face)], b = face[k], c = face[(k+1) % len(face)])
    let (foo = assert(!is_undef(a) && !is_undef(b) && !is_undef(c), face))
    if (norm(cross(b - a, c - b)) >= $poly_err_tolerance || !is_sequential_triplet(faces, [c, b, a]))
    face[k]
];

function is_sequential_triplet(faces, points, i = 0) =
      i >= len(faces) ? false
    : is_sequential_triplet_in_face(faces[i], points) ? true
    : is_sequential_triplet(faces, points, i + 1);

function is_sequential_triplet_in_face(face, points, j = 0) =
      j >= len(face) ? false
    : norm(face[j] - points[0]) < $poly_err_tolerance &&
      norm(face[(j+1) % len(face)] - points[1]) < $poly_err_tolerance &&
      norm(face[(j+2) % len(face)] - points[2]) < $poly_err_tolerance ? true
    : is_sequential_triplet_in_face(face, points, j + 1);

function num_faces_containing(faces, point) =
    sum([ for (face = faces) face_contains_point(face, point) ? 1 : 0 ]);
        
function face_contains_point(face, point, i = 0) =
      i >= len(face) ? false
    : norm(point - face[i]) < $poly_err_tolerance ? true
    : face_contains_point(face, point, i + 1);

// merge_coplanar_faces: find opportunities to merge adjacent coplanar faces, and iterate
// until reaching a state where no such opportunities exist.

function merge_coplanar_faces(faces) =
    let (merged_faces = remove_degeneracies(merge_coplanar_faces_once(faces)))
      len(faces) == len(merged_faces) ? merged_faces    // No mergers happened
    : merge_coplanar_faces(merged_faces);               // Something changed, so iterate

function merge_coplanar_faces_once(faces, i = 0) =
      i >= len(faces) ? faces
    : ( let (face_normal = polygon_normal(faces[i]))
        let (amalgamated_face_info = find_mergeable_face(faces, i, face_normal, i+1))
        is_undef(amalgamated_face_info) ? merge_coplanar_faces_once(faces, i+1)
          : // We found a way to merge another face with face i.
            let (coplanar_index = amalgamated_face_info[0])
            assert(coplanar_index > i)
            let(amalgamated_face = amalgamated_face_info[1])
            // Remove face coplanar_index from the list, and replace face i with the amalgamated face.
            merge_coplanar_faces_once(replace_in_list(remove_from_list(faces, coplanar_index), i, amalgamated_face), i)
       );

// find_merageable_face: find an adjacent coplanar face that can be merged with face face_index.
// If such a face is found, return [j, amalgam], where j is the index of the face to be merged
// and amalgam is the amalgamated face.

// To determine eligibility of the merge, a complex set of conditions must be evaluated. This is
// to ensure that the simplified polyhedron continues to meet OpenSCAD's fairly strict manifoldness
// requirements.

// First, we compute the surface normals and d-values of the two faces. (The d-value is equal to
// unit_vector(normal) * p, where p is any point on the polygon; two polygons lie on the same plane
// just if they have the same normal and d-value.)

// Then, two faces are mergeable provided that each of the following conditions holds:
// 1. *Either* they have the same normal and d-value, *or* one of the faces is degenerate (meaning
//    all its points are collinear).
// 2. The faces share at least one edge, but do not share multiple *nonconsecutive* edges. (If they
//    do, then merging them would yield a non-simply-connected face.)
// 3. Once the faces are merged, and after removing degeneracies from the amalgam, no vertex
//    appears in the amalgam more than once. (If a vertex does appear more than once, then the
//    amalgamated face has an interior cycle, which violates manifoldness.)

function find_mergeable_face(faces, face_index, face_normal, j) =

      j >= len(faces) ? undef

    : ( let (face1 = faces[face_index],
             face2 = faces[j],
             face2_normal = polygon_normal(faces[j]),
             face1_d = unit_vector(face_normal) * face1[0],
             face2_d = unit_vector(face2_normal) * face2[0])
             
        // Check condition 1. If either face is degenerate, or if they have the same normal and
        // d-value, then we can proceed.
        norm(face_normal) < $poly_err_tolerance || norm(face2_normal) < $poly_err_tolerance ||
        (norm(unit_vector(face_normal) - unit_vector(face2_normal)) < $poly_err_tolerance &&
         abs(face1_d - face2_d) < $poly_err_tolerance)
         
          ? let (indices = edge_pair_indices(face1, face2))
          
            // Check condition 2. If the faces share at least one edge, and all the shared edges
            // are consecutive along the face-cycle, then we can proceed.
            len(indices) > 0
                && are_indices_cyclically_consecutive(len(face1), [ for (epi = indices) epi[0] ])
                && are_indices_cyclically_consecutive(len(face2), [ for (epi = indices) epi[1] ])
                    
            ? let (amalgam = remove_face_degeneracies(amalgamate_faces(face1, face2, indices[0])))
              let (sorted_vertices = quicksort_points(amalgam))
              let (duplicate_vertex = find_duplicate(sorted_vertices))
                
                // Check condition 3. If there are no duplicate vertices in the amalgamated face,
                // then we've found a valid merge. Return the amalgam.
                is_undef(duplicate_vertex) ? [j, amalgam]
                
         // If any of the conditions failed, then try the next face.
                
                : find_mergeable_face(faces, face_index, face_normal, j + 1)
            : find_mergeable_face(faces, face_index, face_normal, j + 1)
          : find_mergeable_face(faces, face_index, face_normal, j + 1)

      );

function amalgamate_faces(face1, face2, indices) =
    concat([ for (k=[1:len(face1)-1]) face1[(indices[0]+k) % len(face1)] ],
           [ for (k=[0:len(face2)-2]) face2[(indices[1]+k) % len(face2)] ]);

function edge_pair_indices(face1, face2) =
    [ for (i = [0:len(face1)-1])
        let (edge_pair = edge_pair_indices_2(face1, face2, i))
        if (!is_undef(edge_pair))
        edge_pair
    ];

function edge_pair_indices_2(face1, face2, i, j = 0) =
      j >= len(face2) ? undef
    : is_valid_edge_pair(face1, face2, i, j) ? [i, j]
    : edge_pair_indices_2(face1, face2, i, j+1);
           
function is_valid_edge_pair(face1, face2, i, j) =
    let(p = face1[i], q = face1[(i+1) % len(face1)])
    norm(p - face2[j]) < $poly_err_tolerance &&
    norm(q - face2[(j-1+len(face2)) % len(face2)]) < $poly_err_tolerance &&
    (norm(polygon_normal(face1)) >= $poly_err_tolerance || all_points_between(face1, p, q)) &&
    (norm(polygon_normal(face2)) >= $poly_err_tolerance || all_points_between(face2, p, q));

function all_points_between(points, p, q, i = 0) =
      i >= len(points) ? true
    : (points[i] - p) * (points[i] - q) >= $poly_err_tolerance ? false
    : all_points_between(points, p, q, i + 1);

function are_indices_cyclically_consecutive(length, indices) =
    let (transition_points = [
        for (i = [0:length-1])
        if (list_contains(indices, i) != list_contains(indices, (i + 1) % length))
        i ])
    len(transition_points) <= 2;
    
function make_point_index(points) = [
    for (n = [0:len(points)-1])
    if (n == 0 || abs(compare_points(points[n], points[n-1])) > $poly_err_tolerance)
    points[n]
];
    
function index_of_point(index, p) = index_of_point_rec(index, p, 0, len(index));

function index_of_point_rec(index, p, lower, upper) =
    assert(lower < upper)
    let (mid = floor((upper + lower) / 2))
    let (cmp = compare_points(p, index[mid]))
      cmp < -$poly_err_tolerance ? index_of_point_rec(index, p, lower, mid)
    : cmp > $poly_err_tolerance ? index_of_point_rec(index, p, mid+1, upper)
    : mid;
    
function reorder_faces(faces) =
    quicksort_scalar_lists([ for (face = faces) reorder_face(face) ]);
        
function reorder_face(face) =
    let (first_index = minarg(face))
    [ for (i=[0:len(face)-1]) face[(first_index + i) % len(face)] ];

function remove_unused_vertices(vertices, faces) = let(
    used_vertices = [ for (v = [0:len(vertices)-1]) len(faces_containing_vertex(faces, v)) > 0 ],
    new_vertices = flatten([ for (v = [0:len(vertices)-1])
                len(faces_containing_vertex(faces, v)) > 0 ? [vertices[v]] : []
            ]),
    mapped_vertices = [ for (vertex = vertices) index_of(new_vertices, vertex) ],
    new_faces = [ for (face = faces) [ for (v = face) mapped_vertices[v] ] ]
    )
    [new_vertices, new_faces];
   
function minarg(list, i=0, current_min=undef, current_minarg=undef) =
      i >= len(list) ? current_minarg
    : is_undef(current_min) || list[i] < current_min ? minarg(list, i+1, list[i], i)
    : minarg(list, i+1, current_min, current_minarg);

function quicksort_integers(ints) = len(ints) == 0 ? [] : let(
    pivot   = ints[floor(len(ints)/2)],
    lesser  = [ for (y = ints) if (y < pivot) y ],
    equal   = [ for (y = ints) if (y == pivot) y ],
    greater = [ for (y = ints) if (y > pivot) y ]
) concat(
    quicksort_integers(lesser), equal, quicksort_integers(greater)
);

function quicksort_points(points) = len(points) == 0 ? [] : let(
    pivot   = points[floor(len(points)/2)],
    lesser  = [ for (y = points) if (compare_points(y, pivot) <= -$poly_err_tolerance) y ],
    equal   = [ for (y = points) if (abs(compare_points(y, pivot)) < $poly_err_tolerance) y ],
    greater = [ for (y = points) if (compare_points(y, pivot) >= $poly_err_tolerance) y ]
) concat(
    quicksort_points(lesser), equal, quicksort_points(greater)
);
    
function compare_points(a, b) =
    assert(is_list(a) && is_list(b))
    abs(a.x - b.x) < $poly_err_tolerance ? abs(a.y - b.y) < $poly_err_tolerance ? a.z - b.z : a.y - b.y : a.x - b.x;
    
function quicksort_scalar_lists(lists) = len(lists) == 0 ? [] : let(
    pivot   = lists[floor(len(lists)/2)],
    lesser  = [ for (y = lists) if (compare_scalar_lists(y, pivot) < 0) y ],
    equal   = [ for (y = lists) if (compare_scalar_lists(y, pivot) == 0) y ],
    greater = [ for (y = lists) if (compare_scalar_lists(y, pivot) > 0) y ]
) concat(
    quicksort_scalar_lists(lesser), equal, quicksort_scalar_lists(greater)
);
    
function compare_scalar_lists(a, b, i=0) =
      i >= len(a) && i >= len(b) ? 0
    : i >= len(b) ? 1
    : i >= len(a) ? -1
    : a[i] == b[i] ? compare_scalar_lists(a, b, i+1)
    : a[i] - b[i];

// TODO This checks for edge-validity, but not corner-validity
    
non_manifold_surface_err = "Non-manifold surface! This could be a bug in puzzlecad.";

function validate_manifold(points, faces) =
    let (
        all_edges = [ for (f = faces, i = [0:len(f)-1]) [ f[i], f[(i+1) % len(f)] ] ],
        sorted_edges = quicksort_scalar_lists(all_edges),
        reversed_edges = [ for (edge = all_edges) [ edge[1], edge[0] ] ],
        sorted_reversed_edges = quicksort_scalar_lists(reversed_edges)
    )
    let (duplicate_edge = find_duplicate(sorted_edges))
    assert(is_undef(duplicate_edge), str(non_manifold_surface_err, " Duplicate edge: ", sorted_edges[duplicate_edge]))
    assert(sorted_edges == sorted_reversed_edges, str(non_manifold_surface_err, " There are unpaired edge(s)."))
    let (degenerate_face = find_degenerate_face(points, faces))
    assert(is_undef(degenerate_face), str(non_manifold_surface_err, " Degenerate face: ", degenerate_face))
    //let (noncoplanar_face = find_noncoplanar_face(points, faces))
    //assert(is_undef(noncoplanar_face), str(non_manifold_surface_err, " Noncoplanar face: ", noncoplanar_face))
    let (cyclic_face = find_cyclic_face(faces))
    assert(is_undef(cyclic_face), str(non_manifold_surface_err, " Face has an internal cycle: ", cyclic_face));
 
function find_duplicate(sorted_list, i = 0) =
      i >= len(sorted_list) - 1 ? undef
    : sorted_list[i] == sorted_list[i+1] ? i
    : find_duplicate(sorted_list, i + 1);
        
function find_degenerate_face(points, faces, i = 0) =
      i >= len(faces) ? undef
    : let (face_normal = polygon_normal([ for (p = faces[i]) points[p] ]))
      !(norm(face_normal) >= $poly_err_tolerance) ? i
    : find_degenerate_face(points, faces, i + 1);
    
function find_cyclic_face(faces, i = 0) =
      i >= len(faces) ? undef
    : let (sorted_vertices = quicksort_integers(faces[i]))
      let (duplicate_vertex = find_duplicate(sorted_vertices))
      is_undef(duplicate_vertex) ? find_cyclic_face(faces, i + 1)
    : i;
    
function find_noncoplanar_face(points, faces, i = 0) =
      i >= len(faces) ? undef
    : !is_coplanar_polygon([ for (p = faces[i]) points[p] ]) ? i
    : find_noncoplanar_face(points, faces, i + 1);
    
function is_coplanar_polygon(poly) =
    let (polygon_normal = polygon_normal(poly),
         nonmatching_vertices = [ for (i = [0:len(poly)-1])
             let (a = poly[i], b = poly[(i+1) % len(poly)], c = poly[(i+2) % len(poly)])
             let (normal = cross(b - a, c - b))
             if (norm(normal) >= $poly_err_tolerance && norm(cross(normal, polygon_normal)) >= $poly_err_tolerance)
             i
         ])
    len(nonmatching_vertices) == 0;

/******* Polyhedron Beveling *******/

function make_beveled_poly(faces) =
    !has_beveling() ? make_poly(faces)
    : let (poly = make_poly(merge_coplanar_faces(faces)))
      let (beveled_poly = make_beveled_poly_normalized(poly[0], poly[1]))
      beveled_poly;
    
function has_beveling() =
    $burr_bevel >= 0.01 ||
    is_positive_bevel($burr_outer_x_bevel) ||
    is_positive_bevel($burr_outer_y_bevel) ||
    is_positive_bevel($burr_outer_z_bevel);
    
function is_positive_bevel(bevel) =
    let (bevel_or_pair = to_2_vector(bevel))
    bevel_or_pair[0] >= 0.01 || bevel_or_pair[1] >= 0.01;

function make_beveled_poly_normalized(vertices, faces) = let(
    
    face_normals = [ for (face=faces) polygon_normal([ for (v=face) vertices[v] ]) ],
        
    // faces_containing[v] is a list of all the face ids containing vertex id v.
    faces_containing =
        [ for (v=[0:len(vertices)-1]) faces_containing_vertex(faces, v) ],

    // vf_connectors is a list of elements of the form [ [v, f], prev, next ]
    // where [v, f] is a vertex_id,face_id pair, and prev and next are vertices
    // preceding and succeeding v, in cyclic order on the oriented face f.
    vf_connectors =
        [ for (v=[0:len(vertices)-1], f=faces_containing[v])
          let (n = index_of(faces[f], v))
            [ [v, f], [faces[f][(n-1+len(faces[f])) % len(faces[f])],
                                 faces[f][(n+1) % len(faces[f])] ] ]
        ],
    
    // edge_face_pairings is a mapping from oriented edges to the face_id on
    // which those edges appear. Specifically, it's a list of elements of the
    // form [[v1, v2], f], where v1 and v2 are vertex ids specifying an
    // oriented edge, and f is the (unique) face on which that edge appears.      
    edge_face_pairings =
        [ for (f=[0:len(faces)-1], n=[0:len(faces[f])-1])
            [[faces[f][n], faces[f][(n+1) % len(faces[f])]], f]
        ],
        
    // edge_schemes is the "symmetrization" of edge_face_pairings: it's a list
    // of elements of the form [[v1, v2], f1, f2], where v1 and v2 are vertex
    // ids with v1 < v2, f1 is the "positively oriented" face touching that
    // edge (the face containing the oriented edge [v1, v2]), and f2 is the
    // "negatively oriented" face touching that edge (containing the oriented
    // edge [v2, v1]).
    edge_schemes =
        [ for (edge_face_pairing = edge_face_pairings)
            if (edge_face_pairing[0][0] < edge_face_pairing[0][1])
            let (other_face = lookup_kv(edge_face_pairings, [edge_face_pairing[0][1], edge_face_pairing[0][0]]))
            assert(!is_undef(other_face), str("Invalid polyhedron? Unpaired edge: ", edge_face_pairing))
            [ edge_face_pairing[0], edge_face_pairing[1], other_face ]
        ],
        
    // edge_convexities tells whether the faces joining each edge meet at a
    // convex or concave outer angle (values > 0 are convex).
    edge_convexities =
        [ for (edge_scheme = edge_schemes)
            let (edge_vector = vertices[edge_scheme[0][0]] - vertices[edge_scheme[0][1]],
                 edge_normal_1 = cross(edge_vector, face_normals[edge_scheme[1]]),
                 edge_normal_2 = cross(edge_vector, face_normals[edge_scheme[2]]))
            [edge_scheme[0], [cross(edge_normal_1, edge_normal_2) * edge_vector, 180 - angle(edge_normal_1, edge_normal_2)]]
        ],
        
    xmin = min([ for (v = vertices) v.x ]),
    xmax = max([ for (v = vertices) v.x ]),
    ymin = min([ for (v = vertices) v.y ]),
    ymax = max([ for (v = vertices) v.y ]),
    zmin = min([ for (v = vertices) v.z ]),
    zmax = max([ for (v = vertices) v.z ]),
        
    outer_x_bevel = to_2_vector($burr_outer_x_bevel),
    outer_y_bevel = to_2_vector($burr_outer_y_bevel),
    outer_z_bevel = to_2_vector($burr_outer_z_bevel),

    edge_bevelings =
        [ for (edge_scheme = edge_schemes)
            let (p = vertices[edge_scheme[0][0]], q = vertices[edge_scheme[0][1]])
            let (bevel =
                  outer_x_bevel && values_are_close(xmin, p.x, q.x) ? outer_x_bevel[0]
                : outer_x_bevel && values_are_close(xmax, p.x, q.x) ? outer_x_bevel[1]
                : outer_y_bevel && values_are_close(ymin, p.y, q.y) ? outer_y_bevel[0]
                : outer_y_bevel && values_are_close(ymax, p.y, q.y) ? outer_y_bevel[1]
                : outer_z_bevel && values_are_close(zmin, p.z, q.z) ? outer_z_bevel[0]
                : outer_z_bevel && values_are_close(zmax, p.z, q.z) ? outer_z_bevel[1]
                : $burr_bevel)
            [edge_scheme[0], bevel]
        ],

    convexity_signs =
        [ for (connector = vf_connectors)
          let (v = connector[0][0], f = connector[0][1], prev = connector[1][0], next = connector[1][1])
          let (vector1 = vertices[prev] - vertices[v], vector2 = vertices[next] - vertices[v])
          [ [v, f], cross(vector1, vector2) * face_normals[f] ]
        ],
        
    ordered_faces_containing =
        [ for (v=[0:len(vertices)-1]) ordered_faces_containing_vertex(faces, edge_face_pairings, v) ],

    // new_vertex_ids is a list of unique identifiers for vertices in the beveled polyhedron.
    // They take the form [v, f, loc], where f is a face id, v a vertex id appearing on that
    // face, and loc a sub-locator. The sub-locator will be 0 for convex [v, f]-pairs, and
    // -1 or 1 for concave.
    new_vertex_ids =
        [ for (v=[0:len(vertices)-1], f=faces_containing[v]) [v, f] ],
            
    new_vertex_id_lookup =
        [ for (id=[0:len(new_vertex_ids)-1]) [new_vertex_ids[id], id] ],
            
    new_vertex_locations = [
        
          for (c = vf_connectors)
          
          let (vertex = c[0][0], face = c[0][1], prev_vertex = c[1][0], next_vertex = c[1][1])
          
          let (inedge = vertices[vertex] - vertices[prev_vertex],
               outedge = vertices[next_vertex] - vertices[vertex],
               inedge_setback_dir = unit_vector(cross(-inedge, face_normals[face])),
               outedge_setback_dir = unit_vector(cross(-outedge, face_normals[face])),
               vertex_angle = angle(inedge, outedge),
               inedge_convexity = lookup_kv_unordered(edge_convexities, [prev_vertex, vertex]),
               outedge_convexity = lookup_kv_unordered(edge_convexities, [vertex, next_vertex]),
               inedge_bevel = lookup_kv_unordered(edge_bevelings, [prev_vertex, vertex])  /* * sqrt(1/2) / sin(inedge_convexity[1] / 2) */,
               outedge_bevel = lookup_kv_unordered(edge_bevelings, [vertex, next_vertex]) /* * sqrt(1/2) / sin(outedge_convexity[1] / 2) */
          )

          if (inedge_convexity[0] < -0.001 && outedge_convexity[0] < -0.001)
              // Two concave edges: no beveling; vertex retains its original location.
              vertices[vertex]
          
          else if (inedge_convexity[0] < -0.001)
              // Only the inedge is concave.
              vertices[vertex] - unit_vector(inedge) * outedge_bevel / sqrt(2) / sin(vertex_angle)
          
          else if (outedge_convexity[0] < -0.001)
              // Only the outedge is concave.
              vertices[vertex] + unit_vector(outedge) * inedge_bevel / sqrt(2) / sin(vertex_angle)
          
          else
              vertices[vertex] +
                  (inedge_setback_dir * inedge_bevel + outedge_setback_dir * outedge_bevel) / sqrt(2) /
                  (1 + inedge_setback_dir * outedge_setback_dir)

        ],
          
    new_ordinary_faces =
        [ for (f=[0:len(faces)-1]) [ for (v=faces[f]) [v, f] ] ],
        
    new_edge_bevel_faces =
        [ for (scheme=edge_schemes) let (
            v1 = scheme[0][0], v2 = scheme[0][1], f1 = scheme[1], f2 = scheme[2]
          ) ( [[v1, f1], [v1, f2], [v2, f2], [v2, f1]] ) ],
        
    start_indices_for_corner_bevel_faces =
        [ for (v=[0:len(vertices)-1])
            find_indices_for_corner_bevel_face(v, ordered_faces_containing[v], faces, edge_convexities)
        ],
        
    new_corner_bevel_faces =
        [ for (v=[0:len(vertices)-1])
          let (ofc = ordered_faces_containing[v])
          let (start_indices = start_indices_for_corner_bevel_faces[v])
          for (k = [0:len(start_indices)-1])
          let (start = start_indices[k])
          let (count = len(start_indices) == 1 ? len(ofc) : (start_indices[(k+1) % len(start_indices)] - start + len(ofc)) % len(ofc))
          if (count >= 3)
          for (w=[1:count-2])
          [ [v, ofc[start]], [v, ofc[(start + w) % len(ofc)]], [v, ofc[(start + w + 1) % len(ofc)]] ]
        ],
   
    new_faces = concat(new_ordinary_faces, new_edge_bevel_faces, new_corner_bevel_faces),
            
    literal_new_faces = [ for (f = new_faces) [ for (v = f) new_vertex_locations[lookup_kv(new_vertex_id_lookup, v)] ] ],
        
    linearized_new_faces =
        [ for (new_face = new_faces)
            [ for (v = new_face) lookup_kv(new_vertex_id_lookup, v) ],
        ]
            
    )
//    [new_vertex_locations, linearized_new_faces];
    make_poly(literal_new_faces);

function faces_containing_vertex(faces, vertex, k = 0) =
    k >= len(faces) ? []
    : list_contains(faces[k], vertex) ? concat([k], faces_containing_vertex(faces, vertex, k+1))
    : faces_containing_vertex(faces, vertex, k+1);

function ordered_faces_containing_vertex(faces, edge_face_pairings, vertex, k = 0) =
    k >= len(faces) ? []
    : list_contains(faces[k], vertex) ? ordered_faces_containing_vertex_2(faces, edge_face_pairings, vertex, [k])
    : ordered_faces_containing_vertex(faces, edge_face_pairings, vertex, k+1);

function ordered_faces_containing_vertex_2(faces, edge_face_pairings, vertex, list) =
    let(prev_face = list[len(list)-1])
    let(index_in_prev = index_of(faces[prev_face], vertex))
    let(prev_vertex_in_prev_face = faces[prev_face][(index_in_prev + len(faces[prev_face]) - 1) % len(faces[prev_face])])
    let(mirror_edge = [vertex, prev_vertex_in_prev_face])
    let(this_face = lookup_kv(edge_face_pairings, mirror_edge))
    this_face == list[0] ? list
        : ordered_faces_containing_vertex_2(faces, edge_face_pairings, vertex, concat(list, [this_face]));

function find_index_for_corner_bevel_face(v, ordered_faces_containing, faces, edge_convexities, k = 0) =
    k >= len(ordered_faces_containing) ? 0
    : let(f = ordered_faces_containing[k])
      let(index_in_face = index_of(faces[f], v))
      let(edge = [v, faces[f][(index_in_face + 1) % len(faces[f])]])
      let(convexity = lookup_kv_unordered(edge_convexities, edge))
      convexity[0] < 0 ? k
    : find_index_for_corner_bevel_face(v, ordered_faces_containing, faces, edge_convexities, k + 1);
        
function find_indices_for_corner_bevel_face(v, ordered_faces_containing, faces, edge_convexities, k = 0, result = []) =
    k >= len(ordered_faces_containing)
    ? (len(result) == 0 ? [find_index_for_corner_bevel_face(v, ordered_faces_containing, faces, edge_convexities)] : result)
    : let(f = ordered_faces_containing[k])
      let(index_in_face = index_of(faces[f], v))
      let(inedge = [faces[f][(index_in_face - 1 + len(faces[f])) % len(faces[f])], v])
      let(outedge = [v, faces[f][(index_in_face + 1) % len(faces[f])]])
      let(in_convexity = lookup_kv_unordered(edge_convexities, inedge))
      let(out_convexity = lookup_kv_unordered(edge_convexities, outedge))
      find_indices_for_corner_bevel_face(v, ordered_faces_containing, faces, edge_convexities, k + 1,
        in_convexity[0] < -0.001 && out_convexity[0] < -0.001 ? concat(result, [(k+1) % len(ordered_faces_containing)]) : result)
    ;

/***** Cube Geometry *****/

cube_face_names = ["z-", "y-", "x-", "x+", "y+", "z+"];

directions = [[0, 0, -1], [0, -1, 0], [-1, 0, 0], [1, 0, 0], [0, 1, 0], [0, 0, 1]];

direction_map = [ for (face = [0:5]) [cube_face_names[face], directions[face]] ];

cube_face_rotations = [[180, 0, 0], [90, 0, 0], [0, -90, 0], [0, 90, 0], [-90, 0, 0], [0, 0, 0]];

cube_face_rotation_map = [ for (face = [0:5]) [cube_face_names[face], cube_face_rotations[face]] ];

cube_edge_names = [ ["y-", "x+", "y+", "x-"], ["z+", "x+", "z-", "x-"], ["y+", "z+", "y-", "z-"],
                    ["y+", "z-", "y-", "z+"], ["z-", "x+", "z+", "x-"], ["y+", "x+", "y-", "x-"] ];

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

/***** String manipulation *****/
    
// Splits a string into a vector of tokens.
function strtok(str, sep, i=0, token="", result=[]) =
    is_undef(str) ? undef
    : len(str) == 0 ? []
    : i == len(str) ? concat(result, token)
    : str[i] == sep ? strtok(str, sep, i+1, "", concat(result, token))
    : strtok(str, sep, i+1, str(token, str[i]), result);

// Returns a substring of a given string.
function substr(str, pos=0, len=-1, substr="") =
    is_undef(str) ? undef :
    pos >= len(str) ? substr :
	len == 0 ? substr :
	len == -1 ? substr(str, pos, len(str)-pos, substr) :
	substr(str, pos+1, len-1, str(substr, str[pos]));
    
// Returns the next occurrence of char in str, starting at position i.
function strfind(str, char, i=0) =
    str[i] == undef ? undef :
    str[i] == char ? i :
    strfind(str, char, i+1);

function substr_until(str, char, pos=0, substr="") =
    str[pos] == undef ? undef :
    str[pos] == char ? substr :
    substr_until(str, char, pos+1, str(substr, str[pos]));
    
function lookup_kv(kv, key, default=undef, i=0) =
    kv[i] == undef ? default :
    kv[i][0] == key ? (kv[i][1] != undef ? kv[i][1] : true) :
    lookup_kv(kv, key, default, i+1);

function put_kv(kv, entry, i=0) =
    is_undef(kv) ? [entry] :
    i >= len(kv) ? concat(kv, [entry]) :
    kv[i][0] == entry[0] ? replace_in_list(kv, i, entry) :
    put_kv(kv, entry, i + 1);

function lookup_kv_unordered(kv, key, default=undef, i=0) =
    kv[i] == undef ? default :
    kv[i][0] == key || kv[i][0] == [key[1],key[0]] ? kv[i][1] :
    lookup_kv_unordered(kv, key, default, i+1);
    
function is_substr(str, substr, i = 0) =
      i > len(str) - len(substr) ? false
    : is_substr_at(str, substr, i) ? true
    : is_substr(str, substr, i + 1);
    
function is_substr_at(str, substr, i, j = 0) =
      j >= len(substr) ? true
    : str[i + j] != substr[j] ? false
    : is_substr_at(str, substr, i, j + 1);
    
function str_interpolate(str, args, i = 0) =
    i >= len(str) ? "" :
    let (arg_index = str[i] == "$" ? digit(str[i + 1]) : undef)
    is_undef(arg_index)
        ? str(str[i], str_interpolate(str, args, i + 1))
        : str(args[arg_index], str_interpolate(str, args, i + 2));
        
function mkstring(list, sep = "", i = 0) =
      i >= len(list) ? ""
    : i == len(list) - 1 ? list[i]
    : str(list[i], sep, mkstring(list, sep, i + 1));
             
function atof(str) =
    !is_string(str) ? undef :
    str[0] == "-" ? -atof2(str, 0, 1) :
    str[0] == "+" ? atof2(str, 0, 1) :
    atof2(str, 0, 0);
    
function atof2(str, value, pos) =
    pos == len(str) ? value :
    str[pos] == "." ? value + atof3(str, pos + 1) :
    atof2(str, 10 * value + digit(str[pos]), pos + 1);
    
function atof3(str, pos) =
    pos == len(str) ? 0 :
    (digit(str[pos]) + atof3(str, pos + 1)) / 10;

function digit(char) =
    char == "0" ? 0 : char == "1" ? 1 : char == "2" ? 2 : char == "3" ? 3 : char == "4" ? 4 :
    char == "5" ? 5 : char == "6" ? 6 : char == "7" ? 7 : char == "8" ? 8 : char == "9" ? 9 :
    undef;

/***** Vector manipulation *****/

function zyx_to_xyz(burr) =
    burr == [] ? [] :
    [ for (x = [0:len(burr[0][0])-1])
        [ for (y = [0:len(burr[0])-1])
            [ for (z = [0:len(burr)-1])
                burr[z][y][x]
            ]
        ]
    ];
            
function to_2_vector(a) = is_num(a) ? [a, a] : a;
 
function vectorize(a) = is_num(a) ? [a, a, a] : a;

function is_3_vector(a) = len(a) == 3 && is_num(a[0]) && is_num(a[1]) && is_num(a[2]);
    
function lookup3(array, vector) = array[vector.x][vector.y][vector.z];

// The componentwise (Hadamard) product of a and b.
            
function cw(a, b) = 
    a[0] == undef || b[0] == undef ? a * b : [ for (i=[0:min(len(a), len(b))-1]) a[i]*b[i] ];
        
function cw_inverse(a) = [ 1 / a.x, 1 / a.y, 1 / a.z ];
        
function unit_vector(vector) = vector / norm(vector);

function angle(a, b) = assert(!is_undef(a) && !is_undef(b), [a, b]) atan2(norm(cross(a, b)), a*b);
    
function values_are_close(ref, a, b) = abs(ref - a) < $poly_err_tolerance && abs(ref - b) < $poly_err_tolerance;

function polygon_normal(poly) =
    sum([ for (n=[0:len(poly)-1]) cross(poly[n], poly[(n+1) % len(poly)]) ]);

function poly_x(poly) = [ for (p = poly) p.x ];

function poly_y(poly) = [ for (p = poly) p.y ];

function range(vec) = max(vec) - min(vec);

function apply_rot(rotation, vector) =
    let (
        applied_x = [
            vector.x,
            vector.y * cos(rotation.x) - vector.z * sin(rotation.x),
            vector.z * cos(rotation.x) + vector.y * sin(rotation.x)
        ],
        applied_y = [
            applied_x.x * cos(rotation.y) + applied_x.z * sin(rotation.y),
            applied_x.y,
            applied_x.z * cos(rotation.y) - applied_x.x * sin(rotation.y)
        ],
        applied_z = [
            applied_y.x * cos(rotation.z) - applied_y.y * sin(rotation.z),
            applied_y.y * cos(rotation.z) + applied_y.x * sin(rotation.z),
            applied_y.z
        ]
    )
    applied_z;

/***** List manipulation *****/
    
function indices(list) = [0:len(list)-1];

function list_contains(list, element, k = 0) =
    k >= len(list) ? false : list[k] == element ? true : list_contains(list, element, k+1);

function index_of(list, element, k = 0) =
    k >= len(list) ? -1 : list[k] == element ? k : index_of(list, element, k + 1);

function add_to_list(list, element) = concat(list, [element]);

function remove_from_list(list, index) = [ for (k=indices(list)) if (k != index) list[k] ];
           
function replace_in_list(list, index, replacement) = [ for (k=indices(list)) k == index ? replacement : list[k] ];

function sublist(list, i, j) = i >= j ? [] : [ for (k=[i:j-1]) list[k] ];

function flatten(list) = [ for (l=list, x=l) x ];
    
function distinct(list, result = [], k = 0) =
      k >= len(list) ? result
    : list_contains(result, list[k]) ? distinct(list, result, k + 1)
    : distinct(list, concat(result, [list[k]]), k + 1);
    
function sum(list, k = 0) = k >= len(list) ? undef : k + 1 == len(list) ? list[k] : list[k] + sum(list, k+1);

function reverse_list(list, reverse = true) =
    reverse ? [ for (i = [len(list)-1:-1:0]) list[i] ] : list;
        
function repeat(n, item) = [ for (i = [1:n]) item ];

/***** Misc *****/

function argmin(list, i = 0, cur_argmin = undef, cur_min = undef) =
      i >= len(list) ? cur_argmin
    : is_undef(cur_argmin) || list[i] < cur_min ? argmin(list, i + 1, i, list[i])
    : argmin(list, i + 1, cur_argmin, cur_min);

// Version check. This is a proper implementation of semantic versioning.

module require_puzzlecad_version(required_version) {
    
    if (vector_compare(to_version_spec(puzzlecad_version), to_version_spec(required_version)) < 0) {
        assert(false, str(
            "ERROR: This model requires puzzlecad version ",
            required_version,
            ", and you are using version ",
            puzzlecad_version,
            ". Please upgrade before rendering."
        ));
    }
    
}

function to_version_spec(str) = [ for (element = strtok(strip_beta(str), ".")) atof(element) ];

function strip_beta(str) = let (b = index_of(str, "b")) b == -1 ? str : substr(str, 0, b);

function vector_compare(v1, v2, pos = 0) =
    pos >= max(len(v1), len(v2)) ? 0 :
    pos >= len(v1) ? 0 - v2[pos] :
    pos >= len(v2) ? v1[pos] - 0:
    v1[pos] != v2[pos] ? v1[pos] - v2[pos] :
    vector_compare(v1, v2, pos + 1);

if (list_contains(puzzlecad_version, "b")) {
    echo(str("NOTE: You are using a beta version of puzzlecad (version ", puzzlecad_version, ")."));
}
