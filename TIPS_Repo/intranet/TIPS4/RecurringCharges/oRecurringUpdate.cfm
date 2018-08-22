

<CFTRANSACTION>
<!--- ==============================================================================
Retrieve database TimeStamp
=============================================================================== --->
<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
	SELECT getdate() as TimeStamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>

<!--- =============================================================================================
Concat. Month Day Year for dtEffective Start/End
============================================================================================= --->
<CFSCRIPT>
	dtEffectiveStart = form.monthStart & "/" & form.dayStart & "/" & form.yearStart;
	dtEffectiveStart = CreateODBCDateTime(dtEffectiveStart);
	dtEffectiveEnd = form.monthEnd & "/" & form.dayEnd & "/" & form.yearEnd;
	dtEffectiveEnd = CreateODBCDateTime(dtEffectiveEnd);
</CFSCRIPT>

<CFQUERY NAME="RecurringInfo" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*, RC.mAmount as mAmount
	FROM RecurringCharge RC (NOLOCK)
	JOIN Charges C (NOLOCK) ON C.iCharge_ID = RC.iCharge_ID	
	JOIN ChargeType CT (NOLOCK) ON CT.iChargeType_ID = C.iChargeType_ID
	WHERE iRecurringCharge_ID = #form.iRecurringCharge_ID#
</CFQUERY>

<CFQUERY NAME="qResident" DATASOURCE="#APPLICATION.datasource#">
	select * from tenant where dtrowdeleted is null and itenant_id = #recurringinfo.itenant_id#
</CFQUERY>

<CFSCRIPT>
	if ( (RecurringInfo.bIsRent GT 0 AND RecurringInfo.bIsRentAdjustment EQ '' AND RecurringInfo.bIsDiscount EQ '' AND RecurringInfo.bIsMedicaid EQ '' )
		OR (RecurringInfo.bIsDaily EQ 1) ) {
		iQuantity= DaysInMonth(SESSION.TipsMonth); recqty=1; 
		User=0;
	}
	else { iQuantity=form.iquantity; User=SESSION.UserID; recqty=form.iquantity;}
</CFSCRIPT>


<CFIF Now() GTE dtEffectiveStart AND Now() LTE dtEffectiveEnd> <!--- AND RecurringInfo.bIsMedicaid EQ "" --->
	<CFOUTPUT>
		<!--- ==============================================================================
			Check for a corresponding entry in the invoice detail table
		=============================================================================== --->			
		<CFQUERY NAME = "CheckInvoices" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	iInvoiceDetail_ID
			FROM InvoiceDetail INV (NOLOCK)
			JOIN InvoiceMaster IM (NOLOCK) ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID and inv.dtrowdeleted is null
				and im.dtrowdeleted is null
			WHERE iTenant_ID = #form.iTenant_ID#
			AND	cDescription = '#trim(form.cDescription)#'
			AND	(INV.iRowStartUser_ID IS NULL OR INV.iRowStartUser_ID = 0)
			AND	bFinalized IS NULL AND bMoveInInvoice IS NULL AND bMoveOutInvoice IS NULL
		</CFQUERY>
		
		#CheckInvoices.RecordCount#
		
		<!--- ==============================================================================
		Update the Record if is exists
		=============================================================================== --->
		<CFIF CheckInvoices.RecordCount EQ 1>

			<CFQUERY NAME = "UpdateDetail" DATASOURCE = "#APPLICATION.datasource#">
				UPDATE	InvoiceDetail
				SET		cDescription = '#trim(form.cDescription)#' 
						,mAmount = #form.mAmount# 
						,iQuantity = #iQuantity# 
						,dtRowStart = getDate() 
						,iRowStartUser_ID = #User#
				WHERE	iInvoiceDetail_ID = #CheckInvoices.iInvoiceDetail_ID#
			</CFQUERY>
			
		<CFELSEIF CheckInvoices.RecordCount EQ 0>

			<!--- ==============================================================================
			Retrieve Charge and Charge Type information for this entry
			=============================================================================== --->
			<CFQUERY NAME = "ChargeInfo" DATASOURCE = "#APPLICATION.datasource#">
				SELECT CT.iChargeType_ID, CT.bIsRentAdjustment, CT.bIsRent, CT.bIsDiscount
				FROM Charges C (NOLOCK)
				JOIN ChargeType CT (NOLOCK) ON (C.iChargeType_ID = CT.iChargeType_ID AND CT.dtRowDeleted IS NULL)
				WHERE iCharge_ID = #RecurringInfo.iCharge_ID#
			</CFQUERY>				

			<CFSCRIPT>
				if (ChargeInfo.bIsRent GT 0 AND ChargeInfo.bIsRentAdjustment EQ '' AND ChargeInfo.bIsDiscount EQ '') {
					iQuantity= DaysInMonth(SESSION.TipsMonth); }
				else { iQuantity=1; }
			</CFSCRIPT>

			<!--- ==============================================================================
			Retrieve Current Invoice Master Number
			=============================================================================== --->
			<CFQUERY NAME = "InvoiceNumber" DATASOURCE = "#APPLICATION.datasource#">
				SELECT IM.iInvoiceMaster_ID
				FROM InvoiceMaster IM (NOLOCK)
				JOIN Tenant T (NOLOCK) ON (T.cSolomonKey = IM.cSolomonKey AND T.dtRowDeleted IS NULL)
				WHERE T.iTenant_ID = '#RecurringInfo.iTenant_ID#'
				AND	IM.dtRowDeleted IS NULL AND	IM.bMoveInInvoice IS NULL AND IM.bMoveOutInvoice IS NULL
				AND	bFinalized IS NULL
			</CFQUERY>			
		
			<CFSET cAppliesToAcctPeriod = Year(SESSION.TIPSMonth) & DateFormat((SESSION.TIPSMonth),"mm")>
			
			<!--- ==============================================================================
				If no records exist and it is in the proper effective range.
				Insert a new record in to the Database
			=============================================================================== --->
			<CFQUERY NAME = "InsertDetail" DATASOURCE = "#APPLICATION.datasource#">
				INSERT INTO InvoiceDetail
				(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, dtTransaction, iQuantity, 
					cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart
				)VALUES(
					<CFIF InvoiceNumber.iInvoiceMaster_ID NEQ ""> #InvoiceNumber.iInvoiceMaster_ID#, <CFELSE> ** ERROR No Invoice FOUND **</CFIF> 
					#form.iTenant_ID#,
					#ChargeInfo.iChargeType_ID#,
					<CFIF cAppliesToAcctPeriod NEQ "">'#cAppliesToAcctPeriod#',<CFELSE>#DateFormat(SESSION.TIPSMonth,"yyyymm")#</CFIF>
					<CFIF ChargeInfo.bIsRentAdjustment NEQ ""> #ChargeInfo.bIsRentAdjustment#, <CFELSE> NULL, </CFIF>
					#TimeStamp#,
					#isBlank(iQuantity,1)#,
					'#trim(form.cDescription)#',
					#form.mAmount#,
					<CFIF Len(TRIM(form.cComments)) GT 0>'#TRIM(form.cComments)#',<CFELSE>NULL,</CFIF>
					'#SESSION.AcctStamp#',
					0,
					#TimeStamp#
				)
			</CFQUERY>			
		</CFIF>

	</CFOUTPUT>
</CFIF>
<CFIF RecurringInfo.bisrent neq ''><CFSET form.iquantity=1></CFIF>

<CFIF (IsDefined("AUTH_USER") AND AUTH_USER EQ 'ALC\PaulB') OR 1 EQ 1>
	<CFIF isDefined("SESSION.RDOEmail") AND RecurringInfo.bDirectorEmail GT 0 AND (LSCurrencyFormat(RecurringInfo.mAmount) NEQ LSCurrencyFormat(form.mAmount)) >
		<CFSCRIPT>
			if (SESSION.qSelectedHouse.ihouse_id EQ 200) { email='PBuendia@alcco.com'; }
			else { email=SESSION.RDOEmail; } 
			message= RecurringInfo.cdescription & " has changed for " & qResident.cFirstName & ', ' & qResident.cLastName & ' at ' & SESSION.HouseName & ' ' & "<BR>";
			message= message & "The rate has changed from " & LSCurrencyFormat(RecurringInfo.mAmount) & " to " & LSCurrencyFormat(form.mAmount);
		</CFSCRIPT>
		<CFMAIL TYPE ="HTML" FROM="TIPS4_Recurring_Change@alcco.com" TO="#email#" BCC="pbuendia@alcco.com" SUBJECT="Recurring Rate Change for #SESSION.HouseName#">#message#</CFMAIL>
	</CFIF>
</CFIF>

<!--- ==============================================================================
Update the Recurring Table
=============================================================================== --->	
<CFQUERY NAME="UpdateRecurring" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE	RecurringCharge
	SET		
		<CFIF form.iTenant_ID NEQ "">iTenant_ID = #form.iTenant_ID#,<CFELSE>iTenant_ID = NULL,</CFIF>
		<CFIF form.iCharge_ID NEQ "">iCharge_ID = #form.iCharge_ID#,<CFELSE>iCharge_ID = NULL,</CFIF>
		<CFIF Variables.dtEffectiveStart NEQ "//">dtEffectiveStart = #Variables.dtEffectiveStart#,<CFELSE>dtEffectiveStart = NULL,</CFIF>
		<CFIF Variables.dtEffectiveEnd NEQ "//">dtEffectiveEnd = #Variables.dtEffectiveEnd#,<CFELSE>dtEffectiveEnd = NULL,</CFIF>
		<CFIF recqty NEQ "">iQuantity = #recqty#,<CFELSE>iQuantity = 1,</CFIF>
		<CFIF form.cDescription NEQ "">cDescription = '#trim(form.cDescription)#',<CFELSE>cDescription = NULL,</CFIF>
		<CFIF form.mAmount NEQ "">mAmount =  #form.mAmount#,<CFELSE>mAmount = NULL,</CFIF>
		<CFIF form.cComments NEQ "">cComments = '#form.cComments#',<CFELSE>cComments = NULL,</CFIF>
		dtAcctStamp = #CreateODBCDateTime(SESSION.AcctStamp)#,
		iRowStartUser_ID = #SESSION.UserID#,
		dtRowStart = GetDate()
	WHERE	iRecurringCharge_ID = #form.iRecurringCharge_ID#
</CFQUERY>

</CFTRANSACTION>


<CFIF (IsDefined("AUTH_USER") AND AUTH_USER EQ 'ALC\PaulB')>
	<A HREF="Recurring.cfm"> Continue </A>
<CFELSE>
	<CFLOCATION URL="Recurring.cfm">
</CFIF>