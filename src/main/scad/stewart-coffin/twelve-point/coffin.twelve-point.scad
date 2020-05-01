include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 27;
$burr_inset = 0.14;         // Use 0.12 for a tighter fit
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

// Uncomment one of the following lines to render that module.

*bases();
*tip();

module bases() {
    
    burr_plate([
    [
        ".x{components={z+y+,z+x-,y+z+}}.|x{components=x+y+}x{components={z+,x-y+,y+x-,y-z+,y+z+}}.|.x{components={z+y-,z+x+,y-x-,y-z+}}.|...",
         "x{components=x+z-}x{components={z-y+,z-x-,x-z-},connect=dfy+x+~,clabel=B}.|.x{components=z-}.|.x{components={z-y-,z-x+,x+z-}}x{components=x-z-}|...{connect=dfy-x-~,clabel=B}"
    ],
    [
        ".x{components={z+y+,z+x-,y+z+}}.|x{components=x+y+}x{components={z+,x-y+,y+x-,y-z+,y+z+}}.|.x{components={z+y-,z+x-,y-x-,z+x+,y-z+}}.|...",
         "x{components=x+z-}x{components={z-y+,z-x-,x-z-},connect=dfy+x+~,clabel=B}.|.x{components=z-}.|x{components=x+z-}x{components={z-y-,z-x-,z-x+,x-z-,x+z-}}x{components=x-z-}|...{connect=dfy-x-~,clabel=B}"
    ],
    [
        ".x{components={z+y+,z+x-,y+z+}}.|x{components=x+y+}x{components={z+,x-y+,y+x-,y-z+,y+z+}}.|.x{components={z+y-,z+x-,y-x-,z+x+,y-z+}}.|...",
         "x{components=x+z-}x{components={z-y+,z-x-,x-z-},connect=dfy+x+~,clabel=B}.|.x{components=z-}.{connect=dfx-z-~,clabel=A}|x{components=x+z-}x{components={z-y-,z-x-,z-x+,x-z-,x+z-}}x{components=x-z-}|...{connect=dfy-x-~,clabel=B}"
    ],
    [
        ".x{components={z+y+,z+x-,y+z+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+y-,z+x-,z+x+,y-z+}}.|...",
         "x{components=x+z-}x{components={z-y+,z-x-,x-z-},connect=dfy+x+~,clabel=B}.|.x{components=z-}.|x{components=x+z-}x{components={z-y-,z-x-,z-x+,x-z-,x+z-}}x{components=x-z-}|...{connect=dfy-x-~,clabel=B}"
    ],
    [
        ".x{components={z+y+,z+x-,z+x+,y+z+}}.|x{components=x+y+}x{components={z+,x-y+,y+x-,y-z+,y+z+}}.|.x{components={z+y-,z+x+,y-x-,y-z+}}.|...",
         "x{components=x+z-}x{components={z-y+,z-x-,z-x+,x-z-,x+z-},connect=dfy+x+~,clabel=B}x{components=x-z-}|.x{components=z-}.|.x{components={z-y-,z-x+,x+z-}}x{components=x-z-}|...{connect=dfy-x-~,clabel=B}"
    ],
    [
        ".x{components={z+y+,z+x-,z+x+,y+z+}}.|x{components=x+y+}x{components={z+,x-y+,y+x-,y-z+,y+z+}}.|.x{components={z+y-,z+x-,y-x-,z+x+,y-z+}}.|...",
         "x{components=x+z-}x{components={z-y+,z-x-,z-x+,x-z-,x+z-},connect=dfy+x+~,clabel=B}x{components=x-z-}|.x{components=z-}.|x{components=x+z-}x{components={z-y-,z-x-,z-x+,x-z-,x+z-}}x{components=x-z-}|...{connect=dfy-x-~,clabel=B}"
    ],
    ["x{components={y+x-,y+z+},connect=dmy+x-,clabel=A}|x{components={y-x-,y-z+}}"]
    ], $plate_width = 200);
    
}

module tip() {
    
    burr_piece("x{components={y+x-,y+z+},connect=dmy+z+,clabel=B}|x{components={y-x-,y-z+}}");
    
}
