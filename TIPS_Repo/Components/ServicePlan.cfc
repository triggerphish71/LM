<!----------------------------------------------------------------------------------------------
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
| jcruz	     | 06/27/2008 | Created                                                            |
----------------------------------------------------------------------------------------------->

<cfcomponent name="ServicePlan" output="false" extends="Components.AlcBase">
	<cffunction name="Init" access="public" returntype="void" output="false">
		<cfargument name="assessmentId" type="numeric" required="false" default="0">
		<cfargument name="dsn" type="string" required="true">
		<cfscript>
			//create the variables for the object
			variables.assessmentId = arguments.assessmentId;
			variables.residentId = 0;
			variables.tenantId = 0;
			variables.dsn = arguments.dsn;
			variables.serviceplanid = 0;
			variables.assessmenttoolmasterid = '';
			variables.statuscode = '';
			variables.diagnosis = '';
			variables.Primary = '';
			variables.Secondary = '';
			variables.Third = '';
			variables.Fourth = '';
			variables.Fifth = '';
			variables.Sixth = '';
			variables.Seventh = '';
			variables.allergies = "";
			variables.otherservices = "";
			variables.dtrowstart = "";
			variables.rowStartUserId = 0;
			variables.dtrowdeleted = "";
			variables.rowDeletedUserId = 0;
			
			//if the id isn't 0 this is an actual tenant, get their information;
			if(variables.assessmentId neq 0)
			{
				GetInformation();
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="GetInformation" access="private" returntype="void" output="false" hint="Gets information and fills the object variables.">
		<!--- Get the information form the database --->
		<cfquery name="QueryGetInformation" datasource="#variables.dsn#">
			SELECT
				   IsNull(int_Plan_Id,0) AS serviceplanid
				  ,IsNull(int_AssessmentToolMaster_Id,0) AS iAssessmentToolMaster_Id
				  ,IsNull(int_Resident_Id,0) AS iResidentId
				  ,IsNull(int_Tenant_Id,0) AS iTenantId
			      ,IsNull(char_status,'') AS cStatus
			      ,IsNull(txt_diagnosis,'') AS cDiagnosis
				  ,IsNull(iPrimary,'') AS iPrimary
				  ,IsNull(iSecondary,'') AS iSecondary
				  ,IsNull(iThird,'') AS iThird
				  ,IsNull(iFourth,'') AS iFourth
				  ,IsNull(iFifth,'') AS iFifth
				  ,IsNull(iSixth,'') AS iSixth
				  ,IsNull(iSeventh,'') AS iSeventh
			      ,IsNull(txt_allergies,'') AS cAllergies
			      ,IsNull(txt_otherservices,'') AS cOtherServices
			      ,IsNull(dt_RowStart,'') AS dtRowStart
			      ,IsNull(char_RowStartUser_Id,0) AS iRowStartUserId
			      ,IsNull(dt_RowDeleted,'') AS dtRowDeleted
			      ,IsNull(char_RowDeletedUser_Id,0) AS iRowDeletedUserId
			FROM
				tbl_AssessmentServicePlan asp
			WHERE
				asp.int_AssessmentToolMaster_Id = #variables.assessmentId#
		</cfquery>
		<!--- Set local variables --->
		<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
				//alias the get information query to make typing easier
				theQuery = QueryGetInformation;
				variables.serviceplanid = theQuery["serviceplanid"][1];
				variables.assessmentId = theQuery["iAssessmentToolMaster_Id"][1];
				variables.residentId = theQuery["iResidentId"][1];
				variables.tenantId = theQuery["iTenantId"][1];
				variables.statuscode = theQuery["cStatus"][1];	
				variables.diagnosis = theQuery["cDiagnosis"][1];
				variables.Primary = theQuery["iPrimary"][1];
				variables.Secondary = theQuery["iSecondary"][1];
				variables.Third = theQuery["iThird"][1];
				variables.Fourth = theQuery["iFourth"][1];
				variables.Fifth = theQuery["iFifth"][1];
				variables.Sixth = theQuery["iSixth"][1];
				variables.Seventh = theQuery["iSeventh"][1];
				variables.allergies = theQuery["cAllergies"][1];
				variables.otherservices = theQuery["cOtherServices"][1];
				variables.dtrowstart = theQuery["dtRowStart"][1];
				variables.rowStartUserId = theQuery["iRowStartUserId"][1];
				variables.dtrowdeleted = theQuery["dtRowDeleted"][1];
				variables.rowDeletedUserId = theQuery["iRowDeletedUserId"][1];				 
				
			}
			else
			{
				variables.serviceplanid = 0;
				variables.assessmentId = 0;
				variables.residentId = 0;
				variables.tenantId = 0;
				variables.statuscode = '';	
				variables.diagnosis = '';
				variables.Primary = '';
			    variables.Secondary = '';
			    variables.Third = '';
			    variables.Fourth = '';
			    variables.Fifth = '';
			    variables.Sixth = '';
			    variables.Seventh = '';
				variables.allergies = '';
				variables.otherservices = '';
				variables.dtrowstart = '';
				variables.rowStartUserId = 0;
				variables.dtrowdeleted = '';
				variables.rowDeletedUserId = 0;
			}
		</cfscript>
	</cffunction>

<!----------------------------------------------------------
*                   GETTERS AND SETTERS                    *
----------------------------------------------------------->

	<cffunction name="GetServicePlanID" access="public" returntype="string" output="false" hint="Gets The Tenants Service Plan ID">
		<cfscript>
			return variables.serviceplanid;
		</cfscript>
	</cffunction>	
	
	<cffunction name="SetServicePlanID" access="public" returntype="string" output="false" hint="Sets The Tenants Service Plan ID">
		<cfargument name="serviceplanid" type="string" required="true">
		<cfscript>
			variables.serviceplanid = arguments.serviceplanid;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetAssessmentID" access="public" returntype="string" output="false" hint="Gets The Tenants Assessment Plan ID">
		<cfscript>
			return variables.assessmentid;
		</cfscript>
	</cffunction>	
	
	<cffunction name="SetAssessmentID" access="public" returntype="string" output="false" hint="Sets The Tenants Assessment Plan ID">
		<cfargument name="assessmentid" type="string" required="true">
		<cfscript>
			variables.assessmentid = arguments.assessmentid;
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
	<!--- Added 7 new Dropdowns for project 88898 --->
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
	</cffunction> 
	               <!--- End dropdowns --->
				   
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
	
</cfcomponent>