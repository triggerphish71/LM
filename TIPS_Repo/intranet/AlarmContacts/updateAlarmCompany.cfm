<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Simens Alarm Contact - Administration</title>
<link href="style1.css" rel="stylesheet" type="text/css">
</head>
<!--- Authorized Users, House, and AlarmCompany values are present --->

<cfif isdefined("session.EID") AND (session.EID IS "A8W036272" or Session.EID is "A8W035436") AND isdefined("URL.iHouse_ID") and isdefined("URL.iAlarmCompany_ID")>

<cfelse>
	<cfoutput>Your file number is: #session.eid#*****</cfoutput>
	<cfabort showerror="You are not authorized to use the Simens Alarm Contact Administration-CreateRecord page with out first logging in through ALC APPS with your network username and password. If you need assistance call the VCPI Service desk at VCPI HelpDesk 800-551-1236">
</cfif>
<body>
<cfquery name="TestAlarmRecord" datasource="Intranet">
select * from AlarmContact WHERE iHouse_ID = '#URL.iHouse_ID#'
</cfquery>

<cfset date = now()>
<cfif TestAlarmRecord.recordcount IS 0>
	<cfquery name="createAlarmRecord" datasource="Intranet">
	INSERT INTO AlarmContact(
		iHouse_ID,
		iAlarmCompany_ID,
		cRowStartUser_ID,
		dtRowStart)
	VALUES (
		#URL.iHouse_ID#,
		#URL.iAlarmCompany_ID#,
		'#session.username#',
		#date#)
	</cfquery>
	<cflocation url="AlarmContact_Admin.cfm">
<cfelse><!--- Record already exists --->
	<cfquery name="updateAlarmRecord" datasource="Intranet">
	UPDATE AlarmContact
	SET
	iAlarmCompany_ID = #URL.iAlarmCompany_ID#,
	cRowEndUser_ID = '#Session.username#',
	dtRowEnd = #date#
	WHERE iHouse_ID=#URL.iHouse_ID#
	</cfquery>
	<cflocation url="AlarmContact_Admin.cfm">
</cfif>



</body>
</html>
