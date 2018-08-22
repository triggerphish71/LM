<SCRIPT>
	window.open("loading.htm","MoveInReport","toolbar=no,resizable=yes");
</SCRIPT>
<!--- 
 |S Farmer    | 09/08/2014 | 116824             | Allow all houses edit BSF and Community Fee Rates |
 --->
<CFQUERY NAME="TenantInfo" DATASOURCE="#APPLICATION.datasource#">
	SELECT * FROM Tenant WHERE dtRowDeleted IS NULL AND iTenant_ID = #url.ID#
</CFQUERY>	

<CFOUTPUT>		
	<CFSET User="rw">
	<CFSET Password="4rwriter">

	<FORM NAME="MoveIn" ACTION="http://#crserver#/reports/tips/tips4/MoveInSummary.Rpt" METHOD="Post" TARGET="MoveInReport"> 
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

		<!--
		<INPUT TYPE="Hidden" NAME="user0@GetInvoiceAmount.Rpt" VALUE="#USER#">
		<INPUT TYPE="Hidden" NAME="password0@GetInvoiceAmount.rpt" VALUE="#Password#">				

		<INPUT TYPE="Hidden" NAME="prompt0" VALUE="#TenantInfo.iHouse_ID#">
		<INPUT TYPE="Hidden" NAME="prompt1" VALUE="#TenantInfo.iTenant_ID#">	
		-->
		<INPUT TYPE="Hidden" NAME="prompt0" VALUE="#TenantInfo.iTenant_ID#">	
		
		<SCRIPT>
			location.href='#HTTP_REFERER#';
			document.MoveIn.submit();
		</SCRIPT> 
		
	</FORM>
</CFOUTPUT>