include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_scale = 6.5;

*piece_2_left();
*piece_2_right();
*piece_3();
*piece_4_left();
*piece_4_right();
*piece_5();

module piece_2_left() { piece(2, parity = 1); }
module piece_2_right() { piece(2, parity = 0); }
module piece_3() { piece(3); }
module piece_4_left() { piece(4, parity = 1); }
module piece_4_right() { piece(4, parity = 0); }
module piece_5() { piece(5); }

module piece(length, parity = 0) {

    spec_string = mkstring([ for (i = [0:length-1]) i % 2 == parity ? "d" : "b" ]);
    burr_piece(generalized_altekruse(spec_string, outer_width = 1));
    
}
