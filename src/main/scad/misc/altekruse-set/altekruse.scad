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

require_puzzlecad_version("2.1");

$burr_scale = 6.5;
$burr_inset = 0.07;
$burr_bevel = 0.5;

// Uncomment one of the following to render a standard Altekruse piece
// in length 2 through 7.

*piece_2_left();
*piece_2_right();
*piece_3();
*piece_4_left();
*piece_4_right();
*piece_5();
*piece_6_left();
*piece_6_right();
*piece_7();
*piece_3_reverse_left();
*piece_3_reverse_right();

// The following module can be used to render standard pieces of arbitrary
// length. parity = 1 for left-handed, -1 for right-handed. (The parity is
// significant only for even-length pieces.)

*burr_piece(standard_altekruse(8, parity = 1));

// Use the following module for generalized Altekruse pieces. The string
// encodes a pattern of notches: d, f, b, u for down, front, back, up,
// referring to the location of the solid part of the groove.

*burr_piece(generalized_altekruse("bdf"));

module piece_2_left() { burr_piece(standard_altekruse(2, parity = 1)); }
module piece_2_right() { burr_piece(standard_altekruse(2, parity = -1)); }
module piece_3() { burr_piece(standard_altekruse(3)); }
module piece_4_left() { burr_piece(standard_altekruse(4, parity = 1)); }
module piece_4_right() { burr_piece(standard_altekruse(4, parity = -1)); }
module piece_5() { burr_piece(standard_altekruse(5)); }
module piece_6_left() { burr_piece(standard_altekruse(6, parity = 1)); }
module piece_6_right() { burr_piece(standard_altekruse(6, parity = -1)); }
module piece_7() { burr_piece(standard_altekruse(7)); }
module piece_3_reverse_left() { burr_piece(generalized_altekruse("bdf")); }
module piece_3_reverse_right() { burr_piece(generalized_altekruse("fdb")); }

function standard_altekruse(length, parity = 1) =
    assert(parity == 1 || parity == -1)
    let (spec_string = mkstring([ for (i = [0:length-1]) i % 2 == (parity + 1) / 2 ? "d" : "b" ]))
    generalized_altekruse(spec_string, outer_width = 1);
