<cfoutput>
<cfif not isDefined("session.userid")>
<div style="text-align:center;font-weigth:bold;font-size:medium;">
You must be logged in to use this utility.<br>
<a href="http://#server_name#/intranet/loginindex.cfm">Please login then retry your link.</a>
</div>

<cfabort>
</cfif>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Assessment Reconcile</title>
<link rel="stylesheet" type="text/css" href="http://#server_name#/intranet/tips4/shared/style3.css">
<style>td { white-space: nowrap;} </style>
</head>

<cfquery name="qhouse" datasource="TIPS4">
select * from house where dtrowdeleted is null
</cfquery>

<cfstoredproc procedure="[TIPS4].[rw].[sp_AssessmentBillingProblems]" datasource="TIPS4">
<cfprocresult name="qBilling">
<cfprocparam type="In" cfsqltype="CF_SQL_CHAR" variable="@Scope" null="yes">
<cfprocparam type="In" cfsqltype="CF_SQL_CHAR" variable="@DateRangeStart" value="1/1/2004" null="no">
<cfprocparam type="In" cfsqltype="CF_SQL_CHAR" variable="@DateRangeStart" value="12/31/2004" null="no">
</cfstoredproc>

<cfquery name="qtrx" dbtype="query">
select 
CFIRSTNAME+' '+CLASTNAME as fullname
,CNAME 
,CSOLOMONKEY 
,DTBILLINGACTIVE 
,DTCURRENTTIPSMONTH 
,DTRANGEEND 
,DTRANGESTART 
,DTREVIEWEND 
,IASSESSMENTTOOLMASTER_ID 
,IASSESSMENTTOOL_ID 
,IPREVIOUSINVOICEEXISTS 
,ISPOINTS 
,ITENANT_ID 
,MCURRENTINVOICECURRENTMONTHLOYALTYDISCOUNT 
,MCURRENTINVOICECURRENTMONTHLOYALTYDISCOUNTQTY 
,MCURRENTINVOICECURRENTMONTHRESIDENTCARE 
,MCURRENTINVOICECURRENTMONTHRESIDENTCAREQTY 
,MCURRENTINVOICECURRENTMONTHROOM 
,MCURRENTINVOICEPREVIOUSMONTHLOYALTYDISCOUNT 
,MCURRENTINVOICEPREVIOUSMONTHRESIDENTCARE 
,MPREVIOUSINVOICECURRENTMONTHRESIDENTCARE 
,MPREVIOUSINVOICECURRENTMONTHROOM 
,OPSNAME 
,OPSNUMBER 
,REGIONNAME 
,REGIONNUMBER 
,SCOPENAME 
from qbilling order by Regionnumber, opsnumber, cname, csolomonkey
</cfquery>
<body>
<table border="1">
<tr style="background:##006699;">
<!--- <td>#qtrx.SCOPENAME# </td> --->
<th>Div</th>
<!--- <td>#qtrx.REGIONNUMBER# </td> --->
<th>Reg</th>
<th>House</th>
<!--- 
<td>#qtrx.OPSNUMBER# </td> 
<th>itenant_id</th>
--->
<th>solkey</th>
<th>fullname</th>
<th>pts</th>
<!--- 
<td>#dateformat(qtrx.DTCURRENTTIPSMONTH,"mm/dd/yy")# </td>
<td>#dateformat(qtrx.DTRANGEEND,"mm/dd/yy")# </td>
<td>#dateformat(qtrx.DTRANGESTART,"mm/dd/yy")# </td>
<td>#dateformat(qtrx.DTREVIEWEND,"mm/dd/yy")# </td>
<td>#qtrx.IASSESSMENTTOOLMASTER_ID# </td>
<td>#qtrx.IASSESSMENTTOOL_ID# </td>
<td>#qtrx.IPREVIOUSINVOICEEXISTS# </td>
--->
<th>loyalty</th>
<th>care</th>
<th>diff</th>
<th>prev per care</th>
<th>loyalty qty</td>
<th>care qty</th>
<!--- <th>rb</th> --->
<th>prev care total</th>
<th>prev loy total</th>
<!--- <th>prev inv cur rb </th> --->
<th>bill act</th>
</tr> 
<cfloop query="qtrx">
<cfif not isDefined("lastcname") or lastcname neq trim(qtrx.cname)>
	<cfquery name="qhouseid" dbtype="query">
	select ihouse_id from qhouse where cname = '#trim(qtrx.cname)#'
	</cfquery>
	<cfset currenthouse=qhouseid.ihouse_id>
</cfif>
<cfset rcl="style='color:inherit;'">
<cfif (numberformat(abs(evaluate( qtrx.MCURRENTINVOICECURRENTMONTHLOYALTYDISCOUNT + qtrx.MCURRENTINVOICECURRENTMONTHRESIDENTCARE )),"(99999.99)")) 
eq numberformat(qtrx.MPREVIOUSINVOICECURRENTMONTHRESIDENTCARE,"(99999.99)")>
	<cfset rcl="style='color:gray;'">
</cfif>
<tr #rcl#>
<!--- <td>#qtrx.SCOPENAME# </td> --->
<td>#qtrx.REGIONNAME# </td>
<!--- <td>#qtrx.REGIONNUMBER# </td> --->
<td>#qtrx.OPSNAME# </td>
<td>#qtrx.CNAME# </td>
<!--- 
<td>#qtrx.OPSNUMBER# </td> 
<td>#qtrx.ITENANT_ID# </td>
--->
<td>#qtrx.CSOLOMONKEY# </td>
<td>
<cfif numberformat(abs(evaluate( qtrx.MCURRENTINVOICECURRENTMONTHLOYALTYDISCOUNT + qtrx.MCURRENTINVOICECURRENTMONTHRESIDENTCARE )),"(99999.99)")
neq numberformat(qtrx.MPREVIOUSINVOICECURRENTMONTHRESIDENTCARE,"(99999.99)")>
	<a href="../Charges/ChargesDetail.cfm?id=#qtrx.itenant_id#&SelectedHouse_id=#currenthouse#">#qtrx.fullname#</a>
<cfelse>
	#qtrx.fullname#
</cfif>
</td>
<td>#qtrx.ISPOINTS# </td>
<!--- 
<td>#dateformat(qtrx.DTCURRENTTIPSMONTH,"mm/dd/yy")# </td>
<td>#dateformat(qtrx.DTRANGEEND,"mm/dd/yy")# </td>
<td>#dateformat(qtrx.DTRANGESTART,"mm/dd/yy")# </td>
<td>#dateformat(qtrx.DTREVIEWEND,"mm/dd/yy")# </td>
<td>#qtrx.IASSESSMENTTOOLMASTER_ID# </td>
<td>#qtrx.IASSESSMENTTOOL_ID# </td>
<td>#qtrx.IPREVIOUSINVOICEEXISTS# </td>
--->
<td>#numberformat(qtrx.MCURRENTINVOICECURRENTMONTHLOYALTYDISCOUNT,"(99999.99)")# </td>
<td>#numberformat(qtrx.MCURRENTINVOICECURRENTMONTHRESIDENTCARE,"(99999.99)")# </td>
<cfif numberformat(abs(evaluate( qtrx.MCURRENTINVOICECURRENTMONTHLOYALTYDISCOUNT + qtrx.MCURRENTINVOICECURRENTMONTHRESIDENTCARE )),"(99999.99)")
neq numberformat(qtrx.MPREVIOUSINVOICECURRENTMONTHRESIDENTCARE,"(99999.99)")><cfset cl="style='color:red;font-weight:bold;'"><cfelse><cfset cl="style='color:inherit;'"></cfif>
<td #cl#>#numberformat(abs(evaluate( qtrx.MCURRENTINVOICECURRENTMONTHLOYALTYDISCOUNT + qtrx.MCURRENTINVOICECURRENTMONTHRESIDENTCARE )),"(99999.99)")#</td>
<td #cl#>#numberformat(qtrx.MPREVIOUSINVOICECURRENTMONTHRESIDENTCARE,"(99999.99)")# </td>
<td>#numberformat(qtrx.MCURRENTINVOICECURRENTMONTHLOYALTYDISCOUNTQTY,"999999")# </td>
<td>#numberformat(qtrx.MCURRENTINVOICECURRENTMONTHRESIDENTCAREQTY,"999999")# </td>
<!--- <td>#numberformat(qtrx.MCURRENTINVOICECURRENTMONTHROOM,"(99999.99)")# </td> --->
<td>#numberformat(qtrx.MCURRENTINVOICEPREVIOUSMONTHRESIDENTCARE,"(99999.99)")# </td>
<td>#numberformat(qtrx.MCURRENTINVOICEPREVIOUSMONTHLOYALTYDISCOUNT,"(99999.99)")# </td>
<!--- <td>#numberformat(qtrx.MPREVIOUSINVOICECURRENTMONTHROOM,"(99999.99)")# </td> --->
<td>#dateformat(qtrx.DTBILLINGACTIVE,"mm/dd/yy")# </td>
</tr> 
<cfset lastcname=trim(qtrx.cname)>
</cfloop>
</table>
</body>
</html>
</cfoutput>