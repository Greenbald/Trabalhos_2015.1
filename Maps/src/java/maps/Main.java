package maps;



import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
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

public class Main
{
    static Map<Long, GeoNode> nodeMap;
    static ArrayList<GeoNode> nodeList;
    KdTree.WeightedSqrEuclid<GeoNode> nodeTree;
    public Main()
    {
        nodeMap = new HashMap<Long, GeoNode>();
        nodeList = new ArrayList<GeoNode>();
	nodeTree = new KdTree.WeightedSqrEuclid<GeoNode>(2, Integer.MAX_VALUE);
    }
    public boolean init(String file)
    {
        try
        {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            Document doc = db.parse(new File(file));
            importRoadsUnprocessed(doc);
            importNodeCoordinates(doc);
        } catch(FileNotFoundException e) {
            System.out.println("File not found.");
            return false;
        } catch(Exception e) {
            System.out.println("Issue opening the file.");
            return false;
        }
        return true;
    }

    public GeoNode getNearest(GeoNode n)
    {
        double[] coords = new double[]{n.getLat(), n.getLon()};
        return nodeTree.nearestNeighbor(coords, 1, false).get(0).value;
    }

    public String shortestPath(double lat1, double lon1, double lat2, double lon2, String algorithm)
    {
        GeoNode a = getNearest(new GeoNode(lat1,lon1));
        GeoNode b = getNearest(new GeoNode(lat2,lon2));
        if(algorithm.equals("aStar"))
            return aStar(a,b);
        else if(algorithm.equals("uniformCostSearch"))
                return uniformCostSearch(a,b);
        else if(algorithm.equals("breadthFirstSearch"))
                return breadthFirstSearch(a,b);
        else if(algorithm.equals("simulatedAnnealing"))
                return simulatedAnnealing(a, b);
        return "Failure";
    }

    public String aStar(GeoNode start, GeoNode dest)
    {
        long started = System.currentTimeMillis();
        long generated = 0;
        ArrayList<GeoNode> queue = new ArrayList<>();
        ArrayList<GeoNode> explored = new ArrayList<>();
        HashMap<GeoNode, GeoNode> path = new HashMap<>();
        queue.add(start);

        start.setDistance(0);
        start.setFunction(start.getDistance() + start.distanceFrom(dest));

        GeoNode actual = null;
        double fg, fh;
        while(!queue.isEmpty())
        {
            Collections.sort(queue);
            actual = queue.get(0);
            if(actual == dest)
            {
                long time = System.currentTimeMillis() - started;
                return solution(start, dest, path, "Execution time(ms) : " + time +
                                ", Distance(km) : " + actual.getDistance() +
                                ", Generated Nodes : "  + generated);
            }
            queue.remove(actual);
            explored.add(actual);
            fg = 0;
            for (GeoNode n : actual.getConnections())
            {
                if(!(explored.contains(n)))
                {
                    fg = actual.getDistance() + actual.distanceFrom(n);
                    if((n.getDistance() > fg) || !(queue.contains(n)))
                    {
                        path.put(n, actual);
                        n.setDistance(fg);
                        n.setFunction(n.getDistance() + n.distanceFrom(dest));
                        if(!(queue.contains(n)))
                        {
                            queue.add(n);
                            generated++;
                        }
                    }
                }
            }
        }
        return "Failure";
    }

    public String uniformCostSearch(GeoNode start, GeoNode dest)
    {
        long generated = 0;
        long started = System.currentTimeMillis();
        ArrayList<GeoNode> queue = new ArrayList<>();
        ArrayList<GeoNode> explored = new ArrayList<>();
        HashMap<GeoNode, GeoNode> path = new HashMap<>();
        queue.add(start);
        start.setFunction(0);
        GeoNode actual = null;
        double pathCost = 0;
        while(!queue.isEmpty())
        {
            Collections.sort(queue);
            actual = queue.get(0);
            if(actual == dest)
            {
                long time = System.currentTimeMillis() - started;
                return solution(start, dest, path, "Execution time(ms) : " + time +
                                ", Distance(km) : " + actual.getFunction() +
                                ", Generated Nodes : "  + generated);
            }
            queue.remove(actual);
            explored.add(actual);
            boolean nodeExplored = false;
            boolean nodeFrontier = false;
            for(GeoNode n : actual.getConnections())
            {
                pathCost = actual.getFunction() + actual.distanceFrom(n);
                nodeExplored = explored.contains(n);
                nodeFrontier = queue.contains(n);
                if(n.getFunction() > pathCost || (!nodeFrontier && !nodeExplored))
                {
                    n.setFunction(pathCost);
                    path.put(n, actual);
                    if(!nodeFrontier && !nodeExplored)
                    {
                        queue.add(n);
                        generated++;
                    }
                }
            }
        }
        return "Failure";
    }

    public String breadthFirstSearch(GeoNode start, GeoNode dest)
    {
        long generated = 0;
        long started = System.currentTimeMillis();
        Queue<GeoNode> queue = new ArrayDeque<>();
        ArrayList<GeoNode> explored = new ArrayList<>();
        HashMap<GeoNode, GeoNode> path = new HashMap<>();
        queue.add(start);
        start.setDistance(0);
        GeoNode actual = null;
        while(!queue.isEmpty())
        {
            actual = queue.element();
            if(actual == dest)
            {
                long time = System.currentTimeMillis() - started;
                return solution(start, dest, path, "Execution time(ms) : " + time +
                                ", Distance(km) : " + actual.getDistance() +
                                ", Generated Nodes : "  + generated);
            }
            queue.remove();
            explored.add(actual);
            for(GeoNode n : actual.getConnections())
            {
                if(!explored.contains(n))
                {
                    n.setDistance(actual.getDistance() + actual.distanceFrom(n));
                    path.put(n, actual);
                    queue.add(n);
                    generated++;
                }
            }
        }
        return "Failure";
    }

    public String simulatedAnnealing(GeoNode start, GeoNode dest)
    {
        long started = System.currentTimeMillis();
        HashMap<GeoNode, GeoNode> path = new HashMap<>();
        start.setDistance(0);
        start.setFunction(0 + start.distanceFrom(dest));
        GeoNode actualNode = start;
        GeoNode nextNode;
        int generated = 0;
        do
        {
            fillHeuristic(actualNode, dest);
            nextNode = simulated_annealing(actualNode, dest, 30);
            path.put(nextNode, actualNode);
            actualNode = nextNode;
            generated++;
        }while(actualNode != dest);
        long time = System.currentTimeMillis() - started;
        return solution(start, dest, path, "Execution time(ms) : " + time +
                                ", Distance(km) : " + dest.getDistance() +
                                ", Generated Nodes : "  + generated);
    }
    public GeoNode simulated_annealing(GeoNode node, GeoNode dest, int kMax)
    {
        /* kMax needs to be at least 1
           otherwise it will not work.
        */
        double T = temp_function(node, dest);
        int k = 0;
        GeoNode next = null, current = node;
        while( k < kMax)
        {
            if(T < 0.100)
                return dest;
            next = getSuccessor(node);
            double DeltaE = next.getFunction() - node.getFunction();
            if(DeltaE > 0)
                current = next;
            else
            {
                if(Math.exp(DeltaE/T) > Math.random())
                    current = next;
            }
            k++;
        }
        return next;
    }
    public double temp_function(GeoNode node, GeoNode dest)
    {
        return node.distanceFrom(dest);
    }

    public void fillHeuristic(GeoNode node, GeoNode dest)
    {
        for (GeoNode n : node.getConnections())
        {
            n.setDistance(node.getDistance() + node.distanceFrom(n));
            n.setFunction(n.getDistance() + n.distanceFrom(dest));
        }
    }
    public GeoNode getSuccessor(GeoNode node) /* works */
    {
        GeoNode actualNode = null;
        do
        {
            int i = (int) ((int)Math.floor((node.getConnections().size())*Math.random()));
            actualNode = node.getConnections().get(i);
        }while(actualNode == node);
        return actualNode;
    }
    public String solution(GeoNode start, GeoNode dest, HashMap<GeoNode, GeoNode> path, String info)
    {
        LinkedList<GeoNode> nodes = new LinkedList<GeoNode>();
        nodes.add(dest);
        GeoNode current = dest;
        String result = "";
        long pathNodes = 0;
        while(current != start)
        {
            current = path.get(current);
            nodes.add(current);
            pathNodes++;
        }
        for (int i = 0; i < nodes.size(); i++)
        {
            result += (nodes.get(nodes.size()-i-1).getLat() + "," + nodes.get(nodes.size()-i-1).getLon());
            if(i < nodes.size() - 1)
                result += ",";
        }
        return result + "|" + info + ", Path Nodes : " + pathNodes;
    }

    public void importNodeCoordinates(Document doc) throws IOException
    {
        NodeList nList = doc.getElementsByTagName("node");
        for (int i = 0; i < nList.getLength(); i++)
        {
           Node n = nList.item(i);
           Element e = (Element) n;
           long id = Long.valueOf(e.getAttribute("id"));
           GeoNode actualNode = nodeMap.get(id);
           if(actualNode != null)
           {
              actualNode.setLatLon(Double.valueOf(e.getAttribute("lat")), Double.valueOf(e.getAttribute("lon")));
              nodeList.add(actualNode);
              double[] coords = new double[]{actualNode.getLat(), actualNode.getLon()};
              nodeTree.addPoint(coords, actualNode);
           }
        }
    }

    public void importRoadsUnprocessed(Document doc)
    {
        LinkedList<Long> connections = new LinkedList<Long>();
        boolean highway;
        boolean oneway;
        boolean noVehicle;
        boolean track;
        boolean footway;
        NodeList nList = doc.getElementsByTagName("way");
        for (int i = 0; i < nList.getLength(); i++)
        {
            Node n = nList.item(i);
            Node childNode = n.getFirstChild();
            connections.clear();
            highway = false;
            oneway = false;
            noVehicle = false;
            track = false;
            footway = false;
            while( childNode.getNextSibling()!=null )
            {
                if (childNode.getNodeType() == Node.ELEMENT_NODE && childNode.getNodeName() == "nd")
                {
                    Element childElement = (Element) childNode;
                    connections.add(Long.valueOf(childElement.getAttribute("ref")));
                }
                else if (childNode.getNodeType() == Node.ELEMENT_NODE && childNode.getNodeName() == "tag")
                {
                    Element childElement = (Element) childNode;
                    if(childElement.getAttribute("k").equals("highway"))
                    {
                        highway = true;
                        if(childElement.getAttribute("v").equals("track"))
                        {
                            track = true;
                        }
                    }
                    if(childElement.getAttribute("v").equals("footway")) {

                        footway = true;
                    }
                    if(childElement.getAttribute("k").equals("oneway"))
                    {
                        oneway = true;
                    }
                    if(childElement.getAttribute("k").equals("motor_vehicle"))
                    {
                        if(childElement.getAttribute("v").equals("no"))
                        {
                            noVehicle = true;
                        }
                    }
                }
                childNode = childNode.getNextSibling();
            }
            if(highway && !track && !footway && !noVehicle && connections.size()>1)
            {
                for(int k = 0; k < connections.size()-1; k++)
                {
                    if(nodeMap.get(connections.get(k)) == null)
                    {
                        nodeMap.put(connections.get(k), new GeoNode(connections.get(k)));
                    }
                    if(nodeMap.get(connections.get(k+1)) == null)
                    {
                        nodeMap.put(connections.get(k+1), new GeoNode(connections.get(k+1)));
                    }
                    GeoNode a = nodeMap.get(connections.get(k));
                    GeoNode b = nodeMap.get(connections.get(k+1));
                    a.connect(b);
                    if(!oneway)
                    {
                        b.connect(a);
                    }
                }
            }
        }
    }
}
