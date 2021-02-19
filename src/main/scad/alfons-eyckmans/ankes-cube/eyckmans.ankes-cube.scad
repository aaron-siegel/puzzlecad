/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Alfons Eyckmans
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_scale = 9;
$burr_inset = 0.08;     // Use 0.07 for a tighter fit
$burr_bevel = 0.5;

*pieces_1();
*pieces_2();
*pieces_3();
*pieces_4();
*pieces_5();
*pieces_6();

// 1 - Light blue
// 2 - White
// 3 - Dark blue
// 4 - Grey
// 5 - Med Blue
// 6 - Black

module pieces_1() {
    
    burr_plate([
        [ "xxx..xxx|x.xxxx.x", "x.x..x.x|x.xxxx.x" ],
        [ "xxx..xxx|x.xxxx.x", "x.x..x.x|x.xxxx.x" ],
        [ "xxx..xxx|x.xxxx.x", "x.x..x.x|x.xxxx.x" ],
        [ "xxx..xxx|x.xxxx.x", "x.x..x.x|x.xx{label_text=Anke's Cube,label_orient=y+x-,label_hoffset=-0.5,label_voffset=-0.5}xx.x" ]
    ]);
    
}

module pieces_2() {

    burr_plate([
        [ "x..|xxx{connect=mz+y-,clabel=A}" ],
        [ "..x|x{connect=mz+y-,clabel=B}xx" ],
        [ "xxxx|x{connect=fz+y-,clabel=B}..x{connect=fz+y-,clabel=A}" ]
    ], num_copies = 4);
    
}

module pieces_3() {
    
    burr_plate([
        [ "xxxxxxxx|x......x", "xx....xx|x......x" ],
        [ "xxxxxxxx|x......x", "xx..x.xx|x......x" ]
    ]);
    
}

module pieces_4() {
    
    burr_plate([
        [ "xxx..xxx|xxx..xxx", ".xxxxx..|.xx..x.." ],
        [ "xxx..xxx|xxx..xxx", "..xxxxx.|..x..xx." ],
    ], $auto_layout = true);

}

module pieces_5() {
    
    burr_plate([
        [ "x..x|x{connect=mz+y-,clabel=C}xxx{connect=mz+y-,clabel=D}|x{connect=mz+y-,clabel=C}xxx{connect=mz+y-,clabel=D}",
          "x..x|....|....",
          "x..x|....|...." ],
        [ ".x{connect=fz-y-,clabel=C}|xx{connect=fz-y-,clabel=C}", ".x|.." ],
        [ "x{connect=fz-y-,clabel=D}.|x{connect=fz-y-,clabel=D}x", "x.|.." ]
    ], num_copies = 4);
    
}

module pieces_6() {

    burr_plate([
        [ "xxxxx..x|x...xxxx", "xx.....x|x.....xx" ],
        [ "xxxxxxxx|xxxx...x", "xx.....x|xx.....x" ],
        [ "xxxxxxxx|xx..x.xx", "x......x|x......x" ],
        [ "xxxxxxxx|xxxx.xxx", "x.....xx|x.....xx" ],
        [ "xxxxxxxx|xxxx...x", "x......x|x......x" ],
        [ "x..xxxxx|xxxxxxxx", "x....x.x|x......x" ],
        [ "xxxxxxxx|xx..x.xx", "x.x....x|x......x" ],
        [ "x..xxxxx|xxxx...x", "x.....xx|xx.....x" ],
        [ "x..xxxxx|xxxx...x", "x......x|xx.....x" ]
    ]);

}
