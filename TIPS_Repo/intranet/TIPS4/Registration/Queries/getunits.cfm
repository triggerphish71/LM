

<CFQUERY NAME="UNITS" DATASOURCE="CENSUS" DBTYPE="ODBC" CACHEDWITHIN="#CreateTimeSpan(0,0,5,0)#">
	Select * from units where nhouse = #variables.house# ORDER BY nUnitNumber
</CFQUERY>