<cfcomponent displayname="EFT Services" output="false" hint="I provide all the functionality for the EFT Templates">

	<cffunction access="public" name="getEFTHouseInfo" output="false" returntype="query" hint="I return the recordset for the house EFT information">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfargument name="AcctPeriod" type="string" required="true">
		<cfargument name="showall" type="string" required="true">
		<cfargument name="days" type="string" required="false">
		<cfargument name="strtday" type="numeric" required="true">
		<cfargument name="endday" type="numeric" required="true">
		<cfargument name="sortby" type="string" required="false" default="cAptNumber">
	
		<cfquery name="qEFTinfo" datasource="#application.datasource#">
			SELECT 
				t.clastname + ', ' + t.cfirstname as 'TenantName'
				,t.csolomonkey
				,''  as 'ContactName'
				,t.itenant_id
				,t.cEmail  as 'Email' 
				,ts.bUsesEFT
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
				,EFTA.dtBeginEFTDate, EFTA.dtEndEFTDate		
				,h.cname as 'cHouseName'
				,h.ihouse_id  
				,TS.dDeferral 
				,TS.dSocSec 
				,TS.dMiscPayment
				,TS.dMakeUpAmt	
				,t.bIsPayer	as 'IsPayer'
				,TS.bIsPrimaryPayer as 'IsPrimPayer'
				,'' as 'IsContactPayer'
				,'' as 'IsContactPrimPayer'
				,'' as 'isLTC'
				,AD.cAptNumber  
			FROM  dbo.tenant t WITH (NOLOCK)
			INNER JOIN  dbo.tenantstate ts WITH (NOLOCK) on t.iTenant_ID = ts.iTenant_ID
			INNER JOIN  dbo.house h WITH (NOLOCK) on t.ihouse_id = h.ihouse_id and h.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
													and h.assetclass IS NOT NULL and h.dtRowDeleted IS NULL and h.bIsSandbox = 0
			INNER JOIN  EFTAccount EFTA WITH (NOLOCK) on  EFTA.cSolomonKey = T.cSolomonKey
			INNER JOIN  dbo.InvoiceMaster IM WITH (NOLOCK) on IM.cSolomonKey = T.cSolomonKey
			INNER JOIN  dbo.HouseLog HL WITH (NOLOCK) on  hl.ihouse_id = h.ihouse_id
			INNER JOIN  AptAddress AD WITH (NOLOCK)  on ad.iAptAddress_ID = ts.iAptAddress_ID AND ad.dtRowDeleted is null  
			WHERE EFTA.iContact_id is  null
			<cfif arguments.showall is  "N">
				AND EFTA.dtRowDeleted is  null 
				AND ts.bUsesEFT =  1
			</cfif>	
			AND IM.dtRowDeleted is null
			AND ts.iTenantStateCode_ID = 2
			AND im.cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.acctPeriod#">
			<cfif arguments.days is "seldays">
				<cfif arguments.strtday is 1>
					AND  (((EFTA.iDayofFirstPull BETWEEN <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">)
					OR (EFTA.iDayofSecondPull BETWEEN <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">))	
					OR 	(EFTA.iDayofFirstPull is null AND EFTA.iDayofFirstPull <=  <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">))
				<cfelse>
					AND  ((EFTA.iDayofFirstPull BETWEEN <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">)
					OR (EFTA.iDayofSecondPull BETWEEN <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">))
				</cfif>
			</cfif>	
		UNION     
			SELECT 
				t.clastname + ', ' + t.cfirstname	as 'TenantName'	
				,t.csolomonkey			
				,C.cFirstName + ' ' +  C.cLastName as   'ContactName'  
				,t.itenant_id
				,C.cEmail as  'Email' 
				,LTC.bIsEFT  as 'ContactEFT'
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
				,EFTA.dtRowDeleted ,EFTA.dtBeginEFTDate, EFTA.dtEndEFTDate
				,h.cname as 'cHouseName'
				,h.ihouse_id  
				,TS.dDeferral 
				,TS.dSocSec 
				,TS.dMiscPayment
				,TS.dMakeUpAmt	
				,'' as 'IsPayer'
				,'' as 'IsPrimPayer'
				,LTC.bIsPayer as 'IsContactPayer'
				,LTC.bIsPrimaryPayer as 'IsContactPrimPayer'				
				,'Y' as 'isLTC'
				,AD.cAptNumber  
			FROM dbo.tenant t WITH (NOLOCK)
			INNER JOIN dbo.tenantState TS WITH (NOLOCK) on t.iTenant_ID = ts.iTenant_ID
		INNER JOIN dbo.LinkTenantContact LTC WITH (NOLOCK) on  t.iTenant_ID = LTC.iTenant_ID 
		INNER JOIN dbo.Contact C WITH (NOLOCK) on LTC.iContact_ID = C.iContact_ID
		INNER JOIN dbo.EFTAccount EFTA  WITH (NOLOCK) on EFTA.cSolomonKey = T.cSolomonKey 
		INNER JOIN dbo.InvoiceMaster IM WITH (NOLOCK) on IM.cSolomonKey = T.cSolomonKey
		INNER JOIN dbo.house h WITH (NOLOCK) on t.ihouse_id = h.ihouse_id and h.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
									and h.assetclass IS NOT NULL and h.dtRowDeleted IS NULL and h.bIsSandbox = 0
		INNER JOIN AptAddress AD WITH (NOLOCK) on ad.iAptAddress_ID = ts.iAptAddress_ID AND ad.dtRowDeleted is null  
		INNER JOIN dbo.HouseLog HL  WITH (NOLOCK) on  hl.ihouse_id = h.ihouse_id
		WHERE LTC.bIsEFT = 1 
		<cfif arguments.showall is  "N">
		AND EFTA.dtRowDeleted is  null   
		AND ts.bUsesEFT =  1 
		</cfif>  
		AND ts.iTenantStateCode_ID = 2
		AND IM.dtRowDeleted is null
		AND EFTA.iContact_ID = LTC.iContact_ID
		AND im.cAppliesToAcctPeriod =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.acctPeriod#">
		<cfif  arguments..days is "seldays">
			<cfif arguments.strtday is 1>
				AND  (((EFTA.iDayofFirstPull between <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">)
				OR (EFTA.iDayofSecondPull between <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">))	
				OR 	(EFTA.iDayofFirstPull is null)	)
			<cfelse>
				AND  ((EFTA.iDayofFirstPull between <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">)
				OR (EFTA.iDayofSecondPull between <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">))
			</cfif>
		</cfif>	
		order by #arguments.sortby# 
		</cfquery>	

		<cfreturn qEFTinfo>
	</cffunction>

	<cffunction access="public" name="getEFTAllInfo" output="false" returntype="query" hint="I return a recordset of all companies EFT information">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">		
		<cfargument name="AcctPeriod" type="string" required="true">
		<cfargument name="showall" type="string" required="true">
		<cfargument name="days" type="string" required="false">
		<cfargument name="strtday" required="true">
		<cfargument name="endday" required="true">
		<cfargument name="sortby"  required="false" default="cHouseName, cSolomonkey, EFTA.iOrderofPull">

		<cfquery name="qryEFTinfo" datasource="#application.datasource#">
			SELECT 
				t.clastname + ', ' + T.cfirstname as 'TenantName'
				,t.csolomonkey
				,''  as 'ContactName'
				,T.itenant_id
				,T.cEmail  as 'Email' 
				,ts.bUsesEFT
				,ts.dVAChampsAmt	 as 'VAChampsAmt'	
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
				,h.cname as 'cHouseName'
				,h.ihouse_id  AS 'houseID'
				,IM.mInvoiceTotal
				,TS.dDeferral 
				,TS.dSocSec 
				,TS.dMiscPayment
				,TS.dMakeUpAmt
				,ts.bDeferredPayment 		
				,T.bIsPayer	as 'IsPayer'
				,TS.bIsPrimaryPayer as 'IsPrimPayer'
				,TS.bUsesEFT   as 'EFTUSER'
				,'' as 'IsContactPayer'
				,'' as 'IsContactPrimPayer'
				,'' as 'isLTC'
			FROM  dbo.tenant T WITH (NOLOCK) 
			INNER JOIN dbo.tenantstate ts WITH (NOLOCK) on  t.iTenant_ID = ts.iTenant_ID
			INNER JOIN dbo.house h WITH (NOLOCK) on t.ihouse_id = h.ihouse_id and h.assetclass IS NOT NULL and h.dtRowDeleted IS NULL and h.bIsSandbox = 0
			INNER JOIN dbo.InvoiceMaster IM WITH (NOLOCK) on IM.cSolomonKey = T.cSolomonKey 
			INNER JOIN EFTAccount EFTA WITH (NOLOCK) on  EFTA.cSolomonKey = T.cSolomonKey
			WHERE  EFTA.iContact_id is  null
			<cfif arguments.showall is not "Y">
				AND EFTA.dtRowDeleted is  null 
				AND ts.bUsesEFT =  1
			</cfif>	
			AND ts.iTenantStateCode_ID = 2		
			AND im.cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.AcctPeriod#">	
			AND IM.dtRowDeleted is null			
			<cfif   #arguments.days# is "seldays">
				<cfif #arguments.strtday# is 1>
					AND  (((EFTA.iDayofFirstPull BETWEEN <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">)
					OR (EFTA.iDayofSecondPull BETWEEN <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">))	
					OR 		(EFTA.iDayofFirstPull is null))	
				<cfelse>
					AND ((EFTA.iDayofFirstPull BETWEEN <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">)
					OR (EFTA.iDayofSecondPull BETWEEN <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">))
				</cfif>
			</cfif>		
			AND t.ihouse_id <> 200
			

			UNION     

			SELECT 
				t.clastname + ', ' + T.cfirstname	as 'TenantName'	
				,t.csolomonkey			
				,C.cFirstName + ' ' +  C.cLastName as   'ContactName'  
				,T.itenant_id
					,C.cEmail as  'Email' 
				,LTC.bIsEFT 
				,''	 as 'VAChampsAmt'
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
				,h.cname as 'cHouseName'
				,h.ihouse_id  AS 'houseID'
				,IM.mInvoiceTotal
				,TS.dDeferral 
				,TS.dSocSec 
				,TS.dMiscPayment
				,TS.dMakeUpAmt
				,ts.bDeferredPayment 	
				,'' as 'IsPayer'
				,'' as 'IsPrimPayer'
				,LTC.bIsPayer as 'IsContactPayer'
				,LTC.bIsPrimaryPayer as 'IsContactPrimPayer'				
				,'Y' as 'isLTC'
				,TS.bUsesEFT as 'EFTUSER'
			FROM  dbo.tenant T WITH (NOLOCK) 
			INNER JOIN dbo.tenantState TS WITH (NOLOCK) on T.iTenant_ID = ts.iTenant_ID
			INNER JOIN dbo.LinkTenantContact LTC WITH (NOLOCK) on  T.iTenant_ID = LTC.iTenant_ID 
			INNER JOIN dbo.Contact C WITH (NOLOCK) on LTC.iContact_ID = C.iContact_ID
			INNER JOIN dbo.EFTAccount EFTA WITH (NOLOCK)  on EFTA.cSolomonKey = T.cSolomonKey 
			INNER JOIN dbo.house h WITH (NOLOCK) on t.ihouse_id = h.ihouse_id and h.assetclass IS NOT NULL and h.dtRowDeleted IS NULL and h.bIsSandbox = 0
			INNER JOIN dbo.InvoiceMaster IM WITH (NOLOCK) on IM.cSolomonKey = T.cSolomonKey
			WHERE LTC.bIsEFT = 1 
			<cfif #arguments.showall# is not "Y">
				AND EFTA.dtRowDeleted is  null   
				AND ts.bUsesEFT =  1 
			</cfif>  
			AND ts.iTenantStateCode_ID = 2
			AND EFTA.iContact_ID = LTC.iContact_ID	
			AND im.cAppliesToAcctPeriod =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.AcctPeriod#">	
			AND IM.dtRowDeleted is null		
			<cfif #arguments.days# is "seldays">
				<cfif #arguments.strtday# is 1>
					AND  (((EFTA.iDayofFirstPull BETWEEN <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">)
					OR (EFTA.iDayofSecondPull BETWEEN <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">))	
					OR 	(EFTA.iDayofFirstPull is null))
				<cfelse>
					AND  ((EFTA.iDayofFirstPull BETWEEN <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">)
					OR (EFTA.iDayofSecondPull BETWEEN <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.strtday#"> AND <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.endday#">))
				</cfif>
			</cfif>											
			AND t.ihouse_id <> 200
			
			ORDER BY cHouseName, cSolomonkey, EFTA.iOrderofPull
		</cfquery>	
		<cfreturn qryEFTInfo>
	</cffunction>

	<cffunction access="public" name="getInvAmt" output="false" returntype="query" hint="I return a recordset with the invoice details">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="solomonKey" required="true" type="string">
		<cfargument name="AcctPeriod" required="true" type="string">
		<cfargument name="All" required="false" type="boolean" default="0">

		<cfquery name="qInvAmt" datasource="#arguments.datasource#">
			SELECT  IM.mLastInvoiceTotal,
				IM.dtInvoiceStart, 
				IM.mInvoiceTotal,
				IM.dtInvoiceEnd, 
				IM.iInvoiceMaster_ID
				<cfif arguments.all EQ 1>
				,(SELECT  sum (inv.iquantity * inv.mamount) 
				 FROM  InvoiceDetail INV 
				 WHERE IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID AND INV.dtrowdeleted is null) as 'TipsSum'
				</cfif>
			FROM InvoiceMaster IM WITH (NOLOCK)
			WHERE  IM.cSolomonKey =   <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.solomonKey#">
			AND IM.bMoveOutInvoice is null						 
			AND IM.bFinalized = 1 
			AND im.cAppliesToAcctPeriod =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.AcctPeriod#">
			AND im.dtRowDeleted IS NULL
		</cfquery>
		<cfreturn qInvAmt>
	</cffunction>

	<cffunction access="public" name="getSumPaymnt" output="false" returntype="query" hint="I return a recordset with the payment information">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="solomonKey" type="string" required="true">

		<cfquery name="qrySumPaymnt" datasource="#arguments.datasource#">
			SELECT sum(isnull(dAmtSecondPull,0) + isnull(dAmtFirstPull,0)) as dollarsum
			FROM dbo.EFTAccount efta  WITH (NOLOCK)
			WHERE  dtRowDeleted is null 
			AND csolomonkey =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.solomonkey#">
		</cfquery>
		<cfreturn qrySumPaymnt>
	</cffunction>

	<cffunction access="public" name="getlatefee" output="false" returntype="query">
		<cfargument name="solomonKey" required="true" type="string">
		<cfargument name="AcctPeriod" required="true" type="string">
		<cfquery name="qrylatefee" datasource="#application.datasource#">
			SELECT SUM(mAmount) as LateFeeAmount
			FROM (  <!--- Gets the sum of all Late Fees not Paid or Waived--->
					SELECT  IsNull(sum(mLateFeeAmount),0) as mAmount
					FROM TenantLateFee tlf WITH (NOLOCK)
					WHERE dtRowdeleted is Null
					AND  dtLateFeeDelete is null  
					AND  dtLateFeePaid is null    
					AND cAppliesToAcctPeriod <= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.acctPeriod#">	
					AND isNull(bpaid,0) = 0
					AND isNull(bAdjustmentDelete,0) = 0
					AND isNull(bPartialPaid,0) = 0
					AND  tlf.cSolomonKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.solomonkey#">
					UNION ALL

					<!--- Gets the sum of the unpaid portion of partially paid late fees--->
					SELECT  IsNUll(sum(mActualLateFee - mLateFeePartialPayment),0) as mAmount
					FROM TenantLateFee tlf WITH (NOLOCK)
					INNER JOIN TenantLateFeeAdjustmentDetail lfa WITH (NOLOCK) ON lfa.iInvoiceLateFee_ID = tlf.iInvoiceLateFee_Id AND lfa.dtRowDeleted is null
					WHERE tlf.dtRowdeleted is Null
					AND tlf.dtLateFeeDelete is null	  
					AND tlf.dtLateFeePaid is null	  
					AND tlf.cAppliesToAcctPeriod <= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.acctPeriod#">	
					AND isNull(tlf.bPartialPaid,0) = 1
					AND  tlf.cSolomonKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.solomonkey#">

					) as LateFeeAmount  
				</cfquery> 	
		<cfreturn qrylatefee>
	</cffunction>

</cfcomponent>