/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Yavuz Demirhan
  3D model (c) Yu Chih Chang & Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

$burr_scale = 11.15;
$burr_inset = 0.07;
$burr_bevel = 0.5;

require_puzzlecad_version("2.1");

*basket();
*handle();
*pieces();

module basket() {

    burr_piece([
        "xxxxxx|xxxxxx|xx{connect=mz+x+,clabel=A}x{label_text=Basket Burr,label_orient=z+y+,label_hoffset=0.5,label_voffset=-0.1}x{label_text=Yavuz Demirhan,label_orient=z+y+,label_hoffset=0.5,label_voffset=0.1,label_scale=0.35}x{connect=mz+x-,clabel=A}x|xx{connect=mz+x+,clabel=A}xxx{connect=mz+x-,clabel=A}x|xxxxxx|xxxxxx",
        "xx..xx|xx..xx|x....x|x....x|xx..xx|xx..xx",
        "xx..xx|......|......|......|......|xx..xx"
    ], $burr_bevel_adjustments = "x+o=1.75,x-o=1.75,y+o=1.75,y-o=1.75");

}

module handle() {
    burr_plate([[
        "......|......|..x{connect=fy-z+,clabel=A}x{connect=fy-z+,clabel=A}..|...x..|...x..|..xx..|..xx..",
        "......|......|......|......|......|......|..x{connect=fz+y+,clabel=C}x{connect=mz+y+,clabel=B}.."
    ], [
        "......|......|..x{connect=fy-z+,clabel=A}x{connect=fy-z+,clabel=A}..|...x..|...x..|..xx..|..xx..",
        "......|......|......|......|......|......|..x{connect=fz+y+,clabel=B}x{connect=mz+y+,clabel=C}.."
    ]], $burr_outer_y_bevel = [0.5, 1.75]);
}

module pieces() {
    burr_plate([
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xx..xx|xxxxxx", "x....x|x....x"]
    ], $burr_outer_x_bevel = 1.75);
}
