<html>
<!--- ------------------------------------------------------------------------------------------------------------------
 106456 S Farmer 07-02-2013 Created no-pull file to check tenants that did not have valid draw amounts  -  EFT Updates |
-----------------------------------------------------------------------------------------------------------------------> 
	<cfset thisAcctPeriod = #dateformat(now(), 'yyyymm')#>
	<cfstoredproc procedure="rw.sp_EFT_NoticeXLSNoDraw" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">
		<cfprocresult NAME="getEFTPullWeek" resultset="1"> 
		<cfprocresult NAME="getEFTPullDay" resultset="2">
	
		<cfprocresult NAME="getEFTNoData" resultset="3">				
 
        <cfprocparam type="IN" value="0" DBVARNAME="@Scope"  cfsqltype="cf_sql_varchar">
        <cfprocparam type="IN" value="#thisAcctPeriod#" DBVARNAME="@AcctPeriod" cfsqltype="cf_sql_varchar">
	</cfstoredproc>

	<cfset fileerror = "N">
	<cfset batchdate = #CreateODBCDateTime(Now())#>
	<cfset todaysdate = dateformat(now(),'mmddyyyy')>
	<cfset hdrdate = dateformat(now(),'mm/dd/yy')>	
	<cfif cgi.SCRIPT_NAME is "vmappprod01dev3">
		<cfset destFilePath = "\\fs01\ALC_IT\EFTPull"> 
	<cfelse>
		<cfset destFilePath = "\\fs01\ar\Auto Withdrawal EFT\RAW EFT FILES">	
	</cfif>	
<!--- 	<cfset destFilePath = "\\fs01\ALC_IT\EFTPull">  ---> 
 	<!--- <cfset destFilePath = "\\fs01\ar\Auto Withdrawal EFT\RAW EFT FILES"> --->  
	<cfset firstrec = "Y">
	<!--- <cfset grandtotal = Numberformat(getEFTTotal.eftpulltotal,'999999.00')> --->
 <!---  --->
	<cfif FileExists("#destFilePath#\EFTNoPullFile#todaysdate#.xls")>
		<cffile   action="rename"  source="#destFilePath#\EFTNoPullFile#todaysdate#.xls" destination="#destFilePath#\Old\EFTNoPullFile#todaysdate#.xls" >
	</cfif>
	<cfif FileExists("#destFilePath#\EFTNoPullFile#todaysdate#.xls")>
		<cffile action="delete"  file="#destFilePath#\EFTNoPullFile#todaysdate#.xls" >
	</cfif>

<!---   	<cfoutput>	 	
		<cffile  action="write" nameconflict="overwrite" file="#destFilePath#\EFTPullFile#todaysdate#.xls"  
			output=" ,, Batch ,, #hdrdate#,,,#getEFTTotal.eftpulltotal#,,,," addnewline="Yes"> 	
	</cfoutput >	--->		
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
						<cfoutput>
							<Worksheet ss:Name="getEFTNoData">
								<Table>
									<Column ss:AutoFitWidth="0" ss:Width="120"  />
									<Column ss:AutoFitWidth="0" ss:Width="25"  />		
									<Column ss:AutoFitWidth="0" ss:Width="50"  />
									<Column ss:AutoFitWidth="0" ss:Width="50"  />		
									<Column ss:AutoFitWidth="0" ss:Width="50"  />
									<Column ss:AutoFitWidth="0" ss:Width="60"  />		
									<Column ss:AutoFitWidth="0" ss:Width="100"  />
									<Column ss:AutoFitWidth="0" ss:Width="75"  />		
									<Column ss:AutoFitWidth="0" ss:Width="40"  />
									<Column ss:AutoFitWidth="0" ss:Width="50"  />	
									<Column ss:AutoFitWidth="0" ss:Width="75"  />
									<Column ss:AutoFitWidth="0" ss:Width="50"  />																																									
									<Column ss:AutoFitWidth="0" ss:Width="50"  />
									<Column ss:AutoFitWidth="0" ss:Width="50"  />
									<Column ss:AutoFitWidth="0" ss:Width="50"  />
									<Column ss:AutoFitWidth="0" ss:Width="50"  />	
									<Column ss:AutoFitWidth="0" ss:Width="50"  />
									<Row>
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 										 
										<Cell>
											<Data ss:Type="String">Batch</Data>
										</Cell> 						 
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(hdrdate))#</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell>
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell>
 										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 						
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 
 										<Cell>
											<Data ss:Type="String">MoveIn</Data>
										</Cell> 						
										<Cell>
											<Data ss:Type="String">MoveOut</Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String">SolomonBalance</Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String">TIPSBalance</Data>
										</Cell> 						
										<Cell>
											<Data ss:Type="String">newEFT</Data>
										</Cell>
									</Row>
								<cfloop query="getEFTNoData">
									 <Row>
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(cTenantName))#</Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(cdeferred))#</Data>
										</Cell> 										 
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(cdocument))#</Data>
										</Cell> 						 
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(cSolomonKey))#</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(cPA))#</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(cRoutingNumber))#</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(cAccountNumber))#</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(cAccountType))#</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">No</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(dtTodaysdate))#</Data>
										</Cell> 								
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(isubacct))#</Data>
										</Cell> 						
										<Cell>
											<Data ss:Type="Number">#XmlFormat(trim(mdrawamt))#</Data>
										</Cell> 						 
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(movein))#</Data>
										</Cell>
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(moveout))#</Data>
										</Cell>
										<Cell>
											<Data ss:Type="Number">#XmlFormat(trim(SolomonBal))#</Data>
										</Cell> 						 
										<Cell>
											<Data ss:Type="Number">#XmlFormat(trim(TIPSBal))#</Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(newEFT))#</Data>
										</Cell> 
									 </Row> 
									 <cfquery name="UpdTransLog" datasource="#APPLICATION.datasource#">
									 Insert into EFTPullTransaction (
										  dtBatchDate 
										,iUser_ID 
										,cTenantName  
										,cdeferred 
										,cdocument 
										,cSolomonKey 
										,cPA 
										,cRoutingNumber 
										,cAccountNumber 
										,cAccountType 
										,cNo 
										,dtTodaysdate 
										,isubacct 
										,mdrawamt 	
										,cMoveIn 
										,cMoveOut 	
										,cNoPull
										,mSolomonBalance 	
										,mTIPSBalance 
										,cNewEFT										
										)
										values
										( #batchdate#
										,#session.UserID#
										,'#cTenantName#'
										,'#cdeferred#'
										,'#cdocument#'
										,'#cSolomonKey#'
										,'#cPA#'
										,'#cRoutingNumber#'
										,'#cAccountNumber#'
										,'#cAccountType#'										
										,'No'
										,#CreateODBCDateTime(dtTodaysdate)#
										,'#isubacct#'
										,#mdrawamt#
										,'#movein#'
										,'#moveout#'
										,'Y'
										,#SolomonBal# 	
										,#TIPSBal# 
										,'#newEFT#'
											)							 
									 </cfquery>
								</cfloop>
								</Table>
							</Worksheet>
						</cfoutput>
						</Workbook>
					</cfxml>
				 <cfset xml = ToString(xmlDataDump)> 
 			 	 <cfoutput><cffile action="append" nameconflict="overwrite" file="#destFilePath#\EFTNoPullFile#todaysdate#.xls"  output="#xml#"></cfoutput>  
	</cfprocessingdirective>
 
	<body>
	<cfinclude template="../../header.cfm">	
	<h1 class="PageTitle"> Tips 4 - EFT No Draw Amount Pull</h1>
	<cfinclude template="../Shared/HouseHeader.cfm">	

	<form name="returntosender" method="post" action="EFTPullcalendar.cfm" id="returntosender">
	<cfoutput>	
	<table>
	<tr>
		<td>EFT No Draw Pull File for Accounting Period: #thisAcctPeriod# was created in #destFilePath#\EFTNoPullFile#todaysdate#.xls</td>
	</tr>
	<tr>
		<td>Accouting Period: #getEFTPullWeek.period#</td>
	</tr>
	<tr>
		<td>First Draw Date: #dateformat(getEFTPullWeek.FirstPull, 'mm/dd/yyyy')#</td>
	</tr>	
	<tr>
		<td>Second Draw Date: #dateformat(getEFTPullWeek.SecondPull, 'mm/dd/yyyy')#</td>
	</tr>	
	<tr>
		<td>Third Draw Date: #dateformat(getEFTPullWeek.ThirdPull, 'mm/dd/yyyy')#</td>
	</tr>	
	<tr>
		<td>Fourth Draw Date: #dateformat(getEFTPullWeek.FourthPull, 'mm/dd/yyyy')#</td>
	</tr>	
	<tr>
		<td>Fifth Draw Date: #dateformat(getEFTPullWeek.FifthPull, 'mm/dd/yyyy')#</td>
	</tr>	
	<!--- <cfdump var="#getEFTPullWeek#"><br> --->
	<tr>
		<td>Previous Pull Day: #getEFTPullDay.ilastpull#</td>
	</tr>	
	<tr>
		<td>This Pull Day: #getEFTPullDay.ithispull#</td>
	</tr>		
	<tr>
		<td>Scope: #getEFTPullDay.scope#</td>
	</tr>	
	<tr>
		<td>Date of Pull: #getEFTPullDay.dateofpull#</td>
	</tr>	
	<tr>
		<td>Day of Pull: #getEFTPullDay.dayofpull#</td>
	</tr>		
	<tr>
		<td>PullWeek: #getEFTPullDay.pullweek#</td>
	</tr>	
	<tr>
		<td>Today: #dateformat(getEFTPullDay.today, 'mm/dd/yyyy')#</td>  CompareDate
	</tr>	
<!--- 	<tr>
		<td>Today: #dateformat(getEFTPullDay.InvoiceStartDate, 'mm/dd/yyyy')#</td>  
	</tr>
	<tr>
		<td>Today: #dateformat(getEFTPullDay.CompareDate, 'mm/dd/yyyy')#</td> 
	</tr> --->			
 
 	<tr>
		<td><input type="Submit" value="Return to EFT Processing Page" name="Submit"></td>
	</tr>
		
	</table>	
	</cfoutput>
	</form>	

	</body>
</html>
 
