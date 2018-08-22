<cfset Page = "Edit House Visit">
 
 <cfparam name="rolename" default="">
 
<cfoutput>
	<!--- COLORS --->
	<cfset groupColor = "cdcdcd">
	<cfset freezeColor = "f5f5f5">
	<cfset toolbarColor = "d6d6ab">
	<cfset spellCheckBgColor = "ebebeb">
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
		<head>
			<link rel="stylesheet" href="CSS/datePicker.css" type="text/css">

			<script type="text/javascript" src="ScriptFiles/jquery-1.3.2.js"></script> 			
			<script src="ScriptFiles/jquery.hoverIntent.js" type="text/javascript"></script>
  			<script src="ScriptFiles/jquery.bgiframe.js" type="text/javascript"></script>
  			<script src="ScriptFiles/jquery.cluetip.js" type="text/javascript"></script>
			<script type="text/javascript" src="ScriptFiles/date.js"></script>
			<script type="text/javascript" src="ScriptFiles/jquery.datePicker.js"></script>
			<script type="text/javascript" src="ScriptFiles/jquery.blockUI.js"></script>
			<script type="text/javascript" src="ScriptFiles/jquery.wait.js"></script>
							
			<link rel="stylesheet" href="jquery.cluetip.css" type="text/css" />
			
			<title>
				Online FTA- #page#
			</title>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
			<cfheader name='expires' value='#Now()#'> 
			<cfheader name='pragma' value='no-cache'>
			<cfheader name='cache-control' value='no-cache,no-store, must-revalidate'>
			
			<!--- Instantiate the Helper object. --->
			<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
			
			<cfif isDefined("url.iHouse_ID")>
				<cfset houseId = #url.iHouse_ID#>
			</cfif>
			
			<cfif isDefined("url.SubAccount")>
				<cfset subAccount = #url.SubAccount#>
							
				<cfset dsHouseInfo = #helperObj.FetchHouseInfo(subAccount)#>
				<cfset unitId = #dsHouseInfo.unitId#>
				<!--- <cfset houseId = #dsHouseInfo.iHouse_ID#> --->
				<cfset HouseNumber = #trim(dsHouseInfo.EHSIFacilityID)#>
			</cfif>
			
			<cfif isDefined("url.NumberOfMonths")>
				<cfset numberOfMonths = #url.NumberOfMonths#>
			<cfelse>
				<cfset numberOfMonths = 3>
			</cfif>
			 
			<cfif isDefined("url.FromDateToUse")>
				<cfset fromDateToUse = #url.FromDateToUse#>
			<cfelse>
				<cfset fromDateToUse = #DateAdd("m", -3, dateToUse)#>
			</cfif>			
			
			<cfif isDefined("url.iEntryId")>
				<cfset entryId = #url.iEntryId#>
			<cfelse>
			Lost Connection
			<cfabort>	
			</cfif>

			
			<cfinclude template="Common/DateToUse.cfm">
			<cfinclude template="ScriptFiles/FTACommonScript.cfm">

			<!--- STRING METHODS --->
			<script language="javascript" type="text/javascript">
				String.prototype.endsWith = function(str) {return (this.match(str+"$")==str)}
				String.prototype.startsWith = function(str) {return (this.match("^"+str)==str)}
			</script>
			
			<style type="text/css">

				a.dp-choose-date {
					float: left;
					width: 16px;
					height: 16px;
					padding: 0;
					margin: 3px 1px 0;
					display: block;
					text-indent: -2000px;
					overflow: hidden;
					background: url(Images/Calendar.png) no-repeat; 
				}
				a.dp-choose-date.dp-disabled {
					background-position: 0 -20px;
					cursor: default;
				}

				input.dp-applied {
					width: 122px;
					float: left;
				}
			</style>
		</head>
	<body>
		<cfinclude template="DisplayFiles/Header.cfm">
</cfoutput>


  

<cfoutput>
	<!--- Data Source (Query) Objects --->
	<cfset dsQuestions = helperObj.FetchHouseVisitDataII(entryId)>
	<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryByIdII(entryId)> 
	<cfset dsRole = helperObj.FetchHouseVisitRoleII(dsQuestions.iRole)>

	<!--- <cfdump var="#dsRole#"> --->

	<cfset roleName = dsRole.cRoleName>
	<cfset dsGroups = helperObj.FetchHouseVisitGroupsII(rolename)>
	<cfset dsQuestionRoles = helperObj.FetchHouseVisitQuestionRoles()>

	<!--- Stores all of the active entry info. --->
	<cfset entryDate = #DateFormat(dsActiveEntry.dtHouseVisit, "mm/dd/yyyy")#>
	<cfset userId = dsActiveEntry.cUserName>
	<cfset userFullName = dsActiveEntry.cUserDisplayName>
	
	<cfset lastUpdate = DateFormat(dsActiveEntry.dtLastUpdate, "mm/dd/yyyy") & " " & TimeFormat(dsActiveEntry.dtLastUpdate, "hh:mm:ss tt")>
	<cfset created = DateFormat(dsActiveEntry.dtCreated, "mm/dd/yyyy") & " " & TimeFormat(dsActiveEntry.dtCreated, "hh:mm:ss tt")>
				<input type="hidden"  name="EntryUserId" 			id="hdnEntryUserId" 		value="#url.iEntryUserId#" />
				<input type="hidden"  name="EntryuserRole" 			id="hdnEntryuserRole" 		value="#EntryuserRole#" />
				<input type="hidden"  name="EntryuserFullName" 		id="hdnEntryuserFullName" 	value="#url.EntryuserFullName#" />
				<input type="hidden"  name="hdnrolename" 			id="hdnrolename" 			value="#url.hdnrolename#" />
				<input type="hidden"  name="userRoleID" 			id="hdnuserRoleID" 			value="#url.userRoleID#" />
				<input type="hidden"  name="ihouse_ID" 			id="hdnhouseid" 			value="#url.ihouse_id#" />
	<table id="tblEditEntry" cellspacing="0" cellpadding="1" border="1px"  >
		<tr>
			<td colspan="5" style="margin-left: 10px;" bgcolor="#freezeColor#">
				<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" align="left" id="tblHouseVisitsHeaderContainer">
					<tr>
						<td align="left" valign="top" colspan="1" width="400px">
							<table cellspacing="0" cellpadding="0" border="0" align="left" id="tblHouseVisitsHeader">
								<tr>
									<td align="left" colspan="1" style="font-family: verdana; font-weight: bold;" bgcolor="#freezeColor#" width="60px">
										<label for="txtEntryDate">
											<font size=-1>
												Date:
											</font>
										</label>
									</td>
									<td align="left" colspan="1"  bgcolor="#freezeColor#" width="150px">
										<input type="text" id="txtEntryDate" readonly="yes" name="txtEntryDate" style="text-align: left;" value="#DateFormat(entryDate, 'mm/dd/yyyy')#" />
									</td>
								</tr>
								<tr>
									<td align="left" colspan="1" style="font-family: verdana; font-weight: bold;" bgcolor="#freezeColor#" width="60px">
										<label for="txtEntryUserRole">
											<font size=-1>
												Role:
											</font>
										</label>
									</td>
									<td align="left" colspan="1"  bgcolor="#freezeColor#" width="150px">
										<input type="text" id="txtEntryUserRole" readonly="true" name="rolefilter" style="background-color: #freezeColor#; width: 140px;" value="#roleName#" />
									</td>
								</tr>
								<tr>
									<td align="left" colspan="1" style="font-family: verdana; font-weight: bold;" bgcolor="#freezeColor#" width="60px">
										<label for="txtEntryUserFullName">
											<font size=-1>
												Name:
											</font>
										</label>
									</td>
									<td align="left" colspan="1"  bgcolor="#freezeColor#" width="150px">
										<input type="text" id="txtEntryUserFullName" readonly="true" style="background-color: #freezeColor#; width: 140px;" value="#userFullName#" />
										<input type="hidden" id="hdnEntryUserId" value="#userId#" />
									</td>
								</tr>
							</table>
						</td>
						<td align="right" valign="top" colspan="1" bgcolor="#freezeColor#">
							<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0">
								<tr>
									<td width="100%" height="60%" align="right" valign="top" bgcolor="#freezeColor#">
										<a style="padding: 8px;" href="HouseVisitsII.cfm?iHouse_ID=#houseId#&IENTRYUSERID=#userId#&EntryuserFullName=#Trim(userFullName)#&Role=#url.Role#&NumberOfMonths=#numberOfMonths#&DateToUse=#datetouse#&SubAccount=#subaccount#">
											<font size=-1> 
												Return to House Visits Page
											</font>
										</a>
									</td>
								</tr>	
								<tr>
									<td style="padding-bottom: 7px; padding-right: 8px;" width="100%" height="20%" align="right" valign="bottom" bgcolor="#freezeColor#">
										<font size=-1 color="navy">
											<strong>
												Created: 
											</strong>
											#created#
										</font>
									</td>
								</tr>									
								<tr>
									<td style="padding-bottom: 7px; padding-right: 8px;" width="100%" height="20%" align="right" valign="bottom" bgcolor="#freezeColor#">
										<font size=-1 color="navy">
											<strong>
												Last Update: 
											</strong>
											#lastUpdate#
											<input type="hidden" id="hdnLastUpdate" name="hdnLastUpdate" value="#lastUpdate#" />
										</font>
									</td>
								</tr>	
								<cfif url.userroleid gt 0>
								<cfif #Int(Now()-dsActiveEntry.dtCreated)# le 5> 
								<tr>
									<td width="100%" height="60%" align="right" valign="top" bgcolor="#freezeColor#">
										<a style="padding: 8px;" href="EditHouseVisitEntryII.cfm?iHouse_ID=#houseId#&iEntryId=#iEntryId#&IENTRYUSERID=#userId#&EntryuserFullName=#Trim(userFullName)#&EntryuserRole=#url.EntryuserRole#&hdnrolename=#RoleName#&userRoleId=#userRoleId#&Role=#url.Role#&NumberOfMonths=#numberOfMonths#&DateToUse=#datetouse#&SubAccount=#subaccount#">
											<font size=-1>
												Edit this entry
											</font>
										</a>
									</td>
								</tr>
								<cfelse>
								<tr>
									<td width="100%" height="60%" align="right" valign="top" bgcolor="#freezeColor#">
									Entries older than 5 days are not eligible for editing.
									</td>
								</tr>
								</cfif>
								</cfif>
								<tr>
									<td width="100%" height="60%" align="right" valign="top" bgcolor="#freezeColor#">
										<a style="padding: 8px;" href="HouseVisitViewPrint.cfm?iHouse_ID=#houseId#&iEntryId=#iEntryId#&IENTRYUSERID=#userId#&EntryuserFullName=#Trim(userFullName)#&EntryuserRole=#url.EntryuserRole#&hdnrolename=#RoleName#&userRoleId=#userRoleId#&Role=#url.Role#&NumberOfMonths=#numberOfMonths#&DateToUse=#datetouse#&SubAccount=#subaccount#">
											<font size=-1>
												Print this entry
											</font>
										</a>
									</td>
								</tr>
							</table>		
						</td>
					</tr>
				</table>
			</td>
		</tr>	
				<cfloop query="dsGroups" >
					<cfset thisgroup = dsGroups.iGroupId>
						<cfset dsEntryCount = helperObj.FetchHouseVisitAnswerCountII(#entryiD#, #dsGroups.iGroupId#)> 									
						<cfif dsEntryCount is ""  >
							<cfset maxrep = 0> 
						<cfelse>
							<cfset maxrep = #dsEntryCount#> 
						</cfif>					
					<tr>
						<td colspan="5" >
						<table  id="#trim(dsGroups.cGroupName)#"    border="1"   bordercolor="#groupcolor#" >
						
							<tr style=" background-color: #groupcolor#;">
								<th colspan="5" style="text-align:left"; font-weight:"100"; width="800px"> #dsGroups.iGroupId#.  #dsGroups.cTextHeader#</th>
							</tr>
										<cfset dsGroupQuestionsHdr = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
								<tr>
									<cfloop query="dsGroupQuestionsHdr">
										<th style="text-align:left"  >#dsGroupQuestionsHdr.cQuestion#</th>
									</cfloop>					
								</tr>
							  
								<cfset indexname  = #Trim("dsGroups.indexname")# >
								<cfset i = 0>
								 
								<input type="hidden" name="#trim(indexname)#" value="#maxrep#" id="id#Trim(dsGroups.indexname)#">
								<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
									<cfset i = i + 1>
									<tr  style=" background-color: ##ffffff;" >
										<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
										<cfif dsGroupQuestions.cRowSize is not "">
										<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(entryiD, thisgroup, dsGroupQuestions.iQuestionId, i)>
											<td  colspan="5" style="text-align:left"><textarea name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" rows="#dsGroupQuestions.cRowSize#" cols="#dsGroupQuestions.cColSize#">#dsActiveEntry# </textarea></td>		 
										
										<cfelseif dsGroupQuestions.cColSize is 1>
											<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(entryID, thisgroup, dsGroupQuestions.iQuestionId, i)>
											<td style="text-align:left">
												<cfif #trim(dsActiveEntry)# is "Y">	YES	<cfelseif #trim(dsActiveEntry)# is "N">NO</cfif>
											</td>														
										
										<cfelseif dsGroupQuestions.cIncludeDate is "Y">
											<cfset dsActiveEntry = dateformat(helperObj.FetchHouseVisitEntryAnswersII(entryID, thisgroup, dsGroupQuestions.iQuestionId, i),"mm/dd/yyyy")>
											<td>
											#dsActiveEntry#
												<!--- 	<input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="idMarAuditDate" value="#DateFormat(Now(), 'mm/dd/yyyy')#" onBlur="showAuditDate()" >
												<a onClick="show_calendar2('document.frmHouseVisitOpEntry.dtMarAuditDate',document.getElementById('dtMarAuditDate').value,'dtMarAuditDate');"> 
												<img src="../global/Calendar/calendar.gif" alt="Calendar" width="20" height="20" border="0" align="middle" style="" id="Cal" name="Cal"></a>
												<input type="text" name="DayOfMonth" id="idDayOfMonth" value="">  --->
											</td>
										<cfelse>
											<cfloop query="dsGroupQuestions">
											<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(entryID, thisgroup, dsGroupQuestions.iQuestionId, i)>
												<td width="dsGroupQuestions.cColSize">#dsActiveEntry#  #dsGroupQuestions.posttitle#</td>
											</cfloop>
										</cfif>
									</tr>
								</cfloop>
						</table>
					</td>
				</tr>			
			</cfloop>

		</table>
	</cfoutput>		

	</body>
</html>
 