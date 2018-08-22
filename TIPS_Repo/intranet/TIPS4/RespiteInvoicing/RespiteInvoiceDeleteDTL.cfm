<!----------------------------------------------------------------------------------------------
| DESCRIPTION - RespiteInvoicing/RespiteInvoiceDeleteDTL.cfm                                   |
| Delete invoice detail item from the invoice                                                  |
|----------------------------------------------------------------------------------------------|
| Called by: 		RespiteInvoiceDetails				  	                                   |
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
|R Schuette  | 05/21/2010 | Prj 25575 - Original Authorship     							   |
----------------------------------------------------------------------------------------------->

<cfquery name="deleteINVDetail" datasource="#application.datasource#">
	Update InvoiceDetail
	set dtrowdeleted = getdate(),irowdeleteduser_id = #session.userid#
	where InvoiceDetail.iInvoiceDetail_ID = #URL.INVDTLID#
</cfquery>


<form name="return2page" action="RespiteInvoiceDetails.cfm?INVNID=#URL.INVNID#" method="POST" >
	<!--- use javascript t osubmit and post form back to getdetailspage --->
	<script type='text/javascript'>document.return2page.submit();</script>
</form> 

