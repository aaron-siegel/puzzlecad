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

$burr_scale = 27;
$burr_inset = 0.11;     // Use 0.08 for a tighter fit
$burr_bevel = 0;
$post_rotate = [0, 45, 0];
$plate_width = 160;

*pieces();

module pieces() {

    burr_plate([
        ["x{components={y+z+,z+y+,z+x+}}.|x{components={z+,y-z+,y+z+}}.|x{components={y-z+,z+y-,z+x+}}.",
         "x{components={z-y+,z-x+,x+z-,x+y-,x+z+,z+x+,z+y-}}x{components={x-z-,x-y-,x-z+}}|x{components=z-}.|x{components={z-y-,z-x+,x+z-}}x{components=x-z-}",
         "x{components={z-x+,z-y-}}.|..|.."], // 1
        [".x{components={z+,y+z+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
         "x{components={x+z-,x+y-}}x{components={z-,x-z-,x+z-,x-y-}}x{components=x-z-}|.x{components=z-}.|.x{components={z-y-,z-x+,x+z-,x+y+,x+z+,z+x+,z+y+}}x{components={x-z-,x-y+,x-z+}}",
         "...|...|.x{components={z-x+,z-y+}}."], // 2
        [".x{components={z+,y+z+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
         "x{components={x+z-,x+y-}}x{components={z-,x-z-,x+z-,x-y-}}x{components=x-z-}|.x{components=z-}.|.x{components={z-y-,z-x+,x+z-}}x{components=x-z-}"], // 3
        ["x{components={y+z+,z+y+,z+x+}}.|x{components={z+,y-z+,y+z+}}.|x{components={y-z+,z+y-,z+x+}}.",
         "x{components={z-y+,z-x+,x+z-}}x{components=x-z-}|x{components=z-}.|x{components={z-y-,z-x+,x+z-,x+y+,x+z+,z+x+,z+y+}}x{components={x-z-,x-y+,x-z+}}",
         "..|..|x{components={z-x+,z-y+}}."], // 4
        ["x{components={y+z+,z+y+,z+x+}}.|x{components={z+,y-z+,y+z+}}.|x{components={y-z+,z+y-,z+x+}}.",
         "x{components={z-y+,z-x+,x+z-}}x{components=x-z-}|x{components=z-}.|x{components={z-y-,z-x+,x+z-}}x{components=x-z-}"], // 5
        [".x{components={y+z+,z+y+,z+x+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+,y-z+}}.",
         ".x{components={z-y+,z-x+,x+z-}}x{components=x-z-}|.x{components=z-}.|x{components={x+z-,x+y+}}x{components={z-,x-z-,x+z-,x-y+}}x{components=x-z-}"], // 6
    ]);
    
}
