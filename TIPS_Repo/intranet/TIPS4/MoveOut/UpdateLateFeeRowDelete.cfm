<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page updates as the late fee as deleted of a tenant                     | 
|                 If no reason is been entered then do not allow to delete the record.          |                                                                        |
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
| Sathya  	 |07/23/10    | Created this page as part of project 20933-Part B Late Fees        |
----------------------------------------------------------------------------------------------->

<!--- See if the required variables exisits if not throw an error and abort any further operation --->
 <cftry>
	<cfif NOT isDefined("session.qselectedhouse.ihouse_id")>
	   <!--- throw the error --->
	   <cfthrow message = "Session has expired please try again later. Try to logout and log back in to TIPS">
	</cfif>
	<cfif NOT isDefined("URL.iTenant_ID")>
	   <!--- throw the error --->
	   <cfthrow message = "Tenant ID not found.">
	</cfif>
	<cfif NOT isDefined("URL.iInvoiceLateFee_ID")>
	   <!--- throw the error --->
	   <cfthrow message = "Invoice late fee id not found.">
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


<cfoutput>
 <!--- For debugging only this lines of code is there.
user id: #SESSION.UserID#
<br></br>
iInvoiceLateFee_ID: #URL.iInvoiceLateFee_ID#
<br></br>
iTenant_id : #URL.iTenant_ID#   --->

  
<cftransaction>
		<cftry>
			<cfquery name="UpdateDeleteTenantLatefee" datasource="#APPLICATION.datasource#">
				UPDATE tenantlatefee
				 SET dtrowdeleted = getdate() 
				 	,cReasonforRowDelete = 'Move Out took place after the Current Late fee was generated'
				 	,iRowDeletedUser_ID = #SESSION.UserID#
				WHERE itenant_id =  #URL.iTenant_ID#
				AND iinvoicelateFee_id = #URL.iInvoiceLateFee_ID#
			</cfquery>
					
			<cfcatch type = "DATABASE">
				 <cftransaction action = "rollback"/>
					 <cfabort showerror="An error has occured when trying to update.">
			</cfcatch>
		</cftry>
	</cftransaction> 
</cfoutput>

 <CFLOCATION URL="MoveOutFormSummary.cfm?ID=#URL.iTenant_ID#" ADDTOKEN="No"> 