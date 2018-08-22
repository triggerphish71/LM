<CFSET Cachetime=CreateTimeSpan(0, 0, 0, 30)>

<CFQUERY NAME="DepositSlips" DATASOURCE="#APPLICATION.datasource#" CACHEDWITHIN="#Cachetime#">
	SELECT distinct CM.*
	FROM CashReceiptMaster CM (NOLOCK)
	JOIN CashReceiptDetail CD (NOLOCK) ON (CD.iCashReceipt_ID = CM.iCashReceipt_ID AND CD.dtRowDeleted IS NULL)
	WHERE CM.iHouse_ID <> 200
	AND CM.dtRowDeleted IS NULL AND CM.bFinalized IS NOT NULL
	AND DATEPART(mm, CM.dtRowStart) = 9
	AND DATEPART(yy, CM.dtRowSTart) = 2003
	ORDER BY iHouse_ID, CM.iCashReceiptNumber desc
</CFQUERY>

<CFOUTPUT>

<TABLE STYLE="width: 1%;">
	<TR>
		<TD STYLE="width: 25%;" NOWRAP>	<B>House Number</B>	</TD>
		<TD STYLE="width: 25%;" NOWRAP>	<B>Date Finalized(PST)</B>	</TD>
		<TD NOWRAP STYLE="text-align:right;"><B>Deposit Total</B></TD>
	</TR>
	
	<CFQUERY NAME="CashDetail_Summary" DATASOURCE="#APPLICATION.datasource#">
		SELECT	Distinct CD.iCashReceiptItem_ID, CD.dtRowStart, CD.iCashReceiptItem_ID, CM.dtRowstart as FinalizedDate, CM.iCashReceipt_ID
				,(select sum(mAmount) from cashreceiptdetail where dtrowdeleted is null and icashreceipt_id = cm.icashreceipt_id) as receipttotal
		FROM	CashReceiptDetail CD (NOLOCK)
		JOIN	CashReceiptMaster CM (NOLOCK) ON (CM.iCashReceipt_ID = CD.iCashReceipt_ID AND CD.dtRowDeleted IS NULL AND CM.dtRowDeleted IS NULL)
		WHERE	CM.bFinalized is not null and CM.iHouse_ID <> 200
		AND DATEPART(mm, CM.dtRowStart) = 9
		AND DATEPART(yy, CM.dtRowSTart) = 2003
		GROUP BY CD.dtRowStart, CD.iCashReceiptItem_ID, CM.dtRowStart, CM.iCashReceipt_id
	</CFQUERY>	
	
	<CFLOOP QUERY="DepositSlips">
		
			<CFQUERY NAME="CashDetail" DBTYPE='QUERY'>
				SELECT * FROM CashDetail_Summary WHERE iCashReceipt_ID = #DepositSlips.iCashReceipt_ID#
			</CFQUERY>
		
		<CFSET FORMNAME='Slip' & #DepositSlips.iCashReceiptNumber#>
			<cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE">
				<TD NOWRAP>	#DepositSlips.iHouse_ID#	</TD>
				<TD NOWRAP>	#CashDetail.FinalizedDate#	</TD>
				<TD STYLE="text-align:right;">#LSCurrencyFormat(CashDetail.receipttotal)#</TD>
			</cf_ctTR>
	</CFLOOP>
	
</TABLE>

</CFOUTPUT>