<!----------------------------------------------------------------------------------------------
| DESCRIPTION 					                                                               |
|----------------------------------------------------------------------------------------------|
| HouseMaster.cfm - TIPS.dbo.House Maintenance               	               |
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
| Amal       | 11/02/05   | Create a tool to maintain  House Table						   	   |
----------------------------------------------------------------------------------------------->


<cfset session.CURRENTUSER_ID = 3025>
<cfset session.CURRENTUSER_NAME = 'mlaw'>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>TIPS House Master</title>
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
<!---<link href="grid.css" rel="stylesheet" type="text/css" ></link>
	 <script src="grid.js"></script>
	<!-- grid format -->
	<style>
		.active-controls-grid {height: 50%; font: menu;}
		.active-column-0 {width:  80px; background-color: threedshadow;}
		.active-column-1 {width: 50px;}
		.active-column-2 {text-align: right;}
		.active-column-3 {text-align: right;}
		.active-column-4 {text-align: right;}
		.active-column-6 {text-align: right;}		
		.active-column-7 {text-align: right;}		
		.active-column-8 {text-align: right;}		
		.active-column-9 {text-align: right;}
		.active-column-10 {text-align: right;}		
		.active-grid-column {border-right: 1px solid threedshadow;}
		.active-grid-row {border-bottom: 1px solid threedlightshadow;}
	.style1 {color: #000000}
    .style2 {color: #FF0000}
    </style> --->
	<cfoutput>
	#Application.datasource#
	</cfoutput>
<cfparam name="form.iHouse_id" default="">
<cfset msg = "">
<cfif IsDefined("PageAction")>
	<cfswitch expression="#Form.PageAction#">
		<cfcase value="Insert">
			<cfif form.cName is ''>
				<cfset msg = "Form Field House Name is left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Record Added">
				<!--- Check to see if the record is already there in the table --->
				<cfquery name="CheckHouse" datasource="#Application.datasource#">
					select * from House where
					cName = <cfqueryparam value="#form.cName#" cfsqltype="CF_SQL_VARCHAR" maxlength="50">
				</cfquery>
				<cfif CheckHouse.recordcount eq 0>
					<!--- Check if form values are empty --->
					<cftransaction action= "begin">
						<cftry>
							<cfquery name="InsertHouse" datasource="#Application.datasource#">
								declare @varihouse_id as int
								select @varihouse_id = max(ihouse_id)+ 1 from house
								INSERT INTO TIPS4.dbo.House(
										iHouse_ID,
										iOpsArea_ID, 
										iPDUser_ID, 
										iAcctUser_ID, 
										cName, 
										cNumber, 
										cDepositTypeSet, 
										cSLevelTypeSet, 
										cGLsubaccount, 
										bIsCensusMedicaidOnly, 
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
										cComments, 
										dtAcctStamp, 
										cBillingType, 
										iRowStartUser_ID, 
										dtRowStart, 
										cRowStartUser_ID, 
										iUnitsAvailable, 
										dtRentalAgreement, 
										cNurseUser_ID, 
										EHSIFacilityID,
										bIsSandbox
									)
									values (
										@varihouse_id,
										<cfif form.IOPSAREA_ID is ''>Null <cfelse>#form.IOPSAREA_ID#</cfif>,
										<cfif form.iPDUser_ID is ''>Null <cfelse>'#form.iPDUser_ID#'</cfif>,
										<cfif form.iAcctUser_ID is ''>Null <cfelse>#form.iAcctUser_ID#</cfif>,
										<cfif form.cName is ''>Null <cfelse>'#form.cName#'</cfif>,
										<cfif form.CNUMBER is ''>Null <cfelse>'#form.CNUMBER#'</cfif>,
										NULL,
										<cfif form.cSLevelTypeSet is ''>Null <cfelse>#form.cSLevelTypeSet#</cfif>,
										<cfif form.cGlsubaccount is ''>Null <cfelse>'#form.cGLsubaccount#'</cfif>,
										NULL,
										<cfif form.cPhoneNumber1 is ''>Null <cfelse>'#form.cPhoneNumber1#'</cfif>, 
										<cfif form.iPhoneType1_ID is ''>Null <cfelse>'#form.iPhoneType1_ID#'</cfif>, 
										<cfif form.cPhoneNumber2 is ''>Null <cfelse>'#form.cPhoneNumber2#'</cfif>, 
										<cfif form.iPhoneType2_ID is ''>Null <cfelse>'#form.iPhoneType2_ID#'</cfif>, 
										<cfif form.cPhoneNumber3 is ''>Null <cfelse>'#form.cPhoneNumber3#'</cfif>, 
										<cfif form.iPhoneType3_ID is ''>Null <cfelse>'#form.iPhoneType3_ID#'</cfif>, 
										<cfif form.cAddressLine1 is ''>Null <cfelse>'#form.cAddressLine1#'</cfif>, 
										<cfif form.cAddressLine2 is ''>Null <cfelse>'#form.cAddressLine2#'</cfif>, 
										<cfif form.cCity is ''>Null <cfelse>'#form.cCity#'</cfif>, 
										<cfif form.cStateCode is ''>Null <cfelse>'#form.cStateCode#'</cfif>, 
										<cfif form.cZipCode is ''>Null <cfelse>'#form.cZipCode#'</cfif>, 
										NULL,
										NULL,
										<cfif form.cBillingType is ''>Null <cfelse>'D'</cfif>,
										#session.CURRENTUSER_ID#,
										getdate(),
										'#session.CURRENTUSER_NAME#',
										<cfif form.iUnitsAvailable is ''>0 <cfelse>#form.iUnitsAvailable#</cfif>, 
										NULL,
										<cfif form.cNurseUser_ID is ''>Null <cfelse>'#form.cNurseUser_ID#'</cfif>,
										<cfif form.EHSIFacilityID is ''>Null <cfelse>'#form.EHSIFacilityID#'</cfif>,
										1
									)
									</cfquery>
														
									<cfquery name="insertXBank" datasource="#Application.datasource#">
										INSERT INTO #Application.HOUSES_APPDBServer#.HOUSES_APP.dbo.XBANKINFO(
													ABA, 
													Acct, 
													Addr1, 
													Addr2, 
													BankAcctNum, 
													BankLimit, 
													BankName, 
													BankReqSig2, 
													City, 
													CnyAddr1, 
													CnyAddr2, 
													CnyCity, 
													CnyId, 
													CnyLogo, 
													CnyName, 
													CnyState, 
													CnyZip, 
													OnUsField, 
													prtLine1, 
													RTNum, 
													Signature1, 
													Signature1always, 
													Signature1Limit, 
													Signature2, 
													Signature2Limit, 
													Signature2Valid, 
													Signature2ValidMsg, 
													State, 
													SubAcct, 
													User1, 
													User2, 
													User3, 
													User4, 
													User5, 
													User6, 
													User7, 
													User8, 
													Void, 
													VoidMsg, 
													Zip
												)
												select	x.ABA, 
													x.Acct, 
													x.Addr1, 
													x.Addr2, 
													x.BankAcctNum, 
													x.BankLimit, 
													x.BankName, 
													x.BankReqSig2, 
													x.City, 
													h.cAddressLine1, 
													x.CnyAddr2, 
													h.cCity, 
													x.CnyId, 
													x.CnyLogo, 
													h.cName, 
													h.cStateCode, 
													h.cZipCode, 
													x.OnUsField, 
													x.prtLine1, 
													x.RTNum, 
													x.Signature1, 
													x.Signature1always, 
													x.Signature1Limit, 
													x.Signature2, 
													x.Signature2Limit, 
													x.Signature2Valid, 
													x.Signature2ValidMsg, 
													x.State, 
													h.cGLsubaccount, 
													x.User1, 
													x.User2, 
													x.User3, 
													x.User4, 
													x.User5, 
													x.User6, 
													x.User7, 
													x.User8, 
													x.Void, 
													x.VoidMsg, 
													x.Zip
												from	#Application.HOUSES_APPDBServer#.Houses_App.dbo.xbankinfo x
												join	TIPS4.dbo.House h
												on	h.cName = '#form.cName#'
												where	subacct = '010305109'
								
								</cfquery>
							<cftransaction action="commit"/>
							<cfcatch type="database">
								<cfset msg = "Record Not Added">
								<cfset msg = msg & "<font color='red'>#cfcatch.Message# Error: Problem in Inserting the values into the Tables!</font>">
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
			<cfif form.cName is ''>
				<cfset msg = "Form Field are left blank. Cannot Insert blank values!">
			<cfelse>
				<cfset msg = "Records Updated">
				<cftransaction action= "begin">
					<cftry>
						<cfquery name="UpdateHouse" datasource="#Application.datasource#">
								Update House set 
								<cfif isdefined('form.iOpsArea_ID')><cfif form.iOpsArea_ID is not ''>iOpsArea_ID  = #form.iOpsArea_ID#,</cfif></cfif> 
								<cfif isdefined('form.iPDUser_ID')><cfif form.iPDUser_ID is not ''>iPDUser_ID = #form.iPDUser_ID#,</cfif></cfif> 
								<cfif isdefined('form.iAcctUser_ID')><cfif form.iAcctUser_ID is not ''>iAcctUser_ID = #form.iAcctUser_ID#,</cfif></cfif> 
								<cfif isdefined('form.cName')><cfif form.cName is not ''>cName = '#form.cName#',</cfif></cfif> 
								<cfif isdefined('form.cNumber')><cfif form.cNumber is not ''>cNumber = '#form.cNumber#',</cfif></cfif>	
								<cfif isdefined('form.cDepositTypeSet')><cfif form.cDepositTypeSet is not ''>cDepositTypeSet = '#form.cDepositTypeSet#',</cfif></cfif> 
								<cfif isdefined('form.cSLevelTypeSet')><cfif form.cSLevelTypeSet is not ''>cSLevelTypeSet = '#form.cSLevelTypeSet#',</cfif></cfif>
								<cfif isdefined('form.cGLsubaccount')><cfif form.cGLsubaccount is not ''>cGLsubaccount = '#form.cGLsubaccount#',</cfif></cfif>
								<cfif isdefined('form.bIsCensusMedicaidOnly')><cfif form.bIsCensusMedicaidOnly is not ''>bIsCensusMedicaidOnly = #form.bIsCensusMedicaidOnly#,</cfif></cfif> 
								<cfif isdefined('form.cPhoneNumber1')><cfif form.cPhoneNumber1 is not ''>cPhoneNumber1 = '#form.cPhoneNumber1#', </cfif></cfif>
								<cfif isdefined('form.iPhoneType1_ID')><cfif form.iPhoneType1_ID is not ''>iPhoneType1_ID = #form.iPhoneType1_ID#, </cfif></cfif>
								<cfif isdefined('form.cPhoneNumber2')><cfif form.cPhoneNumber2 is not ''>cPhoneNumber2 = '#form.cPhoneNumber2#',</cfif></cfif>
								<cfif isdefined('form.iPhoneType2_ID')><cfif form.iPhoneType2_ID is not ''>iPhoneType2_ID = #form.iPhoneType2_ID#, </cfif></cfif>
								<cfif isdefined('form.cPhoneNumber3')><cfif form.cPhoneNumber3 is not ''>cPhoneNumber3 = '#form.cPhoneNumber3#', </cfif></cfif>
								<cfif isdefined('form.iPhoneType3_ID')><cfif form.iPhoneType3_ID is not ''>iPhoneType3_ID = #form.iPhoneType3_ID#,</cfif></cfif> 
								<cfif isdefined('form.cAddressLine1')><cfif form.cAddressLine1 is not ''>cAddressLine1 = '#form.cAddressLine1#', </cfif></cfif>
								<cfif isdefined('form.cAddressLine2')><cfif form.cAddressLine2 is not ''>cAddressLine2 = '#form.cAddressLine2#',</cfif></cfif> 
								<cfif isdefined('form.cCity')><cfif form.cCity is not ''>cCity = '#form.cCity#',</cfif></cfif>
								<cfif isdefined('form.cStateCode')><cfif form.cStateCode is not ''>cStateCode = '#form.cStateCode#',	</cfif></cfif>
								<cfif isdefined('form.cZipCode')><cfif form.cZipCode is not ''>cZipCode = '#form.cZipCode#', </cfif></cfif>
								<cfif isdefined('form.cComments')><cfif form.cComments is not ''>cComments = '#form.cComments#', </cfif></cfif>
								<cfif isdefined('form.dtAcctStamp')><cfif form.dtAcctStamp is not ''>dtAcctStamp = '#form.dtAcctStamp#',</cfif></cfif> 
								<cfif isdefined('form.cBillingType')><cfif form.cBillingType is not ''>cBillingType = '#form.cBillingType#',</cfif></cfif> 
								iRowStartUser_ID = #session.CURRENTUSER_ID#, 
								dtRowStart = getdate(),
								cRowStartUser_ID = '#session.CURRENTUSER_NAME#',
								<cfif isdefined('form.iUnitsAvailable')><cfif form.iUnitsAvailable is not ''>iUnitsAvailable = #form.iUnitsAvailable#,</cfif></cfif> 
								<cfif isdefined('form.dtRentalAgreement')><cfif form.dtRentalAgreement is not ''>dtRentalAgreement = '#form.dtRentalAgreement#',</cfif></cfif> 
								<cfif isdefined('form.cNurseUser_ID')><cfif form.cNurseUser_ID is not ''>cNurseUser_ID = '#form.cNurseUser_ID#', </cfif></cfif>
								<cfif isdefined('form.EHSIFacilityID')><cfif form.EHSIFacilityID is not ''>EHSIFacilityID = '#form.EHSIFacilityID#',</cfif></cfif>
								<cfif isdefined('form.bIsSandbox')><cfif form.bIsSandbox is not ''>bIsSandbox = #form.bIsSandbox#</cfif></cfif>
							where iHouse_id = #form.iHouse_id#
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
					<cfquery name="DeleteHouse" datasource="#Application.datasource#">
						Update House set dtRowDeleted = getdate(), iRowDeletedUser_ID = #session.CURRENTUSER_ID#,
						cRowDeletedUser_ID = '#session.CURRENTUSER_NAME#'
						where iHouse_id = #form.iHouse_id#
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
<cfquery name="getHouse" datasource="#Application.Datasource#">
	Select * from House where dtrowdeleted is null order by cname
</cfquery>
<cfquery name="getOpsArea" datasource="#Application.Datasource#">
	Select OpsAreaID iopsArea_id , opsname cname, * from vw_reg_ops order by opsname
</cfquery>
<cfquery name="getStateCode" datasource="#Application.Datasource#">
	Select * from StateCode order by cstatecode
</cfquery>
<cfquery name="getHouseProductLine" datasource="#Application.Datasource#">
	Select * from HouseProductLine where dtrowdeleted is null
</cfquery>
<cfquery name="getHouseNumberControl" datasource="#Application.Datasource#">
	Select * from HouseNumberControl where dtrowdeleted is null
</cfquery>
<cfquery name="getHouseLog" datasource="#Application.Datasource#">
	Select * from HouseLog where dtrowdeleted is null
</cfquery>
<cfquery name="getHouseAddresses" datasource="#Application.Datasource#">
	Select ihouse_id,* from census.dbo.HouseAddresses hd inner join house h
	on h.cNumber = hd.nhouse
</cfquery>
<cfquery name="getHouseAp" datasource="#Application.Datasource#">
	select * from DocLinkALC.dbo.HouseAP hAP
	order by hAP.cName
</cfquery>
<cfquery name="getXBANKINFO" datasource="#Application.Datasource#">
select h.ihouse_id, * from #Application.HOUSES_APPDBServer#.HOUSES_APP.dbo.XBANKINFO hx inner join house h 
on hx.cnyname = h.cname
</cfquery>
<cfquery name="getEmployees" datasource="#Application.Datasource#">
select	Employee_Ndx, Lname, Fname from	#Application.AlcWebDBServer#.alcweb.dbo.employees order by lname, fname
</cfquery>
<cfquery name="getGroups" datasource="#Application.Datasource#">
select * from #Application.DmsDBServer#.dms.dbo.groups
</cfquery>
<cfquery name="getdoclinkhouse" datasource="#Application.Datasource#">
select * from DocLinkALC.dbo.HouseAP hAP
	order by hAP.cName
</cfquery>
<cfquery name="getusers" datasource="#Application.Datasource#">
	select * from #Application.DmsDBServer#.DMS.dbo.users u  
		join house h
		on h.cNumber = u.employeeid
	  where h.bIsSandBox in (1, 0)
		  and h.dtrowdeleted is null
	order by h.cName
</cfquery>
<!--- JavaScript --->
<!--- //Data and column for HouseList in javascript grid
		var myData = [
			<cfloop query="getHouse">
				["#getHouse.iHouse_ID#","#getHouse.iOpsArea_ID#", "#getHouse.iPDUser_ID#", "#getHouse.iAcctUser_ID#", "#getHouse.cName#", "#getHouse.cNumber#",
				"#getHouse.cDepositTypeSet#", "#getHouse.cSLevelTypeSet#", "#getHouse.cGLsubaccount#", "#getHouse.bIsCensusMedicaidOnly#"
				],
			</cfloop>
			[" "," ", " ", " ", " ", " ", " ", " ", " ", " "]
		];

		var myColumns = ["iHouse_ID", "iOpsArea_ID", "iPDUser_ID", "iAcctUser_ID", "cName", "cNumber",
			"cDepositTypeSet","cSLevelTypeSet","cGLsubaccount","bIsCensusMedicaidOnly"
			//"cPhoneNumber1","iPhoneType1_ID","cPhoneNumber2",
			//"iPhoneType2_ID","cPhoneNumber3","iPhoneType3_ID","cAddressLine1","cAddressLine2","cCity","cStateCode",
			//"cZipCode","cComments","dtAcctStamp","cBillingType","iRowStartUser_ID","dtRowStart","iRowEndUser_ID","dtRowEnd","iRowDeletedUser_ID","dtRowDeleted",
			//"cRowStartUser_ID","cRowEndUser_ID","cRowDeletedUser_ID","iUnitsAvailable","dtRentalAgreement","cNurseUser_ID", "EHSIFacilityID", "bIsSandbox"
			]; 
 --->
<cfoutput> 
<SCRIPT>
		
	function popUpStateCodesField(obj)
	{
		<cfloop query="getStateCode">
		if (obj.value=='#getStateCode.cStateCode#') {
			document.forms[0].cStateCode.value = '#getStateCode.cStateCode#'; 
		}
		</cfloop>
	}
	function popUpOpsAreaField(obj)
	{
		<cfloop query="getOpsArea">
		if (obj.value=='#getOpsArea.iOpsArea_ID#') {
			document.forms[0].iOpsArea_ID.value = '#getOpsArea.iOpsArea_ID#'; 
		}
		</cfloop>
	}
	
	function popUpNurseUserField(obj)
	{
		<cfloop query="getEmployees">
		if (obj.value=='#getEmployees.Employee_Ndx#') {
			document.forms[0].cNurseUser_ID.value = '#getEmployees.Employee_Ndx#'; 
		}
		</cfloop>
	}

	function popUpAcctUserField(obj)
	{
		<cfloop query="getEmployees">
		if (obj.value=='#getEmployees.Employee_Ndx#') {
			document.forms[0].iAcctUser_ID.value = '#getEmployees.Employee_Ndx#'; 
		}
		</cfloop>
	}

	function popUpHouseProductLine(obj)
	{
		var found = 'F';
		dc=document.all['houseproductline'];
		
		<cfloop query="getHouseProductLine">
		if (obj.value == '#getHouseProductLine.iHouse_ID#') 
		{
			found = 'T';
			var myvar = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder"><a href="HouseProductLine.cfm"><font color="white">HouseProductLine Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">iHouseProductLine_id</td><td style="font:bold;width:1%;white-space:nowrap;">iHouse_id</td><td style="font:bold;width:1%;white-space:nowrap;">iProductLine_id</td><td style="font:bold;width:1%;white-space:nowrap;">cglsubaccount</td><td class="rightborder" style="font:bold;text-align:left;">iUnitsAvailable</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseProductLine.iHouseProductLine_id#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseProductLine.iHouse_id#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseProductLine.iProductLine_id#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseProductLine.cglsubaccount#</td><td class="rightborder" style="background:##eaeaea;text-align:left;">#getHouseProductLine.iUnitsAvailable# </td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar;
		}
		</cfloop>
		
		if (found == 'F')
		{
		var myvar2 = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder">	<a href="HouseProductLine.cfm"><font color="white">HouseProductLine Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">iHouseProductLine_id</td><td style="font:bold;width:1%;white-space:nowrap;">iHouse_id</td><td style="font:bold;width:1%;white-space:nowrap;">iProductLine_id</td><td style="font:bold;width:1%;white-space:nowrap;">cglsubaccount</td><td class="rightborder" style="font:bold;text-align:left;">iUnitsAvailable</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;"><font color="Red"><b>No Records Found!</b></font></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td class="rightborder" style="background:##eaeaea;text-align:left;"></td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar2;
		}
	}

	function popUpHouseLog(obj)
	{
		var found = 'F';
		dc=document.all['houselog'];
		<cfloop query="getHouseLog">
		if (obj.value =='#getHouseLog.iHouse_ID#') 
		{
			found = 'T';
			var myvar = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder">	<a href="HouseLogMain.cfm"><font color="white">HouseLog Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">iHouseLog_ID</td><td style="font:bold;width:1%;white-space:nowrap;">iHouse_id</td><td style="font:bold;width:1%;white-space:nowrap;">dtCurrentTipsMonth</td><td style="font:bold;width:1%;white-space:nowrap;">dtActualEffective</td><td class="rightborder" style="font:bold;text-align:left;">dtRowStart</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseLog.iHouseLog_ID#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseLog.iHouse_id#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseLog.dtCurrentTipsMonth#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseLog.dtActualEffective#</td><td class="rightborder" style="background:##eaeaea;text-align:left;">#getHouseLog.dtRowStart# </td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';			
			dc.innerHTML = myvar;
		}
		</cfloop>
		if (found == 'F')
		{
		var myvar2 = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder">	<a href="HouseLogMain.cfm"><font color="white">HouseLog Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">iHouseLog_ID</td><td style="font:bold;width:1%;white-space:nowrap;">iHouse_id</td><td style="font:bold;width:1%;white-space:nowrap;">dtCurrentTipsMonth</td><td style="font:bold;width:1%;white-space:nowrap;">dtActualEffective</td><td class="rightborder" style="font:bold;text-align:left;">dtRowStart</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;"><font color="Red"><b>No Records Found!</b></font></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td class="rightborder" style="background:##eaeaea;text-align:left;"></td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar2;
		}
	}

	function popUpHouseNumberControl(obj)
	{
		var found = 'F';
		dc=document.all['housenumbercontrol'];
		<cfloop query="getHouseNumberControl">
		if (obj.value=='#getHouseNumberControl.iHouse_ID#') 
		{
			found = 'T';
			var myvar = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder">	<a href="HouseNbrCtrl.cfm"><font color="white">HouseNumberControl Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">iSolomonKey_ID</td><td style="font:bold;width:1%;white-space:nowrap;">iHouse_id</td><td style="font:bold;width:1%;white-space:nowrap;">cNextSolomonKey</td><td style="font:bold;width:1%;white-space:nowrap;">iNextCashReceipt</td><td class="rightborder" style="font:bold;text-align:left;">iNextInvoice</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseNumberControl.iSolomonKey_ID#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseNumberControl.iHouse_id#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseNumberControl.cNextSolomonKey#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseNumberControl.iNextCashReceipt#</td><td class="rightborder" style="background:##eaeaea;text-align:left;">#getHouseNumberControl.iNextInvoice# </td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';			
			dc.innerHTML = myvar;
		}
		</cfloop>

		if (found == 'F')
		{
		var myvar2 = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder">	<a href="HouseNbrCtrl.cfm"><font color="white">HouseNumberControl Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">iSolomonKey_ID</td><td style="font:bold;width:1%;white-space:nowrap;">iHouse_id</td><td style="font:bold;width:1%;white-space:nowrap;">cNextSolomonKey</td><td style="font:bold;width:1%;white-space:nowrap;">iNextCashReceipt</td><td class="rightborder" style="font:bold;text-align:left;">iNextInvoice</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;"><font color="Red"><b>No Records Found!</b></font></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td class="rightborder" style="background:##eaeaea;text-align:left;"></td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar2;
		}
	}
	
	function popUpHouseAddresses(obj)
	{
		var found = 'F';
		dc=document.all['houseaddresses'];
		<cfloop query="getHouseAddresses">
		if (obj.value=='#getHouseAddresses.iHouse_ID#') 
		{
			found = 'T';		
			var myvar = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder">	<a href="HouseAddress.cfm"><font color="white">HouseAddresses Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">HouseAddress_Ndx</td><td style="font:bold;width:1%;white-space:nowrap;">nHouse</td><td style="font:bold;width:1%;white-space:nowrap;">HAddress</td><td style="font:bold;width:1%;white-space:nowrap;">HCity</td><td class="rightborder" style="font:bold;text-align:left;">HouseEmail</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAddresses.HouseAddress_Ndx#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAddresses.nHouse#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAddresses.HAddress#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAddresses.HCity#</td><td class="rightborder" style="background:##eaeaea;text-align:left;">#getHouseAddresses.HouseEmail# </td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar;
		}
		</cfloop>
		if (found == 'F')
		{
		var myvar2 = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder">	<a href="HouseAddress.cfm"><font color="white">HouseAddresses Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">HouseAddress_Ndx</td><td style="font:bold;width:1%;white-space:nowrap;">nHouse</td><td style="font:bold;width:1%;white-space:nowrap;">HAddress</td><td style="font:bold;width:1%;white-space:nowrap;">HCity</td><td class="rightborder" style="font:bold;text-align:left;">HouseEmail</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;"><font color="Red"><b>No Records Found!</b></font></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td class="rightborder" style="background:##eaeaea;text-align:left;"></td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar2;
		}
		
	}

	function popUpHouseAp(obj)
	{
		var found = 'F';
		dc=document.all['houseap'];
		<cfloop query="getHouseAp">
		if (obj.value=='#getHouseAp.iHouse_ID#') 
		{
			found = 'T';		
			var myvar = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder"><a href="Houseap.cfm"><font color="white">DOCLINK HouseAp Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">iHouse_ID</td><td style="font:bold;width:1%;white-space:nowrap;">cAPEmail</td><td style="font:bold;width:1%;white-space:nowrap;">cAPName</td><td style="font:bold;width:1%;white-space:nowrap;">iOpsArea_ID</td><td class="rightborder" style="font:bold;text-align:left;">cName</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAp.iHouse_ID#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAp.cAPEmail#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAp.cAPName#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAp.iOpsArea_ID#</td><td class="rightborder" style="background:##eaeaea;text-align:left;">#getHouseAp.cName# </td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar;
		}
		</cfloop>
		if (found == 'F')
		{
		var myvar2 = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder"><a href="Houseap.cfm"><font color="white">HouseAp Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">iHouse_ID</td><td style="font:bold;width:1%;white-space:nowrap;">cAPEmail</td><td style="font:bold;width:1%;white-space:nowrap;">cAPName</td><td style="font:bold;width:1%;white-space:nowrap;">iOpsArea_ID</td><td class="rightborder" style="font:bold;text-align:left;">cName</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;"><font color="Red"><b>No Records Found!</b></font></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td class="rightborder" style="background:##eaeaea;text-align:left;"></td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar2;
		}
	}

	function popUpXbankinfo(obj)
	{
		var found = 'F';
		dc=document.all['xbankinfo'];
		<cfloop query="getXbankinfo">
		if (obj.value=='#getXbankinfo.iHouse_ID#') 
		{
			found = 'T';
			var myvar = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder"><a href="xbankinfo.cfm"><font color="white">XBankinfo Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">CnyName</td>	<td style="font:bold;width:1%;white-space:nowrap;">BankName</td><td style="font:bold;width:1%;white-space:nowrap;">CnyAddr1</td><td style="font:bold;width:1%;white-space:nowrap;">CnyState</td><td class="rightborder" style="font:bold;text-align:left;">CnyZip</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">#getxbankinfo.CnyName#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getxbankinfo.BankName#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getxbankinfo.CnyAddr1#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getxbankinfo.CnyState#</td><td class="rightborder" style="background:##eaeaea;text-align:left;">#getxbankinfo.CnyZip# </td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar;
		}
		</cfloop>
		if (found == 'F')
		{
		var myvar2 = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder"><a href="xbankinfo.cfm"><font color="white">XBankinfo Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">CnyName</td><td style="font:bold;width:1%;white-space:nowrap;">BankName</td><td style="font:bold;width:1%;white-space:nowrap;">CnyAddr1</td><td style="font:bold;width:1%;white-space:nowrap;">CnyState</td><td class="rightborder" style="font:bold;text-align:left;">CnyZip</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;"><font color="Red"><b>No Records Found!</b></font></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td class="rightborder" style="background:##eaeaea;text-align:left;"></td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar2;
		}
	}

	function popUpGroups(obj)
	{
		var found = 'F';
		var dd= document.getElementsByName("selectlist")[0];
		dc=document.all['groups'];
		<cfloop query="getGroups">
		if (dd.options[dd.selectedIndex].text =='#getGroups.Groupname#') 
		{
			found = 'T';		
			var myvar = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder"><a href="GroupsMain.cfm"><font color="white">Groups Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">GroupID</td><td style="font:bold;width:1%;white-space:nowrap;">GroupName</td><td style="font:bold;width:1%;white-space:nowrap;">SecurityId</td><td style="font:bold;width:1%;white-space:nowrap;">SystemGroup</td><td class="rightborder" style="font:bold;text-align:left;">User_id</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">#getGroups.groupid#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getGroups.GroupName#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getGroups.Securityid#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getGroups.SystemGroup#</td><td class="rightborder" style="background:##eaeaea;text-align:left;">#getGroups.User_id# </td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar;
		}
		</cfloop>
		if (found == 'F')
		{
		var myvar2 = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder"><a href="GroupsMain.cfm"><font color="white">Groups Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">GroupID</td><td style="font:bold;width:1%;white-space:nowrap;">GroupName</td><td style="font:bold;width:1%;white-space:nowrap;">SecurityId</td><td style="font:bold;width:1%;white-space:nowrap;">SystemGroup</td><td class="rightborder" style="font:bold;text-align:left;">User_id</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;"><font color="Red"><b>No Records Found!</b></font></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td class="rightborder" style="background:##eaeaea;text-align:left;"></td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar2;
		}
	}

	
	function popUpUsers(obj)
	{
		var found = 'F';
		var dd= document.getElementsByName("selectlist")[0];
		dc=document.all['users'];
		<cfloop query="getUsers">
		if (dd.options[dd.selectedIndex].text =='#getUsers.Username#') 
		{
			found = 'T';		
			var myvar = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder"><a href="usersMain.cfm"><font color="white">Users Table</font></a></th><tr>	<td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">UserID</td><td style="font:bold;width:1%;white-space:nowrap;">UserName</td><td style="font:bold;width:1%;white-space:nowrap;">Employeed ID</td><td style="font:bold;width:1%;white-space:nowrap;">Creation Date</td><td class="rightborder" style="font:bold;text-align:left;">Last_Accessed</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">#getusers.UserID#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getusers.UserName#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getusers.EmployeeID#</td><td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getusers.CreationDate#</td><td class="rightborder" style="background:##eaeaea;text-align:left;">#getusers.Last_Accessed# </td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar;
		}
		</cfloop>
		if (found == 'F')
		{
		var myvar2 = '<table><tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr><th width="100%" colspan="5" align="left" class="leftrightborder"><a href="usersMain.cfm"><font color="white">Users Table</font></a></th><tr><td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">UserID</td><td style="font:bold;width:1%;white-space:nowrap;">UserName</td><td style="font:bold;width:1%;white-space:nowrap;">Employeed ID</td><td style="font:bold;width:1%;white-space:nowrap;">Creation Date</td><td class="rightborder" style="font:bold;text-align:left;">Last_Accessed</td></tr><tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;"><font color="Red"><b>No Records Found!</b></font></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td><td class="rightborder" style="background:##eaeaea;text-align:left;"></td></tr><tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr></table>';
			dc.innerHTML = myvar2;
		}
	}


	function popUpFormElements(obj)
	{
		if (obj.value=='') { 
			//document.all['ihouse_id'].innerHTML= '';
			document.forms[0].ihouse_id.value = '';
			document.forms[0].iOpsArea_ID.value = ''; 
			document.forms[0].iPDUser_ID.value = '';  
			document.forms[0].iAcctUser_ID.value = ''; 
			document.forms[0].cName.value = '';                                              
			document.forms[0].cNumber.value = '';    
			document.forms[0].cDepositTypeSet.value = '';      
			document.forms[0].cSLevelTypeSet.value = '';       
			document.forms[0].cGLsubaccount.value = ''; 
			document.forms[0].bIsCensusMedicaidOnly.value = ''; 
			document.forms[0].cPhoneNumber1.value = '';             
			document.forms[0].iPhoneType1_ID.value = ''; 
			document.forms[0].cPhoneNumber2.value = '';             
			document.forms[0].iPhoneType2_ID.value = ''; 
			document.forms[0].cPhoneNumber3.value = '';             
			document.forms[0].iPhoneType3_ID.value = ''; 
			document.forms[0].cAddressLine1.value = '';                                      
			document.forms[0].cAddressLine2.value = '';                                      
			document.forms[0].cCity.value = '';                          
			document.forms[0].cStateCode.value = ''; 
			document.forms[0].cZipCode.value = '';   
			document.forms[0].cComments.value = '';                                                                                                                                                                                                                                                        
			document.forms[0].dtAcctStamp.value = '';                                            
			document.forms[0].cBillingType.value = ''; 
			document.forms[0].iRowStartUser_ID.value = ''; 
			document.forms[0].dtRowStart.value = '';                                             
			document.forms[0].iRowEndUser_ID.value = ''; 
			document.forms[0].dtRowEnd.value = '';                                               
			document.forms[0].iRowDeletedUser_ID.value = ''; 
			document.forms[0].dtRowDeleted.value = '';                                           
			document.forms[0].cRowStartUser_ID.value = '';                                   
			document.forms[0].cRowEndUser_ID.value = '';                                     
			document.forms[0].cRowDeletedUser_ID.value = '';                                 
			document.forms[0].iUnitsAvailable.value = ''; 
			document.forms[0].dtRentalAgreement.value = '';                                      
			document.forms[0].cNurseUser_ID.value = '';                                      
			document.forms[0].EHSIFacilityID.value = ''; 
			document.forms[0].bIsSandbox.value = ''; 
		 }
		<cfloop query="getHouse">
		else if (obj.value=='#getHouse.iHouse_ID#') 
		{ 
			//have all the document.field initialize here
			//document.all['ihouse_id'].innerHTML= '#getHouse.iHouse_id#';
			document.forms[0].ihouse_id.value = '#getHouse.iHouse_id#';
			document.forms[0].OpsArealist.value = '#getHouse.iOpsArea_ID#'; 								
			document.forms[0].iOpsArea_ID.value = '#getHouse.iOpsArea_ID#'; 
			document.forms[0].iPDUser_ID.value = '#getHouse.iPDUser_ID#';  
			document.forms[0].iAcctUser_ID.value = '#getHouse.iAcctUser_ID#'; 
			document.forms[0].AcctUserList.value = '#getHouse.iAcctUser_ID#'; 								
			document.forms[0].cName.value = '#getHouse.cName#';                                              
			document.forms[0].cNumber.value = '#getHouse.cNumber#';    
			document.forms[0].cDepositTypeSet.value = '#getHouse.cDepositTypeSet#';      
			document.forms[0].cSLevelTypeSet.value = '#getHouse.cSLevelTypeSet#';       
			document.forms[0].cGLsubaccount.value = '#getHouse.cGLsubaccount#'; 
			document.forms[0].bIsCensusMedicaidOnly.value = '#getHouse.bIsCensusMedicaidOnly#'; 
			document.forms[0].cPhoneNumber1.value = '#getHouse.cPhoneNumber1#';             
			document.forms[0].iPhoneType1_ID.value = '#getHouse.iPhoneType1_ID#'; 
			document.forms[0].cPhoneNumber2.value = '#getHouse.cPhoneNumber2#';             
			document.forms[0].iPhoneType2_ID.value = '#getHouse.iPhoneType2_ID#'; 
			document.forms[0].cPhoneNumber3.value = '#getHouse.cPhoneNumber3#';             
			document.forms[0].iPhoneType3_ID.value = '#getHouse.iPhoneType3_ID#'; 
			document.forms[0].cAddressLine1.value = '#getHouse.cAddressLine1#';                                      
			document.forms[0].cAddressLine2.value = '#getHouse.cAddressLine2#';                                      
			document.forms[0].cCity.value = '#getHouse.cCity#';                          
			document.forms[0].cStateCode.value = '#getHouse.cStateCode#'; 
			document.forms[0].StateCodeslist.value = '#getHouse.cStateCode#'; 								
			document.forms[0].cZipCode.value = '#getHouse.cZipCode#';   
			document.forms[0].cComments.value = '#replace(getHouse.cComments,Chr(13) & Chr(10)," ", "ALL")#';
			document.forms[0].dtAcctStamp.value = '#getHouse.dtAcctStamp#';                                            
			document.forms[0].cBillingType.value = '#getHouse.cBillingType#'; 
			document.forms[0].iRowStartUser_ID.value = '#getHouse.iRowStartUser_ID#'; 
			document.forms[0].dtRowStart.value = '#getHouse.dtRowStart#';                                             
			document.forms[0].iRowEndUser_ID.value = '#getHouse.iRowEndUser_ID#'; 
			document.forms[0].dtRowEnd.value = '#getHouse.dtRowEnd#';                                               
			document.forms[0].iRowDeletedUser_ID.value = '#getHouse.iRowDeletedUser_ID#'; 
			document.forms[0].dtRowDeleted.value = '#getHouse.dtRowDeleted#';                                           
			document.forms[0].cRowStartUser_ID.value = '#getHouse.cRowStartUser_ID#';                                   
			document.forms[0].cRowEndUser_ID.value = '#getHouse.cRowEndUser_ID#';                                     
			document.forms[0].cRowDeletedUser_ID.value = '#getHouse.cRowDeletedUser_ID#';                                 
			document.forms[0].iUnitsAvailable.value = '#getHouse.iUnitsAvailable#'; 
			document.forms[0].dtRentalAgreement.value = '#getHouse.dtRentalAgreement#';                                      
			document.forms[0].cNurseUser_ID.value = '#getHouse.cNurseUser_ID#';                                      
			document.forms[0].NurseUserList.value = '#getHouse.cNurseUser_ID#'; 								
			document.forms[0].EHSIFacilityID.value = '#getHouse.EHSIFacilityID#'; 
			document.forms[0].bIsSandbox.value = '#getHouse.bIsSandbox#'; 
			
		}
		</cfloop>
	}
	function clearUpFormElements(obj)
	{
			//document.all['ihouse_id'].innerHTML= '';
			document.forms[0].ihouse_id.value = '';
			document.forms[0].iOpsArea_ID.value = ''; 
			document.forms[0].iPDUser_ID.value = '';  
			document.forms[0].iAcctUser_ID.value = '3361'; 
			document.forms[0].cName.value = '';                                              
			document.forms[0].cNumber.value = '';    
			document.forms[0].cDepositTypeSet.value = '';      
			document.forms[0].cSLevelTypeSet.value = '9';       
			document.forms[0].cGLsubaccount.value = ''; 
			document.forms[0].bIsCensusMedicaidOnly.value = ''; 
			document.forms[0].cPhoneNumber1.value = '';             
			document.forms[0].iPhoneType1_ID.value = '2'; 
			document.forms[0].cPhoneNumber2.value = '';             
			document.forms[0].iPhoneType2_ID.value = '6'; 
			document.forms[0].cPhoneNumber3.value = '';             
			document.forms[0].iPhoneType3_ID.value = ''; 
			document.forms[0].cAddressLine1.value = '';                                      
			document.forms[0].cAddressLine2.value = '';                                      
			document.forms[0].cCity.value = '';                          
			document.forms[0].cStateCode.value = ''; 
			document.forms[0].cZipCode.value = '';   
			document.forms[0].cComments.value = '';                                                                                                                                                                                                                                                        
			document.forms[0].dtAcctStamp.value = '';                                            
			document.forms[0].cBillingType.value = 'D'; 
			document.forms[0].iRowStartUser_ID.value = ''; 
			document.forms[0].dtRowStart.value = '';                                             
			document.forms[0].iRowEndUser_ID.value = ''; 
			document.forms[0].dtRowEnd.value = '';                                               
			document.forms[0].iRowDeletedUser_ID.value = ''; 
			document.forms[0].dtRowDeleted.value = '';                                           
			document.forms[0].cRowStartUser_ID.value = '';                                   
			document.forms[0].cRowEndUser_ID.value = '';                                     
			document.forms[0].cRowDeletedUser_ID.value = '';                                 
			document.forms[0].iUnitsAvailable.value = ''; 
			document.forms[0].dtRentalAgreement.value = '';                                      
			document.forms[0].cNurseUser_ID.value = '3317';                                      
			document.forms[0].EHSIFacilityID.value = ''; 
			document.forms[0].bIsSandbox.value = '0'; 
	}
</script>
</cfoutput>
</head>
<body>
<form action="<cfoutput>#cgi.script_name#</cfoutput>" method="post" >
<cfoutput>
<input type="hidden" name="PageAction" value=""> 
<table>
	<tr><td class="topleftcap" colspan="2"></td><td class="toprightcap" colspan="2"></td></tr>
	<tr><th class="leftrightborder" colspan="4">Maintenance House Master</th></tr>
	<tr><td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
	<b>Choose from the List:</b><br>
	<select name="selectlist" size="60" onChange="popUpFormElements(this);popUpHouseProductLine(this);popUpHouseLog(this);popUpHouseNumberControl(this);popUpHouseAddresses(this);popUpHouseAp(this);popUpXbankinfo(this);popUpGroups(this); popUpUsers(this);">
	<cfloop query="getHouse">
	<option value='#getHouse.iHouse_id#' style='color:blue;background:##eaeaea;'>#getHouse.cName#</option>
	</cfloop>
	</select>
	</td>
	<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;font-weight:bold;">
		<table>
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">House:</font></td><td><input name="ihouse_id" type="text" value = "#getHouse.iHouse_id#"></td></tr>
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">iOpsArea_ID:</font></td><td>
		<input name="iOpsArea_ID" type="text" value = "#getHouse.iOpsArea_ID#" size="4" readonly="true">
		<cfset variOpsArea_id = getHouse.iOpsArea_id>
		<select name="OpsArealist"  onChange="popUpOpsAreaField(this);">
		<cfloop query="getOpsArea">
			<option value='#getOpsArea.iOpsArea_id#' style='color:blue;background:##eaeaea;'
			<cfif IsDefined("form.iOpsArea_id")>
				<cfif getOpsArea.iOpsArea_id EQ form.iOpsArea_ID>
					Selected
				</cfif> 
			<cfelse>
				<cfif getOpsArea.iOpsArea_id EQ variOpsArea_id>
					Selected
				</cfif> 
			</cfif>>#getOpsArea.iOpsArea_id#, #getOpsArea.cName#</option>
		</cfloop>
		</select>
		</td></tr>
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">iPDUser_ID:</font></td><td><input name="iPDUser_ID" type="text" size="50" value = "#getHouse.iPDUser_ID#"> 
		cNumber  </td>
		</tr>
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">iAcctUser_ID:</font></td><td>
		<input name="iAcctUser_ID" type="text" value = "#getHouse.iAcctUser_ID#" size="10" readonly="true">
		<cfset variAcctUser_id = getHouse.iAcctUser_id>
		<select name="AcctUserList"  onChange="popUpAcctUserField(this);">
		<cfloop query="getEmployees">
			<option value='#getEmployees.Employee_Ndx#' style='color:blue;background:##eaeaea;'
			<cfif IsDefined("form.iAcctUser_ID")>
				<cfif getEmployees.Employee_Ndx EQ form.iAcctUser_ID>
					Selected
				</cfif> 
			<cfelse>
				<cfif getEmployees.Employee_Ndx EQ variAcctUser_id>
					Selected
				</cfif> 
			</cfif>>#getEmployees.lName#, #getEmployees.fName#</option>
		</cfloop>
		</select>
		</td></tr>
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cName:</font></td><td><input name="cName" type="text" size="50" value = "#getHouse.cName#"></td></tr>
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cNumber:</font></td><td><input name="cNumber" type="text" size="50" value = "#getHouse.cNumber#"></td></tr>
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">cDepositTypeSet:</td><td><input name="cDepositTypeSet" type="text" size="50" value = "#getHouse.cDepositTypeSet#"></td></tr>
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cSLevelTypeSet:</font></td><td><input name="cSLevelTypeSet" type="text" size="50" value = "#getHouse.cSLevelTypeSet#"></td></tr>
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cGLsubaccount:</font></td>
		<td><input name="cGLsubaccount" type="text" size="50" value = "#getHouse.cGLsubaccount#"></td></tr>	
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">bIsCensusMedicaidOnly:</td><td><input name="bIsCensusMedicaidOnly" type="text" size="50" value = "#getHouse.bIsCensusMedicaidOnly#"></td></tr>	
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cPhoneNumber1:</font></td><td><input name="cPhoneNumber1" type="text" size="50" value = "#getHouse.cPhoneNumber1#"></td></tr>	
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">iPhoneType1_ID:</font></td><td><input name="iPhoneType1_ID" type="text" size="50" value = "#getHouse.iPhoneType1_ID#"></td></tr>	
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cPhoneNumber2:</font></td><td><input name="cPhoneNumber2" type="text" size="50" value = "#getHouse.cPhoneNumber2#"></td></tr>	
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">iPhoneType2_ID:</font></td><td><input name="iPhoneType2_ID" type="text" size="50" value = "#getHouse.iPhoneType2_ID#"></td></tr>	
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">cPhoneNumber3:</span></td>
		<td><input name="cPhoneNumber3" type="text" size="50" value = "#getHouse.cPhoneNumber3#"></td></tr>	
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><span class="style1">iPhoneType3_ID:</span></td>
		<td><input name="iPhoneType3_ID" type="text" size="50" value = "#getHouse.iPhoneType3_ID#"></td></tr>	
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cAddressLine1:</font></td><td><input name="cAddressLine1" type="text" size="50" value = "#getHouse.cAddressLine1#"></td></tr>	
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cAddressLine2:</font></td><td><input name="cAddressLine2" type="text" size="50" value = "#getHouse.cAddressLine2#"></td></tr>	
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cCity:</font></td><td><input name="cCity" type="text" size="50" value = "#getHouse.cCity#"></td></tr>	
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cStateCode:</font></td><td><input name="cStateCode" type="text" value = "#getHouse.cStateCode#" size="2" readonly="true">
		<cfset varcStateCode = getHouse.cStateCode>
		<select name="StateCodeslist"  onChange="popUpStateCodesField(this);">
		<cfloop query="getStateCode">
			<option value='#getStateCode.cStateCode#' style='color:blue;background:##eaeaea;'
			<cfif IsDefined("form.cStateCodes")>
				<cfif getStateCode.cStateCode EQ form.cStateCode>
					Selected
				</cfif> 
			<cfelse>
				<cfif getStateCode.cStateCode EQ varcStateCode>
					Selected
				</cfif> 
			</cfif>>#getStateCode.cStateCode#, #getStateCode.cStateName#</option>
		</cfloop>
		</select>
		</td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cZipCode:</font></td><td><input name="cZipCode" type="text" size="5" value = "#getHouse.cZipCode#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">cComments:</td><td><textarea name="cComments" cols="40" rows="5" >#getHouse.cComments#</textarea></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">dtAcctStamp:</td><td><input name="dtAcctStamp" type="text" size="50" value = "#getHouse.dtAcctStamp#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cBillingType:</font></td><td><input name="cBillingType" type="text" size="50" value = "#getHouse.cBillingType#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">iRowStartUser_ID:</td><td><input name="iRowStartUser_ID" type="text" size="50" value = "#getHouse.iRowStartUser_ID#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">dtRowStart:</td><td><input name="dtRowStart" type="text" value = "#getHouse.dtRowStart#" size="50" readonly="true"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">iRowEndUser_ID:</td><td><input name="iRowEndUser_ID" type="text" size="50" value = "#getHouse.iRowEndUser_ID#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">dtRowEnd:</td><td><input name="dtRowEnd" type="text" size="50" value = "#getHouse.dtRowEnd#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">iRowDeletedUser_ID:</td><td><input name="iRowDeletedUser_ID" type="text" size="50" value = "#getHouse.iRowDeletedUser_ID#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">dtRowDeleted:</td><td><input name="dtRowDeleted" type="text" value = "#getHouse.dtRowDeleted#" size="50" readonly="true"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">cRowStartUser_ID:</td><td><input name="cRowStartUser_ID" type="text" size="50" value = "#getHouse.cRowStartUser_ID#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">cRowEndUser_ID:</td><td><input name="cRowEndUser_ID" type="text" size="50" value = "#getHouse.cRowEndUser_ID#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">cRowDeletedUser_ID:</td><td><input name="cRowDeletedUser_ID" type="text" size="50" value = "#getHouse.cRowDeletedUser_ID#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">iUnitsAvailable:</font></td><td><input name="iUnitsAvailable" type="text" size="50" value = "#getHouse.iUnitsAvailable#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;">dtRentalAgreement:</td><td><input name="dtRentalAgreement" type="text" size="50" value = "#getHouse.dtRentalAgreement#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">cNurseUser_ID:</font></td><td>
		<input name="cNurseUser_ID" type="text" value = "#getHouse.cNurseUser_ID#" size="10" readonly="true">
		<cfset varcNurseUser_id = getHouse.cNurseUser_ID>
		<select name="NurseUserList"  onChange="popUpNurseUserField(this);">
		<cfloop query="getEmployees">
			<option value='#getEmployees.Employee_Ndx#' style='color:blue;background:##eaeaea;'
			<cfif IsDefined("form.cNurseUser_ID")>
				<cfif getEmployees.Employee_Ndx EQ form.cNurseUser_ID>
					Selected
				</cfif> 
			<cfelse>
				<cfif getEmployees.Employee_Ndx EQ varcNurseUser_id>
					Selected
				</cfif> 
			</cfif>>#getEmployees.lName#, #getEmployees.fName#</option>
		</cfloop>
		</select>
		</td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">EHSIFacilityID:</font></td><td><input name="EHSIFacilityID" type="text" size="50" value = "#getHouse.EHSIFacilityID#"></td></tr>		
		<tr><td style="background:##eaeaea;text-align:right;font-weight:bold;font-size:10pt;"><font color="Red">bIsSandbox:</font></td><td><input name="bIsSandbox" type="text" size="50" value = "#getHouse.bIsSandbox#"></td></tr>			
		<tr><td></td><td><br><br><table><tr><td><input name="Add" type="button" value="          Add            "onClick="Javascript:document.forms[0].PageAction.value='Insert';document.forms[0].submit();"></td>
		<td><input name="Update" type="button" value="          Update         " onClick="Javascript:document.forms[0].PageAction.value='Update';document.forms[0].submit();"></td>
		<td><input name="Delete" type="button" value="          Delete         " onClick="Javascript:document.forms[0].PageAction.value='Delete';document.forms[0].submit();"></td>
		<td><input name="Clear"  type="button" value="          Clear          " onClick="clearUpFormElements(this);"></td></tr></table></td></tr>
		</table> 
	</td></tr>
	<tr>
		<td colspan="2" class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
		<td class="rightborder" colspan="3" style="background:##eaeaea;text-align:right;"> </td>
	</tr>	
	<tr><td colspan="4" align="right" class="leftrightborder"><b><cfoutput>#msg#</cfoutput></b></td></tr>
	<tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr>
	</table>
	<SPAN ID="houseproductline">
	<table>
	<tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr>
	<th width="100%" colspan="5" align="left" class="leftrightborder">	<a href="HouseProductLine.cfm"><font color="white">HouseProductLine Table</font></a></th>
	<tr>
	<td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">iHouseProductLine_id</td>
	<td style="font:bold;width:1%;white-space:nowrap;">iHouse_id</td>
	<td style="font:bold;width:1%;white-space:nowrap;">iProductLine_id</td>
	<td style="font:bold;width:1%;white-space:nowrap;">cglsubaccount</td><td class="rightborder" style="font:bold;text-align:left;">iUnitsAvailable</td>
	</tr>
	<cfif getHouseProductLine.recordcount gt 0>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
			#getHouseProductLine.iHouseProductLine_id#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseProductLine.iHouse_id#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseProductLine.iProductLine_id#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseProductLine.cglsubaccount#</td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;">#getHouseProductLine.iUnitsAvailable# </td>
			</tr>

	<cfelse>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
				<font color="Red"><b>No Records Found!</b></font></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;"></td>
			</tr>
	</cfif>
		<tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr>
	</table>			
	</span>
	<SPAN ID="houselog">
	<table>
	<tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr>
	<th width="100%" colspan="5" align="left" class="leftrightborder">	<a href="HouseLogMain.cfm"><font color="white">HouseLog Table</font></a></th>
	<tr>
	<td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">iHouseLog_ID</td>
	<td style="font:bold;width:1%;white-space:nowrap;">iHouse_id</td>
	<td style="font:bold;width:1%;white-space:nowrap;">dtCurrentTipsMonth</td>
	<td style="font:bold;width:1%;white-space:nowrap;">dtActualEffective</td>
	<td class="rightborder" style="font:bold;text-align:left;">dtRowStart</td>
	</tr>
	<cfif getHouseLog.recordcount gt 0>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
			#getHouseLog.iHouseLog_ID#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseLog.iHouse_id#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseLog.dtCurrentTipsMonth#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseLog.dtActualEffective#</td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;">#getHouseLog.dtRowStart# </td>
			</tr>
	<cfelse>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
				<font color="Red"><b>No Records Found!</b></font></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;"></td>
			</tr>
	</cfif>
		<tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr>
	</table>			
	</span>
	<SPAN ID="housenumbercontrol">
	<table>
	<tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr>
	<th width="100%" colspan="5" align="left" class="leftrightborder">	<a href="HouseNbrCtrl.cfm"><font color="white">HouseNumberControl Table</font></a></th>
	<tr>
	<td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">iSolomonKey_ID</td>
	<td style="font:bold;width:1%;white-space:nowrap;">iHouse_id</td>
	<td style="font:bold;width:1%;white-space:nowrap;">cNextSolomonKey</td>
	<td style="font:bold;width:1%;white-space:nowrap;">iNextCashReceipt</td>
	<td class="rightborder" style="font:bold;text-align:left;">iNextInvoice</td>
	</tr>
	<cfif getHouseNumberControl.recordcount gt 0>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
			#getHouseNumberControl.iSolomonKey_ID#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseNumberControl.iHouse_id#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseNumberControl.cNextSolomonKey#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseNumberControl.iNextCashReceipt#</td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;">#getHouseNumberControl.iNextInvoice# </td>
			</tr>
	<cfelse>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
				<font color="Red"><b>No Records Found!</b></font></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;"></td>
			</tr>
	</cfif>
		<tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr>
	</table>			
	</span>
	<SPAN ID="houseaddresses">
	<table>
	<tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr>
	<th width="100%" colspan="5" align="left" class="leftrightborder">	<a href="HouseAddress.cfm"><font color="white">HouseAddresses Table</font></a></th>
	<tr>
	<td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">HouseAddress_Ndx</td>
	<td style="font:bold;width:1%;white-space:nowrap;">nHouse</td>
	<td style="font:bold;width:1%;white-space:nowrap;">HAddress</td>
	<td style="font:bold;width:1%;white-space:nowrap;">HCity</td>
	<td class="rightborder" style="font:bold;text-align:left;">HouseEmail</td>
	</tr>
	<cfif getHouseAddresses.recordcount gt 0>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
			#getHouseAddresses.HouseAddress_Ndx#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAddresses.nHouse#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAddresses.HAddress#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAddresses.HCity#</td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;">#getHouseAddresses.HouseEmail# </td>
			</tr>
	<cfelse>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
				<font color="Red"><b>No Records Found!</b></font></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;"></td>
			</tr>
	</cfif>
		<tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr>
	</table>			
	</span>
	<SPAN ID="houseap">
	<table>
	<tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr>
	<th width="100%" colspan="5" align="left" class="leftrightborder"><a href="Houseap.cfm"><font color="white">DOCLINK HouseAp Table</font></a></th>
	<tr>
	<td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">iHouse_ID</td>
	<td style="font:bold;width:1%;white-space:nowrap;">cAPEmail</td>
	<td style="font:bold;width:1%;white-space:nowrap;">cAPName</td>
	<td style="font:bold;width:1%;white-space:nowrap;">iOpsArea_ID</td>
	<td class="rightborder" style="font:bold;text-align:left;">cName</td>
	</tr>
	<cfif getHouseAp.recordcount gt 0>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
			#getHouseAp.iHouse_ID#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAp.cAPEmail#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAp.cAPName#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getHouseAp.iOpsArea_ID#</td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;">#getHouseAp.cName# </td>
			</tr>
	<cfelse>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
				<font color="Red"><b>No Records Found!</b></font></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;"></td>
			</tr>
	</cfif>
		<tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr>
	</table>			
	</span>
	<SPAN ID="xbankinfo">
	<table>
	<tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr>
	<th width="100%" colspan="5" align="left" class="leftrightborder"><font color="white">XBankinfo Table</font></th>
	<tr>
	<td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">CnyName</td>
	<td style="font:bold;width:1%;white-space:nowrap;">BankName</td>
	<td style="font:bold;width:1%;white-space:nowrap;">CnyAddr1</td>
	<td style="font:bold;width:1%;white-space:nowrap;">CnyState</td>
	<td class="rightborder" style="font:bold;text-align:left;">CnyZip</td>
	</tr>
	<cfif getxbankinfo.recordcount gt 0>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
			#getxbankinfo.CnyName#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getxbankinfo.BankName#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getxbankinfo.CnyAddr1#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getxbankinfo.CnyState#</td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;">#getxbankinfo.CnyZip# </td>
			</tr>
	<cfelse>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
				<font color="Red"><b>No Records Found!</b></font></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;"></td>
			</tr>
	</cfif>
		<tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr>
	</table>			
	</span>
	<SPAN ID="groups">
	<table>
	<tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr>
	<th width="100%" colspan="5" align="left" class="leftrightborder"><a href="GroupsMain.cfm"><font color="white">Groups Table</font></a></th>
	<tr>
	<td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">GroupID</td>
	<td style="font:bold;width:1%;white-space:nowrap;">GroupName</td>
	<td style="font:bold;width:1%;white-space:nowrap;">SecurityId</td>
	<td style="font:bold;width:1%;white-space:nowrap;">SystemGroup</td>
	<td class="rightborder" style="font:bold;text-align:left;">User_id</td>
	</tr>
	<cfif getGroups.recordcount gt 0>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
			#getGroups.groupid#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getGroups.GroupName#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getGroups.Securityid#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getGroups.SystemGroup#</td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;">#getGroups.User_id# </td>
			</tr>
	<cfelse>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
				<font color="Red"><b>No Records Found!</b></font></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;"></td>
			</tr>
	</cfif>
		<tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr>
	</table>			
	</span>

	<SPAN ID="users">
	<table>
	<tr><td class="topleftcap" colspan="3"></td><td class="toprightcap" colspan="2"></td></tr>
	<th width="100%" colspan="5" align="left" class="leftrightborder"><a href="usersMain.cfm"><font color="white">Users Table</font></a></th>
	<tr>
	<td class="leftborder" style="font:bold;width:1%;white-space:nowrap;">UserID</td>
	<td style="font:bold;width:1%;white-space:nowrap;">UserName</td>
	<td style="font:bold;width:1%;white-space:nowrap;">Employeed ID</td>
	<td style="font:bold;width:1%;white-space:nowrap;">Creation Date</td>
	<td class="rightborder" style="font:bold;text-align:left;">Last_Accessed</td>
	</tr>
	<cfif getusers.recordcount gt 0>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
			#getusers.UserID#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getusers.UserName#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getusers.EmployeeID#</td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;">#getusers.CreationDate#</td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;">#getusers.Last_Accessed# </td>
			</tr>
	<cfelse>
			<tr>
			<td class="leftborder" style="background:##eaeaea;width:1%;white-space:nowrap;">
				<font color="Red"><b>No Records Found!</b></font></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td  style="background:##eaeaea;width:1%;white-space:nowrap;"></td>
			<td class="rightborder" style="background:##eaeaea;text-align:left;"></td>
			</tr>
	</cfif>
		<tr><td class="bottomleftcap" colspan="3"></td><td class="bottomrightcap" colspan="2"></td></tr>
	</table>			
	</span>
	
<!--- 	
	
<h5>	All Records in House Table </h5>
<span id="houserecords">
	<script>
	//	create ActiveWidgets Grid javascript object
	var obj = new Active.Controls.Grid;
	//	set number of rows/columns
	obj.setRowProperty("count", #getHouse.Recordcount#);
	obj.setColumnProperty("count", 10);
	//	provide cells and headers text
	obj.setDataProperty("text", function(i, j){return myData[i][j]});
	obj.setColumnProperty("text", function(i){return myColumns[i]});
	//	set headers width/height
	obj.setRowHeaderWidth("28px");
	obj.setColumnHeaderHeight("20px");
	//	set click action handler
	obj.setAction("click", function(src){window.status = src.getItemProperty("text")});
	function myColor(){
		var value = this.getItemProperty("value");
		return value > 10000 ? "red" : "blue";
	}
	obj.getColumnTemplate(4).setStyle("color", myColor);
	obj.getColumnTemplate(0).setStyle("color", "Maroon");
	//	write grid html to the page
	document.write(obj);
	
	</script>
</span>

 ---></cfoutput>

</form>
<hr>
</body>
</html>
