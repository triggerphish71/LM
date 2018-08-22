<html> 
<!--- ------------------------------------------------------------------------------------------
 106456 S Farmer 07-02-2013 add movein and moveout to output file  -  EFT Updates              |
        T Pecku  10-19-2016 added variable to be passed to the stored Proc, modified the       |
                            SolomonBal insert to insert 0000.0000 if NULL to prevent an error, | 
                            appended the CompanyID to the excel file                           |
| Mshah 01/26/2017 Added FHLMC enhancement						       |
-----------------------------------------------------------------------------------------------> 
	
	<cfset thisAcctPeriod = #dateformat(now(), 'yyyymm')#>


<!---Mshah Added if condition for key bank file--->
     
	<cfif structKeyExists(url, 'ccompanyID') and #trim(url.ccompanyID)# neq "">
     <cfset CompanyID =#URL.cCompanyID#>
    	<cfstoredproc procedure="rw.sp_EFT_NoticeXLS2" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">
			<cfprocresult NAME="getEFTPullWeek" resultset="1"> 
			<cfprocresult NAME="getEFTPullDay" resultset="2">
			<cfprocresult NAME="getEFTData" resultset="3">
			<cfprocresult NAME="getEFTTotal" resultset="4">	
			<!--- <cfprocresult NAME="getEFTNoData" resultset="5"> --->			
	 
	        <cfprocparam type="IN" value="0" DBVARNAME="@Scope"  cfsqltype="cf_sql_varchar">
	        <cfprocparam type="IN" value="201807" DBVARNAME="@AcctPeriod" cfsqltype="cf_sql_varchar">
	        <cfprocparam type="IN" value="0000" DBVARNAME="@CompanyID" cfsqltype="cf_sql_varchar">
		</cfstoredproc>
	<cfelse>
		<cfstoredproc procedure="rw.sp_EFT_NoticeXLS2_FHLMC" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">
			<cfprocresult NAME="getEFTPullWeek" resultset="1"> 
			<cfprocresult NAME="getEFTPullDay" resultset="2">
			<cfprocresult NAME="getEFTData" resultset="3">
			<cfprocresult NAME="getEFTTotal" resultset="4">	
		    <cfprocparam type="IN" value="0" DBVARNAME="@Scope"  cfsqltype="cf_sql_varchar">
		    <cfprocparam type="IN" value="#thisAcctPeriod#" DBVARNAME="@AcctPeriod" cfsqltype="cf_sql_varchar">
		</cfstoredproc>

	</cfif>


	<cfset fileerror = "N">
	<cfset batchdate = #CreateODBCDateTime(Now())#>
	<cfset todaysdate = dateformat(now(),'mmddyyyy')>
	<cfset hdrdate = dateformat(now(),'mm/dd/yy')>	
	<cfif cgi.SERVER_NAME is "littlemuddy">
		<cfset destFilePath = "\\fs01\ALC_IT\EFTPull"> 
	<cfelse>
		<cfset destFilePath = "\\fs01\ar\Auto Withdrawal EFT\RAW EFT FILES">	
	</cfif>	
	<!--- <cfset destFilePath = "\\fs01\ALC_IT\EFTPull">  ---> 
 	<!--- <cfset destFilePath = "\\fs01\ar\Auto Withdrawal EFT\2012\RAW EFT files"> --->  
	<cfset firstrec = "Y">
	<cfset grandtotal = Numberformat(getEFTTotal.eftpulltotal,'999999.00')>


<!---- begin test
	
<cfoutput>
<Table>
<TR>	
	<TH>
		Tenant Name
	</TH> 
	<TH>
		cDeferred
	</TH> 										 
	<TH>
		Batch
	</TH> 						 
	<TH>
		Solomon Key
	</TH> 					
	<TH>
		< ss:Type="String">#XmlFormat(trim(hdrdate))#</>
	</TH> 							
	<TH>
		Routing Number	
	</TH> 
	<TH>
		Account Number
	</TH> 					
	<TH>
		< ss:Type="String">#XmlFormat(trim(grandtotal))#</>
	</TH>
	<TH>
		< ss:Type="String"></>
	</TH> 							
	<TH>
		< ss:Type="String"></>
	</TH>
		<TH>
		< ss:Type="String"></>
	</TH> 						
	<TH>
		< ss:Type="String"></>
	</TH> 
	<TH>
		< ss:Type="String">MoveIn</>
	</TH> 						
	<TH>
		< ss:Type="String">MoveOut</>
	</TH> 
	<TH>
		< ss:Type="String">SolomonBalance</>
	</TH> 
	<TH>
		< ss:Type="String">TIPSBalance</>
	</TH> 						
	<TH>
		< ss:Type="String">newEFT</>
	</TH> 
</TR>>
<cfloop query="getEFTData">
	 <TR>
		<TD>
			#XmlFormat(trim(cTenantName))#
		</TD> 
		<TD>
			#XmlFormat(trim(cdeferred))#
		</TD> 										 
		<TD>
			#XmlFormat(trim(cdocument))#
		</TD> 						 
		<TD>
			>#XmlFormat(trim(cSolomonKey))#
		</TD> 					
		<TD>
			#XmlFormat(trim(cPA))#
		</TD> 					
		<TD>
		#XmlFormat(trim(cRoutingNumber))#
		</TD> 							
		<TD>
			#XmlFormat(trim(cAccountNumber))#
		</TD> 					
		<TD>
			#XmlFormat(trim(cAccountType))#
		</TD> 							
		<TD>
			No
		</TD> 							
		<TD>
			#XmlFormat(trim(dtTodaysdate))#
		</TD> 								
		<TD>
			#XmlFormat(trim(isubacct))#
		</TD> 						
		<TD>
			#XmlFormat(trim(mdrawamt))#
		</TD> 						 
		<TD>
			>#XmlFormat(trim(movein))#
		</TD> 
		<TD>
			#XmlFormat(trim(moveout))#
		</TD> 
		<TD>
			#XmlFormat(trim(SolomonBal))#
		</TD> 						 
		<TD>
			#XmlFormat(trim(TIPSBal))#
		</TD> 
		<TD>
			#XmlFormat(trim(newEFT))#
		</TD> 
	 </TR> 									 
</cfloop>
</Table>
						
</cfoutput>
					
<cfabort>

 ---->



<!---- end test ---->







 <!---Mshah start--->	
<cfif structKeyExists(url, 'ccompanyID') and #trim(url.ccompanyID)# neq "">	
	<!--- TPecku appended the CompanyID to the excel file   --->
		<cfif FileExists("#destFilePath#\EFTPullFile-#CompanyID#-#todaysdate#.xls")>
			<cffile   action="rename"  source="#destFilePath#\EFTPullFile-#CompanyID#-#todaysdate#.xls" destination="#destFilePath#\Old\EFTPullFile-#CompanyID#-#todaysdate#.xls" >
		</cfif>
		<cfif FileExists("#destFilePath#\EFTPullFile-#CompanyID#-#todaysdate#.xls")>
			<cffile action="delete"  file="#destFilePath#\EFTPullFile-#CompanyID#-#todaysdate#.xls" >
		</cfif>
<cfelse>
		<cfif FileExists("#destFilePath#\EFTPullFile-FHLMC-#todaysdate#.xls")>
		<cffile   action="rename"  source="#destFilePath#\EFTPullFile-FHLMC-#todaysdate#.xls" destination="#destFilePath#\Old\EFTPullFile-FHLMC-#todaysdate#.xls" >
		</cfif>
		<cfif FileExists("#destFilePath#\EFTPullFile-FHLMC-#todaysdate#.xls")>
		<cffile action="delete"  file="#destFilePath#\EFTPullFile-FHLMC-#todaysdate#.xls" >
		</cfif>
</cfif>
<!---Mshah end--->

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
							<Worksheet ss:Name="eftpulldata">
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
									<TR>
										<TH>
											< ss:Type="String"></>
										</TH> 
										<TH>
											< ss:Type="String"></>
										</TH> 										 
										<TH>
											< ss:Type="String">Batch</>
										</TH> 						 
										<TH>
											< ss:Type="String"></>
										</TH> 					
										<TH>
											< ss:Type="String">#XmlFormat(trim(hdrdate))#</>
										</TH> 							
										<TH>
											< ss:Type="String"></>
										</TH> 
										<TH>
											< ss:Type="String"></>
										</TH> 					
										<TH>
											< ss:Type="String">#XmlFormat(trim(grandtotal))#</>
										</TH>
										<TH>
											< ss:Type="String"></>
										</TH> 							
										<TH>
											< ss:Type="String"></>
										</TH>
 										<TH>
											< ss:Type="String"></>
										</TH> 						
										<TH>
											< ss:Type="String"></>
										</TH> 
										<TH>
											< ss:Type="String">MoveIn</>
										</TH> 						
										<TH>
											< ss:Type="String">MoveOut</>
										</TH> 
										<TH>
											< ss:Type="String">SolomonBalance</>
										</TH> 
										<TH>
											< ss:Type="String">TIPSBalance</>
										</TH> 						
										<TH>
											< ss:Type="String">newEFT</>
										</TH> 
									</TR>
								<cfloop query="getEFTData">
									 <TR>
										<TH>
											< ss:Type="String">#XmlFormat(trim(cTenantName))#</>
										</TH> 
										<TH>
											< ss:Type="String">#XmlFormat(trim(cdeferred))#</>
										</TH> 										 
										<TH>
											< ss:Type="String">#XmlFormat(trim(cdocument))#</>
										</TH> 						 
										<TH>
											< ss:Type="String">#XmlFormat(trim(cSolomonKey))#</>
										</TH> 					
										<TH>
											< ss:Type="String">#XmlFormat(trim(cPA))#</>
										</TH> 					
										<TH>
											< ss:Type="String">#XmlFormat(trim(cRoutingNumber))#</>
										</TH> 							
										<TH>
											< ss:Type="String">#XmlFormat(trim(cAccountNumber))#</>
										</TH> 					
										<TH>
											< ss:Type="String">#XmlFormat(trim(cAccountType))#</>
										</TH> 							
										<TH>
											< ss:Type="String">No</>
										</TH> 							
										<TH>
											< ss:Type="String">#XmlFormat(trim(dtTodaysdate))#</>
										</TH> 								
										<TH>
											< ss:Type="String">#XmlFormat(trim(isubacct))#</>
										</TH> 						
										<TH>
											< ss:Type="Number">#XmlFormat(trim(mdrawamt))#</>
										</TH> 						 
										<TH>
											< ss:Type="String">#XmlFormat(trim(movein))#</>
										</TH> 
										<TH>
											< ss:Type="String">#XmlFormat(trim(moveout))#</>
										</TH> 
										<TH>
											< ss:Type="Number">#XmlFormat(trim(SolomonBal))#</>
										</TH> 						 
										<TH>
											< ss:Type="Number">#XmlFormat(trim(TIPSBal))#</>
										</TH> 
										<TH>
											< ss:Type="String">#XmlFormat(trim(newEFT))#</>
										</TH> 
									 </TR> 
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
										,mSolomonBalance 	
										,mTIPSBalance 
										,cnewEFT 										
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
										<cfif IsNull(SolomonBal)>
										,0000.0000
                                         <cfelse>
                                        ,#SolomonBal#
                                         </cfif> 	
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
 			 	 <!--- MShah added here cfif TPecku appended the CompanyID to the excel file   --->
				 <cfif structKeyExists(url, 'ccompanyID') and #trim(url.ccompanyID)# neq "">	
				 		<cfoutput><cffile action="append" nameconflict="overwrite" file="#destFilePath#\EFTPullFile-#CompanyID#-#todaysdate#.xls"  output="#xml#"></cfoutput>  
				 <cfelse>
				 		<cfoutput><cffile action="append" nameconflict="overwrite" file="#destFilePath#\EFTPullFile-FHLMC-#todaysdate#.xls"  output="#xml#"></cfoutput> 
				 </cfif>
				 <!---Mshah end--->

	</cfprocessingdirective>
 
	<body>
	<cfinclude template="../../header.cfm">	
	<h1 class="PageTitle"> Tips 4 - EFT Pull</h1>
	<cfinclude template="../Shared/HouseHeader.cfm">	

	<form name="returntosender" method="post" action="EFTPullcalendar.cfm" id="returntosender">
	<cfoutput>
	<table>
	<tr>
		<!---Mshah start--->
	<cfif structKeyExists(url, 'ccompanyID') and #trim(url.ccompanyID)# neq "">	
		<td>EFT Pull File #CompanyID# for Accounting Period: #thisAcctPeriod# was created in #destFilePath#\EFTPullFile-#CompanyID#-#todaysdate#.xls</td>
	<cfelse>
		<td>EFT Pull File FHLMC for Accounting Period: #thisAcctPeriod# was created in #destFilePath#\EFTPullFile-FHLMC-#todaysdate#.xls</td>		
	</cfif>	
	<!---Mshah--->	
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
	<tr>
		<td>Today: #dateformat(getEFTPullDay.InvoiceStartDate, 'mm/dd/yyyy')#</td>  
	</tr>
	<tr>
		<td>Today: #dateformat(getEFTPullDay.CompareDate, 'mm/dd/yyyy')#</td> 
	</tr>			
 	<tr>
		<td><input type="submit" value="Return to EFT Home Page" name="Submit"></td>
	</tr>
		
	</table>	
	</cfoutput>
	</form>

	</body>
</html>
 
