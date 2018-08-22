<!----------------------------------------------------------------------------------------------
| DESCRIPTION - MoveOut/MoveOutSysDetailUpdate.cfm                                             |
|----------------------------------------------------------------------------------------------|
| 													                                           |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|MLAW        | 08/07/2006 | Create an initialMoveOutSysDetailUpdate page              	       |
|            |            | ChargeType - R&B rate, R&B discount                                |
|MLAW		 | 08/07/2006 | Set up a ShowBtn paramater which will determine when to show the   |
|		     |            | menu button.  Add url parament ShowBtn=#ShowBtn# to all the links  |
|S Farmer    | 09/13/2012 | TPG Collectors Database changes added 'SB' & 'PP' to doctype       |
|sfarmer     | 12/10/2013 | 112478 - adjustments to Billing Information                        |
----------------------------------------------------------------------------------------------->
<!--- 08/07/2006 MLAW show menu button --->
<CFPARAM name="ShowBtn" default="True">
 
<CFOUTPUT>

<CFTRY>
	<CFSCRIPT>
		//Conctenate Dates into one variable
		ChargeDate = form.CHARGEMONTH & "/" & form.CHARGEDAY & "/" & form.CHARGEYEAR;
		NoticeDate = form.NOTICEMONTH & "/" & form.NOTICEDAY & "/" & form.NOTICEYEAR;
		MoveOutDate = form.MOVEOUTMONTH & "/" & form.MOVEOUTDAY & "/" & form.MOVEOUTYEAR;
		ChargeMonthCompareDate = form.CHARGEMONTH & "/" & '01' & "/" & form.CHARGEYEAR;
		//Convert dates into database date times
		dtChargeThrough=CreateODBCDateTime(ChargeDate);
		dtNotice=CreateODBCDateTime(NoticeDate);
		dtMoveOut=CreateODBCDateTime(MoveOutDate);
		dtChargeMonthCompareDate=CreateODBCDateTime(ChargeMonthCompareDate);
	</CFSCRIPT>
	
	<CFCATCH TYPE="ANY">
		<CENTER>
		<B STYLE="font-size: 18; color: red;">
			An error has been encountered with one of the dates entered.<BR>
			<A HREF="#HTTP.REFERER#">Please Click Here to check the dates</A>
		</B>
		</CENTER>
		<CFABORT>
	</CFCATCH>
</CFTRY>
	
<CFSCRIPT>
	//Concatenate Phone Numbers for writing to database
	PHONENUMBER1 = TRIM(form.AREACODE1) & TRIM(form.PREFIX1) & TRIM(form.NUMBER1);
	PHONENUMBER2 = TRIM(form.AREACODE2) & TRIM(form.PREFIX2) & TRIM(form.NUMBER2);
</CFSCRIPT>
<!--- ==============================================================================
Retrieve System Time
=============================================================================== --->
<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
	SELECT	getdate() as TimeStamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>

<!--- ==============================================================================
Retrieve Tenant Information
=============================================================================== --->
<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	Tenant T (nolock)
	JOIN TenantState TS	(nolock) ON	T.iTenant_ID = TS.iTenant_ID		
	JOIN ResidencyType RT (nolock) ON RT.iResidencyType_ID = TS.iResidencyType_ID
	LEFT OUTER JOIN	AptAddress AD (nolock) ON (TS.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
	WHERE T.iTenant_ID = #form.iTenant_ID#
	AND T.dtRowDeleted IS NULL AND TS.dtRowDeleted IS NULL
</CFQUERY>	

<!--- ==============================================================================
Retrieve Contact information
=============================================================================== --->
<CFQUERY NAME="Contact" DATASOURCE="#APPLICATION.datasource#">
	SELECT	C.*
	FROM	LinkTenantContact LTC with (NOLOCK)
	JOIN 	Contact C with (NOLOCK) ON  LTC.iContact_ID = C.iContact_ID		
	WHERE	C.dtRowDeleted IS NULL
	AND 	 c.CFIRSTNAME = '#form.CFIRSTNAME#'  and c.CLASTNAME = '#form.CLASTNAME#'
		<!--- 	AND  	bIsPayer IS NOT NULL  --->
	AND LTC.dtRowDeleted IS NULL
	AND 	C.iContact_ID = ltc.iContact_ID
	AND		iTenant_ID = #Tenant.iTenant_ID#
</CFQUERY>

<!--- ==============================================================================
Retrieve any Move Out Charges already created for this tenant
=============================================================================== --->
<CFQUERY NAME = "MoveOutCharges" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	distinct IM.iInvoiceMaster_ID, dtInvoiceStart, dtInvoiceEnd
	FROM	InvoiceMaster IM  with (NOLOCK)
	JOIN	InvoiceDetail INV with (NOLOCK) ON IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID and INV.dtRowDeleted is null and IM.dtRowDeleted is null
		and IM.bMoveOutInvoice is not null and im.bfinalized is null 
		<CFIF IsDefined("url.MID") AND url.MID NEQ ""> AND IM.iInvoiceMaster_ID = #url.MID#	</CFIF>	
	JOIN	ChargeType CT with (NOLOCK) ON (CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtrowDeleted IS NULL)
	WHERE	INV.iTenant_ID = #Tenant.iTenant_ID#
</CFQUERY>

<CFSCRIPT>
	if (MoveOutCharges.iInvoiceMaster_ID NEQ "") { iInvoiceMaster_ID = MoveOutCharges.iInvoiceMaster_ID; } else { iInvoiceMaster_ID = url.MID; }
	dtInvoiceStart = MoveOutCharges.dtInvoiceStart;
</CFSCRIPT>
<cfabort>
<CFTRANSACTION>

<!--- ==============================================================================
Update the TenantState of the Chosen Tenant (if the state is not moved out)
=============================================================================== --->	
<CFIF Tenant.iTenantStateCode_ID LT 3>
	<CFQUERY NAME = "TenantState" DATASOURCE="#APPLICATION.datasource#">
		UPDATE 	TenantState
		SET		iMoveReasonType_ID	= #form.Reason#,
				dtChargeThrough = <CFIF Variables.ChargeDate NEQ ""> #CreateODBCDateTime(Variables.ChargeDate)#, 	<CFELSE> #TimeStamp#,	</CFIF>
				dtNoticeDate = <CFIF Variables.NoticeDate NEQ ""> #CreateODBCDateTime(Variables.NoticeDate)#, 		<CFELSE> #TimeStamp#,	</CFIF>
				dtMoveOut = <CFIF Variables.MoveOutDate NEQ ""> #CreateODBCDateTime(Variables.MoveOutDate)#,		<CFELSE> NULL, 	</CFIF>
				dtAcctStamp = '#SESSION.AcctStamp#',				
				iTenantStateCode_ID = 2		
		WHERE	iTenant_ID = #form.iTenant_ID#
	</CFQUERY>
<CFELSE>
	<!--- ==============================================================================
	If the tenant is in a moved out state update all information
	BUT do NOT update the state. (comment is redundant but important)
	=============================================================================== --->
	<CFQUERY NAME = "TenantState" DATASOURCE="#APPLICATION.datasource#">
		UPDATE 	TenantState
		SET		iMoveReasonType_ID	= #form.Reason#,
				dtChargeThrough = <CFIF Variables.ChargeDate NEQ ""> #CreateODBCDateTime(Variables.ChargeDate)#, 	<CFELSE> #TimeStamp#,	</CFIF>
				dtNoticeDate = <CFIF Variables.NoticeDate NEQ ""> #CreateODBCDateTime(Variables.NoticeDate)#, 		<CFELSE> #TimeStamp#,	</CFIF>
				dtMoveOut = <CFIF Variables.MoveOutDate NEQ ""> #CreateODBCDateTime(Variables.MoveOutDate)#,		<CFELSE> #TimeStamp#, 	</CFIF>		
				dtAcctStamp = '#SESSION.AcctStamp#'
		WHERE	iTenant_ID = #form.iTenant_ID#
	</CFQUERY>
	<!--- ==============================================================================
	Delete any records left on the monthly invoice for this Moved out resident
	=============================================================================== --->
	<CFQUERY NAME="qDeleteDetails" DATASOURCE="#APPLICATION.datasource#">
		update invoicedetail
		set dtrowdeleted=getdate(),irowdeleteduser_id='#SESSION.UserID#',crowdeleteduser_id='sys_pdmoveout'
		from invoicedetail inv
		join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.dtrowdeleted is null
		and inv.dtrowdeleted is null and im.bfinalized is null and im.bmoveoutinvoice is null and im.bmoveininvoice is null
		join tenant t on t.itenant_id = inv.itenant_id and t.dtrowdeleted is null
		join tenantstate ts on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null
		join house h on h.ihouse_id = t.ihouse_id and h.dtrowdeleted is null
		and ts.itenantstatecode_id = 3
		where t.itenant_id = #form.iTenant_ID#
	</CFQUERY>
</CFIF>
	
	<CFIF IsDefined("form.SysEdit") AND form.SysEdit NEQ "">
			<!--- Set loop number counter  --->
			<CFSET Counter = 0>
			<!--- ==============================================================================
			Start Loop of Fielnames
			=============================================================================== --->
			<CFLOOP INDEX="I" LIST="#form.fieldnames#" DELIMITERS=",">
				<CFIF FindNoCase("SYS",I, 1) GT 0>
					<CFIF FindNoCase("SYSPERIOD",I, 1) GT 0>
						<CFSET Counter = Counter + 1>
						<CFIF Counter EQ 1>
							<CFSET InvDetailList = RemoveChars(I,1,9)>
						<CFELSE>
							<CFSET InvDetailList = InvDetailList & ',' &  RemoveChars(I,1,9)>
						</CFIF>
					</CFIF>
				</CFIF>
			</CFLOOP>
			<!--- List Debug --->
			<CFIF IsDefined("InvDetailList")>
				#InvDetailList# DetailList<BR>
		
				<!--- ==============================================================================
				Loop over Details
				=============================================================================== --->
				<CFLOOP INDEX="N" LIST="#InvDetailList#" DELIMITERS=",">
					<!--- DEBUG --->
					<TABLE BORDER=1><TR>
					<CFLOOP INDEX="M" LIST="#form.fieldnames#" DELIMITERS=",">
						<CFIF FindNoCase(N,M,1) GT 0>
							<CFIF FindNoCase("Period", M, 1) GT 0>
								<TD> Period - #Evaluate(M)# </TD> <CFSET ThiscAppliesToAcctperiod = Evaluate(M)>
							<CFELSEIF FindNoCase("cDescription", M, 1) GT 0>
								<TD> Desc - #Evaluate(M)# </TD> <CFSET ThiscDescription = '#Evaluate(M)#'>
							<CFELSEIF FindNoCase("mAMount", M, 1) GT 0>
								<TD> mAmount - #Evaluate(M)# </TD> <CFSET ThismAmount = Evaluate(M)>
							<CFELSEIF FindNoCase("quantity", M, 1) GT 0>
								<TD> Quantity - #Evaluate(M)# </TD> <CFSET ThisiQuantity = Evaluate(M)>
							</CFIF>
						</CFIF>
					</CFLOOP>
					
					<!--- ==============================================================================
					Save Information
					=============================================================================== --->
					  <CFQUERY NAME="Update#N#" DATASOURCE="#APPLICATION.datasource#">
						UPDATE	InvoiceDetail
						SET	<CFIF ThiscAppliesToAcctperiod NEQ ""> cAppliesToAcctperiod = '#ThiscAppliesToAcctperiod#', </CFIF>
							<CFIF ThiscDescription NEQ ""> cDescription = '#ThiscDescription#', </CFIF>
							<CFIF ThismAmount NEQ "" AND ThismAmount NEQ "NaN"> mAmount = #ThismAmount#, <CFELSE> mAmount = 0.00, </CFIF>
							<CFIF ThisiQuantity NEQ ""> iQuantity = #ThisiQuantity#, </CFIF>
							iRowStartUser_ID = 0,
							dtRowStart = #TimeStamp#	
						WHERE	iInvoiceDetail_ID = #N#
					 </CFQUERY> 
					 
				</CFLOOP>
			</CFIF>
			</TR></TABLE>
		
			<!--- ==============================================================================
			Insert a record into the invoice detail for the damages.
			=============================================================================== --->
			<CFIF IsDefined("form.DamageAmount") AND form.DamageAmount GT 0>
				<CFQUERY NAME="Damages" DATASOURCE="#APPLICATION.datasource#" result="Damagesinsert">
					INSERT INTO InvoiceDetail
					(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, 
						bIsRentAdj, dtTransaction, iQuantity, cDescription, 
						mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart
					)VALUES(
						#iInvoiceMaster_ID#, #form.iTenant_ID#, 36,	
						<CFSET AppliesTo = YEAR(Variables.dtChargeThrough) & DateFormat(Variables.dtChargeThrough,"mm")>
						'#APPLIESTO#',
						NULL,#TimeStamp#,
						1, 'Damages',
						#TRIM(form.DamageAmount)#,'#form.DamageComments#',
						#CreateODBCDateTime(SESSION.AcctStamp)#,
						#SESSION.UserID#,
						#TimeStamp# 
					)
				</CFQUERY>
				<cfdump var="#Damagesinsert#" label="Damagesinsert">
			</CFIF>
	 
			<!--- ==============================================================================
			Retrieve the Charge and ChargeType Information
			dependent upon the type of "Other Charge" Chosen
			=============================================================================== --->
				<CFQUERY NAME="Charge" DATASOURCE="#APPLICATION.datasource#">
					SELECT * 
					FROM Charges C	with (NOLOCK)
					JOIN 	ChargeType CT with (NOLOCK)	ON C.iChargeType_ID = CT.iChargeType_ID
					<CFIF IsDefined("form.OtheriCharge_ID") AND form.OtheriCharge_ID NEQ ''> 
						WHERE	C.iCharge_ID = #form.OtheriCharge_ID#
					<CFELSE> WHERE C.iCharge_ID = 0 </CFIF>
				</CFQUERY>
						
			<CFIF IsDefined("form.OtherAmount") AND form.OtherAmount NEQ 0>
				<!--- ==============================================================================
				Insert a record into the invoice detail for the other charges
				=============================================================================== --->	
				<CFQUERY NAME="Other" DATASOURCE="#APPLICATION.datasource#" result="Otherinsert">
					INSERT INTO InvoiceDetail
					(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, 
						bIsRentAdj, dtTransaction, iQuantity, cDescription, 
						mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart,iDaysBilled
					)VALUES(
						#MoveOutCharges.iInvoiceMaster_ID#, 
						#form.iTenant_ID#, 
					    <cfif #Charge.iChargeType_ID# eq 69>
						 1741,
						<cfelse>
						 #Charge.iChargeType_ID#,
						</cfif>
						<CFIF IsDefined("form.AppliesToMonth") AND IsDefined("form.AppliesToYear")>
							<CFSET Appliesto = form.AppliesToYear & NumberFormat(form.AppliesToMonth, "09")>
						<CFELSE>
							<CFSET Appliesto = YEAR(TIPSMONTH) & DateFormat(TIPSMONTH,"mm")>
						</CFIF>
						'#AppliesTo#', 
						NULL, 
						#TimeStamp#, 
						<!---#form.OtheriQuantity#,--->
		<!---Mshah--->	 <cfif ListFindNoCase("1748,1682",#trim(Charge.iChargeType_ID)#,",")GT 0 > 1 <cfelse> #form.OtheriQuantity# </cfif>,
     					'#form.OthercDescription#', 
						<!---#Trim(NumberFormat(form.OtherAmount,"99999999.99"))#,--->
		<!---Mshah--->	<cfif ListFindNoCase("1748,1682",#trim(Charge.iChargeType_ID)#,",")GT 0 > #Trim(NumberFormat(form.OtherAmount*form.OtheriQuantity,"99999999.99"))# <cfelse> #Trim(NumberFormat(form.OtherAmount,"99999999.99"))# </cfif>,
						<CFIF IsDefined("form.OtherComments") AND form.OtherComments NEQ "">
							'#form.OtherComments#',
						<CFELSE> NULL, </CFIF> 
						#CreateODBCDateTime(SESSION.AcctStamp)#,
						#SESSION.UserID#,
						#TimeStamp#,
						#form.OtheriQuantity#
					)
				</CFQUERY>	
				<cfdump var="#Otherinsert#">
			</CFIF>	 
	 
	</CFIF>

	<!--- ==============================================================================
	Check to see if there are any charges for this MOVE OUT invoice
	=============================================================================== --->
	<CFQUERY NAME="qRecordCheck" DATASOURCE="#APPLICATION.datasource#">
		SELECT	Count(*) as count
		FROM	InvoiceDetail with (NOLOCK)
		WHERE	dtRowDeleted IS NULL 
		AND	iInvoiceMaster_ID = #Variables.iInvoiceMaster_ID#
	</CFQUERY>
		
	<!--- ==============================================================================
	If there are no details automatically add a zero charge
	to the 3011 medicaid co-pay account
	
	03/08/20002
	<CFIF qRecordCheck.RecordCount EQ 0 OR (qRecordCheck.count EQ 0 AND Over30Days EQ 0)>
	=============================================================================== --->
	<CFIF qRecordCheck.Count EQ 0 OR (qRecordCheck.count EQ 0 AND Over30Days EQ 0)>
		<CFQUERY NAME="qZeroCharge" DATASOURCE="#APPLICATION.datasource#">
			SELECT	*
			FROM	ChargeType with (NOLOCK)
			WHERE	dtRowDeleted IS NULL AND bIsRent IS NOT NULL AND bIsDaily IS NULL
			<CFIF Tenant.iResidencyType_ID EQ 2> AND cGLAccount = 3011 <CFELSE> AND cGLAccount = 3010 </CFIF>
		</CFQUERY>
	
		<!--- ==============================================================================
		Insert Zero amount Mediciad Charge
		=============================================================================== --->
		<CFQUERY NAME="ZeroAddition" DATASOURCE="#APPLICATION.datasource#">
			INSERT INTO InvoiceDetail
			(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, dtTransaction, iQuantity, cDescription, 
				mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart
			)VALUES(
				#iInvoiceMaster_ID#,
				#Tenant.iTenant_ID#,
				#qZeroCharge.iChargeType_ID#,
				<CFIF Tenant.dtMoveOut NEQ "">'#DateFormat(Tenant.dtMoveOut,"yyyymm")#'<CFELSE>#DateFormat(SESSION.TIPSMonth,"yyyymm")#</CFIF>,
				NULL, #TimeStamp#, 1, '#qZeroCharge.cDescription#' & 'C',
				<!--- ==============================================================================
				HARD CODED ZERO AMOUNT IF NOT OTHER TRANSACTIONS ARE DEFINED
				=============================================================================== --->
				0.00, NULL, #CreateODBCDateTime(SESSION.AcctStamp)#,
				<!--- ==============================================================================
				Changed to System due to fact that if records are created this charge should be removed.
				#SESSION.USERID#,
				=============================================================================== --->
				0,
				#TimeStamp#
			)
		</CFQUERY>	
		Zero Charge Added because there are not existing details<BR>
	</CFIF>	
	
	
	<CFIF Contact.RecordCount GT 0>
		<!--- ==============================================================================
		Update the LinkTenantContact Table
		=============================================================================== --->
		<CFQUERY NAME="UpdateLinkTenantContact" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	LinkTenantContact
			SET		iRelationshipType_ID = #form.IRELATIONSHIPTYPE_ID#
					,dtrowstart=getdate()
					,irowstartuser_id = #SESSION.UserID#
			<cfif isDefined("form.bIsMoveOutPayer") and form.bIsMoveOutPayer neq ""	>	,bIsMoveOutPayer = 1	</cfif>	
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
						#TimeStamp#
					)	
		</CFQUERY>
		
		<CFQUERY NAME = "GetCID" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	iContact_ID 
			FROM	Contact with (NOLOCK)
			WHERE	cFirstName = '#form.cFirstName#'
			AND		cLastName = '#form.cLastName#'
			AND		iRowStartUser_ID = #SESSION.UserID#
			AND		cAddressLine1 = '#form.cAddressLine1#'
		</CFQUERY>
	
		<CFQUERY NAME="NewLinkTenantContact" DATASOURCE="#APPLICATION.datasource#">
			INSERT INTO 	LinkTenantContact
			(	iTenant_ID, iContact_ID, iRelationshipType_ID, bIsMoveOutPayer, bIsPowerOfAttorney, bIsMedicalProvider, 
				cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart
			)VALUES(
				#form.iTenant_ID#, #GetCID.iContact_ID#, #form.iRelationshipType_ID#,  1,NULL, NULL,
				'#TRIM(form.cComments)#', #CreateODBCDateTime(SESSION.AcctStamp)#, #SESSION.UserID#, #TimeStamp#
			)
		</CFQUERY>
	</CFIF>	

	<!--- ==============================================================================
	Routine to update the invoice total on the header line for this invoice.
	Goal: Update mInvoiceTotal
			Including Solomon Lookup & Current Charges
	=============================================================================== --->
	
	<CFSCRIPT>
		//SET variables to determine the last months period
		PriorMonth = DateAdd("m",-1,SESSION.TIPSMonth); PastDueMonth = DateFormat(PriorMonth,"yyyymm");
	</CFSCRIPT>
	
	<!--- ==============================================================================
	Retrieve the Last FINALIZED Invoice Total
	=============================================================================== --->
	<CFQUERY NAME="LastTotal" DATASOURCE="#APPLICATION.datasource#">
		SELECT	top 1 mInvoiceTotal as Total, dtInvoiceEnd
		FROM InvoiceMaster	IM with (NOLOCK)
		JOIN InvoiceDetail INV	with (NOLOCK) ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
		WHERE INV.dtRowDeleted IS NULL
		AND	IM.dtRowDeleted IS NULL AND IM.bMoveOutInvoice IS NULL AND IM.bFinalized IS NOT NULL
		AND INV.iTenant_ID = #Tenant.iTenant_ID#
		AND IM.cAppliesToAcctPeriod <= '#DateFormat(SESSION.TipsMonth,"yyyymm")#'
		AND	IM.iinvoicemaster_id <> #MoveOutCharges.iinvoicemaster_id#
		ORDER BY im.cAppliesToAcctPeriod desc, im.dtinvoiceend desc, im.iinvoicemaster_id desc 
	</CFQUERY> 
	
	<cfdump var ="#LastTotal#" label="LastTotal">
	<CFSET LastTotaldtInvoiceEnd = LastTotal.dtInvoiceEnd>
	
	<!--- ==============================================================================
	Retrieve Solomon Transaction Information for tenant (if the house is not zeta)
	=============================================================================== --->
	<CFIF SESSION.qSelectedHouse.iHouse_ID NEQ 200>
		<CFQUERY NAME="SolomonTrans" DATASOURCE="#APPLICATION.datasource#">
			SELECT SUM(	CASE WHEN doctype in ('PA','CM','SB','PP') then -origdocamt  ELSE origdocamt END ) as Total
			FROM 	#Application.HOUSES_APPDBServer#.HOUSES_APP.dbo.ardoc with (NOLOCK)
			WHERE	custid = '#TRIM(Tenant.cSolomonKey)#'
			AND	doctype <> 'IN' AND	User7 > = '#Variables.dtInvoiceStart#' and len(user1) = 0
		</CFQUERY>
	</CFIF>	
	
	<CFIF IsDefined("SolomonTrans.Total") AND SolomonTrans.Total NEQ "">
		<CFSET SolomonTransTotal = SolomonTrans.Total>
	<CFELSE>
		<CFSET SolomonTransTotal = 0.00>
	</CFIF>
	
	<!--- ==============================================================================
	Retrieve the current total for this moveout invoice
	=============================================================================== --->
	<CFQUERY NAME="CurrentTotal" DATASOURCE="#APPLICATION.datasource#">
		SELECT	round(Sum(mAmount * iQuantity),2) as Total
		FROM	InvoiceDetail with (NOLOCK)
		WHERE	dtRowDeleted IS NULL
		AND		iInvoiceMaster_ID = '#Variables.iInvoiceMaster_ID#'
	</CFQUERY> 
	
	<!--- ==============================================================================
	Retrieve Refundable Deposits for this person
		LEFT OUTER JOIN DepositLog DL	ON	DL.iTenant_ID = INV.iTenant_ID
		LEFT OUTER JOIN	DepositType DT	ON	DT.iDepositType_ID = DL.iDepositType_ID	
	=============================================================================== --->
	<CFQUERY NAME="TotalRefundables" DATASOURCE="#APPLICATION.datasource#">
		SELECT	distinct INV.*
		FROM	InvoiceMaster IM with (NOLOCK)
		JOIN 	InvoiceDetail INV	with (NOLOCK)	ON	INV.iInvoicemaster_ID = IM.iInvoiceMaster_ID 
		join chargetype ct on ct.ichargetype_id = inv.ichargetype_id and ct.dtrowdeleted is null
			and ct.bisrefundable is not null and ct.bisdeposit is not null
		WHERE	INV.iTenant_ID = #Tenant.iTenant_ID#
		AND IM.bMoveInInvoice IS NOT NULL AND IM.dtRowDeleted IS NULL
		AND INV.dtRowDeleted IS NULL 
	</CFQUERY>
	
	<CFSET RefundTotal = 0>
	
	<CFLOOP QUERY="TotalRefundables">
		<CFSET	RefundTotal = (TotalRefundables.mAmount * TotalRefundables.iQuantity) + RefundTotal>
	</CFLOOP>
	
	<CFIF IsDefined("CurrentTotal.Total") AND CurrentTotal.Total NEQ "">
		<CFSET CurrentTotal = CurrentTotal.Total>
	<CFELSE>
		<CFSET CurrentTotal = 0.00>
	</CFIF>
	
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
		<CFSET LastTotal = LastTotal.Total>
	<CFELSE>
		<CFSET LastTotal = 0.00>
	</CFIF>
	
	<!--- ==============================================================================
	Sum the amounts to obtain the Move out's new Invoice Total
	=============================================================================== --->
	<CFSET NewInvoiceTotal = (LastTotal + CurrentTotal + SolomonTransTotal) - RefundTotal> 
	
	<!--- ==============================================================================
	DEBUG
	=============================================================================== --->
	#Form.Occupancy# Occupancy <BR>
	#LastTotal# LastInvoiceTotal : #CurrentTotal# CurrentTotal :  #SolomonTransTotal# SolomonTransTotal #RefundTotal# RefundTotal<BR>
	
	<!--- ==============================================================================
	Update the header line with the new Balance information
	=============================================================================== --->
	<CFIF Tenant.iTenantStateCode_ID LT 4>
		<CFQUERY NAME="UpdateTotal" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	InvoiceMaster
			SET		mInvoiceTotal = #NewInvoiceTotal#,
					mLastInvoiceTotal = #LastTotal#,
					dtInvoiceStart = '#LastTotaldtInvoiceEnd#',
					cAppliesToAcctPeriod = '#DateFormat(SESSION.TIPSMonth,"yyyymm")#',
					<CFIF IsDefined("form.InvoiceComments") AND form.InvoiceComments NEQ "">cComments='#form.InvoiceComments#',</CFIF>
					dtRowStart = #TimeStamp#,
					iRowStartUser_ID = #SESSION.UserID#
			WHERE	dtRowDeleted IS NULL
			AND		iInvoiceMaster_ID = #Variables.iInvoiceMaster_ID#
		</CFQUERY>
	</CFIF>
	
	<CFSCRIPT>
		if (IsDefined("url.edit")) { Action='MoveOutForm.cfm?ID=#form.iTenant_ID#&edit=1&MID=#Variables.iInvoiceMaster_ID#&ShowBtn=#ShowBtn#'; }
		else { Action='MoveOutFormSummary.cfm?ID=#form.iTenant_ID#&MID=#Variables.iInvoiceMaster_ID#&ShowBtn=#ShowBtn#';}
	</CFSCRIPT>
	
</CFTRANSACTION>

	<CFIF isDefined("auth_user") and auth_user eq 'ALC\PaulB'>
		<A HREF="#Action#">Continue</A>
	<CFELSE>
		<CFLOCATION URL="#Action#" ADDTOKEN="No">
	</CFIF>

</CFOUTPUT>