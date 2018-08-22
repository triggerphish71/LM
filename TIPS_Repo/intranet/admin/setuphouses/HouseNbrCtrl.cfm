<!----------------------------------------------------------------------------------------------
| DESCRIPTION 					                                                               |
|----------------------------------------------------------------------------------------------|
| HouseNbrCtrlMain.cfm - HouseNumberControl Maintenance                                        |
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
| MLAW       | 10/31/05   | Create a tool to maintain HouseNumberControl Table   		 	   |
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

<cfparam name="form.iSolomonKey_ID" default="">
<cfset msg = "">
<cfif IsDefined("PageAction")>
	<cfswitch expression="#Form.PageAction#">
		<cfcase value="Insert">
			<cfif form.iHouse_ID is '' or form.cNextSolomonKey is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Record Added">
				<!--- Check to see if the record is already there in the table --->
				<cfquery name="CheckHouseNumberControl" datasource="#Application.datasource#">
					select * from HouseNumberControl where
					iSolomonKey_ID = '#form.iSolomonKey_ID#'
				</cfquery>
				<cfif CheckHouseNumberControl.recordcount eq 0>
					<!--- Check if form values are empty --->
					<cftransaction action= "begin">
						<cftry>
							<cfquery name="InsertHouseNumberControl" datasource="#Application.datasource#">
								INSERT INTO TIPS4.dbo.HouseNumberControl(
								iHouse_ID, 
								cNextSolomonKey, 
								iNextCashReceipt, 
								iNextInvoice, 
								iNextAddendum, 
								iRowStartUser_ID, 
								dtRowStart
								)
								VALUES(	
								#form.iHouse_ID#, 
								'#form.cNextSolomonKey#',
								1000, 
								10000, 
								10000,
								#session.CURRENTUSER_ID#, 
								getdate()
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
			<cfif form.iHouse_ID is '' or form.cNextSolomonKey is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Records Updated">
				<cftransaction action= "begin">
					<cftry>
						<cfquery name="UpdateAnciCharges" datasource="#Application.datasource#">
							update HouseNumberControl set 
								iHouse_ID = #form.iHouse_ID#, 
								cNextSolomonKey = '#form.cNextSolomonKey#', 
								iNextCashReceipt = #form.iNextCashReceipt#, 
								iNextInvoice = #form.iNextInvoice#, 
								iNextAddendum = #form.iNextAddendum#, 
								iRowStartUser_ID = #form.iRowStartUser_ID#, 
								dtRowStart = getdate()
							where iSolomonKey_ID = #form.iSolomonKey_ID#
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
					<cfquery name="DeleteHouseNumberControl" datasource="#Application.datasource#">
						update HouseNumberControl 
							set dtRowDeleted = getdate()
						where 
							iSolomonKey_ID = #form.iSolomonKey_ID#
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
	select * from HouseNumberControl hl
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
			var mycnumber = '#getHouse.cnumber#';
			
			var mystring = '';
			
			if (mycnumber >= '1900')
			{
				mystring = '';
			}
			else
			{
				if (mycnumber >= '1800')
				{
					mystring = '0';
				}
				else
				{
					mystring = '00';
				}
			}
			var mycal = #getHouse.cnumber# - 1800;
			mystring = mystring + mycal + '10000';			
			document.forms[0].cNextSolomonKey.value = mystring;
		}
		</cfloop>
	}
	function popUpFormElements(obj)
	{
		if (obj.value=='') { 
			document.all['isolomonkey_id'].innerHTML= '';
			document.forms[0].iHouse_id.value = '';
			document.forms[0].cNextSolomonKey.value = '';
			document.forms[0].iNextCashReceipt.value = '';
			document.forms[0].iNextInvoice.value = '';
			document.forms[0].iNextAddendum.value = '';
			document.forms[0].iRowStartUser_ID.value = '';
			document.forms[0].dtRowStart.value = '';
		 }
		<cfloop query="getHouses">
		else if (obj.value=='#getHouses.iHouse_id#') 
		{ 
			//have all the document.field initialize here
			document.all['isolomonkey_id'].innerHTML= '#getHouses.iSolomonKey_ID#';
			document.forms[0].iHouse_id.value = '#getHouses.iHouse_ID#';
			document.forms[0].Houselist.value = '#getHouses.iHouse_ID#';
			document.forms[0].cNextSolomonKey.value = '#getHouses.cNextSolomonKey#';
			document.forms[0].iNextCashReceipt.value = '#getHouses.iNextCashReceipt#';
			document.forms[0].iNextInvoice.value = '#getHouses.iNextInvoice#';
			document.forms[0].iNextAddendum.value = '#getHouses.iNextAddendum#';
			document.forms[0].iRowStartUser_ID.value = '#getHouses.iRowStartUser_ID#';
			document.forms[0].dtRowStart.value = '#dateformat(getHouses.dtRowStart,'MM/DD/YYYY')#';
		}
		</cfloop>
	}
	function clearUpFormElements(ob)
	{
			document.all['isolomonkey_id'].innerHTML= '';
			document.forms[0].iHouse_id.value = '';
			document.forms[0].cNextSolomonKey.value = '';
			document.forms[0].iNextCashReceipt.value = '1000';
			document.forms[0].iNextInvoice.value = '10000';
			document.forms[0].iNextAddendum.value = '10000';
			document.forms[0].iRowStartUser_ID.value = '';
			document.forms[0].dtRowStart.value = '';
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
	  <th class="leftrightborder" colspan="4">HouseNumberControl Maintenance</th>
	</tr>
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
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">ISolomonKey_ID:</td>
            <td>
				<SPAN ID="isolomonkey_id">#getHouses.iSolomonKey_ID#</span>
				<input name="iHouseNumberControl_ID" type="hidden" value="#getHouses.iSolomonKey_ID#">					
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">IHouse_ID:</span></td>
            <td>
				<input name="iHouse_id" type="text" value="#getHouses.ihouse_id#" size="4" readonly="true">		
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
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">cNextSolomonKey:</span></td>
            <td>
				<input name="cNextSolomonKey" type="text" value="#getHouses.cNextSolomonKey#" size="8">

			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">iNextCashReceipt:</span></td>
            <td>
				<input name="iNextCashReceipt" type="text" size="4" value="#getHouses.iNextCashReceipt#"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">iNextInvoice:</span></td>
            <td>
			<input name="iNextInvoice" type="text" size="4" value="#getHouses.iNextInvoice#"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">iNextAddendum:</span></td>
            <td><input type="text" name="iNextAddendum" value="#getHouses.iNextAddendum#" size="4"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">iRowStartUser_ID:</td>
            <td>
				<input name="iRowStartUser_ID" type="text" value="#getHouses.iRowStartUser_id#" size="4" readonly="true"></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">dtRowStart</td>
            <td><input name="dtRowStart" type="text" size="10" readonly="true" value="#dateformat(getHouses.dtrowstart,'MM/DD/yyyy')#">
              MM/DD/YYYY </td>
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
