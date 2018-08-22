component  
	displayName="Solomon Services" 
	output="false"
	hint="I provide functions to get data from solomon"
{


	/**
	@hint returns a recordset with all the SolomonTotal for the resident
	@arg1 is a non required argument that defaults to the application.datasource. If we want to override the application datasource we can pass in a specific datasource
	@arg2 is a required argument which is the custid  (solomonKey)
	@arg3 is a required argument which is invoiceStart date
	@arg4 is a required argument which is invoiceEnd date
	**/

	public query function getSolomonTotal(string datasource="#application.datasource#", required string custid, required date invoiceStart, required date invoiceEnd){
		local.qSolomonTotal = new Query();
		local.qSolomonTotal.setDatasource(arguments.datasource);
		local.qSolomonTotal.addParam(name="custid", value=arguments.custid, cfsqltype="cf_sql_varchar");
		local.qSolomonTotal.addParam(name="invoiceStart", value=arguments.invoiceStart, cfsqltype="cf_sql_datetime");
		local.qSolomonTotal.addParam(name="invoiceEnd", value=arguments.invoiceEnd, cfsqltype="cf_sql_date");
		result = local.qSolomonTotal.execute(sql="
			SELECT isNULL(SUM(amount),0) as 'SolomonTotal'
			FROM rw.vw_Get_Trx
			WHERE custid = :custid
			AND rlsed = 1
			AND user7 > :invoiceStart
			AND user7 <= :invoiceEnd
		");
		return result.getResult();
	} // end getSolomonTotal


	/**
	@hint returns a recordset with all the SolomonTotal for the resident
	@arg1 is a non required argument that defaults to the application.datasource. If we want to override the application datasource we can pass in a specific datasource
	@arg2 is a required argument which is the custid  (solomonKey)
	@arg3 is a required date which is the invoiceEnd date time
	**/

	public query function getOffSet(string datasource="#application.datasource#",required string custid, required date invoiceEnd){
		local.qryOffSet = new query();
		local.qryOffSet.setDatasource(arguments.datasource);
		local.qryOffSet.addParam(name="custid", cfsqltype="cf_sql_varchar", value=arguments.custid);
		local.qryOffSet.addParam(name="invoiceEnd", cfsqltype="cf_sql_datetime", value=arguments.invoiceEnd);
		result = local.qryOffSet.execute(sql="
			SELECT isNULL(SUM(amount),0) as 'paOffSet'
    		FROM rw.vw_Get_Trx 
			WHERE custid = :custid
			AND rlsed = 1 
			AND user7 > :invoiceEnd
			AND user7 <= getDate()
	 		AND doctype IN ('PA' , 'CM' , 'RP' , 'NS' , 'NC' ) 
		");
		return result.getResult();
	} // end getOffSet 


} //end component 