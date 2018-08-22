<!--- ==================================================================================================
After discussion with stevea added calc to get last period completed to run report.
Paul Buendia	12/30/02
================================================================================================== --->

<SCRIPT>window.open("blank.htm","ChargesProposed","toolbar=no,resizable=yes");</SCRIPT>

<CFOUTPUT>

	<CFSET User="rw">
	<CFSET Password="4rwriter">
	<CFSET tmpLastPeriod = DateAdd('m', -1, SESSION.TipsMonth)>
	<CFSET LastPeriod = DateFormat(tmpLastPeriod,'yyyymm')>
	
		<FORM NAME="ChargesProposed" ACTION="//#crserver#/reports/tips/tips4/ChargesProposed.rpt" METHOD="POST" TARGET="ChargesProposed">
			<INPUT TYPE="Hidden" NAME="init" value="actx">
			<INPUT TYPE="Hidden" NAME="promptOnRefresh" value=1>
			<INPUT TYPE="Hidden" NAME="rf" value=1>
			<INPUT TYPE="Hidden" NAME="user0" value="#user#">
			<INPUT TYPE="Hidden" NAME="password0" value="#Password#">
			<INPUT TYPE="Hidden" NAME="prompt0" VALUE="Y">
			<INPUT TYPE="Hidden" NAME="prompt1" VALUE="N">
			<INPUT TYPE="Hidden" NAME="prompt2" VALUE="#SESSION.HouseName#">
			<INPUT TYPE="Hidden" NAME="prompt3" VALUE="#LastPeriod#">			
			<INPUT TYPE="Hidden" NAME="prompt4" VALUE="">			
			
			<SCRIPT>
				location.href='#HTTP_REFERER#'
				document.ChargesProposed.submit();
			</SCRIPT>
		</FORM>
</CFOUTPUT>

	

