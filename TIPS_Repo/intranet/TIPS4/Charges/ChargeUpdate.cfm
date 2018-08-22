<!----------------------------------------------------------------------------------------------
| DESCRIPTION   ChargeUpdate.cfm                                                               |
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
| jcruz      | 09/02/2009 | Remove mlaw@alcco.com                                              |
----------------------------------------------------------------------------------------------->
<CFTRANSACTION>

	<CFQUERY NAME="qChargeInfo" DATASOURCE="#APPLICATION.datasource#">
		select *
		from invoicedetail inv
		join chargetype ct on ct.ichargetype_id = inv.ichargetype_id and ct.dtrowdeleted is null
		where inv.dtrowdeleted is null 
		and inv.iinvoicedetail_id = #form.iInvoiceDetail_ID#
	</CFQUERY>

	<CFQUERY NAME="qResident" DATASOURCE="#APPLICATION.datasource#">
		SELECT	T.*, H.cStateCode 
		FROM Tenant T 
		INNER JOIN House H ON T.iHouse_ID = H.iHouse_ID 
		WHERE H.dtrowdeleted is null and T.dtRowDeleted IS NULL and itenant_id = #qChargeInfo.itenant_id#
	</CFQUERY>
	
	<!--- ------------------------------------------- --->
	<!--- Added by Katie: 9/27/03: Do the calculation so amount is updated into Invoice Details properly for State Medicaid if Daily is checked and it's the proper State --->
	
	<cfif qChargeInfo.iChargeType_ID is 8 OR qChargeInfo.iChargeType_ID is 1661>
		<!--- get copay and R&B amounts from Invoice Detail for same AppliesToAcctPeriod (Tips Month) if they exist --->
		<cfquery name="getMedicaidCoPay" datasource="#application.datasource#">
			SELECT iInvoiceDetail_ID, mAmount from InvoiceDetail
			WHERE iTenant_ID = #form.iTenant_ID# AND cAppliesToAcctPeriod= '#DateFormat(SESSION.TIPSMonth,"yyyymm")#' AND iChargeType_ID = 1661 AND dtRowDeleted IS NULL
		</cfquery>
		
		<cfquery name="getStateMedicaid" datasource="#application.datasource#">
			SELECT iInvoiceDetail_ID, mAmount from InvoiceDetail
			WHERE iTenant_ID = #form.iTenant_ID# AND cAppliesToAcctPeriod= '#DateFormat(SESSION.TIPSMonth,"yyyymm")#' AND iChargeType_ID = 8 AND dtRowDeleted IS NULL
		</cfquery>
		
		<cfif getMedicaidCopay.recordcount is not 0>
			<cfset MedicaidCopay = #getMedicaidCopay.mAmount#>
		<cfelse>
			<cfset MedicaidCopay = 0>
		</cfif>
		
		<cfif getStateMedicaid.recordcount is not 0 and qChargeInfo.iChargeType_ID is not 8>
			<!--- get the mAmount (in most cases: DAILY rate the state approves) from the recurring charges table --->
			<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
				SELECT mAmount 
				FROM recurringcharge 
				WHERE iTenant_ID = #form.iTenant_ID# AND cDescription like '%State Medicaid%' and dtRowDeleted IS NULL
			</cfquery>
			<cfset StateMedicaid = #StateMedicaidRecurringInfo.mAmount#>
		<cfelse>
			<cfset StateMedicaid = 0>
		</cfif>
		
		<!--- calculate the New MONTHLY Amount for State Medicaid --->
		<cfset TotalMonthDays = #DaysInMonth(SESSION.TipsMonth)#>
		
		<cfif qResident.cStateCode is not "OR">
			<cfif qChargeInfo.iChargeType_ID is 8 AND isDefined("form.bIsDaily") AND form.bIsDaily is "1">
				<!--- only do this equasion if entering a DAILY state medicaid recurring charge --->
				<cfset NewAmount = (#form.mAmount# * #TotalMonthDays#) - #MedicaidCoPay#>
				<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
			<cfelseif qChargeInfo.iChargeType_ID is 1661>
				<!--- only do this equasion if entering a medicaid Copay recurring charge and State Medicaid recurring is DAILY--->
				<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
					SELECT bIsDaily 
					FROM recurringcharge 
					WHERE iTenant_ID = #form.iTenant_ID# AND cDescription like '%State Medicaid%' and dtRowDeleted IS NULL
				</cfquery>
				<cfif StateMedicaidRecurringInfo.bIsDaily is 1>
					<cfset NewAmount = (#StateMedicaid# * #TotalMonthDays#) - #form.mAmount#>
					<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
				</cfif>
			</cfif>
		<cfelseif qResident.cStateCode is "OR">
		<!--- updated by Katie on 12/13/2004: NJ now works like TX where subtract copay from Staterate --->
			<cfif qChargeInfo.iChargeType_ID is 8 AND isDefined("form.bIsDaily") AND form.bIsDaily is "1">
					<cfset NewAmount = (#form.mAmount# * #TotalMonthDays#) - #medicaidcopay#>
				<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
			<cfelseif ChargeInfo.iChargeType_ID is 8 and isDefined("form.bIsDaily") and form.bIsDaily is not "1">
						<cfset NewAmount = #form.mAmount# - #medicaidcopay# >
						<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
					<cfelseif ChargeInfo.iChargeType_ID is 1661>					
						<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
							select bIsDaily 
							from recurringcharge 
							where iTenant_ID = #form.iTenant_ID# and cDescription like '%State Medicaid%' and dtRowDeleted is null
						</cfquery>						
						<cfif StateMedicaidRecurringInfo.bIsDaily is 1>
							<!--- <cfif qResident.cStateCode is "IN">
								<cfset NewAmount = (#form.mAmount# * #TotalMonthDays#) - #MedicaidRoomBoard#>
							<cfelse> --->
							<cfset NewAmount = (#StateMedicaid# * #TotalMonthDays#) - #form.mAmount# >
							<!--- </cfif> --->
							<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
						<cfelseif StateMedicaidRecurringInfo.bIsDaily is not 1>
							<cfset NewAmount = #StateMedicaid# - #form.mAmount# >
						<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
						</cfif>
				</cfif>	 					
			</cfif>
		</cfif>
	<!--- update detail of record submitting change for --->
	<CFQUERY NAME = "UpdateDetail" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE	InvoiceDetail
		SET		<CFSET cAppliesToAcctPeriod = form.AppliesToYear & NumberFormat(form.AppliesToMonth, "09")>
				<CFIF Variables.cAppliesToAcctPeriod NEQ "">
					cAppliesToAcctPeriod = '#Variables.cAppliesToAcctPeriod#',
				<CFELSE>
					<CFSET AcctStamp = Year(SESSION.AcctStamp) & NumberFormat(SESSION.AcctStamp, "09")>
					cAppliesToAcctPeriod = '#Variables.AcctStamp#',
				</CFIF>
				<CFIF form.iQuantity NEQ ""> iQuantity = #form.iQuantity#, <CFELSE> iQuantity = 1, </CFIF>	
				<CFIF form.cDescription NEQ "">	cDescription = '#form.cDescription#', <CFELSE> cDescription = NULL, </CFIF>
				<CFIF form.mAmount NEQ ""> mAmount = #form.mAmount#, <CFELSE> mAmount = NULL, </CFIF>	 
				<CFIF form.cComments NEQ ""> cComments = '#TRIM(form.cComments)#', <CFELSE> cComments	= NULL, </CFIF>
				dtAcctStamp = #CreateODBCDateTime(SESSION.AcctStamp)#,
				iRowStartUser_ID = #SESSION.UserID#, <!--- #User# --->
				dtRowStart = getDate() 
		WHERE	iInvoiceDetail_ID = #form.iInvoiceDetail_ID#
	</CFQUERY>
	
	<cfif isDefined("NewAmount")>
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
	
<!--- 	<CFQUERY NAME = "UpdateDetail" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE	InvoiceDetail
		SET		
				<CFSET cAppliesToAcctPeriod = form.AppliesToYear & NumberFormat(form.AppliesToMonth, "09")>
				<CFIF Variables.cAppliesToAcctPeriod NEQ "">
					cAppliesToAcctPeriod = '#Variables.cAppliesToAcctPeriod#',
				<CFELSE>
					<CFSET AcctStamp = Year(SESSION.AcctStamp) & NumberFormat(SESSION.AcctStamp, "09")>
					cAppliesToAcctPeriod = '#Variables.AcctStamp#',
				</CFIF>
				
				<CFIF form.iQuantity NEQ ""> iQuantity = #form.iQuantity#, <CFELSE> iQuantity = 1, </CFIF>	
				<CFIF form.cDescription NEQ "">	cDescription = '#form.cDescription#', <CFELSE> cDescription = NULL, </CFIF>
				<CFIF form.mAmount NEQ ""> mAmount = #form.mAmount#, <CFELSE> mAmount = NULL, </CFIF>	 
				<CFIF form.cComments NEQ ""> cComments = '#TRIM(form.cComments)#', <CFELSE> cComments	= NULL, </CFIF>
				dtAcctStamp = #CreateODBCDateTime(SESSION.AcctStamp)#,
				iRowStartUser_ID = #SESSION.UserID#,
				dtRowStart = getDate()
		WHERE	iInvoiceDetail_ID = #form.iInvoiceDetail_ID#
	</CFQUERY> --->

<CFIF (IsDefined("AUTH_USER") AND AUTH_USER EQ 'ALC\PaulB') OR 1 EQ 1>
	<CFQUERY NAME='qDetail' DATASOURCE='#APPLICATION.datasource#'>
		select inv.cdescription as description, inv.mamount as amount, inv.iquantity as quantity, sum(inv.mamount * inv.iquantity) as extended
			,inv.ccomments as comments
		from invoicedetail inv
		join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.dtrowdeleted is null
			and inv.dtrowdeleted is null and im.bmoveoutinvoice is null and im.bmoveininvoice is null
			and im.bfinalized is null
		where im.csolomonkey = '#qResident.cSolomonKey#' and inv.itenant_id = #qResident.itenant_id#
		and im.cappliestoacctperiod='#DateFormat(SESSION.TIPSMonth,"yyyymm")#'
		group by inv.cdescription, inv.mamount, inv.iquantity, inv.ccomments
	</CFQUERY>
	<CFSET results="<BR><BR>Current Charges:<BR><TABLE STYLE='border: 1px solid black; text-align: right;'>">
	<CFSET results = results & "<TR><TD>Description</TD><TD>Amount</TD><TD>Quantity</TD><TD>Extended</TD><TD>Comments</TD></TR>">
	<CFLOOP QUERY='qDetail'>
		<CFSET results = results & "<TR><TD>#qDetail.Description#</TD><TD>#qDetail.Amount#</TD><TD>#qDetail.quantity#</TD><TD>#qDetail.extended#</TD><TD>#qDetail.comments#</TD></TR>">
	</CFLOOP>
	<CFQUERY NAME='qTotal' DATASOURCE='#APPLICATION.datasource#'>
		select sum(inv.mamount * inv.iquantity) as total
		from invoicedetail inv
		join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.dtrowdeleted is null
			and inv.dtrowdeleted is null and im.bmoveoutinvoice is null and im.bmoveininvoice is null
			and im.bfinalized is null
		where im.csolomonkey = '#qResident.cSolomonKey#' and inv.itenant_id = #qResident.itenant_id#
		and im.cappliestoacctperiod='#DateFormat(SESSION.TIPSMonth,"yyyymm")#'
	</CFQUERY>
	<CFSET results = results & "<TR><TD COLSPAN=100 STYLE='text-align: right;'>Current Total = #qTotal.total#</TD></TR>">
	<CFSET results = results & "</TABLE>">
	<CFIF isDefined("SESSION.RDOEmail") AND qChargeInfo.bDirectorEmail GT 0>
		<CFSCRIPT>
			if (SESSION.qSelectedHouse.ihouse_id EQ 200) { email='#session.developerEmailList#'; }
			else { email=SESSION.RDOEmail; } 
			message= "<STRONG>" & qChargeInfo.cdescription & "</STRONG>" & " has been changed for " & qResident.cFirstName & ', ' & qResident.cLastName & ' at ' & SESSION.HouseName & ' ' & "<BR>";
			message= message & "The charge has been changed to " & LSCurrencyFormat(form.mAmount);
			message= message & "<BR>by: " & SESSION.FullName;
			//message= message & "<BR>" & results & "****";
		</CFSCRIPT>
		<CFMAIL TYPE ="html" FROM="TIPS4_ChargeChanged@alcco.com" TO="#email#" SUBJECT="Current Month Charge changed for #SESSION.HouseName#">#message#</CFMAIL>
	</CFIF>
</CFIF>
	
</CFTRANSACTION>

<CFOUTPUT>
<CFIF isDefined("Auth_user") AND (Auth_User EQ 'ALC\PaulB' OR SESSION.USERID IS 3271)>
	<A HREF="#HTTP.REFERER#">Continue</A>
<CFELSE>
	<CFLOCATION URL = "Charges.cfm">
</CFIF>
</CFOUTPUT>
<!--- ==============================================================================
<CFLOCATION URL = "Charges.cfm?Added=#form.iTenant_ID#">
=============================================================================== --->

