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
 -----------------------------------------------------------------------------------------  --->
 <cfoutput> 
<!---<cfdump var="#session#"><br/><cfabort>  --->

<cfparam name="NrfDiscApprove" default="">
<cfparam name="CommFeePayment" default="">
<cfparam name="monthdays1" default="">
<cfparam name="monthdays2" default="">
<cfparam name="dtcompare" default="">
<cfparam name="dtcompare2" default="">
<cfparam name="DAYSINMONTH1" default="">
<cfparam name="DAYSINMONTH2" default="">
<cfparam name="ACCTPERIOD" default="">
<cfparam name="THISACCTPERIOD1" default="">
<cfparam name="THISACCTPERIOD2" default="">
<cfparam name="NBRDAYS2" default="">
<cfparam name="NBRDAYS1" default="">
<!--- --->
<cfif isdefined('url.acctperiod1')>
	<cfset thisacctperiod1 = #url.acctperiod1#>
<cfelseif IsDefined('form.acctperiod1')>
		<cfset thisacctperiod1 = #form.acctperiod1#>
</cfif>
<cfif isdefined('url.acctperiod2')>
	<cfset thisacctperiod2 = #url.acctperiod2#>
<cfelseif IsDefined('form.acctperiod2')>
		<cfset thisacctperiod2 = #form.acctperiod2#>
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

	<cfquery name="tenantype" datasource="#APPLICATION.datasource#">
	Select ts.iresidencytype_id, t.ihouse_id, ts.dtmovein, h.cname
	, rt.cdescription,ts.iproductline_id ,ts.iResidencyType_ID
	, t.cbillingtype, ts.iAptAddress_ID,h.bIsMemoryCare,ts.dtrenteffective
	,h.isecuritydeposit, chgst.cname cchargeset
	,t.cfirstname + ' ' + t.clastname as 'Resident'
	from tenant t join tenantstate ts on t.itenant_id = ts.itenant_id
	join house h on t.ihouse_id = h.ihouse_id
	join residencytype rt on ts.iresidencytype_id = rt.iResidencyType_ID
	join chargeset chgst on h.ichargeset_id = chgst.ichargeset_id
	where t.itenant_id =  #url.ID#
	</cfquery>
	<cfquery name="qryHouseChargeset" datasource="#APPLICATION.datasource#">
	select chgs.cName as  'ChargeSet'
	from house h join Chargeset chgs on h.ichargeset_id = chgs.ichargeset_id
	where h.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
	</cfquery>
<cfif tenantype.iresidencytype_id is 2>
	<cfquery name="qryMedicaidHouse" datasource="#APPLICATION.datasource#">
		select * from HouseMedicaid where iHouse_id = #tenantype.ihouse_id#
	</cfquery>

	<cfif qryMedicaidHouse.recordcount is 0>
<!--- 		<dir>Medicaid is not applicable for this community<br /><!--- No Medicaid Rates have been established for #tenantype.cname#<br />
		Contact AR department to have Medicaid Rates established.<br /> --->
		<a href="MoveInForm.cfm?ID=#url.ID#">Return to Move In Screen</a><br /></dir> --->
		<cfset processname = "Resident Move In" >
				<cfset residentname = #tenantype.resident#>
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
	<cfquery name="FindOccupancy" datasource="#application.datasource#">
		select t.iTenant_ID, iResidencyType_ID, ST.cDescription as Level, ts.dtMoveIn, ts.dtMoveOut
		from AptAddress AD
		join TenantState ts on (ts.iAptAddress_ID = ad.iAptAddress_ID and ts.dtRowDeleted is null)
		join Tenant T	on (t.iTenant_ID = ts.iTenant_ID and t.dtRowDeleted is null)
		join SLevelType ST on (ST.cSLevelTypeSet = t.cSLevelTypeSet 
		and ts.iSPoints between ST.iSPointsMin and ST.iSPointsMax)
		where ad.dtRowDeleted is null and ts.iTenantStateCode_ID = 2
			and ad.iAptAddress_ID = #tenantype.iAptAddress_ID#	
			and ts.iTenant_ID <>  #url.ID#
	</cfquery>
	<!---<cfdump var="#FindOccupancy#">--->
	<cfif FindOccupancy.RecordCount gt 0>
		<cfif   ((FindOccupancy.iResidencyType_ID eq 1) 
			and (tenantype.iResidencyType_ID eq 2))
			or (FindOccupancy.dtMoveIn LTE createODBCDateTime(tenantype.dtMovein))>
			<cfset Occupancy = 2>
		<cfelse> 
			<cfset Occupancy = 1> 
		</cfif>
	<cfelse> 
		<cfset Occupancy = 1> 
	</cfif>
	<!--- #Occupancy# --->
	
	<cfquery name="qrybiscompanion" datasource="#APPLICATION.datasource#">
		select * from aptaddress ad join apttype at on ad.iapttype_ID= at.iapttype_ID
		and ad.iaptaddress_ID= #tenantype.iAptAddress_ID#
	</cfquery>
	<!---<cfdump var="#qrybiscompanion#">--->
<cfquery name="qryHouseCommunityFee" datasource="#APPLICATION.datasource#">
	select mamount from charges chg
	join house h on h.ihouse_id = chg.ihouse_id
	join chargeset chgset on h.ichargeset_id = chgset.ichargeset_id
	where chg.cchargeset = chgset.cdescription
	and h.ihouse_id = #tenantype.ihouse_id# and chg.ichargetype_id = 69
	and chg.dtrowdeleted is null and chgset.dtrowdeleted is null
</cfquery>
  <!---  tenantype.cbillingtype:: #tenantype.cbillingtype#  Occupancy: #Occupancy# ---> 

	<cfif tenantype.cbillingtype is 'M'>   
		<cfif Occupancy is 1>
		 <cfquery name="qryAptType" datasource="#APPLICATION.datasource#">
			select  aa.iAptAddress_ID ,
				aa.iAptType_ID, aa.cAptNumber
				,chg.mamount
				,at.cdescription
				,chg.ichargetype_id
				,ct.cdescription
				,ct.bResidencyType_ID
				,ops.cname as 'Region' 
				,ts.iresidencytype_id 
				,ts.mBSFOrig				
			from tenant t 
			join  tenantstate ts on t.itenant_id = ts.itenant_id
			join house h on t.ihouse_id = h.ihouse_id
			join chargeset chgst on h.ichargeset_id = chgst.ichargeset_id
			join dbo.AptAddress AA on aa.iAptAddress_id = ts.iAptAddress_id
			join dbo.AptType AT on aa.iAptType_ID = at.iAptType_ID
			join charges chg on chg.iAptType_ID = at.iAptType_ID and chg.ihouse_id = t.ihouse_id
			join dbo.ChargeType ct on ct.ichargetype_id = chg.ichargetype_id 
			join opsarea ops on h.iopsarea_id = ops.iopsarea_id
			where chg.ihouse_id = t.ihouse_id 
				and chg.cchargeset = chgst.cname 
				and   ts.itenant_id =  #url.ID# 
				and chg.dtrowdeleted is null
				and aa.dtrowdeleted is null
				and ct.bisdaily is null
				and aa.dtrowdeleted is null
				and chg.iresidencytype_id = ts.iresidencytype_id
		</cfquery>
		<cfelse><!--- Occupancy = 2 --->
			<cfquery name="qryAptType" datasource="#APPLICATION.datasource#">
				select 
				chg.mamount
				,chg.ichargetype_id
				,ops.cname as 'Region' 
				,ts.iresidencytype_id 
					,ts.mBSFOrig	
				from tenant t 
				join  tenantstate ts on t.itenant_id = ts.itenant_id
				join house h on t.ihouse_id = h.ihouse_id
				join chargeset chgst on h.ichargeset_id = chgst.ichargeset_id
				join opsarea ops on h.iopsarea_id = ops.iopsarea_id
				join charges chg on chg.ihouse_id = t.ihouse_id  and chg.cchargeset = chgst.cname
				join dbo.AptAddress AA on aa.iAptAddress_id = ts.iAptAddress_id
				join dbo.AptType AT on aa.iAptType_ID = at.iAptType_ID and at.iapttype_ID= #qrybiscompanion.iapttype_ID#
				<cfif qrybiscompanion.biscompanionsuite EQ '' or qrybiscompanion.biscompanionsuite eq 0>
				 and chg.ioccupancyposition = 2
				 </cfif>
				<cfif tenantype.iproductline_ID eq 2> and chg.ichargetype_ID=1748</cfif>
				where t.itenant_id =    #url.ID#	
			</cfquery>	
			<cfset StrMonth1 =  #left(thisacctperiod1,4)# & '-' & #right(thisacctperiod1,2)#  & '-01'  >
			<cfset StrMonth2 =  #left(thisacctperiod2,4)# & '-' & #right(thisacctperiod2,2)#  & '-01'  >
			<!--- <br /> StrMonth1:: #left(thisacctperiod1,4)# ::: StrMonth2: #right(thisacctperiod1,2)# 		
			<br /> StrMonth1:: #StrMonth1# ::: StrMonth2: #StrMonth2#  --->
			<cfset DaysInMonth1 = #daysinmonth(StrMonth1)#>
			<cfset DaysInMonth2 = #daysinmonth(StrMonth2)#>
		</cfif>
	<cfelseif tenantype.iresidencytype_id is not 2>
		 <cfquery name="qryAptType" datasource="#APPLICATION.datasource#">
			select  aa.iAptAddress_ID ,
				aa.iAptType_ID, aa.cAptNumber
				,chg.mamount
				,at.cdescription
				,chg.ichargetype_id
				,ct.cdescription
				,ct.bResidencyType_ID
				,ops.cname as 'Region' 
				,ts.iresidencytype_id 
				,ts.mBSFOrig
			from tenant t 
			join  tenantstate ts on t.itenant_id = ts.itenant_id
			join house h on t.ihouse_id = h.ihouse_id
			join chargeset chgst on h.ichargeset_id = chgst.ichargeset_id
			join dbo.AptAddress AA on aa.iAptAddress_id = ts.iAptAddress_id
			join dbo.AptType AT on aa.iAptType_ID = at.iAptType_ID
			join charges chg on chg.iAptType_ID = at.iAptType_ID and chg.ihouse_id = t.ihouse_id
			join dbo.ChargeType ct on ct.ichargetype_id = chg.ichargetype_id 
			join opsarea ops on h.iopsarea_id = ops.iopsarea_id
			where chg.ihouse_id = t.ihouse_id 
				and chg.cchargeset = chgst.cname 
				and   ts.itenant_id =  #url.ID# 
				and chg.dtrowdeleted is null
				and aa.dtrowdeleted is null
				and ct.ichargetype_id = case when (ts.iresidencytype_id = 1) then 89 
											when (ts.iresidencytype_id = 3) then 7 
											when (ts.iresidencytype_id = 5) then   89
											else   31 end
				and aa.dtrowdeleted is null
				and chg.iresidencytype_id = ts.iresidencytype_id
		</cfquery>
	<cfelse>  tenant is Medicaid room type is generic 
	 <br /> thisacctperiod1:: #thisacctperiod1# ::: thisacctperiod2: #thisacctperiod2#  
		<cfset StrMonth1 =  #left(thisacctperiod1,4)# & '-' & #right(thisacctperiod1,2)#  & '-01'  >
		<cfset StrMonth2 =  #left(thisacctperiod2,4)# & '-' & #right(thisacctperiod2,2)#  & '-01'  >
		<!--- <br /> StrMonth1:: #left(thisacctperiod1,4)# ::: StrMonth2: #right(thisacctperiod1,2)# 		
		<br /> StrMonth1:: #StrMonth1# ::: StrMonth2: #StrMonth2#  --->
		<cfset DaysInMonth1 = #daysinmonth(StrMonth1)#>
		<cfset DaysInMonth2 = #daysinmonth(StrMonth2)#>
		<!--- <br /> DaysInMonth1:: #DaysInMonth1# ::: DaysInMonth2: #DaysInMonth2#  --->
		<cfquery name="qryAptType" datasource="#APPLICATION.datasource#">  
			select  aa.iAptAddress_ID ,
				aa.iAptType_ID, aa.cAptNumber
				,chg.mamount
				,at.cdescription
				,chg.ichargetype_id
				,ct.cdescription
				,ct.bResidencyType_ID
				,ops.cname as 'Region' 
				,ts.iresidencytype_id 
				,ts.mBSFOrig
			from tenant t 
			join  tenantstate ts on t.itenant_id = ts.itenant_id
			join house h on t.ihouse_id = h.ihouse_id
			join chargeset chgst on h.ichargeset_id = chgst.ichargeset_id
			join dbo.AptAddress AA on aa.iAptAddress_id = ts.iAptAddress_id
			join dbo.AptType AT on aa.iAptType_ID = at.iAptType_ID
			join charges chg on  chg.ihouse_id = t.ihouse_id
			join dbo.ChargeType ct on ct.ichargetype_id = chg.ichargetype_id 
			join opsarea ops on h.iopsarea_id = ops.iopsarea_id
			where chg.ihouse_id = t.ihouse_id 
				and chg.cchargeset = chgst.cname 
				and   ts.itenant_id =  #url.ID# 
				and chg.dtrowdeleted is null
				and aa.dtrowdeleted is null
 
				and ct.ichargetype_id = case when (ts.iresidencytype_id = 1) then 89 
											when (ts.iresidencytype_id = 3) then 7 
											else   31 end  
				and aa.dtrowdeleted is null
		</cfquery>
	</cfif>
 
  
<!---<cfdump var="#qryAptType#" label="qryAptType">--->
<!---<br /> 
 tenantype.iresidencytype_id is #tenantype.iresidencytype_id#  --->

 	<cfif tenantype.cbillingtype is 'M' and tenantype.iresidencytype_id neq 2> <!---Mshah added here for medicaid at pinicon--->
		<cfset baseNRF = qryAptType.mAmount>
		<cfset  baseNRF = replace(baseNRF, ',' ,'')>
		<cfset  baseNRF = replace(baseNRF, '$' ,'')>		
		<cfquery name="UpdateTenantStateBSF" datasource="#application.datasource#">
			set LOCK_TIMEOUT 60000		
			update TenantState 
			set mBaseNRF = #baseNRF#
			, mBSFOrig =  #qryAptType.mAmount#
			where itenant_id = #url.ID#
		</cfquery>		
	<cfelseif (tenantype.iresidencytype_id is  2)>
		<CFSET thisBaseNRF = 0>
		<cfif ((qryAptType.mBSFOrig is not '') and (qryAptType.mBSFOrig gt 0))>
			<cfquery name="UpdateTenantStateBSF" datasource="#application.datasource#">
				set LOCK_TIMEOUT 60000		
				update TenantState 
				set mBSFOrig =  #qryAptType.mBSFOrig#
				, mBaseNRF = #thisbaseNRF#
				where itenant_id = #url.ID#
			</cfquery>	
		<cfelse>
			<cfquery name="UpdateTenantStateBSF" datasource="#application.datasource#">
				set LOCK_TIMEOUT 60000		
				update TenantState 
				set mBSFOrig =  #qryMedicaidHouse.mMedicaidBSF#
				, mBaseNRF = #thisbaseNRF#
				where itenant_id = #url.ID#
			</cfquery>		
		</cfif>
	<cfelseif  (tenantype.iresidencytype_id is 5)>

			<cfset baseNRF = qryAptType.mAmount * 30.4>
		<!--- <cfset baseNRF = #qryHouseCommunityFee.mamount#> --->
		<cfif IsDefined('baseNRF') and IsNumeric(baseNRF)>
			<cfif (baseNRF gt 0)>
				<cfset thisbaseNRF = #baseNRF#>
			<cfelse>
				<CFSET THISBASEnrf = 0>
			</cfif>
		<CFELSE>
			<CFSET THISBASEnrf = 0>
		</cfif>
		<cfquery name="UpdateTenantStateBSF" datasource="#application.datasource#">
			set LOCK_TIMEOUT 60000		
			update TenantState 
			set mBSFOrig =  #qryAptType.mAmount#
			, mBaseNRF = #thisbaseNRF#
			where itenant_id = #url.ID#
		</cfquery>		
	<cfelse>
	
		<cfset baseNRF = qryAptType.mAmount * 30.4>
		<cfif IsDefined('baseNRF') and IsNumeric(baseNRF)>
			<cfif (baseNRF gt 0)>
				<cfset thisbaseNRF = baseNRF>
			<cfelse>
				<CFSET THISBASEnrf = 0>
			</cfif>
		<CFELSE>
			<CFSET THISBASEnrf = 0>
		</cfif>
		<cfquery name="UpdateTenantStateBSF" datasource="#application.datasource#" result="UpdateTenantStateBSF1">
			set LOCK_TIMEOUT 60000		
			update TenantState 
			set mBSFOrig =  #qryAptType.mAmount#
			, mBaseNRF = #thisbaseNRF#
			where itenant_id = #url.ID#
		</cfquery>	
	</cfif>
	<!---<cfdump var="#qryAptType#">
<cfdump var="#UpdateTenantStateBSF1#">---->
<cfquery name="qrySecDep" datasource="#application.datasource#"> 
Select mamount from charges where ichargetype_id = 53 and ihouse_id = #tenantype.ihouse_id# and cchargeset = '#tenantype.cchargeset#'
</cfquery>
 

<CFSCRIPT>
	stmp= DateFormat(now(),"mmddyy") & TimeFormat(now(),"HHmmss");
	//Check to see if url.insert is given signifying that we are adding a region.
	//Thus, calling HouseInsert.cfm instead of HouseUpdate.cfm
	if (NOT IsDefined("form.iCharge_ID")){
		if (IsDefined("url.MID") AND url.MID NEQ '') { 
			setAction = 'MoveInCredits.cfm?ID=#url.ID#&MID=#url.MID#&NrfDiscApprove=#NrfDiscApprove#';}  
		else { setAction = 'MoveInCredits.cfm?ID=#url.ID#&NrfDiscApprove=#NrfDiscApprove#'; 
		} Action = setAction;
	}
	else { Action = 'MoveInCreditInsert.cfm?NrfDiscApprove=#NrfDiscApprove#'; }
//	if (SESSION.UserID IS 3025) { WriteOutPut(Action); }
</CFSCRIPT>
 
<!--- JavaScript to redirect user to specified template if the Don't save button is pressed --->
<SCRIPT>
	function redirect() { window.location="MoveInCredits.cfm?ID= #url.id#"; }
	
	function chkAmount(){
//	if ((document.getElementById('mAmount').value == 0) || (document.getElementById('mAmount').value == ''))
//	(
// alert('Amount \(cost\) must be greater than 0.00 ' + document.getElementById('mAmount').value);
// return false;
 //)

 }
  function SelCommFee(){
 var mylist=document.getElementById("CommFeePaymentSel");
var monthSel =mylist.options[mylist.selectedIndex].text;
	alert(monthSel);
	document.getElementById('CommFeePayment') = monthSel.value;
 }


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

  function numbers(e)
  {		//  Robert Schuette project 23853  - 8-5-08
  	  // removes House ability to enter negative values for the Amount textbox,
  	//  only AR will enter in negative values.  Added extra: only numeric values.
   //alert('Javascript is hit for test.')
  	keyEntry = window.event.keyCode;
  		if((keyEntry < '46') || (keyEntry > '57') ||( keyEntry == '47')) {return false;  }
  }
  
 function calcenddate()
{ 
 	var nbrMonths =  document.getElementById('MonthstoPay');
 	var strMonth  =  document.getElementById('ApplyToMonthA');

 	var strYear  =  document.getElementById('ApplyToYearA');	
  //	var y		  =  document.getElementById("ApplyToYearA").options;
  var MonToPay = nbrMonths.options[nbrMonths.selectedIndex].text;	

 //	var MonStart = strMonth.options[strMonth.selectedIndex].text;
 //	alert( nbrMonths.value  + ' :: ' +  strYear.value + ' :: ' + strMonth.value );
 //	var YrStart = strYear.options[strYear.selectedIndex].text;

    newPayMonth =    Number(MonToPay)   +  Number(strMonth.value) -1;

 	if (newPayMonth > 12)
 	 	{
  			newPayMonth = newPayMonth - 12;
  			strYear.value = Number(strYear.value) + 1;
  	}

 	if (newPayMonth < 10)
  		{
  			newPayMonth = String('0') + String(newPayMonth);
  		}
  	else
 	{newPayMonth =  String(newPayMonth);}
 		YrStart = String(strYear.value);
  	newPayDate = 	newPayMonth + YrStart
 //	alert( nbrMonths.value  + ' :: ' +  strYear.value + ' :: ' + strMonth.value  + ' :: ' + MonToPay  + ' :: ' +  newPayMonth  + ' :: ' +  newPayMonth   + ' :: ' +   YrStart.value);
   document.getElementById('defEndDate').value = newPayDate;	
} // end function calcenddate 

function showRtnNote()
{
//alert('WARNING: Returning to the Move-In page you may lose New Resident Fee and  NRF Instalment changes.');
alert('WARNING: Returning to the Move-In page you will reset Community Fee changes.');
}

	function validatesel() { 
 		var thissel = document.getElementById("iCharge_ID").selectedIndex;
		var       y = document.getElementById("iCharge_ID").options.text;
		 
	 	if (thissel == 0)
	 	{
	 	alert('No Charge/Credit selection was made');
	 	return false;
	 	}
	}
	
function rateCheck(){
// alert ('Any changes to the Room Basic Service Fee or the Community Fee \n will require Regional approval before the Move-In can be completed');
// alert (document.getElementById('BSF').value + ', ' + document.getElementById('NewmAmount').value + ', ' +document.getElementById('houseOccupancy').value);
//var occupancy = document.getElementById('houseOccupancy').value;
// 	if (occupancy  >= 85 )
// 	{  
 // 		var allowamt = document.getElementById('BSF').value  * .9 ;
  //	 	allowamt   = parseFloat(Math.round(allowamt  * 100)/100).toFixed(2);
// 		 if (document.getElementById('NewmAmount').value < allowamt){
// 			alert ('The minimum allowable rate for this room is $' +  allowamt  + '.\n Please correct to continue. \n Based on Occupancy of ' + occupancy + '%');
 // 			document.getElementById('NewmAmount').focus(); 	}
// 	}
// 	else if (occupancy  >= 50 && occupancy < 85 )
// 	{ 
// 		var allowamt = document.getElementById('BSF').value  * .8 ;
 // 	 	allowamt   =  parseFloat(Math.round(allowamt  * 100)/100).toFixed(2);;
//		 if (document.getElementById('NewmAmount').value < allowamt){
// 		alert ('The minimum allowable rate for this room is $' +  allowamt  +  '. \n Please correct to continue. \n Based on Occupancy of ' + occupancy + '%');
 // 			document.getElementById('NewmAmount').focus();	}
 //	}
 //	else if (  occupancy  < 50 )
 //	{ 
  //		var allowamt = document.getElementById('BSF').value  * .7 ;
  //	  	allowamt   =  parseFloat(Math.round(allowamt  * 100)/100).toFixed(2);
 //		 if (document.getElementById('NewmAmount').value < allowamt){
  // 			alert ('The minimum allowable rate for this room is $' +  allowamt  +  '. \n Please correct to continue. \n Based on Occupancy of ' + occupancy + '%');
  //			document.getElementById('NewmAmount').focus();	}	
 //	}
 }
 

</SCRIPT>
<script>
	function showHelp(){
 		window.open("TIPS-Move-In-Process.pdf");
	}
</script>
<!--- ==============================================================================
Include Shared JavaScript
=============================================================================== --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">
 
 
<!--- ==============================================================================
Include Retrieval of TenantInformation
=============================================================================== --->
<CFINCLUDE TEMPLATE="../Shared/Queries/TenantInformation.cfm">


<cfif isDefined("form.NewmAmount")>

		<!--- ==============================================================================
		If form.NewmAmount exists, the R&B rate has been changed, so make the update in InvoiceDetails
		Added by Katie on 11/4/03
		
		Set deadlock time to 1 minute 6/1/2005 - Paul Buendia
		=============================================================================== --->
	<cfif tenantype.iresidencytype_id is  not 2>
		<cfquery name="qryInvoiceMaster" datasource="#application.datasource#">
			Select iinvoicemaster_id from invoicedetail
			where iInvoiceDetail_ID = #form.mAmountInvoiceDetailID#
		</cfquery>
		<cfset  mNewmAmount = replace(form.NewmAmount, ',' ,'')>
		<cfset  mNewmAmount = replace(mNewmAmount, '$' ,'')>
		<!---Mamta added for not updating the invoicemaster for MC, instead invoicedetail--->
		<cfif tenantype.cbillingtype eq 'M' >
			<cfquery name="getOriginalAmount" datasource="#application.datasource#">
				SELECT mAmount
				FROM InvoiceDetail
				WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.ID#">
				AND iChargeType_ID = 1748
				AND cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.acctPeriod#">
			</cfquery>
			<cfif getOriginalAmount.mAmount NEQ "" AND getOriginalAmount.mAmount NEQ "0.00">
				<cfif mNewmAmount EQ "" OR mNewmAmount EQ "0.00">
					<script language="javascript">
						alert("The new amount cannot be empty or 0.00");
						window.history.back();
					</script>
				</cfif>
			</cfif> 


				<cfquery name="UpdateInvoiceDetail" datasource="#application.datasource#">
					set LOCK_TIMEOUT 60000		
					update InvoiceDetail 
					set mAmount = #mNewmAmount#
					where dtrowdeleted is null
					<!---and iinvoicemaster_id = #qryInvoiceMaster.iinvoicemaster_id#--->
					and ichargetype_id in (1748,1682,1756)
					and iInvoiceDetail_ID = #form.mAmountInvoiceDetailID#
				</cfquery>	
		<cfelse>
				<cfquery name="UpdateInvoiceDetail" datasource="#application.datasource#">
					set LOCK_TIMEOUT 60000		
					update InvoiceDetail 
					set mAmount = #mNewmAmount#
					where dtrowdeleted is null
					and iinvoicemaster_id = #qryInvoiceMaster.iinvoicemaster_id#
					and ichargetype_id in (7,89)
					<!--- and iInvoiceDetail_ID = #form.mAmountInvoiceDetailID# --->
				</cfquery>
		</cfif>
		<!---end--->
		<cfquery name="UpdateNewAmtDetail" datasource="#application.datasource#">
			set LOCK_TIMEOUT 60000		
			update TenantState 
			set mBSFDisc = #mNewmAmount#
			where itenant_id = #url.ID#
		</cfquery>
	<cfelse>
 	<!---    
		<cfquery name="qryHouseMedicaid" datasource="#APPLICATION.datasource#">
			Select mMedicaidBSF, mStateMedicaidAmt_BSF_Daily from HouseMedicaid where ihouse_id = #tenantype.ihouse_id#
		</cfquery>
		<cfquery name="qryInvoiceMaster" datasource="#application.datasource#">
			Select iinvoicemaster_id from invoicedetail
			where iInvoiceDetail_ID = #form.mAmountInvoiceDetailID#
		</cfquery>
		<cfquery name="qryInvoiceDetailMedicaid" datasource="#application.datasource#">
			Select  inv.iinvoicedetail_id 
			, im.iinvoicemaster_id
			, inv.iQuantity, inv.mamount
			,inv.cappliestoacctperiod
			from invoicedetail inv
			join invoicemaster im on inv.iinvoicemaster_id = im.iinvoicemaster_id
			where im.iinvoicemaster_id = #qryInvoiceMaster.iinvoicemaster_id#
			and  inv.ichargetype_id = 1661
			and im.dtrowdeleted is null
			and inv.dtrowdeleted is null
			and inv.cappliestoacctperiod = #form.acctperiod#
		</cfquery>
		<cfquery name="qryInvoiceStateMedicaid" datasource="#application.datasource#">
			Select  inv.iinvoicedetail_id 
			, im.iinvoicemaster_id
			, inv.iQuantity, inv.mamount
			,inv.cappliestoacctperiod
			from invoicedetail inv
			join invoicemaster im on inv.iinvoicemaster_id = im.iinvoicemaster_id
			where im.iinvoicemaster_id = #qryInvoiceMaster.iinvoicemaster_id#
			and  inv.ichargetype_id = 8
			and im.dtrowdeleted is null
			and inv.dtrowdeleted is null
			and inv.cappliestoacctperiod = #form.acctperiod#
		</cfquery>	
		<cfif qryInvoiceDetailMedicaid.recordcount gt 0>
			<cfset dtcompyr = year(#tenantype.dtmovein#)>
			<cfset dtcompmo = month(#tenantype.dtmovein#)>	
			<cfif len(dtcompmo) is 1>
				<cfset dtcompmo = '0' & #dtcompmo#  >
			</cfif> 
			<cfset DaysInMonth1 = daysinmonth(left(#thisacctperiod1#,4) & '-' & right(#thisacctperiod1#,2)  & '-01' )>
			<cfset DaysInMonth2 = daysinmonth(left(#thisacctperiod2#,4) & '-' & right(#thisacctperiod2#,2)  & '-01' )>
				<cfset ChgDays1 = 1>
				<cfset ChgDays2 = 1>
				<cfif  ( (IsDefined('thisacctperiod1')) 
						and (qryInvoiceDetailMedicaid.cappliestoacctperiod is #thisacctperiod1#) 
							and (qryInvoiceDetailMedicaid.cappliestoacctperiod is #acctperiod#))>
					<cfset ChgDays1 = #monthdays1#>
				<cfelseif ((IsDefined('thisacctperiod2')) 
						and (qryInvoiceDetailMedicaid.cappliestoacctperiod is #thisacctperiod2#) 
							and  (qryInvoiceDetailMedicaid.cappliestoacctperiod is #acctperiod#))>
					<cfset ChgDays2 = #monthdays2#>		
				</cfif>
				<cfif #qryInvoiceDetailMedicaid.cappliestoacctperiod# is #thisacctperiod1# and 
						#qryInvoiceDetailMedicaid.cappliestoacctperiod# is #acctperiod#>
					<cfset prorateAmt =  #form.NewmAmount# * (#ChgDays1#/#DaysInMonth1#) >
					<cfset prorateAmt =  round(#prorateAmt# * 100)/100 >

					<cfquery name="UpdateInvoiceDetail" datasource="#application.datasource#">
						set LOCK_TIMEOUT 60000		
						update InvoiceDetail 
						set mAmount = #prorateAmt#
						where dtrowdeleted is null
						and iinvoicemaster_id = #qryInvoiceMaster.iinvoicemaster_id#
						and ichargetype_id in (1661)
						 and iInvoiceDetail_ID = #form.mAmountInvoiceDetailID# 
					</cfquery>	
					<cfquery name="UpdateNewAmtDetail" datasource="#application.datasource#">
						set LOCK_TIMEOUT 60000		
						update TenantState 
						set mMedicaidCopay = #form.NewmAmount#
						where itenant_id = #url.ID#
					</cfquery>	
					<cfset prorateAmtStMedicaid = (#qryHouseMedicaid.mStateMedicaidAmt_BSF_Daily#*#ChgDays1#) - #prorateAmt# >
					<cfset prorateAmtStMedicaid =  round(#prorateAmtStMedicaid#*100)/100>				
					<cfquery name="UpdateInvoiceDetail" datasource="#application.datasource#">
						set LOCK_TIMEOUT 60000		
						update InvoiceDetail 
						set mAmount =  #prorateAmtStMedicaid# 
						where dtrowdeleted is null
						and iinvoicemaster_id = #qryInvoiceStateMedicaid.iinvoicemaster_id#
						and ichargetype_id in (8)
						 and iInvoiceDetail_ID = #qryInvoiceStateMedicaid.iinvoicedetail_id# 
					</cfquery>		
				<cfelseif #qryInvoiceDetailMedicaid.cappliestoacctperiod# is #thisacctperiod2# and 
						#qryInvoiceDetailMedicaid.cappliestoacctperiod# is #acctperiod#>
						<cfset prorateAmt =  #form.NewmAmount#* #ChgDays2#/#DaysInMonth2# >
						<cfset prorateAmt =   round(#prorateAmt#*100) /100 >
					<cfquery name="UpdateInvoiceDetail" datasource="#application.datasource#">
						set LOCK_TIMEOUT 60000		
						update InvoiceDetail 
						set mAmount = #prorateAmt#
						where dtrowdeleted is null
						and iinvoicemaster_id = #qryInvoiceMaster.iinvoicemaster_id#
						and ichargetype_id in (1661)
						 and iInvoiceDetail_ID = #form.mAmountInvoiceDetailID# 
					</cfquery>	
					<cfset prorateAmtStMedicaid = (#qryHouseMedicaid.mStateMedicaidAmt_BSF_Daily#*(#ChgDays2#/#DaysInMonth2#)) - #prorateAmt# >
					<cfset prorateAmtStMedicaid = round(#prorateAmtStMedicaid#*100) / 100>
					<cfquery name="UpdateInvoiceDetail" datasource="#application.datasource#">
						set LOCK_TIMEOUT 60000		
						update InvoiceDetail 
						set mAmount = #prorateAmtStMedicaid#
						where dtrowdeleted is null
						and iinvoicemaster_id = #qryInvoiceStateMedicaid.iinvoicemaster_id#
						and ichargetype_id in (8)
						 and iInvoiceDetail_ID = #qryInvoiceStateMedicaid.iinvoicedetail_id# 
					</cfquery>		
				<cfelse>
					<cfquery name="UpdateInvoiceDetail" datasource="#application.datasource#">
						set LOCK_TIMEOUT 60000		
						update InvoiceDetail 
						set mAmount = #form.NewmAmount#
						where dtrowdeleted is null
						and iinvoicemaster_id = #qryInvoiceMaster.iinvoicemaster_id#
						and ichargetype_id in (7,89)
						 and iInvoiceDetail_ID = #form.mAmountInvoiceDetailID# 
					</cfquery>
					<cfquery name="UpdateNewAmtDetail" datasource="#application.datasource#">
						set LOCK_TIMEOUT 60000		
						update TenantState 
						set mBSFDisc = #form.NewmAmount#
						where itenant_id = #url.ID#
					</cfquery>
				</cfif>
		</cfif> --->
	</cfif>
</cfif>

<cfif isDefined("form.NewResidentFeeAmt")>

	<!--- ==============================================================================
	If form.NewmAmount exists, the R&B rate has been changed, so make the update in InvoiceDetails
	Added by Katie on 11/4/03
	
	Set deadlock time to 1 minute 6/1/2005 - Paul Buendia
	=============================================================================== --->

	<cfquery name="tenantMonDef" datasource="#APPLICATION.datasource#">
		Select  ts.iMonthsDeferred
		from tenant t join tenantstate ts on t.itenant_id = ts.itenant_id
		where t.itenant_id =  #url.ID#
	</cfquery>
	<cfquery name="qryRecurrChgNewDef" DATASOURCE='#APPLICATION.datasource#'>
				Select irecurringCharge_id from recurringcharge rchg
				join Charges chg on rchg.icharge_id = chg.icharge_id
				where 
				chg.ichargetype_id = 1741 
				and chg.ihouse_id = #Tenantinfo.ihouse_id# 
				and chg.dtrowdeleted is null 
				and chg.cchargeset = '#Tenantinfo.cchargeset#'
				and rchg.itenant_id = #Tenantinfo.iTenant_id# 
				and rchg.dtrowdeleted is null
	</cfquery>	
	<cfset  mNewResidentFeeAmt = replace(form.NewResidentFeeAmt, ',' ,'') >
	<cfset  mNewResidentFeeAmt = replace(mNewResidentFeeAmt, '$' ,'')>
	<cfquery name="UpdateInvoiceDetail" datasource="#application.datasource#">
		set LOCK_TIMEOUT 60000		
		update InvoiceDetail 
		set mAmount = #mNewResidentFeeAmt#
		where dtrowdeleted is null
		and iInvoiceDetail_ID = #form.mAmountInvoiceDetailID#
	</cfquery>
	<cfquery name="UpdateNewNRFAMt" datasource="#application.datasource#" result="UpdateNewNRFAMt">
 		set LOCK_TIMEOUT 60000		
		update TenantState 
		set mAdjNRF = #mNewResidentFeeAmt#
		,mAmtDeferred = 0
		where itenant_id = #url.ID#
	</cfquery>	
	<!---<cfdump var="#UpdateNewNRFAMt#">--->
	<cfif tenantMonDef.iMonthsDeferred gt 1>
		<cfset newDeferred = ((#mNewResidentFeeAmt#/#tenantMonDef.iMonthsDeferred# * 100) / 100)>
	<cfelse>
		<cfset newDeferred = 0>
	</cfif>
	
	<cfif tenantMonDef.iMonthsDeferred gt 1>
		<cfquery name="updNewDeferred"  datasource="#application.datasource#">
		update TenantState 
		set mAmtDeferred = #newDeferred#
		where itenant_id = #url.ID#
		</cfquery>
		<cfquery name="updNewDeferred"  datasource="#application.datasource#">
		update RecurringCharge   
		set mAmount = #newDeferred#
		where irecurringCharge_id = #qryRecurrChgNewDef.irecurringCharge_id# 
		</cfquery>		
	</cfif>
	<cfif tenantMonDef.iMonthsDeferred is 0>
		<cfquery name="updNewDeferred"  datasource="#application.datasource#">
		update TenantState 
		set iMonthsDeferred = 1
		where itenant_id = #url.ID#
		</cfquery>
		
	</cfif>	

</cfif>

<!--- ==============================================================================
Retrieve the service level according to the service points
=============================================================================== --->
<CFQUERY NAME = "GetSLevel" DATASOURCE = "#APPLICATION.datasource#">
	SELECT 	* 
	FROM 	SLevelType
	WHERE	dtRowDeleted IS NULL
	AND		iSPointsMin <= #TenantInfo.iSPoints# AND iSPointsMax >= #TenantInfo.iSPoints#
	<CFIF TenantInfo.cSLevelTypeSet NEQ "" OR TenantInfo.cSLevelTypeSet NEQ 0>
		AND cSLevelTypeSet	= #TenantInfo.cSLevelTypeSet# 
	<CFELSE> AND cSLevelTypeSet	= #SESSION.cSLevelTypeSet# </CFIF>	
</CFQUERY>


<!--- ==============================================================================
Retrieve list of all available credits (discounts) for the Move In
=============================================================================== --->
<CFQUERY NAME = "Additional" DATASOURCE = "#APPLICATION.datasource#">
	select C.cDescription, C.ICHARGE_ID,C.MAMOUNT, CT.BISMODIFIABLEDESCRIPTION, CT.BISMODIFIABLEAMOUNT,
	CT.BISMODIFIABLEQTY, C.IQUANTITY, CT.iChargeType_ID
	from Charges C
	join  ChargeTYPE CT	ON C.iChargeType_ID = CT.iChargeType_ID AND CT.dtrowdeleted is NULL
	left outer join	SLevelType ST ON C.iSLevelType_ID = ST.iSLevelType_ID 
	AND (ST.cSLevelTypeSet = #SESSION.cSLevelTypeSet# OR cSLevelTypeSet IS NULL)	
	where C.dtRowDeleted IS NULL 
	AND CT.bIsMoveIn = 1
	and  c.cchargeset =  '#qryHouseChargeset.ChargeSet#'
	and	(C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# OR C.iHouse_ID IS NULL) 
	and CT.cGLAccount <> 1030

	<!--- AR LEVEL access --->
	<CFIF ListFindNoCase(SESSION.codeblock,23) EQ 0> 
		and CT.bAcctOnly is null 
		<CFIF TenantInfo.iResidencyType_ID EQ 2>
			<!--- medicaid residents --->
			and (bIsRent is null or (bIsRent is not null and bIsMedicaid is not null) 
			or ct.cgrouping = 'PM')
			and (CT.bAcctOnly is null or (bIsRent is not null and bIsMedicaid is not null))
		<CFELSE>
			AND (CT.bIsRent is null or ct.cgrouping = 'PM') and CT.bAcctOnly IS NULL 
		</CFIF>
		<!--- AND	CT.bIsDeposit IS NULL AND CT.bIsRentAdjustment IS NULL --->
		<!--- MLAW 08/17/2006 Users would need to select Security Deposit --->
		<!--- and (CT.bIsDeposit IS NULL or '#session.qselectedhouse.cstatecode#' = 'OR')  --->
		and CT.bIsRentAdjustment IS NULL
	<CFELSE>
		and	(bIsRent IS NULL or (bIsRent is not null AND bIsMedicaid is not null) 
		or bisrentadjustment is not null or bisdiscount is not null or ct.cgrouping = 'PM')
	</CFIF>
 		 
  		and CT.iChargeType_ID <> 1740  
 		and CT.iChargeType_ID <> 1741 	
 
	and	C.dtRowDeleted is null and dtEffectiveStart <= #Now()# and dtEffectiveEnd >= #Now()#
	<CFIF IsDefined("form.iCharge_ID") AND form.iCharge_ID NEQ ""> and iCharge_ID = #form.iCharge_ID# </CFIF>
	ORDER BY C.cDescription	
</CFQUERY>

<!--- ==============================================================================
Retrieve the move in invoice number
if the invoice number was not passed via URL
=============================================================================== --->
<cfif ((Not isDefined("url.mid")) or (trim(url.mid) eq ""))>
	<CFQUERY NAME="MoveInInvoice" DATASOURCE="#APPLICATION.datasource#">
		SELECT	distinct IM.iInvoiceMaster_ID as Master_ID
		FROM	InvoiceDetail INV
		JOIN 	InvoiceMaster IM	ON	INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
		WHERE	iTenant_ID = #url.ID#
		AND	INV.dtRowDeleted IS NULL AND IM.bMoveInInvoice IS NOT NULL 
		AND IM.dtRowDeleted IS NULL AND IM.bFinalized IS NULL
	</CFQUERY>
	<CFSET thisMID = MoveInInvoice.Master_ID>
<cfelse>
	<CFSET thisMID = url.MID>
</CFIF>
		<CFQUERY NAME="CommFeeInvoiceCount" DATASOURCE="#APPLICATION.datasource#">
		SELECT	count( IM.iInvoiceDetail_id) as EntryCount, IM.ichargetype_id
		FROM	InvoiceDetail IM
		WHERE	IM.iInvoiceMaster_ID = #thisMID#
		AND	 IM.dtRowDeleted IS NULL and IM.ichargetype_id in (53, 69) 
		group by IM.ichargetype_id
		</CFQUERY> 

<!--- ==============================================================================
Retrieve all information in for this invoice
*, INV.cDescription as cDescription
=============================================================================== --->
<cfif ((tenantinfo.iresidencytype_id eq 1) or (tenantinfo.iresidencytype_id eq 3))>
	<CFQUERY NAME="GetInvoiceDetail" DATASOURCE="#APPLICATION.datasource#">
		SELECT	INV.*, T.cFirstName, T.cLastName, CT.cGLAccount, ts.dtmovein, ts.dtRentEffective
		from InvoiceMaster IM
		join InvoiceDetail inv on im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID 
		and inv.dtRowDeleted is null
		and IM.dtRowDeleted is null	
		and IM.bMoveInInvoice is not null 
		and IM.bMoveOutInvoice is null
		and IM.cSolomonKey = '#TenantInfo.cSolomonKey#'	
		JOIN	ChargeType CT	ON CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL
		LEFT JOIN	Tenant T	ON T.iTenant_ID = INV.iTenant_ID AND T.dtRowDeleted IS NULL
		join tenantstate ts on t.itenant_id = ts.itenant_id
		<!--- AND			IM.iInvoiceMaster_ID = #MoveInInvoice.iInvoiceMaster_ID# --->
		where INV.iChargeType_ID not in (1741)  
		
		ORDER BY	INV.iTenant_ID DESC, INV.cAppliesToAcctPeriod
	</CFQUERY>
<cfelse>
	<CFQUERY NAME="GetInvoiceDetail" DATASOURCE="#APPLICATION.datasource#">
		SELECT	INV.*, T.cFirstName, T.cLastName, CT.cGLAccount, ts.dtmovein, ts.dtRentEffective
		from InvoiceMaster IM
		join InvoiceDetail inv on im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID 
		and inv.dtRowDeleted is null
		and IM.dtRowDeleted is null	
		and IM.bMoveInInvoice is not null 
		and IM.bMoveOutInvoice is null
		and IM.cSolomonKey = '#TenantInfo.cSolomonKey#'	
		JOIN	ChargeType CT	ON CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL
		LEFT JOIN	Tenant T	ON T.iTenant_ID = INV.iTenant_ID AND T.dtRowDeleted IS NULL
		join tenantstate ts on t.itenant_id = ts.itenant_id
		<!--- AND			IM.iInvoiceMaster_ID = #MoveInInvoice.iInvoiceMaster_ID#
		where INV.iChargeType_ID not in (8) --->		
		ORDER BY	INV.iTenant_ID DESC, INV.cAppliesToAcctPeriod
	</CFQUERY>
</cfif>
 
<CFQUERY NAME = "CollectedApplicationFee" DATASOURCE = "#APPLICATION.datasource#">
	SELECT 	*
	FROM DepositLog DL (nolock)
	JOIN Tenant T (nolock) on T.iTenant_ID = DL.iTenant_ID		
	AND	DL.cSolomonKey = '#TenantInfo.cSolomonKey#'			
	AND DL.iDepositType_ID = 6	
	WHERE DL.dtRowDeleted IS NULL AND T.dtRowDeleted IS NULL
</CFQUERY>
<CFQUERY NAME="GetNRF" DATASOURCE="#APPLICATION.datasource#"> 
	SELECT	INV.mAmount as 'NRFee'
	from InvoiceMaster IM
	join InvoiceDetail inv on im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID 
	and inv.dtRowDeleted is null
	and IM.dtRowDeleted is null	and IM.bMoveInInvoice is not null 
	and IM.bMoveOutInvoice is null
	and IM.cSolomonKey = '#TenantInfo.cSolomonKey#'	
	JOIN	ChargeType CT	ON CT.iChargeType_ID = INV.iChargeType_ID 
	AND CT.dtRowDeleted IS NULL
		AND CT.iChargeType_ID in (53, 69)
	LEFT JOIN	Tenant T	ON T.iTenant_ID = INV.iTenant_ID 
	AND T.dtRowDeleted IS NULL
 	ORDER BY	INV.iTenant_ID DESC, INV.cAppliesToAcctPeriod
</CFQUERY>
<cfquery name="FindOccupancy" datasource="#application.datasource#">
	select t.iTenant_ID, iResidencyType_ID
	, st.cDescription as Level, ts.dtMoveIn
	, ts.dtMoveOut, ts.dtRentEffective
	from AptAddress AD
	join TenantState ts on (TS.iAptAddress_ID = AD.iAptAddress_ID and ts.dtRowDeleted is null)
	join Tenant T	 on (t.iTenant_ID = ts.iTenant_ID and t.dtRowDeleted is null)
	join SLevelType ST on (st.cSLevelTypeSet = t.cSLevelTypeSet 
		and ts.iSPoints between st.iSPointsMin 
		and st.iSPointsMax)		
	where AD.dtRowDeleted is null and ts.iTenantStateCode_ID = 2
		and AD.iAptAddress_ID = #TenantInfo.iAptAddress_ID# 
		and ts.iTenant_ID <> #TenantInfo.iTenant_ID#
</cfquery>

<cfscript>	if (FindOccupancy.RecordCount GT 0){ Occupancy = 2;} else {Occupancy = 1;} </cfscript>
	<cfquery name="DailyRent" datasource="#application.datasource#">

			<cfif Occupancy EQ 1>
				select c.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
				from Charges C
				join ChargeType ct on (CT.iChargeType_ID = c.iChargeType_ID 
					and ct.dtRowDeleted is null)
				where c.dtRowDeleted is null
				and ct.bIsRent is not null
				and ct.bIsDiscount is null and ct.bIsRentAdjustment is null and ct.bIsMedicaid is null
				<cfif TenantInfo.iResidencyType_ID EQ 3>
					and (C.iAptType_ID is null or c.iAptType_ID = #TenantInfo.iAptType_id#)
				<cfelse>
					and ct.bAptType_ID is not null 
					and ct.bIsDaily is not null
					and ct.bSLevelType_ID is null
				</cfif>
					and c.iResidencyType_ID = #TenantInfo.iResidencyType_ID#
					and c.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and c.iAptType_ID = #TenantInfo.iAptType_ID#
	            	and c.iOccupancyPosition = 1 
					and dtEffectiveStart <= #Now()# and dtEffectiveEnd >= #Now()#
				<cfif TenantInfo.cChargeSet neq '' and TenantInfo.iResidencyType_ID neq 3>
					and c.cChargeSet = '#TenantInfo.cChargeSet#'
				<cfelse>
					and c.cChargeSet is null
				</cfif>
				and c.iProductLine_ID = #TenantInfo.iProductLine_ID#
				order by c.dtRowStart Desc
			<cfelse>  
				select c.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
				from Charges C
				join ChargeType ct on (CT.iChargeType_ID = c.iChargeType_ID 
					and ct.dtRowDeleted is null)
				where c.dtRowDeleted is null
				and ct.bIsRent is not null
				and ct.bIsDiscount is null 
				and ct.bIsRentAdjustment is null 
				and ct.bIsMedicaid is null
				<!--- and ct.bAptType_ID is not null   ---> 
				and ct.bIsDaily is not null 
				and ct.bSLevelType_ID is null
				<cfif TenantInfo.iResidencyType_ID EQ 3>
					and (C.iAptType_ID is null or c.iAptType_ID = #TenantInfo.iAptType_id#)
				<cfelse>
					and c.iAptType_ID is null
				</cfif>
				and c.iResidencyType_ID = #TenantInfo.iResidencyType_ID#
				and c.iOccupancyPosition = 2
				and c.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				and dtEffectiveStart <= #Now()# 
				and dtEffectiveEnd >= #Now()#				
				<!--- and dtEffectiveStart <= #MonthList[i]# 
				and dtEffectiveEnd >= #MonthList[i]# --->
				<cfif TenantInfo.cChargeSet neq '' >
				<!--- or TenantInfo.iResidencyType_ID neq 3> --->
					and c.cChargeSet = '#TenantInfo.cChargeSet#'
					<!--- <cfelse>and c.cChargeSet is null --->
				</cfif>
				and c.iProductLine_ID = #TenantInfo.iProductLine_ID#
				order by c.dtRowStart Desc
			</cfif>	
		</cfquery>	
  
 
<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../header.cfm">


<FORM NAME = "MoveInCredits" ACTION = "#Variables.Action#" METHOD = "POST" >
	<INPUT TYPE="Hidden" NAME="cSolomonKey" VALUE="#TenantInfo.cSolomonKey#" />
	<INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#TenantInfo.iTenant_ID#" />
	<!--- <input type="hidden" name="houseOccupancy" id="houseOccupancy" value="#qryHouseInfo.iOccupancy#" /> --->
	<input type="hidden" name="BSF" id="BSF" value="#DailyRent.mamount#" />
	<CFIF IsDefined("form.iCharge_ID") AND (Additional.bIsModifiableDescription GT 0 OR Additional.bIsModifiableAmount GT 0)>
		<INPUT NAME="Message" TYPE="TEXT" VALUE="" SIZE="75" STYLE="Color: Red; Font-Weight: bold; Font-Size: 16; text-align: center;">
	</CFIF>
 

	<TABLE>
		<TR>
			<TH COLSPAN=100%>Move In Credits</TH>
		</TR>
	<tr>
		<td colspan="4">
		Need help with a Move In? Select here: &nbsp;&nbsp;
		<img src="../../images/Move-In-Help.jpg" width="25" height="25" onclick="showHelp();" />
		</td>
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
				<TD>Residency Type:</TD>
				<TD>#tenantype.cdescription#</TD>
			</TR>

		<TR>
			<TD> Physical Move In Date </TD>
			<TD> #DATEFORMAT(TenantInfo.dtMoveIn,"mm/dd/yyyy")#</TD>
			<TD> Service Level </TD>
			<TD> #GetSLevel.cDescription# </TD>
		</TR>
		<cfif TenantInfo.dtMoveOutProjectedDate is not ''>
		<TR>
			<TD> Projected Physical Move Out Date</TD>
			<TD> #DATEFORMAT(TenantInfo.dtMoveOutProjectedDate ,"mm/dd/yyyy")#</TD>
			<TD>&nbsp; </TD>
			<TD>&nbsp; </TD>
		</TR>
		</cfif>


		<tr>
			<td colspan="2">VA Deferral: 
			<cfif #tenantinfo.bIsVADeferred# is 1>
				Yes Approver:#tenantinfo.cVADefApproveUser_id#
			<cfelse>
				No
			</cfif>
			</td>
			<!--- <td colspan="2">Region:: #qryAptType.Region#, #SESSION.qSelectedHouse.iopsarea_ID#</td> --->
			<td colspan="2">&nbsp;</td>
		</tr>		
	</TABLE>

	<TABLE>	
		<TR STYLE="text-align: center;">	
			<TD STYLE="font-weight: bold;">	Additional Charges/Credits:	</TD>
			<CFIF IsDefined("form.iCharge_ID") and form.iCharge_ID is not "">
			<!--- display charge detail entry information --->
			
				<cfif not isDefined("form.UpdateAmount")>
				<!--- only display charge detail entry information if there wasn't just an update to the R&B amount --->
					<INPUT TYPE="Hidden" NAME="iCharge_ID" VALUE="#form.iCharge_ID#">
					<TD>
						<CFIF Additional.bIsModifiableDescription GT 0>
							Description <BR> 
							<INPUT TYPE="text" NAME="cDescription" VALUE="#Additional.cDescription#"
							 SIZE=#LEN(Additional.cDescription)# MAXLENGTH=15 
							 	onKeyUP="this.value=Letters(this.value);  Upper(this);">
						<CFELSE>
							#Additional.cDescription#
							 <INPUT TYPE="Hidden" NAME="cDescription" 
							 	VALUE="#Additional.cDescription#" MAXLENGTH="15">
						</CFIF>
					</TD>
					<TD>
						<!---Robert Schuette, project 23853   08-5-2008
						begin: If user is NOT AR then javascript for keyboard restriction
						 on input (only numbers).  '192' is usergroup 'AR'--->
						<cfif ListContains(session.groupid,'192')>	
							<!--- MLAW 03/08/2006 Add condition for R&B rate and R&B discount, BisModifiableAmount is the field that determine if the charge is editable --->
							<CFIF Additional.bIsModifiableAmount GT 0 
								OR listfindNocase(session.codeblock,25) GTE 1 
								OR listfindNocase(session.codeblock,23) GTE 1>
								Amount <BR> <INPUT TYPE = "text" NAME="mAmount" id="mAmount" 
									SIZE="10" STYLE="text-align:right;"
								 	VALUE="#TRIM(LSNumberFormat(Additional.mAmount, "99999.99"))#" 
								  	onKeyUp="this.value=CreditNumbers(this.value);" 
									onBlur="this.value=cent(round(this.value));">
							<CFELSE>
								#LSCurrencyFormat(Additional.mAmount)#
								<INPUT TYPE="Hidden" NAME="mAmount"  id="mAmount"
								VALUE="#TRIM(LSNumberFormat(Additional.mAmount, "99999.99"))#">
							</CFIF>
						<cfelseif ListContains(session.codeblock,'21')>	
							<!--- MLAW 03/08/2006 Add condition for R&B rate and R&B discount, BisModifiableAmount is the field that determine if the charge is editable --->
							<CFIF Additional.bIsModifiableAmount GT 0  >
								Amount <BR> 
								<INPUT TYPE = "text" NAME="mAmount"  id="mAmount" SIZE="10" 
									STYLE="text-align:right;"
								 	VALUE="#TRIM(LSNumberFormat(Additional.mAmount, "99999.99"))#" 
								  	onKeyUp="this.value=CreditNumbers(this.value);" 
									onBlur="this.value=cent(round(this.value));">
							<CFELSE>
								#LSCurrencyFormat(Additional.mAmount)#
								<INPUT TYPE="Hidden" NAME="mAmount"  id="mAmount" 
								VALUE="#TRIM(LSNumberFormat(Additional.mAmount, "99999.99"))#">
							</CFIF>
						<cfelse>
							<!--- MLAW 03/08/2006 Add condition for R&B rate and R&B discount, BisModifiableAmount is the field that determine if the charge is editable --->
							<CFIF Additional.bIsModifiableAmount GT 0 
								OR listfindNocase(session.codeblock,25) GTE 1 
								OR listfindNocase(session.codeblock,23) GTE 1>
								Amount <BR> <INPUT TYPE = "text" NAME="mAmount"  
								id="mAmount" SIZE="10" STYLE="text-align:right;" 
								VALUE="#TRIM(LSNumberFormat(Additional.mAmount, "99999.99"))#"  
								onKeyUp="this.value=CreditNumbers(this.value);" 
								onBlur="this.value=cent(round(this.value));" 
								onkeypress="return numbers(event)">
							<CFELSE>
								#LSCurrencyFormat(Additional.mAmount)#
								<INPUT TYPE="Hidden" NAME="mAmount"  id="mAmount" 
								VALUE="#TRIM(LSNumberFormat(Additional.mAmount, "99999.99"))#" 
								onkeypress="return numbers(event)">
							</CFIF>	
						</cfif>	<!--- end changes of project 23853--->
					</TD>
					<TD>
						<CFIF Additional.bIsModifiableQty GT 0>
							Quantity <BR> <INPUT TYPE="text" NAME="iQuantity" 
							STYLE="text-align:center;"
							 VALUE="#Additional.iQuantity#" SIZE=2 MAXLENGHT=2 
							 onKeyUP="this.value=Numbers(this.value);">
						<CFELSE>
							Quantity (#Additional.iQuantity#)
						</CFIF>	
					</TD>
					<TD>&nbsp;</TD>
				</TR>
				<TR>
					<TD>&nbsp;</TD>
					<TD COLSPAN=100% STYLE="text-align: center;">
					Charge To Period:
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
					<TD bordercolor="linen" style="text-align: left;">
						<INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save" VALUE="Save" 
						onmouseover="chkAmount()">
					</TD>
					<TD>&nbsp;</TD>
					<TD><INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" 
					VALUE="Don't Save" onClick="redirect()"></TD>
					<TD>&nbsp;</TD>
				</TR>
				</cfif>
			<CFELSE><!--- display charge dropdown --->	
			
				<TD COLSPAN="3">
					<SELECT NAME="iCharge_ID">
						<OPTION VALUE=""> None </OPTION>
						<CFLOOP QUERY="Additional"> 
						<OPTION VALUE="#Additional.iCharge_ID#">	#Additional.cDescription# </OPTION>
						 </CFLOOP>
					</SELECT>
					<!--- defined & initialized objects for javascript functions --->
					<INPUT TYPE="hidden" NAME="cDescription" VALUE="none">
					<INPUT TYPE="hidden" NAME="mAmount" VALUE="0.00">
				</TD>
				<TD><INPUT CLASS="DontSaveButton" TYPE="Submit" NAME="Add" VALUE="Add" 
					onclick="return validatesel();">
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
				EXISTING CHARGES/CREDITS:	
			</TD>
			<TD COLSPAN="4" STYLE="font-weight: bold; color: red; text-align: right;">
				Charges shared with other residents appear in red.	
			</TD>
		</TR>
	</TABLE>
	<TABLE>
	</TABLE>
    
	</form>
	<TABLE>	
	<FORM NAME = "MoveInCredits" ACTION = "#Variables.Action#" METHOD = "POST">
		<TR STYLE="font-weight: bold; text-align: center;">
			<TD  style="background:##CCFFCC; " >Description	</TD>
			<TD  style="background:##CCFFCC; " >Effective Date	</TD>
			<cfif tenantype.cbillingtype eq 'M'>
			<TD  style="background:##CCFFCC; " >Monthly Rate</TD>	
			</cfif>	
			<TD style="background:##CCFFCC; "  >Amount</TD>
			<TD style="background:##CCFFCC; " >Qty</TD>
			<TD style="background:##CCFFCC; " >Applies To:</TD>
			<TD style="background:##CCFFCC; " >Corrections?</TD>
		</TR>
		
		<CFSET INVOICETotal = 0>
		<cfset CNT =0>
		
		<CFLOOP QUERY="GetInvoiceDetail">
			<cfif tenantinfo.iresidencytype_id is 2>
				<cfquery name="qryHouseMedicaid" datasource="#APPLICATION.datasource#">
				Select mMedicaidBSF, mStateMedicaidAmt_BSF_Daily from HouseMedicaid where ihouse_id = #tenantype.ihouse_id#
				</cfquery>
			
				<!--- the BSF Medicaid record is loaded with the base amount,
				 check if it should be adjusted for nbr of days in billing month --->
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

				<cfif thisacctperiod1 is #GetInvoiceDetail.cAppliesToAcctPeriod#>
					<cfset ChgDays = #nbrDays1#>
					<cfset daysinmonth = daysinmonth1>
				
				<cfelseif thisacctperiod2 is #GetInvoiceDetail.cAppliesToAcctPeriod#>
					<cfset ChgDays = #nbrdays2#>
					<cfset daysinmonth = daysinmonth2>
					
				</cfif>
			
				
				<cfif  (ichargetype_id is 31 ) and (GetInvoiceDetail.mamount neq 0)> <!---Mshah added here--->

					<cfset adjMedicaidBSF = #qryHouseMedicaid.mMedicaidBSF# * #ChgDays#/#daysinmonth#>
					<cfquery name="updAdjBSF" datasource="#APPLICATION.datasource#">
					update invoicedetail
						set mamount = #adjMedicaidBSF#
						where  iinvoicedetail_id = #qryProrate.iinvoicedetail_id#
					</cfquery>
			
				</cfif>
			</cfif>
			<CFQUERY NAME="DepositLogCheck" DATASOURCE="#APPLICATION.datasource#">
				select *
				from DepositLog DL (nolock)
				join DepositType DT (nolock) on DT.iDepositType_ID = DL.iDepositType_ID
				and DL.dtRowDeleted is null and DT.dtRowDeleted is null
				and iTenant_ID = #GetInvoiceDetail.iTenant_ID#
				and cDescription = '#GetInvoiceDetail.cDescription#'
				and DT.mAmount = #GetInvoiceDetail.mAmount#
			</CFQUERY>
			
			<cfif ((tenantinfo.iresidencytype_id eq 1) or (tenantinfo.iresidencytype_id eq 3))> 
				<CFSCRIPT>
					if (GetInvoiceDetail.iTenant_ID EQ TenantInfo.iTenant_ID ) 
						{ Color='STYLE = "color: navy;"'; 
					INVOICETOTAL=InvoiceTotal+(GetInvoiceDetail.mAmount * GetInvoiceDetail.iQuantity); }
					else { Color = 'STYLE = "color: red;"'; INVOICETOTAL=InvoiceTotal+0; }
				</CFSCRIPT>
			<cfelse>
				<CFSCRIPT>
					if (GetInvoiceDetail.iTenant_ID EQ TenantInfo.iTenant_ID  and 
					GetInvoiceDetail.iChargetype_id NEQ 8) 
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
							#dateformat(GetInvoiceDetail.dtMovein, 'mm/dd/yyyy')# 
						<cfelse>
							#dateformat(GetInvoiceDetail.dtRentEffective, 'mm/dd/yyyy')#
						</cfif> 
					</TD>
					<script>
						function monthlyrateCheck()
						{ 
							//alert('test');
							 var monthlyamount = document.getElementById("currentMonth").value;
							// alert(monthlyamount);
							 //alert(document.getElementById("TXT1").value);
							 var totaldays= document.getElementById("DaysInMonth1").value;
							// alert(totaldays);
							 var rate= (parseFloat(monthlyamount.replace(/,/g, '')) /totaldays);
							 // alert(rate);
							 var daystocharge= document.getElementById("daytocharge").value;
							// alert(daystocharge);
							 var proratedrate = rate*daystocharge
							 //alert(proratedrate);
							 document.getElementById("NewmAmount1").value= Math.round(proratedrate * 100) / 100;
							 //document.getElementById("nextMonth").value= monthlyamount;
							 //document.getElementById("NewmAmount2").value= monthlyamount;
							}
					</script>
					<script>
						function monthlyrateCheckRespite()
						{ 
							//alert('test');
							 var monthlyamount = document.getElementById("currentMonth").value;
							// alert(monthlyamount);
							 //alert(document.getElementById("TXT1").value);
							 var totaldays= 30;
							// alert(totaldays);
							 var rate= (parseFloat(monthlyamount.replace(/,/g, '')) /totaldays);
							//  alert(rate);
							 var daystocharge= document.getElementById("daytocharge").value;
							// alert(daystocharge);
							 var proratedrate = rate*daystocharge
							 //alert(proratedrate);
							 document.getElementById("NewmAmount1").value= Math.round(proratedrate * 100) / 100;
							 //document.getElementById("nextMonth").value= monthlyamount;
							 //document.getElementById("NewmAmount2").value= monthlyamount;
							}
					</script>
		         	<script>
						function monthlyrateCheck1()
						{ 
							//alert('test');					
							 var monthlyamount = document.getElementById("nextMonth").value;
							 //alert(monthlyamount);
							 document.getElementById("NewmAmount2").value= monthlyamount;
							
							}
		         	</script>
		         	
		         	<script>
						function monthlyrateCheck1Respite()
						{ 
							//alert('test');
							 var monthlyamount = document.getElementById("currentMonth").value;
							 alert(parseFloat(monthlyamount.replace(/,/g, '')));
							 //alert(document.getElementById("TXT1").value);
							 var totaldays= 30;
							 //alert(totaldays);
							 var rate= (parseFloat(monthlyamount.replace(/,/g, '')) /totaldays);
							 //alert(rate);
							 var daystocharge= document.getElementById("daytocharge1").value;
							 //alert(daystocharge);
							 var proratedrate = rate*daystocharge
							 //alert(proratedrate);
							 document.getElementById("NewmAmount2").value= Math.round(proratedrate * 100) / 100;
							 //document.getElementById("nextMonth").value= monthlyamount;
							 //document.getElementById("NewmAmount2").value= monthlyamount;
							}
					</script>
					
					<cfif tenantype.cbillingtype eq 'M'  >	
					<TD>
						
						<cfif #GetInvoiceDetail.ichargetype_ID# eq 1748 
							or #GetInvoiceDetail.ichargetype_ID# eq 1682 
							or #GetInvoiceDetail.ichargetype_ID# eq 1756 >
						       <!---$<input type="text" name="monthlyrate" id="monthlyrate" value="#qryAptType.mAmount#" size="7" /> --->
						        <!---   test goin here thisacctperiod1 #thisacctperiod1# TXT#GetInvoiceDetail.currentrow# --->
							  <cfif thisacctperiod1 is #GetInvoiceDetail.cAppliesToAcctPeriod#>
							  	
									<cfset StrMonth1 =  #left(thisacctperiod1,4)# & '-' & #right(thisacctperiod1,2)#  & '-01'  >
									<cfset DaysInMonth1 = #daysinmonth(StrMonth1)#>
								<!---<cfset rate= DecimalFormat(#qryAptType.mAmount#/DaysInMonth1)>--->
									<cfset daytocharge= #DaysInMonth(tenantype.dtrenteffective)#-#day(tenantype.dtrenteffective)#+1>
									<cfset changedmonthlyrate= round((#getInvoiceDetail.mamount#/#daytocharge#)*#DaysInMonth1#)>
									<!---added by Mshah for MC respite --->
										<cfif tenantype.iresidencytype_id eq 3>
										<cfset changedmonthlyrate= round((#getInvoiceDetail.mamount#/#daytocharge#)*30)>
										</cfif>
							 <!---#changedmonthlyrate# #qryAptType.mAmount# (#getInvoiceDetail.mamount#/#daytocharge#)*#DaysInMonth1#) --->
							    	
							      $<input type="text" name="currentMonth" id= "currentMonth" 
							    		value= 
							    	<cfif #changedmonthlyrate# NEQ #qryAptType.mAmount#>
								    	 "#changedmonthlyrate#" 
								    <cfelse>	
							    			"#numberformat(qryAptType.mAmount)#" 
							    	</cfif>	
							    	size="7"  onblur= <cfif tenantype.iresidencytype_id eq 3> "monthlyrateCheckRespite();" 
													<cfelse> "monthlyrateCheck();"
													 </cfif> />
								<input type="hidden" name="DaysInMonth1" id="DaysInMonth1" value="#DaysInMonth1#"/>
								<!---<input type="hidden" name="rate" id="rate" value="#rate#"/>--->
								<input type="hidden" name="daytocharge" id="daytocharge" value="#daytocharge#"/>
								
								
					     <cfelseif thisacctperiod2 is #GetInvoiceDetail.cAppliesToAcctPeriod#>
					     		
					           <cfset StrMonth2 =  #left(thisacctperiod2,4)# & '-' & #right(thisacctperiod2,2)#  & '-01'  >
						        <cfset daysinmonth2 = #daysinmonth(StrMonth2)#>
						       
								<cfset daytocharge= #daysinmonth(StrMonth2)#>
								
							<!--- #getInvoiceDetail.idaysbilled# --->
							     $<input type="text" name="nextMonth" id="nextMonth" 
							     value=
							     <!---<cfif tenantype.iresidencytype_id eq 3><!--- Mshah added for MC respite--->
									    "#numberformat(qryAptType.mAmount)#"
								  <cfelseif #getInvoiceDetail.mamount# NEQ #qryAptType.mAmount#>--->	
								  <cfif #getInvoiceDetail.mamount# NEQ #qryAptType.mAmount#>
							         "#changedmonthlyrate#" 
							     <cfelse>
							     	"#numberformat(qryAptType.mAmount)#" 
							     </cfif>		
							     size="7" onblur= <cfif tenantype.iresidencytype_id eq 3> "monthlyrateCheck1Respite();" <cfelse> "monthlyrateCheck1();" </cfif>/>
							      <input type="hidden" name="DaysInMonth1" id="DaysInMonth1" value="#DaysInMonth2#"/>
								<!---<input type="hidden" name="rate" id="rate" value="#rate#"/>--->
								<input type="hidden" name="daytocharge1" id="daytocharge1" value= <cfif tenantype.iresidencytype_id eq 3> "#getInvoiceDetail.idaysbilled#" <cfelse>"#daytocharge#" </cfif>/>
								
						  </cfif>
					   </cfif>
					</TD>	
						</cfif>		
					<TD STYLE="text-align: right;"> 
					<!--- If charge type is 89 (Private R&B) or 7 (Respite R&B) then make the amount editable --->
					<cfif ( GetInvoiceDetail.iChargeType_ID is 89 
						or GetInvoiceDetail.iChargeType_ID is 7  
						or GetInvoiceDetail.iChargeType_ID is 1748
						or GetInvoiceDetail.iChargeType_ID is 1682
						or GetInvoiceDetail.iChargeType_ID is 1756)>
						<form method="post"  action="moveincredits.cfm?ID=#url.ID#&MID=#thisMID#&NrfDiscApprove=#NrfDiscApprove#">
							<input type="hidden" name="acctperiod" value="#cappliestoacctperiod#" />
							<input type="hidden" name="thisacctperiod1" value="#thisacctperiod1#" />
							<input type="hidden" name="thisacctperiod2" value="#thisacctperiod2#" /> 
							<input type="hidden" name="monthdays2" value="#nbrdays2#">
							<input type="hidden" name="monthdays1" value="#nbrdays1#">	
							<input type="hidden" name="mAmountInvoiceDetailID" value="#getInvoiceDetail.iInvoiceDetail_ID#">
							<input type="hidden" name="iChargeType_ID" value="#GetInvoiceDetail.iChargeType_ID#">
								<CFSCRIPT>
								CNT=CNT+1;
								</CFSCRIPT>	
							$<input type="text" name="NewmAmount" id="NewmAmount#CNT#" 
								value="#DecimalFormat(GetInvoiceDetail.mAmount)#" size="7" onblur="rateCheck();" ><BR>
								<font color="red"><b>*</b></font>
							<input type="submit" value="Update Amount" name="UpdateAmount">
						</form>
					<cfelseif GetInvoiceDetail.iChargeType_ID is 1661 >	#dollarFormat(GetInvoiceDetail.mAmount)# <!--- Medicaid Copay --->
					
<!--- 				<form method="post"  
				action="moveincredits.cfm?ID=#url.ID#&MID=#thisMID#&NrfDiscApprove=#NrfDiscApprove#">
						<input type="hidden" name="acctperiod" value="#cappliestoacctperiod#" />
						<input type="hidden" name="thisacctperiod1" value="#thisacctperiod1#" />
						<input type="hidden" name="thisacctperiod2" value="#thisacctperiod2#" /> 
						<input type="hidden" name="monthdays2" value="#nbrdays2#">
						<input type="hidden" name="monthdays1" value="#nbrdays1#">						
						<input type="hidden" name="mAmountInvoiceDetailID" value="#getInvoiceDetail.iInvoiceDetail_ID#">
						<input type="hidden" name="iChargeType_ID" value="#GetInvoiceDetail.iChargeType_ID#">
						$<input type="text" name="NewmAmount" id="NewmAmount" 
						value="#DecimalFormat(GetInvoiceDetail.mAmount)#" 
						size="7" onblur="rateCheck();"><BR>

								<font color="red"><b>*</b></font>
						<input type="submit" value="Update Amount" name="UpdateAmount">
						
					</form> --->			
	<!--- 					<cfelse>
								 $ #DecimalFormat(GetInvoiceDetail.mAmount)# 
							 
						</cfif> --->
	<!--- If charge type is 69 (Community Fee (New Resident Fee)) then make the amount editable --->
					<cfelseif ( (GetInvoiceDetail.iChargeType_ID is 83)
						or ( GetInvoiceDetail.iChargeType_ID is 57 )
						or ( GetInvoiceDetail.iChargeType_ID is 69 )
						or ( GetInvoiceDetail.iChargeType_ID is 53 ))>
	<!--- 				<cfif SESSION.qSelectedHouse.iopsarea_ID is 44>	 --->		
				<form method="post" 
				action="moveincredits.cfm?ID=#url.ID#&MID=#thisMID#&NrfDiscApprove=#NrfDiscApprove#">
					<!---Mamta added this to form to display the monthky rate text box--->
					<input type="hidden" name="acctperiod" value="#cappliestoacctperiod#" />
					<input type="hidden" name="thisacctperiod1" value="#thisacctperiod1#" />
					<input type="hidden" name="thisacctperiod2" value="#thisacctperiod2#" /> 
					<cfif ((GetInvoiceDetail.mAmount is 0.00) or (GetInvoiceDetail.mAmount is ''))>
					$<input type="text" name="NewResidentFeeAmt" id="NewResidentFeeAmt" 
						value="#DecimalFormat(qrySecDep.mamount)#" size="7" 
						onblur="rateCheck();"><BR>
					<cfelse>
					$<input type="text" name="NewResidentFeeAmt" id="NewResidentFeeAmt" 
						value="#DecimalFormat(GetInvoiceDetail.mAmount)#" size="7" 
						onblur="rateCheck();"><BR>					
					</cfif>
					<input type="hidden" name="mAmountInvoiceDetailID" 
						value="#getInvoiceDetail.iInvoiceDetail_ID#">
						<font color="red"><b>*</b></font>
					<input type="submit" value="Update Amount" name="UpdateAmount">
				</form>
								<!--- 	<cfelse>
														<form method="post" action="moveincredits.cfm?ID=#url.ID#&MID=#url.MID#&NrfDiscApprove=#NrfDiscApprove#">
														$<input type="text" name="NewResidentFeeAmt" id="NewResidentFeeAmt" 
														value="#DecimalFormat(GetInvoiceDetail.mAmount)#" size="7" onblur="rateCheck();"><BR>
														<input type="hidden" name="mAmountInvoiceDetailID" value="#getInvoiceDetail.iInvoiceDetail_ID#">
														<font color="red"><b>*</b></font><input type="submit" value="Update Amount" name="UpdateAmount">
														</form>
												</cfif> --->
				<cfelseif tenantinfo.iresidencytype_id is 2 and getinvoicedetail.ichargetype_id is 31 and (GetInvoiceDetail.mamount neq 0)> <!---Mshah added here--->
						#LSCurrencyFormat(adjMedicaidBSF)#
				<cfelse>
						#LSCurrencyFormat(GetInvoiceDetail.mAmount)#
				</cfif>
				</TD>
					<TD STYLE="text-align: center;"> #GetInvoiceDetail.iQuantity# </TD>
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
						
							<CFIF (  ((GetInvoiceDetail.irowstartuser_id neq 0) 
									OR (DepositLogCheck.RecordCount EQ 0 
									AND GetInvoiceDetail.iChargeType_ID NEQ 1 
									AND GetInvoiceDetail.iChargeType_ID NEQ 30 
									AND GetInvoiceDetail.cGLAccount NEQ 2210) ) 
									and  ((GetInvoiceDetail.iChargeType_ID NEQ 89) 
									and (GetInvoiceDetail.iChargeType_ID NEQ 7) 
									and (GetInvoiceDetail.iChargeType_ID NEQ 91)
									and (GetInvoiceDetail.iChargeType_ID NEQ 1748)
									and (GetInvoiceDetail.iChargeType_ID NEQ 1682)))  >
						 
							<INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" 
							VALUE="Delete Now" 
							onClick="self.location.href='DeleteMoveInCredit.cfm?ID=#GetInvoiceDetail.iInvoiceDetail_ID#&MID=#url.MID#&acctperiod=#cappliestoacctperiod#&thisacctperiod1=#thisacctperiod1#&thisacctperiod2=#thisacctperiod2#&monthdays1=#nbrdays1#&monthdays2=#nbrdays2#'">	
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
							<CFIF <!--- ((listfindNoCase(SESSION.CodeBlock, 24) GT 1) or (SESSION.qSelectedHouse.iopsarea_ID is 44)) 
							 and   --->((GetInvoiceDetail.iChargeType_ID NEQ 89) 
									and (GetInvoiceDetail.iChargeType_ID NEQ 7) 
									and (GetInvoiceDetail.iChargeType_ID NEQ 91)
									and (GetInvoiceDetail.iChargeType_ID NEQ 69)
									and (GetInvoiceDetail.iChargeType_ID NEQ 53)
									and (GetInvoiceDetail.iChargeType_ID NEQ 1748)
									and (GetInvoiceDetail.iChargeType_ID NEQ 1682)) >
							<INPUT CLASS="BlendedButton" TYPE="button" NAME="Delete" 
							VALUE="Delete Charge" 
							onClick="self.location.href='DeleteMoveInCredit.cfm?ID=#GetInvoiceDetail.iInvoiceDetail_ID#&MID=#url.MID#&acctperiod=#cappliestoacctperiod#&thisacctperiod1=#thisacctperiod1#&thisacctperiod2=#thisacctperiod2#&monthdays1=#nbrdays1#&monthdays2=#nbrdays2#'">
							</CFIF>
						</CFIF>
						</TD>
				</TR>
			<!--- 	<CFIF GetInvoiceDetail.cComments NEQ ''><TR><TD COLSPAN=100%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* #GetInvoiceDetail.cComments#</TD></TR></CFIF> 75019 --->
			</CFIF> 
		</CFLOOP>
		
	<!--- 	<cfif ((CommFeeInvoiceCount.EntryCount gt 0) and (TenantInfo.cSecDepCommFee is 'CF'))> --->
		<cfif  ((CommFeeInvoiceCount.EntryCount gt 0) 
				and (CommFeeInvoiceCount.ichargetype_id is 69))  >
				<form name="UpdCommFeePymnt" method="post" action="UpdCommFeePymnt.cfm" >
				<tr>
					<td colspan="4">Select Community Fee Payments:
						
					<input type="hidden" name="thisacctperiod1" value="#thisacctperiod1#" />
					<input type="hidden" name="thisacctperiod2" value="#thisacctperiod2#" />
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
		<CFQUERY NAME="GetNewInvoiceDetail" DATASOURCE="#APPLICATION.datasource#">
			SELECT	sum(inv.mamount * inv.iquantity) as MedInvTotal
			from InvoiceMaster IM
			join InvoiceDetail inv on im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID 
			and inv.dtRowDeleted is null
			and IM.dtRowDeleted is null	
			and im.bfinalized is null
			and IM.bMoveInInvoice is not null 
			and IM.bMoveOutInvoice is null
			and IM.cSolomonKey = '#TenantInfo.cSolomonKey#'	
			LEFT JOIN	Tenant T	ON T.iTenant_ID = INV.iTenant_ID AND T.dtRowDeleted IS NULL
			join tenantstate ts on t.itenant_id = ts.itenant_id
			where inv.ichargetype_id not in (8,1749,1750)
		</CFQUERY>
		</cfif>			
		<cfif tenantype.iresidencytype_id is not 2>
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
<!--- 		*Update Medicaid CoPay per state guidelines
		<br /> --->
		"State Medicaid" entry is shown for reference only, it is not included in Invoice Total
	</cfif>
</div>
</CFOUTPUT>
<!--- Include Intranet footer --->
<CFINCLUDE TEMPLATE="../../footer.cfm">