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
| ranklam    | 2/16/2007 | Created                                                            |
----------------------------------------------------------------------------------------------->
<cfcomponent name="" output="false" extends="Components.AlcBase">
	<cffunction name="Init" access="public" returntype="void" output="false">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="dsn" type="string" required="true">
		
		<cfscript>
			//create the variables for the tenant
			variables.id = arguments.id;
			variables.dsn = arguments.dsn;
			variables.description = '';
			variables.sLevelTypeSet = '';
			variables.rowStartUserId = 0;
			variables.rowStartDate = "";
			variables.rowEndUserId = 0;
			variables.rowEndDate = "";
			variables.rowDeletedUserId = 0;
			variables.rowDeletedDate = "";
			
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
				  iAssessmentTool_ID
				 ,IsNull(cDescription,'') AS cDescription
				 ,IsNull(cSLevelTypeSet,'') AS cSLevelTypeSet
				 ,IsNull(cRowStartUser_id,'') AS cRowStartUser_id
				 ,IsNull(dtRowStart,'') AS dtRowStart
				 ,IsNull(cRowEndUser_id,'') AS cRowEndUser_id
				 ,IsNull(dtRowEnd,'') AS dtRowEnd
				 ,IsNull(cRowDeletedUser_id,'') AS cRowDeletedUser_id
				 ,IsNull(dtRowDeleted,'') AS dtRowDeleted
			FROM
				AssessmentTool
			WHERE
				iAssessmentTool_ID = #variables.id#
		</cfquery>
		
		<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
				//alias the get information query to make typing easier
				theQuery = QueryGetInformation;
							
				variables.description = theQuery["cDescription"][1];
				variables.sLevelTypeSet = theQuery["cSLevelTypeSet"][1];			
				variables.rowStartDate = theQuery["dtRowStart"][1];
				variables.rowEndUserId = theQuery["cRowEndUser_id"][1];
				variables.rowEndDate = theQuery["dtRowEnd"][1];
				variables.rowDeletedUserId = theQuery["cRowEndUser_ID"][1];
				variables.rowDeletedDate = theQuery["dtRowDeleted"][1];	
			}
			else
			{
				Throw("Assessment Tool Not Found","Assessment tool for id #variables.id# was not found in datasource #variables.dsn#");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="GetAllTools" access="public" returntype="array">
		<cfargument name="dsn" type="string" required="true">
		<cfquery name="GetToolsQuery" datasource="#arguments.dsn#">
			SELECT
				iAssessmentTool_ID
			FROM
				AssessmentTool
			WHERE
				dtRowDeleted IS NULL
			ORDER BY
				 dtRowStart ASC
				,cSLevelTypeSet
				,cDescription
		</cfquery>
		
		<cfscript>
			theQuery = GetToolsQuery;
			AssessmentToolArray = ArrayNew(1);
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
				AssessmentTool = CreateObject("Component","Components.AssessmentTool");
				AssessmentTool.Init(theQuery["iAssessmentTool_id"][i],arguments.dsn);
				
				ArrayAppend(AssessmentToolArray,AssessmentTool);
			}
			
			return AssessmentToolArray;
		</cfscript>
	</cffunction>

	<cffunction name="GetServiceCategories" access="public" returntype="array">
		<cfquery name="GetServiceCategoriesQuery" datasource="#variables.dsn#">
			SELECT
				 iServiceCategory_ID
				,IsNull(cSortOrder,0)
			FROM
				ServiceCategories
			WHERE
				iAssessmentTool_ID = #variables.id#
			AND
				dtRowDeleted IS NULL
			ORDER BY
				iassessmenttool_id, bsystem desc, (csortorder*1)
		</cfquery>
		
		<cfscript>
			theQuery = GetServiceCategoriesQuery;
			ServiceCategoryArray = ArrayNew(1);
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
				ServiceCategory = CreateObject("Component","Components.ServiceCategory");
				ServiceCategory.Init(theQuery["iServiceCategory_ID"][i],variables.dsn);
				
				ArrayAppend(ServiceCategoryArray,ServiceCategory);
			}
			
			return ServiceCategoryArray;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetLevelTypesAsStruct" access="public" returntype="array" output="false">
		<cfquery name="GetServiceLevelsQuery" datasource="#variables.dsn#">
				SELECT
					 T.iAssessmentTool_ID
					,S.isleveltype_ID
					,IsNull(s.ispointsmin,0) AS ispointsmin
					,IsNull(s.ispointsmax,0) AS ispointsmax
					,s.cdescription
				FROM
					AssessmentTool T
				INNER JOIN
					sleveltype S ON S.csleveltypeset = t.csleveltypeset
						and
					s.dtrowdeleted is null
				WHERE
					T.dtRowDeleted IS NULL
						AND
					T.iassessmenttool_id = #variables.id#
				ORDER BY
					 T.dtRowStart ASC
					,T.cSLevelTypeSet
					,T.cDescription
		</cfquery>
		
		<cfscript>
				theQuery = GetServiceLevelsQuery;
				LevelTypeArray = ArrayNew(1);
				
				for(i = 1; i lte theQuery.RecordCount; i = i +1)
				{
					LevelStruct = StructNew();
					
					LevelStruct.assessmentTool = theQuery["iassessmenttool_id"][i];
					LevelStruct.levelType = theQuery["isleveltype_ID"][i];
					LevelStruct.pointsMin = theQuery["ispointsmin"][i];
					LevelStruct.pointsMax = theQuery["ispointsmax"][i];
					LevelStruct.description = theQuery["cdescription"][i];
					
					ArrayAppend(LevelTypeArray,LevelStruct);
				}
				
				return LevelTypeArray;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetServicesAsStruct" access="public" returntype="array" output="false">
		<cfquery name="GetServicesQuery" datasource="#variables.dsn#">
			select
				 t.iassessmenttool_id
				,t.cdescription as assessmenttool
				,c.iservicecategory_id
				,c.cdescription as category
				,IsNull(c.bsystem,0) as categorySystem
				,IsNull(l.imultipleselect,0) as categorymultiple
				,l.iservicelist_id
				,l.cdescription as service
				,IsNull(l.fweight,0) as serviceweight
				,l.cgrouping as servicegrouping
				,IsNull(l.bapprovalrequired,0) as serviceapproval
				,s.isubservicelist_id
				,s.cdescription as subservice
				,IsNull(s.fweight,0) as subserviceweight
				,s.cgrouping as subservicegrouping
				,IsNull(s.bapprovalrequired,0) as subserviceapproval
			from
				assessmenttool t
			inner join	
				servicecategories c on c.iassessmenttool_id = t.iassessmenttool_id
					and
				c.dtrowdeleted is null
			inner join
				servicelist l on l.iservicecategory_id = c.iservicecategory_id
					and
				l.dtrowdeleted is null
			left join
				subservicelist s on s.iservicelist_id = l.iservicelist_id
					and
				s.dtrowdeleted is null
			where
				t.iassessmenttool_id = #variables.id#
			order by
				 (c.csortorder * 1)
				,c.iservicecategory_id
				,(l.csortorder * 1)
				,l.iservicelist_id
				,(s.csortorder * 1)
				,s.isubservicelist_id
		</cfquery>
		
		<cfscript>
			theQuery = GetServicesQuery;
			ServiceArray = ArrayNew(1);
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
				ServiceStruct = StructNew();
				ServiceStruct.assessmentToolId = theQuery["iassessmenttool_id"][i];
				ServiceStruct.assessmentTool = theQuery["assessmenttool"][i];
				ServiceStruct.serviceCategoryId = theQuery["iservicecategory_id"][i];
				ServiceStruct.category = theQuery["category"][i];
				ServiceStruct.categorySystem = theQuery["categorySystem"][i];
				ServiceStruct.categoryMultiple = theQuery["categorymultiple"][i];
				ServiceStruct.serviceListId = theQuery["iservicelist_id"][i];
				ServiceStruct.service = theQuery["service"][i];
				ServiceStruct.serviceWeight = theQuery["serviceweight"][i];
				ServiceStruct.serviceGrouping = theQuery["servicegrouping"][i];
				ServiceStruct.serviceApproval = theQuery["serviceapproval"][i];
				ServiceStruct.subServiceList = theQuery["isubservicelist_id"][i];
				ServiceStruct.subService = theQuery["subservice"][i];
				ServiceStruct.subServiceWeight = theQuery["subserviceweight"][i];
				ServiceStruct.subServiceGrouping = theQuery["subservicegrouping"][i];
				ServiceStruct.subServiceApproval = theQuery["subserviceapproval"][i];
				
				ArrayAppend(ServiceArray,ServiceStruct);
			}
			
			return ServiceArray;
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
	
	<cffunction name="GetDescription" access="public" returntype="string" output="false">
		<cfscript>
			return variables.description;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetDescription" access="public" returntype="string" output="false">
		<cfargument name="description" type="string" required="true">
		<cfscript>
			variables.description = arguments.description;
		</cfscript>
	</cffunction>

	<cffunction name="GetSLevelTypeSet" access="public" returntype="string" output="false">
		<cfscript>
			return variables.sLevelTypeSet;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSLevelTypeSet" access="public" returntype="string" output="false">
		<cfargument name="sLevelTypeSet" type="string" required="true">
		<cfscript>
			variables.sLevelTypeSet = arguments.sLevelTypeSet;
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
</cfcomponent>
