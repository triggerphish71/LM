<!---  --------------------------------------------------------------------------------------------------
 sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                                    |
 sfarmer     | 11/20/2012 |tickets 97882, 95010, 95009, 95468, 97570, 97710 for  misc. updates          |
 sfarmer     | 08/08/2013 |     project 106456 EFT Updates                                              |
 sfarmer     | 09/05/2013 |project 106456 EFT Updates - corrections                                     |
**************************************************************************************************** --->
<!--- Include Intranet Header --->
	<cfinclude template="../../header.cfm">
	<h1 class="PageTitle"> Tips 4 - Tenant EFT Information Edit </h1>

	<cfinclude template="../Shared/HouseHeader.cfm">
	
	<!--- Retreive list of State Codes, PhoneType, and Tenant Information --->
	<cfinclude template="../Shared/Queries/StateCodes.cfm">
	<cfinclude template="../Shared/Queries/PhoneType.cfm">
	<cfinclude template="../Shared/Queries/TenantInformation.cfm">
	<!--- <cfinclude template="../Shared/Queries/Residency.cfm"> --->
	<cfinclude template="../Shared/Queries/SolomonKeyList.cfm">
	<cfinclude template="../Shared/Queries/Relation.cfm">
	
	<cfparam name="nextorderpull" default="">
	<!--- <cfparam name="CID" default="0">  --->
	<cfparam name="contactID" default="">	
	<cfparam name="ALLISWELL" default="">	 
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
	
  <cfparam name="AcctPeriod" default="#SESSION.TIPSMonth#">
  <cfset AcctPeriod = dateformat(AcctPeriod ,'yyyymm')>
    <!--- session.acctperiod --->
<!---  <cfparam name="AcctPeriod" default="201203"> ---> 
 <cfset eftpulmonth = dateadd('m', -1,  #session.TIPSMonth#) >
 <cfset thisdate = dateformat(eftpulmonth, 'YYYYMM')>	
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
	
	<!--- Retrieve Tenant Information  --->
	<!--- Proj 26955 rschuette 2/24/2009 added for bond tenant status --->
	<cfquery name="TenantInfo" DATASOURCE="#APPLICATION.datasource#">
		SELECT bUsesEFT,cSolomonKey,iproductline_id,t.iTenant_ID,
			cFirstName, cMiddleInitial, cLastName,
			cOutsideAddressLine1, cOutsideAddressLine2, 
			cOutsideCity, cOutsideStateCode, cOutsideZipCode, 
			cPreviousAddressLine1, cPreviousAddressLine2, 
			cPreviousCity, cPreviousState, cPreviouszipCode, 
			RT.cDescription as Residency, rt.iResidencyType_ID, 
			dtmoveoutprojecteddate, iStateDefinedCareLevel, 
			iPrimaryDiagnosis, iSecondaryDiagnosis, 
			cSSN, dbirthdate, bIsPayer, isnull(cTenantPromotion,0) as cTenantPromotion, 
			bMICheckReceived, cResidenceAgreement, bContractManagementAgreement, 
			cResidentFee, chasExecutor, t.bIsBond as BondTenant, dtBondCert, 
			cBondHouseEligible, bDeferredPayment, cMilitaryVA, VaBranchOfMilitary, 
			VaRepresentativeContacted, VaBenefits, cMilitaryStartDate, cMilitaryEndDate, 
			cOutsidePhoneNumber1, cOutsidePhoneNumber2, cOutsidePhoneNumber3, 
			cEmail, bUsesEFT, T.cComments as TenantComments, cMonthRASigned,
			ts.dVAChampsAmt, ts.bExEFTSrvFee, ts.dDeferral, ts.dSocSec, ts.dMiscPayment, 
			ts.dMakeupAmt, ts.bIsPrimaryPayer  
		FROM tenant T
		JOIN tenantstate TS on T.iTenant_ID = TS.iTenant_ID
		JOIN ResidencyType RT on RT.iResidencyType_ID = TS.iResidencyType_ID
		where T.iTenant_ID = #url.ID#
	</cfquery>
	
	<!--- Get Tenant's EFT Information If they are EFT --->

	<cfquery name="EFTinfo" datasource="#application.datasource#"> 
  		SELECT 
			t.clastname + ', ' + T.cfirstname as 'TenantName'
			,t.csolomonkey
			,''  as 'ContactName'
			,T.itenant_id
			,T.cemail as 'Email'
			,ts.bUsesEFT 	
			,ts.bIsPrimaryPayer		as 'PrimaryPayer'
			,'' as 'bIsGuarantorAgreement'
			,EFTA.iEFTAccount_ID 
			,EFTA.cRoutingNumber 
			,EFTA.CaCCOUNTnUMBER 
			,EFTA.cAccountType 
			,EFTA.iOrderofPull 
			,EFTA.iDayofFirstPull 
			,EFTA.dPctFirstPull 
			,EFTA.dAmtFirstPull 
			,EFTA.iDayofSecondPull 
			,EFTA.dPctSecondPull 
			,EFTA.dAmtSecondPull 
			,EFTA.iContact_id 
			,EFTA.dtBeginEFTDate 
			,EFTA.dtEndEFTDate 
			,EFTA.bApproved	
			,EFTA.dtRowDeleted 
			<!--- ,EFTA.dtRowEnd --->
			,0 as currbal
			,0 as TipsSum
		<!--- 	, (arb.currbal + arb.futurebal) as currbal --->
	<!--- 		, (	select	isnull(sum(isnull(mAmount, 0) * cast(isnull(iQuantity, 0) as money)), 0)  
		from	rw.vw_invoices
		where	iInvoiceNumber = im.iInvoiceNumber
		and	not (bIsRent is null and bIsMedicaid is not null)    
		  
		and (iChargeType_ID <> 1740 ) 
		)	as TipsSum	 --->
 
<!---  --->			
		FROM  
		dbo.tenant t join dbo.tenantstate ts on  t.iTenant_ID = ts.iTenant_ID
		 join dbo.house h on t.ihouse_id = h.ihouse_id
		<!---  join dbo.InvoiceMaster IM on IM.cSolomonKey = T.cSolomonKey ---> 
		 join EFTAccount EFTA on  EFTA.cSolomonKey = T.cSolomonKey
			<!--- left join #Application.HOUSES_APPDBServer#.HOUSES_APP.dbo.ar_balances arb on (arb.custid = t.cSolomonKey) --->
		WHERE 
			 EFTA.iContact_id is  null
<!--- 			and EFTA.dtRowDeleted is  null 
			and  EFTA.dtRowEnd  is  null  --->  
			and t.cSolomonKey = '#TenantInfo.cSolomonKey#'
			and ts.bUsesEFT =  1  
			and ts.iTenantStateCode_ID = 2
			<!--- and im.cAppliesToAcctPeriod =  '#thisdate#'  --->
		 
			<!--- and IM.bMoveInInvoice is null 			
			and IM.bMoveOutInvoice is null	 	
 			and IM.bFinalized = 1 --->
			
			UNION     
			
			SELECT 
				t.clastname + ', ' + T.cfirstname	as 'TenantName'	
				,t.csolomonkey	
				,C.cFirstName + ' ' +  C.cLastName as  'ContactName' 
				,T.itenant_id
				,C.cemail as 'Email'
				,LTC.bIsEFT 
				,LTC.bIsPrimaryPayer	as 'PrimaryPayer'
				,LTC.bIsGuarantorAgreement		as 'bIsGuarantorAgreement'	
				,EFTA.iEFTAccount_ID 
				,EFTA.cRoutingNumber 
				,EFTA.CaCCOUNTnUMBER 
				,EFTA.cAccountType 
				,EFTA.iOrderofPull 
				,EFTA.iDayofFirstPull 
				,EFTA.dPctFirstPull 
				,EFTA.dAmtFirstPull 
				,EFTA.iDayofSecondPull 
				,EFTA.dPctSecondPull 
				,EFTA.dAmtSecondPull 
				,EFTA.iContact_id 
				,EFTA.dtBeginEFTDate 
				,EFTA.dtEndEFTDate 
				,EFTA.bApproved	
				,EFTA.dtRowDeleted 
				<!--- ,EFTA.dtRowEnd --->
				,0 as currbal
				,0 as TipsSum
				<!--- , (arb.currbal + arb.futurebal) as currbal
 
			, (	select	isnull(sum(isnull(mAmount, 0) * cast(isnull(iQuantity, 0) as money)), 0)
		from	rw.vw_invoices
		where	iInvoiceNumber = im.iInvoiceNumber
		and	not (bIsRent is null and bIsMedicaid is not null)     
	 
		and (iChargeType_ID <> 1740 ) 
				) as TipsSum	--->
		FROM 
			dbo.tenant t join dbo.tenantState TS on t.iTenant_ID = ts.iTenant_ID
			   	join dbo.LinkTenantContact LTC on  t.iTenant_ID = LTC.iTenant_ID 
					join dbo.Contact C on LTC.iContact_ID = C.iContact_ID
						join dbo.EFTAccount EFTA  on EFTA.cSolomonKey = T.cSolomonKey  and EFTA.iContact_ID = LTC.iContact_ID
							join dbo.house h on t.ihouse_id = h.ihouse_id
								<!--- join dbo.InvoiceMaster IM on IM.cSolomonKey = T.cSolomonKey --->
									<!--- left join #Application.HOUSES_APPDBServer#.HOUSES_APP.dbo.ar_balances arb on (arb.custid = t.cSolomonKey) --->
			WHERE 
 				LTC.bIsEFT = 1 
<!--- 				and EFTA.dtRowDeleted is  null   
				and  EFTA.dtRowEnd  is  null  --->  
				and	t.cSolomonKey = '#TenantInfo.cSolomonKey#'
				and ts.iTenantStateCode_ID = 2
			<!--- 	and im.cAppliesToAcctPeriod =  '#thisdate#'  --->
				and ts.bUsesEFT =  1
			  
				
				<!--- and IM.bFinalized = 1
				and IM.bMoveInInvoice is null 
 				and IM.bMoveOutInvoice is null --->
			order by  csolomonkey, EFTA.iOrderofPull	
	</cfquery>
	
	<cfquery name="EFTmax" datasource="#application.datasource#">
		SELECT max(iOrderofPull) maxorder 
		FROM EFTAccount 
		WHERE cSolomonKey = '#TenantInfo.cSolomonKey#'
		and dtRowDeleted is  null
	</cfquery>	
	
	<cfif EFTmax.maxorder gt 0>
		<cfif  (EFTmax.maxorder is not "")>
			<cfset nextorderpull = EFTmax.maxorder + 1>
		<cfelse>
			<cfquery name="EFTinfo" datasource="#application.datasource#">
				update EFTAccount
				set iOrderofPull = 1 
				where cSolomonKey = '#TenantInfo.cSolomonKey#'
			</cfquery>	
			<cfset nextorderpull =  2	>		
		</cfif>
	<cfelse>
			<cfset nextorderpull =   1	>
	</cfif>	
 	
	<!--- Retrieve Any KeyChange Information for this Tenant  --->
	<cfquery name="KeyChanges" DATASOURCE="#APPLICATION.datasource#">
		select PT.cSolomonKey, PT.dtRowStart, PT.dtRowEnd from Tenant T 
		join P_Tenant PT on T.iTenant_ID = PT.iTenant_ID 
		where T.iTenant_ID = #url.ID# and PT.cSolomonKey <> '#TenantInfo.cSolomonKey#' 
		and PT.dtRowEnd = 
		( SELECT Max(PT.dtRowEnd) from Tenant T JOIN P_Tenant PT on T.iTenant_ID = PT.iTenant_ID 
		where T.iTenant_ID = #url.ID# AND PT.cSolomonKey <> '#TenantInfo.cSolomonKey#' ) 
	</cfquery>
	
	<cfif IsDefined("URL.CID")  and URL.CID is not ""  >
		<cfquery name="ContactPerson" DATASOURCE="#APPLICATION.datasource#">	
			select C.cFirstName ,  C.cLastName, C.iContact_ID, c.cEmail, LTC.bIsEFT, LTC.bIsGuarantorAgreement 
			from dbo.Contact C, dbo.LinkTenantContact LTC, dbo.tenant T
			where LTC.iTenant_ID = T.iTenant_ID
				and LTC.iContact_ID = C.iContact_ID
				and T.iTenant_ID = #ID#	
				and LTC.iContact_ID = #CID#		
		</cfquery>		
	<cfelseif   IsDefined('URL.CFID') and URL.CFID is not "">
		<cfquery name="ContactPerson" DATASOURCE="#APPLICATION.datasource#">	
			select C.cFirstName ,  C.cLastName, C.iContact_ID, c.cEmail, LTC.bIsEFT, LTC.bIsGuarantorAgreement 
			from dbo.Contact C, dbo.LinkTenantContact LTC, dbo.tenant T
			where LTC.iTenant_ID = T.iTenant_ID
				and LTC.iContact_ID = C.iContact_ID
				and T.iTenant_ID = #CFID#	
				and LTC.iContact_ID = #CFID#		
		</cfquery>		
	</cfif>		
	
	<!--- Retrieve Any KeyChange Information for this Solomon Key --->
	<cfquery name="SolKeyChanges" DATASOURCE="#APPLICATION.datasource#">
		select PT.iTenant_ID, PT.cSolomonKey, PT.dtRowStart, PT.dtRowEnd
		from Tenant T
		join P_Tenant PT ON T.iTenant_ID = PT.iTenant_ID
		where PT.iTenant_ID <> #URL.ID# and PT.cSolomonKey = '#TRIM(TenantInfo.cSolomonKey)#'
		and PT.dtRowEnd = 
		(	select Max(PT.dtRowEnd) from Tenant T
			join P_Tenant PT on T.iTenant_ID = PT.iTenant_ID
			where PT.iTenant_ID <> #URL.ID# and PT.cFirstName NOT LIKE '#TRIM(TenantInfo.cFirstName)#%'  
			and PT.cSolomonKey = '#TRIM(TenantInfo.cSolomonKey)#'
	)
	</cfquery>
	
<!--- 	<cfquery name="getAmt"  datasource="#application.datasource#">
		select ID.iTenant_ID ,sum(ID.iQuantity * mAmount ) as 'InvoiceTotal'
		from dbo.InvoiceMaster IM, dbo.InvoiceDetail ID
		where ID.cAppliesToAcctPeriod ='#AcctPeriod#' <!---#dateformat(SESSION.TIPSMonth, 'yyyymm' )#  --->
		and  IM.cSolomonKey = #TenantInfo.cSolomonKey#
		and IM.iInvoiceMaster_ID = ID.iInvoiceMaster_ID
				<!--- and IM.bFinalized = 1 --->
				and IM.bMoveInInvoice is null			
				and IM.bMoveOutInvoice is null
		group by iTenant_ID
	</cfquery>	 --->
 	<cfquery name="getAmt"  datasource="#application.datasource#">
		 select	  isNULL(Sum(iQuantity * mAmount),0) as 'InvoiceTotal'
		from Tenant tn 
		join TenantState tns  on (tns.iTenant_ID = tn.iTenant_ID and tns.dtRowDeleted is null and tns.iTenantStateCode_ID = 2)
		and tn.iHouse_ID = #session.qselectedhouse.ihouse_id#
		join InvoiceMaster IM  on im.csolomonkey = tn.csolomonkey and IM.dtRowDeleted is null 
		and IM.bFinalized = 1 and IM.cAppliesToAcctPeriod = '#thisdate#'
		and IM.bMoveInInvoice is null and IM.bMoveOutInvoice is null 
		left join InvoiceDetail INV on INV.iinvoicemaster_id = im.iinvoicemaster_id and INV.dtRowDeleted is null
		join ChargeType CT  on INV.iChargeType_ID = Ct.iChargeType_ID and Ct.dtRowDeleted is null
		and Ct.cGLAccount <> 3012 and Ct.cGLAccount <> 3016
		join AptAddress AD  on ad.iAptAddress_ID = tns.iAptAddress_ID and ad.dtRowDeleted is null
		where tn.cSolomonKey = '#TenantInfo.cSolomonKey#'
		 
	</cfquery> 
<cfquery name="sumpayment" DATASOURCE="#APPLICATION.datasource#"> 
SELECT     
	sum(dAmtFirstPull) as 'sumfirstamt'
	, sum(dAmtSecondPull) as 'sumsecondamt' 
	, sum(dPctFirstPull) as 'sumfirstpull'
	, sum (dPctSecondPull) as 'sumsecondpull'
	,count(iEFTAccount_ID) as 'eftcount'
FROM (	SELECT EFTA.dAmtFirstPull, EFTA.dAmtSecondPull, EFTA.dPctFirstPull, EFTA.dPctSecondPull,EFTA.iEFTAccount_ID 
			FROM  dbo.tenant T
				join dbo.EFTAccount EFTA on  EFTA.cSolomonKey = T.cSolomonKey
				join   tenantstate ts on ts.itenant_id = t.itenant_id
			WHERE
				T.cSolomonKey = '#TenantInfo.cSolomonKey#'			
			 	and EFTA.dtRowDeleted is  null 	
			 	and EFTA.iContact_id is  null
				and ts.bUsesEFT =   1 				
		union
			SELECT EFTA.dAmtFirstPull, EFTA.dAmtSecondPull, EFTA.dPctFirstPull, EFTA.dPctSecondPull,EFTA.iEFTAccount_ID 
			FROM dbo.Contact C, dbo.LinkTenantContact LTC, dbo.tenant T,  dbo.EFTAccount EFTA 
			WHERE
				T.cSolomonKey = '#TenantInfo.cSolomonKey#'		
				and EFTA.cSolomonKey = T.cSolomonKey 
			    and EFTA.dtRowDeleted is  null  			
				and LTC.iTenant_ID = T.iTenant_ID
				and LTC.iContact_ID = C.iContact_ID
				and LTC.bIsEFT =  1
				and EFTA.iContact_id  = C.iContact_ID)
				as sumtable
</cfquery>	
						<cfquery name="qryInvAmt" datasource="#application.datasource#"> 
							Select IM.mLastInvoiceTotal
								,IM.dtInvoiceStart 
								,IM.dtInvoiceEnd 
								,IM.iInvoiceMaster_ID
								,(select sum (inv.iquantity * inv.mamount) from  InvoiceDetail INV 
								where IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID and INV.dtrowdeleted is null) as 'TipsSum'
							from
							InvoiceMaster IM
							 where  IM.cSolomonKey =  '#TenantInfo.cSolomonKey#'
								and IM.bMoveInInvoice is null 
								and IM.bMoveOutInvoice is null						 
								  and IM.bFinalized = 1  
								and im.cAppliesToAcctPeriod =  '#thisdate#'	
						</cfquery>
						<cfquery name="qrysolomon" datasource="#application.datasource#">	
							select  isNull(Sum(amount ) , 0) as  'SolomonTotal'  
							from rw.vw_Get_Trx
							where custid = '#TenantInfo.cSolomonkey#' 
							and	rlsed = 1
							and	user7 > '#qryInvAmt.dtInvoiceStart#'
							and	user7 <=  '#qryInvAmt.dtInvoiceEnd#' 
						</cfquery>
						<cfquery name="qryOffset" datasource="#application.datasource#"> 
							SELECT 	IsNull(Sum(amount), 0) as 'paOffset'
							from rw.vw_Get_Trx
							where custid = '#TenantInfo.cSolomonkey#' 
							and	rlsed = 1
							and	user7 > '#qryInvAmt.dtInvoiceEnd#'
							and	user7 <=  #Now()# 
								and doctype in ('PA', 'CM', 'RP', 'NS', 'NC') 						
						</cfquery>
						<cfquery name="sumpaymnt"  datasource="#application.datasource#"> 
							<!--- select  sum(isnull(dollarsum,0))
							from  --->  
							 select sum(isnull(dAmtSecondPull,0) + isnull(dAmtFirstPull,0)) as dollarsum
							 from dbo.EFTAccount efta   
							 where  dtRowDeleted is null and csolomonkey = '#EFTinfo.csolomonkey#' 
						</cfquery>	
	<cfif qryOffset.paOffset is "">
		<cfset offset = 0>
	<cfelse>
		<cfset offset = qryOffset.paOffset>
	</cfif>
	
	<cfif qryInvAmt.mLastInvoiceTotal is "">  
		<cfset  LastInvoiceTotal = 0>
	<cfelse>
		<cfset  LastInvoiceTotal = qryInvAmt.mLastInvoiceTotal>		
	</cfif>
	<cfif qrysolomon.SolomonTotal is "">  
		<cfset qrysolomon.SolomonTotal = 0>
		<cfelse>
		<cfset thisSolomonTotal = qrysolomon.SolomonTotal >		
	</cfif> 
	<cfif qryInvAmt.TipsSum is ""> 
		<cfset thisTipsSum = 0>
	<cfelse>
		<cfset thisTipsSum =  qryInvAmt.TipsSum  >		
	</cfif> 	
 												 
	<cfset finalamt = LastInvoiceTotal + thisSolomonTotal +thisTipsSum   > 
	<cfset adjfinal = LastInvoiceTotal + thisSolomonTotal  + thisTipsSum  + offset>
<script language="JavaScript" type="text/javascript" src="../Shared/JavaScript/global.js"></script>
 
<script language="JavaScript"  type="text/javascript">	
		function onlyNumbers(evt)
		{
			var e = event || evt; // for trans-browser compatibility
			var charCode = e.which || e.keyCode;
		
			if (charCode > 31 && (charCode < 48 || charCode > 57))
				return false;
		
			return true;
		
		}	
		
		function required() { 
			if   (document.getElementById("cRoutingNumber").value !=  document.getElementById("cRoutingNumberValidate").value 
			|| document.getElementById("cRoutingNumber").value == ''
			|| document.getElementById("cRoutingNumber").value.length != 9)  {
				alert('Routing Numbers do not Match!  Please reenter, all routing numbers must be 9 digits long.');
				document.getElementById("cRoutingNumber").style.background = 'white';
				document.getElementById("cRoutingNumberValidate").style.background = 'white';
				document.getElementById("cRoutingNumberValidate").focus();
				document.getElementById("cRoutingNumberValidate").focus();
				return false;
			}

			
			if   (document.getElementById("cAccountNumber").value !=  document.getElementById("cAccountNumberValidate").value 
			|| document.getElementById("cAccountNumber").value == '')  {
				alert('Account Numbers do not Match!  Please reenter.');
				document.getElementById("cAccountNumber").style.background = 'white';
				document.getElementById("cAccountNumberValidate").style.background = 'white';
				document.getElementById("cAccountNumberValidate").focus();
				return false;
			}
				  
			if   (document.getElementById("dPctFirstPull").value > 0 && document.getElementById("dAmtFirstPull").value > 0) 
			 {
				alert('Enter a Percentage withdrawal or an Amount of withdrawal - First Pull!  Not BOTH!.');
				document.getElementById("dPctFirstPull").style.background = 'white';
				document.getElementById("dAmtFirstPull").style.background = 'white';
				document.getElementById("dPctFirstPull").focus();
				return false;
				}
			if   (document.getElementById("dPctSecondPull").value > 0  && document.getElementById("dAmtSecondPull").value > 0 )
			  {
				alert('Enter a Percentage withdrawal or an Amount of withdrawal - Second Pull!  Not BOTH!.');
				document.getElementById("dPctSecondPull").style.background = 'white';
				document.getElementById("dAmtSecondPull").style.background = 'white';
				document.getElementById("dPctSecondPull").focus();
				return false;			
				}
			if    (( document.TenantEdit.cAccountType[0].checked==false) && (document.TenantEdit.cAccountType[1].checked==false) )
			  {
				alert('Select the type of account:  Checking or Savings.');
				document.getElementById("cAccountType").style.background = 'white';
				document.getElementById("cAccountType").focus();
				return false;			
				}
			/* TPecku commented out the email validation block
			if     ( document.getElementById("cEmail").value == ''  ) 
			  {
				alert('An Email is required with for  EFT\'s.');
				document.getElementById("cEmail").style.background = 'white';
				document.getElementById("cEmail").focus();
				return false;			
				}				
			if  ( document.getElementById("cEmail").value != document.getElementById("vEmail").value) 
			  {
				alert('Email entries do not match.');
				document.getElementById("cEmail").style.background = 'white';
				document.getElementById("cEmail").focus();
				return false;			
				}*/
 
			  
			if  (document.getElementById("dPctSecondPull").value > 0 || document.getElementById("dAmtSecondPull").value > 0)   
			  { var thissel = document.getElementById("iDayofSecondPull").selectedIndex;
			    var       y = document.getElementById("iDayofSecondPull").options;
			  	if(  y[thissel].index == 0){
			 		alert( 'Select Day Of Month for Second Pull');
			 		document.getElementById("iDayofSecondPull").style.background = 'white';
			 		document.getElementById("dAmtSecondPull").style.background = 'white';				
			 		document.getElementById("iDayofSecondPull").focus();
			 		return false;		}	
				}
				
		}
		function callsetupeft(){
			tenantID = document.getElementById('iTenant_ID').value;
			SolomonKey = document.getElementById('tenantSolomonKey').value;
			valdata =   'ID=' + document.getElementById('iTenant_ID').value + '&tenantSolomonKey=' + document.getElementById('tenantSolomonKey').value ;
			newlocation = 'TenantEFTEdit.cfm?' + valdata;
			window.location =  newlocation   ; 	
		}
		
		function LeadingZeroNumbers(string) {
		for (var i=0, output='', valid="1234567890."; i<string.length; i++)
		   if (valid.indexOf(string.charAt(i)) != -1)
			  output += string.charAt(i)
		return output;		
		}
		function chktoolargefrst(){
			if (document.getElementById("dPctFirstPull").value > 100)
				{
				alert('Pull percentage cannot be greater than 100%');
				document.getElementById("dPctFirstPull").focus();
				}
		} 
		function frstnotboth(){
			if (document.getElementById("dAmtFirstPull").value > 0  && document.getElementById("dPctFirstPull").value > 0)
				{
				alert('Do not enter both a Percentage pull and an Amount Pull');
				document.getElementById("dPctFirstPull").focus();
				}
		} 		
		function chktoolargescnd(){
			if (document.getElementById("dPctSecondPull").value > 100)
				{
				alert('Pull percentage cannot be greater than 100%');
				document.getElementById("dPctSecondPull").focus();
				}
		} 
		function scndnotboth(){
			if (document.getElementById("dAmtSecondPull").value > 0 && document.getElementById("dPctSecondPull").value > 0)
				{
				alert('Do not enter both a Percentage pull and an Amount Pull');
				document.getElementById("dPctSecondPull").focus();
				}
		} 		
	</script>		
 	
	<script language="JavaScript" src="../Shared/JavaScript/ts_picker2.js" type="text/javascript"></script>
		<form name="TenantEdit" action="TenantEFTUpdate.cfm" method="POST" onSubmit="return required();">
			<cfoutput>
				<input type="hidden" name= "iTenant_ID" id="iTenantID" value="#TenantInfo.iTenant_ID#">
				<input type="hidden" name= "tenantSolomonKey" id="tenantSolomonKey" value="#TenantInfo.cSolomonKey#">
				
				<cfif isDefined('url.CID')>
					<input type="hidden" name= "contactID" id="contactID" value="#url.CID#">
				<cfelse>	
					<input type="hidden" name= "contactID" id="contactID" value="">					
				</cfif>	
			</cfoutput>
			<table width="80%">
				<cfoutput>
					<tr>	
						<td  colspan= "3"  align="center" >Tenant: #TenantInfo.cFirstName# #TenantInfo.cMiddleInitial# #TenantInfo.cLastName# </td>	
					</tr>
				</cfoutput>		
				<cfinclude template="../Admin/EFTBox.cfm">
					
					<tr>
						<td colspan= "3" id="eftcell">
							<div id="eftDIV">
								<TABLE width="100%">
									<cfoutput>
									<cfif IsDefined("URL.CID")  and URL.CID is not "">
										<tr>
											<td colspan="2">Enter EFT information from contact: #ContactPerson.cFirstName# #ContactPerson.cLastName# for Tenant: #TenantInfo.cFirstName# #TenantInfo.cLastName#</td>
										</tr>
										
									</cfif>	
										<tr>
											<td colspan="2" id="Message" style="background:white;color:red;text-align:center;font-weight:bold;font-size:x-small;"> 
												Required are listed in red. 
											</td>
										</tr>							
										<TR>
											<TD class="required">EFT Routing Number:</TD>
											<TD><input type="text" id="cRoutingNumber" name="cRoutingNumber" size="10" onKeyPress="return onlyNumbers();"	maxlength="9"  ondragstart="return false" onselectstart="return false"></INPUT></TD> 
										</TR>
										<TR   class="evenRow"> 
											<TD class="required">Reenter to verify Routing Number:</TD>
											<TD><input type="text" id="cRoutingNumberValidate" name="cRoutingNumberValidate"  size="10" onKeyPress="return onlyNumbers();" maxlength="9" ondragstart="return false" onselectstart="return false"></INPUT></TD>
										</TR>
										<TR>
											<TD class="required">EFT Account Number:	</TD>
											<TD><input type="text" name="cAccountNumber" size="17" maxlength="17" onKeyPress="return onlyNumbers();"   ondragstart="return false" onselectstart="return false" ></INPUT></TD> 
										</TR>
										<TR   class="evenRow"> 
											<TD class="required">Reenter to verify Account Number: </TD>
											 <TD><input type="text" id="cAccountNumberValidate" name="cAccountNumberValidate" size="17" onKeyPress="return onlyNumbers();" maxlength="17"   ondragstart="return false" onselectstart="return false"></INPUT></TD>
										</TR>
										<TR>
											<TD class="required">EFT Checking or Savings: </TD>
											<TD><input type="radio" name="cAccountType" id="cAccountType" Value="C"> Checking 
												<input type="radio" name="cAccountType" id="cAccountType" Value="S"> Savings 
											</TD>
										</TR>
										<TR   class="evenRow"> 
											<TD>Order of Draw: </TD>
											<TD><input type="text" id="iOrderofPull" name="iOrderofPull" size="5" value="#nextorderpull#" onKeyPress="return onlyNumbers();" maxlength="2"></INPUT></TD>
										</TR>
										<TR>
											<TD>Select Day of the Month to do First Draw: </TD>
											<TD>
												<select name="iDayofFirstPull" id="iDayofFirstPull">
													<option>#EFTinfo.iDayofFirstPull#</option>
													<cfloop from="5" to="25" index="i">
													<option>#i#</option>
													</cfloop>
												</select>
												If left blank, default is 5th.
											</TD>
										<TR   class="evenRow"> 
											<TD>First Draw %: </TD>
											<TD><input type="text" id="dPctFirstPull" name="dPctFirstPull" size="7"  maxlength="7"  onkeyup="this.value=LeadingZeroNumbers(this.value);"  onblur="chktoolargefrst();  this.value=cent(round(this.value));"></INPUT> If left blank, default is 100% </TD>
										</TR>
										<TR>
											<TD>First Draw $ Amount: </TD>
											<TD><input type="text" id="dAmtFirstPull" name="dAmtFirstPull" size="10"  maxlength="10"  onkeyup="this.value=LeadingZeroNumbers(this.value);" onblur="frstnotboth();  this.value=cent(round(this.value));"></INPUT></TD>
										</TR>
										<TR   class="evenRow"> 
											<TD>Select Day of the Month to do Second Draw: </TD>
											<TD>
												<select name="iDayofSecondPull" id="iDayofSecondPull">
													<option>#EFTinfo.iDayofSecondPull#</option>
													<cfloop from="5" to="25" index="i">
													<option>#i#</option>
													</cfloop>
												</select>
											</TD>			
										</TR>	
										<TR>
											<TD>Second Draw %: </TD>
											<TD><input type="text" id="dPctSecondPull" name="dPctSecondPull" size="7"  maxlength="7"  onkeyup="this.value=LeadingZeroNumbers(this.value);" onblur="chktoolargescnd();  this.value=cent(round(this.value));"></INPUT> </TD>
										</Tr>
										<TR   class="evenRow"> 
											<TD>Second Draw $ Amount:</TD> 
											<TD><input type="text" id="dAmtSecondPull" name="dAmtSecondPull" size="10"    maxlength="10"  onkeyup="this.value=LeadingZeroNumbers(this.value);" onblur="scndnotboth();  this.value=cent(round(this.value));"></INPUT> </TD> 
										 </TR>
										<TR>
											<TD>Effective Date: <input type="text" id="dtBeginEFTDate" name="dtBeginEFTDate" size="10"   maxlength="2"><a onClick="show_calendar2('document.forms[0].dtBeginEFTDate',document.getElementsByName('dtBeginEFTDate')[0].value);"> <img src="../Shared/JavaScript/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a><br/> Default is Today.</INPUT></TD>
											<TD>End Date:  	 <input type="text" id="dtEndEFTDate" name="dtEndEFTDate" size="10"   maxlength="2"><a onClick="show_calendar2('document.forms[0].dtEndEFTDate',document.getElementsByName('dtEndEFTDate')[0].value);"> <img src="../Shared/JavaScript/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a></INPUT><BR/>If left blank the EFT will be open ended.	</TD>
										</TR>

										<cfif IsDefined("URL.CID")  and URL.CID is not "">							
										<cfif tenantinfo.bIsPrimaryPayer is 1>
										<tr>
											<td colspan="2">The tenant is the primary payer, to change this status deselect the primary payer first</td>
										</tr>
										<cfelseif contactperson.bIsGuarantorAgreement is 1>
										<TR>
											<TD colspan="2">Is this the primary account?: <input type="checkbox" id="PrimAcct" name="PrimAcct" size="50"   maxlength="70" value="Y">Check if "Yes"</INPUT></TD>
										</TR>
										<cfelse>
											<tr>
												<td colspan="2">The contact can be the primary payor only if the Guarantor Agreement has been signed.</td>
											</tr>
										</cfif>
									<!---Tpecku commented out all reference to emails
											<TR>
												<TD class="required" colspan="2"> Contact Email: <input type="text" id="cEmail" name="contactcEmail" size="50"   maxlength="70" value="#ContactPerson.cEmail#"  ondragstart="return false" onselectstart="return false"></INPUT></TD>
											</TR>
											<TR>
												<TD class="required" colspan="2">Reenter to verifiy Contact Email: <input type="text" id="vEmail" name="contactvEmail" size="50"   maxlength="70" value="#ContactPerson.cEmail#" ondragstart="return false" onselectstart="return false"></INPUT></TD>
											</TR>
										<cfelse>							
											<TR>
												<TD colspan="2" class="required"> Enter Email: <input type="text" id="cEmail" name="cEmail" size="50"   maxlength="70" value="#TenantInfo.cEmail#" ondragstart="return false" onselectstart="return false"></INPUT></TD>
											</TR>
											<TR>
												<TD colspan="2" class="required">Reenter to Verify Email: <input type="text" id="vEmail" name="vEmail" size="50"   maxlength="70" value="#TenantInfo.cEmail#" ondragstart="return false" onselectstart="return false"></INPUT></TD>
											</TR> --->											
										</cfif>
<!--- 										<cfif TenantInfo.bExEFTSrvFee is "">
										<tr>
											<td colspan="2">This account is NOT EFT Service Fee Exempt.</td>
										</tr
										><TR>
											<TD>Exempt from EFT Service Fee: <input type="checkbox" id="ExServiceFee" name="ExServiceFee" size="1" value="Y"   <cfif TenantInfo.bExEFTSrvFee is 1>checked="checked"</cfif>  ></input></TD>
											<TD>&nbsp;</TD>
										</TR>
										</cfif> --->
<!--- 										<cfif TenantInfo.bExEFTSrvFee is 1>
										<tr>
											<td colspan="2">This account is EFT Service Fee Exempt.</td>
										</tr>
										<TR>
											<TD>Drop EFT Service Fee Exemption: <input type="checkbox" id="ExServiceFeeDrop" name="ExServiceFeeDrop" size="1" value="Y" ></input></TD>
											<TD>&nbsp;</TD>
										</TR>
										</cfif> --->
									</cfoutput>	
								</TABLE>
							</div>
						</td>
					</tr>
					 
					<cfoutput>
						<tr>
							<td style="text-align: left;"><input class="SaveButton" type="Submit" name="Save" Value="Save"    ></td>
							<td ><input class="ReturnButton" type="button" name="ReturntoTenantEditPage" Value="Return"   onClick="location.href='TenantEdit.cfm?ID=#url.ID#'"  ></td>
							<td>
								<cfscript>
								if (IsDefined("url.cid") AND url.cid EQ 0) { Script="newcontactdata();"; }
								else { Script=''; }
								</cfscript>
								<input class="DontSaveButton" type="button" name="DontSave" value="Don't Save" onClick="location.href='TenantEFTEdit.cfm?ID=#url.ID#'">
							</td>
						</tr>					
					</cfoutput>
					<tr>
						<td colspan="3"><input class="ReturnButton" type="button" name="viewallhouseeft" Value="View House EFT's"   onClick="location.href='TenantEFTHouse.cfm'"  ></td>
					</tr>
			</table>
		</form>	
		<!--- Include intranet footer --->
		<cfinclude template="../../footer.cfm">		
 
