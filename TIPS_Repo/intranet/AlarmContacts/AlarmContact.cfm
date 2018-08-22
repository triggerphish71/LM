<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Alarm Contact</title>

</head>
<!--- (Alarm Contact Info) if user is Administrator, Ops Spec, RDO, Property Mgr, IT --->
<cfif  isdefined("session.EID") and session.EID is not "" and isdefined("session.grouplist") and isdefined("session.ADdescription") 
			and (session.ADdescription contains "Administrator" OR session.ADdescription contains "RDO" OR session.ADdescription contains "Operations Spec" 
			OR session.ADdescription contains "Property Manager" OR  session.grouplist contains "IT" or session.username contains "SBarrett")>
<cfelse>
<font face="arial" color="red" size=+1><B><center>You are not authorized to use the Simens Alarm Contact page with out first logging in through ALC APPS with your network username and password. If you need assistance call the VCPI Service desk at VCPI HelpDesk 800-551-1236.</center></B></font>
<cfabort>
</cfif>
<link href="style1.css" rel="stylesheet" type="text/css">
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

<table width="699"  border="0" cellspacing="1" cellpadding="1">
  <tr>
    <td colspan="7"><div align="right"><a href="%3Ca%20href=%22../logout.cfm%22%3E">[Log Out]</a> <a href="../ApplicationList.cfm?adsi=1&adsi=1">[ALC APPS List]</a>
	<!--- Authorized Users to Set UP Seimens Alarm Contacts, Laurie Wiles, Steven Barrette --->
	<cfif (isdefined("session.EID")) AND (session.EID IS "A8W036272" or Session.EID is "A8W035436")><a href="AlarmContact_Admin.cfm">[Change the Alarm Company Association]</a> [<a href="Export.cfm" target="_blank">Export Details</a>]
	</cfif></div></td>
  </tr>
  <tr>
    <td colspan="7" class="NotSet">This page is used to update the contact information to be used by the alarm company. There should be a check mark in each column. If a house is missing a checkmark, then not all the contact information has yet been provided. Please check to make sure all the contact information for your residence is current and complete. </td>
  </tr>
  <tr>
    <td colspan="7" class="RowHeaderBlue">This information needs to be updated by <u>April 15</u>, for the upcomming switch over to Siemens Security Services </td>
  </tr>
  <tr class="RowHeaderBlack">
    <td width="181">House</td>
    <td width="158">Alarm<br>
    Company </td>
    <td width="71">Fire<br>
      Station</td>
    <td width="77">1st<br>
      Contact </td>
    <td width="81">2nd<br>
      Contact </td>
    <td width="86">Property<br>
    Manager</td>
    <td width="64">Pass<br>
    Code</td>
  </tr>

<cfoutput query="GetHouseList">
<cfquery name="GetAlarmRecord" datasource="Intranet">
select * from AlarmContact WHERE iHouse_ID = '#GetHouseList.iHouse_ID#'
</cfquery>
 <tr <cfif GetAlarmRecord.iAlarmCompany_ID is 0 or GetAlarmRecord.iAlarmCompany_ID is -1>class="NotSet"
	<cfelseif GetAlarmRecord.iAlarmCompany_ID IS 1 >class="Siemens"
	<cfelse>class="OtherCo"	</cfif> >
    <td><a href="ViewContactDetails.cfm?iHouse_ID=#GetHouseList.iHouse_ID#">#GetHouseList.cName#</a></td>
    <td>
	<cfif GetAlarmRecord.recordcount IS 0 or GetAlarmRecord.iAlarmCompany_ID IS -1  >Not Set
	<cfelseif GetAlarmRecord.iAlarmCompany_ID IS 1 >Siemens
	<cfelseif GetAlarmRecord.iAlarmCompany_ID IS 2 >JAlarms
	<cfelseif GetAlarmRecord.iAlarmCompany_ID IS 3 >Sonoran
	<cfelse>other</cfif></td>
    
	<td><cfif GetAlarmRecord.cFireDeptName IS NOT "" 
	AND GetAlarmRecord.iFireDeptDispatchPhone IS NOT ""
	AND GetAlarmRecord.iFireDeptPhone IS NOT "">
      <img src="check_small.gif">    </cfif>&nbsp;</td>
    
	<td><cfif GetAlarmRecord.cPrimaryName IS NOT "" 
	AND GetAlarmRecord.cPrimaryTitle IS NOT ""
	AND GetAlarmRecord.cPrimaryPhone1 IS NOT "">
      <img src="check_small.gif">    </cfif>&nbsp;</td>
	  
    <td><cfif GetAlarmRecord.cSecondaryName IS NOT "" 
	AND GetAlarmRecord.cSecondaryTitle IS NOT ""
	AND GetAlarmRecord.cSecondaryPhone1 IS NOT "">
      <img src="check_small.gif">    </cfif>&nbsp;</td>
    
	<td><cfif GetAlarmRecord.cThirdName IS NOT "" 
	AND GetAlarmRecord.cThirdTitle IS NOT ""
	AND GetAlarmRecord.cThirdPhone1 IS NOT "">
      <img src="check_small.gif">    </cfif>&nbsp;</td>
    
	<td><cfif GetAlarmRecord.cAlarmPassCode IS NOT "" >
      <img src="check_small.gif">    </cfif>&nbsp;</td>
	</tr>
  </cfoutput> 
</table>
</body>
</html>


<cfinclude template="../footer.cfm" >