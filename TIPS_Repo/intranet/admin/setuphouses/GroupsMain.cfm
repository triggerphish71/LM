<!----------------------------------------------------------------------------------------------
| DESCRIPTION 					                                                               |
|----------------------------------------------------------------------------------------------|
| GroupsMain.cfm - Groups Maintenance                             				               |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES																			   |
|----------------------------------------------------------------------------------------------|
| 					                                                                    	   |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| MLAW       | 11/01/05   | Create a tool to maintain Groups Table   		 				   |
----------------------------------------------------------------------------------------------->


<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfset session.CURRENTUSER_ID = 3025>
<cfset session.CURRENTUSER_NAME = 'mlaw'>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Groups Maintenance</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
li { list-style-type:circle; }
.record { color:##FF6600; }
.record:hover { background-color:##FFFF66; color:maroon; }
.notrequired { font-weight:lighter; }
.exempt { color:gray; font-weight:normal; }
.required { color:red; font-weight:normal; }
.completed { color:black; font-weight:bold; }
.optional { color:maroon; font-weight:normal; }
.rep_link { color:blue; }
.rep_link:hover { background-color:yellow; color:blue; }
.trlabel { color:blue; font-size:xx-small; background:yellow; padding:2px 2px 2px 2px; }
.newind { color:red; background-color:yellow; }
.newind:hover { color:red; background-color:yellow; letter-spacing:1px; }
</style>
<link rel="stylesheet" type="text/css" href="Style3.css">

<cfparam name="form.groupid" default="">
<cfset msg = "">
<cfif IsDefined("PageAction")>
	<cfswitch expression="#Form.PageAction#">
		<cfcase value="Insert">
			<cfif form.groupname is '' or form.systemgroup is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Record Added">
				<!--- Check to see if the record is already there in the table --->
				<cfquery name="CheckGroups" datasource="#Application.datasource#">
					select * from #Application.DmsDBServer#.dms.dbo.Groups where
					groupname = '#form.groupname#'
				</cfquery>
				<cfif CheckGroups.recordcount eq 0>
					<!--- Check if form values are empty --->
					<cftransaction action= "begin">
						<cftry>
							<cfquery name="InsertGroups" datasource="#Application.datasource#">
							
								INSERT INTO #Application.DmsDBServer#.dms.dbo.groups(
									groupname,
									securityid,
									systemgroup,
									user_id,
									created_date
								)
								values (
									'#form.groupname#',
									NULL,
									#form.systemgroup#,
									#session.CURRENTUSER_ID# ,
									getdate()
								)
								declare @vargroupid as int
								select @vargroupid = groupid from #Application.DmsDBServer#.dms.dbo.groups where groupname = '#form.groupname#'

								<!--- insert record into groupassignment table	 --->
								INSERT INTO #Application.DmsDBServer#.DMS.dbo.groupassignments (
									groupid,
									uniquecodeblockid
								)
								values	(
									@vargroupid,
									NULL
								)
								<!--- insert record into groupassignment table	 --->
								insert into #Application.DmsDBServer#.DMS.dbo.groupassignments (
									groupid,
									uniquecodeblockid
								)
								values	(
									@vargroupid,
									12
								)
								<!--- insert record into groupassignment table	 --->
								insert into #Application.DmsDBServer#.DMS.dbo.groupassignments
								(
									groupid
									,userid
								)
								values
								(
									3
									,#session.CURRENTUSER_ID#
								)

								<!--- insert record into groupassignment table	 --->
								insert into #Application.DmsDBServer#.DMS.dbo.groupassignments
								(
									groupid
									,userid
								)
								values
								(
									5
									,#session.CURRENTUSER_ID#
								)

								<!--- insert record into groupassignment table	 --->
								insert into #Application.DmsDBServer#.DMS.dbo.groupassignments
								(
									groupid
									,userid
								)
								values
								(
									@vargroupid
									,#session.CURRENTUSER_ID#
								)

								insert into #Application.DmsDBServer#.DMS.dbo.groupassignments(groupid, userid)
								select 
									g.groupid
									, h.cNumber
								from   
									DMS.dbo.groups g
								join   
									TIPS4.dbo.house h
								on     h.cName = g.groupname
								and    h.cName = '#form.groupname#'
									
								insert into #Application.DmsDBServer#.DMS.dbo.groupassignments (groupid, userid)
								select 
									3
									, h.cNumber
								from   
									TIPS4.dbo.House h
								where
									h.cName = '#form.groupname#'
										
								insert into #Application.DmsDBServer#.DMS.dbo.groupassignments (groupid, userid)
								select 
									3
									, h.cNumber
								from   
									TIPS4.dbo.House h
								where
									h.cName = '#form.groupname#'
									
							</cfquery>
							<cftransaction action="commit"/>
							<cfcatch type="database">
								<cfset msg = "Record Not Added">
								<cfset msg = msg & "<font color='red'>Error: Problem in Inserting the values into the Tables!</font>">
							<cftransaction action="rollback"/>
							</cfcatch>
						</cftry>
					</cftransaction>
				<cfelse>
					<cfset msg = "Record is already in the table!">
				</cfif>
			</cfif>
		</cfcase>
		<cfcase value="Update">
			<cfif form.groupname is '' or form.systemgroup is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Records Updated">
				<cftransaction action= "begin">
					<cftry>
						<cfquery name="UpdateGroups" datasource="#Application.datasource#">
							update Groups set
								groupname = '#form.groupname#',
								systemgroup = '#form.systemgroup#',
								user_id = #session.CURRENTUSER_ID#,
								created_date = getdate()
							where groupid = #form.groupid#
						</cfquery>
						<cftransaction action="commit"/>
						<cfcatch type="database">
							<cfset msg = "Record Not Updated">
							<cfset msg = msg & "<font color='red'>Error: Problem in Updating the values into the Tables!</font>">
						<cftransaction action="rollback"/>
						</cfcatch>
					</cftry>
				</cftransaction>
			</cfif>
		</cfcase>
		<cfcase value="Delete">
			<cfset msg = "Records Delete">
			<cftransaction action= "begin">
				<cftry>
					<cfquery name="DeleteGroups" datasource="#Application.datasource#">
						update Groups
							set dtRowDeleted = getdate()
						where
							iGroups_id = #form.iGroups_id#
					</cfquery>
					<cftransaction action="commit"/>
					<cfcatch type="database">
						<cfset msg = "Record Not Deleted">
						<cfset msg = msg & "<font color='red'>Error: Problem in Deleting the Record!</font>">
					<cftransaction action="rollback"/>
					</cfcatch>
				</cftry>
			</cftransaction>
		</cfcase>
	</cfswitch>
</cfif>

<cfquery name="getGroups" datasource="#Application.Datasource#">
	select * from #Application.DmsDBServer#.DMS.dbo.groups
	order by groupid
</cfquery>

<!--- JavaScript --->
<cfoutput>

<SCRIPT>
	function popUpFormElements(obj)
	{
		if (obj.value=='') {
			document.all['groupid1'].innerHTML= '';
			document.forms[0].groupid.value = '';
			document.forms[0].groupname.value = '';
			document.forms[0].securityid.value = '';
			document.forms[0].systemgroup.value = '';
			document.forms[0].user_id.value = '';
			document.forms[0].created_date.value = '';
		 }
		<cfloop query="getGroups">
		else if (obj.value=='#getGroups.groupid#')
		{
			//have all the document.field initialize here
			document.all['groupid1'].innerHTML= '#getGroups.groupid#';
			document.forms[0].groupname.value = '#getGroups.groupname#';
			document.forms[0].securityid.value = '#getGroups.securityid#';
			document.forms[0].systemgroup.value = '#getGroups.systemgroup#';
			document.forms[0].user_id.value = '#getGroups.user_id#';
			document.forms[0].created_date.value = '#dateformat(getGroups.created_date,'MM/DD/YYYY')#';
		}
		</cfloop>
	}
	function clearUpFormElements(obj)
	{
			document.all['groupid1'].innerHTML= '';
			document.forms[0].groupid.value = '';
			document.forms[0].groupname.value = '';
			document.forms[0].securityid.value = '';
			document.forms[0].systemgroup.value = '1';
			document.forms[0].user_id.value = '';
			document.forms[0].created_date.value = '#dateformat(now(),'MM/DD/yyyy')#';
	}
</script>
</cfoutput>
<style type="text/css">
<!--
.style1 {color: #FF0000}
body,td,th {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
-->
</style>
</head>
<body>
<form action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" >
<cfoutput>
<input type="hidden" name="PageAction" value="">
<table>
	<tr><td class="topleftcap" colspan="2"></td><td class="toprightcap" colspan="2"></td></tr>
	<tr>
	  <th class="leftrightborder" colspan="4">Groups Maintenance</th>
	</tr>
	<tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
	 <b>Choose from the List:</b><br>

	<select name="selectlist" size="20" onChange="popUpFormElements(this);">
		<cfloop query="getGroups">
			<option value='#getGroups.groupid#' style='color:blue;background:##eaeaea;'>#getGroups.groupname#</option>
		</cfloop>
	</select>
	</td>
	<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;font-weight:bold;"><table width="100%">
		<tr><td width="50%"><table align="center">
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">groupid:</td>
            <td>
				<SPAN ID="groupid1">#getGroups.groupid#</span>
				<input name="groupid" type="hidden" value="#getGroups.groupid#">
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">groupname:</span></td>
            <td>
				<input name="groupname" type="text" size="20" value="#getGroups.groupname#">
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">securityid:</td>
            <td>
				<input name="securityid" type="text" size="32" value="#getGroups.securityid#">
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">systemgroup:</span></td>
            <td>
				<input name="systemgroup" type="text" value="#getGroups.systemgroup#" size="1" maxlength="1">
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">cNumber(for groupassignments)</td>
            <td><input type="text" name="userid" size="4"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">user_id</td>
            <td><input type="text" name="user_id" value="#getGroups.user_id#" size="4"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">created_date</td>
            <td><input type="text" name="created_date" value="#getGroups.created_date#" size="10"></td>
          </tr>
          <tr valign="baseline">
            <td colspan="2" align="right" nowrap><table>
              <tr>
                <td><input name="Add" type="button" value="          Add            " onClick="Javascript:document.forms[0].PageAction.value='Insert';document.forms[0].submit();"></td>
                <td><input name="Update" type="button" value="          Update         " onClick="Javascript:document.forms[0].PageAction.value='Update';document.forms[0].submit();"></td>
                <td><input name="Delete" type="button" disabled="true" onClick="Javascript:document.forms[0].PageAction.value='Delete';document.forms[0].submit();" value="          Delete         "></td>
                <td><input name="Clear" type="button" value="          Clear          " onClick="clearUpFormElements(this);">
              </tr>
            </table></td>
            </tr>
        </table>
		  </td>
		</tr>
		</table>
	</td></tr>

	<tr>
		<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;"> </td>
		<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;"><a href="HouseMaster.cfm">Go To HouseMaster</a> </td>
	</tr>
	<tr><td colspan="4" align="right" class="leftrightborder"><b><cfoutput>#msg#</cfoutput></b></td></tr>
	<tr><td class="bottomleftcap" colspan="2"></td><td class="bottomrightcap" colspan="2"></td></tr>
</table>
</cfoutput>
</form>
</body>
</html>
