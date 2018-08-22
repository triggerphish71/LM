


<!--- ==============================================================================
Retreive list of current room types
=============================================================================== --->
<CFQUERY NAME = "ApartmentTypes" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	APTTYPE
	WHERE	dtRowDeleted IS NULL
</CFQUERY>