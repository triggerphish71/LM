

<CFOUTPUT>

<!--- ==============================================================================
Retrieve All currently entered rates for this house
=============================================================================== --->
<CFQUERY NAME="qRates" DATASOURCE="TIPS4">
	SELECT	C.cDescription as chargedescription
		,AP.iAptType_ID as apttype
		,ST.cSLevelTypeSet as slevelset
		,C.dtEffectiveStart as startdate
		,C.dtEffectiveEnd as enddate
		,ST.cDescription as level
	FROM	Charges C
	JOIN	ChargeType CT ON (CT.iChargeType_ID = C.iChargeType_ID AND C.dtRowDeleted IS NULL AND CT.dtRowDeleted IS NULL)
	LEFT JOIN AptType AP ON (AP.iAptType_ID = C.iAptType_ID AND AP.dtRowDeleted IS NULL) 
	LEFT JOIN SLevelType ST ON (C.iSLevelType_ID = ST.iSLevelType_ID AND ST.dtRowDeleted IS NULL)
	WHERE	C.dtRowDeleted IS NULL
	AND	C.iHouse_ID = 181
	AND	CT.bIsRent IS NOT NULL
	ORDER BY ST.cSLevelTypeSet
		,dtEffectiveStart
		,dtEffectiveEnd
		,iOccupancyPosition
		,ST.cDescription
</CFQUERY>

<CFQUERY NAME="qSets" DBTYPE="QUERY">
	SELECT	distinct slevelset FROM  qRates
</CFQUERY>
<CFSET Sets = Valuelist(qSets.slevelSet)>
#Sets#<BR>

<CFQUERY NAME="qAptTypes" DBTYPE="QUERY">
	SELECT	distinct apttype FROM qRates
</CFQUERY>
<CFSET apttypes = Valuelist(qAptTypes.apttype)>
#apttypes#<BR>

<CFQUERY NAME="qAptTypes" DBTYPE="QUERY">
	SELECT	distinct level FROM qRates
</CFQUERY>
<CFSET levels = Valuelist(qAptTypes.level)>
#Levels#<BR>

<CFQUERY NAME="qPeriods" DBTYPE="QUERY">
	SELECT	distinct startdate, enddate FROM qRates
</CFQUERY>

<SELECT	NAME="Periods">
	<CFLOOP QUERY="qPeriods">
		<OPTION VALUE="#qPeriods.startdate#,#qPeriods.enddate#">
			#DateFormat(qPeriods.startdate,"mm/dd/yyyy")# to #DateFormat(qPeriods.enddate,"mm/dd/yyyy")#
		</OPTION>
	</CFLOOP>
</SELECT>
<BR>
<CFLOOP INDEX=Sets LIST="#sets#" DELIMITERS=",">
	<CFSET set = Sets>
	<CFLOOP INDEX=apttypes LIST="#apttypes#" DELIMITERS=",">
		<CFSET apttype = apttypes>
		<CFLOOP INDEX=levels LIST="#sets#" DELIMITERS=",">
			<CFQUERY NAME="qData" DBTYPE="QUERY">
				SELECT	*
				FROM	qRates
				WHERE	slevelset = #set#
				AND		apttype = #apttype#
				AND		level = #levels#
			</CFQUERY>
			<B>#qData.slevelset# #qData.Apttype# #qData.level# #qData.recordcount#</B>
		</CFLOOP>
	</CFLOOP>
</CFLOOP>



</CFOUTPUT>