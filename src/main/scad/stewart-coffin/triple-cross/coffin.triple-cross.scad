include <puzzlecad.scad>

$burr_scale = 20;
$burr_inset = 0.11;
$burr_bevel = 1;

*piece();
*piece_length_4();
*piece_length_5();

module piece() {
    
    generalized_piece(3);
    
}

module piece_length_4() {
    
    generalized_piece(4);
    
}

module piece_length_5() {
    
    generalized_piece(5);
    
}

module generalized_piece(n) {

    spec = mkstring([
        for (i = [1:n])
        if (i % 2 == 1) "x{components={x-,z-,x+}}"
        else "x{components={x-,y+,x+}}"
    ]);
    burr_piece(spec);
    
}
