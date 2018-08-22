<!----------------------------------------------------------------------------------------------
| DESCRIPTION - Houseupdate.cfm                                                                |
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
|------------|------------|--------------------------------------------------------------------|
| sfarmer    | 11/26/2013 | #107924 - Leading zero in zipcode is being dropped - fixed by using|
|            |            | <cfqueryparam  cfsqltype="cf_sql_varchar" value="#form.cZipCode#"> |
| SFarmer    | 04/27/2017 | Added fields County, OPCO, OPCO_EIN                                |
----------------------------------------------------------------------------------------------->

<!--- Concat. Phone Number from areacode prefix and number --->
<cfset Phone1 = form.areacode1 & form.prefix1 & form.number1>
<cfset Phone2 = form.areacode2 & form.prefix2 & form.number2>
<cfset Phone3 = form.areacode3 & form.prefix3 & form.number3>

<cfquery name="qhousebIsMedicaid" DATASOURCE="#APPLICATION.datasource#">
Select * from house where iHouse_ID= #form.iHouse_ID#
</cfquery>

<cfquery name="qryResidents" DATASOURCE="#APPLICATION.datasource#">
	select * from tenant t
	join tenantstate ts on t.itenant_id = ts.itenant_id
	join house h on t.ihouse_id = h.ihouse_id and h.iHouse_ID= #form.iHouse_ID#
	where ts.itenantstatecode_id in (1,2,3) 
		and ts.iresidencytype_id = 2
		and t.clastname <> 'Medicaid'
</cfquery>	
<!---<cfdump var="#qhousebIsMedicaid#"> <cfdump var="#qryResidents#">--->
<cfquery name="qryMemoryCareResidents" DATASOURCE="#APPLICATION.datasource#">
	select * from tenant t
	join tenantstate ts on t.itenant_id = ts.itenant_id
	join house h on t.ihouse_id = h.ihouse_id and h.iHouse_ID= #form.iHouse_ID#
	where ts.itenantstatecode_id in (1,2,3) 
		and ts.iProductline_ID = 2
		
</cfquery>
<cfif #qhousebIsMedicaid.bIsMedicaid# eq 1 and not isDefined("form.bIsMedicaid") and #qryResidents.recordcount# gt 0>
			
		<cfinclude template="../../../header.cfm">
<cfoutput>
	   <table>
		<tr><td>Removing #qhousebIsMedicaid.cName# from Medicaid eligibilty is not allowed at this time.
		<br>There are residents still in the system at one or more of the following statuses:</td></tr>
		<tr><td><ul><li>Inquiry/Move-In</li><li>Current Resident</li><li>Move-Out Not Finalize</li></ul></td></tr>
		</table>
</cfoutput>
<cfelseif #qhousebIsMedicaid.bIsMemoryCare# eq 1 and not isDefined("form.bIsMemoryCare") and #qryMemoryCareResidents.recordcount# gt 0> 
	
		<cfinclude template="../../../header.cfm">
<cfoutput>
	   <table>
		<tr><td>Removing #qhousebIsMedicaid.cName# from Memory Care eligibilty is not allowed at this time.
		<br>There are residents still in the system at one or more of the following statuses:</td></tr>
		<tr><td><ul><li>Inquiry/Move-In</li><li>Current Resident</li><li>Move-Out Not Finalize</li></ul></td></tr>
		</table>
</cfoutput>
<cfelse>
<cfquery name="HouseUpdate"	DATASOURCE="#APPLICATION.datasource#">
	update house set 
		<cfif form.iOpsArea_ID neq ""> iOpsArea_ID = #trim(form.iOPSArea_ID)#, <cfelse> iOpsArea_ID = null, </cfif>
		<cfif form.iPDUser_ID neq ""> iPDUser_ID = #trim(form.iPDUser_ID)#, <cfelse> iPDUser_ID = null, </cfif>	
		<cfif form.iPDUser_ID neq ""> iAcctUser_ID = #trim(form.iAcctUser_ID)#, <cfelse> iAcctUser_ID =	null, </cfif>				
		<cfif form.cName neq ""> cName = '#trim(form.cName)#', <cfelse> cName = null, </cfif>	
		<cfif form.cNumber neq ""> cNumber = #trim(form.cNumber)#, <cfelse> cNumber = null, </cfif>	
		<cfif isDefined("form.cDepositTypeSet") and form.cDepositTypeSet neq ""> cDepositTypeSet = '#trim(form.cDepositTypeSet)#', <cfelse> cDepositTypeSet =	null, </cfif>
		<cfif form.cSLevelTypeSet neq ""> cSLevelTypeSet = #trim(form.cSLevelTypeSet)#, <cfelse> cSLevelTypeSet = null, </cfif>	
		<cfif form.cGLsubaccount neq ""> cGLsubaccount = '#trim(form.cGLSubaccount)#', <cfelse> cGLsubaccount = null, </cfif>	
		<cfif isDefined("form.bIsCensusMedicaidOnly")> bIsCensusMedicaidOnly = #trim(form.bIsCensusMedicaidOnly)#, <cfelse> bIsCensusMedicaidOnly = null, </cfif>	
	    <cfif Variables.Phone1 neq ""> cPhoneNumber1 = #trim(Variables.Phone1)#, <cfelse> cPhoneNumber1 = null, </cfif>	
		<cfif form.iPhoneType1_ID neq ""> iPhoneType1_ID = #trim(form.iPhoneType1_ID)#, <cfelse> iPhoneType1_ID = null, </cfif>	
		<cfif Variables.Phone2 neq ""> cPhoneNumber2 = #trim(Variables.Phone2)#, <cfelse> cPhoneNumber2	= null, </cfif>	
		<cfif form.iPhoneType2_ID neq "">iPhoneType2_ID = #trim(form.iPhoneType2_ID)#, <cfelse> iPhoneType2_ID = null, </cfif>	
		<cfif Variables.Phone3 neq ""> cPhoneNumber3 = #trim(Variables.Phone3)#, <cfelse> cPhoneNumber3	= null, </cfif>	
		<cfif form.iPhoneType3_ID neq "">iPhoneType3_ID = #trim(form.iPhoneType3_ID)#, <cfelse> iPhoneType3_ID = null, </cfif>	
		<cfif form.cAddressLine1 neq ""> cAddressLine1 = '#trim(form.cAddressLine1)#', <cfelse> cAddressLine1 = null, </cfif>
		<cfif form.cAddressLine2 neq ""> cAddressLine2 = '#trim(form.cAddressLine2)#', <cfelse> cAddressLine2 = null, </cfif>	
		<cfif form.cCity neq ""> cCity = '#trim(form.cCity)#', <cfelse> cCity = null, </cfif>
		<cfif form.cStateCode neq ""> cStateCode = '#trim(form.cStateCode)#', <cfelse> cStateCode = null, </cfif>
		<!--- <cfif form.cZipCode neq ""> cZipCode = #trim(form.cZipCode)#, <cfelse> cZipCode = null, </cfif> --->
		<cfif form.cZipCode neq ""> cZipCode = <cfqueryparam  cfsqltype="cf_sql_varchar" value="#form.cZipCode#">, <cfelse> cZipCode = null, </cfif>
		<cfif form.cComments neq ""> cComments = '#trim(form.cComments)#', <cfelse> cComments = null, </cfif>	
		<cfif form.cNurseUser_id neq ""> cNurseUser_id= '#trim(form.cNurseUser_id)#', <cfelse> cNurseUser_id = null, </cfif>	
		<!---08/25/2010 Project 59492 added this for iPeriod_Id  --->
		<cfif form.Period_id neq "">
			iPeriod_id = #trim(form.Period_id)#,
		<cfelse>
			iPeriod_id = 1,
		</cfif>
		<!---End of code Project 59492  --->
		iRowStartUser_ID = #Session.UserID#,
		dtRowStart = getDate(),
		<!---mamta added for medicaid project--->
		<cfif isDefined("form.bIsMedicaid")> bIsMedicaid = 1 <cfelse> bIsMedicaid = null </cfif>	
		<!---mamta added for memorycare project--->
		,<cfif isDefined("form.bIsMemoryCare")> bIsMemoryCare = 1 <cfelse> bIsMemoryCare = null </cfif>

		,<cfif isDefined("form.County")> County = '#county#' <cfelse> County = null </cfif>
		,<cfif isDefined("form.OPCO")> OPCO = '#OPCO#' <cfelse> OPCO = null </cfif>
		,<cfif isDefined("form.OPCO_EIN")> OPCO_EIN = '#OPCO_EIN#' <cfelse> OPCO_EIN = null </cfif>				
where dtrowdeleted is null and iHouse_ID = #form.iHouse_ID#
</cfquery>

<cfdump var="#form#">

<cfoutput>
	<cfif IsDefined("form.cSLevelTypeSet")>
		<cfset SESSION.cSLevelTypeSet	= #form.cSLevelTypeSet#>
	</cfif>
</cfoutput>

<cfif SESSION.USERID IS 3025>
	<A HREF="House.cfm">	Continue </A>
<cfelse>
	<CFLOCATION URL="House.cfm" ADDTOKEN="No">
</cfif>
</cfif>	
