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

$tray_scale = 16;

// Uncomment one of the following three lines to render that component.

*pieces();
*tray();
*lid();

module pieces() {
    
    burr_plate([
        [".x.|xx.|.xx"], [".x.|xx.|.xx"], [".x.|xx.|.xx"], [".x.|xx.|.xx"], [".x.|xx.|.xx"]
    ], $burr_scale = [$tray_scale, $tray_scale, $tray_opening_height], $plate_width = 160, $burr_inset = 0.05);
    
}

module tray(render_as_lid = false) {
    
    packing_tray(
        opening_polygon = [[opening_depth / 7, 0], [0, opening_depth], [parallelogram_x_side, opening_depth],
            [parallelogram_x_side + opening_depth / 7, 0]],
        piece_holder_spec = [".x.|.xx|xx."],
        piece_holder_x_adj = -$tray_scale / 2,
        finger_wedge = [1, 3],
        render_as_lid = render_as_lid,
        title = "Quintet in F",
        subtitles = ["Stewart Coffin", "STC #253"]
    );
    
}

module lid() {
    
    tray(render_as_lid = true);
    
}

// The tray has the shape of a parallelogram whose angles differ from right angles
// by an amount equal to theta = arctan(1/7).

parallelogram_x_side = (13 + 4/7) / sqrt(5);
opening_depth = 13 / sqrt(5);
