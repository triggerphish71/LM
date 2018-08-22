<!----------------------------------------------------------------------------------------------
| DESCRIPTION   RecurringAdd.cfm                                                            |
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
|No entries prior
| RSchuette  | 01/28/2010 | Proj 35227 - Adding RecChargeID to InvoiceDetail Table			   |
----------------------------------------------------------------------------------------------->

<cftransaction>
<!--- Initialize User Field --->
<cfset User=SESSION.userid>

<!--- Retrieve database TimeStamp --->
<cfquery name="qTimeStamp" datasource="#APPLICATION.datasource#">
select getdate() as TimeStamp
</cfquery>
<cfset TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>

<!--- Retrieve Tenant Information --->
<cfquery name="qTenant" datasource="#APPLICATION.datasource#">
select	T.*, H.cStateCode from Tenant T 
join House H ON T.iHouse_ID = H.iHouse_ID and H.dtRowDeleted IS NULL 
and  T.dtRowDeleted IS NULL and T.iTenant_ID = #form.iTenant_ID#
</cfquery>

<!--- =============================================================
	Concat. Month Day Year for dtEffective Start/End 
=============================================================  --->
<cfscript>
dtEffectiveStart = form.monthStart & "/" & form.dayStart & "/" & form.yearStart;
dtEffectiveStart = CreateODBCDateTime(dtEffectiveStart);
dtEffectiveEnd = form.monthEnd & "/" & form.dayEnd & "/" & form.yearEnd;
dtEffectiveEnd = CreateODBCDateTime(dtEffectiveEnd);
</cfscript>
	<cfset cAppliesToAcctPeriod = Year(SESSION.TIPSMonth) & DateFormat((SESSION.TIPSMonth),"mm")>
		<cfif (TimeStamp GTE dtEffectiveStart and TimeStamp LTE dtEffectiveEnd) 
			OR (SESSION.TipsMonth GTE dtEffectiveStart and SESSION.TipsMonth LTE dtEffectiveEnd)>
			
			<cfoutput>
			
			<!--- Retrieve Tenant Information --->
			<cfquery name="qTenant" datasource="#APPLICATION.datasource#">
			select	T.*, H.cStateCode from Tenant T 
			join House H ON T.iHouse_ID = H.iHouse_ID and H.dtRowDeleted IS NULL 
			and  T.dtRowDeleted IS NULL and T.iTenant_ID = #form.iTenant_ID#
			</cfquery>
			
			<!--- Check for Duplicate Record for this recurring in the database --->			
			<cfquery name = "CheckRecurr" datasource = "#APPLICATION.datasource#">
			select	*
			from  InvoiceDetail INV
			join InvoiceMaster IM ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID and IM.dtRowDeleted IS NULL
			and INV.dtRowDeleted IS NULL and bFinalized IS NULL and bMoveInInvoice IS NULL 
			and bMoveOutInvoice IS NULL
			and INV.iTenant_ID = #form.iTenant_ID# and INV.cDescription = '#form.cDescription#'
			and	(INV.iRowStartUser_ID IS NULL OR INV.iRowStartUser_ID = 0)
			</cfquery>
			
		<!---<cfdump var="#CheckRecurr#">--->
			<!--- Retrieve Charge and Charge Type information for this entry --->
			<cfquery name="ChargeInfo" datasource="#APPLICATION.datasource#">
			select	CT.iChargeType_ID, CT.bIsRentAdjustment, CT.bIsRent, CT.bIsDiscount, 
					CT.bIsMedicaid, CT.bIsDaily, C.cDescription
			from	Charges C
			join	ChargeType CT ON (C.iChargeType_ID = CT.iChargeType_ID and CT.dtRowDeleted IS NULL)
			where	iCharge_ID = #form.iCharge_ID#
			</cfquery>
		<!---<cfdump var="#ChargeInfo#">--->
			<cfscript>
				if (
				( ChargeInfo.bIsRent gt 0 and ChargeInfo.bIsRentAdjustment eq '' and ChargeInfo.bIsDiscount eq '' 
					and ChargeInfo.bIsMedicaid eq '' and ChargeInfo.bisDaily eq 1)
					OR (isDefined("form.bisdaily") and form.bIsDaily eq 1 and ChargeInfo.bIsMedicaid GT 0)
					OR (ChargeInfo.bIsDaily eq 1) 
				) 
				{ writeoutput(" *** A Problem with the Invoice has occurred: *** "); form.iQuantity= DaysInMonth(SESSION.TipsMonth); recqty=1; User=0;}
				else { iQuantity=form.iquantity; User=SESSION.UserID; recqty=form.iquantity;}
			</cfscript>
			
			<!--- Retrieve Current Invoice Master Number --->
			<cfquery name = "InvoiceNumber" datasource = "#APPLICATION.datasource#">
			select	IM.iInvoiceMaster_ID
			from InvoiceMaster IM
			join Tenant T ON (T.cSolomonKey = IM.cSolomonKey and T.dtRowDeleted IS NULL)
			where IM.dtRowDeleted IS NULL and IM.bMoveInInvoice IS NULL and IM.bMoveOutInvoice IS NULL and bFinalized IS NULL	
			and T.cSolomonKey = '#qTenant.cSolomonKey#'
			</cfquery>
			
			<cfset cAppliesToAcctPeriod = Year(SESSION.TIPSMonth) & DateFormat((SESSION.TIPSMonth),"mm")>
			
			<!--- ------------------------------------------- --->
			<!--- Added by Katie: 9/27/03: Do the calculation so amount is added into Invoice Details properly for State Medicaid if Daily is checked and it's the proper state --->
			
			<cfif ChargeInfo.iChargeType_ID is 8 OR ChargeInfo.iChargeType_ID is 1661 or ChargeInfo.iChargeType_ID is 1749 or ChargeInfo.iChargeType_ID is 1750>
				<!--- get copay and R&B amounts from Invoice Detail for same AppliesToAcctPeriod (Tips Month) if they exist, have to remember to add this code to charges updates, too --->
				<cfquery name="getMedicaidCoPay" datasource="#application.datasource#">
				select iInvoiceDetail_ID, mAmount from InvoiceDetail
				where iTenant_ID = #form.iTenant_ID# and cAppliesToAcctPeriod= <cfif cAppliesToAcctPeriod neq "">'#cAppliesToAcctPeriod#'<cfelse>#DateFormat(SESSION.TIPSMonth,"yyyymm")#</cfif> and iChargeType_ID = 1661 and dtRowDeleted IS NULL
				</cfquery>
				<!---<cfdump var="#getMedicaidCoPay#">--->
				<cfquery name="getStateMedicaid" datasource="#application.datasource#">
				select iInvoiceDetail_ID, mAmount from InvoiceDetail
				where iTenant_ID = #form.iTenant_ID# and cAppliesToAcctPeriod= <cfif Variables.cAppliesToAcctPeriod neq "">'#Variables.cAppliesToAcctPeriod#'<cfelse>#DateFormat(SESSION.TIPSMonth,"yyyymm")#</cfif> and iChargeType_ID in (8,1749,1750) and dtRowDeleted IS NULL
				</cfquery>
				<!---<cfdump var="#getStateMedicaid#">--->
				<cfscript>
					if (getMedicaidCopay.recordcount is not 0) { MedicaidCopay = getMedicaidCopay.mAmount; }
					else { MedicaidCopay = 0; }
				</cfscript>
				
				<cfif getStateMedicaid.recordcount is not 0>
					<cfif ChargeInfo.bIsMedicaid eq 1 and ChargeInfo.bIsRent EQ 0>
						<cfset StateMedicaid = form.mAmount>
					<cfelse>
						<!--- get the mAmount (in most cases: DAILY rate the state approves) from the recurring charges table --->
						<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
						select top 1 mAmount from recurringcharge 
						where dtRowDeleted IS NULL and iTenant_ID = #form.iTenant_ID# and cDescription like '%State Medicaid%' 
						order by dtrowstart desc
						</cfquery>
						<cfset StateMedicaid = StateMedicaidRecurringInfo.mAmount>
					</cfif>
				<cfelse> <cfset StateMedicaid = 0> </cfif>
				
				<!--- calculate the New MONTHLY Amount for State Medicaid --->
				<cfset TotalMonthDays = DaysInMonth(SESSION.TipsMonth)>#qTenant.cStateCode#<BR>
				
				<cfif qTenant.cStateCode is not "OR">
					<!--- NOT OR ---><BR>
					<cfif (ChargeInfo.iChargeType_ID is 8 or ChargeInfo.iChargeType_ID is 1749 or ChargeInfo.iChargeType_ID is 1750)  and isDefined("form.bIsDaily") and form.bIsDaily is "1">
					
						<!--- only do this equation if entering a state medicaid recurring charge --->
						<cfset NewAmount = (form.mAmount * TotalMonthDays) - MedicaidCoPay>
						<cfif NewAmount LT 0> <cfset NewAmount = 0> </cfif>
					<cfelseif (ChargeInfo.iChargeType_ID is 1749 or ChargeInfo.iChargeType_ID is 1750) and not isDefined("form.bIsDaily")>
						<cfset NewAmount=#form.mAmount#>
					
					<cfelseif ChargeInfo.iChargeType_ID is 1661>
					
						<!--- only do this equation if entering a medicaid Copay recurring charge and State Medicaid recurring is DAILY--->
						<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
						select bIsDaily from recurringcharge where iTenant_ID = #form.iTenant_ID# 
						and cDescription like '%State Medicaid%' and dtRowDeleted IS NULL
						</cfquery>
						
						<cfif StateMedicaidRecurringInfo.bIsDaily is 1>
							<cfset NewAmount = (StateMedicaid * TotalMonthDays) - form.mAmount>
							<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
						</cfif>
						
					</cfif>
				<cfelseif qTenant.cStateCode is "NJx"><!--- updated by Katie on 12/13/2004: NJ now works like TX where subtract copay from Staterate --->
					YES NJx<BR>
					<cfif ChargeInfo.iChargeType_ID is 8 and (isDefined("form.bIsDaily") and form.bIsDaily is "1")>
						<cfset NewAmount = (form.mAmount * TotalMonthDays)>
					</cfif>
				<cfelse> <!--- for oregon and Idaho --->
					<cfset NewAmount = isBlank(StateMedicaid,form.mAmount)>
				</cfif>
			</cfif>
			
			<cfif isDefined("NewAmount")>New Amount: #newamount#<BR></cfif>

			<cfif CheckRecurr.RecordCount EQ 0>
				
				<cfscript>
				//calculate TotalMonthDays
				TotalMonthDays = DaysInMonth(SESSION.TipsMonth);
				if (isDefined("form.bIsDaily") and form.bIsDaily is "1") { iQuantity = TotalMonthDays; }
				else { iQuantity = form.iQuantity; }
				</cfscript>
					
				<!--- ==============================================================================
				If no records exist and it is in the proper effective range.
				Insert a new record in to the Database
				=============================================================================== --->
				
				<!--- insert detail of record submitting change for --->
				<cfif ChargeInfo.iChargeType_ID is not 8 or (ChargeInfo.iChargeType_ID is 8 and not isDefined("form.bIsDaily"))>
					<cfif ChargeInfo.iChargeType_ID neq 1749 >
					<cfif  ChargeInfo.iChargeType_ID neq 1750 >
					<!--- enter in detail for most charges --->
					<cfquery name = "InsertDetail" datasource = "#APPLICATION.datasource#" result="test">
					insert into InvoiceDetail
					(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, dtTransaction, 
						iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart,iDaysBilled  <!--- , cInvoiceComments  --->
					) 
					values (
						<cfif InvoiceNumber.iInvoiceMaster_ID neq ""> #InvoiceNumber.iInvoiceMaster_ID#, <cfelse> ** ERROR No Invoice FOUND **,</cfif> 
						#form.iTenant_ID# ,
                        #ChargeInfo.iChargeType_ID#,
						<cfif Variables.cAppliesToAcctPeriod neq "">'#Variables.cAppliesToAcctPeriod#',<cfelse>#DateFormat(SESSION.TIPSMonth,"yyyymm")#,</cfif>
						<cfif ChargeInfo.bIsRentAdjustment neq ""> #ChargeInfo.bIsRentAdjustment#, <cfelse> NULL, </cfif>
						#TimeStamp#,
						#iQuantity#,
						'#form.cDescription#',
						#form.mAmount#,
						<cfif len(trim(form.cComments)) GT 0>'#TRIM(form.cComments)#',<cfelse>NULL,</cfif>
						'#SESSION.AcctStamp#',
						0,
						#TimeStamp#,
						#DaysInMonth(SESSION.TipsMonth)#						
						<!---, '#form.cInvoiceComments#'  --->
						)
					</cfquery>
		           <cfdump var="#test#">
					</cfif>
					</cfif>
				<cfelseif (ChargeInfo.iChargeType_ID is 8 and isDefined("form.bIsDaily") and form.bIsDaily is "1")>
					<!--- enter in detail for State Medicaid DAILY charges --->
					<cfquery name = "InsertDetail" datasource = "#APPLICATION.datasource#" result="InsertDetail">
					insert into InvoiceDetail
					(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, dtTransaction, 
						iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart,iDaysBilled<!--- ,cInvoiceComments  --->)
					values 
					( <cfif InvoiceNumber.iInvoiceMaster_ID neq ""> #InvoiceNumber.iInvoiceMaster_ID#, <cfelse> ** ERROR No Invoice FOUND **</cfif> 
						#form.iTenant_ID#,
						#ChargeInfo.iChargeType_ID#,
						<cfif Variables.cAppliesToAcctPeriod neq "">'#Variables.cAppliesToAcctPeriod#',<cfelse>#DateFormat(SESSION.TIPSMonth,"yyyymm")#</cfif>
						<cfif ChargeInfo.bIsRentAdjustment neq ""> #ChargeInfo.bIsRentAdjustment#, <cfelse> NULL, </cfif>
						#TimeStamp# ,1 ,'#form.cDescription#' ,#NewAmount#,
						<cfif Len(TRIM(form.cComments)) GT 0>'#TRIM(form.cComments)#',<cfelse>NULL,</cfif>
						'#SESSION.AcctStamp#' ,0 ,#TimeStamp#,#DaysInMonth(SESSION.TipsMonth)#<!--- ,'#form.cInvoiceComments#'  --->)
					</cfquery>
					<cfdump var="#InsertDetail#">
				</cfif>
				test going here
				<cfif isDefined("NewAmount") and ChargeInfo.iChargeType_ID is 1749 or ChargeInfo.iChargeType_ID is 1750>
					test going here
					<!--- if entering co-pay, and State Medicaid amount already exits, update State Medicaid amount in recurring charges and invoice details --->
					<cfquery name = "InsertDetail" datasource = "#APPLICATION.datasource#" result="insertdetail">
					insert into InvoiceDetail
					(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, dtTransaction, 
						iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart,iDaysBilled<!--- ,cInvoiceComments  --->)
					values 
					( <cfif InvoiceNumber.iInvoiceMaster_ID neq ""> #InvoiceNumber.iInvoiceMaster_ID#, <cfelse> ** ERROR No Invoice FOUND **</cfif> 
						#form.iTenant_ID#,
						#ChargeInfo.iChargeType_ID#,
						<cfif Variables.cAppliesToAcctPeriod neq "">'#Variables.cAppliesToAcctPeriod#',<cfelse>#DateFormat(SESSION.TIPSMonth,"yyyymm")#</cfif>
						<cfif ChargeInfo.bIsRentAdjustment neq ""> #ChargeInfo.bIsRentAdjustment#, <cfelse> NULL, </cfif>
						#TimeStamp# ,1 ,'#form.cDescription#' ,#NewAmount#,
						<cfif Len(TRIM(form.cComments)) GT 0>'#TRIM(form.cComments)#',<cfelse>NULL,</cfif>
						'#SESSION.AcctStamp#' ,0 ,#TimeStamp#,#DaysInMonth(SESSION.TipsMonth)#<!--- ,'#form.cInvoiceComments#'  --->)
					</cfquery>
					<cfdump var="#Insertdetail#">
				</cfif>
				
				<cfif isDefined("NewAmount") and ChargeInfo.iChargeType_ID is 1661 and getStateMedicaid.recordcount is not 0>
					<!--- if entering co-pay, and State Medicaid amount already exits, update State Medicaid amount in recurring charges and invoice details --->
					<cfquery name = "UpdateStateMedicaidDetail" datasource = "#APPLICATION.datasource#">
					update InvoiceDetail
					set mAmount = #NewAmount# ,iQuantity = 1 ,dtRowStart = getDate() ,iRowStartUser_ID = 0,iDaysBilled= #DaysInMonth(SESSION.TipsMonth)#<!--- #User# --->
					where iInvoiceDetail_ID = #getStateMedicaid.iInvoiceDetail_ID#
					</cfquery>
				</cfif>
					<!---<cfoutput> NewAmount #NewAmount#</cfoutput>--->
				
			<cfelse>
				<!--- If a record already exists (ie. back button) then update the record. --->
				<!--- calculate TotalMonthDays --->
				<cfset TotalMonthDays = DaysInMonth(SESSION.TipsMonth)>
				
				<cfif isDefined("form.bIsDaily") and form.bIsDaily is "1">
					<cfset iQuantity = TotalMonthDays> <br>
				<cfelse> <cfset iQuantity = form.iQuantity> </cfif>
				
				<cfif ChargeInfo.iChargeType_ID is 8 >
					<!--- if a new amount is not defined use entered form amount --->
					<cfset newamount = form.mamount>
			
					<!--- Adding new State Medicaid, but it already exists, so update --->
					<cfquery name = "UpdateStateMedicaidDetail" datasource = "#APPLICATION.datasource#" result="UpdateDetail">
					update InvoiceDetail
					set mAmount = #NewAmount# ,iQuantity = 1 ,dtRowStart = getDate() ,iRowStartUser_ID = 0, iDaysBilled= #DaysInMonth(SESSION.TipsMonth)# <!--- #User# --->
					where dtrowdeleted is null and iInvoiceDetail_ID = #getStateMedicaid.iInvoiceDetail_ID#
					</cfquery>
					
				<cfelseif ChargeInfo.iChargeType_ID is 1749 or ChargeInfo.iChargeType_ID is 1750 >
					
				   <cfquery name = "UpdateStateMedicaidDetail" datasource = "#APPLICATION.datasource#" result="UpdateDetail">
					update InvoiceDetail
					set mAmount = #NewAmount# ,iQuantity = 1 ,dtRowStart = getDate() ,iRowStartUser_ID = 0, iDaysBilled= #DaysInMonth(SESSION.TipsMonth)#<!--- #User# --->
					where dtrowdeleted is null and iInvoiceDetail_ID = #getStateMedicaid.iInvoiceDetail_ID#
					</cfquery>
					
					<cfdump var="#UpdateDetail#">
				<cfelse>
					<!--- adding new Something other than State Medicaid, but it already exists, so update --->
					<cfquery name = "UpdateDetail" datasource = "#APPLICATION.datasource#" result="UpdateDetail">
						update InvoiceDetail
						set cDescription = '#trim(form.cDescription)#', mAmount = #form.mAmount#,
						iQuantity = #iQuantity#, dtRowStart = #TimeStamp#, iRowStartUser_ID = 0, iDaysBilled= #DaysInMonth(SESSION.TipsMonth)#
						where dtrowdeleted is null and iInvoiceDetail_ID = #CheckRecurr.iInvoiceDetail_ID#
					</cfquery>
				</cfif>
				<!---<cfdump var="#UpdateDetail#">--->
				<cfif isDefined("NewAmount") and ChargeInfo.iChargeType_ID is 1661 and getStateMedicaid.recordcount is not 0>
					<!--- if entering co-pay, and State Medicaid amount already exits, update State Medicaid amount in recurring charges and invoice details --->
					<cfquery name = "UpdateStateMedicaidDetail" datasource = "#APPLICATION.datasource#">
					update InvoiceDetail
					set mAmount = #NewAmount# ,iQuantity = 1 ,dtRowStart = getDate() ,iRowStartUser_ID = 0 , iDaysBilled= #DaysInMonth(SESSION.TipsMonth)#<!--- #User# --->
					where iInvoiceDetail_ID = #getStateMedicaid.iInvoiceDetail_ID#
					</cfquery>
				</cfif>
				
			</cfif>
		</cfoutput>
	</cfif>
	<!---
		Add the new Charge to the Recurring Table : 
		NOTE FROM KATIE 9/29/03: Why would we add a new recurring charge for the SAME chargetype???
	--->
	<cfquery name = "AddRecurring" datasource="#APPLICATION.datasource#" result="AddRecurring">
	insert into RecurringCharge
	( iTenant_ID, iCharge_ID, dtEffectiveStart, dtEffectiveEnd, 	iQuantity, cDescription, mAmount, 
		cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart, bIsDaily<!--- , cInvoiceComments --->
	)values(
		<cfif form.iTenant_ID neq "">	#form.iTenant_ID#,	<cfelse>	NULL,	</cfif>
		<cfif form.iCharge_ID neq "">	#form.iCharge_ID#,	<cfelse>	NULL,	</cfif>
		<cfif Variables.dtEffectiveStart neq "//">	#Variables.dtEffectiveStart#,	<cfelse>	NULL,	</cfif>
		<cfif Variables.dtEffectiveEnd neq "//">	#Variables.dtEffectiveEnd#,		<cfelse>	NULL,	</cfif>
		<cfif isDefined("recqty") and recqty neq "">#recqty#,<cfelse>1,</cfif>
		<cfif form.cDescription neq ""> '#form.cDescription#',	<cfelse> NULL, </cfif>
		<cfif form.mAmount neq ""> #form.mAmount#, <cfelse>	NULL, </cfif>
		<cfif form.cComments neq ""> '#form.cComments#', <cfelse> NULL, </cfif>
		#CreateODBCDateTime(SESSION.AcctStamp)#, #isBlank(User,SESSION.USERID)#, #TimeStamp#,
		<cfif not IsDefined("form.bIsDaily")>0<cfelse>1</cfif> 
        <!--- '#form.cInvoiceComments#' ---> )
	</cfquery>
<!---<cfdump var="#AddRecurring#">--->
<cfif (server_name neq 'oldbirch')>
	<cfquery name="RecurringInfo" datasource="#APPLICATION.datasource#">
	select	*, RC.mAmount as mAmount
	from RecurringCharge RC (NOLOCK)
	join Charges C (NOLOCK) ON C.iCharge_ID = RC.iCharge_ID and C.dtrowdeleted is null	
	join ChargeType CT (NOLOCK) ON CT.iChargeType_ID = C.iChargeType_ID and CT.dtrowdeleted is null
	where RC.dtrowdeleted is null
	and RC.iTenant_id = #form.iTenant_id# and RC.iCharge_id = #form.iCharge_ID#
	and rc.dteffectivestart = #Variables.dtEffectiveStart# and rc.dteffectiveend = #Variables.dtEffectiveEnd#
	and rc.iRowStartUser_ID = #isBlank(User,SESSION.USERID)#
	</cfquery>
	<cfif isDefined("SESSION.RDOEmail") and RecurringInfo.bDirectorEmail GT 0>	
		<cfscript>
			if (SESSION.qSelectedHouse.ihouse_id EQ 200) { email='CFDevelopers@alcco.com'; }
			else { email=SESSION.RDOEmail; } 
			message= RecurringInfo.cdescription & " has changed for " & qTenant.cFirstName & ', ' & qTenant.cLastName & ' at ' & SESSION.HouseName & ' ' & "<BR>";
			message= message & "A rate has been added for " & LSCurrencyFormat(form.mAmount);
		</cfscript>
		<cfmail type="HTML" from="TIPS4_Recurring_Change@alcco.com" TO="#email#" BCC="CFDevelopers@alcco.com" SUBJECT="Recurring Rate Addition for #SESSION.HouseName#">#message#</CFMAIL>
	</cfif>
</cfif>
<!---  <cfoutput>hello - #SESSION.RDOEmail# <br/> #message# </cfoutput>
<cfabort> --->
<!--- 1/28/2010 RTS 35227 - get invoicedetail id for later --->
	<cfif Variables.cAppliesToAcctPeriod neq "">
		<cfset thisAcctPeriod = '#Variables.cAppliesToAcctPeriod#'>
	<cfelse>
		<cfset thisAcctPeriod = #DateFormat(SESSION.TIPSMonth,"yyyymm")#>
	</cfif>
	<cfif #InvoiceNumber.iInvoiceMaster_ID# is ''>

		<form action="RecurringCharges/Recurring.cfm#@start" method="post" name="RecurringChargeError">
		<cfoutput>
		<tr>
			<td>The Invoice is missing for period #thisAcctPeriod# Correct this error to continue</td>
		</tr>
		<tr>
			<td><input  type="submit" name="Return" value="Return" /></td>
		</tr>
		</cfoutput>
		</form>
		<cfabort>
	</cfif>
 	<cfquery name="GetInvDtlID" datasource="#application.datasource#">
		select i.iInvoiceDetail_ID,i.iRecurringCharge_ID
		from InvoiceDetail i
		where i.iTenant_ID = #form.iTenant_ID#
		and i.iInvoiceMaster_ID = #InvoiceNumber.iInvoiceMaster_ID#
		and i.iChargeType_ID = #ChargeInfo.iChargeType_ID#
		and i.cAppliesToAcctPeriod = <cfif Variables.cAppliesToAcctPeriod neq "">'#Variables.cAppliesToAcctPeriod#'<cfelse>#DateFormat(SESSION.TIPSMonth,"yyyymm")#</cfif>
		and i.cDescription = '#form.cDescription#'
		and i.dtRowDeleted is null 
	</cfquery>
	<cfdump var="#GetInvDtlID#">
	<cfset IDid = GetInvdtlID.iInvoiceDetail_ID>
<!--- 35227 RTS 1/29/10 update the invoicedetail. --->
	<!---<cfif GetInvDtlID.iRecurringCharge_ID is '' or GetInvDtlID.iRecurringCharge_ID is 'null'>Mamta commented this as the deleting the recurring will not delete the invoicedetail--->
		<cfquery name="UpdateInvDtlWRecChgID" datasource="#application.datasource#" result="UpdateInvDtlWRecChgID">
			update InvoiceDetail 
			set iRecurringCharge_ID = #RecurringInfo.iRecurringCharge_ID#
			where iInvoiceDetail_ID = #IDid#
		</cfquery>
		<cfdump var="#UpdateInvDtlWRecChgID#">
	<!---</cfif>--->

</cftransaction>
 
<cfif SESSION.userid IS 3025 OR SESSION.userid IS 3271>
	<A HREF="Recurring.cfm">Continue</A>
<cfelse>
	<CFLOCATION URL="Recurring.cfm">
</cfif>