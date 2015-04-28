<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet"%>

<portlet:defineObjects />
<style>
.rangeV {
	height: 500px;
	-webkit-appearance: slider-vertical;
	color: #00c;
}

</style>
<script>
	jQuery(function() {
		jQuery("#level").change(function(event) {
			var info = document.getElementById('level').value;
			Liferay.fire('changeLevel', {
				level : info
			});
			return false;
		});
	});
	
    Liferay.on(
            'changeMap',
            function(event) {
            	changeLoaderVisibility(true);
            	if (event.ismap) {
            		document.getElementById('level').disabled = false;
            	} else {
            		document.getElementById('level').disabled = true;
            	}
            }
         );
    
</script>

	<table style="width: 20px; height: 500px; float: left;">
		<tr>
			<td height="0%">18000</td>
		</tr>
		<tr>
			<td height="12%">17000</td>
		</tr>
		<tr>
			<td height="10%">16000 </td>
		</tr>
		<tr>
			<td height="9%">15000</td>
		</tr>
		<tr>
			<td height="10%">14000</td>
		</tr>
		<tr>
			<td height="10%">13000</td>
		</tr>
		<tr>
			<td height="10%">12000</td>
		</tr>
		<tr>
			<td height="9%">11000</td>
		</tr>
		<tr>
			<td height="10%">10000</td>
		</tr>
		<tr>
			<td height="11%">9000</td>
		</tr>
		<tr>
			<td height="11%">8000</td>
		</tr>
	</table>
	<input style="margin-left:-80px;" id="level" class="rangeV" type=range min=0 max=10 value=0 step=1
		list=tickmarks>
	<datalist id=tickmarks>
		<option value="0">8000</option>
		<option value="1">9000</option>
		<option value="2">10000</option>
		<option value="3">11000</option>
		<option value="4">12000</option>
		<option value="5">13000</option>
		<option value="6">14000</option>
		<option value="7">15000</option>
		<option value="8">16000</option>
		<option value="9">17000</option>
		<option value="10">18000</option>
	</datalist>