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

// The parameters for this puzzle are carefully calibrated.
// Be careful changing them, or you might wind up with an
// unsolvable puzzle!

$burr_scale = [16, 16, 5.6];
$burr_bevel = 2;
$burr_outer_z_bevel = 1.001;

$box_wall_thickness = [8, 8, 3];
$box_inset = [0.07, 0.07, 0.3];

require_puzzlecad_version("2.2");

*pieces();
*tray();

module pieces() {
    burr_plate([
        "xxx|.x.",
        ".xx|xx.",
        "xxx|x..",
        ".xx|xx.|.x.",
        "xxx|.xx",
        "xx|x."
    ], $plate_width = 160);
}

module tray() {
    packing_box([
        "xxxxxxx|xxxxxxx|xxxxxxx|xxxxxxx|xxxxxxx|xxxxxxx|xxxxxxx",
        "xxxxxxx|x.....x|x.....x|x.....x|x.....x|x.....x|xxxxxxx",
        "xxxxxxx|x.++..x|x.++..x|x++...x|x.++++x|x..+++x|xxxxxxx"
    ], $plate_width = 200, $auto_layout = true);
}
