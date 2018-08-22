



<!--- ==============================================================================
Retrieve list of all current Houses
=============================================================================== --->
<CFQUERY NAME = "Houses" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM 	HOUSE
	WHERE	dtRowDeleted IS NULL
	ORDER BY cName
</CFQUERY>