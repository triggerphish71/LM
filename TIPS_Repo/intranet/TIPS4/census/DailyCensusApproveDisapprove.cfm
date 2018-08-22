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
| fzahir     | 11/10/2005 | When user clicks approve or disapprove button, corresponding record|
|            |            | is inserted into database tables.                                  |
| mlaw       | 01/16/2007 | add web service to get the time zone                               |
| mlaw       | 01/19/2007 | remove web service piece                                           |
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

<!---<cfquery name="getHouse" datasource="#application.datasource#">
	select
		cnumber
	from
		house h
	where
		h.bissandbox = 0
	and
		h.dtrowdeleted is NULL
	and
		h.ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</cfquery>--->

<!--- <cfset timestamp = now()> --->

<cfif isDefined("form.approve") and not isDefined("form.disapprove")>
<!--- 	<cfinvoke
	 method="getTimeZoneByFacilityNumber"
	 returnvariable="aString"
	 webservice="http://silk-dev/phonedirectoryservice/Service.asmx?wsdl" >
		<cfinvokeargument name="iFacilityNumber" value="#getHouse.cnumber#"/>
	</cfinvoke>

	<cfswitch expression="#aString#">
		<cfcase value="Eastern">
			<cfset timestamp = (dateadd("h", +1, timestamp))>
		</cfcase>
		<cfcase value="Mountain">
			<cfset timestamp =  (dateadd("h", -1, timestamp))>
		</cfcase>
		<cfcase value="Pacific">
			<cfset timestamp =  (dateadd("h", -2, timestamp))>
		</cfcase>
	</cfswitch> --->

	<cfquery name="approvequery" datasource="#APPLICATION.datasource#">
		insert into DailyCensus
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
		insert into DailyCensus
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