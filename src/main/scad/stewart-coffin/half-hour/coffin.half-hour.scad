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
        ["xxx|.x.", "...|.x."],
        [".xx|xx.", "...|.x."],
        [".x.|xxx", "...|x.."],
        [".x.|xxx"],
        ["x..|xxx"],
        ["x.|xx", "..|.x"]
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
            text("Half-Hour", halign = "center", valign = "center", size = 0.25 * $burr_scale);
            translate([0, -0.05 * $burr_scale, 0])
            text("Stewart Coffin", halign = "center", valign = "center", size = 0.2 * $burr_scale);
            translate([0, -0.4 * $burr_scale, 0])
            text("STC #29", halign = "center", valign = "center", size = 0.2 * $burr_scale);
        }
        
    }
    
}
