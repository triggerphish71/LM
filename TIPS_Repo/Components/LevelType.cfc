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
----------------------------------------------------------------------------------------------->

<cfcomponent name="LevelType" output="false" extends="Components.AlcBase">
	<cffunction name="Init" access="public" returntype="void" output="false">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="dsn" type="string" required="true">
		<cfscript>
			//create the variables for the object
			variables.id = arguments.id;
			variables.dsn = arguments.dsn;
			variables.sLevelTypeSet = '';
			variables.pointsMin = 0;
			variables.pointsMax = 0;
			variables.description = "";
			variables.comments = "";
			variables.acctStamp = "";
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
				  iSLevelType_ID
			      ,IsNull(cSLevelTypeSet,'') AS cSLevelTypeSet
			      ,IsNull(iSPointsMin,0) AS iSPointsMin
			      ,IsNull(iSPointsMax,0) AS iSPointsMax
			      ,IsNull(cDescription,'') AS cDescription
			      ,IsNull(cComments,'') AS cComments
			      ,IsNull(dtAcctStamp,'') AS dtAcctStamp
			      ,IsNull(iRowStartUser_ID,0) AS iRowStartUser_ID
			      ,IsNull(dtRowStart,'') AS dtRowStart
			      ,IsNull(iRowEndUser_ID,'') AS iRowEndUser_ID
			      ,IsNull(dtRowEnd,'') AS dtRowEnd
			      ,IsNull(iRowDeletedUser_ID,0) AS iRowDeletedUser_ID
			      ,IsNull(dtRowDeleted,'') AS dtRowDeleted
			      ,IsNull(cRowStartUser_ID,'') AS cRowStartUser_ID
			      ,IsNull(cRowEndUser_ID,'') AS cRowEndUser_ID
			      ,IsNull(cRowDeletedUser_ID,'') AS cRowDeleteUser_ID
			FROM
				SLevelType L
			WHERE
				L.iSLevelType_ID = #variables.id#
		</cfquery>
		<!--- Set local variables --->
		<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
				//alias the get information query to make typing easier
				theQuery = QueryGetInformation;
				variables.id = theQuery["iSLevelType_ID"][1];	
				variables.sLevelTypeSet = theQuery["cSLevelTypeSet"][1];
				variables.pointsMin = theQuery["iSPointsMin"][1];
				variables.pointsMax = theQuery["iSPointsMax"][1];
				variables.description = theQuery["cDescription"][1];
				variables.comments = theQuery["cComments"][1];
				variables.acctStamp = theQuery["dtAcctStamp"][1];
				 
				//if the row start is the users id set it, otherwise if its null try the crowstartuserid
				if(theQuery["iRowStartUser_ID"][1] neq "")
				{
					variables.rowStartUserId = theQuery["iRowStartUser_ID"][1];
				}
				else
				{
					variables.rowStartUserId = theQuery["cRowStartUser_ID"][1];
				}
				
				variables.rowStartDate = theQuery["dtRowStart"][1];
				
				//if the end start is the users id set it, otherwise if its null try the crowstartuserid
				if(theQuery["iRowEndUser_ID"][1] neq "")
				{
					variables.rowEndUserId = theQuery["iRowEndUser_id"][1];
				}
				else
				{
					variables.rowEndUserId = theQuery["cRowEndUser_id"][1];
				}
				
				variables.rowEndDate = theQuery["dtRowEnd"][1];
				
				if(theQuery["iRowEndUser_ID"][1] neq "")
				{
					variables.rowDeletedUserId = theQuery["iRowEndUser_ID"][1];
				}
				else
				{
					variables.rowDeletedUserId = theQuery["cRowEndUser_ID"][1];
				}
				
				variables.rowDeletedDate = theQuery["dtRowDeleted"][1];	
			}
			else
			{
				Throw("LevelType not found","LevelType #variables.id# not found in the database.");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="GetLevelTypeForPoints" access="public" returntype="Components.LevelType" output="false">
		<cfargument name="points" type="numeric" required="true">
		<cfargument name="levelTypeSet" type="string" required="true">
		<cfargument name="dsn" type="string" required="true">
		
		<cfquery name="GetTypeSet" datasource="#arguments.dsn#">
			SELECT
				iSLevelType_ID
			FROM
				SLevelType
			WHERE
				#arguments.points# BETWEEN iSPointsMin AND iSPointsMax
			AND
				cSLevelTypeSet = '#arguments.levelTypeSet#'
			AND
				dtRowDeleted IS NULL
		</cfquery>
		
		<cfscript>
			LevelType = CreateObject("Component","Components.LevelType");
			LevelType.Init(GetTypeSet["iSlevelType_ID"][1],arguments.dsn);
			
			return LevelType;
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

	<cffunction name="GetSLevelTypeSet" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.sLevelTypeSet;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSLevelTypeSet" access="public" returntype="void" output="false" hint="">
		<cfargument name="sLevelTypeSet" type="string" required="true">
		<cfscript>
			variables.sLevelTypeSet = arguments.sLevelTypeSet;
		</cfscript>
	</cffunction>

	<cffunction name="GetPointsMin" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.pointsMin;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPointsMin" access="public" returntype="void" output="false" hint="">
		<cfargument name="pointsMin" type="string" required="true">
		<cfscript>
			variables.pointsMin = arguments.pointsMin;
		</cfscript>
	</cffunction>

	<cffunction name="GetPointsMax" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.pointsMax;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPointsMax" access="public" returntype="void" output="false" hint="">
		<cfargument name="pointsMax" type="string" required="true">
		<cfscript>
			variables.variables.pointsMax = arguments.variables.pointsMax;
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

	<cffunction name="GetComments" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.comments;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetComments" access="public" returntype="void" output="false" hint="">
		<cfargument name="comments" type="string" required="true">
		<cfscript>
			variables.comments = arguments.cComments;
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
