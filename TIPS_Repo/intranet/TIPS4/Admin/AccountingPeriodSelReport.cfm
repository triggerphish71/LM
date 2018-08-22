<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!--- 
|Sfarmer     |01/27/2017  | Select report period of items being updated in Invoices for Report   |
 --->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>AccountingPeriodSelReport</title>
</head>
<cfquery name="qryAccountingPeriodReport" datasource="#APPLICATION.datasource#">
   SELECT  distinct(iAccountingPeriod) as AcctPeriod
  FROM TIPS4.dbo.AccountingApprovalChanges
</cfquery>
<CFINCLUDE TEMPLATE="../../header.cfm">

<TITLE> Tips 4-Admin Approval </TITLE>
<BODY>
<H1 CLASS="PageTitle"> Tips 4 - Administrative Approval Report</H1>

<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">

<cfoutput>
<table width="100%"  >

<tr>
<td>Select Report Period to View Approvals for that Period</td>
</tr>
<cfloop query="qryAccountingPeriodReport">
<tr>
<td><a href="AdminApprovalPrint.cfm">#AcctPeriod#</a></td>
</tr>
</cfloop>

</table>
<CFINCLUDE TEMPLATE='../../Footer.cfm'>
</cfoutput>
</body>
</html>
