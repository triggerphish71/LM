<!----------------------------------------------------------------------------------------------
| DESCRIPTION   RecurringUpdate.cfm                                                            |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| Parameter Name                                                                               |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| mlaw       | 03/21/2006 | Create Flower Box                                                  |
| mlaw       | 01/24/2007 | Remove mlaw@alcco.com                                              |
| RSchuette  | 01/28/2010 | Proj 35227 - Adding RecChargeID to InvoiceDetail Table             |
|sfarmer     | 06/09/2012 | 92628 - alow only AR to edit NRF/Deferred entries                  |
----------------------------------------------------------------------------------------------->

<cftransaction>
<!--- Retrieve database TimeStamp --->
<cfquery name="qTimeStamp" datasource="#APPLICATION.datasource#">
	select getdate() as TimeStamp
</cfquery>
<cfset TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>

<!--- Concat. Month Day Year for dtEffective Start/End --->
<cfscript>
	dtEffectiveStart = form.monthStart & "/" & form.dayStart & "/" & form.yearStart;
	dtEffectiveStart = CreateODBCDateTime(dtEffectiveStart);
	dtEffectiveEnd = form.monthEnd & "/" & form.dayEnd & "/" & form.yearEnd;
	dtEffectiveEnd = CreateODBCDateTime(dtEffectiveEnd);
</cfscript>

<!--- query to get state medicaid charge type id --->
<cfquery name='qStateChargetypeID' datasource='#APPLICATION.datasource#'>
	select top 1 ichargetype_id from chargetype 
	where dtrowdeleted is null 
	and bismedicaid is not null and bisrent is null 
	and bisrentadjustment is null and bisdiscount is null
</cfquery>
<cfset medicaidchargetype = qStateChargetypeID.ichargetype_id>

<!--- query for chosen recurring charge ---->
<cfquery name="RecurringInfo" datasource="#APPLICATION.datasource#">
	select	*, RC.mAmount as mAmount, RC.bIsDaily as RCbIsDaily
	from RecurringCharge RC (NOLOCK)
	join Charges C (NOLOCK) ON C.iCharge_ID = RC.iCharge_ID	
	join ChargeType CT (NOLOCK) ON CT.iChargeType_ID = C.iChargeType_ID
	where iRecurringCharge_ID = #form.iRecurringCharge_ID#
</cfquery>
<!---<cfdump var="#RecurringInfo#" label="RecurringInfo">--->
<!--- obtain current resident information ---->
<cfquery name="qResident" datasource="#APPLICATION.datasource#">
	select	T.*, H.cStateCode from Tenant T 
	join House H ON T.iHouse_ID = H.iHouse_ID 
	where H.dtrowdeleted is null and T.dtRowDeleted is null 
	and itenant_id = #recurringinfo.itenant_id#
</cfquery>

<cfscript>
	if ((RecurringInfo.bIsRent GT 0 and RecurringInfo.bIsRentAdjustment EQ '' and RecurringInfo.bIsDiscount EQ '' and RecurringInfo.bIsMedicaid EQ '')
		OR (isDefined("form.bisdaily") and form.bIsDaily eq 1 and RecurringInfo.bIsMedicaid GT 0)
		OR (RecurringInfo.bIsDaily EQ 1) ) {
		iQuantity= DaysInMonth(SESSION.TipsMonth); recqty=1; User=0;
	}
	else { iQuantity=form.iquantity; User=SESSION.UserID; recqty=form.iquantity;}
</cfscript>
 

<cfif Now() GTE dtEffectiveStart and Now() LTE dtEffectiveEnd>
	<CFOUTPUT>
		<!--- ==============================================================================
			Check for a corresponding entry in the invoice detail table
		=============================================================================== --->			
		<cfquery name= "CheckInvoices" datasource = "#APPLICATION.datasource#">
			select	iInvoiceDetail_ID
			from InvoiceDetail INV (NOLOCK)
			join InvoiceMaster IM (NOLOCK) ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID and inv.dtrowdeleted is null
				and im.dtrowdeleted is null
			where iTenant_ID = #form.iTenant_ID#
			and	cDescription = '#trim(form.cDescription)#'
			<cfif (RecurringInfo.iChargeType_ID neq medicaidchargetype and RecurringInfo.iChargeType_ID is not 1661)>
				and	(INV.iRowStartUser_ID is null OR INV.iRowStartUser_ID = 0)
			</cfif>
			and	bFinalized is null and bMoveInInvoice is null and bMoveOutInvoice is null
		</cfquery>
		<!---
		<cfdump var="#CheckInvoices#" label="CheckInvoices" abort> 
		#CheckInvoices.RecordCount#- #CheckInvoices.iInvoiceDetail_ID# - #trim(form.cDescription)# - #medicaidchargetype#
		--->
		<!--- ==============================================================================
		Update the Record if is exists
		=============================================================================== --->
		<cfif CheckInvoices.RecordCount EQ 1>

			<!--- ==============================================================================
			Retrieve Charge and Charge Type information for this entry
			=============================================================================== --->
			<cfquery name= "ChargeInfo" datasource = "#APPLICATION.datasource#">
				select CT.iChargeType_ID, CT.bIsRentAdjustment, CT.bIsRent, CT.bIsDiscount, C.cDescription
				from Charges C (NOLOCK)
				join ChargeType CT (NOLOCK) ON (C.iChargeType_ID = CT.iChargeType_ID and CT.dtRowDeleted is null)
				where iCharge_ID = #RecurringInfo.iCharge_ID#
			</cfquery>
			
			<cfif ChargeInfo.iChargeType_ID eq medicaidchargetype OR ChargeInfo.iChargeType_ID is 1661>
				<!--- get copay and R&B amounts from Invoice Detail for same AppliesToAcctPeriod (Tips Month) if they exist, have to remember to add this code to charges updates, too --->
				<cfquery name="getMedicaidCoPay" datasource="#application.datasource#">
					select iInvoiceDetail_ID, mAmount from InvoiceDetail
					where iTenant_ID = #form.iTenant_ID# and cAppliesToAcctPeriod= '#DateFormat(SESSION.TIPSMonth,"yyyymm")#' 
					and iChargeType_ID = 1661 and dtRowDeleted is null
				</cfquery>
				
				<cfquery name="getStateMedicaid" datasource="#application.datasource#">
					select iInvoiceDetail_ID, mAmount from InvoiceDetail
					where iTenant_ID = #form.iTenant_ID# and cAppliesToAcctPeriod= '#DateFormat(SESSION.TIPSMonth,"yyyymm")#' 
					and iChargeType_ID = #medicaidchargetype# and dtRowDeleted is null
				</cfquery>
				
				<cfif getMedicaidCopay.recordcount is not 0>
					<cfset MedicaidCopay = #getMedicaidCopay.mAmount#>
				<cfelse>
					<cfset MedicaidCopay = 0>
				</cfif>
				
				<cfif getStateMedicaid.recordcount is not 0 and ChargeInfo.iChargeType_ID is not medicaidchargetype>
					<!--- get the mAmount (in most cases: DAILY rate the state approves) from the recurring charges table --->
					<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
						select mAmount 
						from recurringcharge 
						where iTenant_ID = #form.iTenant_ID# and cDescription like '%State Medicaid%' and dtRowDeleted is null
					</cfquery>
					<cfset StateMedicaid = #StateMedicaidRecurringInfo.mAmount#>
				<cfelse>
					<cfset StateMedicaid = 0>
				</cfif>
				
				<!--- calculate the New MONTHLY Amount for State Medicaid --->
				<cfset TotalMonthDays = #DaysInMonth(SESSION.TipsMonth)#>
				
				<cfif qResident.cStateCode is not "OR"><!---  and qResident.cStateCode is not "NJ" --->
					<cfif ChargeInfo.iChargeType_ID is medicaidchargetype and isDefined("form.bIsDaily") and form.bIsDaily is "1">
						<!--- only do this equation if entering a DAILY state medicaid recurring charge --->
						<cfset NewAmount = (#form.mAmount# * #TotalMonthDays#) - #MedicaidCoPay#>
						<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
					<cfelseif ChargeInfo.iChargeType_ID is 1661>
						<!--- only do this equation if entering a medicaid Copay recurring charge and State Medicaid recurring is DAILY--->
						<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
							select bIsDaily 
							from recurringcharge 
							where iTenant_ID = #form.iTenant_ID# and cDescription like '%State Medicaid%' and dtRowDeleted is null
						</cfquery>
						<cfif StateMedicaidRecurringInfo.bIsDaily is 1>
							<cfset NewAmount = (#StateMedicaid# * #TotalMonthDays#) - #form.mAmount#>
							<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
						</cfif>
					</cfif>
				<cfelseif qResident.cStateCode is "OR"><!--- updated by Katie on 12/13/2004: NJ now works like TX where subtract copay from Staterate --->
					<cfif ChargeInfo.iChargeType_ID is medicaidchargetype>
						<cfset NewAmount = #form.mAmount# - #MedicaidCoPay# >
					<cfelseif ChargeInfo.iChargeType_ID is 1661>
						<!--- only do this equation if entering a medicaid Copay recurring charge and State Medicaid recurring is DAILY--->
						<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
							select bIsDaily 
							from recurringcharge 
							where iTenant_ID = #form.iTenant_ID# and cDescription like '%State Medicaid%' and dtRowDeleted is null
						</cfquery>
						<cfif StateMedicaidRecurringInfo.bIsDaily is 1>
							<cfset NewAmount = (#StateMedicaid# * #TotalMonthDays#) - #form.mAmount#>
						<cfelse>
							<cfset NewAmount = (#StateMedicaid# - #form.mAmount#)>
							<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
						</cfif>
					</cfif>
				</cfif>
				<cfif isDefined("newamount")>New Amount: #newAmount# </cfif>Form Amount: #form.mAmount# Days in Month: #TotalMonthDays# <cfif isDefined("MedicaidCoPay")>Medicaid Copay: #medicaidcopay#</cfif> <cfif isDefined("StateMedicaid")>State Medicaid: #statemedicaid#</cfif><BR>
			</cfif>
			
			<!--- update detail of record submitting change for --->
			<cfquery name= "UpdateDetail" datasource = "#APPLICATION.datasource#" result="UpdateDetail">
				update InvoiceDetail
				set cDescription = '#trim(form.cDescription)#' 
				,mAmount = <cfif ChargeInfo.iChargeType_ID is 1749 or ChargeInfo.iChargeType_ID is 1750> #(form.mAmount*iQuantity)# <cfelse>#form.mAmount# </cfif>
				,iQuantity = 	
				<cfif ChargeInfo.iChargeType_ID is 1748 or ChargeInfo.iChargeType_ID is 1749 or ChargeInfo.iChargeType_ID is 1750 or ChargeInfo.iChargeType_ID is 1682>
					 1 
				<cfelse>
				#iQuantity#
				</cfif>
				,dtRowStart = getDate() 
				,iRowStartUser_ID = 0 
				,iDaysBilled= #DaysInMonth(SESSION.TipsMonth)#
              <!---   cInvoiceComments = '#form.cInvoiceComments#' --->
				where	iInvoiceDetail_ID = #CheckInvoices.iInvoiceDetail_ID#
			</cfquery>
			<!---<cfdump var="#UpdateDetail#">--->
			
			<cfif isDefined("NewAmount")>
				<!--- update detail of record for State Medicaid --->
				<cfquery name= "UpdateStateMedicaidDetail" datasource = "#APPLICATION.datasource#">
					update InvoiceDetail
					set mAmount = #NewAmount# ,iQuantity = 1
							,dtRowStart = getDate() ,iRowStartUser_ID = 0, iDaysBilled= #DaysInMonth(SESSION.TipsMonth)# <!--- #User# --->
					where	iInvoiceDetail_ID = #getStateMedicaid.iInvoiceDetail_ID#
				</cfquery>
			</cfif>
			
			<!--- update of the recurring charge itself is done below around line 297 --->
			
			
		<cfelseif CheckInvoices.RecordCount EQ 0>

			<!--- Retrieve Charge and Charge Type information for this entry --->
			<cfquery name= "ChargeInfo" datasource = "#APPLICATION.datasource#">
				select CT.iChargeType_ID, CT.bIsRentAdjustment, CT.bIsRent, CT.bIsDiscount, C.cDescription
				from Charges C (NOLOCK)
				join ChargeType CT (NOLOCK) ON (C.iChargeType_ID = CT.iChargeType_ID and CT.dtRowDeleted is null)
				where iCharge_ID = #RecurringInfo.iCharge_ID#
			</cfquery>				

			<cfscript>
				if (ChargeInfo.bIsRent GT 0 and ChargeInfo.bIsRentAdjustment EQ '' and ChargeInfo.bIsDiscount EQ '') {
					iQuantity= DaysInMonth(SESSION.TipsMonth); }
				else { iQuantity=1; }
			</cfscript>

			<!--- Retrieve Current Invoice Master Number --->
			<cfquery name= "InvoiceNumber" datasource = "#APPLICATION.datasource#">
				select IM.iInvoiceMaster_ID
				from InvoiceMaster IM (NOLOCK)
				join Tenant T (NOLOCK) ON (T.cSolomonKey = IM.cSolomonKey and T.dtRowDeleted is null)
				where T.iTenant_ID = '#RecurringInfo.iTenant_ID#'
				and	IM.dtRowDeleted is null and	IM.bMoveInInvoice is null and IM.bMoveOutInvoice is null
				and	bFinalized is null
			</cfquery>			
		
			<cfset cAppliesToAcctPeriod = Year(SESSION.TIPSMonth) & DateFormat((SESSION.TIPSMonth),"mm")>
			
			<!--- ------------------------------------------- --->
			<!--- Added by Katie: 9/27/03: Do the calculation so amount is updated into Invoice Details properly for State Medicaid if Daily is checked and it's the proper State --->
			
			<cfif ChargeInfo.iChargeType_ID is medicaidchargetype OR ChargeInfo.iChargeType_ID is 1661>
				<!--- get copay and R&B amounts from Invoice Detail for same AppliesToAcctPeriod (Tips Month) if they exist, have to remember to add this code to charges updates, too --->
				<cfquery name="getMedicaidCoPay" datasource="#application.datasource#">
					select iInvoiceDetail_ID, mAmount from InvoiceDetail
					where iTenant_ID = #form.iTenant_ID# and cAppliesToAcctPeriod= '#DateFormat(SESSION.TIPSMonth,"yyyymm")#' 
					and iChargeType_ID = 1661 and dtRowDeleted is null
				</cfquery>
				
				<cfquery name="getStateMedicaid" datasource="#application.datasource#">
					select iInvoiceDetail_ID, mAmount from InvoiceDetail
					where dtRowDeleted is null and iTenant_ID = #form.iTenant_ID# and cAppliesToAcctPeriod= '#DateFormat(SESSION.TIPSMonth,"yyyymm")#' 
					and iChargeType_ID = #medicaidchargetype#
				</cfquery>
				
				<cfif getMedicaidCopay.recordcount is not 0>
					<cfset MedicaidCopay = getMedicaidCopay.mAmount>
				<cfelse>
					<cfset MedicaidCopay = 0>
				</cfif>
				
				<cfif getStateMedicaid.recordcount is not 0>
					<!--- get the mAmount (in most cases: DAILY rate the state approves) from the recurring charges table --->
					<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
						select mAmount 
						from recurringcharge 
						where iTenant_ID = #form.iTenant_ID# and cDescription like '%State Medicaid%' and dtRowDeleted is null
					</cfquery>
					<cfset StateMedicaid = StateMedicaidRecurringInfo.mAmount>
				<cfelse>
					<cfset StateMedicaid = 0>
				</cfif>
				
				<!--- calculate the New MONTHLY Amount for State Medicaid --->
				<cfset TotalMonthDays = DaysInMonth(SESSION.TipsMonth)>
				
				<cfif qResident.cStateCode is not "IA" and qResident.cStateCode is not "OR"><!---  and qResident.cStateCode is not "NJ" --->
					<cfif ChargeInfo.iChargeType_ID is medicaidchargetype and isDefined("form.bIsDaily") and form.bIsDaily is "1">
						<!--- only do this equation if entering a DAILY state medicaid recurring charge --->
						<cfset NewAmount = (form.mAmount * TotalMonthDays) - MedicaidCoPay>
						<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
					<cfelseif ChargeInfo.iChargeType_ID is 1661>
						<!--- only do this equation if entering a medicaid Copay recurring charge and State Medicaid recurring is DAILY--->
						<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
							select bIsDaily 
							from recurringcharge 
							where iTenant_ID = #form.iTenant_ID# and cDescription like '%State Medicaid%' and dtRowDeleted is null
						</cfquery>
						<cfif StateMedicaidRecurringInfo.bIsDaily is 1>
							<cfset NewAmount = (StateMedicaid * TotalMonthDays) - form.mAmount>
							<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
						</cfif>
					</cfif>
				<cfelseif qResident.cStateCode is "NJx"><!--- updated by Katie on 12/13/2004: NJ now works like TX where subtract copay from Staterate --->
					<cfif ChargeInfo.iChargeType_ID is medicaidchargetype and isDefined("form.bIsDaily") and form.bIsDaily is "1">
						<cfset NewAmount = (form.mAmount * TotalMonthDays)>
					</cfif>
				</cfif>
			</cfif>
			
			<!--- 
				If no records exist and it is in the proper effective range.
				Insert a new record in to the Database
			--->
			<cfquery name= "InsertDetail" datasource = "#APPLICATION.datasource#" result="InsertDetail">
				insert into InvoiceDetail
				(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, dtTransaction, iQuantity, 
					cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart,iDaysBilled
				)values(
					<cfif InvoiceNumber.iInvoiceMaster_ID NEQ ""> #InvoiceNumber.iInvoiceMaster_ID#, <cfelse> ** ERROR No Invoice FOUND **</cfif> 
					#form.iTenant_ID#,
					#ChargeInfo.iChargeType_ID#,
					<cfif cAppliesToAcctPeriod NEQ "">'#cAppliesToAcctPeriod#',<cfelse>#DateFormat(SESSION.TIPSMonth,"yyyymm")#</cfif>
					<cfif ChargeInfo.bIsRentAdjustment NEQ ""> #ChargeInfo.bIsRentAdjustment#, <cfelse> NULL, </cfif>
					#TimeStamp#,
					<cfif ChargeInfo.iChargeType_ID is 1748 or ChargeInfo.iChargeType_ID is 1682 or ChargeInfo.iChargeType_ID is 1749 or ChargeInfo.iChargeType_ID is 1750>
					1 
					<cfelse>
					#isBlank(iQuantity,1)#
					</cfif>,
					'#trim(form.cDescription)#',
					<cfif ChargeInfo.iChargeType_ID is 1749 or ChargeInfo.iChargeType_ID is 1750> 
					#(form.mAmount*iQuantity)# 
					<cfelseif not isDefined("NewAmount")>#form.mAmount#
					<cfelse>#NewAmount#
					</cfif>,
					<cfif Len(TRIM(form.cComments)) GT 0>'#TRIM(form.cComments)#',<cfelse>NULL,</cfif>
					'#SESSION.AcctStamp#',
					0,
					#TimeStamp#,
					#DaysInMonth(SESSION.TipsMonth)#
				)
			</cfquery>	
			<!---<cfdump var="#InsertDetail#">--->
		</cfif>

	</CFOUTPUT>
</cfif>
<cfif RecurringInfo.bisrent neq ''>
	<cfset form.iquantity=1>
</cfif>

<cfif (server_name neq 'oldbirch')>
	<cfif isDefined("SESSION.RDOEmail") and RecurringInfo.bDirectorEmail GT 0 and (LSCurrencyFormat(RecurringInfo.mAmount) NEQ LSCurrencyFormat(form.mAmount)) >
		<cfscript>
			if (SESSION.qSelectedHouse.ihouse_id EQ 200) { email='CFDevelopers@alcco.com'; }
			else { email=SESSION.RDOEmail; } 
			message= RecurringInfo.cdescription & " has changed for " & qResident.cFirstName & ', ' & qResident.cLastName & ' at ' & SESSION.HouseName & ' ' & "<BR>";
			message= message & "The rate has changed from " & LSCurrencyFormat(RecurringInfo.mAmount) & " to " & LSCurrencyFormat(form.mAmount);
		</cfscript>
		<cfmail TYPE="HTML" FROM="TIPS4_Recurring_Change@alcco.com" TO="#email#" SUBJECT="Recurring Rate Change for #SESSION.HouseName#">#message#</cfmail>
	</cfif>
</cfif>

<!--- Update the Recurring Table --->	
<cfquery name="UpdateRecurring" datasource = "#APPLICATION.datasource#" result="UpdateRecurring">
	update RecurringCharge
	set
		<cfif form.iTenant_ID NEQ "">iTenant_ID = #form.iTenant_ID#,<cfelse>iTenant_ID = NULL,</cfif>
		<cfif form.iCharge_ID NEQ "">iCharge_ID = #form.iCharge_ID#,<cfelse>iCharge_ID = NULL,</cfif>
		<cfif Variables.dtEffectiveStart NEQ "//">dtEffectiveStart = #Variables.dtEffectiveStart#,<cfelse>dtEffectiveStart = NULL,</cfif>
		<cfif Variables.dtEffectiveEnd NEQ "//">dtEffectiveEnd = #Variables.dtEffectiveEnd#,<cfelse>dtEffectiveEnd = NULL,</cfif>
		<cfif recqty NEQ "">iQuantity = #recqty#,<cfelse>iQuantity = 1,</cfif>
		<cfif form.cDescription NEQ "">cDescription = '#trim(form.cDescription)#',<cfelse>cDescription = NULL,</cfif>
		<cfif form.mAmount NEQ "">mAmount =  #form.mAmount#,<cfelse>mAmount = NULL,</cfif>
		<cfif form.cComments NEQ "">cComments = '#form.cComments#',<cfelse>cComments = NULL,</cfif>
		dtAcctStamp = #CreateODBCDateTime(SESSION.AcctStamp)#,
		iRowStartUser_ID = #SESSION.UserID#,
		dtRowStart = GetDate(),
		bIsDaily = <cfif not isDefined("form.bIsDaily")>0<cfelse>1</cfif> 
        <!--- cInvoiceComments = '#form.cInvoiceComments#' --->
	where	iRecurringCharge_ID = #form.iRecurringCharge_ID#
</cfquery>
<!---<cfdump var="#UpdateRecurring#">--->
<!--- 1/28/2010 RTS 35227 - get invoicedetail id for later --->
<cfif isDefined('CheckInvoices.RecordCount') and  CheckInvoices.RecordCount LTE 1>
	<cfset cAppliesToAcctPeriod = Year(SESSION.TIPSMonth) & DateFormat((SESSION.TIPSMonth),"mm")>
 	<cfquery name="GetInvDtlIDMstrID" datasource="#application.datasource#">
		select id.iInvoiceMaster_ID from InvoiceDetail id 
		where id.iInvoiceDetail_ID = #CheckInvoices.iInvoiceDetail_ID#
	</cfquery>
	<cfquery name="GetInvDtlID" datasource="#application.datasource#">
		select i.iInvoiceDetail_ID,i.iRecurringCharge_ID
		from InvoiceDetail i
		where i.iTenant_ID = #form.iTenant_ID#
		and i.iInvoiceMaster_ID = #GetInvDtlIDMstrID.iInvoiceMaster_ID#
		and i.iChargeType_ID = #ChargeInfo.iChargeType_ID#
		and i.cAppliesToAcctPeriod = 
			<cfif Variables.cAppliesToAcctPeriod neq "">
				'#Variables.cAppliesToAcctPeriod#'
			<cfelse>
				#DateFormat(SESSION.TIPSMonth,"yyyymm")#
			</cfif>
		and i.cDescription = '#form.cDescription#'
		and i.dtRowDeleted is null 
	</cfquery>
	<cfset IDid = GetInvdtlID.iInvoiceDetail_ID>
<!--- 35227 RTS 1/29/10 update the invoicedetail. --->
	<cfif GetInvDtlID.iRecurringCharge_ID is '' or GetInvDtlID.iRecurringCharge_ID is 'null'>
		<cfquery name="UpdateInvDtlWRecChgID" datasource="#application.datasource#">
			update InvoiceDetail 
			set iRecurringCharge_ID = #RecurringInfo.iRecurringCharge_ID#
			where iInvoiceDetail_ID = #IDid#
		</cfquery>
	</cfif>
</cfif>

</cftransaction>

<cflocation url="Recurring.cfm">