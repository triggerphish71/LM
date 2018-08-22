



<CFTRANSACTION>

<CFQUERY NAME = "GetHouseNumbers" DATASOURCE = "TIPS4">
	SELECT	iHouse_ID
	FROM	House
	Order By iHouse_ID
</CFQUERY>


<CFOUTPUT QUERY = "GetHouseNumbers">

	<CFQUERY NAME = "PrimingMonthOf" DATASOURCE = "#APPLICATION.datasource#">
	Insert Into HouseLog
			(
				iHouse_ID,
				dtCurrentTipsMonth,
				bIsPDclosed,
				bIsOpsMgrClosed,
				dtActualEffective,
				cComments,
				dtAcctStamp,
				iRowStartUser_ID,
				dtRowStart
			)
			Values
			(
				#GetHouseNumbers.iHouse_ID#,
				#CreateODBCDateTime('2001-07-01')#,
				NULL,
				NULL,
				NULL,
				NULL,
				#CreateODBCDateTime(SESSION.AcctStamp)#,
				#SESSION.UserID#,
				GetDate()
			)

	</CFQUERY>

</CFOUTPUT>

</CFTRANSACTION>
