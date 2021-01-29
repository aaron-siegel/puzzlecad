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

$burr_scale = 8;
$burr_inset = 0.08;     // Use 0.07 for a tighter fit
$burr_bevel = 0.5;

*pieces_1();
*pieces_2();
*pieces_3();
*pieces_4();
*pieces_5();
*pieces_6();

// 1 - Dark green
// 2 - Medium green
// 3 - Medium green
// 4 - White
// 5 - Light green
// 6 - Brown

module pieces_1() {
    
    burr_plate([
        [ "x.x{connect=mz+y+,clabel=A}|xxx{connect=mz+y+,clabel=A}", "x..|x.." ],
        [ "x{connect=fz-y+,clabel=A}xxxx{connect=fz-y+,clabel=B}|x{connect=fz-y+,clabel=A}...x{connect=fz-y+,clabel=B}" ],
        [ "x{connect=mz+y+,clabel=B}.x|x{connect=mz+y+,clabel=B}xx", "..x|..x" ]
    ], num_copies = 4);
    
}

module pieces_2() {
    
    burr_plate([
        [ "xxx...xxx|x{label_text=Cube,label_orient=x-y-,label_voffset=0.17}xxxxxxxx|xxx...xxx",
          "x.x...x.x|x{label_text=Moira's,label_orient=x-y-,label_voffset=-0.17}.xxxxx.x|x.x...x.x" ],
        [ "xxx...xxx|xxxxxxxxx|xxx...xxx", "x.x...x.x|x.xxxxx.x|x.x...x.x" ],
        [ "xxx...xxx|xxxxxxxxx|xxx...xxx", "x.x...x.x|x.xxxxx.x|x.x...x.x" ]
    ]);
    
}

module pieces_3() {
    
    burr_plate([
        [ "xxx{connect=mz+y+,clabel=C}|xxx|xxx{connect=mz+y+,clabel=C}", "x..|x..|x.."],
        [ "x{connect=mz+y+,clabel=D}xx|xxx|x{connect=mz+y+,clabel=D}xx", "..x|..x|..x"],
        [ "x{connect=fz-y+,clabel=C}...x{connect=fz-y+,clabel=D}|xxxxx|x{connect=fz-y+,clabel=C}...x{connect=fz-y+,clabel=D}" ]
    ], num_copies = 3);
    
}

module pieces_4() {
    
    burr_plate([
        [ "xxx{connect=fz+y+,clabel=E}", "x.." ],
        [ "x...x|x{connect=mz+y-,clabel=E}xxxx{connect=mz+y-,clabel=F}|x...x", "x...x|.....|....." ],
        [ "x{connect=fz+y+,clabel=F}xx", "..x" ]
    ], num_copies = 4);
    
}

module pieces_5() {

    burr_plate([
        [ "x...x|xxxxx|x...x", "x...x|x{connect=mz+y-,clabel=G}...x{connect=mz+y-,clabel=H}|x{connect=mz+y-,clabel=G}...x{connect=mz+y-,clabel=H}", "x...x|.....|....." ],
        [ ".x{connect=fz-y-,clabel=G}|xx{connect=fz-y-,clabel=G}" ],
        [ "x{connect=fz-y-,clabel=H}.|x{connect=fz-y-,clabel=H}x" ]
    ], num_copies = 4);

}

module pieces_6() {
    
    burr_plate([
        [ "x......xx|xxxxxxxxx|x...xxxxx", "x......xx|xxxxxxxxx|x...xxxxx" ],
        [ "x....xxxx|xxxxxxxxx|x...x.xxx", "x.....xxx|xxx...xxx|x.....xxx" ],
        [ "xxxx...xx|xxxxxxxxx|x.....xxx", "xxx....xx|xxx....xx|x......xx" ],
        [ "xxxx...xx|xxxxxxxxx|xxx...xxx", "x......xx|xxx.x..xx|xx.....xx" ],
        [ "x.xx....x|xxxxxxxxx|x......xx", "x.x.....x|xxx...xxx|x......xx" ],
        [ "x..x...xx|xxxxxxxxx|x.......x", "x..x...xx|xxxxxxxxx|x.......x" ]
    ]);
    
}
