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

$burr_scale = 27;
$burr_inset = 0.15;
$burr_bevel = 1.3;
$unit_beveled = true;

*pieces();
*extra_half_pieces();
*tray();

module pieces() {
    
    burr_plate([
        ["x{components={x-,z-,x+}}x{components={x-,z-,x+}}"],
        ["x{components={x-,y+,x+}}x{components={x-,y-,x+}}"],
        ["x{components={x-,z-,x+}}x{components={x-,y+,x+}}"],
        ["x{components={x-,y+,x+}}x{components={x-,z-,x+}}"],
        ["x{components={y-,y+,x+}}x{components={y-,y+,x-}}"],
        ["x{components={x+,z-,z+}}x{components={x-,y-,y+}}"],
        ["x{components={x-,z-,x+}}x{components={x-,z-,z+}}"],
        ["x{components={x-,z-,x+}}x{components={x-,y-,y+}}"]
    ], $plate_width = 150);
    
}

module extra_half_pieces() {
    
    burr_plate([
        "x{components={x-,z-,x+}}",
        "x{components={x-,z-,x+}}"
    ]);
    
}

module tray() {
    
    thickness = 4;
    difference() {
        packing_box([3, 3, 0.5] * $burr_scale, thickness, $burr_bevel = 0.5);
        translate([1.5 * $burr_scale + thickness, 1.5 * $burr_scale + thickness, thickness - 1 + 0.001])
        linear_extrude(1)
        union() {
            translate([0, 9, 0])
            text("Pieces-of-Eight", halign = "center", valign = "center", size = 7);
            translate([0, -1, 0])
            text("Stewart Coffin", halign = "center", valign = "center", size = 5);
            translate([0, -10, 0])
            text("STC #77", halign = "center", valign = "center", size = 5);
        }
    }
    
}
