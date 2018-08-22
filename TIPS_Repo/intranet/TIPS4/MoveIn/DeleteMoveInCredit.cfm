<!--- 

05/28/2014 Sfarmer 116824 - included deleteing of recurring charge if it exists on the invoicedetail record.
10/06/2016 Mshah changed on line number 40 and 43
 --->

<CFTRANSACTION>

	<!--- ==============================================================================
	Retrieve iTenant_ID from Chosen InvoiceDetail Record
	=============================================================================== --->
	<CFQUERY NAME = "TenantID" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	iTenant_ID, irecurringcharge_id
		FROM	InvoiceDetail
		WHERE	iInvoiceDetail_ID = #url.ID#
	</CFQUERY>
	
	<!--- ==============================================================================
	Flag Chosen Detail from the InvoiceDetail as deleted
	=============================================================================== --->
	<CFQUERY NAME = "InvoiceDetailDelete" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE	InvoiceDetail
		SET		iRowDeletedUser_ID 	= #SESSION.UserID#,
				dtRowDeleted 		= GETDATE()
		WHERE	iInvoiceDetail_ID = #url.ID#
	</CFQUERY>
	<cfif TenantID.irecurringcharge_id is not ''>
		<CFQUERY NAME = "RecurringChargeDelete" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	RecurringCharge
			SET		iRowDeletedUser_ID 	= #SESSION.UserID#,
					dtRowDeleted 		= GETDATE()
			WHERE	iRecurringCharge_ID = #TenantID.irecurringcharge_id# and itenant_id = #TenantID.iTenant_ID#
		</CFQUERY>
	</cfif>
	
</CFTRANSACTION>

<CFQUERY NAME="qGetInvoice" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	InvoiceMaster
	WHERE	iInvoiceMaster_ID = #url.MID#
</CFQUERY>

<CFLOCATION URL="MoveInCredits.cfm?ID=#TenantID.iTenant_ID#&MID=#qGetInvoice.iInvoiceMaster_ID#">