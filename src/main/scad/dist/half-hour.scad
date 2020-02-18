include <puzzlecad.scad>

$burr_scale = 20;
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
