include <puzzlecad.scad>

// This is an example of a simple, fully realized model built with puzzlecad:
// Half-Hour by Stewart Coffin.

// For a more full-featured version of this model, visit:
// https://www.thingiverse.com/thing:3355035

$burr_scale = 17;
$burr_inset = 0.07;
$burr_bevel = 1.3;
$unit_beveled = true;

burr_plate([
    ["xxx|.x.", "...|.x."],
    [".xx|xx.", "...|.x."],
    [".x.|xxx", "...|x.."],
    [".x.|xxx"],
    ["x..|xxx"],
    ["x.|xx", "..|.x"]
]);
