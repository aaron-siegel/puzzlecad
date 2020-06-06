include <puzzlecad.scad>

$burr_scale = 9;
$plate_width = 120;
$burr_inset = 0.05;
$burr_bevel = 1.0;
$unit_beveled = false;

*frame();
*pieces();

module frame() {
    render(convexity = 2)
    burr_plate([
    ["x{connect=mx-z-,clabel=A}xxxx|x{connect=mx-z-,clabel=A}xxxx|...xx|...x{connect=fz+y+,clabel=B}x{connect=fz+y+,clabel=B}"],
    ["xxxxx{connect=mx+z-,clabel=B}|xxxxx{connect=mx+z-,clabel=B}|xx...|x{connect=fz+y+,clabel=A}x{connect=fz+y+,clabel=A}..."],
    ["x{connect=mx-z-,clabel=A}xxxx|x{connect=mx-z-,clabel=A}xxxx|...xx|...x{connect=fz+y+,clabel=B}x{connect=fz+y+,clabel=B}"],
    ["xxxxx{connect=mx+z-,clabel=B}|xxxxx{connect=mx+z-,clabel=B}|xx...|x{connect=fz+y+,clabel=A}x{connect=fz+y+,clabel=A}..."],
    ["x{connect=mx-z-,clabel=A}xxxx|x{connect=mx-z-,clabel=A}xxxx|...xx|...x{connect=fz+y+,clabel=B}x{connect=fz+y+,clabel=B}"],
    ["xxxxx{connect=mx+z-,clabel=B}|xxxxx{connect=mx+z-,clabel=B}|xx...|x{connect=fz+y+,clabel=A}x{connect=fz+y+,clabel=A}..."],
    ]);
}

module pieces() {
    burr_plate([
        ["xxxxxx|xxxxxx", "xxx..x|xxx..x"],
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xx..xx|xxxxxx", "x....x|x....x"],
        ["xx..xx|xxxxxx", "x....x|x....x"]
    ], $burr_bevel = 0.5, $burr_outer_x_bevel = 1.75);
}
