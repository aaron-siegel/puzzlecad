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
    
    stamped_burr_plate([359, 369, 760, 871, 895, 943, 990, 996, 1007]);
    
}

module stamped_burr_plate(piece_ids) {
    
    pieces = [
        for (i = [0:len(piece_ids)-1])
        let (stick = burr_stick(piece_ids[i], add_stamp = true))
        for (piece = opt_split_burr_stick(stick, joint_label = auto_joint_letters[i]))
        piece
    ];

    burr_plate(pieces);
    
}
