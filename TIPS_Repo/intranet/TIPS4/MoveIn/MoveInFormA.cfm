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
----------------------------------------------------------------------------------------------->

<!--- Check to see if the chosen tenant has a move in date. --->
<cfparam name="defpymntamt" default="0">
<cfparam name="NewNRFee"    default="0">
<cfparam name="adjamount"   default="0">
<cfparam name="discamount"  default="0">
<cfparam name="NrfDiscApprove" default="">
<cfset todaysdate = CreateODBCDateTime(now())>




<cfquery name="RegCheck" datasource="#APPLICATION.datasource#">
	select dtMoveIn from tenantstate where dtrowdeleted is null and iTenant_ID = #url.ID# and dtMoveIn is not null
</cfquery>

<cfscript>
	Action = iif(RegCheck.RecordCount LTE 0,DE('MoveInFormInsert.cfm'),DE('MoveInFormUpdate.cfm'));
</cfscript>

<script language="JavaScript" src="../../global/calendar/ts_picker_Validate.js" type="text/javascript"></script>



<cfquery name="Tenant" datasource= "#APPLICATION.datasource#">
	Select iTenantStateCode_ID, t.itenant_ID, cSolomonkey, cBillingType, cSLevelTypeSet, iResidencyType_ID,ts.itenantstate_id,
		cFirstName, cLastName, cSSN, dBirthDate, cOutsideAddressLine1, cOutsideAddressLine2, cOutsideCity, cOutsideStateCode, cOutsideZipCode,
		bIsPayer, bisprimarypayer, bMICheckReceived, cResidenceAgreement, cResidentFee, bDeferredPayment, bAppFeePaid, cMiddleInitial, 
		cPreviousAddressLine1, cPreviousAddressLine2, dtBondCert, bIsBond, chasExecutor, ts.cMilitaryVA, ts.iMonthsDeferred, ts.mAmtDeferred,
		ts.bIsNRFDeferred, ts.mBaseNRF, ts.MADJNRF, cPreviousCity, cpreviouszipcode
	From Tenant T
	Join TenantState TS on T.iTenant_ID = TS.iTenant_ID and TS.dtRowDeleted is null
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
	
	Where  iTenant_ID = #Url.ID#
</cfquery>

<cfquery name="qryRC1740" datasource="#Application.datasource#"> 
	select iRecurringCharge_ID
	from RecurringCharge
		where iTenant_ID= #Url.ID#
			and iCharge_ID = 1740
</cfquery>

<cfquery name="qryRC1741" datasource="#Application.datasource#"> 
	select iRecurringCharge_ID
	from RecurringCharge
		where iTenant_ID= #Url.ID#
			and iCharge_ID = 1741
</cfquery>

<cfif qryRC1740.iRecurringCharge_ID is not "">
	<cfquery name="delNRFhg" datasource="#Application.datasource#">
		UPDATE RecurringCharge
		SET
			dtRowDeleted = #todaysdate#
			,iRowDeletedUser_ID = #session.username# 
		where 
			iRecurringCharge_ID = #qryRC1740.iRecurringCharge_ID#
				AND iTenant_ID= #Url.ID#
				and iCharge_ID = 1740
	</cfquery>
</cfif>

<cfif qryRC1741.iRecurringCharge_ID is not "">
	<cfquery name="delNRFhg" datasource="#Application.datasource#">
		UPDATE RecurringCharge
		SET
			dtRowDeleted = #todaysdate#
			,iRowDeletedUser_ID = #session.username# 
		where 
			iRecurringCharge_ID = #qryRC1741.iRecurringCharge_ID#
				AND iTenant_ID= #Url.ID#
				and iCharge_ID = 1741
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
	From diagnosistype 
	Where dtRowDeleted is null	
</cfquery>

<!--- Get promotion Codes --->
<cfquery name="qTenantPromotion" datasource="#Application.datasource#">
	Select iPromotion_ID, cDescription 
	From TenantPromotionSet 
	Where dtRowDeleted is null 
</cfquery>

<!--- retrieve house product line info --->
<cfquery name="qproductline" datasource="#application.datasource#">
	select pl.iproductline_id, pl.cdescription
	from houseproductline hpl
	join productline pl on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
	where hpl.dtrowdeleted is null and hpl.ihouse_id = #session.qselectedhouse.ihouse_id#
</cfquery>

<!--- retrieve residency types --->
<cfquery name="residency" datasource="#application.datasource#">
	select rt.iresidencytype_id ,rt.cdescription ,pl.iproductline_id ,plrt.iproductlineresidencytype_id
	from houseproductline hpl
	join productline pl on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
	join ProductLineResidencyType plrt on plrt.iproductline_id = pl.iproductline_id and plrt.dtrowdeleted is null
	join residencytype rt on rt.iresidencytype_id = plrt.iresidencytype_id and rt.dtrowdeleted is null
	where hpl.dtrowdeleted is null and hpl.ihouse_id = #session.qselectedhouse.ihouse_id#
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
    From assessmenttoolmaster am 
    where am.dtrowdeleted is null
    	and am.bfinalized = 1
		and am.bBillingActive = 1
    	and itenant_id = #trim(tenant.itenant_id)#
</cfquery>

<!--- query for prior move in invoice --->
<cfquery name='qPriorMI' datasource="#APPLICATION.datasource#">
	select distinct im.iinvoicemaster_id
	from invoicemaster im
	left join invoicedetail inv on inv.iinvoicemaster_id = im.iinvoicemaster_id and  im.dtrowdeleted is null and inv.dtrowdeleted is null and inv.itenant_id = #tenant.itenant_id#
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
  FROM  ALCWeb.dbo.Employees  
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
  FROM  ALCWeb.dbo.Employees
  where JobTitle like '%President%'   and dtrowdeleted is null
</cfquery>

<CFQUERY NAME="GetNRF" DATASOURCE="#APPLICATION.datasource#"> 
		select c.mamount as NRF 
	from Charges c 
	join ChargeType ct on (ct.iChargeType_ID = c.iChargeType_ID)
	where c.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
	and c.cChargeSet = (select cs.cName 
	from Chargeset cs 
	join House h on (h.iChargeSet_ID = cs.iChargeSet_ID and h.iHouse_ID = #session.qSelectedHouse.iHouse_ID#))
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
	select bIsPDClosed from HouseLog where iHouse_ID = #session.qSelectedHouse.iHouse_ID# and dtRowDeleted is null
</cfquery>

<!--- Retrieve the any house specific Deposits --->
<cfquery name="qHouseDeposits" datasource="#APPLICATION.datasource#">
	select ct.* from ChargeType ct 
	join Charges C on (c.iChargeType_ID = ct.iChargeType_ID and c.dtRowDeleted is null)
	where ct.dtRowDeleted is null and bIsDeposit is not null and c.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
</cfquery>

<!--- Retrieve all DepositTypes that are Refundable  --->
<cfquery name= "Refundables" datasource = "#APPLICATION.datasource#">
	select ct.*, c.cDescription as cDescription, c.iCharge_ID
	from ChargeType ct 
	join Charges C on (c.iChargeType_ID = ct.iChargeType_ID and c.dtRowDeleted is null)
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
</cfquery>

<!--- Retreivea all DepositTypes that are Fees (Non-Refundable) --->
<cfquery name="Fees" datasource="#APPLICATION.datasource#">
	select ct.*, c.cDescription as cDescription, c.iCharge_ID
	from ChargeType ct 
	join Charges C on (c.iChargeType_ID = ct.iChargeType_ID and c.dtRowDeleted is null)
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
	from Charges c
	join 	ChargeType ct on c.iChargeType_ID = ct.iChargeType_ID
	where (iHouse_ID is null or c.iHouse_ID=#session.qSelectedHouse.iHouse_ID#)
	and	c.dtRowDeleted is null and c.mAmount < 1
	<cfif IsDefined("url.Charges")> 
		and c.iCharge_ID = #url.Charges# 
	</cfif>
</cfquery>



<cfquery name="bondhouse" datasource="#application.datasource#">
  	select iBondHouse, bBondHouseType from house  where ihouse_id =  #session.qSelectedHouse.iHouse_ID#
 </cfquery>

<cfquery name="Occupied" datasource="#APPLICATION.datasource#">
	select distinct TS.iAptAddress_ID 
	from TenantState TS
	join Tenant T on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
	join AptAddress AD on AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null
	where TS.dtRowDeleted is null 
	and	TS.iTenantStateCode_ID = 2
	and	AD.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
</cfquery>
<cfset OccupiedList=ValueList(Occupied.iAptAddress_ID)>
 <cfif bondhouse.iBondHouse eq 1>
				
				<!--- Apartment List applicable for Bond Tenant Use --->
				<cfquery name="BondAppAptList" datasource="#APPLICATION.datasource#">
					select aa.*,at1.*
					from AptAddress aa
					join apttype at1 on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
					where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and aa.bBondIncluded = 1
					and aa.dtRowDeleted is null
				</cfquery>
				<cfset BondIncludedAptList = ValueList(BondAppAptList.iAptAddress_ID)>
				<!--- Apartment List of apartments set as bond ---> 
				<cfquery name="BondAptList" datasource="#APPLICATION.datasource#">
					select aa.*,at1.* 
					from AptAddress aa
					join apttype at1 on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
					where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and aa.bIsBond = 1
					and aa.dtRowDeleted is null
				</cfquery>
				<cfset BondAptList = ValueList(BondAptList.iAptAddress_ID)>
				<!--- Count of current bond designated apts --->
				<cfquery name="bAptCount" datasource="#APPLICATION.datasource#">
					select count(AA.iAptAddress_ID) as B 
					from AptAddress AA 
					where AA.bIsBond = 1
					and AA.dtrowdeleted is null
					and AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				</cfquery>
				<!--- Count of apts that were built and apply to the bond designation --->
				<cfquery name="AptCountTot" datasource="#APPLICATION.datasource#">
					select count(AA.iAptAddress_ID) as T 
					from AptAddress AA 
					where AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and AA.bBondIncluded = 1
					and AA.dtrowdeleted is null
				</cfquery>
				<!--- Apartment addresses that are occupied and pertain to bond applicable --->
				<cfquery name="Occupied" datasource="#APPLICATION.datasource#">
					select distinct TS.iAptAddress_ID
					from TIPS4.dbo.AptAddress aa, TIPS4.dbo.tenant te, TIPS4.dbo.TenantState TS 
					join TIPS4.dbo.Tenant T on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
					join TIPS4.dbo.AptAddress AD on AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null
					where TS.dtRowDeleted is null
					and TS.iTenantStateCode_ID = 2
					and AD.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and TS.iAptAddress_ID = aa.iAptAddress_ID 
					and te.iTenant_ID = ts.iTenant_ID
					and aa.bBondIncluded = 1
				</cfquery>
				<cfset OccupiedRowCount = (Occupied.recordcount)>

</cfif>
<cfquery name="qryAptType" datasource="#APPLICATION.datasource#">
	select  aa.iAptAddress_ID ,
	aa.iAptType_ID, aa.cAptNumber
	,chg.mamount
	,at.cdescription
	,chg.ichargetype_id
	,ct.cdescription
	  from charges  chg
	join house h on chg.ihouse_id = h.ihouse_id
	join chargeset chgst on h.ichargeset_id = chgst.ichargeset_id
	join dbo.AptAddress AA on aa.ihouse_id = chg.ihouse_id
	join dbo.AptType AT on aa.iAptType_ID = at.iAptType_ID
	join dbo.ChargeType ct on ct.ichargetype_id = chg.ichargetype_id
	where chg.ihouse_id = #session.qselectedhouse.ihouse_id# and chg.cchargeset = chgst.cname 
	and chg.ichargetype_id in (7, 8,31,89)
	and chg.dtrowdeleted is null
	and aa.dtrowdeleted is null
</cfquery>

<script language="JavaScript" type="text/javascript">
 	var	df0=document.forms[0];
	var vWinCal;
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
	
 	function nrfDefApp(NewRFApp){
 
//	 	if (NewRFApp.value=="1"){
//	 	document.getElementById("NRFApp").style.display='block';
//	 	document.getElementById("NRFApprover").style.display='block';		
//	 	}
//	 	else
//	 	{
//	 	document.getElementById("NRFApp").style.display='none';
//	 	document.getElementById("NRFApprover").style.display='none';
//	 	}
					for(j=0;j<MoveInForm.NRFDeferral.length;j++){  
						if(MoveInForm.NRFDeferral[j].checked)
						{
							if(MoveInForm.NRFDeferral[j].value == 1){
							var rfapp = true;
							}
							else{ 
							var rfapp = false;
							}
						}
						if (rfapp){	;
								document.getElementById("NRFApp").style.display = 'block';
							//	document.getElementById("NRFApprover").style.display = 'block';						
						}
						else {
								document.getElementById("NRFApp").style.display='none';
							 	document.getElementById("iChargeType_ID").value = '';	
							 	document.getElementById("MonthstoPay").value = 0;										
						}
					}
 	}	

 	function NRFAdjApp(NewRFAdj){
	 	if (NewRFAdj.value=="1"){
	 	document.getElementById("NRFAdjAmount").style.display='block';
	//document.getElementById("NRFApprover").style.display='block';		
	 	}
	 	else
	 	{
	 	document.getElementById("NRFAdjAmount").style.display='none';
		document.getElementById('NewNRFee').value =  cent(round(document.getElementById('nrfee').value));
	 	}
 	}	
 	
	function validatePMO(){
		var PMODate = document.getElementById("dtmoveoutprojecteddate").value;
		PMODate = new Date(PMODate);
		var AllowDate = document.getElementById("RentMonth").value + '/'+ document.getElementById("RentDay").value + '/' + document.getElementById("RentYear").value;
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
			
			document.getElementById("Mes").style.display='block';
			return false;	
		}
		else
			{document.getElementById("Mes").style.display='none';
			return true;}
	}
function ResetNrf()
{
	document.getElementById("NrfDiscApprove").value = '';	
 	document.getElementById("paymnt1").style.display="none";  
 	document.getElementById("paymnt2").style.display="none"; 
	document.getElementById("paymnt3").style.display="none";  
 	document.getElementById("paymnt4").style.display="none"; 
	document.getElementById("paymnt5").style.display="none"; 
 	document.getElementById("paymnt6").style.display="none"; 
	document.getElementById("paymnt7").style.display="none";  
 	document.getElementById("paymnt8").style.display="none"; 
	document.getElementById("paymnt9").style.display="none"; 
 	document.getElementById('payment1').value = 0;
 	document.getElementById('rembalance1').value = 0;
 	document.getElementById('dtpayment1').value = '';
 	document.getElementById('payment2').value = 0;
 	document.getElementById('rembalance2').value = 0;
 	document.getElementById('dtpayment2').value = '';	
 	document.getElementById('payment3').value = 0;
 	document.getElementById('rembalance3').value = 0;
 	document.getElementById('dtpayment3').value = '';	
 	document.getElementById('payment4').value = 0;
 	document.getElementById('rembalance4').value = 0;
 	document.getElementById('dtpayment4').value = '';
 	document.getElementById('payment5').value = 0;
 	document.getElementById('rembalance5').value = 0;
 	document.getElementById('dtpayment5').value = '';	
 	document.getElementById('payment6').value = 0;
 	document.getElementById('rembalance6').value = 0;
 	document.getElementById('dtpayment6').value = '';	
 	document.getElementById('payment7').value = 0;
 	document.getElementById('rembalance7').value = 0;
 	document.getElementById('dtpayment7').value = '';	
 	document.getElementById('payment8').value = 0;
 	document.getElementById('rembalance8').value = 0;
 	document.getElementById('dtpayment8').value = '';	
 	document.getElementById('payment9').value = 0;
 	document.getElementById('rembalance9').value = 0;
 	document.getElementById('dtpayment9').value = '';	
	document.getElementById('amtpaid').value = 0;
	document.getElementById('NewNRFee').value =0;
	document.getElementById('amtdef').value =0;
	document.getElementById('mcalcrembalance').value =0;
	document.getElementById('adjamount').value =0;
	document.getElementById('discamount').value =0;
	document.getElementById("MonthstoPay").value = 0;
 	document.getElementById('defEndDate').value = '';	
 	document.getElementById('dispEndDate').value  = '';	 
 	document.getElementById('defpymntamt').value  = '';	
 	document.getElementById('nrfZeroApprove').value  = '';	
 	document.getElementById('nrfApprove').value  = '';	
 	document.getElementById('mAmount').value  = 0;	
 	document.getElementById('NrfAdj').value  = 0;	
 	document.getElementById('NrfDisc').value  = 0;				
}	

function TenantCheck()
	{ if (!document.MoveInForm.cNRFFee.checked)
		document.getElementById("NRFDscAmt").style.display='none';		
		document.getElementById("NRFDef").style.display='none';		 
		document.getElementById("iResidencyTypeID").focus();
		alert('Please select Residency Type BEFORE selecting New Resident Fee');		 
	}
 function calcenddate()
{ 
  if (round(document.getElementById("mAmount").value) >=  round(document.getElementById("NewNRFee").value))
	{
  	alert('Amount Paid MUST BE LESS than the amount of the New Resident Fee!');
	document.getElementById("mAmount").style.background = 'white';	
	document.getElementById("mAmount").focus();
	return false;
	}
  else
{
  
 //	alert(document.getElementById('MonthstoPay').value);
 	document.getElementById("paymnt1").style.display="none";  
 	document.getElementById("paymnt2").style.display="none"; 
	document.getElementById("paymnt3").style.display="none";  
 	document.getElementById("paymnt4").style.display="none"; 
	document.getElementById("paymnt5").style.display="none"; 
 	document.getElementById("paymnt6").style.display="none"; 
	document.getElementById("paymnt7").style.display="none";  
 	document.getElementById("paymnt8").style.display="none"; 
	document.getElementById("paymnt9").style.display="none"; 
 	document.getElementById('payment1').value = 0;
 	document.getElementById('rembalance1').value = 0;
 	document.getElementById('dtpayment1').value = '';
 	document.getElementById('payment2').value = 0;
 	document.getElementById('rembalance2').value = 0;
 	document.getElementById('dtpayment2').value = '';	
 	document.getElementById('payment3').value = 0;
 	document.getElementById('rembalance3').value = 0;
 	document.getElementById('dtpayment3').value = '';	
 	document.getElementById('payment4').value = 0;
 	document.getElementById('rembalance4').value = 0;
 	document.getElementById('dtpayment4').value = '';
 	document.getElementById('payment5').value = 0;
 	document.getElementById('rembalance5').value = 0;
 	document.getElementById('dtpayment5').value = '';	
 	document.getElementById('payment6').value = 0;
 	document.getElementById('rembalance6').value = 0;
 	document.getElementById('dtpayment6').value = '';	
 	document.getElementById('payment7').value = 0;
 	document.getElementById('rembalance7').value = 0;
 	document.getElementById('dtpayment7').value = '';	
 	document.getElementById('payment8').value = 0;
 	document.getElementById('rembalance8').value = 0;
 	document.getElementById('dtpayment8').value = '';	
 	document.getElementById('payment9').value = 0;
 	document.getElementById('rembalance9').value = 0;
 	document.getElementById('dtpayment9').value = '';	
 
   var months = new Array(13);
   months[0]  = "January";
   months[1]  = "February";
   months[2]  = "March";
   months[3]  = "April";
   months[4]  = "May";
   months[5]  = "June";
   months[6]  = "July";
   months[7]  = "August";
   months[8]  = "September";
   months[9]  = "October";
   months[10] = "November";
   months[11] = "December";
	var endPayYear = 0;	  
	var endPayMonth = 0;	  
 	var nbrMonths =  document.getElementById('MonthstoPay');
	if (nbrMonths == '')
	 nbrMonths = 1; 

 	var strMonth  =  document.getElementById('ApplyToMonthA');
 
 	var strYear  =  document.getElementById('ApplyToYearA');	
  //	var y		  =  document.getElementById("ApplyToYearA").options;
    var MonToPay = nbrMonths.options[nbrMonths.selectedIndex].text;	

 //	var MonStart = strMonth.options[strMonth.selectedIndex].text;

 //	var YrStart = strYear.options[strYear.selectedIndex].text;

    endPayMonth =    Number(MonToPay)   +  Number(strMonth.value) -1;
 //   	alert( MonToPay  + ' :: ' +  strYear.value  + ' :: ' + strMonth.value  + ' ' + endPayMonth + ' ' + endPayYear);
	if (document.getElementById('mAmount').value == ''){
		alert('Please enter the amount of the NRF that was paid');
 		document.getElementById("mAmount").focus();
		return false;
	}
  	var  endPayMonthL = endPayMonth.length;	
 	if (endPayMonth > 12)
 	 	{
			endPayMonth = endPayMonth - 12;
  			if (endPayMonth < 10)
				{endPayMonth = String('0') + String(endPayMonth);}
			endPayYear  = Number(strYear.value) + 1;
			 //   	alert('A ' + endPayMonthL + ' :: ' +  MonToPay  + ' :: ' +  strYear.value  + ' :: ' + strMonth.value  + ' ' + endPayMonth + ' ' + endPayYear);	
    	}
  	else if (endPayMonth <= 12)
  		{
   			if (endPayMonth < 10)
  			{endPayMonth = String('0') + String(endPayMonth);}
			endPayYear  = Number(strYear.value);
    //	alert('B '  + endPayMonthL   + ' :: ' +    MonToPay  + ' :: ' +  strYear.value  + ' :: ' + strMonth.value  + ' ' + endPayMonth + ' ' + endPayYear);				
  		}
  	else
 	{endPayMonth =  String(endPayMonth);
   // 	alert('C ' + endPayMonthL   + ' :: ' +  MonToPay  + ' :: ' +  strYear.value  + ' :: ' + strMonth.value  + ' ' + endPayMonth + ' ' + endPayYear);		
	}

 	YrStart = String(strYear.value);
  	newPayDate = 	endPayMonth + YrStart;
   	document.getElementById('defEndDate').value = endPayMonth + '' + endPayYear;;	
	document.getElementById('dispEndDate').value  = endPayMonth + '-' + endPayYear; 	
 
   	document.getElementById('amtpaid').value =    document.getElementById('mAmount').value;
 	amtdef = document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value;
	payamt =  (document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value;
    nbrmnth = nbrMonths.value;
	document.getElementById('amtdef').value =      cent(round(amtdef)) ;
    document.getElementById('defpymntamt').value =    	cent(round((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value)); 	
	document.getElementById('mcalcrembalance').value = 	(document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value;
	newbal = amtdef - ((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value);

var YrStartdisp = YrStart; 
var nbrofMonth = 0; 
var i=0;
for (i=0;i<=nbrmnth-1;i++)
{
//alert(nbrmnth + ' ' +  i );
	if  (i == 0)
	{
	document.getElementById("paymnt1").style.display="block";

	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1));	
// 	alert(i + " : " + payamt + " : " + newbal  + " : " +  Number(strMonth.value));
	document.getElementById('payment1').value = cent(round(payamt));
	document.getElementById('rembalance1').value = cent(round(newbal)) ;
	document.getElementById('dtpayment1').value = months[Number(strMonth.value)-1] + ', ' + YrStartdisp  ;
 	}
	else if  (i == 1)
	{
		document.getElementById("paymnt2").style.display="block";
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 //	 	alert(i + " : " + payamt + " : " + newbal + " : " +  months[nbrofMonth] + ', ' + YrStartdisp);
	document.getElementById('payment2').value = cent(round(payamt));
	document.getElementById('rembalance2').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = YrStart + 1;}	
	document.getElementById('dtpayment2').value = months[nbrofMonth] + ', ' + YrStartdisp ;
	}
	else if  (i == 2)
	{
	document.getElementById("paymnt3").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 // 		alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment3').value = cent(round(payamt));
	document.getElementById('rembalance3').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment3').value = months[nbrofMonth] + ', ' + YrStartdisp ;	
	}	
	else if  (i == 3)
	{
	document.getElementById("paymnt4").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 //	 	alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment4').value = cent(round(payamt));
	document.getElementById('rembalance4').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment4').value = months[nbrofMonth] + ', ' + YrStartdisp ;		
	}	
	else if  (i == 4)
	{
	document.getElementById("paymnt5").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 // 		alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment5').value = cent(round(payamt));
	document.getElementById('rembalance5').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment5').value = months[nbrofMonth] + ', ' + YrStartdisp ;		
	}
	else if  (i == 5)
	{
	document.getElementById("paymnt6").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 //	 	alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment6').value = cent(round(payamt));
	document.getElementById('rembalance6').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment6').value = months[nbrofMonth] + ', ' + YrStartdisp ;	
	}	
	else if  (i == 6)
	{
	document.getElementById("paymnt7").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 //	 	alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment7').value = cent(round(payamt));
	document.getElementById('rembalance7').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment7').value = months[nbrofMonth] + ', ' + YrStartdisp ;	
	}		
	else if  (i == 7)
	{
	document.getElementById("paymnt8").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 //	 	alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment8').value = cent(round(payamt));
	document.getElementById('rembalance8').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment8').value = months[nbrofMonth] + ', ' + YrStartdisp ;
	}	
	else if  (i == 8)
	{
	document.getElementById("paymnt9").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
// 	 alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment9').value = cent(round(payamt));
	document.getElementById('rembalance9').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment9').value = months[nbrofMonth] + ', ' + YrStartdisp ;	
	}	
}
}
} // end function calcenddate   
function NRFWaiveY(pdwvd)    
	{
//		var checkthis = pdwvd;
 
//		if (checkthis.value == "1")
	//	{document.getElementById("isnrfwaived").style.display='none';}
	//	else
	//	{document.getElementById("isnrfwaived").style.display='block';}
	}
function NRFWaiveA(pdwvd)     
		{var thisval = document.getElementById("iResidencyType_ID").value;  

	if (thisval == '')
	{	document.getElementById("NRFDscAmt").style.display='none';		
		document.getElementById("NRFDef").style.display='none';		 
		document.getElementById("iResidencyTypeID").focus();
		alert('Please select Residency Type BEFORE selecting New Resident Fee');}
	else
	 {	document.getElementById("NRFDscAmt").style.display='none';
		document.getElementById("NRFDef").style.display='block';
		document.getElementById("NRFAdjAmt").style.display='block';		
		document.getElementById("NrfAdj").value = cent(round(document.getElementById("nrfee").value)); 	
		document.getElementById("NrfDisc").value = 0;
	  	document.getElementById("NrfAdj").style.background = 'salmon';		
		document.getElementById("NrfAdj").focus();	
		document.getElementById("NrfDiscApprove").value = 'N';}	
	}
function NRFWaiveD(pdwvd)     
	{	var thisval = document.getElementById("iResidencyType_ID").value;  
	 
		if (thisval  == '')
	{	document.getElementById("NRFDscAmt").style.display='none';		
		document.getElementById("NRFDef").style.display='none';		 
		document.getElementById("iResidencyTypeID").focus();
		alert('Please select Residency Type BEFORE selecting New Resident Fee');}
	else
	 {	document.getElementById("NRFAdjAmt").style.display='none';
		document.getElementById("NRFDscAmt").style.display='block';		
		document.getElementById("NRFDef").style.display='block';	
		document.getElementById("NrfDisc").value = cent(round(document.getElementById("nrfee").value));	
		document.getElementById("NrfAdj").value = 0;				
		document.getElementById("NrfDisc").focus();
		document.getElementById("NrfDiscApprove").value = 'Y';}
		
	}	
function NRFWaive(pdwvd)     
		{var thisval = document.getElementById("iResidencyType_ID").value;  
	 
		if (thisval  == '')
	{	document.getElementById("NRFDscAmt").style.display='none';		
		document.getElementById("NRFDef").style.display='none';		 
		document.getElementById("iResidencyTypeID").focus();
		alert('Please select Residency Type BEFORE selecting New Resident Fee');}
	else
	 {	document.getElementById("NRFAdjAmt").style.display='none'; 
		document.getElementById("NRFDscAmt").style.display='none';	
		document.getElementById("NRFDef").style.display='block';		
		document.getElementById("NrfAdj").value = 0;
		document.getElementById("NrfDisc").value = 0;
	// 	document.getElementById('NewNRFee').value =  cent(round(document.getElementById('nrfee').value));	
		document.getElementById('NewNRFee').value =  cent(round(document.getElementById('nrfee').value))
		document.getElementById("NrfDiscApprove").value = 'N';}				
	}		
function showfeepaid()
{
		document.getElementById("resfeepaid").style.display='block';
		document.getElementById("selmonthstopay").style.display='block'; 
		document.getElementById("initpayment").style.display='block'; 		
		 
} 

function showmonthstopay() 
{
		document.getElementById("selmonthstopay").style.display='block';
	
} 
function adjNrfAmt()
{
			document.getElementById('NewNRFee').value =  cent(round(document.getElementById('nrfee').value)); 
}
function adjNrfAmtA()
{
 
	var newrate = 0;

	if (
			( document.getElementById('NrfAdj').value != '')   && 
				( round(document.getElementById("NrfAdj").value)  <=  round(document.getElementById("nrfee").value) )
		)
		{
		alert('New Resident Fee entered is LESS or EQUAL to the standard house fee \n Enter the Revised Fee or Refresh the page to start over');
		document.getElementById("NrfAdj").style.background = 'lightgreen';		
		document.getElementById("NrfAdj").focus();
		return;
		}
	else
		{  
			adjamount =  Number(document.getElementById('NrfAdj').value) - Number(document.getElementById('nrfee').value );
			newrate =    Number(document.getElementById('NrfAdj').value) ;
			document.getElementById('NewNRFee').value =  cent(round(newrate));
			document.getElementById('adjamount').value =  cent(round(adjamount));		
		}
 
}
function adjNrfAmtD()
{
 
	var newrate = 0;
 //	alert(document.getElementById("NrfDisc").value + " : " + document.getElementById("nrfee").value);
	if (  document.getElementById('NrfDisc').value != ''  && (round(document.getElementById("NrfDisc").value) >= round(document.getElementById("nrfee").value)) )
		{
		alert('New Resident Fee entered is GREATER or EQUAL to the standard house fee \n Enter the Revised Fee or Refresh the page to start over');
		document.getElementById("NrfDisc").style.background = 'white';	
		document.getElementById("NrfDisc").focus();
		return;
		}
	else if (  document.getElementById('NrfDisc').value != ''  && (document.getElementById("NrfDisc").value == 0 ) && (document.getElementById("stateID").value == 'ID' ))		
			{	alert('New Resident Fees in Idaho cannot be waived! \n Please Re-Enter');
				document.getElementById("NrfDisc").value = cent(round(document.getElementById("nrfee").value));	
				document.getElementById("NrfAdj").value = 0;				
				document.getElementById("paidwaived").focus();			
				document.getElementById("NrfDisc").focus();						
					}
	else if (  document.getElementById('NrfDisc').value != ''  && (document.getElementById("NrfDisc").value == 0 ))
		{
			var answer = confirm('Are you WAIVING the New Resident Fee?');
			if (answer)
			{	discamount = document.getElementById('nrfee').value - document.getElementById('NrfDisc').value;	
				newrate = document.getElementById('NrfDisc').value;	
				document.getElementById('NewNRFee').value =  cent(round(newrate));  
				document.getElementById('discamount').value =  cent(round(discamount));  		
				document.MoveInForm.NRFDeferral.value = 0;
				document.getElementById("NRFDef").style.display='none';	
			//	document.getElementById("NRFZero").style.display='block';
				return;
				}
			else	{
				document.getElementById("NrfDisc").style.background = 'white';	
				document.getElementById("NrfDisc").focus();
					}
		}
	else
	{  
	//	newrate = document.getElementById('nrfee').value - document.getElementById('NrfDisc').value;	
	 	discamount = document.getElementById('nrfee').value - document.getElementById('NrfDisc').value;	
		newrate = document.getElementById('NrfDisc').value;	
		var answer = confirm('You are discounting the NRF by \n$' + discamount + '\n Is This Correct?' );
		if (answer)
		{		
		document.getElementById('NewNRFee').value =  cent(round(newrate));  
		document.getElementById('discamount').value =  cent(round(discamount));  		
		document.MoveInForm.NRFDeferral.value = 0;
		document.getElementById("NRFDef").style.display='block';
//		document.getElementById("nrfdefbutn").focus();
		}
		else{
			document.getElementById("NrfDisc").style.background = 'white';	
			document.getElementById("NrfDisc").focus();
			}
	}	
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
 
	function payor(obj){;
		if (df0.TenantbIsPayer.checked)
		{document.getElementById("contactpayor").style.display='none';}
		if (df0.TenantbIsPayer.checked && df0.ContactbIsPayer.checked){ 
			df0.Message.value = "Please select one person as the payor"; obj.focus() 
			alert('Please select one person as the payor \n Additional payors can be set up on the Tenant Edit screen.'); obj.checked = false;
		}
		if (!df0.TenantbIsPayer.checked && !df0.ContactbIsPayer.checked){ (df0.Message.value = "You must specify a payor"); alert('You must specify a payor'); }
	}
	function primarypayor(obj){;
		if (df0.TenantbIsPrimaryPayer.checked)
		{document.getElementById("contactpripayor").style.display='none';}	
		if (df0.TenantbIsPrimaryPayer.checked && df0.ContactbIsPrimaryPayer.checked){ 
			df0.Message.value = "Please select one person as the primary payor"; obj.focus() 
			alert('Please select one person as the primary payor \n Additional payors can be set up on the Tenant Edit screen. '); obj.checked = false;
		}
	//	if (!df0.TenantbIsPrimaryPayer.checked && !df0.ContactbIsPrimaryPayer.checked){ (df0.Message.value = "You must specify a primary payor"); alert('You must specify a primary payor,\n Additional payers can be established on thhe Tenant Edit screen'); }
	}	
	
	function required() {
	var failed = false;

		if (df0.TenantbIsPayer.checked && df0.ContactbIsPayer.checked){
			var answer  = confirm("You have indicated both the Contact and the Tenant will be Payors."); 
			if (answer)
				return true;
			else
			return false; }
	 	else if (!df0.TenantbIsPayer.checked && !df0.ContactbIsPayer.checked){
			(df0.Message.value = "You must specify a payor"); alert("You must specify a payor"); location.hash = '#start';
			 return false;}	
			 
		verifyNRF(); 
	}

	function checkNRF(){
 
	 	if (!df0.paidwaived.checked ){
	 		(df0.Message.value = "You must specify if New Resident Fee is Adjusted Up, Discounted or using Standard House Fee.");
			 alert("You must Select New Resident Fee action" + " " + df0.paidwaived.checked.value); location.hash = '#start';
			  return false;
	 	}		
		else { df0.Message.value = ""; return true; }	
	}
function verifyNRF(){
for (var i=0; i < document.paidwaived.length; i++)
   {
   if (document.paidwaived[i].checked)
      {
      var rad_val = document.paidwaived[i].value;
	  alert(rad_val);
      }
   }
}
 	
	<cfoutput>	
		function respiterates(string){
			if (string.value == 3 && #qRespiteChargeCheck.RecordCount# == 0){ 
				var message = 'There no respite rates entered for this house. \r Please  contact your AR Specialist for assistance.';
				df0.Message.value = 'There no respite rates entered for this house.'; alert(message);
				string.options[0].selected = true;	
			}
		else if (string.value == 3 )			
			{//	document.getElementById("isnrfwaived").style.display='none';
	 	document.getElementById("NRFDscAmt").style.display='none';
		document.getElementById("NRFDef").style.display='none';
		document.getElementById("NRFAdjAmt").style.display='none';		  
		document.getElementById("NrfAdj").value = 0; 	
		document.getElementById("NrfDisc").value = 0;  
		document.getElementById("NewNRFee").value = 0;  
		document.getElementById("NRFee").value = 0;  				
		document.getElementById("NrfDiscApprove").value = '';	
		document.getElementById("cNRFFee").value = '';	
		document.getElementById("NRFApp").style.display='none';			
		document.getElementById("NRFZero").style.display='none';						
				ResetNrf();
			}
//		else if (string.value != 3 )			
//			{	document.getElementById("isnrfwaived").style.display='block';}	
		else { document.forms[0].Message.value=''; }
		}
	</cfoutput>
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
			if ((MoveInForm.dtBondCertificationMailed.value == '00/00/0000') && (bondq_value)){
					MoveInForm.dtBondCertificationMailed.focus();
						alert("Please enter the date the income certification was mailed to the Corporate Office." + bondq_value);
						return false;
			}
			else if ((MoveInForm.dtBondCertificationMailed.value == '') && (bondq_value)){
					MoveInForm.dtBondCertificationMailed.focus();
						alert("Please enter the date the income certification was mailed to the Corporate Office.");
						return false;
			}
			else if ((bisDate(MoveInForm.dtBondCertificationMailed.value) == false) && (bondq_value)){
					MoveInForm.dtBondCertificationMailed.focus();
						alert("Please enter a valid date in which the income certification was mailed to the Corporate Office. \n \n"+MoveInForm.dtBondCertificationMailed.value+"  is not a valid date.");
						return false;
			}
	 	}
	}
	function hardhaltvalidation(MoveInForm)
	{	
		if(MoveInForm.iResidencyType_ID.options[MoveInForm.iResidencyType_ID.selectedIndex].value == ""){
			MoveInForm.iResidencyType_ID.focus();
			alert("Please select a Residency Type");
			return false;
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
		
//		var RentDate = document.getElementById("RentMonth").value + '/'+ document.getElementById("RentDay").value + '/' + document.getElementById("RentYear").value;		
		var RentDate = new Date(document.getElementById("RentMonth").value + '/'+ document.getElementById("RentDay").value + '/' + document.getElementById("RentYear").value);		

		if (RentDate > new Date()){
			MoveInForm.cSSN.RentMonth();
			alert("Possession Date cannot be in the future.");
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
		
//		if(MoveInForm.cPreviouszipCode.value.length != 5 && MoveInForm.cPreviouszipCode.value.length != 10)
//		{
//			MoveInForm.cPreviouszipCode.focus();
//			alert("Please enter the previous City Zip Code of the resident.  It must be 5 or 10 characters long.");
//			return false;
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
		
		
	 	var NRFpaidwaived = false;
	 	var NRFAdjust = false;		
	 
	 	for(i=0;i<MoveInForm.paidwaived.length;i++)
	 	{
	 		if(MoveInForm.paidwaived[i].checked)
	 		{
				NRFpaidwaived = true;
				NRFAdjust = MoveInForm.paidwaived[i].value;
	 		}
	 	}		
//	 	 if  (!NRFpaidwaived  && MoveInForm.iResidencyType_ID.value != 3 && MoveInForm.paidwaived != 'paid') 
//	 	{
//	 		alert("Please make New Resident Fee Selection");
//	 		return false;
//	 	}
		if(NRFAdjust == 2){
			if (MoveInForm.NrfAdj.value <= MoveInForm.nrfee.value)
			{alert("NRF fee is being adjusted up, value entered is  less than house base NRF");
	 		return false;}
		} 
		//The VA military option
	/*	var military = false;
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
	*/
		//If the Tenant Is Payer
	
//		if(MoveInForm.TenantbIsPayer.checked == true)
//		{
//			  if(MoveInForm.cOutsideAddressLine1.value=="")
//				{
//					MoveInForm.cOutsideAddressLine1.focus();
//					alert("Resident is the Payor so please enter the Billing address");
//					return false;
//				}
//				if(MoveInForm.cOutsideCity.value == "")
//				{
//					MoveInForm.cOutsideCity.focus();
//					alert("Please enter City for Billing address");
//					return false;
//				}
				
//			if(MoveInForm.cOutsideZipCode.value.length != 5 && MoveInForm.cOutsideZipCode.value.length != 10)
//				{
//					MoveInForm.cOutsideZipCode.focus();
//					alert("Please enter Zip Code for Billing address. It must be 5 or 10 characters long.");
//					return false;
//				}
	
//		}
				//If the Contact Is Payer
		if(MoveInForm.ContactbIsPayer.checked == true)
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
//				if(MoveInForm.cZipCode.value.length != 5 && MoveInForm.cZipCode.value.length != 10){
//					MoveInForm.cZipCode.focus();
//					alert("Please enter Zip Code for Billing address");
//					return false;
				if(MoveInForm.cZipCode.value.length < 5 ){
					MoveInForm.cZipCode.focus();
					alert("Please enter Zip (Postal) Code for Contact address or check Zip Code for porper format");
					return false;					
				}
				if(MoveInForm.cPreviouszipCode.value.length < 5 ){
					MoveInForm.cZipCode.focus();
					alert("Please enter Zip (Postal) Code for Resident Previous address or check Zip Code for porper format");
					return false;					
				}
				if(MoveInForm.areacode1.value.length != 3 || MoveInForm.prefix1.value.length != 3 || MoveInForm.number1.value.length != 4){
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
 
		if(MoveInForm.bondval.value==1)
		{
			if(MoveInForm.dtBondCertificationMailed.value == '00/00/0000'){
					MoveInForm.dtBondCertificationMailed.focus();
						alert("Please enter the date the income certification was mailed to the Corporate Office.  " + MoveInForm.bondval.value);
						return false;
			}else if (MoveInForm.dtBondCertificationMailed.value == ''){
					MoveInForm.dtBondCertificationMailed.focus();
						alert("Please enter the date the income certification was mailed to the Corporate Office.");
						return false;
			}else if (bisDate(MoveInForm.dtBondCertificationMailed.value) == false){
					MoveInForm.dtBondCertificationMailed.focus();
						alert("Please enter a valid date in which the income certification was mailed to the Corporate Office. \n \n"+MoveInForm.dtBondCertificationMailed.value+"  is not a valid date.");
						return false;
				}

					for(j=0;j<MoveInForm.cBondQualifying.length;j++){
						if(MoveInForm.cBondQualifying[j].checked)
						{var bondq = true;
						
							if(MoveInForm.cBondQualifying[j].value == 1){
								var bondq_value = true;
							}else{
								var bondq_value = false;
							}
						}
					}

					if(!bondq){
						alert("Please select Yes or No if the resident is bond qualified.");
						return false;
					}	
				
				//HOUSE
				var BondPercentage = MoveInForm.BPercent.value; 
				if(BondPercentage < 20){
					var BondPercentMet = false;
				}else{
					var BondPercentMet = true;
				}  
			
				//ROOM 
 				var bondroom = MoveInForm.iAptAddress_ID.options[MoveInForm.iAptAddress_ID.selectedIndex].text;
				var bRoomisBond = false;
				var bRoomisBondIncluded = false;
				if((bondroom.indexOf("Bond")) > 0){
					bRoomisBond = true;
					}
				if((bondroom.indexOf("Included")) > 0){
					bRoomisBondIncluded = true;}
					
				//if tenat certifies as NOT bond - then room selected cannot be bond designated
				if(bondq_value == false && bRoomisBond == true){
						alert("Tenant is marked as not being eligible as bond.\n \nPlease select a room that is not bond designated.");
						return false;}
				//tenant is bond, but the room cannot be bond involved.
				else if(bondq_value == true && bRoomisBondIncluded == false){
						alert("Tenant is marked as being eligible as bond. \n \nThe room selected is not bond applicable. \n \nPlease select a bond included room.")
						return false;}
			
				//tenant is bond, room selected is already bond, and house is under bond percentage, then halt.
				 else if(bondq_value == true && bRoomisBond == true && BondPercentMet == false){
						alert("Tenant is marked as being eligible as bond. \n \nThe room selected is already Bond designated. \n \nBut the House is not at the Bond percentage requirement. \n \nPlease select a room that is not Bond designated to raise the percentage.")
						return false;} 
			}		
	//	if(MoveInForm.areacode1.value  !='' || MoveInForm.prefix1.value  != '' || MoveInForm.number1.value  != '')		
   	//		{ 
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
					// && MoveInForm.cLastName.value !=''	
		//	alert('Contact Phone Number must be format: 123-456-7890');
		//	return false;
		//	}
		return true;
	}
function setmonth() {
var mylist=document.getElementById("RentMonth");
var monthSel =mylist.options[mylist.selectedIndex].text;


   document.getElementById("RentMonth").value= monthSel;
//	alert ( monthSel);
}

//function  getAptID(){ 
//	alert ('here');
//	document.getElementById("getaprrate").style.display='block';
//	document.getElementById("aptAddress").value = document.getElementById("iAptAddress_ID").value;

//	alert (document.getElementById("aptAddress").value);	
//	document.getElementById("getaprrate").focus();
//}

	window.onload=initialize;
	 
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
<form name="MoveInForm" action="#Variables.Action#" method="POST" onSubmit="return required();">
<br/><a href="../MainMenu.cfm" style="font-size: 18;"> <B>Exit Without Saving</B></a><br/>
	<input type="hidden" name="iTenant_ID" value="#URL.ID#">
	<input type="hidden" name="cSolomonKey" value="#Tenant.cSolomonKey#">
	<input type="hidden" name="cMilitaryVA" value="">
	<input type="hidden" name="hasExecutor" value="">
	<input type="hidden" name="NrfDiscApprove" value="" />
	<input type="hidden" name="stateID" value="#session.qselectedhouse.cstatecode#">	
	<input type="text" name="Message" value="" size="75" style="color: red; font-weight: bold; font-Size: 16; text-align: center;" readonly="readonly">

<table    width="640px"   >
<tr><td>
<table>
	<tr>
		<th colspan="6" style="font-size:medium;"><b>Move In Form</b></th></tr>

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
         	onblur="maskSSN(this);" onkeypress="return allowOnlyNumberOnKey(event)"  size="8" maxlength="11" />
        </td>
	</tr>
	
	<tr style="background-color:##FFFFCC">	
		<td style="font-weight: bold;"> Birthdate </td>
		<td>
			<input type="text" id="dbirthdate" Name="dbirthdate" value = "#DateFormat(tenant.dbirthdate,"mm/dd/yyyy")#" size ="8"> (MM/DD/YYYY)
		</td> 
	</tr>
	<TR><TD><strong>PREVIOUS ADDRESS</strong></TD></TR>
	<tr>
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Address Line 1 </td>
		<td><input type="text" name="cPreviousAddressLine1" value="#tenant.cPreviousAddressLine1#" size="40" maxlength="40" onblur="upperCase(this);"></td>
	</tr>
	<tr style="background-color:##FFFFCC">
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Address Line 2 </td>
		<td><input type="text" name="cPreviousAddressLine2" value="#tenant.cPreviousAddressLine2#" size="40" maxlength="40" onblur="upperCase(this);"></td>
	</tr>
	<tr>	
		<td colspan="5">
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;City 
		<input type="text" name="cPreviousCity" value="#Tenant.cPreviousCity#" onkeypress="return allowOnlyLettersOnKey(event);" onblur="upperCase(this);">
		State 
			<select name="cPreviousState">
				<option value=""> Select </option>
				<cfloop query="StateCodes">
					<cfscript>
						if  (TenantInfo.cPreviousState eq statecodes.cStateCode) { Selected = 'Selected'; }
						else { Selected = ''; }
					</cfscript>
					<option value="#Statecodes.cStateCode#" #Selected#> #cStateName# - #cStateCode#  </option>
				</cfloop>
			</select>
		<BR />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Zip (Postal) Code 
		<input type="text" name="cPreviouszipCode" value="#tenant.cPreviouszipCode#" maxlength="10" size="10" onblur="maskZIP(this);"/>
             
		
		</td><!--- onkeypress="return allowOnlyNumberOnKey(event)"  --->
	</tr>

	<cfif bondhouse.iBondHouse eq 1> 		 
		<tr>
				<td colspan="2" style="Font-weight: bold;color:red;">
				Did the resident qualify as eligible for meeting<br>
				 the Bond program occupancy requirements?  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				 <cfif tenant.bIsBond is 1>
				 Yes<input type="radio" name="cBondQualifying" id="cBondQualifying" value="1" 
                 	onclick="document.MoveInForm.cBondQualifying.value=this.value;" checked="checked"> 
				 No<input type="radio" name="cBondQualifying" id="cBondQualifying" value="0" 
                 	onclick="document.MoveInForm.cBondQualifying.value=this.value;">
				<cfelseif tenant.bIsBond is 0>
				 Yes<input type="radio" name="cBondQualifying" id="cBondQualifying" value="1" 
                 	onclick="document.MoveInForm.cBondQualifying.value=this.value;"> 
				 No<input type="radio" name="cBondQualifying" id="cBondQualifying" value="0" 
                 	onclick="document.MoveInForm.cBondQualifying.value=this.value;" checked="checked">
				
				<cfelse>
				 Yes<input type="radio" name="cBondQualifying" id="cBondQualifying" value="1" 
                 	onclick="document.MoveInForm.cBondQualifying.value=this.value;"> 
				 No<input type="radio" name="cBondQualifying" id="cBondQualifying" value="0" 
                 	onclick="document.MoveInForm.cBondQualifying.value=this.value;">
				</cfif>
				
				</td>
			</tr>
			
			<tr>		
				<td colspan="2"><span style="Font-weight: bold;color:red;">Date the income certification was faxed or emailed to the Corporate Office:&nbsp;</span>
				<cfif tenant.dtBondCert is not "">
				<td><input type="text" name="dtBondCertificationMailed" value="#dateformat(tenant.dtBondCert, 'mm/dd/yyyy')#" size="10" maxlength="10"> (MM/DD/YYYY)</td>
				<cfelse>
				<td><input type="text" name="dtBondCertificationMailed" value="00/00/0000" size="10" maxlength="10"> (MM/DD/YYYY)</td>		
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
	 <tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;">	Apartment Number </td>
		<td colspan="4" style="color:##FF0000">
			<select name="iAptAddress_ID" id="iAptAddress_ID"  onfocus="checkbond()"  > <!--- onblur="getAptID()" --->
				<option value="">Select Apartment...<cfif bondhouse.iBondHouse eq 1>Bond Apt: #BondHTML#%</cfif></option>
				<cfloop query="Available">
					<cfif bondhouse.iBondHouse eq 1>
						<cfscript>
							if (ListFindNoCase(OccupiedList,Available.iAptAddress_ID,",") GT 0){Note = '(Occupied) ';} else{ Note='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							if (ListFindNoCase(BondAptList,Available.iAptAddress_ID,",") GT 0){Note1 = '(Bond) ';} else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							if (ListFindNoCase(BondIncludedAptList,Available.iAptAddress_ID,",") GT 0){Note2 = '(Included)';} else{ Note2=''; } 
						
							if (IsDefined("TenantInfo.iAptAddress_ID") and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
								OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
								Selected = 'Selected'; }
							else { Selected = ''; }
						</cfscript>
						<option value= "#Available.iAptAddress_ID#" #Selected#> #Available.cAptNumber# - #Available.cDescription##NOTE##NOTE1##NOTE2#</option>	
					<cfelse>
						<cfscript>
							if (ListFindNoCase(OccupiedList,Available.iAptAddress_ID,",") GT 0){Note = '(Occupied)';} else{ Note=''; }
							if (IsDefined("TenantInfo.iAptAddress_ID") and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
								OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
								Selected = 'Selected'; }
							else { Selected = ''; }
						</cfscript>
						<option value= "#Available.iAptAddress_ID#" #Selected#> #Available.cAptNumber# - #Available.cDescription##NOTE#</option>
					</cfif>				
				</cfloop>
			</select>
			<!--- <br />*Note: For 2nd Occupancy Rooms, select:<br /> "Use Standard House NRF"<!--- , No Deferral --->.<br  />The process will not add a NRF Fee for 2nd Occupancy in a room. --->
		</td>
	</tr>	
 
 
		
<!---  <tr >
	<td id="getaprrate"  style="visibility:hidden"  >
	<!---  <input type="text" id="aptAddress" name="aptAddress" value="" /> --->
	Community Fee: 
	<cfquery name="qryAptAddr"   dbtype="query"  >
	select mamount from  qryAptType  where iAptAddress_ID = 
	<cfif IsDefined('aptAddress') is "Yes" and aptAddress is not "">aptAddress <cfelse>9999999 </cfif>
	</cfquery>
	 
	<cfset NewNRFee = (#qryAptAddr.mamount# * 30.4)>
	 <input type="hidden" id="mNewNRFee" name="mNewNRFee" value="" />
	 </td>
</tr>  --->
	<tr>
		<td  style="font-weight: bold;">Financial Possession Date</td>
		<td colspan="2">		
			<select name="RentMonth" id="RentMonth" onChange="setmonth(); dayslist(RentMonth,RentDay,RentYear);">
				<option value="#datepart("m",(now()))#" Selected>#datepart("m",(now()))#  </option>
				<cfloop index="i" from="1" to="12" step="1">
				<option value="#i#" > #i# </option>
				</cfloop>
			</select>
			/
			<select name="RentDay" onChange="dayslist(df0.RentMonth,df0.RentDay,df0.RentYear);">
				<option value="#datepart("d",(now()))#" Selected>#datepart("d",(now()))# </option>
				<cfloop index="i" from="1" to="31" step="1">
				<option value= "#i#"  > #i# </option>
				</cfloop>
			</select>
			/
			<select name="RentYear">
				<option value="#Year(Now())-1#">#Year(Now())-1#</option>
				<option value="#Year(Now())#" selected>#Year(Now())#</option>
				
			</select>
		</td>
	</tr>
 	<cfif SESSION.qSelectedHouse.iopsarea_ID is 44>	
		<tr>
			<td  style="font-weight: bold;">Physical Move In Date  </td>
			<td colspan="2">		
				<select name="MoveInMonth" id="MoveInMonth" onChange="setmonth(); dayslist(MoveInMonth,MoveInDay,MoveInYear);">
					<option value="#datepart("m",(now()))#" Selected>#datepart("m",(now()))#  </option>
					<cfloop index="i" from="1" to="12" step="1">
					<option value="#i#" > #i# </option>
					</cfloop>
				</select>
				/
				<select name="MoveInDay" onChange="dayslist(df0.MoveInMonth,df0.MoveInDay,df0.MoveInYear);">
					<option value="#datepart("d",(now()))#" Selected>#datepart("d",(now()))# </option>
					<cfloop index="i" from="1" to="31" step="1">
					<option value= "#i#"  > #i# </option>
					</cfloop>
				</select>
				/
				<select name="MoveInYear">
					<option value="#Year(Now())-1#">#Year(Now())-1#</option>
					<option value="#Year(Now())#" selected>#Year(Now())#</option>
					<option value="#Year(Now())#" >#Year(Now())+1#</option>				
				</select>
			</td>
		</tr>	
	<cfelse>	
	<input type="hidden" name="MoveInMonth" id="MoveInMonth"  value="" />
	<input type="hidden" name="MoveInDay"   id="MoveInDay"  value="" />	
	<input type="hidden" name="MoveInYear"  id="MoveInYear"  value="" />	
	</cfif> 
	<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;"> Product line </td>
		<td><cfset productoptions=""><cfloop query="qproductline"><cfset productoptions=productoptions&"<option value='#qproductline.iproductline_id#'>#qproductline.cDescription#</option>"></cfloop>
			<select id="iproductline_id" name="iproductline_id">#productoptions#</select>	
		</td>
		<td colspan="2"></td>
	</tr>
	<tr>
		<td style="font-weight: bold;"> Residency Type</td>

		<cfif tenant.iResidencyType_ID is 3>
		<td colspan="5">
			<select name="iResidencyType_ID" onChange="respiterates(this);">
					<option value="3">Respite</option>
			</select>
			<font color="red">*Please Enter Projected Move Out Date:</font>
		</td>		
		<cfelse>
		<td colspan="5">
			<select name="iResidencyType_ID" ID="iResidencyTypeID"onChange="respiterates(this);">
				<option value=""> </option>
				<cfloop query="Residency">
					<option value="#Residency.iResidencyType_ID#"> #Residency.cDescription# </option>
				</cfloop>
			</select>
			<!--- <font color="red">*Please Enter Projected Move Out Date if the Resident is Respite</font> --->
			<div style="color:red; font-weight:bold"> *Respite Residents REQUIRE Projected Move Out Date</div>
		</td>		
		</cfif>		
<!--- 		<td colspan="5">
			<select name="iResidencyType_ID" onChange="respiterates(this);">
				<option value=""> </option>
				<cfloop query="Residency">
					<option value="#Residency.iResidencyType_ID#"> #Residency.cDescription# </option>
				</cfloop>
			</select>
			<font color="red">*Please Enter Projected Move Out Date if the Resident is Respite</font>
		</td> --->
	</tr>	
 
	<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;">Projected Move<br />Out Date </td>
			<td><input type="text" size="8" name="dtmoveoutprojecteddate" onblur="validatePMO();"> 
		<!--- 	&nbsp;
			<a onClick="show_calendar2('document.MoveInForm.dtmoveoutprojecteddate',document.getElementById('dtmoveoutprojecteddate').value,'dtmoveoutprojecteddate');"> 
				<img src="../../global/Calendar/calendar.gif" alt="Calendar" width="16" 
				height="15" border="0" align="middle" style="" id="Cal" name="Cal">
			</a> --->    &nbsp;&nbsp;&nbsp;RESPITE ONLY -  REQUIRED    
			<br />(MM/DD/YYYY) 
		</td>
		<td Style="color:red;" colspan="2"><span id="Mes" style="display:none">
			PMO DATE CAN'T BE IN THE PAST,OR MORE THAN 3 MONTHS IN THE FUTURE.</span>
		</td>
	</tr>
	<tr>
		<td style="font-weight: bold;">	Service Level Set </td>
		<td colspan="2">
			<input type="text" name="csleveltypeset" value="#TenantInfo.csleveltypeset#" size="3" maxlength="3" 
			style="border:none;background:transparent;text-align:center;" readonly>
		</td>
	</tr>
	<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;"> Service Points </td>
		<td colspan="2">
		<cfif  ((IsDefined("qapoints.iSPoints") is "Yes") and  (qapoints.iSPoints  is not ""))>
			 <input type="text" name="iSPoints" value="#trim(qapoints.iSPoints)#" size="3" maxlength="3"
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
						if  (TenantInfo.iPrimaryDiagnosis eq qDiagnosisType.iDiagnosisType_ID) { Selected = 'Selected'; }
						else { Selected = ''; }
					</cfscript>
					<option value="#qDiagnosisType.iDiagnosisType_ID#" #Selected#> #qDiagnosisType.cDescription# </option>
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
						if  (TenantInfo.iSecondaryDiagnosis eq qDiagnosisType.iDiagnosisType_ID) { Selected = 'Selected'; }
						else { Selected = ''; }
					</cfscript>
					<option value="#qDiagnosisType.iDiagnosisType_ID#" #Selected#> #qDiagnosisType.cDescription# </option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td id="isrespayor" style="Font-weight: bold;  display:block;" colspan="5"> 
			Is the resident also the Payor?
			<cfif Tenant.bIsPayer eq ""> <cfset Check="Unchecked"> <cfelse> <cfset Check="Checked"> </cfif>	
			<input type="checkbox" name="TenantbIsPayer" value="1" style="text-align: center;" onKeyUp="this.value=Numbers(this.value)" 
			#Variables.Check#  onBlur="required();">
		</td>
	</tr> 
 
	<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
		<tr style="background-color:##FFFFCC">
			<td colspan="5" style="Font-weight: bold;">
				 Was a Move In Check received?
				<cfif Tenant.bMICheckReceived is '' or Tenant.bMICheckReceived eq 0> <cfset MICCheck="Unchecked"> <cfelse> <cfset MICCheck="Checked"> </cfif>	
				<input type="Checkbox" name="TenantbMICheckReceived" value="1" style="text-align: center;"  #Variables.MICCheck#>
			</td>
		</tr>
		<tr>
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
		</tr>
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
				Yes <input name="hasExecutor" type="radio" value="1" onclick ="document.MoveInForm.hasExecutor.value=this.value"  checked="checked">  
				No	<input name="hasExecutor" type="radio" value="0" onclick="document.MoveInForm.hasExecutor.value=this.value"> 
				<cfelseif tenant.chasExecutor is 0>
				Yes <input name="hasExecutor" type="radio" value="1" onclick ="document.MoveInForm.hasExecutor.value=this.value" >  
				No	<input name="hasExecutor" type="radio" value="0" onclick="document.MoveInForm.hasExecutor.value=this.value"  checked="checked"> 				
				<cfelse>
				Yes <input name="hasExecutor" type="radio" value="1" onclick ="document.MoveInForm.hasExecutor.value=this.value" >  
				No	<input name="hasExecutor" type="radio" value="0" onclick="document.MoveInForm.hasExecutor.value=this.value"> 				
				</cfif>
			</td>
		</tr>	
	<input type="hidden" name="bondval" value="#bondhouse.ibondhouse#"> 	
	<input type="hidden" id="paidwaived"  name="cNRFFee" Value="3" >
 	<input type="hidden" name="MonthstoPay" value="0" />
 	<input type="hidden" name="NRFDeferral" value="" />			
<!--- 		<cfif Tenant.iResidencyType_ID IS 3>		
			<tr >
				<td colspan="5" id="isnrfwaived" style="Font-weight: bold; display:none" >
					<input type="hidden" id="paidwaived"  name="cNRFFee" Value="" >	
					<input type="hidden" name="nrfee" id="nrfee" value="0" /> 
				</td>
			</tr>
		<cfelseif Tenant.cResidentFee IS 1>		
			<tr>
				<td colspan="5" style="Font-weight: bold;" >The New Resident Fee was Paid In Full or Waived.</td>
			</tr>
			<input type="hidden" id="paidwaived"    name="cNRFFee" Value="" >
		<cfelse>
			<tr style="background-color:##FFFFCC">
				<td colspan="5" id="isnrfwaived" style="Font-weight: bold; display:block" >
				<input type="hidden" name="nrfee" id="nrfee" value="#GetNRF.NRF#" /> 
					New Resident Fee is: #dollarformat(GetNRF.NRF)# <br />
					Select an action:  <br />
					<cfif session.qselectedhouse.cstatecode is "ID">
						&nbsp;&nbsp; Standard House NRF <input type="radio" id="paidwaived"  name="cNRFFee" Value="3"   onclick="ResetNrf(); NRFWaive(this);document.MoveInForm.cNRFFee.value=this.value;adjNrfAmt()">
					 <input type="hidden" id="paidwaived"  name="cNRFFee" Value="1"    onclick="ResetNrf(); NRFWaiveD(this);document.MoveInForm.cNRFFee.value=this.value"> <br />

					<cfelse>
						&nbsp;&nbsp; Adjusted Up NRF		<input type="radio" id="paidwaived"  name="cNRFFee" Value="2"   onclick="ResetNrf(); NRFWaiveA(this);document.MoveInForm.cNRFFee.value=this.value;"> <br />	 <!--- TenantCheck(); --->
						&nbsp;&nbsp; Discounted NRF			<input type="radio" id="paidwaived"  name="cNRFFee" Value="1"   onclick="ResetNrf(); NRFWaiveD(this);document.MoveInForm.cNRFFee.value=this.value;"> <br />
						&nbsp;&nbsp; Use Standard House NRF <input type="radio" id="paidwaived"  name="cNRFFee" Value="3"   onclick="ResetNrf(); NRFWaive(this);document.MoveInForm.cNRFFee.value=this.value;adjNrfAmt();">
					</cfif>
				</td>
			</tr>		
		</cfif> --->
	
	
<!--- 	<tr id="NRFAdjAmt" style="display:none" >	
		<td  colspan="5">
			<div id="NRFAdjAmount"  style="text-align:justify;font-size:larger"> 
				<p style="font-weight: bold; color:red; text-align:center;">Adjusted New Resident Fee<br /><p/>
				Standard New Residence Fee for this house: #dollarformat(getnrf.NRF)#<br />
				&nbsp; Enter the Adjusted New Residence Fee: $<input  type="text" id="NrfAdj" name="NrfAdj" value="#LSCurrencyFormat(0.00)#"  onchange="adjNrfAmtA();"  onBlur="this.value=cent(round(this.value)); adjNrfAmtA();"/><!--- adjNrfAmtA(); --->
			</div>
			<input type="hidden" name="adjamount"  id="adjamount"  value="#adjamount#">
			<input type="hidden" name="discamount"  id="discamount"  value="#discamount#">		
		</td> 
	</tr> --->

	
<!--- 	<tr id="NRFDscAmt" style="display:none; background-color:##FFFFCC">  
		<td  colspan="5">
			<div id="NRFDscAmount"  style="text-align:justify; font-size:larger"> 
				<!--- 99573 <p style="font-weight: bold; color:red; text-align:center;">Discounted New Resident Fee Requires Approval by a Regional Director or above before Move-In can be Finalized.<br /><p/> --->
				Standard New Residence Fee for this house: #dollarformat(getnrf.NRF)#<br />
				&nbsp; Enter the Approved Discounted New Resident Fee: $ <input  type="text" id="NrfDisc" name="NrfDisc" value="#LSCurrencyFormat(0.00)#" onchange="adjNrfAmtD();" onBlur="this.value=cent(round(this.value));"/> <!---  adjNrfAmtD(); --->
 			</div>
		</td>
	</tr> --->	
<!--- 	<tr  id="NRFZero" style="display:none; background-color:##FFFFCC; "  >
		<td>&nbsp;</td>
		<td colspan="5" style="font-weight: bold; color:red; ">Select the approver of waiving the New Resident Fee:<br />
						<select name="nrfZeroApprove" title="Select Approver of NRF Waiver" > 
							<option  value="" >Select approver</option>			
							<option  value="RDO"   >RDO</option>
							<option  value="RDQCM" >RDQCM</option>							
							<option  value="RDSM"  >RDSM</option>					
							<option  value="DVP"   >DVP</option>
							<option  value="VPSM"  >VPSM</option>										 
							<option  value="CEO"   >CEO</option>            
						</select> 
		</td>
	</tr> --->		
<!--- 	<tr id="NRFDef" style="display:none"  colspan="5" >
		<td colspan="2"><!--- New Resident Fee deferral is temporarily suspended ---></td>
		<input type="hidden" name="MonthstoPay" value="0" />
		<input type="hidden" name="NRFDeferral" value="" />
	</tr> --->
<!---   	<tr id="NRFDef" style="display:none"  colspan="5" >
		<td  style="Font-weight: bold;" colspan="5" >Is the New Resident Fee being deferred?	
			Yes <input name="NRFDeferral" type="radio" id="nrfdefbutn" onclick="nrfDefApp(this);document.MoveInForm.NRFDeferral.value=this.value" value="1" />  
			No	<input name="NRFDeferral" type="radio" id="nrfdefbutn" onclick="nrfDefApp(this);document.MoveInForm.NRFDeferral.value=this.value" value="0" />
		</td>
	</tr> --->  
<!--- 	<tr style="background-color:##FFFFCC">
		<td colspan="5">
			<div id="NRFApp" style="display:none" align="justify"> 
			<table width="100%">
				<!--- <tr>
					<td colspan="3">Solomon Key: #Tenant.cSolomonkey#</td>
				</tr> --->		
 				<!--- <tr>
					<td colspan="3">Amount of New Resident Fee: #dollarformat(GetNRF.NRF)#
					
					</td>
				<tr> --->
			
					<td colspan="4" style="font-weight: bold;color:red;  background-color: ##FFFF99" >
						Prior written approval by RDO or higher<br /> is required for the New Resident Fee Deferral<br />
						<select name="nrfApprove" title="Select Approver of NRF Deferral"  onchange="showfeepaid()" >
							<option  value="" >Select  who provided the approval</option>			
							<option  value="RDO" >RDO</option>
							<option  value="RDQCM" >RDQCM</option>							
							<option  value="RDSM" >RDSM</option>					
							<option  value="DVP" >DVP</option>
							<option  value="VPSM" >VPSM</option>										 
							<option  value="CEO" >CEO</option>
						</select> 
					</td>
				</tr>	

				<TR  id="resfeepaid"   style="display:none"> 
					<td  style="text-align:center"> 
						 New Resident<br /> Fee:<br />  
						 <input type="text" name="NewNRFee" id="NewNRFee" value="#NewNRFee#"  readonly="readonly"/>
					</td>
					<TD colspan="2" style="text-align:center; color:red;font-weight: bold;">
						Enter the amount of the<br /> New Resident Fee that was Paid:<BR> 
						$<INPUT TYPE = "text" NAME="mAmount" id="mAmount" SIZE="10" STYLE="text-align:right;" VALUE="0"   onBlur="this.value=cent(round(this.value)); calcenddate()"  > <!--- showmonthstopay() this.value=cent(round(this.value)); onBlur="this.value=cent(round(this.value));" onKeyUp="this.value=CreditNumbers(this.value);" onchange="calcenddate()";--->
						<INPUT TYPE="hidden" NAME="iQuantity"  VALUE="1" >
						<INPUT TYPE="hidden"  id="iChargeType_ID" NAME="iChargeType_ID" VALUE="1740">
						<INPUT TYPE="Hidden" NAME="cDescription" VALUE="New Resident Fee Deferred" MAXLENGTH="15">
						<INPUT TYPE="Hidden" NAME="mcalcrembalance" VALUE="calculated remaining balance" MAXLENGTH="15">
					</TD>
					<TD    STYLE="text-align: center;; color:red;font-weight: bold;">   
						Select Number of Payments<br /> Remaining:<br/>
						<!--- <SELECT NAME="MonthstoPay"  id="MonthstoPay" onchange="calcenddate()">
							<CFLOOP INDEX="i" FROM="1" TO="9" STEP="1">
								 <OPTION VALUE="#i#"  >#i#</OPTION>
							</CFLOOP>
						</SELECT> --->
					</TD>					
				</TR> 
				<TR style="background-color: ##FFFF99" id="selmonthstopay" style="display:none"   > 
					<td   colspan="2" nowrap="nowrap" STYLE="text-align: center;">Deferral Start Date:<br/> 
						<input type="text" name="thistipsdate" value="#dateformat(session.tipsmonth, 'mm')#-#dateformat(session.tipsmonth, 'yyyy')#"  size="7"   readonly="readonly"/>
						<cfset applytodate = dateformat(#session.tipsmonth#, 'yyyymm')>
						<input type="hidden" name="ApplyToYear"  id="ApplyToYearA"  value="#left(applytodate, 4)#"  size="4" />
						<input type="hidden" name="ApplyToMonth" id="ApplyToMonthA" value="#right(applytodate, 2)#" size="2"/> 
					</td>
					<td  colspan="2" style="text-align:center">Deferral End Date:<br /> 
						<input type="hidden" name="defEndDate" id="defEndDate" value=""  size="10" readonly="Yes" />
						<input type="text" name="dispEndDate" id="dispEndDate" value=""  size="7" readonly="Yes" />  
					</td>	
				</TR>		

				<tr id="initpayment"  style="display:none" >
					<input type="hidden" id="amtpaid" name="amtpaid"  value=""  readonly="Yes" size="7"/> 
					<td colspan="2"  style="text-align:center">Amount<br /> Deferred:<br /> $<input type="text" name="amtdef"  id="amtdef" value=""  readonly="Yes" size="7"></td>
					<td colspan="2"  style="text-align:center">NRF Deferred<br /> Payment Amount:<br /> $<input type="text" name="defpymntamt"  id="defpymntamt" value="#defpymntamt#"    readonly="readonly" size="7"></td>
				</tr>				
				<tr>
					<td colspan="4" style="text-align:center; background-color: ##FFFF99" >Payment Schedule</td>
				</tr>
				<tr  style="background-color: ##FFFF99" >
					<td style="text-align:center">Payment</td>
					<td style="text-align:center">Payment Amount</td>
					<td style="text-align:center">Remaining Balance</td>
					<td style="text-align:center">Payment Date</td>
				</tr>

	 
				<tr id="paymnt1" style="display:none">
					<td style="text-align:center">1</td>
					<td style="text-align:right"><input type="text"  id="payment1"    value="" name="payment1"  readonly="readonly"/></td>
					<td style="text-align:right"><input type="text"  id="rembalance1" value="" name="rembalance1"  readonly="readonly"/></td>	
					<td style="text-align:center"><input type="text" id="dtpayment1"  name="dtpayment1" value=""  readonly="readonly"/></td>
				</tr>
 
		 		<tr id="paymnt2" style="display:none">
					<td style="text-align:center">2</td>
					<td style="text-align:right"><input type="text"  id="payment2" value="" name="payment2"  readonly="readonly"/></td>
					<td style="text-align:right"><input type="text"  id="rembalance2" value="" name="rembalance2"  readonly="readonly"/></td>	
					<td style="text-align:center"><input type="text" id="dtpayment2" name="dtpayment2" value=""  readonly="readonly" /></td>	
				</tr>
				<tr id="paymnt3" style="display:none">
					<td style="text-align:center">3</td>
					<td style="text-align:right"><input type="text"  id="payment3" value="" name="payment3"  readonly="readonly"/></td>
					<td style="text-align:right"><input type="text"  id="rembalance3" value="" name="rembalance3"  readonly="readonly"/></td>	
					<td style="text-align:center"><input type="text" id="dtpayment3" name="dtpayment3" value=""  readonly="readonly" /></td>	
				</tr>	
				<tr id="paymnt4" style="display:none">
					<td style="text-align:center">4</td>
					<td style="text-align:right"><input type="text"  id="payment4" value="" name="payment4"  readonly="readonly"/></td>
					<td style="text-align:right"><input type="text"  id="rembalance4" value="" name="rembalance4"  readonly="readonly"/></td>	
					<td style="text-align:center"><input type="text" id="dtpayment4" name="dtpayment4" value=""  readonly="readonly"/></td>
				</tr>
				<tr id="paymnt5" style="display:none">
					<td style="text-align:center">5</td>
					<td style="text-align:right"><input type="text"  id="payment5" value="" name="payment5"  readonly="readonly"/></td>
					<td style="text-align:right"><input type="text"  id="rembalance5" value="" name="rembalance5"  readonly="readonly"/></td>	
					<td style="text-align:center"><input type="text" id="dtpayment5" name="dtpayment5" value=""  readonly="readonly"/></td>	
				</tr>
				<tr id="paymnt6" style="display:none">
					<td style="text-align:center">6</td>
					<td style="text-align:right"><input type="text"  id="payment6" value="" name="payment6"  readonly="readonly"/></td>
					<td style="text-align:right"><input type="text"  id="rembalance6" value="" name="rembalance6" readonly="readonly"/></td>	
					<td style="text-align:center"><input type="text" id="dtpayment6" name="dtpayment6" value=""  readonly="readonly"/></td>
				</tr>
				<tr id="paymnt7" style="display:none">
					<td style="text-align:center">7</td>
					<td style="text-align:right"><input type="text"  id="payment7" value="" name="payment7"  readonly="readonly"/></td>
					<td style="text-align:right"><input type="text"  id="rembalance7" value="" name="rembalance7" readonly="readonly"/></td>
					<td style="text-align:center"><input type="text" id="dtpayment7" name="dtpayment7" value=""  readonly="readonly"/></td>					
				</tr>
				<tr id="paymnt8" style="display:none">
					<td style="text-align:center">8</td>
					<td style="text-align:right"><input type="text"  id="payment8" value="" name="payment8"  readonly="readonly"/></td>
					<td style="text-align:right"><input type="text"  id="rembalance8" value="" name="rembalance8"  readonly="readonly"/></td>	
					<td style="text-align:center"><input type="text" id="dtpayment8" name="dtpayment8" value=""  readonly="readonly"/></td>					
				</tr>
				<tr id="paymnt9" style="display:none">
					<td style="text-align:center">9</td>
					<td style="text-align:right"><input type="text"  id="payment9" value="" name="payment9"  readonly="readonly"/></td>
					<td style="text-align:right"><input type="text"  id="rembalance9" value="" name="rembalance9"  readonly="readonly"/></td>
					<td style="text-align:center"><input type="text" id="dtpayment9" name="dtpayment9" value=""  readonly="readonly"/></td>					
				</tr>		 														
				</table>
			</div>
			</td>
	 					
		</TR> 	 --->
	 	

	
 <!--- mstriegel 08/21/2018 
	 <tr style="background-color:##FFFFCC">
		 
		<td colspan="5" style="font-weight: bold;color:red;">Has the resident or the resident's spouse served in the Military?  
		<cfif tenant.cMilitaryVA is 1>
			Yes <input type="radio" name="cMilitaryVA" value="1" onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value" checked="checked"> 
			No  <input type="radio" name="cMilitaryVA" value="0" onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value">
		<cfelseif tenant.cMilitaryVA is 0>
			Yes <input type="radio" name="cMilitaryVA" value="1" onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value"> 
			No  <input type="radio" name="cMilitaryVA" value="0" onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value" checked="checked">
		<cfelse>
			Yes <input type="radio" name="cMilitaryVA" value="1" onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value"> 
			No  <input type="radio" name="cMilitaryVA" value="0" onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value">
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
			<option value="United States Navy Reserve/National Guard">United States Navy Reserve/National Guard</option>
			<option value="United States Army Reserve/National Guard">United States Army Reserve/National Guard</option>
			<option value="United States Air Force Reserve/National Guard">United States Air Force Reserve/National Guard</option>
			<option value="United States Marine Corps Reserve/National Guard">United States Marine Corps Reserve/National Guard</option>
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
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Dates of Service: Start <input type="text" name="cMilitaryStartDate" size="10" onblur="dateformat(this)">
			&nbsp&nbsp&nbsp End 
			<input type="text" name="cMilitaryEndDate"  size="10" onblur="dateformat(this)">    (MM/DD/YYYY)<br>&nbsp;&nbsp; If only month/year given use 1 as the day e.g.: "01/01/1960" </div>
		</td>
	</tr> 
mstriegel 08/21/2018 end ---->
</table>
<table  >
	<tr>
		<cfif Refundables.recordcount GT 0>
		<td style='vertical-align:top;'>
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
								select distinct T.iTenant_ID, (T.cFirstName + ' ' + T.cLastName) as FullName, c.cDescription, inv.iChargeType_ID
								from InvoiceDetail INV 
								join ChargeType ct on (ct.iChargeType_ID = inv.iChargeType_ID and ct.dtRowDeleted is null)
								join Charges	C on (c.iChargeType_ID = ct.iChargeType_ID and c.cDescription = inv.cDescription and c.dtRowDeleted is null)
								join Tenant T on (T.iTenant_ID = inv.iTenant_ID and T.dtRowDeleted is null)
								where inv.dtRowDeleted is null and	ct.bIsDeposit is not null and	ct.bIsRefundable is not null
								and T.cSolomonKey = '#trim(Tenant.cSolomonKey)#' and c.iCharge_ID = #Refundables.iCharge_ID#
							</cfquery>
						
							<cfif Refund.RecordCount GT 0 and Refund.iTenant_ID eq TenantInfo.iTenant_ID and (Refund.cDescription eq Refundables.cDescription)>
								<input type="CheckBox" name="Deposit#Refundables.iCharge_ID#" value="#Refundables.iCharge_ID#" Checked>
							<cfelseif Refund.RecordCount GT 0 and Refund.iTenant_ID neq TenantInfo.iTenant_ID>
								Charged to #Refund.FullName#
							<cfelse>
								<input type="CheckBox" name="Deposit#Refundables.iCharge_ID#" value="#Refundables.iCharge_ID#">
							</cfif>
						</td>
					</tr>
				</cfloop>
			</table>
		</td>
		</cfif>
		
	 <!--- 	<cfif Fees.recordcount GT 0>
		<td style='vertical-align:top;text-align:center;'>
			<table style="width: 70%; height: 100%;">
				<tr>
					<td style="font-weight: bold;"><U>Non-Refundable Fees</U></td>
					<td style="text-align: center;"><U>Check for Yes</U></td>
				</tr>
				
				<cfloop query="Fees">
					<tr>
						<td>#Fees.cDescription#</td>
						<td style="text-align: center;">	
							<cfquery name="CurrentFees" datasource="#APPLICATION.datasource#">
								select distinct T.iTenant_ID, (T.cFirstName + ' ' + T.cLastName) as FullName, c.cDescription, inv.iChargeType_ID
								from invoicedetail inv 
								join chargetype ct on (ct.iChargeType_ID = inv.iChargeType_ID and ct.dtRowDeleted is null)
								join charges c on (c.iChargeType_ID = ct.iChargeType_ID and c.cDescription = inv.cDescription and c.dtRowDeleted is null) 
								join tenant t on (T.iTenant_ID = inv.iTenant_ID and T.dtRowDeleted is null)
								where inv.dtRowDeleted is null and ct.bIsDeposit is not null and	ct.bIsRefundable is null
								and	T.cSolomonKey = '#Tenant.cSolomonKey#' and c.iCharge_ID = #Fees.iCharge_ID#
							</cfquery>
							
							<cfif Tenant.bAppFeePaid eq 1 and FindNoCase("App",Fees.cDescription,1) GT 0>
								Collected
							<cfelseif CurrentFees.RecordCount GT 0 and (CurrentFees.iTenant_ID eq TenantInfo.iTenant_ID)>
								<input type="CheckBox" name="Deposit#Fees.iCharge_ID#" value="#Fees.iCharge_ID#" Checked>
							<cfelseif CurrentFees.RecordCount GT 0 and CurrentFees.iTenant_ID neq TenantInfo.iTenant_ID>
								Charged to #CurrentFees.FullName#
							<cfelse>
								<input type="CheckBox" name="Deposit#Fees.iCharge_ID#" value="#Fees.iCharge_ID#">
							</cfif>
						</td>
					</tr>
				</cfloop>
			</table>
		</td>
		</cfif>  removed per Laurie Bebo 03-03-2012 project 75019--->
		
	</tr>
</table>
<table  >
	
 
	<cfif HouseLog.bIsPDClosed GT 0> <cfset Toggle=1> <cfelse> <cfset Toggle=0> </cfif>		
	<input type="Hidden" name="bNextMonthsRent" value="#Toggle#">
	<tr>
		<td colspan="4"></td>
	</tr>
	<tr>
		<td colspan="4" style="font-weight:bold;"><U>Contact Information</U></td>
	</tr>
	<tr style="font-weight: bold; background-color:##FFFFCC">
		<td>First Name </td>
		<td> 
			<input type="text" name="cFirstName" value="#ContactInfo.cFirstName#" onBlur="this.value=ltrs(this.value); upperCase(this);">
		</td>	
		<td>&nbsp;</td>
<!---         <td id="contactpripayor" style="text-align:center;  display:block;">    
            &nbsp;Is this Contact the Primary Payor?<br />	
			<cfset bit= iif(ContactInfo.bIsPrimaryPayer IS 1, DE('Checked'), DE('Unchecked'))>
			<input type="CheckBox" name="ContactbIsPrimaryPayer" Value="1" #Variables.bit# onClick="primarypayor(this);">	
		</td>	 --->	
	</tr>
	<tr style= "Font-weight: bold;">
		<td>Last Name </td>
		<td > 
			<input type="text" name="cLastName" value="#ContactInfo.cLastName#" onBlur="this.value=ltrs(this.value); upperCase(this);">
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
					ContactInfo.iRelationshipType_ID eq RelationShips.iRelationshipType_ID){selected='selected';}
					else{selected='';}
				</cfscript>
				<option value="#RelationShips.iRelationshipType_ID#" #selected#> #RelationShips.cDescription# </option> 
			</cfloop>
			</select>
        </td>
        <td  colspan="2">
			&nbsp;Does this Contact have<br /> the Power of Attorney for Health Care?
			<cfif ContactInfo.bIsMedicalProvider IS 1> <cfset bit="Checked"> <cfelse> <cfset bit="UnChecked"> </cfif>			
			<input type="CheckBox" name="bIsMedicalProvider" Value="1" #Variables.bit#>
		</td>
	</tr>

	<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
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
	</cfif>
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
		<td colspan="4"><input type="text" Name="cAddressLine1" value="#ContactInfo.cAddressLine1#" size="40" maxlength="40"
        				onblur="upperCase(this);">
        </td>
	</tr>
	<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;">Address Line 2</td>
		<td colspan="4"> <input type="text" Name="cAddressLine2" value="#ContactInfo.cAddressLine2#" size="40" maxlength="40"
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
				areacode1 = left(ContactInfo.cPhoneNumber1,3); prefix1 = Mid(ContactInfo.cPhoneNumber1,4,3); number1 = right(ContactInfo.cPhoneNumber1,4);
			</cfscript>
			<input type="text" name="areacode1"	size="3"  id="areacode1" value="#Variables.areacode1#" maxlength="3" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onblur="Three(this);"> -
			<input type="text" name="prefix1"   size="3"  id="prefix1"   value="#Variables.prefix1#"   maxlength="3" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onblur="Three(this);"> -
			<input type="text" name="number1"   size="4"  id="number1"   value="#Variables.number1#"   maxlength="4" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onblur="Four(this);">
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
			<input type="text" name="areacode2"	size="3" id="areacode2" value="#Variables.areacode2#" maxlength="3" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onblur="Three(this);"> -
			<input type="text" name="prefix2"   size="3" id="prefix2"   value="#Variables.prefix2#"   maxlength="3" onKeyUp="this.value=LeadingZeroNumbers(this.value);"  onblur="Three(this);"> -
			<input type="text" name="number2"   size="4" id="number2"   value="#Variables.number2#"   maxlength="4" onKeyUp="this.value=LeadingZeroNumbers(this.value);"  onblur="Four(this);">
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
			<input class="SaveButton" type="submit" name="Save" value="Save" onmouseover="return hardhaltvalidation(MoveInForm); checkNRF();" 
			onclick ="return hardhaltvalidation(MoveInForm); ">
		</td>
		<td colspan="2"></td>
		<td width="478" style= "text-align: right;">
			<input class="DontSaveButton" type="button" name="DontSave" value="Don't Save" onClick="redirect()">
		</td>
	</tr>
	<tr>
		<td colspan="4" style="font-weight: bold; color: red;">	<U>NOTE:</U> You must SAVE to keep information which you have entered!<br /> </td>
	</tr>
	</table>
</td> </tr> 
</table>
</form>
</cfoutput>

<cfinclude template="../../Footer.cfm">