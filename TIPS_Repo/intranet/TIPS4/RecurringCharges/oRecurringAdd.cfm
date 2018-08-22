

<CFTRANSACTION>
<!--- Initialize User Field --->
<CFSET User=SESSION.USERID>

<!--- ==============================================================================
Retrieve database TimeStamp
=============================================================================== --->
<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
	SELECT	getdate() as TimeStamp
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
	
		<CFIF (TimeStamp GTE dtEffectiveStart AND TimeStamp LTE dtEffectiveEnd) 
			OR (SESSION.TipsMonth GTE dtEffectiveStart AND SESSION.TipsMonth LTE dtEffectiveEnd)>
			<CFOUTPUT>
			
			<!--- ==============================================================================
			Retrieve Tenant Information
			=============================================================================== --->
			<CFQUERY NAME="qTenant" DATASOURCE="#APPLICATION.datasource#">
				SELECT	* FROM Tenant T WHERE T.dtRowDeleted IS NULL AND T.iTenant_ID = #trim(form.iTenant_ID)#
			</CFQUERY>
			
			<!--- ==============================================================================
			Check for Duplicate Record for this recurring in the database
			=============================================================================== --->			
			<CFQUERY NAME = "CheckRecurr" DATASOURCE = "#APPLICATION.datasource#">
				SELECT	*
				FROM 	InvoiceDetail INV
				JOIN	InvoiceMaster IM	ON	(INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND IM.dtRowDeleted IS NULL)
				WHERE	INV.dtRowDeleted IS NULL
				AND	bFinalized IS NULL AND bMoveInInvoice IS NULL AND bMoveOutInvoice IS NULL
				AND INV.iTenant_ID = #form.iTenant_ID#
				AND INV.cDescription = '#form.cDescription#'
				AND	(INV.iRowStartUser_ID IS NULL OR INV.iRowStartUser_ID = 0)
			</CFQUERY>
			
			
			<!--- ==============================================================================
			Retrieve Charge and Charge Type information for this entry
			=============================================================================== --->
			<CFQUERY NAME="ChargeInfo" DATASOURCE="#APPLICATION.datasource#">
				SELECT	CT.iChargeType_ID, CT.bIsRentAdjustment, CT.bIsRent, CT.bIsDiscount, 
						CT.bIsMedicaid, CT.bIsDaily
				FROM	Charges C
				JOIN	ChargeType CT	ON (C.iChargeType_ID = CT.iChargeType_ID AND CT.dtRowDeleted IS NULL)
				WHERE	iCharge_ID = #form.iCharge_ID#
			</CFQUERY>
			
			<CFSCRIPT>
				if ( (ChargeInfo.bIsRent GT 0 AND ChargeInfo.bIsRentAdjustment EQ '' AND ChargeInfo.bIsDiscount EQ '' AND ChargeInfo.bIsMedicaid EQ '')
					OR (ChargeInfo.bIsDaily EQ 1) ) {
					form.iQuantity= DaysInMonth(SESSION.TipsMonth); recqty=1; User=0;}
				else { iQuantity=form.iquantity; User=SESSION.UserID; recqty=form.iquantity;}
			</CFSCRIPT>
			
			<!--- ==============================================================================
			Retrieve Current Invoice Master Number
			=============================================================================== --->
			<CFQUERY NAME = "InvoiceNumber" DATASOURCE = "#APPLICATION.datasource#">
				SELECT	IM.iInvoiceMaster_ID
				FROM InvoiceMaster IM
				JOIN Tenant T ON (T.cSolomonKey = IM.cSolomonKey AND T.dtRowDeleted IS NULL)
				WHERE IM.dtRowDeleted IS NULL AND IM.bMoveInInvoice IS NULL 
				AND IM.bMoveOutInvoice IS NULL AND bFinalized IS NULL AND T.cSolomonKey = '#qTenant.cSolomonKey#'
			</CFQUERY>
			
			<CFSET cAppliesToAcctPeriod = Year(SESSION.TIPSMonth) & DateFormat((SESSION.TIPSMonth),"mm")>
			
			<CFIF CheckRecurr.RecordCount EQ 0>
				<!--- ==============================================================================
					If no records exist and it is in the proper effective range.
					Insert a new record in to the Database
				=============================================================================== --->
				<CFQUERY NAME = "InsertDetail" DATASOURCE = "#APPLICATION.datasource#">
					INSERT INTO InvoiceDetail
					(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, dtTransaction, 
						iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart )
					VALUES
					(
						<CFIF InvoiceNumber.iInvoiceMaster_ID NEQ ""> #InvoiceNumber.iInvoiceMaster_ID#, <CFELSE> ** ERROR No Invoice FOUND **</CFIF> 
						#form.iTenant_ID#,
						#ChargeInfo.iChargeType_ID#,
						<CFIF Variables.cAppliesToAcctPeriod NEQ "">'#Variables.cAppliesToAcctPeriod#',<CFELSE>#DateFormat(SESSION.TIPSMonth,"yyyymm")#</CFIF>
						<CFIF ChargeInfo.bIsRentAdjustment NEQ ""> #ChargeInfo.bIsRentAdjustment#, <CFELSE> NULL, </CFIF>
						#TimeStamp#,
						#form.iQuantity#,
						'#form.cDescription#',
						#form.mAmount#,
						<CFIF Len(TRIM(form.cComments)) GT 0>'#TRIM(form.cComments)#',<CFELSE>NULL,</CFIF>
						'#SESSION.AcctStamp#',
						0,
						#TimeStamp#
					)
				</CFQUERY>
				
			<CFELSE>
				<!--- ==============================================================================
					If a record already exists (ie. back button) then update the record.
				=============================================================================== --->
				<CFQUERY NAME = "UpdateDetail" DATASOURCE = "#APPLICATION.datasource#">
					UPDATE	InvoiceDetail
					SET		cDescription = '#trim(form.cDescription)#',
							mAmount = #form.mAmount#,
							iQuantity = #form.iQuantity#,
							dtRowStart = #TimeStamp#,
							iRowStartUser_ID = 0
					WHERE	iInvoiceDetail_ID = #CheckRecurr.iInvoiceDetail_ID#
				</CFQUERY>
			</CFIF>
		</CFOUTPUT>
	</CFIF>
	<!--- ==============================================================================
		Add the new Charge to the Recurring Table
	=============================================================================== --->
	<CFQUERY NAME = "AddRecurring" DATASOURCE = "#APPLICATION.datasource#">
		INSERT INTO RecurringCharge
		(	iTenant_ID, iCharge_ID, dtEffectiveStart, dtEffectiveEnd, iQuantity, cDescription, mAmount, cComments, 
			dtAcctStamp, iRowStartUser_ID, dtRowStart
		)VALUES(
			<CFIF form.iTenant_ID NEQ "">	#form.iTenant_ID#,	<CFELSE>	NULL,	</CFIF>
			<CFIF form.iCharge_ID NEQ "">	#form.iCharge_ID#,	<CFELSE>	NULL,	</CFIF>
			<CFIF Variables.dtEffectiveStart NEQ "//">	#Variables.dtEffectiveStart#,	<CFELSE>	NULL,	</CFIF>
			<CFIF Variables.dtEffectiveEnd NEQ "//">	#Variables.dtEffectiveEnd#,		<CFELSE>	NULL,	</CFIF>
			<CFIF isDefined("recqty") AND recqty NEQ "">#recqty#,<CFELSE>1,</CFIF>
			<CFIF form.cDescription NEQ ""> '#form.cDescription#',	<CFELSE> NULL, </CFIF>
			<CFIF form.mAmount NEQ ""> #form.mAmount#, <CFELSE>	NULL, </CFIF>
			<CFIF form.cComments NEQ ""> '#form.cComments#', <CFELSE> NULL, </CFIF>
			#CreateODBCDateTime(SESSION.AcctStamp)#,
			#isBlank(User,SESSION.USERID)#,
			#TimeStamp#
		)
	</CFQUERY>

<CFIF (IsDefined("AUTH_USER") AND AUTH_USER EQ 'ALC\PaulB') OR 1 EQ 1>
	<CFQUERY NAME="RecurringInfo" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*, RC.mAmount as mAmount
		FROM RecurringCharge RC (NOLOCK)
		JOIN Charges C (NOLOCK) ON C.iCharge_ID = RC.iCharge_ID and. C.dtrowdeleted is null	
		JOIN ChargeType CT (NOLOCK) ON CT.iChargeType_ID = C.iChargeType_ID and CT.dtrowdeleted is null
		WHERE RC.dtrowdeleted is null
		and RC.iTenant_id = #form.iTenant_id# and RC.iCharge_id = #form.iCharge_ID#
		and rc.dteffectivestart = #Variables.dtEffectiveStart# and rc.dteffectiveend = #Variables.dtEffectiveEnd#
		and rc.iRowStartUser_ID = #isBlank(User,SESSION.USERID)#
	</CFQUERY>
	<CFIF isDefined("SESSION.RDOEmail") AND RecurringInfo.bDirectorEmail GT 0>	
		<CFSCRIPT>
			if (SESSION.qSelectedHouse.ihouse_id EQ 200) { email='PBuendia@alcco.com'; }
			else { email=SESSION.RDOEmail; } 
			message= RecurringInfo.cdescription & " has changed for " & qTenant.cFirstName & ', ' & qTenant.cLastName & ' at ' & SESSION.HouseName & ' ' & "<BR>";
			message= message & "A rate has been added for " & LSCurrencyFormat(form.mAmount);
		</CFSCRIPT>
		<CFMAIL TYPE ="HTML" FROM="TIPS4_Recurring_Change@alcco.com" TO="#email#" BCC="pbuendia@alcco.com" SUBJECT="Recurring Rate Addition for #SESSION.HouseName#">#message#</CFMAIL>
	</CFIF>
</CFIF>
	
</CFTRANSACTION>
<CFIF SESSION.USERID IS 3025><A HREF="Recurring.cfm">Continue</A><CFELSE><CFLOCATION URL="Recurring.cfm"></CFIF>