<!----------------------------------------------------------------------------------------------
| DESCRIPTION: Main screen - Collection  Letters Generator                                     |
|----------------------------------------------------------------------------------------------|
| dsp_Main.cfm                                                                                 |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by: 													                               |
| Calls/Submits:	                                                                           |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|MLAW        | 09/20/2002 | Original Authorship                                                |
----------------------------------------------------------------------------------------------->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Collection Letters Generator</title>
<style type="text/css">
<!--
.style1 {
	color: #FF0000;
	font-size: 10px;
	font-family: Arial, Helvetica, sans-serif;
}
-->
</style>

<style type="text/css">

#hintbox{ /*CSS for pop up hint box */
position:absolute;
top: 0;
background-color: lightyellow;
width: 150px; /*Default width of hint.*/ 
padding: 3px;
border:1px solid black;
font:normal 11px Verdana;
line-height:18px;
z-index:100;
border-right: 3px solid black;
border-bottom: 3px solid black;
visibility: hidden;
}

.hintanchor{ /*CSS for link that shows hint onmouseover*/
font-weight: bold;
color: navy;
margin: 3px 8px;
}

body,td,th {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12px;
}
</style>

<script type="text/javascript">

/***********************************************
* Show Hint script- © Dynamic Drive (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit http://www.dynamicdrive.com/ for this script and 100s more.
***********************************************/
		
var horizontal_offset="9px" //horizontal offset of hint box from anchor link

/////No further editting needed

var vertical_offset="0" //horizontal offset of hint box from anchor link. No need to change.
var ie=document.all
var ns6=document.getElementById&&!document.all

function getposOffset(what, offsettype){
var totaloffset=(offsettype=="left")? what.offsetLeft : what.offsetTop;
var parentEl=what.offsetParent;
while (parentEl!=null){
totaloffset=(offsettype=="left")? totaloffset+parentEl.offsetLeft : totaloffset+parentEl.offsetTop;
parentEl=parentEl.offsetParent;
}
return totaloffset;
}

function iecompattest(){
return (document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body
}

function clearbrowseredge(obj, whichedge){
var edgeoffset=(whichedge=="rightedge")? parseInt(horizontal_offset)*-1 : parseInt(vertical_offset)*-1
if (whichedge=="rightedge"){
var windowedge=ie && !window.opera? iecompattest().scrollLeft+iecompattest().clientWidth-30 : window.pageXOffset+window.innerWidth-40
dropmenuobj.contentmeasure=dropmenuobj.offsetWidth
if (windowedge-dropmenuobj.x < dropmenuobj.contentmeasure)
edgeoffset=dropmenuobj.contentmeasure+obj.offsetWidth+parseInt(horizontal_offset)
}
else{
var windowedge=ie && !window.opera? iecompattest().scrollTop+iecompattest().clientHeight-15 : window.pageYOffset+window.innerHeight-18
dropmenuobj.contentmeasure=dropmenuobj.offsetHeight
if (windowedge-dropmenuobj.y < dropmenuobj.contentmeasure)
edgeoffset=dropmenuobj.contentmeasure-obj.offsetHeight
}
return edgeoffset
}

function showhint(menucontents, obj, e, tipwidth){
if ((ie||ns6) && document.getElementById("hintbox")){
dropmenuobj=document.getElementById("hintbox")
dropmenuobj.innerHTML=menucontents
dropmenuobj.style.left=dropmenuobj.style.top=-500
if (tipwidth!=""){
dropmenuobj.widthobj=dropmenuobj.style
dropmenuobj.widthobj.width=tipwidth
}
dropmenuobj.x=getposOffset(obj, "left")
dropmenuobj.y=getposOffset(obj, "top")
dropmenuobj.style.left=dropmenuobj.x-clearbrowseredge(obj, "rightedge")+obj.offsetWidth+"px"
dropmenuobj.style.top=dropmenuobj.y-clearbrowseredge(obj, "bottomedge")+"px"
dropmenuobj.style.visibility="visible"
obj.onmouseout=hidetip
}
}

function hidetip(e){
dropmenuobj.style.visibility="hidden"
dropmenuobj.style.left="-500px"
}

function createhintbox(){
var divblock=document.createElement("div")
divblock.setAttribute("id", "hintbox")
document.body.appendChild(divblock)
}

if (window.addEventListener)
window.addEventListener("load", createhintbox, false)
else if (window.attachEvent)
window.attachEvent("onload", createhintbox)
else if (document.getElementById)
window.onload=createhintbox

</script>

<script language="JavaScript" type="text/javascript">
function validateFields() {
    if (document.lettersform.Period.value == "") {
        alert('Please enter Accounting Period');
        return false;
    }
return true;
}

function validateDistributionList() {
    if (document.FTPform.ToMail.value == "" || document.FTPform.CCMail.value == "") {
        alert('Please enter Distribution List');
        return false;
    }
return true;
}
</script>


</head>

<body>
<!--- Define Variables --->
<cfset fileDirectory = "\\FS01\AR\Collections\Collectionletters\Pending\History">
<cfset fileLettersDetails = "lettersdetails.xls">
<cfset fileLettersDetailsCSV = "lettersdetails.csv">

<cfset TotalLetters = 0>
<cfset house = ''>

<cfset Amounts = 0>
<cfset TotalAmounts = 0>

<!---
<cfset tomailList = "ameyerhofer@Primadatainc.com;lpoole@Primadatainc.com">
<cfset ccmailList = "bleonard@specresources.biz;wlevonowich@alcco.com;tbates@alcco.com;mlaw@alcco.com"> 
--->
<cfset subject = "ALC Collection Letters">
<cfset tomailList = "tbates@alcco.com; WLevonowich@ALCCO.COM; ameyerhofer@Primadatainc.com; lbova@Primadatainc.com; bleonard@specresources.biz; data@primadatainc.com">
<cfset ccmailList = "#session.developerEmailList#;kdobyns@ALCCO.COM">

<!--- Get Houses Information for the Drop Down --->
<cfquery name="GetHouses" datasource="#application.datasource#">
	select 
		cname
	from 
		House 
	where 
		dtrowdeleted is  null
	and 
		bIsSandbox = 0
	order by 
		cname 
</cfquery>
<center>
<img src="../images/ALC%20Logo.jpg" align="top">
</center>
<!--- Send Form Information --->
<form  name="lettersform" action="act_GenerateCollection.cfm" method="post" onSubmit="return validateFields();">
<table width="34%" height="22%" border="1" cellpadding="1" cellspacing="1" bordercolor="gray" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0" style="border-collapse: collapse">
	<tr>
    	<th height="40" colspan="2"><b><font face="Arial">
			Collection Letters Generator</font></b>
		</th>
  	</tr>
  	<tr>
    	<td width="45%" height="32" nowrap><font face="Arial" size="2" color="#0000FF">
    		<b>Scope</b></font>
		</td>
    	<td width="55%" height="32">
			<select name ="Scope">
				<option value="0" selected>All Houses</option>
				<option value="1">West Division</option>
				<option value="11">Pacific</option>
				<option value="14">Greenway</option>
				<option value="17">Northwest</option>
				<option value="2">Central Division</option>
				<option value="22">Central Texas</option>
				<option value="23">West Texas</option>
				<option value="24">Texas/Louisana</option>
				<option value="26">Northern Indiana</option>
				<option value="4">MWA Division</option>
				<option value="41">Ohio</option>
				<option value="43">Western Pennsylvania/Ohio</option>
				<option value="44">South Carolina/New Jersey</option>
				<option value="45">Midwest</option>	
				<option value="6">Heartland</option>	
				<option value="65">Tri-State</option>	
				<option value="68">Gateway</option>
				<option value="67">Southern Indiana/Kentucky</option>
				<cfloop query="GetHouses">
					<cfoutput>
						<option value="#GetHouses.cName#">#GetHouses.cName#</option>
					</cfoutput>
				</cfloop>
			</select><a href="#" class="hintanchor" onMouseover="showhint('Please select Scope (e.g. Tri-State).', this, event, '150px')">[?]</a>
		</td>
  	</tr>
  	<tr>
    	<td width="45%" height="33" nowrap><font face="Arial" size="2" color="#0000FF">
			<b>Accounting Period</b></font>
		</td>
	  <td width="55%" height="33">
			<input name="Period" type="text" size="6" maxlength="6"><a href="#" class="hintanchor" onMouseover="showhint('Please enter Accounting Period (e.g. 200709).', this, event, '150px')">[?]</a>
	  </td>
  	</tr>
  	<tr>
    	<td width="45%" height="32" nowrap><font face="Arial" size="2" color="#0000FF">
    		<b>Collection Letter for</b></font>
		</td>
    	<td width="55%" height="32" bgcolor="#FFFFFF">
			<select name ="LetterType">
              <option value="1">Letter 1 </option>
              <option value="2">Letter 2</option>
              <option value="3">Letter 3</option>
            </select><a href="#" class="hintanchor" onMouseover="showhint('Please select Letter 1 or 2 or 3 List.', this, event, '150px')">[?]</a> 
		</td>
  	</tr>
	<tr>
		<td width="65%" height="32" nowrap><font face="Arial" size="2" color="#0000FF">
    		<b>Exclude Deferred Payment Residents?&nbsp;&nbsp;</b></font>
		</td>
		<td>
			<input type= "CheckBox" name= "cboDeferredPayment" Value = "1">
		</td>
	</tr>
  	<tr>
    	<td height="36" colspan="2"><font size="1" color="#FF0000">
      		<div align="center">
				<input name="run" type="submit" value="Submit">        
				<input type="reset" name="Reset" value="Reset">
   		  </div>
		</td>
	</tr>
</table>
</form>

<cfdirectory directory="#fileDirectory#\" action="list" name="qLettersDetails" filter="#fileLettersDetails#">
<CFIF qLettersDetails.RecordCount GT 0> 
	<cfoutput>
		<cfdirectory directory="#fileDirectory#\" action="list" name="qLettersDetails" filter="#fileLettersDetailsCSV#">
		<CFIF qLettersDetails.RecordCount GT 0>
			<cffile action="read" file="#fileDirectory#\#fileLettersDetailsCSV#" variable="csvFile">
			<cfloop index="index" list="#csvfile#" delimiters="#chr(10)##chr(13)#"> 
				<cfif #listgetAt('#index#',1)# neq 'AccountNumber'>	
					<cfset TotalLetters = #TotalLetters# + 1>
					<cfset Amounts = #listgetAt('#index#',2)# + #Amounts#>
				    <cfset Type = #listgetAt('#index#',3)#>
				</cfif>
			</cfloop>		
		</CFIF>
	</cfoutput>
	<br>	
	<table border="1" cellpadding="1" cellspacing="1" style="border-collapse: collapse" bordercolor="gray" width="22%">
		<tr>
			<th width="100%"><strong>View existing data files</strong> <a href="#" class="hintanchor" onMouseover="showhint('You can view the Collection Letters files before you FTP to Spectrum.', this, event, '150px')">[?]</a></th>
		</tr>
		<tr>
			<td width="100%">
				<cfoutput>
				<a href="#fileDirectory#\#fileLettersDetails#" target="_blank">Letters</a>
				</cfoutput>
			</td>
		</tr>
	</table>

	<cfoutput>
		<br>
	 <form name="FTPform" action="act_FTP.cfm" method="post" onSubmit="return validateDistributionList();">
			<table border="1" cellpadding="1" cellspacing="1" style="border-collapse: collapse" bordercolor="gray" width="25%">
				<tr>
					<td width="27%" nowrap><strong>
						Letter
					</strong></td>
					<td width="73%" nowrap>
						<input name="Type" type="text" value="<cfif isDefined("type")>#type#</cfif>"" size="9" maxlength="8" readonly="true"> 
					</td>
				</tr>
				<tr>
					<td width="27%" nowrap><strong>
						Total Letters:
					</strong></td>
					<td width="73%" nowrap>
						<input name="TotalLetters" type="text" value="#TotalLetters#" size="9" maxlength="8" readonly="true"> 
					</td>
				</tr>
				<tr>
					<td width="27%" nowrap><strong>
						Total Amounts:
					</strong></td>
					<td width="73%" nowrap>
						<input name="Amounts" type="text" value="#Amounts#" size="30" maxlength="30" readonly="true"> 
					</td>
				</tr>
			</table>
  		</cfoutput>
		<br>        
		<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="gray" width="14%">
			<tr>
				<td width="100%" colspan="2">
					<strong>Distribution List: <a href="#" class="hintanchor" onMouseover="showhint('You can edit the distrubution list (use ; to seperate the list)', this, event, '150px')">[?]</a>
					</strong>
				</td>
			</tr>
			<cfoutput>	
			<tr>
				<td width="10%">Subject:</td>
				<td width="90%">
					<input name="EmailSubject" type="text" value="#subject#" size="50" maxlength="200"> 
				</td>
			</tr>
			<tr>
				<td width="10%">To:</td>
				<td width="90%">
					<input name="ToMail" type="text" value="#tomailList#" size="50" maxlength="200"> 
				</td>
			</tr>
			<tr>
				<td width="10%">CC:</td>
				<td width="90%">
					<input name="CCMail" type="text" value="#ccmailList#" size="50" maxlength="200">
				</td>
			</tr>
			</cfoutput>
			<tr>
				<td width="100%" colspan="2">
					<strong>FTP to Spectrum  <a href="#" class="hintanchor" onMouseover="showhint('If the data files are ready to send, click Go to FTP to Spectrum.', this, event, '150px')">[?]</a>
					<input type="submit" name="run" value="Go">
					</strong>
				</td>
			</tr>
		</table>
		</form>	
		<br>
		<form action="act_DeleteCollection.cfm" method="post">
		<table width="34%" height="10%" border="0" cellspacing="1" bordercolor="#111111" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0" style="border-collapse: collapse">
			<tr>
				<td height="37" colspan="2" nowrap><b><font face="Arial">Delete generated data files</font></b><a href="#" class="hintanchor" onMouseover="showhint('If you make a mistake and want to re-generate all collection letters, please delete the existing data and start over.', this, event, '150px')">[?]</a>
			  <input name="run" type="submit" class="style1" value="Delete"></td>
			</tr>
		  </table>
		</form>
</CFIF>

	<p>
	<a href="dsp_Menu.cfm">
		Back
	</a>
</body>
</html>
