include <puzzlecad.scad>

require_puzzlecad_version("2.0");

$tray_scale = 16;

// Uncomment one of the following three lines to render that component.

*pieces();
*tray();
*lid();

module pieces() {
    
    burr_plate([
        ["xxxx|..x."], ["xx.|.x.|.xx"], ["xxx|.x.|.x."], ["x..|xxx|.x."]
    ], $burr_scale = [$tray_scale, $tray_scale, $tray_opening_height], $plate_width = 150, $burr_inset = 0.05);
    
}

module tray(render_as_lid = false) {
    
    packing_tray(
        opening_width = 13 / sqrt(5),
        opening_depth = 11 / sqrt(5),
        piece_holder_spec = [".x|.x|xx|.x"],
        finger_wedge = [2, 2],
        render_as_lid = render_as_lid,
        title = "Four Fit",
        subtitles = ["Stewart Coffin", "STC #217"]
    );
    
}

module lid() {
    
    tray(render_as_lid = true);
    
}
