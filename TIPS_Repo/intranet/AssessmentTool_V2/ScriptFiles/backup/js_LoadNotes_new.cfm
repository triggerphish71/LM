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
|            |            | Notes section Below Category. Added code to check if it belonged   |
|            |            | to category and then load the notes.                               |
----------------------------------------------------------------------------------------------->
<cfoutput>
	<script language="javascript">
	function LoadNotes()
	{	
		//get all the input buttons
		InputArray = document.getElementsByTagName('input');
		var ServiceArray = new Array(#ArrayLen(AssessmentServiceArray)#);
		
		//
		var SubServiceArray = new Array(#ArrayLen(AssessmentSubServiceArray)#);
        //02/18/2010 sathya added this for AssessmentServiceCategory as per project 41315-B
        var ServiceCategoryArray = new Array(#ArrayLen(AssessmentServiceCategory)#);
         // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
        
		<cfloop from="1" to="#ArrayLen(AssessmentServiceArray)#" index="i">
			ServiceArray[#i - 1#] = new Array(3);
			
			ServiceArray[#i - 1#][0] = #AssessmentServiceArray[i].GetId()#;
			
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
		//02/18/2010 Sathya Added this as per project 41315-B
		 <cfloop from="1" to="#ArrayLen(AssessmentServiceCategory)#" index="i">
				ServiceCategoryArray[#i - 1#] = new Array(2);
				
				ServiceCategoryArray[#i - 1#][0] = #AssessmentServiceCategory[i].GetId()#;
				
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
			
			//then check if its a service else 
			if(InputArray[i].name.indexOf('service') != -1 )
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
						//InputArray[i].checked = true;
						notesName = 'notes_' + ServiceArray[x][0];
						//alert(InputArray[i].name.indexOf('service'));
						ShowNotes(notesName);
						
						notesName = 'add_' + notesName;
						//document.getElementsByName(notesName)[0].value = ServiceArray[x][1];
						if(	typeof document.getElementsByName(notesName)[0] != 'undefined')
						{   
							document.getElementsByName(notesName)[0].value = ServiceArray[x][1];
							//InputArray[i].onclick();
						} 
						
						//InputArray[i].onclick();
						break;
					}
				}			
			}
			//02/18/2010 Sathya Added this as per project 41315-B for service category
			else if(InputArray[i].name.indexOf('category') != -1 )
			{
				
				//loop through the service array
				for(x = 0; x < ServiceCategoryArray.length; x++)
				{
					serviceCategoryId = InputArray[i].name.substring(InputArray[i].name.indexOf('_') + 1,InputArray[i].name.length);
					if(serviceCategoryId == ServiceCategoryArray[x][0])
					{
						//InputArray[i].checked = true;
						CategorynotesName = 'notes_' + ServiceCategoryArray[x][0];
						//alert(InputArray[i].name.indexOf('serviceCategory'));
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
	}
</script>
</cfoutput>