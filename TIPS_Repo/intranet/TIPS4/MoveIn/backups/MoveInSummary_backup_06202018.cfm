<!----------------------------------------------------------------------------------------------
| DESCRIPTION - MoveInSummary.cfm                                                              |
|----------------------------------------------------------------------------------------------|
| Show Final move in data and allow finalization                                               |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by: 		MoveInFormInsert.cfm, MoveInFormUpdate.cfm                                 |
| Calls/Submits:	FinalizeMoveIn.cfm														   |		
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| puendia    | 10/01/2001 | Original Authorship		                                           |
|            |            | upon if there is a person in the room. (ie. regardless             |
|            |            | of the solomonkey or linked status)                                |
| puendia    | 04/15/2002 | Changed move in process to pass original invoicenumber via url.    |
|            | 04/17/2002 | Removed no longer needed commented code                            |
| sdavidson  | 04/22/2002 | Added check for companion suite when determining occupancy         |
| mlaw       | 11/15/2005 | Comment the future Date Check                                      |
|MLAW        | 08/17/2006 | Make sure the charges are assigned to correct Product Line ID      |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
|Sfarmer     | 09/18/2013 | 102919 - Revise NRF approval process                               |
 --- ------------------------------------------------------------------------------------_-----|
| Sfarmer   | 10/18/2013  |Proj. 102481 removed Walnut db and tables Census & Leadtracking     |
|S Farmer   | 05/20/2014  | 116824 - Move-In update - Allow ED to adjust BSF rate              |
|S Farmer   | 05/20/2014  | 116824 - Phase 2 Allow different move-in and rent-effective dates  |
|           |             | allow respite to adjust BSF rates                                  |
|S Farmer    | 08/20/2014 | 116824 - back-off different move-in rent-effective dates           |
|            |            | allow adjustment of rates by all regions                           |
|S Farmer    | 09/08/2014 | 116824       | Allow all houses edit BSF and Community Fee Rates   |
|S Farmer    | 2015-01-12 | 116824   Final Move-in Enhancements                                |
|S Farmer    | 2015-07-31 | Updates for Pinicon Place with monthly charges                     |
|sfarmer     | 2017-05-09 | 'move out date' changed to 'physical move out date'                |
|mstriegel   | 2018-05-03 | Logic to fix inocorrect amount total                               |
----------------------------------------------------------------------------------------------->



<cfparam name="secondresident" default="">
<cfif isdefined("url.stmp")>
	<cfscript>time=CreateDateTime(MID(url.stmp,5,2),Left(url.stmp,2),Mid(url.stmp,3,2),Mid(url.stmp,7,2),Mid(url.stmp,9,2),Mid(url.stmp,11,2));</cfscript>
	<cfif datediff('n', time, now()) gt 60><CFLOCATION URL='../MainMenu.cfm' ADDTOKEN="yes"> </cfif>
</cfif>
 
<!--- =============================================================================================
Include Javascript code for only allowing:
Numbers	:	USE onKeyUp = "this.value=Numbers(this.value)"
Letters:	USE onKeyUp = "this.value=Letters(this.value)"
============================================================================================= --->
<cfinclude template="../Shared/JavaScript/ResrictInput.cfm">

<script> function redirect() { window.location = "../Registration/Registration.cfm";} </script>

<!--- Include Intranet Header --->
<cfinclude template="../../header.cfm">

<!--- Retreive list of State Codes --->
<cfinclude template="../Shared/Queries/StateCodes.cfm">
<cfinclude template="../Shared/Queries/PhoneType.cfm">
<cfinclude template="../Shared/Queries/Relation.cfm">
<cfinclude template="../Shared/Queries/TenantInformation.cfm">


<cfif TenantInfo.itenantstatecode_id eq 2>
<cflocation url='../MainMenu.cfm' ADDTOKEN="yes">
</cfif>

<!--- Set variable for timestamp to record corresponding times for transactions --->
<cfquery name="GetDate" datasource="#application.datasource#">
	select getDate() as Stamp
</cfquery>
<cfset TimeStamp=CREATEODBCDateTime(GetDate.Stamp)>


	
<cfif isDefined("tenantinfo.itenant_id")>
<!--- check for active assesssment added 3/28/05 by Paul Buendia --->
<cfquery name="qAssessmentCheck" datasource="tips4">
	select am.iassessmenttoolmaster_id
	from tenant t
<!--- 	left join #Application.LeadTrackingDBServer#.LeadTracking.dbo.residentstate rs on t.itenant_id = rs.itenant_id and rs.dtrowdeleted is null  --->	

<!---  	left join assessmenttoolmaster am on (am.itenant_id = t.itenant_id or am.iresident_id = rs.iresident_id)  --->
 	left join assessmenttoolmaster am on  am.itenant_id = t.itenant_id  
			and am.dtrowdeleted is null and am.bbillingactive is not null
	where t.itenant_id = #trim(tenantinfo.itenant_id)#
</cfquery>
</cfif>

<cfif NOT IsDefined("url.id") and NOT IsDefined("url.mid")
	or (	(IsDefined("url.id") and url.ID eq "") or (IsDefined("url.mid") and url.mid eq "")	)>
	<center style='color:red;font-size:medium;'>
		An error has been detected and a message has been sent to the web administrator.<br/>
		If a shorcut has been used to reach this page please refrain from using the shortcut.<br/>
		You will be redirected in 10 seconds.<br/>
	</center>
	
	<cfmail type="HTML" FROM="MIMessage@alcco.com" TO="CFDevelopers@alcco.com" SUBJECT="#SESSION.HouseName# MI Summary">
		Fullname = #SESSION.FULLNAME#<br/>
		Referer = #HTTP.Referer#<br/>
		fieldnames = <cfif isDefined("form.fieldnames")><cfloop INDEX=I LIST="#form.fieldnames#">#I# == #Evaluate('form.' & I )#<br/></cfloop></cfif>
		<br/>url = <cfif (IsStruct("url") and YesNoFormat(StructIsEmpty(url)) eq 'NO')> <cfloop collection="#url#" ITEM="I">#I# == #Evaulate(I)#<br/></cfloop> </cfif>
		<br/>template = <cfif IsDefined("query_STRING")>#Query_String#</cfif>
	</cfmail>
	
	<script>
		function shortcut(){ location.href='../mainmenu.cfm'; }	setTimeout("shortcut();",10000);
	</script>
	<cfabort>
</cfif>
<script>
	function showHelp(){
 		window.open("TIPS-Move-In-Process.pdf");
	}
</script>
<!--- Retrieve the Move In Invoice Information --->
<cfquery name="MoveInInvoice" datasource="#application.datasource#">
	select * from InvoiceMaster where dtRowDeleted is null and iInvoiceMaster_ID = #url.MID#
</cfquery>

<!--- Throw Error Message if an invoice master record can not be found --->
<cfif MoveInInvoice.RecordCount eq 0 and TenantInfo.iResidencyType_ID neq 2>
	<B style="font-size: 18;">
		<br/><br/>There is no move-in information available for this resident.<br/> (This  is Pre-TIPS 4.0)</B><br/><br/>
	<a href="../MainMenu.cfm" style="font-size: 18;">	Click Here to Continue </a>
	<cfabort>
</cfif>

<cfquery name="FindOccupancy" datasource="#application.datasource#">
	select T.iTenant_ID
		,iResidencyType_ID
		,ST.cDescription as Level
		,TS.dtMoveIn
		,TS.dtMoveOut
		,TS.iSPoints
		,ts.iMonthsDeferred as PaymentMonths
		,ts.mBaseNrf as NRFBase
		,ts.mAdjNrf as NRFAdj
	from AptAddress AD
	join TenantState TS on (TS.iAptAddress_ID = AD.iAptAddress_ID and TS.dtRowDeleted is null)
	join Tenant T on (T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null)
	join SLevelType ST on (ST.cSLevelTypeSet = T.cSLevelTypeSet and TS.iSPoints between ST.iSPointsMin and ST.iSPointsMax)		
	where AD.dtRowDeleted is null and TS.iTenantStateCode_ID = 2
	and AD.iAptAddress_ID = #TenantInfo.iAptAddress_ID# and TS.iTenant_ID <> #TenantInfo.iTenant_ID#
</cfquery>

<cfif FindOccupancy.iResidencyType_ID is 2>
	<cfquery name="qryMedicaidRate" datasource="#application.datasource#">
		Select mStateMedicaidAmt_BSF_Daily,mStateMedicaidAmt_BSF_Monthly
		 from HouseMedicaid 
		WHERE	 ihouse_id =#SESSION.qSelectedHouse.iHouse_ID#
	</cfquery>
</cfif>

<cfquery name="qryMedicaidDate" DATASOURCE = "#APPLICATION.datasource#">
select distinct inv.cappliestoacctperiod
from invoicedetail inv
join invoicemaster im on inv.iinvoicemaster_id = im.iinvoicemaster_id
	and im.csolomonkey = '#tenantinfo.csolomonkey#'
where bMoveininvoice = 1 and im.dtrowdeleted is null 
and inv.dtrowdeleted is null
</cfquery>


<cfloop query="qryMedicaidDate"    > 

<cfquery name="qrySelMedicaidCoPay" DATASOURCE = "#APPLICATION.datasource#">
	Select sum(inv.mamount) from invoicedetail inv
join invoicemaster im on inv.iinvoicemaster_id = im.iinvoicemaster_id
	and im.csolomonkey = '#tenantinfo.csolomonkey#'
where bMoveininvoice = 1 and im.dtrowdeleted is null 
and inv.cappliestoacctperiod = '#qryMedicaidDate.cappliestoacctperiod#'
and inv.dtrowdeleted is null and im.dtrowdeleted is null
and inv.ichargetype_id in (1661)
</cfquery>
<cfquery name="qrySelMedicaidBSF" DATASOURCE = "#APPLICATION.datasource#">
	Select sum(inv.mamount) from invoicedetail inv
join invoicemaster im on inv.iinvoicemaster_id = im.iinvoicemaster_id
	and im.csolomonkey = '#tenantinfo.csolomonkey#'
where bMoveininvoice = 1 and im.dtrowdeleted is null 
and inv.cappliestoacctperiod = '#qryMedicaidDate.cappliestoacctperiod#'
and inv.dtrowdeleted is null and im.dtrowdeleted is null
and inv.ichargetype_id in (31)
</cfquery>
<cfquery name="qrySelMedicaidState" DATASOURCE = "#APPLICATION.datasource#">
	Select iinvoicedetail_id , mamount,iquantity from invoicedetail inv
join invoicemaster im on inv.iinvoicemaster_id = im.iinvoicemaster_id
	and im.csolomonkey = '#tenantinfo.csolomonkey#'
where bMoveininvoice = 1 and im.dtrowdeleted is null
	and inv.cappliestoacctperiod = '#qryMedicaidDate.cappliestoacctperiod#'
	and inv.dtrowdeleted is null 
	and im.dtrowdeleted is null
	and inv.ichargetype_id in (8)
</cfquery>
<cfquery name="qrySumMedicaidState" DATASOURCE = "#APPLICATION.datasource#">
	Select sum (mamount) as SumMedicaidState
		from invoicedetail inv
		join invoicemaster im on inv.iinvoicemaster_id = im.iinvoicemaster_id
		and im.csolomonkey = '#tenantinfo.csolomonkey#'
		where bMoveininvoice = 1 and im.dtrowdeleted is null
		and inv.dtrowdeleted is null 
		and im.dtrowdeleted is null
		and inv.ichargetype_id in (8)
</cfquery>

</cfloop>


	<cfif IsDefined('CommFeePayment') and CommFeePayment is not ''>
		<cfquery name="updCommPaymnt"  DATASOURCE = "#APPLICATION.datasource#">
		Update tenantstate
		set iMonthsDeferred = CommFeePayment
		where itenant_id = #form.iTenant_ID#
		</cfquery>
		
		<cfif CommFeePayment gt 1>
			<cfquery name="qChargeID"  DATASOURCE='#APPLICATION.datasource#'>
			Select cdescription from chargetype where ichargetype_id = 1741
			</cfquery>
			<cfif tenantinfo.mAdjNRF is not ''>
				<cfset NRFAmt = tenantinfo.mAdjNRF>
			<cfelse>
				<cfset  NRFAmt = tenantinfo.mBaseNRF>
			</cfif>
			
			<cfif CommFeePayment is 2>
				<cfset CommFeePaymntAmt =    (Round((NRFAmt/2) * 100) / 100) >
			<cfelse>
				<cfset CommFeePaymntAmt =  (Round((NRFAmt/3) * 100) / 100) >		
			</cfif>
			
			<CFQUERY NAME='qInsertRecurring' DATASOURCE='#APPLICATION.datasource#'>
				INSERT INTO RecurringCharge
				( iTenant_ID, iCharge_ID, dtEffectiveStart, dtEffectiveEnd, iQuantity, cDescription, 
				mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart)
				VALUES
				( #TenantInfo.iTenant_id# 
					,1741 
					,getdate() 
					,DateAdd("yyyy",10,getdate()) 
					,1 
					,'#TRIM(qChargeID.cDescription)#' 
					,#CommFeePaymntAmt#
					,'2Recurring Comm Fee created at move in' 
					,#CreateODBCDateTime(SESSION.AcctStamp)# 
					,#SESSION.USERID# 
					,getdate() )
			</CFQUERY> 	
			<br />INSERT INTO RecurringCharge 1741<br />
		</cfif>	
	</cfif>	
<CFQUERY NAME = "qryNrfPymnt" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*, (T.cFirstName + ' ' + T.cLastName) as FullName
	, RT.cDescription
	, TS.bNRFPend
	, ts.cSecDepCommFee
	,ts.iMonthsDeferred as PaymentMonths
	, ts.mBaseNrf as NRFBase
	, ts.mAdjNrf as NRFAdj
	FROM	TENANT	T
	JOIN 	TenantState TS ON T.iTenant_ID = TS.iTenant_ID
	JOIN 	AptAddress AD ON AD.iAptAddress_ID = TS.iAptAddress_ID
	JOIN 	ResidencyType RT ON RT.iResidencyType_ID = TS.iResidencyType_ID
	WHERE	T.iTenant_ID = #TenantInfo.iTenant_ID#
</CFQUERY>		
	<cfif qryNrfPymnt.PaymentMonths is 0 and qryNrfPymnt.NRFBase gt 0 and qryNrfPymnt.NRFAdj is ''>
		<cfquery name="updNbrPymnt" datasource = "#APPLICATION.datasource#">
			UPDATE	TenantState
				SET	iMonthsDeferred = 1 
			WHERE	iTenant_ID = #TenantInfo.iTenant_ID#
		</CFQUERY>
	</cfif>
	
<cfscript> if (FindOccupancy.RecordCount gt 0) { Occupancy = 2; } else {Occupancy = 1;} </cfscript>

<!--- Retrieve any solomontransactions --->
<cfquery name="qGetSolomonTransactions" datasource="#application.datasource#">
	select * from rw.vw_Get_Trx where custid = '#TenantInfo.cSolomonKey#'
	and	User7 >= '#MoveInInvoice.dtInvoiceStart#'
	and	User7 <= <cfif MoveInInvoice.dtInvoiceEnd neq ""> '#MoveInInvoice.dtInvoiceEnd#' <cfelse> getDate() </cfif>
</cfquery>

<cfif qGetSolomonTransactions.recordcount gt 0 and Occupancy eq 1>
	<!--- Retrieve total of  solomontransactions --->
	<cfquery name="qGetSolomonTrxTotal" datasource="#application.datasource#">
		select sum(amount) as total from rw.vw_Get_Trx
		where custid = '#TenantInfo.cSolomonKey#' and User7 >= '#MoveInInvoice.dtInvoiceStart#'
		and User7 <= <cfif MoveInInvoice.dtInvoiceEnd neq ""> '#MoveInInvoice.dtInvoiceEnd#' <cfelse> getDate() </cfif>
	</cfquery>
	<cfset TransactionsTotal = qGetSolomonTrxTotal.Total>
<cfelse> <cfset TransactionsTotal = 0.00> </cfif>

<cfquery name='qHistSet' datasource="#application.datasource#">
	select distinct tendtRowStart, cSLevelTypeSet, tendtRowEnd, tendtRowDeleted
	from rw.vw_tenant_history_with_state
	where iTenant_ID = #TenantInfo.iTenant_ID#
	and	'#TenantInfo.dtMoveIn#' between tenDtRowStart and tendtRowEnd 
	order by tenDtRowStart desc
</cfquery>

<!--- Retrieve the service level according to the service points --->
<cfquery name="GetSLevel" datasource="#application.datasource#">
	select * from SLevelType where dtRowDeleted is null
	and	iSPointsMin <= #TenantInfo.iSPoints# and iSPointsMax >= #TenantInfo.iSPoints#
	<cfif qHistSet.RecordCount gt 0 and qHistSet.cSLevelTypeSet neq ''>
		and cSLevelTypeSet = #qHistSet.cSLevelTypeSet#
	<cfelseIF TenantInfo.cSLevelTypeSet neq "" or TenantInfo.cSLevelTypeSet neq 0>
		and cSLevelTypeSet = #TenantInfo.cSLevelTypeSet#
	<cfelse>
 and cSLevelTypeSet = #SESSION.cSLevelTypeSet#
	</cfif>
</cfquery>

<!--- Retrieve Credit Entries from the Invoice Detail  --->
<cfquery name="Credits" datasource="#application.datasource#">
	select	*, inv.cDescription as cDescription
	from InvoiceDetail inv
	join InvoiceMaster im	on (inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID and im.dtRowDeleted is null)
	join ChargeType ct on (ct.iChargeType_ID = inv.iChargeType_ID and ct.dtRowDeleted is null)
	where iTenant_ID = #url.ID#
	and	im.iInvoiceMaster_ID = <cfif MoveInInvoice.iInvoiceMaster_ID neq "">#MoveInInvoice.iInvoiceMaster_ID#<cfelse>#url.MID#</cfif>
	and	inv.dtRowDeleted is null
	and	(ct.bIsMedicaid is null or (ct.bIsMedicaid is not null and ct.bIsRent is not null))
	and	ct.bIsDeposit is null and	(inv.iRowStartUser_ID is null or inv.iRowStartUser_ID <> 0)
	and inv.iChargeType_ID <> 1741
</cfquery>

<!--- Check to see if any house specific deposits exist for the house --->
<cfquery name="qDepositCheck" datasource="#application.datasource#">
	select count(*) as count from Charges C
	join ChargeType ct on (ct.iChargeType_ID = C.iChargeType_ID and ct.dtRowDeleted is null)
	where C.dtRowDeleted is null and ct.bIsDeposit is not null and iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</cfquery>

<cfif qDepositCheck.count gt 0> <cfset HouseSpecific=1><cfelse><cfset HouseSpecific=0></cfif>

<!--- Retreive Refundable Deposits  --->
<cfquery name="Refundable" datasource="#application.datasource#">
	select	distinct inv.*
	from InvoiceDetail inv
	join ChargeType ct on (ct.iChargetype_ID = inv.iChargeType_ID and ct.dtRowDeleted is null)
	join Charges C on (C.iChargeType_ID = ct.iChargeType_ID and C.dtRowDeleted is null)
	join Tenant T on (T.iTenant_ID = inv.iTenant_ID and T.dtRowDeleted is null)
	where inv.dtRowDeleted is null
	<cfif HouseSpecific eq 1> 
		and T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# 
	<cfelse>
		and C.iHouse_ID is null	
	</cfif>	
	and ct.bIsDeposit is not null and ct.bIsRefundable is not null 
	and inv.iTenant_ID = #TenantInfo.iTenant_ID#
	and inv.dtrowdeleted is null
</cfquery>

<cfquery name="Fees" datasource="#application.datasource#">	
	select	distinct inv.*, inv.mAmount as mAmount
	from InvoiceDetail inv
	join ChargeType ct on (ct.iChargetype_ID = inv.iChargeType_ID and ct.dtRowDeleted is null)
	join Charges C on (C.iChargeType_ID = ct.iChargeType_ID and C.dtRowDeleted is null)
	join Tenant T on (T.iTenant_ID = inv.iTenant_ID and T.dtRowDeleted is null)
	join InvoiceMaster im on (im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID 
	and im.dtRowDeleted is null)
	where inv.dtRowDeleted is null
	<cfif HouseSpecific eq 1> 
		and T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# 
	<cfelse> 
		and C.iHouse_ID is null
	 </cfif>
	and ct.bIsDeposit is not null and ct.bIsRefundable is null 
	and inv.iTenant_ID = #TenantInfo.iTenant_ID#
</cfquery>

<cfquery name="CheckCompanionFlag" datasource="#application.datasource#">
	select	bIsCompanionSuite from AptAddress AD
	join AptType AT on (AD.iAptType_ID = AT.iAptType_ID and AT.dtRowDeleted is NULL)
	where AD.dtRowDeleted is null and AD.iAptAddress_ID = #TenantInfo.iAptAddress_ID#
</cfquery>

<cfif CheckCompanionFlag.bIsCompanionSuite eq 1> <cfset Occupancy = 1> </cfif>
	<!--- MLAW 08/17/2006 Add iProductline_ID filter --->
	<cfquery name="StandardRent" datasource="#application.datasource#">
		<cfif Occupancy eq 1>
			select * from Charges C
			join ChargeType ct on (ct.iChargeType_ID = C.iChargeType_ID and ct.dtRowDeleted is null
					and ct.bIsRent is not null and ct.bIsMedicaid is null and ct.bIsDiscount is null
					and ct.bIsRentAdjustment is null)
			where C.dtRowDeleted is null and C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			and C.iResidencyType_ID = 1 and C.iAptType_ID = #TenantInfo.iAptType_ID#
			<!--- and ct.bSLevelType_ID is null  --->
			and ct.bIsDaily is null and C.iOccupancyPosition = 1
			<cfif TenantInfo.cChargeSet neq ""> and C.cChargeSet = '#TenantInfo.cChargeSet#' <cfelse> and C.cChargeSet is null </cfif>
			and dtEffectiveStart <= '#TenantInfo.dtMoveIn#' and dtEffectiveEnd >= '#TenantInfo.dtMoveIn#'
			and	c.iproductline_id = #TenantInfo.iProductLine_ID#
			order by C.dtRowStart Desc				
		<cfelse>
			select * from 	Charges C
			join ChargeType ct on C.iChargeType_ID = ct.iChargeType_ID
			where C.dtRowDeleted is null and ct.dtRowDeleted is null 
			and iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			and C.iResidencyType_ID = #TenantInfo.iResidencyType_ID# and iOccupancyPosition = 2
			<cfif TenantInfo.iResidencyType_ID neq 3>
				and ct.bIsDaily is null
				<!--- and 	iSLevelType_ID = #GetSLevel.iSLevelType_ID# --->
			</cfif>
			and dtEffectiveStart <= '#TenantInfo.dtMoveIn#' 
			and dtEffectiveEnd >= '#TenantInfo.dtMoveIn#'
			and	c.iproductline_id = #TenantInfo.iProductLine_ID#
			order by C.dtRowStart Desc
		</cfif>	
	</cfquery>

	<cfif StandardRent.RecordCount eq '0'>
		<cfquery name="StandardRent" datasource="#application.datasource#">
			select C.iChargeType_ID, C.iQuantity, C.cDescription, C.mAmount
			from Charges	C
			join 	ResidencyTYPE RT on C.iResidencyType_ID = RT.iResidencyType_ID
			<!--- left outer join SLevelType ST on C.iSLevelType_ID = ST.iSLevelType_ID --->
			join 	ChargeType ct	 on ct.iChargeType_ID = C.iChargeType_ID
			where C.dtRowDeleted is null and ct.dtRowDeleted is null 
			and IsNull(C.iOccupancyPosition,1) = #Occupancy#	
			<cfif TenantInfo.cChargeSet neq ""> 
			and C.cChargeSet = '#TenantInfo.cChargeSet#' 
			<cfelse> 
			and C.cChargeSet is null 
			</cfif>
			<cfif TenantInfo.iResidencyType_ID neq 3>
				<cfif Occupancy neq 2> 
					and C.iAptType_ID = #TenantInfo.iAptType_ID# 
				<cfelse> 
					and C.iAptType_ID is null 
				</cfif>
				<!--- and C.iSLevelType_ID = #GetSLevel.iSLevelType_ID#  --->
				and ct.bIsDaily is null
			</cfif>
			and C.iResidencyType_ID = #TenantInfo.iResidencyType_ID# 
			and C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			and ( (iCharge_id = 
			(select top 1 iCharge_id from rw.vw_Charges_history 
			where ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
				 and'#TenantInfo.dtMoveIn#' between dtrowstart and isNull(dtrowend,getdate())
				and iChargeType_ID = C.iChargeType_ID and iAptType_ID = C.iAptType_ID
				<!---  and cSLevelDescription = C.cSLevelDescription --->
				 <!--- and iSLevelType_ID = #GetSLevel.iSLevelType_ID# ---> 
				 and dtRowDeleted is null)
				) 
				or  (dtEffectiveStart <= '#TenantInfo.dtMoveIn#' 
				and dtEffectiveEnd >= '#TenantInfo.dtMoveIn#') ) 
				<!--- 25575 rts - 6/30/2010 - add apt type --->
			<cfif TenantInfo.iResidencyType_ID eq 3>
				and c.iAptType_ID = #TenantInfo.iAptType_ID#
			</cfif>
			<!--- end 25575 --->
			and	c.iproductline_id = #TenantInfo.iProductLine_ID#
			order by C.dtRowStart Desc
		</cfquery>
	</cfif>

	<cfquery name="DailyRent" datasource="#application.datasource#">
		<cfif tenantinfo.iresidencytype_id is 5>
				select	C.iChargeType_ID, C.iQuantity, C.cDescription, C.mAmount
			from Charges	C
			join ResidencyTYPE RT	ON	C.iResidencyType_ID = RT.iResidencyType_ID
			LEFT join SLevelType ST  on C.iSLevelType_ID = ST.iSLevelType_ID
			join ChargeType ct on ct.iChargeType_ID = C.iChargeType_ID
			where C.dtRowDeleted is null and ct.dtRowDeleted is null
				and C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
				and C.iResidencyType_ID = #TenantInfo.iResidencyType_ID#
				<cfif TenantInfo.cChargeSet neq ""> 
					and C.cChargeSet = '#TenantInfo.cChargeSet#' 
				<cfelse> 
					and C.cChargeSet is null
				</cfif>
				and C.iAptType_ID = #TenantInfo.iAptType_ID#
				and C.iSLevelType_ID is null 
				and dtEffectiveStart <= '#TenantInfo.dtMoveIn#' 
				and dtEffectiveEnd >= '#TenantInfo.dtMoveIn#'
				and	c.iproductline_id = #TenantInfo.iProductLine_ID#
			order by c.dtRowStart desc
		<cfelseif Occupancy eq 1>
			select	C.iChargeType_ID, C.iQuantity, C.cDescription, C.mAmount
			from Charges	C
			join ResidencyTYPE RT	ON	C.iResidencyType_ID = RT.iResidencyType_ID
			LEFT join SLevelType ST  on C.iSLevelType_ID = ST.iSLevelType_ID
			join ChargeType ct on ct.iChargeType_ID = C.iChargeType_ID
			where C.dtRowDeleted is null and ct.dtRowDeleted is null
			and ct.bIsDaily is not null and C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			and C.iResidencyType_ID = #TenantInfo.iResidencyType_ID#
			<cfif TenantInfo.cChargeSet neq ""> 
			and C.cChargeSet = '#TenantInfo.cChargeSet#' 
			<cfelse> 
			and C.cChargeSet is null
			</cfif>
			and C.iAptType_ID = #TenantInfo.iAptType_ID#
			and C.iSLevelType_ID is null 
			and dtEffectiveStart <= '#TenantInfo.dtMoveIn#' 
			and dtEffectiveEnd >= '#TenantInfo.dtMoveIn#'
			and	c.iproductline_id = #TenantInfo.iProductLine_ID#
			order by c.dtRowStart desc			
		<cfelse>
			select *
			from Charges C
			join ChargeType ct	ON C.iChargeType_ID = ct.iChargeType_ID
			where C.dtRowDeleted is null and ct.dtRowDeleted is null
			and iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# and ct.bIsDaily is not null
			and iOccupancyPosition = 2 and dtEffectiveStart <= '#TenantInfo.dtMoveIn#' 
			and dtEffectiveEnd >= '#TenantInfo.dtMoveIn#'
			and	c.iproductline_id = #TenantInfo.iProductLine_ID#
			order by c.dtRowStart desc
		</cfif>
</cfquery>

<cfif DailyRent.RecordCount eq 0>
		<cfquery name="DailyRent" datasource="#application.datasource#">
		<cfif Occupancy eq 1>
			select C.iChargeType_ID, C.iQuantity, C.cDescription, C.mAmount
			from Charges	C
			join 	ResidencyTYPE RT	 on C.iResidencyType_ID = RT.iResidencyType_ID
			left outer join SLevelType ST	ON C.iSLevelType_ID = ST.iSLevelType_ID
			join 	ChargeType ct		 on ct.iChargeType_ID = C.iChargeType_ID
			where C.dtRowDeleted is null and ct.dtRowDeleted is null
			<cfif TenantInfo.cChargeSet neq ""> 
			and C.cChargeSet = '#TenantInfo.cChargeSet#' 
			<cfelse> and C.cChargeSet is null </cfif>
			<cfif TenantInfo.iResidencyType_ID neq 3>
			and C.iAptType_ID = #TenantInfo.iAptType_ID# 
			<!--- and C.iSLevelType_ID = #GetSLevel.iSLevelType_ID# --->
			</cfif>
			and C.iResidencyType_ID = #TenantInfo.iResidencyType_ID#
			and C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# and ct.bIsDaily is not null
			and dtEffectiveStart <= '#TenantInfo.dtMoveIn#' 
			and dtEffectiveEnd >= '#TenantInfo.dtMoveIn#'
			and	c.iproductline_id = #TenantInfo.iProductLine_ID#
			order by c.dtRowStart desc				
		<cfelse>
			select * from Charges C
			join ChargeType ct	ON C.iChargeType_ID = ct.iChargeType_ID
			where C.dtRowDeleted is null
			and ct.dtRowDeleted is null and ct.bIsDaily is not null and iOccupancyPosition = 2
			and iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# 
			and C.iResidencyType_ID = #TenantInfo.iResidencyType_ID#
			and iSLevelType_ID = #GetSLevel.iSLevelType_ID# 
			and dtEffectiveStart <= '#TenantInfo.dtMoveIn#' 
			and dtEffectiveEnd >= '#TenantInfo.dtMoveIn#'
			and	c.iproductline_id = #TenantInfo.iProductLine_ID#
			order by c.dtRowStart desc
		</cfif>
	</cfquery>
</cfif>

<cfquery name='qMoveInCharges' datasource='#application.datasource#'>
	select inv.* 
	from InvoiceDetail inv
	join ChargeType ct on inv.iChargeType_ID = ct.iChargeType_ID and ct.dtRowDeleted is null
	join InvoiceMaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID 
	and im.dtRowDeleted is null 
	and im.iInvoiceMaster_ID = #MoveInInvoice.iInvoiceMaster_ID#
	where inv.dtRowDeleted is null and ct.bIsDeposit is null and inv.iRowStartUser_ID = 0	
</cfquery>


<cfquery name='qMoveInChargesTotal' DBtype='query'>
select sum(mAmount * iQuantity) as totalcharges from qMoveInCharges where iChargetype_id not in (69,1741,8)  
</cfquery>


<cfif  tenantinfo.iResidencyType_ID is 3 >
	<cfset   totalcharges = VAL(qMoveInChargesTotal.totalcharges)>
<cfelseif  tenantinfo.iResidencyType_ID is 2 >
	<cfset   totalcharges = VAL(qMoveInChargesTotal.totalcharges)>
<cfelseif  tenantinfo.iResidencyType_ID is 5 >
	<cfset   totalcharges = qMoveInChargesTotal.totalcharges>
<cfelseif  (tenantinfo.cSecDepCommFee is 'SC')>
	<cfset   totalcharges = VAL(qMoveInChargesTotal.totalcharges)>
<cfelseif ((tenantinfo.mAdjNrf is not '') and (tenantinfo.mAdjNrf gt 0) and (tenantinfo.iMonthsDeferred gt 1))>
	<cfif qMoveInChargesTotal.totalcharges gt 0>
		<cfset totalcharges = VAL(qMoveInChargesTotal.totalcharges)+ (tenantinfo.mAdjNrf/tenantinfo.iMonthsDeferred)>
	<cfelse>	
		<cfset totalcharges =  (tenantinfo.mAdjNrf/tenantinfo.iMonthsDeferred)>
	</cfif> 
<cfelseif ((tenantinfo.mAdjNrf is   '') and (tenantinfo.mAdjNrf eq 0) and (tenantinfo.iMonthsDeferred gt 1))>
	<cfset totalcharges = qMoveInChargesTotal.totalcharges + (tenantinfo.mBaseNrf/tenantinfo.iMonthsDeferred)>
<cfelseif ((tenantinfo.mAdjNrf is not '') and (tenantinfo.mAdjNrf gt 0) and ((tenantinfo.iMonthsDeferred is 0) 
		or (tenantinfo.iMonthsDeferred is '') or (tenantinfo.iMonthsDeferred is 1))  )>

	<cfset   totalcharges = VAL(qMoveInChargesTotal.totalcharges) +tenantinfo.mAdjNrf>
<cfelseif Occupancy gt 1>
	<cfset   totalcharges = qMoveInChargesTotal.totalcharges>
<cfelseif  (tenantinfo.mAdjNrf is 0)>
	<cfset   totalcharges = qMoveInChargesTotal.totalcharges>

<cfelse>
	<cfset   totalcharges = VAL(qMoveInChargesTotal.totalcharges) + tenantinfo.mBaseNrf>
</cfif>

<!--- Retrieve Current DailyRent Charges --->
<cfquery name="DailyRentCharges" datasource="#application.datasource#">
	select inv.*
	from InvoiceDetail inv
	join ChargeType ct on inv.iChargeType_ID = ct.iChargeType_ID
	join InvoiceMaster im 	ON inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
	where bIsRent is not null and bIsDaily is not null and ct.bSLevelType_ID is null
	and im.bMoveInInvoice is not null and inv.iTenant_ID = #TenantInfo.iTenant_ID# 
	and inv.dtRowDeleted is null
	and inv.cAppliesToAcctPeriod = '#DateFormat(TenantInfo.dtMoveIn,"yyyymm")#'
</cfquery>

<!--- Retrieve Next Rent Charges --->
<cfquery name="MonthRentCharges" datasource="#application.datasource#">
	select inv.*
	from InvoiceDetail inv
	join ChargeType ct ON	inv.iChargeType_ID = ct.iChargeType_ID
	join InvoiceMaster im	ON	inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
	where bIsRent is not null and bIsDaily is null and im.bMoveInInvoice is not null
	and inv.iTenant_ID = #TenantInfo.iTenant_ID# and inv.dtRowDeleted is null
	and inv.cAppliesToAcctPeriod = '#DateFormat(TenantInfo.dtMoveIn,"yyyymm")#'
</cfquery>

<!--- Retrieve Current DailyRent Charges and bIsDaily is not null --->
<cfquery name="qCareCharges" datasource="#application.datasource#">
	<cfif TenantInfo.iResidencyType_ID neq 2>
	select inv.iQuantity ,inv.mAmount ,inv.cDescription 
	,Sum(inv.iQuantity * inv.mAmount) as ExtendedAmount, inv.cAppliesToAcctPeriod
	from InvoiceDetail inv
	join ChargeType ct on inv.iChargeType_ID = ct.iChargeType_ID
	join InvoiceMaster im 	ON inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
	where bIsRent is not null and ct.bAptType_ID is null and im.bMoveInInvoice is not null
	and inv.iTenant_ID = #TenantInfo.iTenant_ID# and inv.dtRowDeleted is null
	group by inv.iQuantity ,inv.mAmount ,inv.cDescription ,inv.cAppliesToAcctPeriod
	order by inv.cAppliesToAcctPeriod
	<cfelse> select 0 as extendedamount </cfif>
</cfquery>

<cfquery name='qDailyCare' datasource="#application.datasource#">
	select C.cDescription ,C.mAmount ,C.iQuantity ,ct.iChargeType_ID
	from Charges C
	join ChargeType ct on (ct.iChargeType_ID = C.iChargeType_ID and ct.dtRowDeleted is null)
	and ct.bIsRent is not null and ct.bIsMedicaid is null and ct.bIsDiscount is null
	and ct.bIsRentAdjustment is null
	where C.dtRowDeleted is null and C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	<cfif TenantInfo.cChargeSet neq ''>
		and C.cChargeSet = '#TenantInfo.cChargeSet#'
	<cfelse>
		and C.cChargeSet is null
	</cfif>
	and	C.iResidencyType_ID = 1 and C.iAptType_ID is null 
	and iSLevelType_ID = #GetSLevel.iSLevelType_ID# 
	and ct.bIsDaily is not null
	and iOccupancyPosition is null
	and dtEffectiveStart <= '#TenantInfo.dtMoveIn#' 
	and dtEffectiveEnd >= '#TenantInfo.dtMoveIn#'
</cfquery>
<!--- 25575 - 6/16/2010 - rts - Respite info --->
<cfif TenantInfo.iResidencyType_ID eq 3>
		<cfquery name="TenantDates" datasource="#application.datasource#">
			select dateadd(dd,1,'#TenantInfo.dtMoveOutProjectedDate#') as NewPMODate
		</cfquery>
		<cfquery name="AdjustEndPMODatemin" datasource="#application.datasource#">
			select dateadd(ss,-1,'#TenantDates.NewPMODate#') as PMODate
		</cfquery>
		<cfset PMODate = AdjustEndPMODatemin.PMODate>
	<cfquery name="getRespiteDays" datasource="#application.datasource#">
		select datediff(dd,'#TenantInfo.dtRentEffective#', '#PMODate#') + 1 as Days
	</cfquery>
</cfif>
<!--- end 25575 --->
<CFQUERY NAME = "qryNrfPymntNbr" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	ts.iMonthsDeferred as NbrPaymentMonths
	FROM	TENANT	T
	JOIN 	TenantState TS ON T.iTenant_ID = TS.iTenant_ID
	WHERE	T.iTenant_ID = #TenantInfo.iTenant_ID#
</CFQUERY>
<Cfquery name="qryHouseRegion" datasource="#application.datasource#">
	SELECT RO.regionID
		,RO.regionname
		,RO.opsname
		,RO.iDirectorUser_ID
		,RO.opsareaID
		,RO.iRegion_ID
		,RO.houseID
		,RO.cNumber
		,RO.cName
	 
	  FROM [TIPS4].[rw].[vw_Reg_Ops_house] RO  
	 
	  WHERE houseID =  #SESSION.qSelectedHouse.iHouse_ID#
</Cfquery>

<!---<cfif    (cgi.server_name NEQ "Littlemuddy")>
<Cfquery name="qryApprover" datasource="FTA">
	Select cFullName 
		  ,cUserName
		  ,cEmail
		  ,cRole
		  ,cScope
	  FROM maple.FTA.dbo.vw_UserAccounts 
	  where cscope = '#qryHouseRegion.opsname#'
	  and cROle like '%RDO%'
</Cfquery>
 
<cfquery name="getRDQCSAuth" datasource="FTA">
	Select cFullName 
		  ,cUserName
		  ,cEmail
		  ,cRole
		  ,cScope
	  FROM maple.FTA.dbo.vw_UserAccounts 
	  where cscope = '#qryHouseRegion.opsname#'
	  and cROle = 'RDQCS'
  </cfquery>
 
<cfquery name="getRDSMAuth"  datasource="FTA">
	Select cFullName 
		  ,cUserName
		  ,cEmail
		  ,cRole
		  ,cScope
	  FROM maple.FTA.dbo.vw_UserAccounts 
	  where cscope = '#qryHouseRegion.opsname#'
	  and cROle = 'RDSM'
</cfquery> 
 
<cfquery name="getVPAuth"  datasource="FTA">
	Select cFullName 
		  ,cUserName
		  ,cEmail
		  ,cRole
		  ,cScope
	  FROM maple.FTA.dbo.vw_UserAccounts 
	  where cscope = '#qryHouseRegion.regionname#'
	  and cROle = 'DVP'
   </cfquery> 
 <cfelse>
<Cfquery name="qryApprover" datasource="FTA">
	Select cFullName 
		  ,cUserName
		  ,cEmail
		  ,cRole
		  ,cScope
	  FROM vmmapledev01.FTA.dbo.vw_UserAccounts 
	  where cscope = '#qryHouseRegion.opsname#'
	  and cROle like '%RDO%'
</Cfquery>
 
<cfquery name="getRDQCSAuth" datasource="FTA">
	Select cFullName 
		  ,cUserName
		  ,cEmail
		  ,cRole
		  ,cScope
	  FROM vmmapledev01.FTA.dbo.vw_UserAccounts 
	  where cscope = '#qryHouseRegion.opsname#'
	  and cROle = 'RDQCS'
  </cfquery>
 
<cfquery name="getRDSMAuth"  datasource="FTA">
	Select cFullName 
		  ,cUserName
		  ,cEmail
		  ,cRole
		  ,cScope
	  FROM vmmapledev01.FTA.dbo.vw_UserAccounts 
	  where cscope = '#qryHouseRegion.opsname#'
	  and cROle = 'RDSM'
</cfquery> 
 
<cfquery name="getVPAuth"  datasource="FTA">
	Select cFullName 
		  ,cUserName
		  ,cEmail
		  ,cRole
		  ,cScope
	  FROM vmmapledev01.FTA.dbo.vw_UserAccounts 
	  where cscope = '#qryHouseRegion.regionname#'
	  and cROle = 'DVP'
   </cfquery>  
 
 </cfif>--->

<cfscript>if(qCareCharges.RecordCount gt 0) { CareTotal=qCareCharges.ExtendedAmount; } else { CareTotal = 0.00; } </cfscript>
<cfif StandardRent.RecordCount eq 0 
	and TenantInfo.iResidencyType_ID neq 2 
	and TenantInfo.iResidencyType_ID neq 3 
	and TenantInfo.iResidencyType_ID neq 5
	and DailyRent.RecordCount eq 0>
	<br/><br/><br/>
	<a href="../MainMenu.cfm" style="font-size: 18; Color: RED;">
		There is no Market Rate entered for this type of resident in this type of room.
		<br/>Please contact your Regional Director or AR Specialist for assistance. 
		<br/>Click Here to go back to the Main Page.
	</a>
	<cfoutput><cfdump var="#standardrent#" label="standardrent"></cfoutput>
	<cfabort>
</cfif>
<cfif DailyRent.RecordCount eq 0 and TenantInfo.iResidencyType_ID neq 2 
		and TenantInfo.iResidencyType_ID neq 3 and StandardRent.RecordCount eq 0>
	<br/><br/><br/>
	<a href="../MainMenu.cfm" style="font-size: 18; Color: RED;">
		There is no Daily Rent entered for this type of resident.<br/>	
		Click Here to go back to the Main Page.</a>
	<cfabort>
</cfif>
<cfoutput>
<style type="text/css">.assess { border: 1px solid black; color: red; background-color:##ccccff; padding: 5px 5px 5px 5px; } </style>
<br/>
<form action="FinalizeMoveIn.cfm" method="POST">
<input type="Hidden" name="iTenant_ID" value="#url.ID#">
<input type="Hidden" name="MID" value="#url.MID#">
<input type="Hidden" name="secondresident" id="secondresident" value="">
<table>
<tr>
	<td style="background: white;">
		<!--- Hide Finalize Button if the Tenant is already in a Moved In State  --->
		<cfif TenantInfo.iTenantStateCode_ID lt 2><a href = "MoveInForm.cfm?ID=#URL.ID#&edit=1" style = "font-size: x-small;"> <strong>Edit Move In Form</strong> </a></cfif>
	</td>
	<td style="background: white;">&nbsp;<!--- <A href="../Reports/MoveInReport.cfm?prompt0=#url.ID#" style="font-size: x-small; color: red; background: yellow;"> <strong>Print Preview</strong> </a> ---></td>
	<td style="background: white; text-align: right;">
		<cfif ListFindNoCase(session.CodeBlock,22) gt 1 
			or ListFindNoCase(session.CodeBlock,23) gt 1
			or ListFindNoCase(session.CodeBlock,24) gt 1 
			or ListFindNoCase(session.CodeBlock,25) gt 1>
			<a href="CSVGeneration.cfm?ID=#URL.ID#" style = "font-size: x-small; color: red; background: yellow;"> <strong>Create CSV</strong> </a>
		</cfif>
	</td>
</tr>
</table>
<cfscript>
 
	if (TenantInfo.iResidencyType_ID eq 2) { DailyRate=0.00; }
	if (TenantInfo.iResidencyType_ID neq 3){
		if(DailyRent.mAmount neq '') {DailyRate = DailyRent.mAmount; }
		else if (DailyRentCharges.RecordCount gt 0 and DailyRentCharges.mAmount neq '')
		{ DailyRate = DailyRentCharges.mAmount; }
		else if (StandardRent.mamount neq ''){DailyRate = StandardRent.mAmount; }
	} 
	else if (StandardRent.mamount neq ''){DailyRate = StandardRent.mAmount; }
	else { DailyRate = 0.00; }

	DaysInHouse = (DaysInMonth(TenantInfo.dtRentEffective) - Day(TenantInfo.dtRentEffective)) + 1;
	DaysInHouseCare = (DaysInMonth(TenantInfo.dtMoveIn) - Day(TenantInfo.dtMoveIn)) + 1;	
//25575 - 6/16/2010 - rts - respite billing  - added IF
	//if (TenantInfo.iResidencyType_ID eq 3)
		//{ AcutalDays = getRespiteDays.Days; } 
	//else { ActualDays = DaysInHouse; }
	ActualDays = DaysInHouse;
	ActualDaysCare = DaysInHouseCare;	
	//AcutalDays = getRespiteDays.Days;
//end 25575
	
	if (Variables.DaysInHouse GTE 30) { DaysInHouse = 30; }
	//if (TenantInfo.iResidencyType_ID neq 3){ DailyRate = DailyRent.mAmount; } else { DailyRate = StandardRent.mAmount; }
	Value = StandardRent.mAmount;
	
	if (TenantInfo.iResidencyType_ID eq 2) { ProrateAmount = 0.00; }
	else if  (TenantInfo.iResidencyType_ID eq 3) {ProrateAmount = StandardRent.mAmount;}
	else { ProrateAmount = (Variables.DailyRate * Variables.DaysInHouse);}
</cfscript>
 

	<table>		
		<tr><th colspan="5"> Move In Summary </th></tr>
			<tr>
				<td colspan="5">
				Need help with a Move In? Select here: &nbsp;&nbsp;
				<img src="../../images/Move-In-Help.jpg" width="25" height="25" 
						onclick="showHelp();" />
				</td>
			</tr>		
		<tr>
		<td> Solomon Key </td>
		<td> #TenantInfo.cSolomonKey# </td>
		<td>&nbsp;</td>
		<td> AptType </td>
		<td> #TenantInfo.RoomType# </td>
		</tr>
		<tr>
		<td>Resident's Name</td>
		<td>#TenantInfo.cFirstName#&nbsp;#TenantInfo.cLastName#</td>
		<td>&nbsp;</td>
		<td> Apt Number </td>
		<td>#TenantInfo.cAptNumber#</td>
		</tr>
		<tr>
			<td> Physical Move In Date </td>
			<td colspan = "2"> #dateformat(TenantInfo.dtMoveIn,"mm/dd/yyyy")# </td>
			<td> Service Level </td>
			<td> #GetSLevel.cDescription# </td>
		</tr>
		<cfif isDefined("TenantInfo.dtRentEffective") and TenantInfo.dtRentEffective neq ''>
			<tr>
				<td> Financial Possession Date </td>
				<td colspan="2"> #dateformat(TenantInfo.dtRentEffective,"mm/dd/yyyy")# </td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>
		</cfif>
		<cfif TenantInfo.dtMoveOutProjectedDate is not ''>
		<TR>
			<TD> Projected Physical Move Out Date</TD>
			<td colspan="2"> #DATEFORMAT(TenantInfo.dtMoveOutProjectedDate ,"mm/dd/yyyy")#</TD>
			<TD>&nbsp; </TD>
			<TD>&nbsp; </TD>
		</TR>
		</cfif>		
		<cfif MoveInInvoice.mLastInvoiceTotal gt 0 
		and MoveInInvoice.mLastInvoiceTotal neq "" 
		and REMOTE_ADDR eq '10.1.0.201'>
			<tr>
				<td colspan="5"><hr></td>
			</tr>
			<tr>
				<td colspan="5" style="text-align:right;">
				<B>Previous Balance: #LSCurrencyFormat(MoveInInvoice.mLastInvoiceTotal)#</B>
			</td>
			</tr>
			<cfset TransactionsTotal = MoveInInvoice.mLastInvoiceTotal>
		</cfif>
		<tr>
			<td colspan=100% style='border-bottom: 1px solid black;'>
		</td>
		</tr>
		<cfif qGetSolomonTransactions.recordcount gt 0 and SESSION.USERID eq 3025>
			<tr style="text-align: left; font-weight: bold;"> 
				<td colspan="5"> 
				TRANSACTIONS 
				</td>
			</tr>
			<tr>
				<td colspan="100%" style="Text-align: center;">
					<table style="width: 85%;">
						<tr>
						<td>Reference Number</td>
						<td>Document Date</td>
						<td>Transaction Type</td>
						<td>Description</td>
						<td>Amount</td>
						</tr>
						<cfloop query="qGetSolomonTransactions">
							<tr>
								<td>#qGetSolomonTransactions.refnbr#</td>
								<td>#DateFormat(qGetSolomonTransactions.docdate,"mm/dd/yyyy")#</td>
								<td>#qGetSolomonTransactions.doctype#</td>
								<td>#qGetSolomonTransactions.docdesc#</td>
								<td style="text-align: right;">
									#LSCurrencyFormat(qGetSolomonTransactions.amount)#
								</td>
							</tr>
						</cfloop>
					</table>
				</td>
			</tr>
			<tr>
			<td colspan="100%" style="text-align: right;">
			Total Transactions: #LSCurrencyFormat(qGetSolomonTrxTotal.total)#</td>
			</tr>
			<tr><td colspan=100% style='border-bottom: 1px solid black;'></td></tr>
		</cfif>
		
		<tr style="text-align: left; font-weight: bold;"> 
			<td colspan="3"> PRO-RATED CALCULATIONS </td>	
			<td colspan=2> ACTUAL CHARGED</td>
		</tr> <!--- removed 'RENT' from pro-rated an Actual titles 75019 --->
		<tr>
			<td colspan="3" style='vertical-align: top;'>
				<table style='width:99%;'>
<!--- 					<tr>
						<td> Standard Rent Rate	</td>
							<td> #LSCurrencyFormat(StandardRent.mAmount)# </td>
							<td></td>
					</tr> --->
					<tr>
					<cfif TenantInfo.cBillingType is 'M'>
						<td> Standard Room Rate </td>
						<td> #LSCurrencyFormat(Variables.DailyRate)# per Month </td>
						<td>&nbsp;</td>						
					<cfelseif TenantInfo.iResidencyType_ID is 2>
						<td> State Medicaid Daily Rate </td>
						<td> #LSCurrencyFormat(Variables.DailyRate)# per day </td>
						<td>&nbsp;</td>					
					<cfelseif TenantInfo.iResidencyType_ID is 5>
						<td> Memory Care Daily Rate </td>
						<td> #LSCurrencyFormat(Variables.DailyRate)# per Day </td>
						<td>&nbsp;</td>	
					<cfelse>
						<td> Standard Daily Rate </td>
						<td> #LSCurrencyFormat(Variables.DailyRate)# per day </td>
						<td>&nbsp;</td>
					</cfif>
					</tr>
					<cfif TenantInfo.mBSFDisc gt 0>
						<tr>	
							<td> Adjusted Daily Rate </td>
							<td> #LSCurrencyFormat(TenantInfo.mBSFDisc)# per day </td>
							<td></td>
						</tr>
					</cfif>
						<cfif TenantInfo.iResidencyType_ID neq 3>
							<tr>
								<td>Financial Possession of Room</td>
								<td> #Variables.ActualDays# days </td>
								<td></td>
							</tr>
<!--- 						<cfelse>
						<tr><td> Number of Days in House </td><td> #getRespiteDays.Days# days </td><td></td></tr>
 --->					</cfif>

					<cfif qDailyCare.RecordCount gt 0>
					<tr>
						<td> Daily Care Rate </td>
						<cfif TenantInfo.iResidencyType_ID is 2>
						<td> #LSCurrencyFormat(0.00)# per day </td>
						<cfelse>
						<td> #LSCurrencyFormat(qDailyCare.mAmount)# per day </td>
						</cfif>
						<td></td>
						<td></td>
					</tr>	
					</cfif>	
					<!--- 25575 - rts - 6/16/2010 - respite display --->
					<cfif TenantInfo.iResidencyType_ID neq 3>
						<tr>
							<td> Number of Care Days in House </td>
							<td> #Variables.ActualDaysCare# days </td>
							<td></td>
						</tr>
						<cfelse>
						<tr>
							<td> Number of Days in House </td>
							<td> #getRespiteDays.Days# days </td>
							<td></td>
						</tr>
						</cfif> 
						<tr>
							<td>House Base Community Fee</td>
							<td>#dollarformat(TenantInfo.mBaseNRF)#</td>
						</tr>
						<cfif TenantInfo.cSecDepCommFee is not 'SC'>
						<tr>
							<td>Adjusted Community Fee</td>
							<td>#dollarformat(TenantInfo.mAdjNrf)#</td>
						</tr>		
						<tr>
							<td>Community Fee Payments</td>
							<td>#qryNrfPymntNbr.NbrPaymentMonths#</td>
						</tr>							
						<cfelse>
							<tr>
							<td>Adjusted Community Fee</td>
							<td>None</td>
						</tr>
						</cfif>				
				</table>
			</td>
			<td colspan=2 style='vertical-align: top;'>
				<!--- mstriegel 05/03/2018 --->
				<cfset temp = 0>
				<table style='width:99%;'>
					<cfloop query='qMoveInCharges'>
						<cfif  findnocase("second", qMoveInCharges.cDescription ) gt 0 >
							<cfset secondresident = "Yes">
						</cfif>
						<cfif ((qMoveInCharges.cDescription is "Community Fee") 
								and (tenantinfo.iMonthsDeferred GT 1))>
						<tr>
							<td>#qMoveInCharges.cDescription# - MoveIn Payment</td>
							<td>
								#left(MonthAsString(right(qMoveInCharges.cAppliesToAcctPeriod,2)),3)#
							</td>
							<td style='text-align:right;'>
								#LSCurrencyFormat(qMoveInCharges.mAmount/tenantinfo.iMonthsDeferred)#
							</td>
							<cfset temp = temp + (qMoveInCharges.mAmount/tenantinfo.iMonthsDeferred)>
						</tr>
						<cfelse>
						<tr>
							<td>#qMoveInCharges.cDescription#</td>
							<td>
								#left(MonthAsString(right(qMoveInCharges.cAppliesToAcctPeriod,2)),3)#
							</td>
							<td style='text-align:right;'>
								#LSCurrencyFormat(qMoveInCharges.mAmount * qMoveInCharges.iQuantity)#
							</td>
						</tr>	
							<cfset temp = temp + (qMoveInCharges.mAmount * qMoveInCharges.iQuantity)>					
						</cfif>
					</cfloop>
				</table>
			</td>
		</tr>	
		<tr>
			<td colspan="3"></td>
			<td style = "font-weight: bold;"> Total Rent Due </td>
			<td style = "font-weight: bold; #right#">
				<!--- <cfset TotalRentDue = #Variables.Value# + #Variables.ProrateAmount#> --->
				<cfscript>
					if(isDefined("totalcharges") 
					and IsBlank(totalcharges,0) gt 0)
						{ TotalRentDue = totalcharges; } 
					else 
						{ TotalRentDue=0;}
				</cfscript>
				<cfset variables.totalRentDue = temp>
				***#LSCurrencyFormat(Variables.TotalRentDue)#
			</td>
		</tr>
		<!--- end mstriegel 05/03/2018 --->
	<cfif   TenantInfo.iResidencyType_ID is 2>		
<!--- 	<cfset statebilledamt = 
		(qrySelMedicaidState.mamount*qrySelMedicaidState.iquantity) - Variables.TotalRentDue> --->
		<tr>
			<td colspan="3">&nbsp;</td>
			<td style = "font-weight: bold;"> Medicaid Billing to State</td>
			<td style = "font-weight: bold; #right#">
					#LSCurrencyFormat(qrySumMedicaidState.SumMedicaidState)#
			</td>
		</tr>	
	</cfif>
		<tr> 
			<td colspan=100% style='border-bottom: 1px solid black;'>
			</td>
		</tr>
		<tr>
			<td colspan="2" style="vertical-align:top;">
				<table style="width: 100%;">
					<tr style="text-align: left; font-weight: bold;"> 
						<td colspan="2" style='background: gainsboro;'> REFUNDABLE DEPOSITS </td>
					</tr>
					<cfset RefundableTotal = 0>
						<cfloop query="refundable">
						<cfset RefundableTotal = RefundableTotal + Refundable.mAmount>
						<tr>
							<td> #Refundable.cDescription#	</td> 
							<td> #LSCurrencyFormat(Refundable.mAmount)#	
								<cfif Refundable.iQuantity gt 1> x (#Refundable.iQuantity#) </cfif>
							</td>
						</tr>
					</cfloop>
				</table>
			</td>
			<td></td>
			<td colspan="2" valign="TOP">
				<table style = "width: 100%;">		
					<tr style="text-align: left; font-weight: bold;"> 
						<td colspan=2 style='background: gainsboro;'>	NON-REFUNDABLE FEES	</td> 
					</tr>
					<cfset FeesTotal = 0>
					<cfloop query="Fees">
						<cfscript>
							if (TenantInfo.bAppFeePaid eq "" or 
							FindNoCase("App",Fees.cDescription,1) eq 0) 
							{ FeesTotal = FeesTotal + Fees.mAmount; 
							mAmount = LSCurrencyFormat(Fees.mAmount); }
							else { mAmount = 'Collected'; }
						</cfscript>
						<tr><td> #Fees.cDescription# </td>
							<td> #Variables.mAmount# 
							<cfif Fees.iQuantity gt 1> x (#Fees.iQuantity#) </cfif> </td>
						</tr>
					</cfloop>						
				</table>
			</td>			
		</tr>
		<tr style="font-weight: bold;">
			<td> Potential Refundable Deposits </td>
			<td> #LSCurrencyFormat(Variables.RefundableTotal)# </td>
			<td></td>
			<td> Total Non-Refundable Deposits </td>
			<td> #LSCurrencyFormat(Variables.FeesTotal)# </td>
		</tr>
		<tr>
			<td colspan=100% style='border-bottom: 1px solid black;'>&nbsp;</td>
		</tr>
		<tr style="text-align: left; font-weight: bold;">
			<td colspan=100%>Adjsutments</td>	
		</tr>
		<!--- Added Credits/Charges:  chgd 75019--->
		<cfset TotalCredits=0>
		<cfloop query="Credits">
			<cfset mAmount= Credits.mAmount * Credits.iQuantity>
			<tr>
				<td> #Credits.cDescription# </td>
				<td colspan=100%>#LSCurrencyFormat(Credits.mAmount)#	x #Credits.iQuantity#</td>
			</tr>
			<cfset TotalCredits = TotalCredits + Variables.mAmount>
		</cfloop>
		<tr style = "font-weight: bold;">
			<td colspan="3"></td>
			<td>Total Adjustments </td>
			<td>#LSCurrencyFormat(Variables.TotalCredits)#</td>
		</tr><!--- Total Credits/Charges 75019 --->
		<tr>
			<td colspan=100% style='border-bottom: 1px solid black;'>&nbsp;</td>
		</tr>
		<tr style="text-align: left; font-weight: bold;">
			<td colspan="5" style='background: gainsboro;'>CONTACT INFORMATION</td>
		</tr>
		<tr>
			<td> FullName </td>
			<td colspan="3"> #ContactInfo.cFirstName#&nbsp;#ContactInfo.cLastName# </td>
		</tr>
		<tr>
			<td> Relationship </td>
		<td colspan="3"> #ContactInfo.Relation# </td>
		</tr>
		<tr>
			<td> Address Line 1 </td>
			<td colspan="3"> #ContactInfo.cAddressLine1# </td>
		</tr>
		<tr>
			<td> Address Line 2 </td>
			<td colspan="3"> #ContactInfo.cAddressLine2# </td>
		</tr>
		<tr>
			<td> City </td>
			<td colspan="3">#ContactInfo.cCity#</td>
		 </tr>
		<tr>
			<td> State </td>
			<td colspan="3"> #ContactInfo.cStateCode#	</td>
		</tr>
		<tr>
			<td> Zip Code </td>
			<td colspan="3"> #ContactInfo.cZipCode# </td>
		</tr>
		<tr>
			<td> Phone Number 1</td>
			<td colspan="3"> #left(ContactInfo.cPhoneNumber1,3)#-#Mid(ContactInfo.cPhoneNumber1,4,3)#-#right(ContactInfo.cPhoneNumber1,4)# 	</td>
		</tr>
		<tr>
			<td>Phone Number 2</td>
		<td colspan="2">#left(ContactInfo.cPhoneNumber2,3)#-#Mid(ContactInfo.cPhoneNumber2,4,3)#-#right(ContactInfo.cPhoneNumber2,4)#</td>
			<td style="font-weight: bold;"> Total Due at Move In </td>
			<td style="font-weight: bold;">
				<cfset TotalDue = Variables.RefundableTotal 
				+ Variables.FeesTotal 
				+ Variables.TotalRentDue 
				+ Variables.TotalCredits 
				+ TransactionsTotal>
				#LSCurrencyFormat(Variables.TotalDue)#
			</td>
		</tr>
</cfoutput>	
		<tr>
<!--- 		<cfif ((TenantInfo.mBaseNRF gt TenantInfo.mAdjNrf and TenantInfo.mAdjNrf is not '')  
			and (SESSION.qSelectedHouse.iopsarea_ID is not 44) 
				and (secondresident is not 'Yes') and (tenantinfo.iresidencytype_id is not  3))>
			<cfoutput>
				<td  colspan = "5" style="font-weight: bold; color:red ;text-align:center"  > Regional Staff, DVP or President <br />
				approval is required when there is a discounted New Resident Fee<br />
					House NRF: #dollarformat(TenantInfo.mBaseNRF)#  Adjusted NRF: #dollarformat(TenantInfo.mAdjNrf)#
					<br />
					<cfif qAssessmentCheck.recordcount gt 0 and qAssessmentCheck.iassessmenttoolmaster_id neq "">
						<input type="submit" name="Complete" value="Save Move-In and Send Notifications for Approval">
						<br />Move in will not be complete until approvals are received for NRF change.
						<!--- <br/><U>If you finalize the move-in, you will not be able to change the move in information.</U> --->	
					</cfif>				
				</td>
			</cfoutput>	
		<cfelse> --->	
		
<!--- 			<cfif ((TenantInfo.iTenantStateCode_ID lt 2 or TenantInfo.iTenantStateCode_ID eq 4) and (TenantInfo.dtMoveIn lt TimeStamp)) or (SESSION.qSelectedHouse.iopsarea_ID is 44)> --->
				<td colspan = "4" style="text-align: center; color: red; font-weight: bold;
				 font-size: 12;">
					<cfif ((qAssessmentCheck.recordcount gt 0) 
					and (qAssessmentCheck.iassessmenttoolmaster_id neq ""))
					 <!--- or (SESSION.qSelectedHouse.iopsarea_ID is   44)   --->  >
						<input type="submit" name="Finalize" value="FinalizeMoveIn">
						<br/>
						<U>
						If you finalize the move-in,
						you will not be able to change the move in information.
						</U>
					<cfelse>
						<cfoutput>
						<a href"../../AssessmentTool_v2/index.cfm?fuse=newassessment&tenantId=#TenantInfo.iTenant_id#
						&assessmentType=tenant" 
						class="assess">
						An assessment for this must be completed 
						#qAssessmentCheck.recordcount#, 
						#qAssessmentCheck.iassessmenttoolmaster_id#
						</a>
						</cfoutput>
					</cfif>
				</td>
<!--- 			<cfelse>
				<td colspan="100%" style="text-align: center; background: gainsboro; color: red;"> <B>You may not finalize a future Move In.</B></td>
			</cfif>	 --->
		<!--- 	</cfif> --->	
<!--- 		<tr>
		<cfif ((tenantinfo.mBaseNRF is not   tenantinfo.mAdjNRF) and (SESSION.qSelectedHouse.iopsarea_ID is not 44) and secondresident is not 'Yes') and tenantinfo.iresidencytype_id is not 3>
		<cfif qryApprover.cFullName   is not ""> 		   
		</tr>
			<td   colspan = "5" >
				<cfoutput query="qryApprover">
					 RDO approval will be sent to: #cFullName# - #crole# - #cEMail# 
						<input type="hidden"  name="approveremail" value="#cEMail#"/>
						<input type="hidden"  name="name" value="#cFullName#"/>
						<input type="hidden"  name="role" value="#crole#"/>	
					 
				</cfoutput>
			</td>
		</tr>
		<cfelseif getRDQCSAuth.cFullName is not ""> 
		</tr>
			<td   colspan = "5" >
				<cfoutput query="getRDQCSAuth">
					 RDQCS Discount approval will be sent to: #cFullName# -  #crole# - #cEMail#
						<input type="hidden"  name="approveremail" value="#cEMail#"/>
						<input type="hidden"  name="name" value="#cFullName#"/>
						<input type="hidden"  name="role" value="#crole#"/>						
					 
				</cfoutput>
			</td>
		</tr>
		<cfelseif getRDSMAuth.cFullName is not ""> 		
		</tr>
			<td   colspan = "5" >
				<cfoutput query="getRDSMAuth">
				 RDSM Discount approval will be sent to: #cFullName# - #crole# - #cEMail#
						<input type="hidden"  name="approveremail" value="#cEMail#"/>
						<input type="hidden"  name="name" value="#cFullName#"/>
						<input type="hidden"  name="role" value="#crole#"/>				
				 
				</cfoutput> 
			</td>
		</tr>
		<cfelse>
		</tr>
			<td   colspan = "5" >
				<cfoutput query="getVPAuth">VP Discount approval will be sent to: #cFullName# - #crole# - #cEMail#
					<input type="hidden"  name="approveremail" value="#cEMail#"/>
					<input type="hidden"  name="name" value="#cFullName#"/>
					<input type="hidden"  name="role" value="#crole#"/>				
				</cfoutput>
			</td>
		</tr>	
		</cfif>	
		</cfif> --->		
	</table> 
</form>	


<cfinclude template="../../footer.cfm">
