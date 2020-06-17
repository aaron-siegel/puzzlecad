include <puzzlecad.scad>

$burr_scale = 12;
$plate_width = 150;
$burr_inset = 0.05;
$burr_bevel = 1;
$unit_beveled = false;

*frame();
*pieces_color1();
*pieces_color2();

module frame() {
   render(convexity = 2)
   burr_plate([
       ["xxx{connect=mz+y-,clabel=A}|x..|x{connect=fx-z-,clabel=B}.."],
       ["..x{connect=mz+x+,clabel=B}|..x|x{connect=fy+z-,clabel=A}xx"],
       ["xxx{connect=mz+y-,clabel=A}|x..|x{connect=fx-z-,clabel=B}.."],
       ["..x{connect=mz+x+,clabel=B}|..x|x{connect=fy+z-,clabel=A}xx"],
       ["xxx{connect=mz+y-,clabel=A}|x..|x{connect=fx-z-,clabel=B}.."],
       ["..x{connect=mz+x+,clabel=B}|..x|x{connect=fy+z-,clabel=A}xx"]
   ], $plate_width = 100);
}


module pieces_color1() {
   render(convexity = 2)
   burr_plate([
      ["x..xxx|xxxxxx|....xx", "x....x|x....x|.....x"],
      ["xxxxxx|x...xx|....xx", "x..x.x|x....x|.....x"],
      ["xx...|xx...|xxxxx{connect=mz+x+,clabel=C}", "xx...|xx...|x...."],
      ["x{connect=fz+x+,clabel=C}x|xx", ".x|.x"]
   ]);
}

module pieces_color2() {
   render(convexity = 2)
   burr_plate([
      ["xxxxxx|xx...x|xx....", "x.x..x|x....x|x....."],
      ["xxxxxx|xxx..x|xx....", "x....x|x....x|x....."],
      ["xxxxxx|xxxxxx|xxx...", "x....x|x....x|x....."]
   ]);
}