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
        ["xx.|.xx", "...|.x."],
        [".x.|xxx", "...|..x"],
        [".x.|xxx", "...|x.."],
        ["x|x", ".|x{components={x-,z-,x+}}"],
        ["x|x", ".|x{components={y-,z-,y+}}"],
        ["x.|xx", "..|.x{components={x-,z-,x+}}"],
        [".x|xx", "..|x{components={x-,z-,x+}}."]
    ], $plate_width = 150);

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
            text("Pillars of Hercules", halign = "center", valign = "center", size = 0.25 * $burr_scale);
            translate([0, -0.05 * $burr_scale, 0])
            text("Stewart Coffin", halign = "center", valign = "center", size = 0.2 * $burr_scale);
            translate([0, -0.4 * $burr_scale, 0])
            text("STC #78", halign = "center", valign = "center", size = 0.2 * $burr_scale);
        }
        
    }
    
}
