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

// Sometimes it's convenient to generate all the pieces of a puzzle at once. The convenience
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
// TRAY PUZZLES

// ======================================
// DIAGONAL GEOMETRY
