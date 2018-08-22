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
| gthota    |10/31/2012  | Added the links of new assessments                                   |
| gthota    | 11/27/2012 | added cfif condition for more regions                                |
| gthota    | 12/19/2012 | rool out all the regions for new assessment tool                     |
| gthota    | 2/28/2013 | added new page option for printAssessmentEnquiry assessment tool      |
| gthota    | 6/24/2013 | added new page option for printAssessment idaho houses report assessment tool      |
| gthota    | 2/2/2014 | 113458 - added new region names from existing once in assessment tool  |
|sfarmer    | 04/01/2014| 113458 added OR CheckRegion.OpsAreaName EQ 'Oregon'                   |
|           |           | OR CheckRegion.OpsAreaName EQ 'Eastern WA/Idaho'                      |
| sfarmer   | 01/02/2015| updated region (opsarea) names                                        |
| Gthota    |10/10/2017 |Added care plan assessment print code                                  |
------------------------------------------------------------------------------------------------>
<!--- include TIPS header --->
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<link  rel="stylesheet" href="Styles\style.css">
<!--- default fuse --->
<cfparam name="fuse" default="assessmentMain">
<!--- Project 88898 added for the region/House checking for new and old assessment --->
<cfquery name="CheckRegion" datasource="#Application.Datasource#">
        SELECT HouseLog.bIsPDClosed, House.iHouse_ID AS HouseId, House.cName AS HouseName ,House.cNumber ,House.cCity ,House.cStateCode AS StateCode
	,OpsArea.cName AS OpsAreaName ,Region.cName AS RegionName ,HouseLog.dtCurrentTipsMonth, TenantMissingItems.TenantWithMissingItems,House.iBondHouse
	FROM House
	INNER JOIN  OpsArea	ON  OpsArea.iOpsArea_ID = House.iOpsArea_ID and opsarea.dtrowdeleted is null
	INNER JOIN  Region	ON  Region.iRegion_ID = OpsArea.iRegion_ID and region.dtrowdeleted is null
	JOIN HouseLog ON House.iHouse_ID = HouseLog.iHouse_ID	
	LEFT JOIN TenantMissingItems ON TenantMissingItems.iHouse_id = House.iHouse_id		
		WHERE	
			House.dtRowDeleted IS NULL and House.cName ='#session.House.GetName()#'  <!---and Region.cName = 'Southern'--->
	ORDER BY House.cName 
 </cfquery>

<cfset assessmentRegionList ="Northern Ohio,Southern Ohio,Southern Indiana/Kentucky,Arizona,DFW,Northeast Texas,Iowa,Greater Wisconsin,Mt. Hood,Washington,Greater New Jersey,Southern Oregon,Pennsylvania,South Carolina,SouthEast,Southeast Texas,Greater Idaho,West Texas,Oregon,Eastern WA/Idaho,Oregon,Southern Indiana,Washington,North Texas,East Texas,West Texas,New Jersey,Wisconsin,Northern Ohio Michigan,Southern Ohio Indiana,Idaho Washington,Iowa Nebraska,Blue Ridge,Great Lakes,Mid-Atlantic,Florida,Great Plains,Georgia,Florida/Louisiana,Carolinas,Kansas/Oklahoma,Iowa/Nebraska,Northern IN/IL,Central Indiana">

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
		<cfif listFindNoCase(assessmentRegionList,checkregion.opsAreaName,",") GT 0>	
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
		<cfelse>
		    <cfinclude template="ActionFiles_OLD\act_GetAssessment.cfm">
			<cfinclude template="ActionFiles_OLD\act_ActivateAssessment.cfm">
			<cfinclude template="ActionFiles_OLD\act_GetAssessmentsForHouse.cfm">
			<cfinclude template="ActionFiles_OLD\act_GetInquiryAssessmentsForHouse.cfm">
			<cfinclude template="ScriptFiles_OLD\js_TrMouseOver.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ShowArea.cfm">
			<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a>">
			<cfinclude template="DisplayFiles_OLD\dsp_Header.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ShowMenu.cfm">
			<cfinclude template="DisplayFiles_OLD\dsp_Navigation.cfm">
			<cfinclude template="DisplayFiles_OLD\dsp_AssessmentMain.cfm">
		</cfif>	
	</cfcase>
	
	<cfcase value="activateAssessmentWithoutBilling">
		<cfif listFindNoCase(assessmentRegionList,checkregion.opsAreaName,",") GT 0>		
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
	 <cfelse>
	    <cfinclude template="ActionFiles_OLD\act_GetAssessment.cfm">
		<cfinclude template="ActionFiles_OLD\act_ActivateAssessmentWithoutBilling.cfm">
		<cfinclude template="ActionFiles_OLD\act_GetAssessmentsForHouse.cfm">
		<cfinclude template="ActionFiles_OLD\act_GetInquiryAssessmentsForHouse.cfm">
		<cfinclude template="ScriptFiles_OLD\js_TrMouseOver.cfm">
		<cfinclude template="ScriptFiles_OLD\js_ShowArea.cfm">
		<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a>">
		<cfinclude template="DisplayFiles_OLD\dsp_Header.cfm">
		<cfinclude template="ScriptFiles_OLD\js_ShowMenu.cfm">
		<cfinclude template="DisplayFiles_OLD\dsp_Navigation.cfm">
		<cfinclude template="DisplayFiles_OLD\dsp_AssessmentMain.cfm">
	 </cfif>
	</cfcase>	
	
	<cfcase value="assessmentMain">	
		<cfif listFindNoCase(assessmentRegionList,checkregion.opsAreaName,",") GT 0>
			<cfinclude template="ActionFiles\act_GetAssessmentsForHouse.cfm">	
			<cfinclude template="ActionFiles\act_GetInquiryAssessmentsForHouse.cfm">			
			<cfinclude template="ScriptFiles\js_TrMouseOver.cfm">
			<cfinclude template="ScriptFiles\js_ShowArea.cfm">
			<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a>">
			<cfinclude template="DisplayFiles\dsp_Header.cfm">
			<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
			<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
			<cfinclude template="DisplayFiles\dsp_AssessmentMain.cfm">
	  <cfelse>
			<cfinclude template="ActionFiles_OLD\act_GetAssessmentsForHouse.cfm">
			<cfinclude template="ActionFiles_OLD\act_GetInquiryAssessmentsForHouse.cfm">
			<cfinclude template="ScriptFiles_OLD\js_TrMouseOver.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ShowArea.cfm">
			<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a>">
			<cfinclude template="DisplayFiles_OLD\dsp_Header.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ShowMenu.cfm">
			<cfinclude template="DisplayFiles_OLD\dsp_Navigation.cfm">
			<cfinclude template="DisplayFiles_OLD\dsp_AssessmentMain.cfm">
	   </cfif>
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
		<cfif CheckRegion.StateCode EQ 'ID'>
	    	<cfinclude template="DisplayFiles\dsp_PrintAssessment_cf_inquiry_ID.cfm">
	    <cfelse>		
			<cfinclude template="DisplayFiles\dsp_PrintAssessment_cf_inquiry.cfm">	
	    </cfif>		
	</cfcase>

	<cfcase value="printAssessmentnew">		
		<cfif CheckRegion.StateCode EQ 'ID'>	  
			<cfinclude template="DisplayFiles\dsp_PrintAssessment_cf_Idhaho.cfm">		 
		<cfelse>
			<cfinclude template="DisplayFiles\dsp_PrintAssessment_cf.cfm">		 
		</cfif>			  	  				  		
	</cfcase>

	<cfcase value="printAssessmentEnquiry">
	  <cfif CheckRegion.StateCode EQ 'ID'>	 <!--- Added code for Idaho houses report.  Ganga-06/24/13 --->
	      <cfinclude template="DisplayFiles\dsp_PrintAssessment_cf_inquiry_ID.cfm">
	   <cfelse>		
		  <cfinclude template="DisplayFiles\dsp_PrintAssessment_cf_inquiry.cfm">	
	   </cfif>	  		
	</cfcase>
	
	<cfcase value="printAssessmentcare">
		<cfif CheckRegion.StateCode EQ 'ID'>	 
			<cfinclude template="DisplayFiles\dsp_PrintAssessment_care_ID.cfm">
		<cfelse>		
			<cfinclude template="DisplayFiles\dsp_PrintAssessment_care.cfm">	
		</cfif>	  		
	</cfcase>

	<cfcase value="printAssessmentcareInquiry">
		<cfif CheckRegion.StateCode EQ 'ID'>	 
			<cfinclude template="DisplayFiles\dsp_PrintAssessment_cf_care_inquiry_ID.cfm">
		<cfelse>		
			<cfinclude template="DisplayFiles\dsp_PrintAssessment_cf_care_inquiry.cfm">	
		</cfif>	  		
	</cfcase>

	<cfcase value="viewAssessment">
		<cfif listFindNoCase(assessmentRegionList,checkregion.opsAreaName,",") GT 0>			
			<cfinclude template="ActionFiles\act_GetAssessment.cfm">			
			<cfinclude template="ActionFiles\act_GetAllTools.cfm">
			<cfinclude template="ActionFiles\act_GetReviewTypes.cfm">			
			<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Assessment.GetTenant().GetName()# Assessment">		
			<cfinclude template="DisplayFiles\dsp_Header.cfm">
			<cfinclude template="ScriptFiles\js_ChangeDate.cfm">
			<cfinclude template="ScriptFiles\js_ChangeActivateDate.cfm">
			<cfinclude template="ScriptFiles\js_SubmitAssessment.cfm">
			<cfinclude template="ScriptFiles\js_DisableAll.cfm">
			<cfinclude template="ScriptFiles\js_ShowNotes.cfm">	
			<cfinclude template="ScriptFiles\js_ShowCategoryNotes.cfm"> 
			<cfinclude template="ScriptFiles\js_Highlight.cfm">
	    	<cfinclude template="ScriptFiles\js_ResetLevel.cfm">
			<cfinclude template="ScriptFiles\js_ShowMenu.cfm">
			<cfinclude template="ScriptFiles\js_SelectOption.cfm">
			<cfinclude template="ScriptFiles\js_EnableParent.cfm">
			<cfset id = #Assessment.GetAssessmentTool().GetId()#>   
			<cfif id neq 25 and id neq 26 and id neq 27 >
				<cfinclude template="ScriptFiles\js_CalculatePoints_OLD.cfm"> 
			<cfelse>
				<cfinclude template="ScriptFiles\js_CalculatePoints.cfm">
			</cfif>
			<cfinclude template="ScriptFiles\js_GetLevel.cfm">
			<cfinclude template="ScriptFiles\js_DisableAllServices.cfm">   <!---Commented for base level yes/no option features--->
			<cfinclude template="ScriptFiles\js_DisableSubServices.cfm">
			<cfinclude template="ScriptFiles\js_ShowTool.cfm">
			<cfinclude template="ScriptFiles\js_LoadAssessment.cfm">
			<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
			<cfinclude template="DisplayFiles\dsp_ViewAssessment.cfm">
			<cfinclude template="ScriptFiles\js_PointsScroll.cfm">
			<cfif Assessment.GetIsFinalized()>
				<cfinclude template="ScriptFiles\js_ActivateAssessment.cfm">
			</cfif>
		<cfelse>		
			<cfinclude template="ActionFiles_OLD\act_GetAssessment.cfm">
			<cfinclude template="ActionFiles_OLD\act_GetAllTools.cfm">
		    <cfinclude template="ActionFiles_OLD\act_GetReviewTypes.cfm">
			<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Assessment.GetTenant().GetName()# Assessment">		
			<cfinclude template="DisplayFiles_OLD\dsp_Header.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ChangeDate.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ChangeActivateDate.cfm">
			<cfinclude template="ScriptFiles_OLD\js_SubmitAssessment.cfm">
			<cfinclude template="ScriptFiles_OLD\js_DisableAll.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ShowNotes.cfm">	
			<cfinclude template="ScriptFiles_OLD\js_ShowCategoryNotes.cfm">		
			<cfinclude template="ScriptFiles_OLD\js_Highlight.cfm">
		    <cfinclude template="ScriptFiles_OLD\js_ResetLevel.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ShowMenu.cfm">
			<cfinclude template="ScriptFiles_OLD\js_SelectOption.cfm">
			<cfinclude template="ScriptFiles_OLD\js_EnableParent.cfm">
			<cfinclude template="ScriptFiles_OLD\js_CalculatePoints.cfm">
			<cfinclude template="ScriptFiles_OLD\js_GetLevel.cfm">
			<cfinclude template="ScriptFiles_OLD\js_DisableAllServices.cfm">
			<cfinclude template="ScriptFiles_OLD\js_DisableSubServices.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ShowTool.cfm">
			<cfinclude template="ScriptFiles_OLD\js_LoadAssessment.cfm">
			<cfinclude template="DisplayFiles_OLD\dsp_Navigation.cfm">
			<cfinclude template="DisplayFiles_OLD\dsp_ViewAssessment.cfm">
			<cfinclude template="ScriptFiles_OLD\js_PointsScroll.cfm">
			<cfif Assessment.GetIsFinalized()>
				<cfinclude template="ScriptFiles_OLD\js_ActivateAssessment.cfm">
			</cfif>
		</cfif>
	</cfcase>

	<cfcase value="saveAssessment">
		<cfset finalize = false>
		<cfif listFindNoCase(assessmentRegionList,checkregion.opsAreaName,",") GT 0>
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
		<cfelse>
		    <cfinclude template="ActionFiles_OLD\act_GetAssessment.cfm">
			<cfinclude template="ActionFiles_OLD\act_SaveAssessment.cfm">
			<cfinclude template="ActionFiles_OLD\act_GetAssessmentsForHouse.cfm">
			<cfinclude template="ActionFiles_OLD\act_GetInquiryAssessmentsForHouse.cfm">
			<cfinclude template="ScriptFiles_OLD\js_TrMouseOver.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ShowArea.cfm">
			<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a>">
			<cfinclude template="DisplayFiles_OLD\dsp_Header.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ShowMenu.cfm">
			<cfinclude template="DisplayFiles_OLD\dsp_Navigation.cfm">
			<cfinclude template="DisplayFiles_OLD\dsp_AssessmentMain.cfm">
		</cfif>
	</cfcase>

	<cfcase value="finalizeAssessment">
		<cfset finalize = true>
		<cfif listFindNoCase(assessmentRegionList,checkregion.opsAreaName,",") GT 0>	
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
		<cfelse>
			<cfinclude template="ActionFiles_OLD\act_GetAssessment.cfm">
			<cfinclude template="ActionFiles_OLD\act_SaveAssessment.cfm">
			<cfinclude template="ActionFiles_OLD\act_GetAssessmentsForHouse.cfm">
			<cfinclude template="ActionFiles_OLD\act_GetInquiryAssessmentsForHouse.cfm">
			<cfinclude template="ScriptFiles_OLD\js_TrMouseOver.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ShowArea.cfm">
			<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a>">
			<cfinclude template="DisplayFiles_OLD\dsp_Header.cfm">
			<cfinclude template="ScriptFiles_OLD\js_ShowMenu.cfm">
			<cfinclude template="DisplayFiles_OLD\dsp_Navigation.cfm">
			<cfinclude template="DisplayFiles_OLD\dsp_AssessmentMain.cfm">
		</cfif>
	</cfcase>

	<cfcase value="newAssessment">		
		<cfif listFindNoCase(assessmentRegionList,checkregion.opsAreaName,",") GT 0>		
			<cfif assessmentType eq "resident">
				<cfinclude template="ActionFiles\act_GetResident.cfm">
				<cfinclude template="ActionFiles\act_GetTenant.cfm">
			    <cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Resident.GetName()# : New Assessment">
				<cfparam name="assessmentType" default="resident">
				<cfparam name="assessmentId" default="#Resident.GetAssessmentId()#">		
				<cfparam name="points" default="#resident.getPoints()#">
				<cfinclude template="ActionFiles\act_GetServicePlan.cfm">
				<cfinclude template="ActionFiles\act_GetAllTools.cfm">
				<cfinclude template="ActionFiles\act_GetReviewTypes.cfm">			
				<cfinclude template="DisplayFiles\dsp_Header.cfm">
				<cfinclude template="ScriptFiles\js_ChangeDate.cfm">				
				<cfinclude template="ScriptFiles\js_SubmitAssessment.cfm">
				<cfinclude template="ScriptFiles\js_ShowNotes.cfm">
			    <cfinclude template="ScriptFiles\js_ShowCategoryNotes.cfm">
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
				<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
				<cfinclude template="DisplayFiles\dsp_NewAssessment.cfm">
				<cfinclude template="ScriptFiles\js_PointsScroll.cfm">
			<cfelseif assessmentType eq "FromStar">
				<cfinclude template="ActionFiles\act_GetTenant.cfm">
				<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Tenant.GetName()# : New Assessment">		
				<cfparam name="assessmentType" default="tenant">
				<cfparam name="assessmentId" default="#Tenant.GetAssessmentId()#">
				<cfparam name="points" default="#tenant.getPoints()#">
				<cfinclude template="ActionFiles\act_GetAssessment.cfm">
				<cfinclude template="ActionFiles\act_GetServicePlan.cfm">
				<cfinclude template="ActionFiles\act_GetAllTools.cfm">
				<cfinclude template="ActionFiles\act_GetReviewTypes.cfm">
				<cfinclude template="DisplayFiles\dsp_Header.cfm">
				<cfinclude template="ScriptFiles\js_ChangeDate.cfm">
				<cfinclude template="ScriptFiles\js_SubmitAssessment.cfm">
			    <cfinclude template="ScriptFiles\js_ShowNotes.cfm"> 
			    <cfinclude template="ScriptFiles\js_ShowCategoryNotes.cfm">	      
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
				<cfinclude template="ScriptFiles\js_LoadNotes_new.cfm">
				<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
				<cfinclude template="DisplayFiles\dsp_NewAssessment.cfm">
				<cfinclude template="ScriptFiles\js_PointsScroll.cfm">
			<cfelseif assessmentType eq "FromStarInquiry">
				<cfinclude template="ActionFiles\act_GetTenant.cfm">
				<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Tenant.GetName()# : New Assessment">		
				<cfparam name="assessmentType" default="tenant">
				<cfparam name="assessmentId" default="#Tenant.GetAssessmentId()#">
				<cfparam name="points" default="#Tenant.getPoints()#">
				<cfinclude template="ActionFiles\act_GetServicePlan.cfm">
				<cfinclude template="ActionFiles\act_GetAllTools.cfm">
				<cfinclude template="ActionFiles\act_GetReviewTypes.cfm">
				<cfinclude template="DisplayFiles\dsp_Header.cfm">
				<cfinclude template="ScriptFiles\js_ChangeDate.cfm">
				<cfinclude template="ScriptFiles\js_SubmitAssessment.cfm">
				<cfinclude template="ScriptFiles\js_ShowNotes.cfm">			
			    <cfinclude template="ScriptFiles\js_ShowCategoryNotes.cfm"> 	
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
			 	<cfinclude template="ScriptFiles\js_LoadNotes_new_note.cfm">
				<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
				<cfinclude template="DisplayFiles\dsp_NewAssessment.cfm">
				<cfinclude template="ScriptFiles\js_PointsScroll.cfm">
			<cfelse>
				<cfinclude template="ActionFiles\act_GetTenant.cfm">
				<cfinclude template="ActionFiles\act_GetResident.cfm">
				<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Tenant.GetName()# : New Assessment">
				<cfparam name="assessmentType" default="tenant">
				<cfparam name="assessmentId" default="#Tenant.GetAssessmentId()#">
				<cfparam name="points" default="#tenant.getPoints()#">
				<cfinclude template="ActionFiles\act_GetAssessment.cfm">
				<cfinclude template="ActionFiles\act_GetServicePlan.cfm">
				<cfinclude template="ActionFiles\act_GetAllTools.cfm">
				<cfinclude template="ActionFiles\act_GetReviewTypes.cfm">
				<cfinclude template="DisplayFiles\dsp_Header.cfm">
				<cfinclude template="ScriptFiles\js_ChangeDate.cfm">
				<cfinclude template="ScriptFiles\js_SubmitAssessment.cfm">
				<cfinclude template="ScriptFiles\js_ShowNotes.cfm"> 
			    <cfinclude template="ScriptFiles\js_ShowCategoryNotes.cfm"> 
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
				<cfinclude template="ScriptFiles\js_LoadNotes_new.cfm">
				<cfinclude template="DisplayFiles\dsp_Navigation.cfm">
				<cfinclude template="DisplayFiles\dsp_NewAssessment.cfm">
				<cfinclude template="ScriptFiles\js_PointsScroll.cfm">
			</cfif>
		<cfelse> 
			<cfif assessmentType eq "resident">
				<cfinclude template="ActionFiles_OLD\act_GetResident.cfm">
				<cfinclude template="ActionFiles_OLD\act_GetTenant.cfm">
				<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Resident.GetName()# : New Assessment">
				<cfparam name="assessmentType" default="resident">
				<cfparam name="assessmentId" default="#Resident.GetAssessmentId()#">
				<cfinclude template="ActionFiles_OLD\act_GetServicePlan.cfm">
				<cfinclude template="ActionFiles_OLD\act_GetAllTools.cfm">
				<cfinclude template="ActionFiles_OLD\act_GetReviewTypes.cfm">
				<cfinclude template="DisplayFiles_OLD\dsp_Header.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ChangeDate.cfm">				
				<cfinclude template="ScriptFiles_OLD\js_SubmitAssessment.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ShowNotes.cfm">			
				<cfinclude template="ScriptFiles_OLD\js_ShowCategoryNotes.cfm">		   
				<cfinclude template="ScriptFiles_OLD\js_Highlight.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ResetLevel.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ShowMenu.cfm">
				<cfinclude template="ScriptFiles_OLD\js_SelectOption.cfm">
				<cfinclude template="ScriptFiles_OLD\js_EnableParent.cfm">
				<cfinclude template="ScriptFiles_OLD\js_CalculatePoints.cfm">
				<cfinclude template="ScriptFiles_OLD\js_GetLevel.cfm">
				<cfinclude template="ScriptFiles_OLD\js_DisableAllServices.cfm">
				<cfinclude template="ScriptFiles_OLD\js_DisableSubServices.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ShowTool.cfm">			
				<cfinclude template="DisplayFiles_OLD\dsp_Navigation.cfm">
				<cfinclude template="DisplayFiles_OLD\dsp_NewAssessment.cfm">
				<cfinclude template="ScriptFiles_OLD\js_PointsScroll.cfm">		
			<cfelseif assessmentType eq "FromStar">
				<cfinclude template="ActionFiles_OLD\act_GetTenant.cfm">
				<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Tenant.GetName()# : New Assessment">		
				<cfparam name="assessmentType" default="tenant">
				<cfparam name="assessmentId" default="#Tenant.GetAssessmentId()#">
				<cfinclude template="ActionFiles_OLD\act_GetAssessment.cfm">
				<cfinclude template="ActionFiles_OLD\act_GetServicePlan.cfm">
				<cfinclude template="ActionFiles_OLD\act_GetAllTools.cfm">
				<cfinclude template="ActionFiles_OLD\act_GetReviewTypes.cfm">
				<cfinclude template="DisplayFiles_OLD\dsp_Header.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ChangeDate.cfm">
				<cfinclude template="ScriptFiles_OLD\js_SubmitAssessment.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ShowNotes.cfm">		
				<cfinclude template="ScriptFiles_OLD\js_ShowCategoryNotes.cfm">		      
				<cfinclude template="ScriptFiles_OLD\js_Highlight.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ResetLevel.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ShowMenu.cfm">
				<cfinclude template="ScriptFiles_OLD\js_SelectOption.cfm">
				<cfinclude template="ScriptFiles_OLD\js_EnableParent.cfm">
				<cfinclude template="ScriptFiles_OLD\js_CalculatePoints.cfm">
				<cfinclude template="ScriptFiles_OLD\js_GetLevel.cfm">
				<cfinclude template="ScriptFiles_OLD\js_DisableAllServices.cfm">
				<cfinclude template="ScriptFiles_OLD\js_DisableSubServices.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ShowTool.cfm">
				<cfinclude template="ScriptFiles_OLD\js_LoadNotes.cfm">
				<cfinclude template="DisplayFiles_OLD\dsp_Navigation.cfm">
				<cfinclude template="DisplayFiles_OLD\dsp_NewAssessment.cfm">
				<cfinclude template="ScriptFiles_OLD\js_PointsScroll.cfm">
			<cfelseif assessmentType eq "FromStarInquiry">
				<cfinclude template="ActionFiles_OLD\act_GetTenant.cfm">
				<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Tenant.GetName()# : New Assessment">		
				<cfparam name="assessmentType" default="tenant">
				<cfparam name="assessmentId" default="#Tenant.GetAssessmentId()#">
				<cfinclude template="ActionFiles_OLD\act_GetServicePlan.cfm">
				<cfinclude template="ActionFiles_OLD\act_GetAllTools.cfm">
				<cfinclude template="ActionFiles_OLD\act_GetReviewTypes.cfm">
				<cfinclude template="DisplayFiles_OLD\dsp_Header.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ChangeDate.cfm">
				<cfinclude template="ScriptFiles_OLD\js_SubmitAssessment.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ShowNotes.cfm">			
				<cfinclude template="ScriptFiles_OLD\js_ShowCategoryNotes.cfm"> 		   
				<cfinclude template="ScriptFiles_OLD\js_Highlight.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ResetLevel.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ShowMenu.cfm">
				<cfinclude template="ScriptFiles_OLD\js_SelectOption.cfm">
				<cfinclude template="ScriptFiles_OLD\js_EnableParent.cfm">
				<cfinclude template="ScriptFiles_OLD\js_CalculatePoints.cfm">
				<cfinclude template="ScriptFiles_OLD\js_GetLevel.cfm">
				<cfinclude template="ScriptFiles_OLD\js_DisableAllServices.cfm">
				<cfinclude template="ScriptFiles_OLD\js_DisableSubServices.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ShowTool.cfm">			
				<cfinclude template="DisplayFiles_OLD\dsp_Navigation.cfm">
				<cfinclude template="DisplayFiles_OLD\dsp_NewAssessment.cfm">
				<cfinclude template="ScriptFiles_OLD\js_PointsScroll.cfm">
			<cfelse>
				<cfinclude template="ActionFiles_OLD\act_GetTenant.cfm">
				<cfinclude template="ActionFiles_OLD\act_GetResident.cfm">
				<cfset session.breadcrumbs = "<a href=""index.cfm?fuse=assessmentMain"" class=""breadcrumbs"">AssessmentTool</a> : #Tenant.GetName()# : New Assessment">
				<cfparam name="assessmentType" default="tenant">
				<cfparam name="assessmentId" default="#Tenant.GetAssessmentId()#">
				<cfinclude template="ActionFiles_OLD\act_GetAssessment.cfm">
				<cfinclude template="ActionFiles_OLD\act_GetServicePlan.cfm">
				<cfinclude template="ActionFiles_OLD\act_GetAllTools.cfm">
				<cfinclude template="ActionFiles_OLD\act_GetReviewTypes.cfm">
				<cfinclude template="DisplayFiles_OLD\dsp_Header.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ChangeDate.cfm">
				<cfinclude template="ScriptFiles_OLD\js_SubmitAssessment.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ShowNotes.cfm"> 			
				<cfinclude template="ScriptFiles_OLD\js_ShowCategoryNotes.cfm">		   
				<cfinclude template="ScriptFiles_OLD\js_Highlight.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ResetLevel.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ShowMenu.cfm">
				<cfinclude template="ScriptFiles_OLD\js_SelectOption.cfm">
				<cfinclude template="ScriptFiles_OLD\js_EnableParent.cfm">
				<cfinclude template="ScriptFiles_OLD\js_CalculatePoints.cfm">
				<cfinclude template="ScriptFiles_OLD\js_GetLevel.cfm">
				<cfinclude template="ScriptFiles_OLD\js_DisableAllServices.cfm">
				<cfinclude template="ScriptFiles_OLD\js_DisableSubServices.cfm">
				<cfinclude template="ScriptFiles_OLD\js_ShowTool.cfm">
				<cfinclude template="ScriptFiles_OLD\js_LoadNotes.cfm">
				<cfinclude template="DisplayFiles_OLD\dsp_Navigation.cfm">
				<cfinclude template="DisplayFiles_OLD\dsp_NewAssessment.cfm">
				<cfinclude template="ScriptFiles_OLD\js_PointsScroll.cfm">
			</cfif>
		</cfif>
	</cfcase>	
	<cfcase value="addNewAssessment">
		<cfif listFindNoCase(assessmentRegionList,checkregion.opsAreaName,",") GT 0>	
	      <cfinclude template="ActionFiles\act_AddNewAssessment.cfm">
	   <cfelse>
		<cfinclude template="ActionFiles_OLD\act_AddNewAssessment.cfm">
	   </cfif>
	</cfcase>
	<cfdefaultcase></cfdefaultcase>
</cfswitch>