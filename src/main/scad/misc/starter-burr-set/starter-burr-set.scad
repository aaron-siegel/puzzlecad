include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_scale = 11.15;
$burr_inset = 0.06;
$burr_bevel = 0.5;
$burr_outer_x_bevel = 1.75;

*part_1();
*part_2();
*expansion();

module part_1() {
    
    stamped_burr_plate([1, 52, 103, 188, 256, 615, 792, 824]);
    
}

module part_2() {
    
    stamped_burr_plate([911, 928, 960, 975, 992, 1024, 1024]);
    
}

module expansion() {
    
    stamped_burr_plate([359, 369, 760, 871, 943, 956, 996, 1000, 1007]);
    
}

module stamped_burr_plate(piece_ids) {
    
    split_pieces = [
        for (i = [0:len(piece_ids)-1])
        let (stick = burr_stick(piece_ids[i], add_stamp = true))
        opt_split_burr_stick(stick, joint_label = auto_joint_letters[i])
    ];

    lower_pieces = [ for (split_piece = split_pieces) split_piece[0] ];
    
    upper_pieces = [ for (split_piece = split_pieces) if (len(split_piece) > 1) split_piece[1] ];

    burr_plate(lower_pieces);
    
    translate([0, ceil(len(lower_pieces) / 2) * ($burr_scale * 2 + $plate_sep), 0])
    burr_plate(upper_pieces, $burr_outer_x_bevel = $burr_bevel);
    
}
