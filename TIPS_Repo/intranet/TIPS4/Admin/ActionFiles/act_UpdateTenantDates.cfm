<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : Update Account dates for Tenant whose account is closed already	 	       |                                                                        |
|----------------------------------------------------------------------------------------------|
|                 Triggered from act_GetDateDetails.cfm  	                                   |
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
| RTS    	 |09/28/09    | Wrote Query  Created Page + code for #42573                        |
----------------------------------------------------------------------------------------------->

<cfoutput>
	<!--- 
	<cfquery name="GetDataforReturn" datasource="#application.datasource#">
		select iTenant_ID from tenant where iTenant_ID = '#form.TID#'
	</cfquery> 
	<cfset ten_id = GetDataforReturn.iTenant_ID>
	--->
	<cfset ten_id = #form.TID#>
	
	
	
	<cfquery name="UpdateTenantDates" datasource="#application.datasource#">
		update TenantState
		set dtMoveOut = '#form.NewMOdate#'
		,irowstartuser_id = #session.userid#
		where iTenant_ID = #ten_id#
	</cfquery>
	
<!---  	<cflocation url="../InvoiceAdmin.cfm" ADDTOKEN="No"> --->
 	<form name="return2page" action="act_GetDateDetails.cfm?ID=#'TenantSelect'#" method="POST" >
	<!--- use javascript t osubmit and post form back to getdetailspage --->
	<input name="TenantSelect" type="hidden" value="#ten_id#">
	<script type='text/javascript'>document.return2page.submit();</script>
	</form> 

</cfoutput>