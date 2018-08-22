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
<cfset oMISServices = createobject("component","intranet.TIPS4.CFC.components.MoveIn.MoveInSummaryServices")>

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
<script>
	function redirect(){ 
		window.location = "../Registration/Registration.cfm";
	} 
</script>
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
<cfset getDate = oMISServices.getDate()>
<cfset TimeStamp=CREATEODBCDateTime(GetDate.Stamp)>
<cfif isDefined("tenantinfo.itenant_id")>
	<!--- check for active assesssment added 3/28/05 by Paul Buendia --->
	<cfset qAssessmentCheck = oMISServices.getAssessmentCheck(tenantID=tenantInfo.iTenant_Id)>
</cfif>

<cfif NOT IsDefined("url.id") and NOT IsDefined("url.mid") or ((IsDefined("url.id") and url.ID eq "") or (IsDefined("url.mid") and url.mid eq ""))>
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
		function shortcut(){ 
			location.href='../mainmenu.cfm'; 
		}	
		setTimeout("shortcut();",10000);
	</script>
	<cfabort>
</cfif>
<script>
	function showHelp(){
 		window.open("TIPS-Move-In-Process.pdf");
	}
</script>
<!--- Retrieve the Move In Invoice Information --->
<cfset MoveInInvoice = oMISServices.getMoveInInvoice(invoiceID=url.MID)>

<!--- Throw Error Message if an invoice master record can not be found --->
<cfif MoveInInvoice.RecordCount eq 0 and TenantInfo.iResidencyType_ID neq 2>
	<B style="font-size: 18;">
		<br/><br/>There is no move-in information available for this resident.<br/> (This  is Pre-TIPS 4.0)</B><br/><br/>
	<a href="../MainMenu.cfm" style="font-size: 18;">	Click Here to Continue </a>
	<cfabort>
</cfif>
<cfset FindOccupancy = oMISServices.getFindOccupancy(addressID=tenantinfo.iAptAddress_ID,tenantID=tenantInfo.iTenant_ID)>
<cfif FindOccupancy.iResidencyType_ID is 2>
	<cfset qryMedicaidRate = oMISServices.getMedicaidRate(houseID=session.qSelectedHouse.iHouse_id)>	
</cfif>
<cfset qryMedicaidDate = oMISServices.getMedicaidDate(residentID=tenantInfo.cSolomonKey)>

<cfloop query="qryMedicaidDate"> 
	<cfset qrySelMedicaidCoPay = oMISServices.getSelMedicaidCoPay(residentId=tenantInfo.cSolomonKey,acctPeriod=qryMedicaidDate.cAppliesToAcctPeriod)>
	<cfset qrySelMedicaidBSF = oMISServices.getSelMedicaidBSF(residentId=tenantInfo.cSolomonKey,acctPeriod=qryMedicaidDate.cAppliesToAcctPeriod)>
	<cfset qrySelMedicaidState = oMISServices.getSelMedicaidState(residentId=tenantInfo.cSolomonKey,acctPeriod=qryMedicaidDate.cAppliesToAcctPeriod)>
	<cfset qrySumMedicaidState = oMISServices.getSumMedicaidState(residentId=tenantInfo.cSolomonKey)>
</cfloop>
<cfif IsDefined('CommFeePayment') and CommFeePayment is not ''>
	<cfset updCommPaymnt = updCommPaymnt(tenantId=form.iTenant_id,monthsDeferred=commFeePayment)>
	<cfif CommFeePayment gt 1>
		<cfset qChargeID = oMISServices.getChargeID()>			
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
		<cfset qInsertRecurring = oMISServices.inRecurring(theData={tenantID=tenantInfo.iTenant_id,desc=qChargeID.cDescription,amount=commFeePaymntAmt,AcctStamp=createODBCDate(session.acctStamp),userID=session.userID})>
	</cfif>	
</cfif>	
<cfset qryNrfPymnt = oMISServices.getNRFPaymnt(tenantID=tenantInfo.iTenant_id)>
<cfif qryNrfPymnt.PaymentMonths is 0 and qryNrfPymnt.NRFBase gt 0 and qryNrfPymnt.NRFAdj is ''>
	<cfset updNbrPymnt = oMISServices.updNbrPymnt(tenantID=tenantInfo.iTenant_ID)>
</cfif>	
<cfscript> 
	if (FindOccupancy.RecordCount gt 0){
		Occupancy = 2;
	}
	else {
		Occupancy = 1;
	} 
</cfscript>
<!--- Retrieve any solomontransactions --->
<cfset qGetSolomonTransactions = oMISServices.GetSolomonTransactions(residentID=tenantinfo.cSolomonKey,theData=MoveInInvoice)>
<cfif qGetSolomonTransactions.recordcount gt 0 and Occupancy eq 1>
<!--- Retrieve total of  solomontransactions --->
	<cfset qGetSolomonTrxTotal = oMISServices.GetSolomonTrxTotal(residentId=tenantInfo.cSolomonKey,theData=MoveInInvoice)>
	<cfset TransactionsTotal = qGetSolomonTrxTotal.Total>
<cfelse> 
	<cfset TransactionsTotal = 0.00> 
</cfif>
<cfset qHistSet = oMISServices.getHistSet(tenantID=tenantInfo.iTenant_Id,MoveInDt=tenantInfo.dtMoveIn)>
<!--- Retrieve the service level according to the service points --->
<cfset getSLevel = oMISServices.getSLevel(qry1=tenantInfo,qry2=qHistSet,sLevelType=session.cSLevelTypeSet)>
<!--- Retrieve Credit Entries from the Invoice Detail  --->
<cfset Credits = oMISServices.getCredits(qry1=MoveInInvoice,MID=url.mid)>
<!--- Check to see if any house specific deposits exist for the house --->
<cfset qDepositCheck = oMISServices.getDepositCheck(houseID=session.qSelectedHouse.iHouse_Id)>
<cfif qDepositCheck.count gt 0> 
	<cfset HouseSpecific=1>
<cfelse>
	<cfset HouseSpecific=0>
</cfif>
<!--- Retreive Refundable Deposits  --->
<cfset Refundable = oMISServices.getRefundable(houseID=session.qSelectedHouse.iHouse_Id,tenantID=tenantInfo.iTenant_Id,houseSpecific=houseSpecific)>
<cfset Fees = oMISServices.getFees(houseID=session.qSelectedHouse.iHouse_Id,tenantID=tenantInfo.iTenant_Id,houseSpecific=houseSpecific)>
<cfset CheckCompanionFlag = oMISServices.getCheckCompanionFlag(addressID=tenantInfo.iAptAddress_ID)>
<cfif CheckCompanionFlag.bIsCompanionSuite eq 1> 
	<cfset Occupancy = 1>
</cfif>
<cfset StandardRent = oMISServices.getStandardRent(occupancy=occupancy,houseID=session.qSelectedHouse.iHouse_Id,theData=tenantInfo)>
<cfif StandardRent.RecordCount eq '0'>
	<cfset standardrent = oMISServices.getStandardRent2(occupancy=occupancy,houseID=session.qSelectedHouse.iHouse_Id,theData=tenantInfo)>
</cfif>
<cfset DailyRent = oMISServices.getDailyRent(occupancy=occupancy,houseID=session.qSelectedHouse.iHouse_Id,theData=tenantInfo)>
<cfif DailyRent.RecordCount eq 0>
	<cfset DailyRent = oMISServices.getDailyRent2(occupancy=occupancy,houseID=session.qSelectedHouse.iHouse_Id,theData=tenantInfo,sLevelTypeID=getSLevel.iSLevelType_ID)>	
</cfif>
<cfset qMoveInCharges = oMISServices.getMoveInCharges(mid=moveInInvoice.iInvoiceMaster_ID)>

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
<cfset DailyRentCharges = oMISServices.getDailyRentCharges(tenantId=tenantInfo.itenant_id,acctPeriod=DateFormat(tenantInfo.dtMoveIn,"yyyymm"))>
<!--- Retrieve Next Rent Charges --->
<cfset MonthRentCharges = oMISServices.getMonthRentCharges(tenantId=tenantInfo.itenant_id,acctPeriod=DateFormat(tenantInfo.dtMoveIn,"yyyymm"))>
<!--- Retrieve Current DailyRent Charges and bIsDaily is not null --->
<cfset qCareCharges = oMISServices.getCareCharges(ResidencyTypeID=tenantInfo.iResidencyType_Id,tenantID=tenantInfo.iTenant_Id)>
<cfset qDailyCare = oMISServices.getDailyCare(houseID=session.qSelectedHouse.iHouse_Id,theData=tenantInfo,sLevelTypeID=getSLevel.iSLevelType_ID)>


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
<cfset qryNrfPymntNbr = oMISServices.qryNrfPymntNbr(tenantID=tenantInfo.iTenant_ID)>
<cfset qryHouseRegion = oMISServices.qryHouseRegion(houseID=session.qSelectedHouse.iHouse_ID)>


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
	<td style="background: white;">&nbsp;</td>
	<td style="background: white; text-align: right;"></td>
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
	ActualDays = DaysInHouse;
	ActualDaysCare = DaysInHouseCare;	

	
	if (Variables.DaysInHouse GTE 30) { DaysInHouse = 30; }

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
		<td>Resident Id </td>
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
		<cfif isDefined("TenantInfo.dtRentEffective") and TenantInfo.dtRentEffective neq ''>
			<tr>
				<td> Financial Possession Date </td>
				<td colspan="2"> #dateformat(TenantInfo.dtRentEffective,"mm/dd/yyyy")# </td>
				<td> Service Level </td>
				<td> #GetSLevel.cDescription# </td>				
			</tr>
		</cfif>
		<tr>
			<td> Physical Move In Date </td>
			<td colspan = "2"> #dateformat(TenantInfo.dtMoveIn,"mm/dd/yyyy")# </td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
	
		<cfif TenantInfo.dtMoveOutProjectedDate is not ''>
		<TR>
			<TD> Projected Physical Move Out Date</TD>
			<td colspan="2"> #DATEFORMAT(TenantInfo.dtMoveOutProjectedDate ,"mm/dd/yyyy")#</TD>
			<TD>&nbsp; </TD>
			<TD>&nbsp; </TD>
		</TR>
		</cfif>		
		<cfif MoveInInvoice.mLastInvoiceTotal gt 0 	and MoveInInvoice.mLastInvoiceTotal neq "" 	and REMOTE_ADDR eq '10.1.0.201'>
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
			<td colspan="3">SUMMARY OF CHARGES </td>	
			<td colspan=2> CURRENT CHARGES</td>
		</tr> 
		<tr>
			<td colspan="3" style='vertical-align: top;'>
				<table style='width:99%;'>
					<tr>
					<cfif TenantInfo.cBillingType is 'M'>
						<td>Standard Room Rate </td>
						<td> #LSCurrencyFormat(standardRent.mAmount)# per Month </td>
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
						<td>Standard Daily Rate </td>
						<td> #LSCurrencyFormat(Variables.DailyRate)# per day </td>
						<td>&nbsp;</td>
					</cfif>
					</tr>
					<cfif TenantInfo.mBSFDisc gt 0>
						<tr>	
							<td> Adjusted Room Rate </td>
							<td><cfif TenantInfo.cBillingType EQ "M">#LSCurrencyFormat(session.currentmonth)# per month<cfelse> #LSCurrencyFormat(TenantInfo.mBSFDisc)# per day</cfif> </td>
							<td></td>
						</tr>
					</cfif>
						<cfif TenantInfo.iResidencyType_ID neq 3>
							<tr>
								<td>Financial Possession of Room</td>
								<td> #Variables.ActualDays# days </td>
								<td></td>
							</tr>
					</cfif>
					<cfif tenantinfo.cBillingType NEQ "M">
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
				<cfset temp = 0>
				<table style='width:99%;'>
					<cfloop query='qMoveInCharges'>
						<cfif  findnocase("second", qMoveInCharges.cDescription ) gt 0 >
							<cfset secondresident = "Yes">
						</cfif>
						<cfif ((qMoveInCharges.cDescription is "Community Fee") and (tenantinfo.iMonthsDeferred GT 1))>
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
			<td style = "font-weight: bold;"> Total Current Charges </td>
			<td style = "font-weight: bold; #right#">
				
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
	
	<cfif   TenantInfo.iResidencyType_ID is 2>		

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
			<td colspan="3" style="vertical-align:top;">
				<table style="width: 100%;">
					<tr style="text-align: left; font-weight: bold;"> 
						<td colspan="4" style='background: gainsboro;'> REFUNDABLE DEPOSITS </td>
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
		</tr>
		<tr style="font-weight: bold;">
			<td colspan="2"> Potential Refundable Deposits </td>
			<td> #LSCurrencyFormat(Variables.RefundableTotal)# </td>
		</tr>
		<tr>
			<td colspan=100% style='border-bottom: 1px solid black;'>&nbsp;</td>
		</tr>
		<tr style="text-align: left; font-weight: bold;">
			<td colspan=100%>Ancillary</td>	
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
			<td>Total Ancillary </td>
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
			<td> Home Phone</td>
			<td colspan="3"> #left(ContactInfo.cPhoneNumber1,3)#-#Mid(ContactInfo.cPhoneNumber1,4,3)#-#right(ContactInfo.cPhoneNumber1,4)# 	</td>
		</tr>
		<tr>
			<td>Cell Phone</td>
		<td colspan="2">#left(ContactInfo.cPhoneNumber2,3)#-#Mid(ContactInfo.cPhoneNumber2,4,3)#-#right(ContactInfo.cPhoneNumber2,4)#</td>
			<td style="font-weight: bold;"> Total Due at Move In </td>
			<td style="font-weight: bold;">
			<cfset FeesTotal = 0>
				<cfloop query="Fees">
					<cfscript>
						if (TenantInfo.bAppFeePaid eq "" or FindNoCase("App",Fees.cDescription,1) eq 0) {
							FeesTotal = FeesTotal + Fees.mAmount; 
							mAmount = LSCurrencyFormat(Fees.mAmount);
						}
						else { mAmount = 'Collected'; }
					</cfscript>
				</cfloop>
				<cfset TotalDue = Variables.RefundableTotal + Variables.FeesTotal + Variables.TotalRentDue + Variables.TotalCredits + TransactionsTotal>
				#LSCurrencyFormat(Variables.TotalDue)#
			</td>
		</tr>
		<tr>
			<td> Email</td>
			<td colspan="3"><a href="MailTO:#contactInfo.cEmail#">#contactinfo.cEmail#</a></td>
		</tr>
</cfoutput>	
		<tr>
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
	</table> 
</form>	
<cfinclude template="../../footer.cfm">
