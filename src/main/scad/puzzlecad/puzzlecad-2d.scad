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

/******* Puzzle containers and lids *******/

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
