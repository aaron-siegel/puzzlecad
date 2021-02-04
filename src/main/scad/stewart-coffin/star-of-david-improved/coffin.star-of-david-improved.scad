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
$burr_inset = 0.13;     // Use 0.11 for a tighter fit
$burr_bevel = 0;
$post_rotate = [0, 45, 0];
$plate_width = 160;

*pieces_1();
*pieces_2();

module pieces_1() {
    burr_plate([
        [".x{components=y+z+,connect=dmy+z+,clabel=A}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+,y-z+}}.",
         "...|.x{components=z-}.|x{components={x+z-,x+y+}}x{components={z-,x-z-,x+z-,x-y+}}x{components=x-z-}"],
        [".x{components=y+z+,connect=dmy+z+,clabel=A}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+,y-z+}}.",
         "...|.x{components=z-}.|x{components={x+z-,x+y+}}x{components={z-,x-z-,x+z-,x-y+}}x{components=x-z-}"],
        [".x{components=y+z+,connect=dmy+z+,clabel=A}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+,y-z+}}.",
         "...|.x{components=z-}.|x{components={x+z-,x+y+}}x{components={z-,x-z-,x+z-,x-y+}}x{components=x-z-}"],
        ["x{components={z+x+,z+y-},connect=dfz+y-,clabel=B}.", "x{components={z-x+,z-y-,x+z-}}x{components=x-z-}"],
        ["x{components={z+x+,z+y-},connect=dfz+y-,clabel=B}.", "x{components={z-x+,z-y-,x+z-}}x{components=x-z-}"],
        ["x{components={z+x+,z+y-},connect=dfz+y-,clabel=B}.", "x{components={z-x+,z-y-,x+z-}}x{components=x-z-}"]
    ]);
}

module pieces_2() {
    burr_plate([
        [".x{components={z+,y+z+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components=y-z+,connect=dmy-z+,clabel=B}.",
         "x{components={x+z-,x+y-}}x{components={z-,x-z-,x+z-,x-y-}}x{components=x-z-}|.x{components=z-}.|..."],
        [".x{components={z+,y+z+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components=y-z+,connect=dmy-z+,clabel=B}.",
         "x{components={x+z-,x+y-}}x{components={z-,x-z-,x+z-,x-y-}}x{components=x-z-}|.x{components=z-}.|..."],
        [".x{components={z+x+,z+y-,z+y+,y+z+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components=y-z+,connect=dmy-z+,clabel=B}.",
         ".x{components={z-x+,z-y-,z-y+,x+z-}}x{components=x-z-}|.x{components=z-}.|..."],
        ["x{components={z+x+,z+y+},connect=dfz+y+,clabel=A}.", "x{components={z-x+,z-y+,x+z-}}x{components=x-z-}"],
        ["x{components={z+x+,z+y+},connect=dfz+y+,clabel=A}.", "x{components={z-x+,z-y+,x+z-}}x{components=x-z-}"],
        ["x{components={z+x+,z+y+},connect=dfz+y+,clabel=A}.",
         "x{components={z-y+,z-x+,x+z-,x+y-,z+x+,x+z+}}x{components={x-z-,x-y-,x-z+}}", "x{components={z-x+}}."]
    ]);
}

// Solid, monochrome pieces

module pieces_solid() {

    burr_plate([
        [".x{components={y+z+,z+y+,z+x+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+,y-z+}}.",
         ".x{components={z-y+,z-x+,x+z-}}x{components=x-z-}|.x{components=z-}.|x{components={x+z-,x+y+}}x{components={z-,x-z-,x+z-,x-y+}}x{components=x-z-}"],
        [".x{components={y+z+,z+y+,z+x+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+,y-z+}}.",
         ".x{components={z-y+,z-x+,x+z-}}x{components=x-z-}|.x{components=z-}.|x{components={x+z-,x+y+}}x{components={z-,x-z-,x+z-,x-y+}}x{components=x-z-}"],
        [".x{components={z+,y+z+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
         "x{components={x+z-,x+y-}}x{components={z-,x-z-,x+z-,x-y-}}x{components=x-z-}|.x{components=z-}.|.x{components={z-y-,z-x+,x+z-}}x{components=x-z-}"],
        [".x{components={z+,y+z+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
         "x{components={x+z-,x+y-}}x{components={z-,x-z-,x+z-,x-y-}}x{components=x-z-}|.x{components=z-}.|.x{components={z-y-,z-x+,x+z-}}x{components=x-z-}"],
        [".x{components={z+x+,z+y-,z+y+,y+z+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
         ".x{components={z-x+,z-y-,z-y+,x+z-}}x{components=x-z-}|.x{components=z-}.|.x{components={z-y-,z-x+,x+z-}}x{components=x-z-}"],
        [".x{components={y+z+,z+y+,z+x+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+,y-z+}}.",
         ".x{components={z-y+,z-x+,x+z-,x+y-,z+x+,x+z+}}x{components={x-z-,x-y-,x-z+}}|.x{components=z-}.|x{components={x+z-,x+y+}}x{components={z-,x-z-,x+z-,x-y+}}x{components=x-z-}",
         ".x{components={z-x+}}.|...|..."],
    ]);
    
}

// Basic triumph companion shape, for reference:

// [".x{components={y+z+,z+y+,z+x+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+,y-z+}}.",
//  ".x{components={z-y+,z-x+,x+z-}}x{components=x-z-}|.x{components=z-}.|x{components=x+z-}x{components={z-,x-z-,x+z-}}x{components=x-z-}"]
