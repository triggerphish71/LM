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

<cfcomponent name="AptType" output="false" extends="Components.AlcBase">
	<cffunction name="Init" access="public" returntype="void" output="false">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="dsn" type="string" required="true">
		<cfscript>
			//create the variables for the object
			variables.id = arguments.id;
			variables.dsn = arguments.dsn;
			variables.displayOrder = 0;
			variables.isPhysicalApt = true;
			variables.isCompanionSuite = false;
			variables.description = "";
			variables.comments = "";
			variables.acctStamp = "";
			variables.displayOnRateCard = true;
			variables.glCode = "";
			variables.discountGlCode = "";
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
				*
			FROM
				AptType A
			WHERE
				A.iAptType_ID = #variables.id#
		</cfquery>
		<!--- Set local variables --->
		<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
				//alias the get information query to make typing easier
				theQuery = QueryGetInformation;
				
				variables.displayOrder = theQuery["iDisplayOrder"][1];
				
				if(theQuery["bIsPhysicalApt"][1] eq 0)
				{
					variables.isPhysicalApt = false;
				}
				
				if(theQuery["bIsCompanionSuite"][1] eq 1)
				{
					variables.isCompanionSuite = true;
				}
				
				variables.description = theQuery["cDescription"][1];
				variables.comments = theQuery["cComments"][1];
				variables.acctStamp = theQuery["dtAcctStamp"][1];
				variables.glCode = theQuery["cGlCode"][1];
				variables.discountGlCode = theQuery["cDiscountGlCode"][1];
				
				if(theQuery["bDisplayOnRateCard"][1] eq 0)
				{
					variables.isPhysicalApt = false;
				}
				 
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
				Throw("AptType not found","AptType #variables.id# not found in the database.");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="Save" access="public" returntype="boolean" output="false" hint="Saves current apartment type">
		<cftry>
			<cfquery name="SaveAptType" datasource="#variables.dsn#">
				UPDATE
					AptType
				SET
					 iDisplayOrder = #variables.displayOrder#
					,bIsPhysicalApt = #BoolToBit(variables.isPhysicalApt)#
					,bIsCompanionSuite = #BoolToBit(variables.isCompanionSuite)#
					,cDescription = '#variables.description#'
					,cComments = '#variables.comments#'
					,dtAcctStamp = '#variables.acctStamp#'
					<cfif isNumeric(variables.rowStartUserId) AND variables.rowStartuserId neq 0>
					,iRowStartUser_ID = #variables.rowStartUserId#
					</cfif>
					,dtRowStart = GetDate()
					,cGlCode = '#variables.glCode#'
					,cDiscountGlCode = '#variables.discountGlCode#'
				WHERE
					iAptType_ID = #variables.id#
			</cfquery>
			
			<cfreturn true>
		<cfcatch type="any">
			<cfreturn false>
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="GetAllAptTypes" access="public" returntype="array" output="false" hint="Gets all current apartment types">
		<cfargument name="dsn" required="true" default="">
		
		<!--- get all the non deleted apartment types --->
		<cfquery name="GetAptTypes" datasource="#arguments.dsn#">
			SELECT DISTINCT
				y.iAptType_ID
			FROM
				tenant t
			INNER JOIN 
				tenantstate s ON s.itenant_id = t.itenant_id
			INNER JOIN
				aptaddress a ON a.iaptaddress_id = s.iaptaddress_id
			INNER JOIN
				apttype y ON y.iapttype_id = a.iapttype_id
		</cfquery>
		
		<cfscript>
			if(GetAptTypes.RecordCount gt 0)
			{
				AptTypeArray = ArrayNew(1);
				
				for(i = 1; i lte GetAptTypes.RecordCount; i = i + 1)
				{
					//create a new apartment type to add to the array
					AptType = CreateObject("Component","Components.AptType");
					AptType.Init(GetAptTypes["iAptType_ID"][i],arguments.dsn);
					
					ArrayAppend(AptTypeArray,AptType);
				}
			}
			else
			{
				Throw("Database error","There was an error getting apartment types from the database.","Database");
			}
			
			return AptTypeArray;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetActiveCount" access="public" returntype="string" output="false">
		<!--- first get the count from the database --->
		<cfquery name="GetActiveCountQuery" datasource="#variables.dsn#">
			select 
				count(a.iaptaddress_id) as typeCount
			from
				aptaddress a
			inner join
				house h on h.ihouse_id = a.ihouse_id
					and
				h.bissandbox = 0
					and
				h.dtrowdeleted is null
			where
				a.iapttype_id = #variables.id#
			and
				a.dtrowdeleted is null
		</cfquery>
		<cfscript>
			return GetActiveCountQuery["typeCount"][1];
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


	<cffunction name="GetDisplayOrder" access="public" returntype="numeric" output="false" hint="">
		<cfscript>
			return variables.displayOrder;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetDisplayOrder" access="public" returntype="void" output="false" hint="">
		<cfargument name="displayOrder" type="numeric" required="true">
		<cfscript>
			variables.displayOrder = arguments.displayOrder;
		</cfscript>
	</cffunction>

	<cffunction name="GetIsPhysicalApt" access="public" returntype="boolean" output="false" hint="">
		<cfscript>
			return variables.isPhysicalApt;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetIsPhysicalApt" access="public" returntype="void" output="false" hint="">
		<cfargument name="isPhysicalApt" type="string" required="true">
		<cfscript>
			variables.isPhysicalApt = arguments.isPhysicalApt;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetIsCompanionSuite" access="public" returntype="boolean" output="false" hint="">
		<cfscript>
			return variables.isCompanionSuite;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetIsCompanionSuite" access="public" returntype="void" output="false" hint="">
		<cfargument name="isCompanionSuite" type="boolean" required="true">
		<cfscript>
			variables.isCompanionSuite = arguments.isCompanionSuite;
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

	<cffunction name="GetGlCode" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.glCode;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetGlCode" access="public" returntype="void" output="false" hint="">
		<cfargument name="glCode" type="string" required="true">
		<cfscript>
			variables.glCode = arguments.glCode;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetDiscountGlCode" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.discountGlCode;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetDiscountGlCode" access="public" returntype="void" output="false" hint="">
		<cfargument name="discountGlCode" type="string" required="true">
		<cfscript>
			variables.discountGlCode = arguments.discountGlCode;
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
