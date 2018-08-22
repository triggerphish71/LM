<!---  
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|sfarmer     |03/20/2012  |  Added for deferred New Resident Fee project 75019                 |
|            |            |                                                                    |
----------------------------------------------------------------------------------------------->

 <cfparam  name="pulldaystart" default="">
 <cfparam  name="pulldayend" default="">
 
 <cfset todaysdate = #now()#>
 
 
 
 	<cfquery name="EFTinfo" datasource="#application.datasource#">
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
			,EFTA.dtRowEnd							
			,h.cname as 'cHouseName'
			,h.ihouse_id  AS 'houseID'
			,IM.mInvoiceTotal
			,TS.dDeferral 
			,TS.dSocSec 
			,TS.dMiscPayment
			,TS.dMakeUpAmt		
		FROM  
		dbo.tenant T join dbo.tenantstate ts on  t.iTenant_ID = ts.iTenant_ID
		 join dbo.house h on t.ihouse_id = h.ihouse_id
		 join dbo.InvoiceMaster IM on IM.cSolomonKey = T.cSolomonKey 
		 join EFTAccount EFTA on  EFTA.cSolomonKey = T.cSolomonKey
		
		WHERE 
			 EFTA.iContact_id is  null
			<cfif showall is not "Y">
			  and EFTA.dtRowDeleted is  null 
			  and  EFTA.dtRowEnd  is  null   
			</cfif>
			and ts.iTenantStateCode_ID = 2
			and im.cAppliesToAcctPeriod = '#AcctPeriod#'
			  and IM.bFinalized = 1 
			and IM.bMoveInInvoice is null 	
			and IM.bMoveOutInvoice is null					 
			and ts.bUsesEFT =  1
	 			
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
			,EFTA.dtRowEnd				
				,h.cname as 'cHouseName'
				,h.ihouse_id  AS 'houseID'
				,IM.mInvoiceTotal
				,TS.dDeferral 
				,TS.dSocSec 
				,TS.dMiscPayment
				,TS.dMakeUpAmt	
			FROM 
			dbo.tenant T join dbo.tenantState TS on T.iTenant_ID = ts.iTenant_ID
			   	join dbo.LinkTenantContact LTC on  T.iTenant_ID = LTC.iTenant_ID 
					join dbo.Contact C on LTC.iContact_ID = C.iContact_ID
						join dbo.EFTAccount EFTA  on EFTA.cSolomonKey = T.cSolomonKey 
							join dbo.house h on t.ihouse_id = h.ihouse_id
								join dbo.InvoiceMaster IM on IM.cSolomonKey = T.cSolomonKey
			WHERE 
 				LTC.bIsEFT = 1 
			<cfif showall is not "Y">
			  and EFTA.dtRowDeleted is  null 
			  and  EFTA.dtRowEnd  is  null   
			</cfif>
				and ts.iTenantStateCode_ID = 2
  				and im.cAppliesToAcctPeriod = '#AcctPeriod#'  
				  and IM.bFinalized = 1 
				and IM.bMoveInInvoice is null 	
				and IM.bMoveOutInvoice is null						 
				and ts.bUsesEFT =  1				 
				and EFTA.iContact_ID = LTC.iContact_ID
			order by cHouseName, cSolomonkey, EFTA.iOrderofPull
	</cfquery>	


