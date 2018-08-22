<cfoutput>
	
<cfquery name="deleteservicecategory" datasource="#application.datasource#">
update servicecategories
set dtrowdeleted=getdate(), crowdeleteduser_id='#session.username#'
where iservicecategory_id = #url.serviceCategoryId#
</cfquery>

<cflocation url="#cgi.HTTP_REFERER#" addtoken="false">

</cfoutput>