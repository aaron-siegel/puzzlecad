include <puzzlecad.scad>

$burr_scale = 27;
$burr_inset = 0.12;
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

*bases();
*tips();

module bases() {
    
    burr_plate([
        base("A", "B"),
        base("A", "C"),
        base("A", "D"),
        base("B", "C"),
        base("B", "D"),
        base("C", "D")
    ]);
    
}

module tips() {
    
    burr_plate(repeat(3,
        ["x{components={z+x+,z+y-},connect=dfz+y-}.",
         "x{components={z-x+,z-y-,x+z-}}x{components=x-z-}"]
    ));
    
}

function base(label1, label2) =
    [ str_interpolate(
        "x{components=y+z+,connect=dmy+z+,clabel=$0}|x{components={z+,y-z+,y+z+}}|x{components=y-z+,connect=dmy-z+,clabel=$1}", [label1, label2]
    ), "..|x{components=z-}|.." ];
