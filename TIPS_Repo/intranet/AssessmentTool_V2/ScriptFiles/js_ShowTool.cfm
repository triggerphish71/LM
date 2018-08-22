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
| Sathya     | 02/12/2010 | Made changes as per Project 41315-B so that  it displays           |
|            |            | Notes section below Service Category in a assessment.              |
| Ganga      | 05/27/2012 | Made changes as per project 88898 Displays the new assessment      |
|            |            |                                                                    |
----------------------------------------------------------------------------------------------->
<cfparam name="AssessmentServiceArray" default="#ArrayNew(1)#">
<cfparam name="AssessmentSubServiceArray" default="#ArrayNew(1)#">
<cfparam name="radioName" default="">
<cfoutput>
<script language="javascript">
	//create arrays to hold the service categories, lists, and subservices
	var ToolArray = new Array(#ArrayLen(AssessmentToolArray)#);
	var vServiceList = '';
	var vnotesList = '';
	
    //alert(#ArrayLen(AssessmentToolArray)# + "AssessmentToolArray");
	<cfloop from="1" to="#ArrayLen(AssessmentToolArray)#" index="x">
		<cfset ServiceArray = AssessmentToolArray[x].GetServicesAsStruct()>
		ToolArray[#x - 1#] = new Array(#ArrayLen(ServiceArray)#); 
		<cfloop from="1" to="#ArrayLen(ServiceArray)#" index="i">
			ToolArray[#x - 1#][#i - 1#] = new Array(16);
			ToolArray[#x - 1#][#i - 1#][0] = '#ReplaceNoCase(ServiceArray[i].assessmentToolId,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][1] = '#ReplaceNoCase(ServiceArray[i].assessmentTool,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][2] = '#ReplaceNoCase(ServiceArray[i].serviceCategoryId,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][3] = '#ReplaceNoCase(ServiceArray[i].category,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][4] = '#ReplaceNoCase(ServiceArray[i].categorySystem,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][5] = '#ReplaceNoCase(ServiceArray[i].categoryMultiple,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][6] = '#ReplaceNoCase(ServiceArray[i].serviceListId,"'","\'","ALL")#';			
			ToolArray[#x - 1#][#i - 1#][7] = '#ReplaceNoCase(ServiceArray[i].service,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][8] = '#ReplaceNoCase(ServiceArray[i].serviceWeight,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][9] = '#ReplaceNoCase(ServiceArray[i].serviceGrouping,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][10] = '#ReplaceNoCase(ServiceArray[i].serviceApproval,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][11] = '#ReplaceNoCase(ServiceArray[i].subServiceList,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][12] = '#ReplaceNoCase(ServiceArray[i].subService,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][13] = '#ReplaceNoCase(ServiceArray[i].subServiceWeight,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][14] = '#ReplaceNoCase(ServiceArray[i].subServiceGrouping,"'","\'","ALL")#';
			ToolArray[#x - 1#][#i - 1#][15] = '#ReplaceNoCase(ServiceArray[i].subServiceApproval,"'","\'","ALL")#';
			<!---ToolArray[#x - 1#][#i - 1#][16] = '#ReplaceNoCase(ServicetextArray[i].Service_text,"'","\'","ALL")#';--->
		</cfloop>
	</cfloop>
	
	function ShowTool(obj,divName)
	{
		var toolId = null;
		var html = '<table border="0" width="800" cellpadding="2" cellspacing="4" id="container">';
		var tab = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
	   // var num = 0;
		toolId = obj.options[obj.selectedIndex].value;
	//loop through the tools		
		for(i = 0; i < ToolArray.length; i++)
		{    
		   //alert(ToolArray[i][0][0] +''+toolId+"test here");
		   //check the toolarray and make suer that the tool matches the selected tool
			if(ToolArray[i][0][0] == toolId) 
			{  			
				var Services = ToolArray[i];
				//now that we know what assessment tool we are using loop through their services
				//for(num=0; num <= Services.length; num++){ 
				
				for(x = 0; x < Services.length; x++)
				{	
					//make sure if we look ahead we dont go outside the array boundry
					//for(num=0; num <= Services[x][6].length; num++){
	           //for(num=0; num <= Services.length; num++){ 
					if(x + 1 < Services.length)
					{   
					  
						if(x == 0)
						{
						
							html += '<tr><td colspan=4 class="ServiceCategory">' + Services[x][3] + '</td></tr>';
							<!---<cfif isDefined("Assessment") AND NOT Assessment.GetIsFinalized()> --->
							<cfif fuse eq "viewAssessment">
							html += '<tr><td class="serviceOption" align="right"><input type="radio" onclick="CalculatePoints(\'pointsSpan\',' + Services[x][8] * -1 + ',' + Services[x][0] + ',this)';
							
							if(Services[x][10] == 1)
							{
								//html += ';Highlight(this);';
							}
													 
							html += '" value="no" id="base" name="service_' + Services[x][6] +  '" >No<input type="radio" onclick="CalculatePoints(\'pointsSpan\',' + Services[x][8] + ',' + Services[x][0] +  ',this)';
															
							if(Services[x][10] == 1)
							{
								//html += ';Highlight(this);';
							}
								
							html += '" value="yes" id="baseno"  name="service_' + Services[x][6] +  '" >Yes</td><td class="service">' + Services[x][7]; 
							<cfelse>
							html += '<tr><td class="serviceOption" align="right"><input type="radio" onclick="DisableAllServices(this,\'pointsSpan\');CalculatePoints(\'pointsSpan\',' + Services[x][8] * -1 + ',' + Services[x][0] + ',this)';
							
							if(Services[x][10] == 1)
							{
								//html += ';Highlight(this);';
							}
							html += '" value="no" id="base" name="service_' + Services[x][6] +  '" >No<input type="radio" onclick="DisableAllServices(this,\'pointsSpan\');CalculatePoints(\'pointsSpan\',' + Services[x][8] + ',' + Services[x][0] +  ',this)';
							
							if(Services[x][10] == 1)
							{
								//html += ';Highlight(this);';
							}
								
							html += '" value="yes" id="baseno"  name="service_' + Services[x][6] +  '" >Yes</td><td class="service">' + Services[x][7]; 
							</cfif>	
							if(Services[x][12] != '' || Services[x][12] != 0)
							{
								if(Services[x][5] == 0)
								{
									html += '<br><strong><U><font color="red">***Please Select an item below if this Service applies to the Resident!</font></U></strong>';
								}
								else
								{
									html += '<br><strong>Select All That Apply</strong>';
								}
							}
							
							html += '&nbsp;' + Services[x][8] + ' points<input type="text" size="1" ID="check_'+Services[x][6] +'" name="check_'+Services[x][6] +'" value="n" style="visibility:hidden"></td></tr>';
							
							//check if this is a sub service & add it
							if(Services[x][12] != '' || Services[x][12] != 0)
							{
								if(Services[x][5] == 0)
								{
									html += '<tr><td class="serviceOption" align="right"><input type="radio"  value="' + Services[x][11] + '" onclick="EnableParent(\'service' + Services[x][6] + '\');CalculatePoints(\'pointsSpan\',' + Services[x][13] + ',' + Services[x][0] +  ')';
									
									if(Services[x][15] == 1)
									{
										//html += ';Highlight(this);';
									}
									
									html += '" name="subService_' + Services[x][6] + '"></td><td class="serviceText">' + Services[x][12] + '&nbsp;' + Services[x][13] + 'points</td></tr>';
								}
								else
								{
									html += '<tr><td class="serviceOption" align="right"><input type="checkbox" value="' + Services[x][11] + '" onclick="EnableParent(\'service_' + Services[x][6] + '\');CalculatePoints(\'pointsSpan\',' + Services[x][13] + ',' + Services[x][0] +  ')';
									
									if(Services[x][15] == 1)
									{
										//html += ';Highlight(this);';
									}
										
									html += '" name="subService_' + Services[x][6] + '"></td><td class="serviceText">' + Services[x][12] + '&nbsp;' + Services[x][13] + 'points</td></tr>';
								}
							}
						}
						else
						{  
							//first check if the service category matches the previous one
							if(Services[x][2] != Services[x-1][2])
							{
								//02/12/2010 Sathya as per Project 41315-B commented this out
								//html += '<tr><td colspan=4 class="ServiceCategory">' + Services[x][3] + '</td></tr>';
								//02/19/2010 sathya as per project 41315-B added this
                              html += '<tr><td colspan=4 class="ServiceCategory"><input type="hidden" name="category_'+ Services[x][2] +  '">' + Services[x][3]+ '&nbsp;&nbsp;&nbsp;(Enter service plan here.)<div name="notes_' + Services[x][2] + '" id="notes_' + Services[x][2] + '"><a href="javascript:ShowCategoryNotes(\'notes_' + Services[x][2] + '\');">add notes</a></div></td></tr>';
                              // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
                           	}
							
							//next check the services
							if(Services[x][6] != Services[x-1][6])
							{  
								html += '<tr><td class="serviceOption" align="right"><input type="radio" onclick="DisableSubServices(this);CalculatePoints(\'pointsSpan\',' + Services[x][8] * -1 + ',' + Services[x][0] +  ',this)';  //ShowNotes(\'notes_' + Services[x][6] + '\');
										
								if(Services[x][10] == 1)
								{
									//html += ';Highlight(this);';
								}
								 	
								html += '" value="no" id="service_' + Services[x][6] +  '" name="service_' + Services[x][6] +  '" >No<input type="radio" onclick="DisableSubServices(this);CalculatePoints(\'pointsSpan\',' + Services[x][8] + ',' + Services[x][0] +  ',this)';   //ShowNotes(\'notes_' + Services[x][6] + '\');DisableServicesWithNoOption();
								
								if(Services[x][10] == 1)
								{
									//html += ';Highlight(this);';
								}
											
								html += '" value="yes" id="service_' + Services[x][6] +  '"  name="service_' + Services[x][6] +  '" >Yes</td><td class="service"><span id="t_service_' + Services[x][6] +  '">' + Services[x][7] +'</span>';

								vServiceList +=  'service_'+ Services[x][6] + ',';
								//vnotesList += 'notes_'+ Services[x][6] + ',';
								if(Services[x][12] != '' || Services[x][12] != 0)
								{
									if(Services[x][5] == 0)
									{
										html += '<br><strong><U><font color="Fuchsia">***Please Select an item below if this Service applies to the Resident!</font></U></strong>';
									}
									else
									{
										html += '<br><strong>Select All That Apply</strong>';
									}
								}
								//There were case were assessment notes were not been saved as they added notes below service question 
								// and it didnot save as the service question is not enabled. If the parent is not enabled the notes for service will not be saved. 
								//Change by Jaime Cruz to enable parent when add notes is clicked.
								html += '&nbsp;' + Services[x][8] + ' points<input type="text" size="1" ID="check_'+Services[x][6] +'" name="check_'+Services[x][6] +'" value="n" style="visibility:hidden"><input type="text" size="1" ID="rbt_'+Services[x][6] +'" name="rbt_'+Services[x][6] +'" value="" style="visibility:hidden"><div name="notes_' + Services[x][6] + '" id="notes_' + Services[x][6] + '"><a href="javascript:ShowNotes(\'notes_' + Services[x][6] + '\');EnableParent(\'service_' + Services[x][6] + '\')"><textarea id="add_notes_' + Services[x][6] + '" name="add_notes_' + Services[x][6] + '" rows="3" cols="45"></textarea><!---add notes---></a></div></td></tr>';
						//vnotesList += 'notes_'+ Services[x][6] + ',';
						<!---<input type="text" size="1" ID="rbt_'+Services[x][6] +'" name="rbt_'+Services[x][6] +'" value="" style="visibility:hidden">--->
							 // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
							}
							
							//make sure always add the sub service
							if(Services[x][12] != '' || Services[x][12] != 0)
							{
								if(Services[x][5] == 0)
								{
									html += '<tr><td class="serviceOption" align="right"><input type="radio"  value="' + Services[x][11] + '" onclick="EnableParent(\'service_' + Services[x][6] + '\');CalculatePoints(\'pointsSpan\',' + Services[x][13] + ',' + Services[x][0] +  ',this)';
											
									if(Services[x][15] == 1)
									{
										
										//html += ';Highlight(this);';
									}
								
									html += '" name="subService_' + Services[x][6] + '"></td><td class="serviceText">' + Services[x][12] + '&nbsp;' + Services[x][13] + 'points</td></tr>';
								}
								else
								{
									html += '<tr><td class="serviceOption" align="right"><input type="checkbox" value="' + Services[x][11] + '" onclick="EnableParent(\'service_' + Services[x][6] + '\');CalculatePoints(\'pointsSpan\',' + Services[x][13] + ',' + Services[x][0] +  ',this)';
											
									if(Services[x][15] == 1)
									{
										//html += ';Highlight(this)';
									}
										
									html += '" name="subService_' + Services[x][6] + '"></td><td class="serviceText">' + Services[x][12] + '&nbsp;' + Services[x][13] + 'points</td></tr>';
								}
							}
						} 
					}
					else //last item in the loop, no look ahead
					{
						//check the sub services
						if(Services[x][6] != Services[x-1][6])
						{
							html += '<tr><td class="serviceOption" align="right"><input type="radio" onclick="DisableSubServices(this);CalculatePoints(\'pointsSpan\',' + Services[x][8] * -1 + ',' + Services[x][0] +  ',this)';
										
								if(Services[x][10] == 1)
								{
									//html += ';Highlight(this);';
								}
										
								html += '" value="no" id="service_' + Services[x][6] +  '" name="service_' + Services[x][6] +  '" >No<input type="radio" onclick="DisableSubServices(this);CalculatePoints(\'pointsSpan\',' + Services[x][8] + ',' + Services[x][0] +  ',this)';   //ShowNotes(\'notes_' + Services[x][6] + '\');
								
								if(Services[x][10] == 1)
								{
									//html += ';Highlight(this);';
								}
								
								html += '" value="yes" id="service_' + Services[x][6] +  '"  name="service_' + Services[x][6] +  '">Yes</td><td class="service">' + Services[x][7];
								vServiceList +=  'service_'+ Services[x][6] + ',';
								
								if(Services[x][12] != '' || Services[x][12] != 0)
								{
									if(Services[x][5] == 0)
									{
										html += '<br><strong><U><font color="Fuchsia">***Please Select an item below if this Service applies to the Resident!</font></U></strong>';
									}
									else
									{
										html += '<br><strong>Select All That Apply</strong>';
									}
								}
								//02/22/2010 Sathya As per project 41315-B please move the below code to production
								// The below code has been modified by Jaime and needs to be moved to production for proper working of assessments
								//There were case were assessment notes were not been saved as they added notes below service question 
								// and it didnot save as the service question is not enabled. If the parent is not enabled the notes for service will not be saved. 
								//Change by Jaime Cruz to enable parent when add notes is clicked.
								html += '&nbsp;' + Services[x][8] + ' points<input type="text" size="1" ID="check_'+Services[x][6] +'" name="check_'+Services[x][6] +'" value="n" style="visibility:hidden"><div name="notes_' + Services[x][6] + '" id="notes_' + Services[x][6] + '"><a href="javascript:ShowNotes(\'notes_' + Services[x][6] + '\',);EnableParent(\'service_' + Services[x][6] + '\')"><a href="javascript:ShowNotes(\'notes_' + Services[x][6] + '\');EnableParent(\'service_' + Services[x][6] + '\')"><textarea id="add_notes_' + Services[x][6] + '" name="add_notes_' + Services[x][6] + '" rows="3" cols="45"></textarea><!---add notes---></a></div></td></tr>';
								 // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
					      }
						
						//always add the sub service
							if(Services[x][5] == 0)
							{
								html += '<tr><td class="serviceOption" align="right"><input type="radio"  value="' + Services[x][11] + '" onclick="EnableParent(\'service_' + Services[x][6] + '\');CalculatePoints(\'pointsSpan\',' + Services[x][13] + ',' + Services[x][0] +  ',this)';
										
								if(Services[x][15] == 1)
								{
									
									html += ';Highlight(this);';
								}
							
								html += '" name="subService_' + Services[x][6] + '"></td><td class="serviceText">' + Services[x][12] + '&nbsp;' + Services[x][13] + 'points</td></tr>';
							}
							else
							{
								html += '<tr><td class="serviceOption" align="right"><input type="checkbox" value="' + Services[x][11] + '" onclick="EnableParent(\'service_' + Services[x][6] + '\');CalculatePoints(\'pointsSpan\',' + Services[x][13] + ',' + Services[x][0] +  ',this)';
										
								if(Services[x][15] == 1)
								{
									html += ';Highlight(this)';
								}
									
								html += '" name="subService_' + Services[x][6] + '"></td><td class="serviceText">' + Services[x][12] + '&nbsp;' + Services[x][13] + 'points</td></tr>';
							}
					}
				}
				
			//done looking at the matching tool
			break;
			//} 
			//alert(Services[x][6].length);
			}	
		}
		
		html += '</table>';
		//get the assessment area
		theDiv = document.getElementsByName(divName)[0];
		theDiv.innerHTML = html;
		//document.getElementById('v1').value=html;
		ResetLevel();
	}
</script>
</cfoutput>
<!---<textarea id="v1"></textarea>--->

<!---<cfdump var="#ServiceArray#">--->