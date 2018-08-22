
<!--- ==============================================================================
Retrieve list of Current Tenants for this House
=============================================================================== --->
<CFQUERY NAME="TenantInfo" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	Tenant T
			JOIN	TenantState TS
			ON		TS.iTenant_ID = T.iTenant_ID
	WHERE	T.iTenant_ID = #form.iTenant_ID#
</CFQUERY>

<!--- ==============================================================================
Retrieve DepositLog Information
=============================================================================== --->
<CFQUERY NAME="DepositInfo" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	DepositLog DL
			JOIN	DepositType DT
			ON		DT.iDepositType_ID = DL.iDepositType_ID
	WHERE	DL.iTenant_ID = #TenantInfo.iTenant_ID#
	AND		DL.dtRowDeleted IS NULL
	AND		DT.dtRowDeleted IS NULL
</CFQUERY>

<!--- ==============================================================================
Retrieve InvoiceInformation
=============================================================================== --->
<CFQUERY NAME="InvoiceInfo" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	InvoiceMaster IM
			JOIN	InvoiceDetail INV
			ON		INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
	WHERE	IM.dtRowDeleted IS NULL
	AND		INV.dtRowDeleted IS NULL
	AND		INV.iTenant_ID = #TenantInfo.iTenant_ID#
	AND		IM.bFinalized IS NULL
</CFQUERY>

<!--- ==============================================================================
Include Intranet header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">


<CFOUTPUT>

<FORM ACTION="KeyChangeSummary.cfm" METHOD="POST">
	<TABLE>
		<TR>
			<TH COLSPAN=2> Key Change.</TH>
		</TR>
		<TR>
			<TD COLSPAN=2>
				#TenantInfo.cFirstName# #TenantInfo.cLastName# (#TenantInfo.cSolomonkey#)
			</TD>
		</TR>	
		<TR><TD COLSPAN=2><HR></TD></TR>
		<TR>
			<TD> This Tenant Has the following Deposits	</TD>
			<TD></TD>
		</TR>
		<CFIF DepositInfo.RecordCount GT 0>	
			<CFLOOP QUERY="DepositInfo">
				<TR>
					<TD>	#DepositInfo.cDescription#	</TD>
					<TD>	#DepositInfo.mAmount#	</TD>
				</TR>
			</CFLOOP>
		<CFELSE>
			<TR>
				<TD COLSPAN=2 STYLE="text-align: center;">
					There are no deposits for this person.
				</TD>
			</TR>
		</CFIF>
		
		<TR>
			<TD> Current Charges for this Tenant.</TD>
			<TD></TD>		
		</TR>
		
		<CFLOOP QUERY="InvoiceInfo">
			<TR>
				<TD COLSPAN=2> Invoice Number: #InvoiceInfo.iInvoiceNumber#</TD>
			</TR>
			
			Retrieve the 
			<CFQUERY NAME="InvoiceDetails" DATASOURCE="#APPLICATION.datasource#">
				SELECT	*
				FROM	InvoiceDetail
				WHERE	dtRowDeleted IS NULL
				AND		iInvoiceMaster_ID = #InvoiceInfo.iInvoiceMaster_ID#
			</CFQUERY>
			
			
		</CFLOOP>
	</TABLE>
</FORM>

</CFOUTPUT>


<!--- ==============================================================================
Include Intranet header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../footer.cfm">