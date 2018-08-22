<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Export Alarm Contact Info</title>

</head>
<!--- (Alarm Contact Info) if user is Administrator, Ops Spec, RDO, Property Mgr, IT --->
<cfif  isdefined("session.EID") and session.EID is not "" and isdefined("session.grouplist") and isdefined("session.ADdescription") 
			and (session.ADdescription contains "Property Manager" OR  session.grouplist contains "IT" or session.username contains "SBarrett")>
<cfelse>
<font face="arial" color="red" size=&1><B><center>You are not authorized to use the Simens Alarm Export page with out first logging in through ALC APPS with your network username and password. If you need assistance call the VCPI Service desk at VCPI HelpDesk 800-551-1236.</center></B></font>
<cfabort>
</cfif>
<link href="style1.css" rel="stylesheet" type="text/css">
<body>



<!--- Carriate Return & Line Feed, whant each record on new line --->
<cfset carriageReturn = chr(13)> 

<cfset HeaderRow =  
	"House Name" & "," & 
	"House PhoneNumber1" & "," & 
	"AddressLine1" & "," & 
	"AddressLine2" & "," & 
	"City" & "," & 
	"StateCode" & "," & 
	"ZipCode" & "," & 
	
	"AlarmCompany" & "," & 
	"HouseAdminName" & "," & 
	"FireDeptName" & "," & 
	"FireDeptDispatchPhone" & "," & 
	"FireDeptPhone" & "," & 
	"AlarmPassCode" & "," & 
	"PrimaryName" & "," & 
	"PrimaryTitle" & "," & 
	"PrimaryPhone1" & "," & 
	"PrimaryPhone2" & "," & 
	"SecondaryName" & "," & 
	"SecondaryTitle" & "," & 
	"SecondaryPhone1" & "," & 
	"SecondaryPhone2" & "," & 
	"ThirdName" & "," & 
	"ThirdTitle" & "," & 
	"ThirdPhone1" & "," & 
	"ThirdPhone2" & "," & 
	"#carriageReturn#"> 

<!--- Delete Original File --->
<!--- <cffile  ACTION="DELETE" file="c:\inetpub\wwwroot\intranet\AlarmContacts\ALC_Alarm_Contacs_ALLHOUSES.csv"> --->

<!--- Create Header --->
<cffile  
ACTION="WRITE"
addnewline="no"
file="c:\inetpub\wwwroot\intranet\AlarmContacts\ALC_Alarm_Contacs_ALLHOUSES.csv"
output="#headerRow#">


<!--- Ignore Zeta 200, HomeOffice 52, and Old Houses --->
<cfquery name="GetHouseList" datasource="TIPS4">
SELECT * 
FROM house 
WHERE dtRowDeleted IS NULL 
and iHouse_ID <>52
and iHouse_ID <>200
ORDER BY cName ASC
</cfquery>

<cfset fileOut= "">


<!--- Build Each Company's string --->
<!--- ***************************************************************  --->
<cfoutput query="GetHouseList">
   <cfquery name="ALARMDETAILS" datasource="intranet">
    select * 
	from AlarmContact 
	WHERE iHouse_ID = '#GetHouseList.iHouse_ID#'
	and dtRowDeleted IS NULL
   </cfquery>
   
<cfset fileOut = fileOut & 
	"#GetHouseList.cName#" & "," & 
	"#GetHouseList.cPhoneNumber1#" & "," & 
	"#GetHouseList.cAddressLine1#" & "," & 
	"#GetHouseList.cAddressLine2#" & "," & 
	"#GetHouseList.cCity#" & "," & 
	"#GetHouseList.cStateCode#" & "," & 
	"#GetHouseList.cZipCode#" & "," > 
	
<cfif ALARMDETAILS.iAlarmCompany_ID IS 1><cfset AlarmCompanyName = "SIEMENS">
<cfelseif ALARMDETAILS.iAlarmCompany_ID IS 2><cfset AlarmCompanyName = "JALARMS"> 
<cfelseif ALARMDETAILS.iAlarmCompany_ID IS 3><cfset AlarmCompanyName = "SONORAN"> 
<cfelseif ALARMDETAILS.iAlarmCompany_ID IS 4><cfset AlarmCompanyName = "OTHER"> 
</cfif>
 
<cfset fileOut = fileOut & 
	"#AlarmCompanyName#" & "," &
	"#ALARMDETAILS.cHouseAdminName#" & "," & 
	"#ALARMDETAILS.cFireDeptName#" & "," & 
	"#ALARMDETAILS.iFireDeptDispatchPhone#" & "," & 
	"#ALARMDETAILS.iFireDeptPhone#" & "," & 
	"#ALARMDETAILS.cAlarmPassCode#" & "," & 
	"#ALARMDETAILS.cPrimaryName#" & "," & 
	"#ALARMDETAILS.cPrimaryTitle#" & "," & 
	"#ALARMDETAILS.cPrimaryPhone1#" & "," & 
	"#ALARMDETAILS.cPrimaryPhone2#" & "," & 
	"#ALARMDETAILS.cSecondaryName#" & "," & 
	"#ALARMDETAILS.cSecondaryTitle#" & "," & 
	"#ALARMDETAILS.cSecondaryPhone1#" & "," & 
	"#ALARMDETAILS.cSecondaryPhone2#" & "," & 
	"#ALARMDETAILS.cThirdName#" & "," & 
	"#ALARMDETAILS.cThirdTitle#" & "," & 
	"#ALARMDETAILS.cThirdPhone1#" & "," & 
	"#ALARMDETAILS.cThirdPhone2#" & "," & 
	"#carriageReturn#"> 
</cfoutput>

<!--- Append All Alarm Company Strings to One File --->
<cffile  
ACTION="APPEND"
addnewline="no"
file="c:\inetpub\wwwroot\intranet\AlarmContacts\ALC_Alarm_Contacs_ALLHOUSES.csv"
output="#fileOut#">








<table  width="300" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
  <tr>
    <td ><table width="100%"  border="0" cellspacing="1" cellpadding="1">
      <tr>
        <td colspan="2" class="RowHeaderBlack" idth="287"><div align="left">ALC Alarm Contacts Reports</div></td>
      </tr>
      <tr>
        <td colspan="2" class="OtherCo"><div align="left">Right Click on the Report Name and Choose "Save Target As". Open it with Excel</div></td>
      </tr>
      <tr>
        <td height="39" class="PlainText"><div align="center"></div></td>
        <td class="PlainText"><img src="../../Content/Dashboards/Useful_Icons/File_Icons/LB_Excel_File_ICON.gif" align="absmiddle">&nbsp;<a href="ALC_Alarm_Contacs_ALLHOUSES.csv" target="_blank">ALL House - All Detail</a></td>
      </tr>
      <tr>
        <td height="30" class="PlainText">&nbsp;</td>
        <td height="30" class="PlainText">&nbsp;</td>
      </tr>

    </table></td>
  </tr>
</table>
</body>
</html>


<cfinclude template="../footer.cfm" >