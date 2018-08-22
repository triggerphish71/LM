<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
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

	<cfset itenantID = #thisresident#>

	<cfquery name="tenantinfo"  datasource="#APPLICATION.datasource#">
	select cfirstname + ' ' + clastname 'Name' from tenant where itenant_id = #itenantID#
	</cfquery>
	<cfquery name="qryChgPeriod" datasource="#APPLICATION.datasource#">
		SELECT  iTenant_ID
			,iLeaveStatus_ID
			,convert(varchar(12),Census_Date,101) Census_Date
			,CurrentStatusInBedAtMidnight
			,convert(varchar(12),TempStatusOutDate,101) TempStatusOutDate
		FROM [TIPS4].[dbo].[DailyCensusTrack] 
		where itenant_id = #itenantID#
		and census_date between '#dtBegin#' and '#dtEnd#'
		order by census_date
	</cfquery>
<body>

	<cfset ChgDayarray=arraynew(2)> 
	<cfset outdays=arraynew(2)>
	<cfset indays=arraynew(2)>
	<cfloop query="qryChgPeriod"> 
		<cfset ChgDayarray[CurrentRow][1]=currentrow>
		<cfset ChgDayarray[CurrentRow][2]=iTenant_ID> 
		<cfset ChgDayarray[CurrentRow][3]=iLeaveStatus_ID> 
		<cfset ChgDayarray[CurrentRow][4]=Census_Date> 
		<cfset ChgDayarray[CurrentRow][5]=TempStatusOutDate> 
		<cfset ChgDayarray[CurrentRow][6]=CurrentStatusInBedAtMidnight>	
	</cfloop> 

	<cfset total_records=qryChgPeriod.recordcount> 
	<cfset ChgPeriodArray=arraynew(2)>
	<cfloop index="Counter" from=1 to="#Total_Records#"  > 
		<cfset thisTenID = #ChgDayarray[Counter][2]#>
	</cfloop> 
	<cfset yesoutdays = 'N'>
	<cfset firstday = #ChgDayarray[1][4]#>
	<cfset index = 1>
	<cfset j = 1><cfset k = 1>
	<cfset indays[1][1] = #ChgDayarray[1][4]#>

	<cfset counter = #qryChgPeriod.recordcount#>
	<cfloop  condition="index lte total_records" > 
		<cfset lastday = #ChgDayarray[#index#][4]#>
		<cfset StoppedatCount = #Counter#>	
		<cfif ChgDayarray[index][3]is 0>
			<cfif yesoutdays is 'Y' >
				<cfset k = k + 1>
				<cfset indays[k][1] = #ChgDayarray[index][4]# >
				<cfset indays[k][3] = #ChgDayarray[index][2]#>
				<cfset yesoutdays = 'N'>
			</cfif>
			<cfset indays[k][2] = #ChgDayarray[index][4]#>
			<cfset indays[k][3] = #ChgDayarray[index][2]#>			
		<cfelseif #ChgDayarray[index][3]# gt 0>
			<cfset outdays[j][1] = index>
			<cfset outdays[j][2] = #ChgDayarray[index][4]#>
			<cfset j = j + 1>
			<cfset yesoutdays = 'Y'>
		</cfif>
		<cfset index = index + 1>	
	</cfloop>

	<cfoutput  > 
		<cfset fileerror = "N">
		<cfset batchdate = #CreateODBCDateTime(Now())#>
		<cfset todaysdate = dateformat(now(),'mmddyyyy')>
		<cfset hdrdate = dateformat(now(),'mm/dd/yy')>	
		<cfif cgi.SERVER_NAME is "vmappprod01dev3">
			<cfset destFilePath = "\\fs01\ALC_IT\MedicaidNJ"> 
		<cfelse>
			<cfset destFilePath = "\\fs01\ar\MedicaidNJ">	
		</cfif>	
		<!--- <cfset destFilePath = "\\fs01\ALC_IT\EFTPull">  ---> 
		<!--- <cfset destFilePath = "\\fs01\ar\Auto Withdrawal EFT\2012\RAW EFT files"> --->  
		<cfset firstrec = "Y">


		<cfif FileExists("#destFilePath#\MedicaidNJ#todaysdate#.xls")>
			<cffile   action="rename"  
				source="#destFilePath#\MedicaidNJ#todaysdate#.xls" destination="#destFilePath#\Old\MedicaidNJ#todaysdate#.xls" >
		</cfif>
		<cfif FileExists("#destFilePath#\MedicaidNJ#todaysdate#.xls")>
			<cffile action="delete"  file="#destFilePath#\MedicaidNJ#todaysdate#.xls" >
		</cfif>		
					<cfdump var="#indays#" label="indays">
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
			
			<Worksheet ss:Name="eftpulldata">
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
							<Data ss:Type="String">TenantID</Data>
						</Cell>
					</Row>
					<cfset index = 1>
					<cfset maxlines = arraylen(indays)>

					<cfloop  condition="#index# lte #maxlines#" >
						<cfset mylist = ArrayToList(indays[index],",")>
						<cfif find(#thisTenID#,mylist) >   
							<cfset tenantID = indays[index][3]>
							<cfset startdate = indays[index][1]>
							<cfset enddate = indays[index][2]>
							<cfset totaldays = #DateDiff('d',startdate, enddate)#  +1>
							<cfquery name="qryMedicaidChg"  datasource="#APPLICATION.datasource#">
								select t.clastname as  'Lname'
								, t.cfirstname as 'Fname'
								,  t.cMiddleInitial as  'MiddleInitial' 
								,'061009175001' as  'NJHSP'
								,'HorizonNJHealth' as  'MCO'
								,'123456789111' as  'MCOID'
								,'123123123123' as  'AuthorizationNo'
								,convert(varchar(12),#startdate#, 101) as  'AuthFDOS'
								,convert(varchar(12),#enddate#, 101) as  'AuthTDOS'
								,convert(varchar(10),t.dbirthdate,101) as  'DOB'
								,'111223333' as  'SSNA'  
								,' ' as  'Sex'
								,'250' as  PICD
								,'2724' as  SICD
								,'401' as  TICD
								,convert(varchar(12),#startdate#, 101) as   'FDOS'
								,convert(varchar(12),#enddate#, 101)  as  'TDOS'
								,#totaldays# as 'Days'
								,convert(DECIMAL(19,2),hm.mStateMedicaidAmt_BSF_Daily * #totaldays#) as  'Gross'
								,convert(DECIMAL(19,2),ts.mMedicaidCopay * #totaldays#/#idaysinMonth#) as  'CostShare'
								,convert(DECIMAL(19,2),hm.mStateMedicaidAmt_BSF_Daily * #totaldays# - ts.mMedicaidCopay * #totaldays#/#idaysinMonth#) 
									as  'Net'
								,t.itenant_id
								
								from tenant t 
								join tenantstate ts on t.itenant_id = ts.itenant_id  
								join house h on t.ihouse_id = h.ihouse_id
								join HouseMedicaid hm on h.ihouse_id = hm.ihouse_id
								
								where
								t.itenant_id = #tenantID#
								and t.dtrowdeleted is null and ts.dtrowdeleted is null 
							</cfquery>
							<div>#qryMedicaidChg.itenant_id# - #tenantID#</div>
							<br />
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
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.AuthorizationNo))#</Data>
								</Cell> 					
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.AuthFDOS))#</Data>
								</Cell> 							
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.AuthTDOS))#</Data>
								</Cell> 							
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.DOB))#</Data>
								</Cell> 								
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.SSNA))#</Data>
								</Cell> 						
								<Cell>
									<Data ss:Type="Number">#XmlFormat(trim(qryMedicaidChg.Sex))#</Data>
								</Cell> 						 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.PICD))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.SICD))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="Number">#XmlFormat(trim(qryMedicaidChg.TICD))#</Data>
								</Cell> 						 
								<Cell>
									<Data ss:Type="Number">#XmlFormat(trim(qryMedicaidChg.FDOS))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.TDOS))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.Days))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.Gross))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="Number">#XmlFormat(trim(qryMedicaidChg.CostShare))#</Data>
								</Cell> 						 
								<Cell>
									<Data ss:Type="Number">#XmlFormat(trim(qryMedicaidChg.Net))#</Data>
								</Cell> 
								<Cell>
									<Data ss:Type="String">#XmlFormat(trim(qryMedicaidChg.itenant_id))#</Data>
								</Cell> 										
							</Row> 
						</cfif>  
						<cfset index = index + 1> 
	
					</cfloop> 
				</Table>
				<div>#qryMedicaidChg.itenant_id# A</div>
				<br />
			</Worksheet>
		</Workbook>
		</cfxml>
		<cfset xml = ToString(xmlDataDump)> 

		<cffile action="append" nameconflict="overwrite" file="#destFilePath#\MedicaidNJ#todaysdate#.xls"  output="#xml#"></cfoutput>  
	</cfprocessingdirective>
	
	<div>#qryMedicaidChg.itenant_id# E</div>
<dir>File Creation #destFilePath#\MedicaidNJ#todaysdate#.xls Complete</dir>
</cfoutput>
</body>
</html>
