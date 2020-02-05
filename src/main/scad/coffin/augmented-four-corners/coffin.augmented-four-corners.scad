include <puzzlecad.scad>

$burr_scale = 27;
$burr_inset = 0;//0.11;
$burr_bevel = 0;//0.6;
$post_rotate = [0, 180, 0];

color1();
*color2();

module color1() {
    
    burr_piece([
        "x{components={y+z+,z+y+}}|x{components={z+,y-z+,y+z+}}|x{components={y-z+,z+y-}}",
        "x{components=z-y+}|x{components=z-}|x{components=z-y-}"
    ], $post_translate = [-sqrt(1/2), 0, sqrt(1/2)]);
    
}
