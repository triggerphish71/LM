<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : Mark Invoice detail item as deleted     						      	       |                                                                        |
|----------------------------------------------------------------------------------------------|
|                 Triggered from act_GetInvoiceDetails.cfm                                     |
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
| RTS    	 |09/02/09    | Wrote Query                                                        |
----------------------------------------------------------------------------------------------->

<cfoutput>
	<cfquery name="GetDataforReturn" datasource="#application.datasource#">
		select im.cSolomonKey
		from InvoiceMaster im 
		join InvoiceDetail id on (id.iInvoiceMaster_ID = im.iInvoiceMaster_ID)
		where id.iInvoiceDetail_ID = '#form.ChargeSelect#'
	</cfquery>
	<cfset sol_id = GetDataforReturn.cSolomonKey>
	
	
	
	<cfquery name="DeleteItem" datasource="#application.datasource#">
		update InvoiceDetail
		Set dtRowDeleted = getdate(),irowdeleteduser_id = #session.userid#
		where iInvoiceDetail_id = '#form.ChargeSelect#'
	</cfquery>
	
<!---  	<cflocation url="../InvoiceAdmin.cfm" ADDTOKEN="No"> --->
 	<form name="return2page" action="act_GetInvoiceDetails.cfm?ID=#'TenantSelect'#" method="POST" >
	<!--- use javascript t osubmit and post form back to getdetailspage --->
	<input name="TenantSelect" type="hidden" value="#sol_id#">
	<script type='text/javascript'>document.return2page.submit();</script>
	</form> 

</cfoutput>