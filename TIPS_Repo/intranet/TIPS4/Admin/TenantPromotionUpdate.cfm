<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page is to Update the promotions for the tenants, when being edited     |
 |            Created this file as per project 20125                                      |
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
| Sathya     |06/24/2010  | Modified it according to project 50227                             |
----------------------------------------------------------------------------------------------->



<cfoutput >

<cfquery name="Promotiontype" datasource="#APPLICATION.datasource#">
select * from tenantPromotionset where dtRowDeleted is null and iPromotion_ID = #url.id#
<!--- <cfif IsDefined("form.iPromotion_ID")>
	<cfif form.iPromotion_ID neq "">
		and iPromotion_ID = #form.iPromotion_ID# 
		<cfelseif IsDefined("url.ID")> and iPromotion_ID = #form.iPromotion_ID# 
	</cfif>
</cfif>		 --->
</cfquery> 

<!--- 08/26/2010 Project 50227 Sathya added this to avoid bypassing --->
<cfif (form.cDescription eq '') or (form.dtEffectiveStart eq '') or (form.dtEffectiveEnd eq '')>
 Please check as one of the required information is missing. 
<br></br>
<A HREF='TenantPromotions.cfm'>Click Here to Go Back to the Tenant Promotion Screen.</A>
<cfelse>
<!--- End of code Project 50227 --->

	<!--- Update the tenantPromotionset Table with the entered Promotions --->
	<cfquery name="TenantPromotionset" datasource="#application.datasource#">
		update tenantPromotionset
		set  cDescription = '#form.cDescription#',
		dtEffectiveStart = '#form.dtEffectiveStart#',
		dtEffectiveEnd =  '#form.dtEffectiveEnd#',
		iRowStartUser_ID =#session.UserID#,
		dtRowStart =   getDate()
		<!--- 06/24/2010 Project 50277 TIPS Promotion Update Sathya made the changes --->
		<cfif isdefined("form.bOccupancyRestricted")>	
		  , bIsHouseOccupancyRestricted = 1
		<cfelseif (Promotiontype.bIsHouseOccupancyRestricted eq 1)>
		  , bIsHouseOccupancyRestricted = 0
		</cfif>
		<!--- End of code Project 50277 --->
		where iPromotion_ID = #Promotiontype.iPromotion_ID# 
	</cfquery>



<cflocation url="TenantPromotions.cfm" ADDTOKEN="No">  
<!--- 08/26/2010 Project 50227 Sathya added this to avoid bypassing --->
</cfif>
</cfoutput>
