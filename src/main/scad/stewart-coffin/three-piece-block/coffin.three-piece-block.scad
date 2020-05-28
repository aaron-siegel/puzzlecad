include <puzzlecad.scad>

// The effective scale is 20 mm, but we use 10 because we need to be able
// to join along half- and quarter-faces.
$burr_scale = 10;
$burr_bevel = 1.3;

burr_plate([
    ["..bb|aabb{connect=fx+z+,clabel=A}|aa..", "..bb|aabb|aa.."],
    ["xx|xx", "xx|xx{connect=mz+y+,clabel=A}"],
    ["xx|xx", "x{connect=fx-z+,clabel=B}x|xx{connect=fy+z+,clabel=C}"],
    ["xx|xx", "xx|x{connect=mz+y-,clabel=B}x"],
    ["xx|xx", "xx|xx{connect=mz+y-,clabel=C}"],
    ["..bb|aabb|aa..", "..bb|aabb{connect=fx+z+,clabel=D}|a{connect=fy+z+,clabel=E}a{connect=fy+z+,clabel=E}.."],
    ["xx|xx", "xx|x{connect=mz+y-,clabel=D}x"],
    ["xx|xx", "xx|x{connect=mz+y-,clabel=E}x{connect=mz+y-,clabel=E}"],
]);
