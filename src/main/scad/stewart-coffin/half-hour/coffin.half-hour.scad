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
    
    packing_box([3, 3, 1.5] * $burr_scale, thickness = 4, $burr_bevel = 0.5);
    
}
