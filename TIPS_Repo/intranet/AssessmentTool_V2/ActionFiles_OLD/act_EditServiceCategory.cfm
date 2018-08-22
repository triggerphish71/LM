
<CFOUTPUT>

<cfset message = "">
<cfset theUrl = "">

<cfif FindNoCase("message",CGI.HTTP_REFERER)>
	<cfset theUrl = LEFT(cgi.HTTP_REFERER,FindNoCase("message",CGI.HTTP_REFERER) - 2)>
<cfelse>
	<cfset theUrl = CGI.HTTP_REFERER>
</cfif>

<CFIF isDefined("form.iservicecategory_id") AND len(trim(form.iservicecategory_id)) gt 0>

	<CFQUERY NAME="qUpdateCategory" DATASOURCE="#application.datasource#">
		update 
			servicecategories
		set 
			 iassessmenttool_id = #trim(form.iassessmenttool_id)#
			,cdescription = '#trim(form.cdescription)#' 
			,csortorder = '#trim(form.cSortOrder)#' 
			,crowstartuser_id = '#session.username#'
			,dtrowstart=getdate()
			<CFIF isDefined("form.multiple")>
			,imultipleselect = 1
			<CFELSE>
			,imultipleselect = NULL
			</CFIF>
		where 
			iservicecategory_id = #form.iservicecategory_id#
	</CFQUERY>

<CFELSE>

	<CFQUERY NAME="check" DATASOURCE="#application.datasource#">
		Select * from servicecategories where dtrowdeleted is null
		and cdescription  = '#trim(form.cdescription)#' and iassessmenttool_id = #form.iassessmenttool_id#
	</cfquery>

	<cfif check.recordcount eq 0>
		<CFQUERY NAME="check" DATASOURCE="#application.datasource#">
			INSERT INTO servicecategories
				( [iassessmenttool_id], [cDescription], [cSortOrder], [cRowStartUser_ID], [dtRowStart])
				VALUES( #trim(form.iassessmenttool_id)#, '#trim(form.cdescription)#', '#trim(form.cSortOrder)#', '#session.username#', getdate() )
		</cfquery>
	<cfelse>
		<cfset message = "Service already exists in the database.">
	</cfif>

</CFIF>

<CFLOCATION URL="#theUrl#&message=#message#" addtoken="false">

</CFOUTPUT>