<!--- *******************************************************************************
Name:			MoveOutUpdate.cfm
Process:		Update Tenants MoveOut Information

Called by: 		MoveOutForm..cfm
Calls/Submits:	MoveOutFormSummary.cfm
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Paul Buendia            03/05/2002      File Created
Steven Farmer			09/13/2012		TPG Collectors Database changes added 'SB' & 'PP' to doctype
|S Farmer    | 2017-01-12 | Add Details for populating iDaysBilled on InvoiceDetail record     |
******************************************************************************** --->

<CFOUTPUT>
<!--- ==============================================================================
Set variable for current tips month for use within this page
=============================================================================== --->
<CFSET CurrPer = #DateFormat(SESSION.TIPSMonth,"yyyymm")#>

<!--- ==============================================================================
Retrieve Tenant Information
=============================================================================== --->
<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	Tenant	T
			JOIN	TenantState TS	 ON	T.iTenant_ID = TS.iTenant_ID		
			JOIN	ResidencyType RT ON	RT.iResidencyType_ID = TS.iResidencyType_ID
			LEFT OUTER JOIN	AptAddress	AD	 ON (TS.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
	WHERE	T.iTenant_ID = #form.iTenant_ID#
	AND		T.dtRowDeleted IS NULL
	AND		TS.dtRowDeleted IS NULL
</CFQUERY>


<!--- ==============================================================================
Check for an Existing Move Out Invoice
=============================================================================== --->
<CFQUERY NAME="InvoiceCheck" DATASOURCE="#APPLICATION.datasource#">
	SELECT	Distinct IM.*
	FROM	InvoiceMaster IM
	LEFT OUTER JOIN	InvoiceDetail INV	ON (INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND INV.iTenant_ID = #form.iTenant_ID#)
	WHERE	IM.cSolomonKey = '#Tenant.cSolomonKey#'
	AND		bMoveOutInvoice IS NOT NULL
	AND		IM.dtRowDeleted IS NULL
</CFQUERY>
	
<CFIF InvoiceCheck.RecordCount GT 0>	
	<!--- ==============================================================================
	Deleted all prior system detail records before writing new records
	=============================================================================== --->
	<CFQUERY NAME = "DeleteDetail" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE	InvoiceDetail
		SET		iRowDeletedUser_ID 	=  	#SESSION.UserID#, dtRowDeleted = GetDate()
		WHERE	iInvoiceMaster_ID = #InvoiceCheck.iInvoiceMaster_ID#
		AND		iTenant_ID = #Tenant.iTenant_ID#
		AND		dtRowDeleted IS NULL
		AND		iRowStartUser_ID = 0
	</CFQUERY>
</CFIF>
	
<!--- ==============================================================================
	If there no available invoice. 
	We get the next number from house number control and update the invoice master table
=============================================================================== --->
<CFIF InvoiceCheck.RecordCount LTE 0>
		<!--- ==============================================================================
		Retrieve the next invoice number
		=============================================================================== --->
		<CFQUERY NAME = "GetNextInvoice" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	iNextInvoice
			FROM	HouseNumberControl
			WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND		dtRowDeleted IS NULL
		</CFQUERY>
		
		<CFSET HouseNumber = #SESSION.HouseNumber#>	
		<CFSET iInvoiceNumber = '#Variables.HouseNumber#'&#GetNextInvoice.iNextInvoice#>
		
		<!--- ==============================================================================
		Retrieve the start date of current invoice
		=============================================================================== --->
		<CFQUERY NAME = "CurrentInvoice" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	IM.iInvoiceMaster_ID, IM.dtInvoiceStart, IM.dtInvoiceEnd
			FROM	InvoiceMaster IM
					JOIN	InvoiceDetail INV	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
			WHERE	bFinalized IS NULL
			AND		bMoveOutInvoice IS NULL
			AND		IM.dtRowDeleted IS NULL
			AND		INV.iTenant_ID = #Tenant.iTenant_ID#
			AND		IM.cSolomonKey = '#Tenant.cSolomonKey#'
			AND		IM.cAppliesToAcctPeriod = '#CurrPer#'
		</CFQUERY>		
		
		<!--- ==============================================================================
		Calculate and Record a new Invoice Number
		=============================================================================== --->
		<CFQUERY NAME = "NewInvoice" DATASOURCE = "#APPLICATION.datasource#">
			INSERT INTO InvoiceMaster
				(	iInvoiceNumber, cSolomonKey, 
					bMoveOutInvoice, bFinalized, 
					cAppliesToAcctPeriod, cComments, 
					dtAcctStamp, dtInvoiceStart, 
					iRowStartUser_ID, 
					dtRowStart
				)VALUES(
					<CFSET iInvoiceNumber = '#Variables.iInvoiceNumber#' & 'MO'>
					'#Variables.iInvoiceNumber#', '#Tenant.cSolomonKey#',
					1, NULL,
					<CFSET AppliesTo = #Year(SESSION.TipsMonth)# & #DateFormat(SESSION.TipsMonth, "mm")#>
					'#Variables.AppliesTo#',
					<CFIF IsDefined("form.InvoiceComments")>'#TRIM(form.InvoiceComments)#',</CFIF>
					#CreateODBCDateTime(SESSION.AcctStamp)#,
					<CFIF CurrentInvoice.RecordCount GT 0 AND CurrentInvoice.dtInvoiceStart NEQ ""> '#CurrentInvoice.dtInvoiceStart#', <CFELSE> NULL, </CFIF>
					#SESSION.UserID#,
					GETDATE()
				)
		</CFQUERY>
		
		<CFSET iNewNextInvoice = #GetNextInvoice.iNextInvoice# + 1>
		
		<!--- ==============================================================================
		Increment the next Invoice Number in the HouseNumberControl Table
		=============================================================================== --->
		<CFQUERY NAME = "HouseNumberControl" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	HouseNumberControl
			SET		iNextInvoice 	= #Variables.iNewNextInvoice#
			WHERE	iHouse_ID 		= #SESSION.qSelectedHouse.iHouse_ID#
		</CFQUERY>

		<!--- ==============================================================================
		Retrieve the Invoice Master ID that was created above
		=============================================================================== --->
		<CFQUERY NAME = "NewMasterID" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	iInvoiceMaster_ID, dtInvoiceStart, dtInvoiceEnd
			FROM	InvoiceMaster
			WHERE	cSolomonKey ='#Tenant.cSolomonKey#'
			AND		bMoveOutInvoice IS NOT NULL
			AND		bFinalized IS NULL
			AND		dtRowDeleted IS NULL
		</CFQUERY>
		
		<CFSET Variables.iInvoiceMaster_ID = #NewMasterID.iInvoiceMaster_ID#>
		<CFSET dtInvoiceStart = #NewMasterID.dtInvoiceStart#>
		
<CFELSE>
		
	<CFSET iInvoiceMaster_ID = #InvoiceCheck.iInvoiceMaster_ID#>
	<CFSET iInvoiceNumber = '#InvoiceCheck.iInvoiceNumber#'>			
	<CFSET dtInvoiceStart = #InvoiceCheck.dtInvoiceStart#>
		
	<CFIF IsDefined("form.InvoiceComments")>
		<CFQUERY NAME = "UpdateInvoiceComments" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	InvoiceMaster 
			<CFIF TRIM(form.InvoiceComments) NEQ ""> SET	cComments = '#TRIM(form.InvoiceComments)#' <CFELSE> SET	cComments = NULL </CFIF>
			WHERE	iInvoiceMaster_ID = #InvoiceCheck.iInvoiceMaster_ID#
		</CFQUERY>
	</CFIF>
		
</CFIF>

<!--- ==============================================================================
Conctenate Dates into one variable
=============================================================================== --->
<CFSET ChargeDate = #form.CHARGEMONTH# & "/" & #form.CHARGEDAY# & "/" & #form.CHARGEYEAR#>
<CFSET NoticeDate = #form.NOTICEMONTH# & "/" & #form.NOTICEDAY# & "/" & #form.NOTICEYEAR#>
<CFSET MoveOutDate = #form.MOVEOUTMONTH# & "/" & #form.MOVEOUTDAY# & "/" & #form.MOVEOUTYEAR#>
<CFSET ChargeMonthCompareDate = #form.CHARGEMONTH# & "/" & '01' & "/" & #form.CHARGEYEAR#>

<!--- ==============================================================================
Convert dates into database date times
=============================================================================== --->
<CFSET dtChargeThrough=#CreateODBCDateTime(ChargeDate)#>
<CFSET dtNotice=#CreateODBCDateTime(NoticeDate)#>
<CFSET dtMoveOut=#CreateODBCDateTime(MoveOutDate)#>
<CFSET dtChargeMonthCompareDate=#CreateODBCDateTime(ChargeMonthCompareDate)#>


<!--- ==============================================================================
Days to Charge
=============================================================================== --->
<CFSET DaysToCharge = #Variables.dtChargeThrough# - #Tenant.dtMoveIn# +1>	

<!--- ==============================================================================
If this person is in a moved out state determine when their state changed
(used to determine the TIPS period that the house was in when their state changed.
This is important to know how many and which months to credit back.
** 
	IF the period is not equal to the current period we set a Variable called 
	TIPSMonth equal to the historical Tips month. Otherwise we set the TIPSMonth
	variable to the current month 
**
=============================================================================== --->
<CFIF Tenant.iTenantStateCode_ID EQ 3>
	<CFQUERY NAME="qStateChanged" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*
		FROM	P_TenantState
		WHERE	iTenant_ID = #form.iTenant_ID#
		AND	iTenantStateCode_ID = 3
		AND	dtRowStart = (	SELECT Min(dtRowStart) 
							FROM 	P_TenantState 
							WHERE 	iTenantStateCode_ID = 3 
							AND	iTenant_ID = #form.iTenant_ID#)
	</CFQUERY>

	<CFIF qStateChanged.RecordCount EQ 0>
		<!--- ==============================================================================
		If no Records found over write last record set and check current table
		=============================================================================== --->
		<CFQUERY NAME="qStateChanged" DATASOURCE="#APPLICATION.datasource#">
			SELECT	*
			FROM	TenantState
			WHERE	iTenant_ID = #form.iTenant_ID#
			AND		iTenantStateCode_ID = 3
		</CFQUERY>
	</CFIF>
	
	<!--- ==============================================================================
	Retrieve the TIPS Month when this tenant was first finalized as moved out
	=============================================================================== --->
	<CFQUERY NAME="qHousePeriod" DATASOURCE="#APPLICATION.datasource#">
			SELECT	dtCurrentTipsMonth
			FROM	P_HouseLog
			WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND		dtRowStart <= cast('#qStateChanged.dtRowStart#' as datetime)
			AND		dtRowEnd >= cast('#qStateChanged.dtRowStart#' as datetime)
			ORDER BY dtCurrentTipsMonth desc
	</CFQUERY>
	
	<CFIF qHousePeriod.RecordCount EQ 0>
		<!--- ==============================================================================
		If not Record in history look up in current table
		=============================================================================== --->
		<CFQUERY NAME="qHousePeriod" DATASOURCE="#APPLICATION.datasource#">
				SELECT	dtCurrentTipsMonth
				FROM	HouseLog
				WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
				AND	dtRowStart <= cast('#qStateChanged.dtRowStart#' as datetime)
				ORDER BY dtCurrentTipsMonth desc
		</CFQUERY>	
	</CFIF>
	<CFSET TIPSMonth = #qHousePeriod.dtCurrentTIPSMonth#>
<CFELSE>
	<CFSET TIPSMonth = #SESSION.TIPSMonth#>
</CFIF>

<!--- ==============================================================================
DEBUG
=============================================================================== --->
#TIPSMonth# = Current TIPS Period<BR>
#dtChargeThrough# = ChargeThrough Date<BR><BR>

<!--- ==============================================================================
Retrieve the Respite Daily Rate
(THERE ARE NO MONTHY RATES FOR RESPITE - Corporate Rule)
=============================================================================== --->
<CFQUERY NAME="qRespiteRate" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	Charges C
			JOIN	ChargeType CT ON C.iChargeType_ID = CT.iChargeType_ID AND CT.dtRowDeleted IS NULL
	WHERE	C.dtRowDeleted IS NULL
	AND		C.iResidencyType_ID = 3
	AND		C.iHouse_ID = #Tenant.iHouse_ID#
	<!--- AND	C.iAptType_ID = #Tenant.iAptType_ID# --->
	AND		(C.iOccupancyPosition = #Occupancy# OR C.iOccupancyPosition IS NULL)
</CFQUERY>	

<!--- ==============================================================================
Retrieve ChargeType where GL account if for current period rent
=============================================================================== --->
<CFQUERY NAME="GetGlAccount" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	ChargeType
	WHERE	dtRowDeleted IS NULL
	AND		bIsRent IS NOT NULL
	AND		bIsDaily IS NULL
	
		<CFIF Tenant.iResidencyType_ID EQ 1>
			AND	cGLAccount = 3010
		<CFELSEIF Tenant.iResidencyType_ID EQ 2>
			AND	cGLAccount = 3011
		</CFIF>
		
</CFQUERY>

<!--- ==============================================================================
	<CFIF Variables.MonthDiff GT 0>	
		<CFIF Tenant.iResidencyType_ID EQ 1>
			AND	cGLAccount = 3010
		<CFELSEIF Tenant.iResidencyType_ID EQ 2>
			AND	cGLAccount = 3011
		</CFIF>
	<CFELSE>
		<CFIF Tenant.iResidencyType_ID EQ 1>
			AND	cGLAccount = 3014
		<CFELSEIF Tenant.iResidencyType_ID EQ 2>
			AND	cGLAccount = 3015
		</CFIF>
	</CFIF>
=============================================================================== --->
		
<!--- ==============================================================================
Record Prorated Rent
=============================================================================== --->
<CFQUERY NAME="ProratedRent" DATASOURCE="#APPLICATION.datasource#">
	INSERT INTO InvoiceDetail
	(	iInvoiceMaster_ID, iTenant_ID, 
		iChargeType_ID, cAppliesToAcctPeriod, 
		bIsRentAdj, dtTransaction, 
		iQuantity, cDescription, 
		mAmount, cComments, 
		dtAcctStamp, 
		iRowStartUser_ID, 
		dtRowStart,
		iDaysBilled				
	)VALUES(
		#Variables.iInvoiceMaster_ID#, #form.iTenant_ID#,
		#GetGLAccount.iChargeType_ID#,
		'#DateFormat(dtChargeThrough,"yyyymm")#',
		1, GetDate(),
		#TRIM(Variables.DaysToCharge)#, 
		'Prorated Rent for #MonthAsString(Month(dtChargeThrough))#',
		#CalcProrate#,
		NULL,
		'#SESSION.AcctStamp#',
		0,
		GetDate() ,
		#TRIM(Variables.DaysToCharge)#
	)
</CFQUERY>			


<!--- ==============================================================================
Concatenate Phone Numbers for writing to database
=============================================================================== --->
<CFSET PHONENUMBER1 = #TRIM(form.AREACODE1)# & #TRIM(form.PREFIX1)# & #TRIM(form.NUMBER1)#>
<CFSET PHONENUMBER2 = #TRIM(form.AREACODE2)# & #TRIM(form.PREFIX2)# & #TRIM(form.NUMBER2)#>


<CFTRANSACTION>
	<!--- ==============================================================================
	Retrieve Contact information
	=============================================================================== --->
	<CFQUERY NAME="Contact" DATASOURCE="#APPLICATION.datasource#">
		SELECT	C.*
		FROM	LinkTenantContact LTC
				JOIN Contact C	ON LTC.iContact_ID = C.iContact_ID		
		WHERE	C.dtRowDeleted IS NULL
		AND		LTC.dtRowDeleted IS NULL
		AND		iTenant_ID = #form.iTenant_ID#
		AND  	bIsPayer IS NOT NULL
	</CFQUERY>
	
<!--- ==============================================================================
Update the TenantState of the Chosen Tenant (if the state is not moved out)
=============================================================================== --->	
<CFIF Tenant.iTenantStateCode_ID LT 3>
	<CFQUERY NAME = "TenantState" DATASOURCE="#APPLICATION.datasource#">
		UPDATE 	TenantState
		SET		iMoveReasonType_ID	= #form.Reason#,
				<CFIF Variables.ChargeDate NEQ ""> dtChargeThrough = #CreateODBCDateTime(Variables.ChargeDate)#, 	<CFELSE> dtChargeThrough = NULL,</CFIF>
				<CFIF Variables.NoticeDate NEQ ""> dtNoticeDate = #CreateODBCDateTime(Variables.NoticeDate)#, 		<CFELSE> dtNoticeDate = NULL,	</CFIF>
				<CFIF Variables.MoveOutDate NEQ ""> dtMoveOut = #CreateODBCDateTime(Variables.MoveOutDate)#,		<CFELSE> dtMoveOut = NULL, 		</CFIF>
				dtAcctStamp = '#SESSION.AcctStamp#',				
				iTenantStateCode_ID = 2		
		WHERE	iTenant_ID = #form.iTenant_ID#
	</CFQUERY>
<CFELSE>
	<!--- ==============================================================================
	If the tenant is in a moved out state update all information
	BUT do NOT update the state. (comment is redundant but important)
	=============================================================================== --->
	<CFQUERY NAME = "TenantState" DATASOURCE="#APPLICATION.datasource#" result="TenantState">
		UPDATE 	TenantState
		SET		iMoveReasonType_ID	= #form.Reason#,
				<CFIF Variables.ChargeDate NEQ ""> dtChargeThrough = #CreateODBCDateTime(Variables.ChargeDate)#, <CFELSE> dtChargeThrough = NULL, </CFIF>
				<CFIF Variables.NoticeDate NEQ ""> dtNoticeDate = #CreateODBCDateTime(Variables.NoticeDate)#, <CFELSE> dtNoticeDate = NULL,	</CFIF>				
				<CFIF Variables.MoveOutDate NEQ ""> dtMoveOut = #CreateODBCDateTime(Variables.MoveOutDate)#, <CFELSE> dtMoveOut = NULL, </CFIF>
				dtAcctStamp = '#SESSION.AcctStamp#'
		WHERE	iTenant_ID = #form.iTenant_ID#
	</CFQUERY>
	<cfdump var="#TenantState#" label="TenantState">
</CFIF>
		
<!--- ==============================================================================
Insert a record into the invoice detail for the damages.
=============================================================================== --->
<CFIF IsDefined("form.DamageAmount") AND form.DamageAmount GT 0>
	<CFQUERY NAME = "Damages"	DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO 	InvoiceDetail
			(	iInvoiceMaster_ID, iTenant_ID, 
				iChargeType_ID, cAppliesToAcctPeriod, 
				bIsRentAdj, dtTransaction, 
				iQuantity, cDescription, 
				mAmount, cComments, 
				dtAcctStamp, iRowStartUser_ID, 
				dtRowStart
			)VALUES(
				#iInvoiceMaster_ID#, #form.iTenant_ID#,
				36,	
				<CFSET AppliesTo = #YEAR(Variables.dtChargeThrough)# & #DateFormat(Variables.dtChargeThrough,"mm")#>
				'#APPLIESTO#',
				NULL,GetDate(),
				1, 'Damages',
				#TRIM(form.DamageAmount)#,'#form.DamageComments#',
				#CreateODBCDateTime(SESSION.AcctStamp)#,
				#SESSION.UserID#,
				GetDate() 
			)
	</CFQUERY>
</CFIF>

<!--- ==============================================================================
	Retrieve the Charge and ChargeType Information
	dependent upon the type of "Other Charge" Chosen
=============================================================================== --->
	<CFQUERY NAME="Charge" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*
		FROM	Charges C	
		JOIN 	ChargeType CT	ON C.iChargeType_ID = CT.iChargeType_ID
		<CFIF IsDefined("form.OtheriCharge_ID")>
			WHERE	C.iCharge_ID = #form.OtheriCharge_ID#
		<CFELSE>	
			WHERE	C.iCharge_ID = 0
		</CFIF>
	</CFQUERY>

<CFIF IsDefined("form.OtherAmount") AND form.OtherAmount NEQ 0>
	<!--- ==============================================================================
	Insert a record into the invoice detail for the other charges
	=============================================================================== --->	
	<CFQUERY NAME = "Other"	DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO 	InvoiceDetail
			(	iInvoiceMaster_ID, iTenant_ID, 
				iChargeType_ID, cAppliesToAcctPeriod, 
				bIsRentAdj, dtTransaction, 
				iQuantity, cDescription, 
				mAmount, cComments, 
				dtAcctStamp,
				iRowStartUser_ID, 
				dtRowStart,
				iDaysBilled
			)VALUES(
				#Variables.iInvoiceMaster_ID#, 
				#form.iTenant_ID#, 
				#Charge.iChargeType_ID#, 
				<CFIF IsDefined("form.AppliesToMonth") AND IsDefined("form.AppliesToYear")>
					<CFSET Appliesto = #form.AppliesToYear# & #NumberFormat(form.AppliesToMonth, "09")#>
				<CFELSE>
					<CFSET Appliesto = #YEAR(TIPSMONTH)# & #DateFormat(TIPSMONTH,"mm")#>
				</CFIF>
				'#AppliesTo#', 
				NULL, 
				GetDate(), 
				#form.OtheriQuantity#, '#form.OthercDescription#', 
				#Trim(NumberFormat(form.OtherAmount,"99999999.99"))#, 	
				<CFIF IsDefined("form.OtherComments") AND form.OtherComments NEQ "">
					'#form.OtherComments#',
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


<!--- ==============================================================================
Check to see if there are any charges for this MOVE OUT invoice
=============================================================================== --->
<CFQUERY NAME="qRecordCheck" DATASOURCE="#APPLICATION.datasource#">
	SELECT	Count(*) as count
	FROM	InvoiceDetail
	WHERE	iInvoiceMaster_ID = #Variables.iInvoiceMaster_ID#
	AND		dtRowDeleted IS NULL
</CFQUERY>
	
<!--- ==============================================================================
If there are no details automatically add a zero charge
to the 3011 medicaid co-pay account
=============================================================================== --->
<CFIF qRecordCheck.RecordCount EQ 0 OR (qRecordCheck.count EQ 0 AND Over30Days EQ 0)>
	<CFQUERY NAME="qZeroCharge" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*
		FROM	ChargeType
		WHERE	dtRowDeleted IS NULL
		AND		bIsRent IS NOT NULL
		AND		bIsDaily IS NULL
		<CFIF Tenant.iResidencyType_ID EQ 2>
			AND	cGLAccount = 3011
		<CFELSE>
			AND	cGLAccount = 3010
		</CFIF>
	</CFQUERY>

	<!--- ==============================================================================
	Insert Zero amount Mediciad Charge
	=============================================================================== --->
	<CFQUERY NAME = "ZeroAddition" DATASOURCE = "#APPLICATION.datasource#">
		INSERT INTO 	InvoiceDetail
						(	iInvoiceMaster_ID, 
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
							dtRowStart
						)VALUES(
							#Variables.iInvoiceMaster_ID#,
							#Tenant.iTenant_ID#,
							#qZeroCharge.iChargeType_ID#,
							<CFIF Tenant.dtMoveOut NEQ "">'#DateFormat(Tenant.dtMoveOut,"yyyymm")#'<CFELSE>#CurrPer#</CFIF>,
							NULL,
							GETDATE(),
							1,
							'#qZeroCharge.cDescription#',
							<!--- ==============================================================================
							HARD CODED ZERO AMOUNT IF NOT OTHER TRANSACTIONS ARE DEFINED
							=============================================================================== --->
							0.00,
							NULL,
							#CreateODBCDateTime(SESSION.AcctStamp)#,
							<!--- ==============================================================================
							Changed to System due to fact that if records are created this charge should be removed.
							#SESSION.USERID#,
							=============================================================================== --->
							0,
							GETDATE()
						)
	</CFQUERY>	
</CFIF>
	
	
<CFIF Contact.RecordCount GT 0>
	<!--- ==============================================================================
	Update the LinkTenantContact Table
	=============================================================================== --->
	<CFQUERY NAME="UpdateLinkTenantContact" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	LinkTenantContact
		SET		iRelationshipType_ID = #form.IRELATIONSHIPTYPE_ID#
		WHERE	iContact_ID = #Contact.iContact_ID#
	</CFQUERY>

	<!--- ==============================================================================
	Update the contact information
	=============================================================================== --->
	<CFQUERY NAME = "UpdateContact" DATASOURCE="#APPLICATION.datasource#">
			UPDATE 	Contact
			SET		
			<CFIF form.cFirstName NEQ ""> cFirstName = '#form.CFIRSTNAME#', <CFELSE> cFirstName = NULL,	</CFIF>	
			<CFIF form.cLastName NEQ ""> cLastName = '#form.CLASTNAME#', <CFELSE> cLastName = NULL, </CFIF>
			<CFIF form.cAddressLine1 NEQ ""> cAddressLine1 = '#form.CADDRESSLINE1#', <CFELSE> cAddressLine1 = NULL,	</CFIF>
			<CFIF form.cAddressLine2 NEQ ""> cAddressLine2 = '#form.CADDRESSLINE2#', <CFELSE> cAddressLine2 = NULL, </CFIF>			
			<CFIF form.cCity NEQ ""> cCity = '#form.CCITY#', <CFELSE> cCity = NULL, </CFIF>
			<CFIF form.cStateCode NEQ ""> cStateCode = '#form.CSTATECODE#', <CFELSE> cStateCode = NULL, </CFIF>	
			<CFIF form.cZipCode NEQ ""> cZipCode = '#form.CZIPCODE#', </CFIF>	
			<CFIF Variables.PhoneNumber1 NEQ ""> cPhoneNumber1 = '#TRIM(Variables.PHONENUMBER1)#', <CFELSE> cPhoneNumber1 = NULL, </CFIF>
			<CFIF Variables.PhoneNumber2 NEQ ""> cPhoneNumber2 = '#TRIM(Variables.PHONENUMBER2)#' <CFELSE> cPhoneNumber2 = NULL </CFIF>
		WHERE	iContact_ID = #Contact.iContact_ID#	
	</CFQUERY>

<CFELSEIF form.cLastName NEQ "" AND form.cFirstName NEQ "">
	<CFQUERY NAME = "NewContact" DATASOURCE = "#APPLICATION.datasource#">
	INSERT INTO Contact
				(	cFirstName, cLastName, 
					cPhoneNumber1, iPhoneType1_ID, 
					cPhoneNumber2, iPhoneType2_ID, 
					cPhoneNumber3, iPhoneType3_ID, 
					cAddressLine1, cAddressLine2, 
					cCity, cStateCode, 
					cZipCode, cComments, 
					dtAcctStamp,
					iRowStartUser_ID, 
					dtRowStart	
				)VALUES(
					'#form.cFirstName#',
					'#form.cLastName#',
					<CFIF PhoneNumber1 NEQ ""> '#TRIM(Variables.PHONENUMBER1)#', <CFELSE> NULL, </CFIF>
					1,
					<CFIF PhoneNumber2 NEQ ""> '#TRIM(Variables.PHONENUMBER2)#', <CFELSE> NULL, </CFIF>
					5, NULL,
					NULL,
					<CFIF form.cAddressLine1 NEQ ""> '#TRIM(form.CADDRESSLINE1)#', <CFELSE> NULL, </CFIF>
					<CFIF form.cAddressLine2 NEQ ""> '#TRIM(form.CADDRESSLINE2)#', <CFELSE> NULL, </CFIF>
					<CFIF form.cCity NEQ ""> '#TRIM(form.cCity)#', <CFELSE> NULL, </CFIF>
					<CFIF form.cStateCode NEQ ""> '#form.cStateCode#', <CFELSE> NULL, </CFIF>
					<CFIF form.cZipCode NEQ "">	'#form.cZipCode#', <CFELSE> NULL, </CFIF>
					<CFIF form.cComments NEQ ""> '#TRIM(form.cComments)#', <CFELSE> NULL, </CFIF>
					#CreateODBCDateTime(SESSION.AcctStamp)#,
					#SESSION.UserID#,
					GetDate()
				)	
	</CFQUERY>
	
	<CFQUERY NAME = "GetCID" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	iContact_ID 
		FROM	Contact
		WHERE	cFirstName = '#form.cFirstName#'
		AND		cLastName = '#form.cLastName#'
		AND		iRowStartUser_ID = #SESSION.UserID#
		AND		cAddressLine1 = '#form.cAddressLine1#'
	</CFQUERY>

	<CFQUERY NAME="NewLinkTenantContact" DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO 	LinkTenantContact
						(	iTenant_ID, iContact_ID, 
							iRelationshipType_ID, bIsPayer, 
							bIsPowerOfAttorney, bIsMedicalProvider, 
							cComments, dtAcctStamp, 
							iRowStartUser_ID, 
							dtRowStart
						)VALUES(
							#form.iTenant_ID#,
							#GetCID.iContact_ID#,
							#form.iRelationshipType_ID#,
							1,
							NULL,
							NULL,
							'#TRIM(form.cComments)#',
							#CreateODBCDateTime(SESSION.AcctStamp)#,
							#SESSION.UserID#,
							GetDate()
						)
	</CFQUERY>
</CFIF>	
	
</CFTRANSACTION>	
	
<!--- ==============================================================================
Routine to update the invoice total on the header line for this invoice.
Goal: Update mInvoiceTotal
		Including Solomon Lookup & Current Charges
=============================================================================== --->
<!--- ==============================================================================
Retrieve Solomon Transaction Information for tenant (if the house is not zeta)
=============================================================================== --->
<CFIF SESSION.qSelectedHouse.iHouse_ID NEQ 200>
	<CFQUERY NAME="SolomonTrans" DATASOURCE="SOLOMON-HOUSES">
		SELECT SUM(	CASE 
						WHEN doctype in ('PA','CM','SB','PP') then -origdocamt 
						ELSE origdocamt 
					END
					) as Total
		FROM 	ardoc
		WHERE	custid = '#TRIM(Tenant.cSolomonKey)#'
		AND		doctype <> 'IN'
		AND	User7 > = '#Variables.dtInvoiceStart#'
	</CFQUERY>
</CFIF>	

<CFIF IsDefined("SolomonTrans.Total") AND SolomonTrans.Total NEQ "">
	<CFSET SolomonTransTotal = #SolomonTrans.Total#>
<CFELSE>
	<CFSET SolomonTransTotal = 0.00>
</CFIF>

<!--- ==============================================================================
Retrieve the current total for this moveout invoice
=============================================================================== --->
<CFQUERY NAME="CurrentTotal" DATASOURCE="#APPLICATION.datasource#">
	SELECT	round(Sum(mAmount * iQuantity),2) as Total
	FROM	InvoiceDetail
	WHERE	dtRowDeleted IS NULL
	AND		iInvoiceMaster_ID = '#Variables.iInvoiceMaster_ID#'
</CFQUERY> 

<!--- ==============================================================================
Retrieve Refundable Deposits for this person
=============================================================================== --->
<CFQUERY NAME="TotalRefundables" DATASOURCE="#APPLICATION.datasource#">
	SELECT	distinct INV.*
	FROM	InvoiceMaster IM
		JOIN InvoiceDetail INV			ON	INV.iInvoicemaster_ID = IM.iInvoiceMaster_ID 
		LEFT OUTER JOIN DepositLog DL	ON	DL.iTenant_ID = INV.iTenant_ID
		LEFT OUTER JOIN	DepositType DT	ON	DT.iDepositType_ID = DL.iDepositType_ID
	WHERE	INV.iTenant_ID = #Tenant.iTenant_ID#
	AND	IM.bMoveInInvoice IS NOT NULL
	AND	IM.dtRowDeleted IS NULL
	AND	INV.dtRowDeleted IS NULL
	AND	DL.dtRowDeleted IS NULL
	AND	DT.dtRowDeleted IS NULL
	AND	DT.bIsFee IS NULL
</CFQUERY>

<CFSET RefundTotal = 0>

<CFLOOP QUERY="TotalRefundables">
	<CFSET	RefundTotal = (#TotalRefundables.mAmount# * #TotalRefundables.iQuantity#) + #RefundTotal#>
</CFLOOP>

<CFIF IsDefined("CurrentTotal.Total") AND CurrentTotal.Total NEQ "">
	<CFSET CurrentTotal = #CurrentTotal.Total#>
<CFELSE>
	<CFSET CurrentTotal = 0.00>
</CFIF>

<!--- ==============================================================================
SET variables to determine the last months period
=============================================================================== --->
<CFSET PriorMonth = #DateAdd("m",-1,SESSION.TIPSMonth)#>
<CFSET PastDueMonth = #DateFormat(PriorMonth,"yyyymm")#>

<!--- ==============================================================================
Retrieve the Last FINALIZED Invoice Total
=============================================================================== --->
<CFQUERY NAME="LastTotal" DATASOURCE="#APPLICATION.datasource#">
	SELECT	top 1 mInvoiceTotal as Total
	FROM	InvoiceMaster	IM
			JOIN InvoiceDetail INV	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
	WHERE	INV.dtRowDeleted IS NULL
	AND		IM.dtRowDeleted IS NULL
	AND		IM.bMoveOutInvoice IS NULL
	<!--- AND		IM.bMoveInInvoice IS NULL [should not matter whether mi or not]--->
	AND		IM.bFinalized IS NOT NULL
	AND		INV.iTenant_ID = #Tenant.iTenant_ID#
	AND		IM.cAppliesToAcctPeriod <= '#PastDueMonth#'
	ORDER BY im.cAppliesToAcctPeriod desc
</CFQUERY> 

<!--- ==============================================================================
DEBUG
=============================================================================== --->
#Variables.iInvoiceMaster_ID# InvoiceMaster_ID<BR>

<!--- ==============================================================================
If the LastTotal is Defined AND is not null AND the occupancy is 1
THEN set a variable equal to the amount 
OTHERWISE set it to 0
=============================================================================== --->
<CFIF IsDefined("LastTotal.Total") AND LastTotal.Total NEQ "" AND form.Occupancy EQ 1>
	<CFSET LastTotal = #LastTotal.Total#>
<CFELSE>
	<CFSET LastTotal = 0.00>
</CFIF>

<!--- ==============================================================================
Sum the amounts to obtain the Move out's new Invoice Total
=============================================================================== --->
<CFSET NewInvoiceTotal = #LastTotal# + #CurrentTotal# + #SolomonTransTotal# - #RefundTotal#> 

<!--- ==============================================================================
DEBUG
=============================================================================== --->
#Form.Occupancy# Occupancy <BR>
#LastTotal# LastInvoiceTotal : #CurrentTotal# CurrentTotal :  #SolomonTransTotal# SolomonTransTotal #RefundTotal# RefundTotal<BR>

<!--- ==============================================================================
Update the header line with the new Balance information
=============================================================================== --->
<CFIF Tenant.iTenantStateCode_ID LT 4>
	<CFTRANSACTION>
		<CFQUERY NAME="UpdateTotal" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	InvoiceMaster
			SET		mInvoiceTotal = #NewInvoiceTotal#,
					mLastInvoiceTotal = #LastTotal#,
					cAppliesToAcctPeriod = '#DateFormat(SESSION.TIPSMonth,"yyyymm")#',
					dtRowStart = GetDate(),
					iRowStartUser_ID = #SESSION.UserID#
			WHERE	dtRowDeleted IS NULL
			AND		iInvoiceMaster_ID = #Variables.iInvoiceMaster_ID#
		</CFQUERY>
	</CFTRANSACTION>
</CFIF>

<CFIF IsDefined("url.edit")>
	<CFSET Action='MoveOutForm.cfm?ID=#form.iTenant_ID#&edit=1'>
<CFELSE>
	<CFSET Action='MoveOutFormSummary.cfm?ID=#form.iTenant_ID#'>
</CFIF>

<CFIF SESSION.UserID IS 3025 OR SESSION.UserID IS 3146>
	<A HREF="#Action#">Continue</A>
<CFELSE>
	<CFLOCATION URL="#Action#" ADDTOKEN="No">
</CFIF>

</CFOUTPUT>