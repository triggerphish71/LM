<!---------------------------------------------------------------------------------------------|
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 02/14/2007 | Created                                                            |
| mlaw       | 11/05/2007 | Add a month command to line 1209                                   |
| jcruz      | 06/26/2008 | Added new function (AddServicePlan) as part of project 12392       |
|            |            | to incorporate Service Plans into the assessment process.          |
|            |            | Also modified save function to include both tenant and resident id |
|            |            | when saving a newly created assessment.							   |
|----------------------------------------------------------------------------------------------|
| sathya     | 01/15/2010 | Sathya modified it as per 41315 added GetTenantID function it gets |
|            |            | the iTenant_id.                                                    |
|----------------------------------------------------------------------------------------------|
| Sathya     | 02/12/2010 | Sathya as per project 41315-B                                      |
|            |            | Added new array ServiceCategoryArray to store the Service Category |
|            |            | Modified some functions.                                           |
|            |            | Added new function  GetServicesCategory and setServicesCategory.   |
|            |            | Added a query GetServiceCategoryQuery in GetInformation function.  |
|            |            | Added AddServiceCategory function to add new record for category   | 
|            |            | in the assessmentdetail table when notes is added in category      |
|----------------------------------------------------------------------------------------------|
| Sathya     |03/10/2010  | Made changes per Project 41315-C for the nurse alerts to display   |
|----------------------------------------------------------------------------------------------|
| S Farmer   |11/03/2011  | qChargesOld changed 'level' dropped from "Service level" for       |
|            |            |  cDescription entry         Ticket 80779                           |
| gthota     |10/30/2012  | added code for new assessment tool options Level/Points            |
|            |            |      Ticket 88898                                                  |
| gthota     |11/16/2012  |commented code line:1292 displaying incurrect assessment for tenanat|
| gthota     |01/25/2013  | Care level change missing month code added                         |
-----------------------------------------------------------------------------------------------|
| Sfarmer   | 10/18/2013  |Proj. 102481 removed Walnut db and tables Census & Leadtracking     |
| Sfarmer   | 11/06/2013  |Proj. 102481 updated                                                |
| gthota    | 11/15/2013  |Proj .112109 added code for assessment Activation issues            |
| Sfarmer   | 12/03/2013  |Proj. 112456 Correction for prevous month when                      |
|           |             |  current month is January  (01)                                    |
| sfarmer   |03-26-2015   | the query  'qDeleteMonthData' was commented out is now uncommented |
|Sfarmer    | 04-29-2015  | revised query qDeleteMonthData to remove condition                 |
|Mamta Shah |             | "and(inv.irowstartuser_id between '1800' and '2000'" and           |
|           |             | query qCurrentInvoice added "where m.dtrowdeleted is null"         |
----------------------------------------------------------------------------------------------->
 
<cfcomponent name="Assessment" output="false" extends="Components.AlcBase"><!---extends="Components.AlcBase"--->
	<cffunction name="Init" access="public" returntype="void" output="false">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="dsn" type="string" required="true">
		<!--- <cfargument name="leadtrackingdbserver" type="string" required="true"> --->
		<!--- <cfargument name="censusdbserver" required="true"> --->
		
		<cfscript>
			//create the variables for the tenant
			variables.id = arguments.id;
			variables.dsn = arguments.dsn;
			variables.tenantId = 0;
			variables.residentId = 0;
			variables.assessmentToolId = 0;
			variables.reviewTypeId = 0;
			variables.points = 0;
			variables.reviewStartDate = '';
			variables.reviewEndDate = '';
			variables.isBillingActive = false;
			variables.billingActiveDate = '';
			variables.isFinalized = false;
			variables.isApprovalRequired = false;
			variables.approvedBy = '';
			variables.nextReviewDate = '';
			variables.rowStartUserId = 0;
			variables.rowStartDate = "";
			variables.rowEndUserId = 0;
			variables.rowEndDate = "";
			variables.rowDeletedUserId = 0;
			variables.rowDeletedDate = "";
			//02/12/2010 sathya added this as per Project 41315-B
			variables.ServiceCategoryArray = ArrayNew(1);
			 // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
			variables.ServiceArray = ArrayNew(1);
			variables.SubServiceArray = ArrayNew(1);
			variables.NoteArray = ArrayNew(1);
			
			variables.ServiceTextArray = ArrayNew(1);
		//	variables.leadtrackingdbserver = arguments.leadtrackingdbserver;
		//	variables.censusdbserver = arguments.censusdbserver;			
			variables.leadtrackingdbserver = '';
			variables.censusdbserver = '';
			variables.serviceplanid = 0;
			variables.statuscode = 0;
			variables.diagnosis = '';
			// this change for project 88898 ( need 7 diagnosis types dropdowns)
			variables.Primary = '';
			variables.Secondary = '';
			variables.Third = '';
			variables.Fourth = '';
			variables.Fifth = '';
			variables.Sixth = '';
			variables.Seventh = '';
			variables.allergies = '';
			varuables.otherservices = '';
			
			//if the id isn't 0 get the information;
			if(variables.id neq 0)
			{
				GetInformation();
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="GetInformation" access="private" returntype="void" output="false" hint="Gets information and fills the object variables.">
      <cfquery name="GettenantidQuery" datasource="#variables.dsn#">
			SELECT  
				 atm.*
			FROM
				AssessmentToolMaster atm				
			WHERE
				atm.iAssessmentToolMaster_id = #variables.id#			
		</cfquery> 	

        <cfquery name="GetAssessmenttoolidQuery" datasource="#variables.dsn#">
			SELECT 
				 t.iTenant_id, t.iHouse_id,t.cSLevelTypeSet,at.iAssessmentTool_id,at.cSLevelTypeSet,at.cDescription
			FROM
				Tenant t
			join AssessmentTool as at on t.csleveltypeset = at.csleveltypeset and at.dtrowdeleted is null	
			WHERE
				t.iTenant_id = #GettenantidQuery.itenant_id#
			AND
				t.dtrowdeleted is null				
		</cfquery> 
		<cfif (not isdefined("URL.fuse") or URL.fuse EQ "viewAssessment") > 
			<cfquery name="QueryGetInformation" datasource="#variables.dsn#">
				SELECT
					  atm.iAssessmentToolMaster_id
					  ,IsNull(atm.iAssessmentTool_id,0) AS iAssessmentTool_id
					  ,IsNull(atm.iTenant_id,0) AS iTenant_id
					  ,IsNull(atm.iResident_id,0) AS iResident_id
					  ,IsNull(atm.iReviewType_id,0) AS iReviewType_id
					  ,IsNull(atm.iSPoints,'') AS iSPoints
					  ,IsNull(atm.dtReviewStart,'') AS dtReviewStart
					  ,IsNull(atm.dtReviewEnd,'') AS dtReviewEnd
					  ,IsNull(atm.bBillingActive,0) AS bBillingActive
					  ,IsNull(atm.dtBillingActive,'') AS dtBillingActive
					  ,IsNull(atm.bFinalized,0) AS bFinalized
					  ,IsNull(atm.bApprovalRequired,0) AS bApprovalRequired
					  ,IsNull(atm.cApprovedBy,'') AS cApprovedBy
					  ,IsNull(atm.cRowStartUser_id,0) AS cRowStartUser_id
					  ,IsNull(atm.dtRowStart,'') AS dtRowStart
					  ,IsNull(atm.cRowEndUser_id,'') AS cRowEndUser_id
					  ,IsNull(atm.dtRowEnd,'') AS dtRowEnd
					  ,IsNull(atm.cRowDeletedUser_id,'') AS cRowDeletedUser_id
					  ,IsNull(atm.dtRowDeleted,'') AS dtRowDeleted
					  ,IsNull(atm.dtNextReview,'') AS dtNextReview
					  ,IsNull(atm.iPrimaryDiagnosis,0) AS iPrimaryDiagnosis
					  ,IsNull(atm.iSecondaryDiagnosis,0) AS iSecondaryDiagnosis
					  ,IsNull(asp.int_Plan_Id,0) AS serviceplanid
					  ,IsNull(asp.char_Status,0) AS char_Status
					  ,IsNull(asp.txt_Diagnosis,'') AS txt_Diagnosis
					  ,IsNull(asp.iPrimary,'') AS iPrimary
					  ,IsNull(asp.iSecondary,'') AS iSecondary
					  ,IsNull(asp.iThird,'') AS iThird
					  ,IsNull(asp.iFourth,'') AS iFourth
					  ,IsNull(asp.iFifth,'') AS iFifth
					  ,IsNull(asp.iSixth,'') AS iSixth
					  ,IsNull(asp.iSeventh,'') AS iSeventh
					  ,IsNull(asp.txt_Allergies,'') AS txt_Allergies
					  ,IsNull(asp.txt_OtherServices,'') AS txt_OtherServices
				FROM
					AssessmentToolMaster atm Left Join
					tbl_AssessmentServicePlan asp on atm.iAssessmentToolMaster_id = asp.int_AssessmentToolMaster_id
				WHERE
					atm.iAssessmentToolMaster_id	= #variables.id#
			</cfquery>
		<cfelseif URL.Fuse EQ "ActivateAssessment" OR URL.Fuse EQ "activateAssessmentWithoutBilling">
	      <cfquery name="QueryGetInformation" datasource="#variables.dsn#">
	       SELECT
					  atm.iAssessmentToolMaster_id
					  ,IsNull(atm.iAssessmentTool_id,0) AS iAssessmentTool_id
					  ,IsNull(atm.iTenant_id,0) AS iTenant_id
					  ,IsNull(atm.iResident_id,0) AS iResident_id
					  ,IsNull(atm.iReviewType_id,0) AS iReviewType_id
					  ,IsNull(atm.iSPoints,'') AS iSPoints
					  ,IsNull(atm.dtReviewStart,'') AS dtReviewStart
					  ,IsNull(atm.dtReviewEnd,'') AS dtReviewEnd
					  ,IsNull(atm.bBillingActive,0) AS bBillingActive
					  ,IsNull(atm.dtBillingActive,'') AS dtBillingActive
					  ,IsNull(atm.bFinalized,0) AS bFinalized
					  ,IsNull(atm.bApprovalRequired,0) AS bApprovalRequired
					  ,IsNull(atm.cApprovedBy,'') AS cApprovedBy
					  ,IsNull(atm.cRowStartUser_id,0) AS cRowStartUser_id
					  ,IsNull(atm.dtRowStart,'') AS dtRowStart
					  ,IsNull(atm.cRowEndUser_id,'') AS cRowEndUser_id
					  ,IsNull(atm.dtRowEnd,'') AS dtRowEnd
					  ,IsNull(atm.cRowDeletedUser_id,'') AS cRowDeletedUser_id
					  ,IsNull(atm.dtRowDeleted,'') AS dtRowDeleted
					  ,IsNull(atm.dtNextReview,'') AS dtNextReview
					  ,IsNull(atm.iPrimaryDiagnosis,0) AS iPrimaryDiagnosis
					  ,IsNull(atm.iSecondaryDiagnosis,0) AS iSecondaryDiagnosis
					  ,IsNull(asp.int_Plan_Id,0) AS serviceplanid
					  ,IsNull(asp.char_Status,0) AS char_Status
					  ,IsNull(asp.txt_Diagnosis,'') AS txt_Diagnosis
					  ,IsNull(asp.iPrimary,'') AS iPrimary
					  ,IsNull(asp.iSecondary,'') AS iSecondary
					  ,IsNull(asp.iThird,'') AS iThird
					  ,IsNull(asp.iFourth,'') AS iFourth
					  ,IsNull(asp.iFifth,'') AS iFifth
					  ,IsNull(asp.iSixth,'') AS iSixth
					  ,IsNull(asp.iSeventh,'') AS iSeventh
					  ,IsNull(asp.txt_Allergies,'') AS txt_Allergies
					  ,IsNull(asp.txt_OtherServices,'') AS txt_OtherServices
				FROM
					AssessmentToolMaster atm Left Join
					tbl_AssessmentServicePlan asp on atm.iAssessmentToolMaster_id = asp.int_AssessmentToolMaster_id
				WHERE
					atm.iAssessmentToolMaster_id	= #variables.id#
			</cfquery>
       <cfelse>
	       <cfquery name="QueryGetInformation" datasource="#variables.dsn#">
			SELECT top 1  atm.iAssessmentToolMaster_id	  
				 ,IsNull(at.iAssessmentTool_id,0) AS iAssessmentTool_id	 
				 ,IsNull(atm.iTenant_id,0) AS iTenant_id
				 ,IsNull(atm.iResident_id,0) AS iResident_id  
				 ,IsNull(atm.iReviewType_id,0) AS iReviewType_id	  
				 ,IsNull(atm.iSPoints,'') AS iSPoints
				 ,IsNull(atm.dtReviewStart,'') AS dtReviewStart  
				 ,IsNull(atm.dtReviewEnd,'') AS dtReviewEnd	  
				 ,IsNull(atm.bBillingActive,0) AS bBillingActive
				 ,IsNull(atm.dtBillingActive,'') AS dtBillingActive  
				 ,IsNull(atm.bFinalized,0) AS bFinalized  
				 ,IsNull(atm.bApprovalRequired,0) AS bApprovalRequired
				 ,IsNull(atm.cApprovedBy,'') AS cApprovedBy 
				 ,IsNull(atm.cRowStartUser_id,0) AS cRowStartUser_id  
				 ,IsNull(atm.dtRowStart,'') AS dtRowStart
				 ,IsNull(atm.cRowEndUser_id,'') AS cRowEndUser_id	  
				 ,IsNull(atm.dtRowEnd,'') AS dtRowEnd	  
				 ,IsNull(atm.cRowDeletedUser_id,'') AS cRowDeletedUser_id
				 ,IsNull(atm.dtRowDeleted,'') AS dtRowDeleted	  
				 ,IsNull(atm.dtNextReview,'') AS dtNextReview  
				 ,IsNull(atm.iPrimaryDiagnosis,0) AS iPrimaryDiagnosis
				 ,IsNull(atm.iSecondaryDiagnosis,0) AS iSecondaryDiagnosis  
				 ,IsNull(asp.int_Plan_Id,0) AS serviceplanid 
				 ,IsNull(asp.char_Status,0) AS char_Status
				 ,IsNull(asp.txt_Diagnosis,'') AS txt_Diagnosis  
				 ,IsNull(asp.iPrimary,'') AS iPrimary  
				 ,IsNull(asp.iSecondary,'') AS iSecondary
				 ,IsNull(asp.iThird,'') AS iThird  
				 ,IsNull(asp.iFourth,'') AS iFourth  
				 ,IsNull(asp.iFifth,'') AS iFifth  
				 ,IsNull(asp.iSixth,'') AS iSixth
				 ,IsNull(asp.iSeventh,'') AS iSeventh  
				 ,IsNull(asp.txt_Allergies,'') AS txt_Allergies
				 ,IsNull(asp.txt_OtherServices,'') AS txt_OtherServices
			FROM
					AssessmentToolMaster atm Left Join
					tbl_AssessmentServicePlan asp on atm.iAssessmentToolMaster_id = asp.int_AssessmentToolMaster_id
					Join Tenant as t on atm.iTenant_id = t.iTenant_id
					join assessmenttool as at on t.csleveltypeset = at.csleveltypeset and at.dtrowdeleted is null
			WHERE		<!---atm.iAssessmentToolMaster_id	= #variables.id#--->
					atm.iTenant_id = #GettenantidQuery.itenant_id#
				<!---and bbillingactive = 1--->
			order by dtrowStart desc
			</cfquery>
	   </cfif>
     <!---02/12/2010 sathya as per project 41315-B added this to get Service Category information  --->
		<!---<cfquery name="GetServiceCategoryQuery" datasource="#variables.dsn#">
			SELECT
				 iServiceCategory_ID
				,cNotes
			FROM
				AssessmentToolDetail
			WHERE
				iAssessmentToolMaster_id = #variables.id#
			AND
				dtrowdeleted is null
			AND
				iServiceCategory_ID is not null
		</cfquery>  --->
		<cfif (not isdefined("URL.fuse") or URL.fuse EQ "viewAssessment")>  <!--- Project 88898 Added code for mapping old notes --->
		<cfquery name="GetServiceCategoryQuery" datasource="#variables.dsn#">
			SELECT
				 iServiceCategory_ID
				,cNotes
			FROM
				AssessmentToolDetail
			WHERE
				iAssessmentToolMaster_id = #variables.id#
			AND
				dtrowdeleted is null
			AND
				iServiceCategory_ID is not null
		</cfquery>
	 <cfelse>
		<cfquery name="activeAssessmentId" datasource="#variables.dsn#">
		SELECT * FROM AssessmentToolMaster where bbillingactive = 1 AND iTenant_id = #GettenantidQuery.itenant_id#
		</cfquery>
	    <cfquery name="GetServiceCategoryQuery" datasource="#variables.dsn#">
			SELECT
				 iServiceCategory_ID
				,cNotes
			FROM
				AssessmentToolDetail_old
			WHERE
			<cfif activeAssessmentId.recordCount GT 0>
				iAssessmentToolMaster_id = #activeAssessmentId.iAssessmentToolMaster_id# <!--- #activeAssessmentId.iAssessmentToolMaster_id#/ #variables.id#--->
			<cfelse>
			    iAssessmentToolMaster_id = #variables.id#
			</cfif>
			AND
				dtrowdeleted is null
			AND
				iServiceCategory_ID is not null
		</cfquery>
	 </cfif>  
		<!---02/12/2010 sathya as per project 41315-B added this to get Service Category information  --->
		 <cfscript>
			theQuery = GetServiceCategoryQuery;
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
				ServiceCategory = CreateObject("Component","Components.ServiceCategory");
				ServiceCategory.Init(theQuery["iServiceCategory_ID"][i],variables.dsn);
				ServiceCategory.SetNotes(theQuery["cNotes"][i]);
				
				ArrayAppend(variables.ServiceCategoryArray,ServiceCategory);
			}
			
		</cfscript> 
<!--- This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code) --->
	<cfif (not isdefined("URL.fuse") or URL.fuse EQ "viewAssessment")> 
		<cfquery name="GetServicesQuery" datasource="#variables.dsn#">
			SELECT
				 iServiceList_ID
				 ,Service_text
				,cNotes
			FROM
				AssessmentToolDetail
			WHERE
				iAssessmentToolMaster_id = #variables.id#
			AND
				dtrowdeleted is null
			AND
				iServiceList_ID is not null
		</cfquery>
   <cfelse>
        <cfquery name="activeAssessmentId" datasource="#variables.dsn#">
		SELECT * FROM AssessmentToolMaster where bbillingactive = 1 AND iTenant_id = #GettenantidQuery.itenant_id#
		</cfquery>
       <cfquery name="GetServicesQuery" datasource="#variables.dsn#">
			SELECT
				 iServiceList_ID
				 ,Service_text
				,cNotes
			FROM
				AssessmentToolDetail_old
			WHERE
				iAssessmentToolMaster_id = <cfif activeAssessmentId.recordCount GT 0>#activeAssessmentId.iAssessmentToolMaster_id#<cfelse>#variables.id#</cfif> <!---#variables.id#--->
			AND
				dtrowdeleted is null
			AND
				iServiceList_ID is not null
		</cfquery>
   </cfif>
		<cfscript>
			theQuery = GetServicesQuery;
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
				Service = CreateObject("Component","Components.ServiceList");
				Service.Init(theQuery["iServiceList_ID"][i],variables.dsn);
				Service.SetService_text(theQuery["Service_text"][i]);
				Service.SetNotes(theQuery["cNotes"][i]);
				
				ArrayAppend(variables.ServiceArray,Service);
				ArrayAppend(variables.ServiceTextArray,theQuery["Service_text"][i]);
			}
			
		</cfscript>

		<cfquery name="GetSubServicesQuery" datasource="#variables.dsn#">
			SELECT
				iSubServiceList_ID
			FROM
				AssessmentToolDetail
			WHERE
				iAssessmentToolMaster_id = #variables.id#
			AND
				dtrowdeleted is null
			AND
				iSubServiceList_ID is not null
		</cfquery>
		
		<cfscript>
			theQuery = GetSubServicesQuery;
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
				SubService = CreateObject("Component","Components.SubServiceList");
				SubService.Init(theQuery["iSubServiceList_ID"][i],variables.dsn);
				
				ArrayAppend(variables.SubServiceArray,SubService);
			}

			theQuery = QueryGetInformation;
			
			if(theQuery.RecordCount gt 0)
			{
				variables.id = theQuery["iAssessmentToolMaster_id"][1];
				
				variables.assessmentToolId = theQuery["iAssessmentTool_id"][1];
				variables.tenantId = theQuery["iTenant_ID"][1];
				variables.residentId = theQuery["iResident_ID"][1];
				variables.reviewTypeId = theQuery["iReviewType_id"][1];
				variables.points = theQuery["iSPoints"][1];
				variables.reviewStartDate = theQuery["dtReviewStart"][1];
				variables.reviewEndDate = theQuery["dtReviewEnd"][1];
				variables.isBillingActive = BitToBool(theQuery["bBillingActive"][1]);
				variables.billingActiveDate = theQuery["dtBillingActive"][1];
				variables.isFinalized = BitToBool(theQuery["bFinalized"][1]);
				variables.isApprovalRequired = BitToBool(theQuery["bApprovalRequired"][1]);
				variables.approvedBy = theQuery["cApprovedBy"][1];
				variables.nextReviewDate = theQuery["dtNextReview"][1];
				variables.rowStartUserId = theQuery["cRowStartUser_ID"][1];
				variables.rowStartDate = theQuery["dtRowStart"][1];
				variables.rowEndUserId = theQuery["cRowEndUser_id"][1];
				variables.rowEndDate = theQuery["dtRowEnd"][1];
				variables.rowDeletedUserId = theQuery["cRowEndUser_ID"][1];
				variables.rowDeletedDate = theQuery["dtRowDeleted"][1];
				variables.serviceplanid = theQuery["serviceplanid"][1];
				variables.statuscode = theQuery["char_Status"][1];
				variables.diagnosis = theQuery["txt_Diagnosis"][1];
				variables.Primary = theQuery["iPrimary"][1];
				variables.Secondary = theQuery["iSecondary"][1];
				variables.Third = theQuery["iThird"][1];
				variables.Fourth = theQuery["iFourth"][1];
				variables.Fifth = theQuery["iFifth"][1];
				variables.Sixth = theQuery["iSixth"][1];
				variables.Seventh = theQuery["iSeventh"][1];
				variables.allergies = theQuery["txt_Allergies"][1];
				variables.otherservices = theQuery["txt_OtherServices"][1];
					
			}
			else
			{
				Throw("Assessment not found","Assessment id #variables.id# not found in datasource #variables.dsn#.");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="New" access="public" returntype="Components.Assessment" output="false">
		<cfargument name="assessmentToolId" type="numeric" required="false" default="0">
		<cfargument name="tenantId" type="numeric" required="false" default="0">
		<!--- <cfargument name="residentId" type="numeric" required="false" default="0"> --->
	  	<cfargument name="reviewType" type="numeric" required="false" default="0">  
		<cfargument name="points" type="numeric" required="false" default="0">
		<cfargument name="reviewStartDate" type="string" required="false" default="">
		<cfargument name="isBillingActive" type="boolean" required="false" default="false">
		<cfargument name="billingActiveDate" type="string" required="false" default="">
		<cfargument name="approvalRequired" type="string" required="false" default="false">
		<cfargument name="approvedBy" type="string" required="false" default="">
		<cfargument name="nextReviewDate" type="string" required="false" default="">
		<cfargument name="primaryDiagnosis" type="string" required="false" default="">
		<cfargument name="secondaryDiagnosis" type="string" required="false" default="">
		<cfargument name="rowStartUserId" type="string" required="false" default="">
		<!--- 02/18/2010 Sathya as per Project 41315-B added this for service category --->
		<cfargument name="ServiceCategoryArray" type="array" required="false" default=""> 
		<!---This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code) --->
		<cfargument name="ServiceArray" type="array" required="false" default="">
		<cfargument name="SubServiceArray" type="array" required="false" default="">
		<cfargument name="NoteArray" type="array" required="false" default="">
		<cfargument name="ServiceTextArray" type="array" required="false" default="">  <!---Added for service_text--->
		<cfargument name="dsn" type="string" required="true">
		<!--- <cfargument name="leadtrackingdbserver" type="string" required="true"> --->
		<!--- <cfargument name="censusdbserver" type="string" required="true"> --->
 	    <cfargument name="statuscode" type="string" required="false" default="">
		<cfargument name="diagnosis" type="string" required="false" default="">
		<cfargument name="Primary" type="string" required="false" default="">
		<cfargument name="Secondary" type="string" required="false" default="">
		<cfargument name="Third" type="string" required="false" default="">
		<cfargument name="Fourth" type="string" required="false" default="">
		<cfargument name="Fifth" type="string" required="false" default="">
		<cfargument name="Sixth" type="string" required="false" default="">
		<cfargument name="Seventh" type="string" required="false" default="">
		<cfargument name="allergies" type="string" required="false" default="">
		<cfargument name="otherservices" type="string" required="false" default="">
		
		
			<cfset myList = "">
			<cfloop from="1" to="#Arraylen(arguments.ServiceTextArray)#" index="index">
				<Cfif right(arguments.ServiceTextArray[index],3) EQ "yes">
					<cfset myList = listAppend(myList, listFirst(arguments.ServiceTextArray[index], '_'))>
				</Cfif>
			</cfloop>
			
			<!---<cfoutput>#myList#</cfoutput>	--->		
		<!---<cfdump var="#arguments.ServiceTextArray#"><cfabort>--->  
		
		<cftransaction>
			<!--- Get the total points for the services and subservices --->   <!---<cfif ListFirst( Arguments.serviceText,'_' ) EQ ServiceList.GetId() >--->
			<cfif IsArray(arguments.ServiceArray) AND ArrayLen(arguments.ServiceArray) gt 0>
				<cfquery name="ServicePointsQuery" datasource="#arguments.dsn#">
					SELECT
						SUM(fWeight) as ServicePoints
					FROM
						ServiceList
					WHERE
						iServiceList_ID IN (#myList#)
					
				</cfquery>
			<cfelse>
				<cfset ServicePointsQuery.ServicePoints = 0>
			</cfif>
			
			<cfif IsArray(arguments.SubServiceArray) AND ArrayLen(arguments.SubServiceArray) gt 0>
				<cfquery name="SubServicePointsQuery" datasource="#arguments.dsn#">
					SELECT
						SUM(fWeight) as SubServicePoints
					FROM
						SubServiceList
					WHERE
						iSubServiceList_ID IN (#ArrayToList(arguments.SubServiceArray)#)
				</cfquery>
			<cfelse>
				<cfset SubServicePointsQuery.SubServicePoints = 0>
			</cfif>
			
			<cfset totalPoints = ServicePointsQuery.ServicePoints + SubServicePointsQuery.SubServicePoints>
			
			<!--- step 1 is insert the master record into the database --->
			<cfquery name="NewAssessment" datasource="#arguments.dsn#">
					INSERT INTO
						AssessmentToolMaster(iAssessmentTool_ID
										,iTenant_id
										,iResident_id
										,iReviewType_ID
										,iSPoints
										,dtReviewStart
										,dtReviewEnd
										,bBillingActive
										,dtBillingActive
										,bApprovalRequired
										,cApprovedBy
										,dtNextReview
										,cRowStartUser_id
										,iPrimaryDiagnosis
										,iSecondaryDiagnosis)
					VALUES
						(#arguments.assessmentToolId#
						,#arguments.tenantId#
						<!--- <cfif arguments.residentId neq 0>,#arguments.residentId#<cfelse>,NULL</cfif> --->
						 ,NULL 
						,#arguments.reviewType#
						,#totalPoints#                
						,'#arguments.reviewStartDate#'   
						,null
						,#BoolToBit(arguments.isBillingActive)#
						,'#arguments.billingActiveDate#'
						,#BoolToBit(arguments.approvalRequired)#
						<cfif arguments.approvedBy neq "">,#arguments.approvedBy#<cfelse>,NULL</cfif>
						,'#arguments.nextReviewDate#'
						,'#arguments.rowStartUserId#'
						,<cfif arguments.primaryDiagnosis neq "">#arguments.primaryDiagnosis#<cfelse>NULL</cfif>
						,<cfif arguments.secondaryDiagnosis neq "">#arguments.secondaryDiagnosis#)<cfelse>NULL</cfif>)
						
					SELECT @@identity as newId					
			</cfquery>

			<cfscript>
				Assessment = CreateObject("Component","Components.Assessment");
			//	Assessment.Init(NewAssessment.newId,arguments.dsn,arguments.leadtrackingdbserver,arguments.censusdbserver);
				Assessment.Init(NewAssessment.newId,arguments.dsn);
				
				//loop through the services and add them to the details
				for(i = 1; i lte ArrayLen(ServiceArray); i = i +1)
				{
					theNotes = "";
					
					ServiceList = CreateObject("Component","Components.ServiceList");
					ServiceList.Init(ServiceArray[i],arguments.dsn);
					
					//loop through the notes to see if there is a note for this service
					/*for(x = 1; x lte ArrayLen(NoteArray); x = x +1)
					{	
						if(NoteArray[x][1] eq ServiceList.GetId())
						{
							///now get the notes
							theNotes = NoteArray[x][2];
							break;
						}
					}*/
					
					notesArrayPosition = ArrayFindByDimension(NoteArray,ServiceList.GetId(),1) ;
					if( notesArrayPosition GT 0 )
					{
						theNotes = arguments.NoteArray[notesArrayPosition][2];					
					}

					serviceTextArrayPosition = arrFind(ServiceTextArray,ServiceList.GetId()&'_yes') ;
					if( serviceTextArrayPosition EQ 0 )
					{
						serviceTextArrayPosition = arrFind(ServiceTextArray,ServiceList.GetId()&'_no') ;
					}
					
					if( serviceTextArrayPosition GT 0 )
					{
						theServciceText = arguments.ServiceTextArray [serviceTextArrayPosition ];
					}
					
					if( notesArrayPosition GT 0  or  serviceTextArrayPosition GT 0)
					{
						Assessment.AddService(ServiceList,theNotes,theServciceText);					
					}
				}
				
				//02/12/2010 Sathya as per project 41315-B added this
				for(i = 1; i lte ArrayLen(ServiceCategoryArray); i = i +1)
				{
					theNotes = "";
					
					ServiceCategory = CreateObject("Component","Components.ServiceCategory");
					ServiceCategory.Init(ServiceCategoryArray[i],arguments.dsn);
					
					//loop through the notes to see if there is a note for this service
					for(x = 1; x lte ArrayLen(NoteArray); x = x +1)
					{	
						if(NoteArray[x][1] eq ServiceCategory.GetId())
						{
							///now get the notes
							theNotes = NoteArray[x][2];
							break;
						}
					}
					
					Assessment.AddServiceCategory(ServiceCategory,theNotes);					
				}
				 // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
				
				//loop through the services and add them to the details
				for(i = 1; i lte ArrayLen(SubServiceArray); i = i +1)
				{
					SubServiceList = CreateObject("Component","Components.SubServiceList");
					SubServiceList.Init(SubServiceArray[i],arguments.dsn);
					
					Assessment.AddSubService(SubServiceList);					
				}
// ***** ADDED BY JAIME CRUZ AS PART OF THE SERVICE PLAN PROJECT *****
				{
					//Assessment.AddServicePlan(arguments.statuscode,arguments.diagnosis,arguments.Primary,arguments.Secondary,arguments.Third,arguments.Fourth,arguments.Fifth,arguments.Sixth,arguments.Seventh,arguments.allergies,arguments.otherservices,arguments.tenantId,arguments.residentId);				
					Assessment.AddServicePlan(arguments.statuscode,arguments.diagnosis,arguments.Primary,arguments.Secondary,arguments.Third,arguments.Fourth,arguments.Fifth,arguments.Sixth,arguments.Seventh,arguments.allergies,arguments.otherservices,arguments.tenantId);				

				}

				return Assessment;
			</cfscript>
		</cftransaction>
	</cffunction>
	
	<cffunction name="AddService" access="public" returntype="void" output="false">
		<cfargument name="ServiceList" type="Components.ServiceList" required="true">
		<cfargument name="notes" type="string" required="false" default="">
		<cfargument name="serviceText" type="string" required="false" default="">		

		<cfquery name="AddServiceListQuery" datasource="#variables.dsn#">
			INSERT INTO
				AssessmentToolDetail(iAssessmentToolMaster_ID
									,iServiceList_ID
									,cRowStartUser_ID
									,Service_text
									,cNotes)
				Values(#variables.id#
					  ,#ServiceList.GetId()#				
					  <cfif variables.rowStartUserId neq "">
					  ,'#variables.rowStartUserId#'
					  <cfelse>
					  ,NULL
					  </cfif>
					  <cfif ListFirst( Arguments.serviceText,'_' ) EQ ServiceList.GetId() >
					  	,'#Left(ListLast( Arguments.serviceText,'_' ),1)# '
					  <cfelse>
					  	,NULL
					  </cfif>
					  ,'#arguments.notes#')
		</cfquery>
		<!--- Project - 88898  Added query for old assessments to pull in new assessments notes --->
		<cfquery name="AddServiceListQuery" datasource="#variables.dsn#">
			INSERT INTO
				AssessmentToolDetail_Old(iAssessmentToolMaster_ID
									,iServiceList_ID
									,cRowStartUser_ID
									,Service_text
									,cNotes)
				Values(#variables.id#
					  ,#ServiceList.GetId()#				
					  <cfif variables.rowStartUserId neq "">
					  ,'#variables.rowStartUserId#'
					  <cfelse>
					  ,NULL
					  </cfif>
					  <cfif ListFirst( Arguments.serviceText,'_' ) EQ ServiceList.GetId() >
					  	,'#Left(ListLast( Arguments.serviceText,'_' ),1)# '
					  <cfelse>
					  	,NULL
					  </cfif>
					  ,'#arguments.notes#')
		</cfquery>
	</cffunction>
	
	<!--- 02/12/2010 Sathya as per project 41315-B added this --->
 <cffunction name="AddServiceCategory" access="public" returntype="void" output="false">
		<cfargument name="ServiceCategory" type="Components.ServiceCategory" required="true">
		<cfargument name="notes" type="string" required="false" default="">
		
		<cfquery name="AddServiceCategoryQuery" datasource="#variables.dsn#">
			INSERT INTO
				AssessmentToolDetail(iAssessmentToolMaster_ID
									,iServiceCategory_ID
									,cRowStartUser_ID
									,cNotes)
				Values(#variables.id#
					  ,#ServiceCategory.GetId()#
					  <cfif variables.rowStartUserId neq "">
					  ,'#variables.rowStartUserId#'
					  <cfelse>
					  ,NULL
					  </cfif>
					  ,'#arguments.notes#')
		</cfquery>
		<cfquery name="AddServiceCategoryQuery" datasource="#variables.dsn#">
			INSERT INTO
				AssessmentToolDetail_Old(iAssessmentToolMaster_ID
									,iServiceCategory_ID
									,cRowStartUser_ID
									,cNotes)
				Values(#variables.id#
					  ,#ServiceCategory.GetId()#
					  <cfif variables.rowStartUserId neq "">
					  ,'#variables.rowStartUserId#'
					  <cfelse>
					  ,NULL
					  </cfif>
					  ,'#arguments.notes#')
		</cfquery>
	</cffunction> 
<!---This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code) --->	
		<cffunction name="AddSubService" access="public" returntype="void" output="false">
		<cfargument name="SubServiceList" type="Components.SubServiceList" required="true">
		
		<cfquery name="AddSubServiceListQuery" datasource="#variables.dsn#">
			INSERT INTO
				AssessmentToolDetail(iAssessmentToolMaster_ID
									,iSubServiceList_ID
									,cRowStartUser_ID)
				Values(#variables.id#
					  ,#SubServiceList.GetId()#
					  <cfif variables.rowStartUserId neq "">
					  ,'#variables.rowStartUserId#'
					  <cfelse>
					  ,NULL
					  </cfif>)
		</cfquery>
	</cffunction>
	
	<cffunction name="AddServicePlan" access="public" returntype="void" output="false">
		<cfargument name="statuscode" type="string" required="false" default="">
		<cfargument name="diagnosis" type="string" required="false" default="">		
		<cfargument name="Primary" type="string" required="false" default="">
		<cfargument name="Secondary" type="string" required="false" default="">
		<cfargument name="Third" type="string" required="false" default="">
		<cfargument name="Fourth" type="string" required="false" default="">
		<cfargument name="Fifth" type="string" required="false" default="">
		<cfargument name="Sixth" type="string" required="false" default="">
		<cfargument name="Seventh" type="string" required="false" default="">
		<cfargument name="allergies" type="string" required="false" default="">
		<cfargument name="otherservices" type="string" required="false" default="">
		<cfargument name="tenantId" type="string" required="false" default="">
		<cfargument name="residentId" type="string" required="false" default="">
		
		<cfquery name="NewServicePlan" datasource="#variables.dsn#">
			INSERT INTO
				tbl_AssessmentServicePlan
					(int_AssessmentToolMaster_ID					 
					 ,int_Tenant_Id
					 ,int_Resident_Id
					 ,char_Status
					 ,txt_Diagnosis
					 ,iPrimary
					 ,iSecondary
					 ,iThird
					 ,iFourth
					 ,iFifth
					 ,iSixth
					 ,iSeventh
					 ,txt_Allergies
					 ,txt_OtherServices
					 ,dt_RowStart
					 ,char_RowStartUser_Id)
				VALUES
					(#variables.id#
					 <cfif arguments.tenantId neq 0>,#arguments.tenantId#<cfelse>,Null</cfif>
					 <!--- <cfif arguments.residentId neq 0>,#arguments.residentId#<cfelse>,Null</cfif> --->
					 ,Null
					 ,'#arguments.statuscode#'
					 ,'#arguments.diagnosis#'
					 ,'#arguments.Primary#'
					 ,'#arguments.Secondary#'
					 ,'#arguments.Third#'
					 ,'#arguments.Fourth#'
					 ,'#arguments.Fifth#'
					 ,'#arguments.Sixth#'
					 ,'#arguments.Seventh#'
					 ,'#arguments.allergies#'
					 ,'#arguments.otherservices#'
					 ,<cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />    <!---'#variables.reviewStartDate#'--->
					 <cfif variables.rowStartUserId neq "">
					 ,'#variables.rowStartUserId#'
					 <cfelse>
					 ,NULL
					 </cfif>
					 )										
		</cfquery>		
	</cffunction>
	
	<cffunction name="Save" access="public" output="true" returntype="void">
		<cfargument name="NoteArray" required="true" type="array">
		<cfargument name="ServiceTextArray" required="no" type="array">
		
		<cfset myList = "">
			<cfloop from="1" to="#Arraylen(arguments.ServiceTextArray)#" index="index">
				<Cfif right(arguments.ServiceTextArray[index],3) EQ "yes">
					<cfset myList = listAppend(myList, listFirst(arguments.ServiceTextArray[index], '_'))>
				</Cfif>
			</cfloop>
		
		<cftransaction>		
			<!--- Get the total points for the services and subservices --->
			<cfif IsArray(variables.ServiceArray) AND ArrayLen(variables.ServiceArray) gt 0>
				<cfquery name="ServicePointsQuery" datasource="#variables.dsn#">
					SELECT
						SUM(fWeight) as ServicePoints
					FROM
						ServiceList
					WHERE
						iServiceList_ID IN (#myList#)
				</cfquery>
				
				<!--- check for nurse approval --->
				<cfquery name="CheckNurseApprovalQuery" datasource="#variables.dsn#">
					SELECT
						bApprovalRequired
					FROM
						ServiceList
					WHERE
						iServiceList_ID IN (#ArrayToList(variables.ServiceArray)#)
					AND
						bApprovalRequired = 1
				</cfquery>
				
				<cfif CheckNurseApprovalQuery.RecordCount GT 0>
					<cfset variables.isApprovalRequired = true>
				</cfif>
			<cfelse>
				<cfset ServicePointsQuery.ServicePoints = 0>
			</cfif>
			
			<cfif IsArray(variables.SubServiceArray) AND ArrayLen(variables.SubServiceArray) gt 0>
				<cfquery name="SubServicePointsQuery" datasource="#variables.dsn#">
					SELECT
						SUM(fWeight) as SubServicePoints
					FROM
						SubServiceList
					WHERE
						iSubServiceList_ID IN (#ArrayToList(variables.SubServiceArray)#)
				</cfquery>
				
				<!--- check for nurse approval if it isn't already required --->
				<cfif NOT variables.isApprovalRequired>
					<cfquery name="CheckNurseApprovalQuery" datasource="#variables.dsn#">
						SELECT
							bApprovalRequired
						FROM
							SubServiceList
						WHERE
							iSubServiceList_ID IN (#ArrayToList(variables.SubServiceArray)#)
						AND
							bApprovalRequired = 1
					</cfquery>
					
					<cfif CheckNurseApprovalQuery.RecordCount GT 0>
						<cfset variables.isApprovalRequired = true>
					</cfif>
				</cfif>
			<cfelse>
				<cfset SubServicePointsQuery.SubServicePoints = 0>
			</cfif>
			
			<cfset totalPoints = ServicePointsQuery.ServicePoints + SubServicePointsQuery.SubServicePoints>
			
			
			<!--- step 1 is insert the master record into the database --->
			<!--- rsa - 2/28/08 - added dtreviewend to this query --->
			<cfquery name="SaveAssessmentQuery" datasource="#variables.dsn#">
					UPDATE
						AssessmentToolMaster
					SET 
						 iAssessmentTool_ID = #variables.assessmentToolId#
						,iTenant_id = 	#variables.tenantId#
						,iResident_id = <cfif variables.residentId neq 0>#variables.residentId#<cfelse>NULL</cfif>
						,iReviewType_ID = #variables.reviewTypeId#
						,iSPoints =  #totalPoints#  <!--- <cfif arguments.points neq 0>,#totalPoints#<cfelse>,1</cfif> --->  
						,dtReviewStart = '#variables.reviewStartDate#' <!---<cfqueryparam value="#variables.reviewStartDate#" cfsqltype="cf_sql_timestamp" />--->
						,bBillingActive = #BoolToBit(variables.isBillingActive)#
						,dtBillingActive = '#variables.billingActiveDate#'
						,bFinalized = #BoolToBit(variables.isFinalized)#
						,bApprovalRequired = #BoolToBit(variables.isApprovalRequired)#
						,cApprovedBy = <cfif variables.approvedBy neq "">#variables.approvedBy#<cfelse>NULL</cfif>
						,dtNextReview = '#variables.nextReviewDate#'
						,cRowStartUser_id = '#variables.rowStartUserId#'
						<cfif IsDate(variables.reviewEndDate)>
						,dtReviewEnd = '#variables.reviewEndDate#'
						</cfif>
				WHERE
						iAssessmentToolMaster_id = #variables.id#
			</cfquery>
			
			<!--- ADDED BY JAIME CRUZ AS PART OF THE SERVICE PLAN PROJECT 06/25/2008 --->
			<cfquery name="qSelectServicePlan" datasource="#variables.dsn#">
			SELECT
				int_Plan_Id
			FROM
				tbl_AssessmentServicePlan
			WHERE
				int_AssessmentToolMaster_Id = #variables.id#
			</cfquery>
			
			<cfif qSelectServicePlan.recordcount eq 0>
			
			<cfquery name="SaveServicePlan" datasource="#variables.dsn#">
			INSERT INTO
				tbl_AssessmentServicePlan
					(int_AssessmentToolMaster_ID
					 ,int_Tenant_Id
					 ,int_Resident_Id
					 ,char_Status
					 ,txt_Diagnosis
					 ,iPrimary
					 ,iSecondary
					 ,iThird
					 ,iFourth
					 ,iFifth
					 ,iSixth
					 ,iSeventh
					 ,txt_Allergies
					 ,txt_OtherServices
					 ,dt_RowStart
					 ,char_RowStartUser_Id)
				VALUES
					(#variables.id#
					 ,#variables.tenantId#
					 <cfif variables.residentId neq 0>,#variables.residentId#<cfelse>,Null</cfif>
					 <cfif #variables.statuscode# neq "">
					 ,'#variables.statuscode#'
					 <cfelse>
					 ,NULL
					 </cfif>
					 <cfif #variables.diagnosis# neq "">
					 ,'#variables.diagnosis#'
					 <cfelse>
					 ,NULL
					 </cfif>
					 <cfif #variables.Primary# neq "">    <!--- Added 88898 - 05/03/2012   7 dropdowns --->
					 ,'#variables.Primary#'
					 <cfelse>
					 ,NULL
					 </cfif>
					 <cfif #variables.Secondary# neq "">
					 ,'#variables.Secondary#'
					 <cfelse>
					 ,NULL
					 </cfif>
					 <cfif #variables.Third# neq "">
					 ,'#variables.Third#'
					 <cfelse>
					 ,NULL
					 </cfif>
					 <cfif #variables.Fourth# neq "">
					 ,'#variables.Fourth#'
					 <cfelse>
					 ,NULL
					 </cfif>
					 <cfif #variables.Fifth# neq "">
					 ,'#variables.Fifth#'
					 <cfelse>
					 ,NULL
					 </cfif>
					 <cfif #variables.Sixth# neq "">
					 ,'#variables.Sixth#'
					 <cfelse>
					 ,NULL
					 </cfif>
					 <cfif #variables.Seventh# neq "">
					 ,'#variables.Seventh#'
					 <cfelse>
					 ,NULL
					 </cfif>                         <!--- Added 88898 - 05/03/2012   end --->
					 <cfif #variables.allergies# neq "">
					 ,'#variables.allergies#'
					 <cfelse>
					 ,NULL
					 </cfif>
					 <cfif #variables.otherservices# neq "">
					 ,'#variables.otherservices#'
					 <cfelse>
					 ,NULL
					 </cfif>
					 ,<cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />
					 <cfif #variables.rowStartUserId# neq "">
					 ,'#variables.rowStartUserId#'
					 <cfelse>
					 ,NULL
					 </cfif>
					 )							
			</cfquery>
			
			<cfelse>
			
			<cfquery name="SaveServicePlan" datasource="#variables.dsn#">
			UPDATE
				tbl_AssessmentServicePlan
			SET
				 char_Status = '#variables.statuscode#'
				,txt_Diagnosis = '#variables.diagnosis#'
				,iPrimary = '#variables.Primary#'
				,iSecondary = '#variables.Secondary#'
				,iThird = '#variables.Third#'
				,iFourth = '#variables.Fourth#'
				,iFifth = '#variables.Fifth#'
				,iSixth = '#variables.Sixth#'
				,iSeventh = '#variables.Seventh#'
				,txt_Allergies = '#variables.allergies#'
				,txt_OtherServices = '#variables.otherservices#'
				,dt_RowStart =  '#variables.reviewStartDate#'
				,char_RowStartUser_Id = <cfif variables.rowStartUserId neq "">'#variables.rowStartUserId#'<cfelse>NULL</cfif>
			WHERE
				int_AssessmentToolMaster_Id = #variables.id#							
			</cfquery>		
			
			</cfif>
			
			<!--- remove any saved services and sub services for this assessment --->
			<cfquery name="RemoveServicesQuery" datasource="#variables.dsn#">
					UPDATE
						AssessmentToolDetail
					SET
						 dtRowDeleted = #CreateODBCDateTime(now())#
						,cRowDeletedUser_ID = '#variables.rowStartUserId#'
					WHERE
						iAssessmentToolMaster_ID = #variables.id#
			</cfquery>
			
			<cfscript>
				sendNurseMail = false;
				
				//02/12/2010 Sathya as per project 41315-B added this for service 
			for(i = 1; i lte ArrayLen(variables.ServiceCategoryArray); i = i +1)
				{
					theNotes = "";
					
					ServiceCategory = CreateObject("Component","Components.ServiceCategory");
					ServiceCategory.Init(variables.ServiceCategoryArray[i],variables.dsn);
					
					//loop through the notes to see if there is a note for this service cateogory
					for(x = 1; x lte ArrayLen(arguments.NoteArray); x = x +1)
					{	
						if(arguments.NoteArray[x][1] eq ServiceCategory.GetId())
						{
							///now get the notes
							theNotes = arguments.NoteArray[x][2];
							break;
						}
					}
					
					AddServiceCategory(ServiceCategory,theNotes);					
				}
	 // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
				
				
				//loop through the services and add them to the details
				for(i = 1; i lte ArrayLen(variables.ServiceArray); i = i +1)
				{
					theNotes = "";
					theServciceText = "";
										
					ServiceList = CreateObject("Component","Components.ServiceList");
					ServiceList.Init(variables.ServiceArray[i],variables.dsn);
					
					if(ServiceList.GetApprovalRequired() AND NOT sendNurseMail)
					{
						sendNurseMail = true;
					}
					
					//loop through the notes to see if there is a note for this service
					/*for(x = 1; x lte ArrayLen(arguments.NoteArray); x = x +1)
					{	
						if(arguments.NoteArray[x][1] eq ServiceList.GetId())
						{
							///now get the notes
							theNotes = arguments.NoteArray[x][2];
							break;
						}
					}*/
					notesArrayPosition = ArrayFindByDimension(NoteArray,ServiceList.GetId(),1) ;
					if( notesArrayPosition GT 0 )
					{
						theNotes = arguments.NoteArray[notesArrayPosition][2];					
					}

					serviceTextArrayPosition = arrFind(ServiceTextArray,ServiceList.GetId()&'_yes') ;
					if( serviceTextArrayPosition EQ 0 )
					{
						serviceTextArrayPosition = arrFind(ServiceTextArray,ServiceList.GetId()&'_no') ;
					}
					
					if( serviceTextArrayPosition GT 0 )
					{
						theServciceText = arguments.ServiceTextArray [serviceTextArrayPosition ];
					}
					
					if( notesArrayPosition GT 0  or  serviceTextArrayPosition GT 0)
					{
						AddService(ServiceList,theNotes,theServciceText);					
					}
					
				}
				
				//loop through the services and add them to the details
				for(i = 1; i lte ArrayLen(variables.SubServiceArray); i = i +1)
				{
					if(ServiceList.GetApprovalRequired() AND NOT sendNurseMail)
					{
						sendNurseMail = true;
					}
					
					SubServiceList = CreateObject("Component","Components.SubServiceList");
					SubServiceList.Init(variables.SubServiceArray[i],variables.dsn);
					
					AddSubService(SubServiceList);					
				}
			</cfscript>
		</cftransaction>
		
		<!--- lastly e-mail the nurse --->
		<cfscript>
			if(variables.isApprovalRequired AND variables.isFinalized)
			{
				EmailNurse();
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="Activate" access="public" output="false" returntype="void">
		<cfargument name="currentPeriod" type="string" required="true">
		<cfargument name="billingActiveDate" type="string" required="true">
		<cfargument name="userId" type="string" required="true">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="solomonDsn" type="string" required="true">
		<!--- <cfargument name="leadTrackDsn" type="string" required="true"> --->
		
		<cfscript>	
			//set the month variables for the start and end dates
			activePeriod = NumberFormat(DatePart("m",arguments.billingActiveDate),00) & DatePart("yyyy",arguments.billingActiveDate);
			activePeriodStart = Month(arguments.billingActiveDate) & "/01/" & Year(arguments.billingActiveDate);
			activePeriodEnd = Month(arguments.billingActiveDate) & "/" & DaysInMonth(arguments.billingActiveDate) & "/" & Year(arguments.billingActiveDate);
			//convert current period to the first and last day of month
			currentPeriodStart = LEFT(arguments.currentPeriod,2) & "/01/" & RIGHT(arguments.currentPeriod,4);
			currentPeriodEnd =  LEFT(arguments.currentPeriod,2) & "/" & DaysInMonth(currentPeriodStart) & "/" & RIGHT(arguments.currentPeriod,4);
			// 112486 - correction for previous month when current month is january (01)			
		if (Month(arguments.currentPeriod) eq '01'){		 
		   PreviousPeriod = DatePart("yyyy",((arguments.currentPeriod) -1)) & "12";
		   PreviousMonthstart = "12" & "/01/" & (RIGHT(arguments.currentPeriod,4)-1);
		   PreviousMonthend =  "12" & "/31/" & (RIGHT(arguments.currentPeriod,4)-1);		    
		   }
		else {
		    PreviousPeriod = DatePart("yyyy",arguments.currentPeriod) & NumberFormat(DatePart("m",arguments.currentPeriod)-1,00);
  		    PreviousMonthstart = (LEFT(arguments.currentPeriod,2)-1) & "/01/" & RIGHT(arguments.currentPeriod,4);
		    PreviousMonthend =  (Month(arguments.currentPeriod)-1) & "/" & DaysInMonth(PreviousMonthstart) & "/" & Year(arguments.currentPeriod); 
			}
			//PreviousPeriod = DatePart("yyyy",arguments.currentPeriod) & NumberFormat(DatePart("m",arguments.currentPeriod)-1,00);
       //	PreviousMonthstart = (LEFT(arguments.currentPeriod,2)-1) & "/01/" & RIGHT(arguments.currentPeriod,4);
      //	PreviousMonthend =  (Month(arguments.currentPeriod)-1) & "/" & DaysInMonth(PreviousMonthstart) & "/" & Year(arguments.currentPeriod);
			//check if this assessment's active date is before the current month
			activeMonthDiff = DateDiff("m",currentPeriod,activePeriodStart);
			
			if (activeMonthDiff neq 0) 
			{ 
				step = (activeMonthDiff/ abs(activeMonthDiff)); 
			} 
			else 
			{ 
				step = 1; 
			}
			
			//get a tenant object for this tenant
			Tenant = this.GetTenant();
			
			tenantState = Tenant.GetState().GetTenantStateCode();
			newLevel = GetLevelType().GetDescription();
		</cfscript>
		<!--- get a timestamp from the database to use in all queries --->
		<cfquery name="GetTimeStampQuery" datasource="#variables.dsn#">
			SELECT
				GetDate() as timeStamp
		</cfquery>
		
		<cfscript>
			timeStamp = GetTimeStampQuery.timeStamp;
		</cfscript>
		
		<!--- set accounting stamp --->
		<cfquery name="AcctStamp" datasource="#arguments.solomonDsn#">
			SELECT 
				CAST(Right(CurrPerNbr,2) + '/01/' + LEFT(CurrPerNbr,4) AS datetime) AS solomonPeriod 
			FROM	
				ARSETUP (NOLOCK)
		</cfquery>
		
				
		<cfquery name="TenantQuery" datasource="#variables.dsn#">
			select 
				 t.itenant_id
				,t.csleveltypeset
				,l.cdescription AS level
				,iresidencytype_id
				,t.dtmovein
				,t.ihouse_id
				,t.itenantStateCode_id
				,t.iAptAddress_ID
			from 
				rw.vw_tenant_history_with_state t
			join 
				rw.vw_servicelevel_history l on l.csleveltypeset = t.csleveltypeset
					and 
				GetDate() between l.dtrowstart and isNull(l.dtrowend,getdate())
					and 
				t.ispoints between l.ispointsmin and l.ispointsmax and l.dtrowdeleted is null
			where 
				t.tendtrowdeleted is null 
			and 
				t.statedtrowdeleted is null
			and 
				t.itenant_id = #variables.tenantid#
			and 
				GetDate() between t.statedtrowstart and isNull(t.statedtrowend,getdate())
			and 
				GetDate() between t.tendtrowstart and isNull(t.tendtrowend,getdate())
		</cfquery>

<!--- 		<cfquery name="qresident" datasource="#arguments.leadTrackDsn#">
			select 
				iResident_id
			from 
				residentstate 
			where 
				dtrowdeleted is null
			and 
				itenant_id = #TenantQuery.itenant_id#
		</cfquery> --->
			
<!--- 		<cfif qresident.recordcount gt 0>
			<cfset iresident_id = qresident.iresident_id>
		<cfelse> --->
			<cfset iresident_id = 0>
		<!--- </cfif> --->
		<!--- look for prior assessment information --->
		<cfquery name="qPriorAssessment" datasource="#variables.dsn#">
			select 
				count(iassessmenttoolmaster_id) as toolcount
			from 
				assessmenttoolmaster 
			where 
				dtrowdeleted is null 
			and 
				itenant_id = #TenantQuery.itenant_id#
			and 
				bfinalized is not null 
			and 
				bbillingactive is not null
		</cfquery>
				
		<!--- if tool and tenant slevelset are not the same change and create log --->
		<cfif (GetAssessmentTool().GetSLevelTypeSet() NEQ TenantQuery.csleveltypeset) OR tenantState EQ 4 OR TenantQuery.csleveltypeset EQ 9>
			<!--- update resident to new sleveltypeset --->
			<cfquery name="qSetUpdate" datasource="#variables.dsn#">
				update 
					tenant
				set 
					 dtrowstart=getdate()
					,irowstartuser_id = 0
					,crowstartuser_id='assess_tool_chng'
					,csleveltypeset = '#GetAssessmentTool().GetSLevelTypeSet()#'
					<cfif tenantState eq 4>
					,dtrowdeleted = null
					,irowdeleteduser_id = null
					</cfif>
				where 
					itenant_id = #trim(TenantQuery.itenant_id)#
			</cfquery>
		
			<!--- create log for change of slevel set on tenant --->
			<cfquery name="WriteActivity" datasource="#variables.dsn#">
				insert into 
					ActivityLog(iActivity_ID
							   ,dtActualEffective
							   ,iTenant_ID
							   ,iHouse_ID
							   ,iAptAddress_ID
							   ,iSPoints
							   ,dtAcctStamp
							   ,iRowStartUser_ID
							   ,dtRowStart
							   ,crowstartuser_id)
				values(10
					  ,#CreateODBCDateTime(arguments.billingActiveDate)# 
					  ,#TenantQuery.itenant_id#
					  ,#TenantQuery.ihouse_id#
					  ,<cfif TenantQuery.iTenantStateCode_ID EQ 1>NULL<cfelse>#TenantQuery.iAptAddress_ID#</cfif>
					  <cfif variables.points neq 0>,#variables.points#<cfelse>,1</cfif>  <!---,#variables.points#--->
					  ,#CreateODBCDateTime(AcctStamp.solomonPeriod)#
					  ,#arguments.userID#
					  ,'#timeStamp#'
					  ,'#arguments.username#')
			</cfquery>
		</cfif>
		
		
		<cftransaction>
			<!--- set selective to active (1st) and other current active to not active (2nd query)--->
			<cfquery name="qsetActive" datasource="#variables.dsn#">
				update 
					assessmenttoolmaster
				set 
					 bBillingActive = 1
					,dtBillingActive=#CreateODBCDateTime(arguments.billingActiveDate)#
					,dtrowstart=getdate()
					,crowstartuser_id='#arguments.username#'
				where 
					iassessmenttoolmaster_id = #variables.id#
			</cfquery>
			
			<!--- deactivate the previous assessment --->
			<cfquery name="qdeactivate" datasource="#variables.dsn#">
				update 
					assessmenttoolmaster
				set 
					 bBillingActive = null
					,dtrowstart= #CreateODBCDateTime(now())#
					,crowstartuser_id = '#arguments.username#'
					<!---,ispoints = #variables.points#--->
				where 
					iassessmenttoolmaster_id <> #variables.id#
				and 
					(itenant_id = #TenantQuery.itenant_id#) <!--- (or (iresident_id = #variables.residentId#)) --->
				and 
					bBillingActive is not null
				and 
					bfinalized is not null
			</cfquery>
			
			<!---08/02/2006 MLAW change the select statement --->
			<cfquery name="qcheck" datasource="#variables.dsn#">
				select
					*
				from
					assessmenttoolmaster
				where
					 (itenant_id = #TenantQuery.itenant_id#) <!--- or (iresident_id = #variables.residentId#)) --->
				and 
					bBillingActive is not null
				and 
					bfinalized is not null
			</cfquery>
		
			<!--- write to reporting log --->
			<cfquery name="WriteActivity" datasource="#variables.dsn#">
				insert into 
					ActivityLog(iActivity_ID
							   ,dtActualEffective
							   ,iTenant_ID
							   ,iHouse_ID
							   ,iAptAddress_ID
							   ,iSPoints
							   ,dtAcctStamp
							   ,iRowStartUser_ID
							   ,dtRowStart
							   ,crowstartuser_id)
				values(7
					  ,#CreateODBCDateTime(arguments.billingActiveDate)#
					  ,#trim(TenantQuery.itenant_id)#
					  ,#trim(TenantQuery.ihouse_id)#
					  <cfif TenantQuery.iTenantStateCode_ID EQ 1>
					  ,NULL
					  <cfelse>
					  ,#trim(TenantQuery.iAptAddress_ID)#
					  </cfif>
					  ,#variables.points#      <!---<cfif variables.points neq 0>,#variables.points#<cfelse>,1</cfif>--->
					  ,#CreateODBCDateTime(AcctStamp.solomonPeriod)#
					  ,#trim(arguments.userID)#
					  ,'#trim(TimeStamp)#'
					  ,'#trim(arguments.username)#')
			</cfquery>
		
			<!--- update service points in tenantstate --->
			<cfquery name="ServicePoints" datasource="#variables.dsn#">
				update 
					TenantState 
				set 
					 iSPoints = #variables.points#   <!---<cfif variables.points neq 0>,#variables.points#<cfelse>,1</cfif>--->
					,dtSPEvaluation = #CreateODBCDateTime(arguments.billingActiveDate)# 
					,iRowStartUser_ID = #arguments.userID#
					,crowstartuser_id = '#arguments.username#' 
					,dtRowStart = '#trim(TimeStamp)#'
					<cfif tenantState eq 4>
					,itenantstatecode_id = 1 
					,iAptAddress_ID = null 
					,dtMoveIn = null
					,dtNoticeDate = null 
					,dtChargeThrough = null 
					,dtMoveOut = null 
					,iMoveReasonType_ID = null
					</cfif>
				where 
					iTenant_ID = #variables.tenantId#
			</cfquery>
		
			<!--- determin upated level --->
			<cfquery name="qUpdatedLevel" datasource="#variables.dsn#">
				select 
					l.cdescription 
				from 
					tenant t
				join 
					tenantstate s on s.itenant_id = t.itenant_id and s.dtrowdeleted is null
						and 
					t.dtrowdeleted is null
				join 
					sleveltype l on l.csleveltypeset = t.csleveltypeset 
						and
					s.ispoints between l.ispointsmin and l.ispointsmax
				where 
					t.itenant_id = #variables.tenantId#
			</cfquery>
			
			<!--- skip prorating and care charges if this is a medicaid resident or previous resident--->
			<cfif TenantQuery.iresidencytype_id neq 2 and tenantState neq 4>
					<!--- retrieve charge type for Private Care Timing Adjustment currently = 1645 --->
					<cfquery name="qCareTimeAdj" datasource="#variables.dsn#">
						select top 1 
							ichargetype_id 
						from 
							chargetype 
						where 
							dtrowdeleted is null 
						and 
							cgrouping='TACDP'
					</cfquery>
					
					<cfset ct1645=qCareTimeAdj.ichargetype_id>

					<!--- 9/21/05 - APAUL - Update cGrouping with 'RD' instead of 'RDDD' --->
					<cfquery name="qCareDisc" datasource="#variables.dsn#">
		            	SELECT
							ichargetype_id
						FROM
							chargetype
						WHERE
							dtrowdeleted is null
						AND
							cGrouping = 'RD'
		            </cfquery>
		            
					<cfset ct1657=qCareDisc.ichargetype_id>
		
					<!--- retrieve current monthly invoice --->
					<cfquery name="qCurrentInvoice" datasource="#variables.dsn#">
						select distinct	
							m.iinvoicemaster_id, 
							m.cappliestoacctperiod
						from 
							invoicemaster m
						left join 
							invoicedetail d on d.iinvoicemaster_id = m.iinvoicemaster_id 
								and 
							d.dtrowdeleted is null
								and 
							m.bfinalized is null 
								and 
							m.bmoveininvoice is null 
								and 
							m.bmoveoutinvoice is null
								and
							m.dtrowdeleted is null							
						where 
							d.itenant_id = #variables.tenantId#
					</cfquery>
		
					<cfif qCurrentInvoice.recordcount eq 0>
						<cfthrow message="No invoice found for tenant." detail="Invoice for tenant #variables.tenantId# was not found while activating assessment #variables.id#.">
					<cfabort>
					</cfif>
		
					<!--- reverse ichargetype_id 1657 --->
					<!--- loop through months ----> 
					<cfloop from="0" to="#activeMonthDiff#" step="#step#" index="i">
						<cfset nDate=dateadd("m",i,arguments.currentPeriod)>
		
						<!--- retrieve current months care charges ---->
						<cfquery name="qMonthData" datasource="#variables.dsn#">
							select distinct 
								d.mamount, d.bisRentAdj as RentAdj
							from 
								invoicemaster m
							inner join 
								invoicedetail d on d.iinvoicemaster_id = m.iinvoicemaster_id 
									and 
								d.dtrowdeleted is null
									and 
								m.bmoveoutinvoice is null 
								<cfif createodbcdate(nDate) eq createodbcdate(arguments.currentPeriod)>
									and 
										m.bfinalized is not null
								<cfelse> 
									and 
										m.bfinalized is not null 
								</cfif>
							inner join 
								chargetype y on y.ichargetype_id = d.ichargetype_id 
									and 
								cGrouping='RD'
							where 
								d.itenant_id = #variables.tenantId# 
							and 
								m.bfinalized is not null
							and (m.cappliestoacctperiod = '#trim(dateformat(ndate,"yyyymm"))#'
									or 
								(m.bmoveininvoice is not null 
									and 
								d.cappliestoacctperiod='#trim(dateformat(ndate,"yyyymm"))#')) order by RentAdj Asc
						</cfquery>
						<cfquery name="qMonthData1" datasource="#variables.dsn#">
						  select top 1 * from Invoicedetail where itenant_id = #variables.tenantId# and iChargetype_id=91 order by iInvoicedetail_id desc
						</cfquery>
						<cfif qMonthData.mAmount eq qMonthData1.mAmount>
						  <cfset oldamount = qMonthData.mAmount>
						<cfelse>
						  <cfset oldamount = qMonthData1.mAmount>
						</cfif>
						
						<!---<cfset oldamount = qMonthData.mAmount>--->
		
						<cfif qmonthdata.recordcount eq 0>
							<!--- if the form evaluation date three months or more in past from the tips month--->
							<cfif createodbcdate(arguments.billingActiveDate) lt createodbcdate(dateadd('h',-3,arguments.currentPeriod))>
								<cfset thisevaldate =createOdbcDateTime(dateformat(arguments.billingActiveDate,"mm/dd/yyyy") & " 23:59:59")>
							<cfelseif createodbcdate(arguments.billingActiveDate) gt createodbcdate(dateadd('h',-3,arguments.currentPeriod))>
								<cfset thisevaldate='DateAdd(m,-1,getDate())'>
							<cfelse>
									<cfset thisevaldate=evaldate>
							</cfif>
							
							<cfquery name="qptMarketData" datasource="#dsn#">
								select 
									vch.*
								from 
									rw.vw_tenant_history vt
								join 
									rw.vw_tenantstate_history vts on vts.itenant_id = vt.itenant_id
										and 
									vt.dtrowdeleted is null 
										and 
									#thisevaldate# between vt.dtrowstart and isNull(vt.dtrowend,getdate())
										and 
									vts.dtrowdeleted is null 
										and 
									#thisevaldate# between vts.dtrowstart and isNull(vts.dtrowend,getdate())
									and 
										vts.itenantstatecode_id = 2
								join 
									rw.vw_aptaddress_history vah on vah.iaptaddress_id = vts.iaptaddress_id
										and 
									vah.dtrowdeleted is null 
										and 
									#thisevaldate# between vah.dtrowstart and isNull(vah.dtrowend,getdate())
								join 
									rw.vw_apttype_history vap on vap.iapttype_id = vah.iapttype_id
										and 
									vap.dtrowdeleted is null 
										and 
									#thisevaldate# between vap.dtrowstart 
										and 
									isNull(vap.dtrowend,getdate())
								join 
									rw.vw_servicelevel_history vsl on vsl.csleveltypeset = vt.csleveltypeset 
										and 
									vsl.dtrowdeleted is null
										and 
									vts.ispoints between vsl.ispointsmin and vsl.ispointsmax
										and 
									#thisevaldate# between vsl.dtrowstart and isNull(vsl.dtrowend,getdate())
								join 
									rw.vw_charges_history vch on vch.ihouse_id = vt.ihouse_id 
										and 
									vch.dtrowdeleted is null
										and 
									vch.iSLevelType_ID = vsl.iSLevelType_ID
										and 
									#thisevaldate# between vch.dteffectivestart and vch.dteffectiveend
										and 
									#thisevaldate# between vch.dtrowstart and isNull(vch.dtrowend,getdate())
								join 
									rw.vw_chargetype_history vcth on vcth.ichargetype_id = vch.ichargetype_id 
										and 
									vcth.cGrouping='RD'
										and 
									#thisevaldate# between vcth.dtrowstart and isNull(vcth.dtrowend,getdate())
								where 
									vt.itenant_id = #variables.tenantid#
								order by 
									vt.itenant_id
							</cfquery>
		
		
							<cfif qptMarketData.recordcount gt 0 and oldamount eq 0>
								<!--- if historical data is found use it--->
								<cfset oldamount = qptMarketData.mamount>
							<cfelseif oldamount neq 0>
							    <cfset oldamount = qMonthData1.mAmount>
							<cfelse>
								<cfset oldamount = 0>
							</cfif>
						</cfif>
		
						<cfif not isDefined("newamount") or newamount eq "">
							<cfset newamount = 0> 
						</cfif>

						<!--- MLAW 04/26/06 Add getdate() between dtEffectiveStart and dtEffectiveEnd logic into qnewRates query --->
						<cfif ( createodbcdate(activePeriodStart) eq createodbcdate(ndate) )
							and (daysinmonth(arguments.billingActiveDate) neq datediff("d",billingActiveDate,activePeriodEnd)+1)
							or ( createodbcdate(nDate) gte createodbcdate(activePeriodStart) ) >
							
							<cfif variables.points gt 0>
								<cfquery name="qnewRates" datasource="#variables.dsn#">
									select 
										 c.*
										,sl.cdescription AS level
										,c.cdescription chargedesc
									from 
										charges c
									join 
										chargetype ct on ct.ichargetype_id = c.ichargetype_id 
											and 
										ct.dtrowdeleted is null
											and 
										c.dtrowdeleted is null <!---and c.cchargeset = '2012Jan' --->
											and 
										c.ihouse_id = #GetTenant().GetHouse().GetId()# 
											and 
										ct.cgrouping='RD'
									join 
										tenant t on t.ihouse_id = c.ihouse_id 
											and 
										t.dtrowdeleted is null 
											and 
										isNull(t.cchargeset,1) = isNull(c.cchargeset,1)
									join 
										tenantstate ts on ts.itenant_id = t.itenant_id 
											and 
										ts.dtrowdeleted is null
									join 
									        <!---sleveltype sl on sl.cdescription = c.csleveldescription--->
										sleveltype sl on sl.isleveltype_id = c.isleveltype_id 
											and 
										sl.dtrowdeleted is null
											and 
										#variables.points# between sl.ispointsmin and sl.ispointsmax 
											 and 
										sl.csleveltypeset='#GetAssessmentTool().GetSLevelTypeSet()#' 
									where 
										t.itenant_id = #variables.tenantId#
									and 
										getdate() between c.dtEffectiveStart and c.dtEffectiveEnd
									order by 
										c.dtrowstart desc
								</cfquery>
								
								<cfif qnewRates.mAmount eq "">
									<cfset newamount = 0>
								<cfelse>
									<cfset newamount = qnewRates.mamount>
								</cfif>
								
								<cfset newctype=qnewRates.ichargetype_id>
								<cfset newlevel=qnewRates.level>
								<cfset newtypedesc=qnewRates.chargedesc>
							<cfelse>
								<cfset newamount=0>
								<cfset newctype='#ct1657#'>
								<cfset newlevel='base level'>
								<cfset newtypedesc =' Resident Care - Level 0'>
							</cfif>
						</cfif>
		
						<cfset prime = evaluate((day(billingActiveDate)-1))>
						<!---<cfset remainder = evaluate(datediff("d",arguments.billingActiveDate,activePeriodEnd)+1)>--->
						
						<cfif activeMonthDiff neq 1 >						   
						   <cfset remainder1 = evaluate(datediff("d",PreviousMonthstart,PreviousMonthend)+1)>						 
						</cfif>						
						   <cfset remainder = evaluate(datediff("d",arguments.billingActiveDate,activePeriodEnd)+1)>
						
	  
						<cftry>
							<!--- MLAW 06/07/2006 if oldamount is less than 0 then set oldamount = 0 --->
							<cfif oldamount lt 0>
								<cfset oldamount=0>
							</cfif>
							<!--- MLAW END--->
							<cfset ratediff=(newamount-oldamount)>
						<cfcatch type="any">
							<cfif auth_user eq "ALC\stephend" or remote_addr eq "10.1.4.218">
								<cfabort>
							</cfif>
						</cfcatch>
						</cftry>
		
						<!--- if the loop month is the current tips month delete care details --->
						<cfif createodbcdate(nDate) eq createodbcdate(arguments.currentPeriod)>
							<!--- delete current month care charges (working invoice)  this query was commented out, uncommented 03-26-2015 SDF--->
							 <cfquery name="qDeleteMonthData" datasource="#variables.dsn#">
								update 
									invoicedetail
								set 
									 dtrowdeleted= #CreateODBCDateTime(now())#
									,irowdeleteduser_id = #arguments.userid#
									, crowdeleteduser_id = '#arguments.username#'
								from 
									invoicemaster im
								join 
									invoicedetail inv on inv.iinvoicemaster_id = im.iinvoicemaster_id 
										and 
									inv.dtrowdeleted is null
										and 
									im.bfinalized is null 
										and 
									im.bmoveininvoice is null 
										and 
									im.bmoveoutinvoice is null
								join 
									chargetype ct on ct.ichargetype_id = inv.ichargetype_id 
										and 
									(cGrouping='RD' 
										or 
									 cGrouping='TACDP' 
									 	or 
									 ct.ichargetype_id = '#ct1657#')
								where 
									inv.itenant_id = #variables.tenantid# 
								and 
									im.cappliestoacctperiod='#trim(dateformat(ndate,"yyyymm"))#'
								and 
									inv.irowstartuser_id = 0									
								<!--- and 
									(inv.irowstartuser_id between '1800' and '2000' or inv.irowstartuser_id = 0) --->
							</cfquery> 
						</cfif>
		
						<cfif createodbcdate(nDate) eq activePeriodStart>
							<cfif TenantQuery.level eq 0>
								<cfset oldamount = newamount>
							</cfif>

							<cfif oldamount gt 0 
									and 
								  (prime gt 0 or remainder eq daysinmonth(arguments.billingActiveDate)) 
								  	and 
								   ratediff neq 0 
								   	and 
								  (createodbcdate(nDate) lt arguments.currentPeriod)>
								<cfif #TenantQuery.level# NEQ #newLevel#>	        <!--- Mamta -- Added for avoid same lvl care --->
								<cfquery name="qChargesOld" datasource="#variables.dsn#">
									insert into 
										InvoiceDetail(iInvoiceMaster_ID
													 ,iTenant_ID
													 ,iChargeType_ID
													 ,cAppliesToAcctPeriod
													 ,bIsRentAdj
													 ,dtTransaction
													 ,iQuantity
													 ,cDescription
													 ,mAmount
													 ,cComments
													 ,dtAcctStamp
													 ,iRowStartUser_ID
													 ,dtRowStart
													 ,iRowEndUser_ID
													 ,dtRowEnd
													 ,iRowDeletedUser_ID
													 ,dtRowDeleted
													 ,cRowStartUser_ID
													 ,cRowEndUser_ID
													 ,cRowDeletedUser_ID)
									values
										(#qCurrentInvoice.iinvoicemaster_id#
										,#variables.tenantid#
										,#ct1657#
										,'#dateformat(ndate,"yyyymm")#'
										,1
										,#CreateODBCDateTime(now())#
										,#remainder#
										,'Resident Care Level Change'    <!---,'lvl #TenantQuery.level# to lvl #newLevel# - #dateformat(arguments.billingActiveDate,"m/d/yy")#'--->
										,#evaluate(ratediff)#
										,'lvl #TenantQuery.level# to lvl #newLevel# - #dateformat(arguments.billingActiveDate,"m/d/yy")#'   <!---,'Resident Care Level Change'--->
										,'#AcctStamp.solomonPeriod#'
										,'#arguments.userid#'
										,getdate()
										,null
										,null
										,null
										,null
										,'#trim(arguments.username)#'
										,null
										,null)
								</cfquery>
							<cfset ndate_1 = #dateformat(ndate,"yyyymm")#>
							<cfif activeMonthDiff neq 1 AND ndate_1 neq PreviousPeriod >
								<cfquery name="qChargesOld" datasource="#variables.dsn#">
									insert into 
										InvoiceDetail(iInvoiceMaster_ID
													 ,iTenant_ID
													 ,iChargeType_ID
													 ,cAppliesToAcctPeriod
													 ,bIsRentAdj
													 ,dtTransaction
													 ,iQuantity
													 ,cDescription
													 ,mAmount
													 ,cComments
													 ,dtAcctStamp
													 ,iRowStartUser_ID
													 ,dtRowStart
													 ,iRowEndUser_ID
													 ,dtRowEnd
													 ,iRowDeletedUser_ID
													 ,dtRowDeleted
													 ,cRowStartUser_ID
													 ,cRowEndUser_ID
													 ,cRowDeletedUser_ID)
									values
										(#qCurrentInvoice.iinvoicemaster_id#
										,#variables.tenantid#
										,#ct1657#
										,'#PreviousPeriod#' <!--- '#dateformat(PreviousPeriod,"yyyymm")#' --->
										,1
										,#CreateODBCDateTime(now())#
										,#remainder1#
										,'Resident Care Level Change' <!---,'lvl #TenantQuery.level# to lvl #newLevel# - #dateformat(arguments.billingActiveDate,"m/d/yy")#'--->
										,#evaluate(ratediff)#
										,'lvl #TenantQuery.level# to lvl #newLevel# - #dateformat(arguments.billingActiveDate,"m/d/yy")#' <!---,'Resident Care Level Change'--->
										,'#AcctStamp.solomonPeriod#'
										,'#arguments.userid#'
										,getdate()
										,null
										,null
										,null
										,null
										,'#trim(arguments.username)#'
										,null
										,null)
								</cfquery>
							</cfif>	
							</cfif>      <!---mamta cfif end--->
						</cfif>
				
						<cfif newamount gt 0 and remainder gt 0 and (createodbcdate(arguments.currentPeriod) eq createodbcdate(ndate)) >
								<cfif createodbcdate(nDate) eq activePeriodStart and activePeriodStart eq arguments.currentPeriod>
									<cfset user='0'>
								<cfelse>
									<cfset newctype='#ct1645#'>
									<cfset user="#trim(session.userid)#">
								</cfif>
		
								<cfif createodbcdate(nDate) lt activePeriodStart>
									<cfset thisdays=remainder>
								<cfelse>
									<cfset thisdays=daysinmonth(nDate)>
								</cfif>
	
								<cfquery name="qChargesNew" datasource="#variables.dsn#">
								insert into 
									 InvoiceDetail(iInvoiceMaster_ID
									 			  ,iTenant_ID
									 			  ,iChargeType_ID
									 			  ,cAppliesToAcctPeriod
									 			  ,bIsRentAdj
									 			  ,dtTransaction
									 			  ,iQuantity
									 			  ,cDescription
									 			  ,mAmount
									 			  ,cComments
									 			  ,dtAcctStamp
									 			  ,iRowStartUser_ID
									 			  ,dtRowStart
									 			  ,iRowEndUser_ID
									 			  ,dtRowEnd
									 			  ,iRowDeletedUser_ID
									 			  ,dtRowDeleted
									 			  ,cRowStartUser_ID
									 			  ,cRowEndUser_ID
									 			  ,cRowDeletedUser_ID )
								VALUES(#qCurrentInvoice.iinvoicemaster_id#
									  ,#variables.tenantId#
									  ,#trim(newctype)#
									  ,'#dateformat(ndate,"yyyymm")#'
									  ,NULL
									  ,#CreateODBCDateTime(now())#
									  ,'#trim(thisdays)#'
									  ,'#trim(newtypedesc)#'
									  ,	#newamount#
									  ,'Resident Care Level Change'       <!---,'service level change'--->
									  ,'#AcctStamp.solomonPeriod#'
									  ,'#PreserveSingleQuotes(user)#'
									  ,getdate()
									  ,null
									  ,null
									  ,null
									  ,null
									  ,'#trim(arguments.username)#'
									  ,null
									  ,null)
								</cfquery>
							</cfif>
	
						<!--- MLAW 11/05/07
						<cfelse>
							<cfif (month(nDate) neq month(activePeriodStart))>
								<cfif (createodbcdate(nDate) eq arguments.currentPeriod)>
									<cfset thiscttype=91>
									<cfset thisuser=0>
								<cfelse>
									<cfset thiscttype=ct1645>
									<cfset thisuser='#trim(arguments.userid)#'>
								</cfif>
								
								<cfif NOT IsDefined("newtypedesc")>
									<cfset newtypedesc  = "#newLevel#">
								</cfif>
								
								<cfquery name="qnewrateCharges" datasource="#variables.dsn#">
									insert into 
										InvoiceDetail(iInvoiceMaster_ID,iTenant_ID ,iChargeType_ID ,cAppliesToAcctPeriod ,bIsRentAdj ,dtTransaction ,iQuantity  ,cDescription
													 ,mAmount ,cComments ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart ,iRowEndUser_ID ,dtRowEnd  ,iRowDeletedUser_ID
													 ,dtRowDeleted  ,cRowStartUser_ID ,cRowEndUser_ID  ,cRowDeletedUser_ID)
								values ('#qCurrentInvoice.iinvoicemaster_id#'
									   ,#variables.tenantId#   ,'#thiscttype#'   ,'#dateformat(ndate,"yyyymm")#'   , 1   ,getdate()
									   ,#daysinmonth(nDate)#  ,'#trim(newtypedesc)#'   ,#newamount#   ,'service level change'   ,'#AcctStamp.solomonPeriod#'
									   ,'#thisuser#'   ,getdate()   ,null   ,null   ,null   ,null
									   ,'#trim(arguments.username)#'
									   ,null
									   ,null)
								</cfquery>
							</cfif>
							--->
						</cfif>
		
						<cfif qPriorAssessment.toolcount eq 0 and TenantQuery.itenantstatecode_id eq 2 and TenantQuery.dtmovein lt "2005-01-01">
							<cfset startrecurring= createODBCDateTime(arguments.billingActiveDate)>
		
							<cfquery name="qInsertedChanges" datasource="#variables.dsn#">
								select top 1 
									inv.* 
								from 
									invoicedetail inv
								join 
									chargetype ct on ct.ichargetype_id = inv.ichargetype_id 
										and 
									ct.dtrowdeleted is null 
										and 
									ct.bSLevelType_ID = 1
								where 
									inv.dtrowdeleted is null 
								and 
									inv.cdescription like 'service%'
								and 
									inv.cComments like '%level%' 
								and 
									inv.itenant_id = #variables.tenantId#
								and 
									inv.irowstartuser_id = #arguments.userid#
								order by 
									inv.dtrowstart desc
							</cfquery>
		
							<!--- get private care daily discount ichargetype_id --->
							<cfquery name="qDiscountCT" datasource="#variables.dsn#">
								select 
									ichargetype_id 
								from 
									chargetype 
								where 
									bSLevelType_ID = 1 
								and 
									bIsDaily = 1 
								and 
									bIsDiscount = 1
							</cfquery>
		
							<!--- get corresponding charge id --->
							<cfquery name="qDiscountCareCharge" datasource="#variables.dsn#">
								select 
									* 
								from 
									charges c
								join 
									chargetype ct on ct.ichargetype_id = c.ichargetype_id 
										and 
									ct.dtrowdeleted is null
										and 
									ct.bisdaily is not null 
										and 
									c.dtrowdeleted is null
								where 
									c.ichargetype_id = #qDiscountCT.ichargetype_id#
								and 
									getdate() between dteffectivestart and dteffectiveend
							</cfquery>
		
							<cfif (TenantQuery.iresidencytype_id neq 2 and remainder gt 0 or (createodbcdatetime(ndate) gte createodbcdatetime(arguments.currentPeriod)) ) and (createodbcdate(nDate) gte createodbcdate(activePeriodStart) and qPriorAssessment.toolcount eq 0)>
								<cfif month(nDate) lt month(arguments.billingActiveDate) and year(nDate) eq year(arguments.billingActiveDate)>
									<cfset tmpquantity=prime> <!--- was remainder --->
								<cfelseif month(nDate) eq month(arguments.billingActiveDate) and year(nDate) eq year(arguments.billingActiveDate) and prime neq 0>
									<cfset tmpquantity=remainder>
								<cfelse>
									<cfset tmpquantity=daysinmonth(ndate)>
								</cfif>
								
								<cfif newamount neq 0>
									<cfset disc_ratediff=(oldamount-newamount)>
								<cfelse>
									<cfset disc_ratediff=0>
								</cfif>
								
								<cfif disc_ratediff lt 0>
									<cfif (tmpquantity eq daysinmonth(ndate) and ( createodbcdate(nDate) gte createodbcdate(activePeriodStart) and createodbcdate(nDate) gte createodbcdate(arguments.currentPeriod) ) or qDiscountCareCharge.ichargetype_id lt '1600' )>
										<cfset user='0'>
									<cfelse>
										<cfset newctype='#ct1645#'>
										<cfset user="#trim(arguments.userid)#">
									</cfif>
								</cfif>
							</cfif>
							
							<cfif NOT isDefined("disc_ratediff")>
								<cfset disc_ratediff=0>
							</cfif>
		
							<cfquery name="qcheckrecurring" datasource="#variables.dsn#">
								select 
									iRecurringCharge_ID 
								from 
									RecurringCharge 
								where 
									dtrowdeleted is null
								and 
									itenant_id = #variables.tenantId# 
								and 
									icharge_id = #qDiscountCareCharge.iCharge_id#
								and 
									rtrim(cComments)='Loyalty discount' 
								and 
									cRowStartUser_ID like 'assesstool-%'
							</cfquery>
		
							<cfif qcheckrecurring.recordcount eq 0 and TenantQuery.iresidencytype_id neq 2 and createodbcdatetime(ndate) eq createodbcdatetime(arguments.currentPeriod) and disc_ratediff lt 0	and TenantQuery.dtmovein lt "2005-01-01">
								<!--- insert recurring and qInsertedChanges.mAmount gt 0  --->
								<!--- MLAW 04/17/2006 STOP THE SYSTEM TO ADD 'Loyalty Discount' by the LOC changes --->
								<cfquery name="qRecurring" datasource="#dsn#">
									select 
										* 
									from 
										RecurringCharge 
									where 
										dtrowdeleted is null 
									and 
										itenant_id = #variables.tenantId#
									and 
										dteffectiveend >= #CreateODBCDateTime(now())# 
									and 
										dtrowstart > #CreateODBCDateTime(now())#
								</cfquery>
							</cfif>
						</cfif>
					</cfloop>
		
					<cfquery name="qout" datasource="#variables.dsn#">
						select 
							* 
						from 
							invoicedetail 
						where 
							dtrowdeleted is null
						and 
							iinvoicemaster_id = '#variables.id#'
						order by 
							cappliestoacctperiod, (mamount * iquantity)
					</cfquery>
		
					<cfquery name="qsum" datasource="#variables.dsn#">
						select 
							sum(iquantity * mamount) tsum 
						from 
							invoicedetail 
						where 
							dtrowdeleted is null
						and 
							iinvoicemaster_id = '#variables.id#'
					</cfquery>
			</cfif>
			<!--- Ganga Testing LVL concept Begin--->
	<!---<cfoutput> activePeriod -- #activePeriod# ,  activePeriodStart -- #activePeriodStart#, activePeriodEnd --  #activePeriodEnd#,<br> arguments.currentPeriod -- #arguments.currentPeriod# <br>
	------------------------------------------------------<br>
	currentPeriodStart  -- #currentPeriodStart#,   currentPeriodEnd   -- #currentPeriodEnd#,<br>  activeMonthDiff -- #activeMonthDiff#, <br> 
	GetTimeStampQuery-timeStamp -- #GetTimeStampQuery.timeStamp# ,	Solomon Current time: - #AcctStamp.solomonPeriod#  <br> 
	<cfset remainder1 = evaluate(datediff("d",PreviousMonthstart,PreviousMonthEnd)+1)>  days -- #remainder1# <br> <!---Last month end -  #PreviousMonth# <br>--->
	<cfset remainder = evaluate(datediff("d",arguments.billingActiveDate,activePeriodEnd)+1)>  days of current month -- #remainder#   <br>
	<!---<cfset npDate=dateadd("m",i,PreviousPeriod)> PreviousMonth  -- #npDate# <br>  --->
	active billing date -- #arguments.billingActiveDate#<br>
	PreviousMonthstart =#PreviousMonthstart#,  PreviousMonthend = #PreviousMonthend#  <br> PreviousPeriod -- #PreviousPeriod# <br>
	
	 Rate difference  - #evaluate(ratediff)# / Old Amount - #oldamount#  / Old amount2 -- #qMonthData.mAmount#   /  NEw Amount -- #newamount# <br>
	 New Level -- #newLevel#   <!---<cfif #TenantQuery.level# NEQ #newLevel#>---> Level info -- 'lvl #TenantQuery.level# to lvl #newLevel#   --- 'lvl(2) #TenantQuery.level# to lvl(2) #newLevel# <!---</cfif>--->
	</cfoutput>							
	<cfabort>--->
	<!--- Ganga Testing LVL concept End --->
		</cftransaction>
	</cffunction>
	<!--- end activate --->
	
	<cffunction name="ActivateWithoutBilling" access="public" output="false" returntype="void">
		<cfargument name="currentPeriod" type="string" required="true">
		<cfargument name="billingActiveDate" type="string" required="true">
		<cfargument name="userId" type="string" required="true">
		<cfargument name="userName" type="string" required="true">
		<cfargument name="solomonDsn" type="string" required="true">
		<!--- <cfargument name="leadTrackDsn" type="string" required="true"> --->
		<!--- <cfargument name="leadtrackingdbserver" type="string" required="true"> --->
		
		<cfquery name="time" datasource="#application.datasource#">
			select getdate() as timestamp
		</cfquery>
		
		<cfset timestamp=time.timestamp>
		
		<cfquery name="qAssessment" datasource="#application.datasource#">
			select 
				*
			from 
				assessmenttoolmaster am
			join assessmenttooldetail ad 
				on am.iassessmenttoolmaster_id = ad.iassessmenttoolmaster_id 
				and am.dtrowdeleted is null and ad.dtrowdeleted is null
			left join servicelist sl 
				on sl.iservicelist_id = ad.iservicelist_id 
				and sl.dtrowdeleted is null
			join 
				assessmenttool ast 
				on ast.iassessmenttool_id = am.iassessmenttool_id 
				and ast.dtrowdeleted is null
			where 
				am.iassessmenttoolmaster_id = #variables.id#
		</cfquery>
		
		<cfif qAssessment.Recordcount gt 0>
			<cfif qAssessment.iresident_ID neq ''>
				<cfset residentid = #variables.tenantId#>
			</cfif>
			<cfif qAssessment.itenant_ID neq ''>
				<cfset tenantid = #qAssessment.itenant_ID#>
			</cfif>
		</cfif>

		<!--- check for corresponding iresident_id --->
		<!--- <cfquery name="qresident" datasource="#application.datasource#">
			select * from #arguments.leadtrackingdbserver#.leadtracking.dbo.residentstate where dtrowdeleted is null
			and itenant_id = #variables.tenantId#
		</cfquery> --->
		
		<!--- <cfif qresident.recordcount gt 0>
			<cfset residentid=qresident.iresident_id>
		<cfelse> --->
			<cfset residentid='0'>
		<!--- </cfif> --->
		
		<cftransaction>
			<!--- deactivate others assessments --->
			<cfquery name="qdeactivate" datasource="#application.datasource#">
				update 
					assessmenttoolmaster
				set 
					 bBillingActive = null
					,dtrowstart= #CreateODBCDateTime(now())#
					,crowstartuser_id='#arguments.username#'
				where 
					iassessmenttoolmaster_id <> #variables.id#
				and 
					 (itenant_id = #variables.tenantid# ) <!---  or (iresident_id = #residentid#))  --->
				and 
					bBillingActive is not null
				and 
					bfinalized is not null	
			</cfquery>
			
			<!--- set chosen to assessment to ** active no billing ** --->	
			<!--- set selective to active (1st) and other current active to not active (2nd query)--->
			<cfquery name="qsetActive" datasource="#application.datasource#">
				update 
					assessmenttoolmaster
				set 
					 bBillingActive = 1
					,dtBillingActive = #CreateODBCDateTime(arguments.billingActiveDate)#
					,dtrowstart = #CreateODBCDateTime(now())#
					,crowstartuser_id = '#arguments.username#'
				where 
					iassessmenttoolmaster_id = #variables.id#
			</cfquery>

			
			<cfif auth_user eq "ALC\PaulB123">
				<cftry>	
					<cfquery name="qErrorout" datasource="#dsn#">
						select getdate()
					</cfquery>
					<cfcatch type="any">
						<cftransaction action="rollback"/><b>Rolling Back transaction</b>
						<cfabort>
					</cfcatch>
				</cftry>
			<cfelse>
				<cftry>
					<cfcatch type="ANY">
						<cfdump var="#cfcatch#"><cfabort>
					</cfcatch>
				</cftry>
			</cfif>		
		</cftransaction>
	</cffunction>

	<cffunction name="GetLevelType" access="public" returntype="Components.LevelType" output="false">
		<cfscript>
			LevelType = CreateObject("Component","Components.LevelType");
			LevelType = LevelType.GetLevelTypeForPoints(variables.points,GetAssessmentTool().GetSLevelTypeSet(),variables.dsn);
			
			return LevelType;
		</cfscript>
	</cffunction>
	
	<cffunction name="EmailNurse" access="private" returntype="void" output="true">
			<!--- retrieve fullname  --->
			<cfquery name="qperson" datasource="#dsn#">
				begin
				 select (clastname + ', ' + cfirstname) as fullname from tenant where dtrowdeleted is null and itenant_id = #variables.tenantId#
 				end
			</cfquery>			
<!--- 			<cfquery name="qperson" datasource="#dsn#">
				begin
				 select (clastname + ', ' + cfirstname) as fullname from tenant where dtrowdeleted is null and itenant_id = #variables.tenantId#
				 union
				 select (clastname + ', ' + cfirstname) as fullname from #leadtrackingdbserver#.LeadTracking.dbo.resident where dtrowdeleted is null and iresident_id = #variables.residentId#
				end
			</cfquery> --->
			
			<cfscript>
				message= session.fullname & " has submitted an assessment that requires care services approval.";
				message2="Resident: " & qperson.fullname & "<br/>House : " & session.housename;
			</cfscript>
			
			<!--- 03/10/2010 Sathya Project 41315-C Added this  --->
			<cfquery name="qnursedetails" datasource="#variables.dsn#">
				select 
					 sl.cdescription service
					,ad.cnotes
				from 
					assessmenttoolmaster am
				inner join 
					assessmenttooldetail ad on ad.iassessmenttoolmaster_id = am.iassessmenttoolmaster_id
						and 
					ad.dtrowdeleted is null 
						and 
					am.dtrowdeleted is null 
						and 
					ad.Service_text = 'y'   <!--- GThota added for testing 12/03/2012--->
					    and
					am.iassessmenttoolmaster_id = #variables.id#
				left join 
					servicelist sl on sl.iservicelist_id = ad.iservicelist_id 
						and 
					sl.dtrowdeleted is null 
						and 
					sl.bApprovalRequired = 1 
				where 
					(sl.bapprovalrequired = 1 )

				union
				
				select 
					 ssl.cdescription service
					,dbo.ufn_GetNotesForSubserviceforNurseAlerts(#variables.id#, ssl.iServicelist_id) as cNotes
				from 
					assessmenttoolmaster am
				inner join 
					assessmenttooldetail ad on ad.iassessmenttoolmaster_id = am.iassessmenttoolmaster_id
						and 
					ad.dtrowdeleted is null 
						and 
					am.dtrowdeleted is null 
						and 
					ad.Service_text = 'y'   <!--- GThota added 12/03/2012--->
					    and
					am.iassessmenttoolmaster_id = #variables.id#
			inner join 
					subservicelist ssl on ssl.isubServicelist_id = ad.isubServicelist_id 
						and 
					ssl.dtrowdeleted is null 
						and 
					ssl.bApprovalRequired = 1
				
				where 
					 ssl.bapprovalrequired = 1
			</cfquery>
			<!--- 03/10/2010 Sathya End code 41315-C   --->
			
			<cfif qnursedetails.recordcount gt 0>
				<!--- add details and notes to email --->
				<cfset message2 = "<br/>" & message2 & "<style>table{padding:0 0 0 0;border:none;font-family:Verdana,Arial;border:1px solid gray;font-size:xx-small;} td{padding:0 0 0 0;} tr{padding:0 0 0 0;}</style>">
				<cfset message2 = message2 & "<table><tr style='background:##ccccff;'><td style='width:75%;'>Service for approval</td><td style='width:25%;'>Notes (if any)</dt></tr>">
				
				<cfloop query="qnursedetails">
					<cfset message2= message2 & "<tr style='color:maroon;'><td>#trim(qnursedetails.service)#</td><td>">
					
					<cfif qnursedetails.cnotes neq "">
						<cfset message2 = message2 & qnursedetails.cnotes>
					</cfif>
					
					<cfset message2 = message2 & "</td><tr>">
				</cfloop>
			
				<cfset message2=message2&"</table>">
			</cfif>
			<!--- retrieve nurse email to sent to  --->
			<cfquery name="qNurseEmail" datasource="#application.datasource#">
				select 
					* 
				from 
					house h
				join 
					<!--- Walnut.alcweb.dbo.employees e on e.employee_ndx = h.cnurseuser_id and e.dtrowdeleted is null --->
					  alcweb.dbo.employees e on e.employee_ndx = h.cnurseuser_id and e.dtrowdeleted is null

				where 
					h.dtrowdeleted is null
				and 
					h.ihouse_id = #GetTenant().GetHouse().GetId()#
			</cfquery>
			
			<cfif isDefined("qNurseEmail.email") and qNurseEmail.email neq "" AND FindNoCase("oldbirch",cgi.SERVER_NAME) eq 0>
				<cfset emailto = qNurseEmail.email>
			<cfelseif FindNoCase("oldbirch",cgi.SERVER_NAME) neq 0>
				<cfset emailto = session.developeremaillist>
			<cfelse>
				<cfset emailto = "">
			</cfif>
			
			<cfif emailto neq "">
				<cfmail to="#emailto#" cc="CFDevelopers@ALCCO.COM" FROM="AssessmentTool@alcco.com" SUBJECT="Assessment Approval Request for #session.housename#" type="html">
					<html>
					<head><link rel="stylesheet" type="text/css" href="http://#server_name#/intranet/TIPS4/Shared/Style3.css"></head>
					<body>
					<br><br>
					<table style="width: 80%;">
					<tr><td class="topleftcap"></td><td class="toprightcap"></td></tr> 
					<tr><td colspan="2" class="leftrightborder">#message#</td></tr>
					<tr><td colspan="2" class="leftrightborder" style="text-align:center;">#message2#</td></tr>
					<tr><td class="bottomleftcap"></td><td class="bottomrightcap"></td></tr>
					</table>
					<a style="font-size:xx-small;font-family:tahoma;">#ucase(server_name)# #now()#</a>
					</body>
					</html>
				</cfmail>
			</cfif>

	</cffunction>
<!----------------------------------------------------------
*                   GETTERS AND SETTERS                    *
----------------------------------------------------------->	
			
	<cffunction name="GetId" access="public" returntype="numeric" output="false" hint="Returns a tenants id.">
		<cfscript>
			return variables.id;
		</cfscript>
	</cffunction>
	
	<!--- 01/15/2010 Sathya as per Project 41315 added this function --->
	<cffunction name="GetTenantID" access="public" returntype="string" output="false" hint="Returns the tenant ID">
		<cfscript>
	    	return variables.tenantId;
		</cfscript>
	</cffunction>

	<cffunction name="GetResidentID" access="public" returntype="numeric" output="false" hint="Returns a tenants resident id">
		<cfscript>
			return variables.residentid;
		</cfscript>
	</cffunction>
	<cffunction name="GetAssessmentTool" access="public" returntype="Components.AssessmentTool" output="false">
		<cfscript>
			AssessmentTool = CreateObject("Component","Components.AssessmentTool");
			AssessmentTool.Init(variables.assessmentToolId,variables.dsn);
			
			return AssessmentTool;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetAssessmentTool" access="public" returntype="void" output="false">
		<cfargument name="assessmentToolId" type="numeric" required="true">
		<cfscript>
			variables.assessmentToolId = arguments.assessmentToolId;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetRowStartUserId" access="public" returntype="string" output="false" hint="Gets the tenatns rowStartUserId">
		<cfscript>
			return variables.rowStartUserId;
		</cfscript>
	</cffunction>

	<!--- ths can return a tenant or resident object --->
	<cffunction name="GetTenant" access="public" returntype="Any" output="false" hint="">
		<cfscript>
			//if the tenantid is 0 then get the resident
			if(variables.tenantId neq 0)
			{
				Tenant = CreateObject("Component","Components.Tenant");
			//	Tenant.Init(variables.tenantId,variables.residentId,variables.dsn,variables.leadtrackingdbserver,variables.censusdbserver);
				Tenant.Init(variables.tenantId, variables.dsn);

			}
			else
			{
				Tenant = CreateObject("Component","Components.Resident");
				Tenant.Init(variables.tenantId,variables.dsn);
//				Tenant.Init(variables.residentId,variables.tenantId,"LeadTracking",variables.dsn,variables.leadtrackingdbserver,variables.censusdbserver);

			}
			
			return Tenant;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetReviewType" access="public" returntype="Components.ReviewType" output="false" hint="">
		<cfscript>
			ReviewType = CreateObject("Component","Components.ReviewType");
			ReviewType.Init(variables.reviewTypeId,variables.dsn);
			
			return ReviewType;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetReviewType" access="public" returntype="void" output="false" hint="">
		<cfargument name="reviewTypeId" type="numeric" required="true">
		<cfscript>
			variables.reviewTypeId = arguments.reviewTypeId;
		</cfscript>
	</cffunction>

	<cffunction name="GetPoints" access="public" returntype="numeric" output="false">
		<cfscript>
			return variables.points;
		</cfscript>
	</cffunction>
	
	<!--- 02/12/2010 Sathya as per project 41315-B added function for Service Category --->
	 <cffunction name="GetServicesCategory" access="public" returntype="array" output="false">
		<cfscript>
			return variables.ServiceCategoryArray;
		</cfscript>
	</cffunction> 
	<!--- 02/12/2010 Sathya as per project 41315-B added function for Service Category --->
	 <cffunction name="SetServicesCategory" access="public" returntype="void" output="false">
		<cfargument name="ServiceCategoryArray" type="array" required="false" default="">
		<cfscript>
			variables.ServiceCategoryArray = arguments.ServiceCategoryArray;
		</cfscript>
	</cffunction> 
	<!---  This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code) --->
	<cffunction name="GetServices" access="public" returntype="array" output="false">
		<cfscript>
			return variables.ServiceArray;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetServices" access="public" returntype="void" output="false">
		<cfargument name="ServiceArray" type="array" required="false" default="">
		<cfscript>
			variables.ServiceArray = arguments.ServiceArray;
		</cfscript>
	</cffunction>

	<cffunction name="GetSubServices" access="public" returntype="array" output="false">
		<cfscript>
			return variables.SubServiceArray;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSubServices" access="public" returntype="void" output="false">
		<cfargument name="SubServiceArray" type="array" required="false" default="">
		<cfscript>
			variables.SubServiceArray = arguments.SubServiceArray; 
		</cfscript>
	</cffunction>

	<cffunction name="GetReviewStartDate" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return DateFormat(variables.reviewStartDate,"mm/dd/yyyy");
		</cfscript>
	</cffunction>
	
	<cffunction name="SetReviewStartDate" access="public" returntype="void" output="false" hint="">
		<cfargument name="reviewStartDate" type="string" required="true">
		<cfscript>
			variables.reviewStartDate = arguments.reviewStartDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetNextReviewDate" access="public" returntype="string" output="false">
		<cfscript>
			return variables.nextReviewDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetNextReviewDate" access="public" returntype="void" output="false">
		<cfargument name="nextReviewDate" type="string" required="true">
		<cfscript>
			variables.nextReviewDate = arguments.nextReviewDate;
		</cfscript>
	</cffunction>

	<cffunction name="GetReviewEndDate" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return DateFormat(variables.reviewEndDate,"mm/dd/yyyy");
		</cfscript>
	</cffunction>
	
	<cffunction name="SetReviewEndDate" access="public" returntype="void" output="false" hint="">
		<cfargument name="reviewEndDate" type="string" required="true">
		<cfscript>
			variables.reviewEndDate = arguments.reviewEndDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetIsBillingActive" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.isBillingActive;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetBillingActiveDate" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.billingActiveDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetIsBillingActive" access="public" returntype="void" output="false" hint="">
		<cfargument name="isBillingActive" type="boolean" required="true">
		<cfscript>
			variables.isBillingActive = arguments.isBillingActive;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetIsFinalized" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.isFinalized;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetIsFinalized" access="public" returntype="void" output="false" hint="">
		<cfargument name="isFinalized" type="boolean" required="true">
		<cfscript>
			variables.isFinalized = arguments.isFinalized;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetApprovalRequired" access="public" returntype="bool" output="false" hint="">
		<cfscript>
			return variables.isApprovalRequired;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetApprovalRequired" access="public" returntype="void" output="false" hint="">
		<cfargument name="isApprovalRequired" type="boolean" required="true">
		<cfscript>
			variables.isApprovalRequired = arguments.isApprovalRequired;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetApprovedBy" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.approvedBy;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetApprovedBy" access="public" returntype="void" output="false" hint="">
		<cfargument name="approvedBy" type="string" required="true">
		<cfscript>
			variables.approvedBy = arguments.approvedBy;
		</cfscript>
	</cffunction>

	<cffunction name="SetRowStartUserId" access="public" returntype="void" output="false" hint="Sets the tenats rowStartUserId">
		<cfargument name="rowStartUserId" type="string" required="true">
		<cfscript>
			variables.rowStartUserId = arguments.rowStartUserId;
		</cfscript>
	</cffunction>


	<cffunction name="GetRowStartDate" access="public" returntype="string" output="false" hint="Gets the tenants rowStartDate">
		<cfscript>
			return variables.rowStartDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetRowStartDate" access="public" returntype="void" output="false" hint="Sets the tenats rowStartDate">
		<cfargument name="rowStartDate" type="string" required="true">
		<cfscript>
			variables.rowStartDate = arguments.rowStartDate;
		</cfscript>
	</cffunction>
	

	<cffunction name="GetRowEndUserId" access="public" returntype="string" output="false" hint="Gets the tenats rowEndUserId">
		<cfscript>
			return variables.rowEndUserId;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetRowEndUserId" access="public" returntype="void" output="false" hint="Sets the users rowEndUserId">
		<cfargument name="rowEndUserId" type="string" required="true">
		<cfscript>
			variables.rowEndUserId = arguments.rowEndUserId;
		</cfscript>
	</cffunction>


	<cffunction name="GetRowEndDate" access="public" returntype="string" output="false" hint="Gets the tenants rowEndDate">
		<cfscript>
			return variables.rowEndDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetRowEndDate" access="public" returntype="void" output="false" hint="Sets the tenants rowEndDate">
		<cfargument name="rowEndDate" type="string" required="true">
		<cfscript>
			variables.rowEndDate = arguments.rowEndDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetService_text" access="public" returntype="string" output="false">
			<cfscript>
				return variables.Service_text;
			</cfscript>
		</cffunction>
	
		<cffunction name="SetService_text" access="public"  output="false">
			<cfargument name="Service_text"  required="true">

			<cfscript>
				variables.Service_text = arguments.Service_text;
			</cfscript>
		</cffunction>

	<cffunction name="GetRowDeletedUserId" access="public" returntype="string" output="false" hint="Gets the tenants rowDeletedUserId">
		<cfscript>
			return variables.rowDeletedUserId;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetRowDeletedUserId" access="public" returntype="void" output="false" hint="Sets the tenants rowDeletedUserId">
		<cfargument name="rowDeletedUserId" type="string" required="true">
		<cfscript>
			variables.rowDeletedUserId = arguments.rowDeletedUserId;
		</cfscript>
	</cffunction>

	<cffunction name="GetRowDeletedDate" access="public" returntype="string" output="false" hint="Gets the tenants rowDeletedDate">
		<cfscript>
			return variables.rowDeletedDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetRowDeletedDate" access="public" returntype="void" output="false" hint="Sets the tenants rowDeletedDate">
		<cfargument name="rowDeletedDate" type="string" required="true">
		<cfscript>
			variables.rowDeletedDate = arguments.rowDeletedDate;
		</cfscript>
	</cffunction>	
	
	<cffunction name="GetServicePlanID" access="public" returntype="string" output="false" hint="Gets The Tenants Status Code">
		<cfscript>
			return variables.serviceplanid;
		</cfscript>
	</cffunction>	
	
	<cffunction name="SetServicePlanID" access="public" returntype="string" output="false" hint="Gets The Tenants Status Code">
		<cfargument name="serviceplanid" type="string" required="true">
		<cfscript>
			variables.serviceplanid = arguments.serviceplanid;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetStatusCode" access="public" returntype="string" output="false" hint="Gets The Tenants Status Code">
		<cfscript>
			return variables.statuscode;
		</cfscript>
	</cffunction>	
	
	<cffunction name="SetStatusCode" access="public" returntype="string" output="false" hint="Gets The Tenants Status Code">
		<cfargument name="statuscode" type="string" required="true">
		<cfscript>
			variables.statuscode = arguments.statuscode;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetDiagnosis" access="public" returntype="string" output="false" hint="Gets The Tenants Diagnosis">
		<cfscript>
			return variables.diagnosis;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetDiagnosis" access="public" returntype="string" output="false" hint="Sets The Tenants Diagnosis">
		<cfargument name="diagnosis" type="string" required="true">
		<cfscript>
			variables.diagnosis = arguments.diagnosis;
		</cfscript>
	</cffunction>
	
	                                                           <!---  Added 88898  New Assessments --->
	<cffunction name="GetPrimary" access="public" returntype="string" output="false" hint="Gets The Tenants Primary Diagnosis">
		<cfscript>
			return variables.Primary;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPrimary" access="public" returntype="string" output="false" hint="Sets The Tenants Primary Diagnosis">
		<cfargument name="Primary" type="string" required="true">
		<cfscript>
			variables.Primary = arguments.Primary;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetSecondary" access="public" returntype="string" output="false" hint="Gets The Tenants Secondary Diagnosis">
		<cfscript>
			return variables.Secondary;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSecondary" access="public" returntype="string" output="false" hint="Sets The Tenants Secondary Diagnosis">
		<cfargument name="Secondary" type="string" required="true">
		<cfscript>
			variables.Secondary = arguments.Secondary;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetThird" access="public" returntype="string" output="false" hint="Gets The Tenants Third Diagnosis">
		<cfscript>
			return variables.Third;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetThird" access="public" returntype="string" output="false" hint="Sets The Tenants Third Diagnosis">
		<cfargument name="Third" type="string" required="true">
		<cfscript>
			variables.Third = arguments.Third;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetFourth" access="public" returntype="string" output="false" hint="Gets The Tenants Fourth Diagnosis">
		<cfscript>
			return variables.Fourth;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetFourth" access="public" returntype="string" output="false" hint="Sets The Tenants Fourth Diagnosis">
		<cfargument name="Fourth" type="string" required="true">
		<cfscript>
			variables.Fourth = arguments.Fourth;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetFifth" access="public" returntype="string" output="false" hint="Gets The Tenants Fifth Diagnosis">
		<cfscript>
			return variables.Fifth;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetFifth" access="public" returntype="string" output="false" hint="Sets The Tenants Fifth Diagnosis">
		<cfargument name="Fifth" type="string" required="true">
		<cfscript>
			variables.Fifth = arguments.Fifth;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetSixth" access="public" returntype="string" output="false" hint="Gets The Tenants Sixth Diagnosis">
		<cfscript>
			return variables.Sixth;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSixth" access="public" returntype="string" output="false" hint="Sets The Tenants Sixth Diagnosis">
		<cfargument name="Sixth" type="string" required="true">
		<cfscript>
			variables.Sixth = arguments.Sixth;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetSeventh" access="public" returntype="string" output="false" hint="Gets The Tenants Seventh Diagnosis">
		<cfscript>
			return variables.Seventh;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSeventh" access="public" returntype="string" output="false" hint="Sets The Tenants Seventh Diagnosis">
		<cfargument name="Seventh" type="string" required="true">
		<cfscript>
			variables.Seventh = arguments.Seventh;
		</cfscript>
	</cffunction>                                                                <!---  Added 88898  end--->
	
	<cffunction name="GetAllergies" access="public" returntype="string" output="false" hint="Gets The Tenants Allergies">
		<cfscript>
			return variables.allergies;
		</cfscript>
	</cffunction>
	
	
	<cffunction name="SetAllergies" access="public" returntype="string" output="false" hint="Gets The Tenants Allergies">
		<cfargument name="allergies" type="string" required="true">
		<cfscript>
			variables.allergies = arguments.allergies;
		</cfscript>
	</cffunction>
	
	
	<cffunction name="GetOtherServices" access="public" returntype="string" output="false" hint="Gets The Tenants Other Services">
		<cfscript>
			return variables.otherservices;
		</cfscript>
	</cffunction>
	
	
	<cffunction name="SetOtherServices" access="public" returntype="string" output="false" hint="Gets The Tenants OtherServices">
		<cfargument name="otherservices" type="string" required="true">
		<cfscript>
			variables.otherservices = arguments.otherservices;
		</cfscript>
	</cffunction>
	
<!---
 Search a multidimensional array for a value.
 
 @param arrayToSearch 	 Array to search. (Required)
 @param valueToFind 	 Value to find. (Required)
 @param dimensionToSearch 	 Dimension to search. (Required)
 @return Returns a number. 
 @author Grant Szabo (&#103;&#114;&#97;&#110;&#116;&#64;&#113;&#117;&#97;&#103;&#109;&#105;&#114;&#101;&#46;&#99;&#111;&#109;) 
 @version 1, September 23, 2004 
--->
<cffunction name="ArrayFindByDimension" access="public" returntype="numeric" output="false">
	<cfargument name="arrayToSearch" type="array" required="Yes">
	<cfargument name="valueToFind" type="string" required="Yes">
	<cfargument name="dimensionToSearch" type="numeric" required="Yes">
	<cfscript>
		var ii = 1;
		
		//loop through the array, looking for the value
		for(; ii LTE arrayLen(arguments.arrayToSearch); ii = ii + 1){
			//if this is the value, return the index
			if(NOT compareNoCase(arguments.arrayToSearch[ii][arguments.dimensionToSearch], arguments.valueToFind))
				return ii;
		}
		//if we've gotten this far, it means the value was not found, so return 0
		return 0;
	</cfscript>
</cffunction>	
<!---
 The arrayFind function uses the java.util.list indexOf function to find an element in an array.
 v1 by Nathan Dintenfas.
 
 @param array 	 Array to search. (Required)
 @param valueToFind 	 Value to find. (Required)
 @return Returns a number, 0 if no match is found. 
 @author Larry C. Lyons (&#108;&#97;&#114;&#114;&#121;&#99;&#108;&#121;&#111;&#110;&#115;&#64;&#103;&#109;&#97;&#105;&#108;&#46;&#99;&#111;&#109;) 
 @version 2, April 30, 2008 
--->
<cffunction name="arrFind" access="public" hint="returns the index number of an item if it is in the array" output="false" returntype="numeric">

<cfargument name="array" required="true" type="array">
<cfargument name="valueToFind" required="true" type="string">

<cfreturn (arguments.array.indexOf(arguments.valueToFind)) + 1>
</cffunction>
</cfcomponent>
