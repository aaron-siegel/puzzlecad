/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Stewart Coffin
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$tray_scale = 30;

// Uncomment one of the following three lines to render that component.

*pieces();
*tray();
*lid();

// The length of the second-smallest edge of the quadrilateral (the smallest
// always has length 1). This can be anything between 1 and 2. The given
// value (1 + phi) / (1 + phi / 2) is arbitrary, and is selected so that the
// golden rectangle makes an appearance in the solution, giving it a pleasing
// appearance.

phi = (1 + sqrt(5)) / 2;
quad_base = (1 + phi) / (1 + phi / 2);

module pieces() {
    
    triangular_piece();
    
    translate([$tray_scale * 1.1, $tray_scale * 2, 0])
    rotate([0, 0, 180])
    triangular_piece();
    
    translate([$tray_scale * 1.2, 0, 0])
    quad_piece();
    
    translate([$tray_scale * (2.3 + (1 + quad_base / 2)), $tray_scale * quad_base, 0])
    rotate([0, 0, 180])
    quad_piece();
    
}

module triangular_piece() {

    beveled_prism(
        [[0, 0], [0, 2], [1, 0]] * ($tray_scale - 2 * $burr_inset),
        $tray_opening_height - 2 * $burr_inset
    );

}

module quad_piece() {
    
    beveled_prism(
        [[0, 0], [0, quad_base], [1, quad_base], [1 + quad_base / 2, 0]] * ($tray_scale - 2 * $burr_inset),
        $tray_opening_height - 2 * $burr_inset
    );
    
}

module tray(render_as_lid = false) {
    
    packing_tray(
        opening_width = 7 / sqrt(5),
        opening_depth = 1 / sqrt(5) + quad_base * sqrt(5) / 2,
        piece_holder_polygon = [[0, 0], [1, 0], [0, 2]],
        finger_wedge = [1/2, 1],
        finger_wedge_radius = 0.25,
        render_as_lid = render_as_lid,
        title = "Cruiser",
        subtitles = ["Stewart Coffin", "STC #167"]
    );
    
}

module lid() {
    
    tray(render_as_lid = true);
    
}
