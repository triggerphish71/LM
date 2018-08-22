<!--- *********************************************************************************************************
Name:			TenantEdit.cfm
Process:		Edit Existing Tenant Information

Called by: 		MainMenu.cfm
Calls/Submits:	TenantUpdate.cfm

Modified By             Date            Reason
-------------------     -------------   --------------------------------------------------------------------------------
Craig Ebbott            09/20/2011      Reworked entire page                                                           |
 sfarmer             | 4/10/2012  |     Project 75019 - EFT Update/NRF Deferral.                                       |
 sfarmer             | 8/17/2012  |     Project 94541 - allow for deleting only the link related to contacts,          |
                     |            |     to allow for deletng duplicate contacts links but not the whole contact        |
  gthota             | 10/05/2012 |     project 93502 Was a Move In Check received checkbox code updated               |
 sfarmer             | 02-01-2013 |     99575 - adjusted postal (ZIP) codes for Canadian postal Codes                  |
 sfarmer             | 08/08/2013 |     project 106456 EFT Updates                                                     |
  sfarmer            | 11/27/2013 |     project 107887 Corrections to make Contact Name, Address, etc required if Payer|
 |sfarmer             | 12/10/2013 | 112478 - adjustments to Billing Information                                        |
|sfarmer             | 2017-05-09 | 'move out date' changed to 'physical move out date'                                |
|MStriegel           | 11/13/2017 | added the bundled pricing logic                                                    |
|MStriegel           | 05/14/2018 | Converted EFT Portion to a CFC                                                     |
******************************************************************************************************************* --->
<!--- Include Intranet Header --->
	<cfinclude template="../../header.cfm">

	<h1 class="PageTitle"> Tips 4 - Tenant Information Edit </h1>

	<cfinclude template="../Shared/HouseHeader.cfm">

	<!--- Retreive list of State Codes, PhoneType, and Tenant Information --->
	<cfinclude template="../Shared/Queries/StateCodes.cfm">
	<cfinclude template="../Shared/Queries/PhoneType.cfm">
	<cfinclude template="../Shared/Queries/TenantInformation.cfm">
	<cfinclude template="../Shared/Queries/SolomonKeyList.cfm">
	<cfinclude template="../Shared/Queries/Relation.cfm">

	<cfparam name="alliswell" default="0">
	<cfparam default="" name="CID">
	<cfparam  name="totalpercent" default="0">
	<cfparam  name="nbrpercent" default="0">
	<cfparam  name="totalpymnt" default="0">
	<cfparam  name="adjInvTotal" default="0">
	<cfparam  name="eftcount" default="0">
	<cfparam  name="primpayer" default="0">
	<cfparam  name="Emailcount" default="0">
	<cfparam  name="totalmisc" default="0">
	<cfparam name="totpayment" default="0">
	<cfparam  name="eachpercent" default="0">
	<cfparam  name="netpercent" default="0">
	<cfparam name="AcctPeriod" default="#SESSION.TIPSMonth#">
	<cfset AcctPeriod = dateformat(AcctPeriod ,'yyyymm')>
	<cfset eftpulmonth = dateadd('m', -1,  #session.TIPSMonth#) >
	<cfset thisdate = dateformat(eftpulmonth, 'YYYYMM')>


	<!--- Retrieve all valid service level sets --->
	<cfquery name="Levels" DATASOURCE="#APPLICATION.datasource#">
		select distinct cSLevelTypeSet from SLevelType WITH (NOLOCK) where dtRowDeleted is null
	</cfquery>

	<!--- Retrieve all valid diagnosis types --->
	<cfquery name="qDiagnosisType" DATASOURCE="#Application.datasource#">
		select idiagnosistype_id, cdescription from diagnosistype WITH (NOLOCK) where dtrowdeleted is null
	</cfquery>

	<!--- retrieve house product line info --->
	<cfquery name="qproductline" datasource="#application.datasource#">
		select pl.iproductline_id, pl.cdescription
		from houseproductline hpl WITH (NOLOCK)
		inner join productline pl WITH (NOLOCK) on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
		where hpl.dtrowdeleted is null and hpl.ihouse_id = #session.qselectedhouse.ihouse_id#
	</cfquery>

	<!---MShah-residency type edit--->
	<cfquery name="HouseDetail" datasource = "#APPLICATION.datasource#">
		select st.bIsMedicaid StateMedicaid
		, h.bIsMedicaid HouseMedicaid
		from House h WITH (NOLOCK)
		join statecode st WITH (NOLOCK) on h.cstatecode = st.cstatecode
		where h.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
		and h.dtrowdeleted is null
	 </cfquery>
	<cfquery name="qresidencytype" datasource="#application.datasource#">
		select rt.iresidencytype_id ,rt.cdescription <!---,pl.iproductline_id ,plrt.iproductlineresidencytype_id--->
		from houseproductline hpl WITH (NOLOCK)
		INNER join productline pl WITH (NOLOCK) on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
		INNER join ProductLineResidencyType plrt WITH (NOLOCK) on plrt.iproductline_id = pl.iproductline_id and plrt.dtrowdeleted is null
		INNER join residencytype rt  WITH (NOLOCK) on rt.iresidencytype_id = plrt.iresidencytype_id and rt.dtrowdeleted is null
		where hpl.dtrowdeleted is null and hpl.ihouse_id = #session.qselectedhouse.ihouse_id# and hpl.iproductline_id=1
		<cfif #HouseDetail.StateMedicaid# eq 1 and #HouseDetail.HouseMedicaid#  eq 1>
		and rt.iresidencytype_id in (1,2)
		<cfelse>
		and rt.iresidencytype_id in (1)
		</cfif>
	</cfquery>
	<!---end--->


	<!--- Used to see if any contacts are marked as payers --->
	<cfquery name="CountPayingContacts" DATASOURCE="#APPLICATION.datasource#">
		Select iLinkTenantContact_id
		from LinkTenantContact WITH (NOLOCK)
		Where iTenant_ID = #url.ID#
		and bIsPayer = 1
		and dtRowDeleted is null
	</cfquery>

	<!--- If a a contact is being shown, see if it is marked as the payer --->
	<cfquery name="CurrentContactPayer" DATASOURCE="#APPLICATION.datasource#">
		Select iLinkTenantContact_id
		from LinkTenantContact WITH (NOLOCK)
 		Where iTenant_ID = #url.ID#
		and bIsPayer = 1
		and dtRowDeleted is null
		and iContact_ID = <cfif isdefined("url.CID")> #url.CID# <cfelse> -1 </cfif>
	</cfquery>
	<cfquery name="CurrentGuarantor" DATASOURCE="#APPLICATION.datasource#">
		Select iLinkTenantContact_id
		from LinkTenantContact WITH (NOLOCK)
 		Where iTenant_ID = #url.ID#
		and bIsGuarantorAgreement = 1
		and dtRowDeleted is null
	</cfquery>
	<!--- Get Tenant's EFT Information If they are EFT --->
	<cfif TenantInfo.bUsesEFT NEQ "">
		<cfquery name="EFTDetail" datasource="#application.datasource#">
			Select cRoutingNumber, cAccountNumber, cAccountType
			From EFTAccount WITH (NOLOCK)
			where cSolomonKey = '#TenantInfo.cSolomonKey#'
		</cfquery>
	</cfif>

	<!--- Retrieve Any KeyChange Information for this Tenant  --->
	<cfquery name="KeyChanges" DATASOURCE="#APPLICATION.datasource#">
		select PT.cSolomonKey, PT.dtRowStart, PT.dtRowEnd
		from Tenant T WITH (NOLOCK)
		inner join P_Tenant PT WITH (NOLOCK) on T.iTenant_ID = PT.iTenant_ID
		where T.iTenant_ID = #url.ID# and PT.cSolomonKey <> '#TenantInfo.cSolomonKey#'
		and PT.dtRowEnd = ( SELECT Max(PT.dtRowEnd) from Tenant T JOIN P_Tenant PT on T.iTenant_ID = PT.iTenant_ID
		where T.iTenant_ID = #url.ID# AND PT.cSolomonKey <> '#TenantInfo.cSolomonKey#' )
	</cfquery>

	<cfquery name="getOccupancyRestrictionforPromotion" datasource="#application.datasource#">
		EXEC rw.sp_GetOccupancyRestrictedPromotionForHouse #session.qselectedhouse.ihouse_id#
	</cfquery>

	<cfif getOccupancyRestrictionforPromotion.CurrentApartmentOfferedWithPromotion gt 0>
		<cfquery name="qTenantPromotion" datasource="#Application.datasource#">
			Select iPromotion_ID, cDescription
			From TenantPromotionSet WITH (NOLOCK)
			where dtrowdeleted is null
			order by cdescription
		</cfquery>
	<cfelse>
		<cfquery name="qTenantPromotion" datasource="#Application.datasource#">
			SELECT iPromotion_ID, cDescription
			FROM TenantPromotionSet WITH (NOLOCK)
			WHERE (bIsHouseOccupancyRestricted = 0 or bIsHouseOccupancyRestricted is null)
			AND dtrowdeleted is null
			order by cdescription
		</cfquery>
	</cfif>

	<cfquery name="ExistingTenantPromotion" datasource="#Application.datasource#">
		Select bIsHouseOccupancyRestricted, cDescription, iPromotion_id
		from Tenantstate ts WITH (NOLOCK)
		left join TenantPromotionSet tps WITH (NOLOCK) on ts.cTenantPromotion = tps.iPromotion_id
		where iTenant_id = #URL.ID#
		and ts.dtrowdeleted is null
	</cfquery>

	<!--- Retrieve the house address information --->
	<cfquery name="House" DATASOURCE="#APPLICATION.datasource#">
		select cPhoneNumber1, iPhoneType1_ID, cPhoneNumber2, iPhoneType2_ID, cPhoneNumber3, iPhoneType3_ID,
				cAddressLine1, cAddressLine2, cCity, cStateCode, cZipCode
		from House WITH (NOLOCK)
		where dtrowdeleted is null and iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</cfquery>

	<cfquery name="Contact" DATASOURCE="#APPLICATION.datasource#">
		select C.*, RT.cDescription as Relation,LTC.iLinkTenantContact_ID,LTC.bIsExecutorContact, LTC.bIsPayer, LTC.bIsPowerOfAttorney,
		LTC.bIsMedicalProvider, LTC.iRelationShipType_ID, LTC.bIsGuarantorAgreement, LTC.bIsEFT, LTC.bIsMoveOutPayer
		from LinkTenantContact LTC WITH (NOLOCK)
		inner join Contact C WITH (NOLOCK) on C.iContact_ID = LTC.iContact_ID
		left join RelationShipType RT WITH (NOLOCK) on LTC.iRelationShipType_ID = RT.iRelationShipType_ID
		where
		<cfif IsDefined("URL.CID")>
			C.iContact_ID = #url.CID#
			<cfif IsDefined("URL.LNK")>
				and ltC.iLinktenantContact_ID = #url.Lnk# <!---Mshah--->
			</cfif>
		<cfelse>
			LTC.iTenant_ID = #url.ID#
		</cfif>
		and C.dtRowDeleted is null and LTC.dtRowDeleted is null
		order by LTC.bIsPayer, C.cLastName
	</cfquery>
	<cfquery name="getAmt"  datasource="#application.datasource#">
		 select	  isNULL(Sum(iQuantity * mAmount),0) as 'InvoiceTotal'
		from Tenant tn WITH (NOLOCK)
		inner join TenantState tns WITH (NOLOCK)  on (tns.iTenant_ID = tn.iTenant_ID and tns.dtRowDeleted is null and tns.iTenantStateCode_ID = 2)
		and tn.iHouse_ID = #session.qselectedhouse.ihouse_id#
		inner join InvoiceMaster IM WITH (NOLOCK)  on im.csolomonkey = tn.csolomonkey and IM.dtRowDeleted is null
		and IM.bFinalized = 1 and IM.cAppliesToAcctPeriod = '#thisdate#'
		and IM.bMoveInInvoice is null and IM.bMoveOutInvoice is null
		left join InvoiceDetail INV WITH (NOLOCK) on INV.iinvoicemaster_id = im.iinvoicemaster_id and INV.dtRowDeleted is null
		inner join ChargeType CT WITH (NOLOCK) on INV.iChargeType_ID = Ct.iChargeType_ID and Ct.dtRowDeleted is null
		and Ct.cGLAccount <> 3012 and Ct.cGLAccount <> 3016
		inner join AptAddress AD WITH (NOLOCK)  on ad.iAptAddress_ID = tns.iAptAddress_ID and ad.dtRowDeleted is null
		where tn.cSolomonKey = '#TenantInfo.cSolomonKey#'
	</cfquery>

	<CFQUERY NAME="GetNRF" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*
		from InvoiceMaster IM WITH (NOLOCK)
		join InvoiceDetail inv WITH (NOLOCK) on im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID and inv.dtRowDeleted is null
		and IM.dtRowDeleted is null	and IM.bMoveInInvoice is not null and IM.bMoveOutInvoice is null
		and IM.cSolomonKey = '#TenantInfo.cSolomonKey#'
		INNER JOIN	ChargeType CT WITH (NOLOCK)	ON CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL AND CT.iChargeType_ID  = 1740
		LEFT JOIN	Tenant T WITH (NOLOCK)	ON T.iTenant_ID = INV.iTenant_ID AND T.dtRowDeleted IS NULL
		join tenantstate ts WITH (NOLOCK) on t.itenant_ID = ts.itenant_id
		ORDER BY	INV.iTenant_ID DESC, INV.cAppliesToAcctPeriod
	</CFQUERY>
<cfif tenantinfo.iresidencytype_id is 2>
	<cfif tenantinfo.iMCOProvider is not ''>
		<cfquery name="qryMedicaidProvider" DATASOURCE="#APPLICATION.datasource#">
		SELECT  iMCOProvider_ID
			  ,cMCOProvider
			  ,iMCO_ID
			  ,cStateCode
			  ,dtRowStart
			  ,iRowStartUser_ID
			  ,dtRowEnd
			  ,iRowEndUser_ID
			  ,dtRowDeleted
			  ,iRowDeletedUser_id
			  ,cRowStartUser_id
			  ,cRowEndUser_ID
			  ,cRowDeletedUser_ID
			  ,dtEffectiveStart
			  ,dtEffectiveEnd
		  FROM  MCOProvider WITH (NOLOCK)
		  where iMCOProvider_ID = #tenantinfo.iMCOProvider#
		</cfquery>
	</cfif>
<cfquery name="qryMCO" DATASOURCE="#APPLICATION.datasource#">
SELECT   [iMCOProvider_ID]
      ,[cMCOProvider]
      ,[iMCO_ID]
      ,[cStateCode]
      ,[dtRowStart]
      ,[iRowStartUser_ID]
      ,[dtRowEnd]
      ,[iRowEndUser_ID]
      ,[dtRowDeleted]
      ,[iRowDeletedUser_id]
      ,[cRowStartUser_id]
      ,[cRowEndUser_ID]
      ,[cRowDeletedUser_ID]
      ,[dtEffectiveStart]
      ,[dtEffectiveEnd]
  FROM [TIPS4].[dbo].[MCOProvider] WITH (NOLOCK)
  where dtrowdeleted is null
</cfquery>
</cfif>
<!---Mshah added for close item--->
<cfquery NAME="CheckContactPayer" DATASOURCE="#APPLICATION.datasource#" >
	select * from LinkTenantContact LTC WITH (NOLOCK)
	inner join Contact C WITH (NOLOCK) on C.iContact_ID = LTC.iContact_ID
	where
	LTC.iTenant_ID = #url.ID#
	<!---<cfif structKeyExists(url, 'CID') and trim(url.CID) neq "" >and c.icontact_ID <> #url.CID# </cfif>--->
	<cfif structKeyExists(url, 'LNK') and trim(url.LNK) neq "" >and ltc.ilinktenantcontact_ID <> #url.LNK# </cfif>
	and ltc.bispayer=1
	and C.dtRowDeleted is null and LTC.dtRowDeleted is null
	order by LTC.bIsPayer, C.cLastName
</cfquery>

<!---Mshah end--->
	<script language="JavaScript" src="../Shared/JavaScript/global.js" type="text/javascript"></script>
	<!---<script language="JavaScript" src="../../../cfide/scripts/wddx.js" type="text/javascript"></script>--->
<script language="JavaScript"  type="text/javascript">
	function initial() {
		df0=document.forms[0];
		dm0=document.all['Message'];
		oLayer=document.getElementById("layerOne");
	//	<cfif isDefined("session.CodeBlock") and ListFindNoCase(session.CodeBlock,25) GT 0>
	//		showText();
	//	</cfif>
		ShowHideVA();
		prodsel=document.getElementById("iproductline_id");

		<cfif IsDefined("URL.Debug") AND URL.Debug IS 1>
			dm0.innerHTML='Save Data Completed.';
		<cfelseif IsDefined("URL.Debug") AND URL.Debug IS 2>
			dm0.innerHTML='Cancel (Do Not Save) Completed.';
		</cfif>

		<cfif tenantinfo.iproductline_id neq "">
			<cfoutput>prodsel.value=#trim(tenantinfo.iproductline_id)#;</cfoutput>
		</cfif>
	}

	function newcontactdata(){
		if (df0.ContactFirstName.value !== '' || document.forms[0].ContactLastName.value !== '') {
			if(confirm('CAUTION: The above information will not be saved. Are you sure?')){ return true;}
			else { return false; }
		}
	}
function hasexecutor()
	{
		var executor = false;
		for(i=0; i < document.getElementById('chasExecutor').length; i++)
		{
			if(document.getElementById('chasExecutor')[i].checked)
			{
				executor = true;
			}
		}
		 if(executor = false)
		{
			document.getElementById('chasExecutor').focus();
			alert("Please make Executor selection");
			failed = true;
		}
	}


	function required() {
		var failed = false;
	hasexecutor();

	if  ( df0.ContactbIsPayer.checked == true)
//		alert ('ok');
{if ( document.getElementById('ContactFirstName').value == '' ||  document.getElementById('ContactLastName').value == '')
{alert('Please Enter Contact Name and Contact Address, fields are Required');
failed = true;
}

	else if ( document.getElementById('ContactAddressLine1').value == ''
// ||  document.getElementById('ContactAddressLine2').value == ''
 ||  document.getElementById('ContactCity').value == ''
 ||  document.getElementById('ContactStateCode').value == ''
 ||  document.getElementById('ContactZipCode').value == ''
)
{alert('Please Enter Contact Street Address, CIty, State and Postal Code fields are Required');
	failed = true;
}

}
//Mshah added here for close item
	if  ( df0.ContactbIsPayer.checked == true)
	{	//alert ('ok');
	     //alert ('test');
		contactID ="";
		//alert(contactID);
		//alert ('test2');
		contactID= '<cfoutput> #CheckContactPayer.recordcount# </cfoutput>';
		if (contactID > 0 ){
		alert('There is already a payer for this resident');
		df0.ContactbIsPayer.checked = false ;
		failed = true;
		}
	}
 		//Mshah end

		if (df0.cFirstName.value.length < 2){
			df0.cFirstName.focus();
		//	dm0.innerHTML = "Please Enter or Check First Name";
			alert('Please Enter or Check First Name');
			failed = true;
		}

		if (df0.cLastName.value.length < 2){
			df0.cLastName.focus();
		//	dm0.innerHTML = "Please Enter or Check Last Name";
			alert('Please Enter or Check Last Name');
			failed = true;
		}

		if  (document.getElementById('cPreviousAddressLine1').value == '') {
			 document.getElementById('cPreviousAddressLine1').focus();
		 //	dm0.innerHTML = "Please Enter Previous Address of Tenant";
			alert('Please Enter Previous Street Address of Tenant');
			failed = true;
		}

		if  (document.getElementById('cPreviousCity').value == '') {
			 document.getElementById('cPreviousCity').focus();
		//	dm0.innerHTML = "Please Enter Previous City of Tenant";
			alert('Please Enter Previous City of Tenant');
			failed = true;
		}
		if  (document.getElementById('cPreviouszipCode').value == '')  {
			 document.getElementById('cPreviouszipCode').focus();
		//	dm0.innerHTML = "Please Enter Previous State of Tenant";
			alert('Please Enter Previous Postal Code');
			failed = true;
		}

		if ( failed == 'true')
			{return false;}
			else { return true;	}

	}

	function showText(){
			if( df0.checkbox1.checked)
				{document.getElementById('eftDIV').style.visibility = 'visible';
				document.getElementById('eftDIV').style.height = '125px';
				document.getElementById('eftcell').style.height = "125px"}
			else
				{document.getElementById('eftDIV').style.visibility = 'hidden';
				document.getElementById('eftDIV').style.height = '5px';
				document.getElementById('eftDIV').style.overflow = 'hidden';
				document.getElementById('eftcell').style.height = "5px"}
		}

	window.onload=initial;

	function ClearBondDate(){
		TenantEdit.txtBondReCertDate.value = '';
	}

	function ShowHideVA(){
		if (document.getElementById("CheckVA").value=="1"){
			document.getElementById("VA").style.display='block'; //show other options
			document.getElementById("VA1").style.display='block';
			document.getElementById("VA2").style.display='block';
			document.getElementById("VA3").style.display='block';
		}
		else{
			document.getElementById("VA").style.display='none'; //hide other options
			document.getElementById("VA1").style.display='none';
			document.getElementById("VA2").style.display='none';
			document.getElementById("VA3").style.display='none';
		}
	}
	function callsetupeft(){
		tenantID = document.getElementById('iTenant_ID').value;
		SolomonKey = document.getElementById('tenantSolomonKey').value;
		valdata =   'ID=' + document.getElementById('iTenant_ID').value + '&tenantSolomonKey=' + document.getElementById('tenantSolomonKey').value ;
		newlocation = 'TenantEFTEdit.cfm?' + valdata;
		window.location =  newlocation   ;
	}
	function callsetupeftcontact(){
		tenantID = document.getElementById('iTenant_ID').value;
		SolomonKey = document.getElementById('tenantSolomonKey').value;
		contactID = document.getElementById('iContact_ID').value;
		valdata =   'ID=' + document.getElementById('iTenant_ID').value + '&tenantSolomonKey=' + document.getElementById('tenantSolomonKey').value  + '&CID=' + document.getElementById('iContact_ID').value  ;
		newlocation = 'TenantEFTEdit.cfm?' + valdata;
		window.location =  newlocation   ;
	}


	function updateHiddenField(val){
		isChecked = document.getElementById("bMoveInSummary").checked;
		if(isChecked == false){
			document.getElementById("bMoveInSummaryHidden").value = 0;
		}
		else{
			document.getElementById("bMoveInSummaryHidden").value = 1;
		}
	}

</script>

<form name="TenantEdit" action="TenantEdit.cfm" method="POST" onsubmit="return hasexecutor(); required();">

<table>
<cfoutput>
 	<input type="hidden" name="bMoveInSummaryHidden" id="bMoveInSummaryHidden" value="#tenantInfo.bMoveInSummary#">
	<input type="hidden"  name="tenantSolomonKey" id="tenantSolomonKey" value="#TenantInfo.cSolomonKey#">
	<input type="hidden"  name="userid" 		 id="userid" 			value="#session.UserID#">
	<input type="Hidden"  name= "iTenant_ID"             				value="#TenantInfo.iTenant_ID#">
	<tr>
		<td colspan="4" id="Message" style="background:white;color:red;text-align:center;font-weight:bold;font-size:x-small;">
			Required are listed in red.
		</td>
	</tr>
	<tr>
		<th colspan="4"> Edit Tenant Information </th>
	</tr>
	<cfif IsDefined("KeyChanges.RecordCount") AND KeyChanges.RecordCount GT 0>
		<tr>
			<td colspan=4 style="font-size: 16; font-weight: bold;">
				<U>NOTE</U>: This Tenants Solomon Key changed from #KeyChanges.cSolomonKey#
				to #TenantInfo.cSolomonKey# on #DateFormat(KeyChanges.dtRowEnd,"mm/dd/yyyy")#
			</td>
		</tr>
	</cfif>
	<tr>
		<td style="text-align: left;">
			<input class="SaveButton" type="button" name="Save" Value="Save" onMouseDown="required();"
			onClick="document.TenantEdit.action='TenantUpdate.cfm';submit();">
		</td>
		<td colspan=2></td>
		<td>
			<cfscript>
				if (IsDefined("url.cid") AND url.cid EQ 0) { Script="newcontactdata();"; }
				else { Script=''; }
			</cfscript>
			<input class="DontSaveButton" type="button" name="DontSave" value="Don't Save" onClick="#SCRIPT# location.href='TenantEdit.cfm?ID=#url.ID#&Debug=2'">
		</td>
	</tr>
	<tr>
		<td style="width: 23%;" class="required" colspan="4">
			First Name <input type="text" name="cFirstName" value="#TenantInfo.cFirstName#" onkeyup="this.value=ltrs(this.value)" onblur="upperCase(this);" size="15">
			MI <input type="text" name="cMiddleInitial" value="#TenantInfo.cMiddleInitial#" onkeyup="this.value=ltrs(this.value);" onblur="upperCase(this);" size="1" maxlength="1">
			Last Name <input type="text" name="cLastName" value="#TenantInfo.cLastName#" onkeyup="this.value=ltrs(this.value);" onblur="upperCase(this);"  size="15">
			<!---<cfif ListFindNoCase(SESSION.CodeBlock,23) GT 0>--->
			<cfif (ListContains(session.groupid,'285') gt 0)>
				<input type="Button" name="Addendum" value="Move In Addendum" style="width: 150;"
				onClick="location.href='MoveInAddendum.cfm?ID=#TenantInfo.iTenant_ID#'">
			</cfif>
		</td>
	</tr>
	<tr>
		<td>Resident ID: #tenantinfo.csolomonkey#</td>
	</tr>
	<TR><TD colspan="2"><strong>PREVIOUS ADDRESS</strong></TD></TR>
	<tr>
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Address Line 1</td>
		<td colspan="2"><input type="text" name="cPreviousAddressLine1"  id="cPreviousAddressLine1" value="#TenantInfo.cPreviousAddressLine1#" SIZE="40"
       					 maxlength="40" onblur="upperCase(this);">
        </td>
	</tr>
	<tr>
		<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Address Line 2</td>
		<td colspan="2"><input type="text" name="cPreviousAddressLine2"  id="cPreviousAddressLine2"  value="#TenantInfo.cPreviousAddressLine2#" SIZE="40"
        				maxlength="40" onblur="upperCase(this);">
       </td>
	</tr>
	<tr>
		<td colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;City
			<input type="text" name="cPreviousCity"  id="cPreviousCity"  value="#TenantInfo.cPreviousCity#"
            onkeypress="return allowOnlyLettersOnKey(event);" onblur="upperCase(this);">

			State
			<select name= "cPreviousState"  id="cPreviousState"  onBlur= "required();">
				<cfscript>
					if (TenantInfo.cPreviousState NEQ "")
						{ cPreviousState=TenantInfo.cPreviousState; }
					else
						{ cPreviousState=House.cStateCode; }
				</cfscript>

				<option value=""> None </option>
				<cfloop Query = "StateCodes">
					<cfscript>
						if (Variables.cPreviousState EQ cStateCode)
							{ Selected = 'Selected'; }
						else
							{ Selected = ''; }
					</cfscript>
					<option value="#cStateCode#" #Selected#> #cStateName# - #cStateCode# </option>
				</cfloop>
			</select>

			Zip (Postal) Code
			<input  type="text" name="cPreviouszipCode" id="cPreviouszipCode" value="#TenantInfo.cPreviouszipCode#" size="10" maxlength="10"  onblur="maskZIP(this);"  >
		</td>
	</tr>

	<tr>
		<td> Product line </td>
		<td>
		<!--- Ganga 04/23  restricting to all user only AR team can edit --->
		<cfquery name="TenantProductline" dbtype="query">
		  select iProductLine_id,cdescription from qproductline  where  iProductLine_id = #tenantinfo.iProductLine_id#
		</cfquery>

		<select id="iproductline_id" name="iproductline_id">

		<cfif (ListContains(session.groupid,'192') gt 0)>
		<cfloop query= "qproductline">
			<option value= "#qproductline.iproductline_id#" <cfif TenantProductline.iproductline_id EQ qProductline.iProductline_id>SELECTED</cfif>>#qproductline.cDescription#	</option>
		</cfloop>
		<Cfelse>
		  <option value= "#TenantProductline.iproductline_id#" <cfif TenantProductline.iproductline_id EQ qProductline.iProductline_id>SELECTED</cfif>>#TenantProductline.cDescription#	</option>
		</cfif>
		</select>
		</td>
	</tr>

	<tr>
		<td> Residency Type </td>
		<!---mshah test start---><td>
		<select id="iResidencytyps_id" name="iresidencytype_id">
			<option value="#tenantinfo.iResidencytype_id#" selected="selected"> #tenantinfo.Residency# </option>
		<!--- Added this to give AR authority to change the residency type--->
		<cfif (ListContains(session.groupid,'192') gt 0)>
			<cfloop query= "qresidencytype">
				<option value= "#qresidencytype.iResidencytype_id#"> #qresidencytype.cdescription#	</option>
			</cfloop>
		</cfif>
		</select>
		</td>
	</tr>

	<cfif TenantInfo.iResidencyType_ID EQ 3>
		<tr>
			<td style="color:red;">Projected Physical Move Out Date</td>
			<td>#DateFormat(TenantInfo.dtmoveoutprojecteddate,"mm/dd/yyyy")#</td>
		</tr>
	</cfif>

	<!--- Retrieve Optional state care level Options --->
	<cfquery name="qCareLevel" DATASOURCE="#APPLICATION.datasource#">
		select iOptionalFieldValue_ID, cValue
		from optionalfield o WITH (NOLOCK)
		join optionalfieldvalue v WITH (NOLOCK) on o.iOptionalField_ID = v.iOptionalField_ID
		and v.dtRowDeleted is null and v.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		where o.dtRowDeleted is null and o.cTablename = 'TenantState' and o.cFieldName = 'iStateDefinedCareLevel'
	</cfquery>

	<cfif qCareLevel.RecordCount GT 0>
		<tr>
			<td> State Defined Care Level </td>
			<td><select name="iStateDefinedCareLevel">
					<option value=''> None </option>
					<cfloop query= "qCareLevel">
						<cfif TenantInfo.iStateDefinedCareLevel eq qCareLevel.iOptionalFieldValue_ID> <cfset Selected = 'Selected'>
						<cfelse> <cfset Selected = ''> </cfif>
						<option value= "#qCareLevel.iOptionalFieldValue_ID#" #Selected#>	#qCareLevel.cValue#	</option>
					</cfloop>
				</select>
			</td>
			<td colspan="2"></td>
		</tr>
	</cfif>

	<tr>
		<td> Primary Diagnosis </td>
		<td><select name="PrimaryDiagnosis">
				<option value=''> None </option>
				<cfloop query="qDiagnosisType">
					<cfscript>
					if  (TenantInfo.iPrimaryDiagnosis EQ qDiagnosisType.iDiagnosisType_ID) { Selected = 'Selected'; }
					else { Selected = ''; }
					</cfscript>
					<option value="#qDiagnosisType.iDiagnosisType_ID#" #Selected#> #qDiagnosisType.cDescription# </option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td> Secondary Diagnosis </td>
		<td><select name="SecondaryDiagnosis">
				<option value=''> None </option>
				<cfloop query="qDiagnosisType">
					<cfscript>
						if  (TenantInfo.iSecondaryDiagnosis EQ qDiagnosisType.iDiagnosisType_ID) { Selected = 'Selected'; }
						else { Selected = ''; }
					</cfscript>
					<option value="#qDiagnosisType.iDiagnosisType_ID#" #Selected#> #qDiagnosisType.cDescription# </option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td> SSN </td>
		<td>
        	<input type="text" name="cSSN" value="#Tenantinfo.cSSN#" size="8" maxlength="11"
            onblur="maskSSN(this);" onkeypress="return allowOnlyNumberOnKey(event)" />
        </td>
	</tr>
	<tr>
		<td> Birthdate </td>
		<td><input type="text" Name="dbirthdate" value = "#DateFormat(TenantInfo.dbirthdate,"mm/dd/yyyy")#" size="6" maxlength="10">
			<b style="color:red;">(MM/DD/YYYY)</b></td>
	</tr>

	<Cfif CurrentGuarantor.recordcount gt 0>
	<tr style="color:red; font-weight:bold">
		<td nowrap="nowrap">A Contact is the Guarantor and will recieve all Invoice Notices.</td>
	</tr>
	<cfelse>
	<tr style="color:red; font-weight:bold">
		<td nowrap="nowrap">The Tenant will recieve all Invoice Notices.</td>
	</tr>
	</Cfif>
	<tr style="font-weight: bold;">

		<input type="hidden" name="ContactPayers" value="#CountPayingContacts.Recordcount#" />
		<input type="hidden" name="CurrentContactPayer" value="#CurrentContactPayer.Recordcount#" />
			<cfif TenantInfo.bIsPayer EQ 1>
				<cfset Checked='Checked'>
			<cfelse>
				<cfset Checked=''>
				<td> Is this Tenant also a Payor?	</td>
				<td> If Yes, Click Here --><input type= "checkbox" name="bIsPayer" value="1" #CHECKED# onClick="required();"></td>	<!---Mshah changed value here--->
			</cfif>

	</tr>
	<tr style="font-weight: bold;">
				<td  nowrap="nowrap"> To Remove as Payor, </td><input type= "hidden" name="bIsPayer" value="" /> <!---Mshah added here--->
				<td nowrap="nowrap">Click Here --><input type= "checkbox" name="bDropIsPayer"   value="X" >( If applicable; this will also cancel any EFT)</td>
		</tr>

<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>

	 <tr>
		<td style="font-weight: bold;"> Promotion Used </td>

 	<cfif (getOccupancyRestrictionforPromotion.CurrentApartmentOfferedWithPromotion gte 0) and (ExistingTenantPromotion.bIsHouseOccupancyRestricted neq 1)
 		or (getOccupancyRestrictionforPromotion.CurrentApartmentOfferedWithPromotion gt 0) and (ExistingTenantPromotion.bIsHouseOccupancyRestricted eq 1)>

		<td>
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
	<cfelseif (getOccupancyRestrictionforPromotion.CurrentApartmentOfferedWithPromotion eq 0) and (ExistingTenantPromotion.bIsHouseOccupancyRestricted eq 1)>
		<td>
			<input type="text" size="45" disabled="disabled" value="#ExistingTenantPromotion.cDescription#">
			<input type="hidden" name="PromotionUsed" value="#ExistingTenantPromotion.iPromotion_id#">
		</td>
	</cfif>
	</tr>

    <tr>
        <td colspan="2" style="Font-weight: bold;"> Was a Move In Check received?
		  <cfset bit= iif(TenantInfo.bMICheckReceived IS 1, DE('Checked'), DE('Unchecked'))>
		    #TenantInfo.dtMICheckReceived#<input type= "CheckBox" name= "cMICheckReceived" Value = "1" #Variables.bit#>
	        </td>
    </tr>
	<tr>
		<td colspan="2" style="Font-weight: bold;"> Has the resident signed the Residency Agreement?
		<cfset bit= iif(TenantInfo.cResidenceAgreement IS 1, DE('Checked'), DE('Unchecked'))>
			<input type= "CheckBox" name= "cResidenceAgreement" Value = "1" #Variables.bit#>
		</td>
	</tr>
	<tr>
		<td colspan="2" style="Font-weight: bold;"> Month Residency Agreement recieved:
			<cfset SelectFlag = ''>
			<select name="cMonthRASigned">
				<option value="" selected></option>
				<cfif 'Prior' eq TenantInfo.cMonthRASigned>
					<cfset SelectFlag = 'Selected'>
				</cfif>
				<cfoutput>
                	<option value="Prior" #SelectFlag#>Prior</option>
                </cfoutput>
				<cfset variables.YearMonth = CreateDate(2011,10,01)>
				<cfloop condition="YearMonth LTE now()">
                	<cfset SelectFlag = ''>
					<cfoutput>
						<cfif DateFormat(Variables.YearMonth,"MMM YYYY") eq TenantInfo.cMonthRASigned>
							<cfset SelectFlag = 'Selected'>
						</cfif>
						<option value='#DateFormat(Variables.YearMonth,"MMM YYYY")#' #SelectFlag#>#DateFormat(Variables.YearMonth,"MMM YYYY")#</option>
					</cfoutput>
					<cfset variables.YearMonth = DateAdd("M",1,Variables.YearMonth)>
				</cfloop>
			</select>
		</td>
	</tr>

	<tr>
		<td colspan="4" style="Font-weight: bold;">Recieved the signed Resident Move-In Summary?
		<cfset bit= iif(TenantInfo.bMoveInSummary IS 1, DE('Checked'), DE('Unchecked'))>
			<input type= "CheckBox" id="bMoveInSummary" name= "bMoveInSummary" Value = "1" #Variables.bit# onClick="updateHiddenField(this.value);">
		</td>
	</tr>
	<tr>
		<td colspan="4" style="Font-weight: bold;">New Resident Fee Paid?
		<cfif TenantInfo.cResidentFee IS 1>Yes<cfelse>No</cfif>
			<!--- <input type= "CheckBox" name= "cResidentFee" Value = "1" #Variables.bit#> --->
			<br />New Resident Fee waivers are processed as a discount on the move in page.
		</td>
	</tr>

	 </cfif>

	 <tr>
	<td colspan="3" style="font-weight: bold;">Does this resident have an Executor of Estate? &nbsp;&nbsp; Yes

		<cfset Checked =''>
		<cfset Checked1 =''>
		<cfif TenantInfo.chasExecutor eq 1>
			<cfset Checked ='Checked'>
		<cfelseif TenantInfo.chasExecutor eq 0 >
			<cfset Checked1 ='Checked'>
		</cfif>

		<input name="chasExecutor"  id="chasExecutor" type="radio" value="1" #Checked#>  No
	    <input name="chasExecutor"  id="chasExecutor" type="radio" value="0" #Checked1#> </td>
	</tr>

	<cfquery name="bondhouse" datasource="#application.datasource#">
		select ibondhouse from house  where ihouse_id =  #session.qSelectedHouse.iHouse_ID#
	</cfquery>
	<input type="hidden" name="bondval" value="#bondhouse.ibondhouse#">
		  <cfset Checked =''>
		  <cfset Checked1 =''>
	<cfif bondhouse.ibondhouse eq 1>
		<tr>
		<cfif TenantInfo.bIsbond eq 1>
			<cfset Checked ='Checked'>
		<cfelseif TenantInfo.bIsbond eq 0 >
			<cfset Checked1 ='Checked'>
		<cfelse>
		 	<cfset Checked =''>
		  	<cfset Checked1 =''>
		</cfif>
		<tr>
			 <td colspan="4" style="Font-weight: bold;">Did the resident re-qualify as eligible for meeting the Bond program occupany requirements?
				 Yes<input type="radio" name="cBondTenant" value="1" onclick="ClearBondDate();" #Checked#>
				 No<input type="radio"  name="cBondTenant" value="0"
				   onclick="ClearBondDate();alert('This tenant is now Non-Bond. \nPlease call your Bond Administrator.');" #Checked1#>

			</td>
		</tr>
		<tr>
			<td colspan="4" style="Font-weight: bold;">Date the income certification or re-certification was faxed or emailed to the Corporate Office:
				<input type="textbox" name="txtBondReCertDate" value="#DateFormat(TenantInfo.dtBondCert,"mm/dd/yyyy")#" size="8" >
				<span style="font-weight: normal;color: red;">(mm/dd/yyyy)</span>
			</td>
		</tr>
	</tr>
	<cfif (ListContains(session.groupid,'284') gt 0)>
		<tr>
			<td colspan="4" style="Font-weight: bold;"> Has the bond certification paperwork been received by corporate?
				<cfset bit= iif(TenantInfo.cBondHouseEligible IS 1, DE('Checked'), DE('Unchecked'))>
				<input type= "CheckBox" name= "cboBondCertReceived" Value = "1" #Variables.bit#>
			</td>
		</tr>
	</cfif>
</cfif>
	</tr>
	<cfif LEN(TenantInfo.bIsBundledPricing) EQ 1 AND tenantInfo.RoomType CONTAINS 'Studio'>
		<tr>
			<td  style="font-weight: bold;">Bundled Pricing?
			<input type="checkbox" name="BundledPricing" value="1" <cfif tenantInfo.bIsBundled EQ 1>Checked</cfif>></td>
		</tr>
		<input type="hidden" name="hasBundledPricing" value="yes">
	<cfelse>
		<input type="hidden" name="hasBundledPricing" value="no">
	</cfif>

	<tr>
		<td> Home Phone	<input type="Hidden" name="iOutSidePhoneType1_ID" value="1"> </td>
		<td colspan="3">
			<cfscript>
			if (TenantInfo.cOutsidePhoneNumber1 NEQ "") {
				areacode1=Left(TenantInfo.cOutsidePhoneNumber1,3);
				prefix1=Mid(TenantInfo.cOutsidePhoneNumber1,4,3);
				number1=Right(TenantInfo.cOutsidePhoneNumber1,4);
			}
			else { areacode1=Left(House.cPhoneNumber1,3); prefix1=Mid(House.cPhoneNumber1,4,3); number1=Right(House.cPhoneNumber1,4); }
			</cfscript>
			<input type="text" name="areacode1" size="3" value="#Variables.areacode1#" maxlength="3" onkeyup="this.value=Numbers(this.value);"> -
			<input type="text" name="prefix1" size="3" value="#Variables.prefix1#" maxlength="3" onkeyup="this.value=Numbers(this.value);"> -
			<input type="text" name="number1" size="4" value="#Variables.number1#" maxlength="4" onkeyup="this.value=Numbers(this.value);">

			&nbsp;&nbsp;&nbsp;Message Phone <input type= "Hidden" name= "iOutsidePhoneType2_ID" value= "5">
			<cfscript>
				areacode2 = Left(TenantInfo.cOutsidePhoneNumber2,3);
				prefix2 = Mid(TenantInfo.cOutsidePhoneNumber2,4,3);
				number2 = Right(TenantInfo.cOutsidePhoneNumber2,4);
			</cfscript>
			<input type="text" name="areacode2" size="3" value="#Variables.areacode2#" maxlength="3" onkeyup="this.value=Numbers(this.value);"> -
			<input type="text" name="prefix2" size="3" value="#Variables.prefix2#" maxlength="3" onkeyup="this.value=Numbers(this.value);"> -
			<input type="text" name="number2" size="4" value="#Variables.number2#" maxlength="4" onkeyup="this.value=Numbers(this.value);">
		</td>
	</tr>

	<tr>
		<td>
			<select name= "iOutsidePhoneType3_ID">
				<option value= ""> Additional Phone </option>
				<cfloop query= "PhoneType">
					<option value= "#PhoneType.iPhoneType_ID#"> #PhoneType.cDescription# </option>
				</cfloop>
			</select>
		</td>
		<td>
			<cfscript>
			areacode3 = Left(TenantInfo.cOutsidePhoneNumber3,3);
			prefix3 = Mid(TenantInfo.cOutsidePhoneNumber3,4,3);
			number3 = Right(TenantInfo.cOutsidePhoneNumber3,4);
			</cfscript>
			<input type="text" name="areacode3" size="3" value= "#Variables.areacode3#" maxlength="3" onkeyup="this.value=Numbers(this.value);"> -
			<input type="text" name="prefix3" size="3" value= "#Variables.prefix3#" maxlength="3" onkeyup="this.value=Numbers(this.value);"> -
			<input type="text" name="number3" size="4" value= "#Variables.number3#" maxlength="4" onkeyup="this.value=Numbers(this.value);">
		</td>
	</tr>

	<tr>
		<td> Email </td>
		<td colspan="2"> <input type="text" name="cEmail" value="#TenantInfo.cEmail#" SIZE="40" maxlength="70"> </td>
	</tr>

	<cfif isDefined("session.CodeBlock") and ListFindNoCase(session.CodeBlock,25) GT 0>
		<tr>
			<td colspan= "4" align="center">
				<cfinclude template="../Admin/EFTBox.cfm">
			</td>
		</tr>
		<tr style=" background:##CCCCFF">
			<td>Direct Payments:<br /> (Social Security & Other <br/>  Enter total here and enter details in Comments Box Below) </td>
			<td > $<input type="text"   name="dSocSec"   value="#numberformat(TenantInfo.dSocSec, '999999.99')#" onkeypress="return numbers(event)" onBlur="this.value=Money(this.value); this.value=cent(round(this.value));"  /></td>
			<td>Miscellaneous Monthly Payments:<br/> (Enter total here and enter details in Comments Box Below)</td>
			<td  colspan="3" > $<input type="text"   name="dMiscPayment"   value="#numberformat(TenantInfo.dMiscPayment, '999999.99')#"  onkeypress="return numbers(event)" onBlur="this.value=Money(this.value); this.value=cent(round(this.value));"   /></td>
		</tr>
		<tr>
			<td> Comments: </td>
			<td colspan= "3"> <textarea cols="50" rows="3" name="cComments">#Trim(TenantInfo.TenantComments)#</textarea> </td>
		</tr>
	<cfelse>
		<cfif TenantInfo.bUsesEFT NEQ "">
			<input type="hidden" value="#TenantInfo.bUsesEFT#" name="bUsesEFT">
			<input type="hidden" value="#Trim(TenantInfo.TenantComments)#" name="cComments">
			<input type="hidden"  value="#numberformat(TenantInfo.dsocsec, '999999.99')#"  name="dsocsec" />
			<input type="hidden"  value="#numberformat(TenantInfo.dMiscPayment, '999999.99')#" name="dMiscPayment" />
		</cfif>
	</cfif>

	<cfif (isDefined("session.CodeBlock") and ListFindNoCase(session.CodeBlock,25) GT 0)
		and Tenantinfo.iresidencytype_id is 2 and Tenantinfo.iTenantStateCode_ID is 2>
		<tr>
		<td>
		<table>
			<tr>
				<td colspan="4" style="font-weight: bold;">Resident Medicaid Information</td>
			</tr>

			<tr id="typMedicaid9" >
				<td>Select MCO Provider</td>
				<td>
					<select name="cMCO">
						<cfif IsDefined('qryMedicaidProvider.cMCOProvider')>
							<option value="#qryMedicaidProvider.iMCOProvider_ID#">
							#qryMedicaidProvider.cMCOProvider#  - Select to Change MCO Provider
							</option>
						<cfelse>
						<option value="">Select to Add MCO Provider</option>
						</cfif>
						<cfloop query="qryMCO">
							<option value="#iMCOProvider_ID#">#cMCOProvider#</option>
						</cfloop>
					</select>
				</td>
			</tr>
	        <!---Mshah added MCO ID Number--->
	        <tr>
				<td>
					MCO ID Nbr.
				</td>
				<td><input type="text"  name="cMCOIDNbr" id="cMCOIDNbr"
							value="#Tenantinfo.cMCOIDNbr#" />
	       		</td>
		   </tr>
           <!---Mshah end--->
		   <cfif #session.qselectedhouse.cStatecode# neq 'WI'> <!---mshah added here--->
			<tr>
				<td>
					MCO Authorization Nbr.
				</td>
				<td><input type="text"  name="cMedicaidAuthorizationNbr" id="cMedicaidAuthorizationNbr"
								value="#Tenantinfo.cMedicaidAuthorizationNbr#" />
		        </td>
			</tr>
			</cfif>
			<tr id="typMedicaid2"  >
				<td>Enter the Authorized MCO "From Date of Service" (FDOS - Format MM/DD/YYYY)</td>
				<td><input type="text" name="dtFDOS"  id="dtFDOS" value="#dateformat(Tenantinfo.dtAuthFDOS,'mm/dd/yyyy')#"/></td>
			</tr>
			<tr id="typMedicaid3"  >
				<td>Enter the Authorized MCO "Through Date Of Service" (TDOS - Format MM/DD/YYYY)</td>
				<td><input type="text" name="dtTDOS"  id="dtTDOS" value="#dateformat(Tenantinfo.dtAuthTDOS,'mm/dd/yyyy')#"/></td>
			</tr>
        		<cfif #session.qselectedhouse.cStatecode# neq 'WI'> <!---mshah added here--->
					<tr id="typMedicaid4"  >
						<td>Medicaid Nbr.</td>
						<td><input type="text" name="cNJHSP"  id="cNJHSP" value="#Tenantinfo.cNJHSP#"/></td>
					</tr>
      		    	<!---Mshah added--->
					<tr id="typMedicaid4"  >
						<td>Medicaid Eligibility Date (Format MM/DD/YYYY) </td>
						<td><input type="text" name="MedicaidEligDate"  id="MedicaidEligDate" value="#dateformat(Tenantinfo.dtMedicaidEligibility,'mm/dd/yyyy')#"</td>
					</tr>
					<!---Mshah--->
					<cfif #session.qselectedhouse.cStatecode# EQ 'IA'> <!---TPecku added logic --->
					 <tr id="typMedicaid5"  >
						<td>Enter the Authorized amount of Medicaid- Basic Service Fee ($)</td>
						<td><input type="text" name="mMedicaidCopay"  id="mMedicaidCopay" value="#TRIM(LSNumberFormat(Tenantinfo.mMedicaidCopay, "99999.99"))#"</td>
					</tr>
					 <cfelse>
					<tr id="typMedicaid5"  >
						<td>Enter the Authorized amount of Medicaid CoPay ($)</td>
						<td><input type="text" name="mMedicaidCopay"  id="mMedicaidCopay" value="#TRIM(LSNumberFormat(Tenantinfo.mMedicaidCopay, "99999.99"))#"/></td>
					</tr>
                    </cfif>
					 <cfif #session.qselectedhouse.cStatecode# EQ 'IA'> <!---TPecku added logic --->
					 <cfelse>
					<tr id="typMedicaid6" >
						<td>ICD 10 Code</td>
						<td><input type="text" name="iPICD"  id="iPICD" value="#Tenantinfo.iPICD#"/></td>
					</tr>
					</cfif>
			    </cfif>
		</table>
		</td>
		</tr>
	<cfelse>
		<tr>
		<td>
		<table>
			<tr>
				<td colspan="4" style="font-weight: bold;">Resident Medicaid Information</td>
			</tr>

			<tr id="typMedicaid9" >
				<td>MCO Provider</td>
				<td>
					<cfif IsDefined('qryMedicaidProvider.cMCOProvider')>#qryMedicaidProvider.cMCOProvider#
					<cfelse>
					Not Selected
					</cfif>
				</td>
			</tr>
			<tr>
				<td>MCO Authorization Nbr.</td>
				<td>#Tenantinfo.cMedicaidAuthorizationNbr#</td>
			</tr>
			<tr >
				<td>From Date of Service</td>
				<td>#dateformat(Tenantinfo.dtAuthFDOS,'mm/dd/yyyy')#</td>
			</tr>
			<tr >
				<td>Through Date Of Service</td>
				<td>#dateformat(Tenantinfo.dtAuthTDOS,'mm/dd/yyyy')#</td>
			</tr>
			<tr >
				<td>Medicaid Nbr.</td>
				<td>#Tenantinfo.cNJHSP#</td>
			</tr>
			<tr >
                <td>Medicaid Eligibility Date</td>
				<td>#Tenantinfo.cNJHSP#</td>
			    </tr>
			<cfif #session.qselectedhouse.cStatecode# EQ 'IA'> <!--- TPecku added logic --->
			<tr >
				<td>Authorized amount of Medicaid- Basic Service Fee</td>
				<td>#dollarformat(Tenantinfo.mMedicaidCopay)#</td>
			</tr>
			<cfelse>
			<tr >
				<td>Authorized amount of Medicaid CoPay</td>
				<td>#dollarformat(Tenantinfo.mMedicaidCopay)#</td>
			</tr>
			</cfif>
       		 <cfif #session.qselectedhouse.cStatecode# neq 'WI'> <!---mshah added here--->
				<cfif #session.qselectedhouse.cStatecode# EQ 'IA'> <!--- TPecku added logic --->
	         <cfelse>
			<tr>
				<td>PICD</td>
				<td>#Tenantinfo.iPICD#</td>
			</tr>
			</cfif>
	      </cfif>
		</table>
		</td>
		</tr>
	</cfif>


	<tr>
		<td colspan="2" style="font-weight: bold;"> CONTACT'S INFORMATION: </td>
		<td style="font-weight: bold;">
			<cfif (Contact.RecordCount EQ 0 AND NOT IsDefined("URL.CID")) OR (NOT IsDefined("URL.CID") AND Contact.RecordCount GT 0)>
				<input type="button" name="AddContact" value="ADD NEW CONTACT" style="width: 150px; color: Green; font-weight: bold; font-size: 10;"
				onClick="location.href='TenantEdit.cfm?ID=#url.ID#&CID=0'">
			</cfif>
		</td>
	</tr>

	<cfif IsDefined("URL.CID")>

		<cfif Contact.iContact_ID NEQ 0>
			<input type="Hidden" name="iContact_ID" value="#Contact.iContact_ID#">
			<!---Mshah--->
			<cfif IsDefined("URL.LNK") >
			<input type="Hidden" name="iLinkTenantContact_ID" value="#URL.LNK#">
			</cfif>
			<!---Mshah--->
		<cfelse>
			<input type="Hidden" name="iContact_ID" value="0">
		</cfif>
		<tr>
			<td>First Name </td>
			<td><input type="text" id="ContactFirstName" name="ContactFirstName" value="#Contact.cFirstName#" SIZE=26 maxlength="25"
				onBlur="this.value=ltrs(this.value); upperCase(this);">
			</td>
		</tr>
		<tr>
			<td> Last Name </td>
			<td> <input type="text" id="ContactLastName" name="ContactLastName" value="#Contact.cLastName#" SIZE=26 maxlength="25"
			onBlur="this.value=ltrs(this.value); upperCase(this);">
			</td>
		</tr>
		<tr>
			<td> Relationship </td>
			<td>
				<select name= "ContactRelationshipType_ID">
				<cfif IsDefined("Contact.Relation")> <option value="#Contact.iRelationshipType_ID#"> #Contact.Relation# </option>
				<cfelse> <option value= ""> Choose RelationShip Type </option> </cfif>
				<cfloop query= "RELATIONSHIPS">
					<option value= "#RelationShips.iRelationshipType_ID#">#RelationShips.cDescription#</option>
				</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td colspan="2" style="font-weight:bold; color:##FF0000">For the following questions, check the box if the answer is 'Yes'</td>
		</tr>

		<tr>
			<td colspan="2" style="Font-weight: bold;"> Is this Contact a payor?
 				<cfset bit= iif(Contact.bIsPayer IS 1, DE('Checked'), DE('Unchecked'))>
				<input type="CheckBox"  id="ContactbIsPayer" name="ContactbIsPayer" value="1" #Variables.bit# onClick="required();">
			</td>
		</tr>
		<tr>
			<td  colspan="2" style="Font-weight: bold;"> Does this Contact have Financial Power Of Attorney?
				<cfif Contact.bIsPowerOfAttorney IS 1> <cfset bit="Checked">
				<cfelse> <cfset bit="UnChecked"> </cfif>
				<input type="CheckBox" name="bIsPowerOfAttorney" Value="1" #Variables.bit#>
			</td>
		</tr>

		<tr>
			<td colspan="3" style="Font-weight: bold;">Does this contact have the Power of Attorney for Health Care ?
				<cfif Contact.bIsMedicalProvider IS 1><cfset bit = "Checked"><cfelse><cfset bit = "UnChecked"></cfif>
				<input type="CheckBox" name="bIsMedicalProvider" Value="1" #Variables.bit#>
			</td>
		</tr>

		<tr>

		<td colspan="2" style="Font-weight: bold;">Is this contact the Executor Contact?
			<cfset bit= iif(Contact.bIsExecutorContact IS 1, DE('Checked'), DE('Unchecked'))>
			<input type= "CheckBox" name= "bIsExecutorContact" Value = "1" #Variables.bit#>
		</td>
	</tr>

	<tr>
		<td colspan="4" style="Font-weight: bold;">Has this Contact signed the Guarantor Agreement?
		<cfscript>
			if (ContactInfo.bIsGuarantorAgreement eq 'null' or ContactInfo.bIsGuarantorAgreement eq ''){ Note = 'Action Needed';}
			else if (ContactInfo.bIsGuarantorAgreement EQ '0'){ Note = 'No Guarantor Agreement Approved';}
			else if (ContactInfo.bIsGuarantorAgreement EQ '1'){ Note = 'Received';}
		</cfscript>
			<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
	 			<select name="oGuarentorAgreement">
					<option value="#ContactInfo.bIsGuarantorAgreement#">#Note#</option>
					<cfif ContactInfo.bIsGuarantorAgreement neq ''><option value="null">Action Needed</option></cfif>
					<cfif ContactInfo.bIsGuarantorAgreement neq 0><option value="0">No Guarantor Agreement Approved</option></cfif>
					<cfif ContactInfo.bIsGuarantorAgreement neq 1><option value="1">Received</option></cfif>
	 			</select>
				Select appropriate response</td>
			<cfelse>
				#Note#
				<input type="hidden" name="bIsGuarantorAgreement" value=#ContactInfo.bIsGuarantorAgreement#>
				</td>
			</cfif>
	</tr> <!---<cfoutput>test -- #ContactInfo.bIsGuarantorAgreement# </cfoutput>--->

	 <tr>
	  	<td colspan="3" style="Font-weight: bold;">Is this Contact the Primary Care Physician ?
			<cfset bit= iif(ContactInfo.cPrimaryCarePhysicianContact IS 1, DE('Checked'), DE('Unchecked'))>
			<input type= "CheckBox" name= "cPrimaryCarePhysicianContact" Value = "1" #Variables.bit#>
		</td>
	</tr>

	<tr>
		<td>Address	Line 1</td>
		<td colspan="4"><input type="text" id="ContactAddressLine1" Name="ContactAddressLine1" value="#Contact.cAddressLine1#" SIZE="40" maxlength="40" onblur="upperCase(this);">	</td>
	</tr>
	<tr>
		<td>Address	Line 2</td>
		<td colspan="4"><input type="text" id="ContactAddressLine2" Name="ContactAddressLine2" value="#Contact.cAddressLine2#" SIZE="40" maxlength="40" onblur="upperCase(this);">	</td>
	</tr>
	<tr>
		<td>City</td>
		<td colspan="3"><input type="text"  id="ContactCity" Name="ContactCity" value="#Contact.cCity#"
        				onkeypress="return allowOnlyLettersOnKey(event);" onblur="upperCase(this);">
        </td>
	</tr>
	<tr>
		<td>State</td>
		<td colspan="3">
			<select name= "ContactStateCode" id="ContactStateCode">
				<option value=""> Select State </option>
					<cfloop Query = "StateCodes">
						<cfscript>
							if (IsDefined("Contact.cStateCode") AND Contact.cStateCode EQ StateCodes.cStateCode)
								{ Selected = 'SELECTED'; }
							else
								{ Selected=''; }
						</cfscript>
						<option value="#cStateCode#" #Selected#> #cStateName# - #cStateCode# </option>

					</cfloop>
				</select>
		</td>
	</tr>
	<tr>
		<td>Zip (Postal) Code</td>
		<td colspan="3"><input type="text" id="ContactZipCode" Name="ContactZipCode" value="#Contact.cZipCode#" maxlength="10" size="10" onblur="maskZIP(this);"			>
        </td><!---  onkeypress="return allowOnlyNumberOnKey(event)" --->
	</tr>
	<tr>
		<td>Home Phone </td>
		<td colspan="3">
			<cfscript>
				areacode1=LEFT(Contact.cPhoneNumber1,3);
				prefix1=Mid(Contact.cPhoneNumber1,4,3);
				number1=RIGHT(Contact.cPhoneNumber1,4);
			</cfscript>
			<input type="text" id="Contactareacode1" name="Contactareacode1" SIZE="3"	value="#Variables.areacode1#" maxlength="3" onkeyup="this.value=Numbers(this.value)"> -
			<input type="text" id="Contactprefix1" name="Contactprefix1" SIZE="3" value="#Variables.prefix1#" maxlength="3" onkeyup="this.value=Numbers(this.value)"> -
			<input type="text" id="Contactnumber1" name="Contactnumber1" SIZE="4" value="#Variables.number1#" maxlength="4" onkeyup="this.value=Numbers(this.value)">
			<input type="hidden"  id="ContactiPhoneType1_ID" name="ContactiPhoneType1_ID" value="1">
		</td>
	</tr>
	<tr>
		<td>Message Phone</td>
		<td colspan="3">
			<cfscript>
			areacode2=LEFT(Contact.cPhoneNumber2,3);
			prefix2=Mid(Contact.cPhoneNumber2,4,3);
			number2=RIGHT(Contact.cPhoneNumber2,4);
			</cfscript>

			<input type="text"  id="Contactareacode2" name="Contactareacode2" SIZE="3"	value="#Variables.areacode2#" maxlength="3" onkeyup="this.value=Numbers(this.value)"> -
			<input type="text" id="Contactprefix2" name="Contactprefix2" SIZE="3" value="#Variables.prefix2#" maxlength="3" onkeyup="this.value=Numbers(this.value)"> -
			<input type="text" id="Contactnumber2" name="Contactnumber2" SIZE="4" value="#Variables.number2#" maxlength="4" onkeyup="this.value=Numbers(this.value)">
			<input type="hidden"  id="ContactiPhoneType2_ID" name="ContactiPhoneType2_ID" value="5">
		</td>
	</tr>
	<tr>
		<td>Email</td>
		<td colspan="4"><input type="text" id="ContactEmail" Name="ContactEmail" value="#Contact.cEmail#" SIZE="40" maxlength="70">	</td>
	</tr>
	<cfelse>
		<cfloop query="Contact">
			<cfscript>
				if ((Contact.bIsPayer EQ "") or (Contact.bIsPayer EQ 0))  { Payor=""; } else { Payor="(Payor)"; }
				if (Contact.bIsPowerOfAttorney NEQ "") { Attorney="(Power of Attorney)"; } else { Attorney = ""; }
				if (Contact.bIsMedicalProvider NEQ "") { Medical="(Medical Provider)"; } else { Medical=""; }
				if (Contact.bIsGuarantorAgreement NEQ "") { Guarantor="(Guarantor)"; } else { Guarantor=""; }
				if (Contact.bIsMoveOutPayer NEQ "") { MoveOutPayor="(MoveOutPayor)"; } else {  MoveOutPayor=""; }
				if (Contact.bIsEFT NEQ "") { EFT="(EFT)"; } else { EFT=""; }
			</cfscript>
			<tr>
				<td colspan="2">
					<A hrEF="TenantEdit.cfm?ID=#URL.ID#&CID=#Contact.iContact_ID#&LNK=#Contact.iLinkTenantContact_ID#">#Contact.cFirstName# #Contact.cLastName# #Variables.Payor# #Variables.Attorney# #Variables.Medical# #Variables.Guarantor# #Variables.EFT# #Variables.MoveOutPayor#</A>
					<cfif Contact.bIsPayer EQ 1>
						<input type="Checkbox" id="ContactbIsPayer" name="ContactbIsPayer" value="database" CHECKED style="visibility: hidden;">
					</cfif>
				</td>
				<cfif isDefined("session.CodeBlock") and ListFindNoCase(session.CodeBlock,25) GT 0>
					<td colspan="1" style="text-align: Left;">
						<input type="Button" class="BlendedButton" name="contactEFT" value="Setup EFT" style="width: 100px;"
						onClick="location.href='TenantEFTEdit.cfm?ID=#TenantInfo.iTenant_ID#&CID=#Contact.iContact_ID#'">
					</td>
					<td   style="text-align: Left;">
						<input type="Button" class="BlendedButton" name="Delete" value="Delete Contact" style="width: 100px;"
						onClick="location.href='DeleteContact.cfm?ID=#TenantInfo.iTenant_ID#&CID=#Contact.iContact_ID#'">
					</td>
					<td   style="text-align: Left;">
						<input type="Button" class="BlendedButton" name="DropContactLinkOnly" value="Drop Link" style="width: 100px;"
						onClick="location.href='DeleteContact.cfm?ID=#TenantInfo.iTenant_ID#&CID=#Contact.iContact_ID#&LNK=#Contact.iLinkTenantContact_ID#'">
					</td>
				<cfelse>
					<td colspan="3" style="text-align: Left;">&nbsp;</td>
				</cfif>

			</tr>
		</cfloop>
	</cfif>
	<tr>
		<td style="text-align: left;">
			<input class="SaveButton" type="button" name="Save" Value="Save" onMouseDown="required();"
			onClick="document.TenantEdit.action='TenantUpdate.cfm';submit();">
		</td>
		<td colspan=2></td>
		<td>
			<cfscript>
				if (IsDefined("url.cid") AND url.cid EQ 0) { Script="newcontactdata();"; }
				else { Script=''; }
			</cfscript>
			<input class="DontSaveButton" type="button" name="DontSave" value="Don't Save" onClick="#SCRIPT# location.href='TenantEdit.cfm?ID=#url.ID#&Debug=2'">
		</td>
	</tr>
	<tr>
		<td colspan="4" style="font-weight: bold; color: red;">
		<U>NOTE:</U> You must SAVE to keep information which you have entered!
		</td>
	</tr>
	<tr>
		<td colspan="4"><input class="ReturnButton" type="button" name="viewallhouseeft" Value="View House EFT's"   onClick="location.href='TenantEFTHouse.cfm'"  ></td>
	</tr>
</cfoutput>
</table>
</form>
