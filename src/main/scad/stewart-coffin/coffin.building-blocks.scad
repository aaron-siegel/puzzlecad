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

$burr_scale = 27;
$burr_inset = 0;
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];
$plate_width = 300;

difference() {
    
    burr_plate([
        ["x{components=y+z+}|x{components=y-z+}"], // T
        ["x{components={z+x+,z+y-}}.", "x{components={z-x+,z-y-,x+z-}}x{components=x-z-}"], // L
        ["x{components={z+x+,z+y+}}.", "x{components={z-x+,z-y+,x+z-}}x{components=x-z-}"], // R
        ["x{components=z+}", "x{components=z-}"], // O
        ["x{components=y+z+}|x{components={z+,y-z+,y+z+}}|x{components=y-z+}", ".|x{components=z-}|."], // C
        ["x{components=y-z+}"], // t
        ["x{components={y+z+,y+x-}}|x{components={y-z+,y-x-}}"], // P
    ], $post_translate = [0, 0, sqrt(1/8)]);
    
    translate($burr_scale * [0.23, 0.5, 0])
    rotate([180, 0, 90])
    linear_extrude(2, center = true)
    text("T", halign = "center", valign = "center", size = 8);

    translate($burr_scale * [1.63, 0.5, 0])
    rotate([180, 0, 0])
    linear_extrude(2, center = true)
    text("R", halign = "center", valign = "center", size = 8);

    translate($burr_scale * [3.28, 0.5, 0])
    rotate([180, 0, 0])
    linear_extrude(1, center = true)
    text("L", halign = "center", valign = "center", size = 8);

    translate($burr_scale * [4.65, 0.5, 0])
    rotate([180, 0, 0])
    linear_extrude(1, center = true)
    text("O", halign = "center", valign = "center", size = 8);
    
    translate($burr_scale * [5.46, 1, 0])
    rotate([180, 0, 0])
    linear_extrude(1, center = true)
    text("C", halign = "center", valign = "center", size = 8);
    
    translate($burr_scale * [6.28, 0.15, 0])
    rotate([180, 0, 90])
    linear_extrude(1, center = true)
    text("t", halign = "center", valign = "center", size = 8);
            
    translate($burr_scale * [7.7, 0.5, 0])
    rotate([180, 0, 0])
    linear_extrude(1, center = true)
    text("P", halign = "center", valign = "center", size = 8);

}
/*
difference() {
    
    burr_plate([
        ["x{components=y-z+}"]
    ], $post_rotate = [-135, 0, 0], $post_translate = [sqrt(2), 1.8, sqrt(1/8)]);
    
    translate($burr_scale * [1.9, 1.88, 0])
    rotate([180, 0, 0])
    linear_extrude(1, center = true)
    text("t", halign = "center", valign = "center", size = 8);
    
}

difference() {
    
    burr_plate([
        ["x{components={y+z+,y+x-}}|x{components={y-z+,y-x-}}"], // P
    ], $post_translate = [sqrt(2)*2, sqrt(2), 0]);
        
    translate($burr_scale * [3.54, 1.93, 0])
    rotate([180, 0, 0])
    linear_extrude(1, center = true)
    text("P", halign = "center", valign = "center", size = 8);

}
*/