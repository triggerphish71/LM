<!--- ------------------------------------------- --->
<cfset datasource = "DMS">
<!--- <cfquery name="getsecurityclearance" datasource="#datasource#" dbtype="ODBC">
Select securityid
From groups
</cfquery> --->
<cfinclude template="/intranet/header.cfm">
<!--- you cant create a group with the same security level --->
<!--- <cfset listing = ValueList(getsecurityclearance.securityid)> --->
<ul>
<form action="action_group.cfm" method="POST">
<table width="300" border="0" cellspacing="2" cellpadding="2">
<tr bgcolor="#336666">
	<td colspan="2">&nbsp;
		<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Create a Group</font>
	</td>
</tr>
<tr bgcolor="#f7f7f7">
    <td valign="middle"><br>&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Group Name:</font><br><br></td>
    <td valign="middle"><br><input type="Text" name="groupname"><br><br></td>
</tr>
<tr bgcolor="#f7f7f7">
    <td valign="middle">&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">System Group?</font></td>
    <td valign="middle"><input type="checkbox" name="systemgroup" value="1"></td>
</tr>

<!--- <tr bgcolor="#f7f7f7">
    <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Security Clearance:</font></td>
    <td>
	<!--- this small loop allows for the drop down list to  omit entries in the data base --->
	<select name="securityid">
	<cfloop index="i" from="1" to="10">
		
		<cfif Find(i,listing,1) is 0>
			<cfoutput><option value="#i#">#i#</option></cfoutput>
		</cfif>
	</cfloop>
	</select>
	
    <td>
		(1 - 10)
	</td>
</tr> --->
<tr bgcolor="#eaeaea">
    <td colspan="2"><input type="Submit" name="Submit" value="Submit"></td>

</tr>
</table>
<input type="Hidden" name="functiontype" value="insert">
<input type="hidden" name="groupname_required">
</form></ul>
<cfinclude template="/intranet/footer.cfm">
