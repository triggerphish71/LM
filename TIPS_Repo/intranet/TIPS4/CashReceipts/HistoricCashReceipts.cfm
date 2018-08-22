
<CFINCLUDE TEMPLATE="../../header.cfm">
<CFSET Cachetime=CreateTimeSpan(0, 0, 0, 30)>

<SCRIPT> function newwin(){ window.open('','CashReceipts','resizable=no,menubar=no'); } </SCRIPT>

<CFQUERY NAME="DepositSlips" DATASOURCE="#APPLICATION.datasource#" CACHEDWITHIN="#Cachetime#">
	SELECT distinct CM.*
	FROM CashReceiptMaster CM (NOLOCK)
	JOIN CashReceiptDetail CD (NOLOCK) ON (CD.iCashReceipt_ID = CM.iCashReceipt_ID AND CD.dtRowDeleted IS NULL)
	WHERE iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	AND CM.dtRowDeleted IS NULL AND CM.bFinalized IS NOT NULL
	ORDER BY CM.iCashReceiptNumber desc
</CFQUERY>
<BR>
<CFOUTPUT>

<TABLE STYLE="width: 1%;">
	<TH COLSPAN=100%>	Historic Cash Receipts for #SESSION.HouseName#	</TH>
	<TR>
		<TD STYLE="width: 25%;" NOWRAP>	<B>Number</B>	</TD>
		<TD STYLE="width: 25%;" NOWRAP>	<B>Date Finalized(PST)</B>	</TD>
		<TD STYLE="width: 25%; text-align: center;" NOWRAP>	<B>## Of Checks</B>	</TD>
		<TD NOWRAP STYLE="text-align:right;"><B>Deposit Total</B></TD>
		<TD STYLE="width: 25%;" NOWRAP>	<B>View Deposit Slip</B></TD>
	</TR>
	
	<CFQUERY NAME="CashDetail_Summary" DATASOURCE="#APPLICATION.datasource#">
		SELECT	Distinct CD.iCashReceiptItem_ID, CD.dtRowStart, CD.iCashReceiptItem_ID, CM.dtRowstart as FinalizedDate, CM.iCashReceipt_ID
				,(select sum(mAmount) from cashreceiptdetail where dtrowdeleted is null and icashreceipt_id = cm.icashreceipt_id) as receipttotal
		FROM	CashReceiptDetail CD (NOLOCK)
		JOIN	CashReceiptMaster CM (NOLOCK) ON (CM.iCashReceipt_ID = CD.iCashReceipt_ID AND CD.dtRowDeleted IS NULL AND CM.dtRowDeleted IS NULL)
		WHERE	CM.bFinalized is not null and CM.iHouse_ID = #SESSION.qSelectedHouse.ihouse_id#
		GROUP BY CD.dtRowStart, CD.iCashReceiptItem_ID, CM.dtRowStart, CM.iCashReceipt_id
	</CFQUERY>	
	
	<CFLOOP QUERY="DepositSlips">
		
			<CFQUERY NAME="CashDetail" DBTYPE='QUERY'>
				SELECT * FROM CashDetail_Summary WHERE iCashReceipt_ID = #DepositSlips.iCashReceipt_ID#
			</CFQUERY>
<!---
			<CFQUERY NAME="CashDetail" DATASOURCE="#APPLICATION.datasource#">
				SELECT	Distinct CD.dtRowStart, CD.iCashReceiptItem_ID, CM.dtRowstart as FinalizedDate
						,(select sum(mAmount) from cashreceiptdetail where dtrowdeleted is null and icashreceipt_id = cm.icashreceipt_id) as receipttotal
				FROM	CashReceiptDetail CD (NOLOCK)
				JOIN	CashReceiptMaster CM (NOLOCK) ON (CM.iCashReceipt_ID = CD.iCashReceipt_ID AND CD.dtRowDeleted IS NULL AND CM.dtRowDeleted IS NULL)
				WHERE	CD.iCashReceipt_ID = #DepositSlips.iCashReceipt_ID#
				GROUP BY CD.dtRowStart, CD.iCashReceiptItem_ID, CM.dtRowStart, CM.iCashReceipt_id
			</CFQUERY>
--->
	
		<CFSET FORMNAME='Slip' & #DepositSlips.iCashReceiptNumber#>
		<FORM NAME="#FormName#"	ACTION="http://#crserver#/reports/tips/tips4/depositslip.rpt" TARGET="CashReceipts" METHOD="POST">
			<cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE">
				<TD NOWRAP>	#DepositSlips.iCashReceiptNumber#	</TD>
				<TD NOWRAP>	#CashDetail.FinalizedDate#	</TD>
				<TD NOWRAP STYLE="text-align: center;">	#CashDetail.RecordCount#</TD>
				<TD STYLE="text-align:right;">#LSCurrencyFormat(CashDetail.receipttotal)#</TD>
				<TD NOWRAP STYLE="text-align: center;">
					<INPUT CLASS="BlendedButton" STYLE="color: Navy;" TYPE="Button" NAME="Submit" VALUE="View Now" onClick="newwin(); submit();">
				</TD>
			</cf_ctTR>
			<INPUT TYPE="Hidden" NAME="user0" VALUE="rw">
			<INPUT TYPE="Hidden" NAME="password0" VALUE="4rwriter">						
			<INPUT TYPE="Hidden" NAME="prompt0" VALUE="#SESSION.nHouse#">
			<INPUT TYPE="Hidden" NAME="prompt1" VALUE="#DepositSlips.iCashReceiptNumber#">
		</FORM>
	</CFLOOP>
	
</TABLE>
<BR>


</CFOUTPUT>

<CFINCLUDE TEMPLATE="../../footer.cfm">
