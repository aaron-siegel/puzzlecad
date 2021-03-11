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

$burr_scale = 17;
$burr_bevel = 1;
$burr_inset = 0.15;
$unit_beveled = true;

require_puzzlecad_version("2.2");

*pieces();
*box();

module pieces() {
    burr_plate([
        "xxx|x..",
        "xxx|x..",
        "xx|xx",
        "xx|x.",
        ".xx|xx.",
        "xxx|.x.",
        "xxx|.x."
    ], $plate_width = 160);
}

module box() {
    
    difference() {
        
        packing_box([
            "xxxxx|xxxxx|xxxxx|xxxxx|xxxxx",
            "xxxxx|x...x|x...x|x...x|xxxxx",
            "xxxxx|x...x|x...x|x...x|xxxxx",
            "xxxxx|x...x|x...x|x...x|xxxxx",
            "xxxxx|x+++x|x+++x|x..+x|xxxxx"
        ], $auto_layout = true);
        
        translate([1.5 * $burr_scale + $box_wall_thickness, 0.999, 1.5 * $burr_scale + $box_wall_thickness / 2])
        rotate([90, 0, 0])
        linear_extrude(1) {
            translate([0, 0.6 * $burr_scale, 0])
            text("Slot Machine", halign = "center", valign = "center", size = 0.32 * $burr_scale);
            translate([0, 0.1 * $burr_scale, 0])
            text("Stewart Coffin", halign = "center", valign = "center", size = 0.23 * $burr_scale);
            translate([0, -0.3 * $burr_scale, 0])
            text("STC #185", halign = "center", valign = "center", size = 0.23 * $burr_scale);
        }
        
    }
    
}
