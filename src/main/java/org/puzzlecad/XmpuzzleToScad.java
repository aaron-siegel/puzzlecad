package org.puzzlecad;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.File;
import java.io.FileInputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.zip.GZIPInputStream;

public class XmpuzzleToScad {

    public final static int GRID_TYPE_RECTILINEAR = 0;
    public final static int GRID_TYPE_RHOMBIC_TETRAHEDRAL = 3;

    File file;

    public XmpuzzleToScad(String filename) {

        this.file = new File(filename);

    }

    public void convert() throws Exception {

        GZIPInputStream inputStream = new GZIPInputStream(new FileInputStream(file));
        DocumentBuilder db = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document document = db.parse(inputStream);

        int gridType = Integer.parseInt(document.getElementsByTagName("gridType").item(0).getAttributes().getNamedItem("type").getTextContent());

        if (gridType != GRID_TYPE_RECTILINEAR && gridType != GRID_TYPE_RHOMBIC_TETRAHEDRAL) {
            throw new UnsupportedOperationException("Unsupported BurrTools grid type (currently only Rectilinear and Rhombic Tetrahedral are supported)");
        }

        NodeList resultNodes = document.getElementsByTagName("result");
        Set<Integer> resultIds = new HashSet<Integer>();
        for (int i = 0; i < resultNodes.getLength(); i++) {
            String id = resultNodes.item(i).getAttributes().getNamedItem("id").getNodeValue();
            resultIds.add(Integer.parseInt(id));
        }

        Node shapesNode = document.getElementsByTagName("shapes").item(0);
        List<int[][][]> pieces = new ArrayList<int[][][]>();

        int pieceNumber = 0;
        for (int i = 0; i < shapesNode.getChildNodes().getLength(); i++) {
            Node node = shapesNode.getChildNodes().item(i);
            if (node.getNodeName().equals("voxel")) {
                if (resultIds.contains(pieceNumber)) {
                    System.out.println("Skipping  shape #" + pieceNumber + ", which is used as a problem result. Re-run with --all if you want to generate it.");
                } else {
                    int x = Integer.parseInt(node.getAttributes().getNamedItem("x").getNodeValue());
                    int y = Integer.parseInt(node.getAttributes().getNamedItem("y").getNodeValue());
                    int z = Integer.parseInt(node.getAttributes().getNamedItem("z").getNodeValue());
                    int[][][] array = xmpuzzleToArray(gridType, x, y, z, node.getTextContent());
                    if (array.length == 0) {
                        System.out.println("Skipping  shape #" + pieceNumber + " (no voxels).");
                    } else {
                        System.out.println("Generated shape #" + pieceNumber + " (" + x + "x" + y + "x" + z + ").");
                        pieces.add(array);
                    }
                }
                pieceNumber++;
            }
        }
        inputStream.close();

        String filename = file.getName();
        if (filename.endsWith(".xmpuzzle")) {
            filename = filename.substring(0, filename.lastIndexOf("."));
        }
        String outputFilename = filename + ".scad";
        write(new File(outputFilename), gridType, pieces);

    }

    public int[][][] xmpuzzleToArray(int gridType, int x, int y, int z, String xmpuzzlePiece) {

        String filteredString = filterXmpuzzleString(xmpuzzlePiece);

        int[][][] array = new int[z][y][x];

        for (int k = 0; k < z; k++) {
            for (int j = 0; j < y; j++) {
                for (int i = 0; i < x; i++) {

                    array[k][j][i] = filteredString.charAt(k * x * y + j * x + i) == '#' ? 1 : 0;

                }
            }
        }

        if (gridType == GRID_TYPE_RECTILINEAR) {
            return stripArray(array);
        } else {
            return array;
        }

    }

    public String filterXmpuzzleString(String string) {

        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < string.length(); i++) {
            char ch = string.charAt(i);
            if (ch == '_' || ch == '#') {
                builder.append(ch);
            }
        }
        return builder.toString();

    }

    public int[][][] stripArray(int[][][] array) {

        int xmin = Integer.MAX_VALUE;
        int xmax = Integer.MIN_VALUE;
        int ymin = Integer.MAX_VALUE;
        int ymax = Integer.MIN_VALUE;
        int zmin = Integer.MAX_VALUE;
        int zmax = Integer.MIN_VALUE;

        for (int k = 0; k < array.length; k++) {
            for (int j = 0; j < array[k].length; j++) {
                for (int i = 0; i < array[k][j].length; i++) {

                    if (array[k][j][i] != 0) {
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
            return new int[0][0][0];

        int[][][] newArray = new int[zmax - zmin + 1][ymax - ymin + 1][xmax - xmin + 1];

        for (int k = zmin; k <= zmax; k++) {
            for (int j = ymin; j <= ymax; j++) {
                for (int i = xmin; i <= xmax; i++) {

                    newArray[k - zmin][j - ymin][i - xmin] = array[k][j][i];

                }
            }
        }

        return newArray;

    }

    public void write(File outputFile, int gridType, List<int[][][]> pieces) throws Exception {

        System.out.println("Writing " + outputFile.getName() + ".");

        PrintWriter out = new PrintWriter(outputFile);

        out.println("include <puzzlecad.scad>");
        out.println();

        out.println("// This model was generated by puzzlecad's bt2scad tool from the BurrTools file:");
        out.println("// " + file.getName());
        out.println();
        out.println("// You can freely edit this file to make changes to the model structure or parameters.");
        out.println();

        out.println("require_puzzlecad_version(\"2.0\");");
        out.println();
        out.println("$burr_scale = " + defaultScale(pieces) + ";");
        if (gridType == GRID_TYPE_RECTILINEAR) {
            out.println("$auto_layout = true;");
        }
        out.println();

        out.println("burr_plate([");
        for (int i = 0; i < pieces.size(); i++) {
            if (gridType == GRID_TYPE_RECTILINEAR) {
                out.print(rectilinearPieceToString(pieces.get(i)));
            } else {
                out.print(rhombicTetrahedralPieceToString(pieces.get(i)));
            }
            if (i < pieces.size() - 1) {
                out.print(",");
            }
            out.println();
        }
        out.println("]);");
        out.close();

    }

    public String defaultScale(List<int[][][]> pieces) {

        int maxdim = 0;
        for (int[][][] piece : pieces) {
            maxdim = Math.max(maxdim, piece.length);
            maxdim = Math.max(maxdim, piece[0].length);
            maxdim = Math.max(maxdim, piece[0][0].length);
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

    public String rectilinearPieceToString(int[][][] array) {

        StringBuilder result = new StringBuilder("    [ ");
        for (int k = 0; k < array.length; k++) {
            result.append("\"");
            for (int j = 0; j < array[k].length; j++) {
                for (int i = 0; i < array[k][j].length; i++) {
                    result.append(array[k][j][i] == 1 ? 'x' : '.');
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

    public String rhombicTetrahedralPieceToString(int[][][] array) {

        StringBuilder result = new StringBuilder("    [ ");
        for (int k = 0; k < array.length; k += 5) {
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

    public String rhombicTetrahedralVoxelToString(int[][][] array, int x, int y, int z) {

        StringBuilder result = new StringBuilder();

        for (int k = 0; k < 5; k++) {
            for (int j = 0; j < 5; j++) {
                for (int i = 0; i < 5; i++) {

                    if (array[z + k][y + j][x + i] == 1) {
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

        try {
        	if (args.length < 1) {
        		System.out.println("Usage: java -jar bt-to-scad.jar [btfile]");
        		System.out.println("  where [btfile] is an .xmpuzzle file");
        	} else {
	            new XmpuzzleToScad(args[0]).convert();
	        }
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
