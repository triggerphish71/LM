


<!--- ==============================================================================
Retrieve all Available Residency Types
=============================================================================== --->
<CFQUERY NAME = "Residency" DATASOURCE = "#APPLICATION.datasource#">
	SELECT * FROM ResidencyType WHERE dtrowdeleted is null ORDER BY iDisplayOrder
</CFQUERY>