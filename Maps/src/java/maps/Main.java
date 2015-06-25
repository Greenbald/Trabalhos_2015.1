package maps;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Queue;
import java.util.Random;

import javax.swing.JOptionPane;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class Main {

    static Map<Long, GeoNode> nodeMap;
    static ArrayList<GeoNode> nodeList;
    static NodeList nList;
    static NodeList wList;
    KdTree.WeightedSqrEuclid<GeoNode> nodeTree;
    short heuristic;
    short straightDist = 0;
    short highwayInfo = 1;

    public Main() {
        nodeMap = new HashMap<Long, GeoNode>();
        nodeList = new ArrayList<GeoNode>();
        nodeTree = new KdTree.WeightedSqrEuclid<GeoNode>(2, Integer.MAX_VALUE);
    }

    public boolean init(String file) {
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            Document doc = db.parse(new File(file));
            nList = doc.getElementsByTagName("node");
            wList = doc.getElementsByTagName("way");
            importRoadsUnprocessed(doc);
            importNodeCoordinates(doc);
        } catch (FileNotFoundException e) {
            System.out.println("File not found.");
            return false;
        } catch (Exception e) {
            System.out.println("Error:" + e);
            return false;
        }
        return true;
    }

    public GeoNode getNearest(GeoNode n) {
        double[] coords = new double[]{n.getLat(), n.getLon()};
        return nodeTree.nearestNeighbor(coords, 1, false).get(0).value;
    }

    public String shortestPath(double lat1, double lon1, double lat2, double lon2, String algorithm) {
        GeoNode a = getNearest(new GeoNode(lat1, lon1));
        GeoNode b = getNearest(new GeoNode(lat2, lon2));
        if (algorithm.equals("aStarSLH")) {
            heuristic = straightDist;
            return aStar(a, b);
        } else if (algorithm.equals("aStarHIH")) {
            heuristic = highwayInfo;
            return aStar(a, b);
        } else if (algorithm.equals("greedySearchSLH")) {
            heuristic = straightDist;
            return greedySearch(a, b);
        } else if (algorithm.equals("greedySearchHIH")) {
            heuristic = highwayInfo;
            return greedySearch(a, b);
        } else if (algorithm.equals("uniformCostSearch")) {
            return uniformCostSearch(a, b);
        } else if (algorithm.equals("breadthFirstSearch")) {
            return breadthFirstSearch(a, b);
        } else if (algorithm.equals("hillClimbing")) {
            return hillClimbing(a, b);
        }
        return "Failure";
    }

    public String aStar(GeoNode start, GeoNode dest) {
        long started = System.currentTimeMillis();
        long generated = 0;
        ArrayList<GeoNode> queue = new ArrayList<>();
        ArrayList<GeoNode> explored = new ArrayList<>();
        HashMap<GeoNode, GeoNode> path = new HashMap<>();
        queue.add(start);

        start.setDistance(0);
        start.setFunction(start.getDistance() + getHeuristicValue(start, dest));

        GeoNode actual = null;
        double fg;
        while (!queue.isEmpty()) {
            Collections.sort(queue);
            actual = queue.get(0);
            if (actual == dest) {
                long time = System.currentTimeMillis() - started;
                return solution(start, dest, path, "Execution time(ms) : " + time
                        + ", Distance(km) : " + actual.getDistance()
                        + ", Generated Nodes : " + generated);
            }
            queue.remove(actual);
            explored.add(actual);
            fg = 0;
            for (GeoNode n : actual.getConnections()) {
                if (!(explored.contains(n))) {
                    fg = actual.getDistance() + getHeuristicValue(actual, n);
                    if ((n.getDistance() > fg) || !(queue.contains(n))) {
                        path.put(n, actual);
                        n.setDistance(actual.getDistance() + actual.distanceFrom(n));
                        n.setFunction(n.getDistance() + getHeuristicValue(n, dest));
                        if (!(queue.contains(n))) {
                            queue.add(n);
                            generated++;
                        }
                    }
                }
            }
        }
        return "Failure";
    }

    public String greedySearch(GeoNode start, GeoNode dest) {
        long started = System.currentTimeMillis();
        long generated = 0;
        ArrayList<GeoNode> queue = new ArrayList<>();
        ArrayList<GeoNode> explored = new ArrayList<>();
        HashMap<GeoNode, GeoNode> path = new HashMap<>();
        queue.add(start);
        
        start.setDistance(0);
        start.setFunction(getHeuristicValue(start, dest));

        GeoNode actual = null;
        double fg;
        while (!queue.isEmpty()) {
            Collections.sort(queue);
            actual = queue.get(0);
            if (actual == dest) {
                long time = System.currentTimeMillis() - started;
                return solution(start, dest, path, "Execution time(ms) : " + time
                        + ", Distance(km) : " + actual.getDistance()
                        + ", Generated Nodes : " + generated);
            }
            queue.remove(actual);
            explored.add(actual);
            fg = 0;
            for (GeoNode n : actual.getConnections()) {
                if (!(explored.contains(n))) {
                    fg = getHeuristicValue(actual, n);
                    if ((n.getFunction() > fg) || !(queue.contains(n))) {
                        path.put(n, actual);
                        n.setDistance(actual.getDistance() + actual.distanceFrom(n));
                        n.setFunction(getHeuristicValue(n, dest));
                        if (!(queue.contains(n))) {
                            queue.add(n);
                            generated++;
                        }
                    }
                }
            }
        }
        return "Failure";
    }

    public String uniformCostSearch(GeoNode start, GeoNode dest) {
        long generated = 0;
        long started = System.currentTimeMillis();
        ArrayList<GeoNode> queue = new ArrayList<>();
        ArrayList<GeoNode> explored = new ArrayList<>();
        HashMap<GeoNode, GeoNode> path = new HashMap<>();
        queue.add(start);
        start.setFunction(0);
        GeoNode actual = null;
        double pathCost = 0;
        while (!queue.isEmpty()) {
            Collections.sort(queue);
            actual = queue.get(0);
            if (actual == dest) {
                long time = System.currentTimeMillis() - started;
                return solution(start, dest, path, "Execution time(ms) : " + time
                        + ", Distance(km) : " + actual.getFunction()
                        + ", Generated Nodes : " + generated);
            }
            queue.remove(actual);
            explored.add(actual);
            boolean nodeExplored = false;
            boolean nodeFrontier = false;
            for (GeoNode n : actual.getConnections()) {
                pathCost = actual.getFunction() + actual.distanceFrom(n);
                nodeExplored = explored.contains(n);
                nodeFrontier = queue.contains(n);
                if (n.getFunction() > pathCost || (!nodeFrontier && !nodeExplored)) {
                    n.setFunction(pathCost);
                    path.put(n, actual);
                    if (!nodeFrontier && !nodeExplored) {
                        queue.add(n);
                        generated++;
                    }
                }
            }
        }
        return "Failure";
    }

    public String breadthFirstSearch(GeoNode start, GeoNode dest) {
        long generated = 0;
        long started = System.currentTimeMillis();
        Queue<GeoNode> queue = new ArrayDeque<>();
        ArrayList<GeoNode> explored = new ArrayList<>();
        HashMap<GeoNode, GeoNode> path = new HashMap<>();
        queue.add(start);
        start.setDistance(0);
        GeoNode actual = null;
        while (!queue.isEmpty()) {
            actual = queue.element();
            if (actual == dest) {
                long time = System.currentTimeMillis() - started;
                return solution(start, dest, path, "Execution time(ms) : " + time
                        + ", Distance(km) : " + actual.getDistance()
                        + ", Generated Nodes : " + generated);
            }
            queue.remove();
            explored.add(actual);
            for (GeoNode n : actual.getConnections()) {
                if (!explored.contains(n)) {
                    n.setDistance(actual.getDistance() + actual.distanceFrom(n));
                    path.put(n, actual);
                    queue.add(n);
                    generated++;
                }
            }
        }
        return "Failure";
    }

    public String hillClimbing(GeoNode start, GeoNode dest) {
        long started = System.currentTimeMillis();
        HashMap<GeoNode, GeoNode> path = new HashMap<>();
        start.setDistance(0);
        start.setFunction(0 + start.distanceFrom(dest));
        GeoNode actualNode = start;
        LinkedList<GeoNode> explored = new LinkedList<>();
        explored.add(start);
        GeoNode nextNode;
        do {
            fillHeuristic(actualNode, dest);
            nextNode = hill_climbing(actualNode, dest, 30, explored);
            if (nextNode == null) {
                actualNode = path.get(actualNode);
            } else {
                explored.add(nextNode);
                path.put(nextNode, actualNode);
                actualNode = nextNode;
            }

        } while (actualNode != dest && actualNode != null);
        if (actualNode == null) {
            return "Failure";
        }
        long time = System.currentTimeMillis() - started;
        return solution(start, dest, path, "Execution time(ms) : " + time);
    }

    public GeoNode hill_climbing(GeoNode node, GeoNode dest, int kMax, LinkedList<GeoNode> explored) {
        double value = 0; /*TMin = temp_function(node, dest);*/

        double valueMin = Double.MAX_VALUE;
        int k = 0;
        GeoNode actualNode = null, possibleNode = node;
        while (k < kMax) {
            possibleNode = getSuccessor(node);
            value = calculateValue(possibleNode, dest);
            if (value < 0.030) {
                return dest;
            }

            if (value < valueMin && !explored.contains(possibleNode)) {
                actualNode = possibleNode;
                valueMin = value;
            }
            k++;
        }
        return actualNode;
    }

    public double calculateValue(GeoNode node, GeoNode dest) {
        return node.distanceFrom(dest);
    }

    public void fillHeuristic(GeoNode node, GeoNode dest) {
        for (GeoNode n : node.getConnections()) {
            n.setDistance(node.getDistance() + node.distanceFrom(n));
            n.setFunction(n.getDistance() + n.distanceFrom(dest));
        }
    }

    public GeoNode getSuccessor(GeoNode node) /* works */ {
        GeoNode actualNode = null;
        do {
            int i = (int) ((int) Math.floor((node.getConnections().size()) * Math.random()));
            actualNode = node.getConnections().get(i);
        } while (actualNode == node);
        return actualNode;
    }

    public String solution(GeoNode start, GeoNode dest, HashMap<GeoNode, GeoNode> path, String info) {
        LinkedList<GeoNode> nodes = new LinkedList<GeoNode>();
        nodes.add(dest);
        GeoNode current = dest;
        String result = "";
        long pathNodes = 0;
        while (current != start) {
            current = path.get(current);
            nodes.add(current);
            pathNodes++;
        }
        for (int i = 0; i < nodes.size(); i++) {
            result += (nodes.get(nodes.size() - i - 1).getLat() + "," + nodes.get(nodes.size() - i - 1).getLon());
            if (i < nodes.size() - 1) {
                result += ",";
            }
        }
        return result + "|" + info + ", Path Nodes : " + pathNodes;
    }

    public void importNodeCoordinates(Document doc) throws IOException {
        for (int i = 0; i < nList.getLength(); i++) {
            Node n = nList.item(i);
            Element e = (Element) n;
            long id = Long.valueOf(e.getAttribute("id"));
            GeoNode actualNode = nodeMap.get(id);
            if (actualNode != null) {
                actualNode.setLatLon(Double.valueOf(e.getAttribute("lat")), Double.valueOf(e.getAttribute("lon")));
                nodeList.add(actualNode);
                double[] coords = new double[]{actualNode.getLat(), actualNode.getLon()};
                nodeTree.addPoint(coords, actualNode);
            }
        }
    }

    public void importRoadsUnprocessed(Document doc) {
        LinkedList<Long> connections = new LinkedList<Long>();
        boolean highway;
        boolean oneway;
        boolean noVehicle;
        boolean track;
        boolean footway;
        int maxspeed;
        int highwayType;
        int surfaceType;
        for (int i = 0; i < wList.getLength(); i++) {
            Node n = wList.item(i);
            Node childNode = n.getFirstChild();
            connections.clear();
            highway = false;
            oneway = false;
            noVehicle = false;
            track = false;
            footway = false;
            maxspeed = 0;
            highwayType = 0;
            surfaceType = 0;
            while (childNode.getNextSibling() != null) {
                if (childNode.getNodeType() == Node.ELEMENT_NODE && childNode.getNodeName() == "nd") {
                    Element childElement = (Element) childNode;
                    connections.add(Long.valueOf(childElement.getAttribute("ref")));
                } else if (childNode.getNodeType() == Node.ELEMENT_NODE && childNode.getNodeName() == "tag") {
                    Element childElement = (Element) childNode;
                    if (childElement.getAttribute("k").equals("highway")) {
                        highway = true;
                        switch (childElement.getAttribute("v")) {
                            case "track":
                                track = true;
                                break;
                            case "motorway":
                                highwayType = 10;
                                break;
                            case "trunk":
                                highwayType = 9;
                                break;
                            case "primary":
                                highwayType = 8;
                                break;
                            case "secondary":
                                highwayType = 7;
                                break;
                            case "tertiary":
                                highwayType = 6;
                                break;
                            case "residential":
                                highwayType = 5;
                                break;
                            default:
                                highwayType = 4;
                                break;
                        }
                    } else {
                        highwayType = 7;
                    }
                    if (childElement.getAttribute("k").equals("maxspeed")) {
                        try {
                            maxspeed = Integer.parseInt(childElement.getAttribute("v"));
                        } catch (NumberFormatException e) {
                            maxspeed = 50;
                        }
                    }
                    if (childElement.getAttribute("k").equals("surface")) {
                        switch (childElement.getAttribute("v")) {
                            case "paved":
                            case "asphalt":
                            case "concrete":
                                surfaceType = 3;
                                break;
                            case "cobblestone":
                                surfaceType = 2;
                                break;
                            default:
                                surfaceType = 1;
                        }
                    } else {
                        surfaceType = 1; //No-information treatment
                    }
                    if (childElement.getAttribute("v").equals("footway")) {
                        footway = true;
                    }
                    if (childElement.getAttribute("k").equals("oneway")) {
                        oneway = true;
                    }
                    if (childElement.getAttribute("k").equals("motor_vehicle")) {
                        if (childElement.getAttribute("v").equals("no")) {
                            noVehicle = true;
                        }
                    }
                }
                childNode = childNode.getNextSibling();

            }
            if (highway && !track && !footway && !noVehicle && connections.size() > 1) {
                for (int k = 0; k < connections.size() - 1; k++) {
                    if (nodeMap.get(connections.get(k)) == null) {
                        nodeMap.put(connections.get(k), new GeoNode(connections.get(k)));
                    }
                    if (nodeMap.get(connections.get(k + 1)) == null) {
                        nodeMap.put(connections.get(k + 1), new GeoNode(connections.get(k + 1)));
                    }
                    GeoNode actualNode = nodeMap.get(connections.get(k));
                    if (actualNode != null) {
                        actualNode.setMaxSpeed(maxspeed);
                        actualNode.setHighwayType(highwayType);
                        actualNode.setSurfaceType(surfaceType);
                    }
                    GeoNode a = nodeMap.get(connections.get(k));
                    GeoNode b = nodeMap.get(connections.get(k + 1));
                    a.connect(b);
                    if (!oneway) {
                        b.connect(a);
                    }
                }
            }
        }
    }

    private double getHeuristicValue(GeoNode n1, GeoNode n2) {
        if (heuristic == straightDist) {
            return n1.distanceFrom(n2);
        } else {
            return n1.wayValuesHeur();
        }
    }
}
