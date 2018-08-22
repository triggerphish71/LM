<!----------------------------------------------------------------------------------------------
| DESCRIPTION - Houseinsert.cfm                                                                  |
|----------------------------------------------------------------------------------------------|
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|Sathya      | 08/25/2010 | Project 59492 Added the option to change the Assessment review     |
|            |            | state. Also added the flowerbox                                    |
|            |            | If no assessment review is selected and it will by default set it  |
|            |            | to 90 days of which the period_Id = 1                              |
| sfarmer    | 11/26/2013 | #107924 - Leading zero in zipcode is being dropped - fixed by using|
|            |            | <cfqueryparam  cfsqltype="cf_sql_varchar" value="#form.cZipCode#"> |
| SFarmer    | 04/27/2017 | Added fields County, OPCO, OPCO_EIN                                |
----------------------------------------------------------------------------------------------->


<!--- Concat. Phone Number from areacode prefix and number --->
<cfset Phone1 = trim(form.areacode1) & trim(form.prefix1) & trim(form.number1)>
<cfset Phone2 = trim(form.areacode2) & trim(form.prefix2) & trim(form.number2)>
<cfset Phone3 = trim(form.areacode3) & trim(form.prefix3) & trim(form.number3)>

<cftransaction>
	<cfquery NAME = "HouseInsert"	DATASOURCE = "#APPLICATION.datasource#">				
	insert into House
	(iOpsArea_ID, iPDUser_ID,	iAcctUser_ID, 	cName, 
	cNumber, 	cDepositTypeSet, 	cSLevelTypeSet, 	cGLsubaccount, 
	bIsCensusMedicaidOnly, 	cPhoneNumber1, 	iPhoneType1_ID, 	cPhoneNumber2, 
	iPhoneType2_ID, 	cPhoneNumber3, 	iPhoneType3_ID, 	cAddressLine1, 
	cAddressLine2, 	cCity, 	cStateCode, 	cZipCode, 
	<!---08/25/2010 Project 59492 added this for iPeriod_Id  --->
	iPeriod_id, 
	<!---End of code Project 59492  --->
	cComments, 	iRowStartUser_ID, 	dtRowStart	)
	values
	(<cfif form.iOPSArea_ID neq "">	#trim(form.iOPSArea_ID)#, <cfelse>	NULL,	</cfif>	 
	<cfif form.iPDUser_ID neq "">	#trim(form.iPDUser_ID)#, <cfelse>	NULL,	</cfif> 
	<cfif form.iAcctUser_ID neq "">	#trim(form.iAcctUser_ID)#, <cfelse>	NULL,	</cfif>
	<cfif form.cName neq ""> '#trim(form.cName)#', <cfelse>	NULL,	</cfif> 
	<cfif form.cNumber neq ""> #trim(form.cNumber)#, <cfelse>	NULL,	</cfif> 
	<cfif isDefined("form.cDepositTypeSet") and form.cDepositTypeSet neq ""> #trim(form.cDepositTypeSet)#, <cfelse>	NULL,	</cfif> 
	<cfif form.cSLevelTypeSet neq "">	#trim(form.cSLevelTypeSet)#, <cfelse>	NULL,	</cfif> 
	<cfif form.cGLsubaccount neq ""> '#trim(form.cGLSubaccount)#', <cfelse> 	NULL,	</cfif> 
	<cfif IsDefined("form.bIsCensusMedicaidOnly")>	#trim(form.bIsCensusMedicaidOnly)#,	<cfelse>	NULL,	</cfif>
	<cfif Phone1 neq ""> #trim(Phone1)#, <cfelse>	NULL,	</cfif>	
	<cfif form.iPhoneType1_ID neq "">	#trim(form.iPhoneType1_ID)#, <cfelse>	NULL,	</cfif>
	<cfif Phone2 neq ""> #trim(Phone2)#, <cfelse>	NULL,	</cfif>	
	<cfif form.iPhoneType2_ID neq "">	#trim(form.iPhoneType2_ID)#,  <cfelse>	NULL,	</cfif> 
	<cfif Phone3 neq ""> #trim(Phone3)#, <cfelse>	NULL,	</cfif>	
	<cfif form.iPhoneType3_ID neq ""> #trim(form.iPhoneType3_ID)#, <cfelse>	NULL,	</cfif> 
	<cfif form.cAddressLine1 neq ""> '#trim(form.cAddressLine1)#', <cfelse>	NULL,	</cfif> 
	<cfif form.cAddressLine2 neq ""> '#form.cAddressLine2#', <cfelse>	NULL,	</cfif> 
	<cfif form.cCity neq ""> '#trim(form.cCity)#', <cfelse>	NULL,	</cfif>
	<cfif form.cStateCode neq ""> '#trim(form.cStateCode)#', <cfelse>	NULL,	</cfif>
	<cfif form.cZipCode neq "">	<cfqueryparam  cfsqltype="cf_sql_varchar" value="#form.cZipCode#">, <cfelse>	NULL,	</cfif>
	<!---08/25/2010 Project 59492 added this for iPeriod_Id  --->
	<cfif form.Period_id neq "">
		#trim(form.Period_id)#,
	<cfelse>
		1,
	</cfif>
		,<cfif isDefined("form.County")> County = #county# <cfelse> County = null </cfif>
		,<cfif isDefined("form.OPCO")> OPCO = #OPCO# <cfelse> OPCO = null </cfif>
		,<cfif isDefined("form.OPCO_EIN")> OPCO_EIN = #OPCO_EIN# <cfelse> OPCO_EIN = null </cfif>		
	<!---End of code Project 59492  --->
	
	<cfif form.cComments neq ""> '#trim(form.cComments)#', <cfelse>	NULL,	</cfif>	
	#SESSION.UserID#, 
	getDate() 
	)
	</cfquery>
</cftransaction>
<cflocation url="House.cfm" ADDTOKEN="No">
