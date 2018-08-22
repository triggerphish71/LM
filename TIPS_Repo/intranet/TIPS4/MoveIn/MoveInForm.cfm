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
|MStriegel   | 08/21/2018 | Removed the hidden field for militaryVA                            |
 -----------------------------------------------------------------------------------------  --->
<cfset oMIServices = createObject("component","Intranet.TIPS4.CFC.Components.MoveIn.MoveInFormServices")>

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

<cfset regCheck = oMIServices.getRegCheck(tenantID=url.id)>
<cfscript>
	Action = iif(RegCheck.dtMoveIn EQ '',DE('MoveInFormInsert.cfm'),DE('MoveInFormUpdate.cfm'));
</cfscript>
<cfset tenant = oMIServices.getTenantInfo(tenantID=url.id)>
<cfset resetNRF = oMIServices.getResetNRF(tenantid = url.id)>
<cfset qryRC1740 = oMIServices.getQryRC(theData={houseID=tenant.iHouse_id,cChargeSet=tenant.cChargeSet,tenantID=tenant.iTenant_id,chargeTypeID=1740})>
<cfset qryRC1741 = oMIServices.getQryRC(theData={houseID=tenant.iHouse_id,cChargeSet=tenant.cChargeSet,tenantID=tenant.iTenant_id,chargeTypeID=1741})>

<cfif qryRC1740.iRecurringCharge_ID is not "">
	<cfset temp = oMIServices.getDelNRFhg(theData={userid=session.userid,recurringChargeID=qryRC1740.iRecurringCharge_ID,tenantID=url.id})>	
</cfif>

<cfif qryRC1741.iRecurringCharge_ID is not "">
	<cfset temp = oMIServices.getDelNRFhg(theData={userid=session.userid,recurringChargeID=qryRC1741.iRecurringCharge_ID,tenantID=url.id})>	
</cfif>

<!--- catch if resident is already moved in --->
<cfif Tenant.iTenantStateCode_ID eq 2> 
	<center><strong style='font-size: large; color: red;'>This tenant is already moved in.<br />You will be redirected in 10 seconds.</strong></center>
	<script> function redirect() { location.href='../MainMenu.cfm'; } setTimeout('redirect()',10000); </script>
	<CFABORT>
</cfif>

<!--- Retrieve all valid diagnosis types --->
<cfset qDiagnosisType = oMIServices.getDiagnosis()>
<!--- Get promotion Codes --->
<cfset qTenantPromotion = oMIServices.getTenantPromotion()>
<!--- retrieve house product line info --->
<cfset qProductLine = oMIServices.getqProductLine(houseID=session.qselectedhouse.ihouse_id)>
<cfset houseDetail = oMIServices.getHouseDetail(houseID=session.qSelectedHouse.iHouse_ID)>
<!--- retrieve residency types --->
<cfset residency = oMIServices.getResidency(theData={houseID=session.qSelectedHouse.iHouse_ID,stateMedicaid=houseDetail.stateMedicaid,houseMedicaid=houseDetail.houseMedicaid})>
<cfset residencyMemoryCare = oMIServices.getResidencyMemoryCare(theData={houseID=session.qSelectedHouse.iHouse_ID,stateMedicaid=houseDetail.stateMedicaid,houseMedicaid=houseDetail.houseMedicaid})>

<!--- Retreive list of State Codes, Phone types, RelationShip Types, Residency Types --->
<cfinclude template="../Shared/Queries/StateCodes.cfm">
<cfinclude template="../Shared/Queries/PhoneType.cfm">
<cfinclude template="../Shared/Queries/Relation.cfm">
<cfinclude template="../Shared/Queries/TenantInformation.cfm">
<!--- replaced the include to shared/queries/availableapartments with the call below 
      the new query removes any apartments that have 2 or more occupants.
--->
<cfset available = oMIServices.getAvailableApt(houseID=session.qSelectedHouse.iHouse_ID)>
<!--- Gets Active assesment points.  --->
<cfset qapoints = oMIServices.getAppPoints(tenantID=tenant.iTenant_Id)>
<!--- query for prior move in invoice --->
<cfset qPriorMI = oMIServices.getPriorMI(tenantID=tenant.iTenant_ID,solKey=tenant.cSolomonKey)>
<cfscript>
	if (qPriorMI.recordcount GT 0) { Action='MoveInFormUpdate.cfm';}
</cfscript>	
<!--- Include Intranet Header --->
<cfinclude template="../../header.cfm">

<!--- Check for Existence Of Respite Rates --->
<cfset qRespiteChargeCheck = oMIServices.getRespiteChargeCheck(houseID=session.qSelectedHouse.iHouse_ID)>
<cfset qryNRFDef = oMIServices.getNRFDef()>
<cfset qryVADef = oMIServices.getVADef(datasource="DMS")>  
<cfset getNRF = oMIServices.getNRF(houseID=session.qSelectedHouse.iHouse_ID)>

<!--- respite catch ---->
<cfif qRespiteChargeCheck.RecordCount eq 0 and Tenant.iResidencyType_ID eq 3>
	<script> alert('There are no respite rates entered for this house. \r Please  contact your AR Specialist for assistance</>');</script>
</cfif>
 
<!--- Retrieve the House Status --->
<cfset HouseLog = oMIServices.getHouseLog(houseID=session.qSelectedHouse.iHouse_id)>
<!--- Retrieve the any house specific Deposits --->
<cfset qHouseDeposits = oMIServices.getHouseDeposits(houseID=session.qSelectedHouse.iHouse_ID)>
<!--- Retrieve all DepositTypes that are Refundable  --->
<cfset Refundables = oMIServices.getRefundables(codeblock=session.codeBlock,houseDepositRC=qHouseDeposits.recordCount,houseID=session.qSelectedHouse.iHouse_ID)>
<!--- Retreivea all DepositTypes that are Fees (Non-Refundable) --->
<cfset Fees = oMIServices.getFees(codeblock=session.codeBlock,houseDepositRC=qHouseDeposits.recordCount,houseID=session.qSelectedHouse.iHouse_ID)>
<!--- Retrieve all pertenant charges. Both General and House Specific --->
<cfif isdefined("url.charges")>
	<cfset charges = url.charges>
<cfelse>
	<cfset charges = "">
</cfif>
<cfset AvailableCharges = oMIServices.getAvailableCharges(houseID=session.qSelectedHouse.iHouse_ID,chargeID=charges)>
<cfset bondhouse = oMIServices.getBondHouse(houseID=session.qSelectedHouse.iHouse_ID)>
<cfif NOT isNumeric(bondhouse.iBondHouse)>
    <cfset bondhouse.iBondHouse = 0>
</cfif>
<cfset occupied = oMIServices.getOccupied(houseID=session.qSelectedHouse.iHouse_ID)>

<cfset OccupiedList=ValueList(Occupied.iAptAddress_ID)>
<cfset OccupiedNonCompanion = oMIServices.getOccupiedNonCompanion(houseID=session.qSelectedHouse.iHouse_ID)>

<cfset OccupiedNonCompanionlist =ValueList(OccupiedNonCompanion.iAptAddress_ID)>
<cfif bondhouse.iBondHouse eq 1>
	<!--- Apartment List applicable for Bond Tenant Use --->
	<cfset BondAppAptList = oMIServices.getBondAppAptList(houseID=session.qSelectedHouse.iHouse_ID)>	
	<cfset BondIncludedAptList = ValueList(BondAppAptList.iAptAddress_ID)>
	<!--- Apartment List of apartments set as bond ---> 
	<cfset BondAptList = oMIServices.getBondAptList(houseID=session.qSelectedHouse.iHouse_ID)>
	<cfset BondAptList = ValueList(BondAptList.iAptAddress_ID)>
	<!--- Count of current bond designated apts --->
	<cfset bAptCount = oMIServices.getBAptCount(houseID=session.qSelectedHouse.iHouse_ID)>
	<!--- Count of apts that were built and apply to the bond designation --->
	<cfset AptCountTot = oMIServices.getAptCountTot(houseID=session.qSelectedHouse.iHouse_ID)>
	<!--- Apartment addresses that are occupied and pertain to bond applicable --->
	<cfset occupied = oMIServices.getOccupiedApt(houseID=session.qSelectedHouse.iHouse_ID)>
	<cfset OccupiedRowCount = (Occupied.recordcount)>
</cfif>
<cfif bondhouse.bIsMedicaid eq 1>
	<!--- Apartment List of apartments set as Medicaid ---> 
	<cfset MedicaidAptList = oMIServices.getMedicaidAptList(houseID=session.qSelectedHouse.iHouse_ID)>
	<cfset MedicaidApartmentList = ValueList(MedicaidAptList.iAptAddress_ID)>
	<!--- Apartment List of apartments set as Medicaid and bond--->
  	<cfset MedicaidbondApt = oMIServices.getMedicaidBondApt(houseID=session.qSelectedHouse.iHouse_ID)>
	<cfset MedicaidbondAptList= ValueList(MedicaidbondApt.iAptAddress_ID)>
	<!--- Apartment List of apartments set as Medicaid and bond incuded--->
	<cfset MedicaidbondincludedApt = oMIServices.getMedicaidbondincludedApt(houseID=session.qSelectedHouse.iHouse_Id)>
	<cfset MedicaidbondIncludedAptList= ValueList(MedicaidbondincludedApt.iAptAddress_ID)>
	<cfset MedicaidAptCount = oMIServices.getMedicaidAptCount(houseID=session.qSelectedHouse.iHouse_id)>
	<!--- Count of total apts --->
	<cfset AptCountTotal = oMIServices.getMedicaidAptCountTot(houseID=session.qSelectedHouse.iHouse_ID)>
	<!---Occupied medicaids rooms--->
	<cfset OccupiedMedicaidApt = oMIServices.getOccupiedMedicaidApt(houseID=session.qSelectedHouse.iHouse_ID)>
	<cfset OccupiedMedicaidAptList=ValueList(OccupiedMedicaidAPt.iAptAddress_ID)>
</cfif>
<cfset MemCareAptList = oMIServices.getMemCareAptList(houseID=session.qSelectedHouse.iHouse_ID)>		

<cfset MemoryCareApartmentList = ValueList(MemcareAptList.iAptAddress_ID)>
<!---Occupied medicaids rooms--->
<cfset OccupiedMemcareApt = oMIServices.getOccupiedMemcareApt(houseID=session.qSelectedHouse.iHouse_ID)>

<cfset OccupiedMemcareAptList=ValueList(OccupiedMemcareApt.iAptAddress_ID)>
<cfset qryAptType = oMIServices.getAptType(houseID=session.qSelectedHouse.iHouse_ID)>

<!--- mstriegel:10/23/2017 this is for the bundled pricing section --->
<!--- create a local struct variable to prevent var leak --->
<cfset loc = {}>
<!--- QofQ to get only the ids for stuido apartments --->
<cfquery name="loc.apartmentType" dbtype="query">
	SELECT iAptAddress_ID
	FROM Available
	WHERE iAptType_ID IN (1,2,16,18,33,34,50,51,52,53,58,71,80,81,85,86,87,88,93,96,97,100,101,102)	
</cfquery>
<cfset qGetBundledPricingHouses= oMIServices.getBundledPricingHouses()> 

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
<link rel="stylesheet" href="..Assets/CSS/MoveIn/MoveInForm.css">
<script language="JavaScript" src="../../global/calendar/ts_picker_Validate.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript" src="../Shared/JavaScript/global.js"></script>
<script type="text/javascript" src="../Assets/Javascript/MoveIn/MoveInForm.js"></script> 

	 <div id="selectopt" style="visibility:hidden;">
 	<select id="masterOpt">
 		<cfoutput query="available">
 			<option value="#available.iAptAddress_ID#">#available.cDescription#</option>
 		</cfoutput>
 	</select>
 </div>

<script> 
	var d = new Date(2011,10,30);
function initialize() { 
  	var	df0=document.forms[0];
	respiterates(df0.iResidencyType_ID); 
	<cfoutput>
		<cfif isDefined("tenantinfo.dtRentEffective") and tenantinfo.dtRentEffective neq "">
			df0.RentMonth.value='#trim(month(tenantinfo.dtRentEffective))#';
			dayslist(df0.RentMonth,df0.RentDay,df0.RentYear);
			df0.RentDay.value='#trim(day(tenantinfo.dtRentEffective))#';
			df0.RentYear.value='#trim(year(tenantinfo.dtRentEffective))#';	
		<cfelse>
			df0.RentMonth.value='#trim(month(now()))#';
			dayslist(df0.RentMonth,df0.RentDay,df0.RentYear);
			df0.RentDay.value='#trim(day(now()))#';
			df0.RentYear.value='#trim(year(now()))#';		
		</cfif> 
		<cfif isDefined("tenantinfo.dtMoveIn") and tenantinfo.dtMoveIn neq "">
			df0.MoveInMonth.value='#trim(month(now()))#';
			dayslist(df0.MoveInMonth,df0.MoveInDay,df0.MoveInYear);
			df0.MoveInDay.value='#trim(day(now()))#';
			df0.MoveInYear.value='#trim(year(now()))#';		
		<cfelse>
			var dateobj= new Date() ;
			var month = dateobj.getMonth() + 1;
			var day = dateobj.getDate() ;
			var year = dateobj.getFullYear();
			df0.MoveInMonth.value='#trim(month(now()))#';
			dayslist(df0.MoveInMonth,df0.MoveInDay,df0.MoveInYear);
			df0.MoveInDay.value='#trim(day(now()))#';
			df0.MoveInYear.value='#trim(year(now()))#';			
		</cfif> 			
		<cfif tenantinfo.iproductline_id neq "">
			document.getElementById("iproductline_id").value='';
			document.getElementById("iResidencyTypeID").value='';
			//document.getElementById("iproductline_id").value=#trim(tenantinfo.iproductline_id)#
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

window.onload=initialize;
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

<cfoutput>
<form name="MoveInForm" action="#Variables.Action#" method="POST" onSubmit="return requiredBeforeYouLeave(); "><!---   hardhaltvalidation(); --->

<br/><a href="../MainMenu.cfm" style="font-size: 18;"> <B>Exit Without Saving</B></a><br/>
	<input type="hidden" name="iTenant_ID" value="#URL.ID#">
	<input type="hidden" name="cSolomonKey" value="#Tenant.cSolomonKey#">
	<!--- mstriegel 08/21/2018
	 <input type="hidden" name="cMilitaryVA" value=""> 
	 mstriegel 08/21.2018  end --->
	<input type="hidden" name="hasExecutor" value="">
	<input type="hidden" name="NrfDiscApprove" value="" />
	<input type="hidden" name="stateID" value="#session.qselectedhouse.cstatecode#">
	<input type="hidden" name="thisHouseID" value="#session.qselectedhouse.iHouse_ID#">		
	<input type="text" name="Message" value="" size="75" style="color: red; font-weight: bold; font-Size: 16; text-align: center;" readonly="readonly">
	<cfif HouseDetail.mStateMedicaidAmt_BSF_Daily is ''> 
		<input  type="hidden" name="StateMedicaidAmtBSFDaily"  id="iStateMedicaidAmtBSFDaily" value="NF" />
	<cfelse>
		<input  type="hidden" name="StateMedicaidAmtBSFDaily"  id="iStateMedicaidAmtBSFDaily" value="#HouseDetail.mStateMedicaidAmt_BSF_Daily#" />	
	</cfif>
	<input type="hidden" name="NrfAdj" value =  '' /> 	
	<input type="hidden" name="NrfDisc" value = '' />   	
	<input type="hidden" name="OccupiedListtest" id="OccupiedListtest" value = '<cfoutput> #OccupiedNoncompanionList# </cfoutput>' />
	<input type="hidden" name="ResidentName" id="ResidentName" value = '<cfoutput> #Tenant.cFirstname# #Tenant.cLastName# </cfoutput>' />
	<!--- mstriegel:10/23/17 added list of studios to a hidden form element --->
	<input type="hidden" name="StudioIdLst" id="studioIDLst" value="<cfoutput>#loc.lstApartmentTypeID#</cfoutput>">
	<input type="hidden" nmae="MCAptList" id="mcAptList" value="<cfoutput>#MemoryCareApartmentList#</cfoutput>">

<table width="640px"> 
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
			<input type="text" name="cPreviousAddressLine1" value="#tenant.cPreviousAddressLine1#" 	size="40" maxlength="40" onblur="upperCase(this);">
		</td>
	</tr>
	<tr style="background-color:##FFFFCC">
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Address Line 2 </td>
		<td>
			<input type="text" name="cPreviousAddressLine2" value="#tenant.cPreviousAddressLine2#" size="40" maxlength="40" onblur="upperCase(this);">
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
		<td>
			<select id="iproductline_id" name="iproductline_id"  onChange="DisplayResidencyType(this);">
				<option value="" Selected>Select product.</option>
				<cfloop query="qproductline">
					<option value="#qproductline.iproductline_id#">#qproductline.cDescription#</option>
				</cfloop>
			</select>
		</td>
		
		<td colspan="2"></td>
	<tr>
		<td style="font-weight: bold;"> Residency Type</td>		
		<td colspan="5">		
			<select name="iResidencyType_ID" ID="iResidencyTypeID" onChange="respiterates(this);typMedicaid(this);DisplayAPtList(this);isMedicaidHouse(this);">
				<option value="">Select Residency Type.</option>
			</select>
			<!--- this ones if for AL --->
			<select name="iResidencyType_ID1" ID="iResidencyTypeID_1" style="visibility: hidden" onChange="respiterates(this);typMedicaid(this);DisplayAPtList(this);isMedicaidHouse(this);">
				<option value="1"></option> 
				<cfloop query="Residency">
					<option value="#Residency.iResidencyType_ID#" > #Residency.cDescription# </option>
				</cfloop>
			</select>
			<!--- this one is for MC --->
			<select name="iResidencyType_ID2" ID="iResidencyTypeID_2" style="visibility: hidden" onChange="respiterates(this);typMedicaid(this);DisplayAPtList(this);isMedicaidHouse(this);">
				<option value="2"></option>
				<cfloop query="ResidencyMemoryCare">
					<option value="#ResidencyMemoryCare.iResidencyType_ID#" >#ResidencyMemoryCare.cDescription# </option>
				</cfloop>
			</select>
		</td>		
	</tr>	

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
	
    	<select name="iAptAddress_ID2" ID="iAptNum2" style="visibility: hidden">
    	<!--- mstriegel:11/09/2017 added the default option below --->s
    	<option value="">Select Apartment</option>
	<cfif (#bondhouse.iBondHouse# eq 0) and (#bondhouse.bIsMedicaid# eq 1)>

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
	<cfif (#bondhouse.iBondHouse# eq 1) and (#bondhouse.bIsMedicaid# eq 1)>
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
		<cfif (#bondhouse.iBondHouse# eq 0) and (#bondhouse.bIsMedicaid# eq 1)>
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
	
	<cfelseif (#bondhouse.iBondHouse# eq 1) and (#bondhouse.bIsMedicaid# eq 1)>
			 <cfloop query="Available">
				  <cfscript>
						if (ListFindNoCase(OccupiedList,Available.iAptAddress_ID,",") GT 0)
						{Note = '(Occupied) ';} 
						else
					    {Note='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
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
	
	<cfelseif (#bondhouse.iBondHouse# eq 1) and (#bondhouse.bIsMedicaid# eq "")>
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
				<cfif (ListFindNoCase(MemoryCareApartmentList,Available.iAptAddress_ID,",") EQ 0)>
				<option value= "#Available.iAptAddress_ID#" >
				 #Available.cAptNumber# - #Available.cDescription##NOTE##NOTE1#
				 </option>
				</cfif>
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
</tr>			    		
<tr>
	<td  style="font-weight: bold;">Financial Possession Date</td>
	<td colspan="2">		
		<select name="RentMonth" id="RentMonth" onChange="dayslist(RentMonth,RentDay,RentYear);">
			<option  value="">Select</option>
			<cfloop index="i" from="1" to="12" step="1">
			<option value="#i#" > #i# </option>
			</cfloop>
		</select>
		/
		<select name="RentDay" onChange="dayslist(RentMonth,RentDay,RentYear);">
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

<tr>
	<td  style="font-weight: bold;">Physical Move In Date</td>
	<td colspan="2">		
		<select name="MoveInMonth" id="MoveInMonth" onChange="dayslist(MoveInMonth,MoveInDay,MoveInYear);">
			<option  value="">Select</option>
			<cfloop index="i" from="1" to="12" step="1">
				<option value="#i#" > #i# </option>
			</cfloop>
		</select>
		/
		<select name="MoveInDay" onChange="dayslist(MoveInMonth,MoveInDay,MoveInYear);verifyMoveinPossessionDates();">
		<option  value="">Select</option>	
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
		<input type="text" name="csleveltypeset" value="#TenantInfo.csleveltypeset#" size="3" maxlength="3" style="border:none;background:transparent;text-align:center;" readonly>
	</td>
</tr>
<tr style="background-color:##FFFFCC">
	<td style="font-weight: bold;"> Service Points </td>
	<td colspan="2">	
	<cfif  IsDefined("qapoints.iSPoints")  and  qapoints.iSPoints  is not "">
		 <input type="text" name="iSPoints" value="#trim(qapoints.iSPoints)#" size="3" maxlength="3" style="border:none;background:transparent;text-align:center;" readonly>
	<cfelse>
		 <input type="text" name="iSPoints" value="0" size="3" maxlength="3" style="border:none;background:transparent;text-align:center;" readonly>		
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
		<input type="checkbox" name="TenantbIsPayer"  id="TenantbIsPayer" value="1" style="text-align: center;"	 onKeyUp="this.value=Numbers(this.value)" 	#Variables.Check#  onClick="residentPayor(this)">		
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
	<tr style="background-color:##FFFFCC">
		<td colspan="5" style="Font-weight: bold;"> 
			Has the resident signed the Residency Agreement?
			<cfset bit= iif(Tenant.cResidenceAgreement IS 1, DE('Checked'), DE('Unchecked'))>
			<input type= "CheckBox" name= "cResidenceAgreement" Value = "1" #Variables.bit#>	
		</td>
	</tr>
</cfif>
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
</table>
<table>

	<cfset qryMCO = oMIServices.getMCO(stateCodeID=houseDetail.cstatecode)> 
	<tr id="typMedicaid" style="display:none" >
		<td style="text-align:center; font-weight:bold;" colspan="2">Medicaid Move-in Information</td>
	</tr>
	<tr id="typMedicaid9" style="display:none" >
		<td>Select MCO Provider</td>
		<td>
			<select name="cMCO">
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
		<tr id="typMedicaid5" style="display:none"></tr>
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
			<cfif ContactInfo.bIsMedicalProvider IS 1>
				<cfset bit="Checked"> 
			<cfelse> 
				<cfset bit="UnChecked">
			</cfif>			
			<input type="CheckBox" name="bIsMedicalProvider" Value="1" #Variables.bit#>
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
		<td colspan="4"><input type="text" Name="cAddressLine1" value="#ContactInfo.cAddressLine1#" size="40" maxlength="40"  onblur="upperCase(this); validatePayor();">
        </td>
	</tr>
	<tr style="background-color:##FFFFCC">
		<td style="font-weight: bold;">Address Line 2</td>
		<td colspan="4"> <input type="text" Name="cAddressLine2" value="#ContactInfo.cAddressLine2#" size="40" maxlength="40" onblur="upperCase(this);">
        </td>
	</tr>
	<tr>
		<td style="font-weight: bold;">City</td>
		<td colspan="5">
			<input type="text" Name="cCity" value="#ContactInfo.cCity#" size="24" maxlength="30" onkeypress="return allowOnlyLettersOnKey(event);" onblur="upperCase(this);">
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
			<input type="text" name="areacode1"	size="3"  id="areacode1" value="#Variables.areacode1#" maxlength="3" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onblur="Three(this);"> -
			<input type="text" name="prefix1"   size="3"  id="prefix1" value="#Variables.prefix1#"   maxlength="3" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onblur="Three(this);"> -
			<input type="text" name="number1"   size="4"  id="number1" value="#Variables.number1#" maxlength="4" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onblur="Four(this);">
			<input type="hidden" name="iPhoneType1_ID" value="1">
		</td> 
	</tr>
	<tr>
		<td style="font-weight: bold;">Cell Phone</td>
		<td colspan="3">
			<cfscript>
				areacode2 = left(ContactInfo.cPhoneNumber2,3); 
				prefix2 = mid(ContactInfo.cPhoneNumber2,4,3); 
				number2 = right(ContactInfo.cPhoneNumber2,4);
			</cfscript>
			<input type="text" name="areacode2"	size="3" id="areacode2" value="#Variables.areacode2#" maxlength="3" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onblur="Three(this);"> -
			<input type="text" name="prefix2" size="3" id="prefix2" value="#Variables.prefix2#"   maxlength="3" onKeyUp="this.value=LeadingZeroNumbers(this.value);"  onblur="Three(this);"> -
			<input type="text" name="number2" size="4" id="number2" value="#Variables.number2#" maxlength="4" onKeyUp="this.value=LeadingZeroNumbers(this.value);"  onblur="Four(this);">
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