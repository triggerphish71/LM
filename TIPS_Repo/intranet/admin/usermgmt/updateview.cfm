
<cfset datasource = "DMS">
<cfif Isdefined("url.userid")>
	<cfset userid = #url.userid#>
</cfif>
<!--- viewrecord --->
<cfparam name="expires" default="">
<!--- <cfparam name="password" default=""> --->

<cfquery name="getupdateinfo" datasource="#datasource#" dbtype="ODBC">
	Select *
	From users
	Where employeeid = #userid#
</cfquery>

<cfquery name="getupdateemp" datasource="#datasource#" dbtype="ODBC">
	Select *
	From vw_employees
	Where employee_ndx = #userid#
</cfquery>

<cfquery name="getdept" datasource="#datasource#" dbtype="ODBC">
Select Department,department_ndx
From vw_Departments
</cfquery>

<cfquery name="getempdept" datasource="#datasource#" dbtype="ODBC">
Select Department,department_ndx
From vw_Departments
Where department_ndx = #getupdateemp.ndepartmentnumber#
</cfquery>

<cfinclude template="/intranet/header.cfm">
<script language="JavaScript1.2" type="text/javascript">
<!--
function validForm(resourcerec)
{
	if (resourcerec.password.value != resourcerec.password2.value) {
	alert('Entered passwords do not match');
	resourcerec.password.focus();
	resourcerec.password.select();
	return false;
	}
	//return false
}
//-->
</script>
<script language="JavaScript" type="text/javascript" src="../../global/Calendar/ts_picker2.js"></script>
<cfoutput query="getupdateemp">
<ul>
<form action="action_biowriter.cfm" method="post" name="resourcerec" onSubmit="return validForm(this)">
  <table width="400" border="0" cellspacing="1" cellpadding="2">
   <tr bgcolor="##336699"> 
      <td colspan="2"> 
        <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Update Employee Entry</font>
      </td>
    </tr>
       <tr bgcolor="##f7f7f7"> 
      <td colspan="2"> 
       <font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">User:&nbsp;&nbsp;#getupdateemp.fname#  #getupdateemp.lname#</font>
      </td>
    </tr>
	<tr bgcolor="##f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">First Name:</font></td>
      <td> 
        <input type="text" name="fname" value="#fname#">
      </td>
    </tr>
    <tr bgcolor="##f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Last name:</font></td>
      <td> 
        <input type="text" name="lname" value="#lname#">
      </td>
    </tr>
   <tr bgcolor="##f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Job Title:</font></td>
      <td> 
        <input type="text" name="jobtitle" value="#jobtitle#">
      </td>
    </tr>
    <tr bgcolor="##f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Department:</font></td>
      <td> 
	  <select name="dept">
	   <option value="#getempdept.department_ndx#" SELECTED>#getempdept.department#</option>
	  <option value="">____________________</option>
		<cfloop query="getdept"><option value="#getdept.department_ndx#">#getdept.department#</option></cfloop>
</select>
      </td>
    </tr>
    <tr bgcolor="##f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Work Email:</font></td>
      <td> 
        <input type="text" name="email" value="#email#">
      </td>
    </tr>
  
    <tr bgcolor="##f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Username:</font></td>
      <td> 
        <CFIF REMOTE_ADDR EQ '10.1.0.211'>	
			<input type="text" name="username" value="#TRIM(getupdateinfo.username)#"> 
		<CFELSE> 
			#TRIM(getupdateinfo.username)# <input type="hidden" name="username" value="#TRIM(getupdateinfo.username)#"> 
		</CFIF>
      </td>
    </tr>
	<!---  <tr bgcolor="##f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Old Password:</font></td>
      <td> 
        <input type="password" name="oldpassword" value="#password#">
      </td>
    </tr> --->
    <tr bgcolor="##f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">New Password:</font></td>
      <td> 
        <input type="password" name="password" value="#getupdateinfo.password#">
		<input type="hidden" name="password_required">
      </td>
    </tr>
	    <tr bgcolor="##f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Confirm New Password:</font></td>
      <td> 
        <input type="password" name="password2"  value="#getupdateinfo.password#">
		<input type="hidden" name="password2_required">
      </td>
    </tr>
	    <tr bgcolor="##f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Password Expires:</font></td>
      <td> 
       <A href="javascript:show_calendar2('document.forms[0].expirationdate', document.forms[0].expirationdate.value)"><img src="../../global/Calendar/calendar.gif" width="16" height="15" border="0"></A> <input type="text" name="expirationdate" value="#Dateformat(getupdateinfo.passexpires,"mm/dd/yyyy")#" size="12" maxlength="12">
      </td>
    </tr>
	  </tr>
	    <tr bgcolor="##f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">User Expires:</font></td>
      <td> 
       <A href="javascript:show_calendar2('document.forms[0].userexpirationdate',document.forms[0].userexpirationdate.value)"><img src="../../global/Calendar/calendar.gif" width="16" height="15" border="0"></A> <input type="text" name="userexpirationdate" value="#Dateformat(getupdateinfo.expires,"mm/dd/yyyy")#" size="12" maxlength="12">
      </td>
    </tr>
	  <tr bgcolor="##eaeaea"> 
	   <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Intranet User:</font></td>
      <td> 
	  <cfif getupdateinfo.recordcount is 0>
	  	<input type="checkbox" name="intranetuser" value="1">
	<cfelse>
		<input type="checkbox" name="intranetuser" value="1" checked>
	</cfif>

	  </td>
    </tr>
	  <tr bgcolor="##eaeaea"> 
      <td colspan="2"> <input type="submit" name="submit" value="Update Employee"></td>
    </tr>
  </table></ul>
  <input type="hidden" name="employeeid" value="#userid#">
   <cfif getupdateinfo.recordcount is not 0>
   		<input type="hidden" name="usernamecheck" value="#getupdateinfo.username#">
   </cfif>
  <input type="Hidden" name="functiontype" value="update">
  <cfif getupdateinfo.recordcount is 0>
    <input type="Hidden" name="userinfo" value="1">
</cfif>

	</form>	
	</cfoutput>
<cfinclude template="/intranet/footer.cfm">
