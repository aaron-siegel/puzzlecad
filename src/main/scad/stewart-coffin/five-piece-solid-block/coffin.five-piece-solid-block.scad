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

$burr_scale = 20;
$burr_inset = 0.07;     // This can be 0.06 for a tighter fit
$burr_bevel = 1.3;

// Uncomment one of the following lines to render the appropriate component.

*pieces();
*box();

module pieces() {
    burr_plate([
        ["xx.|.xx", "...|.x."],
        ["x..|xxx", "...|.x."],
        ["..x|xxx", "...|.x."],
        ["..x|xxx", "..x|x.."],
        ["x.x|xxx", "..x|..."]
    ], $unit_beveled = true);
}


module box() {
    
    thickness = 4;
    difference() {
        
        packing_box([3, 3, 1.5] * $burr_scale, thickness, $burr_bevel = 0.5);
        translate([1.5 * $burr_scale + thickness, 0.999, 0.75 * $burr_scale + thickness / 2])
        rotate([90, 0, 0])
        linear_extrude(1)
        union() {
            translate([0, 0.4 * $burr_scale, 0])
            text("Five-Piece Solid Block", halign = "center", valign = "center", size = 0.2 * $burr_scale);
            translate([0, -0.05 * $burr_scale, 0])
            text("Stewart Coffin", halign = "center", valign = "center", size = 0.2 * $burr_scale);
            translate([0, -0.4 * $burr_scale, 0])
            text("STC #78-C", halign = "center", valign = "center", size = 0.2 * $burr_scale);
        }
        
    }
    
}
