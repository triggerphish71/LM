
<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 10/01/2007 | Added flowerbox                                                    |
| ranklam    | 10/01/2007 | Added an else statement so points don't get calculated twice when  |
|            |            | a radio is clicked twice for the services.                         |
----------------------------------------------------------------------------------------------->

<script language="javascript">

	var selectedSubOptions = new Array();
	var previousOption = null;
	var base =document.getElementById('base');
	var baseno =document.getElementById('baseno');	 
		 
	function CalculatePoints(divName,points,tool,theOption)
	{	

	 if ((document.getElementById('base').value == "no" && document.getElementById('base').checked == false) && 
				(document.getElementById('baseno').value == "yes" && document.getElementById('baseno').checked == false))
			{
				alert(" First select Base Level Option - 'NO' ");
				//if (document.getElementById('base').getAttribute('type') == 'radio') { document.getElementById('base').checked == true; }				
			}
			
		//first check if the selected div has been passed in
		if(theOption)
		{  			
			serviceId = theOption.name.substring(theOption.name.indexOf('_') + 1,theOption.name.length);
			//alert(serviceId);
			if(theOption.type == 'radio')
			{							
				if(theOption == previousOption)
				{
					return;
				}
				
					
				//determine the length of the selected options array				
				selectedSubOptions.length ? len = selectedSubOptions.length : len = 0;				
				//loop through the selected sub options
				for(i = 0; i < len; i++)
				{  					
					//if the parent id's match remove the points
					if(selectedSubOptions[i][0] == serviceId && selectedSubOptions[i][2] != theOption.value)
					{					
						//subtract the points						
						//alert(totalPoints + "-" + selectedSubOptions[i][1]);
						totalPoints += selectedSubOptions[i][1];
						//alert(totalPoints);
						//remove the options						
						selectedSubOptions.splice(i,1);
						len--;

						break;
					}
					else {
						//alert(totalPoints);
                    /*	if(theOption.value == 'no' && totalPoints != 0){
							totalPoints += points;
						}*/
						if(theOption.value != 'no' && theOption.value != 'yes') {
							//alert("inside forloop else " + totalPoints + "+" + selectedSubOptions[i][1]);
							if(totalPoints < 0)
								totalPoints = 0;
							totalPoints += selectedSubOptions[i][1];							
							//alert("inside sub for loop else");
						}
						break;
					}
				}
				
				//reset the selectedsubotipns length
				selectedSubOptions.length ? len = selectedSubOptions.length : len = 0;
				
				//only add sub services that have been checked
				if(theOption.name.indexOf('sub') != -1 && theOption.checked)
				{	
					selectedSubOptions[len] = new Array(3);
					selectedSubOptions[len][0] = serviceId;
					selectedSubOptions[len][1] = points;
					selectedSubOptions[len][2] = theOption.value;
					
					previousOption = theOption;
				}
				//rsa 10/1/07 - added else so service points are not added everytime the radio is clicked
				else
				{
					previousOption = theOption;
				}
			}
			else
			{					
				//get all the checkboxes for this service
				var optionArray = document.getElementsByName('subService_' + serviceId);
				
				//loop through the options and remove the points for any options that are checked
				for(i = 0; i < optionArray.length; i++)
				{
					if(optionArray[i] == theOption && !theOption.checked)
					{
						points = points * -1;
					}
				} 
				
			}
		}
		theDiv = document.getElementsByName(divName)[0];
		
		//dont add the points if the div is not selected		
		if((theOption.name.indexOf('sub') != -1 && theOption.checked) || (theOption.name.indexOf('sub') == -1) || theOption.type == 'radio')
		{  
		  if(theOption.value == 'yes')
		     {  //alert(serviceId +"serviceId12");	
			 	//alert("Inside yes");
				document.getElementsByName('check_' + serviceId).checked = true;
				if(totalPoints < 0)
					totalPoints = 0;
				totalPoints += points;
				//alert("Inside Yes" + totalPoints);
				
		     }
			 else if(theOption.value == 'no' && totalPoints != 0 )
				{ 
				document.getElementsByName('check_' + serviceId).checked = true;
				//alert(serviceId +"serviceId");
					//alert(totalPoints + "+" + points);
					totalPoints += points;
					//alert("Inside no-2"  +  totalPoints);
					
				}
			
		}	
		 		
		//set the level
		level = GetLevel(totalPoints,tool);
	  
		theDiv.innerHTML = totalPoints + ' Points :: Level ' + level;
				 	   
	}
</script>