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
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_scale = 27;
$burr_inset = 0.12;         // Use 0.11 for a tighter fit
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

burr_plate([
    
    [".x{components={z+y+,z+x+,y+z+,y+x-}}.|x{components={x+y-,x+z-}}x{components={z+,y-z+,y-x-,x-y-,x-z-},connect=dfz+y+}.",
     ".x{components={z-y+,z-x+,x+z-,x+y-}}x{components={x-z-,x-y-}}|.x{components=z-}."],
     
    [".x{components={z+y+,z+x+,y+z+,y+x-}}.|x{components={x+y-,x+z-}}x{components={y-z+,y-x-,x-y-,x-z-},connect=dmy-z+}.",
     ".x{components={z-y+,z-x+,x+z-,x+y-}}x{components={x-z-,x-y-}}|..."]

]);
