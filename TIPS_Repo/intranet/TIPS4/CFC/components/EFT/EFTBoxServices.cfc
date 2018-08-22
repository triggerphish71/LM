
component  
	displayName="EFT Box Services" 
	output="false"
	hint="I provide all the functions for the EFT Box process"
{

	/**
	@hint returns a recordset with all the EFT informaiton for the resident
	@arg1 is a non required argument that defaults to the application.datasource. If we want to override the application datasource we can pass in a specific datasource
	@arg2 is a required argument which is the solomonKey
	**/

	public query function eftInfo(string datasource="#application.datasource#",required string solomonKey){
		local.qEftInfo=new Query();
		local.qEftInfo.setDatasource(arguments.datasource);
		local.qEftInfo.addParam(name="solomonkey" ,value="#arguments.solomonKey#",  cfsqltype="cf_sql_varchar");
		local.qEftInfo.setSQL("
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
			FROM  tenant T WITH (NOLOCK)
			INNER JOIN EFTAccount EFTA WITH (NOLOCK) on  EFTA.cSolomonKey = T.cSolomonKey
			INNER JOIN tenantstate ts WITH (NOLOCK) on ts.itenant_id = t.itenant_id
			WHERE T.cSolomonKey = :solomonkey		
			AND EFTA.iContact_id is  null					
		UNION
			SELECT
				t.clastname + ', ' + T.cfirstname	as 'TenantName'	
				,t.csolomonkey	
				,C.cFirstName + ' ' +  C.cLastName as  'ContactName' 
				,T.itenant_id
				,C.cemail as 'Email'
				,LTC.bIsEFT 
				,LTC.bIsPrimaryPayer	as 'PrimaryPayer'	
				,LTC.bIsGuarantorAgreement		
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
			FROM tenant t WITH (NOLOCK)
			INNER JOIN LinkTenantContact ltc WITH (NOLOCK) on t.iTenant_id = ltc.iTenant_ID AND LTC.bIsEFT =  1	
			INNER JOIN Contact c WITH (NOLOCK) ON ltc.iContact_ID = c.iContact_ID
			INNER JOIN EFTAccount efta WITH (NOLOCK) ON t.cSolomonKey = efta.cSolomonKey AND c.iContact_ID = efta.iContact_id
			WHERE T.cSolomonKey = :solomonKey							
			ORDER BY  iOrderofPull 				
		");
		return local.qEftInfo.execute().getResult();		
	}  //end eftinfo

	/**
	@hint returns a recordset with payment information for a resident
	@arg1 is a non required argument that defaults to the application.datasource. If we want to override the application datasource we can pass in a specific datasource
	@arg2 is a required argument which is the solomonKey
	**/

	public query function sumPayment(string datasource="#application.datasource#", required string solomonKey){
		local.qSumPayment = new Query();
		local.qSumPayment.setDatasource(arguments.datasource);
		local.qSumPayment.addParam(name="solomonkey", cfsqltype="cf_sql_varchar", value="#arguments.solomonkey#");
		local.qSumPayment.setSQL("
			SELECT  sum(sumtable.dAmtFirstPull) as 'sumfirstamt'
					,sum(sumtable.dAmtSecondPull) as 'sumsecondamt' 
					,sum(sumtable.dPctFirstPull) as 'sumfirstpull'
					,sum (sumtable.dPctSecondPull) as 'sumsecondpull'
					,count(sumtable.iEFTAccount_ID) as 'eftcount'
			FROM(   SELECT EFTA.dAmtFirstPull, EFTA.dAmtSecondPull, EFTA.dPctFirstPull, EFTA.dPctSecondPull,EFTA.iEFTAccount_ID 
					FROM  dbo.tenant T WITH (NOLOCK)
					INNER JOIN dbo.EFTAccount EFTA WITH (NOLOCK) on  EFTA.cSolomonKey = T.cSolomonKey AND  EFTA.dtRowDeleted is  null  AND	EFTA.iContact_id is  null
					INNER JOIN tenantstate ts WITH (NOLOCK) on ts.itenant_id = t.itenant_id AND ts.bUsesEFT =   1 
					WHERE T.cSolomonKey = :solomonKey				
								
					UNION
					SELECT EFTA.dAmtFirstPull, EFTA.dAmtSecondPull, EFTA.dPctFirstPull, EFTA.dPctSecondPull,EFTA.iEFTAccount_ID 
					FROM  dbo.Tenant t WITH (NOLOCK) 
					INNER JOIN dbo.LinkTenantContact ltc WITH (NOLOCK) on t.iTenant_id = ltc.iTenant_id AND ltc.bIsEFT = 1
					INNER JOIN dbo.Contact c WITH (NOLOCK) ON ltc.iContact_Id = c.iContact_id
					INNER JOIN dbo.EFTAccount efta WITH (NOLOCK) ON t.cSolomonKey = efta.cSolomonKey AND c.iContact_id = efta.iContact_ID AND efta.dtRowDeleted IS NULL
					WHERE t.cSolomonKey = :solomonKey
				) as sumtable
		");
	 	return local.qSumPayment.execute().getResult();	
	} //end sumPayment

	/**
	@hint returns a recordset with invoice Amount total  for a resident
	@arg1 is a non required argument that defaults to the application.datasource. If we want to override the application datasource we can pass in a specific datasource
	@arg2 is a required argument which is the solomonKey
	@arg3 is a reqired argument which is the cAppliedToAcctPeriod
	**/

	public query function InvAmt(string datasource="#application.datasource#", required string solomonkey, required string acctPeriod){
		local.qInvAmt = new Query();
		local.qInvAmt.setDatasource(arguments.datasource);
		local.qInvAmt.addParam(name="solomonKey", cfsqltype="cf_sql_varchar", value="#arguments.solomonkey#");
		local.qInvAmt.addParam(name="acctPeriod", cfsqltype="cf_sql_varchar", value="#arguments.acctPeriod#");
		local.qInvAmt.setSQL("
			SELECT  TOP 1 IM.mLastINvoiceTotal,
				IM.dtInvoiceStart, 
				IM.dtInvoiceEnd, 
				IM.iInvoiceMaster_ID,
				( SELECT SUM(inv.iQuantity * inv.mAmount)
				  FROM  InvoiceDetail INV 
				  WHERE IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID 
				  AND INV.dtrowdeleted is null 
				  AND inv.ichargetype_ID <> 69
				) as 'TipsSum'

			FROM InvoiceMaster IM
		 	WHERE IM.cSolomonKey = :solomonkey 
			AND IM.bMoveOutInvoice is null						 
			AND IM.bFinalized = 1  
			AND im.cAppliesToAcctPeriod = :acctPeriod	
			AND im.dtRowDeleted IS NULL
			ORDER BY im.iInvoiceMaster_ID DESC
		");

		return local.qInvAmt.execute().getResult();

	} // end InvAmt	


	/**
	@hint returns a recordset with invoice Amount total  for a resident
	@arg1 is a non required argument that defaults to the application.datasource. If we want to override the application datasource we can pass in a specific datasource
	@arg2 is a required argument which is the solomonKey
	**/

	public query function sumpaymnt(string datasource="#application.datasource#", required string solomonkey){
		local.qSumPaymnt = new query();
		local.qSumPaymnt.setDatasource(arguments.datasource);
		local.qSumPaymnt.addParam(name="solomonkey", value=arguments.solomonkey, cfsqltype="cf_sql_varchar");
		local.qSumPaymnt.setSQL("
			SELECT sum(isnull(dAmtSecondPull,0) + isnull(dAmtFirstPull,0)) as dollarsum
		 	FROM dbo.EFTAccount efta  WITH (NOLOCK)
		 	WHERE  dtRowDeleted is null
		 	AND csolomonkey = :solomonkey
		");
		return local.qSumPaymnt.execute().getResult();
	}// end sumpaymnt




}  //end componet