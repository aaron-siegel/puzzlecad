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

require_puzzlecad_version("2.0");

$burr_scale = 16;
$plate_width = 180;
$burr_inset = 0.07;     // This can be 0.06 for a tighter fit
$burr_bevel = 1.2;

// Uncomment one of the following lines to render that module.

*color_1();
*color_2();
*color_3();
*color_4();
*single_color();

module color_1() {
    
    burr_plate([
        ["x{connect=fx-z+,clabel=A}|x|x|x{connect=mz+y+,clabel=X}"],
        ["x|x{connect=mz+y-,clabel=B}|x|x{connect=fx+z+,clabel=C}"],
        ["x{connect=fx-z+,clabel=D}|x|x{connect=mz+y+,clabel=E}|x"],
        ["x{connect=fx-z+,clabel=F}|x{label_text=Stewart Coffin,label_orient=z-y-,label_hoffset=-0.5,label_scale=0.275}|x{connect=mz+y+,clabel=G}|x"],
    ]);
    
}

module color_2() {
    
    burr_plate([
        ["x|x|x|x{connect=fx-z+,clabel=B}"],
        ["x{connect=fx+z+,clabel=E}|x|x|x{connect=mz+y+,clabel=X}"],
        ["x{connect=fx+z+,clabel=G}|x|x|x{connect=mz+y+,clabel=X}"],
        ["a.|a{label_text=Convolution's Cousin,label_orient=z+y-,label_hoffset=-0.5,label_scale=0.275}.|ab|a.", "..|..|.b|.."]
    ]);
    
}

module color_3() {
    
    burr_plate([
        ["x{connect=mz+y+,clabel=X}|x|x{connect=mz+y+,clabel=A}|x"],
        ["x|x{connect=mz+y-,clabel=C}|x|x{connect=mz+y+,clabel=X}"],
        ["x{connect=mz+y+,clabel=X}|x{connect=mz+y-,clabel=D}|x|x{connect=mz+y+,clabel=X}"],
        ["x|x|x{connect=mz+y+,clabel=F}|x{connect=mz+y+,clabel=X}"]
    ]);
    
}

module color_4() {
    
    burr_plate(copies(8, ["x{connect=fz-y+,clabel=X}"]));
    
}

module single_color() {
    
    burr_plate([
        ["a|a|a{connect=mz+y+,clabel=A}|a", "b|.|.|."],
        ["aaaa{connect=fz+y+,clabel=A}|b..."],
        [".a|ba|.a|.a{connect=mz+y+,clabel=B}", "..|b.|..|..", "..|b.|..|..", "..|b.|..|.."],
        ["aaa{connect=fz+y+,clabel=B}a", "b..."],
        ["ab|ac|a.|a.", "..|.c|..|..", "..|.c{connect=fy-z+,clabel=C}|..|..", "..|.c|..|.."],
        ["a...|bbbb{connect=mz+y-,clabel=C}"],
        ["ab|.b|cb|db", "..|..|c.|..", "..|..|c{connect=fy+z+,clabel=D}.|..", "..|..|c.|.."],
        ["a{connect=mz+y+,clabel=D}aaa|...b"],
        ["..a.|bbbb", "..a.|...."]
    ]);

}
