include <puzzlecad.scad>

$burr_scale = 32;
$burr_inset = 0.12;
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

*solid();
*multicolor();

module solid() {
    
    burr_piece([
        "x{components={y+z+,z+y+}}|x{components={z+,y-z+,y+z+}}|x{components={y-z+,z+y-}}",
        "x{components=z-y+}|x{components=z-}|x{components=z-y-}"
    ]);
    
}

module multicolor() {

    burr_plate([
        ["x{components=y+z+,connect=dfy+z+}|x{components={z+,y-z+,y+z+}}|x{components=y-z+,connect=dfy-z+}",
         "..|x{components=z-}|.."],
        ["x{components=y+z+}|x{components=y-z+,connect=dmy-z+}"],
        ["x{components=y+z+}|x{components=y-z+,connect=dmy-z+}"]
    ]);

}
