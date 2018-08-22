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
|  ranklam   | 2/15/2007 | Created                                                            |
----------------------------------------------------------------------------------------------->
<cfcomponent name="TenantState" output="false" extends="Components.AlcBase">
	<cffunction name="Init" access="public" returntype="void" output="false">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="dsn" type="string" required="true">
		
		<cfscript>
			//create the variables for the tenant
			variables.id = arguments.id;
			variables.dsn = arguments.dsn;
			variables.moveInDate = '';
			variables.aptAddressId = 0;
			variables.noticeDate = '';
			variables.chargeThroughDate = '';
			variables.moveOutDate = '';
			variables.moveReasonTypeId = 0;
			variables.tenantStateCodeId = 0;
			variables.residencyTypeId = 0;
			variables.points = 0;
			variables.spEvaluationDate = '';
			variables.pointsNurse = 0;
			variables.spEvaluationNurseDate = '';
			variables.isNextMonthsRent = false;
			variables.acctStampDate = '';
			variables.usesEft = false;
			variables.stateDefinedCareLevel = 0;
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
				TenantState
			WHERE
				iTenantState_ID = #variables.id#
		</cfquery>
		
		<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
				//alias the get information query to make typing easier
				theQuery = QueryGetInformation;
				//set the variables
				variables.moveInDate = theQuery["dtMoveIn"][1];
				
				if(theQuery["iAptAddress_Id"][1] neq "")
				{
					variables.aptAddressId = theQuery["iAptAddress_Id"][1];
				}
				variables.noticeDate = theQuery["dtNoticeDate"][1];
				variables.chargeThroughDate = theQuery["dtChargeThrough"][1];
				variables.moveOutDate = theQuery["dtMoveOut"][1];
				variables.moveReasonTypeId = theQuery["iMoveReasonType_ID"][1];
				variables.tenantStateCodeId = theQuery["iTenantStateCode_ID"][1];
				variables.residencyTypeId = theQuery["iResidencyType_ID"][1];
				variables.points = theQuery["iSPoints"][1];
				variables.spEvaluationDate = theQuery["dtSPEvaluation"][1];
				variables.pointsNurse = theQuery["iSPointsNurse"][1];
				variables.spEvaluationNurseDate = theQuery["dtSPEvaluationNurse"][1];
				
				if(theQuery["bNextMonthsRent"][1] neq "")
				{
					variables.isNextMonthsRent = BitToBool(theQuery["bNextMonthsRent"][1]);
				}
				variables.acctStampDate = theQuery["dtAcctStamp"][1];
				if(theQuery["bUsesEft"][1] neq "")
				{
					variables.usesEft = BitToBool(theQuery["bUsesEft"][1]);
				}
				variables.stateDefinedCareLevel = theQuery["iStateDefinedCareLevel"][1];
			
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
				Throw("Tenant state record not found","No tenant state was found for id #variables.id# and datasource #variables.dsn#");
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
	
	<cffunction name="GetMoveInDate" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.moveInDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetMoveInDate" access="public" returntype="void" output="false" hint="">
		<cfargument name="moveInDate" type="string" required="true">
		<cfscript>
			variables.moveInDate = arguments.moveInDate;
		</cfscript>
	</cffunction>

	<cffunction name="GetApartment" access="public" returntype="Components.Apartment" output="false" hint="">
		<cfscript>
			Apartment = CreateObject("Component","Components.Apartment");
			Apartment.Init(variables.aptAddressId,variables.dsn);
			
			return Apartment;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetApartment" access="public" returntype="void" output="false" hint="">
		<cfargument name="aptAddressId" type="string" required="true">
		<cfscript>
			variables.aptAddressId = arguments.aptAddressId;
		</cfscript>
	</cffunction>

	<cffunction name="GetNoticeDate" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.noticeDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SeNoticeDatet" access="public" returntype="void" output="false" hint="">
		<cfargument name="noticeDate" type="string" required="true">
		<cfscript>
			variables.noticeDate = arguments.noticeDate;
		</cfscript>
	</cffunction>

	<cffunction name="GetChargeThroughDate" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.chargeThroughDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetChargeThroughDate" access="public" returntype="void" output="false" hint="">
		<cfargument name="chargeThroughDate" type="string" required="true">
		<cfscript>
			variables.chargeThroughDate = arguments.chargeThroughDate;
		</cfscript>
	</cffunction>

	<cffunction name="GetMoveOutDate" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.moveOutDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetMoveOutDate" access="public" returntype="void" output="false" hint="">
		<cfargument name="moveOutDate" type="string" required="true">
		<cfscript>
			variables.moveOutDate = arguments.moveOutDate;
		</cfscript>
	</cffunction>

	<cffunction name="GetMoveReason" access="public" returntype="Components.MoveReason" output="false" hint="">
		<cfscript>
			MoveReason = CreateObject("Component","Components.MoveReason");
			MoveReason.Init(variables.moveReasonTypeId,variables.dsn);
			
			return MoveReason;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetMoveReason" access="public" returntype="void" output="false" hint="">
		<cfargument name="moveReasonTypeId" type="string" required="true">
		<cfscript>
			variables.moveReasonTypeId = arguments.moveReasonTypeId;
		</cfscript>
	</cffunction>

	<cffunction name="GetTenantStateCode" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.tenantStateCodeId;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetTenantStateCode" access="public" returntype="void" output="false" hint="">
		<cfargument name="tenantStateCodeId" type="string" required="true">
		<cfscript>
			variables.tenantStateCodeId = arguments.tenantStateCodeId;
		</cfscript>
	</cffunction>

	<cffunction name="GetResidencyType" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.residencyTypeId;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetResidencyType" access="public" returntype="void" output="false" hint="">
		<cfargument name="residencyTypeId" type="string" required="true">
		<cfscript>
			variables.residencyTypeId = arguments.residencyTypeId;
		</cfscript>
	</cffunction>

	<cffunction name="GetPoints" access="public" returntype="numeric" output="false" hint="">
		<cfscript>
			return variables.points;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPoints" access="public" returntype="void" output="false" hint="">
		<cfargument name="points" type="numeric" required="true">
		<cfscript>
			variables.points = arguments.points;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetSpEvaluationDate" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.spEvaluationDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSpEvaluationDate" access="public" returntype="void" output="false" hint="">
		<cfargument name="spEvaluationDate" type="string" required="true">
		<cfscript>
			variables.spEvaluationDate = arguments.spEvaluationDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetPointsNurse" access="public" returntype="numeric" output="false" hint="">
		<cfscript>
			return variables.pointsNurse;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPointsNurse" access="public" returntype="void" output="false" hint="">
		<cfargument name="pointsNurse" type="numeric" required="true">
		<cfscript>
			variables.pointsNurse = arguments.pointsNurse;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetSpEvaluationNurseDate" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.spEvaluationNurseDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSpEvaluationNurseDate" access="public" returntype="void" output="false" hint="">
		<cfargument name="spEvaluationNurseDate" type="string" required="true">
		<cfscript>
			variables.spEvaluationNurseDate = arguments.spEvaluationNurseDate;
		</cfscript>
	</cffunction>

	<cffunction name="GetIsNextMonthsRent" access="public" returntype="boolean" output="false" hint="">
		<cfscript>
			return variables.isNextMonthsRent;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetIsNextMonthsRent" access="public" returntype="void" output="false" hint="">
		<cfargument name="isNextMonthsRent" type="boolean" required="true">
		<cfscript>
			variables.isNextMonthsRent = arguments.isNextMonthsRent;
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

	<cffunction name="GetUsesEft" access="public" returntype="boolean" output="false" hint="">
		<cfscript>
			return variables.usesEft;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetUsesEft" access="public" returntype="void" output="false" hint="">
		<cfargument name="usesEft" type="boolean" required="true">
		<cfscript>
			variables.usesEft = arguments.usesEft;
		</cfscript>
	</cffunction>

	<cffunction name="GetStateDefinedCareLevel" access="public" returntype="string" output="false" hint="">
		<cfscript>
			return variables.stateDefinedCareLevel;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetStateDefinedCareLevel" access="public" returntype="void" output="false" hint="">
		<cfargument name="stateDefinedCareLevel" type="string" required="true">
		<cfscript>
			variables.stateDefinedCareLevel = arguments.stateDefinedCareLevel;
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
