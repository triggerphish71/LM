<!----------------------------------------------------------------------------------------------
| DESCRIPTION: action screen - Generate collection letters                                     |
|----------------------------------------------------------------------------------------------|
| act_GenerateCollection.cfm                                                                   |
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
|MLAW        | 11/02/2007 | add dummy record at the end of the file                            |
| rschuette	 | 08/04/2009 | Prj 36359 - Deferred Payment adds                                  |
----------------------------------------------------------------------------------------------->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Generate Collection</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

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

<center>
<img src="../images/ALC%20Logo.jpg" align="top">
</center>

<p><strong>Letters Generated
</strong></p>

<cfset fileDirectory = "\\FS01\AR\Collections\Collectionletters\Pending\History">
<cfset fileLettersDetails = "lettersdetails.xls">
<cfset fileLettersDetailsCSV = "lettersdetails.csv">

<cfset TotalLetters = 0>
<cfset house = ''>

<cfset Amounts = 0>
<cfset TotalAmounts = 0>

<cfset LineCount = 0>

<cfset TempHouseName = ''>
<cfset TempHouseAddress1 = ''>
<cfset TempHouseAddress2 = ''>
<cfset TempHousePhone = ''>			
<cfset TempDate= ''>
<cfset TempARContact = ''>
<cfset TempARPhone = ''>
<cfset TempType = ''>

<!---
<cfset tomailList = "ameyerhofer@Primadatainc.com;lpoole@Primadatainc.com">
<cfset ccmailList = "bleonard@specresources.biz;wlevonowich@alcco.com;tbates@alcco.com;mlaw@alcco.com"> 
--->
<cfset subject = "ALC Collection Letters">
<cfset tomailList = "tbates@alcco.com; WLevonowich@ALCCO.COM; ameyerhofer@Primadatainc.com; lbova@Primadatainc.com; bleonard@specresources.biz; data@primadatainc.com">
<cfset ccmailList = "#session.developerEmailList#;kdobyns@ALCCO.COM">
	
<!---
<cfsetting enablecfoutputonly="yes">--->

<cfoutput>
	<cfif #form.LetterType# eq 3>
		<cfset thirdletter = 1>
	<cfelse>
		<cfset thirdletter = 0>
	</cfif>
	
	<!--- Project 36359 - rts - 7-31-2009  Deferred Payment option --->
	 <cfif isdefined("form.cboDeferredPayment") and form.cboDeferredPayment neq ''> 
		 <cfif "#form.cboDeferredPayment#" eq 1>		
				<cfset Deferred = "YES">
		 <cfelse>
				<cfset Deferred = "NO">
		</cfif>
	<cfelse>
				<cfset Deferred = "NO">
	</cfif> 
	<!--- End 36359 --->
<CFTRY>
	<CFSTOREDPROC PROCEDURE="rw.sp_CollectionRegister" DATASOURCE="#APPLICATION.datasource#" returncode="yes">
		<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_VARCHAR"  DBVARNAME="@Scope" VALUE="#form.Scope#" >
		<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_CHAR"  DBVARNAME="@Period" VALUE="#form.Period#" null="no" >	
		<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_CHAR"  DBVARNAME="@Stage" VALUE="#form.LetterType#" null="no" >	
		<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_CHAR"  DBVARNAME="@thirdletter" VALUE="#thirdletter#" null="no" >
		<!--- Project 36359 - rts - 7-31-2009  Deferred Payment option --->
		<CFPROCPARAM TYPE="In" cfsqltype="CF_SQL_BIT"  DBVARNAME="@Deferred" VALUE="#Deferred#" null="no" >
		<!--- End 36359 --->	
		<CFPROCRESULT name="rs1" resultset="1">
	</CFSTOREDPROC>
	
	<CFCATCH TYPE="Any">
		<CFMAIL TYPE ="HTML" FROM="TIPS4-Message@alcco.com" TO="#session.developeremaillist#" SUBJECT="STOREDPROC STATUS CODE ERROR - Collection Letters Generator">

		</CFMAIL>	
	</CFCATCH>
</CFTRY>
<!--- set vars for special characters --->
<cfset TabChar = Chr(9)>
<cfset NewLine = Chr(13) & Chr(10)>
<!--- proj 36359 - rts 8-04-2009 DeferredPayment--->
<!--- set content type to invoke Excel 
<cfcontent type="application/msexcel">
<cfheader name="Content-Disposition" value="filename=invoice_test.xls">
file directory: #fileDirectory#
file: #fileDirectory#\#fileInvoicesDetails#--->

<cfdirectory directory="#fileDirectory#\" action="list" name="qLettersDetails" filter="#fileLettersDetails#">
	<CFIF qLettersDetails.RecordCount EQ 0>
		<cffile action="write" addnewline="yes" file="#fileDirectory#\#fileLettersDetails#" output = 
		"
		<table border=1>
		<tr>
		<td><b>HouseName</b></td>
		<td><b>HouseAddress1</b></td>
		<td><b>HouseAddress2</b></td>
		<td><b>HousePhone</b></td>
		<td><b>ResidentName</b></td>
		<td><b>AccountNumber</b></td>
		<td><b>ContactName</b></td>
		<td><b>ContactAddress1</b></td>
		<td><b>ContactAddress2</b></td>
		<td><b>ContactPhone</b></td>
		<td><b>Total</b></td>
		<td><b>Date</b></td>
		<td><b>Apt</b></td>
		<td><b>ARContact</b></td>
		<td><b>ARPhone</b></td>
		<td><b>Type</b></td>
		<td><b>Deferred Payment</b></td>
		</tr>
		</table>
		">
	
		<cffile action="write" addnewline="yes" file="#fileDirectory#\#fileLettersDetailsCSV#" output = 
		"AccountNumber,Total,Type">
	</CFIF>
       
	<CFLOOP QUERY="rs1">
		<cfset solomonkey = "'"&#csolomonkey#&"'">
		<!--- Proj 36359 - 8/3/2009 - rts - Deferred Payment display --->
			<cfif #bDeferredPayment# eq '1'>
				<cfset DeferredPymnt = 'Yes'>
			<cfelseif #bDeferredPayment# eq '0'>
				<cfset DeferredPymnt = 'No'>
			<cfelseif #bDeferredPayment# eq ''>
				<cfset DeferredPymnt = 'No Data Provided'>
			</cfif>
		<cffile action="append" addnewline="yes" file="#fileDirectory#\#fileLettersDetails#" output = 
		"
			<table border = 1>
			  <tr>
				<td>#cHouseName#</td>
				<td>#cHouseAddress#</td>
				<td>#cHouseAddress2#</td>
				<td>#cHousePhone#</td>
				<td>#cTenantName#</td>
				<td>#solomonkey#</td>
				<td>#cContactName#</td>
				<td>#cContactAddress#</td>
				<td>#cContactAddress2#</td>
				<td>#cContactPhone#</td>
				<td>#Total#</td>
				<td>#dateformat(dtrowstart,'MM/DD/YYYY')#</td>
				<td>#Apt#</td>
				<td>#ARContact#</td>
				<td>#ARPhone#</td>
			    <td>#right(type,1)#</td>
			    <td>#DeferredPymnt#</td>	
			</table>
		">	
		<!--- end 36359 --->
		<cfset TempHouseName = #cHouseName#>
		<cfset TempHouseAddress1 = #cHouseAddress#>
		<cfset TempHouseAddress2 = #cHouseAddress2#>
		<cfset TempHousePhone = #cHousePhone#>			
		<cfset TempDate= #dateformat(dtrowstart,'MM/DD/YYYY')#>
		<cfset TempARContact = #ARContact#>
		<cfset TempARPhone = #ARPhone#>
		<cfset TempType = #right(type,1)#>
		
		<cffile action="append" addnewline="yes" file="#fileDirectory#\#fileLettersDetailsCSV#" output = 
		"#solomonkey#,#Total#,#right(type,1)#">

		<cfset LineCount = #LineCount# + 1>
	</CFLOOP>
	
	<cffile action="read" file="#fileDirectory#\#fileLettersDetailsCSV#" variable="csvFile">
	<cfloop index="index" list="#csvfile#" delimiters="#chr(10)##chr(13)#"> 
		<cfif #listgetAt('#index#',1)# neq 'AccountNumber'>	
			<cfset TotalLetters = #TotalLetters# + 1>
			<cfset Amounts = #listgetAt('#index#',2)# + #Amounts#>
			<cfset Type = #listgetAt('#index#',3)#>
		</cfif>
	</cfloop>

	<cfif #TotalLetters# neq 0 and #LineCount# neq 0 <!---and (#TotalLetters# eq #LineCount#)---> >				
		<cffile action="append" addnewline="yes" file="#fileDirectory#\#fileLettersDetails#" output = 
		"
			<table border = 1>
			  <tr>
				<td>#TempHouseName#</td>
				<td>#TempHouseAddress1#</td>
				<td>#TempHouseAddress2#</td>
				<td>#TempHousePhone#</td>
				<td>Samuel L.</td>
				<td>'10128099'</td>
				<td>Wally L.</td>
				<td>W140 N8981 Lilly Road</td>
				<td>Menomonee Falls, WI 53051</td>
				<td>(262)257-8760</td>
				<td>0.00</td>
				<td>#TempDate#</td>
				<td>199</td>
				<td>#TempARContact#</td>
				<td>#TempARPhone#</td>
			    <td>#TempType#</td>	
			</table>
		">	
		<cffile action="append" addnewline="yes" file="#fileDirectory#\#fileLettersDetailsCSV#" output = 
		"'10128099',0.00,#TempType#">		
		
		<cfset TempHouseName = ''>
		<cfset TempHouseAddress1 = ''>
		<cfset TempHouseAddress2 = ''>
		<cfset TempHousePhone = ''>			
		<cfset TempDate= ''>
		<cfset TempARContact = ''>
		<cfset TempARPhone = ''>
		<cfset TempType = ''>		
	</cfif>
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
<br>
  <cfoutput>
		 
	<form name="FTPform" action="act_FTP.cfm" method="post" onSubmit="return validateDistributionList();">
 
	<table border="1" cellpadding="1" cellspacing="1" style="border-collapse: collapse" bordercolor="gray" width="24%">
		<tr>
			<td width="33%" nowrap><strong>Scope:</strong></td>
			<td width="67%" nowrap>
				<input name="Scope" type="text" value="#form.Scope#" size="30" maxlength="30" readonly="true"> 
			</td>
		</tr>
		<tr>
			<td width="33%" nowrap><strong>Period:</strong></td>
			<td width="67%" nowrap>
				<input name="Period" type="text" value="#form.Period#" size="9" maxlength="8" readonly="true"> 
			</td>
		</tr>
		<tr>
			<td width="27%" nowrap><strong>Letter:</strong></td>
			<td width="73%" nowrap>
				<input name="Type" type="text" value="<cfif isDefined("type")>#type#</cfif>" size="9" maxlength="8" readonly="true"> 
			</td>
		</tr>	  
		<tr>
			<td width="33%" nowrap><strong>Total Letters:</strong></td>
			<td width="67%" nowrap>
				<input name="TotalLetters" type="text" value="#TotalLetters#" size="9" maxlength="8" readonly="true"> 
			</td>
	</tr>
	<tr>
		<td width="33%" nowrap><strong>Total Amounts:</strong></td>
		<td width="67%" nowrap>
			<input name="Amounts" type="text" value="#Amounts#" size="30" maxlength="30" readonly="true"> 
		</td>
	</tr>
	</table>
</cfoutput>

	  <p><a href="dsp_Main.cfm"><font color="red">Go back to generate more Collection Letters files for different regions</font></a><a href="#" class="hintanchor" onMouseover="showhint('You can go back to generate more Collection Letters data for different regions, the new data will append to the existing files.', this, event, '150px')">[?]</a></p>
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
			<td height="34" colspan="2" nowrap><b><font face="Arial">Delete generated data files</font></b><a href="#" class="hintanchor" onMouseover="showhint('If you make a mistake and want to re-generate all collection letters, please delete the existing data and start over.', this, event, '150px')">[?]</a>
		  <input name="run" type="submit" class="style1" value="Delete"></td>
		</tr>
	  </table>
	</form>

</body>
</html>

