include <puzzlecad.scad>

$burr_scale = 16;
$burr_inset = 0.06;
$burr_bevel = 1;

burr_plate([
    ["aa..|a{connect=mz+x-,clabel=A}abb|..bb"],
    ["x{connect=fx-z+,clabel=A}x|xx"],
    ["a{connect=mz+x-,clabel=B}a..|aabb", "....|..bb"],
    ["xx|x{connect=fx-z+,clabel=B}x"],
    ["xx|x{connect=mz+y+,clabel=C}x"],
    ["a..|abb{connect=fz-y+,clabel=C}|.bb", "a..|a..|..."],
    ["..aa|..a{label_text=Cube-16,label_orient=z+y-,label_hoffset=-0.5}a|bcc.|bcc.", "...d|...d|b...|b...", "...d|...d|....|...."],
    ["a..c|ab{label_text=#205,label_orient=z+x+,label_hoffset=0.5,label_voffset=0.1}bc|.b{label_text=STC,label_orient=z+x+,label_hoffset=0.5,label_voffset=-0.1}b.", "a..c|a..c|...."]
]);
