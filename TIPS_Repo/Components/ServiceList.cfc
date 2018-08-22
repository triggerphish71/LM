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
----------------------------------------------------------------------------------------------->
<cfcomponent name="ServiceList" output="false" extends="Components.AlcBase">
	<cffunction name="Init" access="public" returntype="void" output="false">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="dsn" type="string" required="true">
		
		<cfscript>
			//create the variables for the tenant
			variables.id = arguments.id;
			variables.dsn = arguments.dsn;
			variables.serviceCategoryId = 0;
			variables.description = '';
			variables.weight = 0;
			variables.grouping = '';
			variables.sortOrder = '';
			variables.notes = ''; //only used when attaching this to an assessment
			variables.Service_text = '';
			variables.approvalRequired = false;
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
				 IsNull(iServicelist_id,0) AS iServicelist_id
			     ,IsNull(iServiceCategory_id,0) AS iServiceCategory_id
			     ,IsNull(cDescription,'') AS cDescription
			     ,IsNull(fWeight,0) AS fWeight
			     ,IsNull(cGrouping, '') AS cGrouping
			     ,IsNull(cSortOrder, '0') AS cSortOrder
			     ,IsNull(bApprovalRequired, 0) AS bApprovalRequired
			     ,IsNull(cRowStartUser_id,'') AS cRowStartUser_id
			     ,IsNull(dtRowStart, '') AS dtRowStart
			     ,IsNull(cRowEndUser_id, '') AS cRowEndUser_id
			     ,IsNull(dtRowEnd, '') AS dtRowEnd
			     ,IsNull(cRowDeletedUser_id, '') AS cRowDeletedUser_id
			     ,IsNull(dtRowDeleted, '') AS dtRowDeleted
			     ,IsNull(bsubselect, 0) AS bsubselect
      			 ,IsNull(imultipleselect,0) AS imultipleselect
			FROM
				ServiceList
			WHERE
				iServiceList_ID = #variables.id#
		</cfquery>
		
		<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
			
				//alias the get information query to make typing easier
				theQuery = QueryGetInformation;
				
				variables.serviceCategoryId = theQuery["iServiceCategory_id"][1];
				variables.description = theQuery["cDescription"][1];
				variables.weight = theQuery["fWeight"][1];
				variables.grouping = theQuery["cGrouping"][1];
				variables.sortOrder = theQuery["cSortOrder"][1];
				variables.approvalRequired = BitToBool(theQuery["bApprovalRequired"][1]);
				variables.rowStartUserId = theQuery["cRowStartUser_ID"][1];
				variables.rowStartDate = theQuery["dtRowStart"][1];
				variables.rowEndUserId = theQuery["cRowEndUser_id"][1];
				variables.rowEndDate = theQuery["dtRowEnd"][1];
				variables.rowDeletedUserId = theQuery["cRowEndUser_ID"][1];
				variables.rowDeletedDate = theQuery["dtRowDeleted"][1];	
			}
			else
			{
				Throw("Servicelist not found","Service list for #variables.id# on datasource #variables.dsn#.");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="GetSubServiceList" access="public" returntype="array">
		<cfquery name="GetSubServiceCategoriesQuery" datasource="#variables.dsn#">
			SELECT
				iSubServiceList_ID
			FROM
				SubServiceList
			WHERE
				iServiceList_id = #variables.id#
			AND
				dtRowDeleted IS NULL
			ORDER BY
				cSortOrder
		</cfquery>
		
		<cfscript>
			theQuery = GetSubServiceCategoriesQuery;
			SubServiceListArray = ArrayNew(1);
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
				SubServiceList = CreateObject("Component","Components.SubServiceList");
				SubServiceList.Init(theQuery["iSubServiceList_ID"][i],variables.dsn);
				
				ArrayAppend(SubServiceListArray,SubServiceList);
			}
			
			return SubServiceListArray;
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

	<cffunction name="GetServiceCategory" access="public" returntype="Components.ServiceCategory" output="false" hint="">
		<cfscript>
			ServiceCategory = CreateObject("Component","Components.ServiceCategory");
			ServiceCategory.Init(variables.serviceCategoryId,variables.dsn);
			
			return ServiceCategory;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetServiceCategory" access="public" returntype="void" output="false" hint="">
		<cfargument name="serviceCategoryId" type="numeric" required="true">
		<cfscript>
			variables.serviceCategoryId = arguments.serviceCategoryId;
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

	<cffunction name="GetWeight" access="public" returntype="numeric" output="false" hint="">
		<cfscript>
			return variables.weight;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetWeight" access="public" returntype="void" output="false" hint="">
		<cfargument name="weight" type="numericng" required="true">
		<cfscript>
			variables.weight = arguments.weight;
		</cfscript>
	</cffunction>

	<cffunction name="GetGrouping" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.grouping;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetGrouping" access="public" returntype="void" output="false" hint="">
		<cfargument name="grouping" type="string" required="true">
		<cfscript>
			variables.grouping = arguments.grouping;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetNotes" access="public" returntype="string" output="false">
		<cfscript>
			return variables.notes;
		</cfscript>
	</cffunction>

	<cffunction name="SetNotes" access="public" returntype="string" output="false">
		<cfargument name="notes" type="string" required="true">
		<cfscript>
			variables.notes = arguments.notes;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetService_text" access="public" returntype="string" output="false">
		<cfscript>
			return variables.Service_text;
		</cfscript>
	</cffunction>

	<cffunction name="SetService_text" access="public" returntype="string" output="false">
		<cfargument name="Service_text" type="string" required="true">
		<cfscript>
			variables.Service_text = arguments.Service_text;
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

	<cffunction name="GetApprovalRequired" access="public" returntype="boolean" output="false" hint="">
		<cfscript>
			return variables.approvalRequired;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetApprovalRequired" access="public" returntype="void" output="false" hint="">
		<cfargument name="approvalRequired" type="boolean" required="true">
		<cfscript>
			variables.approvalRequired = arguments.approvalRequired;
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
