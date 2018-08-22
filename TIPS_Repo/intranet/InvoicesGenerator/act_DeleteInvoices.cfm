<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Delete generated invoices data</title>
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

	<cftry>
		<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoiceDetails" filter="#fileInvoicesDetails#">
		<CFIF qInvoiceDetails.RecordCount GT 0> 
			<cffile action="delete" file="#fileDirectory#\#fileInvoicesDetails#">	
		</CFIF>

		<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoicePayments" filter="#fileInvoicesPayments#">
		<CFIF qInvoicePayments.RecordCount GT 0> 
			<cffile action="delete" file="#fileDirectory#\#fileInvoicesPayments#">	
		</CFIF>

		<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoiceCharges" filter="#fileInvoicesCharges#">
		<CFIF qInvoiceCharges.RecordCount GT 0> 
			<cffile action="delete" file="#fileDirectory#\#fileInvoicesCharges#">	
		</CFIF>

		<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoiceDetailsCSV" filter="#fileInvoicesDetailsCSV#">
		<CFIF qInvoiceDetailsCSV.RecordCount GT 0> 
			<cffile action="delete" file="#fileDirectory#\#fileInvoicesDetailsCSV#">	
		</CFIF>

		<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoicePaymentsCSV" filter="#fileInvoicesPaymentsCSV#">
		<CFIF qInvoicePaymentsCSV.RecordCount GT 0> 
			<cffile action="delete" file="#fileDirectory#\#fileInvoicesPaymentsCSV#">	
		</CFIF>

		<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoiceChargesCSV" filter="#fileInvoicesChargesCSV#">
		<CFIF qInvoiceChargesCSV.RecordCount GT 0> 
			<cffile action="delete" file="#fileDirectory#\#fileInvoicesChargesCSV#">	
		</CFIF>											
								
		<cfcatch type="any">
	        <CFMAIL TYPE ="HTML" FROM="TIPS4-Message@alcco.com" TO="cfdevelopers@alcco.com" SUBJECT="ERROR - Delete Invoices Failed">
		        ERROR
	      </CFMAIL>
        </cfcatch>

	</cftry>
	<p class="style1">	Invoices have been deleted. </p>
	<p class="style1">  <a href="Index.cfm">Back to Invoices Generator</a></p>
</body>
</html>
