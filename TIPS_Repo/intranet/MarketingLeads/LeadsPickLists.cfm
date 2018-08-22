<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 08/12/2007 | Created                                                            |
| jcruz		 | 11/03/2008 | changed by Jaime Cruz to fix error during move-in of residents     |
|  			 |  		  | Users being asked to do an assessment even when one was already	   |
|			 |			  | done.															   |
----------------------------------------------------------------------------------------------->


<cfoutput>
<cfset DSN='LeadTracking'>

<!--- <cfset InquiryMethod='Phone,walk-in,reply card,Corporate Reffered,Internet,Other'>
<cfset LeadSource = 'Walk-in,Drive By,Yellow Pages,Special Event,Internet,Refferal-Medical,Refferal-Family,Refferal-Other'>
<cfset Sex = 'Male,Female'>
<cfset MaritalStatus='Married,Single'>
<cfset CareNeeds='Assissted Living, Alzhiemers'>
<cfset AssisstanceRequired='Medications,Meals,Dressing,Shaving/Hair,Bathing,Toileting,Eating,Laundry,Ambulation,Memory support,Other'>
<cfset DecisionTime='One Week,One Month,3 months,6 months,other'>
<cfset AptPreference = 'Studio,1BR,2BR,Companion'>
<cfset CurrentLivingSituation='Home Alone,Home w/spouse,Home w/family,Rents,Owns'> --->

<cfif IsDefined("url.SelectedHouse_ID") OR (NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") OR SESSION.qSelectedHouse.iHouse_ID EQ "")>
	<cfquery name="qHouse" DATASOURCE="TIPS4">
		select * from House where dtRowDeleted IS NULL and iHouse_ID = #SelectedHouse_ID#
	</cfquery>
	<cfset SESSION.qSelectedHouse = qHouse>
</cfif>

<cfquery name="qAptType" DATASOURCE="TIPS4">
select distinct APT.*
from House H
join AptAddress AD ON (AD.iHouse_ID = H.iHouse_ID AND AD.dtRowDeleted IS NULL)
join AptType APT ON (APT.iAptType_ID = AD.iAptType_ID AND APT.dtRowDeleted IS NULL)
where H.dtRowDeleted IS NULL and H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</cfquery>

<cfquery name="qStateCodes" DATASOURCE="TIPS4">
select cStateCode, cStateName from StateCode
</cfquery>

<cfquery name="qCategories" DATASOURCE="#DSN#">
select * from Categories where dtRowDeleted IS NULL
</cfquery>

<cfquery name="qGroups" DATASOURCE="#DSN#">
select * 
from Groups g
where dtRowDeleted IS NULL 
and (iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# or (ihouse_id is null AND 0 >= ( select count(igroup_id) 
		from groups 
		where dtrowdeleted is null 
		and ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
		and isNull(cdescription,'xyz')=g.cdescription
	))) 
order by cDescription
</cfquery>

<cfquery name="qSources" DATASOURCE="#DSN#">
select S.*
from Sources S
join Groups G ON (G.iGroup_ID = S.iGroup_ID AND G.dtRowDeleted IS NULL)
where S.dtRowDeleted IS NULL and (G.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# 
or 0 < (select count(iresidentstate_id) from residentstate rs
join resident r on r.iresident_id = rs.iresident_id and rs.dtrowdeleted is null
and r.dtrowdeleted is null and rs.istatus_id not in (5,6)
where rs.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID# and isource_id = s.isource_id
)

)
order by s.cdescription
</cfquery>
<!---
select S.*
from Sources S
join Groups G ON (G.iGroup_ID = S.iGroup_ID AND G.dtRowDeleted IS NULL)
where S.dtRowDeleted IS NULL and G.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
--->

<cfquery name="qMaritalStatus" DATASOURCE="#DSN#">
select * from MaritalStatus where dtRowDeleted IS NULL
</cfquery>

<cfquery name="qDecisionTime" DATASOURCE="#DSN#">
select * from DecisionTime where dtRowDeleted IS NULL
</cfquery>

<cfquery name="qCurrentSituation" DATASOURCE="#DSN#">
select * from CurrentSituation where dtRowDeleted IS NULL
</cfquery>

<cfquery name="qStatus" DATASOURCE="#DSN#">
select * from Status where dtRowDeleted IS NULL
</cfquery>
<!--- Change made by Jaime Cruz on 11/03/2008 to correct problem during move-in of resident. Users were being asked to create an assessment when one was already done. --->
<cfquery name="qAllResidents" DATASOURCE="#DSN#">
	SELECT	distinct
			r.iResident_ID 
			,r.cFirstName 
			,r.cLastName 
			,r.dtBirthdate
			,r.cSSN
			,ltrim(rtrim(r.cSex)) csex
			,r.cAddressLine1
			,r.cAddressLine2
			,r.cCity
			,r.cStateCode
			,r.cZipCode
			,r.cPhoneNumber1
			,r.cPhoneNumber2
			,r.cRowStartUser_ID
			,r.dtRowStart
			,r.cRowEndUser_ID
			,r.dtRowEnd
			,r.cRowDeletedUser_ID
			,r.dtRowDeleted			
			,RS.*, isNull(S.cDescription,G.cDescription) as sourcename, Stat.cDescription as status ,isNULL(R.dtRowDeleted,0) as residentdeleted, Stat.iSortOrder
			,S.isource_id ,G.igroup_id, ltrim(rtrim(r.csex)) csex
			,(
				select min(dtrowstart) from vw_resident_history
				where dtrowdeleted is null and iresident_id = r.iresident_id
			) as startdate
			,ts.dtmovein
			,(select count(distinct iassessmenttoolmaster_id) from #application.tips4dbserver#.tips4.dbo.assessmenttoolmaster am
				where am.dtrowdeleted is null and am.bbillingactive is not null
				and ( (am.itenant_id = rs.itenant_id)  <!--- and am.iresident_id is null)  --->
					or (am.iresident_id = rs.iresident_id)) <!--- and am.itenant_id is null)) --->
				) numactive
	FROM	Resident R
	JOIN	ResidentState RS ON (R.iResident_ID = RS.iResident_ID AND RS.dtRowDeleted IS NULL)
	join Status Stat ON (Stat.iStatus_ID = RS.iStatus_ID AND Stat.dtRowDeleted IS NULL)
	LEFT JOIN InquirerToResidentLink IR ON (IR.iResident_ID = R.iResident_ID AND IR.dtrowDeleted IS NULL)
	LEFT JOIN Inquirer I ON (I.iInquirer_ID = IR.iInquirer_ID AND I.dtRowDeleted IS NULL)
	LEFT JOIN Sources S ON (S.iSource_ID = RS.iSource_ID AND S.dtRowDeleted IS NULL)
	LEFT JOIN Groups G ON (G.iGroup_ID = RS.iGroup_ID AND G.dtRowDeleted IS NULL)
	left join #application.tips4dbserver#.tips4.dbo.tenantstate ts on ts.itenant_id = rs.itenant_id and ts.dtrowdeleted is null and ts.itenantstatecode_id < 2
	WHERE	R.dtRowDeleted IS NULL
	AND		RS.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	ORDER BY <cfif IsDefined("sort")> 
				<cfset sort=url.sort>
				<cfif sort EQ 'source'>	source 
				<cfelseif sort EQ 'stat'> Stat.iSortOrder
				<cfelseif sort eq 'entered'> r.dtrowstart
				<cfelse> R.cLastName </cfif>
			<cfelse> 
				<cfset sort=''> Stat.iSortOrder 
			</cfif>
</cfquery>

<!--- set filter for qresidents query --->
<cfscript>
if ((IsDefined("url.com") AND url.com EQ 'true') OR (IsDefined("ref") AND ref EQ 'com') ) { filter="iStatus_ID = 6"; }
else if (IsDefined("url.lst") AND url.lst EQ 'true' OR (IsDefined("ref") AND ref EQ 'lst') ) { filter="iStatus_ID = 5"; } 
else { filter="iStatus_ID <> 6 AND iStatus_ID <> 5"; }
</cfscript>
<!--- Retrieve all current non commited residents --->
<cfquery name="qResidents" DBTYPE="QUERY">
	select 
		* 
	from 
		qAllResidents 
	where
		#filter# 
<!--- <cfif IsDefined("url.sort")> 
	<cfset sort=url.sort>
	<cfif sort EQ 'source'>	source 
	<cfelseif sort EQ 'stat'> Stat.iSortOrder
	<cfelseif sort eq 'entered'> r.dtrowstart
	<cfelse> R.cLastName </cfif>
<cfelse> 
	<cfset sort=''> Stat.iSortOrder 
</cfif> --->
</cfquery>

<cfquery name="qContacts" DATASOURCE="#DSN#">
select isNull(I.cFirstName,'HERE') as InquirercFirstName, isNULL(I.cLastName,'none') as InquirercLastName, I.iInquirer_ID, 
		I.cAddress, I.cCity, I.cStateCode, I.cZipCode, I.cPhoneNumber1, I.cPhoneNumber2, IR.iResident_id
from InquirerToResidentLink IR 
join Inquirer I ON (I.iInquirer_ID = IR.iInquirer_ID AND I.dtRowDeleted IS NULL)
join Resident R ON (R.iResident_id = IR.iResident_id AND R.dtrowdeleted is null)
join ResidentState RS ON (RS.iResident_id = R.iResident_id AND RS.dtrowdeleted is null AND RS.iStatus_ID < 5 )
where IR.dtRowDeleted IS NULL and RS.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
order by IR.dtrowstart desc, InquirercLastName
</cfquery>

<cfquery name="qContactList" DATASOURCE="#DSN#">
select distinct isNull(I.cFirstName,'HERE') as InquirercFirstName, isNULL(I.cLastName,'none') as InquirercLastName, I.iInquirer_ID, 
	I.cAddress, I.cCity, I.cStateCode, I.cZipCode, I.cPhoneNumber1, I.cPhoneNumber2
	,count(r.iresident_id) as residentcount
from InquirerToResidentLink IR 
join Inquirer I ON (I.iInquirer_ID = IR.iInquirer_ID AND I.dtRowDeleted IS NULL)
join Resident R ON (R.iResident_id = IR.iResident_id AND R.dtrowdeleted is null)
join  ResidentState RS ON (RS.iResident_id = R.iResident_id AND RS.dtrowdeleted is null AND RS.iStatus_ID < 5 )
where IR.dtRowDeleted IS NULL and RS.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
group by isNull(I.cFirstName,'HERE'), isNULL(I.cLastName,'none'), I.iInquirer_ID, 
	I.cAddress, I.cCity, I.cStateCode, I.cZipCode, I.cPhoneNumber1, I.cPhoneNumber2
order by InquirercLastName
</cfquery>

<cfif Len(ValueList(qResidents.iResident_ID)) GT 0> <cfset ResidentList=ValueList(qResidents.iResident_ID)> <cfelse> <cfset ResidentList=0> </cfif>

<cfquery name='qEvents' DATASOURCE='#DSN#'>
select distinct EM.dtRowStart as EventStart, AT.cDescription as Action, ED.cComments as detailcomments, ED.dtRowStart as detailstart
		,isNull(ED.dtDue,'1900-01-01') as dtdue, ED.iNextActionType_ID, ED.cNextComments, ED.iEvent_ID,
		EM.cShortDescription, EM.cLongDescription, R.iResident_ID, EM.cComments
from EventMaster EM
join EventDetail ED ON (EM.iEvent_ID = ED.iEvent_ID AND ED.dtRowDeleted IS NULL)
join ActionType AT ON (AT.iActionType_ID = ED.iActionType_ID AND AT.dtRowDeleted IS NULL)
join Resident R ON (R.iResident_ID = EM.iResident_ID AND R.dtRowDeleted IS NULL)
join ResidentState RS ON (RS.iResident_id = R.iResident_id AND RS.dtrowdeleted is null AND RS.iStatus_ID not in (5,6) ) 
where EM.dtRowDeleted IS NULL
and EM.iResident_ID IN (#ResidentList#) and RS.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</cfquery>

<cfif IsDefined("iResident_ID") AND iResident_ID NEQ "" OR (IsDefined("url.iResident_ID") AND url.iResident_ID NEQ "")>
	<cfquery name="qResident" DATASOURCE="#DSN#">
	select *, RS.iGroup_ID as iGroup_ID, RS.iSource_ID as iSource_ID
	from Resident R
	join ResidentState RS ON (R.iResident_ID = RS.iResident_ID AND RS.dtRowDeleted IS NULL)
	left join Sources S ON (S.iSource_ID = RS.iSource_ID AND S.dtRowDeleted IS NULL)
	where R.dtRowDeleted IS NULL and R.iResident_ID = #iResident_ID#
	</cfquery>
	
	<cfquery name="qResidentContacts" DATASOURCE="#DSN#">
	select isNull(I.cFirstName,'HERE') as InquirercFirstName, isNULL(I.cLastName,'none') as InquirercLastName, I.iInquirer_ID, 
		I.cAddress, I.cCity, I.cStateCode, I.cZipCode, I.cPhoneNumber1, I.cPhoneNumber2, IR.iResident_id
	from InquirerToResidentLink IR 
	join Inquirer I ON (I.iInquirer_ID = IR.iInquirer_ID AND I.dtRowDeleted IS NULL)
	where IR.dtRowDeleted IS NULL and IR.iResident_ID = #iResident_ID#
	</cfquery>	
</cfif>

</CFOUTPUT>