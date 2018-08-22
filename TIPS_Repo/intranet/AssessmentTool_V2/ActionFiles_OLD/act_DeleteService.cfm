<cfoutput>

<cfquery name="deleteservice" datasource="#application.datasource#">
update servicelist
set dtrowdeleted=getdate(), crowdeleteduser_id='#session.username#'
where iservicelist_id = #url.serviceId#
</cfquery>

<cflocation url="#cgi.HTTP_REFERER#" addtoken="false">

</cfoutput>