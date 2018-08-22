<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>FTP to Spectrum</title>

<link href="Styles/Index.css" rel="stylesheet" type="text/css" />

</head>
<!--- 
ticket		date		Programmer			Action
96214 	09/19/2012		S Farmer		change primadata emails
102505  11/20/2015      S Farmer        all c:\Inetpub file locations changed to e:\Inetpub for move to CF01
 --->
<body>
	<center>
	<img src="../images/ALC%20Logo.jpg" align="top">
	</center>
<cfoutput>

<cfset fileDirectory = "\\FS01\AR\CentralizedInvoices\Pending">
<cfset fileHistoryDirectory = "\\FS01\AR\CentralizedInvoices\Pending\History">	
<cfset fileFTPErrorDirectory = "e:\Inetpub\wwwroot\intranet\InvoicesGenerator">
<!--- <cfset fileFTPErrorDirectory = "c:\Inetpub\wwwroot\intranet\InvoicesGenerator"> --->
<cfset fileInvoicesDetails = "invoice_details.xls">
<cfset fileInvoicesPayments = "invoice_Payments.xls">
<cfset fileInvoicesCharges = "invoice_charges.xls">

<cfset fileInvoicesDetailsCSV = "invoice_details.csv">
<cfset fileInvoicesPaymentsCSV = "invoice_Payments.csv">
<cfset fileInvoicesChargesCSV = "invoice_charges.csv">
<cfset fileFTPError = "ftperror.txt">

<cfset subject = "ALC Invoices statements">
<cfset footer = "This communication may contain Protected Health Information.  This information is intended only for the use of the individual or entity to which it is addressed.  The authorized recipient of this information is prohibited from disclosing this information to any other party unless required to do so by law or regulation and is required to destroy the information after its stated need has been fulfilled.  If you are not the intended recipient, you are hereby notified that any disclosure, copying, distribution, or action taken in reliance on the contents of these documents is STRICTLY PROHIBITED by federal law.  If you have received this information in error, please notify the sender immediately and arrange for the return or the destruction of these documents.">
	
	<!--- Get Current Date --->
<cfset filename = DATEFORMAT(now(),'mmddyyyy')>
<span class="style1">		
	<cftry>
		    <!--- FTP to Spectrum call window FTP --->
		    <!--- ftpcommand.txt has all the login information --->
<!---  			<cfexecute name="c:\winnt\system32\cmd.exe" arguments="/c ftp -s:c:\Inetpub\wwwroot\intranet\InvoicesGenerator\ftpcommand.txt 69.129.28.250" outputfile="c:\Inetpub\wwwroot\intranet\InvoicesGenerator\ftperror_#filename#.txt">  --->
  			<cfexecute name="c:\winnt\system32\cmd.exe" arguments="/e ftp -s:e:\Inetpub\wwwroot\intranet\InvoicesGenerator\ftpcommand.txt 69.129.28.250" outputfile="e:\Inetpub\wwwroot\intranet\InvoicesGenerator\ftperror_#filename#.txt"> 
		</cfexecute>
		<cfcatch type="any">
			<CFMAIL TYPE ="HTML" FROM="TIPS4-Message@alcco.com" TO="JDengel@ALCCO.COM" cc="cfdevelopers@alcco.com" SUBJECT="ERROR - FTP to Spectrum Failed">
				    The ftp step has failed!<br>
				    <b>#CFCATCH.Message#<br>
					#CFCATCH.Detail#</b>
			</CFMAIL>
			<cfabort>
		</cfcatch>		
	</cftry>
	<cftry>		  
			<!--- Set Sleep for the FTP process to complete --->
		    <cfscript>
			    thread = CreateObject("java", "java.lang.Thread");
    			thread.sleep(10000);
			</cfscript>

			<CFMAIL TYPE ="HTML" FROM="nansay@ALCCO.COM" TO="#form.ToMail#" CC="#form.CCMail#" SUBJECT="#form.EmailSubject#">
			<table border="1" style="border-collapse: collapse" bordercolor="gray" width="50%">
				<tr>
					<td width="16%" nowrap class="style1"><font face="Arial" size="2"><strong>Invoices:</strong></font><font face="Arial" size="2">&nbsp;</font></td>
					<td width="16%" nowrap>
						<span class="style1"><font face="Arial" size="2">#form.TotalInvoices# </font><font face="Arial" size="2"></font>
						</span></td>
					<td width="68%" colspan="4" >&nbsp;</td>
				</tr>
				<tr>
					<td width="16%" nowrap class="style1"><font face="Arial" size="2"><strong>Payments:</strong></font><font face="Arial" size="2">&nbsp;</font></td>
					<td width="16%" nowrap>
						<span class="style1"><font face="Arial" size="2">#form.NbrOfPayments# </font><font face="Arial" size="2"></font>
						</span></td>
					<td width="17%" nowrap class="style1"><font face="Arial" size="2"><strong>Sum Total:</strong></font><font face="Arial" size="2">&nbsp;</font></td>
					<td width="17%" nowrap>
						<span class="style1"><font face="Arial" size="2">#form.Payments#</font><font face="Arial" size="2"></font>
						</span></td>
					<td width="17%" nowrap class="style1"><font face="Arial" size="2"><strong>Absolute Total:</strong></font><font face="Arial" size="2">&nbsp;</font></td>
					<td width="17%" nowrap>
						<span class="style1"><font face="Arial" size="2">#form.ABSPayments#</font><font face="Arial" size="2"></font>
						</span></td>
				</tr>
				<tr>
					<td width="16%" nowrap class="style1"><font face="Arial" size="2"><strong>Charges:</strong></font><font face="Arial" size="2">&nbsp;</font></td>
					<td width="16%" nowrap>
						<span class="style1"><font face="Arial" size="2">#form.NbrOfCharges#</font><font face="Arial" size="2"></font>
						</span></td>
					<td width="17%" nowrap class="style1"><font face="Arial" size="2"><strong>Sum Total:</strong></font><font face="Arial" size="2">&nbsp;</font></td>
					<td width="17%" nowrap>
						<span class="style1"><font face="Arial" size="2">#form.Totalcharges#</font><font face="Arial" size="2"></font>
						</span></td>
					<td width="17%" nowrap class="style1"><font face="Arial" size="2"><strong>Absolute Total:</strong></font><font face="Arial" size="2">&nbsp;</font></td>
					<td width="17%" nowrap>
						<span class="style1"><font face="Arial" size="2">#form.ABSTotalCharges#</font><font face="Arial" size="2"></font>
						</span></td>
				</tr>
			</ta
				><span class="style1">
				<p>#footer#</p>
			    </span>
			</CFMAIL>

			<p class="style1">Data have been transferred to Spectrum. The confirmation email has been sent. </p>
			
			<CFCATCH TYPE="Any">
			    <CFMAIL TYPE ="HTML" FROM="TIPS4-Message@alcco.com" TO="cfDevelopers@alcco.com;rschuette@alcco.com" SUBJECT="ERROR - FTP to Spectrum Failed">
				    The ftp and send mail step has failed!<br>
				    <b>#CFCATCH.Message#<br>
					#CFCATCH.Detail#</b>
			  	</CFMAIL>
			</CFCATCH>
	</cftry>
    
    <p class="style1">  <a href="../applicationlist.cfm">Back to Main Menu</a></p>
</span>
<!---<span class="style1">
	  	<cftry>
		  	<cfscript>
			    thread = CreateObject("java", "java.lang.Thread");
    			thread.sleep(20000);
			</cfscript>
			<!--- rename all the exported files with current date and time stamp --->
		    <cffile action="rename" attributes="normal" destination="#fileHistoryDirectory#\invoice_details_#filename#.xls" source="#fileDirectory#\#fileInvoicesDetails#">
		    <cffile action="rename" attributes="normal" destination="#fileHistoryDirectory#\invoice_payments_#filename#.xls" source="#fileDirectory#\#fileInvoicesPayments#">
		    <cffile action="rename" attributes="normal" destination="#fileHistoryDirectory#\invoice_charges_#filename#.xls" source="#fileDirectory#\#fileInvoicesCharges#">
		    <cffile action="rename" attributes="normal" destination="#fileHistoryDirectory#\invoice_details_#filename#.csv" source="#fileDirectory#\#fileInvoicesDetailsCSV#">
		    <cffile action="rename" attributes="normal" destination="#fileHistoryDirectory#\invoice_payments_#filename#.csv" source="#fileDirectory#\#fileInvoicesPaymentsCSV#">
		    <cffile action="rename" attributes="normal" destination="#fileHistoryDirectory#\invoice_charges_#filename#.csv" source="#fileDirectory#\#fileInvoicesChargesCSV#">
		    <CFCATCH TYPE="Any">
			    <CFMAIL TYPE ="HTML" FROM="TIPS4-Message@alcco.com" TO="cfDevelopers@alcco.com" SUBJECT="ERROR - File Renaming Failed">
				    The file renaming failed! You must manually rename and move all generated files to the History Directory.<BR>
				    <b>#CFCATCH.Message#<br>
					#CFCATCH.Detail#</b>
			  	</CFMAIL>		
			</CFCATCH>		
		</cftry>	  
			
			  
</span>--->
</cfoutput>
</body>
</html>
