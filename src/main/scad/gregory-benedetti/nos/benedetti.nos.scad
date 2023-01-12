include <puzzlecad.scad>


$burr_scale = 11.15;

// $burr_inset value for each of the 7 puzzles:
insets = [0.06, 0.08, 0.07, 0.06, 0.07, 0.07, 0.07];

// This can be used to uniformly adjust the insets up or down:
inset_delta = 0;

// Use a very slight interior bevel; intersect with a hull later to get a larger exterior bevel
$burr_bevel = 0.1;

// OpenSCAD is fussy about some of these shapes. If you get GCAL errors rendering them, try flushing
// the cache ("Flush Caches" in the Design menu) and re-render directly in render mode (F6).

*nos1_compressed();
*nos2_transfer();
*nos3_round_trip();
*nos4_go_back();
*nos5_crenel();
*nos6_dodge();
*nos7_seizaine();

module nos1_compressed() {

    $burr_inset = insets[0] + inset_delta;
    $plate_width = $burr_scale * 7;
    burr_plate([
        ["xxx{components=sy-z+}.x{connect=mz+y+,clabel=A}x|xxxxxx", "x....x|x...x{components=sx-z-}x"],
        ["xxx{components=sy+z+}x{components=sy+z+}xx|xx..xx",
         "xx{components=sx-z-}...x|xx{components=sx-z-}..x{components=sx+z+}x"],
        ["x{components=sx+y-}x{connect=fz-y+,clabel=A}"]
    ]);

}

module nos2_transfer() {

    $burr_inset = insets[1] + inset_delta;
    $joint_style = "flush";
    $plate_width = $burr_scale * 7;
    burr_plate([
        ["xxx{components=sy+z+}x{components=sy+z+}xx|xx.x{components=sy+z-}xx",
         "xx{components=sy-z-}..x{components=sx+z-}x|x...x{components=sx+z-}x"],
        ["xx.x{components=sx+y+}xx|xxx{components=sy-z+,connect=mz+y-,clabel=B}x{components=sy-z+}xx",
         "x...x{components=sx+z-}x|x...x{components=sx+z-}x"],
        [".x{components=sx-y+}..|.x{connect=fz+y-,clabel=B}x{components=sx-z-}."]
    ]);
    
}

module nos3_round_trip() {
    
    $burr_inset = insets[2] + inset_delta;
    burr_plate([
        ["xxxxxx|xxxxxx", "xx{components=sx-z-}x.x{components=sx+z-}x|xx{components=sx-z-}x.x{components=sx+z-}x"],
        ["xx..xx|xxxxxx", "xx{components=sx-z-}..x{components=sx+z-}x|xx{components=sx-z-}..x{components=sx+z-}x"],
        ["xxx{components=sy-z+}x{components=sy-z+}xx|xxxxxx", "x....x|x....x"],
        ["xxx{components=sy-z+}x{components=sy-z+}xx|xxx{components=sy+z+}x{components=sy+z+}xx", "x....x|x....x"],
        ["xxx{components=sy+z+}.xx|xxx{components=sy-z+}x{components=sy-z+}xx", "x....x|x...x{components=sx+z+}x"],
        ["xx..xx|xxx{components=sy-z+}x{components=sy-z+}xx", "x....x|xx{components=sx-z+}..x{components=sx+z+}x"]
    ]);
    
}

module nos4_go_back() {
    
    $burr_inset = insets[3] + inset_delta;
    $use_diag_voxel_expand_hack = true;
    burr_plate([
        ["xxx{components=sx+y+}x{components=sx-y+}xx|xxx{components=sy-z+}xxx",
            "x...x{components=sx+y+}x|xxx{components=sx-y-}x{components=sx+y+}x{components=sx-y-}x"],
        ["xxx{components=sx+y+}x{components=sx-y+}xx|xxx{components=sx-z+}x{components=sx+z-}xx",
            "xx{components=sy+z-}...x|xx{components=sy-z+}x{components=sx+z-}..x"],
        ["xx..xx|xxxxxx", "x....x|xx{components=sx-z-}...x"],
        ["xx..xx|xxx{components=sy+z+}x{components=sy+z+}xx", "xx{components=sy+z-}...x|x....x"],
        ["xxx{components=sy+z-}x{components=sy+z-}x{components=sy-z-}x|xxx{components=sx+z+}x{components=sx-z+}x{components=sy+z-}x",
            "x....x|xx{components=sx-z+}...x"],
        ["xx{components=sy-z-}..xx|xx{components=sy+z-}x{components=sx-y+}x{components=sx+y-}xx",
            "x....x{components=sx+y-}|x.x{components=sy-z-}x{components=sy-z-}.x{components=sx+y+}"]
    ]);
    
}

module nos5_crenel() {
    
    $burr_inset = insets[4] + inset_delta;
    burr_plate([
        ["xxxxxx|xxxxxx", "x....x|xx{components=sx-z+}x{components=sx+z-}x{components=sx-z+}x{components=sx+z-}x"],
        ["xxxxxx|xxxxxx", "x.x{components=sy+z-}..x|x.x{components=sx+z-}x{components=sx-z-}x{components=sx+z+}x"],
        ["xx..xx|xxxx{components=sy+z+}xx", "x....x|xx{components=sy-z+}..x{components=sx+z+}x"],
        ["xx..xx|xxx{components=sy-z+}x{components=sy-z+}xx", "x....x|xx{components=sx-z+}.x{components=sy+z-}x{components=sy-z+}x"],
        ["xx.x{components=sx+y-}xx|xxx{components=sy+z+}x{components=sy+z+}xx", "x....x|x.x{components=sy-z-}x{components=sx-z-}.x"],
        ["xxx{components=sx-y-}.xx|xxx{components=sy+z+}x{components=sy+z+}xx", "x....x|x....x"]
    ]);
    
}

module nos6_dodge() {
    
    $burr_inset = insets[5] + inset_delta;
    burr_plate([
        ["xx{components=sx-y+}x{components=sx+y-}x{components=sx-y+}x{components=sy-z+}x|xxxx{components=sy-z-}xx", "x...x{components=sy+z-}x|xx..xx"],
        ["xxx{components={x+y-,y-x+,x+z+,z+x+,y-z+,z+y-,z+x-,z+y+}}x{components=sy-z+}xx|xxx{components=sy+z+}x{components=sy+z+}xx", "xx{components=sx+z+}x{components=sx-y+}..x|x...x{components=sx+z-}x"],
        ["xxx{components=sy-z+}.xx|xxxxxx", "x...x{components=sx+z+}x|x....x"],
        ["xx..xx|xxx{components=sy-z+}x{components=sy-z+}xx", "x....x|xx{components={x-y-,y-x-,x-z+,z+x-,y-z+,z+y-,x-z-,x-y+}}x{components=sy+z-}x{components=sy+z-}x{components=sx+z+}x"],
        ["xx..xx|xxx{components=sx-y+}x{components=sx+y-}xx", "x....x|x.x{components=sy-z-}x{components={x-y-,y-x-,x-z-,z-x-,y-z-,z-y-,z-x+,z-y+}}x{components=sx+z+}x"],
        ["xx{components=sy-z-}x{components=sy-z-}.x{components=sy-z-}x|xxx{components=sy+z+}x{components=sy+z+}xx", "x....x|x...x{components=sy-z-}x"]
    ]);
    
}

module nos7_seizaine() {

    $burr_inset = insets[6] + inset_delta;
    $use_diag_voxel_expand_hack = true;
    burr_plate([
        ["xxx{components=sx-y+}x{components=sx-y+}xx|xxxxxx", "x....x|x.x{components=sx-z-}.xx"],
        ["xxx{components=sy+z+}x{components=sy+z+}xx|xxx{components=sx+y-}x{components=sx-y-}xx", "x.x{components=sy+z+}x{components=sy-z-}.x|x.x{components=sy-z-}..x"],
        ["xx.x{components=sy+z+}xx|xxxxxx", "xx{components=sx-z-}...x|x....x"],
        ["xx..xx|xxx{components=sy-z+}x{components=sy-z+}xx", "xx{components=sx-z-}...x|xx{components=sx-z-}x{components=sx+z+}x{components=sy-z-}.x"],
        ["xxx{components=sx-y-}.x{components=sy-z-}x|xxxxx{components=sy+z-}x", "x....x|x..x{components=sx-z-}.x"],
        ["xx..xx|xxx{components=sy+z+}xxx", "xx{components=sy+z+}...x|xx{components=sx-y-}...x{components=sx+y+}"]
    ]);
    
}

module nos2_transfer_alternate() {
    
    $burr_inset = insets[1] + inset_delta;
    burr_piece(["xx.x{components=sx+y+}xx|xxx{components=sy-z+}x{components=sy-z+}xx",
        "x.x{components=sx+y+}x{components=sx-z-}x{components=sx+z-}x|xx{components=sx+z+}x{components=sy-z-}.x{components=sx+z-}x"]);
    
}

module minkowski_inset_shape(inset) {
    
    cube(2 * inset, center = true);
    
}

module minkowski_bevel_cutout_shape(bevel) {
    
    cube(2 * bevel, center = true);
    
}

module post_process_burr_piece() {
    
    intersection() {
        children(0);
        burr_piece_base(1, $burr_bevel = 0.5, $burr_outer_x_bevel = 1.75);
    }
    
}
