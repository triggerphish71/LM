<!--- ==============================================================================
Modification History:
1/10/02	SBD	Added quotes around cCheckNumber field in "Details" query
=============================================================================== --->

<!--- =============================================================================================
Concat. Month Day Year for dBirthDate
============================================================================================= --->
<CFSET dtCheckDate = form.month & "/" & form.day & "/" & form.year>
<CFSET dtCheckDate = CreateODBCDateTime(dtCheckDate)>

<!--- ==============================================================================
Retrieve Server Time
=============================================================================== --->
<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
	SELECT	getDate() as TimeStamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>

<!--- ==============================================================================
Retrieve Information by the tenant
=============================================================================== --->
<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM Tenant T 
	JOIN TenantState TS ON T.iTenant_ID = TS.iTenant_ID
	WHERE T.dtRowDeleted IS NULL AND TS.dtRowDeleted IS NULL AND T.iTenant_ID = #form.iTenant_ID#
</CFQUERY>
	
<!--- ==============================================================================
Obtain the Current Cash Reciepts Information
=============================================================================== --->
<CFQUERY NAME = "GetCashReceiptID" DATASOURCE = "#APPLICATION.datasource#">
	SELECT * FROM CashReceiptMaster WHERE dtRowDeleted IS NULL AND bFinalized IS NULL
	AND iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</CFQUERY>
	
<!--- ==============================================================================
Check for Duplicate entries
=============================================================================== --->
<CFQUERY NAME="Check" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM CashReceiptDetail CD
	JOIN Tenant T ON (CD.iTenant_ID = T.iTenant_ID AND T.dtRowDeleted IS NULL)
	WHERE CD.dtRowDeleted IS NULL
	AND CD.cCheckNumber = '#TRIM(form.cCheckNumber)#'
	AND T.cSolomonKey = '#TRIM(Tenant.cSolomonKey)#'
	and CD.dtrowstart between dateadd(d,-7,getdate()) and dateadd(d,7,getdate())
</CFQUERY>	
	
<CFIF Check.RecordCount EQ 0>
	
<CFTRANSACTION>	
	<CFQUERY NAME = "InsertCashReceipt" DATASOURCE = "#APPLICATION.datasource#">
		INSERT INTO CashReceiptDetail
		( iCashReceipt_ID, iTenant_ID, cCheckNumber, dtCheckDate, mAmount, cComments, iRowStartUser_ID, dtRowStart
		)VALUES(
			#GetCashReceiptID.iCashReceipt_ID#, 
			#form.iTenant_ID#,
			'#TRIM(form.cCheckNumber)#', 
			#Variables.dtCheckDate#,
			<CFIF form.mAmount NEQ 'NaN' AND form.mAmount NEQ ''>#TRIM(form.mAmount)#,<CFELSE>0.00,</CFIF>
			'#TRIM(form.cComments)#',
			#SESSION.UserID#,
			#TimeStamp#
		)
	</CFQUERY>
</CFTRANSACTION>

<CFELSE>	
	<CFOUTPUT>
		<CFINCLUDE template="../../header.cfm">	
		<BR><BR>
		<TABLE STYLE="width: 640;">
			<TR> <TH> Warning: Duplicate Entry Detected. </TH> </TR>
			<TR>
				<TD>
					<B>Check Number - #Check.cCheckNumber#</B> <BR>
					An entry has already been entered for Tenant ID #Check.cSolomonKey# for #lscurrencyformat(form.mAmount)#<BR>
					<B>If this payment is for two charges please document this in the comments section.</B><BR>
				</TD>
			</TR>
		</TABLE>
		<BR>
		<A HREF="CashReceipts.cfm" STYLE="font-Size: 18;"> Click Here to Continue.<BR> </A>
		<!--- CashReceipts.cfm?ID=#Check.iTenant_ID#&item=#Check.iCashReceiptItem_ID# ---->
		<CFABORT>
	</CFOUTPUT>
</CFIF>

<CFIF (isDefined("Auth_user") AND Auth_user EQ 'ALC\PaulB')>
	<A HREF="CashReceipts.cfm"> Continue </A>
<CFELSE>
	<CFLOCATION URL = "CashReceipts.cfm">
</CFIF>