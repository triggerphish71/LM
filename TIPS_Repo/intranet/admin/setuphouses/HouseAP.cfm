<!----------------------------------------------------------------------------------------------
| DESCRIPTION 					                                                               |
|----------------------------------------------------------------------------------------------|
| DocLinkHouseAPMain.cfm - DocLinkALC.dbo.HouseAP Maintenance               	               |
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
| MLAW       | 11/02/05   | Create a tool to maintain  DocLinkALC.dbo.HouseAP Table   		   |
----------------------------------------------------------------------------------------------->


<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>DocLinkALC.dbo.HouseAP Maintenance</title>
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
			<cfif form.house is '' or form.cAPEmail is '' or form.cAPName is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Record Added">
				<!--- Check to see if the record is already there in the table --->
				<cfquery name="CheckHouseAp" datasource="#Application.datasource#">
					select * from DocLinkALC.dbo.HouseAP where
					iHouse_ID =  #form.iHouse_ID#
				</cfquery>
				<cfif CheckHouseAp.recordcount eq 0>
					<!--- Check if form values are empty --->
					<cftransaction action= "begin">
						<cftry>
							<cfquery name="InsertHouseAp" datasource="#Application.datasource#">
								INSERT INTO DocLinkALC.dbo.HouseAP (
									iHouse_ID, 
									cAPEmail, 
									cAPName, 
									iOpsArea_ID, 
									iPDUser_ID, 
									iAcctUser_ID, 
									cName, 
									cNumber, 
									cGLsubaccount, 
									cPhoneNumber1, 
									iPhoneType1_ID, 
									cPhoneNumber2, 
									iPhoneType2_ID, 
									cPhoneNumber3, 
									iPhoneType3_ID, 
									cAddressLine1, 
									cAddressLine2, 
									cCity, 
									cStateCode, 
									cZipCode, 
									cComments)
								select	
									iHouse_ID, 
									'#form.cAPEmail#',
									'#form.cAPName#',
									iOpsArea_ID, 
									iPDUser_ID, 
									iAcctUser_ID, 
									cName, 
									cNumber, 
									cGLsubaccount, 
									cPhoneNumber1, 
									iPhoneType1_ID, 
									cPhoneNumber2, 
									iPhoneType2_ID, 
									cPhoneNumber3, 
									iPhoneType3_ID, 
									cAddressLine1, 
									cAddressLine2, 
									cCity, 
									cStateCode, 
									cZipCode, 
									cComments
								from	TIPS4.dbo.house
								where	iHouse_ID = #form.iHouse_ID#
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
			<cfif form.house is '' or form.cAPEmail is '' or form.cAPName is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Records Updated">
				<cftransaction action= "begin">
					<cftry>
						<cfquery name="UpdateHouseAp" datasource="#Application.datasource#">
							update DocLinkALC.dbo.HouseAP 
								set 
								cAPEmail	= '#form.cAPEmail#',
								cAPName		= '#form.cAPName#'
								where	iHouse_ID = #form.iHouse_ID#
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
	
<cfquery name="getHouseAp" datasource="#Application.Datasource#">
	select * from DocLinkALC.dbo.HouseAP hAP
	order by hAP.cName
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
			document.all['houseid'].innerHTML= '';
			document.forms[0].cName.value = '';
			document.forms[0].cAPEmail.value = '';
			document.forms[0].cAPName.value = '';
		 }
		<cfloop query="getHouseAp">
		else if (obj.value=='#getHouseAp.iHouse_ID#') 
		{ 
			//have all the document.field initialize here
			document.all['houseid'].innerHTML= '#getHouseAp.iHouse_ID#';
			document.forms[0].ihouse_id.value = '#getHouseAp.iHouse_ID#';	
			document.forms[0].house.value = '#getHouseAp.iHouse_ID#';
			document.forms[0].cAPEmail.value = '#getHouseAp.cAPEmail#';
			document.forms[0].cAPName.value = '#getHouseAp.cAPName#';
		}
		</cfloop>
	}
	function clearUpFormElements(ob)
	{
			document.all['houseid'].innerHTML= '';
			document.forms[0].house.value = '';
			document.forms[0].cAPEmail.value = '';
			document.forms[0].cAPName.value = '';
	}
	function popUpHouseName(obj)
	{
		<cfloop query="getHouses">
		if (obj.value=='#getHouses.iHouse_ID#') 
		{ 
			//have all the document.field initialize here
			document.all['houseid'].innerHTML= '#getHouses.iHouse_ID#';
			document.forms[0].ihouse_id.value = '#getHouses.iHouse_ID#';	
			document.forms[0].house.value = '#getHouses.iHouse_ID#';		
		}
		</cfloop>
	}	
</script>
</cfoutput>
<style type="text/css">
<!--
body,td,th {
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
.style3 {
	font-family: 'Courier New';
	color: red;
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
	  <th class="leftrightborder" colspan="4">DocLink HouseApp   Maintenance</th>
	</tr>
	<tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
	 <b>Choose from the List:</b><br>
			
	<select name="selectlist" size="20" onChange="popUpFormElements(this);">
		<cfloop query="getHouseAp">
			<option value='#getHouseAp.iHouse_ID#' style='color:blue;background:##eaeaea;'>#getHouseAp.cName#</option>
		</cfloop>
	</select> 
	</td>
	<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;font-weight:bold;"><table width="100%">
		<tr><td width="50%"><table align="center">
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">iHouse_ID:</td>
            <td><input name="ihouse_id" type="hidden" value="#getHouseAp.iHouse_ID#">
			<span id="houseid">#getHouseAp.iHouse_ID#  
            </span></td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">cName</td>
            <td>
				<select name="house" onChange="popUpHouseName(this);">
					<cfloop query="getHouses">
						<option value="#getHouses.iHouse_ID#">#getHouses.cName#</option>
					</cfloop>
				</select>     
			</td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">cAPEmail</td>
            <td><input name="cAPEmail" type="text" value="#getHouseAp.cAPEmail#" size="32">             </td>
          </tr>
          <tr valign="baseline">
            <td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">cAPName</td>
            <td><input name="cAPName" type="text" value="#getHouseAp.cAPName#" size="32"> 
              </td>
          </tr>
          <tr valign="baseline">
            <td colspan="2" align="right" nowrap><table>
              <tr>
                <td><input name="Add" type="button" value="          Add            "onClick="Javascript:document.forms[0].PageAction.value='Insert';document.forms[0].submit();"></td>
                 <td><input name="Update" type="button" onClick="Javascript:document.forms[0].PageAction.value='Update';document.forms[0].submit();" value="          Update         "></td>                
<!--- 				  <td><input name="Delete" type="button" disabled="true" onClick="Javascript:document.forms[0].PageAction.value='Delete';document.forms[0].submit();" value="          Delete         "></td>--->
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
		<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;"><a href="Housemaster.cfm">Go TO HouseMaster</a> </td>
	</tr>	
	<tr><td colspan="4" align="right" class="leftrightborder"><b><cfoutput>#msg#</cfoutput></b></td></tr>
	<tr><td class="bottomleftcap" colspan="2"></td><td class="bottomrightcap" colspan="2"></td></tr>
</table>
</cfoutput>
</form>

</body>
</html>
