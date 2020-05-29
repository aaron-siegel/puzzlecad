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
        ["x{connect=fz-y+,clabel=X}x{connect=mz+x+,clabel=A}"], // 1 = F/B
        ["x{connect=fy-z+,clabel=A}|x{connect=mz+y+,clabel=B}"], // 1
        ["x{connect=fy-z+,clabel=C}", "x{connect=fx-z+,clabel=X}"], // 1
        ["a{connect=fz+x-,clabel=X}ab", "..b{connect=fy+z+,clabel=E}"], // 1
        ["x{connect=mz+y-,clabel=J}|x"], // 1
        ["a|a{connect=fx-z+,clabel=K}", "b|.", "b|."], // 1
    ]);
    
}

module color_2() {
    
    burr_plate([
        ["ab{label_text=STC #198,label_orient=y-x+,label_scale=0.35}b{connect=fz-y+,clabel=B}", "a.."], // 2 = U/D
        ["x{connect=fx+z+,clabel=D}|x{connect=fz+y+,clabel=X}"], // 2
        ["x|x{connect=mz+x-,clabel=F}"], // 2
        ["x", "x{connect=mz+y+,clabel=G}"], // 2
        ["x{connect={fz-x-,mz+x-},clabel={G,H}}|x{connect=fz-x-,clabel=J}"], // 2
        ["ab.|cdd", "...|c{connect=fx-z+,clabel=X}.."] // 2
    ]);
    
}

module color_3() {
    
    burr_plate([
        ["ab{label_text=Involution,label_orient=y-x+,label_scale=0.35}b{connect=mz+x+,clabel=C}|.c.", "a{connect=fy-z+,clabel=X}..|..."], // 3 = L/R
        ["a..|bcc{connect=mz+x+,clabel=D}|b{connect=fz+y+,clabel=X}..", "a..|...|..."], // 3
        ["x{connect=fz-y+,clabel=F}|x{connect=mz+x+,clabel=E}"], // 3
        ["a|a|b", ".|.|b{connect=fx-z+,clabel=H}"], // 3
        ["a{connect=fz+y+,clabel=X}ab{connect=mx+z-,clabel=K}|.c.", "..b|..."], // 3
    ]);
    
}

module color_4() {
    
    burr_plate(repeat(8, ["x{connect=mz+y+,clabel=X}"]), $plate_width = ($burr_scale + $plate_sep) * 3);
    
}

module single_color() {
    
    burr_plate([
        ["x..|xx.|.x.|.xx{connect=mz+,clabel=Ay-}"], ["xx", ".x{connect=fz+,clabel=Ay-}"],
        ["x{connect=mz+,clabel=By-}xx{connect=mz+,clabel=Gy-}|.x."],
        ["x|x{connect=fz+,clabel=By-}"], ["x.|xx{connect=fz+,clabel=Gy-}"],
        ["x..|xxx{connect=mz+,clabel=Cy-}|x..", "x|.|x"], ["xx|x{connect=fz+,clabel=Cy+}."],
        ["xxx{connect=mz+,clabel=Dy-}", "x.."], [".x{connect=fz+,clabel=Dy-}|xx|x.", "..|..|x."],
        ["x{connect=mz+,clabel=Ey-}xx"], ["x.|xx|xx|x{connect=fz+,clabel=Ey-}.", "..|.x"],
        ["xxxx|.x.x{connect=fz-,clabel=Fy-}", "x.x."], ["x", "x{connect=mz+,clabel=Fy-}"],
        ["x.|xx|.x|.x", "..|.x|.x"]
    ]);
    
}

// The same components as above, but organized by piece rather than color:

module piece_1() {
    burr_plate([
        ["x{connect=fz-y+,clabel=X}x{connect=mz+x+,clabel=A}"], // 1 = F/B
        ["x{connect=fy-z+,clabel=A}|x{connect=mz+y+,clabel=B}"], // 1
        ["ab{label_text=STC #198,label_orient=y-x+,label_scale=0.35}b{connect=fz-y+,clabel=B}", "a.."], // 2 = U/D
    ]);
}

module piece_2() {
    burr_plate([
        ["ab{label_text=Involution,label_orient=y-x+,label_scale=0.35}b{connect=mz+x+,clabel=C}|.c.", "a{connect=fy-z+,clabel=X}..|..."], // 3 = L/R
        ["x{connect=fy-z+,clabel=C}", "x{connect=fx-z+,clabel=X}"] // 1
    ]);
}

module piece_3() {
    burr_plate([
        ["a..|bcc{connect=mz+x+,clabel=D}|b{connect=fz+y+,clabel=X}..", "a..|...|..."], // 3
        ["x{connect=fx+z+,clabel=D}|x{connect=fz+y+,clabel=X}"], // 2
    ]);
}

module piece_4() {
    burr_plate([
        ["a{connect=fz+x-,clabel=X}ab", "..b{connect=fy+z+,clabel=E}"], // 1
        ["x{connect=fz-y+,clabel=F}|x{connect=mz+x+,clabel=E}"], // 3
        ["x|x{connect=mz+x-,clabel=F}"] // 2
    ]);
}

module piece_5() {
    burr_plate([
        ["x", "x{connect=mz+y+,clabel=G}"], // 2
        ["x{connect={fz-x-,mz+x-},clabel={G,H}}|x{connect=fz-x-,clabel=J}"], // 2
        ["a|a|b", ".|.|b{connect=fx-z+,clabel=H}"], // 3
        ["x{connect=mz+y-,clabel=J}|x"] // 1
    ]);
}

module piece_6() {
    burr_plate([
        ["a{connect=fz+y+,clabel=X}ab{connect=mx+z-,clabel=K}|.c.", "..b|..."], // 3
        ["a|a{connect=fx-z+,clabel=K}", "b|.", "b|."], // 1
    ]);
}

module piece_7() {
    burr_plate([
        ["ab.|cdd", "...|c{connect=fx-z+,clabel=X}.."] // 2
    ]);
}