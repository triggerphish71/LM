<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| MoveInCredits.cfm - Create/Add New room to the house                                         |
| Called by:        MoveInForm.cfm                                                             |
| Calls/Submits:    MoveInCredit.cfm                                                           |
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
| Paul B     | 02/07/2002 | Original Authorship                                                |
| Paul B     | 07/11/2002 | Changed Additional query to allow AR to have access                |
|            |            | to deposits to be adjusted.                                        |
| mlaw       | 03/08/2006 | Remedy Call 32362 - User should allow to change all charges except |
|            |            | ChargeType - R&B rate, R&B discount                                |
| MLAW       | 08/17/2006 | Users would need to select Security Deposit Line 125               |
| MLAW       | 03/12/2007 | add chargetype.dtrowdeleted is NULL in Additional Query            |
| rschuette  | 08/05/2008 | added code to disable anyone not in AR from adding credits         |
| sfarmer    | 04/05/2012 | added submit check if no charge/credit was selected  proj nbr 75019|
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
|sfarmer     | 06/09/2012 | 75019 - Adjustments for 2nd opp, respite, Idaho                    |
|sfarmer     | 07/17/2013 | 108529 - Remove access to delete BSF & LOC charges                 |
| Sfarmer    | 09/18/2013 | 102919  - Revise NRF approval process                              |
| S Farmer   | 05/20/2014 | 116824 - Move-In update   - Allow ED to adjust BSF rate            |
|S Farmer    | 05/20/2014 | 116824 - Phase 2 Allow different move-in and rent-effective dates  |
|            |            | allow respite to adjust BSF rates                                  |
|S Farmer    | 08/20/2014 | 116824 - back-off different move-in rent-effective dates           |
|            |            | allow adjustment of rates by all regions                           |
|S Farmer    | 09/08/2014 | 116824 - Allow all houses edit BSF and Community Fee Rates         |
|S Farmer    | 2015-01-12 | 116824      Final Move-in Enhancements                             |
|S Farmer    | 2015-07-31 | Updates for Pinicon Place with monthly charges                     |
|SFarmer,    | 2015-09-28 |  Medicaid, Memory Care Updates                                     |
|MShah       |            |                                                                    |
|SFarmer     | 05/02/2017 | Remove extraneous displays, comments & dumps,use error routine     |
|            |            |and display page                                                    |
|MStriegel   | 06/14/2018 | I added logic to update room and board so that it cannot be blank  |
|                           or 0.00 if the original amount is not blank or 0.00                |
 -----------------------------------------------------------------------------------------  --->
<cfset oMICServices = createobject("component","intranet.TIPS4.CFC.components.MoveIn.MoveInCreditServices")>

<cfoutput> 
<cfparam name="NrfDiscApprove" default="">
<cfparam name="CommFeePayment" default="">
<cfparam name="monthdays1" default="">
<cfparam name="monthdays2" default="">
<cfparam name="dtcompare" default="">
<cfparam name="dtcompare2" default="">
<cfparam name="DAYSINMONTH1" default="">
<cfparam name="DAYSINMONTH2" default="">
<cfparam name="ACCTPERIOD" default="">
<cfparam name="session.THISACCTPERIOD1" default="">
<cfparam name="session.THISACCTPERIOD2" default="">
<cfparam name="NBRDAYS2" default="">
<cfparam name="NBRDAYS1" default="">

<cfif isdefined('url.acctperiod1')>
	<cfset session.thisacctperiod1 = #url.acctperiod1#>
<cfelseif IsDefined('form.acctperiod1')>
	<cfset session.thisacctperiod1 = #form.acctperiod1#>
</cfif>
<cfif isdefined('url.acctperiod2')>
	<cfset session.thisacctperiod2 = #url.acctperiod2#>
<cfelseif IsDefined('form.acctperiod2')>
	<cfset session.thisacctperiod2 = #form.acctperiod2#>
</cfif>

<cfif isdefined('url.monthdays1')>
	<cfset nbrdays1 = #url.monthdays1#>
<cfelseif IsDefined('form.monthdays1')>
		<cfset nbrdays1 = #form.monthdays1#>
</cfif>
<cfif isdefined('url.monthdays2')>
	<cfset nbrdays2 = #url.monthdays2#>
<cfelseif IsDefined('form.monthdays2')> 
		<cfset nbrdays2 = #form.monthdays2#>
</cfif>

<cfset tenantType = oMICServices.getTenantType(tenantID=url.id)>
<cfset qryHouseChargeset = oMICServices.getHouseChargeset(houseid=session.qSelectedHouse.iHouse_id)>

<cfif tenanttype.IRESIDENCYTYPE_ID is 2>
	<cfset qryMedicaidHouse = oMICServices.getMedicaidHouse(houseID=tenanttype.iHouse_ID)>
	<cfif qryMedicaidHouse.recordcount is 0>
		<cfset processname = "Resident Move In" >
		<cfset residentname = #tenanttype.resident#>
		<cfset residentID = #url.ID#>
		<cfset Formname = "MoveInCredits.cfm">
		<cfif IsSecondOccupant is 'yes'>
			<cfset Is2ndOccupant = "Second Occupant">
		<cfelse>
			<cfset Is2ndOccupant = "Single Occupant">
		</cfif>
		<CFSCRIPT>
			Msg1 = "Medicaid is not applicable for this community.<BR>";
			Msg1 = Msg1 & "Residency: Medicaid<br>";
		</CFSCRIPT>			
		<cfset wherefrom = 'MoveInCredits'>
    	<cflocation url="../Shared/ErrorTemplate.cfm?processname=#processname#&Formname=#Formname#&wherefrom=#wherefrom#&residentID=#residentID#&residentname=#residentname#&Msg1=#Msg1#">
		<cfabort>
	</cfif> 
</cfif>
<cfset FindOccupancy = oMICServices.getFindOccupancy(addressID=tenantType.iAptAddress_ID,tenantID=url.id)>
<cfif FindOccupancy.RecordCount gt 0>
	<cfif ((FindOccupancy.iResidencyType_ID eq 1) and (tenanttype.iResidencyType_ID eq 2))	or (FindOccupancy.dtMoveIn LTE createODBCDateTime(tenanttype.dtMovein))>
		<cfset Occupancy = 2>
	<cfelse> 
		<cfset Occupancy = 1> 
	</cfif>
<cfelse> 
	<cfset Occupancy = 1> 
</cfif>
<cfset  qrybIscompanion = oMICServices.getIsCompanion(addressID=tenantType.iAptAddress_ID)>
<cfset qryHouseCommunityFee = oMICServices.getHouseCommunityFee(houseID=tenantType.ihouse_ID)>

<cfif tenantType.cbillingtype is 'M'>   
	<cfif Occupancy is 1>
		<cfset qryAptType = oMICServices.getAptType(tenantID=url.id)>		
	<cfelse>
		<cfset qryAptType = oMICServices.getAptType1(tenantID=url.id,bIsCompanion=VAL(qrybiscompanion.biscompanionsuite),productlineID=tenantType.iProductline_id)>
		<cfset StrMonth1 =  #left(session.thisacctperiod1,4)# & '-' & #right(session.thisacctperiod1,2)#  & '-01'  >
		<cfset StrMonth2 =  #left(session.thisacctperiod2,4)# & '-' & #right(session.thisacctperiod2,2)#  & '-01'  >
		<cfset DaysInMonth1 = #daysinmonth(StrMonth1)#>
		<cfset DaysInMonth2 = #daysinmonth(StrMonth2)#>
	</cfif>
<cfelseif tenantType.iresidencytype_id is not 2>
	<cfset qryAptType = oMICServices.getAptType2(tenantID=url.id)>
<cfelse>  
	<cfset StrMonth1 =  #left(session.thisacctperiod1,4)# & '-' & #right(session.thisacctperiod1,2)#  & '-01'  >
	<cfset StrMonth2 =  #left(session.thisacctperiod2,4)# & '-' & #right(session.thisacctperiod2,2)#  & '-01'  >
	<cfset DaysInMonth1 = #daysinmonth(StrMonth1)#>
	<cfset DaysInMonth2 = #daysinmonth(StrMonth2)#>
	<cfset qryAptType = oMICServices.getAptType3(tenantID=url.id)>
</cfif>
 
<cfif tenantType.cbillingtype is 'M' and tenanttype.iresidencytype_id neq 2> 
	<cfset baseNRF = qryAptType.mAmount>
	<cfset  baseNRF = replace(baseNRF, ',' ,'')>
	<cfset  baseNRF = replace(baseNRF, '$' ,'')>	
	<cfset updateTenantStateBSF = oMICServices.updTenantStateBSF(theData={mBaseNRF=baseNRF,mBSFOrig=qryAptType.mAmount,tenantID=url.id})>	
<cfelseif (tenantType.iresidencytype_id is  2)>
	<cfset thisBaseNRF = 0>
	<cfif ((qryAptType.mBSFOrig is not '') and (qryAptType.mBSFOrig gt 0))>
		<cfset updateTenantStateBSF = oMICServices.updTenantStateBSF(theData={mBSFOrig=qryAptType.mBSFOrig,mBaseNRF=thisbaseNRF,tenantID=url.id})>
	<cfelse>
		<cfset updateTenantStateBSF = oMICServices.updTenantStateBSF(theData={mBSFOrig=qryMedicaidHouse.mMedicaidBSF,mBaseNRF=thisbaseNRF,tenantID=url.id})>
	</cfif>
<cfelse>
	<cfset baseNRF = qryAptType.mAmount * 30.4>
	<cfif IsDefined('baseNRF') and IsNumeric(baseNRF)>
		<cfif (baseNRF gt 0)>
			<cfset thisbaseNRF = baseNRF>
		<cfelse>
			<cfset THISBASEnrf = 0>
		</cfif>
	<cfelse>
		<cfset THISBASEnrf = 0>
	</cfif>
	<cfset updateTenantStateBSF = oMICServices.updTenantStateBSF(theData={mBSFOrig=qryAptType.mAmount,mBaseNRF=thisbaseNRF,tenantID=url.id})>
</cfif>

<cfset qrySecDep = oMICServices.getSecDep(houseID=tenantType.iHouse_ID,chargeSet=tenantType.cChargeSet)>

<cfscript>
	stmp= DateFormat(now(),"mmddyy") & TimeFormat(now(),"HHmmss");
	if (NOT IsDefined("form.iCharge_ID")){
		if (IsDefined("url.MID") AND url.MID NEQ '') { 
			setAction = 'MoveInCredits.cfm?ID=#url.ID#&MID=#url.MID#&NrfDiscApprove=#NrfDiscApprove#';}  
		else { setAction = 'MoveInCredits.cfm?ID=#url.ID#&NrfDiscApprove=#NrfDiscApprove#'; 
		} Action = setAction;
	}
	else { Action = 'MoveInCreditInsert.cfm?NrfDiscApprove=#NrfDiscApprove#'; }
</cfscript>

<SCRIPT>
 	// CommFeePaymentSel CommFeePayment
	<cfif isDefined("form.DontSave")>
		function redirect() { window.location = "MoveInCredits.cfm?ID=#url.id#"; }
		function required() { 
			var failed = false;
			if (document.MoveInCredits.cDescription.value.length < 2){ (document.MoveInCredits.Message.value = "Enter Description"); 
			document.MoveInCredits.cDescription.focus();
				return false; }
			if (document.MoveInCredits.mAmount.value.length < 2){ (document.MoveInCredits.Message.value = "Enter Amount"); 
			document.MoveInCredits.mAmount.focus(); return false; }
		}

		function CreditNumbers(string) {
		for (var i=0, output='', valid="1234567890.-"; i<string.length; i++)
	       if (valid.indexOf(string.charAt(i)) != -1)
	          output += string.charAt(i)
	    return output;	
		} 
	<cfelse>
		function required() { /* no requirements */ }
	</cfif>
</SCRIPT>

<script type="text/javascript" src="../Assets/Javascript/MoveIn/MoveInCredits.js"></script> 
<!--- ==============================================================================
Include Shared JavaScript
=============================================================================== --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">
<!--- ==============================================================================
Include Retrieval of TenantInformation
=============================================================================== --->
<CFINCLUDE TEMPLATE="../Shared/Queries/TenantInformation.cfm">

<cfif isDefined("form.NewmAmount") AND tenantType.iResidencyType_ID IS NOT 2>	
	<cfset qryInvoiceMaster = oMICServices.getInvoiceMaster(invoiceDetailID=form.mAmountInvoiceDetailID)>
	<cfset  mNewmAmount = replace(form.NewmAmount, ',' ,'')>
	<cfset  mNewmAmount = replace(mNewmAmount, '$' ,'')>
	<cfif tenanttype.cbillingtype eq 'M' >
		<cfset updateInvoiceDetail = oMICServices.updInvoiceDetail(billingtype="M",amount=form.newMAmount,id=form.mAmountInvoiceDetailID,formData=form)>		
	<cfelse>
		<cfset updateInvoiceDetail = oMICServices.updInvoiceDetail(billingtype="D",amount=form.newMAmount,id=qryInvoiceMaster.iInvoiceMaster_ID,formData=form)>				
	</cfif>
	<cfset updateNewAmtDetail = oMICServices.updNewAmt(mBSFDisc=mNewmAmount,tenantID=url.id)>		
	<cfif isdefined("form.currentmonth")>
		<cfset session.currentMonth = form.currentMonth>
	</cfif>
</cfif>

<cfif isDefined("form.NewResidentFeeAmt")>
	<cfset tenantMonDef = oMICServices.getTenantMonDef(tenantID=url.id)>
	<cfset qryRecurrChgNewDef = oMICServices.getRecurrChg(houseID=tenantInfo.iHouse_id,chargeset=tenantInfo.cChargeset,tenantID=tenantinfo.iTenant_ID)>
	<cfset mNewResidentFeeAmt = replace(form.NewResidentFeeAmt, ',' ,'') >
	<cfset mNewResidentFeeAmt = replace(mNewResidentFeeAmt, '$' ,'')>
	<cfset updateInvoiceDetail = oMICServices.updInvoiceDetails(mAmount=mNewResidentFeeAmt,id=form.mAmountInvoiceDetailID)>
	<cfset updateNewNRFAmt = oMICServices.updNewNRFAmt(mAdjNRF=mNewResidentFeeAmt,tenantID=url.id)>
	<cfif tenantMonDef.iMonthsDeferred gt 1>
		<cfset newDeferred = ((#mNewResidentFeeAmt#/#tenantMonDef.iMonthsDeferred# * 100) / 100)>
	<cfelse>
		<cfset newDeferred = 0>
	</cfif>
	<cfif tenantMonDef.iMonthsDeferred gt 1>
		<cfset updNewDeferred = oMICServices.updNewDeferred(mAmtDeferred=newDeferred,tenantID=url.id)>
		<cfset updNewDeferredRC =oMICServices.updNewDeferredRC(mAmount=newDeferred,recurringID=qryRecurrChgNewDef.irecurringCharge_ID)>		
	</cfif>
	<cfif tenantMonDef.iMonthsDeferred is 0>
		<cfset updNewDeferred = oMICServices.updNewDeferredTS(tenantID=url.id)>
	</cfif>
</cfif>
<!--- ==============================================================================
Retrieve the service level according to the service points
=============================================================================== --->
<cfset GetSLevel = oMICServices.getSLevel(points=tenantInfo.iSPoints,LevelTypeSet=Val(tenantInfo.cSlevelTypeSet),sLevelTypeSet=session.cSLevelTypeSet)>
<!--- ==============================================================================
Retrieve list of all available credits (discounts) for the Move In
=============================================================================== --->
<cfset Additional = oMICServices.getAdditional(sLevelType=session.cSLevelTypeSet,chargeSet=qryHouseChargeset.ChargeSet,houseID=session.qSelectedHouse.iHouse_ID,codeblock=session.codeblock,qryData=tenantInfo,frmData=form)>
<!--- ==============================================================================
Retrieve the move in invoice number
if the invoice number was not passed via URL
=============================================================================== --->
<cfif ((Not isDefined("url.mid")) or (trim(url.mid) eq ""))>
	<cfset MoveInInvoice = oMICServices.getMoveInInvoice(tenantID=url.id)>
	<CFSET thisMID = MoveInInvoice.Master_ID>
<cfelse>
	<CFSET thisMID = url.MID>
</CFIF>
<cfset CommFeeInvoiceCount = oMICServices.getCommFeeInvoiceCount(id=thisMID)>
<!--- ==============================================================================
Retrieve all information in for this invoice
*, INV.cDescription as cDescription
=============================================================================== --->
<cfset GetInvoiceDetail = oMICServices.getInvoiceDetail(residentID=tenantInfo.cSolomonKey,residentTypeID=tenantInfo.iResidencyType_ID)>
<cfset CollectedApplicationFee = oMICServices.getCollectedApplicationFee(residentID=tenantInfo.cSolomonKey)>
<cfset GetNRF = oMICServices.getNRF(residentID=tenantInfo.cSolomonKey)>
<cfset FindOccupancy = oMICServices.getFindOccupancy(AddressID=tenantInfo.iAptAddress_ID,tenantID=TenantInfo.iTenant_ID)>
<cfscript>	
	if (FindOccupancy.RecordCount GT 0){ Occupancy = 2;} else {Occupancy = 1;} 
</cfscript>
<cfset DailyRent = oMICServices.getDailyRent(theData=tenantInfo,houseId=session.qSelectedHouse.iHouse_Id,occupancy=occupancy)>	 
<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../header.cfm">

<form NAME = "MoveInCredits" ACTION = "#Variables.Action#" METHOD = "POST" >
	<INPUT TYPE="Hidden" NAME="cSolomonKey" VALUE="#TenantInfo.cSolomonKey#" />
	<INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#TenantInfo.iTenant_ID#" />
	<input type="hidden" name="BSF" id="BSF" value="#DailyRent.mamount#" />
	<CFIF IsDefined("form.iCharge_ID") AND (Additional.bIsModifiableDescription GT 0 OR Additional.bIsModifiableAmount GT 0)>
		<INPUT NAME="Message" TYPE="TEXT" VALUE="" SIZE="75" STYLE="Color: Red; Font-Weight: bold; Font-Size: 16; text-align: center;">
	</CFIF>

	<TABLE>
		<TR>
			<TH COLSPAN=100%>Move In Charges</TH>
		</TR>
		<tr>
			<td colspan="4">Need help with a Move In? Select here: &nbsp;&nbsp;<img src="../../images/Move-In-Help.jpg" width="25" height="25" onclick="showHelp();" /></td>
		</tr>		
		<TR>
			<TD WIDTH=25%> Resident ID</TD>
			<TD WIDTH=25%> #TenantInfo.cSolomonKey#</TD>
			<TD WIDTH=25%> AptType</TD>
			<TD WIDTH=25%> #TenantInfo.RoomType#</TD>
		</TR>
		<TR>
			<TD> Resident's Name </TD>
			<TD> #TenantInfo.cFirstName#&nbsp;#TenantInfo.cLastName# </TD>
			<TD> Apt Number</TD>
			<TD> #TenantInfo.cAptNumber# </TD>
		</TR>
		<TR>
			<TD>Financial Possession Date</TD>
			<TD > #DATEFORMAT(TenantInfo.dtRentEffective,"mm/dd/yyyy")# </TD>
			<TD>Product Line:</TD>
			<TD>#tenantType.productDesc#</TD>
		</TR>
		<TR>
			<TD> Physical Move In Date </TD>
			<TD> #DATEFORMAT(TenantInfo.dtMoveIn,"mm/dd/yyyy")#</TD>
			<TD>Residency Type:</TD>
			<TD>#tenanttype.ResidentDesc#</TD>
		</TR>
		<TR>
			<cfif TenantInfo.dtMoveOutProjectedDate is not ''>
				<TD> Projected Physical Move Out Date</TD>
				<TD> #DATEFORMAT(TenantInfo.dtMoveOutProjectedDate ,"mm/dd/yyyy")#</TD>
			<cfelse>
				<td colspan="2">&nbsp;</td>
			</cfif>
			<TD> Service Level </TD>
			<TD> #GetSLevel.cDescription# </TD>
		</TR>		
	</TABLE>
	<TABLE>	
		<TR STYLE="text-align: center;">	
			<TD STYLE="font-weight: bold;">	Additional Charges:	</TD>
			<CFIF IsDefined("form.iCharge_ID") and form.iCharge_ID is not "">
				<cfif not isDefined("form.UpdateAmount")>
					<INPUT TYPE="Hidden" NAME="iCharge_ID" VALUE="#form.iCharge_ID#">
					<TD>
						<CFIF Additional.bIsModifiableDescription GT 0>	Description <BR> 
							<INPUT TYPE="text" NAME="cDescription" VALUE="#Additional.cDescription#" SIZE=#LEN(Additional.cDescription)# MAXLENGTH=15 onKeyUP="this.value=Letters(this.value);  Upper(this);">
						<CFELSE>
							#Additional.cDescription#
							 <INPUT TYPE="Hidden" NAME="cDescription" VALUE="#Additional.cDescription#" MAXLENGTH="15">
						</CFIF>
					</TD>
					<TD>
						<cfif ListContains(session.groupid,'192')>							
							<CFIF Additional.bIsModifiableAmount GT 0 OR listfindNocase(session.codeblock,25) GTE 1 OR listfindNocase(session.codeblock,23) GTE 1>
								Amount <BR> 
								<INPUT TYPE = "text" NAME="mAmount" id="mAmount" SIZE="10" STYLE="text-align:right;" VALUE="#TRIM(LSNumberFormat(Additional.mAmount, "99999.99"))#" onKeyUp="this.value=CreditNumbers(this.value);" onBlur="this.value=cent(round(this.value));">
							<CFELSE>
								#LSCurrencyFormat(Additional.mAmount)#
								<INPUT TYPE="Hidden" NAME="mAmount"  id="mAmount" VALUE="#TRIM(LSNumberFormat(Additional.mAmount, "99999.99"))#">
							</CFIF>
						<cfelseif ListContains(session.codeblock,'21')>	
							<CFIF Additional.bIsModifiableAmount GT 0  >Amount <BR> 
								<INPUT TYPE = "text" NAME="mAmount"  id="mAmount" SIZE="10" STYLE="text-align:right;" VALUE="#TRIM(LSNumberFormat(Additional.mAmount, "99999.99"))#" onKeyUp="this.value=CreditNumbers(this.value);"  onBlur="this.value=cent(round(this.value));">
							<CFELSE>
								#LSCurrencyFormat(Additional.mAmount)#
								<INPUT TYPE="Hidden" NAME="mAmount"  id="mAmount" VALUE="#TRIM(LSNumberFormat(Additional.mAmount, "99999.99"))#">
							</CFIF>
						<cfelse>
							<!--- MLAW 03/08/2006 Add condition for R&B rate and R&B discount, BisModifiableAmount is the field that determine if the charge is editable --->
							<CFIF Additional.bIsModifiableAmount GT 0 OR listfindNocase(session.codeblock,25) GTE 1 OR listfindNocase(session.codeblock,23) GTE 1>
								Amount <BR> <INPUT TYPE = "text" NAME="mAmount"  
								id="mAmount" SIZE="10" STYLE="text-align:right;" 
								VALUE="#TRIM(LSNumberFormat(Additional.mAmount, "99999.99"))#"  
								onKeyUp="this.value=CreditNumbers(this.value);" 
								onBlur="this.value=cent(round(this.value));" 
								onkeypress="return numbers(event)">
							<CFELSE>
								#LSCurrencyFormat(Additional.mAmount)#
								<INPUT TYPE="Hidden" NAME="mAmount"  id="mAmount" VALUE="#TRIM(LSNumberFormat(Additional.mAmount, "99999.99"))#" onkeypress="return numbers(event)">
							</CFIF>	
						</cfif>	
					</TD>
					<TD>
						<CFIF Additional.bIsModifiableQty GT 0>
							Quantity <BR> <INPUT TYPE="text" NAME="iQuantity" STYLE="text-align:center;" VALUE="#Additional.iQuantity#" SIZE=2 MAXLENGHT=2  onKeyUP="this.value=Numbers(this.value);">
						<CFELSE>
							Quantity (#Additional.iQuantity#)
						</CFIF>	
					</TD>
					<TD>&nbsp;</TD>
			       <!---</TR> --->
					<TR>
						<TD>&nbsp;</TD>
						<TD COLSPAN=100% STYLE="text-align: center;">Charge To Period:
							<SELECT NAME="ApplyToMonth">
								<CFLOOP INDEX=I FROM=1 TO=12 STEP=1>
									<CFIF I EQ Month(TenantInfo.dtMoveIn)>
										<CFSET Selected='SELECTED'>
									<CFELSE>
										<CFSET Selected=''>
									</CFIF>
									<CFIF Len(I) EQ 1>
										<CFSET N='0'&I>
									<CFELSE>
										<CFSET N=I>
									</CFIF>
									<OPTION VALUE="#N#" #SELECTED#>#N#</OPTION>
								</CFLOOP>
							</SELECT>
							<SELECT NAME="ApplyToYear">
								<OPTION VALUE="#Year(Now())#">#Year(Now())#</OPTION>
								<CFIF MONTH(Now()) EQ 1>
									<OPTION VALUE="#Year(DateAdd("yyyy",-1,Now()))#">#Year(DateAdd("yyyy",-1,Now()))#</OPTION>
								</CFIF>
								<OPTION VALUE="#Year(DateAdd("yyyy",+1,Now()))#">#Year(DateAdd("yyyy",+1,Now()))#
							</SELECT>
						</TD>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<td colspan="2">Is this a recurring (monthly) charge? 
							<input type="checkbox" name="ChargeIsRecurring" value="Yes" />
						</td>
					</tr>				
					<TR>
						<TD>&nbsp;</TD>
						<TD COLSPAN=100%>Comments:<BR>
							<TEXTAREA COLS="40" ROWS="2" NAME="cComments">
							</TEXTAREA>
						</TD>
					</TR>					
					<TR>
						<TD>&nbsp;</TD>
						<TD bordercolor="linen" style="text-align: left;"><INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save" VALUE="Save" onmouseover="chkAmount()"></TD>
						<TD>&nbsp;</TD>
						<TD><INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" onClick="redirect()"></TD>
						<TD>&nbsp;</TD>
					</TR>
				</cfif>
			<CFELSE>			
				<TD COLSPAN="3">
					<SELECT NAME="iCharge_ID">
						<OPTION VALUE=""> None </OPTION>
						<CFLOOP QUERY="Additional"> 
						<OPTION VALUE="#Additional.iCharge_ID#">	#Additional.cDescription# </OPTION>
						 </CFLOOP>
					</SELECT>					
					<INPUT TYPE="hidden" NAME="cDescription" VALUE="none">
					<INPUT TYPE="hidden" NAME="mAmount" VALUE="0.00">
				</TD>
				<TD><INPUT CLASS="DontSaveButton" TYPE="Submit" NAME="Add" VALUE="Add" 	onclick="return validatesel();">
				</TD>
			</CFIF>
		</TR>
		<TR>
			<TD COLSPAN=100% STYLE="font-weight: bold; color: red; bordercolor: linen; text-align: center;">
				 <U>NOTE:</U> Please VERIFY your entry below. 
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="1" STYLE="font-weight: bold;">	
				EXISTING CHARGES:	
			</TD>
			<TD COLSPAN="4" STYLE="font-weight: bold; color: red; text-align: right;">
				Charges shared with other residents appear in red.	
			</TD>
		</TR>
	</TABLE>
</form>
<CFSET INVOICETotal = 0>
<cfset CNT =0>
<TABLE>	
	<FORM NAME = "MoveInCredits" ACTION = "#Variables.Action#" METHOD = "POST">
		<TR STYLE="font-weight: bold; text-align: center;">
			<TD  style="background:##CCFFCC; " >Description	</TD>
			<TD  style="background:##CCFFCC; " >Effective Date	</TD>
			<cfif tenanttype.cbillingtype eq 'M'><TD  style="background:##CCFFCC; " >Monthly MC Rate</TD></cfif>	
			<TD style="background:##CCFFCC; "  >Amount Due</TD>
			<cfif tenanttype.cbillingtype neq 'M'><TD style="background:##CCFFCC; " >Qty</TD></cfif>
			<TD style="background:##CCFFCC; " >Applies To:</TD>
			<TD style="background:##CCFFCC; " >Corrections?</TD>
		</TR>		
		<CFLOOP QUERY="GetInvoiceDetail">
			<cfif tenantinfo.iresidencytype_id is 2>
				<cfset qryHouseMedicaid = oMICServices.getHouseMedicaid(houseID=tenantType.iHouse_ID)>
				<!--- the BSF Medicaid record is loaded with the base amount check if it should be adjusted for nbr of days in billing month --->
				<cfquery name="qryMonth" dbtype="query">
					select iquantity 
					from GetInvoiceDetail 
					where ichargetype_id = 8 
						and cappliestoacctperiod = '#GetInvoiceDetail.cAppliesToAcctPeriod#'
				</cfquery>
				<cfquery name="qryProrate" dbtype="query">
					select iinvoicedetail_id 
					from GetInvoiceDetail 
					where ichargetype_id = 31 
						and cappliestoacctperiod = '#GetInvoiceDetail.cAppliesToAcctPeriod#'
				</cfquery>			
				<cfif session.thisacctperiod1 is #GetInvoiceDetail.cAppliesToAcctPeriod#>
					<cfset ChgDays = #nbrDays1#>
					<cfset daysinmonth = daysinmonth1>				
				<cfelseif session.thisacctperiod2 is #GetInvoiceDetail.cAppliesToAcctPeriod#>
					<cfset ChgDays = #nbrdays2#>
					<cfset daysinmonth = daysinmonth2>
				</cfif>
				<cfif  (ichargetype_id is 31 ) and (GetInvoiceDetail.mamount neq 0)> 
					<cfset adjMedicaidBSF = #qryHouseMedicaid.mMedicaidBSF# * #ChgDays#/#daysinmonth#>
					<cfset updAdjBSF = oMICServices.updAdjBSF(amount=adjMedicaidBSF,invoicedetailID=qryProrate.iInvoiceDetail_Id)>		
				</cfif>
			</cfif>
			<cfset DepositLogCheck = oMICServices.getDepositLogCheck(tenantID=GetInvoiceDetail.iTenant_ID,desc=GetInvoiceDetail.cDescription,amount=GetInvoiceDetail.mAmount)>		
			<cfif ((tenantinfo.iresidencytype_id eq 1) or (tenantinfo.iresidencytype_id eq 3))> 
				<CFSCRIPT>
					if (GetInvoiceDetail.iTenant_ID EQ TenantInfo.iTenant_ID ) 
						{ Color='STYLE = "color: navy;"'; 
					INVOICETOTAL=InvoiceTotal+(GetInvoiceDetail.mAmount * GetInvoiceDetail.iQuantity); }
					else { Color = 'STYLE = "color: red;"'; INVOICETOTAL=InvoiceTotal+0; }
				</CFSCRIPT>
			<cfelse>
				<CFSCRIPT>
					if (GetInvoiceDetail.iTenant_ID EQ TenantInfo.iTenant_ID  and GetInvoiceDetail.iChargetype_id NEQ 8) 
						{ Color='STYLE = "color: navy;"'; 
							INVOICETOTAL=InvoiceTotal; }
					else { Color = 'STYLE = "color: red;"'; INVOICETOTAL=InvoiceTotal+0; }
				</CFSCRIPT>			
			</cfif>
			
			<CFIF DepositLogCheck.bLocked NEQ 1>
				<TR #COLOR#>
					<TD STYLE="width: 30%;"> #GetInvoiceDetail.cDescription#</TD>
					<TD>
						
						<cfif GetInvoiceDetail.iChargeType_ID is 91> 
							<cfif #ListGetAt(dateformat(GetInvoiceDetail.dtMovein,"mm/dd/yyyy"),"1","/")# EQ #RIGHT(GetInvoiceDetail.cAppliesToAcctPeriod,2)#>								
								<cfset tMIDate = GetInvoiceDetail.dtMovein>
							<cfelse>							
								<cfset tmonth = RIGHT(GetInvoiceDetail.cAppliesToAcctPeriod,2)>
								<cfset tyear = LEFT(GetInvoiceDetail.cAppliesToAcctPeriod,4)>
								<cfset tMIDate = CreateDate(tyear,tmonth,01)>
							</Cfif>							
							#dateFormat(tMIDate,"mm/dd/yyyy")#								
						<cfelse>
							<cfif #ListGetAt(dateformat(getInvoiceDetail.dtRentEffective,"mm/dd/yyyy"),"1","/")# EQ #RIGHT(GetInvoiceDetail.cAppliesToAcctPeriod,2)#>								
								<cfset tDate = getInvoiceDetail.dtRentEffective>
							<cfelse>							
								<cfset tmonth = RIGHT(GetInvoiceDetail.cAppliesToAcctPeriod,2)>
								<cfset tyear = LEFT(GetInvoiceDetail.cAppliesToAcctPeriod,4)>
								<cfset tDate = CreateDate(tyear,tmonth,01)>
							</Cfif>							
							#dateFormat(tDate,"mm/dd/yyyy")#								
						</cfif>  
					</TD>		         
					<cfif tenanttype.cbillingtype eq 'M'>	
						<TD>
							<cfif listFindNoCase("89,1682,1748,1756",#getInvoiceDetail.iChargeType_ID#,",")>				
								<cfif session.thisacctperiod1 is #GetInvoiceDetail.cAppliesToAcctPeriod#>
									<cfset StrMonth1 =  #left(session.thisacctperiod1,4)# & '-' & #right(session.thisacctperiod1,2)#  & '-01'  >
									<cfset DaysInMonth1 = #daysinmonth(StrMonth1)#>							
									<cfset daytocharge= #DaysInMonth(tenanttype.dtrenteffective)#-#day(tenanttype.dtrenteffective)#+1>
									<cfset changedmonthlyrate= round((#getInvoiceDetail.mamount#/#daytocharge#)*#DaysInMonth1#)>									
									<cfif tenanttype.iresidencytype_id eq 3>
										<cfset changedmonthlyrate= round((#getInvoiceDetail.mamount#/#daytocharge#)*30)>
									</cfif>		
								    <!--- input under Monthly MC Rate current month ---->
								    $<input type="text" name="currentMonth" id= "currentMonth" value=<cfif #changedmonthlyrate# NEQ #qryAptType.mAmount#>"#changedmonthlyrate#"<cfelse>"#numberformat(qryAptType.mAmount)#"</cfif> size="7"  onblur= <cfif tenanttype.iresidencytype_id eq 3> "monthlyrateCheckRespite();" <cfelse> "checkForZero(this.value,#cnt#,'#tenantType.cBillingType#');monthlyrateCheck();"</cfif> />
									<input type="hidden" name="DaysInMonth1" id="DaysInMonth1" value="#DaysInMonth1#"/>
									<input type="hidden" name="daytocharge" id="daytocharge" value="#daytocharge#"/>							
							   	<cfelseif session.thisacctperiod2 is #GetInvoiceDetail.cAppliesToAcctPeriod#>
							     	<cfset StrMonth2 =  #left(session.thisacctperiod2,4)# & '-' & #right(session.thisacctperiod2,2)#  & '-01'  >
								    <cfset daysinmonth2 = #daysinmonth(StrMonth2)#>						       
									<cfset daytocharge= #daysinmonth(StrMonth2)#>
									<!--- input for R&B under monthly MC Rate for future month --->		
									$<input type="text" name="nextMonth" id="nextMonth" size="7" value="<cfif #changedmonthlyrate# NEQ #qryAptType.mAmount#>#changedmonthlyrate#<cfelse>#numberformat(qryAptType.mAmount)#</cfif>" onblur="checkForZero(this.value,#cnt#,'#tenantType.cBillingType#');<cfif tenantType.iresidencyType_id EQ 3>monthlyrateCheck1Respit();<cfelse>monthlyrateCheck1();</cfif>"/>
									<input type="hidden" name="DaysInMonth" id="DaysInMonth2" value="#DaysInMonth2#"/>							
									<input type="hidden" name="daytocharge1" id="daytocharge2" value=<cfif tenanttype.iresidencytype_id eq 3>"#getInvoiceDetail.idaysbilled#"<cfelse>"#daytocharge#"</cfif>/>		  
								</cfif>
							</cfif>
						</TD>	
					</cfif>		
					<TD STYLE="text-align: right;"> 
					<cfif ( GetInvoiceDetail.iChargeType_ID is 89 or GetInvoiceDetail.iChargeType_ID is 7  or GetInvoiceDetail.iChargeType_ID is 1748	or GetInvoiceDetail.iChargeType_ID is 1682	or GetInvoiceDetail.iChargeType_ID is 1756)>
						<form method="post"  action="moveincredits.cfm?ID=#url.ID#&MID=#thisMID#&NrfDiscApprove=#NrfDiscApprove#">
							<input type="hidden" name="acctperiod" value="#cappliestoacctperiod#" />
							<input type="hidden" name="thisacctperiod1" value="#session.thisacctperiod1#" />
							<input type="hidden" name="thisacctperiod2" value="#session.thisacctperiod2#" /> 
							<input type="hidden" name="monthdays2" value="#nbrdays2#">
							<input type="hidden" name="monthdays1" value="#nbrdays1#">	
							<input type="hidden" name="mAmountInvoiceDetailID" value="#getInvoiceDetail.iInvoiceDetail_ID#">
							<input type="hidden" name="iChargeType_ID" value="#GetInvoiceDetail.iChargeType_ID#">
								<CFSCRIPT>
								CNT=CNT+1;
								</CFSCRIPT>	
								<!--- R&B under amount due --->
								<cfif tenantType.cBillingType EQ "M">
									$<input type="text" name="NewmAmount" id="NewmAmount#CNT#" 	value="#DecimalFormat(GetInvoiceDetail.mAmount)#" size="7" readonly="true" onfocus="alert('This field is readonly');"><BR>
								<cfelse>
									$<input type="text" name="NewmAmount" id="NewmAmount#CNT#" 	value="#DecimalFormat(GetInvoiceDetail.mAmount)#" size="7" onblur="checkForZero(this.value,#cnt#,'#tenantType.cBillingType#');rateCheck();" ><BR>
								</cfif>
								<font color="red"><b>*</b></font>
							<input type="submit" value="Update Amount" id="subBtn#CNT#" name="UpdateAmount" onClick="checkForZero('a',#cnt#,'#tenantType.cBillingType#');">
						</form>
					<cfelseif GetInvoiceDetail.iChargeType_ID is 1661 >	#dollarFormat(GetInvoiceDetail.mAmount)# 
					<cfelseif ( (GetInvoiceDetail.iChargeType_ID is 83)	or ( GetInvoiceDetail.iChargeType_ID is 57 ) or ( GetInvoiceDetail.iChargeType_ID is 69 ) or ( GetInvoiceDetail.iChargeType_ID is 53 ))>

				<form method="post" action="moveincredits.cfm?ID=#url.ID#&MID=#thisMID#&NrfDiscApprove=#NrfDiscApprove#">		
					<input type="hidden" name="acctperiod" value="#cappliestoacctperiod#" />
					<input type="hidden" name="thisacctperiod1" value="#session.thisacctperiod1#" />
					<input type="hidden" name="thisacctperiod2" value="#session.thisacctperiod2#" /> 
					<cfif ((GetInvoiceDetail.mAmount is 0.00) or (GetInvoiceDetail.mAmount is ''))>
						$<input type="text" name="NewResidentFeeAmt" id="NewResidentFeeAmt" value="#DecimalFormat(qrySecDep.mamount)#" size="7" onblur="rateCheck();"><BR>
					<cfelse>
						<!--- input for community fee under amount due --->
						$<input type="text" name="NewResidentFeeAmt" id="NewResidentFeeAmt" value="#DecimalFormat(GetInvoiceDetail.mAmount)#" size="7" onblur="rateCheck();"><BR>					
					</cfif>
					<input type="hidden" name="mAmountInvoiceDetailID" value="#getInvoiceDetail.iInvoiceDetail_ID#">
					<font color="red"><b>*</b></font>
					<input type="submit" id="subBtn#cnt#" value="Update Amount" name="UpdateAmount">
				</form>

				<cfelseif tenantinfo.iresidencytype_id is 2 and getinvoicedetail.ichargetype_id is 31 and (GetInvoiceDetail.mamount neq 0)> 
					#LSCurrencyFormat(adjMedicaidBSF)#
				<cfelse>
					#LSCurrencyFormat(GetInvoiceDetail.mAmount)#
				</cfif>
				</TD>
					<cfif tenanttype.cbillingtype neq 'M'><TD STYLE="text-align: center;"> #GetInvoiceDetail.iQuantity# </TD></cfif>
					<TD STYLE="text-align: center;">
						<CFIF GetInvoiceDetail.iTenant_ID NEQ TenantInfo.iTenant_ID>
							#GetInvoiceDetail.cFirstName# #GetInvoiceDetail.cLastName#
						<CFELSE> 
							#GetInvoiceDetail.cAppliesToAcctPeriod# 
						</CFIF>	
					</TD>
					<TD STYLE="text-align: center;" nowrap="nowrap">
						<CFIF GetInvoiceDetail.iRowStartUser_ID GT 0 
						AND (GetInvoiceDetail.iTenant_ID EQ #TenantInfo.iTenant_ID#)>
						
							<CFIF ( ((GetInvoiceDetail.irowstartuser_id neq 0) 
								OR (DepositLogCheck.RecordCount EQ 0 AND GetInvoiceDetail.iChargeType_ID NEQ 1 AND GetInvoiceDetail.iChargeType_ID NEQ 30 AND GetInvoiceDetail.cGLAccount NEQ 2210) ) 
									and  ((GetInvoiceDetail.iChargeType_ID NEQ 89)	and (GetInvoiceDetail.iChargeType_ID NEQ 7) and (GetInvoiceDetail.iChargeType_ID NEQ 91) and (GetInvoiceDetail.iChargeType_ID NEQ 1748) and (GetInvoiceDetail.iChargeType_ID NEQ 1682)))  >
						 
							<INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" 
							VALUE="Delete Now" 
							onClick="self.location.href='DeleteMoveInCredit.cfm?ID=#GetInvoiceDetail.iInvoiceDetail_ID#&MID=#thisMID#&acctperiod=#cappliestoacctperiod#&thisacctperiod1=#session.thisacctperiod1#&thisacctperiod2=#session.thisacctperiod2#&monthdays1=#nbrdays1#&monthdays2=#nbrdays2#'">	
							 <CFELSEIF DepositLogCheck.bLocked EQ 1>
								Collected
							<CFELSE>
								<A HREF="MoveInForm.cfm?ID=#TenantInfo.iTenant_ID#" >
								Rtn to Move-In Form</A>
								 <!--- onmouseover="showRtnNote()" --->
							</CFIF>
							<CFELSEIF GetInvoiceDetail.iTenant_ID NEQ #TenantInfo.iTenant_ID#>		
						*
						<CFELSE>
							<A HREF = "MoveInForm.cfm?ID=#TenantInfo.iTenant_ID#" >
							Rtn to Move-In Form</A>
							 <!--- onmouseover="showRtnNote()" --->
							<CFIF ((GetInvoiceDetail.iChargeType_ID NEQ 89) and (GetInvoiceDetail.iChargeType_ID NEQ 7) and (GetInvoiceDetail.iChargeType_ID NEQ 91) and (GetInvoiceDetail.iChargeType_ID NEQ 69) and (GetInvoiceDetail.iChargeType_ID NEQ 53) and (GetInvoiceDetail.iChargeType_ID NEQ 1748) and (GetInvoiceDetail.iChargeType_ID NEQ 1682)) >
							<INPUT CLASS="BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Charge" onClick="self.location.href='DeleteMoveInCredit.cfm?ID=#GetInvoiceDetail.iInvoiceDetail_ID#&MID=#thisMID#&acctperiod=#cappliestoacctperiod#&thisacctperiod1=#session.thisacctperiod1#&thisacctperiod2=#session.thisacctperiod2#&monthdays1=#nbrdays1#&monthdays2=#nbrdays2#'">
							</CFIF>
						</CFIF>
						</TD>
				</TR>

			</CFIF> 
		</CFLOOP>		

		<cfif  ((CommFeeInvoiceCount.EntryCount gt 0) and (CommFeeInvoiceCount.ichargetype_id is 69))>
				<form name="UpdCommFeePymnt" method="post" action="UpdCommFeePymnt.cfm" >
				<tr>
					<td colspan="4">Select Community Fee Payments:
						
					<input type="hidden" name="thisacctperiod1" value="#session.thisacctperiod1#" />
					<input type="hidden" name="thisacctperiod2" value="#session.thisacctperiod2#" />
						<input type="hidden" name="itenant_id" id="itenant_id"  value="#url.ID#"/>		
						<input type="hidden" name="iInvoiceMaster_ID" id="iInvoiceMaster_ID"
							  value="#thisMID#"/>	
										
						<select name="CommFeePaymentSel"  id="CommFeePaymentSel" >  
							<cfif tenantinfo.iMonthsDeferred gt 0>
								<option value="#tenantinfo.iMonthsDeferred#" selected="selected">
								#tenantinfo.iMonthsDeferred#
								</option>
							<option value="1" >1</option>
							<option value="2" >2</option>
							<option value="3" >3</option>								
							<cfelse>
							<option value="1" selected="selected" >1</option>
							<option value="2" >2</option>
							<option value="3" >3</option>
							</cfif>							
						</select>
						( 1 - 3 Months)
					</td>
					<td colspan="2"><input name="updCommPymnt" type="submit" 
						value="Update Number of Payments" />
					</td>
				</tr>
				</form>
			</cfif>
		<cfif tenantinfo.iresidencytype_id eq 2>
			<cfset getNewInvoiceDetail = oMICServices.getNewInvoiceDetail(residentId=tenantInfo.cSolomonKey)>
		</cfif>			
		<cfif tenanttype.iresidencytype_id is not 2>
		<tr>
			<td colspan="100%" style="color:##FF0000; text-align:left; font-weight:bold">
			Note: Update Basic Service Fee and Community Fee separately using the appropriate "Update Amount" buttons.<br /> Make all charge changes and corrections BEFORE selecting the "Continue" button.<br />Any Changes to Basic Service Fee or Community Fee will be lost if you Return to the Main Move In page or re-start this Move In. <br />If appropriate, update the number of payments the Community Fee will be spread over, the first payment will be included with the Move-In Invoice.
			</td>
		</tr>
		</cfif>

		<TR>
			<TD COLSPAN=100% STYLE="border-bottom: 1px solid black;"></TD>&nbsp;
		</TR>
	<cfif 	((tenantinfo.iresidencytype_id is 1) or (tenantinfo.iresidencytype_id is 3))>
		<TR STYLE="font-weight: bold;">
			<TD>Total</TD>
			<TD STYLE="text-align: right;">#LSCurrencyFormat(Variables.INVOICETotal)#</TD>
			<TD COLSPAN=3>&nbsp;</TD>
		</TR>
	<cfelseif	(tenantinfo.iresidencytype_id is 2)>
		<TR STYLE="font-weight: bold;">
			<TD>Total</TD>
			<TD STYLE="text-align: right;">#LSCurrencyFormat(GetNewInvoiceDetail.MedInvTotal)#</TD>
			<TD COLSPAN=3>&nbsp;</TD>
		</TR>
	</cfif>
		<tr>
			<td colspan="100%" style="text-align: right;">
				<cfif isDefined("url.mid") and trim(url.mid) neq "">
					<cfset master=trim(url.mid)>
				<cfelse>
					<cfset master=getInvoiceDetail.iinvoicemaster_id>
				</cfif>
				<input type="button" name="Continue" 
				value="Continue" 
				onmouseover ="return hardhaltmonthlyrate();"
				onClick="self.location.href='MoveInSummary.cfm?ID=#TenantInfo.iTenant_ID#&MID=#master#&stmp=#stmp#&NrfDiscApprove=#NrfDiscApprove#&CommFeePayment=#CommFeePayment#'; ">
			</td>
		</tr>
	</table>
</FORM>
<div style="color:##FF0000; font-weight:bold; font-size:smaller">
	<cfif tenantinfo.iresidencytype_id is not 2>
	  <cfif listfindNocase(session.codeblock,25) GTE 1 OR listfindNocase(session.codeblock,23) GTE 1>
		*Changing the Basic Service Fee here will also change the Basic Service Fee recurring rate
	  </cfif>	
	</cfif>
	<cfif tenantinfo.iresidencytype_id is 2>
		"State Medicaid" entry is shown for reference only, it is not included in Invoice Total
	</cfif>
</div>
</CFOUTPUT>
<CFINCLUDE TEMPLATE="../../footer.cfm">