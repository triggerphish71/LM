<SCRIPT>report = window.open("loading.htm","MoveInSummary","toolbar=no,resizable=yes"); report.moveTo(0,0);</SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, h.cName, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>
	
<CFOUTPUT>		
	<CFSET User="rw">
	<CFSET Password="4rwriter">

	<FORM NAME="MoveInSummary" ACTION="http://#crserver#/reports/tips/tips4/MoveInSummary.Rpt" METHOD="Post" TARGET="MoveInSummary"> 
		<INPUT TYPE="Hidden" NAME="user0" VALUE="#USER#">
		<INPUT TYPE="Hidden" NAME="password0" VALUE="#Password#">

		<INPUT TYPE="Hidden" NAME="user0@Prev_Trx2.Rpt" VALUE="#USER#">
		<INPUT TYPE="Hidden" NAME="password0@Prev_Trx2.Rpt" VALUE="#Password#">			

		<INPUT TYPE="Hidden" NAME="user0@AddedCharges.Rpt" VALUE="#USER#">
		<INPUT TYPE="Hidden" NAME="password0@AddedCharges.Rpt" VALUE="#Password#">

		<INPUT TYPE="Hidden" NAME="user0@DepositSub.Rpt" VALUE="#USER#">
		<INPUT TYPE="Hidden" NAME="password0@DepositSub.Rpt" VALUE="#Password#">			

		<INPUT TYPE="Hidden" NAME="user0@FeesSub.Rpt" VALUE="#USER#">
		<INPUT TYPE="Hidden" NAME="password0@FeesSub.Rpt" VALUE="#Password#">

		<INPUT TYPE="Hidden" NAME="user0@HouseInfo" VALUE="#USER#">
		<INPUT TYPE="Hidden" NAME="password0@HouseInfo" VALUE="#Password#">			

		<INPUT TYPE="Hidden" NAME="user0@InvoiceContactSubReport.rpt" VALUE="#USER#">
		<INPUT TYPE="Hidden" NAME="password0@InvoiceContactSubReport.rpt" VALUE="#Password#">			

		<INPUT TYPE="Hidden" NAME="user0@ProRatedRent.Rpt" VALUE="#USER#">
		<INPUT TYPE="Hidden" NAME="password0@ProRatedRent.Rpt" VALUE="#Password#">	

		<INPUT TYPE="Hidden" NAME="user0@RentsSub.Rpt" VALUE="#USER#">
		<INPUT TYPE="Hidden" NAME="password0@RentsSub.Rpt" VALUE="#Password#">

		<INPUT TYPE="Hidden" NAME="user0@getOccupancy" VALUE="#USER#">
		<INPUT TYPE="Hidden" NAME="password0@getOccupancy" VALUE="#Password#">

		<INPUT TYPE="Hidden" NAME="user0@srMoveInAddendum" VALUE="#USER#">
		<INPUT TYPE="Hidden" NAME="password0@srMoveInAddendum" VALUE="#Password#">


		<INPUT TYPE="Hidden" NAME="prompt0" VALUE="#form.prompt0#">
		
		<SCRIPT> location.href='#HTTP_REFERER#'; document.MoveInSummary.submit(); </SCRIPT>
		
	</FORM>
</CFOUTPUT>