<script language="javascript">
	function ShowNotes(divName,remove)
	{
		theDiv = document.getElementsByName(divName)[0];
		
		if(!remove)
		{
			theDiv.innerHTML = '<a href="javascript:ShowNotes(\''+ divName + '\',true)">remove notes : notes for this service will be discarded</a><br><textarea name="add_' + divName + '" rows="3" cols="45"></textarea>';
		}
		else
		{
			theDiv.innerHTML = '<a href="javascript:ShowNotes(\'' + divName + '\')">add notes</a>';
		}
	}
</script>