/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Christoph Lohe
  3D model (c) Aaron Siegel

==================================================================== */

include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 8;
$burr_inset = 0.12;
$burr_bevel = 0.5;

*frame();
*frame_cap();
*pieces_1();
*pieces_2();

module frame() {
    
    burr_piece([
        "xxxxxxxxxxxxxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxx|x............x|x............x|x............x|x............x|x............x|x............x|x............x|x............x|xxxxxxxxxxxxxx",
        "x{connect=mz+y+}xxxxxx{connect=mz+y+}x{connect=mz+y+}xxxxxx{connect=mz+y+}|x............x|x............x|x............x|x............x|x............x|x............x|x............x|x............x|x{connect=mz+y+}xxxxxx{connect=mz+y+}x{connect=mz+y+}xxxxxx{connect=mz+y+}"
    ], $burr_outer_z_bevel = [1.75, $burr_bevel]);

}

module frame_cap() {
    
    burr_piece([
        "x{connect=fz-y+}xxxxxx{connect=fz-y+}x{connect=fz-y+}xxxxxx{connect=fz-y+}|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|x{connect=fz-y+}xxxxxx{connect=fz-y+}x{connect=fz-y+}xxxxxx{connect=fz-y+}"
    ], $burr_outer_z_bevel = [$burr_bevel, 1.75]);

}

module pieces_1() {
    
    burr_plate([
        [ "..xxxx|xxxx..|x{connect=fz-y+,clabel=A}xxx{connect=fz-y+,clabel=A}..|..xxxx",
          "..xxxx|xxxx..|xxxx..|..xxxx", 
          "..xxxx|......|......|..xxxx",
          "..x{label_text=Z,label_orient=x-z-}x{label_text=Y,label_orient=z+x-,label_hoffset=1}xx|......|......|..xxxx" ],
        [ "x{label_text=W,label_orient=x-z-}x{label_text=X,label_orient=z-x+,label_hoffset=-1}xx..|..x{connect=fz-y+,clabel=B}xxx{connect=fz-y+,clabel=B}|xxxx..|xxxx..",
          "xxxx..|..xxxx|xxxx..|xxxx..",
          "xxxx..|......|xx....|xxxx..",
          "xxxx..|......|xx....|xxxx.." ]
    ], $burr_outer_y_bevel = 1.75);
    
    translate([0, $burr_scale * 4 + $plate_sep, 0])
    burr_plate([
        [ "xxxx", "x{connect=mz+y+,clabel=A}xxx{connect=mz+y+,clabel=A}" ],
        [ "xxxx", "x{connect=mz+y+,clabel=B}xxx{connect=mz+y+,clabel=B}" ]
    ]);

}

module pieces_2() {
    
    burr_plate([
        [ "xxxx..|xxxxxx|..xx..|xxxx..",
          "xxxx..|xxxxxx|..xx..|xxxx..",
          "xxxx..|xx....|......|xxxx..",
          "x{label_text=Y,label_orient=x-z-}x{label_text=X,label_orient=z+x-,label_hoffset=1}xx..|xx....|......|xxxx.." ],
        [ "xxxx..|xxxx..|..xxxx|xxxx..",
          "xxxx..|xxxx..|..xxxx|xxxx..",
          "xxxx..|xx....|......|xxxx..",
          "x{label_text=W,label_orient=x-z-}x{label_text=Z,label_orient=z+x-,label_hoffset=1}xx..|xx....|......|xxxx..",
          "......|xx....|......|......",
          "......|xx....|......|......" ]
    ], $burr_outer_y_bevel = 1.75);

}
