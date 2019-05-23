// This is puzzlecad, an OpenSCAD library for modeling mechanical puzzles.
// To obtain the latest version of puzzlecad: https://www.thingiverse.com/thing:3198014
// For an overview of interlocking puzzles: http://robspuzzlepage.com/interlocking.htm

// Puzzlecad is (c) 2019 Aaron Siegel and is licensed for use under the
// Creative Commons - Attribution license. A copy of this license is available here:
// https://creativecommons.org/licenses/by/3.0/

// Version ID for version check.

puzzlecad_version = "1.3";

// Default values for scale, inset, bevel, etc.

$burr_scale = 11.15;
$burr_inset = 0.07;
$burr_bevel = 0.5;
$plate_width = 180;
$plate_depth = 180;
$plate_sep = 6;
$joint_inset = 0;

// These parameters are optional and can be used to increase
// the amount of beveling on outer edges of burr pieces.

$burr_outer_x_bevel = undef;
$burr_outer_y_bevel = undef;
$burr_outer_z_bevel = undef;

/* Main module for rendering a burr piece.
 * "burr_spec" can be any of the following:
 *    - a stick number: 975
 *    - a string for a single-layer puzzle piece: "xxxx.|x..x.|x....|xxxxx"
 *    - an array of such strings, one per layer
 * "label" is a text label that appears on the end of a burr stick; this currently works correctly
 *    ONLY for 2x2xN pieces.
 * "piece_number" is the ordinal number of the burr piece in a build plate (or sequence of pieces)
 *    and is used only for output/debugging (it has no effect on rendering).
 */

module burr_piece(burr_spec, label = undef, piece_number = 1) {
    
    joint_str = $joint_inset == 0 ? "" : str(", joint inset ", $joint_inset);
    scale_vec = vectorize($burr_scale);
    inset_vec = vectorize($burr_inset);
    echo(str("Generating piece #", piece_number, " at scale ", $burr_scale, " with inset ", $burr_inset, ", bevel ", $burr_bevel, joint_str));
    render(convexity = 2)
    translate(scale_vec / 2 - inset_vec)
    difference() {
        burr_piece_base(burr_spec);
        if (label) {
            translate([-scale_vec.x/2+1+inset_vec.x, scale_vec.y/2, scale_vec.z/2])
            rotate([90,0,-90])
            linear_extrude(height=1)
            text(label, halign="center", valign="center", size=6, $fn=64);
        }
    }
    
}
        
/* Module for rendering multiple burr pieces on a single plate. The module will prearrange the
 * pieces so that they can be generated into a single STL/OBJ file.
 * "burr_specs" is a vector of burr pieces (specified the same way as when calling burr_piece).
 * "labels" is an (optional) vector of labels.
 * The other arguments should be left as defaults (they're used for recursive calls to burr_plate).
 */

module burr_plate(burr_specs, labels = undef, i = 0, y = 0, x = 0, row_depth = 0) {
    
    scale_vec = vectorize($burr_scale);
    
    if (i < len(burr_specs)) {
        cur_piece = to_burr_info(burr_specs[i]);
        piece_width = len(cur_piece) * scale_vec.x;
        piece_depth = len(cur_piece[0]) * scale_vec.y;
        if (x + piece_width < $plate_width) {
            translate([x, y, 0]) burr_piece(burr_specs[i], label = labels[i], piece_number = i+1);
            burr_plate(burr_specs, labels, i + 1,
                y, x + piece_width + $plate_sep, max([row_depth, piece_depth]));
        } else {
            burr_plate(burr_specs, labels, i, y + row_depth + $plate_sep, 0, 0);
        }
    }
    
}

/* This module does most of the work. It should seldom be called directly (use burr_piece instead).
 */

// TODO $burr_bevel doesn't work properly if it's a vector with different values along each dimension.
// TODO Connectors don't work properly if $burr_scale is a vector with different values along each dimension.
// TODO Negative insets don't work with beveling.

iota = 0.00001;
iota_vec = [iota, iota, iota];

module burr_piece_base(burr_spec) {
    
    scale_vec = vectorize($burr_scale);
    inset_vec = vectorize($burr_inset);
    bevel_vec = vectorize($burr_bevel);
    burr_info = to_burr_info(burr_spec);
    xlen = len(burr_info);
    ylen = len(burr_info[0]);
    zlen = len(burr_info[0][0]);
    burr = [ for (x=[0:xlen-1]) [ for (y=[0:ylen-1]) [ for (z=[0:zlen-1]) burr_info[x][y][z][0] ]]];
    aux = [ for (x=[0:xlen-1]) [ for (y=[0:ylen-1]) [ for (z=[0:zlen-1]) burr_info[x][y][z][1] ]]];
    
    // $burr_inset is allowed to be negative (or a vector with negative numbers), in
    // which case we enlarge each cube. But we *don't* shrink the cubes for positive
    // insets; so we take the componentwise min of inset_vec and [0, 0, 0].
    neg_inset_vec = [ for (i=[0:2]) min(0, inset_vec[i]) ];
        
    interior_scale_vec = scale_vec - 2 * inset_vec;

    render(convexity = 2)
    difference() {
        
        union() {
            // Create the basic polycube.
            for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1]) {
                if (burr[x][y][z] == 1) {
                    // There's a cube here.
                    translate(cw(scale_vec, [x,y,z]))
                    cube(scale_vec - 2 * neg_inset_vec, center = true);
                }
            }
        }
        
        // Remove insets, by removing an enlarged cube from each empty location.
        for (x=[-1:xlen], y=[-1:ylen], z=[-1:zlen]) {
            if (burr[x][y][z] != 1) {
                translate(cw(scale_vec, [x,y,z]))
                cube(scale_vec + 2 * inset_vec, center = true);
            }
        }
        
        // Remove female connector artifacts.
        for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1]) {
            connect = lookup_kv(aux[x][y][z], "connect");
            if (connect[0] == "f") {
                clabel = lookup_kv(aux[x][y][z], "clabel");
                translate(cw(scale_vec, [x,y,z]))
                connector("f", substr(connect, 1, 2), clabel[0], substr(clabel, 1, 2));
            }
        }
        
        // Create beveling.
        
        for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1]) {
            translate(cw(scale_vec, [x,y,z])) {
                // Remove edge bevels in the z direction.
                for (i=[-1,1], j=[-1,1]) {
                    if (burr[x][y][z] == 1 && burr[x+i][y][z] != 1 && burr[x][y+j][z] != 1) {
                        z_bevel = $burr_outer_z_bevel && (x+i == -1 || x+i == xlen) && (y+j == -1 || y+j == ylen) ? $burr_outer_z_bevel : bevel_vec.z;
                        edge_bevel_cutout(scale_vec.z + 2 * inset_vec.z, interior_scale_vec.x, interior_scale_vec.y, z_bevel, i, j);
                    }
                }
                // Remove edge bevels in the y direction.
                for (i=[-1,1], k=[-1,1]) {
                    if (burr[x][y][z] == 1 && burr[x+i][y][z] != 1 && burr[x][y][z+k] != 1) {
                        y_bevel = $burr_outer_y_bevel && (x+i == -1 || x+i == xlen) && (z+k == -1 || z+k == zlen) ? $burr_outer_y_bevel : bevel_vec.y;
                        rotate([90, 0, 0])
                        edge_bevel_cutout(scale_vec.y + 2 * inset_vec.y, interior_scale_vec.x, interior_scale_vec.z, y_bevel, i, k);
                    }
                }
                // Remove edge bevels in the x direction.
                for (j=[-1,1], k=[-1,1]) {
                    if (burr[x][y][z] == 1 && burr[x][y+j][z] != 1 && burr[x][y][z+k] != 1) {
                        x_bevel = $burr_outer_x_bevel && (y+j == -1 || y+j == ylen) && (z+k == -1 || z+k == zlen) ? $burr_outer_x_bevel : bevel_vec.x;
                        rotate([0, -90, 0])
                        edge_bevel_cutout(scale_vec.x + 2 * inset_vec.x, interior_scale_vec.z, interior_scale_vec.y, x_bevel, k, j);
                    }
                }
                // Remove corner bevels.
                for (i=[-1,1], j=[-1,1], k=[-1,1]) {
                    if (burr[x][y][z] == 1) {
                        // Exterior corner bevel.
                        if (burr[x+i][y][z] != 1 && burr[x][y+j][z] != 1 && burr[x][y][z+k] != 1) {
                            z_bevel = $burr_outer_z_bevel && (x+i == -1 || x+i == xlen) && (y+j == -1 || y+j == ylen) ? $burr_outer_z_bevel : bevel_vec.z;
                            y_bevel = $burr_outer_y_bevel && (x+i == -1 || x+i == xlen) && (z+k == -1 || z+k == zlen) ? $burr_outer_y_bevel : bevel_vec.y;
                            x_bevel = $burr_outer_x_bevel && (y+j == -1 || y+j == ylen) && (z+k == -1 || z+k == zlen) ? $burr_outer_x_bevel : bevel_vec.x;
                            x_adj = min(y_bevel, z_bevel);
                            y_adj = min(x_bevel, z_bevel);
                            z_adj = min(x_bevel, y_bevel);
                            bevel_scale = min(x_bevel, y_bevel, z_bevel);
                            if (bevel_scale > 0) {
                                translate(cw(scale_vec / 2, [i,j,k]) + iota_vec)
                                translate(-[x_adj*i, y_adj*j, z_adj*k] / sqrt(2) + cw([bevel_scale, bevel_scale, bevel_scale] / sqrt(2) / 2 - inset_vec, [i,j,k]))
                                scale(bevel_scale / sqrt(2) / 2)
                                exterior_corner_bevel_cutout([i,j,k]);
                            }
                        }
                    } else {
                        // Interior corner bevel on the xy plane.
                        if (burr[x+i][y][z] == 1 && burr[x][y+j][z] == 1 &&
                            burr[x+i][y][z+k] != 1 && burr[x][y+j][z+k] != 1) {
                            translate(cw(scale_vec / 2, [i,j,k]))
                            translate(cw(inset_vec + bevel_vec / sqrt(2) / 2, [i,j,-k]))
                            scale(bevel_vec / sqrt(2) / 2)
                            interior_corner_bevel_cutout([-i,-j,k]);
                        }
                        // Interior corner bevel on the xz plane.
                        if (burr[x+i][y][z] == 1 && burr[x][y][z+k] == 1 &&
                            burr[x+i][y+j][z] != 1 && burr[x][y+j][z+k] != 1) {
                            translate(cw(scale_vec / 2, [i,j,k]))
                            translate(cw(inset_vec + bevel_vec / sqrt(2) / 2, [i,-j,k]))
                            scale(bevel_vec / sqrt(2) / 2)
                            interior_corner_bevel_cutout([-i,j,-k]);
                        }
                        // Interior corner bevel on the yz plane.
                        if (burr[x][y+j][z] == 1 && burr[x][y][z+k] == 1 &&
                            burr[x+i][y+j][z] != 1 && burr[x+i][y][z+k] != 1) {
                            translate(cw(scale_vec / 2, [i,j,k]))
                            translate(cw(inset_vec + bevel_vec / sqrt(2) / 2, [-i,j,k]))
                            scale(bevel_vec / sqrt(2) / 2)
                            interior_corner_bevel_cutout([i,-j,-k]);
                        }
                    }
                }
            }
        }
        
    }
    
    // Add male connector artifacts.
    for (x=[0:xlen-1], y=[0:ylen-1], z=[0:zlen-1]) {
        connect = lookup_kv(aux[x][y][z], "connect");
        if (connect[0] == "m") {
            clabel = lookup_kv(aux[x][y][z], "clabel");
            translate(cw(scale_vec, [x,y,z]))
            connector("m", substr(connect, 1, 2), clabel[0], substr(clabel, 1, 2));
        }
    }
    
}

/* Module for rendering a (male or female) connector.
 * TODO: Adjust labels for joint insets?
 */
module connector(type, orient, label, label_orient) {
    
    rot = orient_rot(orient);
    size = type == "f"
        ? $burr_scale * 2/3 + $joint_inset * 2
        : $burr_scale * 2/3 - $joint_inset * 2;
    displacement = type == "f"
        ? ($burr_scale - size) / 2 - $burr_inset + 0.00001
        : ($burr_scale + size) / 2 - $burr_inset - 0.00001;
    
    render(convexity = 2)
    rotate(rot)
    translate([0, 0, displacement])
    union() {
        difference() {
            cube(size, center=true);
            if (type == "m") {
                // Remove 1.5mm beveling from the cap
                for (i=[-1,1]) {
                    translate([size * i / 2, 0, size / 2])
                    rotate([0, 45, 0])
                    cube([1.5, size + 0.00001, 1.5], center = true);
                    translate([0, size * i / 2, size / 2])
                    rotate([45, 0, 0])
                    cube([size + 0.00001, 1.5, 1.5], center = true);
                }
                // Shave 0.35mm off the top to ensure clean fit
                translate([0, 0, size/2 - 0.175])
                cube([size, size, 0.35], center=true);
                // Etch the label
                if (label) {
                    connector_label(-1, orient, label, label_orient);
                }
            }
        }
        // Stick the label out
        if (type == "f" && label) {
            connector_label(1, orient, label, label_orient);
        }
    }
    
}

/* Module for rendering a connector label. The connector label will always be rendered
 * in the z+ orientation. The parent module rotates it into the proper place.
 */
module connector_label(parity, orient, label, label_orient) {

    label_depth = 0.5;
    label_rot = label_rot(str(orient, label_orient));
    label_translate = $burr_scale / 3 + label_depth / 2 * parity;

    // Apply an appropriate rotation to position properly. After this rotation it will be in
    // z+y- or z+x- or z+y+ or z+x+ position.
    rotate(label_rot)
    // Move the label into the z+y- position with a vertical translation according to parity
    // (The vertical translation is purely for aesthetic reasons)
    translate([0, -label_translate, 0.5 * parity])
    // Stand the label upright and facing in the y- direction
    rotate([-90 * parity, 90 + 90 * parity, 0])
    // Create the label, centered at the origin
    translate([0, 0, -label_depth/2])
    linear_extrude(height=label_depth)
    text(label, halign="center", valign="center", size=$burr_scale/3.7, $fn=64);
    
}
  
module edge_bevel_cutout(length, x_scale, y_scale, bevel, i, j) {
    linear_extrude(length + 0.0001, center = true)
    polygon([
        [i * (x_scale / 2 + 0.0001), j * (y_scale / 2 + 0.0001)],
        [i * (x_scale / 2 - bevel / sqrt(2)), j * (y_scale / 2 + 0.0001)],
        [i * (x_scale / 2 + 0.0001), j * (y_scale / 2 - bevel / sqrt(2))]
    ]);
}

/* Module for rendering a cube wedge for purposes of beveling corners.
 * "vertex" is a vector of +-1's, such as [-1, 1, -1], specifying one of the
 * eight cube vertices for the wedge.
 */
module interior_corner_bevel_cutout(vertex) {
    adj_vertex = vertex * (1 + iota * 20) + iota_vec;
    polyhedron(
        [
            adj_vertex,
            [adj_vertex.x,adj_vertex.y,-adj_vertex.z],
            [adj_vertex.x,-adj_vertex.y,adj_vertex.z],
            [-adj_vertex.x,adj_vertex.y,adj_vertex.z]
        ],
        [[0,1,2],[0,2,3],[0,3,1],[1,3,2]]
    );
}

/* Module for rendering the negative of a cube wedge.
 */
module exterior_corner_bevel_cutout(vertex) {
    
    render(convexity = 2)
    difference() {
        translate(iota_vec)
        cube([2, 2, 2] * (1 + iota * 10), center = true);
        interior_corner_bevel_cutout(-vertex);
    }
    
}

/******* Puzzle trays and lids *******/

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
    opening_scaled_dim = [$tray_scale * (opening_max_x - opening_min_x), $tray_scale * (opening_max_y - opening_min_y), $tray_opening_height + 2 * $burr_inset];
    
    burr_info = strings_to_burr_info(piece_holder_spec);
    xlen = len(burr_info);
    ylen = xlen == 0 ? 0 : len(burr_info[0]);
    zlen = xlen == 0 ? 0 : len(burr_info[0][0]);
    
    has_piece_holder = xlen != 0 || piece_holder_polygon;
    
    piece_holder_raw_width = piece_holder_polygon ? max(poly_x(piece_holder_polygon)) : xlen;
    piece_holder_width = finger_wedge
        ? max(piece_holder_raw_width, finger_wedge.x + finger_wedge_radius) * $tray_scale
        : piece_holder_raw_width * $tray_scale;
    piece_holder_depth = (piece_holder_polygon ? extent(poly_y(piece_holder_polygon)) : ylen) * $tray_scale + 2 * $piece_holder_buf;
    
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

        translate(lid_border_dim_vec)
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

/******* Beveled prisms *******/

module beveled_cube(dim, center = false) {

    translate(center ? -dim/2 : [0, 0, 0])
    beveled_prism([[0, 0], [dim.x, 0], [dim.x, dim.y], [0, dim.y]], dim.z);
    
}

module beveled_prism(poly, height) {
    
    wedge_leg = $burr_bevel / sqrt(2);
    
    render(convexity = 2)
    difference() {
        
        linear_extrude(height)
        polygon(poly);
        
        for (i = [0:len(poly)-1]) {
            
            vertex = poly[i];
            prev = poly[(i - 1 + len(poly)) % len(poly)];
            next = poly[(i + 1) % len(poly)];
            
            // Vertical edge

            p1 = vertex + normed_vec(prev - vertex) * wedge_leg;
            p2 = vertex + normed_vec(next - vertex) * wedge_leg;
            secant = normed_vec(normed_vec(prev - vertex) + normed_vec(next - vertex));
            
            linear_extrude(height)
            polygon([vertex - secant * 0.001, p1, p2]);
            
            // Base edge
            
            translate([vertex.x, vertex.y, 0])
            rotate([90, 0, angle(next - vertex)])
            rotate([0, 90, 0])
            linear_extrude(norm(next - vertex))
            polygon([[0, 0], [wedge_leg, 0], [0, wedge_leg]]);
            
            // Top edge
            
            translate([vertex.x, vertex.y, height])
            rotate([0, 0, angle(next - vertex)])
            rotate([0, 90, 0])
            linear_extrude(norm(next - vertex))
            polygon([[0, 0], [wedge_leg, 0], [0, wedge_leg]]);
            
        }
        
    }

}

module regular_polygon(n, parity = 0) {
    polygon([for (i=[0:n-1]) [cos(180*(2*i+1-parity)/n) / sqrt(2), sin(180*(2*i+1-parity)/n) / sqrt(2)]]);
}

function poly_displacement(n, cell) = [
    sum([ for (i=[0:n-2]) cell[i] * cos(360*i/n) / sqrt(2)]),
    sum([ for (i=[0:n-2]) cell[i] * sin(360*i/n) / sqrt(2)]),
    0
    ];

function sum(list, i = 0) = i >= len(list) ? 0 : list[i] + sum(list, i+1);
    
function normed_vec(vec) = vec / norm(vec);
function poly_x(poly) = [ for (p = poly) p.x ];
function poly_y(poly) = [ for (p = poly) p.y ];
function extent(vec) = max(vec) - min(vec);
function dist(a, b) = sqrt(sum([ for (i = [0:len(a)-1]) (a[i] - b[i]) * (a[i] - b[i])]));
function angle(vec) = vec.y >= 0 ? acos(vec.x / norm(vec)) : 360 - acos(vec.x / norm(vec));

/******* Helper functions *******/

/***** Puzzle specification *****/

// Converts a flexible burr spec (argument to burr_piece) into a structured vector of information.
function to_burr_info(burr_spec) =
    burr_spec[0] == undef ? burr_stick(burr_spec, 6)
        : burr_spec[0][0][0][0] + 0 == undef ? strings_to_burr_info(burr_spec)
        : burr_spec;
    
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
 
function strings_to_burr_info(strings) =
    strings[0][0] == "{" ? strings_to_burr_info_2(substr(strings[0], 1, len(strings[0])-2), [ for (i=[1:len(strings)-1]) strings[i] ])
        : strings_to_burr_info_2(undef, strings);

function strings_to_burr_info_2(globals, strings) = zyx_to_xyz(
    [ for (str = strings)
        [ for (row = strtok(str, "|"))
            string_to_burr_info(globals, row)
        ]
    ]);
 
function string_to_burr_info(globals, str, i=0, result=[]) =
    i == len(str) ? result :
        str[i] == "x" ? string_to_burr_info_opt_suffix(globals, str, i, result, 1)
        : str[i] == "." ? string_to_burr_info_opt_suffix(globals, str, i, result, 0)
        : str[i] == "#" ? string_to_burr_info_star(globals, str, i+1, result, 1)
        : undef;
        
function string_to_burr_info_opt_suffix(globals, str, i, result, value) =
    substr(str, i+1, 1) == "*" ? string_to_burr_info_star(globals, str, i+2, result, value)
        : substr(str, i+1, 1) == "{" ? string_to_burr_info_suffix(globals, str, i+2, result, value)
        : string_to_burr_info_next(globals, str, i+1, result, [value, []]);
        
function string_to_burr_info_star(globals, str, i, result, value) =
    string_to_burr_info_next(globals, str, i, result, [value, parse_kv(globals)]);
       
function string_to_burr_info_suffix(globals, str, i, result, value) =
    string_to_burr_info_next(globals, str, strfind(str, "}", i) + 1, result, [value, parse_kv(substr_until(str, "}", i))]);

function string_to_burr_info_next(globals, str, i, result, struct) =
    string_to_burr_info(globals, str, i, concat(result, [struct]));
   
function wrap(burr_map) =
    [ for (layer = burr_map) [ for (row = layer) [ for (voxel = row) voxel[0] == undef ? [voxel] : voxel] ] ];
  
function bit_of(n, exponent) = floor(n/pow(2,exponent)) % 2;
          
function copies(n, burr) = n == 0 ? [] : concat(copies(n-1, burr), [burr]);
    
/***** String manipulation *****/
    
// Splits a string into a vector of tokens.
function strtok(str, sep, i=0, token="", result=[]) =
    i == len(str) ? concat(result, token)
    : str[i] == sep ? strtok(str, sep, i+1, "", concat(result, token))
    : strtok(str, sep, i+1, str(token, str[i]), result);

// Returns a substring of a given string.
function substr(str, pos=0, len=-1, substr="") =
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

function parse_kv(str) =
    [ for (kv = strtok(str, ",")) strtok(kv, "=") ];
    
function lookup_kv(kv, key, default=undef, i=0) =
    kv[i] == undef ? default :
    kv[i][0] == key ? (kv[i][1] != undef ? kv[i][1] : true) :
    lookup_kv(kv, key, default, i+1);
             
function atof(str) =
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

function letter(n) = all_letters[n];

all_letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

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
 
function vectorize(a) = a[0] == undef ? [a, a, a] : a;

// The componentwise (Hadamard) product of a and b.
            
function cw(a, b) = 
    a[0] == undef || b[0] == undef ? a * b : [ for (i=[0:min(len(a), len(b))-1]) a[i]*b[i] ];

/***** Orientation *****/

function orient_rot(str) =
    str == "x+" ? [90, 0, 90] :
    str == "x-" ? [90, 0, -90] :
    str == "y+" ? [90, 0, 180] :
    str == "y-" ? [90, 0, 0] :
    str == "z+" ? [0, 0, 0] :
    str == "z-" ? [180, 0, 0] :
    undef;
            
function label_rot(str) =
    str == "z+y-" || str == "z-y+" || str == "y+z-" || str == "y-z-" || str == "x+z-" || str == "x-z-" ? [0, 0, 0] :
    str == "z+x+" || str == "z-x+" || str == "y+x-" || str == "y-x+" || str == "x+y+" || str == "x-y-" ? [0, 0, 90] :
    str == "z+y+" || str == "z-y-" || str == "y+z+" || str == "y-z+" || str == "x+z+" || str == "x-z+" ? [0, 0, 180] :
    str == "z+x-" || str == "z-x-" || str == "y+x+" || str == "y-x-" || str == "x+y-" || str == "x-y+" ? [0, 0, 270] :
    undef;
     
// Version check. This is a proper implementation of semantic versioning.

require_puzzlecad_version = undef;
if (require_puzzlecad_version &&
    vector_compare(to_version_spec(puzzlecad_version), to_version_spec(require_puzzlecad_version)) < 0) {
    echo(str(
        "WARNING: This design requires puzzlecad version ",
        require_puzzlecad_version,
        ", and you are using version ",
        puzzlecad_version,
        ". Results might not be what you expect."
    ));
}

function to_version_spec(str) = [ for (element = strtok(str, ".")) atof(element) ];
    
function vector_compare(v1, v2, pos = 0) =
    pos >= max(len(v1), len(v2)) ? 0 :
    pos >= len(v1) ? 0 - v2[pos] :
    pos >= len(v2) ? v1[pos] - 0:
    v1[pos] != v2[pos] ? v1[pos] - v2[pos] :
    vector_compare(v1, v2, pos + 1);
