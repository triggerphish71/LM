
<CFOUTPUT>

<CFQUERY NAME="qTenantList" DATASOURCE="#APPLICATION.datasource#">
	SELECT distinct ltrim(rtrim(T.cSolomonKey)) as csolomonkey
	FROM Tenant T (NOLOCK)
	JOIN TenantState TS (NOLOCK) ON (TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted IS NULL)
	WHERE T.dtRowDeleted IS NULL and TS.iTenantStateCode_ID = 2
	AND T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# 
</CFQUERY>

<CFQUERY NAME="qInvoices" DATASOURCE="#APPLICATION.datasource#">
	SELECT	iInvoiceMaster_ID, cAppliesToAcctPeriod, mLastInvoiceTotal, mInvoiceTotal, bMoveInInvoice, bMoveOutInvoice, 
			bFinalized, dtInvoiceStart, dtInvoiceEnd, dtRowStart, dtRowEnd, cComments, iInvoiceNumber, csolomonkey
	FROM	InvoiceMaster (NOLOCK)
	WHERE	dtRowDeleted is null and bMoveOutInvoice IS NULL and cSolomonKey in (#QuotedValueList(qTenantList.cSolomonKey)#)
	ORDER BY  cSolomonkey, cAppliesToAcctPeriod, isnull(bMoveInInvoice, 0) desc, 
			cast(isnull(bMoveInInvoice,0) as int) + cast(isnull(bMoveOutInvoice, 0) as int) desc, 
			isnull(bMoveOutInvoice, 2) desc
</CFQUERY>

<!--- ==============================================================================
<CFTRY>

<CFSTOREDPROC PROCEDURE="rw.sp_Validate_Invoices_by_House" DATASOURCE="#APPLICATION.datasource#" USERNAME="rw" PASSWORD="4rwriter">
	<cfprocresult NAME="qBalanceCheck" resultset="1">
	<cfprocparam type="IN" value="#SESSION.qSelectedHouse.cNumber#" DBVARNAME="@HouseNumber" cfsqltype="CF_SQL_VARCHAR">
</CFSTOREDPROC>

<CFIF qBalanceCheck.RecordCount GT 0>
	<B>#qBalanceCheck.cSolomonKey#</B><BR>
</CFIF>

	<CFCATCH TYPE="Any">
		<P>#cfcatch.message#</P>
		<P>Caught an exception, type = #cfcatch.TYPE# </P>
		<P>The contents of the tag stack are:</P>
		<CFLOOP index=i from=1 to = #ArrayLen(cfcatch.TAGCONTEXT)#>
		      <CFSET sCurrent = #cfcatch.TAGCONTEXT[i]#>
		          <BR>#i# #sCurrent["ID"]# (#sCurrent["LINE"]#,#sCurrent["COLUMN"]#) #sCurrent["TEMPLATE"]#
		</CFLOOP>
	</CFCATCH>
	
</CFTRY>

=============================================================================== --->
<TABLE>
<TR><TD>Balance issues</TD></TR>
<CFSCRIPT>
	lastperiod = ''; lastinvoice = ''; P_lastinvoicetotal = ''; P_invoicetotal = '';
</CFSCRIPT>
	
	<CFLOOP QUERY="qInvoices">
		<CFSCRIPT>
			if (qInvoices.bMoveInInvoice NEQ "") { Type = 2; } else if (qInvoices.bMoveOutInvoice NEQ "") { Type = 3; } else { Type = 1; }
		</CFSCRIPT>
		<CFIF lastperiod EQ qInvoices.cAppliesToAcctPeriod AND (qInvoices.Currentrow NEQ qInvoices.RecordCount)
			AND	(Type EQ LastType) AND Type NEQ 2 AND LastType NEQ 3>
		<TR>
			<TD STYLE="font-size: 10;">
			*** POSSIBLE DUPLICATE INVOICE ***<BR>
			#lastperiod# EQ #qInvoices.cAppliesToAcctPeriod# / #qInvoices.cSolomonKey# #qInvoices.iInvoiceNumber# #lastinvoice#
			</TD>
			
			<CFSCRIPT>
				EmailDuplicate=1; P_period = lastperiod; qPeriod = qInvoices.cAppliesToAcctPeriod; 
				qsolkey = qInvoices.cSolomonKey; qInv = qInvoices.iInvoiceNumber; P_inv = lastinvoice;
			</CFSCRIPT>
		</TR>
		</CFIF>
		
		<CFIF P_InvoiceTotal NEQ "" AND qInvoices.mLastInvoiceTotal NEQ P_invoiceTotal AND Type NEQ 2>
		<TR>
			<TD>
				SolomonKey #qInvoices.cSolomonKey#  (Inv #qInvoices.iInvoiceNumber# #qInvoices.cAppliestoAcctPeriod# #DollarFormat(qInvoices.mLastInvoiceTotal)#) != (Inv #lastinvoice# #DollarFormat(P_invoiceTotal)#)
			</TD>
			<CFSCRIPT>
				EmailBalance=1; SolKey = qInvoices.cSolomonKey; qLastTotal = qInvoices.mLastInvoiceTotal;
				qInv = qInvoices.iInvoiceNumber; P_Total= P_invoiceTotal; P_Invoice = lastinvoice;
			</CFSCRIPT>
		</TR>
		</CFIF>
		
		<CFSCRIPT>
			lastperiod = qInvoices.cAppliesToAcctPeriod; lastinvoice = qInvoices.iInvoicenumber;
			P_lastinvoicetotal = qInvoices.mLastInvoiceTotal; P_invoicetotal = qInvoices.mInvoiceTotal;
			if (qInvoices.bMoveInInvoice NEQ "") { LastType = 2; } else if (qInvoices.bMoveOutInvoice NEQ "") { LastType = 3; } else { LastType = 1; }
		</CFSCRIPT>
	</CFLOOP>
</TABLE>
</CFOUTPUT>



<!--- ==============================================================================
<CFIF IsDefined("EmailBalance")>
	<CFMAIL TO="mlaw@alcco.com" CC="SDavison@alcco.com" FROM="TIPS4-Message" SUBJECT="Balance Problem" TYPE="HTML">
		*** POSSIBLE Balance Problem ***<BR>
		SolomonKey <A HREF="http://gum/intranet/Tips4/Developer.cfm?sol_id=#solkey#">#SolKey#</A><BR>
		#qLastTotal# (Invoice #qInv#) NEQ #P_Total# (Invoice #P_invoice#)<BR>
	</CFMAIL>
</CFIF>

<CFIF IsDefined("EmailDuplicate")>
	<CFMAIL TO="mlaw@alcco.com" CC="SDavison@alcco.com" FROM="TIPS4-Message" SUBJECT="Balance Problem" TYPE="HTML">
		*** POSSIBLE DUPLICATE INVOICE *** 
		#P_period# EQ #qPeriod#<BR>
		#qsolkey# #qInv# #P_inv#<BR>
	</CFMAIL>
</CFIF>
=============================================================================== --->

