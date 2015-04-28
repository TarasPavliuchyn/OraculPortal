<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://liferay.com/tld/aui" prefix="aui" %>
<portlet:defineObjects />
<link type="text/css" rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:300,400,500">
<script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&libraries=places"></script>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>

<script>
var autocomplete;
function initialize() {
  autocomplete = new google.maps.places.Autocomplete(
  /** @type {HTMLInputElement} */(document.getElementById('searchBox')),
   { types: ['geocode'] });
   google.maps.event.addListener(autocomplete, 'place_changed', function() {
   });
}
window.onload = initialize;
</script>

<script>
jQuery(
        function () {
          jQuery('button.senderInfo').click(
            function(event) {
              var info = document.getElementById('searchBox').value;
              Liferay.fire('sendAddress', {location : info} );
              return false;
            });
       }
);
</script>

<form id="locationField" style="margin: 0px; padding: 0px;">
<input style="width: 70%;" id="searchBox" class="searchBox" placeholder="Enter your address" type="text"></input>&nbsp;&nbsp;
<button class="senderInfo">Search</button>&nbsp;
<button type="reset">Clear</button> 
</form>

<script>
$( "#searchBox" ).keypress(function( event ) {
  if ( event.which == 13 ) {
     event.preventDefault();
     var info = document.getElementById('searchBox').value;
     Liferay.fire('sendAddress', {location : info} );
  }
});
</script>