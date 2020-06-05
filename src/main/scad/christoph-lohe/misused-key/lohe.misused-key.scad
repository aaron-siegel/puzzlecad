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
$burr_inset = 0.1;
$burr_bevel = 0.5;

*frame();
*shackle();
*pieces();
*key();

module frame() {
    
    burr_plate([
        [ "xxxxxxx|xxxxxxx|xxxxxxx|xxxxxxx",
          "x.....x|x.x...x|x.....x|x.....x",
          "x.....x|x.....x|x.....x{connect=fx-z+,clabel=B}|x.....x",
          "x.....x|x.....x|x.....x|x.....x",
          "x.....x|x.....x|x.....x|x.....x",
          "x{connect=mz+y+,clabel=A}.....x{connect=mz+y+,clabel=A}|x{connect=fx+z+,clabel=B}.....x|x.....x|x{connect=mz+y+,clabel=A}.....x{connect=mz+y+,clabel=A}" ]
    ], $burr_bevel_adjustments = "z+=0.01,y-=1,y+=1,z-=1");
    
    translate([7 * $burr_scale + $plate_sep, 0, 0])
    burr_plate([
        [ "x{connect=mz+y+,clabel=B}" ],
        [ "x{connect=mz+y+,clabel=B}" ]
    ]);
    
    translate([0, 4 * $burr_scale + $plate_sep, 0])
    burr_plate([
        [ "x{connect=fz-y+,clabel=A}xxxxxx{connect=fz-y+,clabel=A}|x.....x|x.....x|x{connect=fz-y+,clabel=A}xxxxxx{connect=fz-y+,clabel=A}" ]
    ], $burr_bevel = 1);

}

module shackle() {
    
     burr_plate([
        ["x....|x....|x{label_text=Misused Key,label_orient=z+y+,label_hoffset=0.5}....|x....|xx.x{connect=mz+y+,clabel=C}.|xx.xx|x...x|x...x|x...x|xxxxx",
         "x....|.....|.....|.....|.x...|xx.xx|x...x|x...x|x...x|xxxxx"],
        ["x|x|x{label_text=C. Lohe,label_orient=z+y+}|x|x{connect=fz+y+,clabel=C}", "x|.|.|.|."]
    ]);
    
}

module pieces() {
    
    burr_plate([
        [ "x..x|xxxx|x..x", "x..x|x..x|x..x" ],
        [ "x..x|xxxx|xx.x", "x..x|x..x|x..x" ],
        [ "xx.x|x..x|xxxx", "x..x|x..x|x..x" ],
        [ "x.xx|x..x|xxxx", "x..x|x..x|x..x" ]
    ], $burr_outer_x_bevel = 1);
    
}

module key() {
    
    burr_piece(".x.|.xx|.x.|.x.|xxx|x.x|xxx");
    
}
