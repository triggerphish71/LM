
<cfset qapprovalcount = session.oApprovalServices.getApprovalCount(houseid=session.qSelectedHouse.iHouse_Id,acctPeriod=session.tipsmonth)>
<cfoutput>
<cfif fuse neq "assessmentMainMoveOuts">
	<table width="800">
		<tr>
			<td aligh="left"><span class="assessmentMainHeader">Inquiry Residents</span></td>
			<td align="right"><a href="index.cfm?fuse=assessmentMainMoveOuts" class="breadcrumbs">Show Moved Out Residents</a></td>
		</tr>
	</table>
</cfif>

<cfset Tenantlist = #valuelist(qapprovalcount.tenant_ID,",")#>


<!---<cfdump var="#InquiryArray#">--->
<cfif fuse neq "assessmentMainMoveOuts">
	<table class="assessmentMain" cellspacing="1" cellpadding="3">
		<tr>
			<th class="assessmentMain">Resident</th>
			<th class="assessmentMain">Assessments</th>
			<th class="assessmentMain">New</th>
		</tr>
		
		<cfset x = 1>
		<cfset tenantCount = 1>
		<cfset className = "assessmentMain">
		
		<cfloop from="1" to="#Arraylen(InquiryArray)#" index="i">	
			<!--- set the bg color --->
			<cfif tenantCount MOD 2 eq 1>
				<cfset className = "assessmentMain">
			<cfelse>
				<cfset className = "assessmentMainDark">
			</cfif>
			
			<cfif x eq 1>
			<tr onmouseout="TrOut(this,'#className#')" onmouseover="TrHover(this,'assessmentMainOver')">
				<td class="#className#" valign="top">#InquiryArray[i].Name#</td>
				<!--- this is a bit tricky --->
				<td class="#className#" valign="top">
			</cfif>
					<cfif InquiryArray[i].tool neq ''>
						<cfif x eq 1>
							<div>
								<span class="plusMinus">
								<!--- if the next assessment is for the same tenant give show the blus sign --->
								<cfif i lt ArrayLen(InquiryArray) AND InquiryArray[i].id eq InquiryArray[i + 1].id>
									<a href="javascript:ShowArea('Assessments_#InquiryArray[i].id#')" class="assessmentMain">+</a>
								</cfif>
								</span>
								<a href="index.cfm?fuse=viewAssessment&assessmentId=#InquiryArray[i].assessmentId#&assessmentType=resident" class="assessmentMain">#InquiryArray[i].tool# <cfif InquiryArray[i].IsFinalized><strong>Finalized</strong><cfelse>Open</cfif> <cfif InquiryArray[i].isBillingActive><strong class="assessmentMain">Active - (#DateFormat(InquiryArray[i].billingActiveDate,"mm/dd/yyyy")#)</strong></cfif><br>
								<span class="plusMinus"></span>Level #InquiryArray[i].level#  - #InquiryArray[i].points# Points<br>
								<span class="plusMinus"></span>#DateFormat(InquiryArray[i].reviewStartDate,"mm/dd/yyyy")# <cfif InquiryArray[i].reviewEndDate neq "1/1/1900">- #DateFormat(InquiryArray[i].reviewEndDate,"mm/dd/yyyy")#</cfif><br></a>
							</div>
						<cfelseif x eq 2>
							<span style="display:none" name="Assessments_#InquiryArray[i].id#" id="Assessments_#InquiryArray[i].id#">
							<cfif i lt ArrayLen(InquiryArray) AND (InquiryArray[i].id eq InquiryArray[i + 1].id OR x eq 2 AND InquiryArray[i].id neq InquiryArray[i + 1].id)>
								<span class="blackLine"><img src="Images\invisPix.gif" height="1"></span>
							<cfelseif i + 1 eq ArrayLen(InquiryArray) AND InquiryArray[i].id eq InquiryArray[i + 1].id>
								<span class="blackLine"><img src="Images\invisPix.gif" height="1"></span>
							</cfif>
						</cfif>
						<cfif x gt 1>
							<div>
								<a href="index.cfm?fuse=viewAssessment&assessmentId=#InquiryArray[i].assessmentId#&assessmentType=resident" class="assessmentMain">
								<span class="plusMinus"></span>#InquiryArray[i].tool# <cfif InquiryArray[i].IsFinalized><strong>Finalized</strong><cfelse>Open</cfif><br>
								<span class="plusMinus"></span>Level #InquiryArray[i].level#  - #InquiryArray[i].points# Points<br>
								<span class="plusMinus"></span>#DateFormat(InquiryArray[i].reviewStartDate,"mm/dd/yyyy")#<cfif InquiryArray[i].reviewEndDate neq "1/1/1900"> - #DateFormat(InquiryArray[i].reviewEndDate,"mm/dd/yyyy")#</cfif>
								</a>
							</div>
							<cfif i lt ArrayLen(InquiryArray) AND InquiryArray[i].id eq InquiryArray[i + 1].id>
								<span class="blackLine"><img src="Images\invisPix.gif" height="1"></span>
							</cfif>
						</cfif>
						<cfif i lt ArrayLen(InquiryArray) AND InquiryArray[i].id neq InquiryArray[i + 1].id and x gt 1>
							</span>
						</cfif>
					</cfif>
			<!--- 03/17/2009 - Modified by Jaime Cruz as part of project 18650. Using tenantid instead of id for conditional test to determine when to increase the x and tenantCount values. --->
			<cfif i lt ArrayLen(InquiryArray) AND InquiryArray[i].tenantid neq InquiryArray[i + 1].tenantid OR i eq ArrayLen(InquiryArray)>
				</td>
			<!--- 03/17/2009 - Modified by Jaime Cruz as part of project 18650. Added conditional test to determine how to display link for those moved in via the new STAR application. --->
			
			<cfif InquiryArray[i].id neq 0>
				<td class="#className#" valign="top"><a href="index.cfm?fuse=newAssessment&residentID=#InquiryArray[i].id#&tenantID=#InquiryArray[i].tenantid#&assessmentType=resident" class="assessmentMain">New</a></td>
			<cfelse>
				<td class="#className#" valign="top"><a href="index.cfm?fuse=newAssessment&tenantID=#InquiryArray[i].tenantid#&residentID=#InquiryArray[i].id#&assessmentType=fromstarinquiry" class="assessmentMain">New </a></td>
			</cfif>
		
			</tr>
			</cfif>
			<!--- 03/17/2009 - Modified by Jaime Cruz as part of project 18650. Using tenantid instead of id for conditional test to determine when to increase the x and tenantCount values. --->
			<cfif i lt ArrayLen(InquiryArray) AND InquiryArray[i].tenantid eq InquiryArray[i + 1].tenantid>
				<cfset x = x + 1>
			<cfelse>
				<cfset x = 1>
				<cfset tenantCount = tenantCount + 1>
			</cfif>
		</cfloop>
	</table>
</cfif>
<br>

<cfif fuse eq "assessmentMainMoveOuts">
	<table width="800">
		<tr>
			<td aligh="left"><span class="assessmentMainHeader">Tenants</span></td>
			<td align="right"><a href="index.cfm?fuse=assessmentMain" class="breadcrumbs">Show Curent Residents</a></td>
		</tr>
	</table>
<cfelse>
	<span class="assessmentMainHeader">Tenants</span>
</cfif>
<table class="assessmentMain" cellspacing="1" cellpadding="3">
	<tr>
		<th class="assessmentMain">Apartment</th>
		<th class="assessmentMain">Resident</th>
		<th class="assessmentMain">Assessments</th>
		<cfif fuse neq "assessmentMainMoveOuts">
			<th class="assessmentMain">New</th>
		<cfelse>
			<th class="assessmentMain">Move Out</th>
		</cfif>
	</tr>
	<cfset x = 1>
	<cfset tenantCount = 1>
	<cfset className = "assessmentMain">
	
	<cfloop from="1" to="#Arraylen(AssessmentArray)#" index="i">	
		<!--- set the bg color --->
		<cfif tenantCount MOD 2 eq 1>
			<cfset className = "assessmentMain">
		<cfelse>
			<cfset className = "assessmentMainDark">
		</cfif>
		
		<cfif x eq 1>
		<tr onmouseout="TrOut(this,'#className#')" onmouseover="TrHover(this,'assessmentMainOver')">
			<td class="#className#" valign="top">#AssessmentArray[i].apt#</td>
			<td class="#className#" valign="top">#AssessmentArray[i].Name#</td>
			<!--- this is a bit tricky --->
			<td class="#className#" valign="top">
		</cfif>
				<cfif AssessmentArray[i].tool neq ''>
					<cfif x eq 1>
						<div>
							<span class="plusMinus">
							<!--- if the next assessment is for the same tenant show the plus sign --->
							<cfif i lt ArrayLen(AssessmentArray) AND AssessmentArray[i].id eq AssessmentArray[i + 1].id>
								<a href="javascript:ShowArea('Assessments_#AssessmentArray[i].id#')" class="assessmentMain">+</a>
							</cfif>
							</span>
							<a href="index.cfm?fuse=viewAssessment&assessmentId=#AssessmentArray[i].assessmentId#&assessmentType=tenant" class="assessmentMain">#AssessmentArray[i].tool# <cfif AssessmentArray[i].IsFinalized><strong>Finalized</strong><cfelse>Open</cfif> <cfif AssessmentArray[i].isBillingActive><strong class="assessmentMain">Active - (#DateFormat(AssessmentArray[i].billingActiveDate,"mm/dd/yyyy")#)</strong></cfif><br>
							<span class="plusMinus"></span>Level #AssessmentArray[i].level#  - #AssessmentArray[i].points# Points<br>
							<span class="plusMinus"></span>#DateFormat(AssessmentArray[i].reviewStartDate,"mm/dd/yyyy")#<cfif AssessmentArray[i].reviewEndDate neq "1/1/1900"> - #DateFormat(AssessmentArray[i].reviewEndDate,"mm/dd/yyyy")#</cfif><br></a>
						</div>
					<cfelseif x eq 2>
						<span style="display:none" name="Assessments_#AssessmentArray[i].id#" id="Assessments_#AssessmentArray[i].id#">
						<cfif (i lt ArrayLen(AssessmentArray) AND AssessmentArray[i].id eq AssessmentArray[i + 1].id) OR (i lt ArrayLen(AssessmentArray) AND x eq 2 AND AssessmentArray[i].id neq AssessmentArray[i + 1].id)>
							<span class="blackLine"><img src="Images\invisPix.gif" height="1"></span>
						</cfif>
					</cfif>
					<cfif x gt 1>
						<div>
							<a href="index.cfm?fuse=viewAssessment&assessmentId=#AssessmentArray[i].assessmentId#&assessmentType=tenant" class="assessmentMain">
							<span class="plusMinus"></span>#AssessmentArray[i].tool# <cfif AssessmentArray[i].IsFinalized><strong>Finalized</strong><cfelse>Open</cfif><br>
							<span class="plusMinus"></span>Level #AssessmentArray[i].level#  - #AssessmentArray[i].points# Points<br>
							<span class="plusMinus"></span>#DateFormat(AssessmentArray[i].reviewStartDate,"mm/dd/yyyy")#<cfif AssessmentArray[i].reviewEndDate neq "1/1/1900"> - #DateFormat(AssessmentArray[i].reviewEndDate,"mm/dd/yyyy")#</cfif>
							</a>
						</div>
						<cfif i lt ArrayLen(AssessmentArray) AND AssessmentArray[i].id eq AssessmentArray[i + 1].id>
							<span class="blackLine"><img src="Images\invisPix.gif" height="1"></span>
						</cfif>
					</cfif>
					<cfif i lt ArrayLen(AssessmentArray) AND AssessmentArray[i].id neq AssessmentArray[i + 1].id and x gt 1>
						</span>
					</cfif>
				</cfif>

		<cfif i lt ArrayLen(AssessmentArray) AND AssessmentArray[i].id neq AssessmentArray[i + 1].id OR i eq ArrayLen(AssessmentArray)>
			</td>
			<cfif fuse neq "assessmentMainMoveOuts">
			<!--- 03/17/2009 - Modified by Jaime Cruz as part of project 18650. Added conditional test to determine how to display link for those moved in via the new STAR application. --->
			<cfif AssessmentArray[i].residentId neq 0>
		
				 <cfif ListFind(Tenantlist, "#AssessmentArray[i].id#")>
				   <td class="#className#" valign="top"><font color ="red"><b>Prior Assessment <br/>needs approval.</b></font></td> 
				  <cfelse>			 				
					<td class="#className#" valign="top"><a href="index.cfm?fuse=newAssessment&tenantId=#AssessmentArray[i].id#&residentId=#AssessmentArray[i].residentId#&assessmentType=tenant" class="assessmentMain"> New</a></td>			
				 </cfif>		
			 <cfelse>
			      <cfif ListFind(Tenantlist, "#AssessmentArray[i].id#")>
				    <td class="#className#" valign="top"><font color ="red"><b>Prior Assessment <br/>needs approval.</b></font></td> 
				  <cfelse>	
				    <td class="#className#" valign="top"><a href="index.cfm?fuse=newAssessment&tenantId=#AssessmentArray[i].id#&residentId=#AssessmentArray[i].residentId#&assessmentType=fromstar" class="assessmentMain">New</a></td>
				  </cfif>	
			 </cfif>
			<cfelse>
				<td class="#className#" valign="top" align="center">#DateFormat(AssessmentArray[i].dtMoveOut,"mm/dd/yyyy")#</td>
			</cfif>
		</tr>
		</cfif>
		
		<cfif i lt ArrayLen(AssessmentArray) AND AssessmentArray[i].id eq AssessmentArray[i + 1].id>
			<cfset x = x + 1>
		<cfelse>
			<cfset x = 1>
			<cfset tenantCount = tenantCount + 1>
		</cfif>
	</cfloop>
</table>

</cfoutput>