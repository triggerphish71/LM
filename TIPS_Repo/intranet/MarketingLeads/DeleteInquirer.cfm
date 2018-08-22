

<cfoutput>
<cfset DSN='LeadTracking'>

<cfif IsDefined("IID")>
	<cftransaction>
	
	<!--- associated links for resident in general--->
	<cfquery name="qGeneralAssociations" datasource="#DSN#">
		select count(ilink_id) as link
		from InquirerToResidentLink il
		join inquirer i on i.iinquirer_id = il.iinquirer_id and i.dtrowdeleted is null
		join resident r on r.iresident_id = il.iresident_id and r.dtrowdeleted is null
		where il.dtrowdeleted is null and il.iresident_id = #RID#
	</cfquery>		
	
	<!--- remove inquirer link if there is another contact listed--->
	<cfif qGeneralAssociations.link gt 1>
		<cfquery name="qRemoveInquirerLink" datasource="#DSN#">	
			update InquirerToResidentLink
			set dtRowDeleted = getdate() ,cRowDeletedUser_ID = '#SESSION.UserName#'
			where iInquirer_ID = #IID# and iresident_id = #RID#
		</cfquery>
	</cfif>
	
	<!--- show error if this is the last contact --->
	<cfif qGeneralAssociations.link eq 1>
	<p style="color:blue;font-size:medium;text-align:center;">
	This is contact may not be deleted because it is the only contact that <br>
	is listed for this potential resident.<br>
	<a href="Leads.cfm">Click here to continue.</a> 
	</p>
	<cfabort>
	</cfif>

	<!--- associated links --->
	<cfquery name="qAssociations" datasource="#DSN#">
		select count(ilink_id) as link
		from InquirerToResidentLink il
		join inquirer i on i.iinquirer_id = il.iinquirer_id and i.dtrowdeleted is null
		join resident r on r.iresident_id = il.iresident_id and r.dtrowdeleted is null
		where il.dtrowdeleted is null and i.iInquirer_ID = #IID# and il.iresident_id = #RID#
	</cfquery>	
		
	<!--- delete inquirer if they are now associated with any other residents --->
	<cfif qAssociations.link eq 0>
		<cfquery name="qRemoveInquirerLink" datasource="#DSN#">	
			update Inquirer
			set dtRowDeleted = getdate() ,cRowDeletedUser_ID = '#SESSION.UserName#'
			where iInquirer_ID = #IID#
		</cfquery>
	</cfif>
	</cftransaction>
	
</cfif>

<cfif REMOTE_ADDR EQ '10.1.0.211'> <br> <a href="Leads.cfm">Continue</a> 
<cfelse> <cflocation url="Leads.cfm"> 
</cfif>

</cfoutput>