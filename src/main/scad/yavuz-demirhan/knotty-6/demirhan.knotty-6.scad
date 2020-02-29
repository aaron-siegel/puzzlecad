include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$burr_scale = 12;
$burr_inset = 0.07;
$burr_bevel = 1;

*piece();
*alternate_piece();
*inscribed_piece();

module piece() {
    
    burr_piece("xxxx.|x..x.|x....|xxxxx");
    
}

module alternate_piece() {

    burr_piece("xxxx.|x....|x..x.|xxxxx");

}

module inscribed_piece() {
    
    burr_piece("xxx{label_text=Y. Demirhan,label_orient=z+x+,label_hoffset=-0.5,label_scale=0.4}x.|x..x.|x....|xxx{label_text=Knotty 6,label_orient=z+x+,label_hoffset=-0.5}xx");
    
}
