
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

	 	
		//first check if the selected div has been passed in
		if(theOption)
		{
			serviceId = theOption.name.substring(theOption.name.indexOf('_') + 1,theOption.name.length);
			
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
						totalPoints -= selectedSubOptions[i][1];						
						//remove the options
						selectedSubOptions.splice(i,1);
						len--;                         
						break;
					}					
				}   
				if(theOption.value != 'no' && theOption.value != 'yes' && selectedSubOptions.length >= 0 && theOption.checked != false ) 
				 {  
				    totalPoints += points;					
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
				
				//loop through the options and remove the points for any opeions that are checked
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
		//alert(document.getElementById('check_' + serviceId)+"test here");
		//dont add the points if the div is not selected		
		if((theOption.name.indexOf('sub') != -1 && theOption.checked) || (theOption.name.indexOf('sub') == -1) || theOption.type == 'radio')
		{  
		  if(theOption.value == 'yes' && theOption.checked == true)
		     { 
				if( document.getElementById('check_' + serviceId) != null )
				{
					document.getElementById('check_' + serviceId).value = 'y';					
				}
				if( document.getElementById('rbt_' + serviceId) != null )
				{
					document.getElementById('rbt_' + serviceId).value = 'y';
				}				
				//document.getElementById('check_' + serviceId).value = 'y';
				//document.getElementById('rbt_' + serviceId).value = 'y';
				totalPoints += points;				
				//document.getElementsByName('pointbtn_'+serviceId).checked = true;				
		     }
			 //else if(theOption.value == 'no' && document.getElementById('check_' + serviceId).value == 'y')
			 else if(theOption.value == 'no' && document.getElementById('check_' + serviceId).value == 'y')
				{ 
					//document.getElementById('check_' + serviceId).value = 'n';					
				  	//totalPoints += points;	
					if( document.getElementById('check_' + serviceId) != null )
				     {
					      document.getElementById('check_' + serviceId).value = 'n';					
				     }					
				  	totalPoints += points;										
				}	
			if(theOption.value == 'no' && document.getElementById('rbt_' + serviceId) != null )
			{	
			  document.getElementById('rbt_' + serviceId).value = 'n';
			}
		}			 		
		//set the level
		level = GetLevel(totalPoints,tool);
	  
		theDiv.innerHTML = totalPoints + ' Points :: Level ' + level;
		
		// Added Project 88898 - Base level option pre-select.
		if ((document.getElementById('base').value == "no" && document.getElementById('base').checked == false) && (totalPoints > 0 ))
				//(document.getElementById('baseno').value == "yes" && document.getElementById('baseno').checked == false))
		{  <cfif IsDefined("Assessment")>
		 if (document.getElementById('base').getAttribute('type') == 'radio')
		    { 
			  document.getElementById('base').checked = true;
			}
		  <cfelse>
		 //alert(" Base Level Option not selected, By default it will select option - 'NO' Continue...  ");
		 if (document.getElementById('base').getAttribute('type') == 'radio')
		    { 
			  document.getElementById('base').checked = true;
			}
			</cfif>			
		}
		<!---if ((document.getElementById('base').value == "no" && document.getElementById('base').checked == true) && (totalPoints == 0 ))
				//(document.getElementById('baseno').value == "yes" && document.getElementById('baseno').checked == false))
		{
		<cfif IsDefined("Assessment")>
		if (document.getElementById('baseno').getAttribute('type') == 'radio')
		    { 
			  document.getElementById('baseno').checked = true;
			}
		<cfelse>
		 //alert(" Base Level Option By default it will select - 'YES' Continue...  ");
		 if (document.getElementById('baseno').getAttribute('type') == 'radio')
		    { 
			  document.getElementById('baseno').checked = true;
			}	</cfif>				
		}	--->	 	   
	}
</script>