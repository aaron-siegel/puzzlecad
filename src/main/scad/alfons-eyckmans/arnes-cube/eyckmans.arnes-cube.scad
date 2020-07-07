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

module pieces_1() {

    burr_plate([
        [ "xxx..xxx|x.xxxx.x", "x.x..x.x|x.xxxx.x" ],
        [ "xxx..xxx|x.xxxx.x", "x.x..x.x|x.xxxx.x" ],
        [ "xxx..xxx|x.xxxx.x", "x.x..x.x|x.xxxx.x" ],
        [ "xxx..xxx|x.xxxx.x", "x.x..x.x|x.xx{label_text=Arne's Cube,label_orient=y+x-,label_hoffset=-0.5,label_voffset=-0.5}xx.x" ]
    ]);

}

module pieces_2() {
    
    burr_plate([
        [ "x..|xxx{connect=mz+y+,clabel=A}" ],
        [ "..x|x{connect=mz+y+,clabel=B}xx" ],
        [ "..xxxx..|..x{connect=fz+y+,clabel=B}..x{connect=fz+y+,clabel=A}.." ]
    ], num_copies = 4);
    
}

module pieces_3() {
    
    burr_plate([
        [ "xxxx{label_text=A. Eyckmans,label_orient=z+x+,label_hoffset=0.5}xxxx|xx.x...x", "x......x|x......x" ],
        [ "xxxxxxxx|xx.x..xx", "x......x|x......x" ]
    ]);

}

module pieces_4() {

    burr_plate([
        [ ".xxxxxx.|xxx..xxx", ".xx..xx.|xxx..xxx" ]
    ], num_copies = 2);
    
}

module pieces_5() {
    
    burr_plate([
        [ "x..x|x{connect=mz+y-,clabel=C}xxx{connect=mz+y-,clabel=D}|x{connect=mz+y-,clabel=C}xxx{connect=mz+y-,clabel=D}",
          "x..x|....|....",
          "x..x|....|...." ],
        [ ".x{connect=fz-y-,clabel=C}|xx{connect=fz-y-,clabel=C}", ".x|.." ],
        [ "x{connect=fz-y-,clabel=D}.|x{connect=fz-y-,clabel=D}x", "x.|.." ],
        [ "x..x|x{connect=mz+y-,clabel=E}xxx{connect=mz+y-,clabel=F}|x{connect=mz+y-,clabel=E}xxx{connect=mz+y-,clabel=F}",
          "x..x|....|....",
          "x..x|....|...." ],
        [ ".x{connect=fz-y-,clabel=E}|xx{connect=fz-y-,clabel=E}" ],
        [ "x{connect=fz-y-,clabel=F}.|x{connect=fz-y-,clabel=F}x" ]
    ], num_copies = 2);
    
}

module pieces_6() {

    burr_plate([
        [ "xxxxxxxx|x.....xx", "x...x..x|x.....xx" ],
        [ "xxxxxxxx|xxxxxxxx", "xx.....x|xx.....x" ],
        [ "xxxxxxxx|x..x.xxx", "x......x|x......x" ],
        [ "xxxxxxxx|xx....xx", "x..xxx.x|x......x" ],
        [ "xxxxxxxx|x.x.xxxx", "x......x|x......x" ],
        [ "xxxxxxxx|xxx....x", "xx..x..x|x......x" ],
        [ "xxxxxxxx|x.xxx..x", "x......x|x......x" ],
        [ "xxxxxxxx|x....xxx", "xx...xxx|x.....xx" ],
        [ "xxxxxxxx|x....xxx", "xx...xxx|x....xxx" ]
    ]);    
    
}
