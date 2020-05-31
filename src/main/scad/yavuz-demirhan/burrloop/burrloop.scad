include <puzzlecad.scad>

$burr_scale = 9;
$plate_width = 120;
$burr_inset = 0.05;
$joint_inset = 0.08;
$burr_bevel = 1;
$unit_beveled = false;

*frame();
*pieces();

module frame() {
    render(convexity = 2)
    burr_plate([
        ["x{connect=mx-}xxxx|x{connect=mx-}xxxx|...xx|...x{connect=fz+}x{connect=fz+}"],
        ["xxxxx{connect=mx+}|xxxxx{connect=mx+}|xx...|x{connect=fz+}x{connect=fz+}..."],
            ["x{connect=mx-}xxxx|x{connect=mx-}xxxx|...xx|...x{connect=fz+}x{connect=fz+}"],
        ["xxxxx{connect=mx+}|xxxxx{connect=mx+}|xx...|x{connect=fz+}x{connect=fz+}..."],
            ["x{connect=mx-}xxxx|x{connect=mx-}xxxx|...xx|...x{connect=fz+}x{connect=fz+}"],
        ["xxxxx{connect=mx+}|xxxxx{connect=mx+}|xx...|x{connect=fz+}x{connect=fz+}..."]
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
    ]);
}
