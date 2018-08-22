<!---------------------------------------------------------------------------------------------------
|Name:       UpdateHouseLateFee.cfm                                                                      |
|Type:       Template                                                                                |
|Purpose:    This page updates the late fee info for the house when entered by the AR ADmin          |
|                                                                                                    |
|----------------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                                  |
|----------------------------------------------------------------------------------------------------|
|  none                                                                                              |
|----------------------------------------------------------------------------------------------------|
|Called by: LateFeeExemptTenants.cfm                                                                                 |
|    Parameter Name                      Description                                                 |
|----------------------------------------------------------------------------------------------------|
   #SESSION.qSelectedHouse.iHouse_ID#   The house id is being used to pull data for all the queries  |
|																									 |
|Calls: 															                            	 |
|    Parameter Name                      Description                                                 |
|    ------------------------------      ------------------------------------------------------------|
|    None
|																									 |
| -------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                              |
|------------|------------|--------------------------------------------------------------------------|
| Sathya  	 |03/11/10    | Created this page as part of project 20933 Late Fees                     |
------------------------------------------------------------------------------------------------------>

<!--- See if the required variables  exisits if not throw an error --->
 <cftry>
	<cfif NOT isDefined("session.qselectedhouse.ihouse_id")>
	   <!--- throw the error --->
	   <cfthrow message = "Session has expired please try again later. Try to logout and log back in to TIPS">
	</cfif>
	 	
<cfcatch type = "application">
  <cfoutput>
    <p>#cfcatch.message#</p>
	<br></br>
	<a href='LateFeeExemptTenants.cfm'><p>Click here to go back.</p></a>
 </cfoutput>
	<CFABORT>
</cfcatch>
</cftry>

<cfquery name="getHouseLateFeeinfo" DATASOURCE = "#APPLICATION.datasource#">
	Select *
	From
	HouseLateFee where iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# and dtRowDeleted is null
</CFQUERY>

<cfoutput>
<cfif getHouseLateFeeinfo.recordcount gt 0 and isDefined(form.forDelete)>
	<cftransaction>
	<cftry>
		<!--- Mark the present record as deleted in teh houselatefee table --->
		 <cfquery name= "UpdateLateFeeinfoforhouse" datasource = "#APPLICATION.datasource#">
					update HouseLateFee
					set   dtRowDeleted = getDate(),
						  iRowDeletedUser_ID = #SESSION.UserID#
					where ihouse_id =#SESSION.qSelectedHouse.iHouse_ID# 
					  and iHouseLateFee_ID = #getHouseLateFeeInfo.iHouseLateFee_ID#
		</cfquery> 
		<!--- Mark it as null for the house record --->
		<cfquery name="UpdateHouseinfo" datasource = "#APPLICATION.datasource#">
				update House
				 set iHouseLateFee_ID = NULL
				 Where iHouse_id = #SESSION.qSelectedHouse.iHouse_ID#
		</cfquery>
		<cfcatch type = "DATABASE">
			 <cftransaction action = "rollback"/>
		</cfcatch>
		</cftry>
	</cftransaction> 
<cfelse>
	<cftransaction>
	<cftry>
	<!--- Insert a new record in the houselatefee table --->
	<cfquery name= "InsertLateFeeinfoforhouse" datasource = "#APPLICATION.datasource#">
				INSERT INTO HouseLateFee (iHouse_id, mLateFeeAmount, mMinimumBalanceForLateFee, cAppliesToAcctYear, iRowStartUser_ID, dtrowStart) 
				Values   ( 
				 			#SESSION.qSelectedHouse.iHouse_ID#
				           ,#form.LateFeeAmount#
                           ,#Form.MinimumBalanceForLateFee#
						   ,#Form.AppliesToAcctYear#
						   ,#SESSION.UserID#
						   ,getdate()
						  )
	</cfquery> 
	<!--- Get the new record that was inserted from the above query --->
	<cfquery name="getHouseinfo" datasource = "#APPLICATION.datasource#">
		Select iHouseLateFee_ID 
		from HouseLateFee
		Where iHouse_id = #SESSION.qSelectedHouse.iHouse_ID#
		 and dtRowDeleted is null
		 and iRowDeletedUser_ID is null 
	</cfquery>
	<!--- Update the ihouseLateFee_ID for the house table when a new record is created in the houseLateFee table --->
	<cfif getHouseinfo.recordcount gt 0>
		<cfquery name="UpdateHouseinfo" datasource = "#APPLICATION.datasource#">
			update House
			 set iHouseLateFee_ID = #getHouseinfo.iHouseLateFee_ID#
			 Where iHouse_id = #SESSION.qSelectedHouse.iHouse_ID#
		</cfquery>
	</cfif>
	<cfcatch type = "DATABASE">
			 <cftransaction action = "rollback"/>
				 <cfabort showerror="An error has occured when trying to update.">
		</cfcatch>
		</cftry>
	</cftransaction> 
</cfif>
</cfoutput>

<CFLOCATION URL="LateFeeExemptTenants.cfm" ADDTOKEN="No">  
