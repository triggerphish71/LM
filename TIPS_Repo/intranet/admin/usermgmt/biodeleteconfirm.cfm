<cfset datasource = "DMS">

<cfquery name="getuser" datasource="#datasource#" dbtype="ODBC">
Select vw_Employees.employee_ndx,vw_Employees.fname,vw_Employees.lname,users.username
From vw_Employees,users
Where employee_ndx = #employeeid# AND vw_Employees.employee_ndx = users.employeeid
</cfquery>

<cfinclude template="/intranet/header.cfm">
<form action="action_biowriter.cfm" method="POST">
<cfoutput query="getuser"><ul>
	<table width="400" border="0" cellspacing="2" cellpadding="2">
	<tr>
    <td bgcolor="##663300"><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Delete this user from the database?</font></td>
</tr>

<tr bgcolor="##f7f7f7">
    <td><BR>
				<ul><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Firstname:</font>  #fname#<br>
				<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Lastname:</font>  #lname#<br>
				
				<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Username:</font>  #username#<br><br>

				
		</td>
</tr>
<tr bgcolor="##eaeaea">
    <td>
	<input type="hidden" name="employeeid" value="#employee_ndx#">
	<input type="Hidden" name="functiontype" value="delete">
	<input type="Submit" name="Submit" value="Delete">&nbsp;&nbsp;<input type="button" name="Cancel" value="Cancel" onClick="history.back()";></td>
</tr>
</table>
</form>
</cfoutput></ul>
<cfinclude template="/intranet/footer.cfm">