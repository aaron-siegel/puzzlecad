/* ====================================================================

  This is puzzlecad, an OpenSCAD library for modeling mechanical
  puzzles. It is provided as part of the Printable Puzzle Project:
  https://puzzlehub.org/ppp

  To obtain the latest version of puzzlecad:
  https://www.thingiverse.com/thing:3198014

  Puzzlecad code repository:
  https://github.com/aaron-siegel/puzzlecad

  puzzlecad is (c) 2019-2022 Aaron Siegel and is distributed under
  the MIT license. This means you may use or modify puzzlecad for any
  purposes, including commercial purposes, provided that you include
  the attribution "puzzlecad is (c) 2019-2022 Aaron Siegel" in any
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

import static org.puzzlecad.XmpuzzleFile.*;

import java.util.ArrayList;

class XmpuzzlePiece {

    XmpuzzleVoxel[] voxels;
    XmpuzzleVoxel[][][] array;

    boolean isEmpty() {

        return array.length == 0;

    }

    XmpuzzlePiece(int gridType, int x, int y, int z, String xmpuzzlePiece) {

        voxels = compressXmpuzzleString(xmpuzzlePiece);

        XmpuzzleVoxel[][][] array = new XmpuzzleVoxel[z][y][x];

        for (int k = 0; k < z; k++) {
            for (int j = 0; j < y; j++) {
                for (int i = 0; i < x; i++) {

                    int index = k * x * y + j * x + i;
                    array[k][j][i] = voxels[index];

                }
            }
        }

        if (gridType == GRID_TYPE_RECTILINEAR) {
            this.array = stripArray(array);
        } else {
            this.array = array;
        }

    }

    XmpuzzleVoxel[] compressXmpuzzleString(String string) {

        ArrayList<XmpuzzleVoxel> voxels = new ArrayList<XmpuzzleVoxel>();
        for (int i = 0; i < string.length(); i++) {
            char ch = string.charAt(i);
            if (ch == '_' || ch == '#' || ch == '+') {
                boolean isFilled = (ch != '_');
                int color = 0;
                while (i + 1 < string.length() && Character.isDigit(string.charAt(i + 1))) {
                    color = color * 10 + string.charAt(i + 1) - '0';
                    i++;
                }
                voxels.add(new XmpuzzleVoxel(isFilled, color));
            } else {
                throw new RuntimeException("Parse error: unknown char '" + ch + "'");
            }
        }
        return voxels.toArray(new XmpuzzleVoxel[0]);

    }

    static XmpuzzleVoxel[][][] stripArray(XmpuzzleVoxel[][][] array) {

        int xmin = Integer.MAX_VALUE;
        int xmax = Integer.MIN_VALUE;
        int ymin = Integer.MAX_VALUE;
        int ymax = Integer.MIN_VALUE;
        int zmin = Integer.MAX_VALUE;
        int zmax = Integer.MIN_VALUE;

        for (int k = 0; k < array.length; k++) {
            for (int j = 0; j < array[k].length; j++) {
                for (int i = 0; i < array[k][j].length; i++) {

                    if (array[k][j][i].isFilled) {
                        xmin = Math.min(xmin, i);
                        xmax = Math.max(xmax, i);
                        ymin = Math.min(ymin, j);
                        ymax = Math.max(ymax, j);
                        zmin = Math.min(zmin, k);
                        zmax = Math.max(zmax, k);
                    }

                }
            }
        }

        if (xmin == Integer.MAX_VALUE)
            return new XmpuzzleVoxel[0][0][0];

        XmpuzzleVoxel[][][] newArray = new XmpuzzleVoxel[zmax - zmin + 1][ymax - ymin + 1][xmax - xmin + 1];

        for (int k = zmin; k <= zmax; k++) {
            for (int j = ymin; j <= ymax; j++) {
                for (int i = xmin; i <= xmax; i++) {

                    newArray[k - zmin][j - ymin][i - xmin] = array[k][j][i];

                }
            }
        }

        return newArray;

    }

}
