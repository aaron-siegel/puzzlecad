include <puzzlecad.scad>

$burr_scale = 27;
$burr_inset = 0.11;
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

difference() {
    
    burr_plate([
        ["x{components=y+z+}|x{components=y-z+}"], // T
        ["x{components={z+x+,z+y-}}.", "x{components={z-x+,z-y-,x+z-}}x{components=x-z-}"], // L
        ["x{components={z+x+,z+y+}}.", "x{components={z-x+,z-y+,x+z-}}x{components=x-z-}"], // R
        ["x{components=z+}", "x{components=z-}"], // O
        ["x{components=y+z+}|x{components={z+,y-z+,y+z+}}|x{components=y-z+}", ".|x{components=z-}|."], // C
    ], $post_translate = [0, 0, sqrt(1/8)]);
    
    translate($burr_scale * [0.6, 0.5, 0])
    rotate([180, 0, 90])
    linear_extrude(1, center = true)
    text("T", halign = "center", valign = "center", size = 8);

    translate($burr_scale * [2.27, 0.5, 0])
    rotate([180, 0, 0])
    linear_extrude(1, center = true)
    text("L", halign = "center", valign = "center", size = 8);

    translate($burr_scale * [4.02, 0.5, 0])
    rotate([180, 0, 0])
    linear_extrude(1, center = true)
    text("R", halign = "center", valign = "center", size = 8);

    translate($burr_scale * [5.5, 0.5, 0])
    rotate([180, 0, 0])
    linear_extrude(1, center = true)
    text("O", halign = "center", valign = "center", size = 8);
    
    translate($burr_scale * [0.7, 2.25, 0])
    rotate([180, 0, 0])
    linear_extrude(1, center = true)
    text("C", halign = "center", valign = "center", size = 8);

}

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
