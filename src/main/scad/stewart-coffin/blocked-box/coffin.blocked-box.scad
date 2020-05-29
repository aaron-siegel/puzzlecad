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

box_border = 6;

$burr_scale = 17;
$burr_inset = 0.125;
$burr_bevel = 1;

dim = $burr_scale * 3 + box_border * 2;
height = $burr_scale * 3 + box_border + $burr_inset * 2;

*pieces();
*box();
*obstruction();

module pieces() {

    burr_plate([
        ["abc|.d."], [".ab|cd.", "...|.e."], [".a.|bcd", "...|e.."], ["ab|.c", "d.|.."], ["abc"], ["abc|.d.", "...|.e."]
    ], $plate_width = 160);

}

module box() {
    
    render(convexity = 2)
    difference() {
        beveled_cube([dim, dim, height]);
        translate([box_border - $burr_inset, box_border - $burr_inset, box_border])
        cube([
            $burr_scale * 3 + $burr_inset * 2,
            $burr_scale * 3 + $burr_inset * 2,
            $burr_scale * 3 + $burr_inset * 2 + 0.001
        ]);
    }
    translate([$burr_scale * 3/2 + box_border, box_border - $burr_inset - 0.001, height - $burr_scale / 2 - $burr_inset])
    rotate([-90, 0, 0])
    connector(1, 1);
    
}

module obstruction() {
    
    render(convexity = 2)
    difference() {
        burr_piece(["x"]);
        translate([$burr_scale / 2 - $burr_inset, 0, $burr_scale / 2 - $burr_inset])
        rotate([-90, 0, 0])
        connector(1.1, 1.3);
    }
    
}

module connector(radius, height) {
    translate([$burr_scale / 4, $burr_scale / 4, 0]) cylinder(r = radius, h = height, $fn = 32);
    translate([-$burr_scale / 4, $burr_scale / 4, 0]) cylinder(r = radius, h = height, $fn = 32);
    translate([-$burr_scale / 4, -$burr_scale / 4, 0]) cylinder(r = radius, h = height, $fn = 32);
    translate([$burr_scale / 4, -$burr_scale / 4, 0]) cylinder(r = radius, h = height, $fn = 32);
}
