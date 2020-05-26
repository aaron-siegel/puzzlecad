package org.puzzlecad;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.zip.GZIPInputStream;

public class XmpuzzleFile {

    public final static int GRID_TYPE_RECTILINEAR = 0;
    public final static int GRID_TYPE_RHOMBIC_TETRAHEDRAL = 3;

    File file;

    int gridType;
    XmpuzzlePiece[] pieces;

    public XmpuzzleFile(String filename) throws Exception {

        this.file = new File(filename);
        load();

    }

    void load() throws Exception {

        GZIPInputStream inputStream = new GZIPInputStream(new FileInputStream(file));
        DocumentBuilder db = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        Document document = db.parse(inputStream);

        gridType = Integer.parseInt(document.getElementsByTagName("gridType").item(0).getAttributes().getNamedItem("type").getTextContent());

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
        List<XmpuzzlePiece> pieces = new ArrayList<XmpuzzlePiece>();

        int pieceNumber = 0;
        for (int i = 0; i < shapesNode.getChildNodes().getLength(); i++) {
            Node node = shapesNode.getChildNodes().item(i);
            if (node.getNodeName().equals("voxel")) {
                String shapeName = "S" + (pieceNumber + 1);
                if (resultIds.contains(pieceNumber)) {
                    System.out.println(" Skipped  shape " + shapeName + ", which is used as a problem result. Re-run with --all if you want to generate it.");
                } else {
                    int x = Integer.parseInt(node.getAttributes().getNamedItem("x").getNodeValue());
                    int y = Integer.parseInt(node.getAttributes().getNamedItem("y").getNodeValue());
                    int z = Integer.parseInt(node.getAttributes().getNamedItem("z").getNodeValue());
                    XmpuzzlePiece piece = new XmpuzzlePiece(gridType, x, y, z, node.getTextContent());
                    if (piece.isEmpty()) {
                        System.out.println(" Skipped  shape " + shapeName + " (no voxels).");
                    } else {
                        System.out.println("Generated shape " + shapeName + " (" + x + "x" + y + "x" + z + ").");
                        pieces.add(piece);
                    }
                }
                pieceNumber++;
            }
        }
        inputStream.close();

        this.pieces = pieces.toArray(new XmpuzzlePiece[0]);

    }

}
