<cfset datasource = "DMS">

<!---Modified by Sathya Sanipina on 02/21/2008, The drop down list needed to be in the alphabetical order so modified the query.--->
<cfquery name="getuser" datasource="#datasource#" dbtype="ODBC">
Select employee_ndx,fname,lname
From vw_Employees order by  fname
</cfquery>
<cfinclude template="/intranet/header.cfm">
<ul>
<form action="biodeleteconfirm.cfm" method="POST">
<table width="400" border="0" cellspacing="2" cellpadding="2">
<tr bgcolor="#663300">
	<td>
		<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Delete an Employee</font>
	</td>
</tr>
<tr bgcolor="#f7f7f7">
	<td><BR><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">&nbsp;Select an Employee:</font>
	
	<select name="employeeid">
	<option value="">Choose...</option>
		<cfoutput query="getuser">
		<option value="#employee_ndx#">#fname#  #lname#</option></cfoutput>
	</select>&nbsp;&nbsp;
	<BR><br>
</tr>
<tr bgcolor="#eaeaea">
<td>
<input type="hidden" name="employeeid_required" value="">
<input type="Submit" name="Submit" value="Get Employee">
</td>
</tr>
	
</table>


</form>
</ul>
<cfinclude template="/intranet/footer.cfm">
