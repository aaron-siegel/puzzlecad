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
