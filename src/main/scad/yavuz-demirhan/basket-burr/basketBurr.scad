include <puzzlecad.scad>

// Global settings
$burr_scale = 10;
$plate_width = 100;
$burr_inset = 0.05;
$joint_inset = 0.08;
$burr_bevel = 1.0;
$unit_beveled = false;

*basket();
*holder();
*pieces();

module basket() {
    render(convexity = 2)
    burr_piece([
        "xxxxxx|xxxxxx|x....x|......|......|......",
        "xxxxxx|xxxx{connect=fy+}xx|x....x|......|......|......",
        "xxxxxx|......|......|......|......|......",
        "xxxxxx|......|......|......|......|......",
        "xxxxxx|xxx{connect=fy+}xxx|x....x|......|......|......",
        "xxxxxx|xxxxxx|x....x|......|......|......"
    ]); 
}

module holder() {
    burr_plate([[
        "......|......|......|......|......|......",
        "......|......|...x{connect=my-}..|...x..|..xx..|..xx..",
        "......|......|......|......|......|..x{connect=fz+}x{connect=mz+}.."
    ], [
        "......|......|......|......|......|......",
        "......|......|...x{connect=my-}..|...x..|..xx..|..xx..",
        "......|......|......|......|......|..x{connect=fz+}x{connect=mz+}.."
    ]]);
}

module pieces() {
    burr_plate([
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xx..xx|xxxxxx", "x....x|x....x"]
    ]);
}

module holder_single() {
    burr_plate([[
        "......|......|......|......|......|......",
        "......|......|...x{connect=my-}..|...x..|..xx..|..xx..",
        "......|......|......|......|......|..xx..",
        "......|......|......|......|......|..xx..",
        "......|......|..x{connect=my-}...|..x...|..xx..|..xx..",
        "......|......|......|......|......|......"]
    ]);  
}
