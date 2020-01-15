include <puzzlecad.scad>

// This is a tutorial for puzzlecad, an OpenSCAD library for modeling mechanical puzzles.

// To obtain the latest version of puzzlecad: https://www.thingiverse.com/thing:3198014
// For an overview of interlocking puzzles: http://robspuzzlepage.com/interlocking.htm

// Puzzlecad is (c) 2019-2020 Aaron Siegel and is licensed for use under the
// Creative Commons - Attribution license. A copy of this license is available here:
// https://creativecommons.org/licenses/by/3.0/

// To view the effect of any of the examples in this tutorial, just put this file in
// the same directory as puzzlecad.scad, load it in OpenSCAD, and remove the asterisk
// preceding that example. (But just one at a time - remove multiple asterisks and you'll
// get a jumbled mess!)

// ======================================
// BASIC USAGE

// The basic puzzlecad command is the burr_piece module, which can be invoked in a variety
// of ways.

// Standard six-piece burr pieces can be generated just by specifying their Kaenel number.
// (See http://robspuzzlepage.com/interlocking.htm for the definition of Kaenel number.)
// Here's the "right-handed offset":
*burr_piece(975);

// General burr pieces are given by strings composed of the characters "x" and ".", where "x"
// signifies a filled location and "." an empty one. The following example is a simple "T"
// shaped piece from Stewart Coffin's Half Hour puzzle. Note how there are 2 substrings of "x"
// and "." characters, separated by a vertical bar "|".
*burr_piece(".x.|xxx");

// Multi-layer burr pieces are given by a vector of strings, one per layer. Here's a more
// complex piece, also from Half Hour. The single "x" in the second string corresponds to the
// single voxel (cube) in the upper layer:
*burr_piece([".xx|xx.", "...|.x."]);

// Sometimes it's convenient to generate all the pieces of a puzzle at once. The handy
// module burr_plate makes this easy to do. Bill Cutler's Burr #305:
*burr_plate([52, 615, 792, 960, 975, 992]);

// burr_plate arranges a whole vector of pieces on a single canvas. Here's all six pieces for
// Half Hour:
*burr_plate([
    ["xxx|.x.", "...|.x."],
    [".xx|xx.", "...|.x."],
    [".x.|xxx", "...|x.."],
    [".x.|xxx"],
    ["x..|xxx"],
    ["x.|xx", "..|.x"]
]);

// puzzlecad provides a range of options for customizing the size and appearance of a puzzle.
// For example, by default, puzzlecad renders pieces with cubes of dimension 11.15 mm. This
// is ideal for six-piece burr puzzles and similarly-sized interlocking puzzles, but for a
// design like Half Hour, it's uncomfortably small. The dimensions can be adjusted with the
// $burr_scale parameter, like so:
*burr_plate([
    ["xxx|.x.", "...|.x."],
    [".xx|xx.", "...|.x."],
    [".x.|xxx", "...|x.."],
    [".x.|xxx"],
    ["x..|xxx"],
    ["x.|xx", "..|.x"]
], $burr_scale = 17);

// Setting $burr_scale = 17 yields a much more comfortable size. It's recommended that you
// always use puzzlecad's $burr_scale parameter to resize a model, rather than (say)
// scaling the pieces up or down in your slicer. Scaling pieces in your slicer will likely
// result in a puzzle that's too loose or too tight; puzzlecad's $burr_scale parameter
// ensures that the pieces scale as desired, without also changing the tolerances.

// Here are some other useful parameters that you can specify in the same way:

// $burr_scale    specifies the size of a voxel (in millimeters). The default is 11.15.

// $burr_inset    specifies how much the edges of each burr piece should be "trimmed back"
//                (also in millimeters). Smaller values give a tighter fit; larger values
//                give a looser fit. The default is 0.07.

// $burr_bevel    specifies how much to bevel the edges. The default is 0.5, which gives a
//                very slight, clean rounding. A value between 1 and 1.5 will better approximate
//                typical beveling used in wood puzzles. A value of 0 gives no beveling
//                (sharp edges).

// $unit_beveled  Setting  $unit_beveled = true  will chamfer each individual cube of each piece.
//                Whether to do this or not is a purely aesthetic decision.

// Here's another rendering of Half Hour - exactly the same puzzle, but with a different look -
// showcasing several of the above options:
*burr_plate([
    ["xxx|.x.", "...|.x."],
    [".xx|xx.", "...|.x."],
    [".x.|xxx", "...|x.."],
    [".x.|xxx"],
    ["x..|xxx"],
    ["x.|xx", "..|.x"]
], $burr_scale = 17, $burr_bevel = 1, $unit_beveled = true);

// ======================================
// CONNECTORS

// Many puzzle pieces cannot be printed in one piece without supports, since there is no
// orientation for which they lie completely flat on the print bed. A good example of this is
// the following piece from Stewart Coffin's Interlock Four. No matter how it is rotated,
// some part of it will hang over empty space.
*burr_piece(["x..|xxx|...", "...|..x|..x"]);

// Puzzlecad provides a mechanism for coping with such pieces without supports, using an idea
// originally due to Rich Gain. Pieces like the above can be printed in two separate components,
// which can then be locked together using "snap joints". Here's what that looks like in practice:
*burr_plate([["x..|xxx{connect=mz+}"], ["x{connect=fz+}|x"]]);

// After the two components are printed, they can be snapped into place in the obvious manner.
// The joints are designed to form a strong, permanent connection once snapped together.
// They are intentionally tight and depending on the printer and materials used, they may need to
// be clamped or hammered into place.

// That "{connect=mz+}" after the final "x" in the first component is an annotation: it tells
// puzzlecad to attach a male connector in the z+ direction. Likewise, "{connect=fz+}"
// specifies a female connector pointing in the z+ direction. The "z+" is a standard directional
// indicator that is used throughout puzzlecad; it refers to the positive orientation on OpenSCAD's
// standard z axis. There are six directional indicators in all (x+, x-, y+, y-, z+, z-), which
// correspond one-to-one with the six faces of the cube.

// The joints are slightly ambiguous as printed: there are multiple ways to snap any pair of
// joints together; and if you're printing multiple pieces with joints, it can be hard to keep
// track of which components are intended to snap onto which others. To help keep things straight,
// puzzlecad provides an optional labeling feature. Here's the same piece as before, with labels:
*burr_plate([["x..|xxx{connect=mz+,clabel=Ay-}"], ["x{connect=fz+,clabel=Ay-}|x"]]);

// That "clabel=Ay-" annotation tells puzzlecad to stamp the letter "A" on the y- face of the joint.
// (If the labels are hard to see, try rendering with F6 rather than doing a preview. For the female
// connector, the label is stamped on the inside surface of the cavity, so you may need to rotate
// the OpenSCAD view a bit to see it.) This makes it easy to tell, during puzzle assembly, that the
// two "A" joints fit together, oriented so that the "A" labels come into contact.

// A huge variety of puzzle shapes can be formed without supports using snap joints. Here's the full
// Interlock Four puzzle:
*burr_plate([
    ["..x|xxx|x{connect=mz+,clabel=Ay-}.."], ["x|x", ".|x{connect=fz+,clabel=Ay-}"],
    ["x..|xxx|x.x", "...|...|x.."],
    ["x..|xxx{connect=mz+,clabel=By-}"], ["x{connect=fz+,clabel=By-}|x"],
    [".x|x{connect=mz+,clabel=Cy-}x"], ["x{connect=fz+,clabel=Cy-}x|.x"]
    ]);

// ======================================
// ORIENTED CONNECTORS

// Starting with version 2.0, puzzlecad provides a new type of "oriented" connector, tapered on one
// side. Here's our sample Interlock Four piece rendered using oriented connectors:
*burr_plate([["x..|xxx{connect=mz+y+,clabel=A}"], ["x{connect=fz+y+,clabel=A}|x"]]);

// To specify an oriented connector, put *two* orientations in the "connect" annotation: the first
// specifies the cube face to which the connector attaches (as before); the second specifies the
// direction in which to taper the connector. Then the label should be specified *without* any
// orientation, as it will *always* be placed opposite the taper.

// Oriented connectors slightly reduce the contact surface, but they have two huge advantages.
// First, it's easier to see how they align: the joints only fit together in one way. And second,
// female oriented connectors can be printed accurately in horizontal (x+, x-, y+, or y-) orientation,
// with the tip of the pentagon facing up. Here's a square connector and oriented connector side-by-side
// to illustrate what that means:
*burr_piece("x{connect=fy-}x{connect=fy-z+}");

// The square cavity will have a rough interior surface due to the "overhang" on the upper face, while
// the oriented cavity will have a smooth, accurate interior surface.

// Here's a final form of Interlock Four, with oriented connectors, ready for printing:
*burr_plate([
    ["..x|xxx|x{connect=mz+y+,clabel=A}.."], ["x|x", ".|x{connect=fz+y+,clabel=A}"],
    ["x..|xxx|x.x", "...|...|x.."],
    ["x..|xxx{connect=mz+y+,clabel=B}"], ["x{connect=fz+y+,clabel=B}|x"],
    [".x|x{connect=mz+y+,clabel=C}x"], ["x{connect=fz+y+,clabel=C}x|.x"]
    ], $burr_scale = 17, $burr_inset = 0.06, $burr_bevel = 1);

// ======================================
// LABELS



// ======================================
// DIAGONAL GEOMETRY

*burr_piece("x{components=z-}", $burr_inset = 0);

*burr_piece("x{components={z-,x-}}", $burr_inset = 0);

*burr_piece("x{components=z-y+}", $burr_inset = 0);

*union() {
    translate([1, 0, 0]) burr_piece("x{components=z-y-}", $burr_inset = 0);
    translate([0, 1, 0]) burr_piece("x{components=z-x-}", $burr_inset = 0);
    translate([1, 2, 0]) burr_piece("x{components=z-y+}", $burr_inset = 0);
    translate([2, 1, 0]) burr_piece("x{components=z-x+}", $burr_inset = 0);
}

*burr_piece([
    "x{components={z+x+,x+z+}}x{components={z+,x-z+,x+z+}}x{components={z+x-,x-z+}}",
    "x{components=z-x+}x{components=z-}x{components=z-x-}"
], $burr_inset = 0);

*burr_piece([
    "x{components={z+x+,x+z+}}x{components={z+,x-z+,x+z+}}x{components={z+x-,x-z+}}",
    "x{components=z-x+}x{components=z-}x{components=z-x-}"
], $burr_inset = 0, $post_rotate = [45, 0, 0], $post_translate = [0, 0, -1/2]);

// $post_rotate, $post_translate, joints

// ======================================
// 2D AND TRAY PUZZLES

// All of the above models are composed of adjoined cubes ("polycubes") that assemble or interlock
// to form a three-dimensional rectilinear shape. Another common puzzle type is the "tray-packing"
// puzzle, in which a set of two-dimensional pieces must be fitted into a flat opening. Puzzlecad
// provides built-in support for models of this type.

// It's particularly easy to model polyominoes in puzzlecad; just specify $burr_scale as a *vector*
// rather than a single number. Here's the L-Pentomino as an example. Setting $burr_scale to
// [16, 16, 5.6] will yield polyominoes out of 16 mm squares, with a 5.6 mm thickness:
*burr_piece("xxxx|x...", $burr_scale = [16, 16, 5.6]);

// Insets and beveling will be applied just as in the three-dimensional case, with all the usual
// options available ($burr_inset, $burr_bevel, etc).

// For two-dimensional puzzle pieces other than polyominoes, you can use the more general module
// beveled_prism, which takes a polygon as input and generates the corresponding prism, with
// appropriate beveling of the edges. (Make sure the vertices of the polygon wind clockwise, or
// you'll get an error.)
*beveled_prism([[0, 0], [0, 32], [16, 0]], height = 5.6);

// beveled_prism will honor the $burr_bevel parameter, but you'll need to do the scaling and apply
// insets (as appropriate) manually.

// To model trays, puzzlecad provides the convenient module packing_tray, which is highly
// customizable with lots of options. Let's start with an example; this is the actual tray for
// Stewart Coffin's classic design Four Fit:
*packing_tray(
    opening_width = 13 / sqrt(5),
    opening_depth = 11 / sqrt(5),
    piece_holder_spec = [".x|.x|xx|.x"],
    finger_wedge = [2, 2],
    render_as_lid = false,
    title = "Four Fit",
    subtitles = ["Stewart Coffin", "STC #217"],
    $tray_scale = 16
);

// puzzlecad will determine the optimal overall dimensions for the tray based on the supplied
// parameters. If render_as_lid is set to true, then a tray *lid* will be generated rather than the
// tray itself (try it!)
    
// Here's a summary of all the parameters for packing_tray:

// opening_width         the dimensions of the rectangular cavity in the tray, in units of
// opening_depth         $tray_scale

// piece_holder_spec     (optional) an ordinary burr piece specification; if specified, generates
//                       a separate opening that can be used to hold one of the pieces, for
//                       convenient storage when the puzzle is not in use

// finger_wedge          (optional) generates a disc-shaped cavity centered at the specified
//                       coordinates of piece_holder_spec, for ease of removal of the stored piece

// render_as_lid         (optional) if set to true, then a tray *lid* will be generated rather than a
//                       *tray*.

// title                 (optional) if specified, then the title and/or subtitle will be imprinted on
// subtitles             the surface of the tray lid.

// opening_polygon       use in place of opening_width and opening_depth; generates an arbitrary
//                       polygon for the opening, rather than a rectangle

// opening_polygons      use in place of opening_width and opening_depth; generates several (possibly
//                       disconnected) openings. this should be given as a vector of polygons

// piece_holder_polygon  use in place of piece_holder_spec; generates an arbitrary polygon for the
//                       piece holder, rather than a polyomino

// $tray_scale           

// $tray_padding

// $tray_opening_height

// $tray_opening_border

// $piece_holder_buf
