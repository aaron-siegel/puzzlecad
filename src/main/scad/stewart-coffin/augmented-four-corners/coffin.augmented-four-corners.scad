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
$burr_bevel = 0.6;
$plate_width = 160;

*pieces();
*tips();

module pieces() {
    
    burr_plate([
        [".x{components={y+z+,z+y+,z+x+,x+z+}}x{components=x-z+}|.x{components={z+,y-z+,y+z+}}.|x{components=x+z+}x{components={y-z+,z+y-,z+x-,x-z+}}.",
         ".x{components={z-y+,z-x+}}|.x{components=z-}.|.x{components={z-y-,z-x-},connect=dfx+z-~,clabel=A}."],
        [".x{components={y+z+,z+y+,z+x+,x+z+}}x{components=x-z+}|.x{components={z+,y-z+,y+z+}}.|x{components=x+z+,connect=dfx+z+,clabel=B}x{components={y-z+,z+y-,z+x-,x-z+}}.",
         ".x{components={z-y+,z-x+}}|.x{components=z-}.|.x{components={z-y-,z-x-}}."],
        [".x{components={y+z+,z+y+,z+x+,x+z+}}x{components=x-z+}|.x{components={z+,y-z+,y+z+}}.|x{components=x+z+,connect=dfx+z+,clabel=B}x{components={y-z+,z+y-,z+x-,x-z+}}.",
         ".x{components={z-y+,z-x+}}|.x{components=z-}.|.x{components={z-y-,z-x-},connect=dfx+z-~,clabel=A}."],
        [".x{components={y+z+,z+y+,z+x+,x+z+}}x{components=x-z+,connect=dfx-z+,clabel=B}|.x{components={z+,y-z+,y+z+}}.|x{components=x+z+}x{components={y-z+,z+y-,z+x-,x-z+}}.",
         ".x{components={z-y+,z-x+}}|.x{components=z-}.|.x{components={z-y-,z-x-},connect=dfx+z-~,clabel=A}."],
        [".x{components={y+z+,z+y+,z+x+,x+z+}}x{components=x-z+}|.x{components={z+,y-z+,y+z+}}.|x{components=x+z+,connect=dfx+z+,clabel=B}x{components={y-z+,z+y-,z+x-,x-z+}}.",
         ".x{components={z-y+,z-x+}}|.x{components=z-}x{components={},connect=dfx-z-~,clabel=A}|.x{components={z-y-,z-x-},connect=dfx+z-~,clabel=A}."],
        [".x{components={y+z+,z+y+,z+x+,x+z+}}x{components=x-z+,connect=dfx-z+,clabel=B}|.x{components={z+,y-z+,y+z+}}.|x{components=x+z+,connect=dfx+z+,clabel=B}x{components={y-z+,z+y-,z+x-,x-z+}}.",
         ".x{components={z-y+,z-x+}}|.x{components=z-}.|.x{components={z-y-,z-x-},connect=dfx+z-~,clabel=A}."]
    ], $post_rotate = [0, 135, 0]);
    
}

module tips() {
    
    burr_plate([
        ["x{components={y+z+,y+x-},connect=dmy+z+,clabel=A}|x{components={y-z+,y-x-}}"],
        ["x{components={y+z+},connect=dmy+z+,clabel=B}|x{components={y-z+,z+y-}}", ".|x{components=z-y-}"]
    ], num_copies = 6, $post_rotate = [0, 45, 0]);
    
}
