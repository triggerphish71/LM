<!----------------------------------------------------------------------------------------------|
| DESCRIPTION                                                                                 	|
|-----------------------------------------------------------------------------------------------|
|                                                                                             	|
|-----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                           	|
|-----------------------------------------------------------------------------------------------|
|  none                                                                                       	|
|-----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                    	|
|-----------------------------------------------------------------------------------------------|
|  none                                                                                       	|
|-----------------------------------------------------------------------------------------------|
| HISTORY                                                                                     	|
|-----------------------------------------------------------------------------------------------|
| Author    | Date       | 	Description                                                       	|
|-----------|------------|----------------------------------------------------------------------|
| ranklam   | 2/16/2007  |	Created                                                          	|
|-----------|------------|----------------------------------------------------------------------|
| jcruz		| 9/27/2008  |	Modified as part of PROJECT 12392. Modifications include the		|
|						 	addition of a new case statement in the New Assessment section		|
|						 	as well as changes in the View Assessment section					|
-------------------------------------------------------------------------------------------------
| jcruz		| 03/17/2009 | Modified NewAssessment function so it includes an assessment type   	|
|  			|			 | "FromStar" that allows the creation of a new assessment for any     	|
|			|			 | resident moved via the new STAR Applications. Project 18650		 	|
------------------------------------------------------------------------------------------------|
| Sathya    |02/18/2010  | Added the link to ScriptFiles\js_ShowCategoryNotes.cfm               |
|           |            | as per project 41315-B for the display for category notes.           |
------------------------------------------------------------------------------------------------>
<!--- include TIPS header --->

<link  rel="stylesheet" href="Styles\style.css">
<!--- default fuse --->
<cfparam name="fuse" default="assessmentMain">

<cfswitch expression="#fuse#">
	<!--- include all the assessmentmain stuff here also --->
	<cfcase value="reports">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> :: <a href=""index.cfm?fuse=reports"" class=""breadcrumbs"">Assessment Tool Reports</a>">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_Reports.cfm">
	</cfcase>
	<cfcase value="printReports">
		<cfinclude template="DisplayFiles\dsp_PrintReports.cfm">
	</cfcase>
	
	<cfcase value="assessmentToolAdministration">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> :: <a href=""index.cfm?fuse=assessmentToolAdministration"" class=""breadcrumbs"">Administration</a>">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_Administration.cfm">
	</cfcase>
	
	<cfcase value="editAssessmentTools">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> :: <a href=""index.cfm?fuse=assessmentToolAdministration"" class=""breadcrumbs"">Administration</a>">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_EditAssessmentTool.cfm">
	</cfcase>
	
	<cfcase value="editServiceCategories">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> :: <a href=""index.cfm?fuse=assessmentToolAdministration"" class=""breadcrumbs"">Administration</a>">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_EditServiceCategories.cfm">
	</cfcase>
	
	<cfcase value="editServices">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> :: <a href=""index.cfm?fuse=assessmentToolAdministration"" class=""breadcrumbs"">Administration</a>">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_EditService.cfm">
	</cfcase>
	
	<cfcase value="editSubService">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> :: <a href=""index.cfm?fuse=assessmentToolAdministration"" class=""breadcrumbs"">Administration</a>">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_EditSubService.cfm">
	</cfcase>
	
	<cfcase value="processEditAssessmentTool">
		<cfinclude template="ActionFiles\act_EditAssessmentTool.cfm">
	</cfcase>
	
	<cfcase value="processEditServiceCategories">
		<cfinclude template="ActionFiles\act_EditServiceCategory.cfm">
	</cfcase>
	
	<cfcase value="processEditService">
		<cfinclude template="ActionFiles\act_EditService.cfm">
	</cfcase>
	
	<cfcase value="processEditSubService">
		<cfinclude template="ActionFiles\act_EditSubService.cfm">
	</cfcase>
	
	<cfcase value="deleteService">
		<cfinclude template="ActionFiles\act_DeleteService.cfm">
	</cfcase>
	
	<cfcase value="deleteSubService">
		<cfinclude template="ActionFiles\act_DeleteSubService.cfm">
	</cfcase>
	
	<cfcase value="deleteServiceCategory">
		<cfinclude template="ActionFiles\act_DeleteServiceCategory.cfm">
	</cfcase>
	
	<cfcase value="activateAssessment">
		<cfinclude template="ActionFiles\act_GetAssessment.cfm">
		<cfinclude template="ActionFiles\act_ActivateAssessment.cfm">
		<cfinclude template="ActionFiles\act_GetAssessmentsForHouse.cfm">
		<cfinclude template="ActionFiles\act_GetInquiryAssessmentsForHouse.cfm">
		<cfinclude template="ScriptFiles\js_TrMouseOver.cfm">
		<cfinclude template="ScriptFiles\js_ShowArea.cfm">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a>">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_AssessmentMain.cfm">
	</cfcase>
	
	<cfcase value="activateAssessmentWithoutBilling">
		<cfinclude template="ActionFiles\act_GetAssessment.cfm">
		<cfinclude template="ActionFiles\act_ActivateAssessmentWithoutBilling.cfm">
		<cfinclude template="ActionFiles\act_GetAssessmentsForHouse.cfm">
		<cfinclude template="ActionFiles\act_GetInquiryAssessmentsForHouse.cfm">
		<cfinclude template="ScriptFiles\js_TrMouseOver.cfm">
		<cfinclude template="ScriptFiles\js_ShowArea.cfm">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a>">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_AssessmentMain.cfm">
	</cfcase>
	<cfcase value="assessmentMain">
		<cfinclude template="ActionFiles\act_GetAssessmentsForHouse.cfm">
		<cfinclude template="ActionFiles\act_GetInquiryAssessmentsForHouse.cfm">
		<cfinclude template="ScriptFiles\js_TrMouseOver.cfm">
		<cfinclude template="ScriptFiles\js_ShowArea.cfm">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a>">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_AssessmentMain.cfm">
	</cfcase>
	<cfcase value="assessmentMainMoveOuts">
		<cfinclude template="ActionFiles\act_GetMovedOutAssessmentsForHouse.cfm">
		<cfinclude template="ScriptFiles\js_TrMouseOver.cfm">
		<cfinclude template="ScriptFiles\js_ShowArea.cfm">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a>">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_AssessmentMain.cfm">
	</cfcase>
	<cfcase value="printAssessment">
		<cfinclude template="DisplayFiles\dsp_PrintAssessment.cfm">
	</cfcase>
<!--- Modified by Jaime Cruz as part of PROJECT 12392. Change allows viewing of assessment data in a View Assessment page instead of the New Assessment page as was previously done. --->
<!--- 02/17/2010 Sathya js_ShowCategoryNotes.cfm as part of project 41315-B --->
	<cfcase value="viewAssessment">
		<cfinclude template="ActionFiles\act_GetAssessment.cfm">
		<cfinclude template="ActionFiles\act_GetAllTools.cfm">
		<cfinclude template="ActionFiles\act_GetReviewTypes.cfm">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Assessment.GetTenant().GetName()# Assessment">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ChangeDate.cfm">
		<cfinclude template="ScriptFiles\js_SubmitAssessment.cfm">
		<cfinclude template="ScriptFiles\js_DisableAll.cfm">
		<cfinclude template="ScriptFiles\js_ShowNotes.cfm">
		<!--- 02/17/2010 Sathya js_ShowCategoryNotes.cfm as part of project 41315-B --->
		<cfinclude template="ScriptFiles\js_ShowCategoryNotes.cfm"> 
		 <!--- This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code) --->
		<cfinclude template="ScriptFiles\js_Highlight.cfm">
		<cfinclude template="ScriptFiles\js_ResetLevel.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="ScriptFiles\js_SelectOption.cfm">
		<cfinclude template="ScriptFiles\js_EnableParent.cfm">
		<cfinclude template="ScriptFiles\js_CalculatePoints.cfm">
		<cfinclude template="ScriptFiles\js_GetLevel.cfm">
		<cfinclude template="ScriptFiles\js_DisableAllServices.cfm">
		<cfinclude template="ScriptFiles\js_DisableSubServices.cfm">
		<cfinclude template="ScriptFiles\js_ShowTool.cfm">
		<cfinclude template="ScriptFiles\js_LoadAssessment.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_ViewAssessment.cfm">
		<cfinclude template="ScriptFiles\js_PointsScroll.cfm">
		<cfif Assessment.GetIsFinalized()>
		<cfinclude template="ScriptFiles\js_ActivateAssessment.cfm">
		</cfif>
	</cfcase>
	<cfcase value="saveAssessment">
		<cfset finalize = false>
		<cfinclude template="ActionFiles\act_GetAssessment.cfm">
		<cfinclude template="ActionFiles\act_SaveAssessment.cfm">
		<cfinclude template="ActionFiles\act_GetAssessmentsForHouse.cfm">
		<cfinclude template="ActionFiles\act_GetInquiryAssessmentsForHouse.cfm">
		<cfinclude template="ScriptFiles\js_TrMouseOver.cfm">
		<cfinclude template="ScriptFiles\js_ShowArea.cfm">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a>">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_AssessmentMain.cfm">
	</cfcase>
	<cfcase value="finalizeAssessment">
		<cfset finalize = true>
		<cfinclude template="ActionFiles\act_GetAssessment.cfm">
		<cfinclude template="ActionFiles\act_SaveAssessment.cfm">
		<cfinclude template="ActionFiles\act_GetAssessmentsForHouse.cfm">
		<cfinclude template="ActionFiles\act_GetInquiryAssessmentsForHouse.cfm">
		<cfinclude template="ScriptFiles\js_TrMouseOver.cfm">
		<cfinclude template="ScriptFiles\js_ShowArea.cfm">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a>">
		<cfinclude template="DisplayFiles\dsp_Header.cfm">
		<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles\dsp_AssessmentMain.cfm">
	</cfcase>
	<!--- Modified by Jaime Cruz as part of PROJECT 12392. Change allows use of previous assessment data when creating a new assessment as well as the entry of Service Plan data. --->
	<!--- 02/17/2010 Sathya js_ShowCategoryNotes.cfm as part of project 41315-B --->
	<cfcase value="newAssessment">
		<cfif assessmentType eq "resident">
			<cfinclude template="ActionFiles\act_GetResident.cfm">
			<cfinclude template="ActionFiles\act_GetTenant.cfm">
			<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Resident.GetName()# : New Assessment">
			<cfparam name="assessmentType" default="resident">
			<cfparam name="assessmentId" default="#Resident.GetAssessmentId()#">
	 		<cfinclude template="ActionFiles\act_GetServicePlan.cfm">
			<cfinclude template="ActionFiles\act_GetAllTools.cfm">
			<cfinclude template="ActionFiles\act_GetReviewTypes.cfm">
			<cfinclude template="DisplayFiles\dsp_Header.cfm">
			<cfinclude template="ScriptFiles\js_ChangeDate.cfm">
			<cfinclude template="ScriptFiles\js_SubmitAssessment.cfm">
			<cfinclude template="ScriptFiles\js_ShowNotes.cfm">
			<!--- 02/17/2010 Sathya js_ShowCategoryNotes.cfm as part of project 41315-B --->
		    <cfinclude template="ScriptFiles\js_ShowCategoryNotes.cfm">
		    <!--- This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code) --->
			<cfinclude template="ScriptFiles\js_Highlight.cfm">
			<cfinclude template="ScriptFiles\js_ResetLevel.cfm">
			<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
			<cfinclude template="ScriptFiles\js_SelectOption.cfm">
			<cfinclude template="ScriptFiles\js_EnableParent.cfm">
			<cfinclude template="ScriptFiles\js_CalculatePoints.cfm">
			<cfinclude template="ScriptFiles\js_GetLevel.cfm">
			<cfinclude template="ScriptFiles\js_DisableAllServices.cfm">
			<cfinclude template="ScriptFiles\js_DisableSubServices.cfm">
			<cfinclude template="ScriptFiles\js_ShowTool.cfm">
			<!--- 02/23/2010 Sathya commented this as part of project 41315-B --->
			<!--- <cfinclude template="ScriptFiles\js_LoadAssessment.cfm"> --->
			 <!--- This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code) --->
			<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
			<cfinclude template="DisplayFiles\dsp_NewAssessment.cfm">
			<cfinclude template="ScriptFiles\js_PointsScroll.cfm">
		<!--- 03/17/2009 - Modified by Jaime Cruz as part of project 18650. Added FromStar section to allow new assessments for all those moved in via the new STAR application. --->	
		<cfelseif assessmentType eq "FromStar">
			<cfinclude template="ActionFiles\act_GetTenant.cfm">
			<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Tenant.GetName()# : New Assessment">		
			<cfparam name="assessmentType" default="tenant">
			<cfparam name="assessmentId" default="#Tenant.GetAssessmentId()#">
			<cfinclude template="ActionFiles\act_GetAssessment.cfm">
	 		<cfinclude template="ActionFiles\act_GetServicePlan.cfm">
			<cfinclude template="ActionFiles\act_GetAllTools.cfm">
			<cfinclude template="ActionFiles\act_GetReviewTypes.cfm">
			<cfinclude template="DisplayFiles\dsp_Header.cfm">
			<cfinclude template="ScriptFiles\js_ChangeDate.cfm">
			<cfinclude template="ScriptFiles\js_SubmitAssessment.cfm">
			<cfinclude template="ScriptFiles\js_ShowNotes.cfm"> 
			<!--- 02/17/2010 Sathya js_ShowCategoryNotes.cfm as part of project 41315-B --->
		     <cfinclude template="ScriptFiles\js_ShowCategoryNotes.cfm">
		      <!--- This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code) --->
			<cfinclude template="ScriptFiles\js_Highlight.cfm">
			<cfinclude template="ScriptFiles\js_ResetLevel.cfm">
			<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
			<cfinclude template="ScriptFiles\js_SelectOption.cfm">
			<cfinclude template="ScriptFiles\js_EnableParent.cfm">
			<cfinclude template="ScriptFiles\js_CalculatePoints.cfm">
			<cfinclude template="ScriptFiles\js_GetLevel.cfm">
			<cfinclude template="ScriptFiles\js_DisableAllServices.cfm">
			<cfinclude template="ScriptFiles\js_DisableSubServices.cfm">
			<cfinclude template="ScriptFiles\js_ShowTool.cfm">
			<cfinclude template="ScriptFiles\js_LoadNotes.cfm">
			<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
			<cfinclude template="DisplayFiles\dsp_NewAssessment.cfm">
			<cfinclude template="ScriptFiles\js_PointsScroll.cfm">
		<cfelseif assessmentType eq "FromStarInquiry">
			<cfinclude template="ActionFiles\act_GetTenant.cfm">
			<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Tenant.GetName()# : New Assessment">		
			<cfparam name="assessmentType" default="tenant">
			<cfparam name="assessmentId" default="#Tenant.GetAssessmentId()#">
	 		<cfinclude template="ActionFiles\act_GetServicePlan.cfm">
			<cfinclude template="ActionFiles\act_GetAllTools.cfm">
			<cfinclude template="ActionFiles\act_GetReviewTypes.cfm">
			<cfinclude template="DisplayFiles\dsp_Header.cfm">
			<cfinclude template="ScriptFiles\js_ChangeDate.cfm">
			<cfinclude template="ScriptFiles\js_SubmitAssessment.cfm">
			<cfinclude template="ScriptFiles\js_ShowNotes.cfm"> 
			<!--- 02/17/2010 Sathya js_ShowCategoryNotes.cfm as part of project 41315-B --->
		   <cfinclude template="ScriptFiles\js_ShowCategoryNotes.cfm"> 
		   <!--- This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code) --->
			<cfinclude template="ScriptFiles\js_Highlight.cfm">
			<cfinclude template="ScriptFiles\js_ResetLevel.cfm">
			<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
			<cfinclude template="ScriptFiles\js_SelectOption.cfm">
			<cfinclude template="ScriptFiles\js_EnableParent.cfm">
			<cfinclude template="ScriptFiles\js_CalculatePoints.cfm">
			<cfinclude template="ScriptFiles\js_GetLevel.cfm">
			<cfinclude template="ScriptFiles\js_DisableAllServices.cfm">
			<cfinclude template="ScriptFiles\js_DisableSubServices.cfm">
			<cfinclude template="ScriptFiles\js_ShowTool.cfm">
			<!--- 02/23/2010 Sathya commented this as part of project 41315-B --->
			<!--- <cfinclude template="ScriptFiles\js_LoadNotes.cfm"> --->
			 <!--- This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code) --->
			<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
			<cfinclude template="DisplayFiles\dsp_NewAssessment.cfm">
			<cfinclude template="ScriptFiles\js_PointsScroll.cfm">
		<cfelse>
			<cfinclude template="ActionFiles\act_GetTenant.cfm">
			<cfinclude template="ActionFiles\act_GetResident.cfm">
			<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Tenant.GetName()# : New Assessment">
			<cfparam name="assessmentType" default="tenant">
			<cfparam name="assessmentId" default="#Tenant.GetAssessmentId()#">
			<cfinclude template="ActionFiles\act_GetAssessment.cfm">
	 		<cfinclude template="ActionFiles\act_GetServicePlan.cfm">
			<cfinclude template="ActionFiles\act_GetAllTools.cfm">
			<cfinclude template="ActionFiles\act_GetReviewTypes.cfm">
			<cfinclude template="DisplayFiles\dsp_Header.cfm">
			<cfinclude template="ScriptFiles\js_ChangeDate.cfm">
			<cfinclude template="ScriptFiles\js_SubmitAssessment.cfm">
			<cfinclude template="ScriptFiles\js_ShowNotes.cfm"> 
			<!--- 02/17/2010 Sathya js_ShowCategoryNotes.cfm as part of project 41315-B --->
		   <cfinclude template="ScriptFiles\js_ShowCategoryNotes.cfm"> 
		    <!--- This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code) --->
			<cfinclude template="ScriptFiles\js_Highlight.cfm">
			<cfinclude template="ScriptFiles\js_ResetLevel.cfm">
			<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
			<cfinclude template="ScriptFiles\js_SelectOption.cfm">
			<cfinclude template="ScriptFiles\js_EnableParent.cfm">
			<cfinclude template="ScriptFiles\js_CalculatePoints.cfm">
			<cfinclude template="ScriptFiles\js_GetLevel.cfm">
			<cfinclude template="ScriptFiles\js_DisableAllServices.cfm">
			<cfinclude template="ScriptFiles\js_DisableSubServices.cfm">
			<cfinclude template="ScriptFiles\js_ShowTool.cfm">
			<cfinclude template="ScriptFiles\js_LoadNotes.cfm">
			<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
			<cfinclude template="DisplayFiles\dsp_NewAssessment.cfm">
			<cfinclude template="ScriptFiles\js_PointsScroll.cfm">
		</cfif>
	</cfcase>
	<cfcase value="addNewAssessment">
		<cfinclude template="ActionFiles\act_AddNewAssessment.cfm">
	</cfcase>
</cfswitch>