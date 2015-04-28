<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<portlet:defineObjects />

<script>
        Liferay.on(
           'sendAddress',
           function(event) {
        	   codeAddress(event.location);
           }
        );  
        
        Liferay.on(
                'changeLevel',
                function(event) {
                	changeLoaderVisibility(true);
                	initIndex(event.level);
                    reloadData();	
                }
             ); 
        
        Liferay.on(
                'changeMap',
                function(event) {
                	changeLoaderVisibility(true);
                	ismap3d = event.ismap3d;
                	changeMap();
                }
             );
</script>

<script>
	var ismap3d = true;
	var map;
	var markers = [];
	var geocoder;
	var index=0;
	var lvls;
	var result2d;
	var UsFileName;
	var VsFileName;
	var TsFileName;
	$.ajax({
		 url: "http://node6.grid.isofts.kiev.ua:8080/OraculService/prediction/3d/883" ,
		 async: false,
			        type: 'GET',
			        datatype:'jsonp',
			            success: function(data){
			            	 lvls = data.levels;
			        }
			    });
	$.ajax({
		 url: "http://node6.grid.isofts.kiev.ua:8080/OraculService/prediction/2d/30" ,
		 async: false,
			        type: 'GET',
			        datatype:'jsonp',
			            success: function(data){
			            	result2d = data;
			        }
			    });
	
	
	var windVectorsArray = [];
	var windPolygonContoursArray = [];
	var windPolylineContoursArray = [];
	var temperaturePolygonContoursArray = [];
	var temperaturePolylineContoursArray = [];
	
	var zoomMap = 5;
	var startLat = 0;
	var startLng = 0;
	var step = 0.5;
	var arrayLengthLat = 182;
	var arrayLengthLng = 182;
	var windVectorIncrement = 2;

	function initIndex(lvl) {
		index = lvl;
	}
	
	function changeLoaderVisibility(setvisible) {
		var elem = document.getElementById("loaderShow");
		if (setvisible) {
			elem.style.display= "block";
		} else {	
			elem.style.display= "none";	
		}
	}
	
	function changeMap () {
		
		changeLoaderVisibility(true);
		
		if (!ismap3d)	{
			var chkTemperaturePolygonContour = document.getElementById('chkTemperaturePolygonContour').checked = false;
			var chkTemperaturePolylineContour = document.getElementById('chkTemperaturePolylineContour').checked = false;
			var chkTemperaturePolygonContour = document.getElementById('lblTemperaturePolygonContour').style.display = "none";
			var chkTemperaturePolylineContour = document.getElementById('lblTemperaturePolylineContour').style.display = "none";
			
			clearAllOverlays();
			
			step=1.5;
			arrayLengthLat = 61;
			arrayLengthLng = 60;
				
		} else {
			var chkTemperaturePolygonContour = document.getElementById('lblTemperaturePolygonContour').style.display = "block";
			var chkTemperaturePolylineContour = document.getElementById('lblTemperaturePolylineContour').style.display = "block";
			
			clearAllOverlays();
			
			step=0.5;
			arrayLengthLat = 182;
			arrayLengthLng = 182;	
		}	
		//initialize();
		reloadData();
	}
	
	
	function CustomControl(controlDiv, map) {

		var chkTemperaturePolygonContour = document.getElementById('chkTemperaturePolygonContour');
		var chkTemperaturePolylineContour = document.getElementById('chkTemperaturePolylineContour');
		var chkWindVectors = document.getElementById('chkWindVectors');
		var chkWindPolygonContour = document.getElementById('chkWindPolygonContour');
		var chkWindPolylineContour = document.getElementById('chkWindPolylineContour');
		
		google.maps.event.addDomListener(chkTemperaturePolygonContour,
				'change', function() {
					setVisibleOverlays(temperaturePolygonContoursArray,
							chkTemperaturePolygonContour.checked);
				});

		google.maps.event.addDomListener(chkTemperaturePolylineContour,
				'change', function() {
					setVisibleOverlays(temperaturePolylineContoursArray,
							chkTemperaturePolylineContour.checked);
				});

		google.maps.event.addDomListener(chkWindVectors, 'change', function() {
			setVisibleOverlays(windVectorsArray, chkWindVectors.checked);
		});

		google.maps.event.addDomListener(chkWindPolygonContour, 'change',
				function() {
					setVisibleOverlays(windPolygonContoursArray,
							chkWindPolygonContour.checked);
				});

		google.maps.event.addDomListener(chkWindPolylineContour, 'change',
				function() {
					setVisibleOverlays(windPolylineContoursArray,
							chkWindPolylineContour.checked);
				});
	}
	
	function fillArray(value, len) {
		var arr = [];
		for (var i = 0; i < len; i++) {
			arr.push(value);
		}
		;
		return arr;
	}
	
	function clearOverlays(overlaysArray) {
		if (overlaysArray) {
			for (i in overlaysArray) {
				overlaysArray[i].setMap(null);
			}
		}
	}

	function setVisibleOverlays(overlaysArray, visible) {
		if (overlaysArray) {
			for (i in overlaysArray) {
				overlaysArray[i].setVisible(visible);
			}
		}
	}

	function updateZoom(overlaysArray) {
		if (overlaysArray) {
			for (i in overlaysArray) {
				overlaysArray[i].setOptions({
					strokeWeight : 1 * (zoomMap / 4)
				});
			}
		}
	}

	function calcGradient(value) {
		var max = 70;
		if (value > max) {
			value = max;
		}
		;
		//(A1-(A1-B1)/h*x, A2-(A2-B2)/h*x, A3-(A3-B3)/h*x)
		var color = parseInt(0xFF / max * value) * 0x10000
				+ parseInt(0xFF - 0xFF / max * value) * 0x100;
		return ('#' + color.toString(16));
	}

	function addWindVector(startLat, startLng, endLat, endLng, color) {

		var lineSymbol = {
			path : google.maps.SymbolPath.FORWARD_CLOSED_ARROW
		};
		var lineCoordinates = [ new google.maps.LatLng(startLat, startLng),
				new google.maps.LatLng(endLat, endLng) ];

		var line = new google.maps.Polyline({
			path : lineCoordinates,
			strokeWeight : 1 * (zoomMap / 4),
			strokeColor : color,
			icons : [ {
				icon : lineSymbol,
				offset : '100%',
			} ],
			map : map
		});
		windVectorsArray.push(line);
	}

	function addWind() {

		var Us = UsFileName;
		var Vs = VsFileName;
		//var arrLimit = parseInt(Math.sqrt(Us.length));
		var vectorCoefficient = 0.03;

		for (var i = 0; i < arrayLengthLat; i = i + windVectorIncrement) {
			for (var j = 0; j < arrayLengthLng; j = j + windVectorIncrement) {
				addWindVector(startLat + step * i, startLng + step * j,
						startLat + step * i + Vs[(i * arrayLengthLat) + j]
								* vectorCoefficient, startLng + step * j
								+ Us[(i * arrayLengthLat) + j]
								* vectorCoefficient, calcGradient(Math
								.sqrt(Math.pow(Vs[(i * arrayLengthLat) + j], 2)
										+ Math
												.pow(Us[(i * arrayLengthLat)
														+ j], 2))));
			}
		}
	}

	function calcContour(d, addCliffEdge) {

		//Add a "cliff edge" to force contour lines to close along the border.
		if (addCliffEdge) {
			var cliff = -100;
			d.push(fillArray(cliff, arrayLengthLng));
			d.unshift(fillArray(cliff, arrayLengthLng));
			d.forEach(function(nd) {
				nd.push(cliff);
				nd.unshift(cliff);
			});
		}

		//index bounds of data matrix
		var ilb = 0;
		//var iub = arrLimit-1;
		var jlb = 0;
		//var jub = arrLimit-1;
		//             The following two, one dimensional arrays (x and y) contain
		//             the horizontal and vertical coordinates of each sample points.
		// x  - data matrix column coordinates
		var x = [];
		for (var i = 0; i < d.length; i++) {
			x.push(startLat + i * step + (addCliffEdge ? -step : 0));
		}
		//y  - data matrix row coordinates
		var y = [];
		for (var j = 0; j < d[0].length; j++) {
			y.push(startLng + j * step + (addCliffEdge ? -step : 0));
		}
		//nc   - number of contour levels
		//var nc = 4;
		//z  - contour levels in increasing order.
		var z = [ -10, 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65,
				70, 75 ];

		var c = new Conrec();
		c.contour(d, ilb, x.length - 1, jlb, y.length - 1, x, y, z.length, z);
		// c.contours will now contain vectors in the form of doubly-linked lists.
		// c.contourList() will return an array of vectors in the form of arrays.
		return c.contourList();
	}

	function addPolygonContour(data) {
		var polygonContoursArray = [];
		var contours = calcContour(data, true);
		for (i = contours.length - 1; i >= 0; i--) {
			var contourCoords = [];
			for (j = 0; j < contours[i].length; j++) {
				contourCoords.push(new google.maps.LatLng(contours[i][j].x,
						contours[i][j].y));
			}
			var polygon = new google.maps.Polygon({
				paths : contourCoords,
				strokeColor : calcGradient(contours[i].level + 30),
				strokeOpacity : 0.8,
				strokeWeight : 1,
				fillColor : calcGradient(contours[i].level + 30),
				fillOpacity : 0.1,
				map : map
			});
			polygonContoursArray.push(polygon);
		}
		return polygonContoursArray;
	}

	function addPolylineContour(data) {
		var polylineContoursArray = [];
		var contours = calcContour(data, false);
		for (i = 0; i < contours.length; i++) {
			var contourCoords = [];
			for (j = 0; j < contours[i].length; j++) {
				contourCoords.push(new google.maps.LatLng(contours[i][j].x,
						contours[i][j].y));
			}
			var polyline = new google.maps.Polyline({
				path : contourCoords,
				strokeColor : calcGradient(contours[i].level + 30),
				strokeOpacity : 0.8,
				strokeWeight : 1.5,
				map : map
			});
			polylineContoursArray.push(polyline);
		}
		return polylineContoursArray;
	}

	function addTemperaturePolygonContour() {
		var Ts = TsFileName;

		var data = new Array(arrayLengthLat); // - matrix of data to contour
		for (var i = 0; i < arrayLengthLat; i++) {
			data[i] = new Array(arrayLengthLng);
			for (var j = 0; j < arrayLengthLng; j++) {
				data[i][j] = Ts[(i * arrayLengthLat) + j] - 200;
			}
		}
		temperaturePolygonContoursArray = addPolygonContour(data);
	}

	function addTemperaturePolylineContour() {
		var Ts = TsFileName;

		var data = new Array(arrayLengthLat); // - matrix of data to contour
		for (var i = 0; i < arrayLengthLat; i++) {
			data[i] = new Array(arrayLengthLng);
			for (var j = 0; j < arrayLengthLng; j++) {
				data[i][j] = Ts[(i * arrayLengthLat) + j] - 200;
			}
		}
		temperaturePolylineContoursArray = addPolylineContour(data);
	}

	function addWindPolygonContour() {
		var Us = UsFileName;
		var Vs = VsFileName;
		var data = new Array(arrayLengthLat); // - matrix of data to contour
		for (var i = 0; i < arrayLengthLat; i++) {
			data[i] = new Array(arrayLengthLng);
			for (var j = 0; j < arrayLengthLng; j++) {
				data[i][j] = Math.sqrt(Math
						.pow(Vs[(i * arrayLengthLat) + j], 2)
						+ Math.pow(Us[(i * arrayLengthLat) + j], 2));
			}
		}
		windPolygonContoursArray = addPolygonContour(data);
	}

	function addWindPolylineContour() {
		var Us = UsFileName;
		var Vs = VsFileName;

		var data = new Array(arrayLengthLat); // - matrix of data to contour
		for (var i = 0; i < arrayLengthLat; i++) {
			data[i] = new Array(arrayLengthLng);
			for (var j = 0; j < arrayLengthLng; j++) {
				data[i][j] = Math.sqrt(Math
						.pow(Vs[(i * arrayLengthLat) + j], 2)
						+ Math.pow(Us[(i * arrayLengthLat) + j], 2));
			}
		}
		windPolylineContoursArray = addPolylineContour(data);
	}
	
	function clearAllOverlays() {
		clearOverlays(windVectorsArray);
		clearOverlays(windPolygonContoursArray);
		clearOverlays(windPolylineContoursArray);
		clearOverlays(temperaturePolygonContoursArray);
		clearOverlays(temperaturePolylineContoursArray);	
	}
	
	function reloadData() {
		
		changeLoaderVisibility(true);
		clearAllOverlays();
		
		if (ismap3d) {
			UsFileName = lvls[index].u ;
			VsFileName = lvls[index].v;
			TsFileName = lvls[index].t;	
		} else {
			UsFileName = result2d.u;
			VsFileName = result2d.v;
		}
		
		addWind();
		addWindPolygonContour();
		addWindPolylineContour();
		
		if (ismap3d) {
			addTemperaturePolygonContour();
			addTemperaturePolylineContour();
		}	
		
		setVisibleOverlays(windVectorsArray, document.getElementById('chkWindVectors').checked);
		setVisibleOverlays(windPolygonContoursArray, document.getElementById('chkWindPolygonContour').checked);
		setVisibleOverlays(windPolylineContoursArray, document.getElementById('chkWindPolylineContour').checked);
		
		if (ismap3d) {
			setVisibleOverlays(temperaturePolygonContoursArray, document.getElementById('chkTemperaturePolygonContour').checked);
			setVisibleOverlays(temperaturePolylineContoursArray, document.getElementById('chkTemperaturePolylineContour').checked);
		} 
		
		changeLoaderVisibility(false);
	}

	function initialize() {
		changeLoaderVisibility(true);
		UsFileName = lvls[index].u;
		VsFileName = lvls[index].v;
		TsFileName = lvls[index].t;	
		
		geocoder = new google.maps.Geocoder();
		var mapOptions = {
			zoom : 10,
			zoomControl : false,
			streetViewControl:false
		};
		map = new google.maps.Map(document.getElementById('map-canvas'),
				mapOptions);

		// Try HTML5 geolocation
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition(function(position) {
				var pos = new google.maps.LatLng(position.coords.latitude,
						position.coords.longitude);
				var marker = new google.maps.Marker({
					position : pos,
					title : 'Your Location',
					map : map
				});
				markers.push(marker);

				map.setCenter(pos);
			}, function() {
				handleNoGeolocation(true);
			});
		} else {
			// Browser doesn't support Geolocation
			handleNoGeolocation(false);
		}
		addWind();
		addWindPolygonContour();
		addWindPolylineContour();
		
		if (ismap3d) {
			addTemperaturePolygonContour();
			addTemperaturePolylineContour();	
		}

		zoomChangeListener = google.maps.event
				.addListener(
						map,
						'zoom_changed',
						function(event) {
							zoomChangeBoundsListener = google.maps.event
									.addListener(
											map,
											'bounds_changed',
											function(event) {
												zoomMap = map.zoom;
												updateZoom(windVectorsArray)
												google.maps.event
														.removeListener(zoomChangeBoundsListener);
											});
						});


		var customControlDiv = document.getElementById('customControlDiv');
		var customControl = new CustomControl(customControlDiv, map);

		customControlDiv.index = 1;
		map.controls[google.maps.ControlPosition.RIGHT].push(customControlDiv);
		setVisibleOverlays(windPolygonContoursArray, false);
		setVisibleOverlays(windPolylineContoursArray, false);
		if (ismap3d) {
			setVisibleOverlays(temperaturePolygonContoursArray, false);
			setVisibleOverlays(temperaturePolylineContoursArray, false);	
		}
		changeLoaderVisibility(false);
	}

	function handleNoGeolocation(errorFlag) {
		if (errorFlag) {
			var content = 'Error: The Geolocation service failed.';
		} else {
			var content = 'Error: Your browser doesn\'t support geolocation.';
		}

		var options = {
			map : map,
			position : new google.maps.LatLng(60, 105),
			content : content
		};

		var infowindow = new google.maps.InfoWindow(options);
		map.setCenter(options.position);
	}
	
	function codeAddress(address) {
		deleteMarkers();
		  geocoder.geocode( { 'address': address}, function(results, status) {
		    if (status == google.maps.GeocoderStatus.OK) {
		      map.setCenter(results[0].geometry.location);
		      var marker = new google.maps.Marker({
		          map: map,
		          position: results[0].geometry.location
		      });
		      markers.push(marker);
		    } else {
		      alert('Geocode was not successful for the following reason: ' + status);
		    }
		  });
		}
	
	function mouseOnCheck() {
		document.getElementById('controlUI').style.opacity = '1';	
	}
	
	function mouseOffCheck() {
		document.getElementById('controlUI').style.opacity = '0.5';	
	}
	
	function deleteMarkers() {
        //Loop through all the markers and remove
        for (var i = 0; i < markers.length; i++) {
            markers[i].setMap(null);
        }
        markers = [];
    };

	google.maps.event.addDomListener(window, 'load', initialize);
</script>

<div class="loaderShow" id="loaderShow"><b>Loading map, please wait</b></div>
<div style="width: 100%; height: 500px;  cursor: progress;" id="map-canvas"></div>
<div id="customControlDiv"  style="padding: 5px;">
<div class="controlUI" id="controlUI" title="Select layers to display" style="background-color: white; cursor: pointer; text-align: left; opacity: 0.5;" >
<div class="checkboxes" id="controlSelectDiv" style="padding-left: 5px; padding-right: 5px;" onmouseover="mouseOnCheck()" onmouseleave="mouseOffCheck()">
<label for="controlSelectDiv"><b>Layers:</b></label>

<label id="lblTemperaturePolygonContour">
<input type="checkbox" id="chkTemperaturePolygonContour" value = "TemperaturePolygonContour" /><span> Temperature polygons</span></label>

<label id="lblTemperaturePolylineContour">
<input type="checkbox" id="chkTemperaturePolylineContour" value = "TemperaturePolylineContour" /><span> Temperature polilynes</span></label>

<label><input type="checkbox" id="chkWindVectors" value = "WindVectors" checked="checked"/><span> Wind speed vector</span></label>

<label><input type="checkbox" id="chkWindPolygonContour" value = "WindPolygonContour"/><span> Wind speed polygons</span></label>

<label><input type="checkbox" id="chkWindPolylineContour" value = "WindLineContour"/><span> Wind speed polilynes</span></label>
</div>
</div>
</div>


<style type="text/css">
.loaderShow {
	text-align: center;
	margin-top: 15px; 
    width: 100%;
}

.checkboxes br {
   display: block;
   margin: 0px 0;
   line-height: 1px;
}

.checkboxes label {
    display: block;
    padding-left: 15px;
    text-indent: -15px;
    font-size: 1.2em;
    font-weight: 550;
}

.checkboxes input {
    padding: 0;
    margin:0;
    vertical-align: top;
    position: relative;
    top: -1px;
    *overflow: hidden;
}
</style>