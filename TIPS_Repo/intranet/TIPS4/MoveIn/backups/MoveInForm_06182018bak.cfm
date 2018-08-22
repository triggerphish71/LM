<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| Gather Move in Information for this tenant                                                   |
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
| puendia    | 02/20/2002 | Programmers header created                                         |
| puendia    | 02/20/2002 | Added clauses to default to linked tenants room and residency type |
|                         | if that information exists.                                        |
| sdavison   |	04/22/2002 | Changed check for next months rent from PDClosed to               |
|                         | OpsManagerClosed.                                                  |
| ranklam    | 11/11/2005 | Changed the code for the move in date and rent effective date so   |
|                         | it always displays the current year AND next year.                 |
|SSathya     | 03/24/2008 |Did modification so that the refundable and non-refundable fee is   |
|                          visible. Added a condition to the exisiting code.                   |
|SSathya	 | 06/03/08   |Did the necessary modification according to Project# 20125          |
|RSchuette   | 09/30/08   |Added Validationdate() to validate birthdate entry  	Project 28289  |
|RSchuette   | 10/01/08   |Added code (commented out) for Proj 26955 BOND Designations         |
|Ssathya     | 11/10/2008 |Project 30178 added Guarantor Agreement                             |
|RSchuette	 | 11/21/2008 |Provided more code for apt listing based on bond qualifying status  |
|			 |  		  |of tenant (Project 26955)										   |
|RSchuette	 | 3/30/2009  |Proj 35400 - Email validation on contact.						   |
|RSchuette	 | 7/1/2009   |Proj 36359 - MI Check Received project.   						   |
|SFarmer	 | 2/7/2012   |Proj 75019 - Changes for Deferred NRF and VA. 					   |
|sfarmer     | 04/24/2012 | move in charges changed to check dtEffectiveEnd date. tckt 89924   |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
|sfarmer     | 06/09/2012 | 75019 - Adjustments for 2nd opp, respite, Idaho                    |
|sfarmer     | 12/13/2012 | 99579 - removed required approval process for discounted NRF       |
|sfarmer     | 02-01-2013 | 99575 - adjusted postal (ZIP) codes for Canadian postal Codes      |
|Sfarmer     | 09/18/2013 | 102919 - Revise NRF approval process                               |
|Sfarmer     | 11/01/2013 | 111674 - Revise Move-in date so it reflects correct nbr of days in |
|            |            |          the month for the move-in month/date selected             |
|S Farmer    | 05/20/2014 | 116824 - Move-In update  - Allow ED to adjust BSF rate             |
|S Farmer    | 05/20/2014 | 116824 - Phase 2 Allow different move-in and rent-effective dates  |
|            |            | allow respite to adjust BSF rates                                  |
|S Farmer    | 08/20/2014 | 116824 - back-off different move-in rent-effective dates           |
|            |            | allow adjustment of rates by all regions                           |
|S Farmer    | 09/08/2014 | 116824 - Allow all houses edit BSF and Community Fee Rates         |
|S Farmer    | 2015-01-12 | 116824  Final Move-in Enhancements                                 |
|SFarmer,    | 2015-09-28 |  Medicaid, Memory Care Updates                                     |
|MShah       |            |                                                                    |
|Sfarmer     | 2016-09-07 | added 'mBSFOrig = null' and 'mBSFDisc  = null' to reset            |
|            |            |teantstate values list                                              |
|SFarmer     | 05/02/2017 | Remove extraneous displays, comments & dumps,use error routine     |
|            |            |and display page
|MStriegel   | 10/20/2017 | Added check box for bundled pricing. Add javascript                |
 -----------------------------------------------------------------------------------------  --->

  <!--- <cfdump var="#session#"> --->
<!--- Check to see if the chosen tenant has a move in date. --->
<cfparam name="defpymntamt" default="0">
<cfparam name="NewNRFee"    default="0">
<cfparam name="adjamount"   default="0">
<cfparam name="discamount"  default="0">
<cfparam name="NrfDiscApprove" default="">
<cfparam name="iPICD" default="">
<cfparam name="iSICD" default="">
<cfparam name="iTICD" default="">
<cfset todaysdate = CreateODBCDateTime(now())>

<cfquery name="RegCheck" datasource="#APPLICATION.datasource#">
	select dtMoveIn from tenantstate WITH (NOLOCK) where dtrowdeleted is null and iTenant_ID = #url.ID# and dtMoveIn is    null
</cfquery>
<!--- <cfoutput> dtmovein #RegCheck.dtMoveIn#</cfoutput>
   --->
<cfscript>
	Action = iif(RegCheck.dtMoveIn EQ '',DE('MoveInFormInsert.cfm'),DE('MoveInFormUpdate.cfm'));
</cfscript>
<!--- <cfscript>
	Action = iif(RegCheck.RecordCount LTE 0,DE('MoveInFormInsert.cfm'),DE('MoveInFormUpdate.cfm'));
</cfscript> --->

<script language="JavaScript" src="../../global/calendar/ts_picker_Validate.js" type="text/javascript"></script>



<cfquery name="Tenant" datasource= "#APPLICATION.datasource#">
	Select iTenantStateCode_ID
	, t.itenant_ID
	, cSolomonkey
	, cBillingType
	, cSLevelTypeSet
	, iResidencyType_ID
	,ts.itenantstate_id
	,		cFirstName
		, cLastName
		, cSSN
		, dBirthDate
		, cOutsideAddressLine1
		, cOutsideAddressLine2
		, cOutsideCity
		, cOutsideStateCode
		, cOutsideZipCode
		,		bIsPayer
		, bisprimarypayer
		, bMICheckReceived
		, cResidenceAgreement
		, cResidentFee
		, bDeferredPayment
		, bAppFeePaid
		, cMiddleInitial
		, 		cPreviousAddressLine1
		, cPreviousAddressLine2
		, dtBondCert
		, bIsBond
		, chasExecutor
		, ts.cMilitaryVA
		, ts.iMonthsDeferred
		, ts.mAmtDeferred,
		ts.bIsNRFDeferred
		, ts.mBaseNRF
		, ts.MADJNRF
		, cPreviousCity
		, cpreviouszipcode
		,t.ihouse_id
		,t.cchargeset
		,ts.csex
	From Tenant T WITH (NOLOCK)
	Join TenantState TS WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID and TS.dtRowDeleted is null
	Where T.dtRowDeleted is null and T.iTenant_ID = #Url.ID#	
</cfquery>

<cfquery name="resetNRF" datasource= "#APPLICATION.datasource#">
	update TenantState
	set
		bIsNRFDeferred = null
		,cNRFDefApproveUser_ID  = null
		,mBaseNRF = null
		,mAdjNRF = null
		,cNRFAdjApprovedBy = null
		,dtNRFAdjApproved = null
		,iNRFMid = null
		,bNRFPend = null
		,cNRFDiscAppUsername = null
		,mAmtDeferred = null
		,iMonthsDeferred = null
		,mAmtNRFPaid = null
		,mMedicaidCopay = null
		,mBSFOrig = null
		,mBSFDisc  = null
	Where  iTenant_ID = #Url.ID#
</cfquery>

<cfquery name="qryRC1740" datasource="#Application.datasource#"> 
				Select irecurringCharge_id from recurringcharge rchg WITH (NOLOCK)
				join Charges chg WITH (NOLOCK) on rchg.icharge_id = chg.icharge_id
				where chg.ichargetype_id = 1741 
				and chg.ihouse_id = #Tenant.ihouse_id# 
				and chg.dtrowdeleted is null 
				and chg.cchargeset = '#Tenant.cchargeset#'
				and chg.ichargetype_id = 1740 
				and rchg.itenant_id = #Tenant.iTenant_id# 
				and rchg.dtrowdeleted is null
</cfquery>

<cfquery name="qryRC1741" datasource="#Application.datasource#"> 
				Select irecurringCharge_id from recurringcharge rchg WITH (NOLOCK)
				join Charges chg WITH (NOLOCK) on rchg.icharge_id = chg.icharge_id
				where chg.ichargetype_id = 1741 
				and chg.ihouse_id = #Tenant.ihouse_id# 
				and chg.dtrowdeleted is null 
				and chg.cchargeset = '#Tenant.cchargeset#'
				and chg.ichargetype_id = 1741 
				and rchg.itenant_id = #Tenant.iTenant_id# 
				and rchg.dtrowdeleted is null
</cfquery>

<cfif qryRC1740.iRecurringCharge_ID is not "">
	<cfquery name="delNRFhg" datasource="#Application.datasource#">
		UPDATE RecurringCharge
		SET
			dtRowDeleted = #todaysdate#
			,iRowDeletedUser_ID = #session.userid# 
		where 
			iRecurringCharge_ID = #qryRC1740.iRecurringCharge_ID#
				AND iTenant_ID= #Url.ID#
	</cfquery>
</cfif>

<cfif qryRC1741.iRecurringCharge_ID is not "">
	<cfquery name="delNRFhg" datasource="#Application.datasource#">
		UPDATE RecurringCharge
		SET
			dtRowDeleted = #todaysdate#
			,iRowDeletedUser_ID = #session.userid# 
		where 
			iRecurringCharge_ID = #qryRC1741.iRecurringCharge_ID#
				AND iTenant_ID= #Url.ID#
	</cfquery>
 
</cfif>

<!--- catch if resident is already moved in --->
<cfif Tenant.iTenantStateCode_ID eq 2> 
	<center><strong style='font-size: large; color: red;'>This tenant is already moved in.<br />You will be redirected in 10 seconds.</strong></center>
	<script> function redirect() { location.href='../MainMenu.cfm'; } setTimeout('redirect()',10000); </script>
	<CFABORT>
</cfif>

<!--- Retrieve all valid diagnosis types --->
<cfquery name="qDiagnosisType" datasource="#Application.datasource#">
	Select idiagnosistype_id, cdescription 
	From diagnosistype WITH (NOLOCK)
	Where dtRowDeleted is null	
</cfquery>

<!--- Get promotion Codes --->
<cfquery name="qTenantPromotion" datasource="#Application.datasource#">
	Select iPromotion_ID, cDescription 
	From TenantPromotionSet WITH (NOLOCK)
	Where dtRowDeleted is null 
</cfquery>

<!--- retrieve house product line info --->
<cfquery name="qproductline" datasource="#application.datasource#">
	select pl.iproductline_id, pl.cdescription
	from houseproductline hpl WITH (NOLOCK)
	join productline pl on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
	where hpl.dtrowdeleted is null and hpl.ihouse_id = #session.qselectedhouse.ihouse_id#
</cfquery>
<cfquery name="HouseDetail" datasource = "#APPLICATION.datasource#">  
	select st.bIsMedicaid StateMedicaid
	, h.bIsMedicaid HouseMedicaid
	, h.cstatecode 
	,chgs.cName ChargeSet
	, h.ihouse_id
	,hm.mStateMedicaidAmt_BSF_Daily
	,hm.mStateMedicaidAmt_BSF_Monthly
	,hm.mMedicaidBSF
	,hm.mMedicaidCopay
	from House h WITH (NOLOCK)
	join statecode st WITH (NOLOCK) on h.cstatecode = st.cstatecode
	join ChargeSet chgs WITH (NOLOCK) on h.iChargeSet_ID = chgs.iChargeSet_ID
	left join HouseMedicaid hm WITH (NOLOCK) on  hm.ihouse_id = h.ihouse_id
	where h.iHouse_ID = #session.qSelectedHouse.iHouse_ID# and chgs.dtRowDeleted is null and h.dtrowdeleted is null
		and hm.dtrowdeleted is null
</cfquery>
<!--- retrieve residency types --->
<cfquery name="residency" datasource="#application.datasource#">
	select rt.iresidencytype_id ,rt.cdescription <!---,pl.iproductline_id ,plrt.iproductlineresidencytype_id--->
	from houseproductline hpl WITH (NOLOCK)
	join productline pl WITH (NOLOCK) on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
	join ProductLineResidencyType plrt WITH (NOLOCK) on plrt.iproductline_id = pl.iproductline_id and plrt.dtrowdeleted is null
	join residencytype rt WITH (NOLOCK) on rt.iresidencytype_id = plrt.iresidencytype_id and rt.dtrowdeleted is null
	where hpl.dtrowdeleted is null and hpl.ihouse_id = #session.qselectedhouse.ihouse_id# and hpl.iproductline_id=1
	<cfif #HouseDetail.StateMedicaid# eq 1 and #HouseDetail.HouseMedicaid#  eq 1> and rt.iresidencytype_id in (1,2,3)
	<cfelse>and rt.iresidencytype_id in (1,3)
	</cfif>
</cfquery>

 <cfquery name="residencyMemoryCare" datasource="#application.datasource#">
	select rt.iresidencytype_id ,rt.cdescription <!---,pl.iproductline_id ,plrt.iproductlineresidencytype_id--->
	from houseproductline hpl WITH (NOLOCK)
	join productline pl WITH (NOLOCK) on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
	join ProductLineResidencyType plrt WITH (NOLOCK) on plrt.iproductline_id = pl.iproductline_id and plrt.dtrowdeleted is null
	join residencytype rt WITH (NOLOCK) on rt.iresidencytype_id = plrt.iresidencytype_id and rt.dtrowdeleted is null
	where hpl.dtrowdeleted is null and hpl.ihouse_id = #session.qselectedhouse.ihouse_id# and hpl.iproductline_id=2
	<cfif #HouseDetail.StateMedicaid# neq 1 and #HouseDetail.HouseMedicaid#  neq 1> and rt.iresidencytype_id not in (2)
	</cfif>
</cfquery>

<!--- Retreive list of State Codes, Phone types, RelationShip Types, Residency Types --->
<cfinclude template="../Shared/Queries/StateCodes.cfm">
<cfinclude template="../Shared/Queries/PhoneType.cfm">
<cfinclude template="../Shared/Queries/Relation.cfm">
<cfinclude template="../Shared/Queries/TenantInformation.cfm">
<cfinclude template="../Shared/Queries/AvailableApartments.cfm">


<!--- Gets Active assesment points.  --->
<cfquery name="qapoints" datasource="#APPLICATION.datasource#">
    Select distinct am.iSPoints
    From assessmenttoolmaster am WITH (NOLOCk)
    where am.dtrowdeleted is null
    	and am.bfinalized = 1
		and am.bBillingActive = 1
    	and itenant_id = #trim(tenant.itenant_id)#
</cfquery>

<!--- query for prior move in invoice --->
<cfquery name='qPriorMI' datasource="#APPLICATION.datasource#">
	select distinct im.iinvoicemaster_id
	from invoicemaster im WITH (NOLOCK)
	left join invoicedetail inv WITH (NOLOCK) on inv.iinvoicemaster_id = im.iinvoicemaster_id and  im.dtrowdeleted is null and inv.dtrowdeleted is null and inv.itenant_id = #tenant.itenant_id#
	where im.bmoveininvoice is not null and im.bfinalized is null and im.csolomonkey = '#Tenant.csolomonkey#'
</cfquery>

<cfscript>
	if (qPriorMI.recordcount GT 0) 
		{ Action='MoveInFormUpdate.cfm';}
</cfscript>	

<!--- Include Intranet Header --->
<cfinclude template="../../header.cfm">

<!--- Check for Existence Of Respite Rates --->
<cfquery name="qRespiteChargeCheck" datasource="#APPLICATION.datasource#">
	Select iCharge_ID 
	From Charges 
	Where dtRowDeleted is null and ihouse_ID = #session.qSelectedHouse.iHouse_ID# 
	and iResidencyType_ID = 3
</cfquery>

<!---  --->
<!--- <cfquery  name="qryNRFDef" datasource="#APPLICATION.datasource#"> --->
 <cfquery  name="qryNRFDef"  datasource="DMS">
SELECT nEmployeeNumber
      ,nDepartmentNumber
      ,LName
      ,FName
      ,MName
      ,JobTitle
	  ,Fname + ' ' +  Lname as 'FullName'
  FROM  ALCWeb.dbo.Employees WITH (NOLOCK) 
  where JobTitle like '%President%' or JobTitle like '%Regional Manager%' and dtrowdeleted is null
</cfquery>

  
<!--- <cfquery  name="qryVADef" datasource="#APPLICATION.datasource#"> --->
 <cfquery  name="qryVADef"  datasource="DMS">
SELECT nEmployeeNumber
      ,nDepartmentNumber
      ,LName
      ,FName
      ,MName
      ,JobTitle
	  ,Fname + ' ' +  Lname as 'FullName'
  FROM  ALCWeb.dbo.Employees WITH (NOLOCK)
  where JobTitle like '%President%'   and dtrowdeleted is null
</cfquery>

<CFQUERY NAME="GetNRF" DATASOURCE="#APPLICATION.datasource#"> 
		select c.mamount as NRF 
	from Charges c 
	join ChargeType ct on (ct.iChargeType_ID = c.iChargeType_ID)
	where c.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
	and c.cChargeSet = (select cs.cName 
	from Chargeset cs WITH (NOLOCK)
	join House h WITH (NOLOCK) on (h.iChargeSet_ID = cs.iChargeSet_ID and h.iHouse_ID = #session.qSelectedHouse.iHouse_ID#))
	and c.dtRowDeleted is null
	and c.iChargeType_ID   in (69)
	and c.bIsMoveInCharge = 1
</CFQUERY>


<!--- respite catch ---->
<cfif qRespiteChargeCheck.RecordCount eq 0 and Tenant.iResidencyType_ID eq 3>
	<script> alert('There are no respite rates entered for this house. \r Please  contact your AR Specialist for assistance</>');</script>
</cfif>





<script language="JavaScript" type="text/javascript" src="../Shared/JavaScript/global.js"></script>
 


<!--- Retrieve the House Status --->
<cfquery name="HouseLog" datasource = "#APPLICATION.datasource#">
	select bIsPDClosed from HouseLog WITH (NOLOCK) where iHouse_ID = #session.qSelectedHouse.iHouse_ID# and dtRowDeleted is null
</cfquery>

<!--- Retrieve the any house specific Deposits --->
<cfquery name="qHouseDeposits" datasource="#APPLICATION.datasource#">
	select ct.* from ChargeType ct WITH (NOLOCK)
	join Charges C WITH (NOLOCK) on (c.iChargeType_ID = ct.iChargeType_ID and c.dtRowDeleted is null)
	where ct.dtRowDeleted is null and bIsDeposit is not null and c.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
</cfquery>

<!--- Retrieve all DepositTypes that are Refundable  --->
<cfquery name= "Refundables" datasource = "#APPLICATION.datasource#">
	select ct.*, c.cDescription as cDescription, c.iCharge_ID
	from ChargeType ct WITH (NOLOCK)
	join Charges C WITH (NOLOCK) on (c.iChargeType_ID = ct.iChargeType_ID and c.dtRowDeleted is null)
	where ct.dtRowDeleted is null
	and bIsDeposit is not null
	and getdate() between c.dteffectivestart and c.dteffectiveend
	and	bIsRefundable is not null
	<cfif FindNoCase(25, session.CodeBlock, 1) eq 0>
		and bAcctOnly is null
	</cfif>	

	<cfif qHouseDeposits.RecordCount GT 0>
		and	c.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
	<cfelse> 
		and c.iHouse_ID is null
	</cfif>
	and c.iChargeType_ID not in (53, 83)
</cfquery>

<!--- Retreivea all DepositTypes that are Fees (Non-Refundable) --->
<cfquery name="Fees" datasource="#APPLICATION.datasource#">
	select ct.*, c.cDescription as cDescription, c.iCharge_ID
	from ChargeType ct WITH (NOLOCK)
	join Charges C WITH (NOLOCK) on (c.iChargeType_ID = ct.iChargeType_ID and c.dtRowDeleted is null)
	where ct.dtRowDeleted is null and bIsDeposit is not null
	and getdate() between c.dteffectivestart and c.dteffectiveend
	and	bIsRefundable is null
	<cfif FindNoCase(25, session.CodeBlock, 1) eq 0> 
		and bAcctOnly is null
	</cfif>	

	<cfif qHouseDeposits.RecordCount GT 0>
		and	c.iHouse_ID = #session.qSelectedHouse.iHouse_ID# 
	<cfelse> 
		and c.iHouse_ID is null
	</cfif>
</cfquery>

<!--- Retrieve all pertenant charges. Both General and House Specific --->
<cfquery name= "AvailableCharges"	datasource = "#APPLICATION.datasource#">
	select c.*, ct.bIsModifiableDescription, ct.bIsModifiableAmount, ct.bIsModifiableQty
	from Charges c WITH (NOLOCK)
	join 	ChargeType ct WITH (NOLOCK) on c.iChargeType_ID = ct.iChargeType_ID
	where (iHouse_ID is null or c.iHouse_ID=#session.qSelectedHouse.iHouse_ID#)
	and	c.dtRowDeleted is null and c.mAmount < 1
	<cfif IsDefined("url.Charges")> 
		and c.iCharge_ID = #url.Charges# 
	</cfif>
</cfquery>
<!---mamta added bisMedicaid,bIsMemorycare--->
<cfquery name="bondhouse" datasource="#application.datasource#">
  	select iBondHouse, bBondHouseType, iSecurityDeposit, bIsMedicaid,bIsMemorycare from house WITH (NOLOCK)  where ihouse_id =  #session.qSelectedHouse.iHouse_ID#
 </cfquery>
<cfif NOT isNumeric(bondhouse.iBondHouse)>
    <cfset bondhouse.iBondHouse = 0>
</cfif>
<cfquery name="Occupied" datasource="#APPLICATION.datasource#">
	select distinct TS.iAptAddress_ID 
	from TenantState TS WITH (NOLOCK)
	join Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
	join AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null
	where TS.dtRowDeleted is null 
	and	TS.iTenantStateCode_ID = 2
	and	AD.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
</cfquery>
<cfset OccupiedList=ValueList(Occupied.iAptAddress_ID)>
<!---Mshah--->
<cfquery name="OccupiedNonCompanion" datasource="#APPLICATION.datasource#">
select distinct TS.iAptAddress_ID 
from TenantState TS WITH (NOLOCK)
join Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
join AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null
join apttype at WITH (NOLOCK) on at.iapttype_ID= ad.iapttype_ID and at.dtrowdeleted is null
where TS.dtRowDeleted is null 
and	TS.iTenantStateCode_ID = 2
and at.biscompanionSuite <>1
and	AD.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
</cfquery>
<cfset OccupiedNonCompanionlist =ValueList(OccupiedNonCompanion.iAptAddress_ID)>
<!---Mshah--->
 <cfif bondhouse.iBondHouse eq 1>
				
				<!--- Apartment List applicable for Bond Tenant Use --->
				<cfquery name="BondAppAptList" datasource="#APPLICATION.datasource#">
					select aa.*,at1.*
					from AptAddress aa WITH (NOLOCK)
					join apttype at1 WITH (NOLOCK) on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
					where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and aa.bBondIncluded = 1
					and aa.dtRowDeleted is null
				</cfquery>
				<cfset BondIncludedAptList = ValueList(BondAppAptList.iAptAddress_ID)>
				<!--- Apartment List of apartments set as bond ---> 
				<cfquery name="BondAptList" datasource="#APPLICATION.datasource#">
					select aa.*,at1.* 
					from AptAddress aa WITH (NOLOCK)
					join apttype at1 WITH (NOLOCK) on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
					where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and aa.bIsBond = 1
					and aa.dtRowDeleted is null
				</cfquery>
				<cfset BondAptList = ValueList(BondAptList.iAptAddress_ID)>
				<!--- Count of current bond designated apts --->
				<cfquery name="bAptCount" datasource="#APPLICATION.datasource#">
					select count(AA.iAptAddress_ID) as B 
					from AptAddress AA WITH (NOLOCK)
					where AA.bIsBond = 1
					and AA.dtrowdeleted is null
					and AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				</cfquery>
				<!--- Count of apts that were built and apply to the bond designation --->
				<cfquery name="AptCountTot" datasource="#APPLICATION.datasource#">
					select count(AA.iAptAddress_ID) as T 
					from AptAddress AA WITH (NOLOCK)
					where AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and AA.bBondIncluded = 1
					and AA.dtrowdeleted is null
				</cfquery>
				<!--- Apartment addresses that are occupied and pertain to bond applicable --->
				<cfquery name="Occupied" datasource="#APPLICATION.datasource#">
					select distinct TS.iAptAddress_ID
					from TIPS4.dbo.AptAddress aa, TIPS4.dbo.tenant te, TIPS4.dbo.TenantState TS 
					join TIPS4.dbo.Tenant T on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
					join TIPS4.dbo.AptAddress AD on AD.iAptAddress_ID = TS.iAptAddress_ID 
						and AD.dtRowDeleted is null
					where TS.dtRowDeleted is null
					and TS.iTenantStateCode_ID = 2
					and AD.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and TS.iAptAddress_ID = aa.iAptAddress_ID 
					and te.iTenant_ID = ts.iTenant_ID
					and aa.bBondIncluded = 1
				</cfquery>
				<cfset OccupiedRowCount = (Occupied.recordcount)>

</cfif>
<!---mamta added to count percent and display medicaid
<cfoutput> #bondhouse.bIsMedicaid# </cfoutput>--->
<cfif bondhouse.bIsMedicaid eq 1>
              <!--- Apartment List of apartments set as Medicaid ---> 
				<cfquery name="MedicaidAptList" datasource="#APPLICATION.datasource#">
					select aa.*,at1.* 
					from AptAddress aa WITH (NOLOCK)
					join apttype at1 on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
					where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and aa.bIsMedicaidEligible = 1
					and aa.dtRowDeleted is null
				</cfquery>
				<cfset MedicaidApartmentList = ValueList(MedicaidAptList.iAptAddress_ID)>
				<!--- Apartment List of apartments set as Medicaid and bond--->
				<cfquery name="MedicaidbondApt" datasource="#APPLICATION.datasource#">
					select aa.*,at1.* 
					from AptAddress aa WITH (NOLOCK)
					join apttype at1 on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
					where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and aa.bIsMedicaidEligible = 1
					and aa.bIsbond=1
					and aa.dtRowDeleted is null
				</cfquery>
				<cfset MedicaidbondAptList= ValueList(MedicaidbondApt.iAptAddress_ID)>
				<!--- Apartment List of apartments set as Medicaid and bond incuded--->
				<cfquery name="MedicaidbondincludedApt" datasource="#APPLICATION.datasource#">
					select aa.*,at1.* 
					from AptAddress aa WITH (NOLOCK)
					join apttype at1 on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
					where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and aa.bIsMedicaidEligible = 1
					and aa.bbondIncluded=1
					and aa.dtRowDeleted is null
				</cfquery>
				<cfset MedicaidbondIncludedAptList= ValueList(MedicaidbondincludedApt.iAptAddress_ID)>
				<!---<cfoutput> #MedicaidApartmentList#, MedicaidbondAptList #MedicaidbondAptList#,MedicaidbondIncludedAptList#MedicaidbondIncludedAptList#</cfoutput>
				 Count of current Medicaid designated apts --->
				<cfquery name="MedicaidAptCount" datasource="#APPLICATION.datasource#">
					select count(AA.iAptAddress_ID) as TotalMedicaidApt 
					from AptAddress AA  WITH (NOLOCK)
					where AA.bIsMedicaidEligible = 1
					and AA.dtrowdeleted is null
					and AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				</cfquery>
				<!--- Count of total apts --->
				<cfquery name="AptCountTotal" datasource="#APPLICATION.datasource#">
					select count(AA.iAptAddress_ID) as T 
					from AptAddress AA WITH (NOLOCK)
					where AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and AA.dtrowdeleted is null
				</cfquery>
				<!---Occupied medicaids rooms--->
				<cfquery name="OccupiedMedicaidApt" datasource="#APPLICATION.datasource#">
					select distinct TS.iAptAddress_ID 
					from TenantState TS WITH (NOLOCK)
					join Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
					join AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID 
					and AD.dtRowDeleted is null
					where TS.dtRowDeleted is null 
					and	TS.iTenantStateCode_ID = 2
					and AD.Bismedicaideligible=1
					and	AD.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				</cfquery>
				<cfset OccupiedMedicaidAptList=ValueList(OccupiedMedicaidAPt.iAptAddress_ID)>
</cfif>
<!---Mamta testing



<cfoutput> #MedicaidApartmentList# and ##</cfoutput>

				<cfquery name="MemCareAptList" datasource="#APPLICATION.datasource#">
				select c.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
				,c.iAptType_ID, ct.bIsDaily
				,c .*, ct.*
				,aa.*, at1.*
				from Charges C
				join ChargeType ct on (CT.iChargeType_ID = c.iChargeType_ID and ct.dtRowDeleted is null)
				join AptAddress aa on c.iapttype_id = aa.iapttype_id
				join apttype at1 on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
					where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
						and c.dtRowDeleted is null
						and c.cChargeSet = '#HouseDetail.ChargeSet#'
						and ct.bIsRent is not null
						and ct.bIsDiscount is null 
						and ct.bIsRentAdjustment is null 
						and ct.bAptType_ID is not null 
						and ct.bIsMedicaid is null
						and c.iOccupancyPosition = 1
						<!--- and ct.bIsDaily is   null --->
						and ct.bSLevelType_ID is null
						and c.iResidencyType_ID = 5
						and c.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
						<!--- and c.cdescription = 'Memory Care - BSF' --->
						and dtEffectiveStart <= getdate() and dtEffectiveEnd >= getdate()
						and c.iProductLine_ID = 1
				order by captnumber  				
				</cfquery>--->
				
				
		<!---added for the memory care apt list//mamta--->	
				
		<cfquery name="MemCareAptList" datasource="#APPLICATION.datasource#">
				select aa.*,at1.* 
				from AptAddress aa WITH (NOLOCK)
				join apttype at1 WITH (NOLOCK) on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
				where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				and aa.bIsmemorycareeligible = 1
				and aa.dtRowDeleted is null	
		</cfquery>
		<cfset MemoryCareApartmentList = ValueList(MemcareAptList.iAptAddress_ID)>
		<!---Occupied medicaids rooms--->
		<cfquery name="OccupiedMemcareApt" datasource="#APPLICATION.datasource#">
				select distinct TS.iAptAddress_ID 
				from TenantState TS WITH (NOLOCK)
				join Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
				join AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID 
				and AD.dtRowDeleted is null
				where TS.dtRowDeleted is null 
				and	TS.iTenantStateCode_ID = 2
				and AD.bIsMemoryCareEligible=1
		    	and	AD.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
		</cfquery>
		<cfset OccupiedMemcareAptList=ValueList(OccupiedMemcareApt.iAptAddress_ID)>
<cfquery name="qryAptType" datasource="#APPLICATION.datasource#">
	select  aa.iAptAddress_ID ,
	aa.iAptType_ID, aa.cAptNumber
	,chg.mamount
	,at.cdescription
	,chg.ichargetype_id
	,ct.cdescription
	  from charges  chg WITH (NOLOCK)
	join house h WITH (NOLOCK) on chg.ihouse_id = h.ihouse_id
	join chargeset chgst WITH (NOLOCK) on h.ichargeset_id = chgst.ichargeset_id
	join dbo.AptAddress AA WITH (NOLOCK) on aa.ihouse_id = chg.ihouse_id
	join dbo.AptType AT WITH (NOLOCK) on aa.iAptType_ID = at.iAptType_ID
	join dbo.ChargeType ct WITH (NOLOCK) on ct.ichargetype_id = chg.ichargetype_id
	where chg.ihouse_id = #session.qselectedhouse.ihouse_id# and chg.cchargeset = chgst.cname 
	and chg.ichargetype_id in (7, 8,31,89)
	and chg.dtrowdeleted is null
	and aa.dtrowdeleted is null
</cfquery>
<script>
	function primarypayor(obj){
		if (document.getElementById("ContactbIsPayor").checked){
			alert('This will remove the Resident as the Payor');
			document.getElementById("TenantbIsPayer").checked = false;
		}
	}	
	function residentPayor(obj){
		if (document.getElementById("TenantbIsPayer").checked){
			alert('This will remove the Contact as the Payor');
			document.getElementById("ContactbIsPayor").checked = false;
		}
	}
function validatePayor(){
//alert('got here');
// 		if (document.getElementById("cLastName").value != ''){
 	 		if((document.getElementById("ContactbIsPayor").checked == false) &&
 		 		  (document.getElementById("TenantbIsPayer").checked  == false) ) 
 			 	    {
 				 	MoveInForm.ContactbIsPayor.focus();
 				 	alert("Select either tenant or contact as the Payor");
 					 return false;					
 				 }		
//		 	}
		}
function validateroom(){
	
	
}
</script>

<script>
function bondValidate(){
  		if(MoveInForm.bondval.value==1)
 		 {
//		alert("here i'am to save the day");
  			if(MoveInForm.dtBondCertificationMailed.value == '00/00/0000'){
  					MoveInForm.dtBondCertificationMailed.focus();
  						alert("Please enter the date the income certification was mailed to the Corporate Office.  "
  						 + MoveInForm.bondval.value);
  						return false;
  			}
 			else if (MoveInForm.dtBondCertificationMailed.value == ''){
  					MoveInForm.dtBondCertificationMailed.focus();
  						alert("Please enter the date the income certification was mailed to the Corporate Office.");
  						return false;
  			}
 			else if (bisDate(MoveInForm.dtBondCertificationMailed.value) == false){
  					MoveInForm.dtBondCertificationMailed.focus();
  						alert("Please enter a valid date in which the income certification was mailed to the Corporate Office. \n \n"
  						+ MoveInForm.dtBondCertificationMailed.value+"  is not a valid date.");
  						return false;
  				}


  					for(j=0;j<MoveInForm.cBondQualifying.length;j++){
  						if(MoveInForm.cBondQualifying[j].checked)
  						{var bondq = true;
						
  							if(MoveInForm.cBondQualifying[j].value == 1){
  								var bondq_value = true;  							}else{
  								var bondq_value = false;
  							}
  						}
  					}

 // 					if(!bondq){
  //						alert("Please select Yes or No if the resident is bond qualified.");
  //						return false;
  //					}	
				
				//HOUSE
//  				var BondPercentage = MoveInForm.BPercent.value; 
 // 				if(BondPercentage < 20){
  //					var BondPercentMet = false;
  //				}
 //				else{
  //					var BondPercentMet = true;
  //				}  
			
				//ROOM 
 //  				var bondroom = MoveInForm.iAptAddress_ID.options[MoveInForm.iAptAddress_ID.selectedIndex].text;
  //				var bRoomisBond = false;
 // 				var bRoomisBondIncluded = false;
 // 				if((bondroom.indexOf("Bond")) > 0){
 // 					bRoomisBond = true;
  //					}
  //				if((bondroom.indexOf("Included")) > 0){
  //					bRoomisBondIncluded = true;}
					
				//if tenat certifies as NOT bond - then room selected cannot be bond designated
 // 				if(bondq_value == false && bRoomisBond == true){
 // 						alert("Tenant is marked as not being eligible as bond.\n \nPlease select a room that is not bond designated.");
 // 						return false;}
				//tenant is bond, but the room cannot be bond involved.
//  				else if(bondq_value == true && bRoomisBondIncluded == false){
 // 						alert("Tenant is marked as being eligible as bond. \n \nThe room selected is not bond applicable. \n \n
  //						Please select a bond included room.")
  //						return false;}
			
				//tenant is bond, room selected is already bond, and house is under bond percentage, then halt.
//  				 else if(bondq_value == true && bRoomisBond == true && BondPercentMet == false){
 // 						alert("Tenant is marked as being eligible as bond. \n \nThe room selected is already Bond designated. \n \n
  //						But the House is not at the Bond percentage requirement. \n \n
  //						Please select a room that is not Bond designated to raise the percentage.")
                                                                                                                                             //                  						return false;} 
  		 	}	
}


</script>

<script>

	function checkbond(){ 
 		if(MoveInForm.bondval.value==1)
 			{
					for(j=0;j<MoveInForm.cBondQualifying.length;j++){
						if(MoveInForm.cBondQualifying[j].checked)
						{var bondq = true;
							if(MoveInForm.cBondQualifying[j].value == 1)
							{
								var bondq_value = true;
							}
						else{
								var bondq_value = false;
							}
						}
					}
					if(!bondq){
						alert("Please select Yes or No if the resident is bond qualified.");
						return false;
					}
			if ((MoveInForm.dtBondCertificationMailed.value == '00/00/0000') 
				&& (bondq_value)){
					MoveInForm.dtBondCertificationMailed.focus();
						alert("Please enter the date the income certification was mailed to the Corporate Office." + bondq_value);
						return false;
			}
			else if ((MoveInForm.dtBondCertificationMailed.value == '') && (bondq_value)){
					MoveInForm.dtBondCertificationMailed.focus();
						alert("Please enter the date the income certification was mailed to the Corporate Office.");
						return false;
			}
			else if ((bisDate(MoveInForm.dtBondCertificationMailed.value) == false) 
					&& (bondq_value)){
					MoveInForm.dtBondCertificationMailed.focus();
						alert("Please enter a valid date in which the income certification was mailed to the Corporate Office. \n \n" 
						+ MoveInForm.dtBondCertificationMailed.value+"  is not a valid date.");
						return false;
			}
	 	}
	}
</script>
<script >
	if (objRad.value=="1"){ 
		document.getElementById("otherOpt").style.display='block'; //show other options
		document.getElementById("otherOpt2").style.display='block'; //show other options
		document.getElementById("otherOpt1").style.display='block'; //show other options
		document.getElementById("otherOpt3").style.display='block'; //show other options
	//	document.getElementById("VADef").style.display='block';		
		}
	else{ 
		document.getElementById("otherOpt").style.display='none'; //hide other options
		document.getElementById("otherOpt2").style.display='none'; //hide other options
		document.getElementById("otherOpt1").style.display='none'; //hide other options
		document.getElementById("otherOpt3").style.display='none'; //hide other options
	//	document.getElementById("VADef").style.display='none';		
		}
	}
</script>
<script>
	function doClick(objRad){
 
	if (objRad.value=="1"){ 
		document.getElementById("otherOpt").style.display='block'; //show other options
		document.getElementById("otherOpt2").style.display='block'; //show other options
		document.getElementById("otherOpt1").style.display='block'; //show other options
		document.getElementById("otherOpt3").style.display='block'; //show other options
	//	document.getElementById("VADef").style.display='block';		
		}
	else{ 
		document.getElementById("otherOpt").style.display='none'; //hide other options
		document.getElementById("otherOpt2").style.display='none'; //hide other options
		document.getElementById("otherOpt1").style.display='none'; //hide other options
		document.getElementById("otherOpt3").style.display='none'; //hide other options
	//	document.getElementById("VADef").style.display='none';		
		}
	}
	function typMedicaid(MoveInForm)
	{	
		if (document.getElementById("iResidencyType_ID").value == 2)
		{
			document.getElementById("typMedicaid").style.display='block';
			document.getElementById("typMedicaid1").style.display='block';
			document.getElementById("typMedicaid2").style.display='block';
			document.getElementById("typMedicaid3").style.display='block';
			document.getElementById("typMedicaid4").style.display='block';
			document.getElementById("typMedicaid5").style.display='block';
			document.getElementById("typMedicaid6").style.display='block';
			document.getElementById("typMedicaid7").style.display='block';
			document.getElementById("typMedicaid8").style.display='block';	
			document.getElementById("typMedicaid9").style.display='block';																							
		}
		else
		{ 
			document.getElementById("typMedicaid").style.display='none';
			document.getElementById("typMedicaid1").style.display='none';
			document.getElementById("typMedicaid2").style.display='none';
			document.getElementById("typMedicaid3").style.display='none';
			document.getElementById("typMedicaid4").style.display='none';
			document.getElementById("typMedicaid5").style.display='none';
			document.getElementById("typMedicaid6").style.display='none';
			document.getElementById("typMedicaid7").style.display='none';
			document.getElementById("typMedicaid8").style.display='none';	
			document.getElementById("typMedicaid9").style.display='none';					 
		}
	}
</script>
<script>
	function hardhaltvalidation()
	{	 
		if (document.getElementById("iResidencyType_ID").value == 2){
			if (document.getElementById("mMedicaidCopay").value == ''){
				MoveInForm.mMedicaidCopay.focus();
				alert('Please enter the Authorized Copay Amount for this Medicaid Resident');
				return false;
			}	
			if (document.getElementById("cMedicaidAuthorizationNbr").value == ''){
				MoveInForm.cMedicaidAuthorizationNbr.focus();
				alert('Please enter the Medicaid ID for this Medicaid Resident');
				return false;
			}	
		}
	var productLineDropDown = document.getElementById('iproductline_id');
	if (document.getElementById("iproductline_id").value=='')
			{
			productLineDropDown.focus();
			alert("Please select a Product Line");
			return false;
		}
	var residencyDropDown = document.getElementById('iResidencyTypeID'); //iResidencyTypeID
		if(residencyDropDown.selectedIndex == "")
		{
			residencyDropDown.focus();
			alert("Please select a Residency Type");
			return false;
		}	
 
		if  ( MoveInForm.thisHouseID.value == 233
		 || MoveInForm.thisHouseID.value == 229 
		|| MoveInForm.thisHouseID.value == 226){
	 	if (MoveInForm.FeeType.options[MoveInForm.FeeType.selectedIndex].value == 	'')
	 		{
	 		alert("Select if the Fee Type is Community Fee or Security Deposit"); 		
  	 		return false;
	 		}
			}
		if  ( MoveInForm.thisHouseID.value == 212 ){
	 	if (MoveInForm.FeeType.options[MoveInForm.FeeType.selectedIndex].value == 	'')
	 		{
	 		alert("Select if a Security Deposit is to be charged"); 		
  	 		return false;
	 		}
			}	
		if(MoveInForm.iAptAddress_ID.options[MoveInForm.iAptAddress_ID.selectedIndex].value == ""){
 			MoveInForm.iAptAddress_ID.focus();
 			alert("Please select an Apartment Number");
 			return false;
 		}	
 		if(document.getElementById("cSSN").value.length != 11){
 			MoveInForm.cSSN.focus();
 			alert("Please Enter the SSN of the resident in a 123-45-6789 format.");
 			return false;
 		}
 		if(MoveInForm.cSex.options[MoveInForm.cSex.selectedIndex].value == ""){
 			MoveInForm.cSex.focus();
 			alert("Please Select the Residents Sex  - M/F.");
 			return false;
 		}		
 		if(bisDate(MoveInForm.dbirthdate.value)== false){
 			MoveInForm.dbirthdate.focus();
 			alert("Please enter Birth Date in the MM/DD/YYYY");
 			return false;
 		}
		
 		if(MoveInForm.cPreviousAddressLine1.value==""){
 			MoveInForm.cPreviousAddressLine1.focus();
 			alert("Please enter the previous address of the resident");
 			return false;
 		}
				
 		if(MoveInForm.cPreviousCity.value==""){
 			MoveInForm.cPreviousCity.focus();
 			alert("Please enter the previous City of the resident");
 			return false;
 		}
 
 		if(MoveInForm.cPreviouszipCode.value.length < 5 )
 		{
 			MoveInForm.cPreviouszipCode.focus();
 			alert("Please enter the previous City Zip (Postal) Code of the resident or check for proper format.");
 			return false;			
 		}

 		if (validatePMO() == false){
 			return false;
 		}

		//The tenant Executor	
 		var executor = false;
 		for(i=0;i<MoveInForm.hasExecutor.length;i++)
 		{
 			if(MoveInForm.hasExecutor[i].checked)
 			{
 				executor = true;
 			}
 		}
 		 if(!executor)
 		{
 			MoveInForm.cPreviouszipCode.focus();
 			alert("Please make Executor selection");
 			return false;
 		}
		//The VA military option
 		var military = false;
 		for(q=0;q<MoveInForm.cMilitaryVA.length;q++)
 		{
 			if(MoveInForm.cMilitaryVA[q].checked)
 			{
 				military = true;
 			}
 		}
 	    if(!military)
 		{
 			MoveInForm.cPreviouszipCode.focus();
 			alert("Please provide Military response");
 			return false;
 		}					
 		if(MoveInForm.ContactbIsPayor.checked == true)
 		{
 				if(MoveInForm.cFirstName.value==""){
 					alert("First Name for the Contact");
 						MoveInForm.cFirstName.focus();
 						return false;
 				}
 				if(MoveInForm.cLastName.value==""){
 					alert("Last Name for the Contact");
 						MoveInForm.cLastName.focus();
 						return false;
 				}
			
 			  if(MoveInForm.cAddressLine1.value==""){
 					alert("Billing address for the Contact");
 					MoveInForm.cAddressLine1.focus();
 					return false;
 				}
 				if(MoveInForm.cCity.value == ""){
 					MoveInForm.cCity.focus();
 					alert("Please enter City for Contact address");
 					return false;
 				}
 				if(MoveInForm.cStateCode.value == ""){
 					MoveInForm.cStateCode.focus();
 					alert("Please select State for Contact address");
 					return false;
 				} 
 				if(MoveInForm.cZipCode.value.length < 5 ){
 					MoveInForm.cZipCode.focus();
 					alert("Please enter Zip (Postal) Code for Contact address or check Zip Code for porper format");
 					return false;					
 				}

 				if(MoveInForm.areacode1.value.length != 3 || MoveInForm.prefix1.value.length != 3 
 							|| MoveInForm.number1.value.length != 4){
 					MoveInForm.areacode1.focus();
 					alert("Please enter a Home Phone number.");
 					return false;			
 				}
 				
 				if(MoveInForm.cEmail.value !=""){
 					var str=MoveInForm.cEmail.value
 					var filter=/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
 				if (filter.test(str)){
					
 					}else{
 					alert("Please input a valid email address for the contact.")
 					return false;
 					}
 				}
 		}
 					var tmp1 = MoveInForm.areacode1.value; 
 					var tmp1 = tmp1.replace(' ','');
 				if(tmp1.length < 3  && tmp1.length > 0)		
    					{
 						alert('Contact Phone Number MUST be Format: 123-456-7890');
 						return false;
 					}
 					var tmp2 = MoveInForm.prefix1.value; 
 					var tmp2 = tmp2.replace(' ','');
 				if( tmp2.length < 3  && tmp2.length > 0 )		
    					{
 						alert('Contact Phone Number MUST be Format: 123-456-7890 ');
 						return false;
 					}
 					var tmp3 = MoveInForm.number1.value; 
 					var tmp3 = tmp3.replace(' ','');
 				if(  tmp3.length < 4  && tmp3.length > 0)		
    					{
 						alert('Contact Phone Number MUST be Format: 123-456-7890');
 						return false;
 					}		
					//
 					var tmp1 = MoveInForm.areacode2.value; 
 					var tmp1 = tmp1.replace(' ','');
 				if(tmp1.length < 3  && tmp1.length > 0)		
    					{
 						alert('Contact Message Phone Number MUST be Format: 123-456-7890');
 						return false;
 					}
 					var tmp2 = MoveInForm.prefix2.value; 
 					var tmp2 = tmp2.replace(' ','');
 				if( tmp2.length < 3  && tmp2.length > 0 )		
    					{
 						alert('Contact MEssage Phone Number MUST be Format: 123-456-7890 ');
 						return false;
 					}
 					var tmp3 = MoveInForm.number2.value; 
 					var tmp3 = tmp3.replace(' ','');
 				if(  tmp3.length < 4  && tmp3.length > 0)		
    					{
 						alert('Contact Message Phone Number MUST be Format: 123-456-7890');
 						return false;
 		 			}			
		 	bondValidate();										
		 	validatePayor();	
			 if ( MoveInForm.RentDay.options[MoveInForm.RentDay.selectedIndex].value  == ''
			  || MoveInForm.RentMonth.options[MoveInForm.RentMonth.selectedIndex].value  == ''){ 
	 			alert('Enter a valid Financial Possession Date');
	 			return false;		}
			 if ( MoveInForm.MoveInMonth.options[MoveInForm.MoveInMonth.selectedIndex].value  == ''
			  || MoveInForm.MoveInDay.options[MoveInForm.MoveInDay.selectedIndex].value  == ''){ 
	 			alert('Enter a valid Physical Move In Date');
	 			return false;		}
			/* alert (MoveInForm.iAptAddress_ID.value);
				//alert (document.getElementById("OccupiedListtest").value);
				var str = document.getElementById("OccupiedListtest").value;
				var n = str.search(MoveInForm.iAptAddress_ID.value);
				var a = document.getElementById("ResidentName").value;
				var b = document.getElementById("cSolomonKey").value;
				//alert (n);
				if(n > 0){test = confirm (a + '('+ b +')' + 'will be second occupant and occupancy will be zero');
				  if (test== true){
					  alert ('true');
					  return true;  
				  }
				  else { alert ('false');return false;	}
				}*/
var FinPossessionMonth =  MoveInForm.RentMonth.options[MoveInForm.RentMonth.selectedIndex].value;
	if (FinPossessionMonth.length  == 1)
	{FinPossessionMonth = '0' + FinPossessionMonth;	}
var FinPossessionDay =  MoveInForm.RentDay.options[MoveInForm.RentDay.selectedIndex].value;
	if  (FinPossessionDay.length == 1)
	{FinPossessionDay = '0' + FinPossessionDay;	}	 
// revised to format movein dates in 20170101 format 06-06-2017 SFarmer	
var MoveInMonth =  MoveInForm.MoveInMonth.options[MoveInForm.MoveInMonth.selectedIndex].value;
	if (MoveInMonth.length  == 1)
	{MoveInMonth = '0' + MoveInMonth;	}
var MoveInDay =  MoveInForm.MoveInDay.options[MoveInForm.MoveInDay.selectedIndex].value;
	if  (MoveInDay.length == 1)
	{MoveInDay = '0' + MoveInDay;	}	
	
var FinPossessionDt = MoveInForm.RentYear.options[MoveInForm.RentYear.selectedIndex].value  +  
	FinPossessionMonth + FinPossessionDay;
var MoveInDt = MoveInForm.MoveInYear.options[MoveInForm.MoveInYear.selectedIndex].value  +  
		MoveInMonth + MoveInDay;
  	if (MoveInDt < FinPossessionDt)
  	{alert('Physical Move In Date must be Same or Greater than Financial Possession Date');
  	MoveInForm.MoveInDay.focus();
  	return false;
	}
// 	var FinPossessionDt = MoveInForm.RentYear.options[MoveInForm.RentYear.selectedIndex].value  + '-'+
//	 MoveInForm.RentMonth.options[MoveInForm.RentMonth.selectedIndex].value + '-'+ 
//	 MoveInForm.RentDay.options[MoveInForm.RentDay.selectedIndex].value ;

 //	var MoveInDt = MoveInForm.MoveInYear.options[MoveInForm.MoveInYear.selectedIndex].value  + '-'+
//	 MoveInForm.MoveInMonth.options[MoveInForm.MoveInMonth.selectedIndex].value + '-'+ 
//	 MoveInForm.MoveInDay.options[MoveInForm.MoveInDay.selectedIndex].value;

 //	alert(FinPossessionDt + ' : '+ MoveInDt);
 //  	if (MoveInDt < FinPossessionDt)
  //	{alert('Physical Move In Date must be same or greater than Rent Effective Date');
  //	MoveInForm.MoveInDay.focus();
  //	return false;
//	}	
		return true;
	
	}
	
	//Mshah
	function secondoccupant(){
		//alert (MoveInForm.iAptAddress_ID.value);
		//alert (document.getElementById("OccupiedListtest").value);
		var str = document.getElementById("OccupiedListtest").value;
		var n = str.search(MoveInForm.iAptAddress_ID.value);
		var a = document.getElementById("ResidentName").value;
		var b = document.getElementById("cSolomonKey").value;
		//alert (n);
		if(n > 0){var test = confirm (a + '('+ b +')' + 'will be second occupant and occupancy will be zero. Do you want to continue?');
		 if (test== true){
			  //alert ('true');
			  return true;  
		  }
		  else { //alert ('false');
		  return false;	}
		}
	}
	//Mshah
	function validatePMO(){
		var PMODate = document.getElementById("dtmoveoutprojecteddate").value;
		PMODate = new Date(PMODate);
		var AllowDate = document.getElementById("RentMonth").value + '/'+ 
		document.getElementById("RentDay").value + '/' + document.getElementById("RentYear").value;
		var AllowDate = new Date(AllowDate);
		var MoveinDate = new Date(AllowDate);
		AllowDate.setMonth(AllowDate.getMonth() + 3);
		var ErrorFlag = 'No';
		if (document.getElementById("iResidencyType_ID").value== 3){
			if(document.getElementById("dtmoveoutprojecteddate").value == ''){
				ErrorFlag = 'ShowError';
			}
			
			if(PMODate > AllowDate){
				ErrorFlag = 'ShowError';
			}
	
		}
		
		if(MoveinDate > PMODate){
			ErrorFlag = 'ShowError';
		}	
	
		if (ErrorFlag == 'ShowError'){
			document.getElementById("dtmoveoutprojecteddate").focus();
			if(typeof(vWinCal) !== 'undefined'){
				vWinCal.focus();
			}
			alert('Respites REQUIRE Projected Physical Move Out Date \n PMO date can\'t be in the past, or more then 3 months in the future');
		//	document.getElementById("Mes").style.display='block';
			return false;	
		}
		else
			{document.getElementById("Mes").style.display='none';
			return true;}
	}
 
</script>
<script>
function verifyMoveinPossessionDates(){
//alert('made it');
 	var FinPossessionMonth =  MoveInForm.RentMonth.options[MoveInForm.RentMonth.selectedIndex].value;
	if (FinPossessionMonth.length  == 1)
	{FinPossessionMonth = '0' + FinPossessionMonth;	}
var FinPossessionDay =  MoveInForm.RentDay.options[MoveInForm.RentDay.selectedIndex].value;
	if  (FinPossessionDay.length == 1)
	{FinPossessionDay = '0' + FinPossessionDay;	}	
	
var MoveInMonth =  MoveInForm.MoveInMonth.options[MoveInForm.MoveInMonth.selectedIndex].value;
	if (MoveInMonth.length  == 1)
	{MoveInMonth = '0' + MoveInMonth;	}
var MoveInDay =  MoveInForm.MoveInDay.options[MoveInForm.MoveInDay.selectedIndex].value;
	if  (MoveInDay.length == 1)
	{MoveInDay = '0' + MoveInDay;	}	
	
 	var FinPossessionDt = MoveInForm.RentYear.options[MoveInForm.RentYear.selectedIndex].value  +  
	FinPossessionMonth + FinPossessionDay;
//	 MoveInForm.RentMonth.options[MoveInForm.RentMonth.selectedIndex].value +  
//	 MoveInForm.RentDay.options[MoveInForm.RentDay.selectedIndex].value ;

 	var MoveInDt = MoveInForm.MoveInYear.options[MoveInForm.MoveInYear.selectedIndex].value  +  
		MoveInMonth + MoveInDay;
//	 MoveInForm.MoveInMonth.options[MoveInForm.MoveInMonth.selectedIndex].value +  
//	 MoveInForm.MoveInDay.options[MoveInForm.MoveInDay.selectedIndex].value;
//var daysdiff =  MoveInDt -  FinPossessionDt;
//   	alert(FinPossessionDt + ' : '+ MoveInDt + ' ' + daysdiff);
  	if (MoveInDt < FinPossessionDt)
 // if (daysdiff < 0)
  	{alert('Physical Move In Date must be Same or Greater than Financial Possession Date');
  	MoveInForm.MoveInDay.focus();

 	return false;
	}
}
function isMedicaidHouse(){
	var MedicaidBSFRate = document.getElementById("iStateMedicaidAmtBSFDaily").value;
	var ResidentType = document.getElementById("iResidencyType_ID").value;
   if    ((ResidentType == '2'  ) &&(MedicaidBSFRate == 'NF' ))
  {
 alert ("This Community does not have Medicaid Street Rates established. \n A Medicaid Residency Move In CANNOT be completed until rates are established"); 
return false;}
//else { alert (MedicaidBSFRate  + ' ' + ResidentType ); }
}
</script>
<script >
 	var	df0=document.forms[0];
	var vWinCal;


 	function vaDefApp(VAApp){
	 	if (VAApp.value=="1"){
	 	document.getElementById("VAApproval").style.display='block';
	 	document.getElementById("VAApprover").style.display='block';
	 	}
	 	else
	 	{
	 	document.getElementById("VAApproval").style.display='none';
	 	document.getElementById("VAApprover").style.display='none';
	 	}
 	}	    

function TenantCheck()
	{ if (!document.MoveInForm.cNRFFee.checked)
//		document.getElementById("NRFDscAmt").style.display='none';		
//		document.getElementById("NRFDef").style.display='none';		 
//		document.getElementById("iResidencyTypeID").focus();
//		alert('Please select Residency Type BEFORE selecting New Resident Fee');		 
	}
 
	function initialize() { 
  	var	df0=document.forms[0];
		respiterates(df0.iResidencyType_ID); 
		//t=document.getElementById("maintbl"); df0.Message.width=t.clientWidth;
	 //	alert('initialize');
		<cfoutput>
			<cfif isDefined("tenantinfo.dtRentEffective") and tenantinfo.dtRentEffective neq "">
				df0.RentMonth.value='#trim(month(tenantinfo.dtRentEffective))#';
				dayslist(df0.RentMonth,df0.RentDay,df0.RentYear);
				df0.RentDay.value='#trim(day(tenantinfo.dtRentEffective))#';
				df0.RentYear.value='#trim(year(tenantinfo.dtRentEffective))#';
		//		alert('initializeA');
			<cfelse>
				df0.RentMonth.value='#trim(month(now()))#';
				dayslist(df0.RentMonth,df0.RentDay,df0.RentYear);
				df0.RentDay.value='#trim(day(now()))#';
				df0.RentYear.value='#trim(year(now()))#';
			//	alert('initializeB');
			</cfif> 
			<cfif isDefined("tenantinfo.dtMoveIn") and tenantinfo.dtMoveIn neq "">
				df0.MoveInMonth.value='';
				dayslist(df0.MoveInMonth,df0.MoveInDay,df0.MoveInYear);
				df0.MoveInDay.value='';
				df0.MoveInYear.value='';			
		//		df0.MoveInMonth.value='#trim(month(tenantinfo.dtMoveIn))#';
		//		dayslist(df0.MoveInMonth,df0.MoveInDay,df0.MoveInYear);
		//		df0.MoveInDay.value='#trim(day(tenantinfo.dtMoveIn))#';
		//		df0.MoveInYear.value='#trim(year(tenantinfo.dtMoveIn))#';
		//		alert('initializeA');
			<cfelse>
				df0.MoveInMonth.value='#trim(month(now()))#';
				dayslist(df0.MoveInMonth,df0.MoveInDay,df0.MoveInYear);
				df0.MoveInDay.value='#trim(day(now()))#';
				df0.MoveInYear.value='#trim(year(now()))#';
			//	alert('initializeB');
			</cfif> 			
			<cfif tenantinfo.iproductline_id neq "">
				document.getElementById("iproductline_id").value=#trim(tenantinfo.iproductline_id)#
			</cfif>
	
		</cfoutput>	
		// check contact phone numbers for imbedded dashes '-'
		var tmp2 = df0.number1.value; 
		var tmp2 = tmp2.replace('-','');
 		df0.number1.value = tmp2;  
		var tmp3 = df0.prefix1.value; 
		var tmp3 = tmp3.replace('-','');
 		df0.prefix1.value = tmp3; 	
		
		var tmp4 = df0.number2.value; 
		var tmp4 = tmp4.replace('-','');
 		df0.number2.value = tmp4;  
		var tmp5 = df0.prefix2.value; 
		var tmp5 = tmp5.replace('-','');
 		df0.prefix2.value = tmp5;			
	}
	function redirect() { window.location="../Registration/Registration.cfm"; }
	//function charge() { window.location="MoveInForm.cfm?ID=<cfoutput>#url.ID#</cfoutput>&Charge=" + df0.iCharge_ID.value; }
 //	function checkNRF(){
 
//	 	if (!df0.paidwaived.checked ){
//	 		(df0.Message.value = "You must specify if New Resident Fee is Adjusted Up, Discounted or using Standard House Fee.");
//			 alert("You must Select New Resident Fee action" + " " + df0.paidwaived.checked.value); location.hash = '#start';
//			  return false;
//	 	}		
//		else { df0.Message.value = ""; return true; }	
//	}
//function verifyNRF(){
//for (var i=0; i < document.paidwaived.length; i++)
 //  {
  // if (document.paidwaived[i].checked)
  //    {
  //    var rad_val = document.paidwaived[i].value;
//	  alert(rad_val);
 //     }
  // }
//}
//
function setmonth() {
var mylist=document.getElementById("RentMonth");
var monthSel =mylist.options[mylist.selectedIndex].text;


   document.getElementById("RentMonth").value= monthSel;
//	alert ( monthSel);
}

	window.onload=initialize;
	 
</script>
<script>
	function requiredBeforeYouLeave() {
		var tenantChecked =document.getElementById("TenantbIsPayer").checked;	
		var contactChecked = document.getElementById("ContactbIsPayor").checked;
		if  (tenantChecked == false &&  contactChecked == false) 
			{
 				alert("Select either the Resident or the Contact as the Payor"); 
 				return false;
			}
 		else if (tenantChecked == true &&  contactChecked == true) 
				 {
				  	alert("Select either the Resident or the Contact as the Payor but not both"); 
 					return false; 
				}
		else
 			{ return true;}
 		if(MoveInForm.cSex.options[MoveInForm.cSex.selectedIndex].value == ""){
 			MoveInForm.cSex.focus();
 			alert("Please Select the Residents Sex - M/F.");
 			return false;
 		}	
 	// revised movein date check to form dates in a 20170101 format 06-06-2017 sfarmer
var FinPossessionMonth =  MoveInForm.RentMonth.options[MoveInForm.RentMonth.selectedIndex].value;
	if (FinPossessionMonth.length  == 1)
	{FinPossessionMonth = '0' + FinPossessionMonth;	}
var FinPossessionDay =  MoveInForm.RentDay.options[MoveInForm.RentDay.selectedIndex].value;
	if  (FinPossessionDay.length == 1)
	{FinPossessionDay = '0' + FinPossessionDay;	}	
	
var MoveInMonth =  MoveInForm.MoveInMonth.options[MoveInForm.MoveInMonth.selectedIndex].value;
	if (MoveInMonth.length  == 1)
	{MoveInMonth = '0' + MoveInMonth;	}
var MoveInDay =  MoveInForm.MoveInDay.options[MoveInForm.MoveInDay.selectedIndex].value;
	if  (MoveInDay.length == 1)
	{MoveInDay = '0' + MoveInDay;	}	
	
var FinPossessionDt = MoveInForm.RentYear.options[MoveInForm.RentYear.selectedIndex].value  +  
	FinPossessionMonth + FinPossessionDay;
var MoveInDt = MoveInForm.MoveInYear.options[MoveInForm.MoveInYear.selectedIndex].value  +  
		MoveInMonth + MoveInDay;
  	if (MoveInDt < FinPossessionDt)
  	{alert('Physical Move In Date must be Same or Greater than Financial Possession Date'  );
  	MoveInForm.MoveInDay.focus();
  	return false;
	}		
 //	var FinPossessionDt = MoveInForm.RentYear.options[MoveInForm.RentYear.selectedIndex].value  + '-'+
//	 MoveInForm.RentMonth.options[MoveInForm.RentMonth.selectedIndex].value + '-'+ 
//	 MoveInForm.RentDay.options[MoveInForm.RentDay.selectedIndex].value ;

 //	var MoveInDt = MoveInForm.MoveInYear.options[MoveInForm.MoveInYear.selectedIndex].value  + '-'+
//	 MoveInForm.MoveInMonth.options[MoveInForm.MoveInMonth.selectedIndex].value + '-'+ 
//	 MoveInForm.MoveInDay.options[MoveInForm.MoveInDay.selectedIndex].value;

 //	alert(FinPossessionDt + ' : '+ MoveInDt);
 //  	if (MoveInDt < FinPossessionDt)
  //	{alert('Physical Move In Date must be same or greater than Rent Effective Date');
  //	MoveInForm.MoveInDay.focus();
  //	return false;
//	}		
       maskZIP(this);
 	return true;
//		verifyNRF(); 
	}
</script>
<script>
	<cfoutput>	
		function respiterates (string){
			if (string.value == 3 && #qRespiteChargeCheck.RecordCount# == 0){ 
				var message = 'There no respite rates entered for this house. \r Please  contact your AR Specialist for assistance.';
				df0.Message.value = 'There no respite rates entered for this house.'; alert(message);
				string.options[0].selected = true;	
			}
			else if (string.value == 3){ 
				var message = 'Respite Residents REQUIRE a Projected Physical Move Out Date.';
				alert(message);
			//	string.options[0].selected = true;	
			}
		}
	</cfoutput>
</script>
 <script>//mamta modified for memorycare
   function DisplayAPtList(string){
		//alert(string.value);
		document.MoveInForm.iAptNum.options.length=0;
	//document.MoveInForm.iAptNum2.options[0] = new Options(documents.MoveInForm.iAptNum2.options[0].text,document.MoveInForm.iAptNum2.options[0].value);
	
		if (document.MoveInForm.iproductline_id.value==1)
		{
			if (string.value == 2) 
			{
				
				//alert (document.MoveInForm.iAptNum2.options.length);
				for (var i = 0; i < document.MoveInForm.iAptNum2.options.length; i++)
				{
					document.MoveInForm.iAptNum.options[i] = new Option(document.MoveInForm.iAptNum2.options[i].text, document.MoveInForm.iAptNum2.options[i].value);
				}
			}
		
			else{   
					//alert (document.MoveInForm.iAptNum3.options.length);
				for (var j = 0; j < document.MoveInForm.iAptNum3.options.length; j++)
				{	
					
					document.MoveInForm.iAptNum.options[j] = new Option(document.MoveInForm.iAptNum3.options[j].text,document.MoveInForm.iAptNum3.options[j].value);
					
				//document.MoveInForm.iAptNum.appendChild(document.MoveInForm.iAptNum3.options[j]);
				//document.MoveInForm.iAptNum.options[j]=document.MoveInForm.iAptNum3.options[j];
				}
			}
		}
		else {
		for (var i = 0; i < document.MoveInForm.iAptNum5.options.length; i++)
						{
							//alert(string.value);
						document.MoveInForm.iAptNum.options[i] = new Option(document.MoveInForm.iAptNum5.options[i].text, document.MoveInForm.iAptNum5.options[i].value);
						
						}
						//window.DisplayAPtList = null;	
						//alert('test');		
		}
   }
		</script>
		<script>//Mamta -added new function for display of residencytype on selection of productline
			function DisplayResidencyType(string)
			{   document.MoveInForm.iResidencyTypeID.options.length=0; 
				// alert(string.value);
				if (string.value == 2)
				 {    // alert('test');
				 	    for (var i = 0; i < document.MoveInForm.iResidencyTypeID_2.options.length; i++)
						{
							//alert(string.value);
						document.MoveInForm.iResidencyTypeID.options[i] = new Option(document.MoveInForm.iResidencyTypeID_2.options[i].text, document.MoveInForm.iResidencyTypeID_2.options[i].value);
						
						}
						//alert('test');
				 }
				 else{
				 	for (var i = 0; i < document.MoveInForm.iResidencyTypeID_1.options.length; i++)
						{
							//alert(string.value);
						document.MoveInForm.iResidencyTypeID.options[i] = new Option(document.MoveInForm.iResidencyTypeID_1.options[i].text, document.MoveInForm.iResidencyTypeID_1.options[i].value);
						
						}
				 }
    		}
		</script>
<cfform name="test">
<input type="hidden" id="test" name="test" value="document.test.test.value;" >
</cfform>
<CFSCRIPT>	if (IsDefined("form.test")) { test = form.test; } else { test = "0.00"; }
</CFSCRIPT>
<!--- <cfoutput> #test# </cfoutput> --->

<script>
	function showHelp(){
 		window.open("TIPS-Move-In-Process.pdf");
	}
</script>

	<!--- mstriegel:10/23/2017 this is for the bundled pricing section --->
	<!--- create a local struct variable to prevent var leak --->
	<cfset loc = {}>
	<!--- QofQ to get only the ids for stuido apartments --->
	<cfquery name="loc.apartmentType" dbtype="query">
		SELECT iAptAddress_ID
		FROM Available
		WHERE iAptType_ID IN (1,2,16,18,33,34,50,51,52,53,58,71,80,81,85,86,87,88,93,96,97,100,101,102)	
	</cfquery>
	<cfquery name="qGetBundledPricingHouses" datasource="#application.datasource#">
		SELECT iHouse_ID
		FROM House WITH (NOLOCK)
		WHERE bIsBundledPricing =1
	</cfquery>

	<!--- convert the query resultset into a list --->
	<cfset loc.lstApartmentTypeID = ValueList(loc.apartmentType.iAptAddress_ID)>
	<!--- list of house id's that have bundled pricing.  --->
	<cfset loc.lstHasBundledPricingHouseIDs = ValueList(qGetBundledPricingHouses.iHouse_ID)>
	<script type="text/javascript">
		//called on the apartment number onChange event. Determine if the value selected is a studio apartment.
		function dspBundledPricingChkbx(obj){
		<!--- if/else logic for houses that offer bundled pricing --->
		<cfif ListFindNoCase(loc.lstHasBundledPricingHouseIDs,session.qSelectedHouse.iHouse_ID,",")>
			//get a list of studio apartment ids	
			var lstStudioID = '<cfoutput>#loc.lstApartmentTypeID#</cfoutput>';
			//display label and checkbox	
			document.getElementById('dspBundlePricing').style.display = 'block';	
			document.getElementById('chkBundlePricing').style.display = 'block';			
			//make it disabled
			document.getElementById('bundledPricing').disabled=true;		
			//convert to an array
			var arrStudioId = lstStudioID.split(',');		
			// loop over array to check if the value selected is in the array
			for(i=0;i <= arrStudioId.length; i++){
				if(obj.value == arrStudioId[i]){
					//the value is in the array enable the checkbox				
					document.getElementById('bundledPricing').disabled=false;
				}		
			}	
		<cfelse>
		<!--- if they don't have bundled pricing then we will just continue. This prevents a JS error --->
			return true;
		</cfif>	
		}
	</script>

<style type="text/css">
table.outside {
	border-width: 2px;
	border-spacing: ;
	border-style: outset;
	border-color: green;
	border-collapse: separate;
	background-color: white;
}
table.tableA th {
	border-width: 1px;
	padding: 1px;
	border-style: inset;
	border-color: red;
	background-color: white;
	-moz-border-radius: ;
}
table.tableB td {
	border-width: 1px;
	padding: 1px;
	border-style: inset;
	border-color: blue;
	background-color: white;
	-moz-border-radius: ;
}
</style>

<cfoutput>
<form name="MoveInForm" action="#Variables.Action#" method="POST" onSubmit="return requiredBeforeYouLeave(); "><!---   hardhaltvalidation(); --->
<br/><a href="../MainMenu.cfm" style="font-size: 18;"> <B>Exit Without Saving</B></a><br/>
	<input type="hidden" name="iTenant_ID" value="#URL.ID#">
	<input type="hidden" name="cSolomonKey" value="#Tenant.cSolomonKey#">
	<input type="hidden" name="cMilitaryVA" value="">
	<input type="hidden" name="hasExecutor" value="">
	<input type="hidden" name="NrfDiscApprove" value="" />
	<input type="hidden" name="stateID" value="#session.qselectedhouse.cstatecode#">
	<input type="hidden" name="thisHouseID" value="#session.qselectedhouse.iHouse_ID#">		
	<input type="text" name="Message" value="" size="75"
		style="color: red; font-weight: bold; font-Size: 16; text-align: center;" readonly="readonly">
	<cfif HouseDetail.mStateMedicaidAmt_BSF_Daily is ''> 
		<input  type="hidden" name="StateMedicaidAmtBSFDaily"  id="iStateMedicaidAmtBSFDaily" value="NF" />
	<cfelse>
		<input  type="hidden" name="StateMedicaidAmtBSFDaily"  id="iStateMedicaidAmtBSFDaily" value="#HouseDetail.mStateMedicaidAmt_BSF_Daily#" />	
	</cfif>
	<input type="hidden" name="NrfAdj" value =  '' /> 	
	<input type="hidden" name="NrfDisc" value = '' />   
	<!---Mshah--->
	<input type="hidden" name="OccupiedListtest" id="OccupiedListtest" value = '<cfoutput> #OccupiedNoncompanionList# </cfoutput>' />
	<input type="hidden" name="ResidentName" id="ResidentName" value = '<cfoutput> #Tenant.cFirstname# #Tenant.cLastName# </cfoutput>' />
	<!--- mstriegel:10/23/17 added list of studios to a hidden form element --->
	<input type="hidden" name="StudioIdLst" id="studioIDLst" value="<cfoutput>#loc.lstApartmentTypeID#</cfoutput>">
	<!---Mshah--->
<table    width="640px"   > 
<tr><td>
<table>
	<tr>
		<th colspan="6" style="font-size:medium;"><b>Move In Form</b></th>
	</tr>
	<tr>
		<td colspan="6">
		Need help with a Move In? Select here: &nbsp;&nbsp;
		<img src="../../images/Move-In-Help.jpg" width="25" height="25" 
			onclick="showHelp();" />
		</td>
	</tr>
	<tr>
		<td colspan="6" align="left">
		Second Resident information:&nbsp;&nbsp; <a href="Second Resident.pdf" target="new"> <img src="../../images/Move-In-Help.jpg" width="25" height="25"/> <a/>
		</td>
	</tr>
	<tr> 
		<td style="font-weight: bold; width:150px">Residents Name</td>
		<td > #Tenant.cFirstname# #Tenant.cLastName#</td>
	</tr>

	<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;">Middle Initial</td>
		<td><input name="cMiddleInitial" type = "text" value="#Tenant.cMiddleInitial#" size="1"></td>
	</tr>
	
	<tr>
		<td style="font-weight: bold;">SSN</td>
		<td><input type="text" name="cSSN" id="cSSN" value="#Tenantinfo.cSSN#"
         	onblur="maskSSN(this);" onkeypress="return allowOnlyNumberOnKey(event)"  
			size="11" maxlength="11" />
        </td>
	</tr>
	
	<tr style="background-color:##FFFFCC">	
		<td style="font-weight: bold;"> Birthdate </td>
		<td>
			<input type="text" id="dbirthdate" Name="dbirthdate" 
			value = "#DateFormat(tenant.dbirthdate,"mm/dd/yyyy")#" 
			size ="8"> (MM/DD/YYYY)
		</td> 
	</tr>
	<tr style="background-color:##FFFFCC">	
		<td style="font-weight: bold;"> Sex </td>
		<td>
				<select name="cSex">
				<cfif Tenant.csex is ''>
					<option value="">Select</option>
					<option value="F">F</option>
					<option value="M">M</option>	
				<cfelse>
				<option value="#Tenant.csex#">#Tenant.csex#</option>
				</cfif>			
				</select>
		</td>  
	</tr>	
	<TR>
		<TD><strong>PREVIOUS ADDRESS</strong></TD>
	</TR>
	<tr>
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Address Line 1 </td>
		<td>
			<input type="text" name="cPreviousAddressLine1" 
			value="#tenant.cPreviousAddressLine1#" 
			size="40" maxlength="40" onblur="upperCase(this);">
		</td>
	</tr>
	<tr style="background-color:##FFFFCC">
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Address Line 2 </td>
		<td>
			<input type="text" name="cPreviousAddressLine2" 
			value="#tenant.cPreviousAddressLine2#" 
			size="40" maxlength="40" onblur="upperCase(this);">
		</td>
	</tr>
	<tr>	
		<td colspan="5">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;City 
			<input type="text" name="cPreviousCity" value="#Tenant.cPreviousCity#" 
			onkeypress="return allowOnlyLettersOnKey(event);" 
			onblur="upperCase(this);">
			State 
				<select name="cPreviousState">
					<option value=""> Select </option>
					<cfloop query="StateCodes">
						<cfscript>
							if  (TenantInfo.cPreviousState eq statecodes.cStateCode)
							 { Selected = 'Selected'; }
							else { Selected = ''; }
						</cfscript>
						<option value="#Statecodes.cStateCode#" #Selected#>
						 #cStateName# - #cStateCode# 
						  </option>
					</cfloop>
				</select>
			<BR />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Zip (Postal) Code 
			<input type="text" name="cPreviouszipCode" value="#tenant.cPreviouszipCode#"
			 maxlength="10" size="10" onblur="maskZIP(this);"/>
 		</td><!--- onkeypress="return allowOnlyNumberOnKey(event)"  --->
	</tr>
	<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;"> Product line </td>
		<td><cfset productoptions="">
		<cfloop query="qproductline">
			<cfset productoptions=productoptions&"<option value='#qproductline.iproductline_id#'>#qproductline.cDescription#</option>">
		</cfloop>
			<select id="iproductline_id" name="iproductline_id" onChange="DisplayResidencyType(this);"><option value="" >#productoptions#</select>	
		</td>
		<td colspan="2"></td>
	<tr>
		<td style="font-weight: bold;"> Residency Type</td>

		<!---<cfif tenant.iResidencyType_ID is 3>
		<td colspan="5">
			<select name="iResidencyType_ID" onChange="respiterates(this);">
					<option value="3">Respite</option>
			</select>
			<font color="red">*Please Enter Projected Move Out Date:</font>
		</td>		
		<!---<cfelseif tenant.iResidencyType_ID is 2>
		<td colspan="5">
			<select name="iResidencyType_ID" onChange="respiterates(this);">
					<option value="2">Medicaid</option>
			</select>
		</td>	--->	
		<cfelse>--->
		<td colspan="5">
			<!---Make two select and show on thw basis of selection of productline
		<input type="hidden" name="dispAPT" id="dispAPT" value=""  readonly=""/>--->
		
				<select name="iResidencyType_ID" ID="iResidencyTypeID"
				onChange="respiterates(this);typMedicaid(this);DisplayAPtList(this);isMedicaidHouse(this);">
				</select>
		
		<select name="iResidencyType_ID1" ID="iResidencyTypeID_1" style="visibility: hidden" 
		onChange="respiterates(this);typMedicaid(this);DisplayAPtList(this);isMedicaidHouse(this);">
				 <option value="1" > 
			<cfloop query="Residency">
				<option value="#Residency.iResidencyType_ID#" > #Residency.cDescription# </option>
			</cfloop>
		</select>
		
		<select name="iResidencyType_ID2" ID="iResidencyTypeID_2" style="visibility: hidden" 
		onChange="respiterates(this);typMedicaid(this);DisplayAPtList(this);isMedicaidHouse(this);">
				 <option value="2" > 
			<cfloop query="ResidencyMemoryCare">
				<option value="#ResidencyMemoryCare.iResidencyType_ID#" > #ResidencyMemoryCare.cDescription# </option>
			</cfloop>
		</select>
			<!--- <font color="red">*Please Enter Projected Move Out Date if the Resident is Respite</font> --->
			<!--- <div style="color:red; font-weight:bold">
			 *Respite Residents REQUIRE Projected Move Out Date
			 </div> --->
		</td>		
		<!---</cfif> --->		

	</tr>	
	<!---<cfoutput>Value of dispAPT iResidencyType_ID</cfoutput>
<cfif isDefined("dispAPT")>
<cfoutput>Value of dispAPT #iResidencyType_ID#</cfoutput>
</cfif>
--->
	<cfif bondhouse.iBondHouse eq 1> 		 
		<tr>
			<td colspan="2" style="Font-weight: bold;color:red;">
				Did the resident qualify as eligible for meeting<br>
				 the Bond program occupancy requirements?  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				 <cfif tenant.bIsBond is 1>
					 Yes<input type="radio" name="cBondQualifying" id="cBondQualifying" value="1" 
						onclick="document.MoveInForm.cBondQualifying.value=this.value;"
						 checked="checked"> 
					 No<input type="radio" name="cBondQualifying" id="cBondQualifying" value="0" 
						onclick="document.MoveInForm.cBondQualifying.value=this.value;">
					<cfelseif tenant.bIsBond is 0>
					 Yes<input type="radio" name="cBondQualifying" id="cBondQualifying" value="1" 
						onclick="document.MoveInForm.cBondQualifying.value=this.value;"> 
					 No<input type="radio" name="cBondQualifying" id="cBondQualifying" value="0" 
						onclick="document.MoveInForm.cBondQualifying.value=this.value;"
						 checked="checked">
				<cfelse>
					 Yes<input type="radio" name="cBondQualifying" id="cBondQualifying" value="1" 
						onclick="document.MoveInForm.cBondQualifying.value=this.value;"> 
					 No<input type="radio" name="cBondQualifying" id="cBondQualifying" value="0" 
						onclick="document.MoveInForm.cBondQualifying.value=this.value;">
				</cfif>
			</td>
		</tr>
			
			<tr>		
				<td colspan="2">
					<span style="Font-weight: bold;color:red;">
					Date the income certification was faxed or emailed to the Corporate Office:&nbsp;
					</span>
				<cfif tenant.dtBondCert is not "">
					<td>
						<input type="text" name="dtBondCertificationMailed" 
						value="#dateformat(tenant.dtBondCert, 'mm/dd/yyyy')#" 
						size="10" maxlength="10"> (MM/DD/YYYY)
					</td>
				<cfelse>
					<td>
						<input type="text" name="dtBondCertificationMailed" value="00/00/0000"
						 size="10" maxlength="10"> (MM/DD/YYYY)
					</td>		
				</cfif>		
			</tr>
			<cfif bondhouse.bBondHouseType eq '1'><!--- Percent by total units --->
					<cfset BondPercent = ((#bAptCount.B# / #AptCountTot.T#) * 100)>
					<input type="hidden" name="BPercent" value="#BondPercent#">
					<cfset BondHTML = "#NumberFormat(BondPercent, '__.__')#">
			<cfelse>								<!--- Percent by occupied --->
					<cfset BondPercent = ((#bAptCount.B# / OccupiedRowCount) * 100)>
					<input type="hidden" name="BPercent" value="#BondPercent#">
					<cfset BondHTML = "#NumberFormat(BondPercent, '__.__')#">
			</cfif>
	</cfif>	
	<!--- Mamta added
			 <cfoutput>bondhouse.bIsMedicaid #bondhouse.bIsMedicaid# </cfoutput>
			 <cfoutput> #tenant.iResidencyType_ID#tenant.iResidencyType_ID  </cfoutput> --->
	
			<cfif bondhouse.bIsMedicaid eq '1'><!--- Percent by total units --->
					<cfset MedicaidPercent = ((#MedicaidAptCount.TotalMedicaidApt# / #AptCountTotal.T#) * 100)>
					<input type="hidden" name="MedicaidPercent" value="#MedicaidPercent#">
					<cfset MedicaidHTML = "#NumberFormat(MedicaidPercent, '__.__')#">
			</cfif>
	 <tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;">	Apartment Number
			<!--- mstriegel:10/23/17 added if statment for houses that offer bundled pricing. --->
			<cfif ListFindNoCase(loc.lstHasBundledPricingHouseIDs,session.qSelectedHouse.iHouse_id,",")>
				<span id="dspBundlePricing" style="display:none;">
					<br />Bundled Pricing?
				</span>
			</cfif>
		</td>
		
		<td colspan="4" style="color:##FF0000">
			<!--- mstriegel:10/23/17 added the onchange event --->
			<select name="iAptAddress_ID" ID="iAptNum" onfocus="checkbond();" onchange="dspBundledPricingChkbx(this);">
				<option value=" ">Select Apartment...
					<cfif bondhouse.bIsMedicaid eq 1>Medicaid Apt: #MedicaidHTML#%</cfif> 
					<cfif bondhouse.iBondHouse eq 1>Bond Apt: #BondHTML#%</cfif>
				 </option>
			</select>
			<!--- mstriegel 10/23/17 if statement is to add this option if the house offers bundled pricing  --->
			<cfif ListFindNoCase(loc.lstHasBundledPricingHouseIDs,session.qSelectedHouse.iHouse_id,",")>
				<span id="chkBundlePricing" style="display:none; text-align:bottom;">
					 <input type="checkbox" name="bundledPricing" id="bundledPricing" value="1" <cfif #VAL(tenantInfo.bIsBundled)# EQ "1">Checked</cfif>>
				</span>
			</cfif>
		</td>
		<!--- <td colspan="4" style="color:##FF0000">
		 <td colspan="4" style="color:##FF0000"> --->
    <select name="iAptAddress_ID2" ID="iAptNum2" style="visibility: hidden">
    	<!--- mstriegel:11/09/2017 added the default option below --->
    	<option value="">Select Apartment</option>
	 <cfif bondhouse.iBondHouse eq 0 and bondhouse.bIsMedicaid eq 1>
		<CFLOOP QUERY='MedicaidAptList'>	
			<cfscript>
				if (ListFindNoCase(OccupiedMedicaidAptList,MedicaidAptList.iAptAddress_ID,",") GT 0)
				{Note = '(Occupied) ';} 
				else
				{Note='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
				if (ListFindNoCase(MedicaidbondAptList,MedicaidAptList.iAptAddress_ID,",") GT 0){Note1 = '(Bond) ';} 
				else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
				if (ListFindNoCase(MedicaidbondIncludedAptList,MedicaidAptList.iAptAddress_ID,",") GT 0){Note2 = '(Included)';} 
				else{ Note2=''; } 
			</cfscript>	
			<option value= "#MedicaidAptList.iAptAddress_ID#">
				 #MedicaidAptList.cAptNumber# - #MedicaidAptList.cDescription# #Note# Medicaid
			 </option>
		</CFLOOP>
	</cfif>
	<cfif bondhouse.iBondHouse eq 1 and bondhouse.bIsMedicaid eq 1>
		<cfloop query="MedicaidAptList">
				<cfscript>
					if (ListFindNoCase(OccupiedMedicaidAptList,MedicaidAptList.iAptAddress_ID,",") GT 0)
					{Note = '(Occupied) ';} 
					else
					{Note='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
					if (ListFindNoCase(MedicaidbondAptList,MedicaidAptList.iAptAddress_ID,",") GT 0){Note1 = '(Bond) ';} 
					else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
					if (ListFindNoCase(MedicaidbondIncludedAptList,MedicaidAptList.iAptAddress_ID,",") GT 0){Note2 = '(Included)';} 
					else{ Note2=''; } 
				
					/*if (IsDefined("TenantInfo.iAptAddress_ID") 
					and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
						OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") 
						and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
						Selected = 'Selected'; }
					else { Selected = ''; }*/
				</cfscript>
				<option value= "#MedicaidAptList.iAptAddress_ID#">
				#MedicaidAptList.cAptNumber# - #MedicaidAptList.cDescription# #Note# Medicaid #Note1# #Note2# 
				</option>	
		</cfloop>
	</cfif>			  
	</select>
	<select name="iAptAddress_ID3" ID="iAptNum3" style="visibility: hidden">
		<!--- mstriegel:11/09/2017 added the default option below --->
		<option value="">Select Apartment</option>
		<cfif bondhouse.iBondHouse eq 0 and bondhouse.bIsMedicaid eq 1>
			<cfloop query="Available">
				 <cfscript>
					if (ListFindNoCase(OccupiedList,Available.iAptAddress_ID,",") GT 0)
					{Note = '(Occupied) ';} 
					else
				 { Note='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
					if (ListFindNoCase(MedicaidApartmentList,Available.iAptAddress_ID,",") GT 0){Note3 = '(Medicaid) ';} 
					else{ Note3='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
					if (ListFindNoCase(MemoryCareApartmentList,Available.iAptAddress_ID,",") GT 0){Note1 = '(Memory Care) ';} 
						else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
					if (IsDefined("TenantInfo.iAptAddress_ID") 
					and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
						OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") 
						and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
						Selected = 'Selected'; }
					else { Selected = ''; }
				</cfscript>
				<option value= "#Available.iAptAddress_ID#">
					#Available.cAptNumber# - #Available.cDescription# #Note# #Note3# #Note1#
				</option>	
		</cfloop>
	</cfif>
	<cfif bondhouse.iBondHouse eq 1 and bondhouse.bIsMedicaid eq 1>
			 <cfloop query="Available">
				  <cfscript>
						if (ListFindNoCase(OccupiedList,Available.iAptAddress_ID,",") GT 0)
						{Note = '(Occupied) ';} 
						else
					   { Note='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
						if (ListFindNoCase(MedicaidApartmentList,Available.iAptAddress_ID,",") GT 0){Note3 = '(Medicaid) ';} 
						else{ Note3='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
						if (ListFindNoCase(BondAptList,Available.iAptAddress_ID,",") GT 0){Note1 = '(Bond) ';} 
						else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
						if (ListFindNoCase(BondIncludedAptList,Available.iAptAddress_ID,",") GT 0){Note2 = '(Included)';} 
						else{ Note2=''; } 
						if (ListFindNoCase(MemoryCareApartmentList,Available.iAptAddress_ID,",") GT 0){Note4 = '(Memory Care) ';} 
						else{ Note4='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
					if (IsDefined("TenantInfo.iAptAddress_ID") 
						and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
							OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") 
							and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
							Selected = 'Selected'; }
						else { Selected = ''; }
				  </cfscript>
				  <option value= "#Available.iAptAddress_ID#" >
				 #Available.cAptNumber# - #Available.cDescription# #Note# #Note3# #Note1# #Note2##Note4#
				 </option>	
	         </cfloop>
	</cfif>
	<cfif bondhouse.iBondHouse eq 1 and bondhouse.bIsMedicaid eq "">
			 <cfloop query="Available">
				  <cfscript>
						if (ListFindNoCase(OccupiedList,Available.iAptAddress_ID,",") GT 0)
						{Note = '(Occupied) ';} 
						else
					   { Note='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
						if (ListFindNoCase(BondAptList,Available.iAptAddress_ID,",") GT 0){Note1 = '(Bond) ';} 
						else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
						if (ListFindNoCase(BondIncludedAptList,Available.iAptAddress_ID,",") GT 0){Note2 = '(Included)';} 
						else{ Note2=''; } 
						if (ListFindNoCase(MemoryCareApartmentList,Available.iAptAddress_ID,",") GT 0){Note4 = '(Memory Care) ';} 
						else{ Note4='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
					if (IsDefined("TenantInfo.iAptAddress_ID") 
						and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
							OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") 
							and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
							Selected = 'Selected'; }
						else { Selected = ''; }
				  </cfscript>
				  <option value= "#Available.iAptAddress_ID#" >
				 #Available.cAptNumber# - #Available.cDescription# #Note# #Note1# #Note2##Note4#
				 </option>	
	         </cfloop>
	<cfelse>
	      <cfloop query="Available">
				<cfscript>
					if (ListFindNoCase(OccupiedList,Available.iAptAddress_ID,",") GT 0)
					{Note = '(Occupied)';} else{ Note=''; }
					if (ListFindNoCase(MemoryCareApartmentList,Available.iAptAddress_ID,",") GT 0){Note1 = '(Memory Care) ';} 
						else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
				   if (IsDefined("TenantInfo.iAptAddress_ID") 
					and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
						OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") 
						and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
						Selected = 'Selected'; }
					else { Selected = ''; }
				</cfscript>
				<option value= "#Available.iAptAddress_ID#" >
				 #Available.cAptNumber# - #Available.cDescription##NOTE##NOTE1#
				 </option>
		</cfloop>
	</cfif>
 </select>
 <!--- Memory Care --->
     <select name="iAptAddress_ID5" ID="iAptNum5" style="visibility: hidden">
     	<!--- mstriegel:11/09/2017 added the default option below --->
     	<option value="">Select Apartment</option>
		<CFLOOP QUERY='MemCareAptList'>	
			<cfscript>
			   Note = '(Memory Care)';
			 	if (ListFindNoCase(OccupiedMemcareAptList,MemCareAptList.iAptAddress_ID,",") GT 0)
			 	{Note1 = '(Occupied) ';} 
				else{ Note1=''; }
					if (IsDefined("TenantInfo.iAptAddress_ID") 
					and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
						OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") 
						and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
						Selected = 'Selected'; }
					else { Selected = ''; }
			  
			</cfscript>	
			<option value= "#MemCareAptList.iAptAddress_ID#">
				 #MemCareAptList.cAptNumber# - #MemCareAptList.cDescription#    #Note#  #Note1#
			 </option>
		</CFLOOP>
	</select>
 
 <!---  --->
</tr>			    		
	   <!---<script>
   function DisplayAPtList(string){
		//alert(string.value);
		document.MoveInForm.iAptNum.options.length=0;
		/*
		var toSelect = document.MoveInForm.iAptNum;
		//toSelect.innerHTML = "";
		
		if (string.value == 2) 
		{			
			var fromSelect = document.MoveInForm.iAptNum2;
		}
		else{
			var fromSelect = document.MoveInForm.iAptNum3;
		}
			for (var i = 0; i < fromSelect.options.length; i++) 
			{
	    		var option = fromSelect.options[i];
	    		toSelect.appendChild(option);
			}
		*/	
			
		if (string.value == 2) 
		{
				//alert (document.MoveInForm.iAptNum2.options.length);
			for (var i = 0; i < document.MoveInForm.iAptNum2.options.length; i++)
			{
				//alert(i);
			//document.MoveInForm.iAptNum.options[i] = new Option(document.MoveInForm.iAptNum2.options[i]);
			document.MoveInForm.iAptNum.options[i] = new Option(document.MoveInForm.iAptNum2.options[i].text, document.MoveInForm.iAptNum2.options[i].value);
			//document.MoveInForm.iAptNum.appendChild(document.MoveInForm.iAptNum2.options[i]);
			//document.MoveInForm.iAptNum.options[i]=document.MoveInForm.iAptNum2.options[i];
			}
		}
		else{
				//alert (document.MoveInForm.iAptNum3.options.length);
			for (var j = 0; j < document.MoveInForm.iAptNum3.options.length; j++)
			{
			document.MoveInForm.iAptNum.options[j] = new Option(document.MoveInForm.iAptNum3.options[j].text,document.MoveInForm.iAptNum3.options[j].value);
			//document.MoveInForm.iAptNum.appendChild(document.MoveInForm.iAptNum3.options[j]);
			//document.MoveInForm.iAptNum.options[j]=document.MoveInForm.iAptNum3.options[j];
			}
		}
		
   }
		</script>--->
		<!---><script>
			//Mamta
		function dispval(string)
	{
	alert(string.value);
	}
	function DisplayAPtList1(string){
		alert(string.value);
		if (string.value == 2) {
			//setTenantisMedicaid=1;
			rl="<SELECT>";
		    <CFLOOP QUERY='MedicaidAptList'>
			r1+= "<OPTION> #MedicaidAptList.cAptNumber# - #MedicaidAptList.cDescription# </OPTION>";
			//rl+="<OPTION> #MedicaidAptList.cAptNumber# - #MedicaidAptList.cDescription# </OPTION>";
			</CFLOOP>
			rl+="</SELECT>";
			//alert (setTenantisMedicaid);
			document.all['aptlistone'].innerHTML = r1;
			document.all['aptlistone'].style.display = 'inline';
		}
		
		else if (string.value == 3||string.value == 1) {
		
	        r1="<OPTION VALUE=''>Select list 2</OPTION>";
			//setTenantisMedicaid=1;
			//alert (setTenantisMedicaid);
			document.all['aptlistone'].innerHTML=r1;
			document.all['aptlistone'].style.display='inline'; 
		}
		else {
			document.all['aptlistone'].style.display = 'none';
		}
						
	}
	</script>
	        <cfoutput> <SPAN ID="aptlistone"> </SPAN> </cfoutput>--->
			 	<!--- mamta modify to display units for medicaid also
				
					<cfif bondhouse.iBondHouse eq 1 and bondhouse.bIsMedicaid eq "">
						<cfloop query="Available">
						<cfscript>
							if (ListFindNoCase(OccupiedList,Available.iAptAddress_ID,",") GT 0)
							{Note = '(Occupied) ';} 
							else
						{ Note='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							if (ListFindNoCase(BondAptList,Available.iAptAddress_ID,",") GT 0){Note1 = '(Bond) ';} 
							else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							if (ListFindNoCase(BondIncludedAptList,Available.iAptAddress_ID,",") GT 0){Note2 = '(Included)';} 
							else{ Note2=''; } 
						
							if (IsDefined("TenantInfo.iAptAddress_ID") 
							and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
								OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") 
								and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
								Selected = 'Selected'; }
							else { Selected = ''; }
						</cfscript>
						<option value= "#Available.iAptAddress_ID#" #Selected#>
						 #Available.cAptNumber# - #Available.cDescription##NOTE##NOTE1##NOTE2#
						 </option>	
						 </cfloop>
					
			  <cfelseif bondhouse.iBondHouse eq "" and bondhouse.bIsMedicaid eq 1>
			            <cfif tenant.iResidencyType_ID is 2>
						 <cfloop query="MedicaidAptList">
							<cfscript>
							if (ListFindNoCase(OccupiedMedicaidAptList,MedicaidAptList.iAptAddress_ID,",") GT 0)
							{Note = '(Occupied) ';} 
							else
						    {Note='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							</cfscript>
					     <option value= "#MedicaidAptList.iAptAddress_ID#" #Selected#>
						#MedicaidAptList.cAptNumber# - #MedicaidAptList.cDescription# #Note# Medicaid
						  </option>	
					     </cfloop>
					    <cfelse>
				  	    <cfloop query="Available">
					     <cfscript>
							if (ListFindNoCase(OccupiedList,Available.iAptAddress_ID,",") GT 0)
							{Note = '(Occupied) ';} 
							else
						 { Note='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							if (ListFindNoCase(MedicaidApartmentList,Available.iAptAddress_ID,",") GT 0){Note3 = '(Medicaid) ';} 
							else{ Note3='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							
							if (IsDefined("TenantInfo.iAptAddress_ID") 
							and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
								OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") 
								and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
								Selected = 'Selected'; }
							else { Selected = ''; }
						</cfscript>
						<option value= "#Available.iAptAddress_ID#" #Selected#>
						 #Available.cAptNumber# - #Available.cDescription# #Note# #Note3#
						 </option>	
					    </cfloop>
					  </cfif>
					   
				 <cfelseif bondhouse.iBondHouse eq 1 and bondhouse.bIsMedicaid eq 1>
				          <cfif tenant.iResidencyType_ID is 2>
					        <cfloop query="MedicaidAptList">
							<cfscript>
							if (ListFindNoCase(OccupiedMedicaidAptList,MedicaidAptList.iAptAddress_ID,",") GT 0)
							{Note = '(Occupied) ';} 
							else
						    {Note='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							if (ListFindNoCase(MedicaidbondAptList,MedicaidAptList.iAptAddress_ID,",") GT 0){Note1 = '(Bond) ';} 
							else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							if (ListFindNoCase(MedicaidbondIncludedAptList,MedicaidAptList.iAptAddress_ID,",") GT 0){Note2 = '(Included)';} 
							else{ Note2=''; } 
						
							/*if (IsDefined("TenantInfo.iAptAddress_ID") 
							and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
								OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") 
								and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
								Selected = 'Selected'; }
							else { Selected = ''; }*/
							</cfscript>
					        <option value= "#MedicaidAptList.iAptAddress_ID#" #Selected#>
						    #MedicaidAptList.cAptNumber# - #MedicaidAptList.cDescription# #Note# Medicaid #Note1# #Note2#
						    </option>	
					        </cfloop>
					 
					      <cfelse>
				          <cfloop query="Available">
					      <cfscript>
								if (ListFindNoCase(OccupiedList,Available.iAptAddress_ID,",") GT 0)
								{Note = '(Occupied) ';} 
								else
							   { Note='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
								if (ListFindNoCase(MedicaidApartmentList,Available.iAptAddress_ID,",") GT 0){Note3 = '(Medicaid) ';} 
								else{ Note3='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
								if (ListFindNoCase(BondAptList,Available.iAptAddress_ID,",") GT 0){Note1 = '(Bond) ';} 
								else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
								if (ListFindNoCase(BondIncludedAptList,Available.iAptAddress_ID,",") GT 0){Note2 = '(Included)';} 
								else{ Note2=''; } 
								
							
								if (IsDefined("TenantInfo.iAptAddress_ID") 
								and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
									OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") 
									and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
									Selected = 'Selected'; }
								else { Selected = ''; }
						  </cfscript>
						  <option value= "#Available.iAptAddress_ID#" #Selected#>
						   #Available.cAptNumber# - #Available.cDescription##NOTE##NOTE3##NOTE1##NOTE2#
						   </option>
					   </cfloop>
					    </cfif>
				  <cfelse>
						   <cfloop query="Available">
							<cfscript>
								if (ListFindNoCase(OccupiedList,Available.iAptAddress_ID,",") GT 0)
								{Note = '(Occupied)';} else{ Note=''; }
								if (IsDefined("TenantInfo.iAptAddress_ID") 
								and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
									OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") 
									and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
									Selected = 'Selected'; }
								else { Selected = ''; }
							</cfscript>
							<option value= "#Available.iAptAddress_ID#" #Selected#>
							 #Available.cAptNumber# - #Available.cDescription##NOTE#
							 </option>
				           </cfloop>
					 </cfif> 
			</select>
			<!--- <br />*Note: For 2nd Occupancy Rooms, select:<br /> "Use Standard House NRF"<!--- , No Deferral --->.<br  />The process will not add a NRF Fee for 2nd Occupancy in a room. --->
		</td>
	</tr>	--->
	
    <tr>
		<td  style="font-weight: bold;">Financial Possession Date</td>
		<td colspan="2">		
			<select name="RentMonth" id="RentMonth" onChange="dayslist(RentMonth,RentDay,RentYear);">
		<!--- 	setmonth();	<option value="#datepart("m",(now()))#" Selected>#datepart("m",(now()))#  </option> --->
				<option  value="">Select</option>
				<cfloop index="i" from="1" to="12" step="1">
				<option value="#i#" > #i# </option>
				</cfloop>
			</select>
			/
			<select name="RentDay" onChange="dayslist(RentMonth,RentDay,RentYear);">
			<!--- 	<option value="#datepart("d",(now()))#" Selected>#datepart("d",(now()))# </option> --->
			<option  value="">Select</option>
				<cfloop index="i" from="1" to="31" step="1">
				<option value= "#i#"  > #i# </option>
				</cfloop>
			</select>
			/
			<select name="RentYear">
				<option value="#Year(Now())-1#">#Year(Now())-1#</option>
				<option value="#Year(Now())#" selected>#Year(Now())#</option>
				<option value="#Year(Now())+1#" >#Year(Now())+1#</option>
			</select>
		</td>
	</tr>
 <!--- 	<cfif SESSION.qSelectedHouse.iopsarea_ID is   99>	 	<cfif SESSION.qSelectedHouse.iopsarea_ID is 44> --->
		<tr>
			<td  style="font-weight: bold;">Physical Move In Date  </td>
			<td colspan="2">		
				<select name="MoveInMonth" id="MoveInMonth" onChange="dayslist(MoveInMonth,MoveInDay,MoveInYear);">
			<!--- 	setmonth(); 	<option value="#datepart("m",(now()))#" Selected>#datepart("m",(now()))#  </option> --->
			<option  value="">Select</option>
					<cfloop index="i" from="1" to="12" step="1">
					<option value="#i#" > #i# </option>
					</cfloop>
				</select>
				/
				<select name="MoveInDay" 
				onChange="dayslist(MoveInMonth,MoveInDay,MoveInYear);verifyMoveinPossessionDates();">
				<option  value="">Select</option>
				<!--- 	<option value="#datepart("d",(now()))#" Selected>#datepart("d",(now()))# </option> --->
					<cfloop index="i" from="1" to="31" step="1">
					<option value= "#i#"  > #i# </option>
					</cfloop>
				</select>
				/
				<select name="MoveInYear">
					<option value="#Year(Now())-1#">#Year(Now())-1#</option>
					<option value="#Year(Now())#" selected>#Year(Now())#</option>
					<option value="#Year(Now())+1#" >#Year(Now())+1#</option>				
				</select>
			</td>
		</tr>	
<!--- 	<cfelse>	
	<input type="hidden" name="MoveInMonth" id="MoveInMonth"  value="" />
	<input type="hidden" name="MoveInDay"   id="MoveInDay"  value="" />	
	<input type="hidden" name="MoveInYear"  id="MoveInYear"  value="" />	
	</cfif>  --->
	<!---<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;"> Product line </td>
		<td><cfset productoptions="">
		<cfloop query="qproductline">
			<cfset productoptions=productoptions&"<option value='#qproductline.iproductline_id#'>#qproductline.cDescription#</option>">
		</cfloop>
			<select id="iproductline_id" name="iproductline_id">#productoptions#</select>	
		</td>
		<td colspan="2"></td>
	</tr>--->
	
	<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;">Projected Move<br />Out Date </td>
			<td><input type="text" size="8" name="dtmoveoutprojecteddate" onblur="validatePMO();"> 
			  &nbsp;&nbsp;&nbsp;RESPITE ONLY -  REQUIRED    
				<br />(MM/DD/YYYY) 
		</td>
		<td Style="color:red;" colspan="2"><span id="Mes" style="display:none">&nbsp;
		<!--- 	PMO DATE CAN'T BE IN THE PAST,OR MORE THAN 3 MONTHS IN THE FUTURE.</span> --->
		</td>
	</tr>
	<tr>
		<td style="font-weight: bold;">	Service Level Set </td>
		<td colspan="2">
			<input type="text" name="csleveltypeset" value="#TenantInfo.csleveltypeset#"
			 size="3" maxlength="3" 
			style="border:none;background:transparent;text-align:center;" readonly>
		</td>
	</tr>
	<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;"> Service Points </td>
		<td colspan="2">
		<cfif  ((IsDefined("qapoints.iSPoints") is "Yes") and  (qapoints.iSPoints  is not ""))>
			 <input type="text" name="iSPoints" value="#trim(qapoints.iSPoints)#" size="3" 
			 maxlength="3"
			style="border:none;background:transparent;text-align:center;" readonly>
		<cfelse>
			 <input type="text" name="iSPoints" value="0" size="3" maxlength="3"
			style="border:none;background:transparent;text-align:center;" readonly>		
		</cfif>
		</td>
	</tr>
	<tr>
		<td style="font-weight: bold;"> Primary Diagnosis </td>
		<td colspan="2">		
			<select name="PrimaryDiagnosis">
				<option value=""> None </option>
				<cfloop query="qDiagnosisType">
					<cfscript>
						if  (TenantInfo.iPrimaryDiagnosis eq qDiagnosisType.iDiagnosisType_ID) 
						{ Selected = 'Selected'; }
						else { Selected = ''; }
					</cfscript>
					<option value="#qDiagnosisType.iDiagnosisType_ID#" #Selected#>
					 #qDiagnosisType.cDescription# </option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;"> Secondary Diagnosis </td>
		<td colspan="2">		
			<select name="SecondaryDiagnosis">
				<option value=""> None </option>
				<cfloop query="qDiagnosisType">
					<cfscript>
						if  (TenantInfo.iSecondaryDiagnosis eq qDiagnosisType.iDiagnosisType_ID)
						 { Selected = 'Selected'; }
						else { Selected = ''; }
					</cfscript>
					<option value="#qDiagnosisType.iDiagnosisType_ID#" #Selected#>
					 #qDiagnosisType.cDescription# 
					 </option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td id="isrespayor" style="Font-weight: bold;  display:block;" colspan="5"> 
			Is the Resident also the Payor?
			<cfif Tenant.bIsPayer eq "">
			 <cfset Check="Unchecked"> 
			<cfelse> 
			<cfset Check="Checked">
			 </cfif>	
			<input type="checkbox" name="TenantbIsPayer"  id="TenantbIsPayer" value="1" 
			style="text-align: center;"
				 onKeyUp="this.value=Numbers(this.value)" 	#Variables.Check# 
				  onClick="residentPayor(this)"  >
				 <!---  onBlur="requiredBeforeYouLeave();" --->
		</td>
	</tr> 
 
	<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
		<tr style="background-color:##FFFFCC">
			<td colspan="5" style="Font-weight: bold;">
				 Was a Move In Check received?
					<cfif Tenant.bMICheckReceived is '' or Tenant.bMICheckReceived eq 0> 
						<cfset MICCheck="Unchecked">
					<cfelse> 
						<cfset MICCheck="Checked"> 
					</cfif>	
				<input type="Checkbox" name="TenantbMICheckReceived" value="1" 
				style="text-align: center;"  #Variables.MICCheck#>
			</td>
		</tr>
		<tr><td><input type="hidden"  name="PromotionUsed" id="PromotionUsed" value="" />
<!--- 		<tr> Promotion removed per J. Gedelman 09/11/2014
			<td style="font-weight: bold;"> Promotion Used </td>
			<td colspan="4">		
				<select name="PromotionUsed">
					<option value=""> None </option>
					<cfloop query="qTenantPromotion">
						<cfscript>
							if  (TenantInfo.cTenantPromotion eq qTenantPromotion.iPromotion_ID) { Selected = 'Selected'; }
							else { Selected = ''; }
						</cfscript>
						<option value="#qTenantPromotion.iPromotion_ID#" #Selected#> #qTenantPromotion.cDescription# </option>
					</cfloop>
				</select>
			</td>
		</tr> --->
		<tr style="background-color:##FFFFCC">
			<td colspan="5" style="Font-weight: bold;"> 
				Has the resident signed the Residency Agreement?
				<cfset bit= iif(Tenant.cResidenceAgreement IS 1, DE('Checked'), DE('Unchecked'))>
				<input type= "CheckBox" name= "cResidenceAgreement" Value = "1" #Variables.bit#>	
			</td>
		</tr>

	</cfif>
		<tr>
			<td colspan="5" style="font-weight: bold; color:red;">
				Does this resident have an Executor of Estate? &nbsp;&nbsp; 
				<cfif tenant.chasExecutor is 1>
					Yes <input name="hasExecutor" type="radio" value="1" 
					onclick ="document.MoveInForm.hasExecutor.value=this.value"  
						checked="checked">  
					No	<input name="hasExecutor" type="radio" value="0" 
					onclick="document.MoveInForm.hasExecutor.value=this.value"> 
				<cfelseif tenant.chasExecutor is 0>
					Yes <input name="hasExecutor" type="radio" value="1" 
					onclick ="document.MoveInForm.hasExecutor.value=this.value" >  
					No	<input name="hasExecutor" type="radio" value="0" 
					onclick="document.MoveInForm.hasExecutor.value=this.value"  
						checked="checked"> 				
				<cfelse>
					Yes <input name="hasExecutor" type="radio" value="1" 
					onclick ="document.MoveInForm.hasExecutor.value=this.value" >  
					No	<input name="hasExecutor" type="radio" value="0" 
					onclick="document.MoveInForm.hasExecutor.value=this.value"> 				
				</cfif>
			</td>
		</tr>	
	<input type="hidden" name="bondval" value="#bondhouse.ibondhouse#"> 	
	<input type="hidden" id="paidwaived"  name="cNRFFee" Value="3" >
 	<input type="hidden" name="MonthstoPay" value="0" />
 	<input type="hidden" name="NRFDeferral" value="" />	
	<cfif bondhouse.iSecurityDeposit is 1>
		<cfif Tenant.ihouse_id is 212><!--- Shasta House has only Security Deposit --->
 			<tr> 
				<td colspan="5" style="font-weight: bold; color:black;"> 
					Will this Resident have a Security Deposit?(select): 
					<select name="FeeType">
						<option value="">Select Fee type</option>
						<option value="SC" >Security Deposit</option>
						<option value="2nd" >2nd Resident, Respite, Medicaid - No Security Deposit</option>				
					</select>
				</td>
			</tr>		
		<cfelse>
			<tr>
				<td colspan="5" style="font-weight: bold; color:black;"> 
				Will this Resident have a Security Deposit or Community Fee?(select): 
					<select name="FeeType">
						<option value="">Select Fee type</option>
						<option value="CF">Community Fee</option>
						<option value="SC" >Security Deposit</option>
						<option value="2nd" >2nd Resident, Respite, Medicaid - No Community Fee or Security Deposit</option>				
					</select>
				</td>
			</tr>
		</cfif>
	<cfelse>
		<input type="hidden" name="FeeType" value="" />
	</cfif>
	 <tr style="background-color:##FFFFCC">
		 
		<td colspan="5" style="font-weight: bold;color:red;">
		Has the resident or the resident's spouse served in the Military?  
		<cfif tenant.cMilitaryVA is 1>
			Yes <input type="radio" name="cMilitaryVA" value="1" 
			onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value" 
			checked="checked"> 
			No  <input type="radio" name="cMilitaryVA" value="0" 
			onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value">
		<cfelseif tenant.cMilitaryVA is 0>
			Yes <input type="radio" name="cMilitaryVA" value="1" 
			onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value"> 
			No  <input type="radio" name="cMilitaryVA" value="0" 
			onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value" 
			checked="checked">
		<cfelse>
			Yes <input type="radio" name="cMilitaryVA" value="1" 
			onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value"> 
			No  <input type="radio" name="cMilitaryVA" value="0" 
			onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value">
		</cfif>
		</td> 
	</tr> 
 
	<tr style="background-color:##FFFFCC"><tr>
	<td colspan="5" style="font-weight: bold;">
			<div id="otherOpt3" style="display:none" align="justify">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Branch of Military served :
				
			<select name="VaBranchOfMilitary">
			<option value="">None</option>	
			<option value="United States Army">United States Army</option>
			<option value="United States Marine Corps">United States Marine Corps</option>
			<option value="United States Navy">United States Navy</option>
			<option value="United States Air Force">United States Air Force</option>
			<option value="United States Coast Guard">United States Coast Guard</option>
			<option value="United States Navy Reserve/National Guard">
			United States Navy Reserve/National Guard</option>
			<option value="United States Army Reserve/National Guard">
			United States Army Reserve/National Guard</option>
			<option value="United States Air Force Reserve/National Guard">
			United States Air Force Reserve/National Guard</option>
			<option value="United States Marine Corps Reserve/National Guard">
			United States Marine Corps Reserve/National Guard</option>
			</select> 

			</div>
		</td>
	</tr> 
	
	<tr>
		<td colspan="5" style="font-weight: bold;">
			<div id="otherOpt1" style="display:none" align="justify">
			<cfset bit= iif(Tenantinfo.VaRepresentativeContacted IS 1, DE('Checked'), DE('Unchecked'))>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Has a VA representative been contacted? 
			<input type="CheckBox" name= "VaRepresentativeContacted" Value = "1" #Variables.bit#>
		</td>
	</tr> 
	<tr style="background-color:##FFFFCC">
		<td colspan="5" style="font-weight: bold;">
			<div id="otherOpt2" style="display:none" align="justify">
			<cfset bit= iif(Tenantinfo.VaBenefits IS 1, DE('Checked'), DE('Unchecked'))>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Do they qualify for VA Benefits?
			<input type= "CheckBox" name= "VaBenefits" Value = "1" #Variables.bit# >  
		</td>
	</tr>

	<tr>
		<td colspan="5" style="font-weight: bold;" >
			<div id="otherOpt" style="display:none" align="justify">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Dates of Service: Start 
			<input type="text" name="cMilitaryStartDate" size="10" 
			onblur="dateformat(this)">
			&nbsp&nbsp&nbsp End 
			<input type="text" name="cMilitaryEndDate"  size="10" onblur="dateformat(this)">
			MM/DD/YYYY)<br>&nbsp;&nbsp; If only month/year given use 1 as the day e.g.: "01/01/1960" </div>
		</td>
	</tr> 

</table>


<table  >
	<tr>
		<cfif Refundables.recordcount GT 0>
		<td style="vertical-align:top;">
			<table style="width: 55%;">
				<tr>
					<td style="font-weight: bold;"> <U>Refundable Deposit</U> </td>
					<td style="text-align: center;"> <U>Check for Yes</U> </td>
				</tr>
				<cfloop query="Refundables">
					<tr>
						<td> #Refundables.cDescription# </td>
						<td style="text-align: center;">
							<cfquery name="Refund" datasource="#APPLICATION.datasource#">							
								select distinct T.iTenant_ID
								, (T.cFirstName + ' ' + T.cLastName) as FullName
								, c.cDescription
								, inv.iChargeType_ID
								from InvoiceDetail INV 
								join ChargeType ct on (ct.iChargeType_ID = inv.iChargeType_ID 
								and ct.dtRowDeleted is null)
								join Charges	C on (c.iChargeType_ID = ct.iChargeType_ID 
								and c.cDescription = inv.cDescription and c.dtRowDeleted is null)
								join Tenant T on (T.iTenant_ID = inv.iTenant_ID 
								and T.dtRowDeleted is null)
								where inv.dtRowDeleted is null 
								and	ct.bIsDeposit is not null and	ct.bIsRefundable is not null
								and T.cSolomonKey = '#trim(Tenant.cSolomonKey)#' 
								and c.iCharge_ID = #Refundables.iCharge_ID#
							</cfquery>
						
							<cfif Refund.RecordCount GT 0 
							and Refund.iTenant_ID eq TenantInfo.iTenant_ID 
								and (Refund.cDescription eq Refundables.cDescription)>
								<input type="CheckBox" name="Deposit#Refundables.iCharge_ID#" 
								value="#Refundables.iCharge_ID#" Checked>
							<cfelseif Refund.RecordCount GT 0 
							and Refund.iTenant_ID neq TenantInfo.iTenant_ID>
								Charged to #Refund.FullName#
							<cfelse>
								<input type="CheckBox" name="Deposit#Refundables.iCharge_ID#" 
								value="#Refundables.iCharge_ID#">
							</cfif>
						</td>
					</tr>
				</cfloop>
			</table>
		</td>
		</cfif>

	</tr>
	<cfquery name="qryMCO" datasource="#Application.datasource#">
	select * from MCOProvider where cStateCode = '#HouseDetail.cstatecode#'
	</cfquery>
	<!--- typMedicaid iMedicaid --->
 
	<tr id="typMedicaid" style="display:none" >
		<td style="text-align:center; font-weight:bold;" colspan="2">Medicaid Move-in Information</td>
	</tr>
	<tr id="typMedicaid9" style="display:none" >
		<td>Select MCO Provider</td>
		<td><select name="cMCO">
			<option value=''>Select MCO Provider</option>		
		<cfloop query="qryMCO">
			<option value='#iMCOProvider_ID#'>#cMCOProvider#</option>
		</cfloop>
		</select>
		</td>
	</tr>
	<tr id="typMedicaid1" style="display:none" >
		<cfif HouseDetail.cstatecode is 'WI'>
		<td>Enter the Medicaid Member ID Number</td>
		<cfelse>
		<td>Enter the Medicaid Authorization Number</td>
		</cfif>
		<td><input type="text" name="cMedicaidAuthorizationNbr"  id="cMedicaidAuthorizationNbr" value=""/></td>
	</tr>	
	<tr id="typMedicaid2" style="display:none" >
		<td>Enter the Authorized "From Date of Service" (FDOS - Format MM/DD/YYYY)</td>
		<td><input type="text" name="dtFDOS"  id="dtFDOS" value=""/></td>
	</tr>	
	<tr id="typMedicaid3" style="display:none" >
		<td>Enter the Authorized "Through Date Of Service" (TDOS - Format MM/DD/YYYY)</td>
		<td><input type="text" name="dtTDOS"  id="dtTDOS" value=""/></td>
	</tr>	
	
 	<script>
	function addBSFandCare()
	 { //alert('test');
        var bsf = document.getElementById("mStateMedAidAmtRB").value;
        var care = document.getElementById("mStateMedAidAmtcare").value;
        var statemedicaid = +bsf + +care;
        //alert(statemedicaid);
        document.getElementById("mStateMedAidAmtBSFD").value = Math.round(statemedicaid * 100) / 100;
      }
    </script>

	<cfif HouseDetail.cstatecode is 'WI'>
		<tr id="typMedicaid4" style="display:none" >
			<td>Enter WI State Rate (R&B+LOC)</td>
			<td colspan="6">
				<input type="text" name="mStateMedAidAmtRB"  id="mStateMedAidAmtRB" value="" size="2"/>
				<cfoutput>+</cfoutput>
			    <input type="text" name="mStateMedAidAmtcare"  id="mStateMedAidAmtcare" value="" size="2"/>
			    <cfoutput>=</cfoutput>
			    <input type="text" name="mStateMedAidAmtBSFD"  id="mStateMedAidAmtBSFD" value="" size="2" onfocus="addBSFandCare()" readonly/>
			</td>
		</tr>		
			
			<!---commented for RB and loc for WI medicaid <td><input type="text" name="mStateMedAidAmtBSFD"  id="mStateMedAidAmtBSFD" 
					value="#numberformat(HouseDetail.mStateMedicaidAmt_BSF_Daily, 9999.99)#"/></td>
		</tr>comment end--->
		<tr id="typMedicaid5" style="display:none" >  
		
			<!---<td>Enter the Authorized amount of Medicaid CoPay ($)</td>
			<td><input type="hidden" name="mMedicaidCopay"  id="mMedicaidCopay" value="0.00"/></td>--->
		</tr>
	<cfelse>	
		<tr id="typMedicaid4" style="display:none" >
		<cfif HouseDetail.cstatecode is 'IA'>	
			<td> HSP</td>
		<cfelse>
		<td> NJ HSP</td>
			</cfif>
		<td><input type="text" name="cNJHSP"  id="cNJHSP" value=""/></td>
	   </tr>	
		<tr id="typMedicaid5" style="display:none" >
			<cfif HouseDetail.cstatecode is 'IA'>			
			   <td>Enter the Authorized amount of Medicaid Basic service Fee ($)</td>
			<cfelse> 
			   <td>Enter the Authorized amount of Medicaid CoPay ($)</td>
			</cfif> 
			<td><input type="text" name="mMedicaidCopay"  id="mMedicaidCopay" value=""/></td>
		</tr>
	</cfif>	
	<tr id="typMedicaid6" style="display:none" >
		<td>Enter PICD</td>
		<td><input type="text" name="iPICD"  id="iPICD" value="#iPICD#"/></td>
	</tr>	
	<tr id="typMedicaid7" style="display:none" >
		<td>Enter SICD</td>
		<td><input type="text" name="iSICD"  id="iSICD" value="#iSICD#"/></td>
	</tr >
	<tr id="typMedicaid8" style="display:none" >
		<td>Enter TICD</td>
		<td><input type="text" name="iTICD"  id="iTICD" value="#iTICD#"/></td>
	</tr>	
 	
</table>
<table>
	
 
	<cfif HouseLog.bIsPDClosed GT 0> <cfset Toggle=1> <cfelse> <cfset Toggle=0> </cfif>		
	<input type="Hidden" name="bNextMonthsRent" value="#Toggle#">
	<tr>
		<td colspan="4"></td>
	</tr>
	<tr>
		<td colspan="4" style="font-weight:bold;  text-decoration:underline"> 
		Contact Information 
		</td>
	</tr>
	<tr style="font-weight: bold; background-color:##FFFFCC">
		<td>First Name </td>
		<td> 
			<input type="text" name="cFirstName" value="#ContactInfo.cFirstName#" 
			onBlur="this.value=ltrs(this.value); upperCase(this);">
		</td>	
		<td>&nbsp;</td>
<!---         <td id="contactpripayor" style="text-align:center;  display:block;">    
            &nbsp;Is this Contact the Primary Payor?<br />	
			<cfset bit= iif(ContactInfo.bIsPrimaryPayer IS 1, DE('Checked'), DE('Unchecked'))>
			<input type="CheckBox" name="ContactbIsPrimaryPayer" Value="1" #Variables.bit# onClick="primarypayor(this);">	
		</td>	 ---> 
        <!--- <td id="contactpripayor" style="text-align:center;  display:block;"> --->    
		 <td colspan="2">
           Is this Contact the Payor? 	
			<cfset bit= iif(ContactInfo.bIsContactPayor IS 1, DE('Checked'), DE('Unchecked'))>
			<input type="CheckBox" name="ContactbIsPayor"  id="ContactbIsPayor" 
			Value="1" #Variables.bit#  onClick="primarypayor(this)">	
		</td>			
	</tr>
	<tr style= "Font-weight: bold;">
		<td>Last Name </td>
		<td > 
			<input type="text" name="cLastName" id="cLastName" 
			value="#ContactInfo.cLastName#" onBlur="this.value=ltrs(this.value); upperCase(this);">
         </td>
        <td   colspan="2">
			<span>
				&nbsp;Does this Contact have<br />Financial Power Of Attorney?
				<cfset bit= iif(ContactInfo.bIsPowerOfAttorney IS 1, DE('Checked'), DE('Unchecked'))>
				<input type= "CheckBox" name= "bIsPowerOfAttorney" Value = "1" #Variables.bit#>	
			</span>
		</td>
	</tr>
	
	<tr style="Font-weight: bold; background-color:##FFFFCC">
		<td>Relationship</td>
		<td>
			<select name="iRelationshipType_ID">
			<cfloop query="relationships"> 
				<cfscript>
					if (IsDefined("ContactInfo.iRelationshipType_ID") and
					ContactInfo.iRelationshipType_ID eq RelationShips.iRelationshipType_ID)
					{selected='selected';}
					else{selected='';}
				</cfscript>
				<option value="#RelationShips.iRelationshipType_ID#" #selected#>
				 #RelationShips.cDescription# 
				 </option> 
			</cfloop>
			</select>
        </td>
        <td  colspan="2">
			Does this Contact have<br /> the Power of Attorney for Health Care?
			<cfif ContactInfo.bIsMedicalProvider IS 1> <cfset bit="Checked"> 
			<cfelse> 
			<cfset bit="UnChecked"> </cfif>			
			<input type="CheckBox" name="bIsMedicalProvider" Value="1" #Variables.bit#>
		</td>
	</tr>

<!--- 	<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>  
	  <tr>
	    <td id="contactpayor"   colspan="2"style="Font-weight: bold;" >  
			<span>		  
            &nbsp;Is this Contact a Payor? 	
			<cfset bit= iif(ContactInfo.bIsPayer IS 1, DE('Checked'), DE('Unchecked'))>
			<input type="CheckBox" name="ContactbIsPayer" Value="1" #Variables.bit# >	
			</span>			
		</td>
	  </tr>
	  <tr>
	 	<td colspan="4" style="Font-weight: bold;">Has this Contact signed the Guarantor Agreement?
	 	<select name="oGuarentorAgreement">
		 	<cfscript>
				if (ContactInfo.bIsGuarantorAgreement eq ''){ Note = 'Action Needed';} 
				else if (ContactInfo.bIsGuarantorAgreement EQ '0'){ Note = 'No Guarantor Agreement Approved';} 
				else if (ContactInfo.bIsGuarantorAgreement EQ '1'){ Note = 'Received';} 
			</cfscript>
	 		<option value="#ContactInfo.bIsGuarantorAgreement#">#Note#</option>
	 		<option value="null">Action Needed</option>
	 		<option value="0">No Guarantor Agreement Approved</option>
	 		<option value="1">Received</option>
	 	</select>
	 </tr> 
 	</cfif> --->
	<tr>
		<td colspan="4" style="Font-weight: bold;">Is this Contact the Executor? 
			<cfset bit= iif(ContactInfo.bIsExecutorContact IS 1, DE('Checked'), DE('Unchecked'))>
			<input type= "CheckBox" name= "bIsExecutorContact" Value = "1" #Variables.bit#>	
		</td>
	</tr>
	  
	 <tr style="background-color:##FFFFCC">
	  <td colspan="4" style="Font-weight: bold;">Is this Contact the Primary Care Physician?
		
			<cfset bit= iif(ContactInfo.cPrimaryCarePhysicianContact IS 1, DE('Checked'), DE('Unchecked'))>
			<input type= "CheckBox" name= "cPrimaryCarePhysicianContact" Value = "1" #Variables.bit#>
		</td>
	</tr>
	 
	<tr>
		<td width="104" style="font-weight: bold;">Address Line 1</td>
		<td colspan="4"><input type="text" Name="cAddressLine1" 
		value="#ContactInfo.cAddressLine1#" size="40" maxlength="40"
        				onblur="upperCase(this); validatePayor();">
        </td>
	</tr>
	<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;">Address Line 2</td>
		<td colspan="4"> <input type="text" Name="cAddressLine2" 
		value="#ContactInfo.cAddressLine2#" size="40" maxlength="40"
        				 onblur="upperCase(this);">
        </td>
	</tr>
	<tr>
		<td style="font-weight: bold;">City</td>
		<td colspan="5">
			<input type="text" Name="cCity" value="#ContactInfo.cCity#" size="24" maxlength="30" 
            onkeypress="return allowOnlyLettersOnKey(event);" onblur="upperCase(this);">
		</td>
	</tr>
	<tr>
		<td style="font-weight: bold;">State</td>
		<td colspan="5">
		
			<select name="cStateCode">
				<option value=""> Select </option>
				<cfloop query="StateCodes">
					<cfscript>
					if (isDefined("ContactInfo.cStateCode") and ContactInfo.cStateCode eq cStateCode) { selected='selected';} 
					else {selected='';}
					</cfscript>				
					<option value="#cStateCode#" #selected#> #cStateName# - #cStateCode# </option>
				</cfloop>
			</select>
		</td>
	</tr>	
	<tr>
		<td style="font-weight: bold;" colspan="5">	
			 Zip (Postal) Code
			<input type="text" Name="cZipCode" value="#ContactInfo.cZipCode#" 
             onblur="return maskZIP(this, event)"  size="10" maxlength="10">
        </td>
	</tr>
	<tr style="background-color:##FFFFCC">
		<td style="Font-weight: bold;">	Home Phone	</td>
		<td colspan="3">
			<cfscript>
				areacode1 = left(ContactInfo.cPhoneNumber1,3); 
				prefix1 = Mid(ContactInfo.cPhoneNumber1,4,3); number1 = right(ContactInfo.cPhoneNumber1,4);
			</cfscript>
			<input type="text" name="areacode1"	size="3"  id="areacode1" 
			value="#Variables.areacode1#" maxlength="3" 
				onKeyUp="this.value=LeadingZeroNumbers(this.value);" onblur="Three(this);"> -
			<input type="text" name="prefix1"   size="3"  id="prefix1"  
			 value="#Variables.prefix1#"   maxlength="3" 
				onKeyUp="this.value=LeadingZeroNumbers(this.value);" onblur="Three(this);"> -
			<input type="text" name="number1"   size="4"  id="number1"  
			 value="#Variables.number1#"   maxlength="4" 
				onKeyUp="this.value=LeadingZeroNumbers(this.value);" onblur="Four(this);">
			<input type="hidden" name="iPhoneType1_ID" value="1">
		</td> 
	</tr>
	<tr>
		<td style="font-weight: bold;">Message Phone</td>
		<td colspan="3">
			<cfscript>
				areacode2 = left(ContactInfo.cPhoneNumber2,3); 
				prefix2 = mid(ContactInfo.cPhoneNumber2,4,3); 
				number2 = right(ContactInfo.cPhoneNumber2,4);
			</cfscript>
			<input type="text" name="areacode2"	size="3" id="areacode2"
			 value="#Variables.areacode2#" maxlength="3" 
				onKeyUp="this.value=LeadingZeroNumbers(this.value);" onblur="Three(this);"> -
			<input type="text" name="prefix2"   size="3" id="prefix2"  
			 value="#Variables.prefix2#"   maxlength="3" 
				onKeyUp="this.value=LeadingZeroNumbers(this.value);"  onblur="Three(this);"> -
			<input type="text" name="number2"   size="4" id="number2"   
			value="#Variables.number2#"   maxlength="4" 
				onKeyUp="this.value=LeadingZeroNumbers(this.value);"  onblur="Four(this);">
			<input type="hidden" name="iPhoneType2_ID"	value="5">
		</td>
	</tr>
	<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;">Email</td>
		<td colspan="3">
			<input type="text" Name="cEmail" value="#ContactInfo.cEmail#" size="40" maxlength="70">
		</td>
	</tr>
	<tr>
		<td style="font-weight: bold;">Comments:</td>
		<td colspan="3"> 
		<textarea cols="50" rows="3" name="cComments">#trim(TenantInfo.TenantComments)#</textarea> 
		</td>
	</tr>
	<tr style="background-color:##FFFFCC">	
		<td style="text-align: left;">
			<input class="SaveButton" type="submit" name="Save" value="Save"   
  			onmouseover="return hardhaltvalidation(MoveInForm); " 
			onclick ="return secondoccupant(); return hardhaltvalidation(MoveInForm);return requiredBeforeYouLeave()  ">  
		</td>
		<td colspan="2">&nbsp;</td>
		<td width="478" style= "text-align: right;">
			<input class="DontSaveButton" type="button" name="DontSave" 
			value="Don't Save" onClick="redirect()">
		</td>
	</tr>
	<tr>
		<td colspan="4" style="font-weight: bold; color: red;">	
			<U>NOTE:</U> You must SAVE to keep information which you have entered!<br /> 
		</td>
	</tr>
	</table>
</td> </tr> 
</table>
</form>
</cfoutput>

 
<cfinclude template="../../Footer.cfm">