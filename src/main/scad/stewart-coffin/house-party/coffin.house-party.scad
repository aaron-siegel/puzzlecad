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
        ["xx.|xxx|x.."], ["x.|x.|xx|x."], ["xx.|.x.|.xx"], [".x.|xx.|.xx"]
    ], $burr_scale = [$tray_scale, $tray_scale, $tray_opening_height], $plate_width = 120, $burr_inset = 0.05);
    
}

module tray(render_as_lid = false) {
    
    polygon1 = [[0, 0], [5, 0], [5, 26/6], [2.5, 31/6], [0, 26/6]];
    polygon2 = [[0, 0], [11, 0], [11, 12 + 1/3], [5.5, 14 + 1/6], [0, 12 + 1/3]] / sqrt(5);
    
    packing_tray(
        opening_polygons = [
            polygon1,
            [for (point = polygon2) point + [5 + 4 / $tray_scale, 0]]
        ],
        render_as_lid = render_as_lid,
        title = "House Party",
        subtitles = ["Stewart Coffin", "STC #250"]
    );
    
}

module lid() {
    
    tray(render_as_lid = true);
    
}
