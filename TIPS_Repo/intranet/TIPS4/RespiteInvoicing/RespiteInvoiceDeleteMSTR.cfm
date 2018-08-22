<!----------------------------------------------------------------------------------------------
| DESCRIPTION - RespiteInvoicing/RespiteInvoiceDeleteMSTR.cfm                                  |
| Delete invoice from InvoiceMaster tbl                                                        |
|Also delete any invoice created after since the time periods may change                       |
|IE: if invoice A covers 5 days, and invoice B covers the following 4 days, and invoice A is   |
|deleted.  That timespan is no longer covered, and the replacing invoice may be selected to    | 
|cover more than the original 5 days (or less too).  It must be that all invoices will have    |
| to be recreated.                                     										   |
|----------------------------------------------------------------------------------------------|
	| Called by: 		RespiteInvoice   				  	                                   |
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
|Developed for Project 25575 - Incremental Time Period Billing                                 |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|R Schuette  | 05/25/2010 | Prj 25575 - Original Authorship     							   |
----------------------------------------------------------------------------------------------->

<cfquery name="GetINVMSTRInfo" datasource="#application.datasource#">
	Select iInvoiceMaster_ID, cSolomonKey  
	from InvoiceMaster
	where InvoiceMaster.iInvoiceMaster_ID = #URL.INVMSTRID#
</cfquery>
 <cfquery name="DeleteINVMSTR_INVDTLItems" datasource="#application.datasource#">
	Update InvoiceDetail
	Set dtRowDeleted = getdate(),iRowDeletedUser_ID = #session.userid#
	where InvoiceDetail.iInvoiceMaster_ID IN (Select im1.IInvoiceMaster_ID from InvoiceMaster im1
											where im1.cSolomonKey = #GetINVMSTRInfo.cSolomonKey#
											and im1.dtrowdeleted is null
											and im1.bFinalized is null
											and im1.iInvoiceMaster_ID >= #GetINVMSTRInfo.iInvoiceMaster_ID#)
											
	Update InvoiceMaster
	Set dtRowDeleted = getdate(),iRowDeletedUser_ID = #session.userid#
	where InvoiceMaster.cSolomonKey = #GetINVMSTRInfo.cSolomonKey#
	and InvoiceMaster.dtrowdeleted is null
	and InvoiceMaster.bFinalized is null
	and InvoiceMaster.iInvoiceMaster_ID >= #GetINVMSTRInfo.iInvoiceMaster_ID#
</cfquery> 

<cfquery name="LastRespiteInvoiceID" DATASOURCE = "#APPLICATION.datasource#">
	Select top 1 (im.iInvoiceMaster_ID) as iInvoiceMaster_ID
	from InvoiceMaster im
	where im.dtRowDeleted is null
	and im.cSolomonKey = '#GetINVMSTRInfo.cSolomonKey#'
	order by im.dtInvoiceStart DESC
</cfquery>
<cfquery name="LastRespiteInvoiceInfo" DATASOURCE = "#APPLICATION.datasource#">
	Select dtInvoiceEnd
	from InvoiceMaster im
	where im.iInvoiceMaster_ID = '#LastRespiteInvoiceID.iInvoiceMaster_ID#'
</cfquery>
<cfquery name="DateAdjust" datasource="#APPLICATION.datasource#">
	select CONVERT(VARCHAR(10), GETDATE(), 101) as 'Newdate'
</cfquery>
<cfquery name="UpdatePMODateToLastInvoice" DATASOURCE = "#APPLICATION.datasource#">
	Update TenantState
	set dtMoveOutProjectedDate = '#LastRespiteInvoiceInfo.dtInvoiceEnd#'
	where TenantState.iTenant_ID = (Select t1.iTenant_ID from tenant t1 where t1.cSolomonKey = #GetINVMSTRInfo.cSolomonKey#)
</cfquery>

 <cfoutput><form name="return2page" action="RespiteInvoice.cfm?SolID=#GetINVMSTRInfo.cSolomonKey#" method="POST" ></cfoutput>
	<!--- use javascript t osubmit and post form back to getdetailspage --->
	<script type='text/javascript'>document.return2page.submit();</script>
</form>  
