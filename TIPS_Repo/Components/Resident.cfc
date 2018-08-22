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
| ranklam    | 09/29/2006 | Created                                                            |
-----------------------------------------------------------------------------------------------|
| Sfarmer   | 10/18/2013  |Proj. 102481 removed Walnut db and tables Census & Leadtracking     |
----------------------------------------------------------------------------------------------->

<cfcomponent name="Resident" output="false" extends="Components.AlcBase">
	<cffunction name="Init" access="public" returntype="void" output="false">
		<!--- <cfargument name="id" type="numeric" required="false" default="0"> --->
		<cfargument name="tenantid" type="numeric" required="false" default="0">
		 <cfargument name="dsn" type="string" required="true"> 
		<cfargument name="tipsDsn" type="string" required="true">
		<!--- <cfargument name="leadtrackingdbserver" type="string" required="true">
		<cfargument name="censusdbserver" type="string" required="true"> --->
		
		<cfscript>
			//create the variables for the tenant
			//variables.id = arguments.id;
			variables.id = arguments.tenantid;
			variables.itenantid = arguments.tenantid;
			//variables.dsn = arguments.dsn;
			variables.dsn = '';
			variables.tipsDsn = arguments.tipsDsn;
			variables.firstName = '';
			variables.lastName = '';
			variables.birthDate = '';
			variables.ssn = '';
			variables.sex = '';
			variables.houseId = 0;
			variables.phoneNumber1 = '';
			variables.phoneNumber2 = '';
			variables.addressLine1 = '';
			variables.addressLine2 = '';
			variables.city = '';
			variables.stateCode = '';
			variables.zipCode = '';
			variables.rowStartUserId = 0;
			variables.rowStartDate = '';
			variables.rowEndUserId = 0;
			variables.rowEndDate = '';
			variables.rowDeletedUserId = 0;
			variables.rowDeletedDate = '';
			variables.leadtrackingdbserver = '';
			variables.censusdbserver = '';	
			variables.productLineID = '';	
			variables.dtMoveIn = '';	
			//variables.leadtrackingdbserver = arguments.leadtrackingdbserver;
			//variables.censusdbserver = arguments.censusdbserver;
			
			//if the id isn't 0 this is an actual tenant, get their information;
			if(variables.id neq 0 or variables.itenantid neq 0)
			{
				GetInformation();
				GetAssessment();
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="GetInformation" access="private" returntype="void" output="false">
		<cfquery name="QueryGetInformation" datasource="#variables.tipsdsn#">
			SELECT iResident_ID = r.itenant_id
				  ,R.*
				 ,R.iHouse_id
				 ,S.iTenant_Id
				 ,S.iProductLine_ID
				 ,S.dtMoveIn
			FROM
				Tenant R 
			INNER JOIN
				TenantState S ON S.itenant_id = R.itenant_id
			WHERE
			 s.iTenant_Id = #variables.itenantid#
		</cfquery>	

		<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
				//this is just easier to type than querygettenantinformation
				theQuery = QueryGetInformation;

				//create the variables for the tenant
			 	variables.id = theQuery["iResident_ID"][1];
				variables.id = theQuery["iTenant_ID"][1];
				variables.itenantid = theQuery["iTenant_ID"][1];
				variables.firstName = theQuery["cFirstName"][1];
				variables.lastName = theQuery["cLastName"][1];
				variables.birthDate = theQuery["dBirthDate"][1];
				variables.ssn = theQuery["cSSN"][1];
				variables.phoneNumber1 = theQuery["cOutsidePhoneNumber1"][1]; //["cPhoneNumber1"][1];
				variables.phoneNumber2 = theQuery["cOutsidePhoneNumber2"][1]; //["cPhoneNumber2"][1];
				variables.addressLine1 = theQuery["cOutsideAddressLine1"][1];
				variables.addressLine2 = theQuery["cOutsideAddressLine2"][1];
				variables.houseId = theQuery["iHouse_id"][1];
				variables.city = theQuery["cOutsideCity"][1];
				variables.stat = theQuery["cOutsideStateCode"][1];
				variables.zipCode = theQuery["cOutsideZipCode"][1];
				variables.rowStartUserId = theQuery["cRowStartUser_ID"][1];
				variables.rowStartDate = theQuery["dtRowStart"][1];
				variables.rowEndUserId = theQuery["cRowEndUser_id"][1];
				variables.rowDeletedUserId = theQuery["cRowEndUser_ID"][1];
				variables.rowDeletedDate = theQuery["dtRowDeleted"][1];
				variables.productLineID = theQuery["iProductLine_ID"][1];
				if(isDate(theQuery["dtMoveIn"][1])){
					variables.dtMoveIn = DateFormat(theQuery['dtMoveIn'][1],"mm/dd/yyyy");
				}
				else{
					variables.dtMoveIn = '';
				}
			}	
					
			else
			{
				Throw("Resident not found","Resident #variables.id# information not found in datasource #variables.dsn#.");
			}
		
		</cfscript>
	</cffunction>
	
	<cffunction name="GetAssessment" access="public" returntype="void" output="false">
		<!--- Get the assessment from the database --->
		<cfquery name="GetAssessmentQuery" datasource="#variables.tipsDsn#">
			SELECT IsNull(Max(iAssessmentToolMaster_ID),0) AS iAssessmentToolMaster_ID
			FROM
				AssessmentToolMaster
			WHERE
				iResident_ID = #variables.id# or iTenant_ID = #variables.itenantid# 
			AND
				dtRowDeleted IS NULL
			AND
				bBillingActive = 1
		</cfquery>
		<cfset setPoints(points=0)>
		<cfif getAssessmentQuery.recordcount GT 0>
			<cfquery name="getAssessmentPoints" datasource="#variables.tipsDsn#">
				SELECT IsNULL(iSLPoints,0) as points
				FROM AssessmentToolMaster
				WHERE iAssessmentToolMaster_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#getAssessmentQuery.iAssessmentToolMaster_ID#">
			</cfquery>	
			<cfif getAssessmentPoints.recordcount GT 0>
				<cfset setPoints(points=getAssessmentPoints.points)>
			</cfif>
		</cfif>
		
		<cfscript>
			if(GetAssessmentQuery.RecordCount gt 0)
			{
				//this is just easier to type than GetAssessmentQuery
				theQuery = GetAssessmentQuery;
				
				//create the variables for the tenant
				variables.assessmentid = theQuery["iAssessmentToolMaster_ID"][1];
				
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="GetAssessments" access="public" returntype="array" output="false">
		<!--- Get the assessments from the database --->
		<cfquery name="GetAssessmentsQuery" datasource="#variables.tipsDsn#">
			SELECT
				 iAssessmentToolMaster_ID
				,bBillingActive
			FROM
				AssessmentToolMaster 
			WHERE
				iResident_ID = #variables.id#
			AND
				dtRowDeleted IS NULL
			ORDER BY
				bBillingActive DESC
		</cfquery>
		
		<cfscript>
			theQuery = GetAssessmentsQuery;
			AssessmentArray = ArrayNew(1);
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
				Assessment = CreateObject("Component","Components.Assessment");
	//			Assessment.Init(theQuery["iAssessmentToolMaster_ID"][i],variables.tipsDsn,variables.leadtrackingdbserver);
				Assessment.Init(theQuery["iAssessmentToolMaster_ID"][i],variables.tipsDsn);
				
				ArrayAppend(AssessmentArray,Assessment);
			}
			return AssessmentArray;
		</cfscript>
	</cffunction>
<!----------------------------------------------------------
*                   GETTERS AND SETTERS                    *
----------------------------------------------------------->	

	<cffunction name="GetAssessmentId" access="public" returntype="numeric" output="false" hint="Returns tenants assessment id.">
		<cfscript>
			return variables.assessmentid;
		</cfscript>
	</cffunction>

	<cffunction access="public" name="getPoints" returntype="numeric" output="false" hint="Returns tenants iSLPoints.">
		<cfreturn variables.points>
	</cffunction>

	<cffunction access="public" name="setPoints" returntype="void" output="false" hint="Sets the assessment points">
		<cfargument name="points" type="numeric" required="true">
		<cfset variables.points = arguments.points> 
	</cffunction>

	<cffunction name="GetId" access="public" returntype="numeric" output="false" hint="Returns a tenants id.">
		<cfscript>
			return variables.id;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetTenantId" access="public" returntype="numeric" output="false" hint="Returns the Tenant Id.">
		<cfscript>
			return variables.itenantId;
		</cfscript>
	
	</cffunction>
	
	<cffunction name="GetFirstName" access="public" returntype="string" output="false" hint="Gets the tenants first name">
		<cfscript>
			return variables.firstName;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetFirstName" access="public" returntype="void" output="false" hint="Sets the tenants first name">
		<cfargument name="firstName" type="string" required="true">
		<cfscript>
			variables.firstName = arguments.firstName;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetLastName" access="public" returntype="string" output="false" hint="Gets the tenants last name">
		<cfscript>
			return variables.lastName;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetLastName" access="public" returntype="void" output="false" hint="Sets the tenants last name">
		<cfargument name="lastName" type="string" required="true">
		<cfscript>
			variables.lastName = arguments.lastName;
		</cfscript>
	</cffunction>

	<cffunction name="GetHouse" access="public" returntype="Components.House" output="false" hint="Gets the tenants last name">
		<cfscript>
			House = CreateObject("Component","Components.House");
	//		House.Init(variables.houseId, variables.tipsDsn, variables.leadtrackingdbserver, variables.censusdbserver);
			House.Init(variables.houseId, variables.tipsDsn);
			
			return House;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetName" access="public" returntype="string" output="false" hint="Gets a tenants full name">
		<cfscript> 
		 	return variables.firstname & " " & variables.lastname;
		</cfscript>
	</cffunction>

	<cffunction name="GetBirthDate" access="public" returntype="string" output="false" hint="Gets the tenatns birth date">
		<cfscript>
			return variables.birthDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetBirthDate" access="public" returntype="void" output="false" hint="Sets the tenatns birth date">
		<cfargument name="birthDate" type="string" required="true">
		<cfscript>
			variables.birthDate = arguments.birthDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetSsn" access="public" returntype="string" output="false" hint="Gets the tenants ssn">
		<cfscript>
			return variables.ssn;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSsn" access="public" returntype="void" output="false" hint="Sets the tenants ssn">
		<cfargument name="ssn" type="string" required="true">
		<cfscript>
			variables.ssn = arguments.ssn;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetSex" access="public" returntype="string" output="false" hint="Gets the tenants medicaid number">
		<cfscript>
			return variables.sex;
		</cfscript>	
	</cffunction>
	
	<cffunction name="SetSex" access="public" returntype="void" output="false" hint="Sets the tenants medicaid number">
		<cfargument name="sex" type="string" required="true">
		<cfscript>
			variables.sex = arguments.sex;
		</cfscript>	
	</cffunction>
	
	<cffunction name="GetPhoneNumber1" access="public" returntype="string" output="false" hint="Gets a tenants outside phone number.">
		<cfscript>
			return variables.phoneNumber1;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPhoneNumber1" access="public" returntype="void" output="false" hint="Sets a tenants outside phone number.">
		<cfargument name="phoneNumber1" type="string" required="true">
		<cfscript>
			variables.phoneNumber1 = arguments.phoneNumber1;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetPhoneNumber2" access="public" returntype="string" output="false" hint="Gets a tenants outside phone number.">
		<cfscript>
			return variables.phoneNumber2;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPhoneNumber2" access="public" returntype="void" output="false" hint="Sets a tenants outside phone number.">
		<cfargument name="phoneNumber2" type="string" required="true">
		<cfscript>
			variables.phoneNumber2 = arguments.phoneNumber2;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetAddressLine1" access="public" returntype="string" output="false" hint="Gets a tenants outside address line 1">
		<cfscript>
			return variables.addressLine1;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetAddressLine1" access="public" returntype="string" output="false" hint="Sets a tenants outside address line 1">
		<cfargument name="addressLine1" type="string" required="true">
		<cfscript>
			variables.addressLine1 = arguments.addressLine1;
		</cfscript>
	</cffunction>

	<cffunction name="GetAddressLine2" access="public" returntype="string" output="false" hint="Gets a tenants outside address line 2">
		<cfscript>
			return variables.addressLine2;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetAddressLine2" access="public" returntype="string" output="false" hint="Sets a tenants outside address line 2">
		<cfargument name="addressLine2" type="string" required="true">
		<cfscript>
			variables.addressLine2 = arguments.addressLine2;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetCity" access="public" returntype="string" output="false" hint="Gets a tenants outside city">
		<cfscript>
			return variables.city;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetCity" access="public" returntype="void" output="false" hint="Sets a tenants outside city">
		<cfargument name="city" type="string" required="true">
		<cfscript>
			variables.city = arguments.city;
		</cfscript>
	</cffunction>
		
	<cffunction name="GetState" access="public" returntype="string" output="false" hint="Gets a tenants outside state code">
		<cfscript>
			return variables.stateCode;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetStateCode" access="public" returntype="string" output="false" hint="Sets a tenants outside state code">
		<cfargument name="stateCode" type="string" required="true">
		<cfscript>
			variables.stateCode = arguments.stateCode;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetZipCode" access="public" returntype="string" output="false" hint="Gets a tenants zip code">
		<cfscript>
			return variables.zipCode;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetZipCode" access="public" returntype="string" output="false" hint="Sets a tenants zip code">
		<cfargument name="zipCode" type="string" required="true">
		<cfscript>
			variables.zipCode = arguments.zipCode;
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
	
	<cffunction name="GetType" access="public" returntype="string" output="false">
		<cfscript>
			return "Resident";
		</cfscript>
	</cffunction>	

	<cffunction access="public" name="SetProductLineID" returntype="void" output="false" hint="sets the tenants productlineID">
		<cfargument name="productLineID" type="numeric" required="true">
		<cfset variables.productLineID = arguments.productlineID>
	</cffunction>  

	<cffunction access="public" name="getProductLineID" output="false" returntype="string">
		<cfreturn variables.productLineID>
	</cffunction>

	<cffunction access="public" name="GetMoveIn" output="false" hint="Returns the movein date">
		<cfreturn variables.dtMoveIn>
	</cffunction>

	<cffunction access="public" name="setMoveIn" output="false" hint="Sets the movein date">
		<cfargument name="MoveInDate" type="date" required="true">
		<cfset variables.dtMoveIn = arguments.MoveInDate>
	</cffunction>

</cfcomponent>