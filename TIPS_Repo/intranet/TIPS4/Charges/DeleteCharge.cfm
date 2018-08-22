<!----------------------------------------------------------------------------------------------
| DESCRIPTION   DeleteCharge.cfm                                                               |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| Parameter Name   																			   |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                     												   |                                                                        
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| mlaw       | 03/21/2006 | Create Flower Box                                                  | 
| mlaw       | 01/24/2007 | Remove mlaw@alcco.com                                              |
----------------------------------------------------------------------------------------------->
<CFQUERY NAME='ChargeInfo' DATASOURCE='#APPLICATION.datasource#'>
	select *
	from invoicedetail inv
	join chargetype ct on ct.ichargetype_id = inv.ichargetype_id and ct.dtrowdeleted is null
	where inv.dtrowdeleted is null
	and inv.iinvoicedetail_id = #url.detail#
</CFQUERY>

<CFQUERY NAME="qResident" DATASOURCE="#APPLICATION.datasource#">
	SELECT	T.*, H.cStateCode 
	FROM Tenant T 
	INNER JOIN House H ON T.iHouse_ID = H.iHouse_ID 
	WHERE H.dtrowdeleted is null and T.dtRowDeleted IS NULL and itenant_id = #ChargeInfo.itenant_id#
</CFQUERY>
	

<CFTRANSACTION>
	<!--- ==============================================================================
	Flag the Selected charge (passed via URL) as Deleted
	=============================================================================== --->
	<CFQUERY NAME = "DeleteCharge" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE	InvoiceDetail
		SET		dtRowDeleted = GetDate(),
				iRowDeletedUser_ID = #SESSION.UserID#
		WHERE	iInvoiceDetail_ID = #url.detail#
	</CFQUERY>
	
	<!--- if deleting copay charge and Tenant has daily State Medicaid recurring charge, must add copay back into State Medicaid invoice detail amount --->
	
	<cfif ChargeInfo.iChargeType_ID is 31 or ChargeInfo.iChargeType_ID is 1661>
		<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
			SELECT mAmount, bIsDaily 
			FROM recurringcharge 
			WHERE iTenant_ID = #ChargeInfo.iTenant_ID# AND cDescription like '%State Medicaid%' and dtRowDeleted IS NULL
		</cfquery>
		
		<cfif StateMedicaidRecurringInfo.recordcount is not 0 and StateMedicaidRecurringInfo.bIsDaily is 1>
			<!--- does have a state medicaid recurring charge and IS daily --->
			<cfif qResident.cStateCode is not "OR" >
				<!--- then this is a state that subtracts co-pay; get current state medicaid invoice detail amount --->
				<cfquery name="getStateMedicaid" datasource="#application.datasource#">
					SELECT iInvoiceDetail_ID, mAmount from InvoiceDetail
					WHERE iTenant_ID = #ChargeInfo.iTenant_ID# AND cAppliesToAcctPeriod= '#DateFormat(SESSION.TIPSMonth,"yyyymm")#' AND iChargeType_ID = 8 AND dtRowDeleted IS NULL
				</cfquery>
				<cfset NewAmount = isBlank(getStateMedicaid.mAmount,0) + isBlank(ChargeInfo.mAmount,0)>
				<!--- update detail of record for State Medicaid --->
				<CFQUERY NAME = "UpdateStateMedicaidDetail" DATASOURCE = "#APPLICATION.datasource#">
					UPDATE	InvoiceDetail
					SET		 mAmount = #NewAmount# 
							,iQuantity = 1
							,dtRowStart = getDate() 
							,iRowStartUser_ID = 0 <!--- #User# --->
					WHERE	iInvoiceDetail_ID = #getStateMedicaid.iInvoiceDetail_ID#
				</CFQUERY>
			<cfelseif qResident.cStateCode is "OR">
				<cfquery name="getStateMedicaid" datasource="#application.datasource#">
					SELECT iInvoiceDetail_ID, mAmount from InvoiceDetail
					WHERE iTenant_ID = #ChargeInfo.iTenant_ID# AND cAppliesToAcctPeriod= '#DateFormat(SESSION.TIPSMonth,"yyyymm")#' AND iChargeType_ID = 8 AND dtRowDeleted IS NULL
				</cfquery>
				<cfset NewAmount = isBlank(getStateMedicaid.mAmount,0) + isBlank(ChargeInfo.mAmount,0)>
				<!--- update detail of record for State Medicaid --->
				<CFQUERY NAME = "UpdateStateMedicaidDetail" DATASOURCE = "#APPLICATION.datasource#">
					UPDATE	InvoiceDetail
					SET		 mAmount = #NewAmount# 
							,iQuantity = 1
							,dtRowStart = getDate() 
							,iRowStartUser_ID = 0 <!--- #User# --->
					WHERE	iInvoiceDetail_ID = #getStateMedicaid.iInvoiceDetail_ID#
				</CFQUERY>
			</cfif>
		</cfif>
	</cfif>
</CFTRANSACTION>

<CFQUERY NAME="qResident" DATASOURCE="#APPLICATION.datasource#">
	select * from tenant where dtrowdeleted is null and itenant_id = #qResident.itenant_id#
</CFQUERY>
<CFQUERY NAME='qDetail' DATASOURCE='#APPLICATION.datasource#'>
	select inv.cdescription as description, inv.mamount as amount, inv.iquantity as quantity, sum(inv.mamount * inv.iquantity) as extended,
			inv.ccomments as comments
	from invoicedetail inv
	join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.dtrowdeleted is null
		and inv.dtrowdeleted is null and im.bmoveoutinvoice is null and im.bmoveininvoice is null
		and im.bfinalized is null
	where im.csolomonkey = '#qResident.cSolomonKey#' and inv.itenant_id = #qResident.itenant_id#
	and im.cappliestoacctperiod='#DateFormat(SESSION.TipsMonth,"yyyymm")#'
	group by inv.cdescription, inv.mamount, inv.iquantity, inv.ccomments
</CFQUERY>
<CFSET results="<BR><BR>Current Charges:<BR><TABLE STYLE='border: 1px solid black; text-align:right;'>">
<CFSET results = results & "<TR><TD>Description</TD><TD>Amount</TD><TD>Quantity</TD><TD>Extended</TD><TD>Comments</TD></TR>">
<CFLOOP QUERY='qDetail'>
	<CFSET results = results & "<TR><TD>#qDetail.Description#</TD><TD>#qDetail.Amount#</TD><TD>#qDetail.quantity#</TD><TD>#qDetail.extended#</TD><TD>#qDetail.Comments#</TD></TR>">
</CFLOOP>
<CFQUERY NAME='qTotal' DATASOURCE='#APPLICATION.datasource#'>
	select sum(inv.mamount * inv.iquantity) as total
	from invoicedetail inv
	join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.dtrowdeleted is null
		and inv.dtrowdeleted is null and im.bmoveoutinvoice is null and im.bmoveininvoice is null
		and im.bfinalized is null
	where im.csolomonkey = '#qResident.cSolomonKey#' and inv.itenant_id = #qResident.itenant_id#
	and im.cappliestoacctperiod='#DateFormat(SESSION.TipsMonth,"yyyymm")#'
</CFQUERY>
<CFSET results = results & "<TR><TD COLSPAN=100 STYLE='text-align: right;'>Current Total = #qTotal.total#</TD></TR>">
<CFSET results = results & "</TABLE>">
<CFIF isDefined("SESSION.RDOEmail") AND ChargeInfo.bDirectorEmail GT 0>
	<CFSCRIPT>
		if (SESSION.qSelectedHouse.ihouse_id EQ 200) { email='#session.developerEmailList#'; }
		else { email=SESSION.RDOEmail; } 
		message= ChargeInfo.cdescription & " has changed for " & qResident.cFirstName & ', ' & qResident.cLastName & ' at ' & SESSION.HouseName & ' ' & "<BR>";
		message= message & "The rate for " & LSCurrencyFormat(ChargeInfo.mAmount) & " has been deleted.";
		message= message & "<BR>by: " & SESSION.FullName;
		//message= message & "<BR>" & results & "****";
	</CFSCRIPT>
	<CFIF server_name neq 'oldbirch'>
		<CFMAIL TYPE ="html" FROM="TIPS4_ChargeDeleted@alcco.com" TO="#email#" SUBJECT="Current Month Charge has been deleted for #SESSION.HouseName#">#message#</CFMAIL>
	</CFIF>
</CFIF>


<!--- ==============================================================================
Relocate the page to original charges screen
=============================================================================== --->
<CFLOCATION URL="ChargesDetail.cfm?ID=#url.ID#" ADDTOKEN="No">