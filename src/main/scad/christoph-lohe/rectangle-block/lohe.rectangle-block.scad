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

*frame();
*pieces();

module frame() {
    
    burr_plate([
        ["xxxxxxxxxxxxxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxxxxxxxxxxxxx",
         "xxxxxxxxxxxxxx|x............x|x............x|x............x|x............x|x............x|x............x|x............x|x............x|xxxxxxxxxxxxxx",
         "x{connect=mz+y+}xxxxxx{connect=mz+y+}x{connect=mz+y+}xxxxxx{connect=mz+y+}|x............x|x............x|x............x|x............x|x............x|x............x|x............x|x............x|x{connect=mz+y+}xxxxxx{connect=mz+y+}x{connect=mz+y+}xxxxxx{connect=mz+y+}"
    ],
        ["x{connect=fz-y+}xxxxxx{connect=fz-y+}x{connect=fz-y+}xxxxxx{connect=fz-y+}|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|xxx........xxx|x{connect=fz-y+}xxxxxx{connect=fz-y+}x{connect=fz-y+}xxxxxx{connect=fz-y+}" ]
    ]);

}

module pieces() {

    burr_plate([
        
        [ "......|......|..xxxx|..xxxx|..xxxx|..xxxx",
          "xxxx..|xxxx..|xxxx..|xxxx..|......|......",
          "......|......|xxxx..|xxxx..|......|......",
          "......|......|..xxxx|..xxxx|..xxxx|..xxxx" ],
        [ "xxxx..|xxxx..|xxxx..|xxxx..",
          "xx....|xx....|xxxxxx|xxxxxx",
          "......|......|..xx..|..xx..",
          "xxxx..|xxxx..|xxxx..|xxxx.." ],
        [ "......|......|xxxx..|xxxx..|xxxx..|xxxx..",
          "xx....|xx....|xx....|xx....|xxxx..|xxxx..",
          "......|......|......|......|..xxxx|..xxxx",
          "......|......|xxxx..|xxxx..|xxxx..|xxxx.." ],
        [ "xxxx..|xxxx..|xxxx..|xxxx..|......|......",
          "......|......|..xxxx|..xxxx|..xxxx|..xxxx",
          "xx....|xx....|xxxx..|xxxx..|......|......",
          "xxxx..|xxxx..|xxxx..|xxxx..|......|......" ]
    ], $auto_layout = true);

}
