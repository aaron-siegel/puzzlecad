include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_scale = 11.15;
$burr_inset = 0.07;

*left_handed_piece();
*right_handed_piece();

module left_handed_piece() {
    
    burr_piece(generalized_altekruse("bd"));
    
}

module right_handed_piece() {
    
    burr_piece(generalized_altekruse("db"));
    
}
