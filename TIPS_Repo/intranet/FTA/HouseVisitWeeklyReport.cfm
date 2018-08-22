<cfset Page = "Edit House Visit">
 
 <cfparam name="rolename" default="">
 

	<!--- COLORS --->
	<cfset groupColor = "cdcdcd">
	<cfset freezeColor = "f5f5f5">
	<cfset toolbarColor = "d6d6ab">
	<cfset spellCheckBgColor = "ebebeb">
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
		<head>
		<cfoutput>
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
			
<!--- 			<cfif isDefined("url.iHouse_ID")>
				<cfset houseId = #url.iHouse_ID#>
			</cfif> --->
			
<!--- 			<cfif isDefined("url.SubAccount")>
				<cfset subAccount = #url.SubAccount#>
							
				<cfset dsHouseInfo = #helperObj.FetchHouseInfo(subAccount)#>
				<cfset unitId = #dsHouseInfo.unitId#>
				<!--- <cfset houseId = #dsHouseInfo.iHouse_ID#> --->
				<cfset HouseNumber = #trim(dsHouseInfo.EHSIFacilityID)#>
			</cfif> --->
			
<!--- 			<cfif isDefined("url.NumberOfMonths")>
				<cfset numberOfMonths = #url.NumberOfMonths#>
			<cfelse>
				<cfset numberOfMonths = 3>
			</cfif> --->
			 
<!--- 			<cfif isDefined("url.FromDateToUse")>
				<cfset fromDateToUse = #url.FromDateToUse#>
			<cfelse>
				<cfset fromDateToUse = #DateAdd("m", -3, dateToUse)#>
			</cfif>	 --->		
			
 

			
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
			</cfoutput>
		</head>
	<body >
	<table width="660px">
	<!--- <cfoutput> --->
	<!--- <div style="width:720px"> --->
	<!--- 	<cfinclude template="DisplayFiles/Header.cfm"> --->

	<!--- Data Source (Query) Objects --->
	<cfset dsHouseInfo = helperObj.qryDashboardHouseInfo()>	
	<!--- <cfdump var="dsHouseInfo" > --->
<!--- 	<cfset dsQuestions = helperObj.FetchHouseVisitDataII(entryId)> --->
<!--- 	<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryByIdII(entryId)> ---> 
<!--- 	<cfset dsRole = helperObj.FetchHouseVisitRoleII(dsQuestions.iRole)> --->

	<!--- <cfdump var="#dsRole#"> --->

<!--- 	<cfset roleName = dsRole.cRoleName> --->
 
<!--- 	<cfset dsQuestionRoles = helperObj.FetchHouseVisitQuestionRoles()> --->

<!--- 	<!--- Stores all of the active entry info. --->
<!--- 	<cfset entryDate = #DateFormat(dsActiveEntry.dtHouseVisit, "mm/dd/yyyy")#> --->
	<cfset userId = dsActiveEntry.cUserName> --->
<!--- 	<cfset userFullName = dsActiveEntry.cUserDisplayName>  --->
	
<!--- 	<cfset lastUpdate = DateFormat(dsActiveEntry.dtLastUpdate, "mm/dd/yyyy") & " " & TimeFormat(dsActiveEntry.dtLastUpdate, "hh:mm:ss tt")>
	<cfset created = DateFormat(dsActiveEntry.dtCreated, "mm/dd/yyyy") & " " & TimeFormat(dsActiveEntry.dtCreated, "hh:mm:ss tt")>
 --->	<!--- 			<input type="hidden"  name="EntryUserId" 			id="hdnEntryUserId" 		value="#url.iEntryUserId#" />
				<input type="hidden"  name="EntryuserRole" 			id="hdnEntryuserRole" 		value="#EntryuserRole#" />
				<input type="hidden"  name="EntryuserFullName" 		id="hdnEntryuserFullName" 	value="#url.EntryuserFullName#" />
				<input type="hidden"  name="hdnrolename" 			id="hdnrolename" 			value="#url.hdnrolename#" />
				<input type="hidden"  name="userRoleID" 			id="hdnuserRoleID" 			value="#url.userRoleID#" />
				<input type="hidden"  name="ihouse_ID" 			id="hdnhouseid" 			value="#url.ihouse_id#" /> --->
	<table id="tblEditEntry" cellspacing="0" cellpadding="1"    width="100%" >
 
					<cfoutput query="dsHouseInfo"  group="iDivisionId">	
						<cfset thishouseid = dsHouseInfo.iHouseId>
					<tr>
						<td>#cDivisionName#</td>
						<td>&nbsp;</td> 
						<td>&nbsp;</td>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
					</tr>
					<cfoutput  group="iRegionId">	

					<tr>
						<td>&nbsp;</td>
						<td>#cRegionName#</td> 
						<td>&nbsp;</td>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
					</tr>					
					<cfoutput >	

					<tr>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
						<td>#cHouseName#</td>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
					</tr>					
 					
 	 	<cfset dsEntryCount = helperObj.qryHouseVisitEntryByHouseByRDO(iHouseId)> 
 		<cfloop query="dsEntryCount" >
 
	<cfif (dsEntryCount.iRole is 1)   >
		<cfset rolename = "RDO">
		<cfset userrole = "OPS">
	<cfelseif (dsEntryCount.iRole is 2)   >
		<cfset rolename = "RDSM">
		<cfset userrole = "SLS">		
	<cfelseif 	dsEntryCount.iRole is 3   >
		<cfset rolename = "RDQCS">
		<cfset userrole = "CLN">	
	<cfelseif 	dsEntryCount.iRole is 11    >
		<cfset rolename = "CSS">
		<cfset userrole = "SLS">		
	<cfelseif 	dsEntryCount.iRole is  12  >
		<cfset rolename = "OPS">
		<cfset userrole = "OPS">
	<cfelseif 	dsEntryCount.iRole is  4  >
		<cfset rolename = "RDO">
		<cfset userrole = "OPS">
	<cfelse   >
		<cfset rolename = "Undefined">
		<cfset userrole = "Undefined">
 
	</cfif>

				

			<tr style="background-color:#toolbarColor#;">
				<th colspan="5" align="left">#rolename# #dateformat(dsEntryCount.dtCreated, "mm/dd/yyyy")# #cuserDisplayName#</th>
			</tr>
				<cfset dsGroups = helperObj.FetchHouseVisitGroupsII(rolename)>
				<cfset thisgroup = dsGroups.iGroupId>
<!--- 				<cfset dsEntries = helperObj.FetchHouseVisitAnswerCountII(dsEntryCount.iEntryId, #dsGroups.iGroupId#)>   									
				<cfif dsEntries is ""  >
				<cfset maxrep = 0> 
				<cfelse>
				<cfset maxrep = #dsEntries#> 
				</cfif> --->
				<cfset dsQuestions = helperObj.FetchHouseVisitDataII(dsEntryCount.iEntryId)>					
						<!--- <cfset maxrep = #dsEntryCount#> ---> 
				<cfloop query="dsGroups" >
					<cfset thisgroup = dsGroups.iGroupId>
						<cfset dsEntryries = helperObj.FetchHouseVisitAnswerCountII(dsEntryCount.iEntryId, #dsGroups.iGroupId#)> 									
						<cfif dsEntryries is ""  >
							<cfset maxrep = 0> 
						<cfelse>
							<cfset maxrep = #dsEntryries#> 
						</cfif>					
					<tr>
						<td  colspan="5" >
						<table  id="#trim(dsGroups.cGroupName)#"  width="100%"    >
						
							<tr style=" background-color: #groupcolor#;">
								<th colspan="5" style="text-align:left"; font-weight:"100"; width="660px"> #dsGroups.iGroupId#.  #dsGroups.cTextHeader#</th>
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
									<tr  style="border:none" >
										<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
										<cfif dsGroupQuestions.cRowSize is not "">
										<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(dsEntryCount.iEntryId, thisgroup, dsGroupQuestions.iQuestionId, i)>
											<td  colspan="5" style="text-align:left">#dsActiveEntry#</td>		 
										
										<cfelseif dsGroupQuestions.cColSize is 1>
											<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(dsEntryCount.iEntryId, thisgroup, dsGroupQuestions.iQuestionId, i)>
											<td style="text-align:left">
												<cfif #trim(dsActiveEntry)# is "Y">	YES	<cfelseif #trim(dsActiveEntry)# is "N">NO</cfif>
											</td>														
										
										<cfelseif dsGroupQuestions.cIncludeDate is "Y">
											<cfset dsActiveEntry = dateformat(helperObj.FetchHouseVisitEntryAnswersII(dsEntryCount.iEntryId, thisgroup, dsGroupQuestions.iQuestionId, i),"mm/dd/yyyy")>
											<td>#dsActiveEntry#</td>
										<cfelse> 
  											<cfloop query="dsGroupQuestions">
												<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(#dsEntryCount.iEntryId#, thisgroup, dsGroupQuestions.iQuestionId, i)>
												<td width="dsGroupQuestions.cColSize">#dsActiveEntry#  #dsGroupQuestions.posttitle#</td>
											</cfloop> 
										</cfif>
									</tr>
								</cfloop> 
						</table>
					</td>
				</tr>	 			
				</cfloop>
			</cfloop>
 
 	 	<cfset dsEntryCount = helperObj.qryHouseVisitEntryByHouseByRDSM(iHouseId)> 
 		<cfloop query="dsEntryCount" >
 
	<cfif (dsEntryCount.iRole is 1)   >
		<cfset rolename = "RDO">
		<cfset userrole = "OPS">
	<cfelseif (dsEntryCount.iRole is 2)   >
		<cfset rolename = "RDSM">
		<cfset userrole = "SLS">		
	<cfelseif 	dsEntryCount.iRole is 3   >
		<cfset rolename = "RDQCS">
		<cfset userrole = "CLN">	
	<cfelseif 	dsEntryCount.iRole is 11    >
		<cfset rolename = "CSS">
		<cfset userrole = "SLS">		
	<cfelseif 	dsEntryCount.iRole is  12  >
		<cfset rolename = "OPS">
		<cfset userrole = "OPS">
	<cfelseif 	dsEntryCount.iRole is  4  >
		<cfset rolename = "RDO">
		<cfset userrole = "OPS">
	<cfelse   >
		<cfset rolename = "Undefined">
		<cfset userrole = "Undefined">
 
	</cfif>

 
			<tr style="background-color:#toolbarColor#;">
				<th colspan="5" align="left">#rolename#  #dateformat(dsEntryCount.dtCreated, "mm/dd/yyyy")# #cuserDisplayName#</th>
			</tr>
				<cfset dsGroups = helperObj.FetchHouseVisitGroupsII(rolename)>
				<cfset thisgroup = dsGroups.iGroupId>
<!--- 				<cfset dsEntries = helperObj.FetchHouseVisitAnswerCountII(dsEntryCount.iEntryId, #dsGroups.iGroupId#)>   									
				<cfif dsEntries is ""  >
				<cfset maxrep = 0> 
				<cfelse>
				<cfset maxrep = #dsEntries#> 
				</cfif> --->
				<cfset dsQuestions = helperObj.FetchHouseVisitDataII(dsEntryCount.iEntryId)>					
						<!--- <cfset maxrep = #dsEntryCount#> ---> 
				<cfloop query="dsGroups" >
					<cfset thisgroup = dsGroups.iGroupId>
						<cfset dsEntryries = helperObj.FetchHouseVisitAnswerCountII(dsEntryCount.iEntryId, #dsGroups.iGroupId#)> 									
						<cfif dsEntryries is ""  >
							<cfset maxrep = 0> 
						<cfelse>
							<cfset maxrep = #dsEntryries#> 
						</cfif>					
					<tr>
						<td  colspan="5" >
						<table  id="#trim(dsGroups.cGroupName)#"  width="100%" >
						
							<tr style=" background-color: #groupcolor#;">
								<th colspan="5" style="text-align:left"; font-weight:"100"; width="660px"> #dsGroups.iGroupId#.  #dsGroups.cTextHeader#</th>
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
									<tr  style="border:none" >
										<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
										<cfif dsGroupQuestions.cRowSize is not "">
										<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(dsEntryCount.iEntryId, thisgroup, dsGroupQuestions.iQuestionId, i)>
											<td  colspan="5" style="text-align:left">#dsActiveEntry#</td>		 
										
										<cfelseif dsGroupQuestions.cColSize is 1>
											<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(dsEntryCount.iEntryId, thisgroup, dsGroupQuestions.iQuestionId, i)>
											<td style="text-align:left">
												<cfif #trim(dsActiveEntry)# is "Y">	YES	<cfelseif #trim(dsActiveEntry)# is "N">NO</cfif>
											</td>														
										
										<cfelseif dsGroupQuestions.cIncludeDate is "Y">
											<cfset dsActiveEntry = dateformat(helperObj.FetchHouseVisitEntryAnswersII(dsEntryCount.iEntryId, thisgroup, dsGroupQuestions.iQuestionId, i),"mm/dd/yyyy")>
											<td>#dsActiveEntry#</td>
										<cfelse> 
  											<cfloop query="dsGroupQuestions">
												<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(#dsEntryCount.iEntryId#, thisgroup, dsGroupQuestions.iQuestionId, i)>
												<td width="dsGroupQuestions.cColSize">#dsActiveEntry#  #dsGroupQuestions.posttitle#</td>
											</cfloop> 
										</cfif>
									</tr>
								</cfloop> 
						</table>
					</td>
				</tr>	 			
				</cfloop>
			</cfloop> 		

 
 	 	<cfset dsEntryCount = helperObj.qryHouseVisitEntryByHouseByRDQCS(iHouseId)> 
 		<cfloop query="dsEntryCount" >
 
	<cfif (dsEntryCount.iRole is 1)   >
		<cfset rolename = "RDO">
		<cfset userrole = "OPS">
	<cfelseif (dsEntryCount.iRole is 2)   >
		<cfset rolename = "RDSM">
		<cfset userrole = "SLS">		
	<cfelseif 	dsEntryCount.iRole is 3   >
		<cfset rolename = "RDQCS">
		<cfset userrole = "CLN">	
	<cfelseif 	dsEntryCount.iRole is 11    >
		<cfset rolename = "CSS">
		<cfset userrole = "SLS">		
	<cfelseif 	dsEntryCount.iRole is  12  >
		<cfset rolename = "OPS">
		<cfset userrole = "OPS">
	<cfelseif 	dsEntryCount.iRole is  4  >
		<cfset rolename = "RDO">
		<cfset userrole = "OPS">
	<cfelse   >
		<cfset rolename = "Undefined">
		<cfset userrole = "Undefined">
 
	</cfif>

			<tr style="background-color:#toolbarColor#;">
				<th colspan="5" align="left">#rolename#  #dateformat(dsEntryCount.dtCreated, "mm/dd/yyyy")# #cuserDisplayName#</th>
			</tr>
				<cfset dsGroups = helperObj.FetchHouseVisitGroupsII(rolename)>
				<cfset thisgroup = dsGroups.iGroupId>
<!--- 				<cfset dsEntries = helperObj.FetchHouseVisitAnswerCountII(dsEntryCount.iEntryId, #dsGroups.iGroupId#)>   									
				<cfif dsEntries is ""  >
				<cfset maxrep = 0> 
				<cfelse>
				<cfset maxrep = #dsEntries#> 
				</cfif> --->
				<cfset dsQuestions = helperObj.FetchHouseVisitDataII(dsEntryCount.iEntryId)>					
						<!--- <cfset maxrep = #dsEntryCount#> ---> 
				<cfloop query="dsGroups" >
					<cfset thisgroup = dsGroups.iGroupId>
						<cfset dsEntryries = helperObj.FetchHouseVisitAnswerCountII(dsEntryCount.iEntryId, #dsGroups.iGroupId#)> 									
						<cfif dsEntryries is ""  >
							<cfset maxrep = 0> 
						<cfelse>
							<cfset maxrep = #dsEntryries#> 
						</cfif>					
					<tr>
						<td  colspan="5" >
						<table  id="#trim(dsGroups.cGroupName)#"  width="100%"   >
						
							<tr style=" background-color: #groupcolor#;">
								<th colspan="5" style="text-align:left"; font-weight:"100"; width="660px"> #dsGroups.iGroupId#.  #dsGroups.cTextHeader#</th>
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
									<tr  style="border:none" >
										<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
										<cfif dsGroupQuestions.cRowSize is not "">
										<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(dsEntryCount.iEntryId, thisgroup, dsGroupQuestions.iQuestionId, i)>
											<td  colspan="5" style="text-align:left">#dsActiveEntry#</td>		 
										
										<cfelseif dsGroupQuestions.cColSize is 1>
											<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(dsEntryCount.iEntryId, thisgroup, dsGroupQuestions.iQuestionId, i)>
											<td style="text-align:left">
												<cfif #trim(dsActiveEntry)# is "Y">	YES	<cfelseif #trim(dsActiveEntry)# is "N">NO</cfif>
											</td>														
										
										<cfelseif dsGroupQuestions.cIncludeDate is "Y">
											<cfset dsActiveEntry = dateformat(helperObj.FetchHouseVisitEntryAnswersII(dsEntryCount.iEntryId, thisgroup, dsGroupQuestions.iQuestionId, i),"mm/dd/yyyy")>
											<td>#dsActiveEntry#</td>
										<cfelse> 
  											<cfloop query="dsGroupQuestions">
												<cfset dsActiveEntry = helperObj.FetchHouseVisitEntryAnswersII(#dsEntryCount.iEntryId#, thisgroup, dsGroupQuestions.iQuestionId, i)>
												<td width="dsGroupQuestions.cColSize">#dsActiveEntry#  #dsGroupQuestions.posttitle#</td>
											</cfloop> 
										</cfif>
									</tr>
								</cfloop> 
						</table>
					</td>
				</tr>	 			
				</cfloop>
			</cfloop> 				 				
					</cfoutput>					
					</cfoutput>
					</cfoutput>
				</table>
			</td>
		</tr>	
<!--- --->

		</table>
	<!--- </cfoutput>	 --->	
	<!--- </div> --->
	</body>
</html>
 