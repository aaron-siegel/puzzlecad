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

$burr_scale = 20;
$burr_inset = 0.11;
$burr_bevel = 1.3;
$unit_beveled = true;

// Uncomment one of the following lines to render the appropriate component.

*pieces();
*box();

module pieces() {

    burr_plate([
        ["xx.|.xx", "...|..x{components={z-,y-,y+}}"],
        ["xx|x.", "..|x{components={z-,x-,x+}}"],
        ["xx", ".x{connect=fz+y-,clabel=A}"],
        ["x{components={z-,x-,x+}}x{connect=mz+y-,clabel=A}"],
        ["x{connect=fz-y-,clabel=B}..|xxx{components={z-,x-,x+}}"],
        ["x{connect=mz+y-,clabel=B}"],
        ["x{connect=mz+y-,clabel=C}xx{components={z-,x-,x+}}"],
        ["x{connect=fz+y-,clabel=C}|x"],
        ["x{components={z-,x-,x+}}xx{connect=fy-z+,clabel=D}"],
        ["x{connect=mz+y-,clabel=D}|x"]
    ]);

}


module box() {
    
    thickness = 4;
    difference() {
        
        packing_box([3, 3, 1.5] * $burr_scale, thickness, $burr_bevel = 0.5);
        translate([1.5 * $burr_scale + thickness, 0.999, 0.75 * $burr_scale + thickness / 2])
        rotate([90, 0, 0])
        linear_extrude(1)
        union() {
            translate([0, 0.22 * $burr_scale, 0])
            text("Design #78-A", halign = "center", valign = "center", size = 0.25 * $burr_scale);
            translate([0, -0.23 * $burr_scale, 0])
            text("Stewart Coffin", halign = "center", valign = "center", size = 0.2 * $burr_scale);
        }
        
    }
    
}
