<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| To approve or disapprove tenants for a house daily and insert records in database tables.    |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| gthota     | 09/06/2017 | Created new page                             |
----------------------------------------------------------------------------------------------->

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
<!---  CreateODBCDateTime(now()) --->
<cfif not isDefined("session.qselectedhouse.ihouse_id") or not isDefined("session.userid")>
	<cflocation url="../../Loginindex.cfm" addtoken="yes">
</cfif>

<!--- Include Intranet header --->
<cfinclude template="../../header.cfm">

<cfquery name="checkhouse" datasource="#application.datasource#">
	select * from [dbo].[RL_RES_STG]	WHERE ToHouseID = #SESSION.qSelectedHouse.iHouse_ID#
</cfquery>	

<!--- <cfset timestamp = now()> --->

<cfif isDefined("form.approve") and not isDefined("form.disapprove")>

	<cfquery name="approvequery" datasource="#APPLICATION.datasource#">
		insert into DailyCensus_RL
		(
		rl_fromHouse_ID
		,rl_toHouse_ID
		, Census_Date
		, House_Admin
		, Approve_Disapprove
		, Record_Count
		, iRowStartUser_ID
		, dtRowStart
		, iRowEndUser_ID
		, dtRowEnd
		, iRowDeletedUser_ID
		, dtRowDeleted
		, cRowStartUser_ID
		, cRowEndUser_ID
		, cRowDeletedUser_ID
		)
		values
		(
		#checkhouse.FromHouseID#
		,#SESSION.qSelectedHouse.iHouse_ID#
		, '#dtCompare#'
		, #session.userid#
		, 'A'
		, #countrecord#
		, #session.userid#
		, getdate()
		, NULL
		, NULL
		, NULL
		, NULL
		, 'CensusApprove'
		, NULL
		, NULL
		)
	</cfquery>
		<cflocation url="census.cfm" addtoken="no">
<cfelseif isDefined("form.disapprove") and not isDefined("form.approve")>
	<cfquery name="disapprovequery" datasource="#APPLICATION.datasource#">
		insert into DailyCensus_RL
		(
		iHouse_ID
		, Census_Date
		, House_Admin
		, Approve_Disapprove
		, Record_Count
		, iRowStartUser_ID
		, dtRowStart
		, iRowEndUser_ID
		, dtRowEnd
		, iRowDeletedUser_ID
		, dtRowDeleted
		, cRowStartUser_ID
		, cRowEndUser_ID
		, cRowDeletedUser_ID
		)
		values
		(
		#SESSION.qSelectedHouse.iHouse_ID#
		, '#dtCompare#'
		, #session.userid#
		, 'D'
		, #countrecord#
		, #session.userid#
		, getdate()
		, NULL
		, NULL
		, NULL
		, NULL
		, 'CensusDisapprove'
		, NULL
		, NULL
		)
	</cfquery>
	<cflocation url="census.cfm" addtoken="no">
<cfelse>


</cfif>

</body>
</html>
<!--- Include Intranet footer --->
<cfinclude template="../../footer.cfm">