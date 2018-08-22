
<cfset datasource = "DMS">

<!--- group update preview --->
<cfinclude template="/intranet/header.cfm">
<form action="action_group.cfm" method="POST">
    
		<cfquery name="getupdateinfo" datasource="#datasource#" dbtype="ODBC">
			Select *
			From groups
			Where groupid = #groupid#
		</cfquery>
		
	<!--- 	<cfquery name="getsecurityclearance" datasource="#datasource#" dbtype="ODBC">
		Select securityid
		From groups
		</cfquery> --->

<!--- 	<cfset listing = ValueList(getsecurityclearance.securityid)> --->
		
<cfoutput query="getupdateinfo" group="groupname">
	<ul>
	<table width="400" border="0" cellspacing="2" cellpadding="2">
	   <tr bgcolor="##336699">
	<td colspan="2">
		&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Edit a Group</font>
	</td>
</tr>
		<tr bgcolor="##f7f7f7">
      <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Group Name:</font></td>
      <td> 
	  <input type="text" name="groupname" value="#groupname#">
      </td>
		</tr>
		<tr bgcolor="##f7f7f7">
    <td colspan="2">&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">System Group?</font>

	<cfif getupdateinfo.systemgroup is 0>
		<input type="checkbox" name="systemgroup" value="#getupdateinfo.systemgroup#">
	<cfelse>
		<input type="checkbox" name="systemgroup" value="#getupdateinfo.systemgroup#" checked>
	</cfif>
	
	</td>
</tr>
		<!--- <tr bgcolor="##f7f7f7">
		      <td colspan="2"> 
			  <font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Current Clearance Level: #securityid#</font>
		       </td>
		</tr> --->
		<!--- <tr bgcolor="##f7f7f7">
		<td>
			<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">New Security Clearance</font></td>
		      <td> 
		        <select name="securityid">
				<cfloop index="i" from="1" to="10">
					
					<cfif Find(i,listing,1) is 0>
						<cfoutput><option value="#i#">#i#</option></cfoutput>
					</cfif>
				</cfloop>
				</select>&nbsp;&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">(1 - 10)</font>
			</td>
		</tr> --->
		<tr bgcolor="##eaeaea">
		      <td colspan="2"> 
		        <input type="Hidden" name="groupid" value="#groupid#">
				<input type="Hidden" name="functiontype" value="update">
				<input type="Submit" name="Submit" value="Update">
			</td>
		</tr>
	</form>
	</table></ul>
</cfoutput>
<cfinclude template="/intranet/Footer.cfm">
</body>
</html>