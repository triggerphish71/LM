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
| Sathya  	 |07/16/10    | Created this page as part of project 20933-Part B Late Fees        |
----------------------------------------------------------------------------------------------->
<CFINCLUDE TEMPLATE="../../header.cfm">
<!--- Include shared javascript ---> 
<CFINCLUDE TEMPLATE='../Shared/HouseHeader.cfm'>
<!--- See if the required variables exisits if not throw an error and abort any further operation --->
 <cftry>
	<cfif NOT isDefined("session.qselectedhouse.ihouse_id")>
	   <!--- throw the error --->
	   <cfthrow message = "Session has expired please try again later. Try to logout and log back in to TIPS">
	</cfif>
	<cfif NOT isDefined("form.iTenant_ID")>
	   <!--- throw the error --->
	   <cfthrow message = "Tenant ID not found.">
	</cfif>
	<cfif NOT isDefined("form.iInvoiceLateFee_ID")>
	   <!--- throw the error --->
	   <cfthrow message = "Invoice late fee id not found.">
	</cfif>
	<cfif NOT isDefined("SESSION.UserID")>
	   <!--- throw the error --->
	   <cfthrow message = "User Session not found. The session seems to have expired.">
	</cfif>
	<cfif NOT isDefined("form.ReasonOfDelete")>
	   <!--- throw the error --->
	   <cfthrow message = "Reason for Deletion of the Late fee in empty. Cannot delete the charge without a reason. Please enter the reason and try again. Thanks.">
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
 reason for delete : #form.ReasonOfDelete#
<br></br>
iInvoiceLateFee_ID: #form.iInvoiceLateFee_ID#
<br></br>
iTenant_id : #form.iTenant_ID# --->

<!---Check if there reason for deleting the record is empty. If empty then do not delete the record.  --->
<cfif form.ReasonOFDelete eq ''>
	You have not entered a valid reason. <b><a href='CurrentLateFee.cfm'><p>Please click here to go back to the Screen to enter a valid reason.</p></a></b>
<cfelse> 
    <!---  This is a valid reason. --->
	<cftransaction>
		<cftry>
			<cfquery name="UpdateDeleteTenantLatefee" datasource="#APPLICATION.datasource#">
				UPDATE tenantlatefee
				 SET dtrowdeleted = getdate() 
				 	,cReasonforRowDelete = '#form.ReasonOfDelete#'
				 	,iRowDeletedUser_ID = #SESSION.UserID#
				WHERE itenant_id =  #form.iTenant_ID#
				AND iinvoicelateFee_id = #form.iInvoiceLateFee_ID#
			</cfquery>
					
			<cfcatch type = "DATABASE">
				 <cftransaction action = "rollback"/>
					 <cfabort showerror="An error has occured when trying to update.">
			</cfcatch>
		</cftry>
	</cftransaction> 
	<CFLOCATION URL="CurrentLateFee.cfm" ADDTOKEN="No"> 
</cfif>

</cfoutput>

