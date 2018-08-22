
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
	//var base =document.getElementById('base');
	//var baseno =document.getElementById('baseno');	 
		 
	function CalculatePoints(divName,points,tool,theOption)
	{	
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
						totalPoints -= selectedSubOptions[i][1];
						//remove the options
						selectedSubOptions.splice(i,1);
						len--;

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
		
		//dont add the points if the div is not selected
		if((theOption.name.indexOf('sub') != -1 && theOption.checked) || (theOption.name.indexOf('sub') == -1) || theOption.type == 'checkbox')
		{  //alert(theOption.name.indexOf('sub'));
			totalPoints += points;
		}		
		//set the level
		level = GetLevel(totalPoints,tool);
		
		theDiv.innerHTML = totalPoints + ' Points :: Level ' + level;
		/*// 88898 project- If nothing will select and points =0 set to points and  level is equal to 1   -- Ganga 04/03/2012
	 if( (document.getElementById('base').value == "yes" && document.getElementById('base').checked == false )&&
	    (document.getElementById('baseno').value == "no" && document.getElementById('baseno').checked == true ))   
		 {   
		     totalPoints = 1;
			 level = 1;
			 //alert(" Base Level is 'NO' you'll get 1 Point :: Level 1 - by default ");
			 theDiv.innerHTML = totalPoints + ' Points :: Level ' + level;
		     //theDiv.innerHTML = 1 + ' Points :: Level ' + 1;
		}*/
	  
		 	   
	}
</script>