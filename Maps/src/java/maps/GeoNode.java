package maps;



import java.util.LinkedList;

/**
 *
 * @author Paulo, Juan, Lucas
 */
public class GeoNode implements Comparable<GeoNode>
{
    private double lat;
    private double lon;
    private long id;  /* This is an identifier for a way*/
    private double d;
    private double f;
    private LinkedList<GeoNode> connected;
    public GeoNode(double lat, double lon)
    {
        this.connected = new LinkedList<GeoNode>();
        this.lat = lat;
        this.lon = lon;
        this.d = 0;
        this.f = 0;
    }
    public GeoNode(double lat, double lon, long id)
    {
        this.connected = new LinkedList<GeoNode>();
        this.lat = lat;
        this.lon = lon;
        this.id = id;
        this.d = 0;
        this.f = 0;
    }
    public GeoNode(long id)
    {
        this.id = id;
        this.connected = new LinkedList<GeoNode>();
        this.d = 0;
        this.f = 0;
    }
    void setLatLon(double latitude, double longditude) 
    {
        this.lat = latitude;
        this.lon = longditude;
    }
    void setFunction(double val)
    {
        this.f = val;
    }
    /* Distance from the start node until this node */
    void setDistance(double val) 
    {
        this.d = val;
    }
    double getLat()
    {
        return this.lat;
    }
    double getLon()
    {
        return this.lon;
    }
    long getId()
    {
        return this.id;
    }
    double getDistance()
    {
        return this.d;
    }
    double getFunction()
    {
        return this.f;
    }
    LinkedList<GeoNode> getConnections()
    {
        return this.connected;
    }
    boolean isConnected(GeoNode a)
    {
        for (GeoNode n : connected) 
        {
            if(n == a)
                return true;
        }
        return false;
    }
    void connect(GeoNode a)
    {
        if(!isConnected(a))
            connected.add(a);
    }
    public double distanceFrom(GeoNode n) 
    {	// Haversine formula
        final double R = 6372.8;
        double lat1 = Math.toRadians(lat);
        double lat2 = Math.toRadians(n.getLat());
        double dLat = Math.toRadians(n.getLat() - lat);
        double dLon = Math.toRadians(n.getLon() - lon);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
        double c = 2 * Math.asin(Math.sqrt(a));
        return R * c;
    }

    public double distanceFrom(double latOther, double lonOther) 
    {	// Haversine formula
        final double R = 6372.8;
        double lat1 = Math.toRadians(lat);
        double lat2 = Math.toRadians(latOther);
        double dLat = Math.toRadians(latOther - lat);
        double dLon = Math.toRadians(lonOther - lon);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
        double c = 2 * Math.asin(Math.sqrt(a));
        return R * c;
    }
    @Override
    public int compareTo(GeoNode t)
    {
        if(this.f > t.getFunction())
            return 1;
        else if(this.f < t.getFunction())
            return -1;
        else
            return 0;
    }
}
