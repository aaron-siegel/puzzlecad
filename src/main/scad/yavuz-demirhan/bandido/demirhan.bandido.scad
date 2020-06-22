/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Yavuz Demirhan
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.1");

$burr_scale = 9;
$burr_inset = 0.06;     // Use 0.04 for a tighter fit
$burr_bevel = 0.5;

*central_piece();
*other_pieces();

module central_piece() {
    
    burr_piece([
        "xxxx|xxxx|xxxx|xxxx",
        "x..x|xxxx|xxxx|xxxx",
        "x..x|xxxx{connect=mz+y+}|xxx.|xxxx{connect=mz+y+}",
        "x..x|x...|xx..|xxx."
    ], $burr_bevel_adjustments = "z+o=1,z-o=1,x-o=0.99,x+o=1");
    
    translate([$burr_scale * 4 + $plate_sep, 0, 0])
    burr_piece("x{connect=fz-y+}|x|x{connect=fz-y+}", $burr_bevel_adjustments = "z+y+=1,z+x+=1,x+y+=1");

}

module other_pieces() {
    
    burr_plate([
        [ "xx.....x|xx.xx.xx|xxxxxxxx", "x......x|xx....xx|xxx..xxx" ],
        [ "x......x|xx.x..xx|xxxxxxxx", "x......x|xx....xx|xxxxxxxx" ],
        [ "x......x|xx...xxx|xxxxxxxx", "x......x|xx....xx|xxxxxxxx" ],
        [ "x......x|xx....xx|xxxx{label_text=Y. Demirhan,label_orient=y-x+,label_hoffset=0.5,label_voffset=0.1}xxxx",
          "x......x|xx....xx|xxxx{label_text=Bandido,label_orient=y-x+,label_scale=0.5,label_hoffset=0.5,label_voffset=-0.1}xxxx" ],
        [ "x......x|xx....xx|xxxxxxxx", "xx.....x|xx....xx|xxx..xxx" ],
        [ "x......x|xx....xx|xxxxxxxx", "x......x|xx....xx|xxx..xxx" ]
    ], $burr_outer_x_bevel = 1.75, $auto_layout = true);
    
}
