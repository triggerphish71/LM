<script language="javascript">
	function ShowNotes(divName,remove)
	{
		theDiv = document.getElementsByName(divName)[0];
		if(	typeof theDiv != 'undefined')
		{
		//alert(theDiv);
		if(!remove)
		{
			//theDiv.innerHTML = '<a href="javascript:ShowNotes(\''+ divName + '\',true)"></a><br><textarea id="add_' + divName + '" name="add_' + divName + '" rows="3" cols="45"></textarea>';
			//alert("add_"+divName);
		}
		else
		{
			//theDiv.innerHTML = '<a href="javascript:ShowNotes(\'' + divName + '\')">add notes</a>';
		}
	  }	
	}
	
	
</script>