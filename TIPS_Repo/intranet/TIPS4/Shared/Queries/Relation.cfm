

<!--- ==============================================================================
Retrieves the RelationShip Types
=============================================================================== --->
<CFQUERY NAME = "RelationShips" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	iRelationshipType_ID, cDescription
	FROM	RelationShipType
</CFQUERY>