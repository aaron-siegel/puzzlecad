include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 32;
$burr_inset = 0;// 0.12;
$burr_bevel = 0.6;

*solid();
*twocolor_base();
*twocolor_tip();
*fivecolor_bases();
*fivecolor_tips_1();
*fivecolor_tips_2();
*fivecolor_tips_3();
*fivecolor_tips_4();

module solid() {
    
    burr_plate([
        [".x{components={z+x-,y+z+,z+y+,z+x+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+x-,y-z+,z+y-,z+x+}}.",
         "x{components=x+z-}x{components={x-z-,z-x-,z-y+,z-x+,x+z-}}x{components=x-z-}|.x{components=z-}.|x{components=x+z-}x{components={x-z-,z-x-,z-y-,z-x+,x+z-}}x{components=x-z-}"]
    ], $post_rotate = [0, 45, 0], $post_translate = [-(sqrt(2)+1)/2, 0, (sqrt(2)-1)/2]);
    
}

module twocolor_base() {
    
    burr_piece([
        ".x{components={y+z+,z+y+,z+x-}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
        "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}|.x{components=z-}x{components={},connect=dfx-y-~}|.x{components={z-y-,x+z-,z-x+},connect=dfx+y+~}x{components=x-z-}"
    ], $post_rotate = [0, 45, 0], $post_translate = [-(sqrt(2)+1)/2, 0, (sqrt(2)-1)/2]);
    
}

module twocolor_tip() {
    
    burr_piece([
        "x{components=z+x+}.|..",
        "x{components={z-x+,x+z-}}x{components=x-z-}|.x{components={},connect=dmy-x-~}"
    ], $post_rotate = [0, 45, 0], $post_translate = [-1/2, 0, -1/2]);

}

module fivecolor_bases() {
    
    // Color scheme as specified in AP-ART, entry 8-B.
    
    burr_plate([
        base("AFCH"),
        base("AGDF"),
        base("AHBG"),
        base("DGBE"),
        base("BHCE"),
        base("CFDE")
    ],  $post_rotate = [0, 45, 0],
        $post_translate = [0, 0, sqrt(1/8)],
        $diag_joint_scale = 0.3,
        $diag_joint_position = 0.3
    );
    
}

module fivecolor_tips_1() {
    
    fivecolor_tips("AE");
    
}

module fivecolor_tips_2() {
    
    fivecolor_tips("BF");
    
}

module fivecolor_tips_3() {
    
    fivecolor_tips("CG");
    
}

module fivecolor_tips_4() {
    
    fivecolor_tips("DH");
    
}

module fivecolor_tips(labels) {
    
    burr_plate(repeat(3, tip1(labels[0])),
        $post_rotate = [-135, 0, 0],
        $post_translate = [-1/2, 0, sqrt(2)/2 - 1/2],
        $plate_width = $burr_scale * 3,
        $diag_joint_scale = 0.3,
        $diag_joint_position = 0.3
    );

    translate([$burr_scale * 2, 0, 0])
    burr_plate(repeat(3, tip2(labels[1])),
        $post_rotate = [-90, -45, 0],
        $post_translate = [-1/2, 0, -1/2],
        $plate_width = $burr_scale * 3,
        $diag_joint_scale = 0.3,
        $diag_joint_position = 0.3
    );
    
}

function base(labels) = [
    ".x{components={y+z+,z+y+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-}}.",
    str_interpolate(
        ".x{components={z-y+}}|.x{components=z-,connect=dfx+y-~,clabel=$2}x{components={},connect=dfx-y-~,clabel=$1}|.x{components=z-y-,connect=dfx+y+~,clabel=$3}x{components={},connect=dfx-y+~,clabel=$0}",
        labels
    )
];

function tip1(label) = [
    "x{components=z+x+}.",
    str_interpolate("x{components={z-x+,x+z-}}x{components=x-z-,connect=dmy+x-~,clabel=$0}", label)
];

function tip2(label) = [
    "x{components=z+x+}.",
    str_interpolate("x{components={z-x+,x+z-}}x{components=x-z-,connect=dmy+z+~,clabel=$0}", label)
];
