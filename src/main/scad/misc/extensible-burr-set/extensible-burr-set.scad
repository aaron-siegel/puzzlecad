/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.1");

// This is the Extensible Burr Set, version 2.1. It uses the puzzlecad library, and this
// documentation assumes you're familiar with puzzlecad and its usage. Details can be
// found in the Puzzle Modeling Tutorial here:
// https://www.puzzlehub.org/ppp

////// Usage

// The burr_set module takes as input a list of Kaenel numbers and
// generates the corresponding burr pieces. For example:
*burr_set([1, 256, 824, 928, 975, 1024]);

// There are various predefined sets, described below; instead of explicit Kaenel
// numbers, you can give it one of the predefined sets:
*burr_set(notchables);

// If a set contains more than 12 elements, only the first "page" of 12 burr pieces will
// be generated. You can generate the second page as follows:
*burr_set(notchables, page_number = 2);

// By default, all the sticks will be generated with length 6. Burr sets made with
// length 8 sticks are not uncommon, and settings of 10 or 12 may occasionally be
// desired as well. You can set it to any (even) number:
*burr_set(notchables, page_number = 2, stick_length = 8);

// Finally, use burr_tray to generate a tray; the following examples give a large-size
// 8x6 tray. The optional `tray_inset` parameter can be used to adjust the insets (default
// is 0.15 mm).
*burr_tray(8, 6);
*burr_tray(8, 6, tray_inset = 0.25);

////// Parameters

// The following parameter controls the page size; it is 12 by default.

page_size = 6;

// These four parameters are the usual puzzlecad parameters. For details, refer to the
// Puzzle Modeling Tutorial at: https://www.puzzlehub.org/ppp

$burr_scale = 11.15;
$burr_inset = 0.06;
$burr_bevel = 0.5;
$burr_outer_x_bevel = 1.75;

////// Predefined burr sets

// The standard 42-piece notchable set (the minimal set that can make every notchable,
// solid burr)

notchables = [1, 18, 18, 35, 52, 52, 86, 103, 120, 154, 188, 188, 256, 256, 256, 359, 615, 792, 792, 824, 824, 856, 871, 871, 888, 888, 911, 911, 928, 928, 943, 960, 960, 975, 975, 992, 992, 1007, 1007, 1024, 1024, 1024];

// The 27-piece Ultimate Burr Set

ultimate = [1, 60, 64, 124, 128, 188, 192, 224, 256, 410, 412, 414, 416, 442, 444, 448, 474, 476, 478, 480, 506, 508, 512, 928, 960, 992, 1024];

// The 42-piece Level 5 Burr Set, which can make lots of level-5 burrs

level5 = [103, 120, 154, 188, 256, 256, 327, 344, 344, 376, 412, 444, 463, 480, 480, 480, 495, 512, 551, 568, 632, 670, 687, 704, 704, 734, 751, 768, 824, 856, 888, 928, 943, 960, 960, 975, 992, 992, 1007, 1024, 1933, 2836];

// A selection of additional pieces that are not part of the above sets
// and that are identified as signficant in Rob Stegmann's catalog

additional = [20, 55, 56, 72, 88, 94, 112, 126, 156, 160, 216, 240, 464, 499, 511, 564, 576, 624, 702, 736, 757, 760, 800, 820, 832, 880, 883, 896, 909, 922, 926, 927, 956, 976, 984, 990, 996, 1008, 1008, 1015, 1016, 1021, 1023];

// Comprehensive Burr Set: The minimal set containing all of the above (125 pieces)

comprehensive = union_of_number_lists(notchables, union_of_number_lists(ultimate, union_of_number_lists(level5, additional)));

// Even More Burr Set: Even more pieces that further expand the Comprehensive Burr Set!

even_more = [63, 144, 154, 256, 256, 276, 311, 368, 369, 383, 508, 622, 640, 672, 743, 766, 768, 788, 863, 864, 887, 895, 924, 954, 957, 983, 986, 989, 997, 1000, 1012, 1013, 1935];

// Rob Stegmann's "obscure notchables" and "obscure millables" - rarely used pieces of
// the corresponding type. There is some overlap between these and the above sets.

obscure_notchables = [276, 291, 308, 395, 427, 534, 598, 653, 717, 1417, 1419, 1449, 1935, 2840];

obscure_millables = [88, 118, 160, 192, 224, 399, 416, 431, 448, 491, 508, 536, 600, 630, 672, 736, 766, 1423, 1513];

// The Length 8 Set: be sure to print this with stick_length = 8! With it you can make
// several notable burrs that require length 8 pieces in order to work.

length_8 = [216, 412, 476, 624, 512, 702, 751, 757, 768, 883, 896, 944, 956, 960, 1015, 1021, 1024];

// An example six-piece burr that is useful for doing test prints.

example = [1, 256, 824, 928, 975, 1024];

if (!is_undef(pieces)) {

    stamped_burr_plate(pieces);

}

module burr_set(pieces, page_number = 1, stick_length = 6) {

    if (len(pieces) > page_size * (page_number - 1)) {

        first_index = page_size * (page_number - 1);
        last_index = min(page_size * page_number, len(pieces)) - 1;
        page = [ for (i = [first_index:last_index]) pieces[i] ];
        stamped_burr_plate(page, stick_length);
        
    }

}

module stamped_burr_plate(piece_ids, stick_length = 8) {
    
    split_pieces = [
        for (i = [0:len(piece_ids)-1])
        let (stick = burr_stick(piece_ids[i], stick_length, add_stamp = true))
        opt_split_burr_stick(stick, joint_label = auto_joint_letters[i])
    ];

    lower_pieces = [ for (split_piece = split_pieces) split_piece[0] ];
    
    upper_pieces = [ for (split_piece = split_pieces) if (len(split_piece) > 1) split_piece[1] ];

    burr_plate(lower_pieces);
    
    translate([0, ceil(len(lower_pieces) / 2) * ($burr_scale * 2 + $plate_sep), 0])
    burr_plate(upper_pieces, $burr_outer_x_bevel = $burr_bevel);
    
}

module tray_6x4(tray_inset = 0.15) {
    
    burr_tray(6, 4, tray_inset);
    
}

module tray_7x6(tray_inset = 0.15) {
    
    burr_tray(7, 6, tray_inset);
    
}

module tray_8x6(tray_inset = 0.15) {
    
    burr_tray(8, 6, tray_inset);
    
}

module tray_10x7(tray_inset = 0.15) {
    
    burr_tray(10, 7, tray_inset);
    
}

module burr_tray(x_size, y_size, tray_inset = 0.15) {
    
    perimeter_thickness = 3;
    spacing = 4;
    base_thickness = 3;

    difference() {
        
        beveled_cube([
            x_size * $burr_scale * 2 + 2 * perimeter_thickness,
            y_size * $burr_scale * 2 + (y_size - 1) * spacing + 2 * perimeter_thickness,
            $burr_scale * 4 + base_thickness
        ], $burr_bevel = 0.5, $burr_outer_x_bevel = undef);
        
        for (y = [1:y_size]) {
            
            translate([perimeter_thickness - tray_inset, (y - 1) * ($burr_scale * 2 + spacing) + perimeter_thickness - tray_inset, base_thickness])
            cube([x_size * $burr_scale * 2 + tray_inset * 2, $burr_scale * 2 + tray_inset * 2, $burr_scale * 4 + 0.01]);
            
        }
        
        if (y_size > 1) {
            for (y = [1:y_size-1]) {
                
                translate([perimeter_thickness - tray_inset, y * $burr_scale * 2 + (y - 1) * spacing + perimeter_thickness + tray_inset - 0.01, base_thickness + 3 * $burr_scale])
                cube([x_size * $burr_scale * 2 + tray_inset * 2, spacing + 0.02, $burr_scale + 0.01]);
                
            }
        }
        
    }

}
