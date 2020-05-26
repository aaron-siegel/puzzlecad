include <puzzlecad.scad>

// The effective scale is 17 mm, but we use 8.5 because we need to be able
// to join along half- and quarter-faces.
$burr_scale = 8.5;
$burr_bevel = 1.2;
$plate_width = 120;

burr_plate([
    ["....cc|..bbcc|aabb..|aa{connect=fy+z+,clabel=A}....", "....cc|..bbc{connect=fy+z+,clabel=B}c{connect=fy+z+,clabel=B}|aabb..|aa...."],
    ["xx|xx", "xx|x{connect=mz+y+,clabel=A}x"],
    ["xx|xx", "xx|x{connect=mz+y-,clabel=B}x{connect=mz+y-,clabel=B}"],
    ["....cc|..bbcc|a{connect=fy-z+,clabel=C}abb..|aa....", "....cc|..bbcc|aabb..|aa...."],
    ["xx|xx", "xx|x{connect=mz+y+,clabel=C}x"],
    ["aa..|aabb|..bb", "aa..|a{connect=fy+z+,clabel=D}a{connect=mz+y+,clabel=E}b{connect=mz+y+,clabel=E}b|..b{connect=mz+y+,clabel=E}b"],
    ["x{connect=fz-y+,clabel=E}x{connect=fz-y+,clabel=E}|xx{connect=fz-y+,clabel=E}", "xx|xx"],
    ["xx|xx{connect=fx+z+,clabel=F}", "xx|x{connect=mz+y-,clabel=D}x"],
    ["xx|xx", "xx|xx{connect=mz+y+,clabel=F}"],
    ["xx|xx", "xx|xx{connect=mz+y+,clabel=G}"],
    ["x{connect=fz-y+,clabel=G}x|xx", "xx|xx"]
]);
