include <puzzlecad.scad>

$burr_scale = 32;
$burr_inset = 0.13;     // Use 0.11 for a tighter fit
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

*bases();
*tips();

module bases() {

    burr_plate([
        [".x{components=y+z+,connect=dmy+z+,clabel=A}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+,y-z+}}.",
         "...|.x{components=z-}.|x{components=x+z-}x{components={z-,x-z-,x+z-}}x{components=x-z-}"],
        [".x{components={z+,y+z+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components=y-z+,connect=dmy-z+,clabel=B}.",
         "x{components=x+z-}x{components={z-,x-z-,x+z-}}x{components=x-z-}|.x{components=z-}.|..."]
    ]);
    
}

module tips() {
    
    burr_plate([
        ["x{components={z+x+,z+y+},connect=dfz+y+,clabel=A}.", "x{components={z-x+,z-y+,x+z-}}x{components=x-z-}"],
        ["x{components={z+x+,z+y-},connect=dfz+y-,clabel=B}.", "x{components={z-x+,z-y-,x+z-}}x{components=x-z-}"]
    ]);
    
}
