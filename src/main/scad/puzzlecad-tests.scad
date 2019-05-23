include <puzzlecad.scad>

// Burr piece with prominent bevels to test various interior and exterior bevel effects.
*burr_piece(["xx|.x", ".x|.."], $burr_bevel = 1.5);

// Burr piece with a very prominent inset.
*burr_piece(["xx|.x", ".x|.."], $burr_inset = 2, $burr_bevel = 1.5);

// Burr piece with negative inset (= enlarged cubes). Doesn't work yet with beveling.
*burr_piece(["xx|.x", ".x|.."], $burr_inset = -2, $burr_bevel = 0);

// Burr piece with different scale on each dimension.
*burr_piece(["xx|.x", ".x|.."], $burr_scale = [10, 20, 30], $burr_bevel = 1.5);

// Burr piece with different inset on each dimension.
*burr_piece(["xx|.x", ".x|.."], $burr_inset = [0, 1.5, 3], $burr_bevel = 1.5);

// Simple connector test:
*burr_plate([
    ["x{connect=mz+,clabel=Lx+}"]
]);

// Male connector test:
*burr_plate([
    ["x{connect=mz+,clabel=Lx+}"],
    ["x{connect=mz+,clabel=Ly-}"],
    ["x{connect=mz+,clabel=Lx-}"],
    ["x{connect=mz+,clabel=Ly+}"],
    ["x{connect=mz-,clabel=Lx+}"],
    ["x{connect=mz-,clabel=Ly-}"],
    ["x{connect=mz-,clabel=Lx-}"],
    ["x{connect=mz-,clabel=Ly+}"],
    ["x{connect=my+,clabel=Lx+}|."],
    ["x{connect=my+,clabel=Lz-}|."],
    ["x{connect=my+,clabel=Lx-}|."],
    ["x{connect=my+,clabel=Lz+}|."],
    ["x{connect=my-,clabel=Lx+}"],
    ["x{connect=my-,clabel=Lz-}"],
    ["x{connect=my-,clabel=Lx-}"],
    ["x{connect=my-,clabel=Lz+}"],
    ["x{connect=mx+,clabel=Lz+}."],
    ["x{connect=mx+,clabel=Ly-}."],
    ["x{connect=mx+,clabel=Lz-}."],
    ["x{connect=mx+,clabel=Ly+}."],
    [".x{connect=mx-,clabel=Lz+}"],
    [".x{connect=mx-,clabel=Ly-}"],
    [".x{connect=mx-,clabel=Lz-}"],
    [".x{connect=mx-,clabel=Ly+}"]    
], $plate_width = 75, $joint_inset = 0);

// Female connector test:
*burr_plate([
    ["x{connect=fz+,clabel=Lx+}"],
    ["x{connect=fz+,clabel=Ly-}"],
    ["x{connect=fz+,clabel=Lx-}"],
    ["x{connect=fz+,clabel=Ly+}"],
    ["x{connect=fz-,clabel=Lx+}"],
    ["x{connect=fz-,clabel=Ly-}"],
    ["x{connect=fz-,clabel=Lx-}"],
    ["x{connect=fz-,clabel=Ly+}"],
    ["x{connect=fy+,clabel=Lx+}"],
    ["x{connect=fy+,clabel=Lz-}"],
    ["x{connect=fy+,clabel=Lx-}"],
    ["x{connect=fy+,clabel=Lz+}"],
    ["x{connect=fy-,clabel=Lx+}"],
    ["x{connect=fy-,clabel=Lz-}"],
    ["x{connect=fy-,clabel=Lx-}"],
    ["x{connect=fy-,clabel=Lz+}"],
    ["x{connect=fx+,clabel=Lz+}"],
    ["x{connect=fx+,clabel=Ly-}"],
    ["x{connect=fx+,clabel=Lz-}"],
    ["x{connect=fx+,clabel=Ly+}"],
    ["x{connect=fx-,clabel=Lz+}"],
    ["x{connect=fx-,clabel=Ly-}"],
    ["x{connect=fx-,clabel=Lz-}"],
    ["x{connect=fx-,clabel=Ly+}"]
], $plate_width = 75, $joint_inset = 0);

// This particular example caused some manifold-related rendering grief
// with OpenSCAD 2019.05 (the issue has been fixed, but keeping the test
// here just in case):
*burr_piece(["xxx{connect=mz+}|x.."]);

*burr_piece("x{connect=fz+,clabel=Ay-}");

*burr_plate([["x{connect=my-}...|x{connect=fz+}x{connect=mz+}x.|...."]]);

*burr_piece(975, label = "975");
