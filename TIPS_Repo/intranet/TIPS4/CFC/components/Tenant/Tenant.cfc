
component  
	displayName="Tenant Services" 
	output="false"
	hint="I provide the results set of a tenant"
{

	/**
	@hint returns the resident information based on solomon Key or resident id
	@arg1 is a non required argument that defaults to the application.datasource. If we want to override the application datasource we can pass in a specific datasource
	@arg2 is a required argument this is the ResidentID (cSolomonKey) from the tenant table.
	**/

	public query function getResidentInfoByKey(string datasource="#application.datasource#",required string solomonid){
		myQry=new Query();
		myQry.setDatasource(arguments.datasource);
		myQry.addParam(name="solomonid" ,value="#arguments.solomonid#",  cfsqltype="cf_sql_varchar");
		myQry.setSQL("
			SELECT itenant_id
			FROM tenant t			
			WHERE t.cSolomonKey = :solomonid			
		");
		local.tenantInfo = myQry.execute().getResult();
		return getResidentInfoById(tenantID=local.tenantInfo.iTenant_ID);			
	}



   public query function getResidentInfoById(string datasource="#application.datasource#", required numeric tenantID){

   	 TenantInfo = new Query();
   	 TenantInfo.setDatasource(arguments.datasource);
   	 TenantInfo.addParam(name="tenantID", value="#arguments.tenantId#", cfsqltype="cf_sql_integer");
   	 TenantInfo.setSQL("
   	 		SELECT	 (T.cFirstName + ' ' + T.cLastName) as FullName
   	 		,t.cFirstName
   	 		,t.cLastName
   	 		,t.csolomonkey
			,t.bispayer
			,t.iTenant_id
			,t.ihouse_id
			,t.cchargeset
			,t.itenant_id	
			,t.CBILLINGTYPE
			
			,ts.iTenantStateCode_ID
			,ts.iResidencyType_ID
			,ts.cSecDepCommFee,		
			,tS.dtMoveIn
			,ts.dtrenteffective
			,ts.mMedicaidCopay 
			,TS.bNRFPend
			,ts.iMonthsDeferred as PaymentMonths
			,ts.mBaseNrf as NRFBase
			,ts.mAdjNrf as NRFAdj	
			,ts.MADJNRF
			,ts.ispoints
			,ts.MBASENRF 
			,ts.IPRODUCTLINE_ID
			,ts.dtChargeThrough
			,ts.mBSFDisc 
			,ts.mBSFOrig
			,ts.IMONTHSDEFERRED  
			,TS.iAptAddress_ID 
			,ts.dtMoveOutProjectedDate
			,ts.dtMoveOut
			,ts.MAMTDEFERRED
			,ts.dtNoticeDate
			
			,HMed.MSTATEMEDICAIDAMT_BSF_DAILY
			,HMed.mMedicaidBSF

			,RT.cDescription
						
			,ad.IAPTTYPE_ID 
		
			,h.cName HouseName 
			,h.cstatecode
			,h.cNumber
		
		FROM	TENANT	T WITH (NOLOCK)
		Join    TenantState TS WITH (NOLOCK) on T.itenant_id = TS.itenant_id
		JOIN 	House H WITH (NOLOCK) on h.ihouse_id = T.ihouse_id
		JOIN 	AptAddress AD WITH (NOLOCK) ON AD.iAptAddress_ID = TS.iAptAddress_ID
		JOIN 	ResidencyType RT WITH (NOLOCK) ON RT.iResidencyType_ID = TS.iResidencyType_ID
		left join HouseMedicaid HMed WITH (NOLOCK) on t.ihouse_id = HMed.ihouse_id
		WHERE	T.iTenant_ID = :tenantID
   	 ");
   	 return TenantInfo.execute().getResult();	

   }


} // end component