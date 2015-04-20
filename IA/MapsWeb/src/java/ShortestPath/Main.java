package ShortestPath;



import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.PriorityQueue;
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
    
    public String shortestPath(double lat1, double lon1, double lat2, double lon2) 
    {
        GeoNode a = getNearest(new GeoNode(lat1,lon1));
        GeoNode b = getNearest(new GeoNode(lat2,lon2));
        return aStar(a, b);
    }
    
    public String aStar(GeoNode start, GeoNode dest)
    {
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
                return solution(start, dest, path);
            queue.remove(actual);
            explored.add(actual);
            fg = 0; fh = 0;
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
                            queue.add(n);
                    }
                }
            }
        }
        return "Failure";
    }
    
    public String solution(GeoNode start, GeoNode dest, HashMap<GeoNode, GeoNode> path)
    {
        LinkedList<GeoNode> nodes = new LinkedList<GeoNode>();
        nodes.add(dest);
        GeoNode current = dest;
        String result = "";
        while(current != start)
        {
            current = path.get(current);
            nodes.add(current);
        }
        for (int i = 0; i < nodes.size(); i++) 
        {    
            result += (nodes.get(nodes.size()-i-1).getLat() + "," + nodes.get(nodes.size()-i-1).getLon());
            if(i < nodes.size() - 1)
                result += ",";
        }
        return result;
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
