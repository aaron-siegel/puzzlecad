/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Christoph Lohe
  3D model (c) Yu Chih Chang & Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 11.15;
$plate_width = 150;
$burr_inset = 0.07;     // Use 0.05 for a tighter fit
$burr_bevel = 1;

*frame_components_1();
*frame_components_2();
*pieces_color_1();
*pieces_color_2();

module frame_components_1() {
   render(convexity = 2)
   burr_plate([
       ["xxx{connect=mz+y+,clabel=A}|x..|x{connect=fx-z+,clabel=B}.."]
   ], num_copies = 3, $plate_width = 100);
}

module frame_components_2() {
   render(convexity = 2)
   burr_plate([
       ["..x{connect=mz+x-,clabel=B}|..x|x{connect=fy+z+,clabel=A}xx"]
   ], num_copies = 3, $plate_width = 100);
}

module pieces_color_1() {
   render(convexity = 2)
   burr_plate([
      ["xxxxxx|xx...x|xx....", "x.x..x|x....x|x....."],
      ["xxxxxx|xxx..x|xx....", "x....x|x....x|x....."],
      ["xxx{label_text=Christoph Lohe,label_orient=z+x+,label_hoffset=0.5,label_voffset=0.15,label_scale=0.35}xxx|xxx{label_text=Corsage,label_orient=z+x+,label_hoffset=0.5,label_voffset=-0.15}xxx|xxx...", "x....x|x....x|x....."]
   ]);
}

module pieces_color_2() {
   render(convexity = 2)
   burr_plate([
      ["x..xxx|xxxxxx|....xx", "x....x|x....x|.....x"],
      ["xxxxxx|x...xx|....xx", "x..x.x|x....x|.....x"],
      ["xx...|xx...|xxxxx{connect=mz+x+,clabel=C}", "xx...|xx...|x...."],
      ["x{connect=fz+x+,clabel=C}x|xx", ".x|.x"]
   ]);
}
