<script language="javascript">
	function DisableAllServices(theObj)
	{
		var inputArray = document.getElementsByTagName('input');
		var baseFound = false;
		var disable = null;
		
		//set the disable to true if base equals yes
		(theObj.value == 'yes') ? disable = true: disable = false;
		
		for(i = 0; i < inputArray.length; i++)
		{		
			//if the base is found disable or enable all the objects below it
			if(baseFound && inputArray[i].type != 'submit' && inputArray[i].type != 'button' && inputArray[i].type != 'hidden')
			{
				if(disable)
				{	
					inputArray[i].disabled = true;
					inputArray[i].checked = false;
				}
				else
				{
					inputArray[i].disabled = false;
					//if this is not a sub service
					if(inputArray[i].name.indexOf('sub') == -1)
					{						
						if(inputArray[i].value == 'no')
						{
							inputArray[i].checked = true;
						}
					}
				}
			}
				
			//first check for the base level object
			if(inputArray[i].name == theObj.name && !baseFound)
			{
				baseFound = true;
				i++;
			}
		}
		
		ResetLevel();
	}
</script>