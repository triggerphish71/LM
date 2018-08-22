<!--- -----------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
-----------------------------------------------------------------------------------------------|
| Sfarmer   | 11/06/2013  | removed references to census DB & leadtracking DB                  |
----------------------------------------------------------------------------------------------->

<cfinclude template="../application.cfm">
	<cfset tipsDsn = "TIPS4">
<cfif NOT IsDefined("application.datasource")>
	<cfset application.datasource = "TIPS4">
</cfif>

<!--- get the assessmsent tool admin group id --->
<cfquery name="GetAdminId" datasource="#application.datasource#">
	SELECT
		groupId
	FROM
		DMS.dbo.Groups
	WHERE
		groupname = 'Assessment Tool Admin'
</cfquery>

<cfset adminGroupId = GetAdminId.groupId>

<cfscript>
	//no session house defined but a house is selected  create the session house
	if(NOT isDefined("session.House") AND IsDefined("session.qSelectedHouse"))
	{
		House = CreateObject("Component","Components.House");
		House.Init(session.qSelectedHouse.iHouse_id,application.datasource);
	//	House.Init(session.qSelectedHouse.iHouse_id,application.datasource,application.leadtrackingdbserver,application.censusdbserver);

		session.House = House;
	}
	//session house defined and qselected house is defined and they don't match
	else if	((IsDefined("session.House") AND IsDefined("session.qSelectedHouse")) AND (session.House.GetId() neq session.qSelectedHouse.iHouse_ID))
	{
		House = CreateObject("Component","Components.House");
	//	House.Init(session.qSelectedHouse.iHouse_id,application.datasource,application.leadtrackingdbserver,application.censusdbserver);
		House.Init(session.qSelectedHouse.iHouse_id,application.datasource);		
		session.House = House;
	}
	//no session selected hosue defined, default to first session.houseaccesslist house
	else if(NOT isDefined("session.House") AND NOT isDefined("session.qSelectedHouse"))
	{
		House = CreateObject("Component","Components.House");
	//	House.Init(ListGetAt(session.houseaccesslist,1),application.datasource,application.leadtrackingdbserver,application.censusdbserver);
		House.Init(ListGetAt(session.houseaccesslist,1),application.datasource);
		
		session.House = House;
	}
	
// 	if(NOT IsDefined("session.leadTrackDsn"))
	//{
	//	session.leadTrackDsn = "LeadTracking";
	//} 
	
	if(NOT IsDefined("session.tipsmonth"))
	{
		session.tipsmonth1 = session.House.GetTipsMonth();
	}
	
	if(NOT IsDefined("session.HouseName"))
	{
		session.HouseName = session.House.GetName();
	}
	
	if(NOT IsDefined("session.HouseNumber"))
	{
		session.HouseNumber = NumberFormat(session.House.GetNumber() - 1800,000);
	}
	
	if(NOT IsDefined("session.nHouse"))
	{
		session.nHouse = session.House.GetNumber();
	}
	
	if(NOT IsDefined("session.cSLevelTypeSet"))
	{
		session.cSLevelTypeSet = session.House.GetSLevelTypeSet();
	}
	
	if(NOT IsDefined("session.HouseClosed"))
	{
		SESSION.HouseClosed	= session.House.GetIsClosed();
	}
	//mstriegel 7/31/18 begin
	session.houseType = session.house.getHouseType();	
	// mstriegel 7/31/18 end 
	
	//create the breadcrumbs variable
	session.breadcrumbs = '';
</cfscript>


<cfif NOT IsDefined("session.qSelectedHouse")>
	<cfquery name="qHouse" datasource="#APPLICATION.DataSource#">
		select 
			* 
		from 
			House H (NOLOCK)
		join  
			HouseLog HL (NOLOCK) ON (H.iHouse_ID = HL.iHouse_ID 
				AND 
			HL.dtRowDeleted IS NULL 
				AND 
			H.dtRowDeleted IS NULL)
		where 
			H.iHouse_ID = #session.House.GetId()#
	</cfquery>
	<cfset session.qSelectedHouse = qHouse>
	<cfset Session.TIPSMonth = qHouse.dtCurrentTipsMonth>

	<cfset session.oApprovalServices = CreateObject("component","intranet.TIPS4.CFC.components.admin.approvalServices")>
	

</cfif>
