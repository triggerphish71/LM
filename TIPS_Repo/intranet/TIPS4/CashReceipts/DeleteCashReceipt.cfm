


<CFTRANSACTION>

	<CFQUERY NAME = "UpdateDetail" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE 	CashReceiptDetail
		
		SET 	iRowDeletedUser_ID	= #SESSION.UserID#,
				dtRowDeleted		= GetDate()
		
		WHERE 	iCashReceiptItem_ID = #Url.itemID#
	</CFQUERY>

</CFTRANSACTION>


<CFLOCATION URL="CashReceipts.cfm" ADDTOKEN="No">