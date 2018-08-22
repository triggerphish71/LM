<!--- ------------------------------------------- --->
<!--- Created By Andy leontovich --->
<!--- Nov, 16,99 --->
<!--- Update form for Group Creation --->
<!--- Convergent Communications, Inc. --->
<!--- ------------------------------------------- --->
<cfset datasource = "DMS">

<cfparam name="employeeid" default="0">
<cfparam name="submitResponse" default="0">

<cfquery name="getgroups" datasource="#datasource#" dbtype="ODBC">
Select * From Groups order by groupname
</cfquery>
<!--- Where user_id = #session.userid# --->

<cfinclude template="/intranet/header.cfm">
<ul>
	<form action="groupupdatepreview.cfm" method="POST">
	<table width="400" border="0" cellspacing="1" cellpadding="2">
	<tr bgcolor="#336699">
		<td colspan="2">
			&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Edit a Group</font>
		</td>
	</tr>
		<tr bgcolor="#f7f7f7">
			
	      <td  colspan="2">
		  <br> 
		  <cfif getgroups.recordcount is 0>
			<ul><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">There are no groups to edit.</font></ul>
		  <cfelse>
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
	    <td  colspan="2"> 
	 		&nbsp;
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
