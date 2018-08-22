<!----------------------------------------------------------------------------------------------
| DESCRIPTION 					                                                               |
|----------------------------------------------------------------------------------------------|
| HouseAddressMain.cfm - CENSUS.dbo.HouseAddresses Maintenance               	               |
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
| MLAW       | 11/02/05   | Create a tool to maintain  CENSUS.dbo.HouseAddresses Table   	   |
----------------------------------------------------------------------------------------------->


<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>House Addresses Maintenance</title>
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

<cfparam name="form.iHouse_ID" default="">
<cfset msg = "">
<cfif IsDefined("PageAction")>
	<cfswitch expression="#Form.PageAction#">
		<cfcase value="Insert">
			<cfif form.HouseEmail is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Record Added">
				<!--- Check to see if the record is already there in the table --->
				<cfquery name="CheckHouseAddress" datasource="#Application.datasource#">
					select * from #application.censusdbserver#.census.dbo.HouseAddresses
					where nHouse = #form.ihouse_id#
				</cfquery>
				<cfif CheckHouseAddress.recordcount eq 0>
					<!--- Check if form values are empty --->
					<cftransaction action= "begin">
						<cftry>
							<cfquery name="InsertHouseAddress" datasource="#Application.datasource#">
								declare @varNextid as int
								select	@varNextid = max(HouseAddress_Ndx) + 1
								from  #application.censusdbserver#.CENSUS.dbo.HouseAddresses

								INSERT INTO #application.censusdbserver#.CENSUS.dbo.HouseAddresses(
									HouseAddress_Ndx, 
									nHouse, 
									HAddress, 
									HCity, 
									HState, 
									HZip, 
									HFax, 
									HPhone, 
									ProgramDirector, 
									HEmail, 
									Region, 
									nRegionNumber, 
									nOpsArea, 
									ProgramDirectorEmail, 
									HouseEmail
								)
								SELECT
									@varNextid, 
									h.cNumber, 
									h.cAddressLine1, 
									h.cCity, 
									h.cStateCode, 
									h.cZIPCode, 
									h.cPhoneNumber2, 
									h.cPhoneNumber1, 
									NULL,
									NULL,
									h.RegionName,
									h.RegionNumber,
									h.OpsNumber,
									NULL,
									'#form.HouseEmail#'
								from 	tIPS4.rw.vw_reg_ops_house h
								where	h.cNumber = '#form.house#'
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
			<cfif form.HouseEmail is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Records Updated">
				<cftransaction action= "begin">
					<cftry>
						<cfquery name="UpdateAnciCharges" datasource="#Application.datasource#">
							update #application.censusdbserver#.CENSUS.dbo.HouseAddresses  set 
									HouseEmail = '#form.HouseEmail#'
							where HouseAddress_Ndx = #form.HouseAddress_Ndx#
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
	
<cfquery name="getHouseAddress_Ndx" datasource="#Application.Datasource#">
	select * from #application.censusdbserver#.CENSUS.dbo.HouseAddresses ch
		join house h
		on h.cNumber = ch.nHouse
	where h.bIsSandbox = 0
	  and h.dtrowdeleted is Null
	order by h.cName
</cfquery>

<cfquery name="getHouseAddress_NdxMax" datasource="#Application.Datasource#">
	select	max(HouseAddress_Ndx) + 1 as Max
		from  #application.censusdbserver#.CENSUS.dbo.HouseAddresses
</cfquery>
<cfquery name="getHouse" datasource="#Application.Datasource#">
select * from house where dtrowdeleted is null  order by cname
</cfquery>

<!--- JavaScript --->
<cfoutput>

<SCRIPT>
	function popUpFormElements(obj)
	{
		if (obj.value=='') { 
			document.all['houseid'].innerHTML= '';
			document.forms[0].house.value = '';
			document.forms[0].HouseAddress_Ndx.value = '';
			document.forms[0].HouseEmail.value = '';
		 }
		<cfloop query="getHouseAddress_Ndx">
		else if (obj.value=='#getHouseAddress_Ndx.nHouse#') 
		{ 
			//have all the document.field initialize here
			document.all['houseid'].innerHTML= '#getHouseAddress_Ndx.nHouse#';
			document.forms[0].ihouse_id.value = '#getHouseAddress_Ndx.nHouse#';
			document.forms[0].house.value = '#getHouseAddress_Ndx.nHouse#';
			document.forms[0].HouseAddress_Ndx.value = '#getHouseAddress_Ndx.HouseAddress_Ndx#';
			document.forms[0].HouseEmail.value = '#getHouseAddress_Ndx.HouseEmail#';
		}
		</cfloop>
	}
	function clearUpFormElements(ob)
	{
			document.all['houseid'].innerHTML= '';
			document.forms[0].house.value = '';
			document.forms[0].HouseAddress_Ndx.value = '';
			document.forms[0].HouseEmail.value = '';
	}
	function popUpHouseName(obj)
	{
		<cfloop query="getHouse">
		if (obj.value=='#getHouse.cNumber#') 
		{ 
			//have all the document.field initialize here
			document.all['houseid'].innerHTML= '#getHouse.cNumber#';
			document.forms[0].ihouse_id.value = '#getHouse.cNumber#';
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
<form action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" >
<cfoutput>
<input type="hidden" name="PageAction" value=""> 
<table>
	<tr><td class="topleftcap" colspan="2"></td><td class="toprightcap" colspan="2"></td></tr>
	<tr>
	  <th class="leftrightborder" colspan="4">House Addresses  Maintenance</th>
	</tr>
	<tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
	 <b>Choose from the List:</b><br>
			
	<select name="selectlist" size="20" onChange="popUpFormElements(this);">
		<cfloop query="getHouseAddress_Ndx">
			<option value='#getHouseAddress_Ndx.nHouse#' style='color:blue;background:##eaeaea;'>#getHouseAddress_Ndx.cName#</option>
		</cfloop>
	</select> 
	</td>
	<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;font-weight:bold;"><table width="100%">
		<tr><td width="50%"><table align="center">
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">cNumber:</td>
            <td>
				<input name="ihouse_id" type="hidden" value="#getHouseAddress_Ndx.nHouse#">
				<SPAN ID="houseid">#getHouseAddress_Ndx.nHouse#</span>
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">cName</span></td>
            <td>
              <select name="house" onChange="popUpHouseName(this);">
                <cfloop query="getHouse">
                  <option value="#getHouse.cNumber#">#getHouse.cName#</option>
                </cfloop>
              </select></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">HouseAddress_Ndx:</td>
            <td>
				<input name="HouseAddress_Ndx" type="text" value="#getHouseAddress_Ndx.HouseAddress_Ndx#" size="20"> 
				auto-generated  
				</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">HouseEmail:</span></td>
            <td>
				<input name="HouseEmail" type="text" size="32" value="#getHouseAddress_Ndx.HouseEmail#"> 
			</td>
          </tr>
          <tr valign="baseline">
            <td colspan="2" align="right" nowrap><table>
              <tr>
                <td><input name="Add" type="button" value="          Add            "onClick="Javascript:document.forms[0].PageAction.value='Insert';document.forms[0].submit();"></td>
                <td><input name="Update" type="button" onClick="Javascript:document.forms[0].PageAction.value='Update';document.forms[0].submit();" value="          Update         "></td>
                <td><input name="Delete" type="button" disabled="true" onClick="Javascript:document.forms[0].PageAction.value='Delete';document.forms[0].submit();" value="          Delete         "></td> 
                <td><input name="Clear" type="button" value="         Clear         " onClick="clearUpFormElements(this);">
              </tr>
            </table></td>
            </tr>
        </table>
		  </td>
		</tr>
		</table> 
	</td></tr>
	<tr>
		<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
		<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;"><a href="HouseMaster.cfm">Go To HouseMaster</a></td>
	</tr>	
	<tr><td colspan="4" align="right" class="leftrightborder"><b><cfoutput>#msg#</cfoutput></b></td></tr>
	<tr><td class="bottomleftcap" colspan="2"></td><td class="bottomrightcap" colspan="2"></td></tr>
</table>
</cfoutput>
</form>
</body>
</html>
