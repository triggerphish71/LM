<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page is to add data in HousePromotionOccupancyrestriction table         |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
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
| Sathya	 |08/03/10    | Created this file for project 50277                                |                                          |
|                                                                                              |
----------------------------------------------------------------------------------------------->
<!--- See if the required variables exisits if not throw an error and abort any further operation --->
 <cftry>
	<cfif NOT isDefined("session.qselectedhouse.ihouse_id")>
	   <!--- throw the error --->
	   <cfthrow message = "Session has expired please try again later. Try to logout and log back in to TIPS">
	</cfif>
	<cfif NOT isDefined("SESSION.UserID")>
	   <!--- throw the error --->
	   <cfthrow message = "User Session not found. The session seems to have expired.">
	</cfif>
	<cfif NOT isDefined("form.OccupancyPercentage")>
	   <!--- throw the error --->
	   <cfthrow message = "Occupancy Percentage is not valid. Please enter the reason and try again. Thanks.">
	</cfif>
	<cfif form.OccupancyPercentage eq ''>
	   <!--- throw the error --->
	   <cfthrow message = "Occupancy Percentage is not valid. Please enter the reason and try again. Thanks.">
	</cfif>
	<cfif form.AppliesToAcctYear eq ''>
	   <!--- throw the error --->
	   <cfthrow message = "Applies to Acct Year is not valid. Please enter the reason and try again. Thanks.">
	</cfif>
	
	
<cfcatch type = "application">
  <cfoutput>
    <p>#cfcatch.message#</p>
	<br></br>
	<a href='../MainMenu.cfm'><p>Please click here to go back to TIPS Main Screen.</p></a>
 </cfoutput>
<cfabort>
</cfcatch>
</cftry>
<cftransaction>
		<cftry>
		<cfquery name = "ChargeInsert" datasource = "#application.datasource#">
			insert HousePromotionOccupancyRestriction
				 ( 
					 iHouse_id
					,fOccupancyPercentageRestriction
					,cAppliesToAcctYear
					,iRowStartUser_ID
		           )
				values
				( 
					#session.qselectedhouse.ihouse_id#
					,#form.OccupancyPercentage#
					,'#form.AppliesToAcctYear#'
					,#SESSION.UserID#
				  
				 )
		</cfquery>
				
		<cfcatch type = "DATABASE">
		 <cftransaction action = "rollback"/>
		 <cfabort showerror="An error has occured when trying to update.">
		</cfcatch>
		</cftry>
</cftransaction> 
<cflocation url="TenantPromotions.cfm" ADDTOKEN="No">