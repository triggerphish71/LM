<!--- DO NOT MOVE TO PRODUCTION UNTIL THE the "move out date" CHECK IS CHANGED BACK TO ORIGINAL FORM --->

<!----------------------------------------------------------------------------------------------
| DESCRIPTION - MoveOut/MoveOutFormSummary.cfm                                                 |
|----------------------------------------------------------------------------------------------|
| Display database summary for saved move out information                                      |
| Called by: 		MainMenu.cfm, MoveOutUpdate.cfm, PDFinalize.cfm							   |
| Calls/Submits:	MoveOutReport.cfm, CloseAccount.cfm, MoveOutCSVGeneration.cfm,             |
|					ResetTenant.cfm                                                            |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|MLAW        | 07/26/2006 | Create an initial Finalize MoveOut page                  	       |
|Paul Buendia| 02/07/2002 | Original Authorship/ Header Created								   |
|			 |			  |	1) added filter to CurrentCharges								   |
|			 |			  |		AND	NOT (CT.bIsMedicaid IS NOT NULL                            | 
|			 |			  |		AND bIsRent IS NULL)										   |
|			 |			  |		to filter state medicaid charges from query/display			   |
|			 |			  |	2) CurrentCharges query changed to use SP_MoveOutInvoice  		   |
|			 |			  |	3)	Added to treat all people as second tenant occupant if there is| 
|			 |			  |	    another person in the room									   |
|			 |	03/14/2002|		Changed Second tenant moved out status (point in time)		   |
|			 |			  |		to only check for status if the existence of variable	       |
|			 |			  |		exists. ie. if the query is not null and record count          |
|			 |			  |		is not 0 then use the conditional.						       |
|Steve D	 |	04/22/2002|		Added check for companion suite when determining 			   |
|			 |			  |		occupancy													   |
|MLAW		 | 08/04/2006 | Set up a ShowBtn paramater which will determine when to show the   |
|		     |            | menu button.  Add url parament ShowBtn=#ShowBtn# to all the links  |
|MLAW        | 08/17/2006 | Make sure the charges are assigned to correct Product Line ID      |
|MLAW        | 09/25/2006 | Remove Databsource = "QUERY", this is not necessary for new version|
|RSchuette   | 03/25/2010 | 51267 - MO Codes - added code for this                             |
|Sathya      | 04/27/2010 | 20933- Late Fee project changes to populate the late fee           |
|Sathya      | 07/01/2010 | 50227- Tips Promotion Update. Display a checkbox so that the Ar    |
|            |            | can update to acknowledge that they know the tenant has a promotion|
|            |            | Unless the Ar acknowledge to this checkbox the Close account will  |
|            |            | not show up.                                                       |
|Sathya      | 07/20/2010 | 20933-PartB Late fee project rename the delete button to waive     |
|Sathya      | 08/11/2010 | 20933 Part-C Late Fee project Pursue Button.                       |
 sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                           |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
|sfarmer     | 12/10/2013 | 112478 - adjustments to Billing Information                        |
|S Farmer    | 2015-01-12 | 116824   Final Move-in Enhancements                                |
|S Farmer    | 2015-07-17 | Medicaid enhancements 
| Mshah         2015-05-05 | Medicaid state charge avoid to print                              |
|sfarmer     | 2017-05-09 | 'move out date' changed to 'physical move out date'                |
|MShah		  |2017-11-27| 'MoveOutSummary' Change												|
 ----------------------------------------------------------------------------------------------->

<!--- 51267 - 3/31/2010 - RTS - MO Codes --->
<script language="javascript">
	function checkMO(){
		for(j=0;j<MoveOutFormSummary.TMORLreview.length;j++)
		{
			if(MoveOutFormSummary.TMORLreview[j].checked){
				return true;
			}else{
				alert("Have you reviewed the Move Out Reasons and Location?");
				window.scrollTo(1,1);
				return false;
			}
		}
	}
	
</script>
<!--- End 51267 --->

<!--- 08/04/2006 MLAW show menu button --->
<CFPARAM name="ShowBtn" default="True">
<cfset NRFrembal = 0>

<!--- ==============================================================================
Set variable for timestamp to record corresponding times for transactions
=============================================================================== --->
<CFQUERY NAME="GetDate" DATASOURCE="#APPLICATION.datasource#">
	SELECT	GetDate() as Stamp
</CFQUERY>
<CFSET TimeStamp = CREATEODBCDateTime(GetDate.Stamp)>

<!--- ==============================================================================
Set Variable for Current Period format "yyyymm" (solomon format)
=============================================================================== --->
<CFSET PerPost = Year(SESSION.TIPSMonth) & DateFormat(SESSION.TIPSMonth,"mm")>
<CFSET PriorMonth = DateAdd("m",-1,SESSION.TIPSMonth)>
<CFSET PastDueMonth = DateFormat(PriorMonth,"yyyymm")>

<!--- ==============================================================================
Retreive the Tenants Information
T.cFirstName, T.cLastName, T.cSolomonKey, T.dBirthDate, T.iTenant_ID, T.cSLevelTypeSet
=============================================================================== --->
<!--- 51267 3/25/2010 RTS - added code to reason 2,TL tbl link --->
<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT	T.*
			,TS.iTenantState_ID
			,TS.dtMoveIn
			,ts.dtRentEffective
			,TS.iSPoints
			,TS.dtChargeThrough
			,TS.dtMoveOut
			,TS.dtNoticeDate
			,TS.iTenantStateCode_ID
			,TS.iResidencyType_ID
			,AD.cAptNumber
			,AD.iAptAddress_ID
			,AT.cDescription as AptType
			, AT.iAptType_ID
			,RT.cDescription as Residency
			,MT.cDescription as Reason
			,MT.bIsVoluntary
			,MT2.cDescription as Reason2
			,MT2.bIsVoluntary as bIsVoluntary2
			,TS.iProductLine_ID
			,TS.iTenantMOLocation_ID
			,TL.cDescription as 'TMOLDescription'
			<!--- 07/01/2010 Project 50227 Sathya added this for promotions --->
			,TS.cTenantPromotion as Promotions
			,TS.bIsArAcknowledgePromotion
			<!--- End of code Project 50227 --->
	FROM	Tenant T with (NOLOCK)
	LEFT JOIN TenantState TS with (NOLOCK)	ON T.iTenant_ID = TS.iTenant_ID
	LEFT JOIN AptAddress AD	with (NOLOCK)	ON AD.iAptAddress_ID = TS.iAptAddress_ID	
	LEFT JOIN AptType AT with (NOLOCK)		ON AT.iAptType_ID = AD.iAptType_ID
	LEFT JOIN ResidencyType RT with (NOLOCK)ON TS.iResidencyType_ID = RT.iResidencyType_ID
	LEFT JOIN MoveReasonType MT	with (NOLOCK) ON TS.iMoveReasonType_ID = MT.iMoveReasonType_ID
	LEFT JOIN MoveReasonType MT2 with (NOLOCK) ON TS.iMoveReason2Type_ID = MT2.iMoveReasonType_ID
	LEFT JOIN TenantMOLocation TL with (NOLOCK) ON TS.iTenantMOLocation_ID = TL.iTenantMOLocation_ID
	WHERE	T.iTenant_ID = #url.ID# and TS.dtRowDeleted IS NULL
</CFQUERY>
<!--- end 51267 --->
<CFIF Tenant.iResidencyType_ID EQ 2> 
	<!--- Retrieve the Respite Daily Rate (THERE ARE NO MONTHY RATES FOR RESPITE - Corporate Rule) --->
	<CFQUERY NAME="qMedicaidRate" DATASOURCE="#APPLICATION.datasource#">
	SELECT	TS.mMedicaidCopay ResidentCoPay
	  ,HM.mStateMedicaidAmt_BSF_Daily
      ,HM.mStateMedicaidAmt_BSF_Monthly
      ,HM.mMedicaidBSF
      ,HM.mMedicaidCopay HouseCoPay
      ,HM.cStateAcuity
      ,HM.cMedicaidLevelLow
      ,HM.cMedicaidLevelMedium
      ,HM.cMedicaidLevelHigh
	FROM Tenant	T with (NOLOCK)
	JOIN TenantState TS with (NOLOCK) ON T.iTenant_ID = TS.iTenant_ID		
	JOIN House h with (NOLOCK) on t.ihouse_id = h.ihouse_id
	join HouseMedicaid HM with (NOLOCK) on t.ihouse_id = HM.ihouse_id
	WHERE   T.iTenant_ID = #url.ID#
	</CFQUERY>	
</CFIF> 
<!--- 04/27/2010 Sathya Project 20933 late fee --->
<!--- project 20933 sathya Retreive all the late fee that are pending --->
	<cfquery name="getTenantLateFeeRecords" DATASOURCE = "#APPLICATION.datasource#">
				SELECT * 
				FROM TenantLateFee ltf with (NOLOCK)
				join Tenant t with (NOLOCK)
				on t.iTenant_id = ltf.iTenant_id
				WHERE t.iTenant_id =#url.ID#
				AND ltf.dtrowdeleted is null
				AND t.dtrowdeleted is null
				AND (ltf.bPaid is null or ltf.bPaid = 0)
				AND (ltf.bAdjustmentDelete is Null or ltf.bAdjustmentDelete = 0)
				<!--- 08/12/2010 Project 20933 Part-C sathya Added the prusue field check --->
				AND (ltf.bPursueLateFee is null or ltf.bPursueLateFee = 0)
				<!--- End of code Project 20933 Part-C --->
	</cfquery>
<!--- project 20933 sathya Retreive partialpayment --->
	<cfquery name="getPartialPayment" datasource="#APPLICATION.datasource#">
		select   tla.iInvoiceLateFee_ID , sum(mLateFeePartialPayment) as LateFeePayment
		from TenantLateFeeAdjustmentDetail tla with (NOLOCK)
		join invoicedetail ind with (NOLOCK)
		on tla.iinvoicedetail_id = ind.iinvoicedetail_id
		where tla.iInvoiceLateFee_ID in ( SELECT ltf.iInvoiceLateFee_ID 
										FROM TenantLateFee ltf with (NOLOCK)
										join Tenant t with (NOLOCK)
										on t.iTenant_id = ltf.iTenant_id
										WHERE t.iTenant_id =#url.ID#
										AND ltf.dtrowdeleted is null
										AND t.dtrowdeleted is null
										AND (ltf.bPaid is null or ltf.bPaid = 0)
										<!--- 08/12/2010 Project 20933 Part-C sathya Added the prusue field check --->
										AND (ltf.bPursueLateFee is null or ltf.bPursueLateFee = 0)
										<!--- End of code Project 20933 Part-C --->
										AND (ltf.bAdjustmentDelete is Null or ltf.bAdjustmentDelete = 0))
		and tla.dtrowdeleted is null
		and ind.dtrowdeleted is null
		Group by  iInvoiceLateFee_ID
	</cfquery>
	

<!---  end of code Project 20933  --->


<!--- ==============================================================================
If this tenant is in a moved out state retrieve the day 
that they first went to a "Moved Out" Status
=============================================================================== --->
<CFIF Tenant.iTenantStateCode_ID EQ 3>

<!---	<CFQUERY NAME="qStateChanged" DATASOURCE="#APPLICATION.datasource#">
		SELECT	distinct top 1 stateDtRowStart, iTenantStateCode_ID
		FROM	rw.vw_Tenant_History_with_State with (NOLOCK)
		WHERE	iTenant_ID = #Tenant.iTenant_ID#
		AND		iTenantStateCode_ID = 3
		ORDER BY stateDtRowStart Desc
	</CFQUERY>--->
		
	<CFQUERY NAME="qMIState" DATASOURCE="#APPLICATION.datasource#">
		SELECT	distinct top 1 stateDtRowStart, iTenantStateCode_ID
		FROM	rw.vw_Tenant_History_with_State with (NOLOCK)
		WHERE	iTenant_ID = #Tenant.iTenant_ID#
		AND	iTenantStateCode_ID = 2
		ORDER BY stateDtRowStart Desc
	</CFQUERY>			
</CFIF>

<!--- ==============================================================================
Retrieve Move Out Invoice Information
=============================================================================== --->
<CFQUERY NAME="MoveOutInfo" DATASOURCE = "#APPLICATION.datasource#">
	select distinct IM.iInvoiceMaster_ID
	, IM.cComments as InvoiceComments
	, case when IM.dtInvoiceEnd is null then NULL else dateadd(second, 1, IM.dtInvoiceEnd) end dtInvoiceEnd
	, IM.dtInvoiceStart
	,IM.iInvoiceNumber
	, mLastInvoiceTotal as PastDue
	, IM.cAppliesToAcctPeriod
	from InvoiceMaster IM with (NOLOCK)
	join InvoiceDetail INV	with (NOLOCK)ON (INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND INV.dtRowDeleted IS NULL)
	where IM.cSolomonKey = '#Tenant.cSolomonKey#' and INV.iTenant_ID = #Tenant.iTenant_ID#
	and bMoveOutInvoice IS NOT NULL and IM.bFinalized is null and IM.dtRowDeleted IS NULL
	<CFIF IsDefined("url.MID")>
	AND		IM.iInvoiceMaster_ID = #url.MID#
	</CFIF>
		order by im.cappliestoacctperiod desc <!---, im.dtinvoiceend desc  --->
</CFQUERY>

<!---  Used to make sure the pursut of a late fee doens't effect total balance due ---->
<CFQUERY NAME="LateFeeAllowance" DATASOURCE = "#APPLICATION.datasource#">
	select sum(ABS(mAmount)) as Total from invoicedetail with (NOLOCK)
	where cdescription = 'Allowance for Late Fee Recovery'
	and itenant_id = #Tenant.iTenant_ID#
	and dtrowdeleted is null
</CFQUERY>

<CFIF MoveOutInfo.dtInvoiceStart EQ "">
	<!--- ==============================================================================
	If not record from MoveOutInfo query look to see if there is an invoice number 
	without transactions
	=============================================================================== --->
	<CFQUERY NAME="MoveOutInfo" DATASOURCE="#APPLICATION.datasource#">
		SELECT	distinct IM.cComments as InvoiceComments, IM.iInvoiceMaster_ID, IM.dtInvoiceEnd, IM.dtInvoiceStart,
				IM.iInvoiceNumber, mLastInvoiceTotal as PastDue, IM.cAppliesToAcctPeriod
		FROM	InvoiceMaster IM with (NOLOCK)
		LEFT OUTER JOIN	InvoiceDetail INV with (NOLOCK)	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
		where IM.cSolomonKey = '#Tenant.cSolomonKey#'
		and INV.iTenant_ID = #Tenant.iTenant_ID# and bMoveOutInvoice IS NOT NULL and IM.dtRowDeleted IS NULL
		order by im.cappliestoacctperiod desc   <!---, im.dtinvoiceend desc --->
	</CFQUERY>
</CFIF>

<!--- ==============================================================================
Retrieve if Security Deposit has been paid
=============================================================================== --->
<!---<CFQUERY NAME="Refundable" DATASOURCE="#APPLICATION.datasource#">
	<CFIF SESSION.qSelectedHouse.iHouse_ID EQ 200>
		SELECT	sum(mAmount * iQuantity) as TotalDeposits
		FROM	InvoiceDetail INV with (NOLOCK)
		JOIN	ChargeType CT with (NOLOCK)ON (CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL)
		WHERE	INV.dtRowDeleted IS NULL
		AND		CT.bIsDeposit IS NOT NULL
		AND		CT.bIsRefundable IS NOT NULL
		AND		iTenant_ID = #Tenant.iTenant_ID#
	<CFELSE>
		SELECT	distinct sum(INV.mAmount) as mAmount
		FROM	DepositLOG DL
		JOIN	DepositType DT	with (NOLOCK)ON DL.iDepositType_ID = DT.iDepositType_ID
		JOIN	InvoiceDetail INV with (NOLOCK)	ON INV.cDescription = DT.cDescription
		JOIN	InvoiceMaster IM with (NOLOCK)ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
		WHERE	INV.iTenant_ID = #url.ID#
		AND		DT.bIsFee IS NULL
		AND		INV.dtRowDeleted IS NULL
		AND		IM.bMoveInInvoice IS NOT NULL
	</CFIF>
</CFQUERY>--->

<!--- ==============================================================================
Retreive the Solomon Past Balance for this tenant
=============================================================================== --->
<CFIF SESSION.qSelectedHouse.iHouse_ID NEQ 200>
	<CFSET PerPost = Year(SESSION.AcctStamp) & DateFormat(SESSION.AcctStamp,"mm")>
	<CFSET PaymentPer = Year(Tenant.dtChargeThrough) & DateFormat(Tenant.dtChargeThrough,"mm")>
	<CFQUERY NAME="CheckforPayment" DATASOURCE="SOLOMON-HOUSES">
		SELECT origdocamt FROM ARDOC (NOLOCK) WHERE Custid = '#Tenant.cSolomonKey#' AND DocType = 'PA' AND PerPost = '#PaymentPer#'
	</CFQUERY>
	
</CFIF>

<!--- ==============================================================================
Retrieve the last invoice end date for the following solomon query
=============================================================================== --->
<CFSET IntPeriod = Year(Tenant.dtChargeThrough) & DateFormat(Tenant.dtChargeThrough,"mm")>

<!--- ==============================================================================
Find the End date of the LAST FINALIZED INVOICE
=============================================================================== --->
<!---<CFQUERY NAME="StartRange" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	MAX(dtInvoiceEnd) as dtInvoiceEnd
	FROM	InvoiceMaster IM
		JOIN	InvoiceDetail INV	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
	WHERE	IM.dtRowDeleted IS NULL
	AND		INV.dtRowDeleted IS NULL 
	AND 	( bMoveInInvoice IS NULL AND bMoveOutInvoice IS NULL AND bFinalized IS NOT NULL )
	AND		INV.iTenant_ID = #Url.ID#
	<CFIF MoveOutInfo.RecordCount GT 0> 
		<CFSET tempdate = DateAdd("m",-1,CreateODBCDateTime(LEFT(MoveOutInfo.cAppliesToAcctPeriod,4) & '-' & RIGHT(MoveOutInfo.cAppliesToAcctPeriod,2) & '-01'))>
		<CFSET THIScAppliesToAcctPeriod = #DateFormat(tempdate,"yyyymm")#>
		AND IM.cAppliesToAcctPeriod = #THIScAppliesToAcctPeriod#
	</CFIF>
</CFQUERY>

<CFSCRIPT>if (StartRange.RecordCount GT 0) { StartRange = StartRange.dtInvoiceEnd; } else { StartRange = '2001-01-01'; }</CFSCRIPT>--->

<!--- ==============================================================================
Retrieve the ServiceLevel
=============================================================================== --->
<CFQUERY NAME="GetSLevel" DATASOURCE="#APPLICATION.datasource#">
	SELECT 	iSLevelType_ID 
	FROM 	SLevelType with (NOLOCK)
	WHERE	dtRowDeleted IS NULL
	AND		(iSPointsMin <= #Tenant.iSPoints#	AND	iSPointsMax >= #Tenant.iSPoints#)
	<CFIF IsDefined("Tenant.cSLevelTypeSet") AND (Tenant.cSLevelTypeSet NEQ "" OR Tenant.cSLevelTypeSet EQ 0)>
		AND	cSLevelTypeSet = #Tenant.cSLevelTypeSet#
	<CFELSE>
		AND	cSLevelTypeSet 	= #SESSION.cSLevelTypeSet#
	</CFIF>
</CFQUERY>

<!--- ==============================================================================
Stored Proc. to find the date the tenant dropped to state 3
=============================================================================== --->
<CFQUERY NAME="FindDtStateChange" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	isnull(min(stateDtRowStart), getdate()) dtStateChange
	FROM	rw.vw_Tenant_History_with_State with (NOLOCK)
	WHERE	iAptAddress_ID = #Tenant.iAptAddress_ID#
	AND		iTenantStateCode_ID = 3 AND tendtRowDeleted IS NULL AND statedtRowDeleted IS NULL
	AND		cSolomonKey = '#Tenant.cSolomonKey#'
	AND		iTenant_ID = #Tenant.iTenant_ID#
</CFQUERY>

<!--- ==============================================================================
Stored Proc. to find if there is another tenant in the room
=============================================================================== --->
<CFSTOREDPROC PROCEDURE="rw.sp_GetOccupancy" datasource="#APPLICATION.datasource#" debug="Yes">
	<CFPROCRESULT NAME="FindOccupancy">
	<CFIF IsDefined("FindDtStateChange.dtStateChange") AND FindDtStateChange.dtStateChange LTE NOW()>
		<CFSET dtSPCompare = CreateODBCDateTime(FindDtStateChange.dtStateChange)>
	<CFELSE>
		<CFSET dtSPCompare = Now()>
	</CFIF>
	<CFPROCPARAM TYPE="IN" VALUE="#Tenant.iTenant_ID#" DBVARNAME="@iTenant_ID" cfsqltype="CF_SQL_INTEGER">
	<CFPROCPARAM TYPE="IN" VALUE="#dtSPCompare#" DBVARNAME="@dtCompare" cfsqltype="CF_SQL_TIMESTAMP">
	<CFPROCPARAM TYPE="IN" VALUE="1" DBVARNAME="@bVerboseResults" cfsqltype="CF_SQL_BIT">
</CFSTOREDPROC>


<!--- ==============================================================================
Get Acuity Level of other Tenant (if exists)
=============================================================================== --->
<CFIF FindOccupancy.RecordCount GT 0>
	<CFQUERY NAME="qOtherTenant" DATASOURCE="#APPLICATION.datasource#">
		SELECT 	*, SLT.cDescription as Level
		FROM 	Tenant T with (NOLOCK)
		JOIN	SLevelType SLT with (NOLOCK)ON	SLT.cSLevelTypeSet = T.cSLevelTypeSet
		JOIN	TenantState TS	with (NOLOCK)ON	(TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted IS NULL)
		WHERE	T.dtRowDeleted IS NULL
		AND		SLT.dtRowDeleted IS NULL
		AND		T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		AND	cSolomonKey = '#Tenant.cSolomonKey#'
		AND	iSPointsMin <= #FindOccupancy.iSPoints#
		AND	iSPointsMax >= #FindOccupancy.iSPoints#
		AND	T.iTenant_ID <> #Tenant.iTenant_ID#
		order by isNull(ts.dtmoveout,getdate()) desc
	</CFQUERY>
	
	<CFQUERY NAME='qOtherActive' DBTYPE='QUERY'>
		select * from qOtherTenant where itenantstatecode_id = 2
	</CFQUERY>
	
	<CFIF qOtherTenant.iTenantStateCode_ID EQ 3 AND Tenant.iTenantStateCode_ID EQ 3>
		<CFQUERY NAME="qOtherMOState" DATASOURCE="#APPLICATION.datasource#">
			SELECT	distinct top 1 stateDtRowStart, iTenantStateCode_ID
			FROM	rw.vw_Tenant_History_with_State with (NOLOCK)
			WHERE	iTenant_ID = #qOtherTenant.iTenant_ID#
			AND	iTenantStateCode_ID = 3
			ORDER BY stateDtRowStart Desc
		</CFQUERY>
		
		<CFQUERY NAME="qOtherMIState" DATASOURCE="#APPLICATION.datasource#">
			SELECT	distinct top 1 stateDtRowStart, iTenantStateCode_ID
			FROM	rw.vw_Tenant_History_with_State with (NOLOCK)
			WHERE	iTenant_ID = #qOtherTenant.iTenant_ID#
			AND	iTenantStateCode_ID = 2
			ORDER BY stateDtRowStart Desc
		</CFQUERY>
	</CFIF>
</CFIF>

<CFOUTPUT>
	<CFIF IsDefined("MoveOutInfo.PastDue") AND MoveOutInfo.Pastdue NEQ "" AND FindOccupancy.RecordCount LTE 1>
		<CFSET PastDue = MoveOutInfo.PastDue>
	<CFELSE>
		<CFSET PastDue = 0.00>
	</CFIF>
</CFOUTPUT> 

<CFIF FindOccupancy.RecordCount GT 0>
	<CFIF qOtherActive.recordcount gt 0 OR (Tenant.iTenantStateCode_ID EQ 2 AND (IsDefined("qOtherMIState.stateDTRowStart") AND qOtherMIState.stateDTRowStart GT qMIState.stateDTRowStart))
	OR (Tenant.iTenantStateCode_ID EQ 3 AND IsDefined("qOtherMOState.stateDTRowStart") AND qOtherMOState.stateDTRowStart GT FindDtStateChange.dtStateChange
		OR qOtherTenant.iTenantStateCode_ID NEQ 3)>
		<CFSET Occupancy = 2>
	<CFELSE>
		<CFSET Occupancy = 1>
	</CFIF>
<CFELSE>
	<CFSET Occupancy = 1>
</CFIF>

<CFQUERY NAME="CheckCompanionFlag" DATASOURCE="#APPLICATION.datasource#">
	SELECT	bIsCompanionSuite
	FROM	AptAddress AD with (NOLOCK)
	JOIN	AptType AT ON (AD.iAptType_ID = AT.iAptType_ID AND AT.dtRowDeleted is NULL)
	WHERE	AD.dtRowDeleted IS NULL
	AND		AD.iAptAddress_ID = #Tenant.iAptAddress_ID#
</CFQUERY>

<CFIF CheckCompanionFlag.bIsCompanionSuite EQ 1>
	<CFSET Occupancy = 1>
</CFIF>
<!--- MLAW 08/17/2006 Add iProductline_ID filter --->
<CFQUERY NAME="StandardRent" DATASOURCE="#APPLICATION.datasource#">
	<CFIF Tenant.iResidencyType_ID NEQ 3>
		EXEC rw.sp_MoveOutMonthlyRate @iTenant_ID=#Tenant.iTenant_ID#, @HouseNumber=#session.nhouse#,@dtComparison=<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(Tenant.dtMoveOut)#<CFELSE>#Now()#</CFIF> 
	<CFELSE>
		SELECT  *, mAmount as mRoomAmount, 0 as mCareAmount
		FROM	Charges with (NOLOCK)
		WHERE	iHouse_ID = #Tenant.iHouse_ID#
		AND		iResidencyType_ID = #Tenant.iResidencyType_ID#
		AND 	iOccupancyPosition = #Occupancy#
		<CFIF Tenant.iResidencyType_ID NEQ 3>AND iAptType_ID = #Tenant.iAptType_ID#</CFIF>
		AND		dtEffectiveStart <= 
			<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>	
				#CreateODBCDateTime(Tenant.dtMoveOut)#
			<CFELSE>
				#Now()#
			</CFIF>
		AND		dtEffectiveEnd >= 
			<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>
				#CreateODBCDateTime(Tenant.dtMoveOut)#
			<CFELSE>
				#Now()#
			</CFIF>
		<!--- 11/17/2008 Sathya rectified this as it had c.iproductline_id which was wrong so change it to Charges.iProductLine_id --->
		AND		Charges.iProductLine_ID = #Tenant.iProductLine_ID#
	</CFIF>
</CFQUERY>

<CFIF (isBlank(StandardRent.mRoomAmount,0) + isBlank(StandardRent.mCareAmount,0)) LTE 0>
	<!--- MLAW 08/17/2006 Add iProductline_ID filter --->
	<CFQUERY NAME="StandardRent" DATASOURCE="#APPLICATION.datasource#">
		<CFIF Occupancy EQ 1>
			SELECT	C.cDescription, C.mAmount mRoomAmount, 0 mCareAmount, C.iQuantity ,CT.iChargeType_ID
			FROM	Charges C with (NOLOCK)
			JOIN	ChargeType CT with (NOLOCK) ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
			WHERE	C.dtRowDeleted IS NULL
			AND	CT.bIsRent IS NOT NULL
			AND	CT.bIsDiscount IS NULL AND CT.bIsRentAdjustment IS NULL AND CT.bIsMedicaid IS NULL
			AND	CT.bAptType_ID IS NOT NULL AND	CT.bIsDaily IS NULL AND	CT.bSLevelType_ID IS NULL
			AND	C.iResidencyType_ID = #Tenant.iResidencyType_ID#
			AND	C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND	C.iAptType_ID = #Tenant.iAptType_ID#
			AND	C.iOccupancyPosition = #Occupancy#
			AND	C.dtEffectiveStart <= 
				<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>
					#CreateODBCDateTime(Tenant.dtMoveOut)#
				<CFELSE>
					#Now()#
				</CFIF>
			AND	C.dtEffectiveEnd >= 
				<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>
					#CreateODBCDateTime(Tenant.dtMoveOut)#
				<CFELSE>
					#Now()#
				</CFIF>
			AND	C.iProductLine_ID = #Tenant.iProductLine_ID#
		<CFELSE>
			SELECT	C.cDescription, C.mAmount mRoomAmount, 0 mCareAmount, C.iQuantity, CT.iChargeType_ID
			FROM	Charges C with (NOLOCK)
			JOIN	ChargeType CT with (NOLOCK) ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
			WHERE	C.dtRowDeleted IS NULL
			AND	CT.bIsRent IS NOT NULL
			AND	CT.bIsDiscount IS NULL AND CT.bIsRentAdjustment IS NULL AND CT.bIsMedicaid IS NULL
			AND	CT.bAptType_ID IS NOT NULL AND CT.bIsDaily IS NULL 	AND	CT.bSLevelType_ID IS NULL
			AND	C.iAptType_ID IS NULL
			AND	C.iResidencyType_ID = #Tenant.iResidencyType_ID#
			AND	C.iOccupancyPosition = #Occupancy#
			AND	C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND	C.dtEffectiveStart <= 
				<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>
					#CreateODBCDateTime(Tenant.dtMoveOut)#
				<CFELSE>
					#Now()#
				</CFIF>
			AND	C.dtEffectiveEnd >= 
				<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>
					#CreateODBCDateTime(Tenant.dtMoveOut)#
				<CFELSE>
					#Now()#
				</CFIF>
			AND	C.iProductLine_ID = #Tenant.iProductLine_ID#
		</CFIF>		
	</CFQUERY>
</CFIF>

<CFIF Tenant.iResidencyType_ID EQ 2 OR (Tenant.iResidencyType_ID EQ 3 
	and isDefined("StandardRent.mAmount") 
	AND isBlank(StandardRent.mAmount,0) EQ 0)>
	<CFQUERY NAME="StandardRent" DATASOURCE="#APPLICATION.datasource#">
		Select 0 mRoomAmount, 0 mCareAmount
	</CFQUERY>
</CFIF>

	<!--- MLAW 08/17/2006 Add iProductline_ID filter --->
	<CFQUERY NAME = "DailyRent" DATASOURCE = "#APPLICATION.datasource#">
		<CFIF Occupancy EQ 1>
			SELECT	C.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
			FROM	Charges C with (NOLOCK)
			JOIN	ChargeType CT ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
			WHERE	C.dtRowDeleted IS NULL
			AND	CT.bIsRent IS NOT NULL
			AND	CT.bIsDiscount IS NULL AND CT.bIsRentAdjustment IS NULL AND CT.bIsMedicaid IS NULL
			AND	CT.bAptType_ID IS NOT NULL AND CT.bIsDaily IS NOT NULL AND	CT.bSLevelType_ID IS NULL
			AND	C.iResidencyType_ID = #Tenant.iResidencyType_ID#
			AND	C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND	C.iAptType_ID = #Tenant.iAptType_ID#
			AND	C.iOccupancyPosition = #Occupancy#
			AND	C.dtEffectiveStart <= 
			<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>
				#CreateODBCDateTime(Tenant.dtMoveOut)#
			<CFELSE>
				#Now()#
			</CFIF>
			AND	C.dtEffectiveEnd >= 
				<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>
					#CreateODBCDateTime(Tenant.dtMoveOut)#
				<CFELSE>
					#Now()#
				</CFIF>
			<CFIF Tenant.cChargeSet NEQ ''>
				AND C.cChargeSet = '#Tenant.cChargeSet#'
			<CFELSE>
				AND C.cChargeSet IS NULL
			</CFIF>
			AND C.iProductLine_ID = #Tenant.iProductLine_ID#
		<CFELSE>
			SELECT	C.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
			FROM	Charges C with (NOLOCK)
			JOIN	ChargeType CT with (NOLOCK) ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
			WHERE	C.dtRowDeleted IS NULL
			AND	CT.bIsRent IS NOT NULL
			AND	CT.bIsDiscount IS NULL AND CT.bIsRentAdjustment IS NULL AND CT.bIsMedicaid IS NULL
			AND	CT.bAptType_ID IS NOT NULL AND CT.bIsDaily IS NOT NULL 	AND	CT.bSLevelType_ID IS NULL
			AND	C.iAptType_ID IS NULL
			AND	C.iResidencyType_ID = #Tenant.iResidencyType_ID#
			AND	C.iOccupancyPosition = #Occupancy#
			AND	C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND	C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(Tenant.dtMoveOut)#<CFELSE>#Now()#</CFIF>
			AND	C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(Tenant.dtMoveOut)#<CFELSE>#Now()#</CFIF>
			<CFIF Tenant.cChargeSet NEQ ''>AND C.cChargeSet = '#Tenant.cChargeSet#'<CFELSE>AND C.cChargeSet IS NULL</CFIF>
			AND C.iProductLine_ID = #Tenant.iProductLine_ID#
		</CFIF>	
	</CFQUERY>	

	<CFQUERY NAME='qResidentCare' DATASOURCE="#APPLICATION.datasource#">
		SELECT	C.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
		FROM	Charges C with (NOLOCK)
		JOIN	ChargeType CT with (NOLOCK)ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
		AND 	CT.bIsRent IS NOT NULL AND CT.bIsMedicaid IS NULL AND CT.bIsDiscount IS NULL
		AND 	CT.bIsRentAdjustment IS NULL
		WHERE	C.dtRowDeleted IS NULL AND C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		<CFIF Tenant.cChargeSet NEQ ''>AND C.cChargeSet = '#Tenant.cChargeSet#'<CFELSE>AND C.cChargeSet IS NULL</CFIF>
		AND	C.iResidencyType_ID = #Tenant.iResidencyType_ID# AND C.iAptType_ID IS NULL AND iSLevelType_ID = #GetSLevel.iSLevelType_ID# AND CT.bIsDaily IS NULL
		AND iOccupancyPosition IS NULL
		AND	C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(Tenant.dtMoveOut)#<CFELSE>#Now()#</CFIF>
		AND	C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(Tenant.dtMoveOut)#<CFELSE>#Now()#</CFIF>
	</CFQUERY>
	
	<!--- 25575 - rts - 6/30/2010 - rts - care should not be dependant on residency type --->
	<CFQUERY NAME='qDailyCare' DATASOURCE="#APPLICATION.datasource#">
		SELECT	C.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
		FROM	Charges C with (NOLOCK)
		JOIN	ChargeType CT with (NOLOCK) ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
		AND 	CT.bIsRent IS NOT NULL AND CT.bIsMedicaid IS NULL AND CT.bIsDiscount IS NULL
		AND 	CT.bIsRentAdjustment IS NULL
		WHERE	C.dtRowDeleted IS NULL AND C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		<CFIF Tenant.cChargeSet NEQ ''>AND C.cChargeSet = '#Tenant.cChargeSet#'<CFELSE>AND C.cChargeSet IS NULL</CFIF>
		<cfif Tenant.iResidencyType_ID neq 3>
		AND	C.iResidencyType_ID = #Tenant.iResidencyType_ID#
		</cfif> 
		AND C.iAptType_ID IS NULL AND iSLevelType_ID = #GetSLevel.iSLevelType_ID# AND CT.bIsDaily IS NOT NULL
		AND iOccupancyPosition IS NULL
		AND	C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(Tenant.dtMoveOut)#<CFELSE>#Now()#</CFIF>
		AND	C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(Tenant.dtMoveOut)#<CFELSE>#Now()#</CFIF>
	</CFQUERY>


<CFOUTPUT>		
	<CFIF (Tenant.cBillingType EQ 'D' AND DailyRent.mAmount NEQ '')>
		<CFSET DailyRentCalc = DailyRent.mAmount>
	<CFELSEIF DailyRent.mAmount EQ "" OR DailyRent.mAmount EQ 0>
		<CFSET DailyRentCalc = 0.00>
	<CFELSEIF Tenant.iResidencyType_ID EQ 3>
		<CFSET DailyRentCalc = StandardRent.mRoomAmount>
	<CFELSEIF Tenant.iResidencyType_ID EQ 2>
		#StandardRent.mRoomAmount#/#DaysInMonth(Tenant.dtChargeThrough)# *********************<BR>
		<CFSET DailyRentCalc = StandardRent.mRoomAmount/DaysInMonth(Tenant.dtChargeThrough)>
	<CFELSE>
		<CFSET DailyRentCalc = isBlank(StandardRent.mRoomAmount,0)/30>
	</CFIF>

	<CFSET DailyRent = NumberFormat(DailyRentCalc,"-9999999.99")>
</CFOUTPUT>

<!--- ==============================================================================
Retreive all current charges
=============================================================================== --->
<CFQUERY NAME="Charges" DATASOURCE="#APPLICATION.datasource#">
	SELECT	SUM(INV.mAmount) as SUM
	FROM	InvoiceMaster IM with (NOLOCK)
	JOIN	InvoiceDetail INV with (NOLOCK)	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
	JOIN	ChargeType CT with (NOLOCK)ON CT.iChargeType_ID = INV.iChargeType_ID
	WHERE	bMoveInInvoice IS NULL
	AND		INV.iTenant_ID = #url.ID# 
	AND		INV.dtRowDeleted IS NULL <!--- AND		CT.bIsRent IS NULL --->
	AND		IM.bFinalized IS NULL <!--- Added 1/8/02 SBD --->
	AND		IM.dtRowDeleted is null <!--- End Added 1/8/02 SBD --->
</CFQUERY>

<CFIF MoveOutInfo.dtInvoiceStart EQ "">
	<!--- ==============================================================================
	Retrieve Finalized invoices dtInvoiceEnd
	=============================================================================== --->
	<CFQUERY NAME="qLastInvoice" DATASOURCE="#APPLICATION.datasource#">
		SELECT	dtInvoiceEnd
		FROM 	InvoiceMaster with (NOLOCK)
		WHERE 	cSolomonKey = '#TRIM(Tenant.cSolomonKey)#' 
		AND	 	bFinalized is not null 
		AND		dtrowdeleted is null 
		ORDER BY cAppliesToAcctPeriod
	</CFQUERY>
	<CFSET PaymentsdtInvoiceStart = qLastInvoice.dtInvoiceEnd>
<CFELSE>
	<CFSET PaymentsdtInvoiceStart = MoveOutInfo.dtInvoiceStart>
</CFIF>

<!--- ==============================================================================
Retreive the Recent payments for this House
EXEC rw.sp_MoveOutPayments @SolomonKey='#Tenant.cSolomonKey#', @dtInvoiceStart='#PaymentsdtInvoiceStart#'
=============================================================================== --->
<CFQUERY NAME="Payments" DATASOURCE="#APPLICATION.datasource#">
	EXEC rw.sp_MoveOutPayments @SolomonKey= '#Tenant.cSolomonKey#', @iInvoiceMaster_ID= #MoveOutInfo.iInvoiceMaster_ID#
</CFQUERY>

<!--- ==============================================================================
Remove any lines that are from this working invoice
=============================================================================== --->
<CFQUERY NAME="Payments" DBTYPE="QUERY">
	SELECT	* FROM Payments WHERE User1 <> '#MoveOutInfo.iInvoiceNumber#'
</CFQUERY>

<!--- ==============================================================================
Retrieve all Current MoveOut Charges
=============================================================================== --->
<CFQUERY NAME = "CurrentCharges" DATASOURCE = "#APPLICATION.datasource#">
	<CFIF Tenant.iTenantStateCode_ID LT 3>
		SELECT	inv.iInvoiceDetail_ID
	,inv.[iInvoiceMaster_ID]
	,inv.[iTenant_ID] 
	,inv.[iChargeType_ID]
	,inv.[cAppliesToAcctPeriod]
	,inv.[bIsRentAdj] 
	,inv.[dtTransaction]
	,inv.[iQuantity] 
	,inv.[cDescription] 
	,ROUND(inv.mAmount, 2) as  mAmount
	,inv.[cComments] 
	,inv.[dtAcctStamp] 
	,inv.[iRowStartUser_ID] 
	,inv.[dtRowStart]
	,inv.[iRowEndUser_ID] 
	,inv.[dtRowEnd] 
	,inv.[iRowDeletedUser_ID] 
	,inv.[dtRowDeleted] 
	,inv.[cRowStartUser_ID] 
	,inv.[cRowEndUser_ID] 
	,inv.[cRowDeletedUser_ID] 
	,inv.[iRecurringCharge_ID] 
	,inv.[bNoInvoiceDisplay]
	,inv.[iDaysBilled] ,		
		INV.cAppliesToAcctPeriod as DetailAppliesToAcctPeriod
		FROM InvoiceMaster IM with (NOLOCK)
		JOIN InvoiceDetail INV with (NOLOCK)ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
		JOIN ChargeType CT with (NOLOCK)ON INV.iChargeType_ID = CT.iChargeType_ID and ct.dtrowdeleted is null
		WHERE bMoveInInvoice IS NULL AND IM.dtRowDeleted IS NULL AND	INV.dtRowDeleted IS NULL
		AND	
		
		((IM.bFinalized IS NULL AND INV.iRowStartUser_ID <> 0 and im.bmoveoutinvoice is not null) 
		OR 
		IM.bMoveOutInvoice IS NOT NULL and im.bfinalized is null)
		
		AND	INV.iTenant_ID = #url.ID#
		<!---AND	NOT (CT.bIsMedicaid IS NOT NULL AND bIsRent IS not NULL)--->
		and INV.iChargeType_ID not in (1740, 69,44, 8, 1749,1750)	 <!---mshah removed 1741--->	
		<CFIF IsDefined("url.MID")>
		AND	IM.iInvoiceMaster_ID = #URL.MID#
		</CFIF>
		<!--- 05/25/2010 Project 20933 Sathya Added this not to display the added not to show up the added late fee --->
		AND (INV.bNoInvoiceDisplay is null or INV.bNoInvoiceDisplay = 0)  AND ROUND(inv.mAmount,2) <> 0.00
		<!--- End of code for project 20933 --->
		ORDER BY INV.cAppliesToAcctPeriod
	<CFELSE>
		EXEC rw.sp_MoveOutInvoice @TenantID=#Tenant.iTenant_ID#, @iInvoiceMaster_ID=#MoveOutInfo.iInvoiceMaster_ID#
		
		
<!--- ==============================================================================
		<CFIF Moveoutinfo.dtInvoiceEnd NEQ "">
			EXEC.rw.sp_MoveOutInvoice @TenantID=#Tenant.iTenant_ID#, @InvoiceDate='#MoveOutInfo.dtInvoiceEnd#'
		<CFELSE>
			EXEC.rw.sp_MoveOutInvoice @TenantID=#Tenant.iTenant_ID#
		</CFIF>
=============================================================================== --->
	</CFIF>
</CFQUERY>

<cfquery name="qryDeferred"  datasource="#application.datasource#">
		select
		t.itenant_id 
		,t.csolomonkey 
		,t.cfirstname
		, t.clastname
		, h.cname as housename
		,h.ihouse_id
		, h.iOpsArea_ID 
		,h.cnumber
		,OPSA.cName	as 'OPSname'
		,OPSA.iRegion_ID
		,reg.cName	as 'Regionname'			
		, HL.dtCurrentTipsMonth as dtCurrentTipsMonth	
		,cast(cast(ts.mBaseNRF as decimal(10,2)) as varchar(10))  as 'BaseNRF'
 
		,rc.cdescription
		,ts.cNRFAdjApprovedBy
		,ts.dtMoveIn	
		,ts.mAmtDeferred
		,ts.mAmtNRFPaid
		,case when ts.itenantstatecode_id	> 2 then 'Moved Out' else 	'Current' end as 'Status'
		,ts.mAdjNRF   as 'AdjNRF'
		,convert(varchar, rc.dtRowStart, 101) as dtRowStart
		,convert(varchar, rc.dtEffectiveStart, 101) as dtEffectiveStart
		,convert(varchar, rc.dtEffectiveEnd, 101) as dtEffectiveEnd
		,rc.dtRowDeleted
		,ts.imonthsdeferred	as 'nbrpaymnt'		
		,(	select count (mamount)
			from invoicedetail inv with (NOLOCK)
			join invoicemaster im with (NOLOCK)on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and	itenant_id =  t.itenant_id 
			and inv.ichargetype_id = 1741 
			and im.bMoveOutInvoice is null			
			and im.bFinalized = 1
			) as dispnbrpaymentmade
		,	(select sum (mamount)
			from invoicedetail inv with (NOLOCK)
			join invoicemaster im with (NOLOCK) on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and	itenant_id =   t.itenant_id 
			and inv.ichargetype_id = 1741 
			and im.bMoveOutInvoice is null
			and im.bFinalized = 1
			) as Accum
		from tenant t with (NOLOCK)
		join tenantstate ts with (NOLOCK) on t.itenant_id = ts.itenant_id
		join house h with (NOLOCK) on t.ihouse_id = h.ihouse_id
		join dbo.OpsArea OPSA with (NOLOCK) on OPSA.iOpsArea_ID  = h.iOpsArea_ID
		join dbo.Region reg with (NOLOCK) on reg.iRegion_ID = OPSA.iRegion_ID
		join dbo.RecurringCharge RC with (NOLOCK) on RC.iTenant_ID = t.iTenant_ID 
		JOIN HouseLog HL with (NOLOCK) ON h.iHouse_ID = HL.iHouse_Id
		join charges chg with (NOLOCK) on chg.iCharge_ID = RC.iCharge_ID and chg.ichargetype_id = 1740
 
		where ts.bIsNRFDeferred = 1
		  and   rc.dtEffectiveEnd >= getdate() 
		  and t.itenant_id = #Tenant.iTenant_ID#
	 
		order by housename,t.clastname,t.cfirstname
</cfquery>

<cfif qryDeferred.AdjNRF is "">
 	<cfset thisadjnrf = 0>
<cfelse>
	<cfset thisadjnrf = qryDeferred.AdjNRF>
</cfif>

<cfif qryDeferred.mAmtNRFPaid is "">
 	<cfset thismAmtNRFPaid = 0>
<cfelse>
	<cfset thismAmtNRFPaid = qryDeferred.mAmtNRFPaid>
</cfif>

<cfif qryDeferred.Accum is "">
 	<cfset thisAccum = 0>
<cfelse>
	<cfset thisAccum= qryDeferred.Accum>
</cfif>



<cfset NRFrembal =  ((thisadjnrf- thismAmtNRFPaid)   - thisAccum) >
<cfset NRFrembal = numberformat(NRFrembal,'999999.00')>
<!--- 05/25/2010 Project 20933 sathya Added this add the total to the invoice--->
	<CFIF MoveOutInfo.RecordCount GT 0> 
		<CFSET tempdateforlatefee = CreateODBCDateTime(LEFT(MoveOutInfo.cAppliesToAcctPeriod,4) & '-' & RIGHT(MoveOutInfo.cAppliesToAcctPeriod,2) & '-01')>
		<CFSET LatefeeAppliesToAcctPeriod = #DateFormat(tempdateforlatefee,"yyyymm")#>
	
		<cfquery name="LateFeeBalanceForinvoice" DATASOURCE = "#APPLICATION.datasource#">
			EXEC rw.sp_LateFeeBalanceForInvoice @csolomonkey='#Tenant.cSolomonKey#' ,@tipsMonth='#LatefeeAppliesToAcctPeriod#'
		</cfquery>
	
		<!---07/28/2010 Project 20933 Part-B sathya added this for the Current Late fee display  --->
		<cfquery name="CurrentLatefeeInfoRecord" DATASOURCE = "#APPLICATION.datasource#">
			select * 
			from tenantlatefee with (NOLOCK)
			where itenant_id = #url.ID#
			and cAppliesToAcctPeriod ='#LatefeeAppliesToAcctPeriod#'
			and dtrowdeleted is null
		</cfquery>
		<!--- Project 20933 Part-B End of Code --->
	</CFIF>
	
<!--- End of code for project 20933 --->

<!--- 07/02/2010 Project 50227 Sathya added this to retrieve which promotion the tenant had
				Here in this query we are not checking if the promotion was deleted or not.
				The reason being they  were assigned and we have to display if for notifiying 
				to the AR--->
	<cfif (Tenant.iTenantStateCode_ID EQ 3) and (Tenant.Promotions GT 0)>
		<cfquery name="PromotionName" DATASOURCE="#APPLICATION.datasource#">
			 Select * from TenantPromotionSet with (NOLOCK) where iPromotion_id = #Tenant.Promotions#
		</cfquery>
	</cfif>
<!--- End of code Project 50227 --->


<!--- ==============================================================================
Retreive Payor Information
=============================================================================== --->
<!--- <CFQUERY NAME="Payor" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	C.*, LTC.iRelationshipType_ID, RT.cDescription as RelationShip
	FROM	LinkTenantContact LTC
	JOIN RelationshipType RT ON RT.iRelationshipType_ID = LTC.iRelationshipType_ID
	JOIN Contact C ON C.iContact_ID = LTC.iContact_ID
	JOIN Tenant T ON LTC.iTenant_ID = T.iTenant_ID
	WHERE	(LTC.iTenant_ID = #isblank(url.ID,tenant.itenant_id)# AND T.cSolomonKey = '#Tenant.cSolomonKey#')
	AND	LTC.bIsPayer IS NOT NULL AND C.dtRowDeleted IS NULL AND LTC.dtRowDeleted IS NULL
</CFQUERY> --->
<CFQUERY NAME="Payor" DATASOURCE="#APPLICATION.datasource#">
	SELECT C.*, LTC.iRelationshipType_ID, RT.cDescription as RelationShip
	FROM LinkTenantContact LTC
	JOIN RelationshipType RT (NOLOCK) ON RT.iRelationshipType_ID = LTC.iRelationshipType_ID and RT.dtrowdeleted is null	
		and LTC.bIsMoveOUtPayer = 1
	JOIN Contact C (NOLOCK) ON C.iContact_ID = LTC.iContact_ID and c.dtrowdeleted is null
	JOIN Tenant T (NOLOCK) ON LTC.iTenant_ID = T.iTenant_ID and t.dtrowdeleted is null
	WHERE LTC.dtrowdeleted is null <!--- and LTC.bIsPayer IS NOT NULL ---> 
	AND (LTC.iTenant_ID = #url.ID# 
	AND T.cSolomonKey = '#trim(Tenant.cSolomonKey)#')
	and LTC.bIsMoveOutPayer = 1	
	order by c.dtrowstart desc
</CFQUERY>

<!---Mshah added query for to get info for account closed move out--->
<CFQUERY NAME="TenantstateAfterAcctClosed" DATASOURCE="#APPLICATION.datasource#">
	select top 1 vw.dtrowstart,  * from rw.vw_tenantstate_history vw with (NOLOCK) where iTenant_ID = #url.ID# 
	and itenantstatecode_ID= 4
	order by vw.dtRowStart
</cfquery>
<CFQUERY NAME="TenantAfterAcctClosed" DATASOURCE="#APPLICATION.datasource#">
	select top 1 * from rw.vw_Tenant_History with (NOLOCK)
	where iTenant_ID = #url.ID# 
	and dtrowstart < '#TenantstateAfterAcctClosed.dtRowStart#'
	order by dtRowStart desc
</cfquery>
<!--- ==============================================================================
Retrieve all current GLAccounts
=============================================================================== --->
<!---<CFQUERY NAME = "GLAccounts" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	distinct cGLaccount FROM ChargeType WHERE dtRowDeleted IS NULL
</CFQUERY>--->

<!--- ==============================================================================
Retreive Tenant Information
=============================================================================== --->
<!---<CFINCLUDE TEMPLATE="../Shared/Queries/TenantInformation.cfm">--->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">
<!---<CFINCLUDE TEMPLATE="../Shared/Queries/Relation.cfm">
<CFINCLUDE TEMPLATE="../Shared/Queries/StateCodes.cfm">--->

<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<!--- MLAW 08/07/2006 --->
<CFIF ShowBtn>
	<CFINCLUDE TEMPLATE="../../header.cfm">
<CFELSE>
	<style type="text/css">
	<!---
	body {
		background-color: #FFFFCC;
	}
	--->
	</style>
	<CFOUTPUT>
		<CFIF FindNoCase("TIPS4",getTemplatePath(),1) GT 0>
			<LINK REL=StyleSheet TYPE="Text/css"  HREF="//#SERVER_NAME#/intranet/Tips4/Shared/Style2.css">
		<CFELSE>
			<LINK REL="STYLESHEET" TYPE="text/css" HREF="//#SERVER_NAME#/intranet/TIPS/Tip30_Style.css">
		</CFIF>
	</CFOUTPUT>	
</CFIF>

<CFOUTPUT>

<CFIF ShowBtn>
	<A HREF = "../MainMenu.cfm" STYLE = "Font-size: 14;"><B>Click Here to Go Back To TIPS Summary.</B></A>
<CFELSE>
<!--- 51267 - MO Codes - 4/8/2010 - RTS - Remove any MO links from Census, and going back to census --->
<!--- 	<A HREF = "../census/FinalizeMoveOut.cfm" STYLE = "Font-size: 14;"><B>Click Here to Go Back.</B></A> --->
<!--- end 51267 --->
</CFIF>

<BR>
<BR>
<!---<cfdump var="#formfield#" cfabort>   --->
<FORM NAME = "MoveOutFormSummary" ACTION = "MoveOutForm.cfm?ShowBtn=#ShowBtn#" METHOD = "POST">
<CFIF ListFindNoCase(SESSION.codeblock,23) GTE 1 OR SESSION.UserID IS 3025>
	<CFIF Tenant.iTenantStateCode_ID GTE 3>
		<TABLE CLASS="noborder">
			<CFIF Tenant.iTenantStateCode_ID EQ 3>
				<CFSET shortstyle='width: 25%; background: yellow; text-align: center; font-size: 14;'>
				<TR>
												
					<TD STYLE="#shortstyle#">
						<A HREF="MoveOutForm.cfm?ID=#Tenant.iTenant_ID#&edit=1&stp=5&MID=#MoveOutInfo.iInvoiceMaster_ID#&ShowBtn=#ShowBtn#"> 
							Edit Move Out Form </A>
					</TD>
					<!--- 07/02/2010 Project 50227 Sathya made changes for the tips promotions
					       if the tenant had a promotion record then the AR acknowledgement must be 
					       	recorded to show up the close account option. 
					       	rewrote the close account option --->
				<!---	<cfif (Tenant.Promotions GT 0)>
						<cfif Tenant.bIsArAcknowledgePromotion EQ 1> ---->
								<!--- 04/27/2010 project 20933 sathya added  this out for late fee  if there is a late fee dont show the close account--->
							<!---	<cfif (getTenantLateFeeRecords.recordcount eq 0) and (Tenant.iTenantStateCode_ID EQ 3)>--->
								 <TD STYLE="#shortstyle#">
								 	<A HREF="CloseAccount.cfm?ID=#url.ID#&ShowBtn=#ShowBtn#"> Close Account </A>
								 </TD>
							<!---	 </cfif> --->
								<!--- End of code Project 20933 --->
					<!---	</cfif>
					<cfelse>
						<cfif (getTenantLateFeeRecords.recordcount eq 0) and (Tenant.iTenantStateCode_ID EQ 3)>
						 <TD STYLE="#shortstyle#">
						 	<A HREF="CloseAccount.cfm?ID=#url.ID#&ShowBtn=#ShowBtn#"> Close Account </A>
						 </TD>
						 </cfif>
				 	</cfif> --->
					<!--- End of code Project 50227 --->
					<TD STYLE="#shortstyle#">
						<A HREF="ResetTenant.cfm?ID=#url.ID#&ShowBtn=#ShowBtn#"> Reset to Moved In </A>
					</TD>
					<TD STYLE="#shortstyle#">
						<CFIF ListFindNoCase(session.CodeBlock,22) GT 1 OR ListFindNoCase(session.CodeBlock,23) GT 1
						OR ListFindNoCase(session.CodeBlock,24) GT 1 OR ListFindNoCase(session.CodeBlock,25) GT 1>
							<!--- 
								all imports should be done via the auto-import process now 
								the CSV Process is not reliable since the Charge Types Changes
							---->
							<!--- <A HREF="MoveOutCSVGeneration.cfm?ID=#URL.ID#" STYLE = "font-size: 14; color: red; background: yellow;"> 
							Create CSV </A> --->
						</CFIF>
					</TD>				
				</TR>
			<CFELSE>
				<TR>
					<TD COLSPAN=100% STYLE="width: 25%; background: yellow; text-align: center; font-size: 14;">
						<A HREF="../Registration/MoveOutAddendum.cfm?ID=#Tenant.iTenant_ID#&mosummary=1&ShowBtn=#ShowBtn#">
						Create Addendum to this Account</A>
					</TD>
				</TR>
			</CFIF>
			<TR>
				<TD COLSPAN=100% STYLE="background: yellow; text-align: center; font-size: 14;">
<!--- ==============================================================================
					<A HREF="MoveOutReport.cfm?ID=#url.ID#<CFIF MoveOutInfo.dtInvoiceEnd NEQ "">&Inv=#MoveOutInfo.dtInvoiceEnd#</CFIF>"> Print Move Out Invoice </A>
=============================================================================== --->
					<A HREF="MoveOutReport.cfm?ID=#url.ID#&MID=#MoveOutInfo.iInvoiceMaster_ID#"> Print Move Out Invoice </A>
				</TD>
			</TR>				
		</TABLE>
	</CFIF>
	
</CFIF>

<TABLE>
	<TR><TH COLSPAN="2">Move Out Form</TH></TR>
<!---Mshah - needs to change here if tenantstatecode_ID = 4 --->
	<cfif Tenant.iTenantStateCode_ID eq 4>
	<TR>
		<TD STYLE="text-align: center;">
			<TABLE CLASS=noborder STYLE="width: 100%;">			
				<TR><TD>Account Number:</TD><TD STYLE="text-align: right;">#TenantAfterAcctClosed.cSolomonKey#</TD></TR>
				<TR><TD>Name</TD><TD STYLE="text-align: right;">#TenantAfterAcctClosed.cFirstName# #TenantAfterAcctClosed.cLastName#</TD></TR>
				<TR><TD>Financial Possesion Date</TD><TD STYLE="text-align: right;">#LSDateFormat(TenantstateAfterAcctClosed.dtRentEffective, "mm/dd/yyyy")#</TD></TR>	
			</TABLE>
		</TD>
	<cfelse>
		<TR>
			<TD STYLE="text-align: center;">
				<TABLE CLASS=noborder STYLE="width: 100%;">			
					<TR><TD>Account Number:</TD><TD STYLE="text-align: right;">#TENANT.cSolomonKey#</TD></TR>
					<TR><TD>Name</TD><TD STYLE="text-align: right;">#TENANT.cFirstName# #TENANT.cLastName#</TD></TR>
					<TR><TD>Financial Possesion Date</TD><TD STYLE="text-align: right;">#LSDateFormat(TENANT.dtRentEffective, "mm/dd/yyyy")#</TD></TR>	
				</TABLE>
			</TD>
	</cfif>		
	<!---End here --->
		<TD STYLE="text-align: center; width: 50%;">
			<TABLE CLASS="noborder" STYLE="width: 100%;">
				<TR><TD>Unit</TD><TD STYLE="text-align: right; width: 50%;">#TENANT.cAptNumber#</TD></TR>
				<TR><TD>Apartment Size</TD><TD STYLE="text-align: right; width: 50%;">#TENANT.AptType#</TD><TR>
				<TR><TD>Payment Method</TD><TD STYLE="text-align: right; width: 50%;">#TENANT.Residency#</TD></TR>
			</TABLE>
		</TD>
	</TR>

</TABLE>
<TABLE>	
	<TR>
		<TD STYLE="font-weight: bold; text-align: left;">Reason for Move Out:</TD>
		<TD>#Tenant.Reason# <CFIF Tenant.bIsVoluntary GT 0>(Voluntary)<CFELSE>(InVoluntary)</CFIF></TD>
		<TD COLSPAN="2" STYLE="text-align: right;">	<B>Invoice Number: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; #MoveOutInfo.iInvoiceNumber#</B> </TD>
	</TR>
	<!--- 51267 - 3/25/2010 - RTS - MO Codes --->
	<TR>
		<TD STYLE="font-weight: bold; text-align: left;">Secondary Reason:</TD>
		<cfif Tenant.Reason2 neq ''>
		<TD>#Tenant.Reason2# <CFIF Tenant.bIsVoluntary2 GT 0>(Voluntary)<CFELSE>(InVoluntary)</CFIF></TD>
		<cfelse>
		<TD>(Not Provided - Optional)</td>
		</cfif>
	</TR>
	<TR>
		<TD STYLE="font-weight: bold; text-align: left;">Move Out Location:</TD>
		<TD>#Tenant.TMOLDescription# </TD>
		<CFIF Tenant.iTenantStateCode_ID EQ 3>
		<td>&nbsp;</td>
		<cfelse>
		<TD STYLE="text-align: right;">
		<A href="MoveOutForm.cfm?ID=#Tenant.iTenant_ID#&edit=1" id="EditTMORL">Edit Move Out Reasons and Location</A>
		</TD>
		</cfif>
	</TR>
	<!--- end 51267 --->
</TABLE>

<TABLE>				
<TR><TD COLSPAN="4" STYLE="font-weight: bold;"> CURRENT MONTH PRORATED RENT: </TD></TR>		
	<TR>
		<TD VALIGN="TOP" COLSPAN=2 STYLE="text-align: center;">
			<TABLE STYLE="width: 85%; height: 100%; text-align: right; ">
				<CFIF Tenant.cBillingType NEQ 'd'>
				<TR>
					<TD NOWRAP STYLE="width: 40%; font-size: 12; text-align: left;">Monthly Rent Rate:</TD>							
					<TD STYLE="text-align: right;"> $#TRIM(NumberFormat((StandardRent.mRoomAmount), "999999.99"))# </TD>
				</TR>
				<TR>
					<TD NOWRAP STYLE="width: 40%; font-size: 12; text-align: left;">Resident Care:</TD>							
					<TD STYLE="text-align: right;"> $#TRIM(NumberFormat(qResidentCare.mAmount, "999999.99"))# </TD>
				</TR>
				</CFIF>
				<!---Mshah - need to change here if tenant account closed --->
				<cfif tenant.iTenantStateCode_ID eq 4>
					<TR>
						<TD STYLE="width: 40%; font-size: 12; text-align: left;"> Physical Move Out Date:</TD>
						<TD>#DateFormat(TenantstateAfterAcctClosed.dtMoveOut, "mm/dd/yyyy")#</TD>
					</TR>
					<TR>
						<TD STYLE="font-size: 12; text-align: left;">Date of Notice:</TD>
						<TD>#DateFormat(TenantstateAfterAcctClosed.dtNoticeDate, "mm/dd/yyyy")#</TD>
					</TR>
				<cfelse>
					<TR>
						<TD STYLE="width: 40%; font-size: 12; text-align: left;">Physical Move Out Date:</TD>
						<TD>#DateFormat(Tenant.dtMoveOut, "mm/dd/yyyy")#</TD>
					</TR>
					<TR>
						<TD STYLE="font-size: 12; text-align: left;">Date of Notice:</TD>
						<TD>#DateFormat(Tenant.dtNoticeDate, "mm/dd/yyyy")#</TD>
					</TR>
				</cfif>
				<!---Mshah end --->
				<TR>
					<TD STYLE="font-size: 12; text-align: left;"> Financial Move Out Date: </TD>
					<CFSCRIPT>
						//If there is no data passed via the form fields use the database information
						if (Tenant.dtChargeThrough EQ "" AND IsDefined("form.ChargeMonth")) { dtChargeThrough = CreateODBCDateTime(form.ChargeYear & "/" & form.ChargeMonth & "/" & form.ChargeDay); }
						else if (Tenant.dtChargeThrough NEQ "") { dtChargeThrough = Tenant.dtChargeThrough; form.ChargeYear = Year(Tenant.dtChargeThrough); form.ChargeMonth = Month(Tenant.dtChargeThrough); form.ChargeDay = Day(Tenant.dtChargeThrough); }
						else { dtChargeThrough = Now(); form.ChargeYear = Year(Now()); form.ChargeMonth = Month(Now()); form.ChargeDay = Day(Now()); }
									
						//Since policy is 30 days for all months start the end date at the 30th day
						CalculatedChargeDate = Variables.dtChargeThrough;
						EndDate	= Month(dtChargeThrough) & '/30/' & Year(dtChargeThrough);
		
						//Set the ChargeMonth as day one of that month
						ChargeMonthYear = CreateODBCDateTime(Month(dtChargeThrough) & '/01/' & Year(dtChargeThrough));
					</CFSCRIPT>
					<!--- ==============================================================================
					Query for current month rent charges
					=============================================================================== --->
					<CFQUERY NAME="IsRentCharged" DATASOURCE="#APPLICATION.datasource#">
						SELECT	*
						FROM	InvoiceDetail INV with (NOLOCK)
						JOIN	ChargeType CT with (NOLOCK)	ON INV.iChargeType_ID = CT.iChargeType_ID
						JOIN	InvoiceMaster IM with (NOLOCK)	ON	INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
						WHERE	INV.dtRowDeleted IS NULL
						AND	CT.dtRowDeleted IS NULL AND IM.dtRowDeleted IS NULL AND	CT.bIsRent IS NOT NULL 
						AND IM.bMoveOutInvoice IS NULL AND IM.bMoveInInvoice IS NULL
						AND	IM.cAppliesToAcctPeriod = '#PerPost#'
						AND	INV.iTenant_ID = #url.ID#
					</CFQUERY>
					
					<CFSCRIPT>
						if (Tenant.dtChargeThrough EQ "") {
							dtChargeThrough = CreateODBCDateTime(form.ChargeYear & "/" & form.ChargeMonth & "/" & form.ChargeDay);
							dtChargeDayOne = CreateODBCDateTime(form.ChargeYear & "/" & form.ChargeMonth & "/" & '01'); }
						else {
							dtChargeThrough = Tenant.dtChargeThrough; form.ChargeYear = Year(Tenant.dtChargeThrough); form.ChargeMonth = 
							Month(Tenant.dtChargeThrough); 
							form.ChargeDay = Day(Tenant.dtChargeThrough); dtChargeDayOne = CreateODBCDateTime(form.ChargeYear & "/" & 
							form.ChargeMonth & "/" & '01'); }
					
						NumberOfMonths = DateDiff("m", SESSION.TipsMonth, Variables.dtChargeDayOne);
						
						if (NumberOfMonths LT 0) { Month = NumberOfMonths - 1; } else { Month = NumberOfMonths; }
					</CFSCRIPT>
					
					<INPUT TYPE="Hidden" Name="Month" VALUE="#Month#">
					<CFSCRIPT>
						//Check to see if this move out is the same month and year as the move in
						//If this is true, dayscharged = difference in days.
						if ((Month(Tenant.dtRentEffective) EQ Month(Variables.dtChargeThrough)) 
						AND (Year(Tenant.dtRentEffective) EQ Year(dtChargeThrough))) {
							DaysCharged = Variables.dtChargeThrough - Tenant.dtRentEffective +1; }
						else { DaysCharged = Day(Variables.dtChargeThrough);
							if (DaysCharged LTE 30) 
							{ DaysCharged = Day(Variables.dtChargeThrough); } 
							else { DaysCharged = 30; }
						}
						if ((Month(Tenant.dtMoveIn) EQ Month(Variables.dtChargeThrough)) 
						AND (Year(Tenant.dtMoveIn) EQ Year(dtChargeThrough))) {
							DaysChargedCare = Variables.dtChargeThrough - Tenant.dtMoveIn +1; }
						else { DaysChargedCare = Day(Variables.dtChargeThrough);
							if (DaysCharged LTE 30) 
							{ DaysChargedCare = Day(Variables.dtChargeThrough); } 
							else { DaysChargedCare = 30; }
						}						
					</CFSCRIPT>
					<!---Mshah needs to change here for closed account --->
					<cfif tenant.iTenantStateCode_ID eq 4>
					 <TD> #DateFormat(TenantstateAfterAcctClosed.dtChargeThrough, "mm/dd/yyyy")# </TD>
					<cfelse>
					 <TD> #DateFormat(Tenant.dtChargeThrough, "mm/dd/yyyy")# </TD>
					 </cfif>
				</TR>
			</TABLE>
		</TD>
		<TD VALIGN="top" COLSPAN="2" STYLE="text-align: center;">
			<TABLE STYLE="width: 80%; height: 100%;">
				<TR>
					<TD COLSPAN="2" STYLE="width: 75%; font-size: 12; text-align: left;"> Daily Rate:</TD>
					<TD STYLE="text-align: right; width: 20%;">#LSCurrencyFormat(DailyRent)#</TD>
					<TD></TD>
				</TR>
				<TR>
					<TD COLSPAN="2" STYLE="width: 75%; font-size: 12; text-align: left;"> Daily Care:</TD>
					<TD STYLE="text-align: right; width: 20%;">#LSCurrencyFormat(qDailyCare.mAmount)#</TD>
					<TD></TD>
				</TR>
				<TR>
					<TD COLSPAN="2"  STYLE="font-size: 12; text-align: left;">Number of Days Charged:</TD>
					<TD STYLE="text-align: right;">#DaysCharged#</TD>
					<TD STYLE="width: 25%;"></TD>
				</TR>
				<TR>
					<TD COLSPAN="2"  STYLE="font-size: 12; text-align: left;">Number of Care Days Charged:</TD>
					<TD STYLE="text-align: right;">#DaysChargedCare#</TD>
					<TD STYLE="width: 25%;"></TD>
				</TR>
				
				<cfif tenant.iresidencytype_id is 2>
				<TR>
					<TD COLSPAN="2" STYLE="text-align: left;">Medicaid Resident CoPay:</TD>							
					<TD STYLE="text-align: right;">
						#dollarformat(qMedicaidRate.ResidentCoPay)#
					</TD>
					<TD></TD>
				</TR>				
				<cfelse>
				<TR>
					<TD COLSPAN="2" STYLE="text-align: left;">Current Month's Rent Prorated:</TD>							
					<TD STYLE="text-align: right;">
					<CFSCRIPT>
						if (Variables.DaysCharged LT 30) { ProratedRent = NumberFormat(DailyRent,"-99999999.99") * DaysCharged; 
						WriteOutPut(LSCurrencyFormat(Variables.ProratedRent)); }
						else { WriteOutPut(LSCurrencyFormat((isBlank(StandardRent.mRoomAmount,0) + IsBlank(StandardRent.mCareAmount,0)))); }
					</CFSCRIPT>
					</TD>
					<TD></TD>
				</TR>
				</cfif>
				<cfif tenant.iresidencytype_id is 2>
				<TR>
					<TD COLSPAN="2" STYLE="text-align: left;">Medicaid Resident BSF(Monthly):</TD>							
					<TD STYLE="text-align: right;">
				 	#dollarformat(qMedicaidRate.mMedicaidBSF)#
					</TD><TD></TD>
				</TR>					
				<cfelse>				
				<TR>
					<TD COLSPAN="2" STYLE="text-align: left;">Current Month's Care Prorated:</TD>							
					<TD STYLE="text-align: right;">
					<CFSCRIPT>
						if (Variables.DaysCharged LT 30) 
						{ ProratedCare = NumberFormat(qDailyCare.mAmount,"-99999999.99") * Variables.DaysCharged; 
							WriteOutPut(LSCurrencyFormat(Variables.ProratedCare)); }
						else { WriteOutPut(LSCurrencyFormat(qResidentCare.mAmount)); }
					</CFSCRIPT>
					</TD><TD></TD>
				</TR>	
				</cfif>	
			</TABLE>
		</TD>
	</TR>
</TABLE>

<CFIF Occupancy EQ 1>
	<TABLE>			
		<TR>
			<TD COLSPAN="2" STYLE="font-weight: bold; width: 25%;"> CHARGES OWED ON ACCOUNT: </TD>
			<TD COLSPAN="2" STYLE="font-weight: bold; width: 25%; text-align: right;">
				CURRENT BILLING MONTH: #DateFormat(SESSION.TIPSMonth,"mmmm yyyy")#
			</TD>
		</TR>
	</TABLE>
			
	<TABLE>
		<TR>
			<TD COLSPAN="2" STYLE="width: 50%;"><B>Past Due Balance as of #DateFormat(MoveOutInfo.dtInvoiceStart,"mm/dd/yyyy")#:</B></TD>

				<CFSET PastbalancewithLateFee = 0>
				<CFIF MoveOutInfo.PastDue NEQ 0>
					<CFSET PastbalancewithLateFee =  PastbalancewithLateFee + MoveOutInfo.PastDue>
				</CFIF>
				<CFIF LateFeeBalanceForinvoice.pastLateFeeBalance GT 0>
					<CFSET PastbalancewithLateFee =  PastbalancewithLateFee + LateFeeBalanceForinvoice.pastLateFeeBalance>
				</CFIF>
				<CFIF LateFeeAllowance.Total GT 0>
					<CFSET PastbalancewithLateFee =  PastbalancewithLateFee - LateFeeAllowance.Total>
				</CFIF>
			<TD COLSPAN=2 STYLE="text-align: right;">
				#LSCurrencyFormat(PastbalancewithLateFee)#
			</TD>
		</TR>
		<TR>
			<TD COLSPAN=4 STYLE="text-align: right;">
				<TABLE CLASS=noborder STYLE="width: 100%;">
					<TR>
						<TD STYLE="text-align: center;">
							<TABLE STYLE="width: 95%;">
								<CFIF Payments.RecordCount GT 0>
									<TR>
										<TD STYLE="width: 25%; text-align: left; background: gainsboro;"><B>Transaction Type</B></TD>
										<TD STYLE="width: 25%; text-align: center; background: gainsboro;"><B>Month of:</B></TD>
										<TD STYLE="width: 25%; text-align: left; background: gainsboro;"><B>Description</B></TD>
										<TD STYLE="width: 25%; text-align: right; background: gainsboro;"><B>Amount</B></TD>
									</TR>
								<CFELSE>
									<TR>
										<TD COLSPAN ="4" STYLE="font-weight: bold;">
											There are no transactions listed for this tenant within the last month.
										</TD>
									</TR>
								</CFIF>
						
								<CFSET StatementsTotal = 0>
								<CFLOOP Query="Payments">
									<TR>
										<TD NOWRAP STYLE="width: 25%;">#Payments.docType#</TD>
										<TD NOWRAP STYLE="width: 25%; text-align: center;">#DateFormat(Payments.docdate,"yyyymm")#</TD>
											<!--- #RIGHT(Statements.PerPost,2)#/#LEFT(Payments.PerPost,4)# --->
										<TD NOWRAP STYLE="width: 25%; text-align: left;">#Payments.docdesc#</TD>
										<TD NOWRAP STYLE="width: 25%; text-align: right;">#LSCurrencyFormat(Payments.amount)#</TD>
									</TR>
									<CFSET StatementsTotal = StatementsTotal + Payments.amount> 
								</CFLOOP>
									<TR>
										<TD>&nbsp;</TD>
										<TD>&nbsp;</TD>
										<TD STYLE="text-align: right;"> <B>Total Transactions:</B> </TD>
										<TD STYLE="text-align: right;">	<B>#LSCurrencyFormat(StatementsTotal)#</B>	</TD>
									</TR>															
							</TABLE>
						</TD>
					</TR>						
				</TABLE>
			</TD>				
		</TR>	
			
	</TABLE>
<CFELSE> 
	<CFSCRIPT>PastDue=0; Total=0; StatementsTotal=0;</CFSCRIPT> 
</CFIF>

<TABLE>
	<TR>
		<TD STYLE="text-align: center;">
			<CFIF Charges.Sum NEQ ""> <CFSET ChargeSum = #Charges.Sum#> <CFELSE> <CFSET ChargeSum = 0.00> </CFIF>		
				<TABLE CLASS="noborder" STYLE="width: 95%; background: ;">
					<TR><TD COLSPAN="100%">	<B>Current Tenant Charges:</B>	</TD></TR>								
					<TR>
						<TD NOWRAP><B><U>Period to Apply</U></B></TD>
						<TD STYLE="width: 40%;"><B><U>Description</U></B></TD>
						<TD STYLE="text-align: center;"><B><U>Amount</U></B></TD>
						<TD STYLE="text-align: center;"><B><U>Qty</U></B></TD>
						<TD STYLE="text-align: center; width: 5%;"><B><U>Price</U></B></TD>
						<TD COLSPAN=2 STYLE="text-align: left;"><B><U>Comments</U></B></TD>
					</TR>		
												
					<CFSET TOTAL = 0> 
					<CFIF CurrentCharges.mAmount NEQ '' AND CurrentCharges.iquantity NEQ ''>
					<CFLOOP QUERY = "CurrentCharges"> 
						<CFSET TOTAL = Total + (CurrentCharges.mAmount * CurrentCharges.iQuantity)>
						<TR>
							<TD STYLE="text-align: center;"> #CurrentCharges.DetailAppliesToAcctPeriod# </TD>
							<TD> #CurrentCharges.cDescription#.</TD>
							<TD NOWRAP STYLE="text-align: right;"> #LSCurrencyFormat(CurrentCharges.mAmount)# </TD>
							<TD NOWRAP STYLE="text-align: center;">	x #CurrentCharges.iQuantity# </TD>				
							<CFSET CalculatedPrice = #CurrentCharges.mAmount# * #CurrentCharges.iQuantity#>
							<TD STYLE="text-align: right;">
								$<INPUT TYPE="text" NAME="CalculatedPrice" VALUE="#NumberFormat(Variables.CalculatedPrice,"999999.99")#" 
								SIZE="7" STYLE="background: transparent; text-align: right; border: none; color: navy;" READONLY="">
							</TD>								
							<TD COLSPAN="2" STYLE="text-align: left;">#TRIM(CurrentCharges.cComments)#</TD>
						</TR>
					</CFLOOP>
					</CFIF>
<!---     					<cfif Nrfrembal gt 0>	 
						<TR>
							<TD STYLE="text-align: center;"> #CurrentCharges.DetailAppliesToAcctPeriod# </TD>
							<TD> Deferred NRF Unpaid Balance </TD>
							<TD NOWRAP STYLE="text-align: right;"> #LSCurrencyFormat(NRFrembal)# </TD>
							<TD NOWRAP STYLE="text-align: center;">	x 1 </TD>				
							<CFSET CalculatedPrice = #CurrentCharges.mAmount# * #CurrentCharges.iQuantity#>
							<TD STYLE="text-align: right;">
								$<INPUT TYPE="text" NAME="NRFRemainBalance" VALUE="#NumberFormat(Variables.NRFrembal,"999999.99")#" SIZE="7" STYLE="background: transparent; text-align: right; border: none; color: navy;" READONLY="">
							</TD>								
							<TD COLSPAN="2" STYLE="text-align: left;">&nbsp; </TD>
						</TR>	
					</cfif>	 --->   		
					<TR>
						<TD COLSPAN=2></TD>		
						<TD NOWRAP COLSPAN=4 STYLE="text-align: right; font-weight: bold;">
								
							Total Charges On Account:
							<CFSET TotalCharges = PastDue + Total + StatementsTotal>
							<!--- 05/26/2010 Project 20933 Sathya Added this for late fee to sum up in the past balance --->
							<CFIF IsDefined("LateFeeBalanceForinvoice.solomonKey")>
								<CFSET PastLateFeebal = (LateFeeBalanceForinvoice.CurrentLateFeeForinvoiceDisplay)+ 
								(LateFeeBalanceForinvoice.pastLateFeeBalance)>
							<CFELSE>
								<CFSET PastLateFeebal = 0>
							</CFIF>
							<CFSET TotalCharges = TotalCharges + PastLateFeebal>
							<!--- 05/26/2010 Project 20933 Sathya commented this line and rewrote it so that it will be easy to move over to production --->
							<!--- $<INPUT TYPE="text" NAME="TotalCharges" VALUE="#TRIM(NumberFormat(Variables.TotalCharges, "999999.99"))#" SIZE=7 STYLE="background: transparent; text-align: right; border: none; color: navy;" READONLY="">
							 --->
							$<INPUT TYPE="text" NAME="NewCurrentCharges" VALUE="#TRIM(NumberFormat(Variables.Total, "999999.99"))#" 
							SIZE=7 STYLE="background: transparent; text-align: right; border: none; color: navy;" READONLY="">
							<!--- ENd of code project 20933 --->
						</TD>									
					</TR>
				</TABLE>
			</TD>
		</TR>
	</TABLE>
<!--- 07/30/2010 Project 20933 Part-B sathya display the current late fee --->
<cfif CurrentLatefeeInfoRecord.recordcount gt 0>
<TABLE>
	<TR>
		<TD STYLE="text-align: center;">
			<TABLE CLASS="noborder" STYLE="width: 95%; background: ;">
					<TR><TD COLSPAN="100%">	<B>Current Late Fee Charges:</B>	</TD></TR>								
					<TR>
						<TD NOWRAP><B><U>Period to Apply</U></B></TD>
						<TD><B><U>Description</U></B></TD>
						<TD STYLE="text-align: center;"><B><U>Amount</U></B></TD>
						<TD STYLE="text-align: center;"><B><U>Qty</U></B></TD>
						<TD STYLE="text-align: center; width: 5%;"><B><U>Price</U></B></TD>
						<TD COLSPAN=2 STYLE="text-align: left;"><B><U>Comments</U></B></TD>						
					</TR>		
								
		<cfloop Query="CurrentLatefeeInfoRecord">
		<TR>
			<TD STYLE="text-align: left;">#CurrentLatefeeInfoRecord.cAppliesToAcctPeriod#</TD>
			<TD>Late Fee</TD>
			<TD NOWRAP STYLE="text-align: center;">#LSCurrencyFormat(CurrentLatefeeInfoRecord.mLateFeeAmount)#</TD>
			<TD NOWRAP STYLE="text-align: center;">x 1</TD>
			<TD STYLE="text-align: right;">#LSCurrencyFormat(CurrentLatefeeInfoRecord.mLateFeeAmount)#</TD>
		     <TD COLSPAN="2" STYLE="text-align: left;"> </TD>
		</TR>
		</cfloop>
		</TABLE>	
	</TD>
	</TR>
 </TABLE>	
</cfif>
<!---End of Code Project 20933 Part-B --->

		<!--- ==============================================================================
		Retrieve if Refundable Deposit has been paid
		=============================================================================== --->
		<CFQUERY NAME="RefundableList" DATASOURCE="#APPLICATION.datasource#"> exec rw.sp_MoveOutDeposits #Tenant.iTenant_ID# </CFQUERY>
	<TABLE>			
	<CFIF Occupancy EQ 1 AND RefundableList.recordcount GT 0>	
		<TR>
			<TD COLSPAN="4" STYLE="font-weight: bold;">	REFUNDABLE DEPOSITS ON ACCOUNT:	</TD>
		</TR>
		<TR>
			<TD COLSPAN="4" STYLE="text-align: center;">
				<TABLE CLASS=noborder STYLE="width: 90%;">
					<CFIF RefundableList.RecordCount GT 0>
						<TR STYLE - "font-weight: bold;">
							<TD STYLE="width: 25%;"> <B><U>Description</U></B> </TD>
							<TD STYLE="width: 25%; text-align: center;"> <B><U>Quanity</U></B> </TD>
							<TD STYLE="width: 25%; text-align: right;">	<B><U>Price</U></B> </TD>
							<TD STYLE="width: 25%; text-align: right;">	<B><U>Total</U></B> </TD>
						</TR>
					</CFIF>
					
					<CFSET TotalRefundable = 0>
					
					<CFLOOP QUERY="RefundableList">
						<TR>	
							<TD>#RefundableList.cDescription#</TD>
							<TD STYLE="text-align: center;">#RefundableList.iQuantity#</TD>
							<TD STYLE="text-align: right;">#NumberFormat(RefundableList.mAmount, "999999.99")#</TD>
							<TD STYLE="text-align: right;"> 
							<CFSET Extended = RefundableList.iQuantity * RefundableList.mAmount> #LSCurrencyFormat(Variables.Extended)# 
							</TD>
						</TR>
						<CFSET TotalRefundable = Variables.TotalRefundable + Variables.Extended>
					</CFLOOP>
				</TABLE>
			</TD>
		</TR>
		<CFELSE> <CFSET TotalRefundable=0.00> </CFIF>	
		<CFIF refundablelist.recordcount gt 0>
			<TR>
				<TD></TD> <TD></TD> <TD></TD>
				<TD STYLE="text-align: right;">
					<CFSCRIPT>
						if (IsDefined("Variables.TotalRefundables") AND TotalRefundable.mAmount NEQ "") { Refundable=Variables.TotalRefundable; } else { Refundable = 0.00; }
					</CFSCRIPT>
					$<INPUT TYPE="text" NAME="RefundableAmount" VALUE="#LSNumberFormat(Variables.TotalRefundable, "_-9999999.99")#" STYLE="background: transparent; text-align: right; border: none; color: navy;" READONLY="">
				</TD>
			</TR>
		</CFIF>
		
		<TR><TD COLSPAN=100% STYLE='border-bottom: 1px thin black;'></TD></TR>
		<TR>
			<TD COLSPAN="2" STYLE="font-weight: bold;">	MOVE OUT INVOICE TOTAL: </TD>
			<TD></TD>
			<TD STYLE="width: 10%; text-align: right; background: gainsboro;">
				<CFSET MoveOutTotal = Variables.TotalCharges - Variables.TotalRefundable>
				<CFIF LateFeeAllowance.Total GT 0>
					<CFSET MoveOutTotal =  MoveOutTotal - LateFeeAllowance.Total>
				</CFIF>				
				$<INPUT TYPE="text" NAME="MoveOutTotal" VALUE="#LSNumberFormat(Variables.MoveOutTotal, "_-9999999.99")#" STYLE="background: gainsboro; text-align: right; border: none; color: navy;" READONLY="">
			</TD>
		</TR>
	</TABLE>
	<!--- 04/27/2010 Project 20933 Sathya  late fee --->
	<!--- 04/27/2010 Project 20933 Sathya If there is a pending late fee and if this tenant state is 3 which is moved out --->
	<cfif (getTenantLateFeeRecords.recordcount gt 0) and (Tenant.iTenantStateCode_ID EQ 3)>
	<Table>
		<TR>
		<TD STYLE="text-align: center;">
				<TABLE CLASS="noborder" STYLE="width: 95%; background: ;">
					<!---07/30/2010 Project 20933 Part-B sathya commented it and rewrote it --->
				<!--- 	<TR><TD COLSPAN="100%">	<B>Pending Late Fee Charges:</B>	</TD></TR>	 --->
						<TR><TD COLSPAN="100%">	<B>List of Pending and Current Late Fee Charges to be Handled:</B>	</TD></TR>								
					<!--- End of code Project 20933 Part-B --->
					<TR>
						<TD NOWRAP><B><U>Period to Apply</U></B></TD>
						 <!--- 08/02/2010 Project 20933 Part-B sathya commented and rewrote it --->
						 <!--- <TD STYLE="width: 40%;"><B><U>Description</U></B></TD>  --->
						 <TD STYLE="width: 20%;"><B><U>Description</U></B></TD> 
						<!--- End of code Project 20933 Part-B --->
						<TD STYLE="text-align: center;"><B><U>Amount</U></B></TD>
						<TD STYLE="text-align: center;"><B><U>Qty</U></B></TD>
						<!--- 08/02/2010 Project 20933 Part-B sathya added the price --->
						<TD STYLE="text-align: center;"><B><U>Price</U></B></TD>
						<!--- End of code Project 20933 Part-B --->
						<TD STYLE="text-align: center;"><B><U>Add</U></B></TD>
						<!--- 07/20/2010 Project 20933 Part-B sathya commented this out and rewrote it --->
						<!--- <TD STYLE="text-align: center;"><B><U>Delete</U></B></TD> --->
						<TD STYLE="text-align: center;"><B><U>Waived</U></B></TD>
						<TD STYLE="text-align: center;"><B><U>Delete</U></B></TD>
						<!--- End of Code Project 20933 Part-B changes --->
						
						<!---08/11/2010 Project 20933 Part-C Sathya Added the Pursue option  --->
						<TD STYLE="text-align: center;"><B><U>Pursue</U></B></TD>
						<!--- End of Code Project 20933 Part-C changes --->
					</TR>		
												
					<CFSET LateFeeTotal = 0>
					<cfoutput>
					<CFLOOP QUERY = "getTenantLateFeeRecords">
						<CFSET LateFeeTotal = LateFeeTotal + (getTenantLateFeeRecords.mLateFeeAmount)>
						<TR>
							<TD STYLE="text-align: center;"> #getTenantLateFeeRecords.cAppliesToAcctPeriod# </TD>
							<TD> Late Fee</TD>
							<!--- <TD NOWRAP STYLE="text-align: right;"> #LSCurrencyFormat(getTenantLateFeeRecords.mLateFeeAmount)# </TD>
							 --->
							 <!--- If this is a ID has a partial payment  --->
							 <cfquery name="getPaidLateFeeAmount" dbtype="query">
								Select LateFeePayment from getPartialPayment where iInvoiceLateFee_ID = #getTenantLateFeeRecords.iInvoiceLateFee_ID#
							</cfquery>
						<cfif (getTenantLateFeeRecords.bPartialPaid eq 1) and (getPaidLateFeeAmount.recordcount gt 0)>
							<cfset PaidAmount = getPaidLateFeeAmount.LateFeePayment>
							<cfset RemainingLateFeeAmount = getTenantLateFeeRecords.mLateFeeAmount - PaidAmount>
							<TD NOWRAP STYLE="text-align: right;"> #LSCurrencyFormat(RemainingLateFeeAmount)# </TD>
						<cfelse>
							<TD NOWRAP STYLE="text-align: right;"> #LSCurrencyFormat(getTenantLateFeeRecords.mLateFeeAmount)# </TD>
						</cfif>
									 
							 <TD NOWRAP STYLE="text-align: center;">	x 1 </TD>
							
							<!--- 08/02/2010 Project 20933 Part-B sathya added the price --->
							<cfif (getTenantLateFeeRecords.bPartialPaid eq 1) and (getPaidLateFeeAmount.recordcount gt 0)>
							<cfset PaidAmount = getPaidLateFeeAmount.LateFeePayment>
							<cfset RemainingLateFeeAmount = getTenantLateFeeRecords.mLateFeeAmount - PaidAmount>
							<TD NOWRAP STYLE="text-align: right;"> #LSCurrencyFormat(RemainingLateFeeAmount)# </TD>
							<cfelse>
							<TD NOWRAP STYLE="text-align: right;"> #LSCurrencyFormat(getTenantLateFeeRecords.mLateFeeAmount)# </TD>
							</cfif>
							<!--- End of code Project 20933 Part-B --->
							
							 <!--- if partial payment was made then it will be a different amount that needs to be sent over to the invoicedetail table --->	
							<cfif (getTenantLateFeeRecords.bPartialPaid eq 1) and (getPaidLateFeeAmount.recordcount gt 0)>
								<!--- 07/20/2010 Project 20933 Part-B sathya commented this out and rewrote it --->
								<!--- <TD><input type="button" name="ADD" value=" Add " style="color:red;font-size:xx-small;" onClick="self.location.href='AddLateFeeCharges.cfm?ID=#getTenantLateFeeRecords.iTenant_ID#&detail=#getTenantLateFeeRecords.iInvoiceLateFee_ID#&invoicemaster=#MoveOutInfo.iInvoiceMaster_ID#&invoicepartialamount=#RemainingLateFeeAmount#'"></TD>		
									 <TD> Cannot Delete a Partial Payment</td>
								 --->
								 <TD><input type="button" name="ADD" value=" Paid " style="color:red;font-size:xx-small;" 
								 onClick="self.location.href='AddLateFeeCharges.cfm?ID=#getTenantLateFeeRecords.iTenant_ID#&detail=#getTenantLateFeeRecords.iInvoiceLateFee_ID#&invoicemaster=#MoveOutInfo.iInvoiceMaster_ID#&invoicepartialamount=#RemainingLateFeeAmount#'">
								 </TD>		
															 								 
								 <TD STYLE="text-align: center;"> Cannot Waive a Partial Payment</td>
								 <TD></TD>
							 <TD><input type="button" name="Pursue" value="Pursue" 
							 style="color:red;font-size:xx-small;" 
							 onClick="self.location.href='UpdatePursueLateFee.cfm?ID=#getTenantLateFeeRecords.iTenant_ID#&detail=#getTenantLateFeeRecords.iInvoiceLateFee_ID#&invoicemaster=#MoveOutInfo.iInvoiceMaster_ID#&invoiceamount=#RemainingLateFeeAmount#'"></TD>		
							<!--- End of Code Project 20933 Part-C changes  --->
							
							<cfelse>	 
								<TD><input type="button" name="ADD" value=" Paid " 
								style="color:red;font-size:xx-small;" 
								onClick="self.location.href='AddLateFeeCharges.cfm?ID=#getTenantLateFeeRecords.iTenant_ID#&detail=#getTenantLateFeeRecords.iInvoiceLateFee_ID#&invoicemaster=#MoveOutInfo.iInvoiceMaster_ID#'"></TD>		
							    <TD STYLE="text-align: center;"><input type="button" name="Waived" value="Waived" 
								style="color:red;font-size:xx-small;" 
								onClick="self.location.href='DeleteLateFeeCharge.cfm?ID=#getTenantLateFeeRecords.iTenant_ID#&detail=#getTenantLateFeeRecords.iInvoiceLateFee_ID#&invoicemaster=#MoveOutInfo.iInvoiceMaster_ID#'"></TD>		
								
								<!--- If the late fee was generated the same month that they are moving out then give the option to delete the charge --->
								<cfif getTenantLateFeeRecords.cAppliesToAcctPeriod eq MoveOutInfo.cAppliesToAcctPeriod>
								<TD><input type="button" name="Delete" value="Delete" 
								style="color:red;font-size:xx-small;"  
								onClick="self.location.href='UpdateLateFeeRowDelete.cfm?iTenant_ID=#getTenantLateFeeRecords.iTenant_ID#&iInvoiceLateFee_ID=#getTenantLateFeeRecords.iInvoiceLateFee_ID#'" 
								onmouseover="return hardhaltvalidation(MoveOutFormSummary);" 
								onfocus ="return hardhaltvalidation(MoveOutFormSummary);"></TD>
								<cfelse>
								<TD></TD>
								</cfif>
								
								<!---End of code Project 20933 Part-B  --->
								<!--- 08/11/2010 Project 20933 Part-C Sathya Added the Pursue Option --->
							 <TD><input type="button" name="Pursue" value="Pursue" style="color:red;font-size:xx-small;" onClick="self.location.href='UpdatePursueLateFee.cfm?ID=#getTenantLateFeeRecords.iTenant_ID#&detail=#getTenantLateFeeRecords.iInvoiceLateFee_ID#&invoicemaster=#MoveOutInfo.iInvoiceMaster_ID#&invoiceamount=#getTenantLateFeeRecords.mLateFeeAmount#'"></TD>		
							<!--- End of Code Project 20933 Part-C changes  --->
								
							</cfif>
						</TR>
					</CFLOOP>
				   </cfoutput>	
				 	 
				</TABLE>
			</TD>
		</TR>
	</table>
	 <!--- 07/28/2010 Project 20933 Part-B wrote this to give instructions --->
	<table>
		<tr><TD COLSPAN="100%" style="color:red">	<B>IMPORTANT INFORMATION:</B>	</TD> </tr>
		<tr>	
		  <td style="color:red;font-size: 8pt;">
			 **If you Click on Paid button, it will export the respective amount to Solomon upon Account Close. 
		   </td>
		 </tr>
		 <tr>	
		  <td style="color:red;font-size: 8pt;">
			 **If you Click on Waived button, it will export a Credit and Debit of the respective amount to Solomon upon Account Close. 
			</td>
		 </tr>
		  <tr>	
		  	<td style="color:red;font-size: 8pt;">
			**If you Click on Delete button, it will delete the record permanently and will not show up in the invoice.
			  The respective amount will not export to Solomon upon Account Close. The option of delete button
			  will only be visible when the tenant has moved out in the same period, when the late fee was generated
			  for the respective period. If the late fee has been appeared in the previous invoice sent to the tenant
			  then the option of delete button will not show.
		  </td>	
		 </tr>
		  <!--- 08/19/2010 Project 20933 Part-C Sathya Modified it for Pursue button--->
		 <tr>	
		  <td style="color:red;font-size: 8pt;">
			 **If you Click on Pursue button, Allowance for Late Fee Recovery is sent to Solomon upon Account Close. 
			</td>
		 </tr>
		 <!--- 08/19/2010 End of project 20933 Part-C --->
		 
	</table>
	<!--- End of Project 20933 Part-B --->	
	
	
	</cfif>
<!--- 04/27/2010 project 20933 sathya end of code --->
<!--- 07/01/2010 Project 50227 Sathya added this for tips promotions. This section will be visible only to the AR personal --->
	<cfif (Tenant.iTenantStateCode_ID EQ 3) and (Tenant.Promotions GT 0)>
	<TABLE>
		<TR><TD COLSPAN=100% STYLE='border-bottom: 1px thin black;'></TD></TR>
		<TR>
			<TD COLSPAN="2" STYLE="font-weight: bold; Center;">TENANT PROMOTION ACKNOWLEDGEMENT </TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" STYLE="text-align: Left;">
				Tenant Existing Promotion : <cfoutput>#PromotionName.cDescription#</cfoutput>
			</td>
		</TR>
		<cfif Tenant.bIsArAcknowledgePromotion EQ 1>
			<tr>
				<TD COLSPAN="100%" STYLE="text-align: Left;">
					An Acknowledgement by an AR Analyst has been recorded,
					 stating that they are aware that the tenant had a promotion listed.
					 
				</TD>
			</tr>
			
		<cfelse>
			<TR>
				<td style="color:red;font-size: 8pt;">In order to close the Account, AR Analyst must Acknowledge that the 
					tenant had a promotion listed. Please click on the Acknowledge button 
					to acknowledge that you are aware of the tenant existing promotion before Account close.</td>
				<td><input type="button" name="Acknowledgement" value=" Acknowledge " style="color:red;font-size:xx-small;" onClick="self.location.href='UpdateArConsentForPromotion.cfm?ID=#Tenant.iTenant_ID#'"></TD>		
									
			</TR>
		</cfif>
		
	</TABLE>
	</cfif>
<!--- End of code for Project 50227 --->
	<TABLE>	
		<TR><TD COLSPAN="100%" STYLE="font-weight: bold;"> BILLING INFORMATION: </TD></TR>	
		<TR>
			<TD COLSPAN="100%" STYLE="text-align: center;">
				<TABLE CLASS=noborder STYLE="width: 95%;">
			<cfif Payor.recordcount GT 0>
					<TR><TD STYLE="Font-weight: bold; width: 25%;">	Name / Company</TD><TD> #Payor.cFirstName# #Payor.cLastName#</TD><TD></TD><TD></TD></TR>
					<TR><TD STYLE="Font-weight: bold;">RelationShip:</TD><TD>#Payor.RelationShip#</TD><TD></TD><TD></TD></TR>
					<TR><TD STYLE="Font-weight: bold;"> Address (Line 1) </TD><TD>#Payor.cAddressLine1#</TD><TD></TD><TD></TD></TR>
					<TR><TD STYLE="Font-weight: bold;"> Address (Line 2) </TD><TD>#Payor.cAddressLine2#</TD><TD></TD><TD></TD></TR>
					<TR><TD STYLE="Font-weight: bold;"> City </TD><TD COLSPAN="3">#Payor.cCity#</TD></TR>
					<TR><TD STYLE="Font-weight: bold;"> State </TD><TD COLSPAN="3"> #Payor.cStateCode# </TD></TR>
					<TR><TD STYLE="Font-weight: bold;">	Zip Code </TD><TD COLSPAN="3"> #Payor.cZipCode# </TD></TR>
					<TR>
						<TD STYLE="Font-weight: bold;">	Home Phone:</TD>
						<TD>
						<CFSCRIPT>
							if (Payor.cPhoneNumber1 NEQ "") { WriteOutPut( '(' & LEFT(Payor.cPhoneNumber1, 3) &') '&  MID(Payor.cPhoneNumber1, 4, 3) &'-'& RIGHT(Payor.cPhoneNumber1, 4) ); } 
							else {WriteOutPut('&nbsp;'); }
						</CFSCRIPT>
						</TD><TD></TD><TD></TD>	
					</TR>
					
					<TR>
						<TD STYLE = "Font-weight: bold;"> Message Phone: </TD>
						<TD>
						<CFSCRIPT>
							if (Payor.cPhoneNumber2 NEQ "") { WriteOutPut( '(' & LEFT(Payor.cPhoneNumber2, 3) &') '&  MID(Payor.cPhoneNumber2, 4, 3) &'-'& RIGHT(Payor.cPhoneNumber2, 4) ); } 
							else {WriteOutPut('&nbsp;'); }
						</CFSCRIPT>	
						</TD><TD></TD><TD></TD>	
					</TR>
					<TR>
						<TD>
							<CFIF Payor.cComments NEQ ""><CFSET cComments = #Payor.cComments#><CFELSE><CFSET cComments = ""></CFIF>
							<B>Comments:</B>
						</TD>
						<TD> #Payor.cComments# </TD><TD></TD><TD></TD>
					</TR>
			<cfelse>
			  <CFQUERY NAME="Payor1" DATASOURCE="#APPLICATION.datasource#">
					select iTenant_id,bIsPayer, cFirstName,cLastName,cSSN,cOutsidePhoneNumber1,cOutsidePhoneNumber2,cOutsideAddressLine1,cOutsideAddressLine2,cOutsideCity,cOutsideStateCode,cOutsideZipCode
 						FROM Tenant with (NOLOCK)
						WHERE dtrowdeleted is null AND (iTenant_ID = #url.ID# AND cSolomonKey = '#trim(Tenant.cSolomonKey)#')

			 </CFQUERY>
			      <TR><td></td><TD STYLE="Font-weight: bold; width: 25%; font-style:oblique;"><span style="color:##CC66CC"> Tenant is the Payor</span></TD></TR>
			     <TR><TD STYLE="Font-weight: bold; width: 25%;">	Name / Company</TD><TD> #Payor1.cFirstName# #Payor1.cLastName#</TD><TD></TD><TD></TD></TR>
					
					<TR><TD STYLE="Font-weight: bold;"> Address (Line 1) </TD><TD>#Payor1.cOutsideAddressLine1#</TD><TD></TD><TD></TD></TR>
					<TR><TD STYLE="Font-weight: bold;"> Address (Line 2) </TD><TD>#Payor1.cOutsideAddressLine2#</TD><TD></TD><TD></TD></TR>
					<TR><TD STYLE="Font-weight: bold;"> City </TD><TD COLSPAN="3">#Payor1.cOutsideCity#</TD></TR>
					<TR><TD STYLE="Font-weight: bold;"> State </TD><TD COLSPAN="3"> #Payor1.cOutsideStateCode# </TD></TR>
					<TR><TD STYLE="Font-weight: bold;">	Zip Code </TD><TD COLSPAN="3"> #Payor1.cOutsideZipCode# </TD></TR>
					<TR>
						<TD STYLE="Font-weight: bold;">	Home Phone:</TD>
						<TD>
						<CFSCRIPT>
							if (Payor1.cOutsidePhoneNumber1 NEQ "") { WriteOutPut( '(' & LEFT(Payor1.cOutsidePhoneNumber1, 3) &') '&  MID(Payor1.cOutsidePhoneNumber1, 4, 3) &'-'& RIGHT(Payor1.cOutsidePhoneNumber1, 4) ); } 
							else {WriteOutPut('&nbsp;'); }
						</CFSCRIPT>
						</TD><TD></TD><TD></TD>	
					</TR>
					
					<TR>
						<TD STYLE = "Font-weight: bold;"> Message Phone: </TD>
						<TD>
						<CFSCRIPT>
							if (Payor1.cOutsidePhoneNumber2 NEQ "") { WriteOutPut( '(' & LEFT(Payor1.cOutsidePhoneNumber2, 3) &') '&  MID(Payor1.cOutsidePhoneNumber2, 4, 3) &'-'& RIGHT(Payor1.cOutsidePhoneNumber2, 4) ); } 
							else {WriteOutPut('&nbsp;'); }
						</CFSCRIPT>	
						</TD><TD></TD><TD></TD>	
					</TR>
					
			</cfif>					
				</TABLE>
			</TD>
		</TR>	
	
		<TR>
			<TD COLSPAN="100%" STYLE="text-align: left; background: gainsboro;">
				<CFSCRIPT>if (MoveOutInfo.InvoiceComments NEQ "") {InvoiceComments = MoveOutInfo.InvoiceComments;}else{InvoiceComments = '';}</CFSCRIPT>
				<!--- Program Director / Accounting Notes Changes 04/18/2002 for consistency--->
				<B>Past Due Balance Description</B>: <BR> #Variables.InvoiceComments#
			</TD>
		</TR>	
	</TABLE>
 
  <CFIF Tenant.iTenantStateCode_ID EQ 2 AND (Now() GTE Tenant.dtMoveOut)> 
	<TABLE>
		<!--- 51267 - MO Codes - RTS - 3/31/2010 --->
		<TR>
			<TD COLSPAN="100%" STYLE="text-align: center;">
			Have you reviewed the Move Out Reasons and Location:&nbsp;
			Yes<input type="radio" value="1" Name="TMORLreview" onclick="document.MoveOutFormSummary.TMORLreview.value=this.value">
			No<input type="radio" value="0" CHECKED Name="TMORLreview" onclick="document.MoveOutFormSummary.TMORLreview.value=this.value">
			</TD>
		</TR>
		<!--- end 51267 --->
		<TR>
			<TD COLSPAN="100%" STYLE="text-align: center;">
				<INPUT TYPE="BUTTON" NAME="Finalize" VALUE="Finalize Move Out" STYLE="color: green;" onmouseover="return checkMO();"
				onClick="document.MoveOutFormSummary.action='PDFinalize.cfm?ID=#url.ID#&ShowBtn=#ShowBtn#'; submit();">
			</TD>
		</TR>
	</TABLE>
  <CFELSEIF Now() LTE Tenant.dtMoveOut>
	<TABLE><TR><TD COLSPAN="100%" STYLE="text-align: center;"> This Move Out may not be Finalized until <I><B>after</B></I> the Physical Move Out Date. </TD></TR></TABLE>
</CFIF> 

</FORM>
</CFOUTPUT>

<BR>
<!---<CFIF ShowBtn>--->
	<A HREF="../MainMenu.cfm" STYLE="Font-size: 18;">Click Here to Go Back To TIPS Summary.</A>
<!---</CFIF>--->
<!--- ==============================================================================
Include Intranet Footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">
