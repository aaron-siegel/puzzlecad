include <puzzlecad.scad>

$burr_scale = 32;
$burr_inset = 0.11;
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

burr_plate([
    ["x{components=y+z+,connect=dfy+z+}|x{components={z+,y-z+,y+z+}}|x{components=y-z+,connect=dfy-z+}",
     "..|x{components=z-}|.."],
    ["x{components=y+z+}|x{components=y-z+,connect=dmy-z+}"],
    ["x{components=y+z+}|x{components=y-z+,connect=dmy-z+}"]
]);
