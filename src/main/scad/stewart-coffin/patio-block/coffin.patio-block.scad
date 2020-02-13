include <puzzlecad.scad>

$burr_scale = 14;
$burr_bevel = 1;

*pieces();
*box();

module pieces() {
    
    burr_plate([
        ["..a|bba|bb.", "..a|..a|..."],
        [".aa|bb.|bb.", ".aa|...|..."],
        ["aa|aa|b.|b.", "..|..|b.|b."],
        ["a.|a.|bb|bb", "a.|a.|..|.."],
        ["aab|aab", "..b|..b"],
        [".aa|.aa|bb.|bb."],
        ["a.|ab|.b", "a.|ab|.b"],
        ["a.|ab|.b", "a.|ab|.b"]
    ]);

}

module box() {
    
    packing_box([4, 4, 1.5] * $burr_scale, thickness = 4, $burr_bevel = 0.5);

}
