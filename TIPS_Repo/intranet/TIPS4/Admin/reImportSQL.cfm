<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Importing #url.name#</title>
<link rel="stylesheet" type="text/css" href="../Shared/Style3.css">
</head>

<body>

<cfif isdefined("url.period")>
	<cfset local.period = url.period>
<cfelse>
	<cfset local.period = "">
</cfif>
<cfif isDefined("url.invoice")>
	<cfset local.invoice = url.invoice>
<cfelse>
	<cfset local.invoice = "">
</cfif>
<cftry>
<!--- mstriegel: 01/18/2018 added call to cfc --->
<cfset qImport = session.oExport2Solomon.sp_ExportInv2Solomon(iHouseID=#Trim(url.ihouse_ID)#,period=local.period,invoice=local.invoice,batchType="ReImport")>
<!--- end mstriegel:01/18/2018 --->
<cfif qimport.recordcount gt 0>
<div style="font-size:medium;color:blue;text-align:center;">
This batch of items has already been imported. Please see below. <br>
</div>
<cfdump var="#qimport#">
<cfabort>
</cfif>

<cfcatch type="any">
<cfdump var="#cfcatch#">
<cfabort>
</cfcatch>

</cftry>

</body>
</html>

<cfif isDefined("url.period")>
	<cfset loc='missedMonthlyImports.cfm'>
<cfelse>
	<cfset loc='reImportInv.cfm'>
</cfif>

<script>
opener.document.open();
opener.document.write("<div style='font-size:medium;color:blue;text-align:center;'>Reloading data</div>");
opener.document.close();
opener.focus();wsdw
opener.location='#loc#'; 
self.close();
</script>
</cfoutput>