/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design and 3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_scale = 11.15;
$burr_inset = 0.07;
$burr_bevel = 0.5;
$burr_bevel_adjustments = "x-=1.25,x+=1.25,y-=1.25,y+=1.25";

// The Board Burr Bundle is a set of 18 board burr pieces in three colors that
// together can make dozens of challenges with unique solutions.
// There are three parts to the set, each with six pieces, that should each be
// printed in a different color.

// These modules generate the standard set:

*part_1();
*part_2();
*part_3();
*tray();

// To generate board burr pieces with arbitrary kaenel numbers, uncomment and edit
// one of the following:

*burr_piece(board(832));
*burr_plate([board(320), board(509), board(832)]);

// To generate a larger tray, uncomment the following (this example gives a tray with
// 3 columns and 9 pieces per column):

*board_burr_tray(3, 9);

bundle = [[256, 488, 508, 511, 896, 960],
          [256, 496, 512, 512, 1016, 1024],
          [384, 480, 1012, 1016, 1024, 1936]];

module part_1() {
    burr_plate([for (n = bundle[0]) board(n, add_stamp = true)]);
}

module part_2() {
    burr_plate([for (n = bundle[1]) board(n, add_stamp = true)]);
}

module part_3() {
    burr_plate([for (n = bundle[2]) board(n, add_stamp = true)]);
}

module tray() {
    board_burr_tray(3, 6);
}

function board(kaenel_number, add_stamp = false) =
    let (unstamped_burr_info = wrap(zyx_to_xyz(kaenel_number_to_board_burr_info(kaenel_number))))
    add_stamp ? add_board_burr_stamp(unstamped_burr_info, str(kaenel_number)) : unstamped_burr_info;

function kaenel_number_to_board_burr_info(kaenel_number) =
    let (bitmask = kaenel_number - 1)
    [[
        [1, 1                     , 1 - bit_of(bitmask,  8), 1 - bit_of(bitmask,  9), 1,                      1],
        [1, 1 - bit_of(bitmask, 0), 1 - bit_of(bitmask,  1), 1 - bit_of(bitmask,  2), 1 - bit_of(bitmask, 3), 1],
        [1, 1 - bit_of(bitmask, 4), 1 - bit_of(bitmask,  5), 1 - bit_of(bitmask,  6), 1 - bit_of(bitmask, 7), 1],
        [1, 1                     , 1 - bit_of(bitmask, 10), 1 - bit_of(bitmask, 11), 1                     , 1]
    ]];

function add_board_burr_stamp(burr_info, stamp) =
    replace_in_array(burr_info, [0, 1, 0], [1, [
        ["label_text", stamp],
        ["label_orient", "x-y-"],
        ["label_hoffset", "-0.5"],
        ["label_scale", "0.45"]
    ]]);

module board_burr_tray(x_size, y_size, tray_inset = 0.25) {
    
    perimeter_thickness = 3;
    spacing = 4;
    base_thickness = 3;

    difference() {
        
        beveled_cube([
            x_size * $burr_scale * 4 + (x_size - 1) * spacing + 2 * perimeter_thickness,
            y_size * $burr_scale + 2 * perimeter_thickness,
            $burr_scale * 5 + base_thickness
        ], $burr_bevel = 0.5, $burr_bevel_adjustments = undef);
        
        for (x = [1:x_size]) {
            
            translate([(x - 1) * ($burr_scale * 4 + spacing) + perimeter_thickness - tray_inset, perimeter_thickness - tray_inset, base_thickness])
            cube([$burr_scale * 4 + tray_inset * 2, y_size * $burr_scale + tray_inset * 2, $burr_scale * 5 + 0.01]);
            
        }
        
        if (x_size > 1) {
            for (x = [1:x_size-1]) {
                
                translate([x * $burr_scale * 4 + (x - 1) * spacing + perimeter_thickness + tray_inset - 0.01, perimeter_thickness - tray_inset, base_thickness + 4 * $burr_scale])
                cube([spacing + 0.02, y_size * $burr_scale + tray_inset * 2, $burr_scale + 0.01]);
                
            }
        }
        
    }

}


// The following modules are not part of the 3D model; they are used to generate images
// that are included in the pdf booklet.

*render_burr_set(bundle);
*render_burr_example([[508, 511], [480, 1024], [512, 512]]);
*render_assembly_example([[508, 511], [480, 1024], [512, 512]]);

render_colors = ["sienna", "olive", "teal"];

module render_burr_set(pieces) {

    for (x = [0:len(pieces)-1]) {
        for (y = [0:len(pieces[x])-1]) {
            color(render_colors[x])
            translate($burr_scale * [3.5 + x * 4, 0.5 + y, 5.5] + [3 + x * 4, 3, 3] + [0.15, 0.15, 0])
            rotate([0, 0, 90])
            rotate([0, 90, 0])
            burr_piece_2(board(pieces[x][y], add_stamp = true), center = true);
        }
    }
    
    render(convexity = 2)
    board_burr_tray(len(pieces), len(pieces[0]));
    
}

module render_burr_example(pieces) {
    
    for (y = [0:len(pieces)-1]) {
        for (x = [0:len(pieces[y])-1]) {
            color(render_colors[y])
            translate([x * (6 * $burr_scale + $plate_sep), y * (4 * $burr_scale + $plate_sep), 0])
            burr_piece(board(pieces[y][x], add_stamp = false));
        }
    }
    
}

module render_assembly_example(pieces) {
    
    rotations = [[0, 0, 0], [-90, 0, 90], [0, -90, 90]];
    translations = [[[0, 0, 2], [0, 0, 3]], [[2, -1, 4], [3, -1, 4]], [[4, 1, 0], [4, 2, 0]]];

    for (y = [0:len(pieces)-1]) {
        for (x = [0:len(pieces[y])-1]) {
            color(render_colors[y])
            translate($burr_scale * translations[y][x])
            rotate(rotations[y])
            burr_piece_2(board(pieces[y][x], add_stamp = false), center = true);
        }
    }

}
