<!----------------------------------------------------------------------------------------------
| DESCRIPTION 					                                                               |
|----------------------------------------------------------------------------------------------|
| UsersMain.cfm - Users Maintenance                             				               |
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
| MLAW       | 11/01/05   | Create a tool to maintain DMS.dbo.users Table   		 		   |
----------------------------------------------------------------------------------------------->


<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfset session.CURRENTUSER_ID = 3025>
<cfset session.CURRENTUSER_NAME = 'mlaw'>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Users Maintenance</title>
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

<cfparam name="form.userid" default="">
<cfset msg = "">
<cfif IsDefined("PageAction")>
	<cfswitch expression="#Form.PageAction#">
		<cfcase value="Insert">
			<cfif form.house is '' or form.password is '' or form.employeeid is '' or
				  form.passexpires is ''  or form.expires is '' or form.creationdate is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Record Added">
				<!--- Check to see if the record is already there in the table --->
				<cfquery name="CheckUsers" datasource="#Application.datasource#">
					select * from #Application.DmsDBServer#.DMS.dbo.users where
					username = '#form.house#'
				</cfquery>
				<cfif CheckUsers.recordcount eq 0>
					<!--- Check if form values are empty --->
					<cftransaction action= "begin">
						<cftry>
							<cfquery name="InsertUsers" datasource="#Application.datasource#">
								INSERT INTO #Application.DmsDBServer#.DMS.dbo.users (
									USERNAME,
									PASSWORD,
									employeeid,
									passexpires,
									creationdate,
									expires,
									created_by_user_id
								)
								VALUES (
									'#form.house#',
									'#form.password#',
									 #form.employeeid#,
									'#form.passexpires#',
									'#form.creationdate#',
									'#form.expires#',
									 #session.CURRENTUSER_ID#
								)
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
			<cfif form.house is '' or form.password is '' or form.employeeid is '' or
				  form.passexpires is ''  or form.expires is '' or form.creationdate is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Records Updated">
				<cftransaction action= "begin">
					<cftry>
						<cfquery name="UpdateUsers" datasource="#Application.datasource#">
							update #Application.DmsDBServer#.DMS.dbo.users  set
									username = '#form.house#',
									password = '#form.password#',
									employeeid = #form.employeeid#,
									passexpires = '#form.passexpires#',
									expires = '#form.expires#',
									creationdate = '#form.creationdate#',
									created_by_user_id = #Session.CURRENTUSER_ID#
							where userid = #form.userid#
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
						update users
							set dtRowDeleted = getdate()
						where
							userid = #form.userid#
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

<cfquery name="getusers" datasource="#Application.Datasource#">
	select * from #Application.DmsDBServer#.DMS.dbo.users u
		join house h
		on h.cNumber = u.employeeid
	  where h.bIsSandBox = 0
		  and h.dtrowdeleted is null
	order by h.cName
</cfquery>

<cfquery name="getHouses" datasource="#Application.Datasource#">
	select * from House h
		WHERE h.bIsSandBox in (1,0)
		  and h.dtrowdeleted is null
	order by h.cName
</cfquery>


<!--- JavaScript --->
<cfoutput>

<SCRIPT>
	function popUpFormElements(obj)
	{
		if (obj.value=='') {
			document.all['userid1'].innerHTML= '';
			document.forms[0].house.value = '';
			document.forms[0].password.value = '';
			document.forms[0].employeeid.value = '';
			document.forms[0].passexpires.value = '';
			document.forms[0].expires.value = '';
			document.forms[0].creationdate.value = '';
			document.forms[0].created_by_user_id.value = '';
		 }
		<cfloop query="getusers">
		else if (obj.value=='#getusers.userid#')
		{
			//have all the document.field initialize here
			document.all['userid1'].innerHTML= '#getusers.userid#';
			document.forms[0].userid.value = '#getusers.userid#';
			document.forms[0].house.value = '#getusers.username#';
			document.forms[0].password.value = '#getusers.password#';
			document.forms[0].employeeid.value = '#getusers.employeeid#';
			document.forms[0].passexpires.value = '#dateformat(getusers.passexpires,'MM/DD/YYYY')#';
			document.forms[0].expires.value = '#dateformat(getusers.expires,'MM/DD/YYYY')#';
			document.forms[0].creationdate.value = '#dateformat(getusers.creationdate,'MM/DD/YYYY')#';
			document.forms[0].created_by_user_id.value = '#getusers.created_by_user_id#';
		}
		</cfloop>
	}
	function clearUpFormElements(ob)
	{
			document.all['userid1'].innerHTML= '';
			document.forms[0].house.value = '';
			document.forms[0].password.value = 'tips';
			document.forms[0].employeeid.value = '';
			document.forms[0].passexpires.value = '12/31/2010';
			document.forms[0].expires.value = '12/31/2010';
			document.forms[0].creationdate.value = '#dateformat(now(),'MM/DD/yyyy')#';
			document.forms[0].created_by_user_id.value = '';
	}
	function popUpHouseName(obj)
	{
		<cfloop query="getHouses">
		if (obj.value=='#getHouses.iHouse_ID#')
		{
			//have all the document.field initialize here

			document.forms[0].house.value = '#getHouses.iHouse_ID#';
			document.forms[0].employeeid.value = '#getHouses.cNumber#';

		}
		</cfloop>
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
<form action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" name="usersmain" >
<cfoutput>
<input type="hidden" name="PageAction" value="">
<table>
	<tr><td class="topleftcap" colspan="2"></td><td class="toprightcap" colspan="2"></td></tr>
	<tr>
	  <th class="leftrightborder" colspan="4">Users Maintenance</th>
	</tr>
	<tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
	 <b>Choose from the List:</b><br>

     <select name="selectlist" size="20" onChange="popUpFormElements(this);">
       <cfloop query="getusers">
         <option value='#getusers.userid#' style='color:blue;background:##eaeaea;'>#getusers.cName#</option>
       </cfloop>
     </select>	</td>
	<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;font-weight:bold;"><table width="100%">
		<tr><td width="50%"><table align="center">
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">iuserid:</td>
            <td>
				<input name="userid" type="hidden" value="#getusers.userid#"><span id="userid1">#getusers.userid#</span>
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">house:</span></td>
            <td>

<!--- 				<select name="house" onChange="popUpHouseName(this);" >
				<cfloop query="getHouses">
					<option value="#getHouses.iHouse_ID#">#getHouses.cName#</option>
				</cfloop>
				</select>  --->
				<input name="house" type="text" size="20" value="#getHouses.cName#">
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">password:</span></td>
            <td>
				<input name="password" type="text" size="20" value="#getusers.password#">
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">employeeid:</span></td>
            <td>
				<input name="employeeid" type="text" value="#getusers.employeeid#" size="20">
				e.g. cNumber </td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">passexpires</td>
            <td><input type="text" name="passexpires" value="#getusers.passexpires#" size="10"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">expires</td>
            <td><input type="text" name="expires" value="#getusers.expires#" size="10	"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">creationdate</td>
            <td><input type="text" name="creationdate" value="#getusers.creationdate#" size="10"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">created_by_user_id</td>
            <td><input type="text" name="created_by_user_id" value="3025" size="4"></td>
          </tr>
          <tr valign="baseline">
            <td colspan="2" align="right" nowrap><table>
              <tr>
                <td><input name="Add" type="button" value="          Add            "onClick="Javascript:document.forms[0].PageAction.value='Insert';document.forms[0].submit();"></td>
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
		<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;"><a href="Housemaster.cfm">Go To House Master</a> </td>
	</tr>
	<tr><td colspan="4" align="right" class="leftrightborder"><b><cfoutput>#msg#</cfoutput></b></td></tr>
	<tr><td class="bottomleftcap" colspan="2"></td><td class="bottomrightcap" colspan="2"></td></tr>
</table>
</cfoutput>
</form>

</body>
</html>
