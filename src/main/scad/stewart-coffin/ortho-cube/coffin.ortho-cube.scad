include <puzzlecad.scad>

*solid_colors();
*color1();
*color2();
*color3();

$burr_scale = 14.5;
$burr_inset = 0.06;
$burr_bevel = 1;

module solid_colors() {
    
    burr_plate([
        ["x..|xxx{connect=mz+,clabel=Ay-}"], ["..x{connect=fz+,clabel=Ay-}|xxx","...|x.."],
        ["x..|xxx{connect=mz+,clabel=By-}"], ["x{connect=fz-,clabel=By-}..|xxx","...|..x"],
        ["xxx{connect=mz+,clabel=Cy-}|x.."], ["..x{connect=fz+,clabel=Cy-}|xxx"]
    ]);
    
}

// Main color:

module color1() {
    
    burr_plate([
        ["xxx{connect=fy-,clabel=Az-,ctaper=z+}"],
        ["xxx{connect=fz+,clabel=By-,ctaper=y+}|x{connect=mz+,clabel=Ay+,ctaper=y-}.."],
        ["x{connect=fy-,clabel=Ez-,ctaper=z+}xx{connect=fz+,clabel=Cy-,ctaper=y+}"],
        ["..x{connect=mz+,clabel=Ey+,ctaper=y-}|x{connect=fz+,clabel=Dy-,ctaper=y+}xx"],
        ["x{connect=fy-,clabel=Gz-,ctaper=z+}xx{connect=fz+,clabel=Fy-,ctaper=y+}"],
        ["..x{connect=mz+,clabel=Gy+,ctaper=y-}|x{connect=fz-,clabel=Hy-,ctaper=y+}xx"]
    ]);
    
}

// Corner color:

module color2() {
    
    burr_plate([
        ["x{connect=mz+,clabel=By-,ctaper=y+}"],
        ["x{connect=mz+,clabel=Dy-,ctaper=y+}"]
    ]);
    
}

// Edge color:

module color3() {
    
    burr_plate([
        ["x{connect=mz+,clabel=Cy-,ctaper=y+}"],
        ["x{connect=mz+,clabel=Fy-,ctaper=y+}"],
        ["x{connect=mz+,clabel=Hy-,ctaper=y+}"]
    ]);
    
}
