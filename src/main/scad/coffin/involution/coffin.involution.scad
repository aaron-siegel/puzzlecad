include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 16;
$plate_width = 120;
$burr_inset = 0.07;     // This can be 0.06 for a tighter fit
$burr_bevel = 1.2;
$joint_inset = 0.025;

// Uncomment one of the following lines to render that module.

*color_1();
*color_2();
*color_3();
*color_4();

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
        ["a..|bcc{connect=mz+x+,clabel=D}|b{connect=mz+y+,clabel=X}..", "a..|...|..."], // 3
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
        ["a{connect=mz+y+,clabel=X}ab{connect=mx+z-,clabel=K}|.c.", "..b|..."], // 3
        ["a|a{connect=fx-z+,clabel=K}", "b|.", "b|."], // 1
    ]);
}

module piece_7() {
    burr_plate([
        ["ab.|cdd", "...|c{connect=fx-z+,clabel=X}.."] // 2
    ]);
}