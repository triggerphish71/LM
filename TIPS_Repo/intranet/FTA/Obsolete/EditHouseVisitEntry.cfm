<cfset Page = "Edit House Visit">
<cfoutput>
	<!--- COLORS --->
	<cfset groupColor = "cdcdcd">
	<cfset freezeColor = "f5f5f5">
	<cfset toolbarColor = "d6d6ab">
	<cfset spellCheckBgColor = "ebebeb">
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
		<head>
			<link rel="stylesheet" href="CSS/datePicker.css" type="text/css">

			<script type='text/javascript' src='http://localhost/cfprojects/FTA/Ajax/core/engine.js'></script>
			<script type='text/javascript' src='http://localhost/cfprojects/FTA/Ajax/core/util.js'></script>
			<script type='text/javascript' src='http://localhost/cfprojects/FTA/Ajax/core/settings.js'></script>

			<script type="text/javascript" src="ScriptFiles/jquery-1.3.2.js"></script> 			
			<script src="ScriptFiles/jquery.hoverIntent.js" type="text/javascript"></script>
  			<script src="ScriptFiles/jquery.bgiframe.js" type="text/javascript"></script>
  			<script src="ScriptFiles/jquery.cluetip.js" type="text/javascript"></script>
			<script type="text/javascript" src="ScriptFiles/date.js"></script>
			<script type="text/javascript" src="ScriptFiles/jquery.datePicker.js"></script>
			<script type="text/javascript" src="ScriptFiles/jquery.blockUI.js"></script>
			<script type="text/javascript" src="ScriptFiles/jquery.wait.js"></script>
							
			<link rel="stylesheet" href="jquery.cluetip.css" type="text/css" />
			
			<title>
				Online FTA- #page#
			</title>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
			<cfheader name='expires' value='#Now()#'> 
			<cfheader name='pragma' value='no-cache'>
			<cfheader name='cache-control' value='no-cache,no-store, must-revalidate'>
			
			<!--- Instantiate the Helper object. --->
			<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
			
			<cfif isDefined("url.iHouse_ID")>
				<cfset houseId = #url.iHouse_ID#>
			</cfif>
			
			<cfif isDefined("url.SubAccount")>
				<cfset subAccount = #url.SubAccount#>
							
				<cfset dsHouseInfo = #helperObj.FetchHouseInfo(subAccount)#>
				<cfset unitId = #dsHouseInfo.unitId#>
				<cfset houseId = #dsHouseInfo.iHouse_ID#>
				<cfset HouseNumber = #trim(dsHouseInfo.EHSIFacilityID)#>
			</cfif>
			
			<cfif isDefined("url.EntryId")>
				<cfset entryId = #url.EntryId#>
			</cfif>
			
			<cfif isDefined("url.Save")>
				<cfset save = #url.Save#>
			<cfelse>
				<cfset save = "No">
			</cfif>
			
			<cfinclude template="Common/DateToUse.cfm">
			<cfinclude template="ScriptFiles/FTACommonScript.cfm">
		
			<!--- String Functions --->
			<script language="javascript" type="text/javascript">
				String.prototype.endsWith = function(str) {return (this.match(str+"$")==str)}
				String.prototype.startsWith = function(str) {return (this.match("^"+str)==str)}
			</script>
			<!--- THE CODE BELOW IS FOR THE SPELL CHECKING FUNCTIONALITY. --->
			<script language="javascript" type="text/javascript">
					
				function checkSpelling(iQuestionId)
				{
					// Get the spellcheck image element.
					var spellCheckImage = document.getElementById('imgSpellCheck_' + iQuestionId);	
					// Get the textarea element.
					var answerTextBox = document.getElementById('txtAnswer_' + iQuestionId);
					// Get the div element.
					var answerDiv = document.getElementById('divAnswer_' + iQuestionId);
					// Get the sub div element.
					var spellingSuggestionsDiv = document.getElementById('divSuggestions_' + iQuestionId);			
					// Determine the image type (state).
					if (spellCheckImage.src.endsWith('Images/resume.png'))
					{	
						// The user has requested to end the spell check process.
						spellCheckComplete(iQuestionId, false);
					}
					else
					{
						// Check if the answer textbox has a value.
						if ((answerTextBox.value != null) && (answerTextBox.value != ''))
						{
							// Block any user input.
							//$.blockUI({ message: '<div style="margin-top: 15px; color: darkblue; align: center; width: 200px; height: 40px; font-family: tahoma; font-size: 10pt; font-weight: bold;"><img src="Images/busy.gif" style="margin-right: 5px;" /> Spell Checking...</div>' }); 
							spellCheckImage.src = "Images/working.gif";
							// Stores the parameter string of the element id's and the spell check text.
							var spellingText = answerTextBox.value;
							alert('sending');
							// Execute the server-side spell check function.
							DWREngine._execute("http://localhost/cfprojects/FTA/Ajax/examples/", "functions.cfm", 'checkSpelling', spellingText, iQuestionId, spellCheckResult);
							alert('sending3');
						}
					}
				}
				function spellCheckResult(resultObj)
				{
					alert('RESULT');
					// Get the index of the seperator.
					var sepIndex = resultObj.indexOf("|");
					// Stores the question id and resulting html from the server-side function.
					var questionId = resultObj.substring(0, sepIndex);
					var resultHtml = resultObj.substring(sepIndex + 1);
					// Get the spellcheck image element.
					var spellCheckImage = document.getElementById('imgSpellCheck_' + questionId);				
					// Check if the result object is null, which means the text was valid with no spelling errors.
					if ((resultHtml != null) && (resultHtml != ''))
					{
						// Update the image source.
						spellCheckImage.src = 'Images/resume.png';
						// Update the image's tooltip text.
						spellCheckImage.title = 'Click to Finish Spell Checking';
						// Get the textarea element.
						var answerTextBox = document.getElementById('txtAnswer_' + questionId);
						// Get the div element.
						var answerDiv = document.getElementById('divAnswer_' + questionId);
						// Hide the textarea.
						answerTextBox.style.display = "none";
						// Create the new div tag to embed.
						var spellCheckDiv = document.createElement("div");
						// Setup the divSuggestion element.
						spellCheckDiv.id = "divSuggestions_" + questionId;
						// Set the size to fit 100% inside of the cell, like the textbox.
						spellCheckDiv.style.width = "100%";
						spellCheckDiv.style.height = "100%";
						// Setup the borders.
						spellCheckDiv.style.borderStyle = "inset";
						spellCheckDiv.style.borderWidth = "2px";
						spellCheckDiv.style.padding = "1px";
						spellCheckDiv.style.marginTop = "1px";
						// Setup the text.
						spellCheckDiv.style.fontFamily = "verdana";
						spellCheckDiv.style.fontSize = "10pt";
						// Set the scrolling area.
						spellCheckDiv.style.overflowX = "hidden";
						spellCheckDiv.style.overflowY = "scroll";
						// Make sure the background color is white, because the text is black.
						spellCheckDiv.style.background = "#spellCheckBgColor#";
						// Embed the string returned from the spell check web service.
						spellCheckDiv.innerHTML = resultHtml; 
						// Set the inner html of the div.
						answerDiv.appendChild(spellCheckDiv);
						// Setup the cluetip.
						$('a.load-local').cluetip(
						{
							local: true, 
							width: "160px",
							hidelocal: true,
							arrows: true,
							cursor: 'help', 
					  		hoverClass: 'highlight',
  							sticky: true,
  							closePosition: 'title',
  							mouseOutClose: true,
  							waitImage: true,
  							open: 'slideDown',
  							showTitle: false,
  							closeText: '<img title="Close" src="Images/cross.png" alt="" />'				
						});					
					}
					else
					{
						// Update the image source.
						spellCheckImage.src = 'Images/accept.png';
						// Update the tooltip text.
						spellCheckImage.title = 'Spell Check Complete';		
					}
					//$.unblockUI(); 		
				}
				// Removes the link, but keeps the links children.
				function clearLink(n)
				{
					// Check if the link contains any Child Nodes.
    				if(n.hasChildNodes())
    					// Loop through all of the link's child nodes.
        				for(var i=0;i<n.childNodes.length;i++)
        					// Create a copy of the link's child node and add it to the link's parent.
            				n.parentNode.insertBefore(n.childNodes[i].cloneNode(true),n);
            		// Remove the link by using the link's parent to remove it as a child.
    				n.parentNode.removeChild(n);
				}
				function correctSpelling(id, newWord, iQuestionId)
				{
					// Get the misspelled link word.
					var lnkElement = document.getElementById(id);
					// Check if the new word is empty.
					if ((newWord != null) && (newWord != ''))
					{
						// Update the misspelled word's inner text.
						lnkElement.innerText = newWord;
					}
					// Remove the link from the misspelled word.
					clearLink(lnkElement);
					// Hide the spelling suggestions popup.
					$('##cluetip').hide();
					// Get the sub div element.
					var spellingSuggestionsDiv = document.getElementById('divSuggestions_' + iQuestionId);
					// Get all of the hyperlinks from the main div.
					var allLinks = spellingSuggestionsDiv.getElementsByTagName('a');
					// Check if the spell check is complete.
					if ((allLinks == null) || (allLinks.length < 1))
					{
						// The spell check is not done.
						spellCheckComplete(iQuestionId, true);
					}					
				}
				function spellCheckComplete(iQuestionId, iSpellingCorrected)
				{
					// Try to hide the cluetip.
					try { $('##cluetip').hide(); } catch (e) { }
					// Get the spellcheck image element.
					var spellCheckImage = document.getElementById('imgSpellCheck_' + iQuestionId);	
					// Get the textarea element.
					var answerTextBox = document.getElementById('txtAnswer_' + iQuestionId);
					// Get the div element.
					var answerDiv = document.getElementById('divAnswer_' + iQuestionId);
					// Get the sub div element.
					var spellingSuggestionsDiv = document.getElementById('divSuggestions_' + iQuestionId);
					// Get all of the child divs.			
					var allChildDivs = spellingSuggestionsDiv.getElementsByTagName('div');
					// Remove the child divs.
					for (var index = 0; index < allChildDivs.length; index++)
					{
						// Keep looping until the element is NULL.
						while (allChildDivs[index])
						{
							// Remove the current child.
							spellingSuggestionsDiv.removeChild(allChildDivs[index]);
						}
					}
					// Check if the spell check is complete.
					if (iSpellingCorrected)
					{
						while (!spellCheckImage.src.endsWith('Images/accept.png'))
						{
							// Update the image source.
							spellCheckImage.src = 'Images/accept.png';
							// Update the tooltip text.
							spellCheckImage.title = 'Spell Check Complete';			
						}
					}
					else
					{
						while (!spellCheckImage.src.endsWith('Images/spellcheck.png'))
						{
							// Update the image source.
							spellCheckImage.src = 'Images/spellcheck.png';
							// Update the tooltip text.
							spellCheckImage.title = 'Check Spelling';		
						}
					}
					// Get the spelling suggestion's div again.
					spellingSuggestionsDiv = document.getElementById('divSuggestions_' + iQuestionId);
					// Replace a new line breaks with new line javascript feeds.
					spellingSuggestionsDiv.innerHTML = spellingSuggestionsDiv.innerHTML.replace('<br />', '\n'); 
					// Get the suggestions inner text.
					var newText = spellingSuggestionsDiv.innerText;
					// Remove the child div.
					answerDiv.removeChild(spellingSuggestionsDiv);
					// Show the text box.
					answerTextBox.style.display = '';
					// Set the textbox's value.
					answerTextBox.value = newText;			
				}
				function exitSpellChecking()
				{
					// Disable the prompt, which is issued when leaving the page.
					this.textChanged = false;
					// Get all of the image elements.
					var images = document.getElementsByTagName('img');
					// Loop through all of the images.
					for (var index = 0; index < images.length; index++)
					{
						// Check if the current image is a spellcheck image.
						if ((images[index].id.startsWith('imgSpellCheck_')) && 
						(images[index].src.endsWith('Images/resume.png')))
						{
							// Fetch the question id in the image's id.
							var questionId = images[index].id.substring(14);
							// Call the Check Spelling Method to end the spell check.
							checkSpelling(questionId);
						} 
					}
					// Return TRUE, so the POST BACK can continue.
					return (true);
				}
				function spellCheckAll()
				{
					// Block any user input.
					$.blockUI({ message: '<div style="margin-top: 15px; color: darkblue; align: center; width: 200px; height: 40px; font-family: tahoma; font-size: 10pt; font-weight: bold;"><img src="Images/busy.gif" style="margin-right: 5px;" /> Spell Checking...</div>' }); 
					// Get all of the image elements.
					var images = document.getElementsByTagName('img');
					// Loop through all of the images.
					for (var index = 0; index < images.length; index++)
					{
						// Check if the current image is a spellcheck image.
						if ((images[index].id.startsWith('imgSpellCheck_')) && 
						(images[index].src.endsWith('Images/spellcheck.png')))
						{
							// Fetch the question id in the image's id.
							var questionId = images[index].id.substring(14);
							if ((index + 1) < images.length)
							{
								$("##" + images[index].id).wait(1000,function(){
    								checkSpelling(questionId);
								}); 
							}
							else
							{
								$("##" + images[index].id).wait(1000, function(){
    								checkSpelling(questionId);
  									$.unblockUI();
								}); 
							}							
							
						} 
					}
				}
			</script>			
			<style type="text/css">

				a.dp-choose-date {
					float: left;
					width: 16px;
					height: 16px;
					padding: 0;
					margin: 3px 1px 0;
					display: block;
					text-indent: -2000px;
					overflow: hidden;
					background: url(Images/Calendar.png) no-repeat; 
				}
				a.dp-choose-date.dp-disabled {
					background-position: 0 -20px;
					cursor: default;
				}

				input.dp-applied {
					width: 122px;
					float: left;
				}
			</style>
		</head>
	<body>
		<cfinclude template="DisplayFiles/Header.cfm">
		<form id="frmEditHouseVisitEntry" name="frmEditHouseVisitEntry" method="post" action="EditHouseVisitEntry.cfm?Save=Yes&EntryId=#entryId#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#">
			<br />
</cfoutput>

<cfif lcase(save) eq "yes">
	
	<CFLDAP ACTION="query" NAME="getUserADInfo" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="sAMAccountName,Title,DisplayName" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(sAMAccountName=#SESSION.UserName#))" USERNAME="ldap" PASSWORD="paulLDAP939">		
			

	<cfset userId = getUserADInfo.sAMAccountName>
	<cfset userFullName = getUserADInfo.DisplayName>
	<cfset userRole = getUserADInfo.Title>	


	<cfset timeStamp = DateFormat(Now(), "mm/dd/yyyy") & " " & TimeFormat(Now(), "hh:mm:ss tt")>
	
	<cfset newEntryDate = DateFormat(#Evaluate("Form.txtEntryDate")#, "mm/dd/yyyy") & " 12:00:00 AM">
	
	<cfquery name="UpdateEntry" datasource="#FTAds#">
		UPDATE
			dbo.HouseVisitEntries
		SET
			dtHouseVisit = '#newEntryDate#',
			dtLastUpdate = '#timeStamp#'
		WHERE
			iEntryId = #entryId#;
	</cfquery>
	
	<cfset dsAnswers = helperObj.FetchHouseVisitAnswers(houseId)>
	<cfset dsActiveAnswers = helperObj.FetchHouseVisitEntryAnswers(dsAnswers, entryId)>
	
	<cfloop list="#Form.FieldNames#" index="fieldItem">
		<cfset splitFieldName = #ListToArray(fieldItem, "_")#>
		<cfif ArrayLen(splitFieldName) gt 1>
			<cfset questionId = #splitFieldName[2]#>
			<cfset fieldValue = #Evaluate("Form." & fieldItem)#>
			<cfset originalValue = helperObj.FetchHouseVisitEntryAnswer(dsActiveAnswers, questionId)>
		
			<!--- Check if the answers are different --->
			<cfif Trim(fieldValue) neq Trim(originalValue)>
				<!--- Delete the original value. --->
				<cfquery name="DeleteAnswer" datasource="#FTAds#">
					UPDATE
						dbo.HouseVisitAnswers
					SET 
						dtRowDeleted = '#timeStamp#',
						cRowDeletedby = '#userFullName#'
					WHERE
						iEntry = '#entryId#' AND
						iQuestion = '#questionId#' AND
						dtRowDeleted is NULL;
				</cfquery>
				<!--- Check whether or not the new value is empty and insert into the table if it's not. --->
				<cfif Trim(fieldValue) neq "">
					<cfquery name="AddAnswer" datasource="#FTAds#">
						INSERT INTO
							dbo.HouseVisitAnswers
							(
								iEntry,
								iQuestion,
								cEntryAnswer,
								dtCreated,
								cCreatedBy
							)
							VALUES
							(
								#entryId#,
								#questionId#,
								'#fieldValue#',
								'#timeStamp#',
								'#userFullName#'
							);
					</cfquery>
				</cfif>
			</cfif>	
		</cfif>
	</cfloop>
</cfif>

<cfoutput>
	<!--- Data Source (Query) Objects --->
	<cfset dsEntries = helperObj.FetchHouseVisitEntries(houseId)>
	<cfset dsAnswers = helperObj.FetchHouseVisitAnswers(houseId)>
	<cfset dsRoles = helperObj.FetchHouseVisitRoles()>
	<cfset dsQuestionRoles = helperObj.FetchHouseVisitQuestionRoles()>
	<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryById(dsEntries, entryId)>
	<cfset dsActiveAnswers = helperObj.FetchHouseVisitEntryAnswers(dsAnswers, entryId)>
	<cfset dsUserRole = helperObj.FetchHouseVisitRole(dsRoles, dsActiveEntry.iRole)>
	<cfset dsGroups = helperObj.FetchHouseVisitGroups()>
	<cfset dsQuestions = helperObj.FetchHouseVisitQuestions()>
	<!--- Stores all of the active entry info. --->
	<cfset entryDate = #DateFormat(dsActiveEntry.dtHouseVisit, "mm/dd/yyyy")#>
	<cfset userId = dsActiveEntry.cUserName>
	<cfset userFullName = dsActiveEntry.cUserDisplayName>
	<cfset userRole = helperObj.FetchHouseVisitRoleName(dsRoles, dsUserRole.iRoleId)>
	<cfset lastUpdate = DateFormat(dsActiveEntry.dtLastUpdate, "mm/dd/yyyy") & " " & TimeFormat(dsActiveEntry.dtLastUpdate, "hh:mm:ss tt")>
	<cfset created = DateFormat(dsActiveEntry.dtCreated, "mm/dd/yyyy") & " " & TimeFormat(dsActiveEntry.dtCreated, "hh:mm:ss tt")>
	
	
	<!--- THE SCRIPT BELOW IS FOR THE DATE PICKER AND TO HANDLE PAGE EXITS. --->
	<script type="text/javascript" language="javascript">
		
		// Set the Date Picker's Format 'Month/Day/Year'.  example: 04/31/2009
		Date.format = 'mm/dd/yyyy';
		// Instantiate the Date Picker object and set the minimum Date to 2008.
		$(function()
		{
			$('##txtEntryDate').datePicker().val('#entryDate#').trigger('change');
			$('##txtEntryDate').datePicker({startDate:'#DateFormat(DateAdd("d", -5, created), "mm/dd/yyyy")#', endDate: '#DateFormat(created, "mm/dd/yyyy")#'});
		});
		
		// Adds the OnBeforeUnload Event Handler, so if there are any
		// changes, the user will be prompted when he/she tries to leave.
		window.onbeforeunload = confirmExit;
		
		// Stores whether or not the Form's TextBoxes have ever been changed.
		var textChanged = false;
		
		// -------------------------------------------------------------------------------------------
		// DESCRIPTION: Runs everytime a TextBoxes onChange() Event Fires and sets the textChanged 
		//				variable to TRUE.
		// PARAMETERS:	None
		// RETURN TYPE: Void
		// -------------------------------------------------------------------------------------------
		function addUnloadPrompt(iQuestionId)
		{
			// Get the spellcheck image element.
			spellCheckImage = document.getElementById('imgSpellCheck_' + iQuestionId);
			// Update the image source, if it's not the spellcheck image.
			if (spellCheckImage.src != "Images/spellcheck.png") 
			{
				// Setup the image to the spell check state.
				spellCheckImage.src = 'Images/spellcheck.png';
				spellCheckImage.title = 'Check Spelling';
			}
			// Check if the runOnce switch has been run one time.
			if (this.textChanged == false)
			{
				// Disable the runOnce switch.
				this.textChanged = true;
			}
		}
		
		// -------------------------------------------------------------------------------------------
		// DESCRIPTION: Redirects the User to the House Visits Main Page.  The User is Prompted with
		//				a Message to determine whether or not the User wants to leave the Form/Page.
		// PARAMETERS:	None
		// RETURN TYPE: Void
		// -------------------------------------------------------------------------------------------
		function leavePage()
		{
			// Redirect the User to the main House Visits Page.
			window.location = "HouseVisits.cfm?NumberOfMonths=<cfif isDefined("url.NumberOfMonths")>#url.NumberOfMonths#<cfelse>3</cfif>&Role=<cfif isDefined("url.Role")>#url.Role#<cfelse>0</cfif>&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#";			
		}
		
		// -------------------------------------------------------------------------------------------
		// DESCRIPTION: The User is Prompted with a Message to determine whether or not the User wants 
		// 				to leave the Page, if any of the TextBoxes have been changed.
		// PARAMETERS:	None
		// RETURN TYPE: String
		// -------------------------------------------------------------------------------------------
		function confirmExit()
		{
			// Build the Redirect/Leave Confirmation Message.
			var leaveMessage = "Any changes since the last Save will be lost.";
			leaveMessage += "\nLast Save Time: " + document.getElementById("hdnLastUpdate").value;
			// Prompt the User with whether or not he/she should leave the Page and return the result.
			if (this.textChanged == true) return(leaveMessage);
		}				
	
		// -------------------------------------------------------------------------------------------
		// DESCRIPTION: Does a Form Reset to clear out any newly entered values, since the Page Load.
		// 				The User is Prompted with a Message to determine whether or not the Reset
		//				should take place.
		// PARAMETERS:	None
		// RETURN TYPE: Void
		// -------------------------------------------------------------------------------------------
		function userReset()
		{
			// Check if any of the onChange events have fired.
			if (this.textChanged == true)
			{			
				// Build the Reset Confirmation Message.
				var resetMessage = "Are you sure you want to Reset the Form? "; 
				resetMessage += " \n "; 
				resetMessage += "\nAny changes since the last Save will be lost.";
				resetMessage += "\nLast Save Time: " + document.getElementById("hdnLastUpdate").value;
				// Prompt the User with whether or not to confirm the Reset.
				if (confirm(resetMessage))
				{
					// Fire the Form's Reset() Method. 
					document.frmEditHouseVisitEntry.reset(); 
				}
			}
			else
			{
				// Fire the Form's Reset() Method. 
				document.frmEditHouseVisitEntry.reset();			
			}
		}
	</script>
	<table cellspacing="0" cellpadding="1" border="1px" width="880px">
		<tr>
			<td colspan="5" style="margin-left: 10px;" bgcolor="#freezeColor#">
				<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" align="left" id="tblHouseVisitsHeaderContainer">
					<tr>
						<td align="left" valign="top" colspan="1" width="400px">
							<table cellspacing="0" cellpadding="0" border="0" align="left" id="tblHouseVisitsHeader">
								<tr>
									<td align="left" colspan="1" style="font-family: verdana; font-weight: bold;" bgcolor="#freezeColor#" width="60px">
										<label for="txtEntryDate">
											<font size=-1>
												Date:
											</font>
										</label>
									</td>
									<td align="left" colspan="1"  bgcolor="#freezeColor#" width="150px">
										<input type="text" id="txtEntryDate" readonly="yes" name="txtEntryDate" style="text-align: left;" value="#DateFormat(entryDate, 'mm/dd/yyyy')#" />
									</td>
								</tr>
								<tr>
									<td align="left" colspan="1" style="font-family: verdana; font-weight: bold;" bgcolor="#freezeColor#" width="60px">
										<label for="txtEntryUserRole">
											<font size=-1>
												Role:
											</font>
										</label>
									</td>
									<td align="left" colspan="1"  bgcolor="#freezeColor#" width="150px">
										<input type="text" id="txtEntryUserRole" readonly="true" style="background-color: #freezeColor#; width: 140px;" value="#userRole#" />
									</td>
								</tr>
								<tr>
									<td align="left" colspan="1" style="font-family: verdana; font-weight: bold;" bgcolor="#freezeColor#" width="60px">
										<label for="txtEntryUserFullName">
											<font size=-1>
												Name:
											</font>
										</label>
									</td>
									<td align="left" colspan="1"  bgcolor="#freezeColor#" width="150px">
										<input type="text" id="txtEntryUserFullName" readonly="true" style="background-color: #freezeColor#; width: 140px;" value="#userFullName#" />
										<input type="hidden" id="hdnEntryUserId" value="#userId#" />
									</td>
								</tr>
							</table>
						</td>
						<td align="right" valign="top" colspan="1" bgcolor="#freezeColor#">
							<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0">
								<tr>
									<td width="100%" height="60%" align="right" valign="top" bgcolor="#freezeColor#">
										<a style="padding: 8px;" href="javascript: this.leavePage();">
											<font size=-1>
												Return to House Visits Page
											</font>
										</a>
									</td>
								</tr>	
								<tr>
									<td style="padding-bottom: 7px; padding-right: 8px;" width="100%" height="20%" align="right" valign="bottom" bgcolor="#freezeColor#">
										<font size=-1 color="navy">
											<strong>
												Created: 
											</strong>
											#created#
										</font>
									</td>
								</tr>									
								<tr>
									<td style="padding-bottom: 7px; padding-right: 8px;" width="100%" height="20%" align="right" valign="bottom" bgcolor="#freezeColor#">
										<font size=-1 color="navy">
											<strong>
												Last Update: 
											</strong>
											#lastUpdate#
											<input type="hidden" id="hdnLastUpdate" name="hdnLastUpdate" value="#lastUpdate#" />
										</font>
									</td>
								</tr>	
							</table>		
						</td>
					</tr>
				</table>
			</td>
		</tr>	
		<tr>
			<td colspan="5" bgcolor="#toolbarColor#" style="height: 30px;">
				<table width="100%" height="100%" border="0px" cellpadding="0" cellspacing="0">
					<tr>	
						<td align="left" width="50%" height="100%" colspan="1" bgcolor="#toolbarColor#" style="padding: 4px;">
							<input type="button" value="Return" style="width: 120px; margin-right: 22px;" onClick="leavePage();" />				
						</td>
						<td align="right" width="50%" height="100%" colspan="1" bgcolor="#toolbarColor#" style="padding: 4px;">
							<input type="button" value="Check Spelling" style="width:120px; margin-right: 10px;" onclick="spellCheckAll();"></input>							
							<input type="button" value="Reset" style="width:120px; margin-right: 10px;" onClick="userReset();"></input>
							<input type="Submit" value="Save" style="width:120px" onClick="exitSpellChecking();"></input>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<th align="middle" bgcolor="#freezeColor#" style="width: 40px;">
				<font size=-1>
					Nbr
				</font>
			</th>
			<th align="middle" bgcolor="#freezeColor#" style="width: 40px;">
				<font size=-1>
					Who
				</font>
			</th>
			<th align="middle" bgcolor="#freezeColor#" style="width: 40px;">
				<font size=-1>
					Frq
				</font>
			</th>
			<th align="middle" bgcolor="#freezeColor#" style="width: 400px;">
				<font size=-1>
					Questions
				</font>
			</th>
			<th align="middle" bgcolor="#freezeColor#" style="width: 400px;">
				<font size=-1>
					Comments/Notes
				</font>
			</th>			
		</tr>
		<cfloop query="dsGroups">
			<cfif dsUserRole.bIsSuperUser eq true>
				<cfset dsGroupQuestions = helperObj.FetchHouseVisitGroupQuestions(dsQuestions, dsGroups.iGroupId)>
			<cfelse>
				<cfset dsGroupQuestions = helperObj.FetchHouseVisitGroupQuestionsByRole(dsQuestions, dsGroups.iGroupId, dsQuestionRoles, dsUserRole.iRoleId)>
			</cfif>
			<cfif dsGroupQuestions.RecordCount gt 0>
				<tr>
					<td colspan="1" align="middle" bgcolor="#groupColor#" style="font-weight: bold; font-family: verdana;">
						<font size=2>
							#dsGroups.iSortOrder# 
						</font>
					</td>
					<td colspan="3" align="middle" bgcolor="#groupColor#" style="font-weight: bold; font-family: verdana;">
						<font size=2>
							#dsGroups.cGroupName# 
							<cfif dsGroups.iGroupCompletionTime gt 0>
								(#dsGroups.iGroupCompletionTime# min)
							</cfif>
						</font>
					</td>
					<td bgcolor="#groupColor#">
						<font size=-1>
							&##160;
						</font>
					</td>
				</tr>
			</cfif>
			<cfloop query="dsGroupQuestions">
				<tr>
					<td valign="top" colspan="1" align="middle" bgcolor="#freezeColor#" style="height: 100px;">
						<font size=-1>
							#dsGroups.iSortOrder[dsGroups.CurrentRow]#-#dsGroupQuestions.iSortOrder#
						</font>
					</td>
					<td valign="top" align="left" bgcolor="#freezeColor#" style="padding-left: 3px;">
						<font size=-1>
							#helperObj.FetchHouseVisitQuestionRoleGroupString(dsQuestionRoles, dsRoles, dsGroupQuestions.iQuestionId)#
						</font>
					</td>
					<td valign="top" align="middle" bgcolor="#freezeColor#">
						<font size=-1>
							#dsGroupQuestions.cFrequency#
						</font>
					</td>
					<td valign="top" align="left" bgcolor="#freezeColor#" valign="center" style="font-family: tahoma; font-size: 14px;">
						<table width="100%" height="100%" border="0px" cellpadding="0" cellspacing="0">
							<tr>
								<td valign="top" align="left" bgcolor="#freezeColor#">
									#dsGroupQuestions.cQuestion#
								</td>
								<td style="width: 30px;" valign="top" align="right" bgcolor="#freezeColor#">
									<img id="imgSpellCheck_#dsGroupQuestions.iQuestionId#" 
										title="Check Spelling" style="cursor: hand;" 
										onclick="checkSpelling('#dsGroupQuestions.iQuestionId#');" 
										src="Images/spellCheck.png" />
								</td>
							</tr>
						</table>
					</td>
					<td align="left" bgcolor="#freezeColor#" valign="top">
						<div id="divAnswer_#dsGroupQuestions.iQuestionId#" style="height: 100%; width: 100%;">
							
							<cfset textAreaValue = #helperObj.FetchHouseVisitEntryAnswer(dsActiveAnswers, dsGroupQuestions.iQuestionId)#>
							<cfset textAreaOutput = "<TextArea cols='54' onKeyDown='addUnloadPrompt(#dsGroupQuestions.iQuestionId#);' onChange='addUnloadPrompt(#dsGroupQuestions.iQuestionId#);' name='txtAnswer_#dsGroupQuestions.iQuestionId#' id='txtAnswer_#dsGroupQuestions.iQuestionId#' style='height: 100%; font-family: verdana; overflow-x: hidden; overflow-y: scroll;'>#textAreaValue#</TextArea>">
							
							#textAreaOutput#
						</div>
					</td>
				</tr>
			</cfloop>
		</cfloop>
		<tr>
			<td colspan="5" bgcolor="#toolbarColor#" style="height: 30px;">
				<table width="100%" height="100%" border="0px" cellpadding="0" cellspacing="0">
					<tr>	
						<td align="left" width="50%" height="100%" colspan="1" bgcolor="#toolbarColor#" style="padding: 4px;">
							<input type="button" value="Return" style="width: 120px; margin-right: 22px;" onClick="leavePage();" />				
						</td>
						<td align="right" width="50%" height="100%" colspan="1" bgcolor="#toolbarColor#" style="padding: 4px;">
							<input type="button" value="Check Spelling" style="width:120px; margin-right: 10px;" onclick="spellCheckAll();"></input>									
							<input type="button" value="Reset" style="width:120px; margin-right: 10px;" onClick="userReset();"></input>
							<input type="Submit" value="Save" style="width:120px" onClick="exitSpellChecking();"></input>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</cfoutput>		
<cfoutput>
			</form>
		</body>
	</html>
</cfoutput>