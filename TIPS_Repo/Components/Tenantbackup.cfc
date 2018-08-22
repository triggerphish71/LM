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
| jcruz      | 05/20/2008 | Added GetTenantsWithContacts and GetTenantsWithContactsExcel       |
|            |            | Export Functions as part of the Solomon Statements Project         |
| jcruz      | 05/21/2008 | Added RunSolomonUpdate Function as part of the Solomon Statements  |
|            |            | Project.														   |
| jcruz      | 05/21/2008 | Added GetTenantsWithOverflow and GetTenantsWithOverflowExcel       |
|            |            | Export Functions as part of the Solomon Statements Project .       |
| jcruz      | 07/25/2008 | Added GetTenantsOver59Points and GetTenantsOver59PointsExcelExport |
|            |            | Functions as part of the Project 25436.						       |
|------------|------------|---------------------------------------------------------------------|
| jcruz		| 9/27/2008	  | Modified as part of PROJECT 12392. Changes include the use	of		|
| 			| 			  | the resident id when initializing the component.					|
| 			| 			  | Change also incorporates the use of a Get Assessment function that	|
| 			| 			  | gets the last assessment for a tenant which is then used to  		|
| 			| 			  | retreive service plan data when creating a new assessment.			|
------------------------------------------------------------------------------------------------|
| Sathya    | 01/12/2010  | As part of project 41315 modified it so that it would get height and|
|           |             | weight of the tenant. Added GetHeight, GetWeight method             |
|           |             | Added SetHeight, SetWeight method                                   |
|           |             | Modified the GetInformation function. Modified QueryGetInformation  |
|           |             | Added UpdateTenantInfo function to update the height and weight     | 
|           |             | Modified the Init function to initialize the iheight and iweight    |
|           |             | variable                                                            |
----------------------------------------------------------------------------------------------->

<cfcomponent name="Tenant" output="false" extends="Components.AlcBase">
	<cffunction name="Init" access="public" returntype="void" output="false">
		<cfargument name="id" type="numeric" required="false">
		<cfargument name="residentid" type="numeric" required="false">
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="leadtrackingdbserver" required="true">
		<cfargument name="censusdbserver" required="true">
		<cfargument name="houses_appdbserver" required="false">
		
		<cfscript>
			//create the variables for the tenant
			variables.id = arguments.id;
			variables.residentId = arguments.residentid;
			variables.dsn = arguments.dsn;
			variables.houseId = 0;
			variables.tenantStateID = 0;
			variables.solomonKey = '';
			variables.isPayer = false;
			variables.firstName = '';
			variables.lastName = '';
			variables.birthDate = '';
			variables.ssn = '';
			variables.medicaidNumber = '';
			variables.outsidePhoneNumber1 = '';
			variables.outsidePhoneType1Id = 0;
			variables.outsidePhoneNumber2 = '';
			variables.outsidePhoneType2Id = 0;
			variables.outsidePhoneNumber3 = '';
			variables.outsidePhoneNumberType3 = 0;
			variables.outsideAddressLine1 = '';
			variables.outsideAddressLine2 = '';
			variables.outsideCity = '';
			variables.outsideStateCode = '';
			variables.outsideZipCode = '';
			variables.comments = '';
			variables.chargeSet = '';
			variables.isMedicaid = false;
			variables.isMisc = false;
			variables.isDayRespite = false;
			variables.sLevelTypeSet = '';
			variables.appFeePaid = false;
			variables.acctStamp = '';
			variables.billingType = '';
			variables.rowStartUserId = 0;
			variables.rowStartDate = '';
			variables.rowEndUserId = 0;
			variables.rowEndDate = '';
			variables.rowDeletedUserId = 0;
			variables.rowDeletedDate = '';
			variables.email = '';
			variables.dunningMessageId = 0;
			variables.overduebalance = 0;
			variables.leadtrackingdbserver = arguments.leadtrackingdbserver;
			variables.censusdbserver = arguments.censusdbserver;
			
			//01/12/2010 Sathya as per project 41315 added height and weight
			variables.height = 0;
			variables.weight = 0;
			
			//if the id isn't 0 this is an actual tenant, get their information;
			if(variables.id neq 0 or variables.residentId neq 0)
			{
				GetInformation();
				GetAssessment();
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="GetInformation" access="private" returntype="void" output="false">
		<!--- 01/12/2010 Sathya as per project 41315 added two fields in the query tenantHeight and tenantWeight --->
		<cfquery name="QueryGetInformation" datasource="#variables.dsn#">
			SELECT
				 T.*
				 ,IsNull(T.iheight,0) AS tenantHeight
				 ,IsNull(T.iWeight,0) AS tenantWeight
				,S.iTenantState_ID
				,IsNull(rS.iResident_ID,0) AS iResident_id
			FROM
				Tenant T
			INNER JOIN
				TenantState S ON S.iTenant_id = T.iTenant_ID
			LEFT JOIN
				#variables.leadtrackingdbserver#.leadtracking.dbo.ResidentState rS ON rS.iTenant_id = S.iTenant_id
			WHERE
				T.iTenant_ID = #variables.id#
		</cfquery>
		
		<cfscript>
			if(QueryGetInformation.RecordCount gt 0)
			{
				//this is just easier to type than querygettenantinformation
				theQuery = QueryGetInformation;
				
				//create the variables for the tenant
				variables.id = theQuery["iTenant_ID"][1];
				variables.residentid = theQuery["iResident_ID"][1];
				variables.houseId = theQuery["iHouse_ID"][1];
				variables.solomonKey = theQuery["cSolomonKey"][1];
				if(theQuery["bIsPayer"][1] eq 1)
				{
					variables.isPayer = true;
				}
				variables.tenantStateID = theQuery["iTenantState_ID"][1];
				variables.firstName = theQuery["cFirstName"][1];
				variables.lastName = theQuery["cLastName"][1];
				variables.birthDate = theQuery["dBirthDate"][1];
				variables.ssn = theQuery["cSSN"][1];
				variables.medicaidNumber = theQuery["cMedicaidNumber"][1];
				variables.outsidePhoneNumber1 = theQuery["cOutsidePhoneNumber1"][1];
				variables.outsidePhoneType1Id = theQuery["iOutsidePhoneType1_ID"][1];
				variables.outsidePhoneNumber2 = theQuery["cOutsidePhoneNumber2"][1];
				variables.outsidePhoneType2Id = theQuery["iOutsidePhoneType2_ID"][1];
				variables.outsidePhoneNumber3 = theQuery["cOutsidePhoneNumber3"][1];
				variables.outsidePhoneNumberType3 = theQuery["iOutsidePhoneType3_id"][1];
				variables.outsideAddressLine1 = theQuery["cOutsideAddressLine1"][1];
				variables.outsideAddressLine2 = theQuery["cOutsideAddressLine2"][1];
				variables.outsideCity = theQuery["cOutsideCity"][1];
				variables.outsideStateCode = theQuery["cOutsideStateCode"][1];
				variables.outsideZipCode = theQuery["cOutsideZipCode"][1];
				variables.comments = theQuery["cComments"][1];
				variables.chargeSet = theQuery["cChargeSet"][1];
				if(theQuery["bIsMedicaid"][1] eq 1)
				{
					variables.isMedicaid = true;
				}
				if(theQuery["bIsMisc"][1] eq 1)
				{
					variables.isMisc = true;
				}
				if(theQuery["bIsDayRespite"][1] eq 1)
				{
					variables.isDayRespite = true;
				}
				variables.sLevelTypeSet = theQuery["cSLevelTypeSet"][1];
				if(theQuery["bAppFeePaid"][1] eq 1)
				{
					variables.appFeePaid = true;
				}
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
				variables.email = theQuery["cEmail"][1];
				variables.dunningMessageId = theQuery["iDunningMessage_ID"][1];
				
				//01/12/2010 sathya as per project 41315 added this
				variables.height = theQuery["tenantHeight"][1];
			    variables.weight = theQuery["tenantWeight"][1];
					
			}
			else
			{
				Throw("Tenant not found","Tenant #variables.id# information not found in datasource #variables.dsn#.");
			}
		</cfscript>
	</cffunction>

	<cffunction name="GetCollectionTenants" access="public" returntype="array" output="false" >
		<cfargument name="scope" type="string" required="false" default="">
		<cfargument name="dsn" type="string" required="false" default="">
		<cfargument name="leadtrackingdbserver" type="string" required="false" default="">
		<cfargument name="censusdbserver" type="string" required="false" default="">
		
		<cfstoredproc procedure="sp_CollectionLetter1" datasource="#APPLICATION.datasource#">
			<cfprocresult name="GetCollection">
			<cfprocparam type="In" cfsqltype="CF_SQL_CHAR" dbvarname="@SCOPE" value="#arguments.scope#" null="no"> 
		</cfstoredproc>

		<cfscript>
			TenantArray = ArrayNew(1);
			
			// Loop through houses's array. Create House Object
			for(i = 1; i lte GetCollection.RecordCount; i=i+1)
			{
				Tenant = CreateObject("Component", "Components.Tenant");
				Tenant.Init(GetCollection["itenant_ID"][i],arguments.dsn,arguments.leadtrackingdbserver,arguments.censusdbserver);
				Tenant.SetOverDueBalance(GetCollection["total"][i]);
				ArrayAppend(TenantArray, Tenant);
				
			}				
			
			Return TenantArray;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetAverageLengthOfStay" access="public" returntype="query" output="false">
		<cfargument name="scope" type="string" required="true">
		<cfargument name="dsn" type="string" required="true">
		
		<cfstoredproc procedure="sp_GetLengthOfStayForHouse_v1" datasource="#arguments.dsn#">
			<cfprocparam value="#arguments.scope#" cfsqltype="CF_SQL_VARCHAR">
			<cfprocresult name="GetTenantsForHouse" resultset="1">
		</cfstoredproc>
	
		<cfreturn GetTenantsForHouse>
	</cffunction>
	
	<cffunction name="GetLengthOfStayExcelExport" access="public" returntype="string" output="false">
		<cfargument name="theQuery" type="query" required="true">
		
		<cfscript>
				GetTenantsForHouse = theQuery; 
				
				//the number of rows to add to the xml spreadshet
				numRows = GetTenantsForHouse.RecordCount + 1;
				
				//create the xml for the excel spreadsheet
				xml = "<?xml version=""1.0""?>
						<?mso-application progid=""Excel.Sheet""?>
						<Workbook xmlns=""urn:schemas-microsoft-com:office:spreadsheet""
						 xmlns:o=""urn:schemas-microsoft-com:office:office""
						 xmlns:x=""urn:schemas-microsoft-com:office:excel""
						 xmlns:ss=""urn:schemas-microsoft-com:office:spreadsheet""
						 xmlns:html=""http://www.w3.org/TR/REC-html40"">
						 <DocumentProperties xmlns=""urn:schemas-microsoft-com:office:office"">
						  <Author>ranklam</Author>
						  <LastAuthor>ranklam</LastAuthor>
						  <Created>2007-02-09T14:47:58Z</Created>
						  <Company>Assisted Living Concepts</Company>
						  <Version>11.8107</Version>
						 </DocumentProperties>
						 <ExcelWorkbook xmlns=""urn:schemas-microsoft-com:office:excel"">
						  <WindowHeight>14820</WindowHeight>
						  <WindowWidth>24795</WindowWidth>
						  <WindowTopX>240</WindowTopX>
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
						  <Style ss:ID=""s23"">
						   <Borders>
						    <Border ss:Position=""Bottom"" ss:LineStyle=""Continuous"" ss:Weight=""2""/>
						   </Borders>
						   <Font x:Family=""Swiss"" ss:Bold=""1""/>
						   <Interior ss:Color=""##FFFF99"" ss:Pattern=""Solid""/>
						  </Style>
						 </Styles>
						 <Worksheet ss:Name=""Sheet1"">
						  <Table ss:ExpandedColumnCount=""11"" ss:ExpandedRowCount=""~~ROWCOUNT~~"" x:FullColumns=""1""
						   x:FullRows=""1"">
						   <Column ss:Index=""6"" ss:Width=""83.25""/>
						   <Column ss:AutoFitWidth=""0"" ss:Width=""79.5""/>
						   <Column ss:Width=""81""/>
						   <Row ss:Height=""13.5"">
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Region</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Division</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">House</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Tenant</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Gender</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">SSAN</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Move In</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Charge Through</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Resident Fee</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Residency Type</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Stay</Data></Cell>
						   </Row>";
		//add the rows from the query to the xml spreadsheet			   
		for(i = 1; i lte GetTenantsForHouse.RecordCount; i = i + 1)
		{
			//check if the tenant has the same solomon key
			if(i lt GetTenantsForHouse.RecordCount and GetTenantsForHouse["csolomonkey"][i] eq GetTenantsForHouse ["csolomonkey"][i + 1])
			{
				GetTenantsForHouse["stay"][i + 1] = GetTenantsForHouse["stay"][i] + GetTenantsForHouse["stay"][i + 1];
				i = i + 1;
				
				numRows = numRows -1;
			}
			
			xml = xml & "<Row> 
				    <Cell><Data ss:Type=""String"">#GetTenantsForHouse["region"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#GetTenantsForHouse["division"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#GetTenantsForHouse["cname"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#GetTenantsForHouse["tenantName"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#GetTenantsForHouse["cSex"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#GetTenantsForHouse["cssn"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#DateFormat(GetTenantsForHouse["dtMoveIn"][i],'mm/dd/yyyy')#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#DateFormat(GetTenantsForHouse["dtChargeThrough"][i],'mm/dd/yyyy')#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#DollarFormat(GetTenantsForHouse["mAmount"][i])#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#GetTenantsForHouse["cdescription"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""Number"">#GetTenantsForHouse["Stayed"][i]#</Data></Cell>
				     </Row>";
		}
		
		//finish the excel xml spreadsheet
		xml = xml & "</Table>
			  <WorksheetOptions xmlns=""urn:schemas-microsoft-com:office:excel"">
			   <Print>
			    <ValidPrinterInfo/>
			    <HorizontalResolution>600</HorizontalResolution>
			    <VerticalResolution>600</VerticalResolution>
			   </Print>
			   <Selected/>
			   <Panes>
			    <Pane>
			     <Number>3</Number>
			     <ActiveRow>1</ActiveRow>
			     <ActiveCol>10</ActiveCol>
			    </Pane>
			   </Panes>
			   <ProtectObjects>False</ProtectObjects>
			   <ProtectScenarios>False</ProtectScenarios>
			  </WorksheetOptions>
			 </Worksheet>
			</Workbook>";
		
		//replace the numbrows with the modified numrows
		xml = Replace(xml,"~~ROWCOUNT~~",numRows);
		
		//send back the xml spreadsheet
		return xml;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetTenantsWithContacts" access="public" returntype="query" output="false">
		<cfargument name="dsn" type="string" required="true">		
		<cfstoredproc procedure="sp_GetTenantWithContacts" datasource="#arguments.dsn#">
			<cfprocresult name="GetTenantsAndContacts" resultset="1">
		</cfstoredproc>
	
		<cfreturn GetTenantsAndContacts>
	</cffunction>
	
	<cffunction name="GetTenantsWithContactsExcelExport" access="public" returntype="string" output="false">
		<!--- <cfargument name="theQuery" type="query" required="true"> --->
		<cfargument name="dsn" type="string" required="true">
		
		<cfscript>
				theQuery = GetTenantsWithContacts(arguments.dsn); 
				
				//the number of rows to add to the xml spreadshet
				numRows = theQuery.RecordCount + 1;
				
				//create the xml for the excel spreadsheet
				xml = "<?xml version=""1.0""?>
						<?mso-application progid=""Excel.Sheet""?>
						<Workbook xmlns=""urn:schemas-microsoft-com:office:spreadsheet""
						 xmlns:o=""urn:schemas-microsoft-com:office:office""
						 xmlns:x=""urn:schemas-microsoft-com:office:excel""
						 xmlns:ss=""urn:schemas-microsoft-com:office:spreadsheet""
						 xmlns:html=""http://www.w3.org/TR/REC-html40"">
						 <DocumentProperties xmlns=""urn:schemas-microsoft-com:office:office"">
						  <Author>jcruz</Author>
						  <LastAuthor>jcruz</LastAuthor>
						  <Created>2008-05-20T14:47:58Z</Created>
						  <Company>Assisted Living Concepts</Company>
						  <Version>11.8107</Version>
						 </DocumentProperties>
						 <ExcelWorkbook xmlns=""urn:schemas-microsoft-com:office:excel"">
						  <WindowHeight>14820</WindowHeight>
						  <WindowWidth>24795</WindowWidth>
						  <WindowTopX>240</WindowTopX>
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
						  <Style ss:ID=""s23"">
						   <Borders>
						    <Border ss:Position=""Bottom"" ss:LineStyle=""Continuous"" ss:Weight=""2""/>
						   </Borders>
						   <Font x:Family=""Swiss"" ss:Bold=""1""/>
						   <Interior ss:Color=""##FFFF99"" ss:Pattern=""Solid""/>
						  </Style>
						 </Styles>
						 <Worksheet ss:Name=""Sheet1"">
						  <Table ss:ExpandedColumnCount=""20"" ss:ExpandedRowCount=""#theQuery.RecordCount + 1#"" x:FullColumns=""1""
						   x:FullRows=""1"">
						   <Column ss:Index=""6"" ss:Width=""83.25""/>
						   <Column ss:AutoFitWidth=""0"" ss:Width=""79.5""/>
						   <Column ss:Width=""81""/>
						   <Row ss:Height=""13.5"">						    
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Customer ID</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Status</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Statement Cycle</Data></Cell>	   
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Customer Balance</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Last Activity Date</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Last Invoice Date</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Name</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Bill To Name</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Tenant ID</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Linked Tenant ID</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Tenant Payer</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Contact Payer</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Contact First Name</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Contact Last Name</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Contact Address 1</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Contact Address 2</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Contact City</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Contact State</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Contact Zip Code</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Relationship</Data></Cell>				    
						   </Row>";
		//add the rows from the query to the xml spreadsheet			   
		for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
			xml = xml & "<Row>
					<Cell><Data ss:Type=""String"">#theQuery["CustId"][i]#</Data></Cell>
					<Cell><Data ss:Type=""String"">#theQuery["Status"][i]#</Data></Cell> 
				    <Cell><Data ss:Type=""String"">#theQuery["StmtCycleId"][i]#</Data></Cell>	
				    <Cell><Data ss:Type=""String"">#theQuery["CustBal"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["LastActDate"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["LastInvcDate"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["Name"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["BillName"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["iTenant_ID"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["LinkedTenantID"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["TenantIsPayer"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["ContactIsPayer"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["ContactFname"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["ContactLname"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["cAddressLine1"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["cAddressLine2"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["cCity"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["cStateCode"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["cZipCode"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["cDescription"][i]#</Data></Cell>
				     </Row>";
		}
		
		//finish the excel xml spreadsheet
		xml = xml & "</Table>
			  <WorksheetOptions xmlns=""urn:schemas-microsoft-com:office:excel"">
			   <Print>
			    <ValidPrinterInfo/>
			    <HorizontalResolution>600</HorizontalResolution>
			    <VerticalResolution>600</VerticalResolution>
			   </Print>
			   <Selected/>
			   <Panes>
			    <Pane>
			     <Number>3</Number>
			     <ActiveRow>1</ActiveRow>
			     <ActiveCol>20</ActiveCol>
			    </Pane>
			   </Panes>
			   <ProtectObjects>False</ProtectObjects>
			   <ProtectScenarios>False</ProtectScenarios>
			  </WorksheetOptions>
			 </Worksheet>
			</Workbook>";
		
		//replace the numbrows with the modified numrows
		xml = Replace(xml,"~~ROWCOUNT~~",numRows);
		
		//send back the xml spreadsheet
		return xml;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetTenantsWithOverflow" access="public" returntype="query" output="false">
		<cfargument name="dsn" type="string" required="true">		
		<cfstoredproc procedure="sp_CustomerWithOverflow" datasource="#arguments.dsn#">
			<cfprocresult name="GetTenantsAndOverflow" resultset="1">
		</cfstoredproc>
	
		<cfreturn GetTenantsAndOverflow>
	</cffunction>
	
	<cffunction name="GetTenantsWithOverflowExcelExport" access="public" returntype="string" output="false">
		<!--- <cfargument name="theQuery" type="query" required="true"> --->
		<cfargument name="dsn" type="string" required="true">
		
		<cfscript>
				theQuery = GetTenantsWithOverflow(arguments.dsn); 
				
				//the number of rows to add to the xml spreadshet
				numRows = GetTenantsAndOverflow.RecordCount + 1;
				
				//create the xml for the excel spreadsheet
				xml = "<?xml version=""1.0""?>
						<?mso-application progid=""Excel.Sheet""?>
						<Workbook xmlns=""urn:schemas-microsoft-com:office:spreadsheet""
						 xmlns:o=""urn:schemas-microsoft-com:office:office""
						 xmlns:x=""urn:schemas-microsoft-com:office:excel""
						 xmlns:ss=""urn:schemas-microsoft-com:office:spreadsheet""
						 xmlns:html=""http://www.w3.org/TR/REC-html40"">
						 <DocumentProperties xmlns=""urn:schemas-microsoft-com:office:office"">
						  <Author>jcruz</Author>
						  <LastAuthor>jcruz</LastAuthor>
						  <Created>2008-05-20T14:47:58Z</Created>
						  <Company>Assisted Living Concepts</Company>
						  <Version>11.8107</Version>
						 </DocumentProperties>
						 <ExcelWorkbook xmlns=""urn:schemas-microsoft-com:office:excel"">
						  <WindowHeight>14820</WindowHeight>
						  <WindowWidth>24795</WindowWidth>
						  <WindowTopX>240</WindowTopX>
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
						  <Style ss:ID=""s23"">
						   <Borders>
						    <Border ss:Position=""Bottom"" ss:LineStyle=""Continuous"" ss:Weight=""2""/>
						   </Borders>
						   <Font x:Family=""Swiss"" ss:Bold=""1""/>
						   <Interior ss:Color=""##FFFF99"" ss:Pattern=""Solid""/>
						  </Style>
						 </Styles>
						 <Worksheet ss:Name=""Sheet1"">
						  <Table ss:ExpandedColumnCount=""19"" ss:ExpandedRowCount=""#GetTenantsAndOverflow.RecordCount + 1#"" x:FullColumns=""1""
						   x:FullRows=""1"">
						   <Column ss:Index=""6"" ss:Width=""83.25""/>
						   <Column ss:AutoFitWidth=""0"" ss:Width=""79.5""/>
						   <Column ss:Width=""81""/>
						   <Row ss:Height=""13.5"">						    
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Customer ID</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Status</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Statement Cycle</Data></Cell>	   
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Customer Balance</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Last Activity Date</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Last Invoice Date</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Name</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Bill To Name</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Bill To Attn</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Bill To Address 1</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Bill To Salutation</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Bill To Address 2</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Email Address</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Bill To City</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Bill To Country</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Bill To Fax</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Bill To Phone</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Bill To State</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Bill To Zip</Data></Cell>				    
						   </Row>";
		//add the rows from the query to the xml spreadsheet			   
		for(i = 1; i lte theQuery.RecordCount; i = i + 1)
			{
			xml = xml & "<Row>
					<Cell><Data ss:Type=""String"">#theQuery["CustId"][i]#</Data></Cell>
					<Cell><Data ss:Type=""String"">#theQuery["Status"][i]#</Data></Cell> 
				    <Cell><Data ss:Type=""String"">#theQuery["StmtCycleId"][i]#</Data></Cell>	
				    <Cell><Data ss:Type=""String"">#theQuery["CustBal"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["LastActDate"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["LastInvcDate"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["Name"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["BillName"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["BillAttn"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["BillAddr1"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["BillSalut"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["BillAddr2"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["EMailAddr"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["BillCity"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["BillCountry"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["BillFax"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["BillPhone"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["BillState"][i]#</Data></Cell>
				    <Cell><Data ss:Type=""String"">#theQuery["BillZip"][i]#</Data></Cell>
				     </Row>";
		}
		
		//finish the excel xml spreadsheet
		xml = xml & "</Table>
			  	<WorksheetOptions xmlns=""urn:schemas-microsoft-com:office:excel"">
			   		<Print>
			    		<ValidPrinterInfo/>
			    		<HorizontalResolution>600</HorizontalResolution>
			    		<VerticalResolution>600</VerticalResolution>
			   		</Print>
			   	<Selected/>
			   			<Panes>
			    			<Pane>
			     				<Number>3</Number>
			     				<ActiveRow>1</ActiveRow>
			     				<ActiveCol>19</ActiveCol>
			    			</Pane>
			   			</Panes>
			   			<ProtectObjects>False</ProtectObjects>
			   			<ProtectScenarios>False</ProtectScenarios>
			  	</WorksheetOptions>
			</Worksheet>
			</Workbook>";
		
		//replace the numbrows with the modified numrows
		xml = Replace(xml,"~~ROWCOUNT~~",numRows);
		
		//send back the xml spreadsheet
		return xml;
		</cfscript>
	</cffunction>
	
	<cffunction name="RunSolomonUpdate" access="public" returntype="query" output="false">
		<cfargument name="dsn" type="string" required="true">		
		<cfstoredproc procedure="sp_SolomonNightlyUpdate" datasource="#arguments.dsn#">
			<cfprocresult name="SolomonNightlyUpdate" resultset="1">
		</cfstoredproc>
	
		<cfreturn SolomonNightlyUpdate>
	</cffunction>
<!--- Modified as part of PROJECT 12392 by adding new function which gets the assessment id for the last assessment done for any given tenant. --->
	<cffunction name="GetAssessment" access="public" returntype="void" output="false">
		<!--- Get the assessment from the database --->
		<cfquery name="GetAssessmentQuery" datasource="#variables.dsn#">
			SELECT IsNull(Max(iAssessmentToolMaster_ID),0) AS iAssessmentToolMaster_ID 
			FROM
				AssessmentToolMaster
			WHERE
				iTenant_ID = #variables.id# or iResident_ID = #variables.residentId#
			AND
				dtRowDeleted IS NULL
			AND
				bBillingActive = 1
		</cfquery>
		
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
		<cfquery name="GetAssessmentsQuery" datasource="#variables.dsn#">
			SELECT
				 iAssessmentToolMaster_ID
				,bBillingActive
			FROM
				AssessmentToolMaster
			WHERE
				iTenant_ID = #variables.id#
			AND
				dtRowDeleted IS NULL
			UNION 
			SELECT
				 iAssessmentToolMaster_ID
				,bBillingActive
			FROM
				AssessmentToolMaster
			WHERE
				iResident_ID = (SELECT 
								R.iResident_ID 
							 FROM 
							 	#variables.leadtrackingdbserver#.LeadTracking.dbo.Resident R 
							 INNER JOIN 
							 	#variables.leadtrackingdbserver#.LeadTracking.dbo.ResidentState S ON S.iResident_ID = R.iResident_ID
							 WHERE 
							 	S.iTenant_ID = #variables.id#)
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
				Assessment.Init(theQuery["iAssessmentToolMaster_ID"][i],variables.dsn,variables.leadtrackingdsn);
				
				ArrayAppend(AssessmentArray,Assessment);
			}
			return AssessmentArray;
		</cfscript>
	</cffunction>
	<!--- Modified 4/15/2009 by Jaime Cruz as part of PROJECT 36034 in order to add new charge type to resulting spreadsheet. --->	
	<cffunction name="GetTenantsOver59Points" access="public" returntype="query" output="false">
			<cfargument name="dsn" type="string" required="true">		
			<cfstoredproc procedure="sp_TenantsOver59Points" datasource="#arguments.dsn#">
				<cfprocresult name="GetTenantsOver59Points" resultset="1">
			</cfstoredproc>
		
			<cfreturn GetTenantsOver59Points>
	</cffunction>
	
	<cffunction name="GetTenantsOver59PointsExcelExport" access="public" returntype="string" output="false">
		<!--- <cfargument name="theQuery" type="query" required="true"> --->
		<cfargument name="dsn" type="string" required="true">
		
		<cfscript>
				theQuery = GetTenantsOver59Points(arguments.dsn); 
				
				//the number of rows to add to the xml spreadshet
				numRows = theQuery.RecordCount + 1;
				
				//create the xml for the excel spreadsheet
				xml = "<?xml version=""1.0""?>
						<?mso-application progid=""Excel.Sheet""?>
						<Workbook xmlns=""urn:schemas-microsoft-com:office:spreadsheet""
						 xmlns:o=""urn:schemas-microsoft-com:office:office""
						 xmlns:x=""urn:schemas-microsoft-com:office:excel""
						 xmlns:ss=""urn:schemas-microsoft-com:office:spreadsheet""
						 xmlns:html=""http://www.w3.org/TR/REC-html40"">
						 <DocumentProperties xmlns=""urn:schemas-microsoft-com:office:office"">
						  <Author>jcruz</Author>
						  <LastAuthor>jcruz</LastAuthor>
						  <Created>2008-07-07T11:47:58Z</Created>
						  <Company>Assisted Living Concepts</Company>
						  <Version>11.8107</Version>
						 </DocumentProperties>
						 <ExcelWorkbook xmlns=""urn:schemas-microsoft-com:office:excel"">
						  <WindowHeight>14820</WindowHeight>
						  <WindowWidth>24795</WindowWidth>
						  <WindowTopX>240</WindowTopX>
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
						  <Style ss:ID=""s23"">
						   <Borders>
						    <Border ss:Position=""Bottom"" ss:LineStyle=""Continuous"" ss:Weight=""2""/>
						   </Borders>
						   <Font x:Family=""Swiss"" ss:Bold=""1""/>
						   <Interior ss:Color=""##FFFF99"" ss:Pattern=""Solid""/>
						  </Style>
						 </Styles>
						 <Worksheet ss:Name=""Sheet1"">
						  <Table ss:ExpandedColumnCount=""11"" ss:ExpandedRowCount=""#theQuery.RecordCount + 1#"" x:FullColumns=""1""
						   x:FullRows=""1"">
						   <Column ss:Index=""6"" ss:Width=""83.25""/>
						   <Column ss:AutoFitWidth=""0"" ss:Width=""79.5""/>
						   <Column ss:Width=""81""/>
						   <Row ss:Height=""13.5"">						    
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Division</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Region</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">House</Data></Cell>	   
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Tenant Name</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Date Billing Activated</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Level</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Points</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Personal Service Charge</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Additional Service Charge</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Private Care Adjustment</Data></Cell>
						    <Cell ss:StyleID=""s23""><Data ss:Type=""String"">Payor Type</Data></Cell>						    
						   </Row>";
				//add the rows from the query to the xml spreadsheet			   
				for(i = 1; i lte theQuery.RecordCount; i = i + 1)
					{
					xml = xml & "<Row>
							<Cell><Data ss:Type=""String"">#theQuery["division"][i]#</Data></Cell>
							<Cell><Data ss:Type=""String"">#theQuery["region"][i]#</Data></Cell> 
						    <Cell><Data ss:Type=""String"">#theQuery["house"][i]#</Data></Cell>
						    <Cell><Data ss:Type=""String"">#theQuery["tenantname"][i]#</Data></Cell>
						    <Cell><Data ss:Type=""String"">#theQuery["dtbillingactive"][i]#</Data></Cell>
						    <Cell><Data ss:Type=""String"">#theQuery["level"][i]#</Data></Cell>
						    <Cell><Data ss:Type=""Number"">#theQuery["ispoints"][i]#</Data></Cell>	
						    <Cell><Data ss:Type=""Number"">#theQuery["mAmount"][i]#</Data></Cell>
						    <Cell><Data ss:Type=""Number"">#theQuery["AdditionalServiceCharge"][i]#</Data></Cell>
						    <Cell><Data ss:Type=""Number"">#theQuery["PrivateCareAdjustment"][i]#</Data></Cell>
						    <Cell><Data ss:Type=""String"">#theQuery["payortype"][i]#</Data></Cell>
						   
						     </Row>";
					}
		
				//finish the excel xml spreadsheet
				xml = xml & "</Table>
					  	<WorksheetOptions xmlns=""urn:schemas-microsoft-com:office:excel"">
					   		<Print>
					    		<ValidPrinterInfo/>
					    		<HorizontalResolution>600</HorizontalResolution>
					    		<VerticalResolution>600</VerticalResolution>
					   		</Print>
					   	<Selected/>
					   			<Panes>
					    			<Pane>
					     				<Number>3</Number>
					     				<ActiveRow>1</ActiveRow>
					     				<ActiveCol>11</ActiveCol>
					    			</Pane>
					   			</Panes>
					   			<ProtectObjects>False</ProtectObjects>
					   			<ProtectScenarios>False</ProtectScenarios>
					  	</WorksheetOptions>
					</Worksheet>
					</Workbook>";
				
				//replace the numbrows with the modified numrows
				xml = Replace(xml,"~~ROWCOUNT~~",numRows);
				
				//send back the xml spreadsheet
				return xml;
		</cfscript>
	</cffunction>

   <!--- 01/14/2010 Sathya as per project 41315 added this to save the tenant height and weight information--->
  	<cffunction name="UpdateTenantInfo" access="public" returntype="void" output="false" hint="updated the height and weight of a tenant">
		   <cfquery name="QuerySaveforTenant" datasource="#variables.dsn#">
	         UPDATE
					Tenant
			  SET
			  	iWeight = <cfif variables.weight NEQ 0>#variables.weight#<cfelse>NULL</cfif>,
				iHeight = <cfif variables.height NEQ 0>#variables.height#<cfelse>NULL</cfif>  
				
			WHERE
				iTenant_id =  #variables.id#
			</cfquery>
	</cffunction>

<!----------------------------------------------------------
*                   GETTERS AND SETTERS                    *
----------------------------------------------------------->	

	<cffunction name="GetId" access="public" returntype="numeric" output="false" hint="Returns a tenants id.">
		<cfscript>
			return variables.id;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetResidentId" access="public" returntype="numeric" output="false" hint="Returns the Resident Id.">
		<cfscript>
			return variables.residentId;
		</cfscript>
	
	</cffunction>
	
	<cffunction name="GetAssessmentId" access="public" returntype="numeric" output="false" hint="Returns tenants assessment id.">
		<cfscript>
			return variables.assessmentid;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetState" access="public" returntype="Components.TenantState" output="false">
		<cfscript>
			TenantState = CreateObject("Component","Components.TenantState");
			TenantState.Init(variables.tenantStateID,variables.dsn);
			
			return TenantState;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetHouse" access="public" returntype="Components.House" output="false" hint="Returns a tenants house.">
		<cfscript>
			House = CreateObject("Component","Components.House");
			House.Init(variables.houseId,variables.dsn,variables.leadtrackingdbserver,variables.censusdbserver);
			
			return House;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetHouse" access="public" returntype="void" output="false" hint="Sets a tenants house.">
		<cfargument name="House" type="Components.House" required="true">
		
		<cfscript>
			variables.houseId = House.GetId();
		</cfscript>
	</cffunction>
	
	<cffunction name="GetSolomonKey" access="public" returntype="string" output="false" hint="Gets a tenants solomon key">
		<cfscript>
		 return variables.solomonKey;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSolomonKey" access="public" returntype="void" output="false" hint="Sets a tenants solomon key">
		<cfargument name="solomonKey" type="string" required="true">
		
		<cfscript>
			variables.solomonKey = arguments.solomonKey;
		</cfscript>	
	</cffunction>
	
	<cffunction name="GetIsPayer" access="public" returntype="boolean" output="false" hint="Gets the tenants payer status">
		<cfscript>
			return variables.isPayer;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetIsPayer" access="public" returntype="void" output="false" hint="Sets the tenants payer status">
		<cfargument  name="isPayer" type="boolean" required="true">
		<cfscript>
			variables.isPayer = arguments.isPayer;
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
	
	<cffunction name="GetFullName" access="public" returntype="string" output="false" hint="Gets the tenatns full name">
		<cfscript>
			return variables.firstName & ' ' & variables.lastName;
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
	
	<cffunction name="GetMedicaidNumber" access="public" returntype="string" output="false" hint="Gets the tenants medicaid number">
		<cfscript>
			return variables.medicaidNumber;
		</cfscript>	
	</cffunction>
	
	<cffunction name="SetMedicaidNumber" access="public" returntype="void" output="false" hint="Sets the tenants medicaid number">
		<cfargument name="medicaidNumber" type="string" required="true">
		<cfscript>
			variables.medicaidNumber = arguments.medicaidNumber;
		</cfscript>	
	</cffunction>
	
	<cffunction name="GetOutsidePhoneNumber1" access="public" returntype="string" output="false" hint="Gets a tenants outside phone number.">
		<cfscript>
			return variables.outsidePhoneNumber1;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetOutsidePhoneNumber1" access="public" returntype="void" output="false" hint="Sets a tenants outside phone number.">
		<cfargument name="outsidePhoneNumber1" type="string" required="true">
		<cfscript>
			variables.outsidePhoneNumber1 = arguments.outsidePhoneNumber1;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetOutsidePhoneType1" access="public" returntype="Components.PhoneType" output="false" hint="Gets the tenants outside phone type">
		<cfscript>
			PhoneType = CreateObject("Component","Components.PhoneType");
			PhoneType.Init(variables.outsidePhoneType1Id, variables.dsn);
			
			return PhoneType;
		</cfscript>
	</cffunction>

	<cffunction name="SetOutsidePhoneType1" access="public" returntype="void" output="false" hint="Sets the tenants outside phone type">
		<cfargument name="outsidePhoneTypeId" type="numeric" required="true">
		<cfscript>
			variables.outsidePhoneType1Id = arguments.outsidePhoneTypeId;
		</cfscript>
	</cffunction>		

	<cffunction name="GetOutsidePhoneNumber2" access="public" returntype="string" output="false" hint="Gets a tenants outside phone number.">
		<cfscript>
			return variables.outsidePhoneNumber2;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetOutsidePhoneNumber2" access="public" returntype="void" output="false" hint="Sets a tenants outside phone number.">
		<cfargument name="outsidePhoneNumber2" type="string" required="true">
		<cfscript>
			variables.outsidePhoneNumber2 = arguments.outsidePhoneNumber2;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetOutsidePhoneType2" access="public" returntype="Components.PhoneType" output="false" hint="Gets the tenants outside phone type">
		<cfscript>
			PhoneType = CreateObject("Component","Components.PhoneType");
			PhoneType.Init(variables.outsidePhoneType2Id, variables.dsn);
			
			return PhoneType;
		</cfscript>
	</cffunction>

	<cffunction name="SetOutsidePhoneType2" access="public" returntype="void" output="false" hint="Sets the tenants outside phone type">
		<cfargument name="outsidePhoneTypeId" type="numeric" required="true">
		<cfscript>
			variables.outsidePhoneType2Id = arguments.outsidePhoneTypeId;
		</cfscript>
	</cffunction>	

	<cffunction name="GetOutsidePhoneNumber3" access="public" returntype="string" output="false" hint="Gets a tenants outside phone number.">
		<cfscript>
			return variables.outsidePhoneNumber3;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetOutsidePhoneNumber3" access="public" returntype="void" output="false" hint="Sets a tenants outside phone number.">
		<cfargument name="outsidePhoneNumber3" type="string" required="true">
		<cfscript>
			variables.outsidePhoneNumber3 = arguments.outsidePhoneNumber3;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetOutsidePhoneType3" access="public" returntype="Components.PhoneType" output="false" hint="Gets the tenants outside phone type">
		<cfscript>
			PhoneType = CreateObject("Component","Components.PhoneType");
			PhoneType.Init(variables.outsidePhoneType3Id, variables.dsn);
			
			return PhoneType;
		</cfscript>
	</cffunction>

	<cffunction name="SetOutsidePhoneType3" access="public" returntype="void" output="false" hint="Sets the tenants outside phone type">
		<cfargument name="outsidePhoneTypeId" type="numeric" required="true">
		<cfscript>
			variables.outsidePhoneType3Id = arguments.outsidePhoneTypeId;
		</cfscript>
	</cffunction>	
	
	<cffunction name="GetOutsideAdressLine1" access="public" returntype="string" output="false" hint="Gets a tenants outside address line 1">
		<cfscript>
			return variables.outsideAddressLine1;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetOutsideAdressLine1" access="public" returntype="string" output="false" hint="Sets a tenants outside address line 1">
		<cfargument name="outsideAddressLine1" type="string" required="true">
		<cfscript>
			variables.outsideAddressLine1 = arguments.outsideAddressLine1;
		</cfscript>
	</cffunction>

	<cffunction name="GetOutsideAdressLine2" access="public" returntype="string" output="false" hint="Gets a tenants outside address line 2">
		<cfscript>
			return variables.outsideAddressLine2;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetOutsideAdressLine2" access="public" returntype="string" output="false" hint="Sets a tenants outside address line 2">
		<cfargument name="outsideAddressLine2" type="string" required="true">
		<cfscript>
			variables.outsideAddressLine2 = arguments.outsideAddressLine2;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetOutsideCity" access="public" returntype="string" output="false" hint="Gets a tenants outside city">
		<cfscript>
			return variables.outsideCity;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetOutsideCity" access="public" returntype="void" output="false" hint="Sets a tenants outside city">
		<cfargument name="outsideCity" type="string" required="true">
		<cfscript>
			variables.outsideCity = arguments.outsideCity;
		</cfscript>
	</cffunction>
		
	<cffunction name="GetOutsideStateCode" access="public" returntype="string" output="false" hint="Gets a tenants outside state code">
		<cfscript>
			return variables.outsideStateCode;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetOutsideStateCode" access="public" returntype="string" output="false" hint="Sets a tenants outside state code">
		<cfargument name="outsideStateCode" type="string" required="true">
		<cfscript>
			variables.outsideStateCode = arguments.outsideStateCode;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetOutsideZipCode" access="public" returntype="string" output="false" hint="Gets a tenants zip code">
		<cfscript>
			return variables.outsideZipCode;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetOutsideZipCode" access="public" returntype="string" output="false" hint="Sets a tenants zip code">
		<cfargument name="outsideZipCode" type="string" required="true">
		<cfscript>
			variables.outsideZipCode = arguments.outsideZipCode;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetComments" access="public" returntype="string" output="false" hint="Gets a tenants comments">
		<cfscript>
			return variables.comments;
		</cfscript>
	</cffunction>

	<cffunction name="SetComments" access="public" returntype="void" output="false" hint="Sets a tenants comments">
		<cfargument name="comments" type="string" required="true">
		<cfscript>
			variables.comments = arguments.comments;
		</cfscript>
	</cffunction>
		
	<cffunction name="GetChargeSet" access="public" returntype="string" output="false" hint="Gets a tenants chargeset">
		<cfscript>
			return variables.chargeSet;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetChargeSet" access="public" returntype="void" output="false" hint="Sets a tenants chargeset">
		<cfargument name="chargeset" type="string" required="true">
		<cfscript>
			variables.chargeSet = arguments.chargeset;
		</cfscript>
	</cffunction>
	
	<cffunction name="GetIsMedicaid" access="public" returntype="boolean" output="false" hint="Gets the tenats ismedicaid status">
		<cfscript>
			return variables.isMedicaid;
		</cfscript>
	</cffunction>

	<cffunction name="SetIsMedicaid" access="public" returntype="boolean" output="false" hint="Sets the tenats ismedicaid status">
		<cfargument name="isMedicaid" type="boolean" required="true">
		<cfscript>
			variables.isMedicaid = arguments.isMedicaid;
		</cfscript>
	</cffunction>
		
	<cffunction name="GetIsMisc" access="public" returntype="boolean" output="false" hint="Gets the tenats isMisc status">
		<cfscript>
			return variables.isMisc;
		</cfscript>
	</cffunction>

	<cffunction name="SetIsMisc" access="public" returntype="boolean" output="false" hint="Sets the tenats isMisc status">
		<cfargument name="isMisc" type="boolean" required="true">
		<cfscript>
			variables.isMisc = arguments.isMisc;
		</cfscript>
	</cffunction>		

	<cffunction name="GetIsDayRespite" access="public" returntype="boolean" output="false" hint="Gets the tenats isDayRespite status">
		<cfscript>
			return variables.isDayRespite;
		</cfscript>
	</cffunction>

	<cffunction name="SetIsDayRespite" access="public" returntype="void" output="false" hint="Sets the tenats isDayRespite status">
		<cfargument name="isDayRespite" type="boolean" required="true">
		<cfscript>
			variables.isDayRespite = arguments.isDayRespite;
		</cfscript>
	</cffunction>


	<cffunction name="GetSLevelTypeSet" access="public" returntype="string" output="false" hint="Gets the tenants sLevelTypeSet">
		<cfscript>
			return variables.sLevelTypeSet;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetSLevelTypeSet" access="public" returntype="void" output="false" hint="Sets the tenatns sLevelTypeSet">
		<cfargument name="sLevelTypeSet" type="string" required="true">
		<cfscript>
			variables.sLevelTypeSet = arguments.sLevelTypeSet;
		</cfscript>
	</cffunction>


	<cffunction name="GetAppFeePaid" access="public" returntype="boolean" output="false" hint="Get the tenants appFeePaid">
		<cfscript>
			return variables.appFeePaid;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetAppFeePaid" access="public" returntype="void" output="false" hint="Sets the tenants appFee paid">
		<cfargument name="appFeePaid" type="boolean" required="true">
		<cfscript>
			variables.appFeePaid = arguments.appFeePaid;
		</cfscript>
	</cffunction>


	<cffunction name="GetAcctStamp" access="public" returntype="string" output="false" hint="Gets the tenants acctStamp">
		<cfscript>
			return variables.acctStamp;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetAcctStamp" access="public" returntype="void" output="false" hint="Sets the tenants acctStamp">
		<cfargument name="acctStamp" type="string" required="true">
		<cfscript>
			variables.acctStamp = arguments.acctStamp;
		</cfscript>
	</cffunction>


	<cffunction name="GetBillingType" access="public" returntype="string" output="false" hint="Gets the tenatns billingType">
		<cfscript>
			return variables.billingType;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetBillingType" access="public" returntype="void" output="false" hint="Gets the tenants billingType">
		<cfargument name="billingType" type="string" required="true">
		<cfscript>
			variables.billingType = arguments.billingType;
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
	
	
	<cffunction name="GetEmail" access="public" returntype="string" output="false" hint="Gets the tenants email">
		<cfscript>
			return variables.email;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetEmail" access="public" returntype="void" output="false" hint="Sets the tenants email">
		<cfargument name="email" type="string" required="true">
		<cfscript>
			variables.email = arguments.email;
		</cfscript>
	</cffunction>

	<cffunction name="GetDunningMessageId" access="public" returntype="numeric" output="false" hint="Gets the tenants dunningMessageId">
		<cfscript>
			return variables.dunningMessageId;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetDunningMessageId" access="public" returntype="void" output="false" hint="Sets the tenants dunningMessageId">
		<cfargument name="dunningMessageId" type="numeric" required="true">
		<cfscript>
			variables.dunningMessageId = arguments.dunningMessageId;
		</cfscript>
	</cffunction>

	<cffunction name="GetOverDueBalance" access="public" returntype="numeric" output="false" hint="Gets a tenants overdue balance">
		<cfscript>
		 	return variables.overDueBalance;
		</cfscript>
	</cffunction>
	
	<cffunction name="SetOverDueBalance" access="public" returntype="void" output="false" hint="Sets a tenants overdue balance">
		<cfargument name="overDueBalance" type="numeric" required="true">
		
		<cfscript>
			variables.overDueBalance = arguments.overDueBalance;
		</cfscript>	
	</cffunction>

	<cffunction name="GetName" access="public" returntype="string" output="false" hint="Gets a tenants full name">
		<cfscript> 
		 	return variables.firstname & " " & variables.lastname;
		</cfscript>
	</cffunction>
		
	<cffunction name="GetType" access="public" returntype="string" output="false">
		<cfscript>
			return "Tenant";
		</cfscript>
	</cffunction>
	<!--- 01/12/2010 Sathya as per project 41315 added this --->
	<cffunction name="GetWeight" access="public" returntype="String" output="false" hint="Returns Tenant Weight.">
		<cfscript>
			return variables.Weight;
		</cfscript>
	</cffunction>
	<!--- 01/12/2010 Sathya as per project 41315 added this --->
	<cffunction name="GetHeight" access="public" returntype="String" output="false" hint="Returns Tenant Height.">
		<cfscript>
			return variables.Height;
		</cfscript>
	</cffunction>
	<!--- 01/14/2010 Sathya as per project 41315 added this --->
	<cffunction name="SetTenantHeight" access="public" returntype="void" output="false" hint="Set the tenant height">
		<cfargument name="TenantHeight" type="string" required="true">
		<cfscript>
			variables.height = arguments.TenantHeight;
		</cfscript>
	</cffunction>
    <!--- 01/14/2010 Sathya as per project 41315 added this --->
   <cffunction name="SetTenantWeight" access="public" returntype="void" output="false" hint="Set the tenant weight">
		<cfargument name="TenantWeight" type="string" required="true">
		<cfscript>
			variables.weight = arguments.TenantWeight;
		</cfscript>
	</cffunction>
</cfcomponent>