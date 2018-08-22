<script language="javascript">
	function EnableParent(divName)
	{
		if(!skip)
		{
			var theInput = document.getElementsByName(divName);
	
			for(i = 0; i < theInput.length; i++)
			{		
				if(theInput[i].value == 'yes' && !theInput[i].checked)
				{  //alert("test here");
					theInput[i].checked = true;
					//call the inputs onclick method to add its points
					theInput[i].onclick();
				}
			}
		}
	}
</script>