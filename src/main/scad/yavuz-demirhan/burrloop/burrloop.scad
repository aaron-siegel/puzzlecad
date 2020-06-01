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
        ["x{connect=mx-z-}xxxx|x{connect=mx-z-}xxxx|...xx|...x{connect=fz+y+}x{connect=fz+y+}"],
        ["xxxxx{connect=mx+z-}|xxxxx{connect=mx+z-}|xx...|x{connect=fz+y+}x{connect=fz+y+}..."],
        ["x{connect=mx-z-}xxxx|x{connect=mx-z-}xxxx|...xx|...x{connect=fz+y+}x{connect=fz+y+}"],
        ["xxxxx{connect=mx+z-}|xxxxx{connect=mx+z-}|xx...|x{connect=fz+y+}x{connect=fz+y+}..."],
        ["x{connect=mx-z-}xxxx|x{connect=mx-z-}xxxx|...xx|...x{connect=fz+y+}x{connect=fz+y+}"],
        ["xxxxx{connect=mx+z-}|xxxxx{connect=mx+z-}|xx...|x{connect=fz+y+}x{connect=fz+y+}..."],
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
