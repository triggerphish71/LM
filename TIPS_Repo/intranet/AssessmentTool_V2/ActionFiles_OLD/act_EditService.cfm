
<CFOUTPUT>
	
<cfset message = "">
<cfset theUrl = "">

<cfif FindNoCase("message",CGI.HTTP_REFERER)>
	<cfset theUrl = LEFT(cgi.HTTP_REFERER,FindNoCase("message",CGI.HTTP_REFERER) - 2)>
<cfelse>
	<cfset theUrl = CGI.HTTP_REFERER>
</cfif>

<CFIF isDefined("form.iservicelist_id") and form.iservicelist_id neq "">

	<CFQUERY NAME="qUpdateListing" DATASOURCE="#application.datasource#">
	update servicelist
	set  iServiceCategory_id=#form.iservicecategory_id#
		,cDescription='#form.cdescription#'
		,fWeight='#form.fweight#'
		,cGrouping=NULL
		,cSortOrder='#form.cSortOrder#'
		<CFIF isDefined("form.approval")>
		,bApprovalRequired=1
		<cfelse>
		,bApprovalRequired=0
		</CFIF>
		,cRowStartUser_ID='#session.username#'
		,dtrowstart=getdate()
		<CFIF isDefined("form.subselect")>,bsubselect=1<cfelse>,bsubselect=NULL</CFIF>
		<CFIF isDefined("form.imultipleselect")>,imultipleselect=1<cfelse>,imultipleselect=NULL</CFIF>	
	where iservicelist_id = #form.iservicelist_id#
	</CFQUERY>

<CFELSE>

	<CFQUERY NAME="check" DATASOURCE="#application.datasource#">
		Select 
			* 
		from 
			servicelist
		where 
			cdescription  = '#trim(form.cdescription)#' 
		and 
			iServiceCategory_id = #trim(form.iServiceCategory_id)#
		and
			dtrowdeleted is null
	</cfquery>

	<cfif check.recordcount eq 0>
		<CFQUERY NAME="check" DATASOURCE="#application.datasource#">
			INSERT INTO servicelist
			( iServiceCategory_id, cDescription, fWeight, cGrouping, cSortOrder, bApprovalRequired, cRowStartUser_ID, dtrowstart ,bsubselect ,imultipleselect )
			VALUES
			( #form.iservicecategory_id#, '#form.cdescription#', '#form.fweight#', NULL, '#form.cSortOrder#', 
			<CFIF isDefined("form.approval")>1,<CFELSE>NULL,</CFIF>
			'#session.username#', getdate(), <CFIF isDefined("form.subselect")>1<CFELSE>NULL</CFIF>
			,<CFIF isDefined("form.imultipleselect")>1<cfelse>NULL</CFIF> )
		</cfquery>
	<cfelse>
		<cfset message = "Service already exists in the database.">
	</cfif>
</CFIF>


<CFLOCATION URL="#theUrl#&message=#message#" addtoken="false">

</CFOUTPUT>