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
| ssanipina  | 01/27/2008 | Added two functions GetTotalPointsBymonthsAndResidencyType and     |
|                            GetTotalPointsByMonthsAndResidencyTypeExcellExport                |
-----------------------------------------------------------------------------------------------|
| jcruz		 | 02/28/2008 | Modified GetInquiryAssessmentsAsStruct to change the sort order    |
|                           for assessments that appear in main page. Newest assessment will   |
|							now appear on the top of each list.								   |
-----------------------------------------------------------------------------------------------|
| jcruz		 | 03/14/2008 | Modified GetAssessmentsAsStruct to change the sort order           |
|                           for assessments that appear in main page. Newest assessment will   |
|							now appear on the top of each list.								   |
-----------------------------------------------------------------------------------------------|
| jcruz		 | 08/21/2008	| Modified GetInquiryAssessmentsAsStruct to change the sort order  |
|                       	  for assessments that appear in main page. Only assessments for   |
|							| residents in status 7 (comitted) will appear on the screen.	   |
|						 	| Added iTenant_ID to query for to use as part of the Service Plan |
|						 	| Project. Now Resident Type Assessments will be saved with the    |
|						 	| Tenant ID and the Resident ID.								   |
| jcruz		 | 09/27/2008	| Modified GetAssessmentsAsStructs function so it includes         |
|  			 |				| Resident Id field. GetInquiryResident function also modified so  |
|			 |				| it now only looks for residents in status code 7 (Committed)	   |
| Gthota     | 04/25/2013   | More specified sql statement to get result set for enquiry tenant sec.| 
| Sfarmer    | 10/18/2013   |Proj. 102481 removed Walnut db and tables Census & Leadtracking        |
| SFarmer    | 2015-07-20   | added "and t.cfirstname is not null" to GetInquiryAssessmentsAsStruct |
|            |              | to prevent the dummy medicaid tenants from being displayed            |
| Sfarmer    | 2017-01-25   | GetFormattedName revised                                              |
---------------------------------------------------------------------------------------------------->
<cfcomponent name="House" output="false" extends="Components.AlcBase">
	<cffunction name="Init" access="public" returntype="void" output="false">
		<cfargument name="id" type="numeric" required="false" default="0">
		<cfargument name="dsn" type="string" required="true">
<!--- 		<cfargument name="censusdbserver" type="string" required="true">
		<cfargument name="leadtrackingdbserver" type="string" required="true"> --->
		
		<cfscript>
			//create the variables for the tenant
			variables.id = arguments.id;
			variables.dsn = arguments.dsn;
			variables.opsAreaId = 0;
			variables.pdUserId = 0;
			acctUserId = 0;
			variables.name = '';
			variables.number = '';
			variables.depositTypeSet = '';
			variables.sLevelTypeSet = '';
			variables.glSubAccount = '';
			variables.isCensusMedicaidOnly = false;
			variables.phoneNumber1 = '';
			variables.phoneType1Id = 0;
			variables.phoneNumber2 = '';
			variables.phoneType2Id = 0;
			variables.phoneNumber3 = '';
			variables.phoneType3Id = 0;
			variables.addressLine1 = '';
			variables.addressLine2 = '';
			variables.city = '';
			variables.stateCode = '';
			variables.zipCode = '';
			variables.comments = '';
			variables.acctStamp = '';
			variables.billingType = '';
			variables.rowStartUserId = 0;
			variables.rowStartDate = '';
			variables.rowEndUserId = 0;
			variables.rowEndDate = '';
			variables.rowDeletedUserId = 0;
			variables.rowDeletedDate = '';
			variables.unitsAvailable = '';
			variables.rentalAgreementDate = '';
			variables.nurseUserId = 0;
			variables.ehsiFacilityId = 0;
			variables.isSandbox = false;
			variables.chargeSetId = 0;
			variables.email ='';
			variables.currentTipsMonth = '';
			variables.isPeriodClosed = false;
			variables.censusdbserver = ''; //arguments.censusdbserver;
			variables.leadtrackingdbserver = ''; //arguments.leadtrackingdbserver;
			variables.houseType = '';
			
			//if the id isn't 0 this is an actual tenant, get their information
			if(variables.id neq 0)
			{
				GetInformation();
				HouseTypeCheck(houseid=variables.id);
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="GetInformation" access="private" returntype="void" output="false" hint="Gets information and fills the object variables.">
		<cfquery name="QueryGetInformation" datasource="#variables.dsn#">
			SELECT
				 h.*
				,L.dtCurrentTipsMonth AS tipsmonth
				,IsNull(L.bIsPdClosed,0) AS isClosed
				,'' AS houseemail
				<!--- ,IsNull(a.houseemail,'') AS houseemai ---> 
			FROM
				House h
			INNER JOIN
				HouseLog L ON L.ihouse_id = H.ihouse_id
			<!--- LEFT JOIN 
				#variables.censusdbserver#.census.dbo.houseaddresses a on a.nHouse = h.cNumber	 --->
			WHERE
				h.iHouse_ID = #variables.id#
		</cfquery>
		
		<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
				//alias the get information query to make typing easier
				theQuery = QueryGetInformation;
	
				variables.opsAreaId = theQuery["iOpsArea_ID"][1];
				variables.pdUserId = theQuery["iPDUser_ID"][1];
				acctUserId = theQuery["iAcctUser_ID"][1];
				variables.name = theQuery["cName"][1];
				variables.number = theQuery["cNumber"][1];
				variables.depositTypeSet = theQuery["cDepositTypeSet"][1];
				variables.sLevelTypeSet = theQuery["cSLevelTypeSet"][1];
				variables.glSubAccount = theQuery["cGlSubAccount"][1];
				variables.currentTipsMonth = theQuery["tipsmonth"][1];
				variables.isPeriodClosed = BitToBool(theQuery["isClosed"][1]);
				if(theQuery["bIsCensusMedicaidOnly"][1] eq 1)
				{
					variables.isCensusMedicaidOnly = true;
				}
				variables.phoneNumber1 = theQuery["cPhoneNumber1"][1];
				variables.phoneType1Id = theQuery["iPhoneType1_ID"][1];
				variables.phoneNumber2 = theQuery["cPhoneNumber2"][1];
				variables.phoneType2Id = theQuery["iPhoneType2_ID"][1];
				variables.phoneNumber3 = theQuery["cPhoneNumber3"][1];
				variables.phoneType3Id = theQuery["iPhoneType3_ID"][1];
				variables.addressLine1 = theQuery["cAddressLine1"][1];
				variables.addressLine2 = theQuery["cAddressLine2"][1];
				variables.city = theQuery["cCity"][1];
				variables.stateCode = theQuery["cStateCode"][1];
				variables.zipCode = theQuery["cZipCode"][1];
				variables.comments = theQuery["cComments"][1];
				variables.acctStamp = theQuery["dtAcctStamp"][1];
				variables.billingType = theQuery["cBillingType"][1];
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
				variables.unitsAvailable = theQuery["iUnitsAvailable"][1];
				variables.rentalAgreementDate = theQuery["dtRentalAgreement"][1];
				variables.nurseUserId = theQuery["cNurseUser_ID"][1];
				variables.ehsiFacilityId = theQuery["EHSIFacilityID"][1];
				if(theQuery["bIsSandbox"][1] eq 1)
				{
					variables.isSandbox = true;
				}
				variables.chargeSetId = theQuery["iChargeSet_ID"][1];
				
				variables.email = theQuery["houseemail"][1];
			}
			else
			{
				Throw("House not found","House #variables.id# was not found in datasource #variables.dsn#");
			}
		</cfscript>
	</cffunction>

	<cffunction name="Save" access="public" returntype="void" output="false" hint="Saves the current house object">
		<!--- <cftry> --->
			<cfquery name="QuerySave" datasource="#variables.dsn#">
				UPDATE 
					House
				SET
					 iOpsArea_ID = #variables.opsAreaId# 
					,ipdUser_ID = #variables.pdUserId#
					,iAcctUser_ID = #acctUserId#
					,cName = '#variables.name#'
					,cNumber = '#variables.number#'
					,cDepositTypeSet = '#variables.depositTypeSet#'
					,cSLevelTypeSet = '#variables.sLevelTypeSet#'
					,cGLSubAccount = '#variables.glSubAccount#'
					,bIsCensusMedicaidOnly = <cfif variables.isCensusMedicaidOnly>1<cfelse>0</cfif>
					,cPhoneNumber1 = '#variables.phoneNumber1#'
					,iPhoneType1_ID = #variables.phoneType1Id#
					,cPhoneNumber2 = '#variables.phoneNumber2#'
					,iPhoneType2_ID = #variables.phoneType2Id#
					,cPhoneNumber3 = '#variables.phoneNumber3#'
					,iPhoneType3_ID = #variables.phoneType3Id#
					,cAddressLine1 = '#variables.addressLine1#'
					,cAddressLine2 = '#variables.addressLine2#'
					,cCity = '#variables.city#'
					,cStateCode = '#variables.stateCode#'
					,cZipCode = '#variables.zipCode#'
					,cComments = '#variables.comments#'
					,dtAcctStamp = '#variables.acctStamp#'
					,cBillingType = '#variables.billingType#'
					,iRowStartUser_ID = <cfif isNumeric(variables.rowStartUserId)>#variables.rowStartUserId#<cfelse>NULL</cfif>
					,dtRowStart = <cfif isDate(variables.rowStartDate)>'#variables.rowStartDate#'<cfelse>NULL</cfif>
					,iRowEndUser_ID = <cfif isNumeric(variables.rowEndUserId)>#variables.rowEndUserId#<cfelse>NULL</cfif>
					,dtRowEnd = <cfif isDate(variables.rowEndDate)>'#variables.rowEndDate#'<cfelse>NULL</cfif>
					,iRowDeletedUser_ID = <cfif isNumeric(variables.rowDeletedUserId)>#variables.rowDeletedUserId#<cfelse>NULL</cfif>
					,dtRowDeleted = <cfif isDate(variables.rowDeletedDate)>'#variables.rowDeletedDate#'<cfelse>NULL</cfif>
					,cRowStartUser_ID = <cfif NOT isNumeric(variables.rowStartUserId) AND variables.rowStartUserId NEQ "">'#variables.rowStartUserId#'<cfelse>NULL</cfif>
					,cRowEndUser_ID = <cfif NOT isNumeric(variables.rowEndUserId) AND variables.rowEndUserId NEQ "">'#variables.rowEndUserId#'<cfelse>NULL</cfif>
					,cRowDeletedUser_ID = <cfif NOT isNumeric(variables.rowDeletedUserId) AND variables.rowDeletedUserId NEQ "">'#variables.rowDeletedUserId#'<cfelse>NULL</cfif>
					,iUnitsAvailable = #variables.unitsAvailable#
					,dtRentalAgreement = <cfif isDate(variables.rentalAgreementDate)>'#variables.rentalAgreementDate#'<cfelse>NULL</cfif>
					,cNurseUser_ID = '#variables.nurseUserId#'
					,EHSIFacilityId = '#variables.ehsiFacilityId#'
					,bIsSandbox = <cfif variables.isSandbox>1<cfelse>0</cfif>
					,iChargeSet_ID = #variables.chargeSetId#
				WHERE
					iHouse_ID = #variables.id#	
			</cfquery>
		<!--- <cfcatch>
			<cfdump var="#cfcatch#">
			<cfthrow message="Save failed." detail="Save for house #variables.id# failed on datasource #variables.dsn#.">
		</cfcatch>
		</cftry> --->
	</cffunction>
	
	<cffunction name="GetActiveHouses" access="public" returntype="array" output="false" >
		<cfargument name="dsn" type="string" required="false" default="">
<!--- 		<cfargument name="leadtrackingdbserver" type="string" required="false" default="">
		<cfargument name="censusdbserver" type="string" required="false" default=""> --->
		
		<cfquery name="GetHouses" datasource="#arguments.dsn#">
			SELECT 
				 h.ihouse_ID
			FROM 
				House h
<!--- 			INNER JOIN 
				census.dbo.houseaddresses a on a.nHouse = h.cNumber --->
			WHERE 
				h.bisSandbox = 0
			AND 
				h.dtrowdeleted is NULL
			ORDER BY
				h.cName
		</cfquery>

		<cfscript>
			HouseArray = ArrayNew(1);
			
			// Loop through houses's array. Create House Object
			for(i = 1; i lte GetHouses.RecordCount; i=i+1)
			{
				House = CreateObject("Component", "Components.House");
			//	House.Init (GetHouses["ihouse_ID"][i],arguments.dsn,arguments.leadtrackingdbserver,arguments.censusdbserver);
				House.Init (GetHouses["ihouse_ID"][i],arguments.dsn);
				
				ArrayAppend(HouseArray, House);
			}				
			
			Return HouseArray;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetCurrentPrivateTenants" access="public" returntype="array" output="false">
		<cfargument name="sortColumns" default="">
		<cfquery name="GetTenantsQuery" datasource="#variables.dsn#">
			SELECT
				t.itenant_id
			FROM
				tenant t
			INNER JOIN
				tenantstate s on s.itenant_id = t.itenant_id
					AND
				s.itenantstatecode_id < 3
					AND
				T.bIsMedicaid IS NULL
					AND
				T.bIsMisc IS NULL
			LEFT JOIN
				AptAddress a on a.iAptAddress_ID = S.iAptAddress_ID
			WHERE
				t.ihouse_id = #variables.id#
			AND
				t.dtrowdeleted IS NULL
			<cfif arguments.sortColumns NEQ "">
			ORDER BY
				#arguments.sortColumns#
			</cfif>
		</cfquery>
		
		<cfscript>
			theQuery = GetTenantsQuery;
			TenantArray = ArrayNew(1);
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
				Tenant = CreateObject("Component","Components.Tenant");
				//Tenant.Init(theQuery["iTenant_ID"][i],variables.dsn,variables.leadtrackingdbserver,variables.censusdbserver);
				Tenant.Init(theQuery["iTenant_ID"][i],variables.dsn);
				
				ArrayAppend(TenantArray,Tenant);
			}
			
			return TenantArray;
		</cfscript>
	</cffunction>

	<cffunction name="GetInquiryResidents" access="public" returntype="array" output="false">
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="tipsDsn" type="string" required="true">
		<cfargument name="sortColumns" default="" required="false">
		<!--- <cfargument name="leadtrackingdbserver" type="string" required="true">
		<cfargument name="censusdbserver" type="string" required="true"> --->
		<cfargument name="tips4dbserver" type="string" required="true">
		<cfquery name="GetResidentQuery" datasource="#arguments.dsn#">
			SELECT DISTINCT
				 R.clastname
				,R.cfirstname
				,R.iresident_id
			FROM
				Tenant R
			INNER JOIN
				TenantState S ON S.itenant_id = R.itenant_id 
					AND
				S.dtrowdeleted IS NULL
			INNER JOIN
				tenantstatecode A ON A.itenantstatecode_id = S.itenantstatecode_id 
					AND
				A.dtrowdeleted is null
			INNER JOIN
				#arguments.tips4dbserver#.TIPS4.dbo.House H ON H.ihouse_id = S.ihouse_id 
					AND 
				h.dtrowdeleted IS NULL
			INNER JOIN
				#arguments.tips4dbserver#.TIPS4.dbo.SLevelType Y on Y.csleveltypeset = H.csleveltypeset 
					AND
				Y.dtrowdeleted IS NULL
					AND 
				A.itenantstatecode_id NOT IN (3,4)
			WHERE 
				R.dtrowdeleted IS NULL 
			AND 
				S.ihouse_id = #variables.id# 	
			<cfif arguments.sortColumns NEQ "">
			ORDER BY
				#arguments.sortColumns#
			</cfif>
		</cfquery>		
<!--- 		<cfquery name="GetResidentQuery" datasource="#arguments.dsn#">
			SELECT DISTINCT
				 R.clastname
				,R.cfirstname
				,R.iresident_id
			FROM
				Resident R
			INNER JOIN
				ResidentState S ON S.iresident_id = R.iresident_id 
					AND
				S.dtrowdeleted IS NULL
			INNER JOIN
				Status A ON A.istatus_id = S.istatus_id 
					AND
				A.dtrowdeleted is null
			INNER JOIN
				#arguments.tips4dbserver#.TIPS4.dbo.House H ON H.ihouse_id = S.ihouse_id 
					AND 
				h.dtrowdeleted IS NULL
			INNER JOIN
				#arguments.tips4dbserver#.TIPS4.dbo.SLevelType Y on Y.csleveltypeset = H.csleveltypeset 
					AND
				Y.dtrowdeleted IS NULL
					AND 
				A.istatus_id NOT IN (5,6)
			WHERE 
				R.dtrowdeleted IS NULL
			AND 
				S.ihouse_id = #variables.id# 	
			<cfif arguments.sortColumns NEQ "">
			ORDER BY
				#arguments.sortColumns#
			</cfif>
		</cfquery> --->
		
		<cfscript>
			theQuery = GetResidentQuery;
			ResidentArray = ArrayNew(1);
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
				Resident = CreateObject("Component","Components.Resident");
			//	Resident.Init(theQuery["iResident_ID"][i],arguments.dsn,arguments.tipsDsn,arguments.leadtrackingdbserver,arguments.censusdbserver);
				Resident.Init(theQuery["iResident_ID"][i],arguments.dsn,arguments.tipsDsn);
				
				ArrayAppend(ResidentArray,Resident);
			}
			
			return ResidentArray;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetAssessmentsAsStruct" access="public" returntype="array" output="false">
		<cfquery name="GetAssessmentsQuery" datasource="#variables.dsn#">
			select iassessmenttoolmaster_id
					,itenant_id
					,iresident_id
					,tenantname
					,assessmenttool
					,bbillingactive
					,dtbillingactive
					,dtreviewstart
					,dtreviewend
					,level
					,ispoints
					,captnumber
					,isfinalized 
			From(select 
				 m.iassessmenttoolmaster_id
				,t.itenant_id
				,'' as iresident_id
				,IsNull(t.cfirstname + ' ' + t.clastname,'') as tenantname
				,IsNull(o.cdescription,'') as assessmenttool
				,IsNull(m.bbillingactive,0) as bbillingactive
				,IsNull(m.dtbillingactive,'') as dtbillingactive
				,IsNull(m.dtreviewstart,'') as dtreviewstart
				,IsNull(m.dtreviewend,'') as dtreviewend
				,IsNull(y.cdescription,'') as level
				,IsNull(m.ispoints,0) as ispoints
				,IsNull(a.captnumber,'') as captnumber
				,IsNull(m.bfinalized,0) as isfinalized
			from
				assessmenttoolmaster m 
			inner join
				assessmenttool o on o.iassessmenttool_id = m.iassessmenttool_id
			inner join
				tenant t on t.itenant_id = m.itenant_id
					and
				t.dtrowdeleted is null
			inner join
				tenantstate s on s.itenant_id = t.itenant_id
					and
				s.itenantstatecode_id = 2
					and
				t.bIsMedicaid is null
					and
				t.bIsMisc is null
			inner join
				sleveltype y on y.csleveltypeset = o.csleveltypeset
					and
				m.ispoints between y.ispointsmin and y.ispointsmax
					and
				y.dtrowdeleted is null
			left join
				AptAddress a on a.iAptAddress_ID = S.iAptAddress_ID
					and
				a.dtrowdeleted is null
			inner join
				house h on h.ihouse_id = t.ihouse_id
					and
				h.ihouse_id = #variables.id#
			where
				m.dtrowdeleted is null and t.cfirstname is not null
			union
			select
				 m.iassessmenttoolmaster_id
				,t.itenant_id
				<!--- ,r.iresident_id --->
				,'' as iresident_id
				,IsNull(t.cfirstname + ' ' + t.clastname,'') as tenantname
				,IsNull(o.cdescription,'') as assessmenttool
				,IsNull(m.bbillingactive,0) as bbillingactive
				,IsNull(m.dtbillingactive,'') as dtbillingactive
				,IsNull(m.dtreviewstart,'') as dtreviewstart
				,IsNull(m.dtreviewend,'') as dtreviewend
				,IsNull(y.cdescription,'') as level

				,IsNull(m.ispoints,0) as ispoints
				,IsNull(a.captnumber,'') as captnumber
				,IsNull(m.bfinalized,0) as isfinalized
			from
				assessmenttoolmaster m 
			inner join
				assessmenttool o on o.iassessmenttool_id = m.iassessmenttool_id
			<!---      	inner join
				#variables.leadtrackingdbserver#.leadtracking.dbo.resident r on r.iresident_id = m.iresident_id
					and
				r.dtrowdeleted is null --->
			<!--- inner join
				#variables.leadtrackingdbserver#.leadtracking.dbo.residentstate s1 on s1.iresident_id = r.iresident_id --->
			inner join
				tenant t on t.itenant_id = m.itenant_id
			inner join
				tenantstate s on s.itenant_id = t.itenant_id
					and
				s.itenantstatecode_id = 2
					and
				t.bIsMedicaid is null
					and
				t.bIsMisc is null
			inner join
				sleveltype y on y.csleveltypeset = o.csleveltypeset
					and
				m.ispoints between y.ispointsmin and y.ispointsmax
					and
				y.dtrowdeleted is null
			left join
				AptAddress a on a.iAptAddress_ID = S.iAptAddress_ID
					and
				a.dtrowdeleted is null
			inner join
				house h on h.ihouse_id = t.ihouse_id
					and
				h.ihouse_id = #variables.id#
			where
				m.dtrowdeleted is null and t.cfirstname is not null
			and
				m.itenant_id is null) a
			order by
				 a.captnumber
				,a.itenant_id
				,a.iresident_id
				,a.bbillingactive desc
				,a.dtbillingactive desc
		</cfquery>
		
		<cfscript>
			theQuery = GetAssessmentsQuery;
			
			AssessmentArray = ArrayNew(1);
			
			for(i = 1; i lte GetAssessmentsQuery.RecordCount; i = i + 1)
			{
				AssessmentStruct = StructNew();
				
				AssessmentStruct.id = theQuery["itenant_id"][i];
				AssessmentStruct.residentid = theQuery["iresident_id"][i];
				AssessmentStruct.apt = theQuery["captnumber"][i];
				AssessmentStruct.assessmentId = theQuery["iassessmenttoolmaster_id"][i];
				AssessmentStruct.name = theQuery["tenantname"][i];
				AssessmentStruct.tool = theQuery["assessmenttool"][i];
				AssessmentStruct.isBillingActive = BitToBool(theQuery["bbillingactive"][i]);
				AssessmentStruct.billingActiveDate = theQuery["dtbillingactive"][i];
				AssessmentStruct.reviewStartDate = theQuery["dtreviewstart"][i];
				AssessmentStruct.reviewEndDate = theQuery["dtreviewend"][i];
				AssessmentStruct.level = theQuery["level"][i];
				AssessmentStruct.points = theQuery["ispoints"][i];
				AssessmentStruct.isFinalized = BitToBool(theQuery["isFinalized"][i]);
				ArrayAppend(AssessmentArray,AssessmentStruct);
			}
			
			return AssessmentArray;
		</cfscript>
	</cffunction>
	<!--- Query change for sql2005 , ticket#28385 RTS. In "GetMovedOutAssessmentsAsStruct"--->		
	<cffunction name="GetMovedOutAssessmentsAsStruct" access="public" returntype="array" output="false">
		<cfquery name="GetAssessmentsQuery" datasource="#variables.dsn#">
			select
				iassessmenttoolmaster_id
				,itenant_id
				,tenantname
				,assessmenttool
				,bbillingactive
				,dtbillingactive
				,dtreviewstart
				,dtreviewend
				,level
				,ispoints
				,captnumber
				,isfinalized
				,dtmoveout
			From 
			(select
				 m.iassessmenttoolmaster_id
				,t.itenant_id
				,IsNull(t.cfirstname + ' ' + t.clastname,'') as tenantname
				,IsNull(o.cdescription,'') as assessmenttool
				,IsNull(m.bbillingactive,0) as bbillingactive
				,IsNull(m.dtbillingactive,'') as dtbillingactive
				,IsNull(m.dtreviewstart,'') as dtreviewstart
				,IsNull(m.dtreviewend,'') as dtreviewend
				,IsNull(y.cdescription,'') as level
				,IsNull(m.ispoints,0) as ispoints
				,IsNull(a.captnumber,'') as captnumber
				,IsNull(m.bfinalized,0) as isfinalized
				,IsNull(s.dtmoveout,'') as dtmoveout
			from
				assessmenttoolmaster m 
			inner join
				assessmenttool o on o.iassessmenttool_id = m.iassessmenttool_id
			inner join
				tenant t on t.itenant_id = m.itenant_id
					and
				t.dtrowdeleted is null
			inner join
				tenantstate s on s.itenant_id = t.itenant_id
					and
				s.itenantstatecode_id in (3,4)
					and
				t.bIsMedicaid is null
					and
				t.bIsMisc is null
			inner join
				sleveltype y on y.csleveltypeset = o.csleveltypeset
					and
				m.ispoints between y.ispointsmin and y.ispointsmax
					and
				y.dtrowdeleted is null
			left join
				AptAddress a on a.iAptAddress_ID = S.iAptAddress_ID
					and
				a.dtrowdeleted is null
			inner join
				house h on h.ihouse_id = t.ihouse_id
					and
				h.ihouse_id = #variables.id#
			where
				m.dtrowdeleted is null  and t.cfirstname is not null
			union
			select
				 m.iassessmenttoolmaster_id
				,t.itenant_id
				,IsNull(t.cfirstname + ' ' + t.clastname,'') as tenantname
				,IsNull(o.cdescription,'') as assessmenttool
				,IsNull(m.bbillingactive,0) as bbillingactive
				,IsNull(m.dtbillingactive,'') as dtbillingactive
				,IsNull(m.dtreviewstart,'') as dtreviewstart
				,IsNull(m.dtreviewend,'') as dtreviewend
				,IsNull(y.cdescription,'') as level
				,IsNull(m.ispoints,0) as ispoints
				,IsNull(a.captnumber,'') as captnumber
				,IsNull(m.bfinalized,0) as isfinalized
				,IsNull(s.dtmoveout,'') as dtmoveout
			from
				assessmenttoolmaster m 
			inner join
				assessmenttool o on o.iassessmenttool_id = m.iassessmenttool_id
			<!--- inner join
				#variables.leadtrackingdbserver#.leadtracking.dbo.resident r on r.iresident_id = m.iresident_id
					and
				r.dtrowdeleted is null
			inner join
				#variables.leadtrackingdbserver#.leadtracking.dbo.residentstate s1 on s1.iresident_id = r.iresident_id --->
			inner join
				tenant t on t.itenant_id = m.itenant_id
			inner join
				tenantstate s on s.itenant_id = t.itenant_id
					and
				s.itenantstatecode_id in (3,4)
					and
				t.bIsMedicaid is null
					and
				t.bIsMisc is null
			inner join
				sleveltype y on y.csleveltypeset = o.csleveltypeset
					and
				m.ispoints between y.ispointsmin and y.ispointsmax
					and
				y.dtrowdeleted is null
			left join
				AptAddress a on a.iAptAddress_ID = S.iAptAddress_ID
					and
				a.dtrowdeleted is null
			inner join
				house h on h.ihouse_id = t.ihouse_id
					and
				h.ihouse_id = #variables.id#
			where
				m.dtrowdeleted is null  and t.cfirstname is not null
			and
				m.itenant_id is null) a
			order by
				 a.captnumber
				,a.itenant_id
				,a.bbillingactive desc
				,a.dtbillingactive desc
		</cfquery>
		
		<cfscript>
			theQuery = GetAssessmentsQuery;
			
			AssessmentArray = ArrayNew(1);
			
			for(i = 1; i lte GetAssessmentsQuery.RecordCount; i = i + 1)
			{
				AssessmentStruct = StructNew();
				
				AssessmentStruct.id = theQuery["itenant_id"][i];
				AssessmentStruct.apt = theQuery["captnumber"][i];
				AssessmentStruct.assessmentId = theQuery["iassessmenttoolmaster_id"][i];
				AssessmentStruct.name = theQuery["tenantname"][i];
				AssessmentStruct.tool = theQuery["assessmenttool"][i];
				AssessmentStruct.isBillingActive = BitToBool(theQuery["bbillingactive"][i]);
				AssessmentStruct.billingActiveDate = theQuery["dtbillingactive"][i];
				AssessmentStruct.reviewStartDate = theQuery["dtreviewstart"][i];
				AssessmentStruct.reviewEndDate = theQuery["dtreviewend"][i];
				AssessmentStruct.level = theQuery["level"][i];
				AssessmentStruct.points = theQuery["ispoints"][i];
				AssessmentStruct.isFinalized = BitToBool(theQuery["isFinalized"][i]);
				AssessmentStruct.dtMoveOut = theQuery["dtmoveout"][i];
				ArrayAppend(AssessmentArray,AssessmentStruct);
			}
			
			return AssessmentArray;
		</cfscript>
	</cffunction>	
	
	<!--- 03/17/2009 - Modified by Jaime Cruz as part of project 18650. Modified query to include union that will ensure all residents moved via the STAR application are included in the resulting record set. --->
	<cffunction name="GetInquiryAssessmentsAsStruct" returntype="array" access="public" output="false">
		<cfquery name="GetInquiriesQuery" datasource="#variables.dsn#">
<!--- 			select
				 t.iresident_id
				,IsNull(s.itenant_id,0) as itenant_id
				,m.iassessmenttoolmaster_id
				,IsNull(t.cfirstname + ' ' + t.clastname,'') as tenantname
				,t.cfirstname
				,t.clastname
				,IsNull(o.cdescription,'') as assessmenttool
				,IsNull(m.bbillingactive,0) as bbillingactive
				,IsNull(m.dtbillingactive,'') as dtbillingactive
				,IsNull(m.dtreviewstart,'') as dtreviewstart
				,IsNull(m.dtreviewend,'') as dtreviewend
				,IsNull(y.cdescription,'') as level
				,IsNull(m.ispoints,0) as ispoints
				,IsNull(m.bfinalized,0) as isfinalized
			from
				#variables.leadtrackingdbserver#.leadtracking.dbo.resident t 
			inner join
				#variables.leadtrackingdbserver#.leadtracking.dbo.residentstate s on s.iresident_id = t.iresident_id
					and
				s.dtrowdeleted is null
			left join
				assessmenttoolmaster m on m.iresident_id = t.iresident_id
					and
				m.dtrowdeleted is null
			left join
				assessmenttool o on o.iassessmenttool_id = m.iassessmenttool_id
			inner join
				#variables.leadtrackingdbserver#.leadtracking.dbo.Status A ON A.istatus_id = S.istatus_id 
					AND
				A.dtrowdeleted is null
					AND 
				A.istatus_id = 7 
			inner join
				house h on h.ihouse_id = s.ihouse_id
					and
				h.ihouse_id = #variables.id#
					and
				h.dtrowdeleted is null
			left join
				sleveltype y on y.csleveltypeset = h.csleveltypeset
					and
				m.ispoints between y.ispointsmin and y.ispointsmax
					and
				y.dtrowdeleted is null			
			where
				t.dtrowdeleted is null
		union   --->
			select
				'' as iresident_id
				,t.itenant_id
				,m.iassessmenttoolmaster_id
				,IsNull(t.cfirstname + ' ' + t.clastname,'') as tenantname
				,t.cfirstname
				,t.clastname
				,IsNull(o.cdescription,'') as assessmenttool
				,IsNull(m.bbillingactive,0) as bbillingactive
				,IsNull(m.dtbillingactive,'') as dtbillingactive
				,IsNull(m.dtreviewstart,'') as dtreviewstart
				,IsNull(m.dtreviewend,'') as dtreviewend
				,IsNull(y.cdescription,'') as level
				,IsNull(m.ispoints,0) as ispoints
				,IsNull(m.bfinalized,0) as isfinalized
			from
				tenant t 
			inner join
				tenantstate s on s.itenant_id = t.itenant_id
					and
				s.dtrowdeleted is null
			left join
				assessmenttoolmaster m on m.itenant_id = t.itenant_id
					and
				m.dtrowdeleted is null  
			left join
				assessmenttool o on o.iassessmenttool_id = m.iassessmenttool_id
			inner join
				tenantstatecodes A ON A.itenantstatecode_id = S.itenantstatecode_id 
					AND
				A.dtrowdeleted is null
					AND 
				A.itenantstatecode_id = 1
			inner join
				house h on h.ihouse_id = t.ihouse_id
					and
				h.ihouse_id = #variables.id#
					and
				h.dtrowdeleted is null
			left join
				sleveltype y on y.csleveltypeset = h.csleveltypeset
					and
				m.ispoints between y.ispointsmin and y.ispointsmax
					and
				y.dtrowdeleted is null			
			where
				t.dtrowdeleted is null  and t.cfirstname is not null
			order by
				 t.clastname
				<!--- ,t.cfirstname
				,m.dtreviewstart desc --->
				,bbillingactive desc
				<!---,m.dtbillingactive desc---> 
		</cfquery>
		
		<cfscript>
			theQuery = GetInquiriesQuery;
			InquiryArray = ArrayNew(1);
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
				{
					InquiryStruct = StructNew();
					
					InquiryStruct.id = theQuery["itenant_id"][i];
					InquiryStruct.tenantid = theQuery["itenant_id"][i];
					InquiryStruct.assessmentId = theQuery["iassessmenttoolmaster_id"][i];
					InquiryStruct.name = theQuery["tenantname"][i];
					InquiryStruct.tool = theQuery["assessmenttool"][i];
					InquiryStruct.isBillingActive = BitToBool(theQuery["bbillingactive"][i]);
					InquiryStruct.billingActiveDate = theQuery["dtbillingactive"][i];
					InquiryStruct.reviewStartDate = theQuery["dtreviewstart"][i];
					InquiryStruct.reviewEndDate = theQuery["dtreviewend"][i];
					InquiryStruct.level = theQuery["level"][i];
					InquiryStruct.points = theQuery["ispoints"][i];
					InquiryStruct.isfinalized = BitToBool(theQuery["isFinalized"][i]);
					
					ArrayAppend(InquiryArray,InquiryStruct);
				}
			
				return InquiryArray;
		</cfscript>
	</cffunction>

	<cffunction name="GetHouseByName" access="public" returntype="Components.House" output="false">
		<cfargument name="houseName" type="string" required="true" default="">
		<cfargument name="dsn" type="string" required="true" default="">
<!--- 		<cfargument name="leadtrackingdbserver" type="string" required="true" default="">
		<cfargument name="censusdbserver" type="string" required="true" default=""> --->
		
		<cfquery name="GetHouse" datasource="#arguments.dsn#">
			SELECT
				iHouse_ID
			FROM
				House
			WHERE
				cName = '#arguments.houseName#'
		</cfquery>
		
		<cfscript>
			House = CreateObject("Component","Components.House");
			
			if(GetHouse.RecordCount eq 1)
			{
				//House.Init(GetHouse.iHouse_id,arguments.dsn,arguments.leadtrackingdbserver,arguments.censusdbserver);
				House.Init(GetHouse.iHouse_id,arguments.dsn);
			}
			else
			{
				House.Init(0,arguments.dsn);			
			//	House.Init(0,arguments.dsn,arguments.leadtrackingdbserver,arguments.censusdbserver);
			}
			
			return House;
		</cfscript>
	</cffunction>
	
	<!---Added by ssanipina on 01/27/2008----Function for getting total points by months and residency type--->
	<cffunction name="GetTotalPointsBymonthsAndResidencyType" access="public" returntype="query" output="true" >
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="startMonth" type="string" required="true">
		<cfargument name ="startYear" type="string" required="true">
		
		<cfstoredproc procedure="sp_GetTotalPointsByHouseByMonthByResidencyType" datasource="#arguments.dsn#" >
			<cfprocparam value="#arguments.startMonth#" cfsqltype="cf_sql_vARCHAR">
			<cfprocparam value="#arguments.startYear#" cfsqltype="cf_sql_vARCHAR">
			<cfprocresult name="GetTotalPointsMonthly" resultset="1">
		</cfstoredproc>
		
		<cfreturn GetTotalPointsMonthly>	
	</cffunction>
	
	<!---Added by ssanipina on 01/27/2008------Function for exporting data in an Excell sheet--->
	<cffunction name="GetTotalPointsByMonthsAndResidencyTypeExcellExport" access="public" returntype="string" output="false" >
	<!--- <cfargument name="theQuery" type="query" required="true"> --->
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="startMonth" type="string" required="true">
		<cfargument name ="startYear" type="string" required="true">
		<cfscript>
			theQuery = GetTotalPointsBymonthsAndResidencyType(arguments.dsn,arguments.startMonth,arguments.startYear);
			
			//xml table setup
			xml = "<?xml version=""1.0""?>
			<?mso-application progid=""Excel.Sheet""?>					
			<Workbook xmlns=""urn:schemas-microsoft-com:office:spreadsheet""
			xmlns:o=""urn:schemas-microsoft-com:office:office""
			xmlns:x=""urn:schemas-microsoft-com:office:excel""
			xmlns:ss=""urn:schemas-microsoft-com:office:spreadsheet""
			xmlns:html=""http://www.w3.org/TR/REC-html40"">					 
			<DocumentProperties xmlns=""urn:schemas-microsoft-com:office:office"">
			<Author>ssanipina</Author>					  
			<LastAuthor>ssanipina</LastAuthor>					  
			<Created>2008-01-25T16:27:15Z</Created>					  
			<Company>alc</Company>					  
			<Version>11.5606</Version>					 
			</DocumentProperties>					 
			<ExcelWorkbook xmlns=""urn:schemas-microsoft-com:office:excel"">					  			<WindowHeight>15585</WindowHeight>
			<WindowWidth>24795</WindowWidth>
			<WindowTopX>480</WindowTopX>
			<WindowTopY>105</WindowTopY>
			<ProtectStructure>False</ProtectStructure>
			<ProtectWindows>False</ProtectWindows>
			</ExcelWorkbook>
			<Styles>
			<Style ss:ID=""Default"" ss:Name=""Normal"">
				<Alignment ss:Vertical=""Bottom""/>
				<Borders/>
				<Font/>
				<Interior/>
				<NumberFormat/>
				<Protection/>
			</Style>
			<Style ss:ID=""s22"">
				<Font ss:Color=""##FFFFFF""/>
				<Interior ss:Color=""##0000FF"" ss:Pattern=""Solid""/>
			</Style>					 
			</Styles>					 
			<Worksheet ss:Name=""Sheet1"">
			<Table ss:ExpandedColumnCount=""6"" ss:ExpandedRowCount=""#theQuery.RecordCount + 1#"" x:FullColumns=""1"" x:FullRows=""1"">
				<Row>					    
				<Cell ss:StyleID=""s22""><Data ss:Type=""String"">House</Data></Cell>
				<Cell ss:StyleID=""s22""><Data ss:Type=""String"">Residency Type</Data></Cell>
				<Cell ss:StyleID=""s22""><Data ss:Type=""String"">Residence Sol ID</Data></Cell>
				<Cell ss:StyleID=""s22""><Data ss:Type=""String"">Month</Data></Cell>
				<Cell ss:StyleID=""s22""><Data ss:Type=""String"">Year</Data></Cell>
				<Cell ss:StyleID=""s22""><Data ss:Type=""String"">Points</Data></Cell>
				</Row>";			
			//xml table data
			
			for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
				xml = xml & "<Row>    
				<Cell><Data ss:Type=""String"">#theQuery['HouseName'][i]#</Data></Cell>    
				<Cell><Data ss:Type=""String"">#theQuery['ResidencyType'][i]#</Data></Cell>
				<Cell><Data ss:Type=""Number"">#theQuery['HouseSolID'][i]#</Data></Cell>    
				<Cell><Data ss:Type=""Number"">#theQuery['Month'][i]#</Data></Cell>    
				<Cell><Data ss:Type=""Number"">#theQuery['Year'][i]#</Data></Cell>    
				<Cell><Data ss:Type=""Number"">#theQuery['TotalPoints'][i]#</Data></Cell>   
				</Row>";
			}	
					
			//close xml table setup
			xml = xml & "</Table>				  
				<WorksheetOptions xmlns=""urn:schemas-microsoft-com:office:excel"">				   
					<Print>				    
						<ValidPrinterInfo/>				    
						<HorizontalResolution>600</HorizontalResolution>
						<VerticalResolution>0</VerticalResolution>				   
					</Print>				   
					<Selected/>				   
						<Panes>				    
							<Pane>				     
								<Number>3</Number>				     
								<ActiveRow>1</ActiveRow>				     
								<ActiveCol>4</ActiveCol>				    
							</Pane>				   
						</Panes>				   
						<ProtectObjects>False</ProtectObjects>
						<ProtectScenarios>False</ProtectScenarios>				  
					</WorksheetOptions>				 
			</Worksheet>				 
			<Worksheet ss:Name=""Sheet2"">				  
				<WorksheetOptions xmlns=""urn:schemas-microsoft-com:office:excel"">				   					<ProtectObjects>False</ProtectObjects>				   					<ProtectScenarios>False</ProtectScenarios>				  
				</WorksheetOptions>				 
			</Worksheet>				 
			<Worksheet ss:Name=""Sheet3"">				  
				<WorksheetOptions xmlns=""urn:schemas-microsoft-com:office:excel"">
					<ProtectObjects>False</ProtectObjects>
					<ProtectScenarios>False</ProtectScenarios>				  
				</WorksheetOptions>				 
			</Worksheet>				
			</Workbook>";			
			
			//send back the xml spreadsheet		
			return xml;		
		</cfscript>
	</cffunction>

	<cffunction access="public" name="HouseTypeCheck" output="false" returntype="void" hint="Get House Assessment Types (MC, AL, Both)">
	<cfargument name="datasource" required="true" type="string" default="#application.datasource#">
	<cfargument name="houseID" required="true" type="numeric">

	<cfquery name="qChecKHouse" datasource="#arguments.datasource#">
		declare @retVal int;
		declare @housecnt int;
		select @housecnt = count(distinct(iHouseProductLine_ID)) from AptAddress WHERE iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">

		 IF(@housecnt = 2)
			BEGIN
				-- set return value to hybred
				SET @retVal = 0;
			END
		ELSE
			BEGIN
				-- set the return value to either AL(1) or MC(2)
				SELECT @retVal = iProductLine_id 
				FROM HouseProductLine
				WHERE iHouseProductLine_id = (select DISTINCT(iHouseProductLine_Id) FROM AptAddress WHERE iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">)
			END
		
		select @retVal as houseType
	</cfquery>
	<cfif qCheckHouse.recordcount GT 0>
		<cfset variables.houseType = qCheckHouse.houseType>			
	</cfif>
</cffunction>

<!----------------------------------------------------------
*                   GETTERS AND SETTERS                    *
----------------------------------------------------------->	

	<cffunction name="GetId" access="public" returntype="numeric" output="false" hint="Returns a tenants id.">
		<cfscript>
			return variables.id;
		</cfscript>
	</cffunction>

	<cffunction name="GetOpsArea" access="public" returntype="Components.OpsArea" output="false" hint="Gets this houses opsarea">
		<cfscript>
			OpsArea = CreateObject("Component","Components.OpsArea");
			OpsArea.Init(variables.id, variables.dsn);
			
			return OpsArea;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetTipsMonth" access="public" returntype="string" output="false">
		<cfscript>
			return variables.currentTipsMonth;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetIsClosed" access="public" returntype="boolean" output="false">
		<cfscript>
			return variables.isPeriodClosed;
		</cfscript>
	</cffunction>
	
	<cffunction name="getHouseType" access="public" returntype="string" output="false">
		<cfreturn variables.houseType>
	</cffunction>


	<cffunction name="SetOpsArea" access="public" returntype="void" output="false" hint="Sets this houses ops area">
		<cfargument name="OpsArea" type="string" required="true">
		<cfscript>
			variables.opsAreaId = arguments.OpsArea.GetId();
		</cfscript>
	</cffunction>
	
	<cffunction name="GetPdUserId" access="public" returntype="string" output="false" hint="Gets this houses pdUserId">
		<cfscript>
			return variables.pdUserId;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPdUserId" access="public" returntype="void" output="false" hint="Sets this houses pdUserId">
		<cfargument name="pdUserId" type="string" required="true">
		<cfscript>
			variables.pdUserId = arguments.pdUserId;
		</cfscript>
	</cffunction>

	<cffunction name="GetAcctUserId" access="public" returntype="string" output="false" hint="Gets this houses acctUserId">
		<cfscript>
			return variables.acctUserId;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetAcctUserId" access="public" returntype="void" output="false" hint="Sets this houses acctUserId">
		<cfargument name="acctUserId" type="string" required="true">
		<cfscript>
			variables.acctUserId = arguments.acctUserId;
		</cfscript>
	</cffunction>

	<cffunction name="GetName" access="public" returntype="string" output="false" hint="Gets this houses name">
		<cfscript>
			return variables.name;
		</cfscript>
	</cffunction>
	<cffunction name="GetFormattedName" access="public" returntype="string" output="false" hint="Gets this houses name">
 	 		<cfset formattedName = "">
 
			<cfset formattedName =#variables.name#>
 
		<cfscript>
			return TRIM(formattedName);
		</cfscript>
	</cffunction>	
<!--- 	<cffunction name="GetFormattedName" access="public" returntype="string" output="false" hint="Gets this houses name">
		<cfset formattedName = "">
		<cfloop list="#variables.name#" index="i" delimiters=" ">
			<cfset formattedName = formattedName & UCASE(LEFT(i,1)) & LCASE(RIGHT(i,LEN(i) - 1)) & " ">
		</cfloop>
		<cfscript>
			return TRIM(formattedName);
		</cfscript>
	</cffunction> --->
	
	<cffunction name="SetName" access="public" returntype="void" output="false" hint="Sets this houses name">
		<cfargument name="name" type="string" required="true">
		<cfscript>
			variables.name = arguments.name;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetNumber" access="public" returntype="string" output="false" hint="Gets this houses number">
		<cfscript>
			return variables.number;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetNumber" access="public" returntype="void" output="false" hint="Sets this houses number">
		<cfargument name="number" type="string" required="true">
		<cfscript>
			variables.number = arguments.number;
		</cfscript>
	</cffunction>

	<cffunction name="GetDepositTypeSet" access="public" returntype="string" output="false" hint="Gets this houses depositTypeSet">
		<cfscript>
			return variables.depositTypeSet;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetDepositTypeSet" access="public" returntype="void" output="false" hint="Sets this houses depositTypeSet">
		<cfargument name="depositTypeSet" type="string" required="true">
		<cfscript>
			variables.depositTypeSet = arguments.depositTypeSet;
		</cfscript>
	</cffunction>

	<cffunction name="GetSLevelTypeSet" access="public" returntype="string" output="false" hint="Gets the houses sLevelTypeSet">
		<cfscript>
			return variables.sLevelTypeSet;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSLevelTypeSet" access="public" returntype="void" output="false" hint="Sets the houses sLevelTypeSet">
		<cfargument name="sLevelTypeSet" type="string" required="true">
		<cfscript>
			variables.sLevelTypeSet = arguments.sLevelTypeSet;
		</cfscript>
	</cffunction>

	<cffunction name="GetGlSubAccount" access="public" returntype="string" output="false" hint="Gets the houses glSubAccount">
		<cfscript>
			return variables.glSubAccount;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetGlSubAccount" access="public" returntype="void" output="false" hint="Sets the houses glSubAccount">
		<cfargument name="glSubAccount" type="string" required="true">
		<cfscript>
			variables.glSubAccount = arguments.glSubAccount;
		</cfscript>
	</cffunction>

	<cffunction name="GetCensusMedicaidOnly" access="public" returntype="boolean" output="false" hint="Gets the houses isCensusMedicaidOnly">
		<cfscript>
			return variables.isCensusMedicaidOnly;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetCensusMedicaidOnly" access="public" returntype="void" output="false" hint="Sets the houses isCensusMedicaidOnly">
		<cfargument name="isCensusMedicaidOnly" type="boolean" required="true">
		<cfscript>
			variables.isCensusMedicaidOnly = arguments.isCensusMedicaidOnly;
		</cfscript>
	</cffunction>

	<cffunction name="GetPhoneNumber1" access="public" returntype="string" output="false" hint="Gets the houses phoneNumber1">
		<cfscript>
			return variables.phoneNumber1;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPhoneNumber1" access="public" returntype="void" output="false" hint="Sets the houses phoneNumber1">
		<cfargument name="phoneNumber1" type="string" required="true">
		<cfscript>
			variables.phoneNumber1 = arguments.phoneNumber1;
		</cfscript>
	</cffunction>

	<cffunction name="GetPhoneType1" access="public" returntype="Components.PhoneType" output="false" hint="Gets the houses phoneType1">
		<cfscript>
			PhoneType = CreateObject("Component","Components.PhoneType");
			PhoneType.Init(variables.phoneType1Id,variables.dsn);
			
			return PhoneType;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPhoneType1" access="public" returntype="void" output="false" hint="Sets the houses phoneType1">
		<cfargument name="PhoneType" type="Components.PhoneType" required="true">
		<cfscript>
			variables.phoneType1Id = arguments.PhoneType.GetId();
		</cfscript>
	</cffunction>

	<cffunction name="GetPhoneNumber2" access="public" returntype="string" output="false" hint="Gets the houses phoneNumber2">
		<cfscript>
			return variables.phoneNumber2;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPhoneNumber2" access="public" returntype="void" output="false" hint="Sets the houses phoneNumber2">
		<cfargument name="phoneNumber2" type="string" required="true">
		<cfscript>
			variables.phoneNumber2 = arguments.phoneNumber2;
		</cfscript>
	</cffunction>

	<cffunction name="GetPhoneType2" access="public" returntype="Components.PhoneType" output="false" hint="Gets the houses phoneType2">
		<cfscript>
			PhoneType = CreateObject("Component","Components.PhoneType");
			PhoneType.Init(variables.phoneType2Id,variables.dsn);
			
			return PhoneType;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPhoneType2" access="public" returntype="void" output="false" hint="Sets the houses phoneType2">
		<cfargument name="PhoneType" type="Components.PhoneType" required="true">
		<cfscript>
			variables.phoneType2Id = arguments.PhoneType.GetId();
		</cfscript>
	</cffunction>

	<cffunction name="GetPhoneNumber3" access="public" returntype="string" output="false" hint="Gets the houses phoneNumber3">
		<cfscript>
			return variables.phoneNumber3;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPhoneNumber3" access="public" returntype="void" output="false" hint="Sets the houses phoneNumber3">
		<cfargument name="phoneNumber3" type="string" required="true">
		<cfscript>
			variables.phoneNumber3 = arguments.phoneNumber3;
		</cfscript>
	</cffunction>

	<cffunction name="GetPhoneType3" access="public" returntype="Components.PhoneType" output="false" hint="Gets the houses phoneType3">
		<cfscript>
			PhoneType = CreateObject("Component","Components.PhoneType");
			PhoneType.Init(variables.phoneType3Id,variables.dsn);
			
			return PhoneType;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetPhoneType3" access="public" returntype="void" output="false" hint="Sets the houses phoneType3">
		<cfargument name="PhoneType" type="Components.PhoneType" required="true">
		<cfscript>
			variables.phoneType3Id = arguments.PhoneType.GetId();
		</cfscript>
	</cffunction>

	<cffunction name="GetAddressLine1" access="public" returntype="string" output="false" hint="Gets the house addressLine1">
		<cfscript>
			return variables.addressLine1;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetAddressLine1" access="public" returntype="void" output="false" hint="Sets the houses addressLine1">
		<cfargument name="addressLine1" type="string" required="true">
		<cfscript>
			variables.addressLine1 = arguments.addressLine1;
		</cfscript>
	</cffunction>

	<cffunction name="GetAddressLine2" access="public" returntype="string" output="false" hint="Gets the house addressLine2">
		<cfscript>
			return variables.addressLine2;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetAddressLine2" access="public" returntype="void" output="false" hint="Sets the houses addressLine2">
		<cfargument name="addressLine2" type="string" required="true">
		<cfscript>
			variables.addressLine2 = arguments.addressLine2;

		</cfscript>
	</cffunction>

	<cffunction name="GetCity" access="public" returntype="string" output="false" hint="Gets the houses city">
		<cfscript>
			return variables.city;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetCity" access="public" returntype="void" output="false" hint="Sets the houses city">
		<cfargument name="city" type="string" required="true">
		<cfscript>
			variables.city = arguments.city;
		</cfscript>
	</cffunction>

	<cffunction name="GetStateCode" access="public" returntype="string" output="false" hint="Gets this houses stateCode">
		<cfscript>
			return variables.stateCode;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetStateCode" access="public" returntype="void" output="false" hint="Sets this houses stateCode">
		<cfargument name="stateCode" type="string" required="true">
		<cfscript>
			variables.stateCode = arguments.stateCode;
		</cfscript>
	</cffunction>

	<cffunction name="GetZipCode" access="public" returntype="string" output="false" hint="Gets this houses zip code">
		<cfscript>
			return variables.zipCode;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetZipCode" access="public" returntype="void" output="false" hint="Sets thie houses zipCode">
		<cfargument name="zipCode" type="string" required="true">
		<cfscript>
			variables.zipCode = arguments.zipCode;
		</cfscript>
	</cffunction>

	<cffunction name="GetComments" access="public" returntype="string" output="false" hint="Gets this houses comments">
		<cfscript>
			return variables.comments;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetComments" access="public" returntype="void" output="false" hint="Sets this houses comments">
		<cfargument name="comments" type="string" required="true">
		<cfscript>
			variables.comments = arguments.comments;
		</cfscript>
	</cffunction>

	<cffunction name="GetAcctStamp" access="public" returntype="string" output="false" hint="Gets this houses acctStamp">
		<cfscript>
			return variables.acctStamp;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetAcctStamp" access="public" returntype="void" output="false" hint="Sets this houses acctStamp">
		<cfargument name="acctStamp" type="string" required="true">
		<cfscript>
			variables.acctStamp = arguments.acctStamp;
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
	
	<cffunction name="GetUnitsAvailable" access="public" returntype="string" output="false" hint="Gets this houses unitsAvailable">
		<cfscript>
			return variables.unitsAvailable;
		</cfscript>
	</cffunction>

	<cffunction name="SetUnitsAvailable" access="public" returntype="void" output="false" hint="Sets this houses unitsAvailable">
		<cfargument name="unitsAvailable" type="string" required="true">
		<cfscript>
			variables.unitsAvailable = arguments.unitsAvailable;
		</cfscript>
	</cffunction>

	<cffunction name="GetRentalAgreementDate" access="public" returntype="string" output="false" hint="Gets the houses rentalAgreementDate.">
		<cfscript>
			return variables.rentalAgreementDate;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetRentalAgreementDate" access="public" returntype="void" output="false" hint="Sets this houses rentalAgreementDate.">
		<cfargument name="rentalAgreementDate" type="string" required="true">
		<cfscript>
			variables.rentalAgreementDate = arguments.rentalAgreementDate;
		</cfscript>
	</cffunction>

	<cffunction name="GetNurseUserId" access="public" returntype="string" output="false" hint="Gets this houses nurseUserId">
		<cfscript>
			return variables.nurseUserId;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetNurseUserId" access="public" returntype="void" output="false" hint="Sets this houses nurseUserId">
		<cfargument name="nurseUserId" type="string" required="true">
		<cfscript>
			variables.nurseUserId = arguments.nurseUserId;
		</cfscript>
	</cffunction>

	<cffunction name="GetEhsiFacilityId" access="public" returntype="string" output="false" hint="Gets this houses ehsiFacilityId">
		<cfscript>
			return variables.ehsiFacilityId;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetEhsiFacilityId" access="public" returntype="void" output="false" hint="Sets thie houses ehsiFacilityId">
		<cfargument name="ehsiFacilityId" type="string" required="true">
		<cfscript>
			variables.ehsiFacilityId = arguments.ehsiFacilityId;
		</cfscript>
	</cffunction>

	<cffunction name="GetIsSandbox" access="public" returntype="string" output="false" hint="Gets this houses bIsSandbox">
		<cfscript>
			return variables.bIsSandbox;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetIsSandbox" access="public" returntype="void" output="false" hint="Sets this houses bIsSandbox">
		<cfargument name="bIsSandbox" type="string" required="true">
		<cfscript>
			variables.bIsSandbox = arguments.bIsSandbox;
		</cfscript>
	</cffunction>

	<cffunction name="GetChargeSet" access="public" returntype="Components.ChargeSet" output="false" hint="Gets this houses chargeset">
		<cfscript>
			ChargeSet = CreateObject("Component","Components.ChargeSet");
			ChargeSet.Init(variables.chargeSetId,variables.dsn);
			
			return ChargeSet;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetChargeSet" access="public" returntype="void" output="false" hint="Sets this houses chargeset">
		<cfargument name="ChargeSet" type="Components.ChargeSet" required="true">
		<cfscript>
			variables.chargeSetId = arguments.ChargeSet.GetId();
		</cfscript>
	</cffunction>

	<cffunction name="GetEmail" access="public" returntype="String" output="false" hint="Gets this houses email">
		<cfscript>
			return variables.email;
		</cfscript>
	</cffunction>
	
</cfcomponent>
