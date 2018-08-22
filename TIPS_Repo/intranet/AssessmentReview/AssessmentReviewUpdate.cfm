<cftry>
<cfoutput>
<cfset DSN='TIPS4'>

<!--- Retrieve Time Stamp --->
<cfquery name='qTimeStamp' DATASOURCE='#DSN#'>
select getdate() as Stamp
</cfquery>
<cfset TimeStamp = CreateODBCDateTime(qTimeStamp.Stamp)>

<!--- Retriev Period Information  --->
<cfquery name='qPeriod' DATASOURCE="#DSN#">
select * from AssessmentPeriod where dtRowDeleted is null and iAssessmentPeriod_ID = #form.period#
</cfquery>

<!--- Check for any existing records for this house and this period --->
<cfquery name='qCheckRecords' DATASOURCE='#DSN#'>
select * from AssessmentMaster am
left join AssessmentDetail AD on (AD.iAssessmentMaster_ID = am.iAssessmentMaster_ID AND AD.dtRowDeleted IS NULL)
where am.dtRowDeleted is null and am.iAssessmentPeriod_ID = #form.Period#
and am.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</cfquery>

<cfif qCheckRecords.RecordCount EQ 0>
	<cftransaction>
		<!--- Create New Master Record --->
		<cfquery name='qNewMaster' DATASOURCE='#DSN#'>
		insert into AssessmentMaster	
		([iAssessmentPeriod_ID], [iHouse_ID], [cDescription], [cComments], [cRowStartUser_ID], [dtRowStart])
		values
		(#form.Period#, #SESSION.qSelectedHouse.iHouse_ID#, '#qPeriod.cDescription#', NULL, '#session.username#', #TimeStamp# )
		</cfquery>
	</cftransaction>	
<cfelse>
	<!--- Create list of tenants with records in database --->
	<cfset TenantsWithRecords = ValueList(qCheckRecords.iTenant_ID)>
	<cfif IsDefined("form.HeaderComments")>
		<cftransaction>
			<!--- Update Master Record --->
			<cfquery name='qUpdateMaster' DATASOURCE='#DSN#'>
			update AssessmentMaster
			set <cfif form.HeaderComments neq ''> cComments = '#trim(form.HeaderComments)#',<cfelse> cComments = NULL, </cfif>
					cRowStartUser_ID = '#session.username#', dtRowStart = #TimeStamp#
			where iAssessmentPeriod_ID = #form.period# and iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			</cfquery>
		</cftransaction>
	</cfif>
</cfif>

<!--- Retreive current master record for this house and this period --->
<cfquery name='qMasterRecord' DATASOURCE='#DSN#'>
select * from AssessmentMaster am
where am.iAssessmentPeriod_ID = #form.Period#
and am.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
and am.dtRowDeleted is null
</cfquery>
<cfset MasterRecord = qMasterRecord.iAssessmentMaster_ID>

<!--- Collect List of All Tenant ID Numbers --->
<cfset counter = 1>
<cfset TenantList = ''>
<cfloop INDEX=I LIST="#form.fieldnames#">
	<cfif Find('IP', I, 1) GT 0> 
		<cfset ID = MID(I, 3, LEN(I))>	
		<cfif counter EQ 1> <cfset TenantList = ID>	<cfelse> <cfset TenantList = TenantList & ',' & ID>	</cfif>	
		<cfset counter = counter + 1>
	</cfif>
</cfloop>

<cfif IsDefined("AUTH_USER") AND AUTH_USER eq 'ALC\paulb'>#ListLen(TenantList,',')#</cfif>
<!--- DEBUG <B>#TenantList#</B> --->

<!--- Collect list of tenants with form variables submitted --->
<cfset counter2 = 1>
<cfset TenantsWithChanges = ''>
<cfloop INDEX=I LIST="#TenantList#" DELIMITERS=",">
	<cfif Evaluate('form.IP' & I) neq '' OR Evaluate('form.cComments' & I) neq '' OR Evaluate('form.cRDOComments' & I) neq ''>
		<!--- #I#<BR> --->
		<cfif counter2 EQ 1> <cfset TenantsWithChanges = I>	<cfelse> <cfset TenantsWithChanges = TenantsWithChanges & ',' & I></cfif>	
		<cfset counter2 = counter2 + 1>
	</cfif>
</cfloop>

<!--- DEBUG <B>#TenantsWithChanges#</B><BR> --->

<cfquery name='qPeriodDetails' DATASOURCE='#DSN#'>
select ad.*, isNull(ad.cComments,'zzzz') cComments
from assessmentmaster am
join assessmentdetail ad on ad.iassessmentmaster_id = am.iassessmentmaster_id and ad.dtrowdeleted is null
where am.dtrowdeleted is null
and ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
and iassessmentperiod_id = #form.Period#
</cfquery>

<cfloop index="ID" list="#TenantsWithChanges#">	
	<cfscript>
	points = Evaluate('form.IP' & ID); if (POINTS EQ '') { POINTS = 0; }
	comments = Evaluate('form.cComments' & ID); RDOCOMMENTS = Evaluate('form.cRDOComments' & ID);
	</cfscript>

	<cfquery name='qCheckDetail' DBTYPE='QUERY'>
	select iAssessmentDetail_ID, cComments, cRDOComments, iIndicatedPoints
	from qPeriodDetails WHERE iTenant_ID = #ID#
	</cfquery>
		
	<cfif qCheckDetail.RecordCount EQ 0>
		<!--- Insert New Detail --->
		<cfquery name='qNewDetail' DATASOURCE='#DSN#'>
			insert into AssessmentDetail
			( iAssessmentMaster_ID, iTenant_ID, iIndicatedPoints, cComments, cRDOComments, cRowStartUser_ID, dtRowStart )
			values
			( #qMasterRecord.iAssessmentMaster_ID# ,#ID# ,#POINTS# ,'#comments#'
				,<cfif RDOComments neq "">'#RDOComments#'<cfelse> NULL </cfif> ,'#session.username#' ,#TimeStamp# )
		</cfquery>
		Insert #ID#, #points#, '#comments#'<BR>
	<cfelseIF Comments neq qCheckDetail.cComments OR RDOComments neq qCheckDetail.cRDOComments 
				OR qCheckDetail.iIndicatedPoints neq Points>
	
		<cfif qCheckDetail.RecordCount GT 0>
			<!--- Update Detail --->
			<cfquery name='qUpdateDetail' DATASOURCE='#DSN#'>
				update AssessmentDetail
				set iAssessmentMaster_ID = #qMasterRecord.iAssessmentMaster_ID#, iTenant_ID = #ID#, 
				<cfif qCheckDetail.iIndicatedPoints neq Points>iIndicatedPoints = #Points#, </cfif>
				<cfif qCheckDetail.cComments neq trim(Comments)> cComments = <cfif Comments neq ''>'#comments#', <cfelse> NULL, </cfif> </cfif>
				<cfif qCheckDetail.cRDOComments neq trim(RDOcomments)> cRDOComments = <cfif trim(RDOComments) neq ''>'#RDOcomments#', <cfelse> NULL, </cfif> </cfif>
				cRowStartUser_ID = '#session.username#', 
				dtRowStart = #TimeStamp# 
				WHERE 	iAssessmentDetail_ID = #qCheckDetail.iAssessmentDetail_ID#
			</cfquery>
			UPDATE #ID# ID, #POINTS# POINTS, #COMMENTS# Comments, #RDOComments# RDOComments<BR>
		<cfelse>
			<B>.</B>
		</cfif>	
	</cfif>	
</cfloop>

</cfoutput>

<cfcatch type="any">
	<cfmail to="#session.developerEmailList#" from="TIPS4_CFSERVER@alcco.com" subject="Review form vars" type="html">
	list of form variables.
	<style>td{font-size:xx-small;}</style>
	<table border="1">
	<cfloop index="I" list="#form.fieldnames#" delimiters=",">
	<tr><td>#i#</td><td>#evaluate("form." & i)#</td></tr>
	</cfloop>
	</table>
	<cfdump var="#cfcatch#">
	</cfmail>
</cfcatch>

</cftry>

<cfoutput>
<cfif IsDefined("AUTH_USER") AND AUTH_USER eq 'ALC\paulb'>
	<a name="start" href="AssessmentReview.cfm?period=#form.period#">Continue</A>
	<script>location.hash= 'start';</script>
<cfelse>
	<cflocation url="AssessmentReview.cfm?period=#form.period#" ADDTOKEN="No">
</cfif>
</cfoutput>

