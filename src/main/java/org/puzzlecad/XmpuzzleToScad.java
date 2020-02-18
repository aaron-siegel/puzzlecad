package org.puzzlecad;

import org.w3c.dom.Document;
import org.w3c.dom.Node;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.File;
import java.io.FileInputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.GZIPInputStream;

public class XmpuzzleToScad {

    File file;

    public XmpuzzleToScad(String filename) {

        this.file = new File(filename);

    }

    public void convert() throws Exception {

        GZIPInputStream inputStream = new GZIPInputStream(new FileInputStream(file));
        DocumentBuilder db = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document document = db.parse(inputStream);

        int gridType = Integer.parseInt(document.getElementsByTagName("gridType").item(0).getAttributes().getNamedItem("type").getTextContent());

        if (gridType != 0) {
            throw new UnsupportedOperationException("Unsupported BurrTools grid type (currently only Rectilinear is supported)");
        }

        Node shapes = document.getElementsByTagName("shapes").item(0);
        List<String> pieces = new ArrayList<>();

        for (int i = 0; i < shapes.getChildNodes().getLength(); i++) {
            Node piece = shapes.getChildNodes().item(i);
            if (piece.getNodeName().equals("voxel")) {
                int x = Integer.parseInt(piece.getAttributes().getNamedItem("x").getNodeValue());
                int y = Integer.parseInt(piece.getAttributes().getNamedItem("y").getNodeValue());
                int z = Integer.parseInt(piece.getAttributes().getNamedItem("z").getNodeValue());
                String convertedPiece = convertPiece(x, y, z, piece.getTextContent());
                pieces.add(convertedPiece);
            }
        }
        inputStream.close();

        String filename = file.getName();
        if (filename.endsWith(".xmpuzzle")) {
            filename = filename.substring(0, filename.lastIndexOf("."));
        }
        String outputFilename = filename + ".scad";
        write(new File(outputFilename), pieces);

    }

    public String convertPiece(int x, int y, int z, String xmpuzzlePiece) {

        StringBuilder result = new StringBuilder("    [ ");
        for (int k = 0; k < z; k++) {
            result.append("\"");
            for (int j = 0; j < y; j++) {
                for (int i = 0; i < x; i++) {
                    result.append(xmpuzzlePiece.charAt(k * x * y + j * x + i) == '#' ? 'x' : '.');
                }
                if (j < y - 1) {
                    result.append("|");
                }
            }
            result.append("\"");
            if (k < z - 1) {
                result.append(",\n      ");
            }
        }
        result.append(" ]");
        return result.toString();

    }

    public void write(File outputFile, List<String> pieces) throws Exception {

        PrintWriter out = new PrintWriter(outputFile);

        out.println("include <puzzlecad.scad>");
        out.println();

        out.println("require_puzzlecad_version(\"2.0\")");
        out.println("$auto_layout = true;");
        out.println();

        out.println("burr_plate([");
        for (int i = 0; i < pieces.size(); i++) {
            out.print(pieces.get(i));
            if (i < pieces.size() - 1) {
                out.print(",");
            }
            out.println();
        }
        out.println("]);");
        out.close();

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
            System.exit(-1);
        }

    }

}
