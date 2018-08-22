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
			<cfset spellCheckingActive = false>
			<cfif isDefined("url.Save")>
				<cfset save = #url.Save#>
				<cfif  mid(lcase(url.Save), 1, 10) eq "spellcheck">
					<cfset spellCheckingActive = true>
				</cfif>
			<cfelse>
				<cfset save = "No">
			</cfif>
			
			<cfinclude template="Common/DateToUse.cfm">
			<cfinclude template="ScriptFiles/FTACommonScript.cfm">
			<cfif spellCheckingActive eq true>
				<script language="javascript" type="text/javascript">
					$(function()
					{
						// Setup the cluetip.
						$('a.load-local').cluetip(
						{
							local: true, 
							width: "160px",
							hidelocal: true,
							arrows: true,
							cursor: 'default', 
					  		hoverClass: 'highlight',
  							sticky: true,
  							closePosition: 'title',
  							mouseOutClose: true,
  							activation: 'click',
  							waitImage: true,
  							open: 'slideDown',
  							showTitle: false,
  							closeText: '<img title="Close" src="Images/cross.png" alt="" />'				
						});
					});
				</script>
			</cfif>
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
					var spellingSuggestionsDiv = document.getElementById('divSuggestions_' + iQuestionId)				
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
							// Update the image.
							spellCheckImage.src = "Images/working.gif";
							// Exit out of any active spell checking
							exitSpellChecking();
							// Set textchanged to FALSE, so the prompt does NOT get displayed.
							this.textChanged = false;
							// Update the Form's Action url, so during the PostBack processing, the page knows Spell Checking is active.
							document.frmEditHouseVisitEntry.action = "EditHouseVisitEntry.cfm?Save=SpellCheck|" + iQuestionId + "&EntryId=#entryId#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#";
							// Submit the Main Form for spell checking.
							document.frmEditHouseVisitEntry.submit();
						}
					}
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
				function correctSpelling(id, nextId, newWord, iQuestionId)
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
					// Move the page to the next misspelled word.
					location.href = "##" + nextId;
					// Popup the spelling suggestions for the current misspelled word.
					$("##" + nextId).click();
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
							// Change the cursor.
							spellCheckImage.style.cursor = 'default';					
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
							// Change the cursor.
							spellCheckImage.style.cursor = 'hand';		
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
					// Exit out of any active spell checking
					exitSpellChecking();
					// Set textchanged to FALSE, so the prompt does NOT get displayed.
					this.textChanged = false;
					// Update the Form's Action url, so during the PostBack processing, the page knows Spell Checking is active.
					document.frmEditHouseVisitEntry.action = "EditHouseVisitEntry.cfm?Save=SpellCheck|*&EntryId=#entryId#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#";
					// Submit the Main Form for spell checking for every field.	
					document.frmEditHouseVisitEntry.submit();
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
<cfelseif spellCheckingActive eq true>
	<cfif mid(url.Save, 12, len(url.Save) - 11) eq "*">
		<!--- Create the array to store the text in each input field. --->
		<cfset answerValues = arrayNew(1)>
		<!--- Create an array to store each text input fields matching question id. --->
		<cfset answerQuestionIds = arrayNew(1)>
		<!--- Used to store the current array index for adding new elements to the above array. --->
		<cfset arrayIndex = 1>
		<!--- Loop through all of the Form fields that were submitted. --->
		<cfloop list="#Form.FieldNames#" index="fieldItem">
			<cfset splitFieldName = #ListToArray(fieldItem, "_")#>
			<cfif lcase(splitFieldName[1]) eq "txtAnswer">
				<cfset questionId = #splitFieldName[2]#>
				<cfset fieldValue = Form[#fieldItem#]>
				<cfif fieldValue neq "">
					<!--- Add the current field's value and question id to the arrays. --->
					<cfset answerValues[arrayIndex] = fieldValue>
					<cfset answerQuestionIds[arrayIndex] = questionId>
					<!--- Increment the Array Index counter by 1. --->
					<cfset arrayIndex = arrayIndex + 1>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfscript>
			function getTextArray(iAnswerValues)
			{
				var answerValuesText = "";
				var delim = "|";
				
				for (index = 1; index lte arrayLen(iAnswerValues); index = index + 1)
				{
					answerValuesText = answerValuesText & iAnswerValues[index];		
					if (index lt arrayLen(iAnswerValues))
					{
						answerValuesText = answerValuesText & delim;
					}					
				}
				return (dotNetWebServiceArray(answerValuesText));
			}
			function getIdArray(iAnswerQuestionIds)
			{
				var answerQuestionIdsText = "";
				var delim = "|";
				
				for (index = 1; index lte arrayLen(iAnswerQuestionIds); index = index + 1)
				{
					answerQuestionIdsText = answerQuestionIdsText & iAnswerQuestionIds[index]; 
					if (index lt arrayLen(iAnswerQuestionIds))
					{
						answerQuestionIdsText = answerQuestionIdsText & delim;
					}	
				}
				return (dotNetWebServiceArray(answerQuestionIdsText));
			}
   			function dotNetWebServiceArray(items)
   			{
   				var delim = "|";
				
				var arrayContainer=StructNew();
				
				arrayContainer.string = ListToArray(items, delim);
				
				return (arrayContainer);
			}
		</cfscript>
		<!--- Invoke the web service to get the spelling suggestions results. --->
		<cfinvoke webservice="ExcelWebService" method="GetManySpellingSuggestionsFTA" returnvariable="resultArray">
			<cfinvokeargument name="iText" value="#getTextArray(answerValues)#">
			<cfinvokeargument name="iQuestionId" value="#getIdArray(answerQuestionIds)#">
		</cfinvoke>
		<cfset spellCheckingHTML = ArrayNew(1)>
		<cfloop index="spellCheckIndex" from="0" to="#arrayLen(answerValues) - 1#">
			<cfset currentResult = resultArray.getString(spellCheckIndex)>
			<cfscript>
				spellCheckItem = structNew();
				spellCheckItem.DoesExist = true;
				spellCheckItem.QuestionId = answerQuestionIds[spellCheckIndex + 1];
				if (currentResult eq "")
				{
					spellCheckItem.HTML = answerValues[spellCheckIndex + 1];
					spellCheckItem.IsCorrect = true; 
				}
				else
				{
					divStartHTML = "<div id='divSuggestions_#spellCheckItem.QuestionId#' style='height: 100%; width: 100%; border-style: inset; border-width: 2px; padding: 1px; margin-top: 1px; font-family: verdana; font-size: 10pt; overflow-x: hidden; overflow-y: scroll; background: #spellCheckBgColor#'>";
						
					spellCheckItem.HTML = divStartHTML & currentResult & "</div>";
					spellCheckItem.IsCorrect = false; 
				}
				spellCheckingHTML[spellCheckIndex + 1] = spellCheckItem;
			</cfscript>
		</cfloop>
	<cfelse>
		<!--- Used to store the question id passed-in. --->
		<cfset splitFieldName = #ListToArray(url.Save, "|")#>
		<cfset activeQuestionId = splitFieldName[2]>
		<!--- Store the text to spell check. --->
		<cfset spellCheckText = "">
		<!--- Loop through all of the Form fields that were submitted. --->
		<cfloop list="#Form.FieldNames#" index="fieldItem">
			<cfif lcase(fieldItem) eq "txtanswer_" & activeQuestionId>
				<cfset spellCheckText = Form[fieldItem]>
				<cfbreak>
			</cfif>
		</cfloop>
		<!--- Invoke the web service to get the spelling suggestions results. --->
		<cfinvoke webservice="ExcelWebService" method="GetSpellingSuggestionsFTA" returnvariable="resultText">
			<cfinvokeargument name="iText" value="#spellCheckText#">
			<cfinvokeargument name="iQuestionId" value="#activeQuestionId#">
		</cfinvoke>
		<cfset spellCheckingHTML = ArrayNew(1)>
		<cfscript>
			spellCheckItem = structNew();
			spellCheckItem.DoesExist = true;
			spellCheckItem.QuestionId = activeQuestionId;
			if (resultText eq "")
			{
				spellCheckItem.HTML = spellCheckText;
				spellCheckItem.IsCorrect = true; 
			}
			else
			{
				divStartHTML = "<div id='divSuggestions_#spellCheckItem.QuestionId#' style='height: 100%; width: 100%; border-style: inset; border-width: 2px; padding: 1px; margin-top: 1px; font-family: verdana; font-size: 10pt; overflow-x: hidden; overflow-y: scroll; background: #spellCheckBgColor#'>";
					
				spellCheckItem.HTML = divStartHTML & resultText & "</div>";
				spellCheckItem.IsCorrect = false; 
			}
			spellCheckingHTML[1] = spellCheckItem;
		</cfscript>
	</cfif>
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
				spellCheckImage.style.cursor = 'hand';
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
		<cfif spellCheckingActive eq true>
			<script language="javascript" type="text/javascript">
				$(function()
				{
					try
					{
						location.href = "##lnk_1501";
						$("##lnk_1501").click();
					}
					catch (e)
					{
						// handle the error.
					}
				});
			</script>
		</cfif>		
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
				<cfset spellCheckCurrentItem = false>
				<cfif spellCheckingActive eq true>
					<cfset currentSpellCheckItem = helperObj.SearchSpellCheckItems(spellCheckingHTML, dsGroupQuestions.iQuestionId)>
					<cfif currentSpellCheckItem.DoesExist eq true>
						<cfset spellCheckCurrentItem = true>
					</cfif>
				</cfif>
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
									<cfset spellCheckImgSrc = "Images/spellCheck.png">
									<cfset spellCheckToolTip = "Click to Spell Check">
									<cfset spellCheckCursor = "hand">
									<cfif spellCheckCurrentItem eq true>
										<cfif currentSpellCheckItem.IsCorrect eq true>
											<cfset spellCheckImgSrc = "Images/accept.png">
											<cfset spellCheckToolTip = "Spell Check Is Complete">
											<cfset spellCheckCursor = "default">
										<cfelse>
											<cfset spellCheckImgSrc = "Images/resume.png">
											<cfset spellCheckToolTip = "Click to Finish Spell Checking">
											<cfset spellCheckCursor = "hand">
										</cfif>
									</cfif>
									<img id="imgSpellCheck_#dsGroupQuestions.iQuestionId#" 
										title="#spellCheckToolTip#" style="cursor: #spellCheckCursor#;" 
										onclick="checkSpelling('#dsGroupQuestions.iQuestionId#');" 
										src="#spellCheckImgSrc#" />
								</td>
							</tr>
						</table>
					</td>
					<td align="left" bgcolor="#freezeColor#" valign="top">
						<div id="divAnswer_#dsGroupQuestions.iQuestionId#" style="height: 100%; width: 100%;">
							<cfif spellCheckingActive eq true>
								<cfset textAreaValue = Form["txtAnswer_#dsGroupQuestions.iQuestionId#"]>
							<cfelse>
								<cfset textAreaValue = #helperObj.FetchHouseVisitEntryAnswer(dsActiveAnswers, dsGroupQuestions.iQuestionId)#>
							</cfif>
							<cfset displayTextBox = "">
							<cfif spellCheckCurrentItem eq true And currentSpellCheckItem.IsCorrect eq false>
								<cfset displayTextBox = "display: none;">
							</cfif>
							<cfset textAreaOutput = "<TextArea cols='54' onKeyDown='addUnloadPrompt(#dsGroupQuestions.iQuestionId#);' onChange='addUnloadPrompt(#dsGroupQuestions.iQuestionId#);' name='txtAnswer_#dsGroupQuestions.iQuestionId#' id='txtAnswer_#dsGroupQuestions.iQuestionId#' style='height: 100%; font-family: verdana; overflow-x: hidden; overflow-y: scroll; #displayTextBox#'>#textAreaValue#</TextArea>">
							#textAreaOutput#
							<cfif spellCheckCurrentItem eq true And currentSpellCheckItem.IsCorrect eq false>
								#currentSpellCheckItem.HTML#
							</cfif>
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