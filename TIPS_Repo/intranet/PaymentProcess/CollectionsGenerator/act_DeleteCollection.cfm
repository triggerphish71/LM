<!----------------------------------------------------------------------------------------------
| DESCRIPTION: action screen - Delete collection letters                                       |
|----------------------------------------------------------------------------------------------|
| act_DeleteCollection.cfm                                                                     |
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
<title>Delete generated Collection Letters data</title>
<style type="text/css">
<!--
.style1 {
	font-family: Arial, Helvetica, sans-serif;
	font-weight: bold;
}
-->
</style>
</head>

<body>
<center>
<img src="../images/ALC%20Logo.jpg" align="top">
</center>

<cfset fileDirectory = "\\FS01\AR\Collections\Collectionletters\Pending\History">
<cfset fileLettersDetails = "lettersdetails.xls">
<cfset fileLettersDetailsCSV = "lettersdetails.csv">	
	
	<cftry>
		<span class="style1">
		<cfdirectory directory="#fileDirectory#\" action="list" name="qLettersDetails" filter="#fileLettersDetails#">
		<CFIF qLettersDetails.RecordCount GT 0> 
			<cffile action="delete" file="#fileDirectory#\#fileLettersDetails#">	
		</CFIF>

		<cfdirectory directory="#fileDirectory#\" action="list" name="qLettersDetailsCSV" filter="#fileLettersDetailsCSV#">
		<CFIF qLettersDetailsCSV.RecordCount GT 0> 
			<cffile action="delete" file="#fileDirectory#\#fileLettersDetailsCSV#">	
		</CFIF>
								
		<cfcatch type="any">
	        <CFMAIL TYPE ="HTML" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" SUBJECT="ERROR - Delete Collection Letters Failed">
		        ERROR
	      </CFMAIL>
        </cfcatch>
	    </span>
	</cftry>
	<p class="style1">	Collection Letters Data have been deleted. </p>
	<p class="style1">  <a href="dsp_Main.cfm">Back to Collection Letters Generator</a></p>
</body>
</html>
