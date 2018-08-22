
<CFOUTPUT>
<CFSET DSN='TIPS4'>

<!--- ==============================================================================
Retrieve Time Stamp
=============================================================================== --->
<CFQUERY NAME='qTimeStamp' DATASOURCE='#DSN#'>
	SELECT	getdate() as Stamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.Stamp)>

<!--- ==============================================================================
Retriev Period Information
=============================================================================== --->
<CFQUERY NAME='qPeriod' DATASOURCE="#DSN#">
	SELECT	* FROM AssessmentPeriod WHERE dtRowDeleted IS NULL AND iAssessmentPeriod_ID = #form.period#
</CFQUERY>

<!--- ==============================================================================
Check for any existing records for this house and this period
=============================================================================== --->
<CFQUERY NAME='qCheckRecords' DATASOURCE='#DSN#'>
	SELECT	*
	FROM	AssessmentMaster AM
	LEFT JOIN AssessmentDetail AD ON (AD.iAssessmentMaster_ID = AM.iAssessmentMaster_ID AND AD.dtRowDeleted IS NULL)
	WHERE	AM.iAssessmentPeriod_ID = #form.Period#
	AND		AM.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	AND		AM.dtRowDeleted IS NULL
</CFQUERY>

<CFIF qCheckRecords.RecordCount EQ 0>
	<CFTRANSACTION>
		<!--- ==============================================================================
		Create New Master Record
		=============================================================================== --->
		<CFQUERY NAME='qNewMaster' DATASOURCE='#DSN#'>
			INSERT INTO AssessmentMaster	
			(	[iAssessmentPeriod_ID],	[iHouse_ID], [cDescription], [cComments], [cRowStartUser_ID], [dtRowStart]		
			)VALUES(
				#form.Period#, #SESSION.qSelectedHouse.iHouse_ID#, '#qPeriod.cDescription#', NULL, '#SESSION.USERNAME#', #TimeStamp# 
			)
		</CFQUERY>
	</CFTRANSACTION>	
<CFELSE>
	<!--- ==============================================================================
	Create list of tenants with records in database
	=============================================================================== --->
	<CFSET TenantsWithRecords = ValueList(qCheckRecords.iTenant_ID)>
	<CFIF IsDefined("form.HeaderComments")>
		<CFTRANSACTION>
			<!--- ==============================================================================
			Update Master Record
			=============================================================================== --->
			<CFQUERY NAME='qUpdateMaster' DATASOURCE='#DSN#'>
				UPDATE AssessmentMaster
				SET 	<CFIF form.HeaderComments NEQ ''> cComments = '#TRIM(form.HeaderComments)#',<CFELSE> cComments = NULL, </CFIF>
						cRowStartUser_ID = '#SESSION.USERNAME#',
						dtRowStart = #TimeStamp#
				WHERE 	iAssessmentPeriod_ID = #form.period#
				AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			</CFQUERY>
		</CFTRANSACTION>
	</CFIF>
</CFIF>

<!--- ==============================================================================
Retreive current master record for this house and this period
=============================================================================== --->
<CFQUERY NAME='qMasterRecord' DATASOURCE='#DSN#'>
	SELECT	*
	FROM	AssessmentMaster AM
	WHERE	AM.iAssessmentPeriod_ID = #form.Period#
	AND		AM.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	AND		AM.dtRowDeleted IS NULL
</CFQUERY>
<CFSET MasterRecord = qMasterRecord.iAssessmentMaster_ID>

<!--- ==============================================================================
Collect List of All Tenant ID Numbers
=============================================================================== --->
<CFSET COUNTER = 1>
<CFSET TenantList = ''>
<CFLOOP INDEX=I LIST="#form.fieldnames#">
	<CFIF Find('IP', I, 1) GT 0> 
		<CFSET ID = MID(I, 3, LEN(I))>	
		<CFIF COUNTER EQ 1> <CFSET TenantList = ID>	<CFELSE> <CFSET TenantList = TenantList & ',' & ID>	</CFIF>	
		<CFSET COUNTER = COUNTER + 1>
	</CFIF>
</CFLOOP>

<CFIF Remote_Addr EQ '10.1.0.201'>#ListLen(TenantList,',')#</CFIF>
<!--- ==============================================================================
DEBUG
<B>#TenantList#</B>
=============================================================================== --->

<!--- ==============================================================================
Collect list of tenants with form variables submitted
=============================================================================== --->
<CFSET COUNTER2 = 1>
<CFSET TenantsWithChanges = ''>
<CFLOOP INDEX=I LIST="#TenantList#" DELIMITERS=",">
	<CFIF Evaluate('form.IP' & I) NEQ '' OR Evaluate('form.cComments' & I) NEQ '' OR Evaluate('form.cRDOComments' & I) NEQ ''>
		<!--- #I#<BR> --->
		<CFIF COUNTER2 EQ 1> <CFSET TenantsWithChanges = I>	<CFELSE> <CFSET TenantsWithChanges = TenantsWithChanges & ',' & I></CFIF>	
		<CFSET COUNTER2 = COUNTER2 + 1>
	</CFIF>
</CFLOOP>

<!--- ==============================================================================
DEBUG
<B>#TenantsWithChanges#</B><BR>
=============================================================================== --->
<!--- 
WE DO NOT NEED TO DELETE DETAILS SINCE WE CHECK FOR CHANGES AND INSERTS
<CFIF IsDefined("TenantsWithRecords") AND NOT IsDefined("form.RDOCommentsOnly")>
	<CFLOOP INDEX=Existing LIST="#TenantsWithRecords#" DELIMITERS=",">
		<CFIF ListFindNoCase(TenantsWithChanges, Existing, ",") EQ 0>
			<!--- ==============================================================================
			Delete Detail
			=============================================================================== --->
			<CFQUERY NAME='qDeleteDetail' DATASOURCE='#DSN#'>
				UPDATE 	AssessmentDetail
				SET 	dtRowDeleted = #TimeStamp#,
						cRowDeletedUser_ID = '#SESSION.USERNAME#'
				WHERE 	iTenant_ID = #Existing#
				AND		iAssessmentMaster_ID = #qMasterRecord.iAssessmentMaster_ID#
			</CFQUERY>
			DELETING #Existing#<BR>
		</CFIF>
	</CFLOOP>
</CFIF>
<CFLOOP INDEX=ID LIST="#TenantsWithChanges#">#ID#,</CFLOOP> 
--->

<CFLOOP INDEX=ID LIST="#TenantsWithChanges#">	

	<CFSET POINTS = Evaluate('form.IP' & ID)> 
	<CFIF POINTS EQ ''> <CFSET POINTS = 0> </CFIF>
	<CFSET COMMENTS = Evaluate('form.cComments' & ID)>
	<CFSET RDOCOMMENTS = Evaluate('form.cRDOComments' & ID)>
	
	<CFQUERY NAME='qCheckDetail' DATASOURCE='#DSN#'>
		SELECT	iAssessmentDetail_ID, cComments, cRDOComments, iIndicatedPoints
		FROM	AssessmentDetail
		WHERE	dtRowDeleted IS NULL
		AND		iTenant_ID = #ID#
		AND		iAssessmentMaster_ID = #MasterRecord#
	</CFQUERY>
		
	<CFIF qCheckDetail.RecordCount EQ 0>
		<!--- ==============================================================================
		Insert New Detail
		=============================================================================== --->
		<CFQUERY NAME='qNewDetail' DATASOURCE='#DSN#'>
			INSERT INTO AssessmentDetail
			( iAssessmentMaster_ID, iTenant_ID, iIndicatedPoints, cComments, cRDOComments, cRowStartUser_ID, dtRowStart )
			VALUES
			( #qMasterRecord.iAssessmentMaster_ID# ,#ID# ,#POINTS# ,'#comments#'
				,<CFIF RDOComments NEQ "">'#RDOComments#'<CFELSE> NULL </CFIF>
				,'#SESSION.USERNAME#' ,#TimeStamp#
			)
		</CFQUERY>
		Insert #ID#, #POINTS#, '#COMMENTS#'<BR>
	<CFELSEIF Comments NEQ qCheckDetail.cComments OR RDOComments NEQ qCheckDetail.cRDOComments OR qCheckDetail.iIndicatedPoints NEQ Points>
<!--- ==================================================================================================
		<CFQUERY NAME="qAnyChanges" DATASOURCE="#DSN#">
			SELECT	*
			FROM	AssessmentDetail
			WHERE	iAssessmentMaster_ID = #qMasterRecord.iAssessmentMaster_ID# 
			AND iTenant_ID = #ID# 
			AND iIndicatedPoints = #Points#
			AND cComments <CFIF Comments NEQ qCheckDetail.cComments AND Comments NEQ ''>= '#TRIM(comments)#' <CFELSE> IS NULL </CFIF>
			AND cRDOComments <CFIF RDOComments NEQ qCheckDetail.cRDOComments AND RDOComments NEQ ''>= '#TRIM(RDOcomments)#' <CFELSE> IS NULL </CFIF>
		</CFQUERY>
================================================================================================== --->
		
		<CFIF qCheckDetail.RecordCount GT 0>
			<!--- ==============================================================================
			Update Detail
			=============================================================================== --->
			<CFQUERY NAME='qUpdateDetail' DATASOURCE='#DSN#'>
				UPDATE 	AssessmentDetail
				SET 	iAssessmentMaster_ID = #qMasterRecord.iAssessmentMaster_ID#, 
				iTenant_ID = #ID#, 
				<CFIF qCheckDetail.iIndicatedPoints NEQ Points>iIndicatedPoints = #Points#, </CFIF>
				<CFIF qCheckDetail.cComments NEQ TRIM(Comments)> cComments = <CFIF Comments NEQ ''>'#comments#', <CFELSE> NULL, </CFIF> </CFIF>
				<CFIF qCheckDetail.cRDOComments NEQ TRIM(RDOcomments)> cRDOComments = <CFIF TRIM(RDOComments) NEQ ''>'#RDOcomments#', <CFELSE> NULL, </CFIF> </CFIF>
				cRowStartUser_ID = '#SESSION.USERNAME#', 
				dtRowStart = #TimeStamp# 
				WHERE 	iAssessmentDetail_ID = #qCheckDetail.iAssessmentDetail_ID#
			</CFQUERY>
			UPDATE #ID# ID, #POINTS# POINTS, #COMMENTS# Comments, #RDOComments# RDOComments<BR>
		<CFELSE>
			<B>.</B>
		</CFIF>	
	</CFIF>	
</CFLOOP>

<CFIF REMOTE_ADDR EQ '10.1.0.201'>
	<A NAME="start" HREF="../AssessmentReview.cfm?period=#form.period#">Continue</A>
	<SCRIPT>location.hash= 'start';</SCRIPT>
<CFELSE>
	<CFLOCATION URL="../AssessmentReview.cfm?period=#form.period#" ADDTOKEN="No">
</CFIF>

</CFOUTPUT>