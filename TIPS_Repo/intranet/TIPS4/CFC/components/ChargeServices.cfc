
component  
	displayName="Charge Services" 
	output="false"
	hint="I provide functions for charges"
{

	/**
	@hint returns the charge type iD for a specific description
	@arg1 is a non required argument that defaults to the application.datasource. If we want to override the application datasource we can pass in a specific datasource
	@arg2 is a required argument that is the where clause criteria
	**/

	public query function getChargeTypeID(string datasource="#application.datasource#",string required wherecondition){
		myQry=new Query();
		myQry.setDatasource(arguments.datasource);
		myQry.addParam(name="wherecondition" ,value="%#arguments.wherecondition#%",  cfsqltype="cf_sql_varchar");
		myQry.setSQL("
			SELECT iChargeType_ID
			FROM chargeType WITH (NOLOCK)
			WHERE cDescription LIKE :wherecondition
		");
		return myQry.execute().getResult();
		
	}

}

