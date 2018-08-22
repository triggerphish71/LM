 
<!--- *********************************************************************************************
Name:       MainMenu.cfm
Type:       Template
Purpose:    Set SESSION variables and display the main menu.

Called by: Index.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    URL.SelectedHouse_ID                House.aHouse_ID value of the house the user selected.

Calls: Tenant/Add.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    None

Calls: Tenant/Edit.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    URL.SelectedTenant_ID               Tenant.aTenant_ID value of the tenant the user selected.

Modified By      Date            Reason                                                             
-------------  -----------   -----------------------------------------------------------------------
C. Ebbott    |Oct 19, 2010|      New Original Authorship                                           |
S. Farmer    |Apr 20, 2012|      Updates for 75019 EFT/NRF-Deferral Changes                        |
 sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                      |
 sfarmer     | 09/24/2013 | 102919 - NRF/discount revision allows NRF Discount to process through  |
             |            | with followup approval                                                 |
             |            | and house canot approve NRF discount                                   |
S Farmer     | 03/05/2014 | 114729 - add to list of NRF discount Approvers                         |
S Farmer     | 05/20/2014 | 116824 - Move-In update                                                |
S Farmer     | 06/04/2014 | 116824 - dtmovein replaced by dtRentEffective                          |
********************************************************************************************** --->

<cfif NOT IsDefined("session.USERNAME") or NOT IsDefined("session.UserID") or isNumeric(session.userid) eq 'NO'>
<cflocation url="../Loginindex.cfm">
</cfif>

<cfinclude template="../header.cfm">

<cfinclude template="Shared/JavaScript/ResrictInput.cfm">
<!--- <cfinclude template="Shared/JavaScript/PageTimer.js">  --->


</script>

<cfparam name="IsApprover" default="">
<cfparam name="IsRejApprover" default="">
<!--- Create time stamp for template creation --->
<cfset stmp= DateFormat(now(),"mmddyy") & TimeFormat(now(),"HHmmss")>

<!--- Only Index.cfm can create URL.SelectedHouse_ID.  If it exists set SESSION variables. --->
<cfif not isDefined("url.SelectedHouse_id") and isDefined("session.qselectedhouse.ihouse_id")>
	<cfset url.SelectedHouse_id=session.qselectedhouse.ihouse_id>
</cfif>
<cftry>

<cfif  IsDefined("URL.SelectedHouse_ID") and url.SelectedHouse_ID neq '' 
		or not isDefined("session.TIPSMonth")>
    <cfquery  name="qHouse" datasource="#application.DataSource#">
		select  *
		from House H 
		join HouseLog HL  on (H.iHouse_ID = HL.iHouse_ID 
			and HL.dtRowDeleted is null 
			and H.dtRowDeleted is null)
		where H.iHouse_ID = #url.SelectedHouse_ID#
	</cfquery>

	<cfscript>
		CalcHouse = qhouse.cNumber - 1800;
		if (Len(CalcHouse) eq 2) { HouseNumber = '0' & CalcHouse; }
		else if (Len(CalcHouse) eq 1) { HouseNumber = '0' & '0' & CalcHouse; }
		else { HouseNumber = '#CalcHouse#'; }

   		session.qSelectedHouse = qHouse;
		session.HouseName = qhouse.cName;
		session.HouseNumber = '#HouseNumber#';
		session.nHouse = qhouse.cNumber;
		session.TIPSMonth = qhouse.dtCurrentTipsMonth;
		session.cSLevelTypeSet = qhouse.cSLevelTypeSet;
		session.HouseClosed	= qhouse.bIsPDclosed;
		session.cDepositTypeSet	= qHouse.cDepositTypeSet;
		session.cBillingType = trim(qHouse.cBillingType);

		//renew user session variables to renew timeout period.
		if (isDefined("session.userid")) {session.userid=session.userid;}
		if (isDefined("session.fullname")) {session.fullname=session.fullname;}
	</cfscript>
 
<!---  We did NOT arrive via Index.cfm.  Verify SESSION variables still exist. --->
<cfelseif  NOT  IsDefined("session.qSelectedHouse")>
	<cfset  UrlStatusMessage =  URLEncodedFormat("Please select a house.")>
	<cflocation url="Index.cfm?UrlStatusMessage=#UrlStatusMessage#" addtoken="NO">
</cfif>
	<cfcatch type="any">
<cfoutput>		session.userid=#session.userid#
	<br>session.fullname=#session.fullname#
	<br>url.SelectedHouse_ID:: #url.SelectedHouse_ID#
	<br>CalcHouse = #qhouse.cNumber#
		<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" 
			SUBJECT="MainMenuError">
		 session.userid=#session.userid#
		<br>session.fullname=#session.fullname#
		<br>url.SelectedHouse_ID:: #url.SelectedHouse_ID#
		<br>CalcHouse = #qhouse.cNumber#
		</CFMAIL></cfoutput>
	</cfcatch>
</cftry>
  
<!---  Retrieve the corresponding AREmail --->
<cfquery name="GetEmail" datasource="#application.datasource#">
	select Du.EMail as AREmail from House H
	join ALCWEB.dbo.employees DU on H.iAcctUser_ID = DU.Employee_ndx
	where H.iHouse_ID = #url.SelectedHouse_id#
</cfquery>

<cfset session.AREMAIL = GetEmail.AREMail>

<!--- <cfquery name="qryWhoAreYou" datasource="#application.datasource#">
Select cFullName, cUserName, cEMail, cROle, cScope 
  FROM maple.FTA.dbo.vw_UserAccounts 
  where cusername = '#session.username#'
</cfquery> --->

<cfquery name="qryARAnalyst" datasource="#application.datasource#">
	select ae.Employee_Ndx
      ,ae.nEmployeeNumber
      ,ae.nDepartmentNumber 
      ,ae.LName
      ,ae.FName
      ,ae.MName
      ,ae.JobTitle
      ,ae.nAccessStatus
      ,ae.EMail
from  #Application.AlcWebDBServer#.alcweb.dbo.employees ae  
		where  ae.Employee_Ndx =   '#session.userid#'
</cfquery>

<cfif FindNoCase( 'RDO',qryARAnalyst.jobtitle)> 
	<cfset  IsApprover = 'Y'>
<cfelseif FindNoCase('RDSM',qryARAnalyst.jobtitle )>
	<cfset  IsApprover = 'Y'>
<cfelseif FindNoCase('DVP',qryARAnalyst.jobtitle)>
	<cfset  IsApprover = 'Y'>	
<cfelseif FindNoCase('RDQCM',qryARAnalyst.jobtitle)>
	<cfset  IsApprover = 'Y'>	
<cfelseif FindNoCase( 'Regional Director of Marketing NJ',qryARAnalyst.jobtitle)>
	<cfset  IsApprover = 'Y'>	
<cfelseif FindNoCase( 'Regional Director of Sales & Market',qryARAnalyst.jobtitle)>
	<cfset  IsApprover = 'Y'>	
<cfelseif FindNoCase( 'Regional Director of QCS',qryARAnalyst.jobtitle)>
	<cfset  IsApprover = 'Y'>		
	
 <cfelseif session.userid is  4035 >
	<cfset  IsApprover = 'Y'>	
<cfelseif listcontains(session.groupid, 193)>
	<cfset  IsApprover = 'Y'>	
</cfif>
<cfif listcontains(session.groupid, 193)>
	<cfset  IsRejApprover = 'Y'>	
<cfelseif listcontains(session.groupid, 240)>
	<cfset  IsRejApprover = 'Y'>
</cfif>


<!---  Retrieve the corresponding RDO Email --->
<cfquery name="RDOEmail" datasource="#application.datasource#">
	select h.cname, ae.Email as RDOEmail
	from house h
	join opsarea o on o.iopsarea_id = h.iopsarea_id and o.dtrowdeleted is null
	join #Application.AlcWebDBServer#.alcweb.dbo.employees ae on ae.employee_ndx = o.idirectoruser_id
	where h.dtrowdeleted is null and h.ihouse_id = #url.SelectedHouse_id#
</cfquery>
<cfset session.RDOEMAIL = RDOEmail.RDOEmail>

<!--- Retreive List of all available apartments//added bIsMedicaid mamta  --->
<cfinclude template="Shared/Queries/AvailableApartments.cfm">
<cfquery name="bondhouse" datasource="#application.datasource#">
	select ibondhouse, bBondHouseType,bIsMedicaid from house  where ihouse_id =  #url.SelectedHouse_id#
</cfquery>
<!--- added bIsMedicaidEligible mamta  --->
<cfquery name="bondapt" datasource="#application.datasource#">
	select a.iaptAddress_ID,a.bIsBond,a.bIsMedicaidEligible from AptAddress a where a.iHouse_ID = #url.SelectedHouse_id#
</cfquery>
<!--- Get the tenants for the selected house along with other related information. --->
<cfquery name="qResidentTenants" datasource="#application.datasource#">
	select CASE LEN(ad.cAptNumber) 
				WHEN 1 THEN ('00' + ad.cAptNumber)
				WHEN 2 THEN ('0' + ad.cAptNumber) 
				ELSE ad.cAptNumber
			END as cAptNumber,t.iTenant_ID,
			apt.cDescription as cAptType ,t.iTenant_ID ,t.cSolomonKey ,t.cFirstName ,t.cLastName ,rt.cDescription as Residency
			,ts.dtMoveIn ,ts.dtMoveOut ,ts.iSPoints ,ts.dtRentEffective,st.cDescription as Level ,ts.iproductline_id, ts.bNRFPend 
			,pl.iproductline_id aptproductline
			,AD.bIsBond
			,AD.bIsMedicaidEligible
			,TPS.cDescription as promotions
			,ARB.custID, (arb.currbal + arb.futurebal) as currbal, 
			case WHEN t.iTenant_ID is null then NULL else sum(IsNull(tlf.mLateFeeAmount,0))-IsNull(PartialPayment,0) end as LateFee
			, rt.iResidencyType_ID
			,ts.cNRFDiscAppUsername
	from AptAddress AD 
	left join houseproductline hpl on hpl.ihouseproductline_id = ad.ihouseproductline_id and hpl.dtrowdeleted is null
	left join productline pl on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
	left outer join	AptType APT on (apt.iAptType_ID = ad.iAptType_ID and apt.dtRowDeleted is null)
	left join	TenantState ts  on ad.iAptAddress_ID = ts.iAptAddress_ID and (ts.iTenantStateCode_ID is null or ts.iTenantStateCode_ID = 2 and ts.dtRowDeleted is null)		

	left join Tenant t  on (t.iTenant_ID = ts.iTenant_ID)
	left join	ResidencyType RT on (rt.iResidencyType_ID = ts.iResidencyType_ID)
	left join SLevelType ST on (t.cSlevelTypeSet = st.cSlevelTypeSet and ts.iSPoints <= iSPointsMax and ts.iSPoints >= iSPointsMin)
	left join TenantPromotionSet TPS on (ts.cTenantPromotion = TPS.iPromotion_ID)
	left join #Application.HOUSES_APPDBServer#.HOUSES_APP.dbo.ar_balances arb on (arb.custid = t.cSolomonKey)
	left join TenantLateFee tlf on (tlf.iTenant_id = t.iTenant_id)
		 	  AND (tlf.bpaid is null OR tlf.bPaid = 0)
		  	  AND (tlf.bAdjustmentDelete is Null or tlf.bAdjustmentDelete = 0)
			  AND tlf.dtrowdeleted is null
	left join (select Sum(tla.mLateFeePartialPayment) as PartialPayment, tla.iTenant_id
					from dbo.TenantLateFeeAdjustmentDetail tla
					join invoicedetail ind
					on tla.iinvoicedetail_id = ind.iinvoicedetail_id
					Where tla.iInvoiceLateFee_ID in (SELECT iInvoiceLateFee_ID
										FROM TenantLateFee tlf
										join Tenant t
										on t.iTenant_id = tlf.iTenant_id
										join TenantState ts
										on ts.iTenant_id = t.iTenant_id
										WHERE  t.ihouse_id =#url.SelectedHouse_id#
											  AND bPartialPaid = 1
										      AND t.dtrowdeleted is null
										      AND (tlf.bpaid is null OR tlf.bPaid = 0)
											  AND (tlf.bAdjustmentDelete is Null or tlf.bAdjustmentDelete = 0)
										      AND tlf.dtrowdeleted is null
											  AND (ts.iTenantStateCode_ID is null or ts.iTenantStateCode_ID IN (2))
											  AND ts.dtrowdeleted is null)
                     and tla.dtrowdeleted is null
					 and ind.dtrowdeleted is null											 
				Group by tla.iTenant_id) as PLF on (PLF.itenant_id = t.itenant_id)
	where	ad.dtRowDeleted is null	and ad.iHouse_ID = #url.SelectedHouse_id#	and t.dtRowDeleted is null
	and (ts.iTenantStateCode_ID is null or ts.iTenantStateCode_ID IN (2)) 
	group by
			cAptNumber,
			apt.cDescription ,t.iTenant_ID ,t.cSolomonKey ,t.cFirstName ,t.cLastName ,rt.cDescription
			,ts.dtMoveIn ,ts.dtMoveOut ,ts.iSPoints,ts.dtRentEffective ,st.cDescription ,ts.iproductline_id
			,pl.iproductline_id
			,AD.bIsBond
			,TPS.cDescription
			,ARB.custID, arb.currbal, arb.futurebal, PLF.PartialPayment, rt.iResidencyType_ID,  ts.bNRFPend, ts.cNRFDiscAppUsername 
            ,AD.bIsMedicaidEligible
	<cfif NOT IsDefined("URL.SelectedSortOrder")  or  URL.SelectedSortOrder eq "Apt">
		<cfif #url.SelectedHouse_id# eq 231 or #url.SelectedHouse_id# eq 215>
			order by cAptNumber asc
		<cfelse>
			order by ad.cAptNumber asc
		</cfif>
	<cfelseif URL.SelectedSortOrder eq "Id"> order by isNull(t.cSolomonKey,'zzzz'), ad.cAptNumber
	<cfelseif URL.SelectedSortOrder eq "Name"> order by isNull(t.cLastName,'zzzz'), t.cFirstName, ad.cAptNumber
	<cfelseif URL.SelectedSortOrder eq "Type"> order by isNull(rt.cDescription,'zzzz'), ad.cAptNumber
	<cfelseif URL.SelectedSortOrder eq "Points"> order by ts.iSPoints desc, ad.cAptNumber
	<cfelseif URL.SelectedSortOrder eq "MoveIn"> order by ts.dtMoveIn desc, ad.cAptNumber
	<cfelseif URL.SelectedSortOrder eq "MoveOut"> order by ts.dtMoveOut desc, ad.cAptNumber
	<cfelseif URL.SelectedSortOrder eq "LastBalance"> order by (arb.currbal + arb.futurebal) desc, ad.cAptNumber
	<cfelseif URL.SelectedSortOrder eq "LateFee"> order by 
	case WHEN t.iTenant_ID is null 
	then NULL 
	else sum(IsNull(tlf.mLateFeeAmount,0))-IsNull(PartialPayment,0) 
	end desc, ad.cAptNumber
	<cfelseif URL.SelectedSortOrder eq "PaymentsSince"> order by t.cLastName, t.cFirstName, ad.cAptNumber
	<cfelseif URL.SelectedSortOrder eq "CurrentCharges"> order by t.cLastName, t.cFirstName, ad.cAptNumber
	<cfelseif URL.SelectedSortOrder eq "Bond"> order by AD.bIsBond desc, ad.cAptNumber, t.cLastName, t.cFirstName 
	<cfelseif URL.SelectedSortOrder eq "Medicaid"> order by AD.bIsMedicaidEligible desc, ad.cAptNumber, t.cLastName, t.cFirstName 
	</cfif>
</cfquery>

<!--- Retrieve the information for Moved Out Tenants --->
<cfquery name="MovedOut" datasource="#application.datasource#">
	select cSolomonKey, dtMoveOut, ItenantStateCode_ID, apt.cDescription as cAptType, rt.cDescription as Residency,
	cAptnumber, cFirstName, cLastName, isPoints, cSLevelTypeSet, T.itenant_ID, DTMoveIn, dtRentEffective
	,TPS.cDescription as promotions, (arb.currbal + arb.futurebal) as currbal
	from Tenant t
	join TenantState ts  on (t.iTenant_ID = ts.iTenant_ID and ts.dtRowDeleted is null and t.dtRowDeleted is null and ts.iTenantStateCode_ID IN (3,4))
	join ResidencyType RT  on (rt.iResidencyType_ID = ts.iResidencyType_ID and rt.dtRowDeleted is null)
	join rw.vw_aptAddress_History AD on (ad.iAptAddress_ID = ts.iAptAddress_ID and ts.dtRowStart between ad.dtRowStart and isNull(ad.dtRowEnd,getdate()))
	join AptType APT  on (apt.iAptType_ID = ad.iAptType_ID and apt.dtRowDeleted is null)
	left join TenantPromotionSet TPS  on (ts.cTenantPromotion = TPS.iPromotion_ID)
	left join #Application.HOUSES_APPDBServer#.HOUSES_APP.dbo.ar_balances arb on (arb.custid = t.cSolomonKey)
	where t.iHouse_ID = #url.SelectedHouse_id#
	<cfif url.SelectedHouse_id eq 200>
		and ( (ts.dtRowStart between DateAdd(day, -1, getdate()) and DateAdd(day, 1, getdate()) and ts.iTenantStateCode_ID = 4) 
	  or (ts.iTenantStateCode_ID = 3 and t.iHouse_ID = #url.SelectedHouse_id#) )
	<cfelse>
		and ( (ts.dtRowStart between DateAdd(day, -14, getdate()) and DateAdd(day, 14, getdate()) and ts.iTenantStateCode_ID = 4) 
		or (ts.iTenantStateCode_ID = 3 and t.iHouse_ID = #url.SelectedHouse_id#) ) 
	</cfif>
</cfquery>

<cfquery name="HouseStatus" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,0,1,0)#">
	select iHouseLog_ID,iHouse_ID,dtCurrentTipsMonth,bIsPDclosed,bIsOpsMgrClosed,dtActualEffective,cComments,dtAcctStamp,iRowStartUser_ID,dtRowStart
	from	HouseLog 
	where dtRowDeleted is null and iHouse_ID = #url.SelectedHouse_id#
</cfquery>

<cfif listfindNocase(session.codeblock,21) gte 1 and listfindNocase(session.codeblock,23) eq 0>
	<cfquery name="qNoTenantsCheck" datasource="#application.datasource#">
		select t.iTenant_ID from Tenant t 
		join TenantState ts  on (t.iTenant_ID = ts.iTenant_ID and ts.dtRowDeleted is null)
		where	t.dtRowDeleted is null and bIsMedicaid is null and bIsMisc is null and bIsDayRespite is null
		and ts.iTenantStateCode_ID = 2 and ihouse_ID = #url.SelectedHouse_id# 
	</cfquery>
	
	<cfif qNoTenantsCheck.RecordCount lt 1 or Year(session.TIPSMonth) eq '2001'>
		<cflocation url="Reports/Menu.cfm?activex=1">
	</cfif>
</cfif>

<title> Tips 4-Main Menu </title>
<body>

 

<!--- Display any status message. --->
<cfif  isDefined("URL.UrlStatusMessage") and Len(URL.UrlStatusMessage)  gt  0>
	<div class="UrlStatusMessage"> <cfoutput> #URL.UrlStatusMessage# </cfoutput> </div><br/>
</cfif>

<h1 class="PageTitle"> Tips 4 - TIPS Summary </h1>

<cfinclude template="Shared/HouseHeader.cfm">
<CFINCLUDE TEMPLATE="Shared/HouseSummary.cfm"><br/>
		
			<!--- Count of current bond designated apts --->
			<cfquery name="bAptCount" datasource="#APPLICATION.datasource#">
				select count(AA.iAptAddress_ID) as B 
				from AptAddress AA 
				where AA.bIsBond = 1
				and AA.dtrowdeleted is null
				and AA.iHouse_ID = #url.SelectedHouse_id#
			</cfquery>
			<!--- Count of apts that were built and apply to the bond designation --->
			<cfquery name="AptCountTot" datasource="#APPLICATION.datasource#">
				select count(AA.iAptAddress_ID) as T 
				from AptAddress AA 
				where AA.iHouse_ID = #url.SelectedHouse_id#
				and AA.bBondIncluded = 1
				and AA.dtrowdeleted is null
			</cfquery>
			<!--- Count of apt designated as medicaideligible-- mamta --->
			<cfquery name="AptcountMedicaid" datasource="#APPLICATION.datasource#">
				select count(AA.iAptAddress_ID) as MedicaidEligible 
				from AptAddress AA 
				where AA.bIsMedicaidEligible = 1
				and AA.dtrowdeleted is null
				and AA.iHouse_ID = #url.SelectedHouse_id#
			</cfquery>
			<!--- Count of total apt mamta --->
			<cfquery name="AptcountTotal" datasource="#APPLICATION.datasource#">
				select count(AA.iAptAddress_ID) as TotalAPT 
				from AptAddress AA 
				where  AA.dtrowdeleted is null
				and AA.iHouse_ID = #url.SelectedHouse_id#
			</cfquery>
			<!--- Apartment addresses that are occupied and pertain to bond applicable --->
			<cfquery name="Occupied" datasource="#APPLICATION.datasource#">
				select distinct TS.iAptAddress_ID
				from AptAddress aa, tenant te, TenantState TS  
				join Tenant T on (T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null)
				join AptAddress AD on (AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null)
				where TS.dtRowDeleted is null
				and TS.iTenantStateCode_ID = 2
				and AD.iHouse_ID = #url.SelectedHouse_id#
				and TS.iAptAddress_ID = aa.iAptAddress_ID 
				and te.iTenant_ID = ts.iTenant_ID
				and aa.bBondIncluded = 1
			</cfquery>
			<cfset OccupiedRowCount = (Occupied.recordcount)>
			<cfif bondhouse.ibondhouse eq 1>
				<cfif bondhouse.bBondHouseType eq '1'><!--- Percent by total units --->
					<cfset Percent = ((#bAptCount.B# / #AptCountTot.T#) * 100)>
					<cfif Percent LT 20>
						<cfset bhtml="<font color='FF3300'>#NumberFormat(Percent, '__.__')#%</font></b>">
					<cfelse>
						<cfset bhtml="<font color='7CFC00'>#NumberFormat(Percent, '__.__')#%</font></b>">
					</cfif>
				<cfelse><!--- Percent by occupied --->
					<cfset Percent = ((#bAptCount.B# / OccupiedRowCount) * 100)>
					<cfif Percent LT 20>
						<cfset bhtml="<b><font color='FF3300'>#NumberFormat(Percent, '__.__')#%</font></b>">
					<cfelse>
						<cfset bhtml="<font color='7CFC00'>#NumberFormat(Percent, '__.__')#%</font></b>">
					</cfif>
				</cfif> 
		  </cfif>
		  <cfif #bondhouse.bIsMedicaid# eq 1>
		      <cfset medicaidpercent= ((#AptcountMedicaid.MedicaidEligible#/#AptcountTotal.TotalAPT#)*100)>
		  	  <cfif medicaidpercent LT 20>
				<cfset bhtmlMedicaid="<font color='FF3300'>#NumberFormat(medicaidpercent, '__.__')#%</font></b>">
			  <cfelse>
				<cfset bhtmlMedicaid="<font color='7CFC00'>#NumberFormat(medicaidpercent, '__.__')#%</font></b>">
			  </cfif>	
		  </cfif>     
<cfscript>
	//Hide the menubar if there are now tenants and the user is not part of accounting
	if (qResidentTenants.RecordCount eq 0 and ListFindNoCase(session.CodeBlock, 23, ",") eq 0) {HIDE='hidden'; }
	else{ HIDE='visible'; }
	
	if (HouseStatus.bIsPDClosed eq "" or ListFindNoCase(session.Codeblock,23) gte 1) { Action = 'Charges/Charges.cfm'; }
	else {Action = 'MonthClosed.cfm';}
</cfscript>

<table>
	<tr>
	<th>
	<a href="?SelectedSortOrder=Apt" style="color: White;" onMouseOver="hoverdesc('Sort by Apartment Number');" onMouseOut="resetdesc();"> Apt </a> 
	</th>
	<th>
	<a href="?SelectedSortOrder=Id" style="color: White;" onMouseOver="hoverdesc('Sort by Apartment Type');" onMouseOut="resetdesc();"> Type </a> 
	</th>
	<th>
	<a href="?SelectedSortOrder=Id" style="color: White;" onMouseOver="hoverdesc('Sort by Resident ID');" onMouseOut="resetdesc();"> RID </a> 
	</th>
	<th>
	<a href="?SelectedSortOrder=Name" style="color: White;" onMouseOver="hoverdesc('Sort by Name');" onMouseOut="resetdesc();"> Name </a> 
	</th>
	<cfif bondhouse.bIsMedicaid eq 1>
	<th nowrap>
	<a href="?SelectedSortOrder=Medicaid" style="color: White;" onMouseOver="hoverdesc('Sort By Medicaid Apt');" onMouseOut="resetdesc();"> Medicaid APT<cfoutput>#bhtmlMedicaid#</cfoutput> </a>&nbsp;&nbsp;
	</th> 
	</cfif>
	<cfif bondhouse.ibondhouse eq 1>
	<th nowrap>
	<a href="?SelectedSortOrder=Bond" style="color: White;" onMouseOver="hoverdesc('Sort By Bond Apt');" onMouseOut="resetdesc();"> BOND APT <cfoutput>#bhtml#</cfoutput> </a>&nbsp;&nbsp;
	</th> 
	</cfif>
	<th>
	<a href="?SelectedSortOrder=Type" style="color: White;" onMouseOver="hoverdesc('Sort by Residency Type');" onMouseOut="resetdesc();"> Type </a> 
	</th>
	<th>
	<a href="?SelectedSortOrder=Points" style="color: White;" onMouseOver="hoverdesc('Sort by Service Points');" onMouseOut="resetdesc();"> SPts. </a>
	 </th>
	<th>
	<a href="?SelectedSortOrder=MoveIn" style="color: White;" onMouseOver="hoverdesc('Sort by Financial Possession Date');" onMouseOut="resetdesc();">Financial Possession Date <!--- Physical Move-In Date  ---></a> 
	</th>
	<th>
<a href="?SelectedSortOrder=MoveOut" style="color: White;" onMouseOver="hoverdesc('Sort by Move Out date');" onMouseOut="resetdesc();"> MoveOut </a> 
	</th>
	<th nowrap> 
	<a href="?SelectedSortOrder=LastBalance" style="color: White;" onMouseOver="hoverdesc('Sort by Current Balance');" onMouseOut="resetdesc();"> Curr. Bal. </a> 
	</th>
	<th nowrap> 
	<a href="?SelectedSortOrder=LateFee" style="color: White;" onMouseOver="hoverdesc('Sort by Late Fee');" onMouseOut="resetdesc();"> Late Fee </a>
	 </th>
	<cfoutput>
		<cfset Month = DateAdd("m", +1,"#Now()#")>
		<th nowrap> 
		<a href="?SelectedSortOrder=PaymentsSince" style="color: White;" onMouseOver="hoverdesc('Sort by Charges  ');" onMouseOut="resetdesc();"> #DateFormat(Session.TIPSMonth,"mmm")#<br>Charges </a> 
		</th>
	</cfoutput>
	<th nowrap><u>Promotions</u></th>
	<th nowrap><u>Missing<br>Items</u> </th>
	<th>&nbsp;&nbsp;&nbsp;<u>Collection<br>Notes</u> </th>
	</tr>

	<!--- Now display all of the rows from our query. --->
	<cfquery name="TotalCharges" datasource="#application.datasource#">
		select	ad.cAptNumber, t.iTenant_ID, isNULL(Sum(iQuantity * mAmount),0) as sum
		from Tenant t 
		join TenantState ts  on (ts.iTenant_ID = t.iTenant_ID and ts.dtRowDeleted is null and ts.iTenantStateCode_ID = 2)
		and t.iHouse_ID = #url.SelectedHouse_id#
		join InvoiceMaster IM  on im.csolomonkey = t.csolomonkey and IM.dtRowDeleted is null 
		and IM.bFinalized is null and IM.cAppliesToAcctPeriod = '#Year(session.TIPSMonth)##DateFormat(session.TIPSMonth, "mm")#'
		and IM.bMoveInInvoice is null and IM.bMoveOutInvoice is null 
		left join InvoiceDetail INV on INV.iinvoicemaster_id = im.iinvoicemaster_id and INV.dtRowDeleted is null
		join ChargeType CT  on INV.iChargeType_ID = Ct.iChargeType_ID and Ct.dtRowDeleted is null
		and Ct.cGLAccount <> 3012 and Ct.cGLAccount <> 3016
		join AptAddress AD  on ad.iAptAddress_ID = ts.iAptAddress_ID and ad.dtRowDeleted is null
		group by t.iTenant_ID, ad.cAptNumber
		order by cAptNumber
	</cfquery>
	<cfset TenantList=ValueList(TotalCharges.iTenant_ID)>
	<cfset TenantTotal=ValueList(TotalCharges.sum)>

	<cfoutput query="qResidentTenants">
		<cfscript>
			if (qResidentTenants.dtMoveIn neq ""){ ROW=''; MoveInCheck='';}
			else if (qResidentTenants.iTenant_ID neq "") { ROW="font-weight: bold;"; MoveInCheck="background: lightyellow; color: red;";}
			else {ROW=''; MoveInCheck='';}
		</cfscript>
		
		<cfif qResidentTenants.aptproductline eq 2>
			<cfset atc="class='memcare'">
		<cfelse>
			<cfset atc=''>
		</cfif>
		<cfif qResidentTenants.iproductline_id eq 2>
			<cfset tc="title='#qResidentTenants.cLastName#, #qResidentTenants.cFirstName# - memory care' class='memcare'">
		<cfelse>
			<cfset tc=''>
		</cfif>
	 <cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE"> 
			<td #atc#> #qResidentTenants.cAptNumber# </td>
			<td nowrap> #trim(qResidentTenants.cAptType)# </td>
			<td> #qResidentTenants.cSolomonKey# </td>
			<td nowrap> 
				<a href="Tenant/TenantEdit.cfm?ID=#qResidentTenants.iTenant_ID#" #tc#>
					<cfif qResidentTenants.cLastName neq ""> #qResidentTenants.cLastName#, #qResidentTenants.cFirstName# </cfif>
				</a>
			</td>
			<cfif bondhouse.bIsmedicaid eq 1> 
				<cfif #qResidentTenants.bIsMedicaidEligible# eq 1>
				<td style="text-align:center"><b>Medicaid</b></td>
				<cfelse>
				<td style="text-align:center"></td>
				</cfif>
			</cfif>
			<cfif bondhouse.ibondhouse eq 1> 
				<cfif #qResidentTenants.bIsBond# eq 1>
				<td style="text-align:center"><b>Bond</b></td>
				<cfelse>
				<td style="text-align:center"></td>
				</cfif>
			</cfif>
			<cfif qResidentTenants.iResidencyType_ID EQ 3>
				 <cfquery name="GetRespiteColor" datasource="#application.datasource#">
					Select case when (getdate() between im.dtInvoiceStart and im.dtInvoiceEnd) then
						'Yes' else 'No' end INVAnswer
					from InvoiceMaster im
					where im.cSolomonKey = '#qResidentTenants.cSolomonKey#'
					and im.dtrowdeleted is null
					and (getdate() between im.dtInvoiceStart and im.dtInvoiceEnd)
					and im.bFinalized = 1
				</cfquery>
				
				<cfif GetRespiteColor.INVAnswer eq 'Yes'>
					<cfset RespiteColor = 'green'>
				<cfelse>
					<cfset RespiteColor = 'red'>
				</cfif>
				<a href="RespiteInvoicing/RespiteInvoice.cfm?SolID=#qResidentTenants.cSolomonKey#" #tc#>
					<td style="text-decoration:underline;color:'#RespiteColor#';" >
						#qResidentTenants.Residency#
					</td> 
				</a><hr>
			<cfelse>
				<td> #qResidentTenants.Residency# </td>   
			</cfif>           
			<td style="text-align: center;"> 
				<cfif qResidentTenants.iSPoints neq ""> #qResidentTenants.iSPoints#
				<cfelseif qResidentTenants.iTenant_ID neq "" and qResidentTenants.iSPoints eq "">
					<i style="color: red;" onMouseOver="alert('The service points for (#qResidentTenants.cFirstName# #qResidentTenants.cLastName#) is missing. \r Please update the service points information.');">Missing</i>
				</cfif>
			</td>
			
			<cfif  ((qResidentTenants.bNRFPend is 1)  and  (SESSION.qSelectedHouse.iopsarea_ID is  99))>
				 <cfif IsApprover is 'Y'>
					<td style="width: 5%;  text-align: center;  color:red;"  > 
						<Cfset namebreakcnt = find(",", qResidentTenants.cNRFDiscAppUsername) -1>
						<cfif namebreakcnt gt 0>
						<cfset thislastname = left(#qResidentTenants.cNRFDiscAppUsername#,namebreakcnt)>
						<cfelse>
						<cfset thislastname = qResidentTenants.cNRFDiscAppUsername>
						</cfif> 
						<a href="MoveIn/FinalizeMoveInPend.cfm?ID=#qResidentTenants.iTenant_ID#" style="color:red">NRF APPROVAL REQUIRED</a><br>
						#thislastname#
					</td>
				<cfelse>
					<td style="width: 5%;  text-align: center; color:red;" > 
						<Cfset namebreakcnt = (find(",", qResidentTenants.cNRFDiscAppUsername)) -1>
						<cfif namebreakcnt lte 0 > 
							 NRF APPROVAL REQUIRED<br>N/A
					  	<cfelse>
							<cfset thislastname = left(#qResidentTenants.cNRFDiscAppUsername#,namebreakcnt)>
							  NRF APPROVAL REQUIRED<br>#thislastname#
					 	</cfif>
					</td>
				</cfif>
			<cfelseif ((qResidentTenants.bNRFPend is 0)  and (SESSION.qSelectedHouse.iopsarea_ID is  99))>
				<cfif IsRejApprover is 'Y'>
					<td style="width: 5%;  text-align: center; color:red;" > 
					
						<Cfset namebreakcnt = find(",", qResidentTenants.cNRFDiscAppUsername) -1>
						<cfif namebreakcnt gt 0>
							<cfset thislastname = left(#qResidentTenants.cNRFDiscAppUsername#,namebreakcnt)>
						<cfelse>
							<cfset thislastname = qResidentTenants.cNRFDiscAppUsername>
						</cfif>
						<a href="MoveIn/ReviseMoveIn.cfm?ID=#qResidentTenants.iTenant_ID#" style="color:red">NRF ADJUSTMENT APPROVAL IS REJECTED</a>
							 <!--- <br>#thislastname#<br>#qryWhoAreYou.cROle#<br>#qryARAnalyst.JobTitle# --->
					</td>
					 <!--- onMouseOver="shwrejmsg(#qResidentTenants.iTenant_ID#)" --->
				<cfelse >
					<td style="width: 5%;  text-align: center; color:red;" > 
						
						<Cfset namebreakcnt = find(",", qResidentTenants.cNRFDiscAppUsername) -1>
						<cfif namebreakcnt gt 0>
						<cfset thislastname = left(#qResidentTenants.cNRFDiscAppUsername#,namebreakcnt)>
						<cfelse>
						<cfset thislastname = qResidentTenants.cNRFDiscAppUsername>
						</cfif>
							  NRF ADJUSTMENT APPROVAL IS REJECTED
					</td>
				</cfif>
			<cfelse>
<!--- 				<cfif SESSION.qSelectedHouse.iopsarea_ID is  44> --->
				<td style="width: 5%; text-align: center; #MoveInCheck#">
						<cfif trim(qResidentTenants.dtRentEffective) neq "">
							<a href="Reports/MoveInReportA.cfm?prompt0=#qResidentTenants.iTenant_ID#">#DATEFORMAT(qResidentTenants.dtRentEffective, "mm/dd/yyyy")#</a>
						<cfelseif qResidentTenants.iTenant_ID neq "">
							<i onMouseOver="alert('The move in date for (#qResidentTenants.cFirstName# #qResidentTenants.cLastName#) is missing. \r Please give the date to your AR Specialist for IT to update.');">Missing</i>
						</cfif>
				</td>			
<!--- 				<cfelse>
				<td style="width: 5%; text-align: center; #MoveInCheck#">
						<cfif trim(qResidentTenants.dtRentEffective) neq "">
							<a href="MoveIn/MoveInReport.cfm?ID=#qResidentTenants.iTenant_ID#">#DATEFORMAT(qResidentTenants.dtRentEffective, "mm/dd/yyyy")#</a>
						<cfelseif qResidentTenants.iTenant_ID neq "">
							<i onMouseOver="alert('The move in date for (#qResidentTenants.cFirstName# #qResidentTenants.cLastName#) is missing. \r Please give the date to your AR Specialist for IT to update.');">Missing</i>
						</cfif>
				</td>		
				</cfif> --->		
            </cfif>			
			
<!--- 			<cfif qResidentTenants.bNRFPend is 1>
				<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0) or (listfindNocase(session.codeblock,21) gte 1 and listfindNocase(session.codeblock,23) eq 0)>
					<td style="width: 5%;  text-align: center;" > 
					
						<Cfset namebreakcnt = find(",", qResidentTenants.cNRFDiscAppUsername) -1>
						<cfif namebreakcnt gt 0>
						<cfset thislastname = left(#qResidentTenants.cNRFDiscAppUsername#,namebreakcnt)>
						<cfelse>
						<cfset thislastname = qResidentTenants.cNRFDiscAppUsername>
						</cfif>
							 <a href="MoveIn/FinalizeMoveInPend.cfm?ID=#qResidentTenants.iTenant_ID#" style="color:red">PENDING NRF APPROVAL</a><br>#thislastname#
					</td>
				<cfelse>
					<td style="width: 5%;  text-align: center;" > 
					
						<Cfset namebreakcnt = find(",", qResidentTenants.cNRFDiscAppUsername) -1>
						<cfset thislastname = left(#qResidentTenants.cNRFDiscAppUsername#,namebreakcnt)>
							 PENDING NRF APPROVAL<br>#thislastname#
					</td>
				</cfif>
			<cfelse>
				<td style="width: 5%; text-align: center; #MoveInCheck#">

						<cfif trim(qResidentTenants.dtMoveIn) neq "">
							<a href="MoveIn/MoveInReport.cfm?ID=#qResidentTenants.iTenant_ID#">#DATEFORMAT(qResidentTenants.dtMoveIn, "mm/dd/yyyy")#</a>
						<cfelseif qResidentTenants.iTenant_ID neq "">
							<i onMouseOver="alert('The move in date for (#qResidentTenants.cFirstName# #qResidentTenants.cLastName#) is missing. \r Please give the date to your AR Specialist for IT to update.');">Missing</i>
						</cfif>
				</td>			
            </cfif> --->
			<cfif qResidentTenants.dtMoveOut neq "">
				<td style="text-align: center;">
					<input class="MoveOutButton" type="button" name="Pending" VALUE="Pending" style="color: blue;" 
					onClick="self.location.href='MoveOut/MoveOutForm.cfm?ID=#qResidentTenants.iTenant_ID#&edit=1'">
				</td>
			<cfelseif qResidentTenants.iTenant_ID neq "">
				<td style="text-align: center;">
					<input class="MoveOutButton" type="button" name="MoveOut" VALUE="MoveOut" 
					onClick="self.location.href='MoveOut/MoveOutForm.cfm?ID=#qResidentTenants.iTenant_ID#'">
				</td>
			<cfelse> <td></td> </cfif>
						
			<td style="text-align: right;">
				<cfif url.SelectedHouse_id neq 200>
					<cfif qResidentTenants.iTenant_ID neq "">
					<a href="Reports/CustomerTrialBalance.cfm?prompt0=#qResidentTenants.cSolomonKey#">#LSCurrencyFormat(qResidentTenants.CurrBal)#</a>
					<cfelse> &nbsp;	</cfif>
				<cfelseif qResidentTenants.iTenant_ID neq ""> ZetaTest </cfif>
			</td>
				<td style="text-align: center;">
				<cfif qResidentTenants.itenant_id neq ""> <!--- Check to see if room is occupied --->
				 <a href="Charges/DisplayLateFee.cfm?ID=#qResidentTenants.iTenant_ID#">
					#LSCurrencyFormat(qResidentTenants.LateFee)#
				</a>
				</cfif>
				</td>
		
			<cfif qResidentTenants.iTenant_ID neq "">
				<cfif ListFindNoCase(TenantList, qResidentTenants.iTenant_ID, ",") gt 0>
					<cfset pos=ListFindNoCase(TenantList, qResidentTenants.iTenant_ID, ",")>
					<td style="text-align: right;">
						<cftry> #LSCurrencyFormat(ListGetAt(TenantTotal, pos, ","))#  
						<cfcatch type="ANY"> #Len(TenantTotal)# == #TenantTotal# </cfcatch> 
						</cftry>
					</td>
				<cfelse>
					<td style="text-align: right;"> #LSCurrencyFormat(0.00)# </td>
				</cfif>
       		<cfelse> 
				<td>&nbsp;</td> 
			</cfif>

		<td style="text-align: center;" nowrap> #Left(qResidentTenants.promotions, 20)# </td>

	<cfif qResidentTenants.itenant_id neq "">
			<cfquery name="MissingItems" datasource="#application.datasource#">
				select distinct
				CASE WHEN len(isnull(t.cssn,1)) < 9 or len(isnull(t.cssn,1)) = 10 or len(isnull(t.cssn,1)) > 11 
					or (len(isnull(t.cssn,1)) = 9 and isnull(t.cssn,1) not LIKE '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%')
					or (len(isnull(t.cssn,1)) = 11 
					and isnull(t.cssn,1) not LIKE '%[0-9][0-9][0-9][-/ ][0-9][0-9][-/ ][0-9][0-9][0-9][0-9]%')
					THEN 1 ELSE 0 end +
				CASE WHEN t.dbirthDate is null THEN 1 ELSE 0 end +
				CASE WHEN t.cResidenceAgreement is null THEN 1 ELSE 0 end  +
				CASE WHEN ts.cMilitaryVA is null THEN 1 ELSE 0 end  +
				CASE WHEN ( select ibondhouse from house  where ihouse_id = #session.qSelectedHouse.iHouse_ID#)=1 
							and (select cBondHouseEligible from tenantstate where itenant_id = #qResidentTenants.itenant_id# 
							and dtrowdeleted is null) is null THEN 1 ELSE 0 end +
				CASE WHEN isnull(lt2.bIsPayer,0) = 1 and lt2.bIsGuarantorAgreement is null  THEN 1 ELSE 0 end  +
				CASE WHEN isnull(ts.bContractManagementAgreement,0)= 0 THEN 1 ELSE 0 end as countme
				from tenant t
				left join Tenantstate ts  on ts.iTenant_ID = t.iTenant_ID and ts.dtrowdeleted is null
				left join (select itenant_id,bIsGuarantorAgreement,bIsPayer from  LinkTenantContact 
		  					where itenant_id = #qResidentTenants.itenant_id# and bIsPayer = 1 
							and dtrowdeleted is null) lt2 on (lt2.Itenant_id = t.itenant_id ) 
				where t.itenant_id = #qResidentTenants.itenant_id#
				and t.dtrowdeleted is null
			</cfquery>
		   	<cfif MissingItems.countme neq 0 >
				<td style="text-align: center;"> 
					<a href="Tenant/MissingTenantItems.cfm?HouseID=#session.qSelectedHouse.iHouse_ID#"> #MissingItems.countme#</a>   
			   </td>
			<cfelse>
				<td style="text-align: center;"></td>
			</cfif>
			<td>
				<input type="button" value="View" onclick='window.open("Tenant/CollectionNotes.cfm?SolID=#qResidentTenants.cSolomonkey#","Notes",
				"toolbar=no,width=900,height=600,resizable=yes,scrollbars= yes,top=10, left=150 ");'>
			</td>
	<cfelse>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</cfif>
	
	    </cf_ctTR>
    </cfoutput>
	
		<tr><td colspan="100%" style="background: lightsteelblue; text-align: center;"><B style="font-size: 16;">Moved Out Residents</B></td></tr>
	
	<!--- Start of the Moved out Section --->
	<cfoutput query="MovedOut">
		
		<cfif (MovedOut.dtMoveOut GTE DateAdd("m",-1,session.TIPSMonth))
				or 
			(MovedOut.dtMoveOut neq "" and MovedOut.iTenantStateCode_ID IS 3)>

		<cf_cttr colorOne="E6E6FA" colorTwo="E6E6F0">
			<td> #MovedOut.cAptNumber# </td>
			<td> #trim(MovedOut.cAptType)# </td>
			<td> #MovedOut.cSolomonKey# </td>
			<td> #MovedOut.cFirstName# #MovedOut.cLastName# </td>
			<td> #MovedOut.Residency# </td>
			<td style="text-align: center;" nowrap> #MovedOut.iSPoints# / #MovedOut.cSLevelTypeSet# </td>
			<td> <a href="Reports/MoveInReportA.cfm?prompt0=#MovedOut.iTenant_ID#"> #DATEFORMAT(MovedOut.dtRentEffective, "mm/dd/yyyy")# </a> </td>
			
			<cfif ListFindNoCase(session.codeblock,23) or ListFindNoCase(session.codeblock,24) or ListFindNoCase(session.codeblock,25)>
				<td>	
					<cfscript> if (MovedOut.iTenantStateCode_ID eq 4) { Button='Approved'; } 
					else { Button='#DATEFORMAT(MovedOut.dtMoveOut, "mm/dd/yyyy")#'; } </cfscript>
					<input type="button" name="MoveOut" VALUE="#Button#" style="color: blue; font-size: xx-small; width: 65px; height: 20px;
					 text-align: center; vertical-align: middle;" 
					 onClick="self.location.href='MoveOut/MoveOutFormSummary.cfm?ID=#MovedOut.iTenant_ID#'">
				</td>
			<cfelse>
				<cfif MovedOut.iTenantStateCode_ID eq 4>
					<td ID="modate#MovedOut.iTenant_ID#" style="font-size:12; text-align: center;" 
					onMouseOver="hoverdesc('#DATEFORMAT(MovedOut.dtMoveOut, 'mm/dd/yyyy')#');" 
					onMouseOut="resetdesc();"> Approved </td>
				<cfelse>
					<cfquery name="qGetMOInvoice" datasource="#application.datasource#">
					select distinct im.iinvoicemaster_id
					from invoicemaster im 
					join invoicedetail inv  on inv.iinvoicemaster_id = im.iinvoicemaster_id and inv.dtrowdeleted is null
					and im.dtrowdeleted is null and im.bfinalized is null and im.bmoveoutinvoice is not null
					where inv.itenant_id = #MovedOut.iTenant_ID#
					and 1 = (select count(distinct itenant_id) from invoicedetail iin where iin.dtrowdeleted is null 
					and iin.iinvoicemaster_id = im.iinvoicemaster_id)
					</cfquery>
					<td> 
					<a href="./MoveOut/MoveOutReport.cfm?ID=#MovedOut.iTenant_ID#&MID=#qGetMOInvoice.iInvoiceMaster_ID#">#DATEFORMAT(MovedOut.dtMoveOut, "mm/dd/yyyy")#</a> </td>
				</cfif>
			</cfif>
			
			<td style="text-align: right;">						
				<cfif url.SelectedHouse_id neq 200>
					<a href="Reports/CustomerTrialBalance.cfm?prompt0=#MovedOut.cSolomonKey#"> #LSCurrencyFormat(MovedOut.currbal)# </a>
				<cfelseif MovedOut.iTenant_ID neq ""> ZetaTest </cfif>
			</td>
			<td style="text-align: right;">#LSCurrencyFormat(0)# </td>
			<td style="text-align: right;"> #LSCurrencyFormat(0)# </td>
			<td style="text-align: center;" nowrap> #Left(MovedOut.promotions, 20)# </td>
			<td style="text-align: right;"> </td>
		</cf_ctTR>
	</cfif>	
</cfoutput>
	<tr>
		<td colspan="14"><input class="ReturnButton" type="button" name="viewallhouseeft" Value="View House EFT's"   
		onClick="location.href='tenant/TenantEFTHouse.cfm'"  ></td>
	</tr>
</table>
<br/><br/>

<cfinclude template="../Footer.cfm">