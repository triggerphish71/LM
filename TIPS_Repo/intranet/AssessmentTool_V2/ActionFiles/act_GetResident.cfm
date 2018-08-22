<!--- -----------------------------------------------------------------------------------------|
| Sfarmer   | 10/18/2013  |Proj. 102481 removed Walnut db and tables Census & Leadtracking     |
----------------------------------------------------------------------------------------------->
<cfparam name="residentId" default="0">
<cfparam name="tenantId" default="0">
<cfscript>
	Resident = CreateObject("Component","Components.Resident");
//	Resident.Init(residentId,tenantId,session.leadTrackDsn,application.datasource,application.leadtrackingdbserver,application.censusdbserver);
//	Resident.Init(tenantId,application.datasource);
	Resident.Init(tenantId,application.datasource,application.datasource);
	getResidentMoveInDate = Resident.getMoveIn();
	
</cfscript>