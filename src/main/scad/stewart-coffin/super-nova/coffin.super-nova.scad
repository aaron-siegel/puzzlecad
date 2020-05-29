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

require_puzzlecad_version("2.0");

$burr_scale = 27;
$burr_inset = 0.14;      // Use 0.12 for a tighter fit
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

// Uncomment one of the following lines to render that module.

*bases();
*tips();

module bases() {
    
    burr_plate([
    
        [".x{components={y+z+,z+y+,z+x-}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
    "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}.|.x{components={z-y-,x+z-,z-x+},connect=dfx+z-~,clabel=A}x{components=x-z-}"
        ],
    
        [".x{components={y+z+,z+y+,z+x-}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
    "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}.|.x{components={z-y-,x+z-,z-x+},connect={dfx+z-~,dfx+y+~},clabel={A,B}}x{components=x-z-}"
        ],
    
        [".x{components={y+z+,z+y+,z+x-}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
    "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}x{components={},connect=dfx-z-~,clabel=A}|.x{components={z-y-,x+z-,z-x+},connect={dfx+z-~,dfx+y+~},clabel={A,B}}x{components=x-z-}"
        ],
    
        [".x{components={y+z+,z+y+,z+x-}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
    "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}.|.x{components={z-y-,x+z-,z-x+},connect=dfx+y+~,clabel=B}x{components=x-z-}"
        ],
     
        [".x{components={y+z+,z+y+,z+x-}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
    "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}x{components={},connect=dfx-z-~,clabel=A}|.x{components={z-y-,x+z-,z-x+},connect=dfx+y+~,clabel=B}x{components=x-z-}"
        ],
    
        [".x{components={y+z+,z+y+,z+x-}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+}}.",
    "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}x{components={},connect=dfx-y-~,clabel=B}|.x{components={z-y-,x+z-,z-x+},connect={dfx+z-~,dfx+y+~},clabel={A,B}}x{components=x-z-}"
        ],
    
    ]);
    
}

module tips() {

    burr_plate([
        ["x{components=z+x+}.", "x{components={z-x+,x+z-}}x{components=x-z-,connect=dmy+x-~,clabel=A}"],
        ["x{components=z+x+}.|..", "x{components={z-x+,x+z-}}x{components=x-z-}|.x{components={},connect=dmy-x-~,clabel=B}"]
    ]);

}

function tip1(label) = [
    "x{components=z+x+}.",
    str_interpolate("x{components={z-x+,x+z-}}x{components=x-z-,connect=dmy+x-~,clabel=$0}", label)
];

function tip2(label) = [
    "x{components=z+x+}.",
    str_interpolate("x{components={z-x+,x+z-}}x{components=x-z-,connect=dmy+z+~,clabel=$0}", label)
];

// The solid forms can be useful for visualizing the structure of pieces.
// But to actually print them, snap joints would be needed anyway; so we might as
// well just use the 2-color version.

module solid() {
    
    burr_plate([
    
        [".x{components={y+z+,z+y+,z+x-}}.|x{components=x+y+}x{components={z+,y-z+,y+z+,y+x-,x-y+}}.|.x{components={y-z+,z+y-,z+x+,y-x-}}.",
    "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}.|.x{components={z-y-,x+z-,z-x+}}x{components=x-z-}"
        ],
    
        [".x{components={y+z+,z+y+,z+x-}}.|x{components=x+y+}x{components={z+,y-z+,y+z+,y+x-,x-y+}}.|.x{components={z+x-,y-z+,z+y-,z+x+,y-x-}}.",
    "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}.|x{components=x+z-}x{components={z-x-,x-z-,z-y-,x+z-,z-x+}}x{components=x-z-}"
        ],
    
        [".x{components={y+z+,z+y+,z+x-,y+x+}}.|x{components=x+y+}x{components={z+,y-z+,y+z+,y+x-,x-y+,y-x+,x+y-}}x{components=x-y-}|.x{components={z+x-,y-z+,z+y-,z+x+,y-x-}}.",
    "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}.|x{components=x+z-}x{components={z-x-,x-z-,z-y-,x+z-,z-x+}}x{components=x-z-}"
        ],
    
        [
    ".x{components={y+z+,z+y+,z+x-}}.|.x{components={z+,y-z+,y+z+}}.|.x{components={y-z+,z+y-,z+x+,z+x-}}.",
    "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}.|x{components=x+z-}x{components={z-y-,x+z-,z-x+,x-z-,z-x-}}x{components=x-z-}"
        ],
    
        [".x{components={y+z+,z+y+,z+x-,y+x+}}.|.x{components={z+,y-z+,y+z+,y-x+,x+y-}}x{components=x-y-}|.x{components={z+x-,y-z+,z+y-,z+x+}}.",
    "x{components=x+z-}x{components={z-y+,z-x-,x-z-}}.|.x{components=z-}.|x{components=x+z-}x{components={z-x-,x-z-,z-y-,x+z-,z-x+}}x{components=x-z-}"
        ],
    
        [".x{components={y+z+,z+y+,z+x-,z+x+}}.|x{components=x+y+}x{components={z+,y-z+,y+z+,y+x-,x-y+}}.|.x{components={z+x-,y-z+,z+y-,z+x+,y-x-}}.",
    "x{components=x+z-}x{components={z-y+,z-x-,x-z-,z-x+,x+z-}}x{components=x-z-}|.x{components=z-}.|x{components=x+z-}x{components={z-x-,x-z-,z-y-,x+z-,z-x+}}x{components=x-z-}"
        ],
        
    ]);
    
}
