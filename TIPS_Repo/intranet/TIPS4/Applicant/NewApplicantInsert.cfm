<!--- *********************************************************************************************
Name:       NewApplicantInsert.cfm
Type:       Template
Purpose:    Set SESSION variables and display the main menu.

Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
P.Buendia               17 May 01       Original Authorship
						12032002		Leads Application is now using this file as well
Sfarmer      10/27/2014                 changed #server_name# to cf01                              
********************************************************************************************** --->

<!--- Set variable for timestamp to record corresponding times for transactions --->
<cfquery name="getDate" datasource="#application.datasource#">
select getDate() as stamp
</cfquery>
<cfset timestamp=createODBCDateTime(getDate.Stamp)>

<!--- Reset the house session variable if the resident came from the leads application --->
<cfif isDefined("leads") and leads eq 1>
	<cfquery name='qHouse' datasource='TIPS4'>
	select * from House H 
	join HouseLog HL on (H.iHouse_ID=HL.iHouse_ID and HL.dtRowDeleted IS NULL and H.dtRowDeleted IS NULL)
	where H.dtRowDeleted IS NULL and H.iHouse_ID=#session.qSelectedHouse.iHouse_ID#
	</cfquery>
	
	<cfif not isDefined("session.AcctStamp")>	
		<cfquery name="qstamp" datasource="solomon-houses">
		select cast(Right(CurrPerNbr,2) + '/01/' + left(CurrPerNbr,4) as datetime) as CurrPerNbr from ARSETUP (NOLOCK)
		</cfquery>
		<cflock scope="session" timeout="10"><cfset session.AcctStamp=qstamp.currpernbr></cflock>
	</cfif>
	
	<cfscript>
		CalcHouse=qhouse.cNumber - 1800;
		if (Len(CalcHouse) EQ 2) { HouseNumber='0' & CalcHouse; }
		else if (Len(CalcHouse) EQ 1) { HouseNumber='0' & '0' & CalcHouse; }
		else { HouseNumber='#CalcHouse#'; }
    session.qSelectedHouse=qHouse; session.HouseName=qhouse.cName;
		session.HouseNumber='#Variables.HouseNumber#'; session.nHouse=qhouse.cNumber;
		session.TIPSMonth=qhouse.dtCurrentTipsMonth; session.cSLevelTypeSet=qhouse.cSLevelTypeSet;
		session.HouseClosed	= qhouse.bIsPDclosed; session.cDepositTypeSet	= qHouse.cDepositTypeSet;
		session.cBillingType=trim(qHouse.cBillingType);
	</cfscript>
</cfif>

<cfscript>
	//Concat. First, Middle, Last for Social Security Number
	cSSN=form.First & form.middle & form.last;
	//Concat. Month Day Year for dBirthDate
	dBirthDate=form.month & "/" & form.day & "/" & form.year;
	//Concat. Phone Number from areacode prefix and number
	Phone1=form.areacode1 & form.prefix1 & form.number1;
	Phone2=form.areacode2 & form.prefix2 & form.number2;
	Phone3=form.areacode3 & form.prefix3 & form.number3;
</cfscript>

<!--- 
This will be used to check for duplicate entries : 
When found an exception handling page will be generated 
--->
	<cfquery name="DuplicateCheck" datasource="#application.datasource#">
	select iTenant_ID ,cFirstName ,cLastName ,cSolomonKey ,dBirthDate
	from tenant where dtRowDeleted IS NULL and cFirstName='#trim(form.cFirstName)#'
	and cLastName='#trim(form.cLastname)#'
	and cOutsideAddressLine1='#trim(form.cOutsideAddressLine1)#'
	and	iHouse_ID=#session.qSelectedHouse.iHouse_ID#
	</cfquery>
	
	<cfif DuplicateCheck.RecordCount GT 0 and trim(form.iResidencyType_ID) neq 3>
		<cfquery name="DuplicateStatus" datasource="#application.datasource#">
		select * from TenantState TS
		join TenantStateCodes TSC on TS.iTenantStateCode_ID=TSC.iTenantStateCode_ID and TSC.dtrowdeleted is null
		and TS.dtrowdeleted is null and TS.itenantstatecode_id < 4
		where iTenant_ID=#DuplicateCheck.iTenant_ID#
		</cfquery>
	</cfif>

<cfif isDefined("DuplicateStatus.iTenant_ID") and DuplicateStatus.iResidencyType_ID neq 3>	
	<cfinclude template="../../header.cfm">	
	<cfoutput><B style="font-weight: bold; font-size: 20;">There are already #DuplicateCheck.RecordCount# tenant(s) with this name.</B><BR></cfoutput>
		<table>
			<tr><th>Name</th><th>Account Number</th><th>BirthDate</th><th>Social Security</th></tr>	
			<cfoutput query="DuplicateCheck">
				<tr>
					<td>#DuplicateCheck.cFirstName# #DuplicateCheck.cLastName#</td>
					<td style="text-align: center;">#DuplicateCheck.cSolomonKey#</td>
					<td>#LSDateFormat(DuplicateCheck.dBirthDate, "mm/dd/yyyy")#</td>
					<td>#DuplicateStatus.cDescription#</td>
				</tr>
			</cfoutput>
		</table>
		
	<a href="../Registration/Registration.cfm" style="font-size: 18;"> Click Here to Continue </a>	
	<!--- Include Intranet footer --->	
	<cfinclude template="../../Footer.cfm">		
	<cfabort>
</cfif>

<!--- Retrieve Next SolomonKey From HouseNumber Control --->
<cfquery name="NextSolomonKey" datasource="#application.datasource#">
select cNextSolomonKey from HouseNumberControl where iHouse_ID=#session.qSelectedHouse.iHouse_ID# and dtRowDeleted IS NULL
</cfquery>	

<!--- If Next SolomonKey is less than required 8 digits append appropriate amount of zeros --->	
<cfscript>
if (Len(NextSolomonKey.cNextSolomonKey) EQ 7){ cSolomonKey='0' & '#NextSolomonKey.cNextSolomonKey#'; }
else if (Len(NextSolomonKey.cNextSolomonKey) EQ 6){ cSolomonKey='00' & '#NextSolomonKey.cNextSolomonKey#'; }
else { cSolomonKey='#NextSolomonKey.cNextSolomonKey#'; }
</cfscript>

	
<!--- 
If there is no solomonkey defined... 
IE. this is not a shared billing TenantID then get 
the next solomon key and insert it into the TENANT table
--->
<cfif form.cSolomonKey EQ "">
	<!--- Check Solomon to ensure that this Solomon Key is not Already in use. --->
	<cfquery name="SolomonCheck" datasource="SOLOMON-HOUSES" dbtype="ODBC">
	select custid from customer where custid='#Variables.cSolomonKey#'
	</cfquery>
	
	<!--- If this Solomon Key Already Exists Show Error Screen --->		
		<cfif SolomonCheck.RecordCount GT 0>
			<cfloop index=C from=1 TO=11>
				<cfif C neq 11>
					<cfscript>
					Variables.LEFTcSolomonKey=left(Variables.cSolomonKey,3);
					RightLen=LEN(Variables.cSolomonKey) -3;
					Variables.RightcSolomonKey=right(Variables.cSolomonKey,RightLen) + 1;
					Variables.cSolomonKey=Variables.LEFTcSolomonKey & Variables.RIGHTcSolomonKey;
					</cfscript>
					<cfoutput>#RightLen#<BR> #LEFTcSolomonKey# LEFT #RightcSolomonKey# RIGHT <BR></cfoutput>
					<!--- Check Solomon to ensure that this Solomon Key is not Already in use. --->
					<cfquery name="SolomonCheck" datasource="SOLOMON-HOUSES" dbtype="ODBC">
					select custid from customer where custid='#Variables.cSolomonKey#'
					</cfquery>
					<cfif SolomonCheck.RecordCount EQ 0> <CFBREAK> <cfelse> <cfoutput><B>#SolomonCheck.RecordCount#</B></cfoutput> </cfif>
				<cfelse>		
					This Tenant ID already Exists In Solomon. More than 10 tries ABORTED !!!<BR> <CFABORT>
				</cfif>
			</cfloop>
		</cfif>
</cfif>
	
<cfif (isDefined("SolomonCheck.RecordCount") and SolomonCheck.RecordCount EQ 0) 
		OR form.cSolomonKey neq "" OR session.qSelectedHouse.iHouse_ID EQ 200>

	<cftransaction>
		<!--- Insert new Applicant Record into TIPS --->
		<cfquery name="Applicant" datasource="#application.datasource#">
			insert into	tenant
			( iHouse_ID ,cSolomonKey ,bIsPayer ,cFirstName ,cLastName ,dBirthDate ,cSSN ,cMedicaidNumber 
				,cOutsidePhoneNumber1 ,iOutsidePhoneType1_ID ,cOutsidePhoneNumber2 ,iOutsidePhoneType2_ID
				,cOutsidePhoneNumber3 ,iOutsidePhoneType3_ID ,cOutsideAddressLine1 ,cOutsideAddressLine2
				,cOutsideCity ,cOutsideStateCode ,cOutsideZipCode ,cComments ,cChargeSet ,cSLevelTypeSet ,bAppFeePaid
				,cBillingType ,iRowStartUser_ID ,dtRowStart, cEmail)
			values
			(	#session.qSelectedHouse.iHouse_ID#,
				<cfif form.cSolomonKey EQ ""> '#Variables.cSolomonKey#', <cfelse> '#trim(form.cSolomonKey)#', </cfif>
				1,
				<cfif form.cFirstName neq ""> '#trim(form.cFirstName)#', <cfelse> NULL, </cfif>
				<cfif form.cLastName neq ""> '#trim(form.cLastName)#', <cfelse> NULL, </cfif>
				<cfif dBirthDate neq "//"> '#Variables.dBirthDate#', <cfelse> NULL, </cfif>
				<cfif cSSN neq ""> '#Variables.cSSN#',	<cfelse> '',	</cfif>
				NULL,
				<cfif Variables.Phone1 neq ""> #Variables.Phone1#, <cfelse> NULL, </cfif>
				#form.iOutSidePhoneType1_ID#,
				<cfif Variables.Phone2 neq ""> #Variables.Phone2#, <cfelse> NULL, </cfif>
				#form.iOutSidePhoneType2_ID#,
				<cfif Variables.Phone3 neq ""> #Variables.Phone3#,	<cfelse> NULL, </cfif>
				<cfif form.iOutSidePhoneType3_ID neq ""> #form.iOutSidePhoneType3_ID#, <cfelse> NULL, </cfif>
				<cfif form.cOutsideAddressLine1 neq "">	'#form.cOutsideAddressLine1#', <cfelse> NULL, </cfif>
				<cfif form.cOutsideAddressLine2 neq ""> '#form.cOutsideAddressLine2#', <cfelse> NULL, </cfif>
				<cfif form.cOutsideCity neq "">	'#form.cOutsideCity#', <cfelse> NULL, </cfif>
				<cfif form.cOutsideStateCode neq ""> '#form.cOutsideStateCode#', <cfelse> NULL, </cfif>
				<cfif form.cOutsideZipCode neq ""> '#form.cOutsideZipCode#', <cfelse> NULL, </cfif>
				<cfif form.cComments neq ""> '#trim(form.cComments)#', <cfelse> NULL, </cfif>
				<!--- TEMPORARY CHARGE SET FIX FOR NEW 2003 RATES '200302',
				<cfset HList='36,71,80,124,152,155,179,185'>
				<cfif ListFindNoCase(HList,session.qSelectedHouse.iHouse_ID,",") EQ 0>'200302',<cfelse>NULL,</cfif>
				--->
				<!--- added by Katie 1/5/04: TEMPORARY CHARGE SET FIX FOR NEW 2004 RATES '2004'--->
				<!--- '2004', --->
				NULL,
				'#session.qSelectedHouse.cSLevelTypeSet#',
				<cfif isDefined("form.bApplicationFee")> 1 <cfelse> NULL </cfif>,
				<cfif isdefined("session.cBillingType") and Len(session.cBillingType) gt 0>'#session.cBillingType#',<cfelse>NULL,</cfif>
				#session.UserID# ,#TimeStamp#
				, <cfif form.cEmail neq ""> '#form.cEmail#' <cfelse> NULL </cfif>
			)
		</cfquery>
		
	<!--- Retrieve the TenantID from the last insert statement (called Applicant above) --->
	<cfquery name="GetTenant_ID" datasource="#application.datasource#">
		select Max(iTenant_ID) as iTenant_ID from Tenant
		<cfif form.cSolomonKey EQ "">
		where cSolomonKey='#Variables.cSolomonKey#'
		<cfelse>
		where cSolomonKey='#form.cSolomonKey#' and cFirstName='#form.cFirstName#'
		and cLastName='#form.cLastName#' and cSSN='#Variables.cSSN#'
		</cfif>	
		and	dtRowDeleted is null
	</cfquery>

	<!--- Update the Solomonkey table for next solomonkey --->
	<cfscript>
		cNextSolomonKey=Variables.cSolomonKey + 1;
		if (Len(trim(cNextSolomonKey)) EQ 7) { cNextSolomonKey='0' & cNextSolomonKey; }
		else if (Len(trim(cNextSolomonKey)) EQ 6) { cNextSolomonKey='00' & cNextSolomonKey; }
	</cfscript>
	
	<cfquery name="NextSolomonID" datasource="#application.datasource#">
	update	HouseNumberControl
	set	cNextSolomonKey='#cNextSolomonKey#'
	where dtRowDeleted is null and iHouse_ID=#session.qSelectedHouse.iHouse_ID#
	</cfquery>
		
	<cfquery name="StateDuplicateCheck" datasource="#application.datasource#">
	select iTenant_ID from TenantState where iTenant_ID=#GetTenant_ID.iTenant_ID#
	</cfquery>
	
	<cfif StateDuplicateCheck.RecordCount EQ 0>	
		<!--- Create a record in the Tenant State Table to update the status to REGISTERED --->	
		<cfquery name="Activity" datasource="#application.datasource#">
			insert into TenantState ( iTenant_ID ,dtMoveIn ,dtNoticeDate ,dtMoveOut ,iMoveReasonType_ID ,iTenantStateCode_ID, 
			iResidencyType_ID ,iSPoints ,dtSPEvaluation ,iRowStartUser_ID ,dtRowStart ,iproductline_id
			)values(
			#GetTenant_ID.iTenant_ID# 
			<cfif isDefined("form.dtmovein")>,#form.dtmovein#<cfelse>,NULL </cfif>
			,NULL ,	NULL ,NULL ,1 
			<cfif form.iResidencyType_ID neq ""> ,#trim(form.iResidencyType_ID)# <cfelse> ,NULL </cfif>
			,0 ,NULL ,#session.UserID# ,#TimeStamp# ,#trim(form.iproductline_id)# )
		</cfquery>
	<cfelse>
		<cfquery name="UpdateState" datasource="#application.datasource#">
		update TenantState
		set	iResidencyType_ID=#trim(form.iResidencyType_ID)# ,iTenantStateCode_ID=1 ,iproductline_id = #trim(form.iproductline_id)#
		<cfif isDefined("form.dtmovein")>,dtmovein=#form.dtmovein#</cfif>
		where iTenant_ID=#GetTenant_ID.iTenant_ID#
		</cfquery>
	</cfif>	
		
	<!--- Retrieve All new inserted information for this tenant --->
		<cfquery name="TenantDetail" datasource="#application.datasource#">
		select T.iTenant_ID, TS.iResidencyType_ID, RT.cDescription as Residency
		from Tenant T
		join TenantState TS ON T.iTenant_ID=TS.iTenant_ID
		join ResidencyType RT ON TS.iResidencyType_ID=RT.iResidencyType_ID
		where T.iTenant_ID=#GetTenant_ID.iTenant_ID#
		</cfquery>
		
	</cftransaction>	
	<!--- Insert new Applicant into Solomon --->
	<cfscript>
	if (TenantDetail.iResidencyType_ID IS 2 and TenantDetail.Residency EQ "Medicaid") { CLASS='Medicaid'; }
	else { CLASS='Private'; }
	</cfscript>
	
	<!--- ==============================================================================
	Insert New Solomon Account via Custom Tag.
	Ignore if we are using zetatest house
	Ignore if we are associating with another tenant.
	=============================================================================== --->	
	<cfif session.qSelectedHouse.iHouse_ID neq 200 and form.cSolomonKey EQ "">
		<CF_NewTenantInsert nHouse=#session.nHouse# iTenant_ID=#TenantDetail.iTenant_ID# CLASS="#CLASS#">	
	</cfif>

	<cftransaction>			
		<!--- Write Activity for the Registered Tenant --->	
		<cfquery name="WriteActivity" datasource="#application.datasource#">
		insert into	ActivityLog
		( iActivity_ID, dtActualEffective, iTenant_ID, iHouse_ID, iAptAddress_ID, iSPoints, dtAcctStamp, iRowStartUser_ID, dtRowStart)
		values
		( 1, getDate(), #GetTenant_ID.iTenant_ID#, #session.qSelectedHouse.iHouse_ID#, NULL, NULL, #CreateODBCDateTime(session.AcctStamp)#, #session.UserID#, #TimeStamp# )
		</cfquery>
	</cftransaction>

</cfif>
<cfoutput>

<cfif isDefined("leads") and leads eq 1>
	<cftransaction>
		<cfquery name="qresidentupdate" datasource="LeadTracking">
		update residentstate
		set itenant_id=#getTenant_ID.iTenant_ID# ,dtrowstart=getdate() ,crowstartuser_id='#trim(session.username)#'
		where iresident_id=#trim(form.iResident_ID)#
		</cfquery>
	</cftransaction>
	<cfif trim(form.iStatus_ID) eq 6>
		<cflock scope="session" timeout="10"><cfset session.application="TIPS4"></cflock>
		<script> opener.location.href='http://cf01/intranet/tips4/MoveIn/MoveInForm.CFM?ID=#getTenant_ID.iTenant_ID#'; //self.close(); </script>
	<cfelseif trim(form.iStatus_ID) eq 7>
		<script> opener.location.href='http://cf01/intranet/MarketingLeads/leads.cfm'; //self.close(); </script>
	</cfif>
<cfelse>
	<cfif auth_user eq "ALC\PaulB"> <a href="../Registration/Registration.cfm"> Continue </a> <cfelse> <cflocation url="../Registration/Registration.cfm" ADDTOKEN="No"> </cfif>
</cfif>
</cfoutput>