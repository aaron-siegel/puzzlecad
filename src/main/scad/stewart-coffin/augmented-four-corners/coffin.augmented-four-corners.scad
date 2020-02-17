include <puzzlecad.scad>

$burr_scale = 27;
$burr_inset = 0;//0.11;
$burr_bevel = 0;//0.6;
$post_rotate = [0, 135, 0];

color1();
*color2();

module color1() {
    
    burr_plate([
        [".x{components={y+z+,z+y+,z+x+,x+z+}}x{components=x-z+}|.x{components={z+,y-z+,y+z+}}.|x{components=x+z+}x{components={y-z+,z+y-,z+x-,x-z+}}.",
         ".x{components={z-y+,z-x+}}|.x{components=z-}x{components=,connect=dfx-z-~,clabel=B}|.x{components={z-y-,z-x-},connect=dfx+z-~,clabel=B}."]
    ], $post_translate = [-sqrt(1/2), 0, sqrt(1/2)]);
    
}
