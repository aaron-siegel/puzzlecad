/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) László Molnár
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

$burr_scale = 17;
$burr_inset = 0.125;
$burr_bevel = 1.2;
$unit_beveled = true;

box_thickness = 6;
box_inset = 0.25;

dim = $burr_scale * 3 + box_thickness * 2;
height = $burr_scale * 3 + box_thickness + box_inset;

// Uncomment one of the following lines to render the appropriate component.

*pieces();
*box();

module pieces() {
    
    burr_plate([
        [".x{components={z-,y+,x-z-,x-y+,x+z-,x+y+}}|xx|.x"],
        ["..x|xxx", "...|x{components={z-,y+,x-z-,x-y+,x+z-,x+y+}}.."],
        [".x|xx", "..|x{components={z-,y+,x-z-,x-y+,x+z-,x+y+}}."],
        ["x{components={x+,y+,z+x+,z+y+,z-x+,z-y+}}.|x.|xx"],
        [".x{components={z-,y+,x-z-,x-y+,x+z-,x+y+}}|.x|xx", "..|..|.x"],
        ["x{connect=fz-y+}x{components={x-,y+,z+x-,z+y+,z-x-,z-y+}}|.x", "..|.x"],
        ["x{connect=mz+y+}"]
    ]);
    
}

module box() {
    
    difference() {
        
        beveled_cube([dim, dim, height], $burr_bevel = 0.5);
        translate([box_thickness - box_inset, box_thickness - box_inset, box_thickness - box_inset])
        cube([$burr_scale * 3 + box_inset * 2, $burr_scale * 3 + box_inset * 2, $burr_scale * 3 + box_inset * 2 + 0.01]);
        translate([1.5 * $burr_scale + box_thickness, 0.999, 1.5 * $burr_scale + box_thickness / 2])
        rotate([90, 0, 0])
        linear_extrude(1)
        union() {
            translate([0, 0.3 * $burr_scale, 0])
            text("Half Cut", halign = "center", valign = "center", size = 0.32 * $burr_scale);
            translate([0, -0.25 * $burr_scale, 0])
            text("László Molnár", halign = "center", valign = "center", size = 0.23 * $burr_scale);
        }
        
    }
    
}
