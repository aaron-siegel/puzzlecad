/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Christoph Lohe
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_scale = 10;
$burr_inset = 0.1;      // Use 0.09 for a tighter fit
$burr_bevel = 0.5;

*frame();
*shackle();
*curved_shackle();
*pieces();
*key();
*curved_key();

module frame() {

    burr_plate([
        [ "xxxxxxx|xxxxxxx|xxxxxxx|xxxxxxx",
          "x.....x|xxx...x|x.....x|x.....x",
          "x.....x|x.....x|x.....x{connect=fx-z+,clabel=B}|x.....x",
          "x.....x|x.....x|x.....x|x.....x",
          "x.....x|x.....x|x.....x|x.....x",
          "x{connect=mz+y+,clabel=A}.....x{connect=mz+y+,clabel=A}|x.....x|x.....x|x{connect=mz+y+,clabel=A}.....x{connect=mz+y+,clabel=A}" ]
        ], $burr_bevel_adjustments = "z+=0.01,y-=1,y+=1,z-=1");
        
    translate([7 * $burr_scale + $plate_sep, 0, 0])
    burr_plate([
        [ "x{connect=mz+y+,clabel=B}" ]
    ]);

    translate([0, 4 * $burr_scale + $plate_sep, 0])
    burr_plate([
        [ "x{connect=fz-y+,clabel=A}xxxxxx{connect=fz-y+,clabel=A}|x.....x|x.....x|x{connect=fz-y+,clabel=A}xxxxxx{connect=fz-y+,clabel=A}" ]
    ], $burr_bevel = 1);

}

module shackle() {
    
    burr_plate([
        [ "xxxx.|x....|x{label_text=Key Trap,label_orient=z+y+,label_voffset=-0.05}..x.|x..x{label_text=C. Lohe,label_orient=z+y+}.|x..x.|xx.xx|x...x|x...x|x...x|xxxxx",
          ".....|.....|.....|.....|.....|xx.xx|x...x|x...x|x...x|xxxxx" ]
    ]);
    
}

module curved_shackle() {
    
    burr_plate([
        [ "xxxx.|x....|x{label_text=Key Trap,label_orient=z+y+,label_voffset=-0.05}..x.|x..x{label_text=C. Lohe,label_orient=z+y+}.|x..x.|xx.xx|x...x|x...x|.....|..x..",
          ".....|.....|.....|.....|.....|xx.xx|x...x|x...x|.....|..x.." ]
    ]);

    translate([$burr_scale * 2 - $burr_inset, $burr_scale * 8 - $burr_inset, 0])
    shackle_arc();
    
    translate([$burr_scale * 3 - $burr_inset, $burr_scale * 8 - $burr_inset, 0])
    mirror([1, 0, 0])
    shackle_arc();
    
}

module shackle_arc() {
    
    arc = concat(
        [ for (theta = [90:3:180]) [ ($burr_scale + $burr_inset) * cos(theta), ($burr_scale + $burr_inset) * sin(theta) ] ],
        [ [ -($burr_scale + $burr_inset), -2 * $burr_bevel ], [ -(2 * $burr_scale - $burr_inset), -2 * $burr_bevel ] ],
        [ for (theta = [180:-3:90]) [ (2 * $burr_scale - $burr_inset) * cos(theta), (2 * $burr_scale - $burr_inset) * sin(theta) ] ],
        [ [ 2 * $burr_bevel, 2 * $burr_scale - $burr_inset], [ 2 * $burr_bevel, $burr_scale + $burr_inset ] ]
    );
    
    beveled_prism(arc, height = $burr_scale * 2 - $burr_inset * 2);
    
}

module pieces() {
    
    burr_plate([
        [ "x..x|x..x|xxxx", "x..x|x..x|x..x" ],
        [ "x..x|x..x|xxxx", "x..x|x..x|x..x" ],
        [ "x..x|x..x|xxxx", "x..x|x..x|xx.x" ],
        [ "x..x|x.xx|xxxx", "x..x|x..x|xx.x" ]
    ], $burr_outer_x_bevel = 1);
    
}

module key() {
    
    burr_plate([
        ["xxxx|x..x|x..x{connect=fx+z+,clabel=C}|x..x|xxxx"],
        ["..x.x|x{connect=mx-z-,clabel=C}xxxx"]
    ], $plate_sep = $burr_scale);
    
}

module curved_key() {
    
    burr_plate([
        [".xx.|x..x|x..x{connect=fx+z+,clabel=C}|x..x|.xx."],
        ["..x.x|x{connect=mx-z-,clabel=C}xxxx"]
    ], $plate_sep = $burr_scale);

    translate([$burr_scale - $burr_inset, 4 * $burr_scale - $burr_inset])
    key_arc();
    
    translate([3 * $burr_scale - $burr_inset, 4 * $burr_scale - $burr_inset])
    mirror([1, 0, 0])
    key_arc();

    translate([3 * $burr_scale - $burr_inset, $burr_scale - $burr_inset])
    mirror([1, 0, 0])
    mirror([0, 1, 0])
    key_arc();

    translate([$burr_scale - $burr_inset, $burr_scale - $burr_inset])
    mirror([0, 1, 0])
    key_arc();

}

module key_arc() {
    
    arc = concat(
        [ for (theta = [180:-5:90]) [ ($burr_scale - $burr_inset) * cos(theta), ($burr_scale - $burr_inset) * sin(theta) ] ],
        [ [ 2 * $burr_bevel, $burr_scale - $burr_inset],
          [ 2 * $burr_bevel, $burr_inset ],
          [ -$burr_inset, $burr_inset],
          [ -$burr_inset, -2 * $burr_bevel ],
          [ -($burr_scale - $burr_inset), -2 * $burr_bevel ]
        ]
    );
    
    beveled_prism(arc, height = $burr_scale - $burr_inset * 2);
    
}
