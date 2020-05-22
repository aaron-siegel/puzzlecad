include <puzzlecad.scad>

require_puzzlecad_version("2.1");

// These four parameters control the output.

set = undef;
stick_length = 6;
first_index = 0;
last_index = 11;

$burr_scale = 11.15;
$burr_inset = 0.06;
$burr_bevel = 0.5;
$burr_outer_x_bevel = 1.75;

// stick_length adjusts the length of the pieces; 6 is the usual setting, but burr sets
// made with length 8 sticks are not uncommon, and settings of 10 or 12 may occasionally
// be desired as well.

// set can be either an array of Kaenel numbers (to produce a customized set of pieces)
// or a string representing one of the "standard sets". Examples:
// set = [52, 615, 792, 960, 975, 992];
// set = "notchable";

// The allowable strings that represent "standard sets" are:
// "notchable" - The standard 42 piece notchable burr set
// "ultimate" - The 27 piece Ultimate Burr Set
// "level5" - The 42 piece Level 5 Burr Set
// "extras" - A selection of extra pieces that are significant
// "comprehensive" - A set that includes all of the above (125 pieces)
// "even_more" - 27 *more* pieces, as an expansion to the comprehensive set!
// "obscure_notchables" - All notchable pieces not in any of the above sets
// "obscure_millables" - All millable pieces not in any of the above sets
// "example" - An example set of 6 pieces for testing print settings

// For large sets, first_index and last_index can be used to paginate.

notchable_ids = [1, 18, 18, 35, 52, 52, 86, 103, 120, 154, 188, 188, 256, 256, 256, 359, 615, 792, 792, 824, 824, 856, 871, 871, 888, 888, 911, 911, 928, 928, 943, 960, 960, 975, 975, 992, 992, 1007, 1007, 1024, 1024, 1024];

ultimate_ids = [1, 60, 64, 124, 128, 188, 192, 224, 256, 410, 412, 414, 416, 442, 444, 448, 474, 476, 478, 480, 506, 508, 512, 928, 960, 992, 1024];

level5_ids = [103, 120, 154, 188, 256, 256, 327, 344, 344, 376, 412, 444, 463, 480, 480, 480, 495, 512, 551, 568, 632, 670, 687, 704, 704, 734, 751, 768, 824, 856, 888, 928, 943, 960, 960, 975, 992, 992, 1007, 1024, 1933, 2836];

additional_ids = [20, 56, 72, 88, 94, 109, 112, 126, 156, 160, 216, 240, 464, 499, 511, 564, 576, 624, 702, 736, 757, 760, 800, 820, 832, 880, 883, 896, 909, 922, 926, 927, 956, 976, 984, 990, 996, 1008, 1008, 1015, 1016, 1021, 1023];

comprehensive_ids = union_of_number_lists(notchable_ids, union_of_number_lists(ultimate_ids, union_of_number_lists(level5_ids, additional_ids)));

even_more_ids = [55, 63, 144, 154, 256, 256, 276, 311, 369, 508, 622, 672, 743, 766, 768, 788, 848, 863, 869, 895, 924, 944, 957, 983, 989, 1012, 1013];

obscure_notchables_ids = [276, 291, 308, 395, 427, 534, 598, 653, 717, 1417, 1419, 1449, 1935, 2840];

obscure_millables_ids = [88, 118, 160, 192, 224, 399, 416, 431, 448, 491, 508, 536, 600, 630, 672, 736, 766, 1423, 1513];

example_ids = [1, 256, 824, 928, 975, 1024];

ids = !is_string(set) ? set
    : set == "notchable" ? notchable_ids
    : set == "ultimate" ? ultimate_ids
    : set == "level5" ? level5_ids
    : set == "extras" ? additional_ids
    : set == "comprehensive" ? comprehensive_ids
    : set == "even_more" ? even_more_ids
    : set == "obscure_notchables" ? obscure_notchables_ids
    : set == "obscure_millables" ? obscure_millables_ids
    : set == "example" ? example_ids
    : undef;
    
if (!is_undef(ids)) {

    burr_set(ids, first_index, min(last_index, len(ids)-1));

}

module burr_set(ids, first_index, last_index) {
    
    pieces = [
        for (i = [first_index:last_index])
        let (stick = burr_stick(ids[i], stick_length, add_stamp = true))
        for (piece = opt_split_burr_stick(stick, joint_label = auto_joint_letters[i - first_index]))
        piece
    ];
        
    burr_plate(pieces);
    
}
