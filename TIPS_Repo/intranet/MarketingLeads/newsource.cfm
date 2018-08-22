<cfoutput>
<cfset DSN='LeadTracking'>
<cfscript>
	if (isDefined("form.iresident_id") and form.iresident_id neq ''){ iresident_id=form.iresident_id; }
	else if (isDefined("form.residents") and form.residents neq '' and form.residents neq 'add') { iresident_id=form.residents; }
	else { iresident_id='NULL'; }
	
	if ( (IsDefined("form.iSource_ID") and form.iSource_ID NEQ "") OR (IsDefined("iGroup_ID") and form.iGroup_ID NEQ "") ) {
		writeoutput("<strong>Add record</strong><BR>record with group or source id<BR>");
		if (IsDefined("form.iSource_ID") and form.iSource_ID NEQ ""){ iSource_ID = form.iSource_ID; iGroup_ID = 'NULL'; }
		if (IsDefined("form.iGroup_ID") and form.iGroup_ID NEQ ""){ Count = len(form.igroup_ID)-1; iGroup_ID = LEFT(form.iGroup_ID,Count); iSource_ID = 'NULL'; }	
		writeoutput("<BR><BR>");
	}
</cfscript>

<cftransaction>

<cfif IsDefined("form.newsource") and NOT IsDefined("form.groupname")>
	<strong>add/edit source and assign group</strong><BR>

	<!--- Check for existing records --->
	<cfquery name="qSourceCheck" DATASOURCE="#DSN#">
		select * from Sources where dtRowDeleted is null and cDescription = '#trim(form.newsource)#' 
		and iGroup_ID = #trim(form.groups)# 
	</cfquery>	
	
	<cfif qSourceCheck.RecordCount EQ 0>
		<!--- Add new Source if one does not exist --->
		<cfquery name="qInsertSource" DATASOURCE="#DSN#">	
		insert into Sources
		(iGroup_ID ,cDescription ,cRowStartUser_ID ,dtRowStart) values (#trim(form.groups)# ,'#trim(form.newsource)#' ,'#trim(SESSION.userName)#' ,getdate() )
		</cfquery>
	<cfelse>
		<!--- Update Existing Record --->
		<cfquery name="qUpdateSource" DATASOURCE="#DSN#">	
		update Sources
		set iGroup_ID = #trim(form.groups)# ,cDescription = '#trim(form.newsource)#' ,cRowStartUser_ID = '#trim(SESSION.userName)#' ,dtRowStart = getdate()
		where iSource_ID = #qSourceCheck.iSource_ID#
		</cfquery>
	</cfif>

	<!--- Retrieve the changed record --->
	<cfquery name="qThisSource" DATASOURCE="#DSN#">
		select * from Sources where dtRowDeleted is null
		and cRowStartUser_ID = '#trim(SESSION.userName)#' and cDescription = '#trim(form.newsource)#' 
		and iGroup_ID = #form.groups#
	</cfquery>	
	
<cfset iSource_ID = qThisSource.iSource_ID>
<cfset iGroup_ID = 'NULL'>
</cfif>
<BR>
<BR>

<cfif IsDefined("form.newsource") and IsDefined("form.groupname")>
	<cfquery name="qInsertFull" DATASOURCE="#DSN#">
	declare @iGroup_ID int
	
	print 'Add new group with selectedCategory'
		insert into Groups
		(	iCategory_ID ,iHouse_ID ,cDescription ,cRowStartUser_ID ,dtRowStart 
		)values(
			#form.categories# ,#SESSION.qSelectedHouse.iHouse_ID# ,'#trim(form.groupname)#' ,'#trim(SESSION.USERNAME)#' ,getdate() )	
			
	select @igroup_ID = iGroup_ID 
	from Groups 
	where dtRowDeleted is null and iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# and icategory_ID = #form.categories#
	AND	cDescription = '#trim(form.groupname)#' AND	cRowStartUser_ID = '#trim(SESSION.USERNAME)#'						

	print 'Add New Source with group'
		insert into Sources
		(iGroup_ID ,cDescription ,cRowStartUser_ID ,dtRowStart) values (@igroup_ID ,'#trim(form.newsource)#' ,'#trim(SESSION.userName)#' ,getdate())
	</cfquery>	
	
	<!--- Retrieve the changed record --->
	<cfquery name="qThisSource" DATASOURCE="#DSN#">
		select * from Sources where	dtRowDeleted is null
		AND cRowStartUser_ID = '#trim(SESSION.userName)#' and cDescription = '#trim(form.newsource)#'
		AND	dtRowStart between DateAdd(ss,-10,getdate()) and DateAdd(ss,10,getdate())
	</cfquery>
		
<cfset iSource_ID = qThisSource.iSource_ID>
<!--- <cfset iSource_ID = 'TEMP2'> --->
<cfset iGroup_ID = 'NULL'>				
</cfif>
<BR>
<BR>

<!--- =======================================================================
Add or Edit Tenant Information 
=======================================================================  --->
<cfquery name="qResidentCheck" DATASOURCE="#DSN#">
	select * from Resident
	where	dtRowDeleted is null
	<cfif IsDefined("iResident_ID") and iResident_ID NEQ ''>
		AND iResident_ID = #iResident_ID#
	<cfelse>
		AND cAddressLine1='#trim(cAddress)#' and cFirstName='#trim(form.cFirstName)#' and cLastName='#trim(form.cLastName)#'		
	</cfif>	
</cfquery>

<cfif qResidentCheck.RecordCount EQ 0>
	<!--- Create New Tenant with State Record --->
	<cfquery name="qNewResident" DATASOURCE="#DSN#">
	Declare @iResident_ID int
	declare @timestmp datetime
	SELECT	@timestmp = getdate()
	
		insert into Resident
		( cFirstName ,cLastName ,dtBirthdate ,cSSN ,cSex ,cAddressLine1 ,cAddressLine2 ,cCity ,cStateCode ,cZipCode ,cPhoneNumber1 
			,cPhoneNumber2 ,cRowStartUser_ID ,dtRowStart)
		values
		( '#trim(form.cFirstName)#', '#trim(form.cLastName)#', 
			<CFTRY>#CreateODBCDateTime(form.dtBirthDate)#, <CFCATCH TYPE="any"> NULL, </CFCATCH></CFTRY>
			'#trim(form.cSSN)#', '#trim(form.cSex)#', '#trim(form.cAddress)#', NULL, '#trim(form.cCity)#', 
			'#trim(form.cStateCode)#', '#trim(form.cZipCode)#', '#trim(form.cPhoneNumber)#', NULL, 
			'#trim(SESSION.UserName)#', @timestmp
		)
		
		SELECT	@iResident_ID = iResident_ID from Resident where dtRowDeleted is null
		AND	cFirstName='#trim(form.cFirstName)#' and cLastName='#trim(form.cLastName)#'
		AND	cRowStartUser_ID = '#trim(SESSION.USERNAME)#'
		
		print @iResident_ID
		
		insert into ResidentState
			(	iResident_ID, iHouse_ID, iStatus_ID, iMaritalStatus_ID, iDecisionTime_ID, iCurrentSituation_ID, iAptPrefType_ID, iSource_ID, iGroup_ID, cRowStartUser_ID, dtRowStart
			)values(
			@iResident_ID, #SESSION.qSelectedHouse.iHouse_ID#, 1, #form.iMaritalStatus_ID#, #form.iDecisionTime_ID#, #form.iCurrentSituation_ID#, #form.iAptType_ID#, 
			#iSource_ID#, #iGroup_ID#, '#SESSION.USERNAME#', @timestmp)
 	</cfquery>
	<cfquery name='qResident' DATASOURCE='#DSN#'>
		select iResident_ID from resident where dtrowdeleted is null 
		and cRowStartUser_id='#Session.UserName#' and cfirstname='#trim(form.cFirstName)#' 
		and clastname='#trim(form.cLastName)#'
		order by dtrowstart desc
	</cfquery>
	<cfset iResident_ID = qResident.iResident_ID>
	<!--- #trim(form.iStatus_ID)# --->
<cfelse>
	<cfquery name="qCheckForResidentChanges" DATASOURCE="#DSN#">
		select * from Resident R where R.dtRowDeleted is null
		and R.cFirstName = '#trim(form.cFirstName)#' and R.cLastName = '#trim(form.cLastName)#'
		and R.dtBirthDate <cfif Len(form.dtBirthDate) GT 0>= #CreateODBCDateTime(form.dtBirthDate)#<cfelse>is null</cfif>
		and	R.cSSN = '#trim(form.cSSN)#' and R.cSex = '#trim(form.cSex)#'
		and	R.cAddressLine1 = '#trim(form.cAddress)#' and R.cCity = '#trim(form.cCity)#'
		and	R.cStateCode = '#trim(form.cStateCode)#' and R.cZipCode = '#trim(form.cZipCode)#'
		and	R.cPhoneNumber1 = '#trim(form.cPhoneNumber)#'	
	</cfquery>
	
	<cfif qCheckForResidentChanges.RecordCount EQ 0>
		<cfquery name="qUpdateResident" DATASOURCE="#DSN#">
			UPDATE	Resident
			SET		dtRowStart = getdate()
					,cRowStartUser_ID = '#SESSION.UserName#'				
					,cFirstName = '#trim(form.cFirstName)#'
					,cLastName = '#trim(form.cLastName)#'
					,dtBirthDate = <cfif Len(form.dtBirthDate) GT 0> #CreateODBCDateTime(form.dtBirthDate)# <cfelse>NULL</cfif>
					,cSSN = '#trim(form.cSSN)#'
					,cSex = '#trim(form.cSex)#'
					,cAddressLine1 = '#trim(form.cAddress)#'
					,cCity = '#trim(form.cCity)#'
					,cStateCode = '#trim(form.cStateCode)#'
					,cZipCode = '#trim(form.cZipCode)#'
					,cPhoneNumber1 = '#trim(form.cPhoneNumber)#'						
			where 	iResident_ID = #qResidentCheck.iResident_ID#	
		</cfquery>
	<cfelse>
		No Resident Info. Changes <BR>
	</cfif>
	
	<cfquery name="qCheckForStateChanges" DATASOURCE="#DSN#">
		SELECT	* from ResidentState RS where RS.dtRowDeleted is null
		and	RS.iResident_ID = #qResidentCheck.iResident_ID# and	RS.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		and	RS.iStatus_ID = #trim(form.iStatus_ID)# and	RS.iMaritalStatus_ID = #form.iMaritalStatus_ID#
		and	RS.iDecisionTime_ID = #form.iDecisionTime_ID# and RS.iCurrentSituation_ID = #form.iCurrentSituation_ID#
		and RS.iAptPrefType_ID = #form.iAptType_ID#
		and	RS.iSource_ID <cfif Variables.iSource_ID NEQ "NULL">= #iSource_ID#<cfelse> is null </cfif>
		and	RS.iGroup_ID <cfif Variables.iGroup_ID NEQ "NULL">= #iGroup_ID#<cfelse> is null </cfif>	
	</cfquery>
	
	<cfif qCheckforStateChanges.RecordCount EQ 0>	
		<!--- Update Tenant State Record --->
		<cfquery name="qUpdateResident" DATASOURCE="#DSN#">
			UPDATE	ResidentState
			SET		cRowStartUser_ID = '#trim(SESSION.UserName)#' 
					,dtRowStart = getdate()
					,iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
					,iStatus_ID = #trim(form.iStatus_ID)#
					,iMaritalStatus_ID = #form.iMaritalStatus_ID#
					,iDecisionTime_ID = #form.iDecisionTime_ID#
					,iCurrentSituation_ID = #form.iCurrentSituation_ID#
					,iAptPrefType_ID = #form.iAptType_ID#
					,iSource_ID = #iSource_ID#
					,iGroup_ID = #iGroup_ID#
			where	iResident_ID = #qResidentCheck.iResident_ID#
		</cfquery>
	<cfelse>
		NO CHANGES DETECTED <BR>
	</cfif>
</cfif>


<cfif IsDefined("cInquirerFirstName") and form.cInquirerFirstName NEQ "">

<cfquery name="qInquirerCheck" DATASOURCE="#DSN#">
	SELECT	count(*) as count from Inquirer where dtRowDeleted is null
	and	cFirstName = '#trim(form.cInquirerFirstName)#' and cLastName = '#trim(form.cInquirerLastName)#'
	and	cAddress = '#trim(form.cInquirerAddress)#' and cCity = '#trim(form.cInquirerCity)#'
	and	cStateCode = '#trim(form.cInquirerState)#' and cZipCode = '#trim(form.cInquirerZip)#'
	and	cPhoneNumber1 <cfif trim(form.cInquirerPhone1) NEQ ''>= '#trim(form.cInquirerPhone1)#'<cfelse> is null </cfif>
	and	cPhoneNumber2 <cfif trim(form.cInquirerPhone2) NEQ ''>= '#trim(form.cInquirerPhone2)#'<cfelse> is null </cfif>
	<cfif IsDefined("form.iInquirer_ID")>AND iInquirer_ID = #form.iInquirer_ID#  </cfif>
</cfquery>

<cfif qInquirerCheck.count gt 0>
<cfquery name="qInquirerLookup" DATASOURCE="#DSN#">
	select iinquirer_id from Inquirer where dtRowDeleted is null
	and	cFirstName = '#trim(form.cInquirerFirstName)#' and cLastName = '#trim(form.cInquirerLastName)#'
	and	cAddress = '#trim(form.cInquirerAddress)#' and cCity = '#trim(form.cInquirerCity)#'
	and	cStateCode = '#trim(form.cInquirerState)#' and cZipCode = '#trim(form.cInquirerZip)#'
	and	cPhoneNumber1 <cfif trim(form.cInquirerPhone1) NEQ ''>= '#trim(form.cInquirerPhone1)#'<cfelse> is null </cfif>
	and	cPhoneNumber2 <cfif trim(form.cInquirerPhone2) NEQ ''>= '#trim(form.cInquirerPhone2)#'<cfelse> is null </cfif>
	<cfif IsDefined("form.iInquirer_ID")>AND iInquirer_ID = #form.iInquirer_ID#  </cfif>
</cfquery>
</cfif>

<cfif qInquirerCheck.count EQ 0 and qInquirerCheck.Recordcount EQ 1 and NOT IsDefined("form.iInquirer_ID")>
	<cfquery name="qInsertInquirer" DATASOURCE="#DSN#">
		Declare @iInquirer_ID int
		declare @timestmp datetime
		SELECT	@timestmp = getdate()
	
		insert into Inquirer
		(	cFirstName, cLastName, cAddress, cCity, cStateCode, cZipCode, cPhoneNumber1, cPhoneNumber2, cRowStartUser_ID, dtRowStart
		)values(
			'#trim(form.cInquirerFirstName)#', '#trim(form.cInquirerLastName)#', '#trim(form.cInquirerAddress)#', '#trim(form.cInquirerCity)#', 
			'#trim(form.cInquirerState)#', '#trim(form.cInquirerZip)#', '#trim(form.cInquirerPhone1)#', '#trim(form.cInquirerPhone2)#',
			'#trim(SESSION.UserName)#', getdate()	)
		
		SELECT	@iInquirer_ID = iInquirer_ID
		from Inquirer
		where dtRowDeleted is null
		and	cFirstName = '#trim(form.cInquirerFirstName)#' and cLastName = '#trim(form.cInquirerLastName)#'
		and	cAddress = '#trim(form.cInquirerAddress)#' and cRowStartUser_ID = '#trim(SESSION.UserName)#'
		and	dtRowStart between DateAdd(ss,-10,getdate()) and DateAdd(ss,10,getdate())
		
		insert into InquirerToResidentLink
		(iHouse_ID, iResident_ID, iInquirer_ID, cRowStartUser_ID, dtRowStart)
		values
		(#SESSION.qSelectedHouse.iHouse_ID#, #iResident_ID#, @iInquirer_ID, '#trim(SESSION.UserName)#', getdate() )
	</cfquery>	
</cfif>

<cfif IsDefined("form.iInquirer_ID") OR qInquirerCheck.count GT 0>
	<cfif not isDefined("form.iInquirer_ID")><cfset form.iinquirer_id = qInquirerLookup.iinquirer_id></cfif>
	<cfquery name="qUpdateInquirer" DATASOURCE="#DSN#">
		UPDATE	Inquirer
		SET	cFirstName = '#trim(form.cInquirerFirstName)#'
				,cLastName = '#trim(form.cInquirerLastName)#'
				,cAddress = '#trim(form.cInquirerAddress)#'
				,cCity = '#trim(form.cInquirerCity)#'
				,cStateCode = '#trim(form.cInquirerState)#'
				,cZipCode = '#trim(form.cInquirerZip)#'
				,cPhoneNumber1 <cfif trim(form.cInquirerPhone1) NEQ ''>= '#trim(form.cInquirerPhone1)#'<cfelse>= NULL</cfif>
				,cPhoneNumber2 <cfif trim(form.cInquirerPhone2) NEQ ''>= '#trim(form.cInquirerPhone2)#'<cfelse>= NULL</cfif>
				,cRowStartUser_ID = '#trim(SESSION.UserName)#'
				,dtRowStart = getdate()	
		where	iInquirer_ID = #form.iInquirer_ID#
		
		declare @linkcount int
		select @linkcount = count(*)
		from Inquirer I
		join InquirerToResidentLink IR on (I.iInquirer_ID = IR.iInquirer_ID and IR.dtRowDeleted is null)
		where I.dtRowDeleted is null and IR.iResident_ID = #iResident_ID# and ir.iinquirer_id = #form.iInquirer_ID#
		
		if @linkcount = 0 
		begin
			insert into InquirerToResidentLink
			( iHouse_ID, iResident_ID, iInquirer_ID, cRowStartUser_ID, dtRowStart)
			values
			( #SESSION.qSelectedHouse.iHouse_ID#, #iResident_ID#, #form.iInquirer_ID#, '#SESSION.UserName#', getdate())
		end
	</cfquery>
</cfif>
	
</cfif>

</cftransaction>

<BR><BR>

<cfquery name="qResident" DATASOURCE="#DSN#">
select max(iResident_ID) as iResident_ID from Resident where dtRowDeleted is null
and	cFirstName='#trim(form.cFirstName)#' and cLastName='#trim(form.cLastName)#' 
and	cRowStartUser_ID = '#trim(SESSION.USERNAME)#'
</cfquery>
<cfif qResident.iResident_ID NEQ ""><cfset iResident_ID = qResident.iResident_ID></cfif>

<cfif AUTH_USER eq 'ALC\PaulB'>
	<A HREF="Leads.cfm?iResident_ID=#iResident_ID#">Continue</A>
<cfelse>
	<cflocation url="Leads.cfm?iResident_ID=#iResident_ID#">
</cfif>

</cfoutput>