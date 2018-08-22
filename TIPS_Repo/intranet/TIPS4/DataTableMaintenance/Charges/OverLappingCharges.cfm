

<CFOUTPUT>

<!--- ==============================================================================
Retrieve House List
=============================================================================== --->
<CFQUERY NAME="qOverLapping" DATASOURCE="#APPLICATION.datasource#">
	SELECT	distinct C.iHouse_ID
			,H.cName
			,SLT.cSLevelTypeSet
			,iAptType_ID
			,iOccupancyPosition
			,mAmount
			,C.iSLevelType_ID
			,C.iChargeType_ID
			,dteffectivestart
			,dteffectiveend
			,C.iCharge_ID
	FROM	Charges C
	JOIN	SLevelType SLT ON (SLT.iSLevelType_ID = C.iSLevelType_ID AND SLT.dtRowDeleted IS NULL)
	JOIN	House H ON (C.iHouse_ID = H.iHouse_ID AND H.dtRowDeleted IS NULL)
	WHERE	C.dtRowDeleted IS NULL
	ORDER BY H.cName ,iAptType_ID ,iOccupancyPosition ,SLT.cSLevelTypeSet ,C.iSLevelType_ID ,C.mAmount ,C.iChargeType_ID ,C.dteffectivestart, C.dteffectiveend 
</CFQUERY>

<CFSET width="width:1%;background:gainsboro;">
<CFSET bottomborder = "border-bottom:1px solid navy;">
<TABLE CELLPADDING=3 CELLSPACING=0 STYLE="border:1px solid navy; width: 1%;">
<TR>
	<TH STYLE="#width#">refID</TH>
	<TH STYLE="#width#">House</TH>
	<TH STYLE="#width#">Level Set</TH>
	<TH STYLE="#width#">Apt type ID</TH>
	<TH STYLE="#width#">Occupancy Position</TH>
	<TH STYLE="#width#">Level type id</TH>
	<TH STYLE="#width#">Charge type id</TH>
	<TH STYLE="#width#">Amount</TH>
	<TH STYLE="#width#">Eff. start</TH>
	<TH STYLE="#width#">Eff.end</TH>
</TR>
<CFSET lastchargeid=''>
<CFSET lasthouse = ''>
<CFSET lasthousename = ''>
<CFSET lastlevelset = ''>
<CFSET lastapttype = ''>
<CFSET lastposition = ''>
<CFSET lastamount = ''>
<CFSET lastleveltypeid = ''>
<CFSET lastchargetype = ''>
<CFSET laststart = ''>
<CFSET lastend = ''>
<CFSET lastrefhousename=''>
<CFLOOP QUERY="qOverLapping">
	<CFIF (qOverLapping.iHouse_ID EQ lasthouse) 
		AND ((qOverLapping.dteffectivestart LTE lastend) AND (qOverLapping.dteffectivestart GTE laststart)) 
		AND (lastlevelset EQ qOverLapping.cSLevelTypeSet)
		AND (lastapttype EQ qOverLapping.iAptType_ID)
		AND (lastposition EQ qOverLapping.iOccupancyPosition)
		AND (lastamount NEQ qOverLapping.mAmount)
		AND (lastleveltypeid EQ qOverLapping.iSLevelType_ID)
		AND	(lastchargetype EQ qOverLapping.iChargeType_ID)
		>
		<CFIF qOverLapping.cName NEQ lastrefhousename><TR><TD COLSPAN=100% STYLE="#bottomborder#">&nbsp;</TD></TR></CFIF>
		<TR><TD NOWRAP COLSPAN=100% STYLE="background:gainsboro;"><CFIF qOverLapping.cName NEQ lastrefhousename>#lasthousename#</CFIF></TD></TR>
		<TR>
			<TD>#lastchargeid#</TD>
			<TD></TD>
			<TD>#lastlevelset#</TD>
			<TD>#lastapttype#</TD>
			<TD>#lastposition#</TD>
			<TD>#lastleveltypeid#</TD>
			<TD>#lastchargetype#</TD>
			<TD>#LSCurrencyFormat(lastamount)#</TD>
			<TD>#DateFormat(laststart,"mm/dd/yyyy")#</TD>
			<TD><B>#DateFormat(lastend,"mm/dd/yyyy")#</B></TD>
		</TR>
		<TR>
			<TD STYLE="#bottomborder#">#qOverLapping.iCharge_ID#</TD>
			<TD STYLE="#bottomborder#">&nbsp;</TD>
			<TD STYLE="#bottomborder#">#qOverLapping.cSLevelTypeSet#</TD>
			<TD STYLE="#bottomborder#">#IsBlank(qOverLapping.iAptType_ID,'&nbsp;')#</TD>
			<TD STYLE="#bottomborder#">#qOverLapping.iOccupancyPosition#</TD>
			<TD STYLE="#bottomborder#">#qOverLapping.iSLevelType_ID#</TD>
			<TD STYLE="#bottomborder#">#qOverLapping.iChargeType_ID#</TD>
			<TD STYLE="#bottomborder#">#LSCurrencyFormat(qOverLapping.mAmount)#</TD>
			<TD STYLE="#bottomborder#"><B>#DateFormat(qOverLapping.dteffectivestart,"mm/dd/yyyy")#</B></TD>
			<TD STYLE="#bottomborder#">#DateFormat(qOverLapping.dtEffectiveEnd,"mm/dd/yyyy")#</TD>
		</TR>
		<CFSET lastrefhousename = qOverlapping.cName>
	</CFIF>
	
	<CFSET lastchargeid = qOverLapping.iCharge_ID>
	<CFSET lasthouse = qOverLapping.iHouse_ID>
	<CFSET lasthousename = qOverLapping.cName>
	<CFSET lastlevelset = qOverLapping.cSLevelTypeSet>
	<CFSET lastapttype = qOverLapping.iAptType_ID>
	<CFSET lastposition = qOverLapping.iOccupancyPosition>
	<CFSET lastamount = qOverLapping.mAmount>
	<CFSET lastleveltypeid = qOverLapping.iSLevelType_ID>
	<CFSET lastchargetype = qOverLapping.iChargeType_ID>
	<CFSET laststart = qOverLapping.dteffectivestart>
	<CFSET lastend = qOverLapping.dteffectiveend>
	
</CFLOOP>
</TABLE>

</CFOUTPUT>