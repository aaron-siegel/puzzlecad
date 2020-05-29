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
*tighter_key_piece();

module color_1() {

    burr_plate([
        ["x{connect=fz-y+,clabel=X}x{connect=mz+x+,clabel=A}"],
        ["x{connect=fy-z+,clabel=A}|x{connect=mz+y+,clabel=B}"],
        ["x{connect=fy-z+,clabel=C}", "x{connect=fx-z+,clabel=X}"],
        ["a{connect=fz+x-,clabel=X}ab", "..b{connect=fy+z+,clabel=E}"],
        ["x{connect=mz+y-,clabel=J}|x"],
        ["a{connect=fz+y+,clabel=X}ab", "..b{connect=fy+z+,clabel=L}"]
    ]);

}

module color_2() {

    burr_plate([
        ["ab{label_text=STC #214,label_orient=y-x+,label_scale=0.35}b{connect=fz-y+,clabel=B}", "a.."],
        ["x{connect=fx+z+,clabel=D}|x{connect=fz+y+,clabel=X}"],
        ["x|x{connect=mz+x-,clabel=F}"],
        ["x", "x{connect=mz+y+,clabel=G}"],
        ["x{connect={fz-x-,mz+x-},clabel={G,H}}|x{connect=fz-x-,clabel=J}"],
        ["x{connect=fy-z+,clabel=K}x{connect=fz+y+,clabel=X}"],
        ["aa|.b"]
    ]);

}

module color_3() {
    
    burr_plate([
        ["ab{label_text=Involute,label_orient=y-x+,label_scale=0.35}b{connect=mz+x+,clabel=C}|.c.", "a{connect=fy-z+,clabel=X}..|..."],
        ["a..|bcc{connect=mz+x+,clabel=D}|b..", "a..|...|..."],
        ["x{connect=fz-y+,clabel=F}|x{connect=mz+x+,clabel=E}"],
        ["a|a|b", ".|.|b{connect=fx-z+,clabel=H}"],
        ["a{connect=fz+y+,clabel=X}a.|.bb{connect=mz+y-,clabel=K}"],
        ["x{connect=mz+y+,clabel=L}x"]
    ]);
    
}

module color_4() {
    
    burr_plate(repeat(8, ["x{connect=mz+y+,clabel=X}"]), $plate_width = ($burr_scale + $plate_sep) * 3);
    
}

module single_color() {

    burr_plate([
        ["x{connect=mz+,clabel=Ay-}xxx|.xx.", "....|..x."], ["x|x|x{connect=fz+,clabel=Ay-}"],
        ["x{connect=mz+,clabel=By-}x.|.xx", "...|..x"], ["x|x|x{connect=fz+,clabel=By-}", "x|.|."],
        ["x..|xx.|.x.|.xx{connect=mz+,clabel=Cy-}"], ["xx", ".x{connect=fz+,clabel=Cy-}"],
        ["..x|x{connect=mz+,clabel=Dy-}xx|..x", "...|...|..x"], ["xx|x{connect=fz+,clabel=Dy-}."],
        ["xx{connect=fz-,clabel=Ey-}x.|x.xx", "....|x..x"], ["x{connect=mz+,clabel=Ey-}"],
        [".x|xx|x{connect=mz+,clabel=Fy-}.", ".x|..|.."], [".x{connect=fz+,clabel=Fy-}|xx"],
        ["xxx|x{connect=mz+,clabel=Gy-}.x"], ["x{connect=fz+,clabel=Gy-}x"],
        ["x.|xx"]
    ]);

}

// The same components as above, but organized by piece rather than color:

module piece_1() {
    burr_plate([
        ["x{connect=fz-y+,clabel=X}x{connect=mz+x+,clabel=A}"], // 1 = F/B
        ["x{connect=fy-z+,clabel=A}|x{connect=mz+y+,clabel=B}"], // 1
        ["ab{label_text=STC #214,label_orient=y-x+,label_scale=0.35}b{connect=fz-y+,clabel=B}", "a.."], // 2 = U/D
    ]);
}

module piece_2() {
    burr_plate([
        ["ab{label_text=Involute,label_orient=y-x+,label_scale=0.35}b{connect=mz+x+,clabel=C}|.c.", "a{connect=fy-z+,clabel=X}..|..."], // 3 = L/R
        ["x{connect=fy-z+,clabel=C}", "x{connect=fx-z+,clabel=X}"] // 1
    ]);
}

module piece_3() {
    burr_plate([
        ["a..|bcc{connect=mz+x+,clabel=D}|b..", "a..|...|..."], // 3
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
        ["a{connect=fz+y+,clabel=X}a.|.bb{connect=mz+y-,clabel=K}"], // 3
        ["x{connect=fy-z+,clabel=K}x{connect=fz+y+,clabel=X}"] // 2
    ]);
}

module piece_7() {
    burr_plate([
        ["a{connect=fz+y+,clabel=X}ab", "..b{connect=fy+z+,clabel=L}"], // 1
        ["x{connect=mz+y+,clabel=L}x"] // 3
    ]);
}

module piece_8() {
    burr_plate([
        ["aa|.b"] // 2
    ]);
}

module tighter_key_piece() {
    piece_8($burr_inset = 0.01);
}
