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
| Sathya     | 02/18/2010 | Made changes as per Project 41315-B so that  it displays           |
|            |            |  Notes section Below Category                                      |
|            |            |                                                                    |
----------------------------------------------------------------------------------------------->
<cfoutput>
	<script language="javascript">
	function LoadAssessment()
	{	
		/*var base =document.getElementById('base');
		var baseno =document.getElementById('baseno');	
		if(totalPoints > 0)
		{	
		 alert("hello u r here 1");
		 document.getElementById('baseno').checked == true;
		}
		else{
		alert(document.getElementById('base').value +"hello u r here 2");
		   
		    document.getElementById('base').checked == true;
			
		    }*/	
			//-----------------------------------------------
		//get all the input buttons
		InputArray = document.getElementsByTagName('input');
		var ServiceArray = new Array(#ArrayLen(AssessmentServiceArray)#);
		
		//
		var SubServiceArray = new Array(#ArrayLen(AssessmentSubServiceArray)#);
		
		 //02/18/2010 sathya added this for AssessmentServiceCategory as per project 41315-B
        var ServiceCategoryArray = new Array(#ArrayLen(AssessmentServiceCategory)#);
        // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
      //alert("hello u r in load assessment");
	 	<cfloop from="1" to="#ArrayLen(AssessmentServiceArray)#" index="i">
			ServiceArray[#i - 1#] = new Array(3);
			
			ServiceArray[#i - 1#][0] = #AssessmentServiceArray[i].GetId()#;
	//alert(ServiceArray[#i - 1#][0] +" servicearray value");
			<cfset theNotes = AssessmentServiceArray[i].GetNotes()>
			<cfset theNotes = Replace(theNotes,chr(13),"\n","ALL")>
			<cfset theNotes = Replace(theNotes,chr(10),"","ALL")>
			<cfset theNotes = ReplaceNoCase(theNotes,"'","\'","ALL")>
			ServiceArray[#i - 1#][1] = '#theNotes#';
			ServiceArray[#i - 1#][2] = '#AssessmentServiceArray[i].getservice_text()#';			
		</cfloop>
		
		<cfloop from="1" to="#ArrayLen(AssessmentSubServiceArray)#" index="i">
			SubServiceArray[#i - 1#] = #AssessmentSubServiceArray[i].GetId()#
		</cfloop>
		//alert(AssessmentServiceArray +"AssessmentServiceArray");
		//02/18/2010 Sathya Added this as per project 41315-B
		<cfloop from="1" to="#ArrayLen(AssessmentServiceCategory)#" index="i">
			ServiceCategoryArray[#i - 1#] = new Array(2);
			
			ServiceCategoryArray[#i - 1#][0] = #AssessmentServiceCategory[i].GetId()#;
			//ServiceCategoryArray[#i - 1#][1] = #AssessmentServiceCategory[i].GetDescription()#;
			<cfset theCategoryNotes = AssessmentServiceCategory[i].GetNotes()>
			<cfset theCategoryNotes = Replace(theCategoryNotes,chr(13),"\n","ALL")>
			<cfset theCategoryNotes = Replace(theCategoryNotes,chr(10),"","ALL")>
			<cfset theCategoryNotes = ReplaceNoCase(theCategoryNotes,"'","\'","ALL")>
			ServiceCategoryArray[#i - 1#][1] = '#theCategoryNotes#';
		</cfloop>
		 // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
				
		//loop through the inputs
		for(i = 0; i < InputArray.length; i++)
		{   
			if(InputArray[i].onclick)
			{
				var onClickProcedure = InputArray[i].onclick.toString();
			}
			
			
			//check if this is a subservice first
			if(InputArray[i].name.indexOf('sub') != -1)
			{
				for(x = 0; x < SubServiceArray.length; x++)
				{
					//alert(serviceId + ' ' + ServiceArray[x]);
					if(InputArray[i].value == SubServiceArray[x] && !InputArray[i].checked)
					{
						InputArray[i].checked = true;
						InputArray[i].onclick();
						break;
					}
				}
			}
			//then check if its a service
			else if(InputArray[i].name.indexOf('service') != -1 )
			{
				//loop through the service array
				for(x = 0; x < ServiceArray.length; x++)
				{ 
					serviceId = InputArray[i].name.substring(InputArray[i].name.indexOf('_') + 1,InputArray[i].name.length);
					if( ServiceArray[x][2] =='n' )
					{
						serviceValue = 'no';
					}
					else
					{
						serviceValue = 'yes';
					}
				if(serviceId == ServiceArray[x][0] && InputArray[i].value == serviceValue && !InputArray[i].checked)
					{

						InputArray[i].checked = true;						
						notesName = 'notes_' + ServiceArray[x][0];
						
						ShowNotes(notesName);
						
						notesName = 'add_' + notesName;						 
												
						//document.getElementsByName(notesName)[0].value = ServiceArray[x][1];
						if(	typeof document.getElementsByName(notesName)[0] != 'undefined')
						{   						
							document.getElementsByName(notesName)[0].value = ServiceArray[x][1];
							//alert(ServiceArray[x][1] +"test onclick event");
							//InputArray[i].onclick();							
						}
						  if( InputArray[i].value == 'yes' )
						   {
						       InputArray[i].onclick();
						   }						
						//InputArray[i].onclick();
						break;
					}
					
				}			
			} 
			//02/18/2010 Sathya Added this as per project 41315-B for service category
			else if(InputArray[i].name.indexOf('category') != -1 )
			{    //alert(InputArray[i].name.indexOf('service') );
			 	//loop through the service array
				for(x = 0; x < ServiceCategoryArray.length; x++)
				{
					serviceCategoryId = InputArray[i].name.substring(InputArray[i].name.indexOf('_') + 1,InputArray[i].name.length);					
					if(serviceCategoryId == ServiceCategoryArray[x][0])
					{   
						//InputArray[i].checked = true;
						CategorynotesName = 'notes_' + ServiceCategoryArray[x][0];
						ShowCategoryNotes(CategorynotesName);
						
						CategorynotesName = 'add_' + CategorynotesName;
						document.getElementsByName(CategorynotesName)[0].value = ServiceCategoryArray[x][1];
						
						//InputArray[i].onclick();
						break;
				 
					}
				}			
			} 
		   // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)			
		}  
		
		//if(InputArray[10].value + " no base");		
	}
</script>
</cfoutput>
<!---<cfdump var="#AssessmentServiceArray[1].getservice_text()#">--->