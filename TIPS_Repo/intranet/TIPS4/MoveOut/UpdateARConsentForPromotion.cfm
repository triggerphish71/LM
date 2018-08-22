<!----------------------------------------------------------------------------------------------
| DESCRIPTION - This page is created so that it updates the tenantstate table that the AR      |
|                has Acknowledged that the particular tenant has an  promotion                 |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
| Called by: 		MoveOutFormSummary.cfm, 			                    				   |
| Calls/Submits:	                                                                           |
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
|Sathya      | 07/01/2010 | Created this file for Project 50277                                |
|---------------------------------------------------------------------------------------------->
<!--- See if the required variables  exisits if not throw an error --->
 <cftry>
	<cfif NOT isDefined("session.qselectedhouse.ihouse_id")>
	   <!--- throw the error --->
	   <cfthrow message = "Session has expired please try again later. Try to logout and log back in to TIPS">
	</cfif>
	 
	 <cfif NOT isDefined("URL.ID")>
	   <!--- throw the error --->
	   <cfthrow message = "Tenant Id not found">
	</cfif>
	 <cfif NOT isDefined("SESSION.UserID")>
	   <!--- throw the error --->
	   <cfthrow message = "Your session user Id has expired please try again later.Try to logout and log back in to TIPS">
	</cfif>
		
<cfcatch type = "application">
  <cfoutput>
    <p>#cfcatch.message#</p>
	<br></br>
	<a href='../MainMenu.cfm'><p>Please click here to go back to TIPS Main Screen.</p></a>
 </cfoutput>
	<CFABORT>
</cfcatch>
</cftry>
<cfoutput>
the Tenant_Id: #URL.ID#
<br>
<br>session userid:  #SESSION.UserID#
</cfoutput>

<cftransaction>
	<cftry>
		<!--- update the ,bIsArAcknowledgePromotion	,iArAcknowledgePromotionUser_ID	,dtArAcknowledgePromotionRowStart in tenantstate table --->
		 <cfquery name= "UpdateArConsentForPromotion" datasource = "#APPLICATION.datasource#">
					update TenantState
					set   bIsArAcknowledgePromotion = 1,
						  iArAcknowledgePromotionUser_ID = #SESSION.UserID#,
					      dtArAcknowledgePromotionRowStart = getDate()
						  
					where iTenant_id = #URL.ID#
		</cfquery> 
		
		<cfcatch type = "DATABASE">
			 <cftransaction action = "rollback"/>
			<!--- throw the error --->
	  		 <cfthrow message="An error has occured when trying to update Ar Acknowledgement for promotion in Move out Process.">
				 <cfoutput>
				    <p>#cfcatch.message#</p>
					<br></br>
					<a href='../MainMenu.cfm'><p>Please click here to go back to TIPS Main Screen.</p></a>
				 </cfoutput>
			 <CFABORT>
		</cfcatch>
	</cftry>
</cftransaction> 

<!--- Relocate to Move out form summary to get back --->

<CFLOCATION URL="MoveOutFormSummary.cfm?ID=#URL.ID#" ADDTOKEN="No"> 
