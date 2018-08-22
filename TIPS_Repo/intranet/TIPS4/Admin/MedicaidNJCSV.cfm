<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>

	<cfparam name="itenantID" default="">
	<cfparam name="cperiod" default="">
	<cfparam name="firstday" default="">
	<cfparam name="lastday" default="">
	<cfparam name="StoppedatCount" default="">
	<cfparam name="lastday2" default="">
	<cfparam name="StoppedatCount2" default="">
	<cfparam name="firstday2" default="">
	<cfparam name="dtBegin" default="">
	<cfparam name="dtEnd" default="">
	<cfoutput  > 
		<cfset fileerror = "N">
		<cfset batchdate = #CreateODBCDateTime(Now())#>
		<cfset todaysdate = dateformat(now(),'mmddyyyy')>
		<cfset hdrdate = dateformat(now(),'mm/dd/yy')>	
		<cfif cgi.SERVER_NAME is "Scooby">
			<cfset destFilePath = "\\fs01\ALC_IT\MedicaidNJ"> 
		<cfelse>
			<cfset destFilePath = "\\fs01\ar\MedicaidNJ">	
		</cfif>	
 
		<cfset firstrec = "Y">

		<cfif FileExists("#destFilePath#\MedicaidNJ#todaysdate#.xls")>
			<cffile   action="rename"  
				source="#destFilePath#\MedicaidNJ#todaysdate#.xls" destination="#destFilePath#\Old\MedicaidNJ#todaysdate#.xls" >
		</cfif>
		<cfif FileExists("#destFilePath#\MedicaidNJ#todaysdate#.xls")>
			<cffile action="delete"  file="#destFilePath#\MedicaidNJ#todaysdate#.xls" >
		</cfif>		
 
	<cfprocessingdirective suppresswhitespace="Yes">
		<!--- <cfcontent type="text/xml; charset=utf-16"> --->
		<cfxml variable="xmlDataDump"> 
		<?mso-application progid="Excel.Sheet"?>
		<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:o="urn:schemas-microsoft-com:office:office"
			xmlns:x="urn:schemas-microsoft-com:office:excel"
			xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
			xmlns:html="http://www.w3.org/TR/REC-html40">
			<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
				<ActiveSheet>1</ActiveSheet>
				<ProtectStructure>False</ProtectStructure>
				<ProtectWindows>False</ProtectWindows>
			</ExcelWorkbook>
			<Styles>
				<ss:Style ss:ID="Default" ss:name="Normal">
					<Alignment ss:Vertical="Top"  ss:WrapText="1"/>
					<Borders/>
					<Font/>
					<Interior/>
					<NumberFormat/>
					<Protection/>
				</ss:Style>
			</Styles>		
			
			<Worksheet ss:Name="NJMedicaid">
				<Table>
					<Column ss:AutoFitWidth="0" ss:Width="50"  />
					<Column ss:AutoFitWidth="0" ss:Width="50"  />		
					<Column ss:AutoFitWidth="0" ss:Width="50"  />
					<Column ss:AutoFitWidth="0" ss:Width="50"  />		
					<Column ss:AutoFitWidth="0" ss:Width="50"  />
					<Column ss:AutoFitWidth="0" ss:Width="50"  />		
					<Column ss:AutoFitWidth="0" ss:Width="50"  />
					<Column ss:AutoFitWidth="0" ss:Width="50"  />		
					<Column ss:AutoFitWidth="0" ss:Width="50"  />
					<Column ss:AutoFitWidth="0" ss:Width="50"  />	
					<Column ss:AutoFitWidth="0" ss:Width="50"  />
					<Column ss:AutoFitWidth="0" ss:Width="50"  />		
					<Column ss:AutoFitWidth="0" ss:Width="50"  />
					<Column ss:AutoFitWidth="0" ss:Width="50"  />																																																
					<Column ss:AutoFitWidth="0" ss:Width="50"  />
					<Column ss:AutoFitWidth="0" ss:Width="50"  />	
					<Column ss:AutoFitWidth="0" ss:Width="50"  />
					<Column ss:AutoFitWidth="0" ss:Width="50"  />
					<Column ss:AutoFitWidth="0" ss:Width="50"  />																																																
					<Column ss:AutoFitWidth="0" ss:Width="50"  />
					<Column ss:AutoFitWidth="0" ss:Width="50"  />	
					<Column ss:AutoFitWidth="0" ss:Width="50"  />
					<Row>
						<Cell>
							<Data ss:Type="String">LName</Data>
						</Cell> 
						<Cell>
							<Data ss:Type="String">Fname</Data>
						</Cell> 										 
						<Cell>
							<Data ss:Type="String">MI</Data>
						</Cell> 						 
						<Cell>
							<Data ss:Type="String">NJ HSP</Data>
						</Cell> 					
						<Cell>
							<Data ss:Type="String">MCO</Data>
						</Cell> 							
						<Cell>
							<Data ss:Type="String">MCO ID</Data>
						</Cell> 
						<Cell>
							<Data ss:Type="String">Authorization No.</Data>
						</Cell> 					
						<Cell>
							<Data ss:Type="String">Auth FDOS</Data>
						</Cell>
						<Cell>
							<Data ss:Type="String">Auth TDOS</Data>
						</Cell> 							
						<Cell>
							<Data ss:Type="String">DOB</Data>
						</Cell>
						<Cell>
							<Data ss:Type="String">SSNA</Data>
						</Cell> 						
						<Cell>
							<Data ss:Type="String">Sex</Data>
						</Cell> 
						<Cell>
							<Data ss:Type="String">PICD</Data>
						</Cell> 						
						<Cell>
							<Data ss:Type="String">SICD</Data>
						</Cell> 
						<Cell>
							<Data ss:Type="String">TICD</Data>
						</Cell> 
						<Cell>
							<Data ss:Type="String">FDOS</Data>
						</Cell> 						
						<Cell>
							<Data ss:Type="String">TDOS</Data>
						</Cell> 
						<Cell>
							<Data ss:Type="String">Days</Data>
						</Cell> 						
						<Cell>
							<Data ss:Type="String">Gross</Data>
						</Cell> 
						<Cell>
							<Data ss:Type="String">Cost Share</Data>
						</Cell> 
						<Cell>
							<Data ss:Type="String">Net</Data>
						</Cell> 						
						<Cell>
							<Data ss:Type="String">SolomonID</Data>
						</Cell>
					</Row>
 
					<cfset index = 1>
					<cfset maxlines = arraylen(FinalArray)>
					<cfloop condition="#index# lte #maxlines#" >
							<cfset tenantID = FinalArray[index][1]>
							<cfset startdate = FinalArray[index][2]>
							<cfset enddate = FinalArray[index][3]>
							<cfset totaldays = #DateDiff('d',startdate, enddate)#  +1>
							<!--- t.cssn --->
 							<cfquery name="qryMedicaidChg"  datasource="#APPLICATION.datasource#">
								select t.clastname as  'Lname'
								, t.cfirstname as 'Fname'
								,  IsNull(t.cMiddleInitial, ' ') as  'MiddleInitial' 
								,ts.cNJHSP as  'NJHSP'
								,MCO.cMCOProvider as  'MCO'
								,MCO.iMCO_id as  'MCOID'
								,ts.cMedicaidAuthorizationNbr 
								,ts.dtAuthFDOS  
								,ts.dtAuthTDOS  
								,convert(varchar(10),t.dbirthdate,101) as  'DOB'
								,'555-55-5555' as  'SSNA'  
								,ts.cSex  
								,ts.iPICD as  PICD
								,ts.iSICD as  SICD
								,ts.iTICD as  TICD
								,convert(DECIMAL(19,2),hm.mStateMedicaidAmt_BSF_Daily * #totaldays#) as  'Gross'
								,convert(DECIMAL(19,2),ts.mMedicaidCopay * #totaldays#/#idaysinMonth#) as  'CostShare'
								,convert(DECIMAL(19,2),hm.mStateMedicaidAmt_BSF_Daily * #totaldays# - ts.mMedicaidCopay * #totaldays#/#idaysinMonth#) 
									as  'Net'
								,t.itenant_id
								,t.csolomonkey
								<!--- ,mco.cMCOProvider, mco.iMCO_id --->
								from tenant t 
								join tenantstate ts on t.itenant_id = ts.itenant_id  
								join house h on t.ihouse_id = h.ihouse_id
								join HouseMedicaid hm on h.ihouse_id = hm.ihouse_id
								join MCOProvider MCO on ts.iMCOProvider = MCO.iMCOProvider_ID
								
								where
								t.itenant_id = #tenantID#
								and t.dtrowdeleted is null and ts.dtrowdeleted is null 
							</cfquery>  
							<Row>
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.Lname))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.Fname))#</Data>
								</Cell> 										 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.MiddleInitial))#</Data>
								</Cell> 						 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.NJHSP))#</Data>
								</Cell> 					
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.MCO))#</Data>
								</Cell> 					
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.MCOID))#</Data>
								</Cell> 							
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.cMedicaidAuthorizationNbr))#</Data>
								</Cell> 					
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(dateformat(qryMedicaidChg.dtAuthFDOS,'mm/dd/yyyy')))#</Data>
								</Cell> 							
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(dateformat(qryMedicaidChg.dtAuthTDOS,'mm/dd/yyyy')))#</Data>
								</Cell> 							
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.DOB))#</Data>
								</Cell> 								
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.SSNA))#</Data>
								</Cell> 						
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.cSex))#</Data>
								</Cell> 						 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.PICD))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.SICD))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.TICD))#</Data>
								</Cell> 						 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(dateformat(startdate,'mm/dd/yyyy')))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(dateformat(enddate,'mm/dd/yyyy')))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(totaldays))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.Gross))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.CostShare))#</Data>
								</Cell> 						 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.Net))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.csolomonkey))#</Data>
								</Cell> 										
							</Row> 
						<cfset index = index + 1> 
					</cfloop> 
					
				</Table>
			</Worksheet>
		</Workbook>
		</cfxml>
		<cfset xml = ToString(xmlDataDump)> 
		<cffile action="append" nameconflict="overwrite" file="#destFilePath#\MedicaidNJ#todaysdate#.xls"  output="#xml#">  
	</cfprocessingdirective>
	
<!--- 	<cfinclude template="../../header.cfm">	
	<h1 class="PageTitle"> Tips 4 - New Jersey Medicaid File Extract</h1>
	<cfinclude template="../Shared/HouseHeader.cfm"> --->	

<!--- <dir>New Jersey Medicaid Payment FIle Extract #destFilePath#\MedicaidNJ#todaysdate#.xls is complete</dir> --->
</cfoutput>
 							
</body>
</html>
