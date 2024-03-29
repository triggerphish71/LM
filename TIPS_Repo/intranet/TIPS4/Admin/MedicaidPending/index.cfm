<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| Controls the Medicaid Pending application                                                    |
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
| mlaw       | 03/23/2007 | Created                                                            |
----------------------------------------------------------------------------------------------->
<cfcache action="flush">
<cfparam name="fuse" default="main">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title><cfoutput>ALC - Payment Plan Application</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

</head>

<!---  CreateODBCDateTime(now()) --->
<cfif not isDefined("session.qselectedhouse.ihouse_id") or not isDefined("session.userid")>
	<cflocation url="../../Loginindex.cfm" addtoken="yes">
</cfif>

<!--- Include Intranet header --->
<cfinclude template="../../../header.cfm">

<!--- Include the page for house header --->
<cfinclude template="../../Shared/HouseHeader.cfm">

<link rel="stylesheet" href="style.css">
<br>
	<cfswitch expression="#fuse#">
		<!--- main rate increase page --->
		<cfcase value="main">
        <cfinclude template="DisplayFiles\dsp_main.cfm">
</cfcase>
		<cfcase value="medicaidpending">
			<cfinclude template="QueryFiles\qry_GetAllTenants.cfm">
			<cfinclude template="DisplayFiles\dsp_MedicaidPending.cfm">
		</cfcase>
		<cfcase value="AddMedicaidPending">
			<cfinclude template="ActionFiles\act_UpdateMedicaidPending.cfm">
		</cfcase>
	</cfswitch>
    </body>