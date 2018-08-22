
<!--- =============================================================================================
Concat. Month Day Year for dBirthDate
============================================================================================= --->
<CFSET dtCheckDate = form.month & "/" & form.day & "/" & form.year>
<CFSET dtCheckDate = CreateODBCDateTime(dtCheckDate)>

<CFTRANSACTION>

 <!--- 
 	4/4/2005
 	lines 10-51 added by Paul Buendia as per accounting issues
	to help catch duplicate entries upon update
	--->
	<!--- ==============================================================================
	Retrieve Information by the tenant
	=============================================================================== --->
	<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
		select	*
		from Tenant T 
		join TenantState TS ON T.iTenant_ID = TS.iTenant_ID
		where T.dtRowDeleted IS NULL AND TS.dtRowDeleted IS NULL AND T.iTenant_ID = #form.iTenant_ID#
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
	
	<cfif check.recordcount gt 0>
	<CFOUTPUT>
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
	</cfif>


	<!--- ==============================================================================
	Update CashReceiptDetail
	=============================================================================== --->
	<CFQUERY NAME = "UpdateDetail" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE 	CashReceiptDetail
		SET 	iCashReceipt_ID = #TRIM(form.iCashReceipt_ID)#, 
				iTenant_ID = #TRIM(form.iTenant_ID)#, 
				cCheckNumber = '#TRIM(form.cCheckNumber)#', 
				dtCheckDate = #Variables.dtCheckDate#, 
				mAmount = #LSNumberFormat(LSParseNumber(form.mAmount), "99999999.99")#,
				cComments = '#TRIM(form.cComments)#',
				iRowStartUser_ID = #SESSION.UserID#,
				dtRowStart = getDate()
		WHERE 	iCashReceiptItem_ID = #form.iCashReceiptItem_ID#
	</CFQUERY>

</CFTRANSACTION>

<CFLOCATION URL="CashReceipts.cfm">