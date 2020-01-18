include <puzzlecad.scad>

$burr_scale = 16;
$plate_width = 180;
$burr_inset = 0.06;
$burr_bevel = 1;

color3();

module color1() {
    burr_plate([
        ["x{connect=fy-,clabel=Bz-}|x{connect=mz+,clabel=Ay-}"],
        ["x{connect=mz+,clabel=Bx+}x{connect=fz-,clabel=Xy-}"],
        [".aa{connect=fz-,clabel=Xy-}|b{connect=fx-,clabel=Cy-}b.", "...|c.."],
        ["abb{connect=fy+,clabel=Xz-}|a{connect=mz+,clabel=Ey-}.."],
        ["x{connect=mz+,clabel=Hy-}|x"],
        ["abb{connect=fy+,clabel=Xz-}|a{connect=mz+,clabel=Ky-}.."]
    ]);
}

module color2() {
    burr_plate([
        ["x{connect=fx+,clabel=Xz-}|x{connect=mz+,clabel=Cy-}"],
        ["aab|.c.|.c{connect=mz+,clabel=Dy-}.", "..b|...|..."],
        ["x{connect=mz+,clabel=Fy-}x{connect=fz-,clabel=Ey-}"],
        ["a.|a.|bb{connect=mz+,clabel=Gy-}"],
        ["a{connect=fz+,clabel=Xy-}a.|.bb{connect=mz+,clabel=Jy-}"],
        ["xx{connect=fz-,clabel=Ky-}"]
    ]);
}

module color3() {
    burr_plate([
        ["..|.."],      // Leave some space for the key piece at the end
        ["abb{connect=fz-,clabel=Ay-}", "a.."],
        ["x{connect=fy+,clabel=Xz-}x{connect=fz-,clabel=Dy-}"],
        ["x|x{connect=fz-,clabel=Fy-}"],
        ["a{connect=fx-,clabel=Gy-}b{connect=fy+,clabel=Hz-,label_orient=z+x+,label_text=Involute}b|a.."],
        ["x{connect=fz-,clabel=Jy-}x{connect=fy-,clabel=Xz-}"],
    ]);
    // Render the key piece with a tighter tolerance
    burr_piece(["aa|.b"], $burr_scale = 16.2, $burr_inset = 0.01);
}

module color4() {
    burr_plate([
        ["x{connect=mz+,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"]
    ], $burr_inset = 0.08);
}
/*
module color1() {
    burr_plate([
        ["..|.."],      // Leave some space for the key piece at the end
        ["ab.|.b.|.cc", "a{connect=mz+,clabel=Ay-}..|...|..."],
        ["x{connect=mz+,clabel=Xy-}x{connect=fz-,clabel=Ay-}"],
        ["a{connect=fz-,clabel=Xy-}.bb{connect=fz-,clabel=Xy-}|acc.", "....|.d.."],
        ["aab|.c.|.c{connect=mz+,clabel=Cy-}.", "..b|...|..."],
        ["x{connect=fy+,clabel=Xz-}x{connect=fz-,clabel=Cy-}"],
        [".a|bb|c.", ".a|..|c{connect=fx-,clabel=Dy-}."],
        ["x{connect=fx+,clabel=Xy-}", "x{connect=mz+,clabel=Dy-}"],
        ["a{connect=fx-,clabel=Ey-}b{note=z+x+,note_label=Involute}b|ac.", "...|.c."],
        ["a.|a.|bb{connect=mz+,clabel=Ey-}"],
        ["a{connect=mz+,clabel=Xy-}a.|.bb{connect=mz+,clabel=Fy-}"],
        ["x{connect=fz-,clabel=Fy-}x{connect=fy-,clabel=Xz-}"],
        ["abb{connect=fy+,clabel=Xz-}|a{connect=mz+,clabel=Gy-}.."],
        ["xx{connect=fz-,clabel=Gy-}"]
    ]);
    // Render the key piece with a tighter tolerance
    burr_piece(["aa|.b"], $burr_inset = 0.045);
}

module color2() {
    burr_plate([
        ["x{connect=fz-,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"],
        ["x{connect=fz-,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"],
        ["x{connect=mz+,clabel=Xy-}"]
    ], $joint_inset = 0.1);
}

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