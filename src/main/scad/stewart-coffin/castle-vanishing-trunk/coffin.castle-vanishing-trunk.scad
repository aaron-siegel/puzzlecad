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

$tray_scale = 11;

// Uncomment one of the following three lines to render that component.

*pieces();
*tray();
*lid();

module pieces() {
    
    burr_plate([
        ["xx|xx|x."], [".x|.x|xx|x."], ["x.|x.|xx|x."], ["xx|.x|.x"], [".x.|xx.|.xx"]
    ], $burr_scale = [$tray_scale, $tray_scale, $tray_opening_height], $plate_width = 120, $burr_inset = 0.05);
    
}

module tray(render_as_lid = false) {
    
    castle = [[0, 0], [7, 0], [7, 2], [4, 5], [4, 6], [3, 6], [3, 5], [0, 2]];
    tree = [[0, 1], [3, 1], [3, 0], [4, 0], [4, 1], [7, 1], [7, 3], [3.5, 6.5], [0, 3]];
    vanished = [[0, 0], [10, 0], [10, 3], [5, 8], [0, 3]] / sqrt(2);
    
    packing_tray(
        opening_polygons = [
            [for (point = castle) point + [0, 1]],
            [for (point = tree) point + [7 + 4 / $tray_scale, 0]],
            [for (point = vanished) [point.x + 3.5 + 2 / $tray_scale, 9.75 - point.y]]
        ],
        render_as_lid = render_as_lid,
        title = "Castle / Vanishing Trunk",
        subtitles = ["Stewart Coffin", "STC #181A/B"]
    );
    
}

module lid() {
    
    tray(render_as_lid = true);
    
}
