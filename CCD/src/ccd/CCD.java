package ccd;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.LinkedList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 *
 * @author CCD
 */
public class CCD 
{
    static NodeList nList;
    static NodeList wList;
    public static void main(String[] args) 
    {
        String path = System.getProperty("user.dir");
        String fileName = "niteroi_info.osm";
        init(path + File.pathSeparator + fileName);
    }
    public static boolean init(String file) 
    {
        try 
        {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            Document doc = db.parse(new File(file));
            nList = doc.getElementsByTagName("node");
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

    public static void importNodeCoordinates(Document doc) throws IOException 
    {
        LinkedList<GeographicPoint> geoList = new LinkedList<GeographicPoint>();
        for (int i = 0; i < nList.getLength(); i++) 
        {
            Node n = nList.item(i);
            Node childNode = n.getFirstChild();
            Element element = (Element) childNode;
            String name = null;
            String type = null;
            double lat = 0;
            double lon = 0;
            lat = Double.valueOf(element.getAttribute("lat"));
            lon = Double.valueOf(element.getAttribute("lon"));
            while(childNode.getNextSibling() != null)
            {
                if(childNode.getNodeType() == Node.ELEMENT_NODE && childNode.getNodeName() == "tag")
                {
                    Element e = (Element) childNode;
                    String k = e.getAttribute("k");
                    if(k.equals("name"))
                        name = e.getAttribute("v");
                    else if(k.equals("shop"))
                    {
                        if(e.getAttribute("v").equals("electronics"))
                            type = "Loja de Eletronicos";
                        else if(e.getAttribute("v").equals("supermarket"))
                            type = "Super Mercado";
                        else if(e.getAttribute("v").equals("kiosk"))
                            type = "Quiosque";
                    }
                    else if(k.equals("amenity"))
                    {
                        if(e.getAttribute("v").equals("bank"))
                            type = "Branco";
                        else if(e.getAttribute("v").equals("restaurant"))
                            type = "Restaurante";
                        else if(e.getAttribute("v").equals("university"))
                            type = "Universidade";
                        else if(e.getAttribute("v").equals("school"))
                            type = "Escola";
                        else if(e.getAttribute("v").equals("clinic"))
                            type = "Clinica";
                        else if(e.getAttribute("v").equals("pub"))
                            type = "Bar";
                        else if(e.getAttribute("v").equals("theatre"))
                            type = "Teatro";
                        else if(e.getAttribute("v").equals("fuel"))
                            type = "Posto de Gasolina";
                        else if(e.getAttribute("v").equals("hospital"))
                            type = "Hospital";
                        else if(e.getAttribute("v").equals("bar"))
                            type = "Bar";
                        // We can get bus_station,bus_stop and fast_food here.
                    }
                    else if(k.equals("pharmacy") && e.getAttribute("v").equals("pharmacy"))
                        type = "Farmacia";
                    else if(k.equals("tourism"))
                        type = "Ponto Turistico";
                        
                        
                }
                childNode = childNode.getNextSibling();
            }
            GeographicPoint actualGeoPoint = new GeographicPoint(lat, lon);
            actualGeoPoint.setName(name);
            actualGeoPoint.setType(type);
            geoList.add(actualGeoPoint);
        }
    }
}
