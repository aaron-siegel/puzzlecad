include <puzzlecad.scad>

$burr_scale = 27;
$burr_inset = 0.12;
$burr_bevel = 0.6;
$post_rotate = [0, 45, 0];

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
    
    ], $post_translate = [0, 0, sqrt(1/2)]);
    
}

module tips() {

    burr_plate([
        ["x{components=z+x+}.", "x{components={z-x+,x+z-}}x{components=x-z-,connect=dmy+x-~,clabel=A}"],
        ["x{components=z+x+}.|..", "x{components={z-x+,x+z-}}x{components=x-z-}|.x{components={},connect=dmy-x-~,clabel=B}"]
    ], $plate_sep = 20);

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
        
    ], $post_translate = [0, 0, sqrt(1/8)]);
    
}
