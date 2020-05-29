/* ====================================================================

  This is puzzlecad, an OpenSCAD library for modeling mechanical
  puzzles. It is provided as part of the Printable Puzzle Project:
  https://puzzlehub.org/ppp

  To obtain the latest version of puzzlecad:
  https://www.thingiverse.com/thing:3198014

  Puzzlecad code repository:
  https://github.com/aaron-siegel/puzzlecad

  puzzlecad is (c) 2019-2020 Aaron Siegel and is distributed under
  the MIT license. This means you may use or modify puzzlecad for any
  purposes, including commercial purposes, provided that you include
  the attribution "puzzlecad is (c) 2019-2020 Aaron Siegel" in any
  distributions or derivatives of puzzlecad, along with a copy of
  the MIT license.

  For details of this license, please refer to the license-mit.txt
  file distributed with puzzlecad, or visit:
  https://opensource.org/licenses/MIT

  NOTE THAT WHILE THE PUZZLECAD LIBRARY IS RELEASED UNDER THE MIT
  LICENSE, INDIVIDUAL PUZZLE DESIGNS (INCLUDING VARIOUS DESIGNS THAT
  ARE STORED IN THE PUZZLECAD GITHUB REPO) ARE SHARED UNDER A MORE
  RESTRICTIVE LICENSE. You may not use copyrighted puzzle designs for
  commercial purposes without explicit permission from the copyright
  holder(s).

==================================================================== */

include <puzzlecad.scad>

burr_parser_test_cases = [

    ["Simple Array",
     [".xx.|.xx.", "....|..x."],
     [[[[0], [0]], [[0], [0]]], [[[24], [0]], [[24], [0]]], [[[24], [0]], [[24], [24]]], [[[0], [0]], [[0], [0]]]]
    ],
    
    ["Multi-Component Array",
     [".aa.|.bc.", "....|..c."],
     [[[[0], [0]], [[0], [0]]], [[[1], [0]], [[2], [0]]], [[[1], [0]], [[3], [3]]], [[[0], [0]], [[0], [0]]]]
    ],
    
    ["Kaenel Number",
     975,
     [[[[1], [1]], [[1], [1]]], [[[1], [1]], [[1], [1]]], [[[0], [0]], [[1], [1]]], [[[0], [0]], [[1], [0]]], [[[1], [0]], [[1], [0]]], [[[1], [1]], [[1], [1]]]]
    ],
    
    ["Voxel with Connector",
     ["x{connect=mz+,clabel=Ay-}x"],
     [[[[24, [["connect", "mz+"], ["clabel", "Ay-"]]]]], [[[24]]]]
    ],
    
    ["Connector Specified as Globals",
     ["{connect=mz+,clabel=Ay-}", "#x#"],
     [[[[24, [["connect", "mz+"], ["clabel", "Ay-"]]]]], [[[24]]], [[[24, [["connect", "mz+"], ["clabel", "Ay-"]]]]]]
    ],
        
    ["Voxel with Connector and Extra Braces",
     ["x{connect=mz+,clabel=Ay-,components={z+,y-}}x"],
     [[[[24, [["connect", "mz+"], ["clabel", "Ay-"], ["components", "z+,y-"]]]]], [[[24]]]]
    ],
    
];

echo("---- Parser tests");

for (test = burr_parser_test_cases) {
    echo(test[0]);
    let (result = to_burr_info(test[1]))
    if (result != test[2]) {
        echo(str("EXPECTED: ", test[2]));
        echo(str("ACTUAL: ", result));
        assert(false, "Parse error.");
    }
}

auto_layout_test_cases = [

    ["Simple piece that lays flat",
     [".x.", "xxx"],
     ["xxx|.x."]
    ],

    ["Simple case that must be dissected",
     ["x..|xxx|...", "...|..x|..x"],
     [["x..|xxx{connect=mz+y+,clabel=A}|...", "...|...|..."],
      ["...|x{connect=fz+y+,clabel=A}..|x..", "...|...|..."]]
    ],

    ["Piece that must be rotated and dissected",
     ["x.|xx|..", "..|.x|..", "..|.x|.x"],
     [["..x|..x{connect=mz+y+,clabel=A}|...", "...|...|..."],
      ["...|x{connect=fz+y+,clabel=A}xx|..x", "...|...|..."]]
    ],

    ["Piece with a label that gets split and rotated",
     ["x..|xxx|...", "...|..x{label_text=Puzzlecad,label_orient=y-z-,label_scale=0.4}|...", "...|..x|..x"],
     [["x..|xxx|...", "...|..x{label_text=Puzzlecad,label_orient=y-z-,label_scale=0.4,connect=mz+y+,clabel=A}|...", "...|...|..."],
      ["...|x{connect=fz+y+,clabel=A}..|x..", "...|.{label_text=Puzzlecad,label_orient=y-z+,label_scale=0.4}..|...", "...|...|..."]]
    ],
    
    ["Complex example that cuts into three pieces, with a double connector",
     [".....|.x.x.|.....|.x.x.|.....",
      ".x.x.|xxxxx|.x.x.|xxxxx|.x.x.",
      ".....|.xxx.|.xxx.|.xxx.|.....",
      ".....|.....|.x...|.....|....."],
     [[".....|.....|...x{connect=mz+y+,clabel=A}.|.....|.....",
       ".....|.....|.....|.....|.....",
       ".....|.....|.....|.....|.....",
       ".....|.....|.....|.....|....."],
      [".....|.....|.....|.....|.....",
       ".....|.x{connect=mz+y+,clabel=B}xx{connect=mz+y+,clabel=C}.|.xxx{connect=fz-y+,clabel=A}.|.x{connect=mz+y+,clabel=D}xx{connect=mz+y+,clabel=E}.|.....",
       ".....|.....|.....|.....|.....",
       ".....|.....|.....|.....|....."],
      [".....|.....|.....|.....|.....",
       ".....|.....|.....|.....|.....",
       ".x.x.|xx{connect=fz-y+,clabel=B}xx{connect=fz-y+,clabel=C}x|.x.x.|xx{connect=fz-y+,clabel=D}xx{connect=fz-y+,clabel=E}x|.x.x.",
       ".....|.x.x.|.....|.x.x.|....."]]
    ],
    
    ["Tricky piece with double connectors that needs a thoughtful badness metric to avoid double-female joints",
     ["x.xxxxxx|xxx....x|x.......|xxx.....",
      "x......x|x......x|xx......|x.......",
      ".......x|.......x|........|........",
      ".......x|......xx|........|........"],
     [["x.......|xx......|........|........",
       "x{connect=mz+y+,clabel=A}.......|x{connect=mz+y+,clabel=B}.......|........|........",
       "........|........|........|........",
       "........|........|........|........"],
      ["........|........|........|........",
       "........|........|........|........",
       "x{connect={fz-y+,mz+y+},clabel={A,C}}......x{connect=mz+y+,clabel=D}|x{connect={fz-y+,mz+y+},clabel={B,E}}......x|......xx|.......x{connect=mz+y+,clabel=F}",
       "........|........|........|........"],
      ["x{connect=fz+y+,clabel=D}.xxxxxx{connect=fz+y+,clabel=C}|xxx....x{connect=fz+y+,clabel=E}|x.......|x{connect=fz+y+,clabel=F}xx.....",
       "........|........|........|........",
       "........|........|........|........",
       "........|........|........|........"]]
    ]

];

echo("---- Auto-layout tests");

for (test = auto_layout_test_cases) {
    
    echo(test[0]);
    
    actual = auto_layout(to_burr_info(test[1]))[0];
    expected = [ for (spec = test[2]) to_burr_info(spec) ];
        
    for (i = [0:len(expected)-1]) {
        if (actual[i] != expected[i]) {
            echo(str("EXPECTED:"));
            echo(expected[i]);
            echo(str("ACTUAL:"));
            echo(actual[i]);
            assert(false, str("Auto-layout burr_info structures differed for component ", i, "."));
        }
    }
    
    if (len(actual) != len(expected)) {
        assert(false, "Auto-layout burr_info structures have different numbers of components.");
    }
    
}

burr_piece_test_cases = [

    ["Single Voxel",
     ["x"],
     [[-5, -5, -5], [-5, -5, 5], [-5, 5, -5], [-5, 5, 5], [5, -5, -5], [5, -5, 5], [5, 5, -5], [5, 5, 5]],
     [[0, 1, 5, 4], [0, 2, 3, 1], [0, 4, 6, 2], [1, 3, 7, 5], [2, 6, 7, 3], [4, 5, 7, 6]],
     12, 0, 1
    ],

    ["L Tricube",
     ["xx|x."],
     [[-5, -5, -5], [-5, -5, 5], [-5, 17, -5], [-5, 17, 5], [5, 5, -5], [5, 5, 5], [5, 17, -5], [5, 17, 5], [17, -5, -5], [17, -5, 5], [17, 5, -5], [17, 5, 5]],
     [[0, 1, 9, 8], [0, 2, 3, 1], [0, 8, 10, 4, 6, 2], [1, 3, 7, 5, 11, 9], [2, 6, 7, 3], [4, 5, 7, 6], [4, 10, 11, 5], [8, 9, 11, 10]],
     12, 0, 1
    ],

    ["Chiral Tetracube",
     ["xx|x.", "..|x."],
     [[-5, -5, -5], [-5, -5, 5], [-5, 7, 5], [-5, 7, 17], [-5, 17, -5], [-5, 17, 17], [5, 5, -5], [5, 5, 5], [5, 7, 5], [5, 7, 17], [5, 17, -5], [5, 17, 17], [17, -5, -5], [17, -5, 5], [17, 5, -5], [17, 5, 5]],
     [[0, 1, 13, 12], [0, 4, 5, 3, 2, 1], [0, 12, 14, 6, 10, 4], [1, 2, 8, 7, 15, 13], [2, 3, 9, 8], [3, 5, 11, 9], [4, 10, 11, 5], [6, 7, 8, 9, 11, 10], [6, 14, 15, 7], [12, 13, 15, 14]],
     12, 0, 1
    ],
    
    ["Cross Heptacube",
     ["...|.x.|...", ".x.|xxx|.x.", "...|.x.|..."],
     [[-5, 7, 7], [-5, 7, 17], [-5, 17, 7], [-5, 17, 17], [7, -5, 7], [7, -5, 17], [7, 7, -5], [7, 7, 7], [7, 7, 17], [7, 7, 29], [7, 17, -5], [7, 17, 7], [7, 17, 17], [7, 17, 29], [7, 29, 7], [7, 29, 17], [17, -5, 7], [17, -5, 17], [17, 7, -5], [17, 7, 7], [17, 7, 17], [17, 7, 29], [17, 17, -5], [17, 17, 7], [17, 17, 17], [17, 17, 29], [17, 29, 7], [17, 29, 17], [29, 7, 7], [29, 7, 17], [29, 17, 7], [29, 17, 17]],
     [[0, 1, 8, 7], [0, 2, 3, 1], [0, 7, 11, 2], [1, 3, 12, 8], [2, 11, 12, 3], [4, 5, 17, 16], [4, 7, 8, 5], [4, 16, 19, 7], [5, 8, 20, 17], [6, 7, 19, 18], [6, 10, 11, 7], [6, 18, 22, 10], [8, 9, 21, 20], [8, 12, 13, 9], [9, 13, 25, 21], [10, 22, 23, 11], [11, 14, 15, 12], [11, 23, 26, 14], [12, 15, 27, 24], [12, 24, 25, 13], [14, 26, 27, 15], [16, 17, 20, 19], [18, 19, 23, 22], [19, 20, 29, 28], [19, 28, 30, 23], [20, 21, 25, 24], [20, 24, 31, 29], [23, 24, 27, 26], [23, 30, 31, 24], [28, 29, 31, 30]],
     12, 0, 1
    ],
    
    ["Blind Corner",
     ["xx|xx", "x.|xx"],
     [[-5, -5, -5], [-5, -5, 17], [-5, 17, -5], [-5, 17, 17], [5, -5, 5], [5, -5, 17], [5, 7, 5], [5, 7, 17], [17, -5, -5], [17, -5, 5], [17, 7, 5], [17, 7, 17], [17, 17, -5], [17, 17, 17]],
     [[0, 1, 5, 4, 9, 8], [0, 2, 3, 1], [0, 8, 12, 2], [1, 3, 13, 11, 7, 5], [2, 12, 13, 3], [4, 5, 7, 6], [4, 6, 10, 9], [6, 7, 11, 10], [8, 9, 10, 11, 13, 12]],
     12, 0, 1
    ],
    
    ["Piece #975",
     975,
     [[-5, -5, -5], [-5, -5, 17], [-5, 17, -5], [-5, 17, 17], [17, -5, -5], [17, -5, 17], [17, 7, -5], [17, 7, 17], [29, 7, 5], [29, 7, 17], [29, 17, 5], [29, 17, 17], [43, -5, -5], [43, -5, 5], [43, 7, -5], [43, 7, 5], [55, -5, 5], [55, -5, 17], [55, 17, 5], [55, 17, 17], [65, -5, -5], [65, -5, 17], [65, 17, -5], [65, 17, 17]],
     [[0, 1, 5, 4], [0, 2, 3, 1], [0, 4, 6, 14, 12, 20, 22, 2], [1, 3, 11, 9, 7, 5], [2, 22, 23, 19, 18, 10, 11, 3], [4, 5, 7, 6], [6, 7, 9, 8, 15, 14], [8, 9, 11, 10], [8, 10, 18, 16, 13, 15], [12, 13, 16, 17, 21, 20], [12, 14, 15, 13], [16, 18, 19, 17], [17, 19, 23, 21], [20, 21, 23, 22]],
     12, 0, 1
    ],
    
    ["Voxels Meet At Edges",
     ["x.|.x"],
     [[-5, -5, -5], [-5, -5, 5], [-5, 5, -5], [-5, 5, 5], [5, -5, -5], [5, -5, 5], [5, 5, -5], [5, 5, 5], [7, 7, -5], [7, 7, 5], [7, 17, -5], [7, 17, 5], [17, 7, -5], [17, 7, 5], [17, 17, -5], [17, 17, 5]],
     [[0, 1, 5, 4], [0, 2, 3, 1], [0, 4, 6, 2], [1, 3, 7, 5], [2, 6, 7, 3], [4, 5, 7, 6], [8, 9, 13, 12], [8, 10, 11, 9], [8, 12, 14, 10], [9, 11, 15, 13], [10, 14, 15, 11], [12, 13, 15, 14]],
     12, 0, 1
    ],
    
    // Small inset with close tolerances to ensure nearby vertices are properly distinguished.
    ["Small Inset",
     ["xx|x.", "..|x."],
     [[-5.99, -5.99, -5.99], [-5.99, -5.99, 5.99], [-5.99, 6.01, 5.99], [-5.99, 6.01, 17.99], [-5.99, 17.99, -5.99], [-5.99, 17.99, 17.99], [5.99, 5.99, -5.99], [5.99, 5.99, 5.99], [5.99, 6.01, 5.99], [5.99, 6.01, 17.99], [5.99, 17.99, -5.99], [5.99, 17.99, 17.99], [17.99, -5.99, -5.99], [17.99, -5.99, 5.99], [17.99, 5.99, -5.99], [17.99, 5.99, 5.99]],
     [[0, 1, 13, 12], [0, 4, 5, 3, 2, 1], [0, 12, 14, 6, 10, 4], [1, 2, 8, 7, 15, 13], [2, 3, 9, 8], [3, 5, 11, 9], [4, 10, 11, 5], [6, 7, 8, 9, 11, 10], [6, 14, 15, 7], [12, 13, 15, 14]],
     12, 0, 0.01
    ],
     
    ["Single Beveled Voxel",
     ["x"],
     [[-5, -4.5, -4.5], [-5, -4.5, 4.5], [-5, 4.5, -4.5], [-5, 4.5, 4.5], [-4.5, -5, -4.5], [-4.5, -5, 4.5], [-4.5, -4.5, -5], [-4.5, -4.5, 5], [-4.5, 4.5, -5], [-4.5, 4.5, 5], [-4.5, 5, -4.5], [-4.5, 5, 4.5], [4.5, -5, -4.5], [4.5, -5, 4.5], [4.5, -4.5, -5], [4.5, -4.5, 5], [4.5, 4.5, -5], [4.5, 4.5, 5], [4.5, 5, -4.5], [4.5, 5, 4.5], [5, -4.5, -4.5], [5, -4.5, 4.5], [5, 4.5, -4.5], [5, 4.5, 4.5]],
     [[0, 1, 5, 4], [0, 2, 3, 1], [0, 4, 6], [0, 6, 8, 2], [1, 3, 9, 7], [1, 7, 5], [2, 8, 10], [2, 10, 11, 3], [3, 11, 9], [4, 5, 13, 12], [4, 12, 14, 6], [5, 7, 15, 13], [6, 14, 16, 8], [7, 9, 17, 15], [8, 16, 18, 10], [9, 11, 19, 17], [10, 18, 19, 11], [12, 13, 21, 20], [12, 20, 14], [13, 15, 21], [14, 20, 22, 16], [15, 17, 23, 21], [16, 22, 18], [17, 19, 23], [18, 22, 23, 19], [20, 21, 23, 22]],
     12, 1/sqrt(2), 1
    ],
    
    // Complex beveled piece requiring a double-reduction to normalize the initial polyhedron, with two kinds of concave edges
    ["Complex Beveled Piece",
     ["..x|.xx|...", "..x|..x|..."],
     [[7, 7.5, -4.5], [7, 7.5, 4.5], [7, 16.5, -4.5], [7, 16.5, 4.5], [7.5, 7, -4.5], [7.5, 7, 4.5], [7.5, 7.5, -5], [7.5, 7.5, 5], [7.5, 16.5, -5], [7.5, 16.5, 5], [7.5, 17, -4.5], [7.5, 17, 4.5], [19, -4.5, -4.5], [19, -4.5, 16.5], [19, 7, -4.5], [19, 7, 4.5], [19, 7.5, 5], [19, 16.5, 5], [19, 16.5, 16.5], [19.5, -5, -4.5], [19.5, -5, 16.5], [19.5, -4.5, -5], [19.5, -4.5, 17], [19.5, 7.5, -5], [19.5, 16.5, 17], [19.5, 17, 4.5], [19.5, 17, 16.5], [28.5, -5, -4.5], [28.5, -5, 16.5], [28.5, -4.5, -5], [28.5, -4.5, 17], [28.5, 16.5, -5], [28.5, 16.5, 17], [28.5, 17, -4.5], [28.5, 17, 16.5], [29, -4.5, -4.5], [29, -4.5, 16.5], [29, 16.5, -4.5], [29, 16.5, 16.5]],
     [[0, 1, 5, 4], [0, 2, 3, 1], [0, 4, 6], [0, 6, 8, 2], [1, 3, 9, 7], [1, 7, 5], [2, 8, 10], [2, 10, 11, 3], [3, 11, 9], [4, 5, 15, 14], [4, 14, 23, 6], [5, 7, 16, 15], [6, 23, 21, 29, 31, 8], [7, 9, 17, 16], [8, 31, 33, 10], [9, 11, 25, 17], [10, 33, 34, 26, 25, 11], [12, 13, 20, 19], [12, 14, 15, 16, 17, 18, 13], [12, 19, 21], [12, 21, 23, 14], [13, 18, 24, 22], [13, 22, 20], [17, 25, 26, 18], [18, 26, 24], [19, 20, 28, 27], [19, 27, 29, 21], [20, 22, 30, 28], [22, 24, 32, 30], [24, 26, 34, 32], [27, 28, 36, 35], [27, 35, 29], [28, 30, 36], [29, 35, 37, 31], [30, 32, 38, 36], [31, 37, 33], [32, 34, 38], [33, 37, 38, 34], [35, 36, 38, 37]],
     12, 1/sqrt(2), 1
    ],
    
    ["Beveled Blind Corner",
     ["xx|xx", "x.|xx"],
     [[-5, -4.5, -4.5], [-5, -4.5, 16.5], [-5, 16.5, -4.5], [-5, 16.5, 16.5], [-4.5, -5, -4.5], [-4.5, -5, 16.5], [-4.5, -4.5, -5], [-4.5, -4.5, 17], [-4.5, 16.5, -5], [-4.5, 16.5, 17], [-4.5, 17, -4.5], [-4.5, 17, 16.5], [4.5, -5, 4.5], [4.5, -5, 16.5], [4.5, -4.5, 17], [4.5, 7.5, 17], [5, -4.5, 5], [5, -4.5, 16.5], [5, 7, 5], [5, 7, 16.5], [16.5, -5, -4.5], [16.5, -5, 4.5], [16.5, -4.5, -5], [16.5, -4.5, 5], [16.5, 7, 5], [16.5, 7, 16.5], [16.5, 7.5, 17], [16.5, 16.5, -5], [16.5, 16.5, 17], [16.5, 17, -4.5], [16.5, 17, 16.5], [17, -4.5, -4.5], [17, -4.5, 4.5], [17, 7.5, 4.5], [17, 7.5, 16.5], [17, 16.5, -4.5], [17, 16.5, 16.5]],
     [[0, 1, 5, 4], [0, 2, 3, 1], [0, 4, 6], [0, 6, 8, 2], [1, 3, 9, 7], [1, 7, 5], [2, 8, 10], [2, 10, 11, 3], [3, 11, 9], [4, 5, 13, 12, 21, 20], [4, 20, 22, 6], [5, 7, 14, 13], [6, 22, 27, 8], [7, 9, 28, 26, 15, 14], [8, 27, 29, 10], [9, 11, 30, 28], [10, 29, 30, 11], [12, 13, 17, 16], [12, 16, 23, 21], [13, 14, 17], [14, 15, 19, 17], [15, 26, 25, 19], [16, 17, 19, 18], [16, 18, 24, 23], [18, 19, 25, 24], [20, 21, 32, 31], [20, 31, 22], [21, 23, 32], [22, 31, 35, 27], [23, 24, 33, 32], [24, 25, 34, 33], [25, 26, 34], [26, 28, 36, 34], [27, 35, 29], [28, 30, 36], [29, 35, 36, 30], [31, 32, 33, 34, 36, 35]],
     12, 1/sqrt(2), 1
    ],
    
    // This one triggered a very subtle bug involving proper reduction of degenerate faces.
    
    ["Tricky Edge Case",
     ["x.....x|x.....x|x.....x|x.....x|x.....x|x.xx..x|xxxxxxx",
      "x.....x|x.....x|x.....x|x.....x|x.....x|x.....x|xxxxxxx"],
     [[-4, -3.5, -3.5], [-4, -3.5, 13.5], [-4, 63.5, -3.5], [-4, 63.5, 13.5], [-3.5, -4, -3.5], [-3.5, -4, 13.5], [-3.5, -3.5, -4], [-3.5, -3.5, 14], [-3.5, 63.5, -4], [-3.5, 63.5, 14], [-3.5, 64, -3.5], [-3.5, 64, 13.5], [3.5, -4, -3.5], [3.5, -4, 13.5], [3.5, -3.5, -4], [3.5, -3.5, 14], [3.5, 56.5, -4], [3.5, 56.5, 14], [4, -3.5, -3.5], [4, -3.5, 13.5], [4, 56, -3.5], [4, 56, 13.5], [16, 46.5, -3.5], [16, 46.5, 3.5], [16, 56, -3.5], [16, 56, 3.5], [16.5, 46, -3.5], [16.5, 46, 3.5], [16.5, 46.5, -4], [16.5, 46.5, 4], [16.5, 56, 4], [16.5, 56.5, -4], [33.5, 46, -3.5], [33.5, 46, 3.5], [33.5, 46.5, -4], [33.5, 46.5, 4], [33.5, 56, 4], [33.5, 56.5, -4], [34, 46.5, -3.5], [34, 46.5, 3.5], [34, 56, -3.5], [34, 56, 3.5], [56, -3.5, -3.5], [56, -3.5, 13.5], [56, 56, -3.5], [56, 56, 13.5], [56.5, -4, -3.5], [56.5, -4, 13.5], [56.5, -3.5, -4], [56.5, -3.5, 14], [56.5, 56.5, -4], [56.5, 56.5, 14], [63.5, -4, -3.5], [63.5, -4, 13.5], [63.5, -3.5, -4], [63.5, -3.5, 14], [63.5, 63.5, -4], [63.5, 63.5, 14], [63.5, 64, -3.5], [63.5, 64, 13.5], [64, -3.5, -3.5], [64, -3.5, 13.5], [64, 63.5, -3.5], [64, 63.5, 13.5]],
     [[0, 1, 5, 4], [0, 2, 3, 1], [0, 4, 6], [0, 6, 8, 2], [1, 3, 9, 7], [1, 7, 5], [2, 8, 10], [2, 10, 11, 3], [3, 11, 9], [4, 5, 13, 12], [4, 12, 14, 6], [5, 7, 15, 13], [6, 14, 16, 31, 28, 34, 37, 50, 48, 54, 56, 8], [7, 9, 57, 55, 49, 51, 17, 15], [8, 56, 58, 10], [9, 11, 59, 57], [10, 58, 59, 11], [12, 13, 19, 18], [12, 18, 14], [13, 15, 19], [14, 18, 20, 16], [15, 17, 21, 19], [16, 20, 24, 31], [17, 51, 45, 21], [18, 19, 21, 20], [20, 21, 45, 44, 40, 41, 36, 30, 25, 24], [22, 23, 27, 26], [22, 24, 25, 23], [22, 26, 28], [22, 28, 31, 24], [23, 25, 30, 29], [23, 29, 27], [26, 27, 33, 32], [26, 32, 34, 28], [27, 29, 35, 33], [29, 30, 36, 35], [32, 33, 39, 38], [32, 38, 34], [33, 35, 39], [34, 38, 40, 37], [35, 36, 41, 39], [37, 40, 44, 50], [38, 39, 41, 40], [42, 43, 47, 46], [42, 44, 45, 43], [42, 46, 48], [42, 48, 50, 44], [43, 45, 51, 49], [43, 49, 47], [46, 47, 53, 52], [46, 52, 54, 48], [47, 49, 55, 53], [52, 53, 61, 60], [52, 60, 54], [53, 55, 61], [54, 60, 62, 56], [55, 57, 63, 61], [56, 62, 58], [57, 59, 63], [58, 62, 63, 59], [60, 61, 63, 62]],
     10, 1/sqrt(2), 1
    ],
    
    ["Beveled Ring",
     "xxxxx|x...x|x...x|xxxxx",
     [[-5, -4.5, -4.5], [-5, -4.5, 4.5], [-5, 40.5, -4.5], [-5, 40.5, 4.5], [-4.5, -5, -4.5], [-4.5, -5, 4.5], [-4.5, -4.5, -5], [-4.5, -4.5, 5], [-4.5, 40.5, -5], [-4.5, 40.5, 5], [-4.5, 41, -4.5], [-4.5, 41, 4.5], [4.5, 4.5, -5], [4.5, 4.5, 5], [4.5, 31.5, -5], [4.5, 31.5, 5], [5, 5, -4.5], [5, 5, 4.5], [5, 31, -4.5], [5, 31, 4.5], [41.5, 31.5, 5], [41.5, 40.5, 5], [42.5, 31.5, 5], [42.5, 40.5, 5], [43, 5, -4.5], [43, 5, 4.5], [43, 31, -4.5], [43, 31, 4.5], [43.5, 4.5, -5], [43.5, 4.5, 5], [43.5, 29.5, -5], [43.5, 30.5, -5], [43.5, 31.5, -5], [43.5, 31.5, 5], [52.5, -5, -4.5], [52.5, -5, 4.5], [52.5, -4.5, -5], [52.5, -4.5, 5], [52.5, 29.5, -5], [52.5, 30.5, -5], [52.5, 40.5, -5], [52.5, 40.5, 5], [52.5, 41, -4.5], [52.5, 41, 4.5], [53, -4.5, -4.5], [53, -4.5, 4.5], [53, 40.5, -4.5], [53, 40.5, 4.5]],
     [[0, 1, 5, 4], [0, 2, 3, 1], [0, 4, 6], [0, 6, 8, 2], [1, 3, 9, 7], [1, 7, 5], [2, 8, 10], [2, 10, 11, 3], [3, 11, 9], [4, 5, 35, 34], [4, 34, 36, 6], [5, 7, 37, 35], [6, 36, 38, 30, 28, 12, 14, 32, 31, 39, 40, 8], [7, 9, 21, 20, 15, 13, 29, 33, 22, 23, 41, 37], [8, 40, 42, 10], [9, 11, 43, 41, 23, 21], [10, 42, 43, 11], [12, 16, 18, 14], [12, 28, 24, 16], [13, 15, 19, 17], [13, 17, 25, 29], [14, 18, 26, 32], [15, 20, 22, 33, 27, 19], [16, 17, 19, 18], [16, 24, 25, 17], [18, 19, 27, 26], [20, 21, 23, 22], [24, 26, 27, 25], [24, 28, 30, 31, 32, 26], [25, 27, 33, 29], [30, 38, 39, 31], [34, 35, 45, 44], [34, 44, 36], [35, 37, 45], [36, 44, 46, 40, 39, 38], [37, 41, 47, 45], [40, 46, 42], [41, 43, 47], [42, 46, 47, 43], [44, 45, 47, 46]],
     12, 1/sqrt(2), 1
    ],
    
    // This case tests some subtleties in the beveling algorithm (specifically, the case where a flat edge
    // meets a strictly concave one).
    ["Ring surrounding a protrusion",
     ["xxx|xxx|xxx", "...|.x.|..."],
     [[-5, -4.5, -4.5], [-5, -4.5, 4.5], [-5, 28.5, -4.5], [-5, 28.5, 4.5], [-4.5, -5, -4.5], [-4.5, -5, 4.5], [-4.5, -4.5, -5], [-4.5, -4.5, 5], [-4.5, 28.5, -5], [-4.5, 28.5, 5], [-4.5, 29, -4.5], [-4.5, 29, 4.5], [6, 6, 5], [6, 7, 5], [6, 17, 5], [6, 18, 5], [7, 7.5, 5], [7, 7.5, 16.5], [7, 16.5, 5], [7, 16.5, 16.5], [7.5, 7, 5], [7.5, 7, 16.5], [7.5, 7.5, 17], [7.5, 16.5, 17], [7.5, 17, 5], [7.5, 17, 16.5], [16.5, 7, 5], [16.5, 7, 16.5], [16.5, 7.5, 17], [16.5, 16.5, 17], [16.5, 17, 5], [16.5, 17, 16.5], [17, 7.5, 5], [17, 7.5, 16.5], [17, 16.5, 5], [17, 16.5, 16.5], [28.5, -5, -4.5], [28.5, -5, 4.5], [28.5, -4.5, -5], [28.5, -4.5, 5], [28.5, 6.5, 5], [28.5, 17.5, 5], [28.5, 28.5, -5], [28.5, 28.5, 5], [28.5, 29, -4.5], [28.5, 29, 4.5], [29, -4.5, -4.5], [29, -4.5, 4.5], [29, 28.5, -4.5], [29, 28.5, 4.5]],
     [[0, 1, 5, 4], [0, 2, 3, 1], [0, 4, 6], [0, 6, 8, 2], [1, 3, 9, 7], [1, 7, 5], [2, 8, 10], [2, 10, 11, 3], [3, 11, 9], [4, 5, 37, 36], [4, 36, 38, 6], [5, 7, 39, 37], [6, 38, 42, 8], [7, 9, 43, 41, 15, 14, 24, 18, 16, 20, 13, 12, 40, 39], [8, 42, 44, 10], [9, 11, 45, 43], [10, 44, 45, 11], [12, 13, 20, 26, 32, 34, 30, 24, 14, 15, 41, 40], [16, 17, 21, 20], [16, 18, 19, 17], [17, 19, 23, 22], [17, 22, 21], [18, 24, 25, 19], [19, 25, 23], [20, 21, 27, 26], [21, 22, 28, 27], [22, 23, 29, 28], [23, 25, 31, 29], [24, 30, 31, 25], [26, 27, 33, 32], [27, 28, 33], [28, 29, 35, 33], [29, 31, 35], [30, 34, 35, 31], [32, 33, 35, 34], [36, 37, 47, 46], [36, 46, 38], [37, 39, 47], [38, 46, 48, 42], [39, 40, 41, 43, 49, 47], [42, 48, 44], [43, 45, 49], [44, 48, 49, 45], [46, 47, 49, 48]],
     12, 1/sqrt(2), 1
    ],

    // This case tests Condition 3 in find_mergeable_face.
    ["Ring-shaped face requiring careful face merge logic",
     ["xxxx|xxxx|xxxx", "....|.xx.|...."],
     [[-5, -4.5, -4.5], [-5, -4.5, 4.5], [-5, 28.5, -4.5], [-5, 28.5, 4.5], [-4.5, -5, -4.5], [-4.5, -5, 4.5], [-4.5, -4.5, -5], [-4.5, -4.5, 5], [-4.5, 28.5, -5], [-4.5, 28.5, 5], [-4.5, 29, -4.5], [-4.5, 29, 4.5], [7, 7.5, 5], [7, 7.5, 16.5], [7, 16.5, 5], [7, 16.5, 16.5], [7.5, 7, 5], [7.5, 7, 16.5], [7.5, 7.5, 17], [7.5, 16.5, 17], [7.5, 17, 5], [7.5, 17, 16.5], [18, 6, 5], [18, 7, 5], [18, 17, 5], [18, 18, 5], [28.5, 7, 5], [28.5, 7, 16.5], [28.5, 7.5, 17], [28.5, 16.5, 17], [28.5, 17, 5], [28.5, 17, 16.5], [29, 7.5, 5], [29, 7.5, 16.5], [29, 16.5, 5], [29, 16.5, 16.5], [40.5, -5, -4.5], [40.5, -5, 4.5], [40.5, -4.5, -5], [40.5, -4.5, 5], [40.5, 6.5, 5], [40.5, 17.5, 5], [40.5, 28.5, -5], [40.5, 28.5, 5], [40.5, 29, -4.5], [40.5, 29, 4.5], [41, -4.5, -4.5], [41, -4.5, 4.5], [41, 28.5, -4.5], [41, 28.5, 4.5]],
     [[0, 1, 5, 4], [0, 2, 3, 1], [0, 4, 6], [0, 6, 8, 2], [1, 3, 9, 7], [1, 7, 5], [2, 8, 10], [2, 10, 11, 3], [3, 11, 9], [4, 5, 37, 36], [4, 36, 38, 6], [5, 7, 39, 37], [6, 38, 42, 8], [7, 9, 43, 41, 25, 24, 20, 14, 12, 16, 23, 22, 40, 39], [8, 42, 44, 10], [9, 11, 45, 43], [10, 44, 45, 11], [12, 13, 17, 16], [12, 14, 15, 13], [13, 15, 19, 18], [13, 18, 17], [14, 20, 21, 15], [15, 21, 19], [16, 17, 27, 26, 23], [17, 18, 28, 27], [18, 19, 29, 28], [19, 21, 31, 29], [20, 24, 30, 31, 21], [22, 23, 26, 32, 34, 30, 24, 25, 41, 40], [26, 27, 33, 32], [27, 28, 33], [28, 29, 35, 33], [29, 31, 35], [30, 34, 35, 31], [32, 33, 35, 34], [36, 37, 47, 46], [36, 46, 38], [37, 39, 47], [38, 46, 48, 42], [39, 40, 41, 43, 49, 47], [42, 48, 44], [43, 45, 49], [44, 48, 49, 45], [46, 47, 49, 48]],
     12, 1/sqrt(2), 1
    ],

    ["Single Pyramid",
     "x{components=z-}",
     [[-6, -6, -6], [-6, 6, -6], [0, 0, 0], [6, -6, -6], [6, 6, -6]],
     [[0, 1, 2], [0, 2, 3], [0, 3, 4, 1], [1, 4, 2], [2, 4, 3]],
     12, 0, 0
    ],
    
    ["HoHoHo-Style Half-Cube",
     "x{components={z-,x-,x+}}",
     [[-6, -6, -6], [-6, -6, 6], [-6, 6, -6], [-6, 6, 6], [0, 0, 0], [6, -6, -6], [6, -6, 6], [6, 6, -6], [6, 6, 6]],
     [[0, 1, 4], [0, 2, 3, 1], [0, 4, 5], [0, 5, 7, 2], [1, 3, 4], [2, 4, 3], [2, 7, 4], [4, 6, 5], [4, 7, 8], [4, 8, 6], [5, 6, 8, 7]],
     12, 0, 0
    ],
    
    ["Pyramids Joined at Cube Face",
     "x{components=x+}x{components=x-}",
     [[0, 0, 0], [6, -6, -6], [6, -6, 6], [6, 6, -6], [6, 6, 6], [12, 0, 0]],
     [[0, 1, 3], [0, 2, 1], [0, 3, 4], [0, 4, 2], [1, 2, 5], [1, 5, 3], [2, 4, 5], [3, 5, 4]],
     12, 0, 0
    ],
    
    ["Single Tetrahedron",
     "x{components=z-y-}",
     [[-6, -6, -6], [0, 0, -6], [0, 0, 0], [6, -6, -6]],
     [[0, 1, 2], [0, 2, 3], [0, 3, 1], [1, 3, 2]],
     12, 0, 0
    ],
    
    ["Diagonal Burr Stick",
     ["x{components={z+,x-z+,x+z+}}x{components={z+,x-z+,x+z+}}x{components={z+,x-z+,x+z+}}",
      "x{components={z-,x-z-}}x{components=z-}x{components={z-,x+z-}}"],
     [[-6, -6, 6], [-6, 0, 0], [-6, 0, 12], [-6, 6, 6], [0, 0, 12], [6, -6, 6], [6, 6, 6], [12, 0, 12], [18, -6, 6], [18, 6, 6], [24, 0, 12], [30, -6, 6], [30, 0, 0], [30, 0, 12], [30, 6, 6]],
     [[0, 1, 3, 2], [0, 2, 4, 5], [0, 5, 8, 11, 12, 1], [1, 12, 14, 9, 6, 3], [2, 3, 6, 4], [4, 6, 5], [5, 6, 7], [5, 7, 8], [6, 9, 7], [7, 9, 8], [8, 9, 10], [8, 10, 13, 11], [9, 14, 13, 10], [11, 13, 14, 12]],
     12, 0, 0
    ],
    
    ["Triumph Piece",
     ["x{components={y+z+,z+x+,z+y+}}.|x{components={y-z+,y+z+,z+}}.|x{components={y-z+,z+x+,z+y-}}.",
      "x{components={z-x+,z-y+,x+z-}}x{components=x-z-}|x{components=z-}.|x{components={z-x+,z-y-,x+z-}}x{components=x-z-}"],
     [[-6, 6, 6], [-6, 18, 6], [0, 0, 0], [0, 0, 12], [0, 12, 12], [0, 24, 0], [0, 24, 12], [6, -6, 6], [6, 6, 6], [6, 18, 6], [6, 30, 6], [12, 0, 12], [12, 24, 12]],
     [[0, 1, 4], [0, 2, 5, 1], [0, 3, 7, 2], [0, 4, 8], [0, 8, 11, 3], [1, 5, 10, 6], [1, 6, 12, 9], [1, 9, 4], [2, 7, 11, 8, 9, 12, 10, 5], [3, 11, 7], [4, 9, 8], [6, 10, 12]],
     12, 0, 0
    ],
    
    ["Beveled Single Pyramid",
     "x{components=z-}",
     [[-5.64645, -5.03407, -5.64645], [-5.64645, 5.03407, -5.64645], [-5.5, -5.5, -6], [-5.5, 5.5, -6], [-5.03407, -5.64645, -5.64645], [-5.03407, 5.64645, -5.64645], [-0.612372, 0, -0.612372], [0, -0.612372, -0.612372], [0, 0.612372, -0.612372], [0.612372, 0, -0.612372], [5.03407, -5.64645, -5.64645], [5.03407, 5.64645, -5.64645], [5.5, -5.5, -6], [5.5, 5.5, -6], [5.64645, -5.03407, -5.64645], [5.64645, 5.03407, -5.64645]],
     [[0, 1, 6], [0, 2, 3, 1], [0, 4, 2], [0, 6, 7, 4], [1, 3, 5], [1, 5, 8, 6], [2, 4, 10, 12], [2, 12, 13, 3], [3, 13, 11, 5], [4, 7, 10], [5, 11, 8], [6, 8, 9, 7], [7, 9, 14, 10], [8, 11, 15, 9], [9, 15, 14], [10, 14, 12], [11, 13, 15], [12, 14, 15, 13]],
     12, 1/sqrt(2), 0, 1e-3
    ],
    
    ["Beveled Diagonal Burr Stick",
     ["x{components={z+,x-z+,x+z+}}x{components={z+,x-z+,x+z+}}x{components={z+,x-z+,x+z+}}",
      "x{components={z-,x-z-}}x{components=z-}x{components={z-,x+z-}}"],
     [[-6, -5.29289, 6], [-6, 0, 0.707107], [-6, 0, 11.2929], [-6, 5.29289, 6], [-5.5, -5.64645, 5.64645], [-5.5, -5.64645, 6.35355], [-5.5, -0.353553, 0.353553], [-5.5, -0.353553, 11.6464], [-5.5, 0.353553, 0.353553], [-5.5, 0.353553, 11.6464], [-5.5, 5.64645, 5.64645], [-5.5, 5.64645, 6.35355], [-0.258819, -0.353553, 11.6464], [-0.258819, 0.353553, 11.6464], [0.612372, 0, 11.3876], [5.03407, -5.64645, 6.35355], [5.03407, 5.64645, 6.35355], [6, -5.64645, 5.64645], [6, -5.38763, 6], [6, 5.38763, 6], [6, 5.64645, 5.64645], [6.96593, -5.64645, 6.35355], [6.96593, 5.64645, 6.35355], [11.3876, 0, 11.3876], [12, -0.612372, 11.3876], [12, 0.612372, 11.3876], [12.6124, 0, 11.3876], [17.0341, -5.64645, 6.35355], [17.0341, 5.64645, 6.35355], [18, -5.64645, 5.64645], [18, -5.38763, 6], [18, 5.38763, 6], [18, 5.64645, 5.64645], [18.9659, -5.64645, 6.35355], [18.9659, 5.64645, 6.35355], [23.3876, 0, 11.3876], [24.2588, -0.353553, 11.6464], [24.2588, 0.353553, 11.6464], [29.5, -5.64645, 5.64645], [29.5, -5.64645, 6.35355], [29.5, -0.353553, 0.353553], [29.5, -0.353553, 11.6464], [29.5, 0.353553, 0.353553], [29.5, 0.353553, 11.6464], [29.5, 5.64645, 5.64645], [29.5, 5.64645, 6.35355], [30, -5.29289, 6], [30, 0, 0.707107], [30, 0, 11.2929], [30, 5.29289, 6]],
     [[0, 1, 3, 2], [0, 2, 7, 5], [0, 4, 6, 1], [0, 5, 4], [1, 6, 8], [1, 8, 10, 3], [2, 3, 11, 9], [2, 9, 7], [3, 10, 11], [4, 5, 15, 17], [4, 17, 29, 38, 40, 6], [5, 7, 12, 15], [6, 40, 42, 8], [7, 9, 13, 12], [8, 42, 44, 32, 20, 10], [9, 11, 16, 13], [10, 20, 16, 11], [12, 13, 14], [12, 14, 18, 15], [13, 16, 19, 14], [14, 19, 18], [15, 18, 17], [16, 20, 19], [17, 18, 21], [17, 21, 27, 29], [18, 19, 23], [18, 23, 24, 21], [19, 20, 22], [19, 22, 25, 23], [20, 32, 28, 22], [21, 24, 27], [22, 28, 25], [23, 25, 26, 24], [24, 26, 30, 27], [25, 28, 31, 26], [26, 31, 30], [27, 30, 29], [28, 32, 31], [29, 30, 33], [29, 33, 39, 38], [30, 31, 35], [30, 35, 36, 33], [31, 32, 34], [31, 34, 37, 35], [32, 44, 45, 34], [33, 36, 41, 39], [34, 45, 43, 37], [35, 37, 36], [36, 37, 43, 41], [38, 39, 46], [38, 46, 47, 40], [39, 41, 48, 46], [40, 47, 42], [41, 43, 48], [42, 47, 49, 44], [43, 45, 49, 48], [44, 49, 45], [46, 48, 49, 47]],
     12, 1/sqrt(2), 0, 1e-3
    ],
    
    ["Beveled Triumph Piece",
     ["x{components={y+z+,z+x+,z+y+}}.|x{components={y-z+,y+z+,z+}}.|x{components={y-z+,z+x+,z+y-}}.",
      "x{components={z-x+,z-y+,x+z-}}x{components=x-z-}|x{components=z-}.|x{components={z-x+,z-y-,x+z-}}x{components=x-z-}"],
     [[-5.64645, 6.25882, 5.64645], [-5.64645, 6.96593, 6.35355], [-5.64645, 17.0341, 6.35355], [-5.64645, 17.7412, 5.64645], [-5.38763, 5.38763, 6], [-5.38763, 6, 6], [-5.38763, 18, 6], [-5.38763, 18.6124, 6], [-0.612372, 12, 11.3876], [-0.353553, 0.965926, 0.353553], [-0.353553, 23.0341, 0.353553], [0, 0, 0.612372], [0, 0, 11.3876], [0, 11.3876, 11.3876], [0, 12.6124, 11.3876], [0, 24, 0.612372], [0, 24, 11.3876], [0.258819, 0.353553, 11.6464], [0.258819, 23.6464, 11.6464], [0.353553, 0.258819, 0.353553], [0.353553, 23.7412, 0.353553], [0.612372, 12, 11.3876], [0.965926, -0.353553, 11.6464], [0.965926, 24.3536, 11.6464], [5.38763, -5.38763, 6], [5.38763, 6, 6], [5.38763, 18, 6], [5.38763, 29.3876, 6], [5.64645, 5.74118, 5.64645], [5.64645, 6.96593, 6.35355], [5.64645, 17.0341, 6.35355], [5.64645, 18.2588, 5.64645], [6, -5.38763, 6], [6, -5.38763, 6.61237], [6, 29.3876, 6], [6, 29.3876, 6.61237], [11.0341, -0.353553, 11.6464], [11.0341, 0.353553, 11.6464], [11.0341, 23.6464, 11.6464], [11.0341, 24.3536, 11.6464], [11.3876, 0, 11.3876], [11.3876, 24, 11.3876]],
     [[0, 1, 5], [0, 3, 2, 1], [0, 4, 11, 9], [0, 5, 4], [0, 9, 10, 3], [1, 2, 8], [1, 8, 13, 5], [2, 3, 6], [2, 6, 14, 8], [3, 7, 6], [3, 10, 15, 7], [4, 5, 17, 12], [4, 12, 24, 11], [5, 13, 25], [5, 25, 37, 17], [6, 7, 16, 18], [6, 18, 38, 26], [6, 26, 14], [7, 15, 27, 16], [8, 14, 21, 13], [9, 11, 19], [9, 19, 20, 10], [10, 20, 15], [11, 24, 32, 19], [12, 17, 22], [12, 22, 33, 24], [13, 21, 29, 25], [14, 26, 30, 21], [15, 20, 34, 27], [16, 23, 18], [16, 27, 35, 23], [17, 37, 36, 22], [18, 23, 39, 38], [19, 32, 40, 28, 31, 41, 34, 20], [21, 30, 29], [22, 36, 33], [23, 35, 39], [24, 33, 32], [25, 28, 40, 37], [25, 29, 28], [26, 31, 30], [26, 38, 41, 31], [27, 34, 35], [28, 29, 30, 31], [32, 33, 36, 40], [34, 41, 39, 35], [36, 37, 40], [38, 39, 41]],
     12, 1/sqrt(2), 0, 1e-3
    ],
    
    ["Beveled HoHoHo-Style Half-Cube", // Very tricky case
     "x{components={z-,x-,x+}}",
     [[-6, -5.5, -5.5], [-6, -5.5, 5.5], [-6, 5.5, -5.5], [-6, 5.5, 5.5], [-5.64645, -5.64645, -5.64645], [-5.64645, -5.64645, 5.03407], [-5.64645, -5.03407, 5.64645], [-5.64645, 5.03407, 5.64645], [-5.64645, 5.64645, -5.64645], [-5.64645, 5.64645, 5.03407], [-5.5, -5.5, -6], [-5.5, 5.5, -6], [-0.612372, 0, 0.612372], [-0.306186, -0.306186, -0.306186], [-0.306186, 0.306186, -0.306186], [0, 0, 0], [0.306186, -0.306186, -0.306186], [0.306186, 0.306186, -0.306186], [0.612372, 0, 0.612372], [5.5, -5.5, -6], [5.5, 5.5, -6], [5.64645, -5.64645, -5.64645], [5.64645, -5.64645, 5.03407], [5.64645, -5.03407, 5.64645], [5.64645, 5.03407, 5.64645], [5.64645, 5.64645, -5.64645], [5.64645, 5.64645, 5.03407], [6, -5.5, -5.5], [6, -5.5, 5.5], [6, 5.5, -5.5], [6, 5.5, 5.5]],
     [[0, 1, 5, 4], [0, 2, 3, 1], [0, 4, 10], [0, 10, 11, 2], [1, 3, 7, 6], [1, 6, 5], [2, 8, 9, 3], [2, 11, 8], [3, 9, 7], [4, 5, 13], [4, 13, 15, 16, 21], [4, 21, 19, 10], [5, 6, 12, 13], [6, 7, 12], [7, 9, 14, 12], [8, 11, 20, 25], [8, 14, 9], [8, 25, 17, 15, 14], [10, 19, 20, 11], [12, 14, 13], [13, 14, 15], [15, 17, 16], [16, 17, 18], [16, 18, 23, 22], [16, 22, 21], [17, 25, 26], [17, 26, 24, 18], [18, 24, 23], [19, 21, 27], [19, 27, 29, 20], [20, 29, 25], [21, 22, 28, 27], [22, 23, 28], [23, 24, 30, 28], [24, 26, 30], [25, 29, 30, 26], [27, 28, 30, 29]],
     12, 1/sqrt(2), 0, 1e-3
    ],
    
    ["Different Scale on Each Axis",
     ["x"],
     [[-6.5, -4, -1.5], [-6.5, -4, 1.5], [-6.5, 4, -1.5], [-6.5, 4, 1.5], [6.5, -4, -1.5], [6.5, -4, 1.5], [6.5, 4, -1.5], [6.5, 4, 1.5]],
     [[0, 1, 5, 4], [0, 2, 3, 1], [0, 4, 6, 2], [1, 3, 7, 5], [2, 6, 7, 3], [4, 5, 7, 6]],
     [15, 10, 5], 0, 1
    ]

];

echo("---- Burr generation tests");

for (test = burr_piece_test_cases) {
    echo(test[0]);
    burr_piece_base(
        test[1],
        test_poly = [test[2], test[3]],
        $burr_scale = test[4],
        $burr_bevel = test[5],
        $burr_inset = test[6],
        $unit_test_tolerance = (test[7] ? test[7] : 1e-10)
    );
}

$burr_scale = 12;

// Render a complex piece with a male joint, female joint, and label
burr_piece(["x{connect=mz+x-,clabel=L,label_orient=y-x+,label_text=ABC,label_hoffset=0.5}x{connect=mz+,clabel=Ly-}x{connect=fy-,clabel=Lz-}.|.x{connect=mz+}x{connect=fx+z+,clabel=L}.", "....|..x{connect=fx+}."], $burr_bevel = 1/sqrt(2), $burr_inset = 0.07);

translate([40, 0, 0]) beveled_cube([15, 10, 5]);

translate([40, 15, 0]) burr_piece(["xxx|x..", "...|x.."], $burr_bevel = 1, $unit_beveled = true);

// Render male connectors in all 24 orientations
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

*burr_piece(975);
*burr_piece(["xxxx.|x..x.|x....|xxxxx"]);
