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
			if(placeb.length == 0)
				alert(place_b + ' could not be found.');
			else if(placeb.length > 0 && placea.length > 0)
			{
				latlngs.push([placeb[0].lat, placeb[0].lon]);
				addmark(latlngs[0][0], latlngs[0][1], "");
				addmark(latlngs[1][0], latlngs[1][1], "");
			}
		});
	});
}

function drawLine(latlngs)
{
	var polyline = L.polyline(latlngs, {color: 'red'}).addTo(map);
	map.fitBounds(polyline.getBounds());
}
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
	
	//L.marker([lat, lng]).addTo(map)
    //.bindPopup(text)
    //.openPopup();
}