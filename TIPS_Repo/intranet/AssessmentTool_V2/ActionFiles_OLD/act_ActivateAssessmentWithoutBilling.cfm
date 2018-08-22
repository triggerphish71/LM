<cfoutput>
<cfscript>	
	Assessment.ActivateWithoutBilling(DateFormat(session.tipsmonth,"mm/dd/yyyy"),url.billingActiveDate,session.userId,session.username,'Solomon-Houses',session.leadtrackdsn,application.leadtrackingdbserver);
</cfscript>

<cfset theUrl = "http://#cgi.SERVER_NAME#/intranet/tips4/Charges/ChargesDetail.cfm?ID=#Assessment.GetTenant().GetId()#" & "##@start">

<script language="javascript">
	window.open('#theUrl#','_blank');
</script>
</cfoutput>