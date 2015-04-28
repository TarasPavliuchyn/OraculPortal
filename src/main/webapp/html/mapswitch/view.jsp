<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>

<portlet:defineObjects />

<script>
jQuery(
        function () {
          jQuery("#button3d").click(
            function(event) {
              var info = true;
              Liferay.fire('changeMap', {ismap3d : info} );
              return false;
            });
       }
);

jQuery(
        function () {
          jQuery("#button2d").click(
            function(event) {
              var info = false;
              Liferay.fire('changeMap', {ismap3d : info} );
              return false;
            });
       }
);

	function showButtons(type) {
		if (type == '3d') {
			document.getElementById('button3d').disabled = true;
			document.getElementById('button2d').disabled = false;
		}
		if (type == '2d') {
			document.getElementById('button2d').disabled = true;
			document.getElementById('button3d').disabled = false;
		}
	}
	
</script>
<div class="switcher" style="margin: 5px; padding: 1px;">
<button id="button3d" disabled="disabled" onclick="showButtons('3d')">&nbsp;&nbsp;&nbsp;&nbsp; 3D &nbsp;&nbsp;&nbsp;&nbsp;</button>&nbsp;&nbsp;&nbsp;&nbsp;
<button id="button2d" onclick="showButtons('2d')">&nbsp;&nbsp;&nbsp;&nbsp; 2D &nbsp;&nbsp;&nbsp;&nbsp;</button>
</div>

<style type="text/css">
.switcher {
	text-align: center;
    width: 100%;
}
</style>