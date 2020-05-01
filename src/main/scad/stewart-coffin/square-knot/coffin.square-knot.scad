include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_scale = 8;

*piece();
*left_handed_reverse_piece();
*right_handed_reverse_piece();
*classical_altekruse_piece();

module piece() {

    burr_piece(generalized_altekruse("dbd", outer_width = 2));
    
}

module left_handed_reverse_piece() {
    
    burr_piece(generalized_altekruse("bdf", outer_width = 2));
    
}

module right_handed_reverse_piece() {
    
    burr_piece(generalized_altekruse("fdb", outer_width = 2));
    
}

module classical_altekruse_piece() {
    
    burr_piece(generalized_altekruse("dbd"));
    
}
