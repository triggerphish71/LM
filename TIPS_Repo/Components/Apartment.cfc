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
| ranklam    | 2/15/2007 | Created                                                             |
-----------------------------------------------------------------------------------------------|
| Sfarmer   | 10/18/2013  |Proj. 102481 removed Walnut db and tables Census & Leadtracking     |
----------------------------------------------------------------------------------------------->
<cfcomponent name="Apartment" output="false" extends="Components.AlcBase">
	<cffunction name="Init" access="public" returntype="void" output="false">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="dsn" type="string" required="true">
<!--- 		<cfargument name="leadtrackingdbserver" type="string" required="true">
		<cfargument name="censusdbserver" type="string" required="true"> --->
		
		<cfscript>
			//create the variables for the tenant
			variables.id = arguments.id;
			variables.dsn = arguments.dsn;
			variables.houseId = 0;
			variables.aptTypeId = 0;
			variables.aptNumber = 0;
			variables.comments = '';
			variables.acctStampDate = '';
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
				*
			FROM
				AptAddress 
			WHERE
				iAptAddress_id = #variables.id#
		</cfquery>
		<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
				//alias the get information query to make typing easier
				theQuery = QueryGetInformation;
				variables.houseId = theQuery["iHouse_ID"][1];
				variables.aptTypeId = theQuery["iAptType_ID"][1];
				variables.aptNumber = theQuery["cAptNumber"][1];
				variables.comments = theQuery["cComments"][1];
				variables.acctStampDate = theQuery["dtAcctStamp"][1];
				
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
				Throw("");
			}
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

	<cffunction name="GetAptType" access="public" returntype="Components.AptType" output="false" hint="">
		<cfscript>
			AptType = CreateObject("Component","Components.AptType");
			AptType.Init(variables.aptTypeId,variables.dsn);
			
			return AptType;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetAptType" access="public" returntype="void" output="false" hint="">
		<cfargument name="aptTypeId" type="numeric" required="true">
		<cfscript>
			variables.aptTypeId = arguments.aptTypeId;
		</cfscript>
	</cffunction>

	<cffunction name="GetHouse" access="public" returntype="Components.House" output="false" hint="">
		<cfscript>
			House = CreateObject("Component","Components.House");
			//House.Init(variables.iHouse_id,variables.dsn,variables.leadtrackingdbserver,variables.censusdbserver);
			House.Init(variables.iHouse_id,variables.dsn);			
			return House;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetHouse" access="public" returntype="void" output="false" hint="">
		<cfargument name="houseId" type="string" required="true">
		<cfscript>
			variables.houseId = arguments.houseId;
		</cfscript>
	</cffunction>

	<cffunction name="GetNumber" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.aptNumber;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetNumber" access="public" returntype="void" output="false" hint="">
		<cfargument name="aptNumber" type="string" required="true">
		<cfscript>
			variables.aptNumber = arguments.aptNumber;
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
			variables.comments = arguments.comments;
		</cfscript>
	</cffunction>

	<cffunction name="GetAcctStampDate" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.acctStampDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetAcctStampDate" access="public" returntype="void" output="false" hint="">
		<cfargument name="acctStampDate" type="string" required="true">
		<cfscript>
			variables.acctStampDate = arguments.acctStampDate;
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
