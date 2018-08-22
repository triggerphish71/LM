<!----------------------------------------------------------------------------------------------
| DESCRIPTION   AddOtherCharges.cfm                                                            |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| Parameter Name                                                                               |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     | |----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|S Farmer    | 2017-01-12 | Add Details for populating iDaysBilled on InvoiceDetail record     |
----------------------------------------------------------------------------------------------->

<CFIF SESSION.USERID IS 3025>
	<CFOUTPUT> #form.fieldnames#</CFOUTPUT>
</CFIF>


<CFOUTPUT>

<CFTRANSACTION>

<!--- ==============================================================================
	Retrieve Tenant Information
=============================================================================== --->
	<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*
		FROM	Tenant	T
		JOIN	TenantState TS	ON (T.iTenant_ID = TS.iTenant_ID AND TS.dtRowDeleted IS NULL)
		WHERE	T.iTenant_ID = #form.iTenant_ID#
		AND		T.dtRowDeleted IS NULL
	</CFQUERY>
		
<!--- ==============================================================================
	Retrieve the Charge and ChargeType Information
=============================================================================== --->
	<CFQUERY NAME="Charge" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*
		FROM	Charges C		
		JOIN	ChargeType CT 	
		ON 		(C.iChargeType_ID = CT.iChargeType_ID 
				AND C.dtRowDeleted IS NULL AND CT.dtRowDeleted IS NULL)
		<CFIF IsDefined("form.OtheriCharge_ID")>
			WHERE	C.iCharge_ID = #form.OtheriCharge_ID#
		<CFELSE>	
			WHERE	C.iCharge_ID = 0
		</CFIF>
	</CFQUERY>
	
<!--- ==============================================================================
	Check for an Existing Move Out Invoice
=============================================================================== --->
	<CFQUERY NAME = "InvoiceCheck" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	*
		FROM	InvoiceMaster IM
		JOIN	InvoiceDetail INV	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
		WHERE	IM.cSolomonKey = '#Tenant.cSolomonKey#'
		AND		INV.iTenant_ID = #form.iTenant_ID#
		AND		bMoveOutInvoice IS NOT NULL
	</CFQUERY>

<CFIF InvoiceCheck.RecordCount GT 0>	

<!--- ==============================================================================
Deleted all prior detail record before writing new records
=============================================================================== --->
	<CFQUERY NAME = "DeleteDetail" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE	InvoiceDetail
		SET		iRowDeletedUser_ID 	=  	#SESSION.UserID#,
				dtRowDeleted 		=	GetDate()
		WHERE	iInvoiceMaster_ID = #InvoiceCheck.iInvoiceMaster_ID#
	</CFQUERY>
	
</CFIF>
	
<!--- ==============================================================================
	If there no available invoice. 
	We get the next number from house number control and update the invoice master table
=============================================================================== --->
<CFIF InvoiceCheck.RecordCount LTE 0>

<!--- ------------------------------------------------------------------------------
	Retrieve the next invoice number
------------------------------------------------------------------------------- --->		
		<CFQUERY NAME = "GetNextInvoice" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	iNextInvoice
			FROM	HouseNumberControl
			WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		</CFQUERY>
		
		<CFSET HouseNumber = #SESSION.HouseNumber#>	
		<CFSET iInvoiceNumber = '#Variables.HouseNumber#'&#GetNextInvoice.iNextInvoice#>
		
	
<!--- ------------------------------------------------------------------------------
	Calculate and Record a new Invoice Number
------------------------------------------------------------------------------- --->	
		<CFQUERY NAME="NewInvoice" DATASOURCE="#APPLICATION.datasource#">
			INSERT INTO 	InvoiceMaster
							(
								iInvoiceNumber, 
								cSolomonKey, 
								bMoveOutInvoice, 
								bFinalized, 
								cAppliesToAcctPeriod, 
								cComments, 
								dtAcctStamp, 
								iRowStartUser_ID, 
								dtRowStart
							)VALUES(
								'#Variables.iInvoiceNumber#',
								'#Tenant.cSolomonKey#',
								1,
								NULL,
								<CFSET AppliesTo = #Year(SESSION.TipsMonth)# & #DateFormat(SESSION.TipsMonth, "mm")#>
								'#Variables.AppliesTo#',
								<CFIF IsDefined("form.InvoiceComments")>
									'#TRIM(form.InvoiceComments)#',
								</CFIF>
								#CreateODBCDateTime(SESSION.AcctStamp)#,
								#SESSION.UserID#,
								GETDATE()
							)
		</CFQUERY>
		

		<CFSET iNewNextInvoice = #GetNextInvoice.iNextInvoice# + 1>
		
		
<!--- ------------------------------------------------------------------------------
	Increment the next Invoice Number in the HouseNumberControl Table
------------------------------------------------------------------------------- --->
		<CFQUERY NAME = "HouseNumberControl" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	HouseNumberControl
			SET		iNextInvoice 	= #Variables.iNewNextInvoice#
			WHERE	iHouse_ID 		= #SESSION.qSelectedHouse.iHouse_ID#
		</CFQUERY>

<!--- ------------------------------------------------------------------------------
	Retrieve the Invoice Master ID that was created above
------------------------------------------------------------------------------- --->		
		<CFQUERY NAME = "NewMasterID" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	iInvoiceMaster_ID
			FROM	InvoiceMaster
			WHERE	cSolomonKey = '#Tenant.cSolomonKey#'
			AND		bMoveOutInvoice IS NOT NULL
			AND		bFinalized IS NULL
		</CFQUERY>
		
		<CFSET Variables.iInvoiceMaster_ID = #NewMasterID.iInvoiceMaster_ID#>
		
<CFELSE>
		
	<CFSET iInvoiceMaster_ID = #InvoiceCheck.iInvoiceMaster_ID#>
	<CFSET iInvoiceNumber = '#InvoiceCheck.iInvoiceNumber#'>			
		
	<CFIF IsDefined("form.InvoiceComments")>
		<CFQUERY NAME = "UpdateInvoiceComments" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	InvoiceMaster 
			SET		cComments = '#TRIM(form.InvoiceComments)#'
			WHERE	iInvoiceMaster_ID = #InvoiceCheck.iInvoiceMaster_ID#
		</CFQUERY>
	</CFIF>
		
</CFIF>
		
		
<!--- ------------------------------------------------------------------------------
	Insert a record into the invoice detail for the damages.
------------------------------------------------------------------------------- --->
<CFIF IsDefined("form.DamageAmount") AND form.DamageAmount GT 0>
	<CFQUERY NAME = "Damages"	DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO 	InvoiceDetail
			(
				iInvoiceMaster_ID, 
				iTenant_ID, 
				iChargeType_ID, 
				cAppliesToAcctPeriod, 
				bIsRentAdj, 
				dtTransaction, 
				iQuantity, 
				cDescription, 
				mAmount, 
				cComments, 
				dtAcctStamp, 
				iRowStartUser_ID, 
				dtRowStart,
				iDaysBilled
			)VALUES(
				#iInvoiceMaster_ID#,
				#form.iTenant_ID#,
				36,
				<CFSET AppliesTo = YEAR(SESSION.TIPSMONTH) & DateFormat(SESSION.TIPSMONTH,"mm")>
				'#APPLIESTO#',
				NULL,
				GetDate(),
				1, 
				'Damages',
				#TRIM(form.DamageAmount)#,
				'#form.DamageComments#' & 'B',
				#CreateODBCDateTime(SESSION.AcctStamp)#,
				#SESSION.UserID#,
				GetDate() ,
				1
			)
		
	</CFQUERY>
</CFIF>		
		

<CFIF IsDefined("form.OtherAmount") AND form.OtherAmount GT 0>
<!--- ------------------------------------------------------------------------------
	Insert a record into the invoice detail for the other charges
------------------------------------------------------------------------------- --->
	<CFQUERY NAME = "Other"	DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO 	InvoiceDetail
			(
				iInvoiceMaster_ID, 
				iTenant_ID, 
				iChargeType_ID, 
				cAppliesToAcctPeriod, 
				bIsRentAdj, 
				dtTransaction, 
				iQuantity, 
				cDescription, 
				mAmount, 
				cComments, 
				dtAcctStamp, 
				iRowStartUser_ID, 
				dtRowStart,
				iDaysBilled
			)VALUES(
				#Variables.iInvoiceMaster_ID#, 
				#form.iTenant_ID#, 
				#Charge.iChargeType_ID#, 
				<CFSET Appliesto = #YEAR(SESSION.TIPSMONTH)# & #DateFormat(SESSION.TIPSMONTH,"mm")#>
				'#AppliesTo#', 
				NULL, 
				GetDate(), 
				#form.OtheriQuantity#, 
				'#form.OthercDescription#', 
				#Trim(NumberFormat(form.OtherAmount,"99999999.99"))#, 
				<CFIF IsDefined("form.OtherComments") AND form.OtherComments NEQ "">
					'#form.OtherComments#' & 'A', 
				<CFELSE>
					NULL,
				</CFIF>
				#CreateODBCDateTime(SESSION.AcctStamp)#,
				#SESSION.UserID#,
				GetDate() ,
				#form.OtheriQuantity#
			)
		
	</CFQUERY>		
</CFIF>

	
</CFTRANSACTION>	
	

<CFIF SESSION.UserID IS 3025>
	<A HREF = "MoveOutForm.cfm?ID=#form.iTenant_ID#&stp=#url.stp#&rsn=#url.rsn#">Continue</A>
<CFELSE>
	<CFLOCATION URL="MoveOutForm.cfm?ID=#form.iTenant_ID#&stp=#url.stp#&rsn=#url.rsn#" ADDTOKEN="No">
</CFIF>
</CFOUTPUT>