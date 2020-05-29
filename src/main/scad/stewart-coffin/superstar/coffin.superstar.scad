/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Stewart Coffin
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 27;
$burr_inset = 0.14;     // Use 0.12 for a tighter fit
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

*solid();
*fivecolor_bases();
*fivecolor_tips_1();
*fivecolor_tips_2();
*fivecolor_tips_3();
*fivecolor_tips_4();

module solid() {
    
    burr_piece(
        [".x{components=y+z+}.|.x{components={z+x-,y+z+,z+y-,z+y+,z+x+,y-z+}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={z+x-,y-z+,y+z+,z+y-,z+y+,z+x+}}.|.x{components=y-z+}.",
         "x{components=y+x+}..|x{components={x+z-,x+y-,y-x+}}x{components={x-z-,z-x-,z-y-,z-y+,z-x+,x+z-,x-y-}}x{components=x-z-}|.x{components=z-}.|x{components=x+z-}x{components={x-z-,z-x-,z-y-,z-y+,z-x+,x+z-,x+y+}}x{components={x-z-,x-y+,y+x-}}|..x{components=y-x-}"]
    );
    
}

module fivecolor_bases() {
    
    // Color scheme as specified in AP-ART, entry 50-B.
    
    burr_plate([
        base("AEBF"),
        base("AECG"),
        base("AEDH"),
        base("BFCG"),
        base("BFDH"),
        base("CGDH")
    ], $diag_joint_scale = 0.3, $diag_joint_position = 0.3);
    
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
    
    burr_plate(
        concat(repeat(3, tip_A(labels[0])), repeat(3, tip_B(labels[1]))),
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

function tip_A(label) = [
    str_interpolate("x{components={y+x-,y+z+},connect=dmy+x-,clabel=$0}|x{components={y-x-,y-z+,z+y-,z+x+}}", label),
    ".|x{components={z-y-,z-x+}}"
];

function tip_B(label) = [
    str_interpolate("x{components={y+x-,y+z+},connect=dmy+z+,clabel=$0}|x{components={y-x-,y-z+,z+y-,z+x+}}", label),
    ".|x{components={z-y-,z-x+}}"
];
