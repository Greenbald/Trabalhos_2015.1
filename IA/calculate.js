function calculatePath(place_a, place_b, algorithm)
{
	
}

function drawLine(place_a, place_b)
{
	
}

function addmark(lat, lng, text)
{
	L.marker([lat, lng]).addTo(map)
    .bindPopup(text)
    .openPopup();
}