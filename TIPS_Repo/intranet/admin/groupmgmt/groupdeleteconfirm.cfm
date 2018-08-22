 
 <cfset datasource = "DMS">
 
<cfquery name="getgroup" datasource="#datasource#" dbtype="ODBC">
Select *
From groups
Where groupid = #groupid#
</cfquery>

<cfquery name="getdependenciesemp" datasource="#datasource#" dbtype="ODBC">
Select lname, fname
From groupassignments,vw_employees
Where groupassignments.groupid = #groupid# AND groupassignments.userid = vw_employees.employee_ndx
</cfquery>

<cfquery name="getdependenciessection" datasource="#datasource#" dbtype="ODBC">
Select sectionname
From groupassignments,codeblocks
Where groupassignments.groupid = #groupid# AND groupassignments.uniquecodeblockid = codeblocks.uniqueid
</cfquery>


<cfinclude template="/intranet/header.cfm">
<ul>
<form action="action_group.cfm" method="POST">

  
<table width="600" border="0" cellspacing="2" cellpadding="2">
   <tr bgcolor="#663300">
	<td colspan="2" >
		&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Delete a Group</font>
	</td></tr>
<tr bgcolor="#f7f7f7">
    <td>&nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Delete this group from the database?</font></td>
	<td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small; font-weight: bold;">Dependencies</font></td>
	</tr>
<tr bgcolor="#f7f7f7">
    <td>
	<br>
		<ul>
		<cfoutput query="getgroup">
		<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Group name:</font>  <font color="DimGray" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">#UCase(groupname)#</font></cfoutput></ul>
		<cfif getdependenciessection.recordcount is not 0 OR getdependenciesemp.recordcount is not 0>
<cfoutput>&nbsp;<font color="Maroon" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">You cannot delete any group that still has dependencies. <BR><BR>&nbsp;Click the appropriate button below to remove any &nbsp;associations from the #UCase(getgroup.groupname)# group.</font><BR><br></cfoutput>
		</cfif>
		
			<input type="Hidden" name="functiontype" value="delete">
	</td>
<td valign="top">
<select name="assignments" size="7">
	<cfif getdependenciesemp.recordcount is not 0>
		<cfoutput query="getdependenciesemp"><option>#lname#, #fname#</option></cfoutput>
	</cfif>
	<cfif getdependenciessection.recordcount is not 0 AND getdependenciesemp.recordcount is not 0>
		<option>__________________</option>
	</cfif>
	<cfif getdependenciessection.recordcount is not 0>
		<cfoutput query="getdependenciessection"><option>#sectionname#</option></cfoutput>
	</cfif>
	<cfif getdependenciessection.recordcount is 0 AND getdependenciesemp.recordcount is 0>
		<option>none</option>
	</cfif>
</select>
</td>
</tr>
 <tr bgcolor="#eaeaea">
<cfif getdependenciessection.recordcount is 0 AND getdependenciesemp.recordcount is 0>
 	<td colspan="2">
		<input type="Submit" name="Submit" value="Delete">&nbsp;&nbsp;&nbsp;<input type="button" name="cancel" value="Cancel" onClick="history.back();">
		<cfoutput><input type="hidden" name="groupid" value="#groupid#"></cfoutput>
	</td>
<cfelse>
	<td colspan="2">
	<cfif listfindNocase(session.codeblock,19) GT 0>
		<cfif getdependenciessection.recordcount is not 0>
			<input type="button" name="editsections" value="Edit Section Assignments" onClick="location.href = 'http://#SERVER_NAME#/intranet/admin/securityassignment.cfm?function=2'">
		</cfif>
		&nbsp;&nbsp;&nbsp;
		<cfif getdependenciesemp.recordcount is not 0>
			<input type="button" name="editemp" value="Edit Employee Assignments" onClick="location.href = 'http://#SERVER_NAME#/intranet/admin/securityassignment.cfm?function=1'">
		</cfif>
	<cfelse>
		&nbsp;
	</cfif>
	</td>
</cfif>
	
</tr>
</table>

</form>

<cfinclude template="/intranet/Footer.cfm">

