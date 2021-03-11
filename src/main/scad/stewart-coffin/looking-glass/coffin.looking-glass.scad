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

$burr_scale = [16, 16, 5.6];

$box_wall_thickness = [8, 8, 3];
$box_inset = [0.07, 0.07, 0.3];

*pieces();
*tray();

module pieces() {
   
    burr_plate([
        "xxxx|...x",
        "xxx|..x",
        "xxx|.x.",
        ".xx|xx.",
        "xxx|..x|..x",
        "xx|.x"
    ]); 
    
}

module tray() {
    
    packing_box([
        "xxxxxxx|xxxxxxx|xxxxxxx|xxxxxxx|xxxxxxx|xxxxxxx|xxxxxxx",
        "xxxxxxx|x......|x......|x.....x|x.....x|x.....x|xxxxxxx",
        "xxxxxxx|x+++++x|x+++++x|x+++{circle=1}++x|x+++++x|x+++++x|xxxxxxx"
    ], $plate_width = 200, $auto_layout = true);

}
