/* Init the code */
function calculatePath(place_a, place_b, algorithm)
{	
	var latlngs = [];
	$.getJSON('http://nominatim.openstreetmap.org/search/' + place_a + '?format=json&addressdetails=1&limit=1&polygon_svg=1', function(placea)
	{
		if(placea.length == 0)
			alert(place_a + ' could not be found.');
		else
			latlngs.push([placea[0].lat, placea[0].lon]);
		$.getJSON('http://nominatim.openstreetmap.org/search/' + place_b + '?format=json&addressdetails=1&limit=1&polygon_svg=1', function(placeb)
		{
			if(placeb.length == 0 && placeb.length > 0)
				alert(place_b + ' could not be found.');
			else if(placeb.length > 0 && placea.length > 0)
			{
				latlngs.push([placeb[0].lat, placeb[0].lon]);
				addmark(latlngs[0][0], latlngs[0][1], place_a);
				addmark(latlngs[1][0], latlngs[1][1], place_b);
				calculate(latlngs[0][0], latlngs[0][1], latlngs[1][0], latlngs[1][1]);                                
			}
		});
	});
}

function calculate(lat1, lon1, lat2, lon2)
{
    $.ajax
    ({
        url: "ShortestPath?",
        data: {"lat1" : lat1, "lon1" : lon1, "lat2" : lat2, "lon2" : lon2},
        success: function(data)
        {
            parse(data);
        }
    })
}

function parse(coordsString)
{
    var coordsArray = coordsString.split("|");
    var coords = [];
    for(i in coordsArray)
    {
        coords.push(L.latLng(coordsArray[i].split(",")[0], coordsArray[i].split(",")[1]));
    }
    drawPath(coords);
}
/*function getNodes(lat1, long1, lat2, long2)
{
	var query = "http://overpass.osm.rambler.ru/cgi/interpreter?jsonp=handleOSMResponse&data=[out:json];(node(" + lat1 + "," + long1 + "," + lat2 + "," + long2 + ");<;);out meta;";
	query = encodeURI(query);
	$.getScript(query);
}

handleOSMResponse = function(data) 
{
	var ways = [];
	var wayNodes = [];
	var inway = [];
	for(var x in data.elements)
	{
		if(data.elements[x].type == "way" && !(typeof data.elements[x].tags === "undefined") && (data.elements[x].tags != null))
		{
			if(data.elements[x].tags.highway == "residential" || data.elements[x].tags.highway == "motorway")
			{
				var way_tmp = data.elements[x].nodes;
				ways.push(way_tmp);	
			}
		}
		else if(data.elements[x].type == "node")
			inway.push(data.elements[x]);
	}
	var coords = [];
	for(var h in ways)
	{
		wayNodes = ways[h];
		for(var wn in wayNodes)
		{
			for(var x in inway)
			{
				if(wayNodes[wn] == inway[x].id)
				{
					if(inway[x].lat != null && inway[x].lat != "" && inway[x].lon != "" && inway[x].lon != null)
					{
						var coord = L.latLng(inway[x].lat, inway[x].lon);
						coords.push(coord);
					}
				}
			}
		}
		drawPath(coords);
		coords = []
	}
	//drawPath(coords);
	//aStar(ways, inway);
}

function aStar(ways, nodes)
{
	
}
*/

/* Draw lines section */
function drawPath(latlngs)
{
	var polyline = L.polyline(latlngs, {color: 'red'}).addTo(map);
	//map.fitBounds(polyline.getBounds());
}

/* Mark section */
var marks = [];
var canDeleteMarks = false;
function addmark(lat, lon, text)
{
	if(canDeleteMarks)
	{
			for(var i = 0; i < marks.length; i++)
				map.removeLayer(marks[i]);
			canDeleteMarks = false;
			marks = [];
	}
	var actualMark = new L.marker([lat,lon]);
	marks.push(actualMark);
	map.addLayer(actualMark);
	//actualMark.bindPopup(text).openPopup();
	if(marks.length == 2)
		canDeleteMarks = true;
}
