include <puzzlecad.scad>

$burr_scale = 27;
$burr_inset = 0.11;
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

*solid();
*color1();
*color2();
*color3();
*color4();
*color5();
*diagonal_strut();

module solid() {
    
    burr_piece([
        ".x{components={y+z+,z+y+,z+x-}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
        "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}.|.x{components={z-y-,x+z-,z-x+}}x{components=x-z-}"
    ], $post_translate = [-(sqrt(2)+1)/2, 0, (sqrt(2)-1)/2]);
    
}

module color1() {
    
    burr_plate([
        base("A", "B"),
        base("A", "C"),
        base("A", "D"),
        base("B", "C"),
        base("B", "D"),
        base("C", "D")
    ], $post_translate = [-1/2, 0, -1/2], $plate_width = $burr_scale * 4);
    
}

module color2() {
    
    tip_color("A");
    
}

module color3() {
    
    tip_color("B");
    
}

module color4() {
    
    tip_color("C");
    
}

module color5() {
    
    tip_color("D");
    
}

module tip_color(label) {
    
    burr_plate([tip(label), tip(label), tip(label)], $post_translate = [-1/2, 0, -1/2], $plate_width = $burr_scale * 3);
    
}

function base(label1, label2) =
    [ str(
        "x{components=y+z+,connect=dy+z+,clabel=",
        label1,
        "}|x{components={z+,y-z+,y+z+}}|x{components=y-z+,connect=dy-z+,clabel=",
        label2,
        "}"
    ), "..|x{components=z-}|.." ];

function tip(label) =
    [ str("x{components={z+x+,z+y-},connect=dz+y-,clabel=", label, "}."),
      "x{components={z-x+,z-y-,x+z-}}x{components=x-z-}"
    ];
