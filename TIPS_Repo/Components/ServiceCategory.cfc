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
| ranklam    | 2/26/2007 | Created                                                            |
|----------------------------------------------------------------------------------------------|
| Sathya     |02/12/2010 | Modifed as per Project 41315-B for Notes to be saved               |
----------------------------------------------------------------------------------------------->
<cfcomponent name="ServiceCategory" output="false" extends="Components.AlcBase">
	<cffunction name="Init" access="public" returntype="void" output="false">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="dsn" type="string" required="true">
		
		<cfscript>
			//create the variables for the tenant
			variables.id = arguments.id;
			variables.dsn = arguments.dsn;
			assessmentToolId = 0;
			description = '';
			sortOrder = 0;
			system = false;
			multipleSelect = 0;
			variables.rowStartUserId = 0;
			variables.rowStartDate = "";
			variables.rowEndUserId = 0;
			variables.rowEndDate = "";
			variables.rowDeletedUserId = 0;
			variables.rowDeletedDate = "";
			
			// 02/12/2010 Sathya as per Project 41315-B added this
			variables.notes = "";
			
			//if the id isn't 0 get the information;
			if(variables.id neq 0)
			{
				GetInformation();
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="GetInformation" access="private" returntype="void" output="false" hint="Gets information and fills the object variables.">

		<cfquery name="QueryGetInformation" datasource="#variables.dsn#">
			SELECT
				 iServiceCategory_id
			     ,IsNull(iAssessmentTool_id,0) AS iAssessmentTool_id
			     ,IsNull(cDescription,'') AS cDescription
			     ,IsNull(cSortOrder,'') AS cSortOrder
			     ,IsNull(bSystem,0) AS bSystem
			     ,IsNull(imultipleselect,0) AS imultipleselect
			     ,IsNull(cRowStartUser_ID,'') AS cRowStartUser_ID
			     ,IsNull(dtRowStart,'') AS dtRowStart
			     ,IsNull(cRowEndUser_ID,'') AS cRowEndUser_ID
			     ,IsNull(dtRowEnd,'') AS dtRowEnd
			     ,IsNull(cRowDeletedUser_ID,'') AS cRowDeletedUser_ID
			     ,IsNull(dtRowDeleted,'') AS dtRowDeleted
			FROM
				ServiceCategories
			WHERE
				iServiceCategory_id = #variables.id#
		</cfquery>
		
		<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
				theQuery = QueryGetInformation;
				
				assessmentToolId = theQuery["iAssessmentTool_id"][1];
				description = theQuery["cDescription"][1];
				sortOrder = theQuery["cSortOrder"][1];
				system = BitToBool(theQuery["bSystem"][1]);
				multipleSelect = theQuery["iMultipleSelect"][1];
				variables.rowStartUserId = theQuery["cRowStartUser_ID"][1];
				variables.rowStartDate = theQuery["dtRowStart"][1];
				variables.rowEndUserId = theQuery["cRowEndUser_id"][1];
				variables.rowEndDate = theQuery["dtRowEnd"][1];
				variables.rowDeletedUserId = theQuery["cRowEndUser_ID"][1];
				variables.rowDeletedDate = theQuery["dtRowDeleted"][1];	
			}
			else
			{
				Throw("");
			}
		</cfscript>
	</cffunction>

	<cffunction name="GetServiceList" access="public" returntype="array">
		<cfquery name="GetServiceCategoriesQuery" datasource="#variables.dsn#">
			SELECT
				iServiceList_ID
			FROM
				ServiceList
			WHERE
				iServiceCategory_id = #variables.id#
			AND
				dtRowDeleted IS NULL
			ORDER BY
				(cSortOrder * 1)
		</cfquery>
		
		<cfscript>
			theQuery = GetServiceCategoriesQuery;
			ServiceListArray = ArrayNew(1);
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
				ServiceList = CreateObject("Component","Components.ServiceList");
				ServiceList.Init(theQuery["iServiceList_ID"][i],variables.dsn);
				
				ArrayAppend(ServiceListArray,ServiceList);
			}
			
			return ServiceListArray;
		</cfscript>
	</cffunction>	
<!----------------------------------------------------------
*                   GETTERS AND SETTERS                    *
----------------------------------------------------------->	

	<cffunction name="GetId" access="public" returntype="numeric" output="false" hint="Returns a tenants id.">
		<cfscript>
			return variables.id;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetAssessmentTool" access="public" returntype="Components.AssessmentTool" output="false" hint="">
		<cfscript>
			AssessmentTool = CreateObject("Component","Components.AssessmentTool");
			AssessmentTool.Init(variables.assessmentToolId,variables.dsn);
			
			return AssessmentTool;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetAssessmentTool" access="public" returntype="void" output="false" hint="">
		<cfargument name="assessmentToolId" type="numeric" required="true">
		<cfscript>
			variables.assessmentToolId = arguments.assessmentToolId;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetDescription" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.description;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetDescription" access="public" returntype="void" output="false" hint="">
		<cfargument name="description" type="string" required="true">
		<cfscript>
			variables.description = arguments.description;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetSortOrder" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.sortOrder;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSortOrder" access="public" returntype="void" output="false" hint="">
		<cfargument name="sortOrder" type="string" required="true">
		<cfscript>
			variables.sortOrder = arguments.sortOrder;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetSystem" access="public" returntype="boolean" output="false" hint="">
		<cfscript>
			return variables.system;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSystem" access="public" returntype="void" output="false" hint="">
		<cfargument name="system" type="boolean" required="true">
		<cfscript>
			variables.system = arguments.system;
		</cfscript>
	</cffunction>

	<cffunction name="GetMultipleSelect" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.multipleSelect;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetMultipleSelect" access="public" returntype="void" output="false" hint="">
		<cfargument name="multipleSelect" type="string" required="true">
		<cfscript>
			variables.multipleSelect = arguments.multipleSelect;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetRowStartUserId" access="public" returntype="string" output="false" hint="Gets the tenatns rowStartUserId">
		<cfscript>
			return variables.rowStartUserId;
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
	<!--- 02/12/2010 Sathya as per Project 41315-B adding function for Notes --->
<cffunction name="GetNotes" access="public" returntype="string" output="false">
		<cfscript>
			return variables.notes;
		</cfscript>
	</cffunction>
<!--- 02/12/2010 Sathya as per Project 41315-B adding  function for Notes --->
	<cffunction name="SetNotes" access="public" returntype="string" output="false">
		<cfargument name="notes" type="string" required="true">
		<cfscript>
			variables.notes = arguments.notes;
		</cfscript>
	</cffunction> 
</cfcomponent>
