<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Simens Alarm Contact - Administration</title>
<link href="style1.css" rel="stylesheet" type="text/css">
</head>
<!--- Authorized Users to Set UP Seimens Alarm Contacts, Laurie Wiles, Steven Barrett --->
<cfif (isdefined("session.EID")) AND (session.EID IS "A8W036272" or Session.EID is "A8W035436")>
	
<cfelse>
	<cfoutput>Your file number is: #session.eid#*****</cfoutput>
	<cfabort showerror="You are not authorized to use the Simens Alarm Contact Administration page with out first logging in through ALC APPS with your network username and password. If you need assistance call the VCPI Service desk at VCPI HelpDesk 800-551-1236">
</cfif>
<body>

<!--- Ignore Zeta 200, HomeOffice 52, and Old Houses --->
<cfquery name="GetHouseList" datasource="TIPS4">
SELECT * 
FROM house 
WHERE dtRowDeleted IS NULL 
and iHouse_ID <>52
and iHouse_ID <>200
ORDER BY cName ASC
</cfquery>
<table width="707"  border="0" cellspacing="1" cellpadding="1">
  
    <tr>
    <td colspan="6" ><div align="right"><a href="%3Ca%20href=%22../logout.cfm%22%3E">[Log Out] </a> <a href="../ApplicationList.cfm?adsi=1&adsi=1">[ALC APPS List]</a> <a href="AlarmContact.cfm">[Enter Contact Information]</a> [<a href="export.cfm" target="_blank">Export Details</a>]</div></td>
  </tr>
  <tr>
    <td colspan="6" class="Siemens">This page is used to set the Alarm Company that is associated with each house.</td>
  </tr>
  <tr class="RowHeaderBlack">
    <td>House</td>
    <td>Not Set </td>
    <td>Siemens</td>
    <td>JAlarms</td>
    <td>Sonoran</td>
    <td>Other</td>
  </tr>

<cfoutput query="GetHouseList">
<cfquery name="GetAlarmRecord" datasource="Intranet">
select * from AlarmContact WHERE iHouse_ID = '#GetHouseList.iHouse_ID#'
</cfquery>
 <tr <cfif GetAlarmRecord.recordcount IS 0 or GetAlarmRecord.iAlarmCompany_ID IS -1 >class="NotSet"<cfelseif GetAlarmRecord.iAlarmCompany_ID IS 1>class="Siemens" <cfelse>class="OtherCo" </cfif> >
    <td>#GetHouseList.cName#</td>
    <td><cfif GetAlarmRecord.recordcount IS 0 or GetAlarmRecord.iAlarmCompany_ID IS -1><strong>Not Set</strong><cfelse><a href="updateAlarmCompany.cfm?iHouse_ID=#GetHouseList.iHouse_ID#&iAlarmCompany_ID=-1">Use None</a></cfif></td>
    <td><cfif GetAlarmRecord.iAlarmCompany_ID IS 1>
      <strong>Siemens</strong>
      <cfelse>
      <a href="updateAlarmCompany.cfm?iHouse_ID=#GetHouseList.iHouse_ID#&iAlarmCompany_ID=1">Use Siemens</a>
    </cfif></td>
    <td><cfif GetAlarmRecord.iAlarmCompany_ID IS 2><strong>JAlarms</strong><cfelse><a href="updateAlarmCompany.cfm?iHouse_ID=#GetHouseList.iHouse_ID#&iAlarmCompany_ID=2">Use JAlarms</a></cfif></td>
    <td><cfif GetAlarmRecord.iAlarmCompany_ID IS 3><stron>Sonoran</strong><cfelse><a href="updateAlarmCompany.cfm?iHouse_ID=#GetHouseList.iHouse_ID#&iAlarmCompany_ID=3">Use Sonoran</a></cfif></td>
    <td><cfif GetAlarmRecord.iAlarmCompany_ID IS 4><strong>Other</strong><cfelse><a href="updateAlarmCompany.cfm?iHouse_ID=#GetHouseList.iHouse_ID#&iAlarmCompany_ID=4">Use Other</a></cfif></td>
 </tr>
  </cfoutput> 
</table>

</body>
</html>

<cfinclude template="../footer.cfm" >