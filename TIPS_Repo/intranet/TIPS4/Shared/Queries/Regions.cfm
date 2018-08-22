


<!--- ==============================================================================
Retreive all information for defined regions
=============================================================================== --->
<CFQUERY NAME = "Regions" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	REGION
	WHERE	dtRowDeleted IS NULL
</CFQUERY>