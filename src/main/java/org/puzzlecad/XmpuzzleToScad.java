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

  For details of this license, please refer to the LICENSE-MIT file
  distributed with puzzlecad, or visit:
  https://opensource.org/licenses/MIT

  NOTE THAT WHILE THE PUZZLECAD LIBRARY IS RELEASED UNDER THE MIT
  LICENSE, INDIVIDUAL PUZZLE DESIGNS (INCLUDING VARIOUS DESIGNS THAT
  ARE STORED IN THE PUZZLECAD GITHUB REPO) ARE SHARED UNDER A MORE
  RESTRICTIVE LICENSE. You may not use copyrighted puzzle designs for
  commercial purposes without explicit permission from the copyright
  holder(s).

==================================================================== */

package org.puzzlecad;

import java.io.*;

import static org.puzzlecad.XmpuzzleFile.GRID_TYPE_RECTILINEAR;

public class XmpuzzleToScad {

    Arguments arguments;
    String filename;
    XmpuzzleFile file;

    public XmpuzzleToScad(Arguments arguments) throws Exception {

        this.arguments = arguments;
        this.filename = arguments.filename;
        this.file = new XmpuzzleFile(filename);

    }

    public void convert() throws Exception {

        if (filename.endsWith(".xmpuzzle")) {
            filename = filename.substring(0, filename.lastIndexOf("."));
        }
        PrintWriter writer;
        if (arguments.stdout) {
            writer = new PrintWriter(System.out);
        } else {
            String outputFilename = new File(filename).getName() + ".scad";
            File outputFile = new File(outputFilename);
            System.out.println("Writing " + outputFile.getName() + ".");
            writer = new PrintWriter(outputFile);
        }
        write(writer);

    }

    public void write(PrintWriter out) throws Exception {

        out.println("include <puzzlecad.scad>");
        out.println();

        out.println("// This model was generated by puzzlecad's bt2scad tool from the BurrTools file:");
        out.println("// " + new File(filename).getName());
        out.println();
        out.println("// You can freely edit this file to make changes to the model structure or parameters.");
        out.println();

        if (arguments.header == null) {
            // Generate a header
            out.println("require_puzzlecad_version(\"2.0\");");
            out.println();
            if (file.gridType == GRID_TYPE_RECTILINEAR) {
                out.println("$burr_scale = " + defaultScale() + ";");
                out.println("$auto_layout = true;");
            } else {
                out.println("$burr_scale = 27;");
            }
        } else {
            BufferedReader reader = new BufferedReader(new FileReader(arguments.header));
            String line;
            while ((line = reader.readLine()) != null) {
                out.println(line);
            }
            reader.close();
        }

        out.println();

        out.println("burr_plate([");

        for (int i = 0; i < file.pieces.length; i++) {

            boolean writeThisPiece = true;

            if (arguments.filterByColor != null) {
                writeThisPiece = false;
                filterLoop:
                for (XmpuzzleVoxel voxel : file.pieces[i].voxels) {
                    for (int color : arguments.filterByColor) {
                        if (voxel.color == color) {
                            writeThisPiece = true;
                            break filterLoop;
                        }
                    }
                }
            }

            if (writeThisPiece) {
                if (file.gridType == GRID_TYPE_RECTILINEAR) {
                    out.print(rectilinearPieceToString(file.pieces[i]));
                } else {
                    out.print(rhombicTetrahedralPieceToString(file.pieces[i]));
                }
                out.print(",");
                out.println();
            }

        }
        out.println("]);");
        out.close();

    }

    public String defaultScale() {

        int maxdim = 0;
        for (XmpuzzlePiece piece : file.pieces) {
            maxdim = Math.max(maxdim, piece.array.length);
            maxdim = Math.max(maxdim, piece.array[0].length);
            maxdim = Math.max(maxdim, piece.array[0][0].length);
        }

        if (maxdim <= 3)
            return "17";
        else if (maxdim == 4)
            return "16";
        else if (maxdim == 5)
            return "14";
        else
            return "11";

    }

    public String rectilinearPieceToString(XmpuzzlePiece piece) {

        StringBuilder result = new StringBuilder("    [ ");
        XmpuzzleVoxel[][][] array = piece.array;
        for (int k = 0; k < array.length; k++) {
            result.append("\"");
            for (int j = 0; j < array[k].length; j++) {
                for (int i = 0; i < array[k][j].length; i++) {
                    result.append(array[k][j][i].isFilled ? 'x' : '.');
                }
                if (j < array[k].length - 1) {
                    result.append("|");
                }
            }
            result.append("\"");
            if (k < array.length - 1) {
                result.append(",\n      ");
            }
        }
        result.append(" ]");
        return result.toString();

    }

    public String rhombicTetrahedralPieceToString(XmpuzzlePiece piece) {

        StringBuilder result = new StringBuilder("    [ ");
        XmpuzzleVoxel[][][] array = piece.array;
        for (int k = 0; k < piece.array.length; k += 5) {
            result.append("\"");
            for (int j = 0; j < array[k].length; j += 5) {
                for (int i = 0; i < array[k][j].length; i += 5) {
                    result.append(rhombicTetrahedralVoxelToString(array, i, j, k));
                }
                if (j < array[k].length - 5) {
                    result.append("|");
                }
            }
            result.append("\"");
            if (k < array.length - 5) {
                result.append(",\n      ");
            }
        }
        result.append(" ]");
        return result.toString();

    }

    public String rhombicTetrahedralVoxelToString(XmpuzzleVoxel[][][] array, int x, int y, int z) {

        StringBuilder result = new StringBuilder();

        for (int k = 0; k < 5; k++) {
            for (int j = 0; j < 5; j++) {
                for (int i = 0; i < 5; i++) {

                    if (array[z + k][y + j][x + i].isFilled) {
                        String componentName = diagonalComponentNames[k][j][i];
                        if (componentName == null) {
                            throw new RuntimeException("Invalid .xmpuzzle file: (" + (x + i) + "," + (y + j) + "," + (z + k) + ")");
                        }
                        result.append(componentName);
                        result.append(',');
                    }

                }
            }
        }

        if (result.length() == 0) {
            return ".";
        } else {
            // Remove trailing comma
            return "x{components={" + result.deleteCharAt(result.length() - 1).toString() + "}}";
        }

    }

    public static void main(String[] args) {

        Arguments arguments = null;

        try {
            arguments = new Arguments(args);
        } catch (Exception exc) {
        }

        if (arguments == null || arguments.filename == null) {
            System.out.println("Usage: java -jar bt2scad.jar [btfile]");
            System.out.println("  where [btfile] is an .xmpuzzle file");
            return;
        }

        try {
            new XmpuzzleToScad(arguments).convert();
        } catch (Exception exc) {
            System.err.println("BurrTools conversion failed with the following error message:");
            System.err.println(exc.getMessage());
            exc.printStackTrace();
            System.exit(-1);
        }

    }

    static String[] directions = new String[] { "z-", "y-", "x-", "x+", "y+", "z+" };
    static String[][][] diagonalComponentNames = new String[5][5][5];

    static {

        for (String primary : directions) {
            for (String secondary : directions) {
                if (primary.charAt(0) != secondary.charAt(0)) {
                    int x = directionsToCoord(primary, secondary, 'x');
                    int y = directionsToCoord(primary, secondary, 'y');
                    int z = directionsToCoord(primary, secondary, 'z');
                    diagonalComponentNames[z][y][x] = primary + secondary;
                }
            }
        }

    }

    static int directionsToCoord(String primary, String secondary, char axis) {

        if (primary.charAt(0) == axis) {
            if (primary.charAt(1) == '-')
                return 0;
            else
                return 4;
        } else if (secondary.charAt(0) == axis) {
            if (secondary.charAt(1) == '-')
                return 1;
            else
                return 3;
        } else {
            return 2;
        }

    }

}
