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

$tray_scale = 14.5;

// Uncomment one of the following three lines to render that component.

*pieces();
*tray();
*lid();

module pieces() {
    
    burr_plate([
        ["xxx.|..xx"], ["xxx|.x.|.x."], ["x..|xxx|.x."], ["x...|xxxx|.x.."]
    ], $burr_scale = [$tray_scale, $tray_scale, $tray_opening_height], $plate_width = 150, $burr_inset = 0.05);
    
}

opening_1_w = 11 / sqrt(5);
opening_1_h1 = (13 - 3/7) / sqrt(5);
opening_1_h2 = (14 + 1/7) / sqrt(5);

opening_2_w1 = (19 - 2/7) / sqrt(17);
opening_2_w2 = (22 + 1/7) / sqrt(17);
opening_2_h = 24 / sqrt(17);

tray_width = $tray_scale * (opening_1_w + opening_2_w2) + 12;
tray_depth = $tray_scale * max(opening_1_h2, opening_2_h) + 8;

module tray(render_as_lid = false) {
    
    packing_tray(
        opening_polygons = [
            [[0, 0], [0, opening_1_h1], [opening_1_w, opening_1_h2], [opening_1_w, 0]],
            [for (point = [[0, 0], [0, opening_2_h], [opening_2_w1, opening_2_h], [opening_2_w2, 0]]) point + [1/4 + opening_1_w, (opening_1_h2 - opening_2_h) / 2]]
        ],
        render_as_lid = render_as_lid,
        title = "Lean-2",
        subtitles = ["Stewart Coffin", "STC #255 (rev. 2014)"]
    );
    
}

module lid() {
    
    tray(render_as_lid = true);
    
}
