include <puzzlecad.scad>

$burr_scale = 32;
$burr_inset = 0;//0.12;
$burr_bevel = 0.06;
$plate_width = 260;
$post_rotate = [0, 45, 0];

*solid();
color1();
*color2();

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
        
    ], $post_translate = [-(sqrt(2)+1)/2, 0, (sqrt(2)-1)/2]);
    
}

module color1() {
    
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
    
    ], $post_translate = [-(sqrt(2)+1)/2, 0, (sqrt(2)-1)/2]);
    
}

module color2() {
    
    burr_plate([
        ["x{components=z+x+}.", "x{components={z-x+,x+z-}}x{components=x-z-,connect=dmy+x-~,clabel=A}"],
        ["x{components=z+x+}.|..", "x{components={z-x+,x+z-}}x{components=x-z-}|.x{components={},connect=dmy-x-~,clabel=B}"]
    ], $post_translate = [-1/2, 0, -1/2], $plate_width = $burr_scale * 3);

}

function tip1(label) = [
    "x{components=z+x+}.",
    str_interpolate("x{components={z-x+,x+z-}}x{components=x-z-,connect=dmy+x-~,clabel=$0}", label)
];

function tip2(label) = [
    "x{components=z+x+}.",
    str_interpolate("x{components={z-x+,x+z-}}x{components=x-z-,connect=dmy+z+~,clabel=$0}", label)
];

