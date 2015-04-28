<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<portlet:defineObjects />
 
<portlet:resourceURL id="findState" var="findState" ></portlet:resourceURL>
 <script src="http://code.jquery.com/jquery-1.4.2.min.js"></script>
<script type="text/javascript">
$(document).ready(function(){
	
$( "#country" ).change(function() {
	  $.ajax({
	        url: "${findState}" ,
	        type: 'POST',
	        datatype:'json',
	        data: { 
	                countryName: $("#country").val() 
		      },
	            success: function(data){
	            var content= JSON.parse(data);
	            $('#state').html('');// to clear the previous option
	            $.each(content, function(i, state) {
	                $('#state').append($('<option>').text(state.name).attr('value', state.stateId));
	            });
	        }
	    });
  }); 
});
</script>
 
<b>Change the Country State Change By Ajax</b> <br><br>
Country:
<select id="country" name="country">
<option value="select">Select Country</option>
<option value="india">India</option>
<option value="usa">USA</option>
</select>
<br><br>
State:
<select id="state" name="state">
</select>