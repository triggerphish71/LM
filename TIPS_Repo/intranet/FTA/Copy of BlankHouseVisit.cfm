
<cfparam name="dtMarAuditDate" default="">
<cfparam name="thisgroup" default="">
<cfparam name="rolename" default="">
<cfparam name="Page" default="">
<cfparam name="userid" default="">
<cfparam name="role" default="">
<cfparam name="userfullname" default="">

<cfif IsDefined("url.userRole") >
	<cfif (url.userRole is "RDO")   >
		<cfset userrole = "OPS">
	<cfelseif (url.userRole is "OPS")   >
		<cfset userrole = "OPS">		
	<cfelseif 	url.userRole is "RDSM"   >
		<cfset userrole = "SLS">	
	<cfelseif 	url.userRole is "CSS"   >
		<cfset userrole = "SLS">		
	<cfelseif 	url.userRole is "RDQCS" >
		<cfset userrole = "CLN">
	<cfelse>
	You do not have access to enter House Visit Reports.
	<cfabort>
	</cfif>
		<cfset rolename = url.userRole>		
<cfelse>
You do not have access to enter House Visit Reports. 

<cfabort>
</cfif> 

<!--- <cfif IsDefined("session.role") >
	<cfif (session.userrole is "OPS")   >
		<cfset userrole = "OPS">
	<cfelseif 	session.userrole is "SLS"   >
		<cfset userrole = "SLS">	
	<cfelseif 	session.userrole is "CLN" >
		<cfset userrole = "CLN">
	<cfelse >		
		<cfset userrole = "OPS">
	</cfif>
<cfelseif IsDefined("rolename")>
	<cfif (rolename  is "RDO") or (rolename is "OPS") >
		<cfset userrole = "OPS">
	<cfelseif 	 (rolename  is "RDSM") or (rolename is "CSS") >
		<cfset userrole = "SLS">	
	<cfelseif 	 (rolename  is "RDQCS") >
		<cfset userrole = "CLN">
	<cfelse >		
		<cfset userrole = "OPS">
	</cfif>

<cfelse>	
	<cfset userrole = "OPS">
</cfif> --->

			<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
			<cfset groupColor = "cdcdcd">
			<cfset freezeColor = "f5f5f5">
			<cfset toolbarColor = "d6d6ab">
			<cfset dsGroups = helperObj.FetchHouseVisitGroupsII(rolename)>
			<cfset dsRoles = helperObj.FetchHouseVisitRoles()>
			<cfset dsAuthentication = helperObj.FetchHouseVisitAuthentication()>
	 		<cfset dsQuestionRoles = helperObj.FetchHouseVisitQuestionRoles()>  
	 		<cfset dsUserRole = helperObj.FetchHouseVisitRoleByTitle(dsRoles, dsAuthentication, userRole)>
			<cfset dsGroups = helperObj.FetchHouseVisitGroupsII(rolename)>
<!--- <cfdocument format="PDF"> --->

<cfparam name="userrole" default=""><body onLoad="window.print()">
	<div style="width:750px">
		<table  >
			<cfoutput>
	    <!--- <cfdocumentitem  type = "header">  --->
   		
				<input type="hidden"  name="EntryUserId" 		id="hdnEntryUserId" 		value="#userId#" />
				<input type="hidden"  name="EntryuserRole" 		id="hdnEntryuserRole" 		value="#Role#" />
				<input type="hidden"  name="EntryuserFullName" 	id="hdnEntryuserFullName" 	value="#userFullName#" />
				<input type="hidden"  name="hdnrolename" 	id="hdnrolename" 	value="#rolename#" />
				<cfset dsRoleID = helperObj.FetchHouseVisitRoleID(rolename)>
				 <input type="hidden"  name="userRoleID" 	id="hdnuserRoleID" 	value="#dsRoleID.iRoleID#" /> 
				<tr>
					<td     align="center" bgcolor="#groupColor#" style="font-family: Tahoma; font-weight: bold;">
						<cfswitch expression="#userrole#"> 
							<cfcase value="OPS">Create New House Visit - Operations</cfcase> 
							<cfcase value="SLS">Create New House Visit - Sales</cfcase> 
							<cfcase value="CLN">Create New House Visit - Clinical</cfcase> 
							<cfdefaultcase>Create New House Visit #userrole#  -  ROLE: #rolename#</cfdefaultcase> 
						</cfswitch>
					</td>
				</tr>
			<!---  </cfdocumentitem> --->
				<cfloop query="dsGroups" >
					<cfset thisgroup = dsGroups.iGroupId>
					<cfset maxrep = #dsGroups.indexmax#> 
					<cfset indexname  = #Trim("dsGroups.indexname")# >
					<tr>
						<td  >
						<table  id="#trim(dsGroups.cGroupName)#"  width="90%"   >
						
							<tr style=" background-color: #groupcolor#;">
								<th colspan="5" style="text-align:left"; font-weight:"100"; width="660px";> #dsGroups.iGroupId#.  #dsGroups.cTextHeader#</th>
							</tr>
								<cfset dsGroupQuestionsHdr = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
								<tr>
									<cfloop query="dsGroupQuestionsHdr">
										<th style="text-align:left"  >#dsGroupQuestionsHdr.cQuestion#</th>
									</cfloop>					
								</tr>							
								<cfif dsGroups.IGROUPID is 18 >
									<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
									<TR>
										<td style="text-align:left"><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# --->
											<textarea name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" rows="#dsGroupQuestions.cRowSize#" cols="#dsGroupQuestions.cColSize#"> </textarea>
										</td>	
									</TR>
								<cfelseif dsGroups.IGROUPID is 1>
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
										<tr  style=" background-color: ##ffffff;" >
											<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
												<cfloop query="dsGroupQuestions">
												 <cfif dsGroupQuestions.dropdown is not "">
								 					<cfset dshouseposition = helperObj.qryHousePosition()>
													<td><cfloop query="dshouseposition" >
															#cHousePosition#<br/>
														</cfloop>
														
													</td>
												
													<cfelse>
													<td style="text-align:left" title="#dsGroupQuestions.cQuestion#" ><input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="" size="#dsGroupQuestions.cColSize#"  onBlur="#trim(dsGroupQuestions.cOnChange)#"   style="text-align:left"; /></td>
													</cfif>
												</cfloop>
											 
										</tr>
									</cfloop>
								<cfELSEif dsGroups.IGROUPID is 5>
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
										<tr  style=" background-color: ##ffffff;" >
											<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
												<cfloop query="dsGroupQuestions">
												 <cfif dsGroupQuestions.dropdown is not "">
								 					<cfset dshouseTitle = helperObj.qryHouseTitle()>
													<td> 
														<cfloop query="dshouseTitle" >
															 #cHousetitle#<br/> 
														</cfloop>
														 
													</td>
												
													<cfelse>
													<td style="text-align:left" title="#dsGroupQuestions.cQuestion#" ><input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="" size="#dsGroupQuestions.cColSize#"  onBlur="#trim(dsGroupQuestions.cOnChange)#"   style="text-align:left"; /></td>
													</cfif>
												</cfloop>
											 
										</tr>
									</cfloop>
								<cfELSEif dsGroups.IGROUPID is 16>
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
										<tr  style=" background-color: ##ffffff;" >
											<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
												<cfloop query="dsGroupQuestions">
												<cfif dsGroupQuestions.dropdown is not "">
								 					<cfset dshouseTask = helperObj.qryHouseTask()>
													<td> 
														<cfloop query="dshouseTask" >
															 #ctasksheetdayrange#<br/> 
														</cfloop>
														 
													</td>
												<cfelse>
														<td style="text-align:left" title="#dsGroupQuestions.cQuestion#" ><input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="" size="#dsGroupQuestions.cColSize#"  onBlur="#trim(dsGroupQuestions.cOnChange)#"   style="text-align:left"; /></td>
												</cfif>
												</cfloop>
										</tr>
									</cfloop>
								<cfELSEif dsGroups.IGROUPID is 6>
									<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
									<TR>
										<td style="text-align:left"><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# --->
											<textarea name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" rows="#dsGroupQuestions.cRowSize#" cols="#dsGroupQuestions.cColSize#"> </textarea>
										</td>	
									</TR>
									</cfloop>									
								<cfelseif  dsGroups.IGROUPID is 7>
									<cfset i = 1>
									<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
									<TR>
										<td style="text-align:left"><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# --->
											<input  type="radio"	name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="Y" size="#dsGroupQuestions.cColSize#"     style="text-align:left"; />YES<br/> 									
											<input  type="radio"	name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="N" size="#dsGroupQuestions.cColSize#"    style="text-align:left"; />No
										</td>										
									</TR>	

								<cfelse>
								<cfset maxrep = #dsGroups.indexmax#> 
								<cfset indexname  = #Trim("dsGroups.indexname")# >
								<cfset i = 0>
								<input type="hidden" name="#trim(indexname)#" value="#maxrep#" id="id#Trim(dsGroups.indexname)#">
								<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
									<cfset i = i + 1>
									<tr  style=" background-color: ##ffffff;" >
										<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
										<!--- <INPUT type="hidden" value="#dsGroupQuestions.iQuestionId#" name="QuestionID#trim(dsGroupQuestions.cIDName)##i#"> --->
										<!--- <INPUT type="hidden" value="#dsGroups.iGroupId#" name="GroupID#trim(dsGroupQuestions.cIDName)##i#"> --->
										<cfif dsGroupQuestions.cRowSize is not "">
											<td style="text-align:left"><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# ---><textarea name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" rows="#dsGroupQuestions.cRowSize#" cols="#dsGroupQuestions.cColSize#"> </textarea></td>		 
										
										<cfelseif dsGroupQuestions.cColSize is 1>
										<td style="text-align:left"><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# --->
											<input  type="radio"	name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="Y" size="#dsGroupQuestions.cColSize#"     style="text-align:left"; />YES<br/> 									
											<input  type="radio"	name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="N" size="#dsGroupQuestions.cColSize#"    style="text-align:left"; />No
										</td>														
										
										<cfelseif dsGroupQuestions.cIncludeDate is "Y">
											<td><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# --->
												<input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="idMarAuditDate" value="#DateFormat(Now(), 'mm/dd/yyyy')#" onBlur="showAuditDate()" >
												<a onClick="show_calendar2('document.frmHouseVisitOpEntry.dtMarAuditDate',document.getElementById('dtMarAuditDate').value,'dtMarAuditDate');"> 
												<img src="../global/Calendar/calendar.gif" alt="Calendar" width="20" height="20" border="0" align="middle" style="" id="Cal" name="Cal"></a>
												<input type="hidden" name="DayOfMonth" id="idDayOfMonth" value=""> 
											</td>
										
										<cfelse>
											<cfloop query="dsGroupQuestions">
												 <td style="text-align:left"><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i#  #dsGroupQuestions.cQuestion# ---><input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value=""    onChange="#trim(dsGroupQuestions.cOnChange)#"  style="text-align:left"; />  #dsGroupQuestions.posttitle#</td>
											</cfloop>
										</cfif>
									</tr>
								</cfloop>
								</cfif>
						</table>
					</td>
				</tr>			
			</cfloop>
			</cfoutput>
		
		</table>
	</div>	
	</body>
<!--- 	</cfdocument> --->		