<cfparam name="residentId" default="0">
<cfparam name="tenantId" default="0">
<cfscript>
	Resident = CreateObject("Component","Components_OLD.Resident");
	Resident.Init(residentId,tenantId,session.leadTrackDsn,application.datasource,application.leadtrackingdbserver,application.censusdbserver);
</cfscript>