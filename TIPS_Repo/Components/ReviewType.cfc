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
| ranklam    | 12/14/2006 | Created                                                            |
|----------------------------------------------------------------------------------------------|
| Sathya     | 01/11/2010 | Added a new function GetMaxFutureBillingDays to get the Maximum    |
|            |            | Future billing Days for Project 41315                              |
|            |            | Also Modified exisiting function GetReviewTypes                    |
|            |            | to include a condition while querying    test                          |
----------------------------------------------------------------------------------------------->

<cfcomponent name="ReviewType" output="false" extends="Components.AlcBase">
	<cffunction name="Init" access="public" returntype="void" output="false">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="dsn" type="string" required="true">
		<cfscript>
			//create the variables for the object
			variables.id = arguments.id;
			variables.dsn = arguments.dsn;
			variables.description = "";
			variables.sortOrder = "";
			variables.futureBillingDays = 0;
			variables.rowStartUserId = 0;
			variables.rowStartDate = "";
			variables.rowEndUserId = 0;
			variables.rowEndDate = "";
			variables.rowDeletedUserId = 0;
			variables.rowDeletedDate = "";
			
			//if the id isn't 0 this is an actual tenant, get their information;
			if(variables.id neq 0)
			{
				GetInformation();
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="GetInformation" access="private" returntype="void" output="false" hint="Gets information and fills the object variables.">
		<!--- Get the information form the database --->
		<cfquery name="QueryGetInformation" datasource="#variables.dsn#">
			SELECT
				   iReviewType_ID
			      ,IsNull(cDescription,'') AS cDescription
			      ,IsNull(cSortOrder,999) AS cSortOrder
			      ,IsNull(dtRowStart,'') AS dtRowStart
			      ,IsNull(dtRowEnd,'') AS dtRowEnd
			      ,IsNull(dtRowDeleted,'') AS dtRowDeleted
			      ,IsNull(cRowStartUser_ID,'') AS cRowStartUser_ID
			      ,IsNull(cRowEndUser_ID,'') AS cRowEndUser_ID
			      ,IsNull(cRowDeletedUser_ID,'') AS cRowDeleteUser_ID
			      ,IsNull(futureBillingDays,0) AS futureBillingDays
			FROM
				ReviewType
			WHERE
				iReviewType_ID = #variables.id#
		</cfquery>
		<!--- Set local variables --->
		<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
				//alias the get information query to make typing easier
				theQuery = QueryGetInformation;
				variables.id = theQuery["iReviewType_ID"][1];
				variables.description = theQuery["cDescription"][1];
				variables.sortOrder = theQuery["cSortOrder"][1];
				 
				variables.rowStartUserId = theQuery["cRowStartUser_ID"][1];
				variables.rowStartDate = theQuery["dtRowStart"][1];
				variables.rowEndUserId = theQuery["cRowEndUser_id"][1];
				variables.rowEndDate = theQuery["dtRowEnd"][1];
				variables.rowDeletedUserId = theQuery["cRowEndUser_ID"][1];
				variables.rowDeletedDate = theQuery["dtRowDeleted"][1];	
				variables.futureBillingDays = theQuery["futureBillingDays"][1];	
			}
			else
			{
				Throw("ReviewType not found","ReviewType #variables.id# not found in the database.");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="GetReviewTypes" access="public" returntype="Array" output="false">
		<cfargument name="dsn" type="string" required="true">
		<!--- 01/11/2010 Sathya modified this as per project 41315 --->
		<cfquery name="GetReviewTypesQuery" datasource="#arguments.dsn#">
			SELECT
				iReviewType_ID
			FROM
				ReviewType
			WHERE
				dtRowDeleted IS NULL
				<!--- 01/11/2010 Sathya Made changes for project 41315 --->
				AND
				iPeriod_id in (SELECT iPeriod_id 
							    FROM
                                House
								WHERE
                                iHouse_id = #session.House.GetId()#)
			ORDER BY
				cSortOrder
		</cfquery>
		
		<cfscript>
			theQuery = GetReviewTypesQuery;
			
			ReviewTypeArray = ArrayNew(1);
			
			for(i = 1; i lte theQuery.RecordCount; i = i +1)
			{
				ReviewType = CreateObject("Component","Components.ReviewType");
				ReviewType.Init(theQuery["iReviewType_ID"][i],arguments.dsn);
				
				ArrayAppend(ReviewTypeArray,ReviewType);
			}
			
			return ReviewTypeArray;
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
	
	<cffunction name="GetGutureBillingDays" access="public" returntype="string" output="false">
		<cfscript>
			return variables.futureBillingDays;
		</cfscript>
	</cffunction>
<!--- 01/11/2010 Project 41315 Sathya Added this to get the Maximum number of days --->
    <cffunction name="GetMaxFutureBillingDays" access="public" returntype="string" output="false" hint="">
		<cfargument name="dsn" type="string" required="true">
		<cfquery name="GetMaxDays" datasource="#arguments.dsn#">
			SELECT
				Max(futureBillingDays) as MaxFutureBillingDays
			FROM
				ReviewType
			WHERE
				dtRowDeleted IS NULL
				AND
				iPeriod_id in (SELECT iPeriod_id 
							    FROM
                                House
								WHERE
                               iHouse_id = #session.House.GetId()#)
		</cfquery>
		
		<cfreturn GetMaxDays.MaxFutureBillingDays>
	</cffunction>	
	<cffunction name="GetSortOrder" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.sortOrder;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSortOrder" access="public" returntype="void" output="false" hint="">
		<cfargument name="sortOrder" type="string" required="true">
		<cfscript>
			variables.sortOrderents = arguments.sortOrder;
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
