<SCRIPT>
	function fontsz(){
		if (document.all['Layer'].style.visibility == 'visible') {
			document.all['Layer'].style.visibility = 'hidden';
		}
		else{ document.all['Layer'].style.visibility = 'visible';
		}
	}
</SCRIPT>

<!--- ==============================================================================
Obtain all the rates for the house by SLevelSet, Level, ResidencyType
=============================================================================== --->
<CFQUERY NAME="qMonthlyRates" DATASOURCE="#APPLICATION.datasource#">
	SELECT	C.cDescription as ChargeDescription, ST.cDescription as LevelDescription, CT.cDescription, C.iOccupancyPosition
			,CASE
				WHEN CT.bSLevelType_ID IS NULL THEN 'n/a' ELSE ST.cSlevelTypeSet 
			END as cSlevelTypeSet, C.mAmount, C.iQuantity, C.dtEffectiveStart, C.dtEffectiveEnd
	FROM	CHARGES C	
	JOIN 	ChargeType CT 	ON C.iChargeType_ID = CT.iChargeType_ID
	JOIN 	HOUSE H			ON C.iHouse_ID =  H.iHouse_ID
	JOIN	SLevelType ST	ON (ST.iSLevelType_ID = C.iSLevelType_ID OR	C.iSlevelType_ID IS NULL)
	WHERE	C.dtRowDeleted IS NULL
	AND	CT.dtRowDeleted IS NULL
	AND	H.dtRowDeleted IS NULL
	AND	ST.dtRowDeleted IS NULL
	AND	CT.bIsRent IS NOT NULL AND CT.bIsDaily IS NULL
	AND	C.iHouse_ID IS NOT NULL
	AND	C.iHouse_ID =  178
	ORDER BY   C.cSLevelTypeSet, ST.cDescription, C.iResidencyType_ID, 
	CT.cDescription, C.iOccupancyPosition
</CFQUERY>


<!--- ==============================================================================
Retrieve Service Level Sets (for pick list)
=============================================================================== --->
<CFQUERY NAME="qSetList" DATASOURCE="#APPLICATION.datasource#">
	SELECT	distinct cSLevelTypeSet
	FROM	SLevelType
	WHERE	dtRowDeleted IS NULL
</CFQUERY>

<CFSET SetList = ''>
<CFOUTPUT QUERY="qSetList">
	<CFSET SetList = '#SetList#' & ',' & '#qSetList.cSLevelTypeSet#'>
</CFOUTPUT>

<!--- ==============================================================================
TEST AREA
=============================================================================== --->
<CFOUTPUT>
	<INPUT TYPE="BUTTON" NAME="FONT" VALUE="Font" ONCLICK="fontsz();">
	<FORM ID="Layer" NAME="page">
	
	<TABLE border=1>
		<TR>
			<TH COLSPAN="100%">Monthly Rent</TH>
		</TR>
		<TR>
			<TD>SLvlSet</TD>
			<TD>Description</TD>
			<TD>SLvl</TD>
			<TD>Position</TD>
			<TD>Amount</TD>
			<TD>Qty.</TD>
			<TD>Start</TD>
			<TD>End</TD>
		</TR>
		<CFLOOP QUERY="qMonthlyRates">
			<TR>
				<TD>
					<SCRIPT>
						function SetValidate(string){
						alert(string.value);
						if (string.value.length == 0){ 
							string.value= 'null';
						}
						<CFLOOP INDEX="nLevel" LIST="#SetList#" DELIMITERS=",">
							else if (string.value !== #nLeveL#) { 
								string.value = 'else';
							}
						</CFLOOP>
						}
					</SCRIPT>
					<INPUT TYPE="Text" NAME="cSLevelTypeSet" MaxLength="2" Size="1" VALUE="#TRIM(qMonthlyRates.cSLevelTypeSet)#" onBlur="SetValidate(this);">
				</TD>
				<TD>#qMonthlyRates.ChargeDescription#</TD>
				<TD>#qMonthlyRates.LevelDescription#</TD>
				<TD>#qMonthlyRates.iOccupancyPosition#</TD>
				<TD STYLE="text-align: right;">
					#NumberFormat(qMonthlyRates.mAmount,"-999999999.99")#
				</TD>
				<TD>#qMonthlyRates.iQuantity#</TD>
				<TD STYLE="text-align: right;">
					#DateFormat(qMonthlyRates.dtEffectiveStart,"mm/dd/yyyy")#
				</TD>
				<TD STYLE="text-align: right;">
					#DateFormat(qMonthlyRates.dtEffectiveEnd,"mm/dd/yyyy")#
				</TD>
			</TR>
		</CFLOOP>
	</TABLE>
	</FORM>
</CFOUTPUT>

<!--- ==============================================================================
<SCRIPT>
	alert(document.body.clientWidth);
</SCRIPT>
=============================================================================== --->