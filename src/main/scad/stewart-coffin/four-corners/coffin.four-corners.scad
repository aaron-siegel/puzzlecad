include <puzzlecad.scad>

$burr_scale = 27;
$burr_inset = 0.12;
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

*solid();
*fivecolor_bases();
*fivecolor_tips_1();
*fivecolor_tips_2();
*fivecolor_tips_3();
*fivecolor_tips_4();

module solid() {
    
    burr_piece([
        ".x{components={y+z+,z+y+,z+x-}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
        "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}.|.x{components={z-y-,x+z-,z-x+}}x{components=x-z-}"
    ]);
    
}

module fivecolor_bases() {
    
    burr_plate([
        base("A", "B"),
        base("A", "C"),
        base("A", "D"),
        base("B", "C"),
        base("B", "D"),
        base("C", "D")
    ]);
    
}

module fivecolor_tips_1() {
    
    tip_color("A");
    
}

module fivecolor_tips_2() {
    
    tip_color("B");
    
}

module fivecolor_tips_3() {
    
    tip_color("C");
    
}

module fivecolor_tips_4() {
    
    tip_color("D");
    
}

module tip_color(label) {
    
    burr_plate([tip(label), tip(label), tip(label)]);
    
}

function base(label1, label2) =
    [ str(
        "x{components=y+z+,connect=dmy+z+,clabel=",
        label1,
        "}|x{components={z+,y-z+,y+z+}}|x{components=y-z+,connect=dmy-z+,clabel=",
        label2,
        "}"
    ), "..|x{components=z-}|.." ];

function tip(label) =
    [ str("x{components={z+x+,z+y-},connect=dfz+y-,clabel=", label, "}."),
      "x{components={z-x+,z-y-,x+z-}}x{components=x-z-}"
    ];
