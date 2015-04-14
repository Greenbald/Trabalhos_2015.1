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
				addmark(latlngs[0][0], latlngs[0][1], "");
				addmark(latlngs[1][0], latlngs[1][1], "");
				getNodes(Math.min(placea[0].lat, placeb[0].lat), Math.min(placea[0].lon, placeb[0].lon), Math.max(placea[0].lat, placeb[0].lat), Math.max(placea[0].lon, placeb[0].lon));
			}
		});
	});
}

handleOSMResponse = function(data) 
{
    var x = data.elements;
	/* From this point i must iterate over elements to find all ways and nodes and realize the A* algorithm */
}

function getNodes(lat1, long1, lat2, long2)
{
	var query = "http://overpass.osm.rambler.ru/cgi/interpreter?jsonp=handleOSMResponse&data=[out:json];(node(" + lat1 + "," + long1 + "," + lat2 + "," + long2 + ");<;);out meta;";
	query = encodeURI(query);
	$.getScript(query);
}

function getDistance(lat1,lon1,lat2,lon2) 
{
  var R = 6371; // Radius of the earth in km
  var dLat = deg2rad(lat2-lat1);  // deg2rad below
  var dLon = deg2rad(lon2-lon1); 
  var a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
    Math.sin(dLon/2) * Math.sin(dLon/2)
    ; 
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  var d = R * c; // Distance in km
  return d;
}

function deg2rad(deg) {
  return deg * (Math.PI/180)
}

/* Draw lines section */
function drawLine(latlngs)
{
	var polyline = L.polyline(latlngs, {color: 'red'}).addTo(map);
	map.fitBounds(polyline.getBounds());
}


/* Mark section */
var marks = [];
var canDeleteMarks = false;
function addmark(lat, lng, text)
{
	if(canDeleteMarks)
	{
			for(var i = 0; i < marks.length; i++)
				map.removeLayer(marks[i]);
			canDeleteMarks = false;
			marks = [];
	}
	var actualMark = new L.marker([lat,lng]);
	marks.push(actualMark);
	map.addLayer(actualMark);
	actualMark.bindPopup(text).openPopup();
	if(marks.length == 2)
		canDeleteMarks = true;
}