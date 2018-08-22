<cfoutput> 
 
<cfquery name="qsubservice" datasource="#application.datasource#"> 
select * from subservicelist where dtrowdeleted is null 
and isubservicelist_id = #url.subServiceId# 
</cfquery> 
 
<cfquery name="deleteservice" datasource="#application.datasource#"> 
update subservicelist 
set dtrowdeleted=getdate(), crowdeleteduser_id='#session.username#' 
where isubservicelist_id = #url.subServiceId# 
</cfquery> 
 
<cflocation url="#CGI.HTTP_REFERER#" addtoken="false"> 
 
</cfoutput>