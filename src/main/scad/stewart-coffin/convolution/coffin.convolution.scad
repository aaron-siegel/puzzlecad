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
        ["x{connect=fz-y+,clabel=X}x{connect=mz+x+,clabel=A}"],
        ["x{connect=fy-z+,clabel=A}|x{connect=mz+y+,clabel=B}"],
        ["x{connect=fy-z+,clabel=C}", "x{connect=fx-z+,clabel=X}"],
        ["abb{connect=fz+y+,clabel=X}", "a{connect=fy-z+,clabel=E}.."],
        ["x|x{connect={mz+y+,fz-y+},clabel={G,X}}"],
        [".a{connect=mz+y-,clabel=J}.|ba.|.c{connect=fz-y+,clabel=K}c"],
        ["x", "x{connect=mz+y+,clabel=K}"]
    ]);

}

module color_2() {

    burr_plate([
        ["ab{label_text=STC #30,label_orient=y-x+,label_scale=0.35}b{connect=fz-y+,clabel=B}", "a.."],
        ["x{connect=fx+z+,clabel=D}|x{connect=fz+y+,clabel=X}"],
        ["x|x{connect=mz+y+,clabel=F}"],
        ["x{connect=fz-x+,clabel=G}|x{connect=mz+x+,clabel=H}"],
        ["x{connect=fx+z+,clabel=J}|x"],
        ["x", "x{connect=mz+x-,clabel=L}"],
        ["x{connect={fz-x-,mz+x-},clabel={L,M}}|x{connect=fz+x-,clabel=X}"],
    ]);

}

module color_3() {
    
    burr_plate([
        ["ab{label_text=Convolution,label_orient=y-x+,label_scale=0.35}b{connect=mz+x+,clabel=C}|.c.", "a{connect=fy-z+,clabel=X}..|..."],
        ["a..|bcc{connect=mz+x+,clabel=D}|b{connect=fz+y+,clabel=X}..", "a..|...|..."],
        ["x{connect=mz+y+,clabel=E}x{connect=fz-y+,clabel=F}"],
        ["abb", "a{connect=fy-z+,clabel=H}.."],
        ["abb", "a{connect=fy-z+,clabel=M}.."]
    ]);
    
}

module color_4() {
    
    burr_plate(repeat(8, ["x{connect=mz+y+,clabel=X}"]), $plate_width = ($burr_scale + $plate_sep) * 3);
    
}

module single_color() {
    
    burr_plate([
        ["..ab|cca.|d...", "....|....|d{connect=fz+y+,clabel=A}..."],
        ["x{connect=mz+y+,clabel=A}|x"],
        ["ab{connect=fz-y+,clabel=B,label_text=Convolution,label_orient=z+x+,label_scale=0.35}b.|a.cc", "....|d..e"],
        ["x{connect=mz+y+,clabel=B}"],
        ["a..|bcc{connect=mz+y+,clabel=C}|b..", "a..|...|d.."],
        [".a{connect=fz+y+,clabel=C}|ba"],
        ["ab.|.bc", "a..|..c{connect=fy+z+,clabel=D}"],
        ["a|b", ".|b{connect=mz+y+,clabel=D}"],
        ["aabc|...c{connect=fz-y+,clabel=E}", "..bd|...."],
        ["x", "x{connect=mz+y+,clabel=E}"],
        ["..a|bc{connect=fz-y+,clabel=F}c|d..|d..", "..a|b..|...|..."],
        ["x{connect=mz+y+,clabel=F}"],
        ["a.|a.|bb{connect=mz+x-,clabel=G}"],
        ["a{connect=fx-z+,clabel=G}..|abc", "...|.b."]
    ]);

}

// The same components as above, but organized by piece rather than color:

module piece_1() {
    burr_plate([
        ["x{connect=fz-y+,clabel=X}x{connect=mz+x+,clabel=A}"], // 1 = F/B
        ["x{connect=fy-z+,clabel=A}|x{connect=mz+y+,clabel=B}"], // 1
        ["ab{label_text=STC #30,label_orient=y-x+,label_scale=0.4}b{connect=fz-y+,clabel=B}", "a.."], // 2 = U/D
    ]);
}

module piece_2() {
    burr_plate([
        ["ab{label_text=Convolution,label_orient=y-x+,label_scale=0.35}b{connect=mz+x+,clabel=C}|.c.", "a{connect=fy-z+,clabel=X}..|..."], // 3 = L/R
        ["x{connect=fy-z+,clabel=C}", "x{connect=fx-z+,clabel=X}"] // 1
    ]);
}

module piece_3() {
    burr_plate([
        ["a..|bcc{connect=mz+x+,clabel=D}|b{connect=mz+y+,clabel=X}..", "a..|...|..."], // 3
        ["x{connect=fx+z+,clabel=D}|x{connect=fz+y+,clabel=X}"], // 2
    ]);
}

module piece_4() {
    burr_plate([
        ["abb{connect=fz+y+,clabel=X}", "a{connect=fy-z+,clabel=E}.."], // 1
        ["x{connect=mz+y+,clabel=E}x{connect=fz-y+,clabel=F}"], // 3
        ["x|x{connect=mz+y+,clabel=F}"] // 2
    ]);
}

module piece_5() {
    
    burr_plate([
        ["x|x{connect={mz+y+,fz-y+},clabel={G,X}}"], // 1
        ["x{connect=fz-x+,clabel=G}|x{connect=mz+x+,clabel=H}"], // 2
        ["abb", "a{connect=fy-z+,clabel=H}.."] // 3
    ]);
    
}

module piece_6() {

    burr_plate([
        ["x{connect=fx+z+,clabel=J}|x"], // 2
        [".a{connect=mz+y-,clabel=J}.|ba.|.c{connect=fz-y+,clabel=K}c"], // 1
        ["x", "x{connect=mz+y+,clabel=K}"] // 1
    ]);
    
}

module piece_7() {
    
    burr_plate([
        ["x", "x{connect=mz+x-,clabel=L}"], // 2
        ["x{connect={fz-x-,mz+x-},clabel={L,M}}|x{connect=fz+x-,clabel=X}"], // 2
        ["abb", "a{connect=fy-z+,clabel=M}.."] // 3
    ]);
    
}
