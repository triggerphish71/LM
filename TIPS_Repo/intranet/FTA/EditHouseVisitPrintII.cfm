	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
<cfset Page = "Edit House Visit">
<cfset groupColor = "cdcdcd">
<cfset freezeColor = "f5f5f5">
<cfset toolbarColor = "d6d6ab">
<cfset spellCheckBgColor = "ebebeb">
<cfparam name="rolename" default="">
 
<cfoutput>
	<!--- COLORS --->


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
				<!--- <cfset houseId = #dsHouseInfo.iHouse_ID#> --->
				<cfset HouseNumber = #trim(dsHouseInfo.EHSIFacilityID)#>
			</cfif>
			
			<cfif isDefined("url.iEntryId")>
				<cfset entryId = #url.iEntryId#>
			<cfelse>
			Lost Connection
			<cfabort>	
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
			<!--- STRING METHODS --->
			<script language="javascript" type="text/javascript">
				String.prototype.endsWith = function(str) {return (this.match(str+"$")==str)}
				String.prototype.startsWith = function(str) {return (this.match("^"+str)==str)}
			</script>
			
			<script language="Javascript">
function addRowToHFFamMem(tableid, name, maxrows, colsize, maxid){
 
	var thistableid = tableid;
	var thiscellname = name;	
	var table = document.getElementById(tableid); 
	var rowCount = table.rows.length;	 
 	var itemcount = document.getElementById(maxid).value; 
	var iteration = (itemcount*1) + 1;	
	var row = table.insertRow(rowCount);
 	 
		  // 1st cell
		 var cell0 = row.insertCell(0);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_1_' + iteration;
		 el.id = 'residentname' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell0.appendChild(el); 
	  // 2nd cell
		 var cell1 = row.insertCell(1);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_2_' + iteration;
		 el.id = 'RPName' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell1.appendChild(el);
	  // 3rd cell
		 var cell3 = row.insertCell(3);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_3_' + iteration;
		 el.id = 'RPName' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell3.appendChild(el);
// reset row count	
 		 document.getElementById(maxid).value = iteration;
 	}
	
 
function addRowToNewRes(tableid, name, maxrows, colsize, maxid){
 
	var thistableid = tableid;
	var thiscellname = name;	
	var table = document.getElementById(tableid); 
	var rowCount = table.rows.length;	 
 	var itemcount = document.getElementById(maxid).value; 
	var iteration = (itemcount*1) + 1;	
	var row = table.insertRow(rowCount);
	 
 	  // 1st cell
		 var cell0 = row.insertCell(0);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_1_' + iteration;
		 el.id = 'newresident' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell0.appendChild(el); 
 	  // 2nd cell
		 var cell1 = row.insertCell(1);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_2_' + iteration;
		 el.id = 'newresident' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell1.appendChild(el); 
// reset row count	
 		 document.getElementById(maxid).value = iteration;
 	}
 
function addRowToVacantRm(tableid, name, maxrows, colsize, maxid){
 
	var thistableid = tableid;
	var thiscellname = name;	
	var table = document.getElementById(tableid); 
	var rowCount = document.getElementById(tableid).rows.length;	
  	var itemcount = document.getElementById(maxid).value; 
	var iteration = (itemcount*1) + 1;	
	var row = table.insertRow(rowCount);

// var rowCount = document.getElementById(thistableid).getElementsByTagName("tr").length;
//  alert(tableid + " : " +  name + " : " +   maxrows + " : " +   colsize + " : " +   maxid); 	 
 	  // 1st cell
		 var cell0 = row.insertCell(0);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_1_' + iteration;
		 el.id = 'roomnbr' + iteration;
// 		 el.value = el.name;
		 el.size = colsize;
		 cell0.appendChild(el); 
// reset row count	
 		 document.getElementById(maxid).value = iteration;
 	} 
function addRowToProfRef(tableid, name, maxrows, colsize, maxid){
 
	var thistableid = tableid;
	var thiscellname = name;	
	var table = document.getElementById(tableid); 
	var rowCount = table.rows.length;	 
 	var itemcount = document.getElementById(maxid).value; 
	var iteration = (itemcount*1) + 1;	
	var row = table.insertRow(rowCount);
	 
		  // 1st cell
		 var cell0 = row.insertCell(0);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_1_' + iteration;
		 el.id = 'profreforg' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell0.appendChild(el); 
		  // 2nd cell
		 var cell1 = row.insertCell(1);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_2_' + iteration;
		 el.id = 'profrefname' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell1.appendChild(el); 	
		  // 3rd cell
		 var cell2 = row.insertCell(2);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_3_' + iteration;
		 el.id = 'profrefname' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell2.appendChild(el); 		 	 
// reset row count	
 		 document.getElementById(maxid).value = iteration;
 	}	
	
function addRowToOutOfComm(tableid, name, maxrows, colsize, maxid){
 
	var thistableid = tableid;
	var thiscellname = name;	
	var table = document.getElementById(tableid); 
	var rowCount = table.rows.length;	 
 	var itemcount = document.getElementById(maxid).value; 
	var iteration = (itemcount*1) + 1;	
	var row = table.insertRow(rowCount);
  	 
		  // 1st cell
		 var cell0 = row.insertCell(0);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_1_' + iteration;
		 el.id = 'oocommresidentfn' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell0.appendChild(el); 
		  // 2nd cell
		 var cell1 = row.insertCell(1);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_2_' + iteration;
		 el.id = 'oocommresidentln' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell1.appendChild(el); 
	  // 2nd cell
		 var cell2 = row.insertCell(2);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_3_' + iteration;
		 el.id = 'oocommlocn' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell2.appendChild(el);
 
	  // 3rd cell
		 var cell3 = row.insertCell(3);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_4_' + iteration;
		 el.id = 'oocommedprof' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell3.appendChild(el);
 
	  // 4th cell
		 var cell4 = row.insertCell(4);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_5_' + iteration;
		 el.id = 'oocommtitle' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell4.appendChild(el);
// reset row count	
 		 document.getElementById(maxid).value = iteration;		 		 
 	}		
	
function addRowToHotLeads(tableid, name, maxrows, colsize, maxid){
 
	var thistableid = tableid;
	var thiscellname = name;	
	var table = document.getElementById(tableid); 
	var rowCount = table.rows.length;	 
 	var itemcount = document.getElementById(maxid).value; 
	var iteration = (itemcount*1) + 1;	
	var row = table.insertRow(rowCount);
  	 
		  // 1st cell
		 var cell0 = row.insertCell(0);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_1_' + iteration;
		 el.id = 'hotleadfn' + iteration;
//		 el.value = el.name;
		 el.size = 35;
		 cell0.appendChild(el); 
		  // 2nd cell
		 var cell1 = row.insertCell(1);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_2_' + iteration;
		 el.id = 'hotleadln' + iteration;
//		 el.value = el.name;
		 el.size = 35;
		 cell1.appendChild(el); 
	  // 3rd cell
		 var cell2 = row.insertCell(2);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_3_' + iteration;
		 el.id = 'hotleadsstrat1' + iteration;
//		 el.value = el.name;
		 el.size = 50;
		 cell2.appendChild(el);
 
	  // 4th cell
		 var cell3 = row.insertCell(3);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_4_' + iteration;
		 el.id = 'hotleadsstrat2' + iteration;
//		 el.value = el.name;
		 el.size = 50;
		 cell3.appendChild(el);
// reset row count	
 		 document.getElementById(maxid).value = iteration;		 		 
 	}
 
function addRowToPrefProv(tableid, name, maxrows, colsize, maxid){
 
	var thistableid = tableid;
	var thiscellname = name;	
	var table = document.getElementById(tableid); 
	var rowCount = table.rows.length;	 
 	var itemcount = document.getElementById(maxid).value; 
	var iteration = (itemcount*1) + 1;	
	var row = table.insertRow(rowCount);
 	 
		  // 1st cell
		 var cell0 = row.insertCell(0);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_1_' + iteration;
		 el.id = 'hotleads' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell0.appendChild(el); 
	  // 2nd cell
		 var cell1 = row.insertCell(1);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_2_' + iteration;
		 el.id = 'hotleadsstrat1' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell1.appendChild(el);
 
	  // 3rd cell
		 var cell2 = row.insertCell(2);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_3_' + iteration;
		 el.id = 'hotleadsstrat2' + iteration;
//		 el.value = el.name;
		 el.size = 12;
		 cell2.appendChild(el);
	  // 4th cell
		 var cell3 = row.insertCell(3);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_4_' + iteration;
		 el.id = 'hotleadsstrat2' + iteration;
//		 el.value = el.name;
		 el.size = 12;
		 cell3.appendChild(el);
// reset row count		 
 		 document.getElementById(maxid).value = iteration;		 		 
 	}

function addRowToMentoring(tableid, name, maxrows, colsize, maxid){
// alert(tableid + " : " + name  + " : " +  maxrows  + " : " +  colsize  + " : " +  maxid);
	var thistableid = tableid;
	var thiscellname = name;	
	var table = document.getElementById(tableid); 
	var rowCount = table.rows.length;	 
 	var itemcount = document.getElementById(maxid).value; 
	var iteration = (itemcount*1) + 1;	
	var row = table.insertRow(rowCount);

		  // 1st cell
		 var cell0 = row.insertCell(0);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_1_' + iteration;
		 el.id = 'houseteammem' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell0.appendChild(el); 
		 
	  // 2nd cell
		 var cell1 = row.insertCell(1);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_2_' + iteration;
		 el.id = 'referalsrcname' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell1.appendChild(el);

	  // 3rd cell
		 var cell2 = row.insertCell(2);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_3_' + iteration;
		 el.id = 'refersrctitle' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell2.appendChild(el);
	
	  // 4th cell
		 var cell3 = row.insertCell(3);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_4_' + iteration;
		 el.id = 'referorg' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell3.appendChild(el);
	
	  // 5th cell
		 var cell4 = row.insertCell(4);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_5_' + iteration;
		 el.id = 'salescalleval' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell4.appendChild(el);
// reset row count	
 		 document.getElementById(maxid).value = iteration;	
 	}
 
	
function addRowEmpNoTaskSht(tableid, name, maxrows, colsize, maxid){
 
	var thistableid = tableid;
	var thiscellname = name;	
	var table = document.getElementById(tableid); 
	var rowCount = table.rows.length;	 
 	var itemcount = document.getElementById(maxid).value; 
	var iteration = (itemcount*1) + 1;	
	var row = table.insertRow(rowCount);
	 
		  // 1st cell
		 var cell0 = row.insertCell(0);
		 var el = document.createElement('input');   
		 el.type = 'text';
		 el.name = thiscellname + '_1_' + iteration;
		 el.id = 'tasksheetempname' + iteration;
//		 el.value = el.name;
		 el.size = colsize;
		 cell0.appendChild(el); 
// reset row count			 
 		 document.getElementById(maxid).value = iteration;
 	}			
function showAuditDate(){

//var MarAuditDate = document.getElementById('dtMarAuditDate');
//var mySplitResult = MarAuditDate.value.split("/");
//  alert("You entered: " + mySplitResult[1]);
// document.getElementById('dtDayOfMonth').value = mySplitResult[1];
 }
 
function calcMARErrorRate (){
var monthday = 0;
var MarAuditDate = document.getElementById('dtMarAuditDate');
var mySplitResult = MarAuditDate.value.split("/");
//    alert("You entered: " + mySplitResult[1]);
 document.getElementById('dtDayOfMonth').value = mySplitResult[1];
 if   ((document.getElementById('dtDayOfMonth').value  - 1)  == 0 )
 	{ monthday = 1  }
else {	
 	 monthday = (document.getElementById('dtDayOfMonth').value  - 1) }
	var subTotal = ((document.frmHouseVisitOpEntry.maromissions1.value - 0) + (document.frmHouseVisitOpEntry.marprn1.value - 0)  + (document.frmHouseVisitOpEntry.marcircledmeds1.value - 0));
	var subTotalA = (monthday *  (document.frmHouseVisitOpEntry.marroutineord1.value));

	var MarErrorTotal = subTotal/ subTotalA;
 //    alert( subTotal + " : " + subTotalA + " : " + monthday + " : " + MarErrorTotal);
 	if (isNaN(MarErrorTotal))
 		{ document.getElementById('marerrorrate1').value = 0;
		 alert("WARNING: MAR values are missing, please re-enter or enter 0");
		  }
 	else if (!isFinite(MarErrorTotal))
 		{ document.getElementById('marerrorrate1').value = 0;	
		 alert("WARNING: MAR values are missing, please re-enter or enter 0");	}	
 	else if (document.frmHouseVisitOpEntry.DayOfMonth.value  == 1)
 		{ document.getElementById('marerrorrate1').value = 0;	
		 alert("WARNING: Day of the month is 1 , use the last day of the month of the previous month.");	}		  	
 	else
	document.getElementById('marerrorrate1').value = 100*(Math.round(MarErrorTotal * 100)/100);		
}  

function chkScore(score){
 
 if (score.value > 11) 
 {
 	alert("Score range is 0 - 11");
	score.focus();
	}
 if (isNaN(score.value)) 
 {
 	alert("Score must be numeric and range is 0 - 11");
	score.focus();
	}
}

<cfinclude template="../global/Calendar/ts_picker2.js">

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
							// Set the image to a animated gif.
							spellCheckImage.src = "Images/working.gif";
							// Stores the parameter string of the element id's and the spell check text.
							var spellingText = answerTextBox.value;
							// Exit out of all of the active spell checking activites.
							exitSpellChecking();
							// Set the text changed switch to false, so the user is NOT prompted when the page is submitted to the server.
							this.textChanged = false;
							// Setup the Submit Action for spell checking for an single textbox.
							document.frmEditHouseVisitEntryII.action = "EditHouseVisitEntryII.cfm?Save=SpellCheck|" + iQuestionId + "&EntryId=#entryId#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#";
							// Exicute the Form's Submit() action.
							document.frmEditHouseVisitEntryII.submit();
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
					// Navigate the page to the next in-page anchor.	
					location.href = "##" + nextId;
					// Hide the spelling suggestions popup.
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
					// Exit out of all of the active spell checking activites.
					exitSpellChecking();
					// Set the text changed switch to false, so the user is NOT prompted when the page is submitted to the server.
					this.textChanged = false;
					// Setup the Submit Action for spell checking for the entire page.
					document.frmEditHouseVisitEntryII.action = "EditHouseVisitEntryII.cfm?Save=SpellCheck|*&iEntryId=#entryId#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#";
					// Exicute the Form's Submit() action.
					document.frmEditHouseVisitEntryII.submit();
				}
				function save()
				{
					// Exit out of all of the active spell checking activites.
					exitSpellChecking();
					// Set the text changed switch to false, so the user is NOT prompted when the page is submitted to the server.
					this.textChanged = false;					
					// Setup the Submit Action to Save the House Visit Data.
					document.frmEditHouseVisitEntryII.action = "EditHouseVisitEntryIISave.cfm?Save=Yes&EntryId=#entryId#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#";
					// Exicute the Form's Submit() action.
					document.frmEditHouseVisitEntryII.submit();
					// Set the text changed switch to true.
					this.textChanged = true;				
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
	</cfoutput>
	<body>
	
		<cfinclude template="DisplayFiles/Header.cfm">
	<form id="frmHouseVisitOpEntry" name="frmHouseVisitOpEntry" method="post" <cfoutput> action="HouseVisitOperations_Action.cfm?Save=Yes&EntryId=#entryId#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#"</cfoutput> />


<!--- <cfelseif spellCheckingActive eq true> --->
<cfif spellCheckingActive eq true>
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
		<cfdump var="#answerQuestionIds#">
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
				return (SmartArray(answerValuesText));
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
				return (SmartArray(answerQuestionIdsText));
			}
   			function SmartArray(lItems)
   			{
   				var delim = "|";
				var ArrayContainer=StructNew();
				ArrayContainer.string=ListToArray(lItems,delim);
				return ArrayContainer;
			}
		</cfscript>
		<!--- Invoke the web service to get the spelling suggestions results. --->
		<cfinvoke webservice="ExcelWebService" method="GetManySpellingSuggestionsFTA" returnvariable="resultArray">
			<cfinvokeargument name="iText" value="#getTextArray(answerValues)#">
			<cfinvokeargument name="iQuestionId" value="#getIdArray(answerQuestionIds)#">
		</cfinvoke>
		<cfset spellCheckingHTML = ArrayNew(1)>
		<cfloop index="spellCheckIndex" from="0" to="#arrayLen(answerValues) - 1#">
			<cfset currentResult = resultArray.getString(JavaCast("int", #spellCheckIndex#))>
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
<!--- ***************************** REGULAR DISPLAY STARTS HERE **************************************************** --->		
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
	<cfset dsQuestions = helperObj.FetchHouseVisitDataII(entryId)>
	<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryByIdII(entryId)> 
	<cfset dsRole = helperObj.FetchHouseVisitRoleII(dsQuestions.iRole)>
<!--- <cfdump var="#dsRole#"> --->
	<cfset roleName = dsRole.cRoleName>
	<cfset dsGroups = helperObj.FetchHouseVisitGroupsII(rolename)>
	<cfset dsQuestionRoles = helperObj.FetchHouseVisitQuestionRoles()>
 
	<!--- Stores all of the active entry info. --->
	<cfset entryDate = #DateFormat(dsActiveEntry.dtHouseVisit, "mm/dd/yyyy")#>
	<cfset userId = dsActiveEntry.cUserName>
	<cfset userFullName = dsActiveEntry.cUserDisplayName>
	

	<cfset lastUpdate = DateFormat(dsActiveEntry.dtLastUpdate, "mm/dd/yyyy") & " " & TimeFormat(dsActiveEntry.dtLastUpdate, "hh:mm:ss tt")>
	<cfset created = DateFormat(dsActiveEntry.dtCreated, "mm/dd/yyyy") & " " & TimeFormat(dsActiveEntry.dtCreated, "hh:mm:ss tt")>
				<input type="hidden"  name="EntryUserId" 		id="hdnEntryUserId" 		value="#url.iEntryUserId#" />
				<input type="hidden"  name="EntryuserRole" 		id="hdnEntryuserRole" 		value="#EntryuserRole#" />
				<input type="hidden"  name="EntryuserFullName" 	id="hdnEntryuserFullName" 	value="#url.EntryuserFullName#" />
				<input type="hidden"  name="hdnrolename" 		id="hdnrolename" 			value="#url.hdnrolename#" />
				<input type="hidden"  name="userRoleID" 		id="hdnuserRoleID" 			value="#url.userRoleID#" /> 
				<input type="hidden"  name="NumberOfMonths" 	id="hdnNumberOfMonths" 		value="#url.NumberOfMonths#" />
				<input type="hidden"  name="DateToUse" 			id="hdnDateToUse" 			value="#url.DateToUse#" />
				<input type="hidden"  name="role" 				id="hdnrole" 				value="#url.role#" /> 
	<!--- THE SCRIPT BELOW IS FOR THE DATE PICKER AND TO HANDLE PAGE EXITS. --->

	<table id="tblEditEntry" cellspacing="0" cellpadding="1" border="1px"  >
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
										<input type="text" id="txtEntryUserRole" readonly="true" name="rolefilter" style="background-color: #freezeColor#; width: 140px;" value="#roleName#" />
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
										<!--- <input type="hidden" id="hdnEntryUserId" value="#userId#" />  --->
									</td>
								</tr>
							</table>
						</td>
						<td align="right" valign="top" colspan="1" bgcolor="#freezeColor#">
							<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0">
								<tr>
									<td width="100%" height="60%" align="right" valign="top" bgcolor="#freezeColor#">
										<a style="padding: 8px;" href="HouseVisitsII.cfm?iHouse_ID=#url.iHouse_ID#&userRoleId=#userRoleId#&IENTRYUSERID=#iEntryUserId#&EntryuserFullName=#EntryuserFullName#&EntryuserRole=#EntryuserRole#&subAccount=#subAccount#&NumberOfMonths=#NumberOfMonths#&DateToUse=#DateToUse#&role=#url.role#">
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
							<!--- <input type="button" value="Return" style="width: 120px; margin-right: 22px;" onClick="leavePage();" />	 --->			
						</td>
						<td align="right" width="50%" height="100%" colspan="1" bgcolor="#toolbarColor#" style="padding: 4px;">
							<!--- <input type="button" value="Check Spelling" style="width:120px; margin-right: 10px;" onClick="spellCheckAll();"></input> --->							
							<!--- <input type="button" value="Reset" style="width:120px; margin-right: 10px;" onClick="userReset();"></input> --->
							<input type="submit" value="Save" style="width:120px"  type=" "></input>
						</td>
					</tr>
				</table>
			</td>
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
				<cfloop query="dsGroups" >
					<cfset thisgroup = dsGroups.iGroupId>
					<cfset maxrep = #dsGroups.indexmax#> 
					<cfset indexname  = #Trim("dsGroups.indexname")# >
					<tr>
						<td  >
						<table  id="#trim(dsGroups.cGroupName)#"      >
					<tr><td> <input type="hidden" name="#trim(indexname)#" value="#maxrep#" id="id#Trim(dsGroups.indexname)#"></td></tr>
						
							<tr style=" background-color: #groupcolor#;">
								<th colspan="5" style="text-align:left"; font-weight:"100":  width="800px";> #dsGroups.iGroupId#. #dsGroups.cTextHeader#</th>
							</tr>
							<cfset dsGroupQuestionsHdr = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
							<tr>
								<cfloop query="dsGroupQuestionsHdr">
									<th style="text-align:left"  >#dsGroupQuestionsHdr.cQuestion#</th>
								</cfloop>					
							</tr>
								<cfif dsGroups.AddRows is "Y">
								<TR>
									<td colspan="5" ><input type="button" value="Add Row" onClick="#Trim(dsGroups.addrowname)#('#trim(dsGroups.cGroupName)#', 'txtanswer_#thisgroup#',#maxrep#,#dsGroupQuestionsHdr.cColSize#, 'id#Trim(dsGroups.indexname)#');" /></td>
								</TR>
								</cfif>
								<cfif dsGroups.IGROUPID is 18 >
									<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
									<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(#entryiD#, #thisgroup#, #dsGroupQuestions.iQuestionId#, #i#)>
									<TR>
										<td colspan="5"><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# --->
											<textarea name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" rows="#dsGroupQuestions.cRowSize#" cols="#dsGroupQuestions.cColSize#">#dsActiveEntry# </textarea>
										</td>	
									</TR>
								<cfelseif dsGroups.IGROUPID is 1>
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
										<tr  style=" background-color: ##ffffff;" >
											<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
											<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(#entryiD#, #thisgroup#, #dsGroupQuestions.iQuestionId#, #i#)>
											<cfloop query="dsGroupQuestions">
												 <cfif dsGroupQuestions.dropdown is not "">
													<cfset dshouseposition = helperObj.qryHousePosition()>
													<td><select name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" >
														<option value="#dsActiveEntry#">#dsActiveEntry#</option>
														<cfloop query="dshouseposition" >
															<option value="#cHousePosition#">#cHousePosition#</option>
														</cfloop>
														</select>
													</td>
												<cfelse>
														<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(#entryiD#, #thisgroup#, #dsGroupQuestions.iQuestionId#, #i#)>
														<td style="text-align:left" title="#dsGroupQuestions.cQuestion#" ><input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="#dsActiveEntry#" size="#dsGroupQuestions.cColSize#"  onBlur="#trim(dsGroupQuestions.cOnChange)#"   style="text-align:left"; /></td>
												</cfif>
											</cfloop>
										</tr>
									</cfloop>
								<cfELSEif dsGroups.IGROUPID is 5>
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
										<tr  style=" background-color: ##ffffff;" >
											<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
											<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(#entryiD#, #thisgroup#, #dsGroupQuestions.iQuestionId#, #i#)>

												<cfloop query="dsGroupQuestions">
												 <cfif dsGroupQuestions.dropdown is not "">
								 					<cfset dshouseTitle = helperObj.qryHouseTitle()>
													<td><select name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" >
														<option value="#dsActiveEntry#" >#dsActiveEntry#</option>
														<cfloop query="dshouseTitle" >
															<option value="#cHousetitle#">#cHousetitle#</option>
														</cfloop>
														</select>
													</td>
												
													<cfelse>
													<td style="text-align:left" title="#dsGroupQuestions.cQuestion#" ><input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="" size="#dsGroupQuestions.cColSize#"  onBlur="#trim(dsGroupQuestions.cOnChange)#"   style="text-align:left"; /></td>
													</cfif>
												</cfloop>
											 
										</tr>
									</cfloop>
								<cfelseif  dsGroups.IGROUPID is 7>
									<cfset i = 1>
									<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
									<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(#entryiD#, #thisgroup#, #dsGroupQuestions.iQuestionId#, #i#)>
 
									<TR> 
										<td colspan="5" style="text-align:left"> 
 										<cfif #trim(dsActiveEntry)# is "Y">	YES	
											<input  type="radio"  	name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="Y" size="#dsGroupQuestions.cColSize#"  checked="checked"   style="text-align:left"; />YES<br/> 									
											<input  type="radio" 	name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="N" size="#dsGroupQuestions.cColSize#"    style="text-align:left"; />No
										<cfelseif #trim(dsActiveEntry)# is "N">NO
											<input  type="radio"  	name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="Y" size="#dsGroupQuestions.cColSize#"     style="text-align:left"; />YES<br/> 									
											<input  type="radio" 	name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="N" size="#dsGroupQuestions.cColSize#"  checked="checked"    style="text-align:left"; />No
										<cfelse>
											<input  type="radio"  	name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="Y" size="#dsGroupQuestions.cColSize#"     style="text-align:left"; />YES<br/> 									
											<input  type="radio" 	name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="N" size="#dsGroupQuestions.cColSize#"     style="text-align:left"; />No
										
										</cfif>
										</td>										
									</TR>		
								<cfELSEif dsGroups.IGROUPID is 16>
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
										<tr  style=" background-color: ##ffffff;" >
											<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
											<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(#entryiD#, #thisgroup#, #dsGroupQuestions.iQuestionId#, #i#)>

												<cfloop query="dsGroupQuestions">
												<cfif dsGroupQuestions.dropdown is not "">
								 					<cfset dshouseTask = helperObj.qryHouseTask()>
													<td><select name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" >
														<option value="#dsActiveEntry#">#dsActiveEntry#</option>
														<cfloop query="dshouseTask" >
															<option value="#ctasksheetdayrange#">#ctasksheetdayrange#</option>
														</cfloop>
														</select>
													</td>
												<cfelse>
														<td style="text-align:left" title="#dsGroupQuestions.cQuestion#" ><input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="" size="#dsGroupQuestions.cColSize#"  onBlur="#trim(dsGroupQuestions.cOnChange)#"   style="text-align:left"; /></td>
												</cfif>
												</cfloop>
										</tr>
									</cfloop>														 
								<cfELSEif dsGroups.IGROUPID is 6>
									<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
									<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(#entryiD#, #thisgroup#, #dsGroupQuestions.iQuestionId#, #i#)>


									<TR>
										<td style="text-align:left"><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# --->
											<textarea name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" rows="#dsGroupQuestions.cRowSize#" cols="#dsGroupQuestions.cColSize#">#dsActiveEntry# </textarea>
										</td>	
									</TR>
									</cfloop>
								<cfelse>
								<cfset indexname  = #Trim("dsGroups.indexname")# >
								<cfset i = 0>
								<input type="hidden" name="#trim(indexname)#" value="#maxrep#" id="id#Trim(dsGroups.indexname)#">
								<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
									<cfset i = i + 1>
									<tr  style=" background-color: ##ffffff;" >
										<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
<!--- 										<cfif dsGroupQuestions.cRowSize is not "">
										<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(entryiD, thisgroup, dsGroupQuestions.iQuestionId, i)>
											<td  colspan="5" style="text-align:left"><textarea name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" rows="#dsGroupQuestions.cRowSize#" cols="#dsGroupQuestions.cColSize#">#dsActiveEntry# </textarea></td>		 
										
										<cfelseif dsGroupQuestions.cColSize is 1>
											<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(entryID, thisgroup, dsGroupQuestions.iQuestionId, i)>
											<td style="text-align:left">#dsGroupQuestions.cQuestion#  #dsActiveEntry#
												<cfif dsActiveEntry is "Y">	YES	<cfelseif dsActiveEntry is "N">NO</cfif>
												<select  name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#"   size="2">
													<option value="Y"   >YES</option>
													<option value="N">N0</option>
												</select>		
											</td> --->														
										
										<cfif dsGroupQuestions.cIncludeDate is "Y">
										<!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# --->
											<cfset dsActiveEntry = dateformat(helperObj.FetchHouseVisitEntryAnswersII(entryID, thisgroup, dsGroupQuestions.iQuestionId, i),"mm/dd/yyyy")>
											<td >
											#dsActiveEntry#
													<input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="dtMarAuditDate" value="#DateFormat(Now(), 'mm/dd/yyyy')#" onBlur="showAuditDate()" >
													<a onClick="show_calendar2('document.frmHouseVisitOpEntry.dtMarAuditDate',document.getElementById('dtMarAuditDate').value,'dtMarAuditDate');"> 
													<img src="../global/Calendar/calendar.gif" alt="Calendar" width="20" height="20" border="0" align="middle" style="" id="Cal" name="Cal"></a>
													<input type="hidden" name="DayOfMonth" id="dtDayOfMonth" value=""> 
											</td>
										<cfelse>
											<cfloop query="dsGroupQuestions">
											<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(entryID, thisgroup, dsGroupQuestions.iQuestionId, i)>
												<!---  <td style="text-align:left">#thisgroup# #dsGroupQuestions.iQuestionId# #i# #dsGroupQuestions.cQuestion#<input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="" size="#dsGroupQuestions.cColSize#"  onChange="#trim(dsGroupQuestions.cOnChange)#"  style="text-align:left"; /></td> --->
												<td ><input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="#dsActiveEntry#" size="#dsGroupQuestions.cColSize#"  onChange="#trim(dsGroupQuestions.cOnChange)#" <cfif dsGroupQuestions.readonly is "Y">readonly="readonly" </cfif>   style="text-align:left"; />   #dsGroupQuestions.posttitle#</td>
											</cfloop>
										</cfif>
									</tr>
								</cfloop>
								</cfif>
						</table>
					</td>
				</tr>			
			</cfloop>
		 
		<tr>
			<td colspan="5" bgcolor="#toolbarColor#" style="height: 30px;">
				<table width="100%" height="100%" border="0px" cellpadding="0" cellspacing="0">
					<tr>	
						<td align="left" width="50%" height="100%" colspan="1" bgcolor="#toolbarColor#" style="padding: 4px;">
							<!--- <input type="button" value="Return" style="width: 120px; margin-right: 22px;" onClick="leavePage();" />	 --->			
						</td>
						<td align="right" width="50%" height="100%" colspan="1" bgcolor="#toolbarColor#" style="padding: 4px;">
							<!--- <input type="button" value="Check Spelling" style="width:120px; margin-right: 10px;" onClick="spellCheckAll();"></input> --->									
							<!--- <input type="button" value="Reset" style="width:120px; margin-right: 10px;" onClick="userReset();"></input> --->
							<input type="submit" value="Save" style="width:120px" ></input>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</cfoutput>		
 
			</form>
		</body>
	</html>
 