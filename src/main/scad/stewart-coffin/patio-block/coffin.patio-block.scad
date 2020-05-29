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

$burr_scale = 14.5;
$burr_inset = 0.07;
$burr_bevel = 1.2;

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
