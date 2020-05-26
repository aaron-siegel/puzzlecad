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

                    array[k][j][i] = voxels[k * x * y + j * x + i];

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
            if (ch == '_' || ch == '#') {
                boolean isFilled = (ch == '#');
                int color = 0;
                if (i + 1 < string.length() && Character.isDigit(string.charAt(i + 1))) {
                    color = string.charAt(i + 1) - '0';
                }
                voxels.add(new XmpuzzleVoxel(isFilled, color));
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
