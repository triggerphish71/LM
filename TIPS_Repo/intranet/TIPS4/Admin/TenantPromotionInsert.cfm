<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page is to insert the promotions for the tenants as per project 20125                                                                              |
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
| Sathya	 |06/06/08    | Added Flowerbox                                                    |
| Sathya     |06/24/2010  | Project 50227 Tips Promotion Update                                |
----------------------------------------------------------------------------------------------->

<!--- 08/26/2010 Project 50227 Sathya added this to avoid bypassing --->
<cfif (form.cDescription eq '') or (form.dtEffectiveStart eq '') or (form.dtEffectiveEnd eq '')>
 Please check as one of the required information is missing. 
<br></br>
<A HREF='TenantPromotions.cfm'>Click Here to Go Back to the Tenant Promotion Screen.</A>
<cfelse>
<!--- End of code Project 50227 --->
<cfquery name = "ChargeInsert" datasource = "#application.datasource#">
	insert TenantPromotionSet 
		 (cDescription
           ,dtEffectiveStart
           ,dtEffectiveEnd
           ,iRowStartUser_ID
           ,dtRowStart
		<!--- 06/24/2010 Project 50227 Sathya added this --->
		<cfif isdefined("form.bISOccupancyRestricted")>	
			,bIsHouseOccupancyRestricted
		</cfif>
		<!--- End of code project 50227 --->
           )
		values
		( '#form.cDescription#',
		   '#form.dtEffectiveStart#',
		   '#form.dtEffectiveEnd#',
		   #session.UserID#,
		   getDate()
		   <!--- 06/24/2010 Project 50227 Sathya added this --->
		<cfif isdefined("form.bISOccupancyRestricted")>	
		  ,1
		</cfif>
		<!--- End of code project 50227 --->
				)
				
</cfquery>

<cflocation url="TenantPromotions.cfm" ADDTOKEN="No">
<!--- 08/26/2010 Project 50227 Sathya added this to avoid bypassing --->
</cfif>
<!--- End of code project 50227 --->

