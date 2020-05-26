include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 12;
$burr_inset = 0.07;

*frame();
*pieces();

module frame() {
    
    burr_plate([
        [ "xxxx|x.xx|x.xx|xxxx",
          "x.xx|....|....|x..x",
          "x..x{connect=fy+z+,clabel=B}|....|....|x..x",
          "x{connect=fz+y+,clabel=A}..x{connect=fz+y+,clabel=A}|....|....|x{connect=fz+y+,clabel=A}..x{connect=fz+y+,clabel=A}" ],
        [ "x{connect=mz+y+,clabel=A}xxx{connect=mz+y+,clabel=A}|x.xx|x.xx|x{connect=mz+y+,clabel=A}xxx{connect=mz+y+,clabel=A}" ]
    ], $burr_outer_z_bevel = [2, 0.5]);
    
    translate([0, 4 * $burr_scale + $plate_sep, 0])
    burr_piece("x{connect=mz+y+,clabel=B}");
    
}

module pieces() {
    
    burr_plate([
        [ "x...|x..x{connect=mz+y+,clabel=C}|xxxx{connect=mz+y+,clabel=C}",
          "x...|....|x..." ],
        [ "x|x{connect=fz+y+,clabel=C}|x{connect=fz+y+,clabel=C}" ],
        [ "x...|xxxx{connect=mz+y+,clabel=D}|x...",
          "....|x...|...." ],
        [ "x|x{connect=fz+y+,clabel=D}|x" ],
    ]);
    
}
