<cfif isDefined("url.Invoice") eq false Or isDefined("url.HouseId") eq false>
	<!--- Display the Error Message, because the parameters were NOT supplied --->
	<cfoutput>
		ERROR: Either the [Invoice] or [HouseId] Query 
		String Parameter was NOT provided in the URL.
	</cfoutput>
<cfelse>
	<!--- Build the Url to generate the Report using SSRS. --->
	<cfset DssiInvoicePdfReportUri = "http://maple.alcco.com/ReportServer?%2fFTA%2fDssiInvoiceReport&InvoiceNumber=#rTrim(url.Invoice)#&HouseId=#url.HouseId#&rs%3aCommand=Render&rs%3aFormat=PDF">		
	<!--- Make a request the SSRS using the above Uri to retreive the PDF response stream. --->
	<cfhttp url="#DssiInvoicePdfReportUri#" method="GET" getasbinary="yes">
	<!--- Stores the end of the Report's name, it is consistant. --->
	<cfset pdfFilePath = "#url.Invoice#.pdf">
	<cffile action="write" file="D:\DSSI Invoices\#pdfFilePath#" output="#CFHTTP.FileContent#">
	<cfoutput>
		<html>
			<head>
				<title>
					Invoice: #url.Invoice#
				</title>
			</head>
			<body>		
				<embed src="http://Gum.alcco.com/DSSI Invoices/#pdfFilePath#" width="100%" height="95%">
			</body>
		</html>
	</cfoutput>
</cfif>