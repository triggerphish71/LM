<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: admin/usermgmt/possessionreassignment.cfm  --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: November                  --->
<!--------------------------------------->
<cfset datasource = "DMS">

<cfquery name="getusers" datasource="#datasource#" dbtype="ODBC">
SELECT fname,lname, vw_employees.employee_ndx
FROM users,vw_employees
WHERE users.employeeid = vw_employees.employee_ndx AND vw_employees.employee_ndx <> #url.userid#
</cfquery>

<cfquery name="getuser" datasource="#datasource#" dbtype="ODBC">
SELECT fname,lname
FROM vw_employees
WHERE employee_ndx = #url.userid#
</cfquery>
<html>
<head>
	<title>Transfer Possessions</title>
</head>

<body bgcolor="White" leftmargin=0 topmargin=0 onLoad=window.moveBy(330,300)>
<form action="possessionaction.cfm" method="post">
	<table width="300" cellspacing="2" cellpadding="2" border="0">
		<tr bgcolor="#336699">
		    <td>
				&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Transfer Possessions</font>
			</td>
		</tr>
		<tr bgcolor="#f7f7f7">
		    <td>
				<cfoutput>&nbsp;<font color="##336699" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Owner: #getuser.fname# #getuser.lname#</font></cfoutput><br><br>
				&nbsp;<font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Select Recipient: </font>
				<select name="employeendx">
					<option value="" SELECTED>Choose...</option>
					<cfoutput query="getusers"><option value="#employee_ndx#">#fname# #lname#</option></cfoutput>
				</select>
				<input type="hidden" name="employeendx_required" value="Please select a recipient.">
			<br><p></p>
			</td>
		</tr>
		<tr bgcolor="#eaeaea">
		    <td>
				&nbsp;<input type="submit" name="Submit" value="Transfer">
			</td>
		</tr>
	</table>
	<cfoutput><input type="hidden" name="contentownerid" value="#url.userid#"></cfoutput>
</form>
</body>
</html>