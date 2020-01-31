include <puzzlecad.scad>

$burr_scale = 16;
$plate_width = 180;
$burr_inset = 0.06;
$burr_bevel = 1;

*color1();
*color2();
*color3();
*color4();

module color1() {
    burr_plate([
        ["x{connect=fy-z+,clabel=B}|x{connect=mz+y+,clabel=A}"],
        ["x{connect=mz+x-,clabel=B}x{connect=fz-y+,clabel=X}"],
        [".aa{connect=fz-y+,clabel=X}|b{connect=fx-z+,clabel=C}b.", "...|c.."],
        ["abb{connect=fy+z+,clabel=X}|a{connect=mz+y+,clabel=E}.."],
        ["x{connect=mz+y+,clabel=H}|x"],
        ["abb{connect=fy+z+,clabel=X}|a{connect=mz+y+,clabel=K}.."]
    ]);
}

module color2() {
    burr_plate([
        ["x{connect=fx+z+,clabel=X}|x{connect=mz+x-,clabel=C}"],
        ["aab|.c.|.c{connect=mz+y+,clabel=D}.", "..b|...|..."],
        ["x{connect=mz+y+,clabel=F}x{connect=fz-y+,clabel=E}"],
        ["a.|a.|bb{connect=mz+y+,clabel=G}"],
        ["a{connect=fz+y+,clabel=X}a.|.bb{connect=mz+y+,clabel=J}"],
        ["xx{connect=fz-y+,clabel=K}"]
    ]);
}

module color3() {
    burr_plate([
        ["aa|.b"],
        ["abb{connect=fz-y+,clabel=A}", "a.."],
        ["x{connect=fy+z+,clabel=X}x{connect=fz-y+,clabel=D}"],
        ["x|x{connect=fz-y+,clabel=F}"],
        ["a{connect=fx-y+,clabel=G}b{connect=fy+z+,clabel=H,label_orient=z+x+,label_text=Involute}b|a.."],
        ["x{connect=fz-y+,clabel=J}x{connect=fy-z+,clabel=X}"],
    ]);
}

module color4() {
    burr_plate(repeat(8, ["x{connect=mz+y+,clabel=X}"]), $plate_width = 100);
}

/*
module easy_print() {
    burr_plate([
        ["..|.."],      // Leave some space for the key piece at the end
        ["x{connect=mz+,clabel=Ay-}xxx|.xx.", "....|..x."], ["x|x|x{connect=fz+,clabel=Ay-}"],
        ["x{connect=mz+,clabel=By-}x.|.xx", "...|..x"], ["x|x|x{connect=fz+,clabel=By-}", "x|.|."],
        ["x..|xx.|.x.|.xx{connect=mz+,clabel=Cy-}"], ["xx", ".x{connect=fz+,clabel=Cy-}"],
        ["..x|x{connect=mz+,clabel=Dy-}xx|..x", "...|...|..x"], ["xx|x{connect=fz+,clabel=Dy-}."],
        ["xx{connect=fz-,clabel=Ey-}x.|x.xx", "....|x..x"], ["x{connect=mz+,clabel=Ey-}"],
        [".x|xx|x{connect=mz+,clabel=Fy-}.", ".x|..|.."], [".x{connect=fz+,clabel=Fy-}|xx"],
        ["xxx|x{connect=mz+,clabel=Gy-}.x"], ["x{connect=fz+,clabel=Gy-}x"]
    ]);
    // Render the key piece with a tighter tolerance
    burr_piece(["x.|xx"], $burr_inset = 0.045);
}
*/