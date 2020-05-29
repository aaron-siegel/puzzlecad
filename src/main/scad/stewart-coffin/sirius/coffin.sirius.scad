/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Stewart Coffin
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 32;
$burr_inset = 0.12;     // Use 0.10 for a tighter fit
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

burr_plate([
    ["x{components=y+z+,connect=dfy+z+}|x{components={z+,y-z+,y+z+}}|x{components=y-z+,connect=dfy-z+}",
     "..|x{components=z-}|.."],
    ["x{components=y+z+}|x{components=y-z+,connect=dmy-z+}"],
    ["x{components=y+z+}|x{components=y-z+,connect=dmy-z+}"]
]);
