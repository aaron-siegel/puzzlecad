include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_scale = 27;
$burr_bevel = 0;
$burr_inset = 0;
$post_rotate = [0, 45, 0];

burr_plate([
    
    [".x{components={z+y+,z+x+,y+z+,y+x-}}.|x{components={x+y-,x+z-}}x{components={z+,y-z+,y-x-,x-y-,x-z-},connect=dfz+y+}.",
     ".x{components={z-y+,z-x+,x+z-,x+y-}}x{components={x-z-,x-y-}}|.x{components=z-}."],
     
    [".x{components={z+y+,z+x+,y+z+,y+x-}}.|x{components={x+y-,x+z-}}x{components={y-z+,y-x-,x-y-,x-z-},connect=dmy-z+}.",
     ".x{components={z-y+,z-x+,x+z-,x+y-}}x{components={x-z-,x-y-}}|..."]

]);
