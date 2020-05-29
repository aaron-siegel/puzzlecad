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

$tray_scale = 16;
$tray_opening_border = 10;

$burr_inset = 0.07;

// Uncomment one of the following three lines to render that component.

*pieces();
*tray();
*tray_cap();
*lid();


module pieces() {
    
    burr_plate([
        ["xxxx|x..."], [".xx|xx."], ["xxx|x.."], ["xxx|x..|x.."], ["xx|x."], ["xxx|.x."]
    ], $burr_scale = [$tray_scale, $tray_scale, $tray_opening_height], $plate_width = 150);
    
}

module tray() {
    
    difference() {
        
        // Tray frame
        beveled_cube([
            $tray_scale * 5 + $tray_opening_border * 2,
            $tray_scale * 5 + $tray_opening_border * 2,
            $tray_padding + $tray_opening_height + $burr_inset * 2
        ]);
        
        // Tray opening
        translate([$tray_opening_border - $burr_inset, $tray_opening_border - $burr_inset, $tray_padding])
        cube([
            $tray_scale * 5 + $burr_inset * 2,
            $tray_scale * 5 + $burr_inset * 2,
            $tray_opening_height + $burr_inset * 2 + 0.001
        ]);
        
        // Slot
        translate([$tray_scale * 3 + $tray_opening_border - $burr_inset, -0.001, $tray_padding])
        cube([
            $tray_scale * 2 + $burr_inset * 2,
            $tray_opening_border + 0.002,
            $tray_opening_height + $burr_inset * 2 + 0.001
        ]);
        
        // Glue holes
        height = $tray_padding + $tray_opening_height + $burr_inset * 2;
        mid = $tray_opening_border / 2;
        far = mid + $tray_opening_border + 5 * $tray_scale;
        translate([mid, mid, height - 2.1]) cylinder(r = 2.7, h = 2.101, $fn = 32);
        translate([mid, far, height - 2.1]) cylinder(r = 2.7, h = 2.101, $fn = 32);
        translate([far, mid, height - 2.1]) cylinder(r = 2.7, h = 2.101, $fn = 32);
        translate([far, far, height - 2.1]) cylinder(r = 2.7, h = 2.101, $fn = 32);

    }
    
}

module tray_cap() {
    
    dim = $tray_scale * 5 + $tray_opening_border * 2;
    mid = $tray_opening_border / 2;
    far = mid + $tray_opening_border + 5 * $tray_scale;
    difference() {
        beveled_cube([dim, dim, $tray_padding]);
        translate([dim / 2, dim / 2, 0])
        cube([$tray_scale * 4 + $burr_inset * 2, $tray_scale * 4 + $burr_inset * 2, $tray_padding * 3], center=true);
    }
    translate([mid, mid, $tray_padding]) cylinder(r = 2.5, h = 2, $fn = 32);
    translate([mid, far, $tray_padding]) cylinder(r = 2.5, h = 2, $fn = 32);
    translate([far, mid, $tray_padding]) cylinder(r = 2.5, h = 2, $fn = 32);
    translate([far, far, $tray_padding]) cylinder(r = 2.5, h = 2, $fn = 32);
    
}

module lid() {
    
    packing_tray_lid(
        [$tray_scale * 5 + $tray_opening_border * 2 + 0.5,
         $tray_scale * 5 + $tray_opening_border * 2 + 0.5,
         $tray_padding * 2 + $tray_opening_height + $burr_inset * 3],
        $tray_padding,
        "Window Pain",
        ["Stewart Coffin", "STC #186"],
        8.5
    );
    
}
