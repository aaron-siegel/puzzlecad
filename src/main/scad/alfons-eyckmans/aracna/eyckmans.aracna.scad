/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Alfons Eyckmans
  3D model (c) Tom Burns

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_scale = 9;
$burr_bevel = 0.5;
$auto_layout = true;

//print one copy each of spider() and sticks() below:

*spider();
*sticks();

module spider() {
  burr_piece(
    [".x..x.|......|......|x....x|......|.x..x.",
     ".x..x.|.xxxx.|..xx..|xxxxxx|.xxxx.|.x..x.",
     "......|......|......|..xx..|..xx..|......",]
  );
}

module sticks() {
 burr_plate([
    ["x......x|x.xx..xx|xxxxxxxx","x......x|x.....xx|xx..x.xx"],
    ["x......x|x.xx...x|xxxxxxxx","x......x|x......x|xx....xx"],
    ["x......x|x.x....x|xxxxxxxx","x......x|x......x|xx.xx.xx"],
    ["x......x|x.x....x|xxxxxxxx","x......x|x......x|xx...xxx"],
    ["x......x|x...xx.x|xxxxxxxx","x......x|x......x|xx....xx"],
    ["x......x|x...xx.x|xxxxxxxx","x......x|x......x|xx....xx"],
    ["x......x|x...x..x|xxxxxxxx","x......x|x......x|xx...xxx"],
    ["x......x|x....xxx|xxxxxxxx","x......x|x.....xx|xx....xx"],
    ["x......x|x....x.x|xxxxxxxx","x......x|x......x|xx...xxx"],
    ["x......x|x....x.x|xxxxxxxx","x......x|x......x|xx....xx"],
    ["x{label_text=Aracna,label_orient=x-y-,label_hoffset=0.5}......x|x......x|xxxxxxxx","x......x|x......x|xx.xx.xx"],
    ["x......x{label_text=Aracna,label_orient=x+y+,label_hoffset=-0.5}|x......x|xxxx{label_text=A. Eyckmans,label_orient=y-x+,label_hoffset=0.5}xxxx","x......x|x......x|xx.xx.xx"],
  ], $burr_outer_x_bevel=1.75);
}