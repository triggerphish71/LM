
component  
	displayName="Tenant AR Services" 
	output="false"
	hint="I provide services used in the Tenant AR section"
{

	/**
	@hint returns the resident information
	@arg1 is a non required argument that defaults to the application.datasource. If we want to override the application datasource we can pass in a specific datasource
	@arg2 is a required argument this is the ResidentID (cSolomonKey) from the tenant table.
	**/

	public query function getResidentInfoByKey(string datasource="#application.datasource#",required string solomonid){
		myQry=new Query();
		myQry.setDatasource(arguments.datasource);
		myQry.addParam(name="solomonid" ,value="#arguments.solomonid#",  cfsqltype="cf_sql_varchar");
		myQry.setSQL("
			SELECT h.cname as house, h.iHouse_id, t.cFirstname, t.cLastname, t.cSolomonKey, t.itenant_id,
			       ts.dtMoveOutProjectedDate, ts.dtMoveOut, ts.dtNoticeDate, ts.dtChargeThrough, ts.iResidencyType_ID
			FROM tenant t WITH (NOLOCK)
			INNER JOIN tenantstate ts WITH (NOLOCK) on t.iTenant_id = ts.iTenant_id
			INNER JOIN house h WITH (NOLOCK) on t.iHouse_Id = h.iHouse_id
			WHERE t.cSolomonKey = :solomonid			
		");
		return myQry.execute().getResult();			
	}


	public void function saveTenantAREditData(   string  moveoutdate="",  string projectmoveoutdate="",  string chargedate="", required numeric tenantID){

		myQuery = new Query();
		myQuery.setDatasource(application.datasource);		
		myQuery.addParam(name="moveoutdate", value="#arguments.moveoutdate#", cfsqltype="cf_sql_date", null="#Len(arguments.moveoutdate) EQ 0#");
		myQuery.addParam(name="projectmoveoutdate", value="#arguments.projectmoveoutdate#", cfsqltype="cf_sql_date", null="#Len(arguments.projectmoveoutdate) EQ 0#");
		myQuery.addParam(name="chargedate", value="#arguments.chargedate#", cfsqltype="cf_sql_date", null="#Len(arguments.chargedate) EQ 0#");
		myQuery.addParam(name="tenantId", value="#arguments.tenantID#", cfsqltype="cf_sql_numeric");
		myQuery.setSQL("
			UPDATE tenantstate
			SET dtMoveOut = :moveoutdate,
			    dtChargeThrough = :chargedate,
			    dtMoveOutProjectedDate = :projectmoveoutdate
			WHERE itenant_id = :tenantId 
		");
		myQuery.execute();
	}

	public query function getResidentInvoiceInfoByKey(string datasource="#application.datasource#", required string solomonid){
		myQry=new Query();
		myQry.setDatasource(arguments.datasource);
		myQry.addParam(name="solomonid" ,value="#arguments.solomonid#",  cfsqltype="cf_sql_varchar");
		myQry.setSQL('
			SELECT h.cname as "house",h.iHouse_id, t.cFirstName, t.cLastName, t.cSolomonKey, t.iTenant_id,
				ts.dtMoveOutProjectedDate, ts.dtMoveOut, ts.dtNoticeDate, ts.dtChargeThrough, im.cAppliesToAcctPeriod,
				im.mInvoiceTotal, im.mLastInvoiceTotal, im.iinvoicemaster_id, im.iinvoicenumber, ts.iResidencyType_ID
			from tenant t WITH (NOLOCK)
			inner join tenantstate ts WITH (NOLOCK) on t.itenant_id = ts.itenant_id
			inner join house h WITH (NOLOCK) on h.ihouse_id = t.ihouse_id
			inner join invoicemaster im WITH (NOLOCK) on im.csolomonkey = t.csolomonkey and im.dtrowdeleted is null
			where t.csolomonkey = :solomonid	
			and im.dtrowdeleted is null
			order by im.cappliestoacctperiod desc, im.dtinvoicestart desc
		');
	 return myQry.execute().getResult();
	}	

}  //end component



		