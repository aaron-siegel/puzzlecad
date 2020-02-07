include <puzzlecad.scad>

$burr_scale = 16;
$plate_width = 180;
$burr_inset = 0.06;
$burr_bevel = 1;

piece7();

*color1();
*color2();
*color3();
*color4();

module piece1() {
    burr_plate([
        ["x{connect=mz+y+,clabel=X}"],  // 4
        ["x{connect=fz-y+,clabel=X}x{connect=mz+x+,clabel=A}"], // 1 = F/B
        ["x{connect=fy-z+,clabel=A}|x{connect=mz+y+,clabel=B}"], // 1
        ["abb{connect=fz-y+,clabel=B}", "a.."], // 2 = U/D
    ]);
}

module piece2() {
    burr_plate([
        ["abb{connect=mz+x+,clabel=C}|.c.", "a{connect=fy-z+,clabel=X}..|..."], // 3 = L/R
        ["x{connect=fy-z+,clabel=C}", "x{connect=fx-z+,clabel=X}"] // 1
    ]);
}

module piece3() {
    burr_plate([
        ["a..|bcc{connect=mz+x+,clabel=D}|b{connect=mz+y+,clabel=X}..", "a..|...|..."], // 3
        ["x{connect=fx+z+,clabel=D}|x{connect=fz+y+,clabel=X}"], // 2
    ]);
}

module piece4() {
    burr_plate([
        ["abb{connect=fz+y+,clabel=X}", "a{connect=fy-z+,clabel=E}.."], // 1
        ["x{connect=mz+y+,clabel=E}x{connect=fz-y+,clabel=F}"], // 3
        ["x|x{connect=mz+y+,clabel=F}"] // 2
    ]);
}

module piece5() {
    
    burr_plate([
        ["x|x{connect={mz+y+,fz-y+},clabel={G,X}}"], // 1
        ["x{connect=fz-x+,clabel=G}|x{connect=mz+x+,clabel=H}"], // 2
        ["abb", "a{connect=fy-z+,clabel=H}.."] // 3
    ]);
    
}

module piece6() {

    burr_plate([
        ["x{connect=fx+z+,clabel=J}|x"], // 2
        [".a{connect=mz+y-,clabel=J}.|ba.|.c{connect=fz-y+,clabel=K}c"], // 1
        ["x", "x{connect=mz+y+,clabel=K}"] // 1
    ]);
    
}

module piece7() {
    
    burr_plate([
        ["x", "x{connect=mz+x-,clabel=L}"], // 2
        ["x{connect={fz-x-,mz+x-},clabel={L,M}}|x{connect=fz+x-,clabel=X}"], // 2
        ["abb", "a{connect=fy-z+,clabel=M}.."] // 3
    ]);
    
}