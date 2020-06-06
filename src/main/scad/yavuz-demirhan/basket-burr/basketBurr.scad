include <puzzlecad.scad>

// Global settings
$burr_scale = 10;
$plate_width = 100;
$burr_inset = 0.05;
$burr_bevel = 1.0;
$unit_beveled = false;

*basket();
*holder();
*pieces();

module basket() {
    render(convexity = 2)
    burr_piece([
        "xxxxxx|xxxxxx|x....x|......|......|......",
        "xxxxxx|xxxx{connect=fy+z-,clabel=A}xx|x....x|......|......|......",
        "xxxxxx|......|......|......|......|......",
        "xxxxxx|......|......|......|......|......",
        "xxxxxx|xxx{connect=fy+z+,clabel=A}xxx|x....x|......|......|......",
        "xxxxxx|xxxxxx|x....x|......|......|......"
    ]); 
}

module holder() {
    burr_plate([[
        "......|......|......|......|......|......",
        "......|......|...x{connect=my-z-,clabel=A}..|...x..|..xx..|..xx..",
        "......|......|......|......|......|..x{connect=fz+y+,clabel=C}x{connect=mz+y+,clabel=B}.."
    ], [
        "......|......|......|......|......|......",
        "......|......|...x{connect=my-z-,clabel=A}..|...x..|..xx..|..xx..",
        "......|......|......|......|......|..x{connect=fz+y+,clabel=B}x{connect=mz+y+,clabel=C}.."
    ]]);
}

module pieces() {
    burr_plate([
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xxxxxx|xxxxxx", "x....x|x....x"],
        ["xx..xx|xxxxxx", "x....x|x....x"]
    ], $burr_bevel = 0.5, $burr_outer_x_bevel = 1.75);
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
