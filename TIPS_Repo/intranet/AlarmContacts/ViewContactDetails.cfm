<!--- (Alarm Contact Info) if user is Administrator, Ops Spec, RDO, Property Mgr, IT --->
<cfif  isdefined("session.EID") and session.EID is not "" and isdefined("session.grouplist") and isdefined("session.ADdescription") 
			and (session.ADdescription contains "Administrator" OR session.ADdescription contains "RDO" OR session.ADdescription contains "Operations Spec" 
			OR session.ADdescription contains "Property Manager" OR  session.grouplist contains "IT" or session.username contains "SBarrett")>
<cfelse>
  <cfabort showerror="You are not authorized to use the Simens Alarm Contact page with out first logging in through ALC APPS with your network username and password. If you need assistance call the VCPI Service desk at VCPI HelpDesk 800-551-1236">
</cfif>
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1">
  <cfset today =now()>
  <cfquery datasource="Intranet">
  UPDATE dbo.AlarmContact SET cHouseAdminName=
  <cfif IsDefined("FORM.cHouseAdminName") AND #FORM.cHouseAdminName# NEQ "">
    '#FORM.cHouseAdminName#'
    <cfelse>
    NULL
  </cfif>
  , cFireDeptName=
  <cfif IsDefined("FORM.cFireDeptName") AND #FORM.cFireDeptName# NEQ "">
    '#FORM.cFireDeptName#'
    <cfelse>
    NULL
  </cfif>
  , iFireDeptDispatchPhone=
  <cfif IsDefined("FORM.iFireDeptDispatchPhone_1") AND #FORM.iFireDeptDispatchPhone_1# NEQ ""
  AND IsDefined("FORM.iFireDeptDispatchPhone_2") AND #FORM.iFireDeptDispatchPhone_2# NEQ ""
  AND IsDefined("FORM.iFireDeptDispatchPhone_3") AND #FORM.iFireDeptDispatchPhone_3# NEQ "">
    '#FORM.iFireDeptDispatchPhone_1#' + '#FORM.iFireDeptDispatchPhone_2#' + '#FORM.iFireDeptDispatchPhone_3#'
    <cfelse>
    NULL
  </cfif>
  , iFireDeptPhone=
  <cfif IsDefined("FORM.iFireDeptPhone_1") AND #FORM.iFireDeptPhone_1# NEQ ""
  AND IsDefined("FORM.iFireDeptPhone_2") AND #FORM.iFireDeptPhone_2# NEQ ""
  AND IsDefined("FORM.iFireDeptPhone_3") AND #FORM.iFireDeptPhone_3# NEQ "">
    '#FORM.iFireDeptPhone_1#' + '#FORM.iFireDeptPhone_2#' + '#FORM.iFireDeptPhone_3#'
    <cfelse>
    NULL
  </cfif>
  , cAlarmPassCode=
  <cfif IsDefined("FORM.cAlarmPassCode") AND #FORM.cAlarmPassCode# NEQ "">
    '#FORM.cAlarmPassCode#'
    <cfelse>
    NULL
  </cfif>
  , cPrimaryName=
  <cfif IsDefined("FORM.cPrimaryName") AND #FORM.cPrimaryName# NEQ "">
    '#FORM.cPrimaryName#'
    <cfelse>
    NULL
  </cfif>
  , cPrimaryTitle=
  <cfif IsDefined("FORM.cPrimaryTitle") AND #FORM.cPrimaryTitle# NEQ "">
    '#FORM.cPrimaryTitle#'
    <cfelse>
    NULL
  </cfif>
  , cPrimaryPhone1=
  <cfif IsDefined("FORM.cPrimaryPhone1_1") AND #FORM.cPrimaryPhone1_1# NEQ ""
  AND IsDefined("FORM.cPrimaryPhone1_2") AND #FORM.cPrimaryPhone1_2# NEQ ""
  AND IsDefined("FORM.cPrimaryPhone1_3") AND #FORM.cPrimaryPhone1_3# NEQ "">
    '#FORM.cPrimaryPhone1_1#' + '#FORM.cPrimaryPhone1_2#' + '#FORM.cPrimaryPhone1_3#'
    <cfelse>
    NULL
  </cfif>
  , cPrimaryPhone2=
  <cfif IsDefined("FORM.cPrimaryPhone2_1") AND #FORM.cPrimaryPhone2_1# NEQ ""
  AND IsDefined("FORM.cPrimaryPhone2_2") AND #FORM.cPrimaryPhone2_2# NEQ ""
  AND IsDefined("FORM.cPrimaryPhone2_3") AND #FORM.cPrimaryPhone2_3# NEQ "">
    '#FORM.cPrimaryPhone2_1#' + '#FORM.cPrimaryPhone2_2#' + '#FORM.cPrimaryPhone2_3#'
    <cfelse>
    NULL
  </cfif>
  , cSecondaryName=
  <cfif IsDefined("FORM.cSecondaryName") AND #FORM.cSecondaryName# NEQ "">
    '#FORM.cSecondaryName#'
    <cfelse>
    NULL
  </cfif>
  , cSecondaryTitle=
  <cfif IsDefined("FORM.cSecondaryTitle") AND #FORM.cSecondaryTitle# NEQ "">
    '#FORM.cSecondaryTitle#'
    <cfelse>
    NULL
  </cfif>
  , cSecondaryPhone1=
    <cfif IsDefined("FORM.cSecondaryPhone1_1") AND #FORM.cSecondaryPhone1_1# NEQ ""
  AND IsDefined("FORM.cSecondaryPhone1_2") AND #FORM.cSecondaryPhone1_2# NEQ ""
  AND IsDefined("FORM.cSecondaryPhone1_3") AND #FORM.cSecondaryPhone1_3# NEQ "">
    '#FORM.cSecondaryPhone1_1#' + '#FORM.cSecondaryPhone1_2#' + '#FORM.cSecondaryPhone1_3#'
    <cfelse>
    NULL
  </cfif>
  , cSecondaryPhone2=
    <cfif IsDefined("FORM.cSecondaryPhone2_1") AND #FORM.cSecondaryPhone2_1# NEQ ""
  AND IsDefined("FORM.cSecondaryPhone2_2") AND #FORM.cSecondaryPhone2_2# NEQ ""
  AND IsDefined("FORM.cSecondaryPhone2_3") AND #FORM.cSecondaryPhone2_3# NEQ "">
    '#FORM.cSecondaryPhone2_1#' + '#FORM.cSecondaryPhone2_2#' + '#FORM.cSecondaryPhone2_3#'
    <cfelse>
    NULL
  </cfif>
  , cThirdName=
  <cfif IsDefined("FORM.cThirdName") AND #FORM.cThirdName# NEQ "">
    '#FORM.cThirdName#'
    <cfelse>
    NULL
  </cfif>
  , cThirdTitle='Property Manager' , 
  cThirdPhone1=
   <cfif IsDefined("FORM.cThirdPhone1_1") AND #FORM.cThirdPhone1_1# NEQ ""
  AND IsDefined("FORM.cThirdPhone1_2") AND #FORM.cThirdPhone1_2# NEQ ""
  AND IsDefined("FORM.cThirdPhone1_3") AND #FORM.cThirdPhone1_3# NEQ "">
    '#FORM.cThirdPhone1_1#' + '#FORM.cThirdPhone1_2#' + '#FORM.cThirdPhone1_3#'
    <cfelse>
    NULL
  </cfif>
  , cThirdPhone2=
   <cfif IsDefined("FORM.cThirdPhone2_1") AND #FORM.cThirdPhone2_1# NEQ ""
  AND IsDefined("FORM.cThirdPhone2_2") AND #FORM.cThirdPhone2_2# NEQ ""
  AND IsDefined("FORM.cThirdPhone2_3") AND #FORM.cThirdPhone2_3# NEQ "">
    '#FORM.cThirdPhone2_1#' + '#FORM.cThirdPhone2_2#' + '#FORM.cThirdPhone2_3#'
    <cfelse>
    NULL
  </cfif>
  , cRowEndUser_ID='#Session.Username#' , dtRowEnd= #today# WHERE iHouse_ID=#FORM.iHouse_ID#
  </cfquery>
  <cflocation url="AlarmContact.cfm">
</cfif>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Alarm Contact Detail</title>
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_goToURL() { //v3.0
  var i, args=MM_goToURL.arguments; document.MM_returnValue = false;
  for (i=0; i<(args.length-1); i+=2) eval(args[i]+".location='"+args[i+1]+"'");
}
//-->
</script>
</head>
<!--- Make sure we have the iHouse_ID to pull detail information up by --->
<cfif NOT isdefined("url.ihouse_id")>
  <cfabort showerror="You must log into the Alarm Contact Update application through the ALC APPS menu. If you need assistance call the VCPI Service desk at VCPI HelpDesk 800-551-1236">
</cfif>
<link href="style1.css" rel="stylesheet" type="text/css">
<body>
<cfquery name="GetHouseList" datasource="TIPS4">
select * from house where iHouse_ID = #URL.iHouse_ID#
</cfquery>


<table width="699"  border="0" cellspacing="1" cellpadding="1">
  <td width="246"><form method="post" name="form1" action="#CurrentPage#">
  
  <tr>
    <td colspan="3"><div align="right"><a href="%3Ca%20href=%22../logout.cfm%22%3E">[Log Out]</a> <a href="../ApplicationList.cfm?adsi=1&adsi=1">[ALC APPS List]</a> <a href="AlarmContact.cfm">[Back to House List]</a></div></td>
  </tr>
  <tr>
    <td height="105" colspan="3" class="NotSet"><p><u><strong>Directions:</strong></u> This page is used to update the contact information needed by the Alarm Company in case of an emergency. The way the system will work is if an alarm is picked up by the monitoring service the first call will go to the fire department emergency dispatch number (Do not list 911 as a number to be called, this will not work). The dispatch number has to be a 10 digit telephone number, if you do not know what that number is you will have to contact your city hall for the listing or sometimes it is listed in the first few pages of the local telephone directory. After the call is made to the Fire Dept. the second call is placed to the house, if there is no answer, the next call will go to the 1st Contact, then 2nd Contact, and lastly the Regional Property Manager. - If you have any further questions on how to update this information, contact Steve Barrett 214-424-4054.</p>
      <p><strong>Note:</strong> If the Residence Phone or Address information is incorrect, contact the VCPI HelpDesk 800-551-1236 so that the information can be updated. </p></td>
  </tr>
  <tr class="RowHeaderBlack">
    <td colspan="3"><cfoutput>#GetHouseList.cName#</cfoutput>&nbsp;</td>
  </tr>
  <cfoutput query="GetHouseList">
    <cfquery name="GetAlarmRecord" datasource="Intranet">
    select * from AlarmContact WHERE iHouse_ID = '#GetHouseList.iHouse_ID#'
    </cfquery>
    <tr class="Siemens">
      <td ><div align="right">House Phone:</div></td>
      <td width="1" >&nbsp;</td>
      <td width="442" >#mid(GetHouseList.cPhoneNumber1,1,3)# - #mid(GetHouseList.cPhoneNumber1,4,3)# - #mid(GetHouseList.cPhoneNumber1,7,len(GetHouseList.cPhoneNumber1)-6)#</td>
    </tr>
    <tr class="Siemens">
      <td><div align="right">Address Line 1:</div></td>
      <td>&nbsp;</td>
      <td>#GetHouseList.cAddressLine1#</td>
    </tr>
    <tr class="Siemens">
      <td><div align="right">Address Line 2:</div></td>
      <td>&nbsp;</td>
      <td>#GetHouseList.cAddressLine2#</td>
    </tr>
    <tr class="Siemens">
      <td><div align="right">City, ST ZIP:</div></td>
      <td>&nbsp;</td>
      <td>#GetHouseList.cCity#, #GetHouseList.cStateCode# #GetHouseList.cZipCode#</td>
    </tr>
    <tr class="Siemens">
      <td><div align="right"></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr class="NotSetHeader">
      <td colspan="3"><div align="center">All fields with a * are required for a the <img src="check_small.gif" width="25" height="20">to appear from the master list of houses.</div></td>
    <tr class="NotSetHeader">
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>    
    <tr class="NotSetHeader">
      <td><div align="right"></div></td>
      <td>&nbsp;</td>
      <td>House Alarm Contact
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Administrator:</td>
      <td>&nbsp;</td>
      <td><input type="text" name="cHouseAdminName" value="#GetAlarmRecord.cHouseAdminName#" size="32" maxlength="50">
      *</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Alarm PassCode:</td>
      <td>&nbsp;</td>
      <td><input type="text" name="cAlarmPassCode" value="#GetAlarmRecord.cAlarmPassCode#" size="32" maxlength="20">
      *</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">&nbsp;</td>
      <td>&nbsp;</td>
      <td class="NotSetHeader">Fire Department </td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Fire Department Name:</td>
      <td>&nbsp;</td>
      <td><input type="text" name="cFireDeptName" value="#GetAlarmRecord.cFireDeptName#" size="32" maxlength="50">
      *</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Dispatch Phone (NOT 911):</td>
      <td>&nbsp;</td>
      <td>
	  <input type="text" name="iFireDeptDispatchPhone_1" value="#mid(GetAlarmRecord.iFireDeptDispatchPhone,1,3)#" size="3" maxlength="3">
      <input type="text" name="iFireDeptDispatchPhone_2" value="#mid(GetAlarmRecord.iFireDeptDispatchPhone,4,3)#" size="3" maxlength="3">
      <input type="text" name="iFireDeptDispatchPhone_3" value="#mid(GetAlarmRecord.iFireDeptDispatchPhone,7,4)#" size="4" maxlength="4">
      *</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Non-Emergency Phone:</td>
      <td>&nbsp;</td>
      <td>
	  <input type="text" name="iFireDeptPhone_1" value="#mid(GetAlarmRecord.iFireDeptPhone,1,3)#" size="3" maxlength="3">
      <input type="text" name="iFireDeptPhone_2" value="#mid(GetAlarmRecord.iFireDeptPhone,4,3)#" size="3" maxlength="3">
      <input type="text" name="iFireDeptPhone_3" value="#mid(GetAlarmRecord.iFireDeptPhone,7,4)#" size="4" maxlength="4">
      *
	  </td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">&nbsp;</td>
      <td>&nbsp;</td>
      <td class="NotSetHeader">Primary Contact </td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Name:</td>
      <td>&nbsp;</td>
      <td><input type="text" name="cPrimaryName" value="#GetAlarmRecord.cPrimaryName#" size="32" maxlength="50">
      *</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Title:</td>
      <td>&nbsp;</td>
      <td><input type="text" name="cPrimaryTitle" value="#GetAlarmRecord.cPrimaryTitle#" size="32" maxlength="50">
      *</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Phone1:</td>
      <td>&nbsp;</td>
      <td>
      <input type="text" name="cPrimaryPhone1_1" value="#mid(GetAlarmRecord.cPrimaryPhone1,1,3)#" size="3" maxlength="3">
      <input type="text" name="cPrimaryPhone1_2" value="#mid(GetAlarmRecord.cPrimaryPhone1,4,3)#" size="3" maxlength="3">
      <input type="text" name="cPrimaryPhone1_3" value="#mid(GetAlarmRecord.cPrimaryPhone1,7,4)#" size="4" maxlength="4">
      *
	  </td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Phone2:</td>
      <td>&nbsp;</td>
      <td>
	  <input type="text" name="cPrimaryPhone2_1" value="#mid(GetAlarmRecord.cPrimaryPhone2,1,3)#" size="3" maxlength="3">
      <input type="text" name="cPrimaryPhone2_2" value="#mid(GetAlarmRecord.cPrimaryPhone2,4,3)#" size="3" maxlength="3">
      <input type="text" name="cPrimaryPhone2_3" value="#mid(GetAlarmRecord.cPrimaryPhone2,7,4)#" size="4" maxlength="4">
	  </td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">&nbsp;</td>
      <td>&nbsp;</td>
      <td class="NotSetHeader">Secondary Contact </td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Name:</td>
      <td>&nbsp;</td>
      <td><input type="text" name="cSecondaryName" value="#GetAlarmRecord.cSecondaryName#" size="32" maxlength="50">
      *</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Title:</td>
      <td>&nbsp;</td>
      <td><input type="text" name="cSecondaryTitle" value="#GetAlarmRecord.cSecondaryTitle#" size="32" maxlength="50">
      *</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Phone1:</td>
      <td>&nbsp;</td>
      <td>
      <input type="text" name="cSecondaryPhone1_1" value="#mid(GetAlarmRecord.cSecondaryPhone1,1,3)#" size="3" maxlength="3">
      <input type="text" name="cSecondaryPhone1_2" value="#mid(GetAlarmRecord.cSecondaryPhone1,4,3)#" size="3" maxlength="3">
      <input type="text" name="cSecondaryPhone1_3" value="#mid(GetAlarmRecord.cSecondaryPhone1,7,4)#" size="4" maxlength="4">
      *
	</td>
	</tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Phone2:</td>
      <td>&nbsp;</td>
      <td>
	   <input type="text" name="cSecondaryPhone2_1" value="#mid(GetAlarmRecord.cSecondaryPhone2,1,3)#" size="3" maxlength="3">
      <input type="text" name="cSecondaryPhone2_2" value="#mid(GetAlarmRecord.cSecondaryPhone2,4,3)#" size="3" maxlength="3">
      <input type="text" name="cSecondaryPhone2_3" value="#mid(GetAlarmRecord.cSecondaryPhone2,7,4)#" size="4" maxlength="4">
	  </td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">&nbsp;</td>
      <td>&nbsp;</td>
      <td class="NotSetHeader">Third Contact </td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Name:</td>
      <td>&nbsp;</td>
      <td><input type="text" name="cThirdName" value="#GetAlarmRecord.cThirdName#" size="32" maxlength="50">
      *  </td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Title:</td>
      <td>&nbsp;</td>
      <td>Property Manger </td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Phone1:</td>
      <td>&nbsp;</td>
      <td>
      <input type="text" name="cThirdPhone1_1" value="#mid(GetAlarmRecord.cThirdPhone1,1,3)#" size="3" maxlength="3">
      <input type="text" name="cThirdPhone1_2" value="#mid(GetAlarmRecord.cThirdPhone1,4,3)#" size="3" maxlength="3">
      <input type="text" name="cThirdPhone1_3" value="#mid(GetAlarmRecord.cThirdPhone1,7,4)#" size="4" maxlength="4">
      *
	</td>
	</tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">Phone2:</td>
      <td>&nbsp;</td>
      <td>
	  <input type="text" name="cThirdPhone2_1" value="#mid(GetAlarmRecord.cThirdPhone2,1,3)#" size="3" maxlength="3">
      <input type="text" name="cThirdPhone2_2" value="#mid(GetAlarmRecord.cThirdPhone2,4,3)#" size="3" maxlength="3">
      <input type="text" name="cThirdPhone2_3" value="#mid(GetAlarmRecord.cThirdPhone2,7,4)#" size="4" maxlength="4">
	  </td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr valign="baseline" class="NotSet">
      <td nowrap align="right">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="submit" value="Update record">
        <input name="Cancel" type="button" id="Cancel" onClick="MM_goToURL('parent','AlarmContact.cfm');return document.MM_returnValue" value="Cancel --&gt; Back to House List"></td>
    </tr>
    <tr class="Siemens">
      <td><div align="right"></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <input type="hidden" name="iHouse_ID" value="#GetHouseList.iHouse_ID#">
    <input type="hidden" name="MM_UpdateRecord" value="form1">
    </form>
    
  </cfoutput>
</table>
</body>
</html>


<cfinclude template="../footer.cfm" >