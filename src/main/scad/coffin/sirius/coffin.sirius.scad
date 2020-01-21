include <puzzlecad.scad>

$burr_scale = 32;
$burr_inset = 0.11;
$burr_bevel = 0.6;

*solid();
*multicolor();
*diagonal_strut();

module solid() {
    
    burr_piece([
        "x{components={y+z+,z+y+}}|x{components={z+,y-z+,y+z+}}|x{components={y-z+,z+y-}}",
        "x{components=z-y+}|x{components=z-}|x{components=z-y-}"
    ], $post_rotate = [0, 45, 0], $post_translate = [-1/2, 0, -1/2]);
    
}

module multicolor() {

    burr_piece([
        "x{components=y+z+,connect=dy+z+}|x{components={z+,y-z+,y+z+}}|x{components=y-z+,connect=dy-z+}",
        "..|x{components=z-}|.."
    ], $post_rotate = [0, 45, 0], $post_translate = [-1/2, 0, -1/2]);
    
    burr_piece([
        "x{components=z+y+,connect=dz+y+}", "x{components=z-y+}"
    ], $post_rotate = [-45, 0, 0], $post_translate = [1, 0, -1/2]);

    burr_piece([
        "x{components=z+y+,connect=dz+y+}", "x{components=z-y+}"
    ], $post_rotate = [-45, 0, 0], $post_translate = [1, 1, -1/2]);
    
}
