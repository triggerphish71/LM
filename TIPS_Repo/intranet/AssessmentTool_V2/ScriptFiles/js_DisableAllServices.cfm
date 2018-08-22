<script language="javascript">
	function DisableAllServices(theObj,pointsSpan)
	{
		var inputArray = document.getElementsByTagName('input');
		var baseFound = false;
		var disable = null;
		
		//set the disable to true if base equals yes   //88898 project - set disable to false id base equal to 'no' -Ganga
		/*(theObj.value == 'yes') ? disable = true: disable = false;		
		if(theObj.value == 'yes'){  
		alert(" YES Base Level Selection will mark all Services to NO"); 
		}*/
		for(i = 0; i < inputArray.length; i++)
		{		
			//if the base is found disable or enable all the objects below it
			if(baseFound && inputArray[i].type != 'submit' && inputArray[i].type != 'button') // && inputArray[i].type != 'hidden')
			{
				if(disable)
				{	                    
					//inputArray[i].disabled = true;
					//inputArray[i].checked = false;
					<cfif IsDefined("Assessment")>
					 <cfelse>
				   if(inputArray[i].value == 'no')
					 {  //alert(totalPoints+"test here-2");
					 
					  inputArray[i].checked = true;					  
					 
					 }
					 if( inputArray[i].name.indexOf('subService_') != -1 )
						 {  
						//  inputArray[i].checked = false;    
						 }
					 </cfif>
				}
				else
				{
					//inputArray[i].disabled = false;
					//if this is not a sub service
					if(inputArray[i].name.indexOf('sub') == -1)
					{						
						if(inputArray[i].value == 'no')
						{
							//inputArray[i].checked = false;
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