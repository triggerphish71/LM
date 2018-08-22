
<cfset datasource = "DMS">

<cfquery name="getemployees" datasource="#datasource#" dbtype="ODBC">
Select u.dtrowdeleted deleted, e.*
From vw_employees e
join users u on e.employee_ndx = u.employeeid
Order by u.dtrowdeleted, lname, fname
</cfquery>

<cfinclude template="/intranet/header.cfm">
<ul>
<form action="updateview.cfm" method="post">
	<table width="300" border="0" cellspacing="1" cellpadding="2">
	<tr bgcolor="#006699">
		<td>
			&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Edit Employee Info</font>
		</td>
	</tr>
	
	<tr bgcolor="#f7f7f7">
		<td>
			&nbsp;<font color="dimgray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">
		<cfif getemployees.recordcount is 0>
		There are no users to edit.
		</td>
		</tr>
		<tr bgcolor="#eaeaea">
		<td>
			<input type="button" name="Back" value="Back" onClick="history.back();">
		</td>
	</tr>
		<cfelse>
		<BR>
		Select Employee:</font>&nbsp;<select name="userid">
		<option value="">Choose...</option>
						<cfoutput query="getemployees"> <cfif getemployees.deleted neq ""><cfset del='style="background-color:##eaeaea;color:##666666;"'><cfelse><cfset del=''></cfif>
						<option value="#employee_ndx#"#del#>#lname#, #Fname#</option>
						</cfoutput>
					</select>
					<BR><br>
		</td>
		</tr>
		<tr bgcolor="#eaeaea">
		<td>
			&nbsp;<input type="submit" name="submit" value="Get Employee">
		</td>
	</tr>
	</cfif>
	</table>
		</form>
		</ul>
		<cfinclude template="/intranet/footer.cfm">
		</body>
</html>
