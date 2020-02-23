include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 27;
$burr_inset = 0.14;     // Use 0.12 for a tighter fit
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

// Uncomment one of the following lines to render that module.

*base();
*tip();

module base() {
    
    burr_piece([
        ".x{components={z+,y+z+},connect=dfz+y-}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+,y-z+},connect=dfz+y+}.",
         "x{components=x+z-}x{components={z-,x-z-,x+z-}}x{components=x-z-}|.x{components=z-}.|x{components=x+z-}x{components={z-,x-z-,x+z-}}x{components=x-z-}"
    ]);
    
}

module tip() {
    
    burr_piece("x{components=y+z+}|x{components=y-z+,connect=dmy-z+}");
    
}
