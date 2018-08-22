<!----------------------------------------------------------------------------------------------
| DESCRIPTION 					                                                               |
|----------------------------------------------------------------------------------------------|
| HouseLogMain.cfm - HouseLog Maintenance                                                      |
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
| MLAW       | 10/31/05   | Create a tool to maintain HouseLog Table   		 				   |
----------------------------------------------------------------------------------------------->

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfset session.CURRENTUSER_ID = 3025>
<cfset session.CURRENTUSER_NAME = 'mlaw'>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>House Log Maintenance</title>
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

<cfparam name="form.iHouseLog_ID" default="">
<cfset msg = "">
<cfif IsDefined("PageAction")>
	<cfswitch expression="#Form.PageAction#">
		<cfcase value="Insert">
			<cfif form.iHouse_ID is '' or form.dtCurrentTipsMonth is '' or form.DtActualEffective is '' or 
				  form.DtAcctStamp is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Record Added">
				
				<!--- Check to see if the record is already there in the table --->
				<cfquery name="CheckHouseLog" datasource="#Application.datasource#">
					select * from HouseLog where
					iHouse_ID = #form.iHouse_ID#
				</cfquery>
				<cfif CheckHouseLog.recordcount eq 0>
					<!--- Check if form values are empty --->
					<cftransaction action= "begin">
						<cftry>
							<cfquery name="InsertHouseLog" datasource="#Application.datasource#">
								INSERT INTO TIPS4.dbo.HouseLog(
								iHouse_ID, 
								dtCurrentTipsMonth, 
								dtActualEffective, 
								dtAcctStamp, 
								iRowStartUser_ID, 
								dtRowStart, 
								cRowStartUser_ID
								)
								VALUES(	
								#form.iHouse_ID#, 
								'#form.dtCurrentTipsMonth#',
								'#form.dtActualEffective#', 
								'#form.dtAcctStamp#', 
								#session.CURRENTUSER_ID#,
								getdate(), 
								'#session.CURRENTUSER_NAME#'
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
			<cfif form.iHouse_ID is '' or form.dtCurrentTipsMonth is '' or form.DtActualEffective is '' or 
				  form.DtAcctStamp is ''>
				<cfset msg = "Form Field are left blank. Cannot Update blank values!">
			<cfelse>
				<cfset msg = "Records Updated">
				<cftransaction action= "begin">
					<cftry>
						<cfquery name="UpdateAnciCharges" datasource="#Application.datasource#">
							update HouseLog set 
								iHouse_ID = #form.iHouse_ID#, 
								dtCurrentTipsMonth = '#form.dtCurrentTipsMonth#', 
								dtActualEffective = '#form.dtActualEffective#', 
								dtAcctStamp = '#form.dtAcctStamp#', 
								iRowStartUser_ID = #session.CURRENTUSER_ID#, 
								dtRowStart = getdate(), 
								cRowStartUser_ID = '#session.CURRENTUSER_NAME#'
							where iHouselog_ID = #form.iHouselog_id#
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
					<cfquery name="DeleteHouseLog" datasource="#Application.datasource#">
						update HouseLog 
							set dtRowDeleted = getdate()
						where 
							iHouseLog_ID = #form.iHouseLog_id#
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
	
<cfquery name="getHouses" datasource="#Application.Datasource#">
	select * from houselog hl
		join house h
		on h.ihouse_ID = hl.ihouse_ID
		and h.bIsSandbox = 0
		order by h.cname
</cfquery>

<cfquery name="getHouse" datasource="#Application.Datasource#">
select * from house where dtrowdeleted is null  order by cname
</cfquery>
<!--- JavaScript --->
<cfoutput>

<SCRIPT>
	function popUpHouseField(obj)
	{
		<cfloop query="getHouse">
		if (obj.value=='#getHouse.iHouse_id#') {
			document.forms[0].iHouse_id.value = '#getHouse.iHouse_id#'; 
		}
		</cfloop>
	}
	function popUpFormElements(obj)
	{
		if (obj.value=='') { 
			document.all['ihouselog_id'].innerHTML= '';
			document.forms[0].iHouse_id.value = '';
			document.forms[0].dtCurrentTipsMonth.value = '';
			document.forms[0].bIsPDclosed.value = '';
			document.forms[0].bIsOpsMgrClosed.value = '';
			document.forms[0].dtActualEffective.value = '';
			document.forms[0].cComments.value = '';
			document.forms[0].dtAcctStamp.value = '';
			document.forms[0].iRowStartUser_ID.value = '';
			document.forms[0].dtRowStart.value = '';
			document.forms[0].iRowEndUser_ID.value = '';
			document.forms[0].dtRowEnd.value = '';
			document.forms[0].iRowDeletedUser_ID.value = '';
			document.forms[0].dtRowDeleted.value = '';
			document.forms[0].cRowStartUser_ID.value = '';
			document.forms[0].cRowEndUser_ID.value = '';
			document.forms[0].cRowDeletedUser_ID.value = '';
		 }
		<cfloop query="getHouses">
		else if (obj.value=='#getHouses.iHouse_id#') 
		{ 
			//have all the document.field initialize here
			document.all['ihouselog_id'].innerHTML= '#getHouses.iHouselog_id#';
			document.forms[0].iHouse_id.value = '#getHouses.iHouse_ID#';
			document.forms[0].Houselist.value = '#getHouses.iHouse_id#';
			document.forms[0].dtCurrentTipsMonth.value = '#DateFormat(getHouses.dtCurrentTipsMonth,'MM/DD/YYYY')#';
			document.forms[0].bIsPDclosed.value = '#getHouses.bIsPDclosed#';
			document.forms[0].bIsOpsMgrClosed.value = '#getHouses.bIsOpsMgrClosed#';
			document.forms[0].dtActualEffective.value = '#DateFormat(getHouses.dtActualEffective,'MM/DD/YYYY')#';
			document.forms[0].cComments.value = '#getHouses.cComments#';
			document.forms[0].dtAcctStamp.value = '#DateFormat(getHouses.dtAcctStamp,'MM/DD/YYYY')#';
			document.forms[0].iRowStartUser_ID.value = '#getHouses.iRowStartUser_ID#';
			document.forms[0].dtRowStart.value = '#DateFormat(getHouses.dtRowStart,'MM/DD/YYYY')#';
			document.forms[0].iRowEndUser_ID.value = '#getHouses.iRowEndUser_ID#';
			document.forms[0].dtRowEnd.value = '#getHouses.dtRowEnd#';
			document.forms[0].iRowDeletedUser_ID.value = '#getHouses.iRowDeletedUser_ID#';
			document.forms[0].dtRowDeleted.value = '#getHouses.dtRowDeleted#';
			document.forms[0].cRowStartUser_ID.value = '#getHouses.cRowStartUser_ID#';
			document.forms[0].cRowEndUser_ID.value = '#getHouses.cRowEndUser_ID#';
			document.forms[0].cRowDeletedUser_ID.value = '#getHouses.cRowDeletedUser_ID#';
		}
		</cfloop>
	}
	function clearUpFormElements(ob)
	{
			document.all['ihouselog_id'].innerHTML= '';
			document.forms[0].iHouse_id.value = '';
			document.forms[0].dtCurrentTipsMonth.value = '';
			document.forms[0].bIsPDclosed.value = '';
			document.forms[0].bIsOpsMgrClosed.value = '';
			document.forms[0].dtActualEffective.value = '#dateformat(now(),'MM/DD/yyyy')#';
			document.forms[0].cComments.value = '';
			document.forms[0].dtAcctStamp.value = '#DateFormat(now(),'MM/DD/YYYY')#';
			document.forms[0].iRowStartUser_ID.value = '';
			document.forms[0].dtRowStart.value = '#dateformat(now(),'MM/DD/yyyy')#';
			document.forms[0].iRowEndUser_ID.value = '';
			document.forms[0].dtRowEnd.value = '';
			document.forms[0].iRowDeletedUser_ID.value = '';
			document.forms[0].dtRowDeleted.value = '';
			document.forms[0].cRowStartUser_ID.value = '';
			document.forms[0].cRowEndUser_ID.value = '';
			document.forms[0].cRowDeletedUser_ID.value = '';
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
	<tr><th class="leftrightborder" colspan="4">House Log Maintenance</th></tr>
	<tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
	 <b>Choose from the List:</b><br>
			
	<select name="selectlist" size="20" onChange="popUpFormElements(this);">
		<cfloop query="getHouses">
			<option value='#getHouses.iHouse_id#' style='color:blue;background:##eaeaea;'>#getHouses.cName#</option>
		</cfloop>
	</select> 
	</td>
	<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;font-weight:bold;"><table width="100%">
		<tr><td width="50%"><table align="center">
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">IHouseLog_ID:</td>
            <td>
				<SPAN ID="ihouselog_id">#getHouses.iHouseLog_ID#</span>
				<input name="iHouseLog_ID" type="hidden" value="#getHouses.iHouseLog_ID#">					
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">IHouse_ID:</font></td>
            <td>
				<input name="iHouse_id" type="text" value="#getHouses.iHouse_ID#" size="4" readonly="true">		
				<cfset variHouse_id = getHouses.iHouse_id>
				<select name="Houselist"  onChange="popUpHouseField(this);">
				<cfloop query="getHouse">
					<option value='#getHouse.iHouse_id#' style='color:blue;background:##eaeaea;'
					<cfif IsDefined("form.iHouse_id")>
						<cfif getHouse.iHouse_id EQ form.iHouse_id>
							Selected
						</cfif> 
					<cfelse>
						<cfif getHouse.iHouse_id EQ variHouse_id>
							Selected
						</cfif> 
					</cfif>>#getHouse.cName#</option>
				</cfloop>
				</select>
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">DtCurrentTipsMonth:</font></td>
            <td>
				<input name="dtCurrentTipsMonth" type="text" value="#getHouses.DtCurrentTipsMonth#" size="10"> 
				MM/01/YYYY</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">BIsPDclosed:</td>
            <td><input type="checkbox" name="bIsPDclosed" value="#getHouses.BIsPDclosed#" ></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">BIsOpsMgrClosed:</td>
            <td><input type="checkbox" name="bIsOpsMgrClosed" value="#getHouses.BIsOpsMgrClosed#" ></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">DtActualEffective:</td>
            <td>
				<input name="dtActualEffective" type="text" size="10" value="#getHouses.DtActualEffective#">
				MM/DD/YYYY			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">CComments:</td>
            <td><input name="cComments" type="text" size="32" value="#getHouses.CComments#"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">DtAcctStamp:</font></td>
            <td>
			<input name="dtAcctStamp" type="text" size="10" value="#getHouses.DtAcctStamp#">
			MM/01/YYYY
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">IRowStartUser_ID:</font></td>
            <td><input type="text" name="iRowStartUser_ID" value="#getHouses.IRowStartUser_ID#" size="4" readonly="true"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">DtRowStart:</font></td>
            <td>
				<input name="dtRowStart" type="text" value="#getHouses.DtRowStart#" size="10" readonly="true">
				MM/DD/YYYY			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">IRowEndUser_ID:</td>
            <td><input type="text" name="iRowEndUser_ID" value="#getHouses.IRowEndUser_ID#" size="32" readonly="true"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">DtRowEnd:</td>
            <td><input type="text" name="dtRowEnd" value="#getHouses.DtRowEnd#" size="32" readonly="true"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">IRowDeletedUser_ID:</td>
            <td><input type="text" name="iRowDeletedUser_ID" value="#getHouses.IRowDeletedUser_ID#" size="32" readonly="true"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">DtRowDeleted:</td>
            <td><input type="text" name="dtRowDeleted" value="#getHouses.DtRowDeleted#" size="32" readonly="true"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">CRowStartUser_ID:</font></td>
            <td><input type="text" name="cRowStartUser_ID" value="#getHouses.CRowStartUser_ID#" size="32" readonly="true"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">CRowEndUser_ID:</td>
            <td><input type="text" name="cRowEndUser_ID" value="#getHouses.CRowEndUser_ID#" size="32" readonly="true"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">CRowDeletedUser_ID:</td>
            <td><input type="text" name="cRowDeletedUser_ID" value="#getHouses.CRowDeletedUser_ID#" size="32" readonly="true"></td>
          </tr>
          <tr valign="baseline">
            <td colspan="2" align="right" nowrap><table>
              <tr>
                <td><input name="Add" type="button" value="          Add            "onClick="Javascript:document.forms[0].PageAction.value='Insert';document.forms[0].submit();"></td>
                <td><input name="Update" type="button" value="          Update         " onClick="Javascript:document.forms[0].PageAction.value='Update';document.forms[0].submit();"></td>
                <td><input name="Delete" type="button" value="          Delete         " onClick="Javascript:document.forms[0].PageAction.value='Delete';document.forms[0].submit();"></td>
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
		<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;"><a href="HouseMaster.cfm">Go To HouseMaster</a></td>
	</tr>	
	<tr><td colspan="4" align="right" class="leftrightborder"><b><cfoutput>#msg#</cfoutput></b></td></tr>
	<tr><td class="bottomleftcap" colspan="2"></td><td class="bottomrightcap" colspan="2"></td></tr>
</table>
</cfoutput>
</form>
</body>
</html>
