include <puzzlecad.scad>

require_puzzlecad_version("2.0");

// These four parameters control the output.

stick_length = 6;
set = undef;
first_index = 0;
last_index = 11;
inset = 0.06;

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
// "obscure_notchables" - All notchable pieces not in any of the above sets
// "obscure_millables" - All millable pieces not in any of the above sets
// "example" - An example set of 6 pieces for testing print settings

// For large sets, first_index and last_index can be used to paginate.

notchable_ids = [1, 18, 18, 35, 52, 52, 86, 103, 120, 154, 188, 188, 256, 256, 256, 359, 615, 792, 792, 824, 824, 856, 871, 871, 888, 888, 911, 911, 928, 928, 943, 960, 960, 975, 975, 992, 992, 1007, 1007, 1024, 1024, 1024];

ultimate_ids = [1, 60, 64, 124, 128, 188, 192, 224, 256, 410, 412, 414, 416, 442, 444, 448, 474, 476, 478, 480, 506, 508, 512, 928, 960, 992, 1024];

level5_ids = [103, 120, 154, 188, 256, 256, 327, 344, 344, 376, 412, 444, 463, 480, 480, 480, 495, 512, 551, 568, 632, 670, 687, 704, 704, 734, 751, 768, 824, 856, 888, 928, 943, 960, 960, 975, 992, 992, 1007, 1024, 1933, 2836];

robs_extras_ids = [20, 56, 72, 88, 94, 109, 112, 126, 156, 160, 216, 240, 464, 499, 511, 564, 576, 624, 702, 736, 757, 760, 800, 820, 832, 880, 883, 896, 909, 922, 926, 927, 956, 976, 984, 990, 996, 1008, 1008, 1015, 1016, 1021, 1023];

comprehensive_ids = [1, 18, 18, 20, 35, 52, 52, 56, 60, 64, 72, 86, 88, 94, 103, 109, 112, 120, 124, 126, 128, 154, 156, 160, 188, 188, 192, 216, 224, 240, 256, 256, 256, 327, 344, 344, 359, 376, 410, 412, 414, 416, 442, 444, 448, 463, 464, 474, 476, 478, 480, 480, 480, 495, 499, 506, 508, 511, 512, 551, 564, 568, 576, 615, 624, 632, 670, 687, 702, 704, 704, 734, 736, 751, 757, 760, 768, 792, 792, 800, 820, 824, 824, 832, 856, 871, 871, 880, 883, 888, 888, 896, 909, 911, 911, 922, 926, 927, 928, 928, 943, 956, 960, 960, 975, 975, 976, 984, 990, 992, 992, 996, 1007, 1007, 1008, 1008, 1015, 1016, 1021, 1023, 1024, 1024, 1024, 1933, 2836];

obscure_notchables_ids = [276, 653, 291, 308, 717, 395, 534, 427, 598, 1417, 1419, 1449, 1935, 2840];

obscure_millables_ids = [160, 88, 118, 192, 224, 399, 536, 416, 672, 431, 600, 448, 736, 491, 630, 508, 766, 1423, 1513];

example_ids = [1, 256, 824, 928, 975, 1024];

ids = !is_string(set) ? set
    : set == "notchable" ? notchable_ids
    : set == "ultimate" ? ultimate_ids
    : set == "level5" ? level5_ids
    : set == "extras" ? robs_extras_ids
    : set == "comprehensive" ? comprehensive_ids
    : set == "obscure_notchables" ? obscure_notchables_ids
    : set == "obscure_millables" ? obscure_millables_ids
    : set == "example" ? example_ids
    : undef;
    
if (ids != undef) {
    burr_set(ids, first_index, min(last_index, len(ids)-1));
}

module burr_set(ids, first_index, last_index) {
    
    page = [ for (n = [first_index:last_index])
        [ids[n], opt_split(add_kaenel_number(burr_stick(ids[n], stick_length), ids[n]), auto_joint_letters[n - first_index])]
    ];
    labels = [for (pieces = page, n = [0:len(pieces[1])-1]) n == 0 ? str(pieces[0]) : undef];
    sticks = [for (pieces = page, piece = pieces[1]) piece];
    burr_plate(sticks, $burr_inset = inset, $burr_bevel = 0.5, $burr_outer_x_bevel = 1.75);
    
}

function opt_split(stick, label_char) =
    is_simply_connected(stick) ? [stick] : [lower_split(stick, label_char), upper_split(stick, label_char)];

function is_simply_connected(stick, x = 0, y = 0) =
    y == len(stick[0]) ? true :
    x == len(stick) ? is_simply_connected(stick, 0, y + 1) :
    (stick[x][y][1][0] == 0 || stick[x][y][0][0] > 0) && is_simply_connected(stick, x + 1, y);

function add_kaenel_number(stick, kaenel_number) =
    replace_in_list(stick, 0, replace_in_list(stick[0], 0, replace_in_list(stick[0][0], 0,
        [1, [["label_text", str(kaenel_number)], ["label_orient", "x-y-"], ["label_hoffset", "-0.5"], ["label_voffset", "0.5"], ["label_scale", "0.538"]]]
    )));

function lower_split(stick, label_char) =
    [ for (x = [0:len(stick)-1])
        [ for (y = [0:1])
            [ for (z = [0:1])
                z == 0 && x > 0 && x < len(stick) - 1 ? (stick[x][y][z][0] == 1 && stick[x][y][1][0] == 1 ? [1, [["connect", "mz+y+"], ["clabel", label_char]]] : stick[x][y][z]) :
                x >= (stick_length - 4) / 2 && x < (stick_length + 4) / 2 ? 0 : stick[x][y][z]
            ]
        ]
    ];
            
function upper_split(stick, label_char) =
    [ for (x = [0:len(stick)-1])
        [ for (y = [0:1])
            x >= (stick_length - 4) / 2 && x < (stick_length + 4) / 2 ?
                (stick[x][y][0][0] == 1 && stick[x][y][1][0] == 1 ? [[1, [["connect", "fz-y+"], ["clabel", label_char]]]] :
                        [stick[x][y][1]])
            : [[0]]
        ]
    ];
