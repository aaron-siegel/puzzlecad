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

module burr_plate(burr_specs, num_copies = 1) {
    
    burr_infos = [ for (burr_spec = burr_specs) to_burr_info(burr_spec) ];
    
    layout_burr_infos = $auto_layout ? auto_layout_plate(burr_infos) : burr_infos;
    
    expanded_burr_infos = flatten(copies(num_copies, layout_burr_infos));
    
    burr_plate_r(expanded_burr_infos);
    
    if ($detached_joints) {
        // If using $detached_joints, we need to render the detached joints separately.
        male_joint_count = sum([
          for (burr_info = expanded_burr_infos, layer = burr_info, row = layer, voxel = row)
          let (connect = lookup_kv(voxel[1], "connect"))
          connector_type(connect) == "m" && connector_prefixes(connect) == "" ? 1 : 0
        ]);
        male_diag_joint_count = sum([
          for (burr_info = expanded_burr_infos, layer = burr_info, row = layer, voxel = row)
          let (connect = lookup_kv(voxel[1], "connect"))
          connector_type(connect) == "m" && connector_prefixes(connect) == "d" ? 1 : 0
        ]);
        if (male_joint_count > 0) {
            for (i = [0:male_joint_count-1]) {
                translate([(i + 0.5) * $burr_scale, -1 * ($burr_scale / 2 + $plate_sep), 0])
                detached_male_connector();
            }
        }
        if (male_diag_joint_count > 0) {
            for (i = [0:male_diag_joint_count-1]) {
                translate([(male_joint_count + i + 0.5) * $burr_scale, -1 * ($burr_scale / 2 + $plate_sep), 0])
                detached_male_diag_connector();
            }
        }
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

        translate([-0.001, -0.001, 0])  // OpenSCAD sometimes chokes on floating point errors for rendering complex polyhedra; this seems to help
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

                assert(is_valid_connect_annotation(connect), str("Invalid connector: ", connect));
                
                prefixes = connector_prefixes(connect);
                type = connector_type(connect);
                orient = connector_orient(connect);
                suffixes = connector_suffixes(connect);
                
                is_diagonal = list_contains(prefixes, "d");
                
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
                    
                    if (is_diagonal) {
                        if (type == "m" && !$detached_joints) {
                            if (!$short_joints)
                                male_diag_snap_connector_cutout(orient, twist = list_contains(suffixes, "~"));
                        } else {
                            // If using $detached_joints, we also render "m" connectors as "f"
                            female_diag_snap_connector(orient, clabel, twist = list_contains(suffixes, "~"));
                        }
                    } else {
                        // Rectilinear joint.
                        if (type == "m" && !$detached_joints) {
                            male_connector_cutout(orient);
                        } else {
                            // If using $detached_joints, we also render "m" connectors as "f"
                            female_connector(orient, clabel[0], substr(clabel, 1, 2));
                        }
                    }
                    
                }
                
            }

        }
        
        // Remove any labels that are specified.
        
        for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1]) {
            
            translate(cw(scale_vec, [x, y, z]))
            puzzle_label(aux[x][y][z], scale_vec);

        }
        
    }
        
    // Add space-fillers ("bridges" between components). This ensures that the entire
    // piece remains connected in the final rendering.
    // TODO: Add corner space-fillers?
    
    for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1]) {
        cell = [x,y,z];
        if (lookup3(burr, cell) > 0) {
            for (face=[3:5]) {      // Just the positive-directional faces (so we check each face pair just once)
                
                facing_cell = cell + directions[face];
                face_center = cell + 0.5 * directions[face];
                
                // If the facing cell *is* defined but is from a different component, then
                // we need to render a space-filler.
                if (is_nonzero(lookup3(burr, facing_cell)) && lookup3(burr, facing_cell) != lookup3(burr, cell)) {
                    
                    // Space-filler is 2*insets wide in the facing direction, and (scale - 2*insets - bevel/2)
                    // in the orthogonal directions. This ensures that the corners exactly meet the bevel line
                    // on each face.
                    dim = cw(2 * (inset_vec + 10 * iota_vec), directions[face])
                        + cw(scale_vec - 2 * (inset_vec + bevel_vec / sqrt(2)), [1, 1, 1] - directions[face]);
                    translate(cw(scale_vec, face_center))
                    cube(dim, center = true);
                    
                }
                    
                // Now add any edge space-filler adjacent to this face, taking care (as before) to avoid
                // duplicates.
                if (face < 5)
                for (other_face=[face+1:5]) {
                    if (is_nonzero(lookup3(burr, facing_cell)) &&
                        is_nonzero(lookup3(burr, cell + directions[other_face])) &&
                        is_nonzero(lookup3(burr, facing_cell + directions[other_face])) &&
                        ( lookup3(burr, facing_cell) != lookup3(burr, cell) ||
                          lookup3(burr, cell + directions[other_face]) != lookup3(burr, cell) ||
                          lookup3(burr, facing_cell + directions[other_face]) != lookup3(burr, cell)
                        )) {
                        
                        edge_center = face_center + 0.5 * directions[other_face];
                        dim = cw(2 * (inset_vec + 10 * iota_vec + bevel_vec / sqrt(2)), directions[face] + directions[other_face])
                            + cw(scale_vec - 2 * (inset_vec + bevel_vec / sqrt(2)), [1, 1, 1] - directions[face] - directions[other_face]);
                        translate(cw(scale_vec, edge_center))
                        cube(dim, center = true);
                        
                    }
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
        
            prefixes = connector_prefixes(connect);
            type = connector_type(connect);
            orient = connector_orient(connect);
            suffixes = connector_suffixes(connect);
            
            is_diagonal = list_contains(prefixes, "d");
            
            if (is_diagonal) {
                if (type == "m" && !$detached_joints) {
                    translate(cw(scale_vec, [x, y, z]))
                    male_diag_snap_connector(substr(connect, 2, 4), clabel[0], twist = list_contains(suffixes, "~"));
                }
            } else {
                if (type == "m" && !$detached_joints) {
                    translate(cw(scale_vec, [x, y, z]))
                    male_connector(substr(connect, 1, 4), clabel[0], substr(clabel, 1, 2));
                }
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
        let (components = expand_components_list(strtok(components_str, ",")))
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

function expand_components_list(components, i = 0) =
    is_undef(components) ? undef
      : i >= len(components) ? []
      : components[i][0] == "s" ?
        let (slice_faces = [ substr(components[i], 1, 2), substr(components[i], 3, 2) ])
        concat(
          slice_faces,
          [ for (face_name = cube_face_names, edge_dir = slice_faces)
            if (face_name[0] != slice_faces[0][0] && face_name[0] != slice_faces[1][0])
            str(face_name, edge_dir) ],
          expand_components_list(components, i + 1)
        )
      : concat([components[i]], expand_components_list(components, i + 1));

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

module detached_male_connector() {
    
    size = $burr_scale * 2/3 - $burr_inset * 2 - $joint_inset * 2;
    total_length = size - 0.35;
    translate([0, 0, size / 2])
    rotate([90, 0, 0]) {
        tapered_pentagon([size, size, total_length], center = false, clipped = true);
        translate([0, 0, iota])
        mirror([0, 0, 1])
        tapered_pentagon([size, size, total_length], center = false, clipped = true);
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

module male_diag_snap_connector_tip(length) {

    beveled_prism(
        [[0, $joint_inset],
         [-1/2 * $diag_joint_scale * $burr_scale + sqrt(2) * $joint_inset, sqrt(2)/2 * $diag_joint_scale * $burr_scale - $joint_inset],
         [1/2 * $diag_joint_scale * $burr_scale - sqrt(2) * $joint_inset, sqrt(2)/2 * $diag_joint_scale * $burr_scale - $joint_inset]],
        length,
        $burr_bevel = 1.5,
        $burr_outer_x_bevel = undef,
        $burr_outer_y_bevel = undef,
        $burr_outer_z_bevel = undef,
        $burr_bevel_adjustments = undef
    );
    
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
            
            if ($short_joints) {
                scale(1 / $burr_scale)
                male_diag_snap_connector_tip(joint_length + 1.25);
            } else {
                scale(1 / $burr_scale)
                male_diag_snap_connector_tip(joint_length * 2 + 1);
            }
            
            if (label) {
                
                label_depth = 0.5 / $burr_scale;
                
                translate([0, sqrt(1/2) * $diag_joint_scale - label_depth / 2 + iota, joint_length / 2 / $burr_scale])
                rotate([-90, 0, 0])
                translate([0, 0, -label_depth/2])
                linear_extrude(height=label_depth)
                text(label, halign = "center", valign = "center", size = $burr_scale / 300, $fn = 64);
                
            }
            
        }

        if (!$short_joints) {
            
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
    
}

module detached_male_diag_connector() {
    
    joint_length = $burr_scale / 5;
    translate([0, 0, sqrt(2)/2 * $diag_joint_scale * $burr_scale - $joint_inset])
    rotate([-90, 0, 0]) {
        male_diag_snap_connector_tip(joint_length * 2);
    }
    
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
        $burr_outer_z_bevel = undef,
        $burr_bevel_adjustments = "z-=0,z+=1.5"
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
        $burr_outer_z_bevel = undef,
        $burr_bevel_adjustments = "z-=0,z+=1.5"
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

module puzzle_label(options, scale_vec) {
    
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

        face_axis = label_orient[0] == "x" ? 0 : label_orient[0] == "y" ? 1 : 2;
        unit_size = min(scale_vec[(face_axis + 1) % 3], scale_vec[(face_axis + 2) % 3]);

        hoffset_str = lookup_kv(options, "label_hoffset");
        hoffset = is_undef(hoffset_str) ? [0, 0, 0] :
            let(hoffset = atof(hoffset_str))
            assert(hoffset, str("Invalid label_hoffset: ", hoffset_str))
            hoffset * cw(scale_vec, lookup_kv(edge_directions_map, label_orient)[0]);
        
        voffset_str = lookup_kv(options, "label_voffset");
        voffset = is_undef(voffset_str) ? [0, 0, 0] :
            let(voffset = atof(voffset_str))
            assert(voffset, str("Invalid label_voffset: ", voffset_str))
           -atof(voffset_str) * cw(scale_vec, lookup_kv(edge_directions_map, label_orient)[1]);
        
        label_scale_str = lookup_kv(options, "label_scale", default = "0.4");
        label_scale = atof(label_scale_str);
        assert(label_scale, str("Invalid label_scale: ", label_scale_str));

        label_font = lookup_kv(options, "label_font", default = "Liberation Sans");

        // Translate by the explicit offsets
        translate(voffset)
        translate(hoffset)
        // Translate into natural position
        translate(cw(scale_vec, 0.5 * face_dir))
        // Rotate into proper orientation
        rotate(rot1)
        rotate(rot2)
        // Extra 90-degree z-rotation is required to ensure that label_orient specifies the
        // flow direction of text (as expected)
        rotate([0, 0, 90])
        translate([0, 0, -1])
        linear_extrude(2)
        text(label_text, halign = "center", valign = "center", size = unit_size * label_scale, font = label_font, $fn = 64);
        
    }

}

function connector_prefixes(spec) = parse_connector_spec(spec)[0];

function connector_type(spec) = parse_connector_spec(spec)[1];

function connector_orient(spec) = parse_connector_spec(spec)[2];

function connector_suffixes(spec) = parse_connector_spec(spec)[3];

function parse_connector_spec(spec) =
    let (result = parse_connector_spec_2(spec))
    assert(!is_undef(result), str("Invalid connector: ", spec))
    result;

function parse_connector_spec_2(spec, i = 0) =
      i == len(spec) ? undef
    : spec[i] == "m" || spec[i] == "f"
    ? let (suffix_pos = spec[len(spec) - 1] == "~" ? len(spec) - 1 : len(spec))
      [substr(spec, 0, i), spec[i], substr(spec, i + 1, suffix_pos - i - 1), substr(spec, suffix_pos, len(spec) - suffix_pos)]
    : parse_connector_spec_2(spec, i + 1);

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
                  for (component = expand_components_list(strtok(lookup_kv(aux_cell, "components"), ",")))
                  for (p = component_bounding_points(component))
                      apply_rot($post_rotate, cw(scale_vec, [x, y, z] + p))
            ]
    )
    bounding_box_of_points(cell_bounding_points);

function bounding_box_of_points(points, i = 0, box = undef) =
      i >= len(points) ? box
    : is_undef(box) ? bounding_box_of_points(points, i + 1, [points[i], points[i]])
    : assert(is_3_vector(points[i]), points[i])
      let (
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
