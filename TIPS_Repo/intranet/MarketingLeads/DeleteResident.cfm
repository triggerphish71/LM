

<cfoutput>
<cfset DSN='LeadTracking'>
<cfif IsDefined("resid")>
<cftransaction>
<cfquery NAME="qRemoveInquirer" DATASOURCE="#DSN#">
	UPDATE	Resident
	SET		dtRowDeleted = getdate()
			,cRowDeletedUser_ID = '#SESSION.UserName#'
	WHERE	iResident_ID = #resid#
	
	UPDATE	InquirerToResidentLink
	SET		dtRowDeleted = getdate()
			,cRowDeletedUser_ID = '#SESSION.UserName#'
	WHERE	iResident_ID = #resID#
</cfquery>
</cftransaction>
</cfif>

<cfif REMOTE_ADDR EQ '10.1.0.211' or auth_user eq 'ALC\PaulB'> 
<a href="Leads.cfm">Continue</a> 
<cfelse> 
<CFLOCATION URL="Leads.cfm"> 
</cfif>

</cfoutput>