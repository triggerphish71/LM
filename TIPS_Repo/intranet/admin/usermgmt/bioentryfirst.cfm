
<cfset datasource = "DMS">
<cfinclude template="/intranet/header.cfm">
<!--- <cfquery name="getemployees" datasource="#datasource#" dbtype="ODBC">
Select distinct employee_ndx,fname,lname
From vw_employees
Where employee_ndx NOT IN (select employeeid
							from users)
Order By Lname
</cfquery> --->

<cfquery name="getemployees" datasource="#datasource#" dbtype="ODBC">
	Select distinct employee_ndx,fname,lname,username,isNull(passexpires,getdate()) as passexpires
	From vw_employees,users
	Where employee_ndx = #session.userid# AND users.employeeid = employee_ndx
</cfquery>

<script language="JavaScript1.2" type="text/javascript">
<!--
function validForm(passForm)
{
	if (passForm.password.value != passForm.password2.value) {
		alert('Entered passwords do not match');
		passForm.password.focus();
		passForm.password.select();
	return false;
	}
	return true
}
//-->
</script>
<ul>
<form action="action_biowriter.cfm" method="post" name="passForm" onSubmit="return validForm(this)">

  <table width="420" border="0" cellspacing="1" cellpadding="2">
  <tr><td colspan="2"> <font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small;"> Don't forget to re-enter your password in the Confirm Password field. Once you get a confirmation, you will be able to use the new password.</font><BR><br></td></tr>
   <tr bgcolor="#336699"> 
      <td colspan="2"> 
        <font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Change Employee Password</font>
      </td>
    </tr>
	 <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Employee:</font></td>
      <td> 
		<cfoutput query="getemployees"><font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#fname# #lname#</font>
		<input type="hidden" name="employeeid" value="#getemployees.employee_ndx#"></cfoutput>
      </td>
    </tr>

    <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Username:</font></td>
      <td> 
<cfoutput><input type="text" name="username" value="#getemployees.username#"  size="20" maxlength="20"><input type="Hidden" name="username_required"></cfoutput>
      </td>
    </tr>
    <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">New Password:</font></td>
      <td> 
        <input type="password" name="password"  size="20" maxlength="20"><input type="Hidden" name="password_required">
      </td>
    </tr>
	    <tr bgcolor="#f7f7f7"> 
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Confirm Password:</font></td>
      <td> 
        <input type="password" name="password2" size="20" maxlength="20">
      </td>
    </tr>
	<tr bgcolor="#eaeaea"><td colspan="2"><input type="Submit" name="Submit" value="Submit Employee Info"></td></tr>
  </table>
<br><br>
<input type="Hidden" name="functiontype" value="update">
<cfoutput><input type="Hidden" name="expirationdate" value="#dateadd('d',90,Dateformat(isBlank(getemployees.passexpires,now()),"mm/dd/yy"))#"></cfoutput>
<input type="Hidden" name="intranetuser" value="2">

<input type="hidden" name="return" value="1">
</form></ul>
<cfinclude template="/intranet/footer.cfm">

