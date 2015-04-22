package ShortestPath;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ShortestPath")
public class ShortestPathServlet extends HttpServlet 
{
    private static final long serialVersionUID = 1L;
    private Main main;
       
    public ShortestPathServlet() 
    {
        super();
    }
    
    public void init() 
    {
    	main = new Main();
    	String path = this.getServletContext().getRealPath("/niteroi.osm");
    	main.init(path);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
        double lat1 = Double.valueOf(request.getParameter("lat1"));
        double lon1 = Double.valueOf(request.getParameter("lon1"));
        double lat2 = Double.valueOf(request.getParameter("lat2"));
        double lon2 = Double.valueOf(request.getParameter("lon2"));
        String algorithm = String.valueOf(request.getParameter("algorithm"));
        String solution = main.shortestPath(lat1, lon1, lat2, lon2, algorithm);

        response.getWriter().write(solution);
    }
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
    {
    }

}