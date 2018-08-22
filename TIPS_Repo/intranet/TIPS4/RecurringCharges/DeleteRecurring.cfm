
<!--- Retrieve Recurring Information --->
<CFQUERY NAME="RecurringInfo" DATASOURCE="#APPLICATION.datasource#">
	SELECT	RC.iTenant_ID, bDirectorEmail, RC.cDescription, RC.mAmount as mAmount, T.cFirstName, T.cLastName
	FROM RecurringCharge RC
	JOIN Charges C ON C.iCharge_ID = RC.iCharge_ID	
	JOIN ChargeType CT ON CT.iChargeType_ID = C.iChargeType_ID
    JOIN Tenant T on T.iTenant_ID = RC.iTenant_ID and t.dtRowDeleted is Null
	WHERE iRecurringCharge_ID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#URL.typeID#">
</CFQUERY>

<!---Delete Chosen Charge by Flagging as Deleted --->
<cftransaction>
    <CFQUERY NAME = "DeleteCharge" DATASOURCE = "#APPLICATION.datasource#">
        UPDATE 	RecurringCharge
        SET		iRowDeletedUser_ID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#SESSION.UserID#">,
                dtRowDeleted = getDate() 
        WHERE	iRecurringCharge_ID	= <cfqueryparam cfsqltype="cf_sql_bigint" value="#Url.typeID#">
    </CFQUERY>
    
    <cfquery name="DeleteChargeFromInvoice" DATASOURCE = "#APPLICATION.datasource#"> 
    	Update InvoiceDetail
        Set dtRowDeleted = getDate(),
       		iRowDeletedUser_ID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#SESSION.UserID#">
        Where iRecurringCharge_ID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#Url.typeID#">
        and iInvoiceMaster_ID = (Select distinct IM.iInvoiceMaster_ID from invoicemaster IM
								Join InvoiceDetail ID on ID.iInvoiceMaster_ID = im.iInvoicemaster_id 
                                	and ID.dtRowDeleted is null and ID.iRecurringCharge_ID = #Url.typeID#
                                Where IM.bFinalized is Null
                                and IM.bMoveInInvoice is Null
                                and IM.bMoveOutInvoice is Null
                                and IM.dtRowDeleted is Null)
    </cfquery>
</cftransaction>

<CFIF (server_name eq 'CF01')>
	<CFIF isDefined("SESSION.RDOEmail") AND RecurringInfo.bDirectorEmail GT 0>
		<CFSCRIPT>
			message= RecurringInfo.cdescription & " has changed for " & RecurringInfo.cFirstName & ', ' & RecurringInfo.cLastName & ' at ' & SESSION.HouseName & ' ' & "<BR>";
			message= message & "The rate in the amount of " & LSCurrencyFormat(RecurringInfo.mAmount) & " has been deleted. ";
		</CFSCRIPT>
		<CFMAIL TYPE ="HTML" FROM="TIPS4_Recurring_Change@alcco.com" TO="#SESSION.RDOEmail#" BCC="CFDevelopers@alcco.com" SUBJECT="Deleted Recurring Rate for #SESSION.HouseName#">#message#</CFMAIL>
	</CFIF>
</CFIF>

<CFLOCATION URL="Recurring.cfm" ADDTOKEN="No">