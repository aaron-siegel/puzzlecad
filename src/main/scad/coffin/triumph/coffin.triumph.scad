include <puzzlecad.scad>

$burr_scale = 27;
$burr_inset = 0.11;
$burr_bevel = 0.6;
$plate_width = 120;
$post_rotate = [0, 45, 0];
$post_translate = [-1/2, 0, -1/2];

*solid();
*color1();
*color2();
*diagonal_strut();

module solid() {
    
    burr_piece([
        "x{components={y+z+,z+y+,z+x+}}.|x{components={z+,y-z+,y+z+}}.|x{components={y-z+,z+y-,z+x+}}.",
        "x{components={z-y+,z-x+,x+z-}}x{components=x-z-}|x{components=z-}.|x{components={z-y-,z-x+,x+z-}}x{components=x-z-}"
    ]);
    
}

module color1() {

    burr_plate([
        ["x{components=y+z+,connect=dy+z+,clabel=A}.|x{components={z+,y-z+,y+z+}}.|x{components={y-z+,z+y-,z+x+}}.",
         "..|x{components=z-}.|x{components={z-y-,z-x+,x+z-}}x{components=x-z-}"],
        ["x{components={y+z+,z+y+,z+x+}}.|x{components={z+,y-z+,y+z+}}.|x{components=y-z+,connect=dy-z+,clabel=B}.",
         "x{components={z-y+,z-x+,x+z-}}x{components=x-z-}|x{components=z-}.|.."]
    ]);
    
}

module color2() {
    
    burr_plate([
        ["x{components={z+x+,z+y+},connect=dz+y+,clabel=A}.", "x{components={z-x+,z-y+,x+z-}}x{components=x-z-}"],
        ["x{components={z+x+,z+y-},connect=dz+y-,clabel=B}.", "x{components={z-x+,z-y-,x+z-}}x{components=x-z-}"]
    ]);
    
}
