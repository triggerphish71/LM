
<CFOUTPUT>

<cfset message = "">
<cfset theUrl = "">

<cfif FindNoCase("message",CGI.HTTP_REFERER)>
	<cfset theUrl = LEFT(cgi.HTTP_REFERER,FindNoCase("message",CGI.HTTP_REFERER) - 2)>
<cfelse>
	<cfset theUrl = CGI.HTTP_REFERER>
</cfif>

<CFIF isDefined("form.isubservicelist_id") and form.isubservicelist_id neq "">
	<!--- if existing update --->
	<CFQUERY NAME="qUpdateListing" DATASOURCE="#application.datasource#">
	update subservicelist
	set  cDescription='#form.cdescription#'
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
		,flWeight='#form.flweight#'
	where isubservicelist_id = #form.isubservicelist_id#
	</CFQUERY>
<CFELSE>
	<!--- if does not exist add to table--->
	<CFQUERY NAME="check" DATASOURCE="#application.datasource#">
		select *
		from subservicelist sb
		join servicelist sl on sl.iservicelist_id = sb.iservicelist_id and sl.dtrowdeleted is null
		where sb.cdescription  = '#trim(form.cdescription)#<a href="../../../../../../Documents and Settings/ranklam.ALC/Desktop/SubServiceListByPoints.txt"></a><a href="../../../../../../Documents and Settings/ranklam.ALC/Desktop/SubServiceListByLevel.txt"></a><a href="../../../../../../Documents and Settings/ranklam.ALC/Desktop/ServiceListByPoints.txt"></a><a href="../../../../../../Documents and Settings/ranklam.ALC/Desktop/ServiceListByLevel.txt"></a>' 
		and sl.iservicelist_id = #form.iservicelist_id#
		and sb.dtrowdeleted is null
	</cfquery>
	
	<cfif check.recordcount eq 0>
		<CFQUERY NAME="check" DATASOURCE="#application.datasource#">
			INSERT INTO subservicelist
			( iServicelist_id, cDescription, fWeight, flWeight, cGrouping, cSortOrder, bApprovalRequired, cRowStartUser_ID, dtrowstart)
			VALUES
			( #trim(form.iservicelist_id)#, '#trim(form.cdescription)#', '#trim(form.fweight)#', '#trim(form.flweight)#', NULL, '#trim(form.cSortOrder)#', 
			<CFIF isDefined("form.approval")>1,<CFELSE>NULL,</CFIF>
			'#session.username#', getdate() )
	</cfquery>
	<cfelse>
		<cfset message = "Subservice already exists in the database">
	</cfif>
</cfif>


<CFLOCATION URL="#theUrl#&message=#message#" addtoken="false">

</CFOUTPUT>