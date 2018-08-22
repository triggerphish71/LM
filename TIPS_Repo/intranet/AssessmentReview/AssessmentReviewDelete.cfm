<cfoutput>
<cfset DSN='TIPS4'>

<cftry>
<cftransaction>

<!--- retrieve period --->
<cfquery name="qdetails" datasource="#dsn#">
select * from assessmentdetail ad
join assessmentmaster am on am.iassessmentmaster_id = ad.iassessmentmaster_id and ad.dtrowdeleted is null
and ad.dtrowdeleted is null
where iassessmentdetail_id = #trim(url.did)#
</cfquery>

<!--- delete chosen record --->
<cfquery name="qDeleteRecord" datasource="#dsn#">
update assessmentdetail
set dtrowdeleted = getdate(), crowdeleteduser_id = '#trim(session.username)#'
where iassessmentdetail_id = #trim(url.did)#
</cfquery>

<!---
<cfquery name="qerror" datasource="#dsn#">
selart getdate()
</cfquery>
--->

</cftransaction>

<cflocation url="assessmentreview.cfm?period=#qdetails.iassessmentperiod_id#">

<cfcatch type="any">
<cfdump var="#cfcatch#">
<cfabort>
</cfcatch>

</cftry>

</cfoutput>