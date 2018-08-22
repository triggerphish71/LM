<!----------------------------------------------------------------------------------------------
| DESCRIPTION 					                                                               |
|----------------------------------------------------------------------------------------------|
| HouseProductLine.cfm - HouseProductLine Maintenance                                          |
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
| MLAW       | 11/01/05   | Create a tool to maintain HouseProductLine Table   		 		   |
----------------------------------------------------------------------------------------------->
<cfset session.CURRENTUSER_ID = 3025>
<cfset session.CURRENTUSER_NAME = 'mlaw'>


<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HouseProductLine Maintenance</title>
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

<cfparam name="form.iHouseProductLine_id" default="">
<cfset msg = "">
<cfif IsDefined("PageAction")>
	<cfswitch expression="#Form.PageAction#">
		<cfcase value="Insert">
			<cfif form.iHouse_ID is '' or form.iProductLine_id is '' or form.cglsubaccount is '' or 
				  form.iUnitsAvailable is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Record Added">
				<!--- Check to see if the record is already there in the table --->
				<cfquery name="CheckHouseProductLine" datasource="#Application.datasource#">
					select * from HouseProductLine where
					iHouse_id = #form.iHouse_id#
				</cfquery>
				<cfif CheckHouseProductLine.recordcount eq 0>
					<!--- Check if form values are empty --->
					<cftransaction action= "begin">
						<cftry>
							<cfquery name="InsertHouseProductLine" datasource="#Application.datasource#">
								INSERT INTO TIPS4.dbo.HouseProductLine(
									iHouse_ID, 
									iProductLine_ID, 
									cGLSubAccount, 
									cRowStartUser_ID,
									iUnitsavailable
								)
								VALUES(	
								#form.iHouse_ID#, 
								1,
								'#form.cglsubaccount#', 
								'#session.CURRENTUSER_NAME#',
								#form.iUnitsavailable#
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
			<cfif form.iHouse_ID is '' or form.iProductLine_id is '' or form.cglsubaccount is '' or 
				  form.iUnitsAvailable is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Records Updated">
				<cftransaction action= "begin">
					<cftry>
						<cfquery name="UpdateHouseProductLine" datasource="#Application.datasource#">
							update HouseProductLine set 
								iHouse_ID = #form.iHouse_ID#, 
								iProductLine_ID = #form.iProductLine_ID#,
								cGLSubAccount = '#form.cGLSubAccount#', 
								cRowStartUser_ID = '#session.CURRENTUSER_NAME#',
								iUnitsAvailable = #form.iUnitsAvailable#
							where iHouseProductLine_id = #form.iHouseProductLine_id#
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
					<cfquery name="DeleteHouseProductLine" datasource="#Application.datasource#">
						update HouseProductLine 
							set dtRowDeleted = getdate(), cRowDeletedUser_id = 'session.CURRENTUSER_NAME'
						where 
							iHouseProductLine_id = #form.iHouseProductLine_id#
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
	select * from HouseProductLine hl
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
			document.forms[0].cglsubaccount.value = '#getHouse.cglSubaccount#'; 
			document.forms[0].iUnitsAvailable.value = '#getHouse.iUnitsAvailable#'; 
			
		}
		</cfloop>
	}
	function popUpFormElements(obj)
	{
		if (obj.value=='') { 
			document.all['ihouseproductline_id'].innerHTML= '';
			document.forms[0].iHouse_id.value = '';
			document.forms[0].iProductLine_id.value = '';
			document.forms[0].cglsubaccount.value = '';
			document.forms[0].cRowStartUser_id.value = '';
			document.forms[0].iUnitsAvailable.value = '';
		 }
		<cfloop query="getHouses">
		else if (obj.value=='#getHouses.iHouseProductLine_id#') 
		{ 
			//have all the document.field initialize here
			document.all['ihouseproductline_id'].innerHTML= '#getHouses.iHouseProductLine_id#';
			document.forms[0].iHouseProductLine_id.value = '#getHouses.iHouseProductLine_id#'; 			
			document.forms[0].Houselist.value = '#getHouses.iHouse_id#'; 								
			document.forms[0].iHouse_id.value = '#getHouses.iHouse_ID#';
			document.forms[0].iProductLine_id.value = '#getHouses.iProductLine_id#';
			document.forms[0].cglsubaccount.value = '#getHouses.cglsubaccount#';
			document.forms[0].cRowStartUser_id.value = '#getHouses.cRowStartUser_id#';
			document.forms[0].iUnitsAvailable.value = '#getHouses.iUnitsAvailable#';
		}
		</cfloop>
	}
	function clearUpFormElements(ob)
	{
			document.all['ihouseproductline_id'].innerHTML= '';
			document.forms[0].iHouse_id.value = '';
			document.forms[0].iProductLine_id.value = '1';
			document.forms[0].cglsubaccount.value = '';
			document.forms[0].cRowStartUser_id.value = '';
			document.forms[0].iUnitsAvailable.value = '';
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
.style2 {color: #000000}
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
	  <th class="leftrightborder" colspan="4">HouseProductLine Maintenance</th>
	</tr>
	<tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
	 <b>Choose from the List:</b><br>
			
	<select name="selectlist" size="20" onChange="popUpFormElements(this);">
		<cfloop query="getHouses">
			<option value='#getHouses.iHouseProductLine_id#' style='color:blue;background:##eaeaea;'>#getHouses.cName#</option>
		</cfloop>
	</select> 
	</td>
	<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;font-weight:bold;"><table width="100%">
		<tr><td width="50%"><table align="center">
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">iHouseProductLine_id:</td>
            <td>
				<SPAN ID="ihouseproductline_id">#getHouses.iHouseProductLine_id#</span>
				<input name="iHouseProductLine_id" type="hidden" value="#getHouses.iHouseProductLine_id#">					
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">iHouse_id:</span></td>
            <td>
				<input name="iHouse_id" type="text" value="#getHouses.iHouse_id#" size="4" maxlength="4" readonly="true">		
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
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style2">iProductLine_id:</span></td>
            <td>
				<input name="iProductLine_id" type="text" size="1" value="#getHouses.iProductLine_id#"> 
				(AL = 1) </td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">cglsubaccount:</td>
            <td>
			
			<input name="cglsubaccount" type="text" value="#getHouses.cglsubaccount#" size="10" readonly="true"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">cRowStartUser_id</td>
            <td><input type="text" name="cRowStartUser_id" value="#getHouses.cRowStartUser_id#" size="15"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">iUnitsAvailable</td>
            <td><input name="iUnitsAvailable" type="text" value="#getHouses.iUnitsAvailable#" size="4" readonly="true"></td>
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
