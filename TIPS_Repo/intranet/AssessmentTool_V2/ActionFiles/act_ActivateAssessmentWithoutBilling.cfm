<!--- -----------------------------------------------------------------------------------------|
| Sfarmer   | 10/18/2013  |Proj. 102481 removed Walnut db and tables Census & Leadtracking     |
----------------------------------------------------------------------------------------------->
<cfoutput>
<cfscript>	
//	Assessment.ActivateWithoutBilling(DateFormat(session.tipsmonth,"mm/dd/yyyy"),url.billingActiveDate,session.userId,session.username,'Solomon-Houses',session.leadtrackdsn,application.leadtrackingdbserver);
	Assessment.ActivateWithoutBilling(DateFormat(session.tipsmonth,"mm/dd/yyyy"),url.billingActiveDate,session.userId,session.username,'Solomon-Houses');

</cfscript>

<cfset theUrl = "http://#cgi.SERVER_NAME#/intranet/tips4/Charges/ChargesDetail.cfm?ID=#Assessment.GetTenant().GetId()#" & "##@start">

<script language="javascript">
	window.open('#theUrl#','_blank');
</script>
</cfoutput>