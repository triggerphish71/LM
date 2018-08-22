<!----------------------------------------------------------------------------------------------
| DESCRIPTION: action screen - FTP collection letters                                          |
|----------------------------------------------------------------------------------------------|
| act_FTP.cfm                                                                                  |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by: 													                               |
| Calls/Submits:	                                                                           |
|--------------------------------------------------------------------------------------------------------------|
| HISTORY                                                                                                      |
|--------------------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                                        |
|------------|------------|------------------------------------------------------------------------------------|
|MLAW        | 09/20/2002 | Original Authorship                                                                |
|Sfarmer     | 11/20/2013 | All c:\Inetpub directory locations changed to e:\Inetpub    for move to CF01       |
--------------------------------------------------------------------------------------------------------------->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>FTP to Spectrum</title>
<style type="text/css">
<!--
body,td,th {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12px;
}
-->
</style>

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
<cfoutput>
	<span class="style1">
	<!--- Define Variables --->
	<cfset fileDirectory = "\\FS01\AR\Collections\Collectionletters\Pending\History">
	<cfset fileHistoryDirectory = "\\FS01\AR\Collections\Collectionletters\Pending\History">
	<cfset fileLettersDetails = "lettersdetails.xls">
	<cfset fileLettersDetailsCSV = "lettersdetails.csv">	
	
	<!---
	<cfset tomailList = "ameyerhofer@Primadatainc.com;lpoole@Primadatainc.com">
	<cfset ccmailList = "bleonard@specresources.biz;wlevonowich@alcco.com;tbates@alcco.com;mlaw@alcco.com"> 
	
	<cfset tomailList = "mlaw@alcco.com">
	<cfset ccmailList = "mlaw@alcco.com">
	--->
	<cfset subject = "ALC Collection Letters">
	<cfset footer = "This communication may contain Protected Health Information. This information is intended only for the use of the individual or entity to which it is addressed. The authorized recipient of this information is prohibited from disclosing this information to any other party unless required to do so by law or regulation and is required to destroy the information after its stated need has been fulfilled. If you are not the intended recipient, you are hereby notified that any disclosure, copying, distribution, or action taken in reliance on the contents of these documents is STRICTLY PROHIBITED by federal law. If you have received this information in error, please notify the sender immediately and arrange for the return or the destruction of these documents. 
">
	
	<!--- Get Current Date --->
	<cfset filename = DATEFORMAT(now(),'mmddyyyy')>
		
		<cftry>
		    <!--- FTP to Spectrum call window FTP --->
		    <!--- ftpcommand.txt has all the login information --->
		    <!--- --->
<!--- 			<cfexecute name="c:\winnt\system32\cmd.exe"
			arguments="/c ftp -s:c:\Inetpub\wwwroot\intranet\CollectionsGenerator\ftpcommand.txt 69.129.28.250" outputfile="c:\Inetpub\wwwroot\intranet\CollectionsGenerator\ftperror.txt">
		    </cfexecute> --->
			<cfexecute name="c:\winnt\system32\cmd.exe"
			arguments="/e ftp -s:e:\Inetpub\wwwroot\intranet\CollectionsGenerator\ftpcommand.txt 69.129.28.250" outputfile="e:\Inetpub\wwwroot\intranet\CollectionsGenerator\ftperror.txt">
		    </cfexecute>			 

			<!--- Set Sleep for the FTP process to complete --->
		    <cfscript>
			    thread = CreateObject("java", "java.lang.Thread");
    			thread.sleep(30000);
			</cfscript>
			
			<!--- rename all the exported files with current date and time stamp --->
		    <cffile action="rename" attributes="normal" destination="#fileHistoryDirectory#\lettersdetails_#filename#.xls" source="#fileDirectory#\#fileLettersDetails#">
		    <cffile action="rename" attributes="normal" destination="#fileHistoryDirectory#\lettersdetails_#filename#.csv" source="#fileDirectory#\#fileLettersDetailsCSV#">
			  
			<CFMAIL TYPE ="HTML" FROM="jgedelman@ALCCO.COM" TO="#form.ToMail#" CC="#form.CCMail#" SUBJECT="#form.EmailSubject#">
				<table border="1" style="border-collapse: collapse" bordercolor="gray" width="50%">
				  <tr>
					<td width="16%" nowrap class="style1"><font face="Arial" size="2"><strong>Period:</strong></font><font face="Arial" size="2">&nbsp;</font></td>
					<td width="16%" nowrap>
						<span class="style1"><font face="Arial" size="2">#form.Period#</font><font face="Arial" size="2"></font>
						</span>
					</td>
				  </tr>
				  <tr>
					<td width="16%" nowrap class="style1"><font face="Arial" size="2"><strong>Total Letters:</strong></font><font face="Arial" size="2">&nbsp;</font></td>
					<td width="16%" nowrap>
						<span class="style1"><font face="Arial" size="2">#form.TotalLetters# </font><font face="Arial" size="2"></font>
						</span>
					</td>
				  </tr>
				  <tr>
					<td width="16%" nowrap class="style1"><font face="Arial" size="2"><strong>Total Amounts:</strong></font><font face="Arial" size="2">&nbsp;</font></td>
					<td width="16%" nowrap>
						<span class="style1"><font face="Arial" size="2">#form.Amounts# </font><font face="Arial" size="2"></font>
						</span>
					</td>
				  </tr>
				</table>
				<span class="style1">
				<p>
				 #footer#
				</span>
			</CFMAIL>
			
			<cfif #form.type# eq 3>
				<cfdirectory directory="#fileDirectory#\" action="list" name="qLettersDetails" filter="#fileLettersDetailsCSV#">
				<CFIF qLettersDetails.RecordCount GT 0>
					<cffile action="read" file="#fileDirectory#\#fileLettersDetailsCSV#" variable="csvFile">
					<cfloop index="index" list="#csvfile#" delimiters="#chr(10)##chr(13)#"> 
						<cfif #listgetAt('#index#',1)# neq 'AccountNumber'>	
							#listgetAt('#index#',1)#
							<!---
							<cfset TotalLetters = #TotalLetters# + 1>
							<cfset Amounts = #listgetAt('#index#',2)# + #Amounts#>
							<cfset Type = #listgetAt('#index#',3)#>--->
							<!--- Update the sent date for the thirdletter --->
							<cfquery name="UpdateTenantCollectionList" datasource="#application.datasource#">
								update 
									TenantCollectionList
								set 
									dtthirdletter = getdate()
								where
									dtPeriod = #form.Period#
								and
									cSolomonkey = #listgetAt('#index#',1)#
								and
									istage = #form.type#
								and
									dtrowdeleted is NULL
							</cfquery>
						</cfif>
					</cfloop>		
				</CFIF>
			</cfif>
			<cffile action="rename" attributes="normal" destination="#fileHistoryDirectory#\lettersdetails_#filename#.csv" source="#fileDirectory#\#fileLettersDetailsCSV#">
			<p class="style1">	Data have been transferred to Spectrum. The confirmation email has been sent. </p>
			<p class="style1">  <a href="../applicationlist.cfm">Back to Main Menu</a></p>	  
			<span class="style1">
			<CFCATCH type="Any">
				<CFMAIL TYPE ="HTML" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" SUBJECT="ERROR - FTP to Spectrum Failed">
					ERROR
				</CFMAIL>
			</CFCATCH>
		 	 </span>
        </cftry>
</cfoutput>
</body>
</html>
