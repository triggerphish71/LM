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
----------------------------------------------------------------------------------------------->

<!--- Check to see if the chosen tenant has a move in date. --->
<cfquery name="RegCheck" datasource="#APPLICATION.datasource#">
	select * from tenantstate where dtrowdeleted is null and iTenant_ID = #url.ID# and dtMoveIn is not null
</cfquery>

<cfscript>
//Check to see if url.insert is given signifying that we are adding a region.
Action = iif(RegCheck.RecordCount LTE 0,DE('MoveInFormInsert.cfm'),DE('MoveInFormUpdate.cfm'));
//if (isDefined("session.UserID") and session.UserID IS 3025){ writeoutput(Variables.Action); }

</cfscript>

<script language="JavaScript" src="../../global/calendar/ts_picker_Validate.js" type="text/javascript"></script>
<!--- Project 20125 modification. 06/03/08 SSathya for the Military options to be displayed.--->
<script type="text/javascript">
var vWinCal;
function doClick(objRad){
if (objRad.value=="1"){ 
	document.getElementById("otherOpt").style.display='block'; //show other options
	document.getElementById("otherOpt2").style.display='block'; //show other options
	document.getElementById("otherOpt1").style.display='block'; //show other options
	document.getElementById("otherOpt3").style.display='block'; //show other options
	}
else{ 
	document.getElementById("otherOpt").style.display='none'; //hide other options
	document.getElementById("otherOpt2").style.display='none'; //hide other options
	document.getElementById("otherOpt1").style.display='none'; //hide other options
	document.getElementById("otherOpt3").style.display='none'; //hide other options
	}
}


function validatePMO(){
	var PMODate = document.getElementById("dtmoveoutprojecteddate").value;
	PMODate = new Date(PMODate);
	var AllowDate = document.getElementById("MoveInMonth").value + '/'+ document.getElementById("MoveInDay").value + '/' + document.getElementById("MoveInYear").value;
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
		//if ((typeof vWinCal.closed != "undefined") && (typeof vWinCal != "undefined")){
		//	vWinCal.focus();
		//}
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


</script>

<!---  Retrieve Tenant Information from just tenant table for use when there is no prior contact information --->
<cfquery name="Tenant" datasource= "#APPLICATION.datasource#">
	select * from Tenant T
	join TenantState TS on (T.iTenant_ID = TS.iTenant_ID and TS.dtRowDeleted is null)
	where T.dtRowDeleted is null and T.iTenant_ID = #Url.ID#	
</cfquery>

<!--- Retrieve all valid diagnosis types --->
<cfquery name="qDiagnosisType" datasource="#Application.datasource#">
	select idiagnosistype_id, cdescription from diagnosistype where dtrowdeleted is null	
</cfquery>

<!--- Project 20125 06/03/08 SSathya Added this to Retrive all the valid promotion detials applicable --->
<cfquery name="qTenantPromotion" datasource="#Application.datasource#">
	Select * from TenantPromotionSet where dtrowdeleted is null 
</cfquery>


<!--- catch if resident is already moved in --->
<cfif Tenant.iTenantStateCode_ID eq 2> 
	<center><strong style='font-size: large; color: red;'>This tenant is already moved in.<br />You will be redirected in 10 seconds.</strong></center>
	<script> function redirect() { location.href='../MainMenu.cfm'; } setTimeout('redirect()',10000); </script>
	<CFABORT>
</cfif>

<!--- query for prior move in invoice --->
<cfquery name='qPriorMI' datasource="#APPLICATION.datasource#">
	select distinct im.iinvoicemaster_id
	from invoicemaster im
	left join invoicedetail inv on inv.iinvoicemaster_id = im.iinvoicemaster_id and inv.dtrowdeleted is null and inv.itenant_id = #tenant.itenant_id#
	where im.bmoveininvoice is not null and im.bfinalized is null and im.csolomonkey = '#Tenant.csolomonkey#'
</cfquery>

<cfscript>
// set vars
if (qPriorMI.recordcount GT 0) { Action='MoveInFormUpdate.cfm';}
if (Len(Tenant.cBillingType) GT 0) { switch (Tenant.cBillingType){ case "d": writeoutput('daily'); break; } }
</cfscript>

<!--- Retrieve the Minimum Points Required for this set and points  --->	
<cfquery name="MinPoints" datasource="#APPLICATION.datasource#">
	select min(IsPointsMin) as minimum, max(IsPointsMax) maximum
	from SLevelType
	where cSLevelTypeSet = #iif(Tenant.cSLevelTypeSet neq "",Tenant.cSLevelTypeSet,session.cSLevelTypeSet)#
	and	dtRowDeleted is null
</cfquery>		

<!--- Retrieve the lowest non-zero points --->
<cfquery name="NonZeroPoints" datasource="#APPLICATION.datasource#">
	select min(IsPointsMin) as minimum, max(IsPointsMax) maximum
	from SLevelType where dtRowDeleted is null and IsPointsMin <> 0
	and cSLevelTypeSet = #iif(Tenant.cSLevelTypeSet neq "",Tenant.cSLevelTypeSet,session.cSLevelTypeSet)#
</cfquery>

<!--- Include Intranet Header --->
<cfinclude template="../../header.cfm">

<!--- Retreive list of State Codes, Phone types, RelationShip Types, Residency Types --->
<cfinclude template="../Shared/Queries/StateCodes.cfm">
<cfinclude template="../Shared/Queries/PhoneType.cfm">
<cfinclude template="../Shared/Queries/Relation.cfm">
<cfinclude template="../Shared/Queries/TenantInformation.cfm">
<cfinclude template="../Shared/Queries/AvailableApartments.cfm">
<!--- retrieve assess tool permissions --->
<cfinclude template="../../AssessmentTool/toolaccess.cfm">


<!--- retrieve house product line info --->
<cfquery name="qproductline" datasource="#application.datasource#">
	select pl.iproductline_id, pl.cdescription
	from houseproductline hpl
	join productline pl on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
	where hpl.dtrowdeleted is null and hpl.ihouse_id = #session.qselectedhouse.ihouse_id#
</cfquery>

<!-- retrieve residency types --->
<cfquery name="residency" datasource="#application.datasource#">
	select rt.iresidencytype_id ,rt.cdescription ,pl.iproductline_id ,plrt.iproductlineresidencytype_id
	from houseproductline hpl
	join productline pl on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
	join ProductLineResidencyType plrt on plrt.iproductline_id = pl.iproductline_id and plrt.dtrowdeleted is null
	join residencytype rt on rt.iresidencytype_id = plrt.iresidencytype_id and rt.dtrowdeleted is null
	where hpl.dtrowdeleted is null and hpl.ihouse_id = #session.qselectedhouse.ihouse_id#
</cfquery>

<!--- Check for Existence Of Respite Rates --->
<cfquery name="qRespiteChargeCheck" datasource="#APPLICATION.datasource#">
	select * from Charges where dtRowDeleted is null and ihouse_ID = #session.qSelectedHouse.iHouse_ID#
	and	iResidencyType_ID = 3
</cfquery>

<!-- respite catch ---->
<cfif qRespiteChargeCheck.RecordCount eq 0 and Tenant.iResidencyType_ID eq 3>
	<script> alert('There are no respite rates entered for this house. \r Please  contact your AR Specialist for assistance</>');</script>
</cfif>


<script language="JavaScript" src="../../../cfide/scripts/wddx.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript" src="../Shared/JavaScript/global.js"></script>

<!--- JavaScript function for relocation upon Choosing Do NOT Save the pages data --->
<script>
	<cfwddx action="cfml2js" input="#qproductline#" toplevelvariable="jsProductline">
	<cfwddx action="cfml2js" input="#Residency#" toplevelvariable="jsResidency">
	function initialize() { 
	df0=document.forms[0]; respiterates(df0.iResidencyType_ID); 
	t=document.getElementById("maintbl"); df0.Message.width=t.clientWidth;
	<cfoutput> <cfif isDefined("tenantinfo.dtmovein") and tenantinfo.dtmovein neq "">
		df0.MoveInMonth.value='#trim(month(tenantinfo.dtmovein))#'; 
		df0.MoveInDay.value='#trim(day(tenantinfo.dtmovein))#';
		df0.MoveInYear.value='#trim(year(tenantinfo.dtmovein))#';
		dayslist(df0.MoveInMonth,df0.MoveInDay,df0.MoveInYear); renteffective(df0.MoveInMonth);
	<cfelse>
		df0.MoveInMonth.value='#trim(month(now()))#';
		df0.MoveInDay.value='#trim(day(now()))#';
		df0.MoveInYear.value='#trim(year(now()))#';
		dayslist(df0.MoveInMonth,df0.MoveInDay,df0.MoveInYear); renteffective(df0.MoveInMonth);
	</cfif>
	<cfif isDefined("tenantinfo.dtRentEffective") and tenantinfo.dtRentEffective neq "">
		df0.RentMonth.value='#trim(month(tenantinfo.dtRentEffective))#';
		dayslist(df0.RentMonth,df0.RentDay,df0.RentYear);
		df0.RentDay.value='#trim(day(tenantinfo.dtRentEffective))#';
		df0.RentYear.value='#trim(year(tenantinfo.dtRentEffective))#';
		renteffective(df0.RentMonth);
	<cfelse>
		df0.RentMonth.value='#trim(month(now()))#';
		dayslist(df0.RentMonth,df0.RentDay,df0.RentYear);
		df0.RentDay.value='#trim(day(now()))#';
		df0.RentYear.value='#trim(year(now()))#';
		renteffective(df0.RentMonth);
	</cfif> 
	<cfif isDefined("tenantinfo.iproductline_id") and tenantinfo.iproductline_id neq "">
	document.getElementById("iproductline_id").value=#trim(tenantinfo.iproductline_id)#
	</cfif>
	//if (!document.getElementById("iproductline_id") == false) { genRes( prodsel=document.getElementById("iproductline_id") ); }
<!---	<cfif isDefined("tenantinfo.iresidencytype_id") and tenantinfo.iresidencytype_id neq "">
	document.getElementById("iResidencyType_ID").value=#trim(tenantinfo.iresidencytype_id)#
	</cfif>--->
	</cfoutput>
	}
	function redirect() { window.location="../Registration/Registration.cfm"; }
	function charge() { window.location="MoveInForm.cfm?ID=<cfoutput>#url.ID#</cfoutput>&Charge=" + df0.iCharge_ID.value; }
	function payor(obj){;
		if (df0.TenantbIsPayer.checked && df0.ContactbIsPayer.checked){ 
			df0.Message.value = "Please select one person as the payor"; obj.focus() 
			alert('Please select one person as the payor'); obj.checked = false;
		}
		if (!df0.TenantbIsPayer.checked && !df0.ContactbIsPayer.checked){ (df0.Message.value = "You must specify a payor"); alert('You must specify a payor'); }
	}
	
	
	
	function required() {
	var failed = false;
	
		if (df0.iSPoints.value == "" || df0.iSPoints.value == "..0") {
			df0.iSPoints.value = ""; df0.iSPoints.focus(); df0.Message.value = "Please Enter the Service Points"; return false; }
		if (df0.TenantbIsPayer.checked && df0.ContactbIsPayer.checked){
			(df0.Message.value = "Please  select one person as the payor"); alert("Please select one person as the payor"); location.hash = '#start'; return false;
		}
				
		if (!df0.TenantbIsPayer.checked && !df0.ContactbIsPayer.checked){
			(df0.Message.value = "You must specify a payor"); alert("You must specify a payor"); location.hash = '#start'; return false;
		}	
						
		else { df0.Message.value = ""; return true; }
	}
	<cfoutput>	
		function pointscheck(string){
			if (string.value < #NonZeroPoints.Minimum#){
				if (string.value != #MinPoints.minimum#){ string.value = #NonZeroPoints.Minimum#; df0.Message.value = 'The points chosen were too low. The lowest (non-zero) is now shown'; }
			}
			if (string.value > #NonZeroPoints.Maximum#){ string.value = #NonZeroPoints.Maximum#; df0.Message.value = 'The points chosen were too high. The highest points is now shown'; }
		}
		function renteffective(obj){
			m=Date.UTC(df0.MoveInYear.value,df0.MoveInMonth.value-1,df0.MoveInDay.value,0,0,0);
			today=new Date;
			if ( today.getMonth() == 12) {
				if (df0.RentYear.value !== '#Year(DateAdd('yyyy',1,Now()))#' && df0.RentMonth.value == 1) { 
					df0.RentYear.value='#Year(DateAdd('yyyy',1,Now()))#'; df0.RentDay.value='1';
					m= Date.UTC(df0.RentYear.value,0,1,0,0,0);
				}
				else if (df0.RentYear.value !== '#Year(DateAdd('yyyy',1,Now()))#' && df0.RentMonth.value !== 1) { df0.RentYear.value='#Year(Now())#'; }
			}
			r= Date.UTC(df0.RentYear.value,df0.RentMonth.value-1,df0.RentDay.value,0,0,0);
			a=Math.abs(r-m); b=a/1000/60/60/24;
			if (b > 30) { 
				if (obj.name.indexOf('Rent') == 0) { alert('Rent effective date must be within 30 days of the move in.'); }
				df0.RentMonth.value=df0.MoveInMonth.value;
				dayslist(df0.RentMonth,df0.RentDay,df0.RentYear); 
				df0.RentDay.value=df0.MoveInDay.value; 
				df0.RentYear.value=df0.MoveInYear.value;
			}
		}
	function respiterates(string){
		if (!df0.disablepoints) {
			if (string.value == 3) { df0.iSPoints.style.border="none"; df0.iSPoints.readOnly=true; df0.iSPoints.value = 0; } 
			else { df0.iSPoints.style.border="2px inset gainsboro"; df0.iSPoints.readOnly=false; }
		}
		if (string.value == 3 && #qRespiteChargeCheck.RecordCount# == 0){ 
			var message = 'There no respite rates entered for this house. \r Please  contact your AR Specialist for assistance.';
			df0.Message.value = 'There no respite rates entered for this house.'; alert(message);
			string.options[0].selected = true;	
		}
		else { document.forms[0].Message.value=''; }
	}
	</cfoutput>
<!---	function genRes(obj) {
		targopt=document.getElementsByName("iResidencyType_ID")[0];
		targopt.options.length=0;
		for (i=0;i<=jsResidency['iproductlineresidencytype_id'].length-1;i++){ 
			if (obj.value == jsResidency['iproductline_id'][i]) { 
				targopt.options.length += 1;
				targopt.options[targopt.options.length-1].value=jsResidency['iresidencytype_id'][i];
				targopt.options[targopt.options.length-1].text=jsResidency['cdescription'][i];
			}
		}
	}--->	
	window.onload=initialize;
	

</script>


<!--- retrieve active assessement if assessment tool is implimented --->
<cfif listfindnocase(toollist,session.qselectedhouse.cnumber,",") gt 0 
and listfindnocase(toollist,session.userid,",") gt 0 or 1 eq 1>

	<cfquery name="qActiveTool" datasource="#APPLICATION.datasource#">
	select distinct am.iassessmenttoolmaster_id, ast.csleveltypeset, am.dtbillingactive
	from assessmenttoolmaster am
	join assessmenttooldetail ad on ad.iassessmenttoolmaster_id = am.iassessmenttoolmaster_id 
	and ad.dtrowdeleted is null and am.dtrowdeleted is null
	and am.bfinalized is not null and am.dtbillingactive is not null and am.bbillingactive is not null
	join assessmenttool ast on ast.iassessmenttool_id = am.iassessmenttool_id and ast.dtrowdeleted is null
	where (am.itenant_id = #trim(tenant.itenant_id)#
	or am.iresident_id = (
	select distinct iresident_id from #Application.LeadTrackingDBServer#.leadtracking.dbo.residentstate where dtrowdeleted is null
	and itenant_id = #trim(tenant.itenant_id)#)
	)
	order by am.dtbillingactive desc
	</cfquery>

	<cfif qactivetool.recordcount gt 0>
	
		<cfquery name="qapoints" datasource="#APPLICATION.datasource#">
		select sum(isNull(sl.fweight,ssl.fweight)) ispoints
		from assessmenttoolmaster am 
		join assessmenttooldetail ad on ad.iassessmenttoolmaster_id = am.iassessmenttoolmaster_id
		and am.dtrowdeleted is null and ad.dtrowdeleted is null and am.bfinalized is not null
		and am.dtbillingactive is not null
		left join servicelist sl on sl.iservicelist_id = ad.iservicelist_id and sl.dtrowdeleted is null
		left join subservicelist ssl on ssl.isubservicelist_id = ad.isubservicelist_id and ssl.dtrowdeleted is null
		where am.iassessmenttoolmaster_id = #trim(qactivetool.iassessmenttoolmaster_id)#
		</cfquery>
	
	</cfif>
</cfif>

<!--- Retrieve the House Status --->
<cfquery name="HouseLog" datasource = "#APPLICATION.datasource#">
select * from HouseLog where iHouse_ID = #session.qSelectedHouse.iHouse_ID# and dtRowDeleted is null
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
<cfif FindNoCase(25, session.CodeBlock, 1) eq 0> and bAcctOnly is null </cfif>	
and	bIsRefundable is not null
<cfif qHouseDeposits.RecordCount GT 0>
and	c.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
<cfelse> and c.iHouse_ID is null </cfif>
</cfquery>

<!--- Retreivea all DepositTypes that are Fees (Non-Refundable) --->
<cfquery name="Fees" datasource="#APPLICATION.datasource#">
select ct.*, c.cDescription as cDescription, c.iCharge_ID
from ChargeType ct 
join Charges C on (c.iChargeType_ID = ct.iChargeType_ID and c.dtRowDeleted is null)
where ct.dtRowDeleted is null and bIsDeposit is not null
and getdate() between c.dteffectivestart and c.dteffectiveend
<cfif FindNoCase(25, session.CodeBlock, 1) eq 0> and bAcctOnly is null </cfif>	
and	bIsRefundable is null
<cfif qHouseDeposits.RecordCount GT 0>
and	c.iHouse_ID = #session.qSelectedHouse.iHouse_ID# 
<cfelse> and c.iHouse_ID is null </cfif>
</cfquery>

<!--- Retrieve all pertenant charges. Both General and House Specific --->
<cfquery name= "AvailableCharges"	datasource = "#APPLICATION.datasource#">
select c.*, ct.bIsModifiableDescription, ct.bIsModifiableAmount, ct.bIsModifiableQty
from Charges c
join 	ChargeType ct on c.iChargeType_ID = ct.iChargeType_ID
where (iHouse_ID is null or c.iHouse_ID=#session.qSelectedHouse.iHouse_ID#)
and	c.dtRowDeleted is null and c.mAmount < 1
<cfif IsDefined("url.Charges")> and c.iCharge_ID = #url.Charges# </cfif>
</cfquery>

<!---Project 20125 Modification. 06/04/08 SSathya added the validation for the hard halt--->

<script language="JavaScript" type="text/javascript">
	function hardhaltvalidation(formCheck)
	{	
		if(formCheck.iResidencyType_ID.options[formCheck.iResidencyType_ID.selectedIndex].value == "")
		{
			formCheck.iResidencyType_ID.focus();
			alert("Please select a Residency Type");
			return false;
		}	
	
		if(formCheck.cSSN.value =="")
		{
			formCheck.cSSN.focus();
			alert("Please Enter the SSN of the resident");
			return false;
		}

		if(Validatedate(formCheck.dbirthdate.value)== false)
		{
			formCheck.dbirthdate.focus();
			alert("Please enter Birth Date in the MM/DD/YYYY");
			return false;
		}
		
		if(formCheck.cPreviousAddressLine1.value=="")
		{
			formCheck.cPreviousAddressLine1.focus();
			alert("Please enter the previous address of the resident");
			return false;
		}		
		if(formCheck.cPreviousCity.value=="")
		{
			formCheck.cPreviousCity.focus();
			alert("Please enter the previous City of the resident");
			return false;
		}
		if(formCheck.cPreviouszipCode.value=="")
		{
			formCheck.cPreviouszipCode.focus();
			alert("Please enter the previous City Zip Code of the resident");
			return false;
		}
		//Validate PMO
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
			formCheck.cPreviouszipCode.focus();
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
			formCheck.cPreviouszipCode.focus();
			alert("Please provide Military response");
			return false;
			
		}	
		//If the Tenant Is Payer
	
		if(formCheck.TenantbIsPayer.checked == true)
		{
			  if(formCheck.cOutsideAddressLine1.value=="")
				{
					formCheck.cOutsideAddressLine1.focus();
					alert("Resident is the Payor so please enter the Billing address");
					return false;
				}
				if(formCheck.cOutsideCity.value == "")
				{
					formCheck.cOutsideCity.focus();
					alert("Please enter City for Billing address");
					return false;
				}
				if(formCheck.cOutsideZipCode.value =="")
				{
					formCheck.cOutsideZipCode.focus();
					alert("Please enter Zip Code for Billing address");
					return false;
				}
	
		}
				//If the Contact Is Payer
		if(formCheck.ContactbIsPayer.checked == true)
		{
				if(formCheck.cFirstName.value=="")
				{
					alert("First Name for the Contact");
						formCheck.cFirstName.focus();
						return false;
				}
				if(formCheck.cLastName.value=="")
				{
					alert("Last Name for the Contact");
						formCheck.cLastName.focus();
						return false;
				}
			
			  if(formCheck.cAddressLine1.value=="")
				{
					alert("Billing address for the Contact");
					formCheck.cAddressLine1.focus();
					return false;
				}
				if(formCheck.cCity.value == "")
				{
					formCheck.cCity.focus();
					alert("Please enter City for Billing address");
					return false;
				}
				if(formCheck.cZipCode.value =="")
				{
					formCheck.cZipCode.focus();
					alert("Please enter Zip Code for Billing address");
					return false;
				}
				<!--- Proj 35400 - 3/30/2009 RTS - Email Validation. --->
				if(formCheck.cEmail.value !=""){
					var str=MoveInForm.cEmail.value
					var filter=/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
					if (filter.test(str)){
					
					}else{
					alert("Please input a valid email address for the contact.")
					return false;
					}
				}
		}
		
		
		
	//Add-in for Project 26955  RTS  10/01/2008
		//Bond certification forms mailed date box
		if(formCheck.bondval.value==1)
		{
			if(formCheck.dtBondCertificationMailed.value == '00/00/0000')
				{
					formCheck.dtBondCertificationMailed.focus();
						alert("Please enter the date the income certification was mailed to the Corporate Office.");
						return false;
			}else if (formCheck.dtBondCertificationMailed.value == ''){
					formCheck.dtBondCertificationMailed.focus();
						alert("Please enter the date the income certification was mailed to the Corporate Office.");
						return false;
			}else if (ValidBondDate(formCheck.dtBondCertificationMailed.value) == false){
					formCheck.dtBondCertificationMailed.focus();
						alert("Please enter a valid date in which the income certification was mailed to the Corporate Office. \n \n"+MoveInForm.dtBondCertificationMailed.value+"  is not a valid date.");
						return false;
				}
				//Bond Qualifying Yes/No
					//var bondq = false;
					for(j=0;j<MoveInForm.cBondQualifying.length;j++)
					{
						if(MoveInForm.cBondQualifying[j].checked)
						{var bondq = true;
						
							if(MoveInForm.cBondQualifying[j].value == 1){
								var bondq_value = true;
							}else{
								var bondq_value = false;
							}
						}
					}
					//alert(bondq_value)
					if(!bondq)
					{
						//formCheck.cBondQualifying.focus();
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
		return true;
	}
	
	//09/30/2008 sathya added this as part of project 28289
	function isInteger(s){
	var i;
    for (i = 0; i < s.length; i++){   
        // Check that current character is number.
        var c = s.charAt(i);
        if (((c < "0") || (c > "9"))) return false;
    }
    // All characters are numbers.
    return true;
}
//09/30/2008 sathya added this as part of project 28289
function stripCharsInBag(s, bag){
	var i;
    var returnString = "";
    // Search through string's characters one by one.
    // If character is not in bag, append to returnString.
    for (i = 0; i < s.length; i++){   
        var c = s.charAt(i);
        if (bag.indexOf(c) == -1) returnString += c;
    }
    return returnString;
}
//09/30/2008 sathya added this as part of project 28289
function daysInFebruary (year){
	// February has 29 days in any year evenly divisible by four,
    // EXCEPT for centurial years which are not also divisible by 400.
    return (((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28 );
}
//09/30/2008 sathya added this as part of project 28289
function DaysArray(n) {
	for (var i = 1; i <= n; i++) {
		this[i] = 31
		if (i==4 || i==6 || i==9 || i==11) {this[i] = 30}
		if (i==2) {this[i] = 29}
   } 
   return this
}
//09/30/2008 sathya added this as part of project 28289
function isDate(dtStr){
	var dtCh= "/";
	var minYear=1900;
	var year=new Date();
	var maxYear=year.getYear();
	var daysInMonth = DaysArray(12)
	var pos1=dtStr.indexOf(dtCh)
	var pos2=dtStr.indexOf(dtCh,pos1+1)
	var strMonth=dtStr.substring(0,pos1)
	var strDay=dtStr.substring(pos1+1,pos2)
	var strYear=dtStr.substring(pos2+1)
	strYr=strYear
	if (strDay.charAt(0)=="0" && strDay.length>1) strDay=strDay.substring(1)
	if (strMonth.charAt(0)=="0" && strMonth.length>1) strMonth=strMonth.substring(1)
	for (var i = 1; i <= 3; i++) {
		if (strYr.charAt(0)=="0" && strYr.length>1) strYr=strYr.substring(1)
	}
	month=parseInt(strMonth)
	day=parseInt(strDay)
	year=parseInt(strYr)
	if (pos1==-1 || pos2==-1){
		//alert("The date format should be : mm/dd/yyyy")
		return false
	}
	if (strMonth.length<1 || month<1 || month>12){
		//alert("Please enter a valid month")
		return false
	}
	if (strDay.length<1 || day<1 || day>31 || (month==2 && day>daysInFebruary(year)) || day > daysInMonth[month]){
		//alert("Please enter a valid day")
		return false
	}
	if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
		//alert("Please enter a valid 4 digit year between "+minYear+" and "+maxYear)
		return false
	}
	if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
		//alert("Please enter a valid date")
		return false
	}
		
return true
}
// Proj 26955 2/24/2009  rschuette bond date validation
function isDateB(dtStr){
	var dtCh= "/";
	var minYear=2008;
	var year=new Date();
	var now=new Date();
	var maxYear=year.getYear();
	var daysInMonth = DaysArray(12)
	var pos1=dtStr.indexOf(dtCh)
	var pos2=dtStr.indexOf(dtCh,pos1+1)
	var strMonth=dtStr.substring(0,pos1)
	var strDay=dtStr.substring(pos1+1,pos2)
	var strYear=dtStr.substring(pos2+1)
	strYr=strYear
	if (strDay.charAt(0)=="0" && strDay.length>1) strDay=strDay.substring(1)
	if (strMonth.charAt(0)=="0" && strMonth.length>1) strMonth=strMonth.substring(1)
	for (var i = 1; i <= 3; i++) {
		if (strYr.charAt(0)=="0" && strYr.length>1) strYr=strYr.substring(1)
	}
	month=parseInt(strMonth)
	day=parseInt(strDay)
	year=parseInt(strYr)
	if (pos1==-1 || pos2==-1){
		//alert("The date format should be : mm/dd/yyyy")
		return false
	}
	if (strMonth.length<1 || month<1 || month>12){
		//alert("Please enter a valid month")
		return false
	}
	if (strDay.length<1 || day<1 || day>31 || (month==2 && day>daysInFebruary(year)) || day > daysInMonth[month]){
		//alert("Please enter a valid day")
		return false
	}
	if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
		//alert("Please enter a valid 4 digit year between "+minYear+" and "+maxYear)
		return false
	}
	if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
		//alert("Please enter a valid date")
		return false
	}
		if(strDay.length<2){strDay = 0 + strDay}
		if(strMonth.length<2){strMonth = 0 + strMonth}
		var RearrangedInput=strYear+strMonth+strDay
		RearrangedInput = parseFloat(RearrangedInput)
		var TodayDay = parseInt(now.getDate());
		TodayDay = TodayDay +'';
		if (TodayDay.length<2){TodayDay = 0 + TodayDay;}
		
		var TodayMonth = parseInt(now.getMonth());
		TodayMonth = (TodayMonth + 1)+'';
		if (TodayMonth.length<2){TodayMonth = 0 + TodayMonth;}
		
		var TodayYear = now.getFullYear();
		var TodayRearranged = (TodayYear + ''+ TodayMonth +''+ TodayDay)
		TodayRearranged = parseFloat(TodayRearranged);
		if (RearrangedInput>TodayRearranged){
			//alert("Please no future dates.")
			return false;
		}
return true
}
//09/30/2008 sathya added this as part of project 28289
function Validatedate(dbirthdate){
	
	///var dt=dbirthdate
	if (isDate(dbirthdate)==false){
		return false;
	}
    return true;
}
//2/24/2009 Proj 26955 rschuette bond date validation
function ValidBondDate(dtbond){
	
	///var dt=dbirthdate
	if (isDateB(dtbond)==false){
		return false;
	}
    return true;
}	
	
</script>

<!--- Project 20125 modification. 06/04/08 SSathya Added this for the tenant address statecode  --->
<cfquery name="Statecode" datasource="#APPLICATION.datasource#">
	select * from statecode
</cfquery>
<cfquery name="bondhouse" datasource="#application.datasource#">
  	select * from house  where ihouse_id =  #session.qSelectedHouse.iHouse_ID#
 </cfquery>
<!--- Project 26955  RTS - 11/17/08 --->
<cfquery name="Occupied" datasource="#APPLICATION.datasource#">
					select distinct TS.iAptAddress_ID 
					from TenantState TS (NOLOCK)
					join Tenant T on (T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null)
					join AptAddress AD on (AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null)
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
					join apttype at1 on (at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null)
					where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and aa.bBondIncluded = 1
					and aa.dtRowDeleted is null
				</cfquery>
				<cfset BondIncludedAptList = ValueList(BondAppAptList.iAptAddress_ID)>
				<!--- Apartment List of apartments set as bond ---> 
				<cfquery name="BondAptList" datasource="#APPLICATION.datasource#">
					select aa.*,at1.* 
					from AptAddress aa
					join apttype at1 on (at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null)
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
					from TIPS4.dbo.AptAddress aa, TIPS4.dbo.tenant te, TIPS4.dbo.TenantState TS (NOLOCK) 
					join TIPS4.dbo.Tenant T on (T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null)
					join TIPS4.dbo.AptAddress AD on (AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null)
					where TS.dtRowDeleted is null
					and TS.iTenantStateCode_ID = 2
					and AD.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and TS.iAptAddress_ID = aa.iAptAddress_ID 
					and te.iTenant_ID = ts.iTenant_ID
					and aa.bBondIncluded = 1
				</cfquery>
				<cfset OccupiedRowCount = (Occupied.recordcount)>

</cfif>
<!--- End project 26955 query list --->

<cfoutput>
<form name="MoveInForm" action="#Variables.Action#" method="POST" onSubmit="return required();">
<!--- Link to leave page without scrolling to the bottom --->
<br/><a href="../MainMenu.cfm" style="font-size: 18;"> <B>Exit Without Saving</B></a><br/>
<input type="hidden" name="iTenant_ID" value="#URL.ID#">
<input type="hidden" name="cSolomonKey" value="#Tenant.cSolomonKey#">
<!--- Project 20125 modification. 06/04/08 Ssathya added the cMilitaryVa and HasExecutor as hidden --->
<input type="hidden" name="cMilitaryVA" value="">
 <input type="hidden" name="hasExecutor" value="">
<input type="text" name="Message" value="" size="75" style="color: red; font-weight: bold; font-Size: 16; text-align: center;">

<table id="maintbl">
	<tr><th colspan="6" style="font-size:medium;"><b>Move In Form</b></th></tr>
	<!---  <cfif IsDefined("url.ID")> --->
	<tr>
		<td colspan="2" style="font-weight: bold;">Residents Name</td>
		<td colspan="2"> <cfif IsDefined("url.ID")>#Tenant.cFirstname# #Tenant.cLastName#<cfelse> Tenant Name	</cfif> </td>
	</tr>
<!--- Project 20125 modification.06/04/08 ssathya adding the middle initial project 20125 --->
	<tr>
		<td colspan="2" style="font-weight: bold;">Middle Initial</td>
		<td colspan="2"><input name="cMiddleInitial" type ="text"></td>
	</tr>
	
	
	<!--- </cfif>  --->
	
	<!--- Project 20125 modification. 06/04/08 ssathya adding the ssn --->
	<tr>
		<td colspan="2" style="font-weight: bold;color:red;">SSN</td>
		<td colspan="2">
            
			<input type="text" name="cSSN" value="#Tenant.cSSN#">
			 </td>
	</tr>
	<!--- Project 20125 modification.06/04/08 ssathya adding the birthdate  --->
	
	<tr>	
		<td colspan="2" style="font-weight: bold;color:red;"> Birthdate </td>
		<td>
			<input type="text" Name="dbirthdate" value = "#DateFormat(tenant.dbirthdate,"mm/dd/yyyy")#" size ="12">(MM/DD/YYYY)
		</td> 
	</tr>
	<!--- Project 20125 modification.06/10/08 ssathya add the details of  current address and previous address --->
	<tr >
		<td colspan="2" style="font-weight:bold;color:red;">Previous Address</td>
		<td><input type="text" name="cPreviousAddressLine1" value="#tenant.cOutsideAddressLine1#" >
		
		</td>
		
	</tr>
	<tr >
		<td colspan="2" style="font-weight:bold"> Previous Address Line2</td>
		<td><input type="text" name="cPreviousAddressLine2" value="#tenant.cOutsideAddressLine2#">
		
		</td>
		
	</tr>
	<tr><td colspan="2" style="font-weight:bold;color:red;">Previous City</td>
		<td><input type="text" name="cPreviousCity" value="#tenant.cOutsideCity#">
		</td></tr>
	 <tr>
		<td colspan="2" style="font-weight: bold;color:red;"> Previous State </td>
		<td colspan="2">		
			<select name="cPreviousState">
				<option value=""> None </option>
				<cfloop query="StateCode">
					<cfscript>
						if  (TenantInfo.cOutsideStateCode eq statecode.cStateCode) { Selected = 'Selected'; }
						else { Selected = ''; }
					</cfscript>
					<option value="#Statecode.cStateCode#" #Selected#> #Statecode.cStateCode# </option>
				</cfloop>
			</select>
		</td>
	</tr>
		<tr>
		<td colspan="2" style="font-weight:bold;color:red;">
			Preivous ZipCode</td>
			<td><input type="text" name="cPreviouszipCode" value="#tenant.cOutsidezipCode#" >
		
		</td>
		</tr>
	
	 <tr >
		<td colspan="2" style="font-weight:bold;">Billing Address</td>
		<td><input type="text" name="cOutsideAddressLine1" ></td>
		<td Style="color:red;">*Please Enter the Billing Address if the Resident is The payor
		</td>
	</tr>
	<tr >
		<td colspan="2" style="font-weight:bold">Billing Address Line 2</td>
		<td><input type="text" name="cOutsideAddressLine2">
		
		</td>
	</tr>
	<tr >
		<td colspan="2" style="font-weight:bold;">Billing City</td>
		<td><input type="text" name="cOutsideCity">
		
		</td>
	</tr>
	
	 <tr>
		<td colspan="2" style="font-weight: bold;">Billing State </td>
		<td colspan="2">		
			<select name="cOutsideStateCode">
				<option value=""> None </option>
				<cfloop query="StateCode">
					<option value="#Statecode.cStateCode#" #Selected#> #Statecode.cStateCode# </option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr >
		<td colspan="2" style="font-weight:bold;">Billing Zip Code</td>
		<td><input type="text" name="cOutsideZipCode">
		
		</td>
	</tr>
	
<!--- 	Project 26955 For insert above Apt Number selection	RTS 10/01/2008 --->		 
 <cfif bondhouse.iBondHouse eq 1> 		 
			<tr><td colspan="4" ><span style="Font-weight: bold;color:red;">
				Did the resident qualify as eligible for meeting<br>
				 the Bond program occupancy requirements? </span>&nbsp;&nbsp;<b>
				 Yes<input type="radio" name="cBondQualifying" id="cBondQualifying" value="1" onclick="document.MoveInForm.cBondQualifying.value=this.value;"> 
				 No<input type="radio" name="cBondQualifying" id="cBondQualifying" value="0" onclick="document.MoveInForm.cBondQualifying.value=this.value;"> </b>
				</td>
			</tr>
			
			<tr>		
				<td colspan="3"><span style="Font-weight: bold;color:red;">Date the income certification was faxed or emailed to the Corporate Office:&nbsp;</span>
				<td><input type="text" name="dtBondCertificationMailed" value="00/00/0000">(MM/DD/YYYY)</td>
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
			 <tr>
				<td colspan="2" style="Font-weight: bold;">	Apartment Number </td>
				<td colspan="3.5">
					<select name="iAptAddress_ID">
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
								<option value= "#Available.iAptAddress_ID#" #Selected#> #Available.cAptNumber# - #Available.cDescription##NOTE##NOTE1##NOTE2# </option>	
							<cfelse>
								<cfscript>
									if (ListFindNoCase(OccupiedList,Available.iAptAddress_ID,",") GT 0){Note = '(Occupied)';} else{ Note=''; }
									if (IsDefined("TenantInfo.iAptAddress_ID") and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
										OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
										Selected = 'Selected'; }
									else { Selected = ''; }
								</cfscript>
								<option value= "#Available.iAptAddress_ID#" #Selected#> #Available.cAptNumber# - #Available.cDescription##NOTE# </option>
							</cfif>				
						</cfloop>
					</select>
				</td>
			</tr>			

	<tr>
		<td colspan="2" style="font-weight: bold;">Move In Date</td>
		<td colspan="2">
			
			<select name="MoveInMonth" onChange="dayslist(df0.MoveInMonth,df0.MoveInDay,df0.MoveInYear); renteffective(this);">
				<cfloop index="i" from="1" to="12" step="1"><option value="#i#" #Selected#> #i# </option></cfloop>
			</select>
			/
			<select name="MoveInDay" onChange="dayslist(df0.MoveInMonth,df0.MoveInDay,df0.MoveInYear); renteffective(this);">
				<cfloop index="i" from="1" to="31" step="1"> <option value= "#i#" #Selected#> #i# </option> </cfloop>
			</select>
			/
			<cfif Month(session.TIPSMonth) gte 3 and (TenantInfo.dtMoveIn neq "" and year(TenantInfo.dtMoveIn) eq year(Now()))>
				<input type="text" name="MoveInYear" value="#year(now())#" size="4" maxlength="4" onKeyUp="this.value=Numbers(this.value)" style="text-align: center;" onBlur="YearTest(this);" ReadOnly>
			<cfelse>
				<cfprocessingdirective suppresswhitespace="true">
				<cfscript>
					LastYear = Year(Now()) -1; 
					NextYear = Year(Now()) +1; 
					Year=Year(now());
					
					writeoutput('<select name="MoveInYear">');
					
					if (Year eq Year(Now())) 
					{ 
						Now = 'Selected'; 
					} 
					else 
					{ 
						Now = ''; 
					}
					
					writeoutput('<option value="#year(Now())#" #Now#> #year(Now())# </option><option value="#DateFormat(DateAdd("yyyy",1,NOW()),"yyyy")#"> #DateFormat(DateAdd("yyyy",1,NOW()),"yyyy")# </option>');

					if (Month(Now()) eq 1) 
					{ 
						if (Year eq LastYear){ Last = 'Selected';} else{ Last = ''; } writeoutput('<option value="#LastYear#" #Last#> #LastYear# </option>'); 
					}
					writeoutput('</select>');
				</cfscript>
				</cfprocessingdirective>			
			</cfif>
			<cfif RegCheck.RecordCount GT 0>
				<script> function removedate(){ document.forms[0].action ='removemoveindate.cfm?ID=#Tenant.iTenant_ID#'; document.forms[0].submit(); } </script>
				<br /><input type="button" name="deleteprojected" value="Remove Projected Move In Date" style="width: 200px; font-size:10;" onClick="removedate();">
			</cfif>
		</td>
	</tr>

	<tr>
		<td colspan="2" style="font-weight: bold;">Rent Effective Date</td>
		<td colspan="2">		
			<select name="RentMonth" onChange="dayslist(df0.RentMonth,df0.RentDay,df0.RentYear); renteffective(this);">
				<cfloop index="i" from="1" to="12" step="1"><option value="#i#" #Selected#> #i# </option></cfloop>
			</select>
			/
			<select name="RentDay" onChange="dayslist(df0.RentMonth,df0.RentDay,df0.RentYear); renteffective(this);">
				<cfloop index="i" from="1" to="31" step="1"><option value= "#i#" #Selected#> #i# </option></cfloop>
			</select>
			/
			<cfif Month(session.TIPSMonth) gte 3 and (TenantInfo.dtRentEffective neq "" and year(TenantInfo.dtRentEffective) eq year(Now()) ) and Month(session.TipsMonth) neq 12>
				<input type="text" name="RentYear" value="#year(now())#" size="4" maxlength="4" onKeyUp="this.value=Numbers(this.value)" style="text-align: center;" onBlur="YearTest(this);" ReadOnly>
			<cfelse>
				<cfprocessingdirective suppresswhitespace="true">
				<cfscript>
					LastYear = Year(Now()) -1; 
					NextYear = Year(Now()) +1; 
					Year = Year(now());
					
					writeoutput('<select name="RentYear">');
					
					if (Year eq Year(Now())) 
					{ 
						Now = 'Selected'; 
					} 
					else 
					{ 
						Now = ''; 
					}
					
					writeoutput('<option value="#year(Now())#" #Now#> #year(Now())# </option><option value="#DateFormat(DateAdd("yyyy",1,NOW()),"yyyy")#"> #DateFormat(DateAdd("yyyy",1,NOW()),"yyyy")# </option>');

					
					if (Month(Now()) eq 1) 
					{ 
						if (Year eq LastYear)
						{ 
							Last = 'Selected';
						} 
						else
						{ 
							Last = ''; 
						} 
						
						writeoutput('<option value="#LastYear#" #Last#> #LastYear# </option>'); 
					}
					writeoutput('</select>');
				</cfscript>
				</cfprocessingdirective>			
			</cfif>
		</td>
	</tr>
	
	<tr>
		<td colspan="2" style="font-weight: bold;"> Product line </td>
		<td><cfset productoptions=""><cfloop query="qproductline"><cfset productoptions=productoptions&"<option value='#qproductline.iproductline_id#'>#qproductline.cDescription#</option>"></cfloop>
			<select id="iproductline_id" name="iproductline_id">#productoptions#</select>	
		</td>
		<td colspan="2"></td>
	</tr>
	<tr>
		<td colspan="2" style="font-weight: bold;"> Residency Type</td>
		<td colspan="2">
			<select name="iResidencyType_ID" onChange="respiterates(this);">
				<option value=""> </option>
				<cfloop query="Residency">
					<option value="#Residency.iResidencyType_ID#"> #Residency.cDescription# </option>
				</cfloop>
			</select>
		</td>
	</tr>
	<!--- Project 20125 modification.08/08/2008 SSathya added the projected move out date for the Respite people only --->
	<tr>
		<td colspan="2" style="font-weight: bold;">Projected Move Out Date</td>
			<td><input type="text" size="8" name="dtmoveoutprojecteddate" onblur="validatePMO();"> 
			&nbsp;
			<a onClick="show_calendar2('document.MoveInForm.dtmoveoutprojecteddate',document.getElementById('dtmoveoutprojecteddate').value,'dtmoveoutprojecteddate');"> 
				<img src="../../global/Calendar/calendar.gif" alt="Calendar" width="16" 
				height="15" border="0" align="middle" style="" id="Cal" name="Cal">
			</a>
			<br />(MM/DD/YYYY)
		</td>
		<td Style="color:red;"><span id="Mes" style="display:none">PMO DATE CAN'T BE IN THE PAST, AND FOR RESPITES IT CANNOT BE MORE THAN 3 MONTHS IN THE FUTURE.</span>
</td>
	</tr>
	<tr>
		<td colspan="2" style="font-weight: bold;"></td>
		<td Style="color:red;">*Please Enter the Projected Move Out Date if the Resident is Respite</td>
		<td></td>
	</tr>
	<tr>
		<td colspan="2" style="font-weight: bold;">	Service Level Set	</td>
		<td colspan="2">
			<cfscript>
			if (isDefined("qactivetool.csleveltypeset") and qactivetool.csleveltypeset neq "") { csleveltypeset = numberformat(qactivetool.csleveltypeset,"99"); }
			else if (TenantInfo.csleveltypeset neq ""){ csleveltypeset = TenantInfo.csleveltypeset; }
			else { csleveltypeset = session.qselectedhouse.csleveltypeset; }
			</cfscript>	
		<input type="text" name="csleveltypeset" value="#csleveltypeset#" size="3" maxlength="3" style="border:none;background:transparent;text-align:center;" readonly>
		</td>
	</tr>
	<tr>
		<td colspan="2" style="font-weight: bold;"> Service Points </td>
		<td colspan="2">
			<cfscript>
			stringscript="style='text-align:center;'";
			if (isDefined("qapoints.ispoints") and qapoints.ispoints neq "") { 
			writeoutput("<input type='hidden' name='disablepoints' value='1'>");
			iSPoints = numberformat(qapoints.iSPoints,"99"); 
			stringscript="style='border:none;text-align:center;' readonly";
			}
			else if (TenantInfo.iSPoints neq "" and (Tenant.iSPoints gte MinPoints.Minimum)){ iSPoints = TenantInfo.iSPoints; }
			else { iSPoints = MinPoints.minimum; }
			</cfscript>
			<input type="text" name="iSPoints" value="#trim(iSPoints)#" size="3" maxlength="3" onKeyUp="this.value=Numbers(this.value)" onBlur="required(); pointscheck(this);" #stringscript#>
		</td>
	</tr>
	
	
	
	<tr>
		<td colspan="2" style="font-weight: bold;"> Primary Diagnosis </td>
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
	<tr>
		<td colspan="2" style="font-weight: bold;"> Secondary Diagnosis </td>
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
		<td colspan="2" style="Font-weight: bold;"> Is this resident also the Payor? </td>
		<td colspan="2">		
		<cfif Tenant.bIsPayer eq ""> <cfset Check="Unchecked"> <cfelse> <cfset Check="Checked"> </cfif>	
		<input type="Checkbox" name="TenantbIsPayer" value="1" style="text-align: center;" onKeyUp="this.value=Numbers(this.value)" #Variables.Check# onClick="payor(this);" onBlur="required();">
	</tr>
	<!--- Project 36359 - MI Check received check box --->
	<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
	<tr>
		<td colspan="2" style="Font-weight: bold;"> Was a Move In Check received? </td>
		<td colspan="2">		
		<cfif Tenant.bMICheckReceived is '' or Tenant.bMICheckReceived eq 0> <cfset MICCheck="Unchecked"> <cfelse> <cfset MICCheck="Checked"> </cfif>	
		<input type="Checkbox" name="TenantbMICheckReceived" value="1" style="text-align: center;"  #Variables.MICCheck#>
	</tr>
	</cfif>
	
	<!---  Project 20125 modification. 05/28/08 ssathya done the modification for the residence agreement and resident fee paid/waved for the AR admin and AR analysts access  --->
	 <cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
		 <!--- Project 20125 modification. 06/09/08 SSAthya added the promotion  --->
		 <tr>
		<td colspan="2" style="font-weight: bold;"> Promotion Used </td>
		<td colspan="2">		
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
	<tr>
		<!---Project 20125 modification. 06/09/08 SSathya added the residence agreement as per project# 20125 --->
		<td colspan="2" style="Font-weight: bold;"> Has the resident signed the Residency Agreement? </td>
		<td colspan="2">		
		<cfset bit= iif(Tenant.cResidenceAgreement IS 1, DE('Checked'), DE('Unchecked'))>
			<input type= "CheckBox" name= "cResidenceAgreement" Value = "1" #Variables.bit#>	
		
	</tr>
	<tr>
		<!--- Project 20125 modification.06/09/08 SSAthya added  Resident fee --->
		<td colspan="2" style="Font-weight: bold;">New Resident Fee Paid/Waived? </td>
		<td colspan="2">		
		<cfset bit= iif(Tenant.cResidentFee IS 1, DE('Checked'), DE('Unchecked'))>
			<input type= "CheckBox" name= "cResidentFee" Value = "1" #Variables.bit#>	
		
	</tr>
	
	  </cfif>
	
	 <!--- Project 20125 modification. 06/03/08 sathya added the question of executor --->
	 <tr>
	<td colspan="4" style="font-weight: bold;;color:red;">Does this resident have an Executor of Estate? &nbsp;&nbsp; 
	Yes <input name="hasExecutor" type="radio" value="1" onclick ="document.MoveInForm.hasExecutor.value=this.value" >  
	No	<input name="hasExecutor" type="radio" value="0" onclick="document.MoveInForm.hasExecutor.value=this.value"> </td>
	</tr> 
	 <!--- Project 20125 modification. 06/20/08 ssathya to check if this house is a bond house --->
	 <!--- Query moved to the Project 26955 query list above --->

		   
		 <input type="hidden" name="bondval" value="#bondhouse.ibondhouse#"> 
		  
	 <!--- Project 36359 rts - Deferred Payment option for AR --->
	<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
	<tr>
		<td colspan="2" style="Font-weight: bold;"> Does tenant qualify for Deferred Payments? </td>
		<td colspan="2">		
		<cfif Tenant.bDeferredPayment is '' or Tenant.bDeferredPayment eq 0> <cfset DefPymnt="Unchecked"> <cfelse> <cfset DefPymnt="Checked"> </cfif>	
		<input type="Checkbox" name="TenantbDeferredPayment" value="1" style="text-align: center;"  #Variables.DefPymnt#>
	</tr>
	</cfif>
	<!--- end 36359 --->
	<!--- Project 20125 modification.06/09/08 added the Military detials  --->
	 <tr>
		 
		<td colspan="5" style="font-weight: bold;color:red;">Has the resident or the resident's spouse served in Military?  
			Yes <input type="radio" name="cMilitaryVA" value="1" onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value"> No
			<input type="radio" name="cMilitaryVA" value="0" onClick="doClick(this);document.MoveInForm.cMilitaryVA.value=this.value">
		</td> 
	</tr>
	
	<tr>
	<td colspan="5" style="font-weight: bold;">
			<div id="otherOpt3" style="display:none" align="justify">
				Branch of Military served :
				
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
			Has a VA representative been contacted? <input type= "CheckBox" name= "VaRepresentativeContacted" Value = "1" #Variables.bit#>
		</td>
	</tr>
	<tr>
		<td colspan="5" style="font-weight: bold;">
			<div id="otherOpt2" style="display:none" align="justify">
			<cfset bit= iif(Tenantinfo.VaBenefits IS 1, DE('Checked'), DE('Unchecked'))>
			Do they qualify for VA Benefits?<input type= "CheckBox" name= "VaBenefits" Value = "1" #Variables.bit#>  
			</td>
	</tr>
 
<!--- Project 20125 modification. 06/03/08 SSathya added the  military service dates --->
<tr>
<td colspan="5" style="font-weight: bold;">
	<div id="otherOpt" style="display:none" align="justify">
	Dates of Service: Start <input type="text" name="cMilitaryStartDate">&nbsp&nbsp&nbsp End <input type="text" name="cMilitaryEndDate">
				</div>
		</td>
		</tr>
						
	<tr><td colspan="4"></td></tr>
<!--- Start of multiple table display --->
	<tr>
		<cfif Refundables.recordcount GT 0>
		<td colspan="2" style='vertical-align:top;'>
			<table style="width: 100%;">
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
		<!--- Ssathya Added an if condition to the exsisting code so that it displays it in the movein --->
		<cfif Fees.recordcount GT 0>
		<td colspan="4" style='vertical-align:top;text-align:center;'>
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
								from invoicedetail inv <!--- SSathya corrected the exisiting query there was no from in the query --->
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
		</cfif>
		
	</tr>
	<tr><td colspan="4"></td></tr>

	
<!--- *********************************************************************************************************************
	<cfif HouseLog.bIsPDclosed neq ""> <cfset Toggle=1> <cfelse> <cfset Toggle=0> </cfif>		
********************************************************************************************************************* --->
	<cfif HouseLog.bIsPDClosed GT 0> <cfset Toggle=1> <cfelse> <cfset Toggle=0> </cfif>		
	<input type="Hidden" name="bNextMonthsRent" value="#Toggle#">
	<tr><td colspan="4"></td></tr>
	<tr><td colspan="4" style="font-weight: bold;"><U>Contact Information</U></td></tr>
	<tr>
		<td style="font-weight: bold;">	First Name 	</td>
		<td> <input type="text" name="cFirstName" value="#ContactInfo.cFirstName#" onBlur="this.value=ltrs(this.value); Upper(this);"></td>
		<td></td>
		<!--- Project 20125 modification.06/09/08 SSAthya Changed the wordings --->
		<td style="font-weight: bold;"> Is this Contact a payor? </td>
		<td style="text-align: center;">
			<cfset bit= iif(ContactInfo.bIsPayer IS 1, DE('Checked'), DE('Unchecked'))>
			<input type="CheckBox" name="ContactbIsPayer" Value="1" #Variables.bit# onClick="payor(this);">	
		</td>
	</tr>
	<tr>
		
		<td style= "Font-weight: bold;">Last Name </td>
		<td> <input type="text" name="cLastName" value="#ContactInfo.cLastName#" onBlur="this.value=ltrs(this.value); Upper(this);">	</td>
		<td></td>
		<!--- Project 20125 modification.06/09/08 ssathya changed the wordings  --->
		<td style= "font-weight: bold;">	Does this Contact have <br /> Financial Power Of Attorney? </td>
		<td style= "text-align: center;">
			<cfset bit= iif(ContactInfo.bIsPowerOfAttorney IS 1, DE('Checked'), DE('Unchecked'))>
			<input type= "CheckBox" name= "bIsPowerOfAttorney" Value = "1" #Variables.bit#>	
		</td>
		
	</tr>
	
	<tr>
		<td style="Font-weight: bold;">Relationship</td>
		<td>
			<select name="iRelationshipType_ID">
			<cfloop query="relationships"> 
				<cfscript>
					if (IsDefined("ContactInfo.iRelationshipType_ID") and ContactInfo.iRelationshipType_ID eq RelationShips.iRelationshipType_ID){selected='selected';}
					else{selected='';}
				</cfscript>
				<option value="#RelationShips.iRelationshipType_ID#" #selected#> #RelationShips.cDescription# </option> 
			</cfloop>
			</select>
		</td>
		<td></td>
		<!--- Project 20125 modification.06/09/08 ssathya changed the wordings  --->
		<td style="Font-weight: bold;">	Does this Contact have the Power of Attorney for Health Care?	</td>
		<td style="text-align: center;">	
			<cfif ContactInfo.bIsMedicalProvider IS 1> <cfset bit="Checked"> <cfelse> <cfset bit="UnChecked"> </cfif>			
			<input type="CheckBox" name="bIsMedicalProvider" Value="1" #Variables.bit#>	</td>
	</tr>
	<!--- Project 36359 rts 8-06-2009  guarentor display change AR only--->
	<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
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
	<!--- end 36359 --->
	
	<!---Project 20125 modification.05/28/08 ssathya adding executor contact as a check box --->
	<tr>
		<td colspan="3" style="Font-weight: bold;">Is this Contact the Executor? 
			<cfset bit= iif(ContactInfo.bIsExecutorContact IS 1, DE('Checked'), DE('Unchecked'))>
			<input type= "CheckBox" name= "bIsExecutorContact" Value = "1" #Variables.bit#>	
		</td>
	</tr>
	  
	 <!--- Project 20125 modification.05/28/08 ssathya Primary care physician contact  --->
	 <tr>
	  <td colspan="3" style="Font-weight: bold;">Is this Contact the Primary Care Physician?
		
			<cfset bit= iif(ContactInfo.cPrimaryCarePhysicianContact IS 1, DE('Checked'), DE('Unchecked'))>
			<input type= "CheckBox" name= "cPrimaryCarePhysicianContact" Value = "1" #Variables.bit#>
		</td>
		
	</tr >
	 
	<tr>
		<td style="font-weight: bold;">	Address	Line 1</td>
		<td colspan="4"><input type="text" Name="cAddressLine1" value="#ContactInfo.cAddressLine1#" size="40" maxlength="40"></td>
	</tr>
	<tr>
		<td style="font-weight: bold;">	Address	Line 2</td>
		<td colspan="4"> <input type="text" Name="cAddressLine2" value="#ContactInfo.cAddressLine2#" size="40" maxlength="40">	</td>
	</tr>
	<tr>
		<td style="font-weight: bold;"> City </td>
		<td colspan="3">
			<input type="text" Name="cCity" value="#ContactInfo.cCity#" onKeyUp="this.value=ltrs(this.value)">
		</td>
	</tr>
	<tr>
		<td style="font-weight: bold;"> State </td>
		<td colspan="3">
			<select name="cStateCode">
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
		<td style="Font-weight: bold;"> Zip Code </td>
		<td colspan="3"> <input type="text" Name="cZipCode" value="#ContactInfo.cZipCode#" onKeyUp="this.value=LeadingZeroNumbers(this.value);"></td>
	</tr>
	<tr>
		<td style="Font-weight: bold;">	Home Phone	</td>
		<td colspan="3">
			<cfscript>
				areacode1 = left(ContactInfo.cPhoneNumber1,3); prefix1 = Mid(ContactInfo.cPhoneNumber1,4,3); number1 = right(ContactInfo.cPhoneNumber1,4);
			</cfscript>
			<input type="text" name="areacode1"	size="3" value="#Variables.areacode1#" maxlength="3" onKeyUp="this.value=LeadingZeroNumbers(this.value)"> -
			<input type="text" name="prefix1" size="3" value="#Variables.prefix1#" maxlength="3" onKeyUp="this.value=LeadingZeroNumbers(this.value)"> -
			<input type="text" name="number1" size="4" value="#Variables.number1#" maxlength="4" onKeyUp="this.value=LeadingZeroNumbers(this.value)">
			<input type="hidden" name="iPhoneType1_ID" value="1">
		</td>
	</tr>
	<tr>
		<td style="font-weight: bold;">	Message Phone	</td>
		<td colspan="3">
			<cfscript>
				areacode2 = left(ContactInfo.cPhoneNumber2,3); 
				prefix2 = mid(ContactInfo.cPhoneNumber2,4,3); 
				number2 = right(ContactInfo.cPhoneNumber2,4);
			</cfscript>
			<input type="text" name="areacode2"	size="3" value="#Variables.areacode2#" maxlength="3" onKeyUp="this.value=LeadingZeroNumbers(this.value)"> -
			<input type="text" name="prefix2" size="3" value="#Variables.prefix2#" maxlength="3" onKeyUp="this.value=LeadingZeroNumbers(this.value)"> -
			<input type="text" name="number2" size="4" value="#Variables.number2#" maxlength="4" onKeyUp="this.value=LeadingZeroNumbers(this.value)">
			<input type="hidden" name="iPhoneType2_ID"	value="5">
		</td>
	</tr>
	<tr>
		<td style="font-weight: bold;"> Email	</td>
		<td colspan="3">
			<input type="text" Name="cEmail" value="#ContactInfo.cEmail#" size="40" maxlength="70">
		</td>
	</tr>
	<tr>
		<td>Comments:</td>
		<td colspan="3"> 
		<textarea cols="50" rows="3" name="cComments">#trim(TenantInfo.TenantComments)#</textarea> 
		</td>
	</tr>
	<tr>	
		<td style="text-align: left;">
			<!--- Project 20125 modification. Ssathya added validation --->
			<input class="SaveButton" type="submit" name="Save" value="Save" onmouseover="return hardhaltvalidation(MoveInForm);" onfocus ="return hardhaltvalidation(MoveInForm);">
		</td>
		<td colspan="2"></td>
		<td style= "text-align: right;">
			<input class="DontSaveButton" type="button" name="DontSave" value="Don't Save" onClick="redirect()">
		</td>
	</tr>
	<tr><td colspan="4" style="font-weight: bold; color: red;">	<U>NOTE:</U> You must SAVE to keep information which you have entered!<br /> </td></tr>
</table>
</form>
</cfoutput>

<!--- Include Intranet Footer --->
<cfinclude template="../../Footer.cfm">