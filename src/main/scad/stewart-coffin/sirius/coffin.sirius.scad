include <puzzlecad.scad>

$burr_scale = 32;
$burr_inset = 0.11;
$burr_bevel = 0.6;

*solid();
*multicolor();

module solid() {
    
    burr_piece([
        "x{components={y+z+,z+y+}}|x{components={z+,y-z+,y+z+}}|x{components={y-z+,z+y-}}",
        "x{components=z-y+}|x{components=z-}|x{components=z-y-}"
    ], $post_rotate = [0, 45, 0]);
    
}

module multicolor() {

    burr_plate([
        ["x{components=y+z+,connect=dfy+z+}|x{components={z+,y-z+,y+z+}}|x{components=y-z+,connect=dfy-z+}",
         "..|x{components=z-}|.."],
        ["x{components=y+z+}|x{components=y-z+,connect=dmy-z+}"],
        ["x{components=y+z+}|x{components=y-z+,connect=dmy-z+}"]
    ], $post_rotate = [0, 45, 0]);

    /*
    burr_plate([
        ["x{components=z+y+,connect=dmz+y+}", "x{components=z-y+}"],
        ["x{components=z+y+,connect=dmz+y+}", "x{components=z-y+}"]
    ], $post_rotate = [90, 0, 0]);
    */
}
