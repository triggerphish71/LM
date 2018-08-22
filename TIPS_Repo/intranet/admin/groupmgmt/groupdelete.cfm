
<cfset datasource = "DMS">

<cfquery name="getgroups" datasource="#datasource#" dbtype="ODBC">
Select *
From groups
where systemgroup = 0  AND user_id = #session.userid#
</cfquery>
<cfinclude template="/intranet/header.cfm">
<ul><form action="groupdeleteconfirm.cfm" method="POST">
<table width="400" border="0" cellspacing="1" cellpadding="2">

<tr bgcolor="#663300">
	<td>
		&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Delete a Group</font>
	</td>
</tr>
	<tr bgcolor="#f7f7f7">
      <td>
	  <cfif getgroups.recordcount is 0>
		<ul>	  
		<BR>
		<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">There are no groups to Delete.</font></ul>
	<cfelse>
	&nbsp;<font color="Maroon" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">Will not show system groups.</font>
	<BR>
	  <br>
	  &nbsp;<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Select Group:</font> &nbsp;&nbsp;
     
        <select name="groupid">
				<cfoutput query="getgroups"><option value="#groupid#">#groupname#</option></cfoutput>
			</select>
			<br>
			<br>
			</cfif>
		</td>
	</tr>
	<tr  bgcolor="#eaeaea">
    <td>
	<cfif getgroups.recordcount is 0>
 		<input type="button" name="back" value="Back" onClick="history.back();">
 	<cfelse>
 		<input type="Submit" name="submit">
  	</cfif>
		</td>
	</tr>
</table>
</form>
</ul>

<cfinclude template="/intranet/footer.cfm">
