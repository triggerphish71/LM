<!--- ==============================================================================
Retrieve list of Available Apartments (less than 2 people in an Apartment
=============================================================================== --->
<CFQUERY NAME="Available" DATASOURCE="#APPLICATION.datasource#">
	SELECT 	*
	FROM 	APTADDRESS AD (NOLOCK)
	JOIN 	APTTYPE AP ON (AP.iAptType_ID = AD.iAptType_ID AND AD.dtRowDeleted IS NULL)
	WHERE 	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	ORDER BY cAptNumber
</CFQUERY>


