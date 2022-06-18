/* ====================================================================

  This is a 3D model of a mechanical puzzle. It is released under
  the following license:

  Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported
  https://creativecommons.org/licenses/by-nc-nd/3.0/

  This means the model is licensed for personal, noncommercial use
  only. Anyone may print a copy for their own use, but selling or
  otherwise monetizing the model or print (or any derivatives) is
  prohibited. For details, refer to the summary at the above URL.

  Puzzle design (c) Akaki Kuumeri

==================================================================== */
include <puzzlecad.scad>

$burr_scale = 15.24; //0.6 inch
$burr_bevel = 1;
$burr_inset = 0.07;
$plate_width = 210;
$joint_inset = 0.015;

// Uncomment one of the following lines to render that component.

*chocolate();
*wine();
*vegetable();
*fruit();
*subway();
*egg();
*ice_cream();
*cake();
*coffee();
*sandwich();
*salmiakki();
*chicken();
*hamburger();

module chocolate() {
    burr_plate([

        [".x.|...|.x.","xxx|.x|xx"],
        
        ["..x|...|...","..x|.x{label_text=      Akaki ,label_orient=z-x+,label_hoffset=0.2,label_scale=0.35}x|...","...|..x|..x"],
        
        ["x|.|.","x|x|.",".|x"],
        
        [".x.|xx{label_text= Chocolate    ,label_orient=z+x-,label_hoffset=0.2,label_scale=0.35}x|xx{label_text=        Basket    ,label_orient=z+x-,label_hoffset=0.2,label_scale=0.35}x","...|...|..x","...|...|..."]
        
        ],  $auto_layout = true);
}

module wine() {
    burr_plate([

        ["...|...|...","..x|...|..x","xxx|..x|x{label_text=     Akaki,label_orient=y-x+,label_hoffset=0.2,label_scale=0.35}xx"],
    
        ["x{label_text=       Wine ,label_orient=x+z+,label_hoffset=0.2,label_scale=0.35}..|x..|...","x..|xx{label_text=     Basket ,label_orient=y-z+,label_hoffset=0.2,label_scale=0.35}.|...","...|xx.|..."],
        
        [".x|.x|xx",".x|...|xx"],
        
        ["..x|..x|..x"]
        
        ],  $auto_layout = true);
}


module vegetable() {
    burr_plate([
    
    //This puzzle has two solutions. The solution with no voids visible on top is the canonical solution.
    
        ["...|...|xx.","...|...|x{label_text=  Basket,label_orient=y-z-,label_hoffset=0.2,label_scale=0.3}..","x{label_text=       Vegetable,label_orient=z-y+,label_hoffset=0.2,label_scale=0.3}x.|x..|x.."],
    
        ["...|.x{label_text=       Akaki,label_orient=x+z+,label_hoffset=0.2,label_scale=0.35}.|...","...|.x.|...","..x|.xx|..."],
        
        ["...|...|...","..x|..x|.xx","...|...|.xx"],
        
        ["xxx|x.x|..x","x..|...|...","...|...|..."]
        
        ],  $auto_layout = true);
}


module fruit() {
    burr_plate([

        ["...|...|x..","...|...|x{label_text=    Basket,label_orient=y-z-,label_hoffset=0.2,label_scale=0.35}..","x{label_text=       Fruit,label_orient=z-y+,label_hoffset=0.2,label_scale=0.35}x.|x..|x.."],
    
        ["...|...|...","...|xx.|...","..x|.xx{label_text=    Akaki,label_orient=z-y-,label_hoffset=0.2,label_scale=0.35}|..."],
        
        ["..x|...|...",".xx|..x|..x","...|...|.xx"],
        
        ["xx.|xxx|.xx","x..|...|.x.","...|...|..."]
        
        ],  $auto_layout = true);
}


module subway() {
    burr_plate([

        ["xxx|x{label_text=    Basket,label_orient=z+y-,label_hoffset=0.2,label_scale=0.35}..|xxx","...|...|x.","...|...|x{label_text=     Subway,label_orient=y-z-,label_hoffset=0.2,label_scale=0.35}x.."],
    
        ["...|.x.|...","x..|xx.|.xx","x..|...|..."],
        
        ["...|..x{label_text=       Akaki,label_orient=y-z+,label_hoffset=0.2,label_scale=0.35}|...","...|..x|...",".xx|xxx|..x"]
        
        ],  $auto_layout = true);
}


module egg() {
    burr_plate([

        [".xx|..x|x{label_text=     Akaki ,label_orient=y-x+,label_hoffset=0.2,label_scale=0.35}xx","...|...|..x"],
    
        ["...|.x.|...","...|.x.|...","...|xx.|x.."],
        
        ["x{label_text=      Basket,label_orient=x+y+,label_hoffset=0.2,label_scale=0.35}..|x..|...","xx.|x{label_text=Egg   ,label_orient=x+y+,label_hoffset=0.2,label_scale=0.35}..|x{connect=mx+z-}.","x..|...|..."],
        ["x{connect=fz+y-}|x"],
        
        ["...|...|...","...|..x|...",".xx|..x|..x"]
            
        ],  $auto_layout = true);
}


module ice_cream() {
    burr_plate([

        ["...|x..|xx{connect=fx+z-}.","...|...|x..","...|...|xx."],
        [".xx|..x{label_text=    Basket,label_orient=z+y+,label_hoffset=0.2,label_scale=0.35}|..x{connect=mx-z-}","..x|...|...",".x{label_text=  Ice     ,label_orient=y+z-,label_hoffset=0.2,label_scale=0.35}x{label_text=        Cream    ,label_orient=y+z-,label_hoffset=0.2,label_scale=0.35}|...|..."],
        
        ["...|...|...",".x.|.xx|.x."],
        
        ["x..|.","x{label_text=        Akaki     ,label_orient=y+z-,label_hoffset=0.2,label_scale=0.35}","x|x"],
        ["...|...|...","...|...|..x",".|.xx|..x"]
        
        ],  $auto_layout = true);
}


module cake() {
    burr_plate([

        ["...|...|x..","...|x..|x{label_text=    Cake Basket       ,label_orient=x+z+,label_hoffset=0.2,label_scale=0.35}..","xx{label_text=Akaki     ,label_orient=z-x+,label_hoffset=0.2,label_scale=0.35}x|xx.|x.."],
    
        [".xx|...|...","..x|.xx|...","...|..x|.xx"],
        
        ["x..|xxx|..x","x..|...|..x","...|...|..."]
        
        ],  $auto_layout = true);
}


module coffee() {
    burr_plate([

        ["x..|...","x..|...","xx.|x.."],
        ["..x|...|...","..x{label_text=    Akaki,label_orient=y+z-,label_hoffset=0.2,label_scale=0.35}|...|...","..x|.xx|..."],
        
        
        
        
        [".x.|.xx|..x{connect=mz+y+,clabel=A}",".x."],
        ["...|...|..x{connect=fz-y+,clabel=A}","...|...|.xx"],
        
        ["...|x..|xx{label_text=    Basket,label_orient=y-z+,label_hoffset=0.2,label_scale=0.35}.","...|...|x{label_text=    Coffee ,label_orient=y-z+,label_hoffset=0.2,label_scale=0.35}x.","...|...|x.."]
        
        ],  $auto_layout = true);
}


module sandwich() {
    burr_plate([

        ["xxx|x{label_text=Sandwich            ,label_orient=z+y-,label_hoffset=0.2,label_scale=0.3}..|xx.","x{label_text=    Basket,label_orient=y+z+,label_hoffset=0.2,label_scale=0.3}|.|.","xx|.|."],
    
        ["...|...|..x",".xx|..x|.xx","..."],
        
        ["...|.x.|...","...|.x{label_text=    Akaki,label_orient=y+z+,label_hoffset=0.2,label_scale=0.3}.|...","..x|.xx|..x"],
        
        ["...|...|...","...|...|x..","...|x..|xx"]
        
        ],  $auto_layout = true);
}


module salmiakki() {
    burr_plate([

        ["x{label_text=      Basket ,label_orient=z+x+,label_hoffset=0.2,label_scale=0.35}xx|x{label_text=          Salmiakki ,label_orient=z+x+,label_hoffset=0.2,label_scale=0.35}xx|x..","..x|...|x..",".xx|...|..."],
    
        ["...|...|...","xx.|...|...","x..|x{label_text=    Akaki ,label_orient=z-y+,label_hoffset=0.2,label_scale=0.35}..|xx."],
        
        ["...|...|.x.","...|xx.|.x."],
        ["...|...|...","...|...|..x","...|.xx|..x"],
        
        ],  $auto_layout = true);
}


module chicken() {
    burr_plate([

        [".xx|..x|.xx","...|..x|..x","...|...|..."],
    
        ["...|.x.|x..","...|.x.|xx.",".xx|.xx|..."],
        
        ["...|x..|...","...|x{label_text=    Akaki,label_orient=y-z-,label_hoffset=0.2,label_scale=0.3}..|...","x{label_text=     Chicken,label_orient=x+y+,label_hoffset=0.2,label_scale=0.3}..|x..|xx{label_text=    Basket,label_orient=y-x+,label_hoffset=0.2,label_scale=0.3}x"],
        
        ],  $auto_layout = true);
}



module hamburger() {
    burr_plate([

        ["xx{connect=mx+y+}.|x..|xx.","...|...|x..","...|...|x{label_text=       Akaki,label_orient=y-z-,label_hoffset=0.2,label_scale=0.35}x."],
        ["..x{connect=fx-y+}|...|...","..x|...|...",".xx|...|..."],
        
        ["...|...|..x",".x.|xx.|.xx","...|...|..."],
        
        ["...|...|...","x..|...|...","x..|x{label_text=          Hamburger,label_orient=z-x+,label_hoffset=0.2,label_scale=0.35}x{label_text=Basket          ,label_orient=y+x+,label_hoffset=0.2,label_scale=0.35}x|..x"]
        
        ],  $auto_layout = true);
}
