<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page is to delete existing HousePromotionOccupancyrestriction data      |
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
| Sathya	 |08/03/10    | Created this file for project 50277                                |
|                             |
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
			<cfquery name="getHousePromotionInfo"datasource="#APPLICATION.datasource#">
				select hp.iHousePromotionOccupancyRestriction_id, h.ihouse_id, hp.fOccupancyPercentageRestriction, hp.cAppliesToAcctYear, h.cName
				from HousePromotionOccupancyRestriction hp
				join house h
				on h.ihouse_id = hp.ihouse_id
				and h.dtrowdeleted is null
				where hp.ihouse_id =  #SESSION.qSelectedHouse.iHouse_ID#
				and hp.dtrowdeleted is null
			</cfquery>
				
			<cfquery name="UpdateDeleteHousePromotionOccupancyRestriction" datasource="#APPLICATION.datasource#">
				UPDATE HousePromotionOccupancyRestriction
				 SET dtrowdeleted = getdate() 
				 	,iRowDeletedUser_ID = #SESSION.UserID#
				WHERE iHousePromotionOccupancyRestriction_id =  #getHousePromotionInfo.iHousePromotionOccupancyRestriction_id#
			</cfquery>
					
			<cfcatch type = "DATABASE">
				 <cftransaction action = "rollback"/>
					 <cfabort showerror="An error has occured when trying to update.">
			</cfcatch>
		</cftry>
</cftransaction> 
<cflocation url="TenantPromotions.cfm" ADDTOKEN="No">