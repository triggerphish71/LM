<script language="javascript">
	var skip = false;
			
	function DisableSubServices(theDiv)
	{
		var serviceId = theDiv.name.substring(theDiv.name.indexOf('_') + 1);
		
		var inputArray = document.getElementsByTagName('input');
		
		for(i = 0; i < inputArray.length; i++)
		{			
			if(inputArray[i].name.indexOf(serviceId) != -1 && inputArray[i].name != theDiv.name)
			{
				if(theDiv.value == 'no')
				{
					//if the option is checked uncheck it
					if(inputArray[i].checked)
					{
						skip = true;
						inputArray[i].checked = false;
						inputArray[i].onclick();
						skip = false; 
						previousOption = null;
					}
				}
				else
				{
					//enable the input
					inputArray[i].disabled = false;
				}
			}
		}
	}
</script>