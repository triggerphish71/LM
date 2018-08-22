 <!---  ----------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|S Farmer    | 08-1-2013  | Program to allow AR to directly change move out dates Ticket#109102|
|Mstriegel   | 03/10/2018 | Converted the logic to use a cfc                                   |
----------------------------------------------------------------------------------------------->
<!--- mstriegel 3/10/2018 --->
<cfset oTenantARServices = CreateObject("component","intranet.TIPS4.CFC.components.Tenant.tenantARServices")>


<cfparam name="form.moveoutdate" default="">
<cfparam name="form.projectmoveoutdate" default="">
<cfparam name="form.chargedate" default="">

<cfset oTenantARServices.saveTenantAREditData(moveoutdate=form.moveoutdate,chargedate=form.chargedate,projectmoveoutdate=form.projectmoveoutdate,tenantid=form.tenantId)>

<cfoutput><cflocation url="EditMoveOutDates.cfm?solomonid=#csolomonkey#"></cfoutput>

<!--- 
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>upd MoveOut Dates</title>
</head>
<body>
<cfif ((isDefined('moveoutdate')) and (moveoutdate is not ""))>
	<cfquery name="updmoveoutdates" datasource="#application.datasource#">
		update tenantstate
		set 
			dtMoveOut = <cfqueryparam value="#moveoutdate#" cfsqltype="cf_sql_date">
		where itenant_id = #tenantid#
	</cfquery>
</cfif>
<cfif ((isDefined('chargedate')) and (chargedate is not ""))>
	<cfquery name="updmoveoutdates" datasource="#application.datasource#">
		update tenantstate
		set 
			dtChargeThrough = <cfqueryparam value="#chargedate#" cfsqltype="cf_sql_date"> 
		where itenant_id = #tenantid#
	</cfquery>
</cfif>
<cfif ((isDefined('projectmoveoutdate')) and (projectmoveoutdate is not ""))>
	<cfquery name="updmoveoutdates2" datasource="#application.datasource#">
		update tenantstate
		set 
		dtMoveOutProjectedDate = <cfqueryparam value="#projectmoveoutdate#" cfsqltype="cf_sql_date"> 
		where itenant_id = #tenantid#
	</cfquery>
</cfif>
<cfoutput><cflocation url="EditMoveOutDates.cfm?solomonid=#csolomonkey#"></cfoutput>
</body>
</html>
--->
<!--- end mstriegel 3/10/2018--->