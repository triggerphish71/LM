
<cfset datasource = "DMS">
<script language="JavaScript" src="../../global/Calendar/ts_picker2.js" type="text/javascript"></script>

<cfinclude template="/intranet/header.cfm">

<cfquery name="getdept" datasource="#datasource#" dbtype="ODBC">
Select Department,department_ndx
From vw_Departments
</cfquery>

<!--- <cfquery name="getemployees" datasource="#datasource#" dbtype="ODBC">
Select distinct employee_ndx,fname,lname
From vw_employees
Where employee_ndx NOT IN (select employeeid
							from users)
Order By Lname
</cfquery> --->

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
	return true
}
//-->
</script>
<ul>
<form action="action_biowriter.cfm" method="post" name="resourcerec" onSubmit="return validForm(this)">
  <table width="400" border="0" cellspacing="1" cellpadding="2">
   <tr bgcolor="#336666"> 
      <td colspan="2"> 
        <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">New Employee Username Entry</font>
      </td>
    </tr>
	<!---  <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Employee:</font></td>
      <td> 
	  <select name="employeendx">
	  <option value="" SELECTED>Choose...</option>
		<cfoutput query="getemployees"><option value="#employee_ndx#">#Lname#, #Fname#</option></cfoutput>
</select>
      </td>
    </tr> --->
     <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">First Name:</font></td>
      <td> 
        <input type="text" name="fname" size="40" maxlength="39">
		<input type="hidden" name="fname_required">
      </td>
    </tr>
    <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Last name:</font></td>
      <td> 
        <input type="text" name="lname" size="39" maxlength="39">
		<input type="hidden" name="lname_required">
      </td>
    </tr>
   <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Job Title:</font></td>
      <td> 
        <input type="text" name="jobtitle" size="39" maxlength="39">
		<input type="hidden" name="jobtitle_required">
      </td>
    </tr>
    <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Department:</font></td>
      <td> 
	  <select name="dept">
	  <option value="" SELECTED>Choose...</option>
		<cfoutput query="getdept"><option value="#department_ndx#">#department#</option></cfoutput>
</select>
<input type="hidden" name="dept_required">
      </td>
    </tr>
    <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Work Email:</font></td>
      <td> 
        <input type="text" name="email" value="@alcco.com" size="40" maxlength="40">
		<input type="hidden" name="email_required">
      </td>
    </tr>
  
    <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Username:</font></td>
      <td> 
        <input type="text" name="username" size="20" maxlength="20">
		<input type="hidden" name="username_required">
      </td>
    </tr>
    <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Password:</font></td>
      <td> 
        <input type="password" name="password" size="20" maxlength="20">
		<input type="hidden" name="password_required">
      </td>
    </tr>
	    <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Confirm Password:</font></td>
      <td> 
        <input type="password" name="password2" size="20" maxlength="20">
      </td>
    </tr>
	 <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Password Expires:</font></td>
      <td> 
       <a href="javascript:show_calendar2('document.forms[0].expirationdate', document.forms[0].expirationdate.value);">
			 <img src="../../global/Calendar/calendar.gif" width="16" height="15" border="0">
			 </a> 
			 <input type="text" name="expirationdate" size="12" maxlength="12" value="<cfoutput>#dateformat(now(),'m/d/yyyy')#</cfoutput>">
	     <input type="hidden" name="expirationdate_required">
      </td>
    </tr>
	    <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">User Expires:</font></td>
      <td> 
       <a href="javascript:show_calendar2('document.forms[0].userexpirationdate', document.forms[0].userexpirationdate.value);">
			 <img src="../../global/Calendar/calendar.gif" width="16" height="15" border="0">
			 </a>
			 <input type="text" name="userexpirationdate" value="<cfoutput>#dateformat(now(),'m/d/yyyy')#</cfoutput>" size="12" maxlength="12">
      </td>
    </tr>
	<tr bgcolor="#eaeaea"> 
      <td colspan="2"><input type="Submit" name="Submit" value="Submit Employee Info"></td>
      
    </tr>
  </table>
<br><br>
<input type="Hidden" name="functiontype" value="insert">
</form></ul>
<cfinclude template="/intranet/footer.cfm">

