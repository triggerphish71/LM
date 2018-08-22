<!------------------------------------------------------------------------------------------------
|                                    HISOTRY                                                     |
|------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                          |
|------------|------------|----------------------------------------------------------------------|
| Sathya     | 05/26/2010 | Project 20933 LateFee modified the query to exclude the late fee     |
| Sathya     | 09/09/2010 | Project 20933 Part-D restricted the late fee chargetype_id to be     |
|            |            | from being modified.                                                 |
|sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                             |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                    |
|S Farmer    | 09/08/2014 | 116824 - Allow all houses edit BSF and Community Fee Rates           |
|S Farmer    | 05/06/2015 | deleting of a charge changed to be visible only to AR & IT           |
|mstriegel   | 02/07/2018 | Added logic to remove the delete button for any community fee's      |
------------------------------------------------------------------------------------------------->

<cfoutput>

<cflock scope="application" timeout="10">
	<cfset session.application="TIPS4">
</cflock>

<!--- =============================================================================================
Only Index.cfm can create URL.SelectedHouse_ID.  If it exists set SESSION variables.
============================================================================================== --->
<cfif not isDefined("url.SelectedHouse_id") and isDefined("session.qselectedhouse.ihouse_id")>
	<cfset url.SelectedHouse_id=session.qselectedhouse.ihouse_id>
</cfif>

<CFIF IsDefined("URL.SelectedHouse_ID")	AND url.SelectedHouse_ID NEQ '' OR NOT isDefined("SESSION.TIPSMonth")>
    <CFQUERY  NAME="qHouse" DATASOURCE="#APPLICATION.DataSource#">
		SELECT  
			*
		FROM 
			House H (NOLOCK)
		INNER JOIN  
			HouseLog HL (NOLOCK) ON H.iHouse_ID = HL.iHouse_ID 
				AND 
			HL.dtRowDeleted IS NULL 
				AND 
			H.dtRowDeleted IS NULL
		WHERE 
			H.iHouse_ID = #url.SelectedHouse_ID#
	</CFQUERY>
	
	<CFSCRIPT>
		CalcHouse = qhouse.cNumber - 1800;
		
		if (Len(CalcHouse) EQ 2) 
		{ 
			HouseNumber = '0' & CalcHouse; 
		}
		else if (Len(CalcHouse) EQ 1) 
		{ 
			HouseNumber = '0' & '0' & CalcHouse; 
		}
		else 
		{ 
			HouseNumber = '#CalcHouse#'; 
		}

    		SESSION.qSelectedHouse = qHouse;
		SESSION.HouseName = qhouse.cName;
		SESSION.HouseNumber = '#HouseNumber#';
		SESSION.nHouse = qhouse.cNumber;
		SESSION.TIPSMonth = qhouse.dtCurrentTipsMonth;
		SESSION.cSLevelTypeSet = qhouse.cSLevelTypeSet;
		SESSION.HouseClosed	= qhouse.bIsPDclosed;
		SESSION.cDepositTypeSet	= qHouse.cDepositTypeSet;
		SESSION.cBillingType = TRIM(qHouse.cBillingType);

		//renew user session variables to renew timeout period.
		if (isDefined("SESSION.userid")) {SESSION.userid=SESSION.userid;}
		if (isDefined("SESSION.fullname")) {SESSION.fullname=SESSION.fullname;}
	</CFSCRIPT>
	
<!--- ==============================================================================
We did NOT arrive via Index.cfm.  Verify SESSION variables still exist.
=============================================================================== --->
<CFELSEIF  NOT  IsDefined("SESSION.qSelectedHouse")>
    <CFSET  UrlStatusMessage =  URLEncodedFormat("Please select a house.")>
    <CFLOCATION  URL = "Index.cfm?UrlStatusMessage=#UrlStatusMessage#"  >  <!--- ADDTOKEN = "NO" --->
</CFIF>

<cfset Action = IIF(IsDefined("form.iCharge_ID"),DE('ChargeAdd.cfm'),DE('ChargesDetail.cfm?ID=#url.ID#'))>

<!--- JavaScript to redirect user to specified template if the Don't save button is pressed --->
<script> 
	function redirect() 
	{ 
		window.location = "ChargesDetail.cfm?ID=#url.id#"; 
	} 
</script>

<!--- Retrieve General Tenant Information --->
<cfinclude template="../Shared/Queries/TenantInformation.cfm">
<cfinclude template="RetreiveInvoiceNumber.cfm">

<!--- --->
<cfquery name="qtenant" datasource="#application.datasource#">
select *
from tenant t
join tenantstate ts on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null
and t.dtrowdeleted is null and t.itenant_id = '#trim(url.id)#'
</cfquery>

<cfset TIPSPeriod = Year(SESSION.TIPSMonth) & DateFormat(SESSION.TIPSMonth,"mm")>
<!--- 25575 - 6/2/2010 - rts - need new query ro respites --->
<cfif qtenant.iResidencyType_ID eq 3>
	<cfquery name="InvoiceNumber" datasource="#APPLICATION.datasource#">
	select i.* from InvoiceMaster i
	where i.cSolomonKey = '#TenantInfo.cSolomonKey#'
	and i.bMoveInInvoice is null and i.bMoveOutInvoice is null and i.bFinalized is null and i.dtRowDeleted is null
	and i.cAppliesToAcctPeriod = '#TIPSPeriod#'
	and i.iInvoiceMaster_ID = (Select max(s.iInvoiceMaster_ID) from InvoiceMaster s where s.cSolomonKey = '#TenantInfo.cSolomonKey#'
								and s.bMoveInInvoice is null and s.bMoveOutInvoice is null 
								and s.bFinalized is null and s.dtRowDeleted is null
								and s.cAppliesToAcctPeriod = '#TIPSPeriod#')
	</cfquery>
<cfelse>
	<cfquery name="InvoiceNumber" datasource="#APPLICATION.datasource#">
	select * from InvoiceMaster
	where cSolomonKey = '#TenantInfo.cSolomonKey#'
	and bMoveInInvoice is null and bMoveOutInvoice is null and bFinalized is null and dtRowDeleted is null
	and cAppliesToAcctPeriod = '#TIPSPeriod#'
	</cfquery>
</cfif>
<!--- 06/23/2010 Project 20933 Sathya Code change start --->
<!--- 05/26/2010 Project 20933 Sathya Modified this query to exclude the late fee that was added --->
<!--- Retreive Invoice Information for the Chosen Tenant --->
<cfquery name="ChargesDetail" datasource="#APPLICATION.datasource#">
select T.cFirstName, T.cLastName,
		im.iInvoiceNumber, im.cSolomonKey, 
		inv.iQuantity, inv.cDescription, inv.mAmount, inv.iInvoiceDetail_ID,
		inv.iRowStartUser_ID, CT.bIsMedicaid, CT.bIsRent
		,(select count(*) from RecurringCharge where dtRowDeleted is not null
			and iTenant_ID = inv.iTenant_ID and cComments = inv.cComments
			and inv.iRowStartUser_ID = 0 and dtRowDeleted >= (DateAdd(m,-1,getdate()))
		 )
		as deletedrecurring ,inv.ccomments, inv.cappliestoacctperiod
		<!--- 09/09/2010 Project 20933 Part-D Sathya modified this --->
		, inv.iChargeType_ID
		<!--- 09/09/2010 End of project 20933 Part-D --->
from	InvoiceDetail inv
join Tenant T on T.iTenant_ID = inv.iTenant_ID		
join InvoiceMaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
join ChargeType CT on inv.iChargeType_ID = CT.iChargeType_ID
where bMoveInInvoice is null and bMoveOutInvoice is null and im.bFinalized is null
and inv.dtRowDeleted is null and im.dtRowDeleted is null
and inv.iTenant_ID = #url.ID#
and isNull(im.iInvoiceMaster_ID,0) = #isBlank(InvoiceNumber.iInvoiceMaster_ID,0000)#
<cfif ListFindNoCase(SESSION.codeblock,23) eq 0> 
	and	(
				(CT.bIsMedicaid is not null and CT.bIsRent is not null) 
				or (CT.bIsMedicaid is null and bIsRent is null)
				or (CT.bIsRent is not null and CT.bIsMedicaid is null)
				or (CT.bIsRent is null and CT.bIsMedicaid is not null and CT.bIsDiscount is not null)				
			)
</cfif>
<!--- 05/26/2010 Project 20933 Sathya Added this condition to exclude the late fee to be displayed --->
AND (INV.bNoInvoiceDisplay is null OR INV.bNoInvoiceDisplay = 0) 
<!---End of Code Project 20933  --->
order by ct.bisrent desc, ct.bisdiscount, ct.cgrouping, inv.irowstartuser_id, inv.cappliestoacctperiod desc, inv.mamount
</cfquery>

<!--- Retrieve list of all available credits (discounts) --->
<cfquery name="Additional" datasource="#APPLICATION.datasource#">
select CT.*, C.*, C.cDescription,   <!--- mstriegel ---> ct.cDescription as typeDescription <!--- end mstriegel --->
from Charges	C
join Chargetype CT on C.iChargeType_ID = CT.iChargeType_ID and CT.dtRowDeleted is null
where C.dtRowDeleted is null and	bIsRent is null
and	getdate() between c.dteffectivestart and c.dteffectiveend
and (c.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID# or C.iHouse_id is null)
<cfif IsDefined("form.iCharge_ID")>and iCharge_ID = #form.iCharge_ID#</cfif>
</cfquery>

<!--- mstriegel 02/07/2018 call a function to get the charge type ids --->
<cfset qCommunityFeeChargeTypeID = session.oChargeServices.getChargeTypeID(wherecondition="community")>
<cfset communityFeeChargeTypeIDList = ValueList(qCommunityFeeChargeTypeID.iChargeType_ID)>
<!--- end mstriegel ---> 


<!--- Include Intranet header --->
<cfinclude template="../../header.cfm">
<form action="#variables.Action#" method="POST">
<input type="hidden" name="iInvoiceNumber" value="#InvoiceNumber.iInvoiceNumber#">
<input type="hidden" name="iTenant_ID" value="#TenantInfo.iTenant_ID#">
<input type="hidden" name="iInvoiceMaster_ID" value="#InvoiceNumber.iInvoiceMaster_ID#">

<cfset Period = Year(SESSION.TIPSMonth) & DateFormat(SESSION.TIPSMonth,"mm")>
<!--- 25575 - rts - 6/2/2010 - remove this report link for Respites --->a
<cfif qtenant.iResidencyType_ID neq 3>
	<a href="../Reports/InvoiceReportB.cfm?prompt0=#trim(TenantInfo.cSolomonKey)#&prompt2=#Period#">
	<b style="font-size:medium;">Preview Invoice</b>
	</a>
<cfelse>
	<a href="../Reports/RespiteInvoiceReport.cfm?SolID=#trim(TenantInfo.cSolomonKey)#&INVNBR=#InvoiceNumber.iInvoiceNumber#">
		<b style="font-size:medium;">Preview Respite Invoice</b></a>
</cfif>
<!--- end 25575 --->
<br/><br/>
<table>
	<tr> <th colspan="5">Resident Charges/Credits Detail</th></tr>
	<tr>
		<td style="font-weight: bold; width: 20%; text-align: right;"> Full Name </td>
		<td style="width:20%; text-align: right;"> #TenantInfo.cFirstName# #TenantInfo.cLastName#	</td>
		<td style="width:20%;">
		</td>
		<td style="width:20%;">
		<cfif auth_user eq "ALC\PaulB">
		 Moved In #dateformat(qtenant.dtmovein,"mm/dd/yy")# <br> 
		</cfif>
		<cfif auth_user eq "ALC\PaulB" and 1 eq 0>
		 Last Evaluation #dateformat(qtenant.dtSPEvaluation,"mm/dd/yy")#
		</cfif>
		</td>
		<td style="width:20%;">
		<cfif auth_user eq "ALC\PaulB">
		 <cfquery name="qactive" datasource="#application.datasource#">
		 select distinct iassessmenttoolmaster_id ,dtbillingactive from assessmenttoolmaster where dtrowdeleted is null
		 and itenant_id = #trim(url.id)# and bfinalized is not null and bbillingactive is not null
		 </cfquery>
		 <cfif isDefined("qactive.dtbillingactive") and qactive.dtbillingactive neq "">
		 active date #dateformat(qactive.dtbillingactive,"mm/dd/yy")#</cfif>
		</cfif>
		</td>
	</tr>
	<tr>
		<td style="font-weight: bold; text-align: right;"> Account Number </td>
		<td style="text-align: right;"> #TenantInfo.cSolomonKey# </td>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	<tr>
		<td style="font-weight: bold; text-align: right;">	Invoice Number	</td>
		<td style="text-align: right;"> #InvoiceNumber.iInvoiceNumber#	</td>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	<!--- 25575 - 6/2/2010 - rts - Respite Info line --->
	<cfif qtenant.iResidencyType_ID neq 3>
		<tr> <td colspan="5">&nbsp;</td> </tr>	
	<cfelse>
		<tr> <td></td>
			<td style="text-align: right;" NOWRAP>Last Respite Invoice Created</td>
			<td></td>
			<td></td>
			<td></td> 
		</tr>
	</cfif>
	<!--- end 25575 --->
	<tr> <td colspan="5" style="font-weight: bold;">	Current Charges/Credits: <!--- #SESSION.CodeBlock# ---></td> </tr>
	<tr>
		<td colspan="5" style="text-align: center;">
			<table style="width:95%; border: 1px solid gainsboro;">
			<tr style="font-weight: bold; text-align: center; background: gainsboro;">
				<td style="border-bottom: 1px solid gray;"> Description </td>
				<td style="border-bottom: 1px solid gray;"> Per </td>
				<td style="border-bottom: 1px solid gray;"> Amount </td>
				<td style="border-bottom: 1px solid gray;"> Quantity </td>
				<td style="border-bottom: 1px solid gray;"> Total </td>
				<!---delete can be done by IT and AR only, added if condition--->
				<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
				<td style="border-bottom: 1px solid gray;text-align: center;"> Delete </td>
				</cfif>				
				<!--- <td style="border-bottom: 1px solid gray;text-align: center;"> Delete </td> --->
				<td style="border-bottom: 1px solid gray;"> Created by </td>
			</tr>
			<cfset TotalInvoice = 0>
		
			<cfloop query="ChargesDetail">
				<cfif ChargesDetail.mAmount neq "">	
					<cfset ChargeAmount = ChargesDetail.mAmount> 
				<cfelse> 
					<cfset ChargeAmount = 0.00> 
				</cfif>
				<cfif  ChargesDetail.iQuantity neq ""  and  ChargesDetail.mAmount neq ""  >
					<cfif  (ChargesDetail.iChargeType_ID is not 1740) >
						<cfset ExtendedPrice = ChargesDetail.iQuantity * ChargesDetail.mAmount>	
					<cfelse> 
						<cfset ExtendedPrice = 0.00> 
					</cfif>
				<cfelse> 
					<cfset ExtendedPrice = 0.00> 
				</cfif>
				<cfset TotalInvoice = variables.TotalInvoice + variables.ExtendedPrice>
				<tr>
					<td style="width:40%;"> 
					#ChargesDetail.cDescription# 
					<cfif len(trim(ChargesDetail.ccomments)) gt 0 >
						<div style="padding-left:15px;">#trim(ChargesDetail.ccomments)#</div>
					</cfif>
					</td>
					<td style="text-align: right;"> #ChargesDetail.cAppliesToAcctPeriod#</td>
					<td style="text-align: right;"> #LSCurrencyFormat(ChargesDetail.mAmount)# </td>
					<td style="#center#"> #ChargesDetail.iQuantity# </td>
					<td style="text-align: right;"> #LSCurrencyFormat(variables.ExtendedPrice)# </td>
					<cfif ChargesDetail.iRowStartUser_ID neq 0 or (ListFindNoCase(SESSION.CodeBlock,23) gte 1 
						and ChargesDetail.bIsMedicaid GT 0) 
						or ChargesDetail.bIsRent lt 1 or (ChargesDetail.deletedrecurring GT 0)>
						<cfset Label = IIF(ChargesDetail.iRowStartUser_ID eq 0, DE('Recurring Charge'), DE(''))>
						<!--- 09/09/2010 Project 20933 Part-D Sathya Modified this so that normal users cannot delete the late fee --->
						<!--- commented below code and rewrote it --->
						<!--- <td nowrap style="#Center#">
						<input type="button" name="Delete" value="Delete" style="color:red;font-size:xx-small;" onClick="self.location.href='DeleteCharge.cfm?ID=#TenantInfo.iTenant_ID#&detail=#ChargesDetail.iInvoiceDetail_ID#'">
						<br> #label#
						</td> --->
						<!--- Check if the Chargetype_id is 1697(late fee). Give only the Ar Analyst to delete the late fee--->	
						<!---<cfif ChargesDetail.iChargeType_ID eq 1697> this code is commented to display delete button to AR and IT, 
						Houses wont be able to delete the any of charges. --->
							 <cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)> 
	       						<!---<td nowrap style="#Center#">
								<input type="button" name="Delete" value="Delete" style="color:red;font-size:xx-small;"	
					onClick="self.location.href='DeleteCharge.cfm?ID=#TenantInfo.iTenant_ID#&detail=#ChargesDetail.iInvoiceDetail_ID#'">
								<br> #label#
								</td> 
							 <cfelse>
							  	<td>Only AR Analyst</td> 
							  </cfif>
						<cfelse>--->
							<td nowrap style="#Center#">
								<!--- mstriegel 2/7/2018 added logic for Not displaying button if the charge type is community fee --->
								<cfif listFindNoCase(communityFeeChargeTypeIDList,chargesDetail.iChargeType_ID) EQ 0>
									<input type="button" name="Delete" value="Delete" style="color:red;font-size:xx-small;" onClick="self.location.href='DeleteCharge.cfm?ID=#TenantInfo.iTenant_ID#&detail=#ChargesDetail.iInvoiceDetail_ID#'">
									<br> #label#
								</cfif>
								<!--- end mstriegel --->
							</td> 
						 </cfif>
						 <!--- 09/09/2010 Project 20933 Part-D End of code --->
						<cfquery name="getUser" datasource="DMS">
							select employeeid, username from users where employeeid = #ChargesDetail.iRowStartUser_ID#
						</cfquery>
						<td style="text-align:left; font-size:xx-small;">#getUser.username# </td>
					<cfelseif ChargesDetail.iRowStartUser_ID eq 0>
						<td colspan="2" style="#right#"> system generated </td>
					</cfif>
				</tr>
				<!---
				<cfif len(trim(ChargesDetail.ccomments)) gt 0 ><tr><td colspan=5><DD>#trim(ChargesDetail.ccomments)#</DD></td></tr></cfif>
				--->
			</cfloop>
			</table>
		</td>
	</tr>
	<tr style="font-weight: bold;">
		<td colspan="4"></td>
		<td style="#right#" nowrap> Invoice Total #LSCurrencyFormat(variables.TotalInvoice)# </td>	
	</tr>
</table>
</form>

</cfoutput>
<!--- Include Intranet footer --->
<cfinclude template="../../footer.cfm">
