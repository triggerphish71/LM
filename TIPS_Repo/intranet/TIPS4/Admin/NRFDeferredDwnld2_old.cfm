<html>
<cfset destFilePath = "\\fs01\ALC_IT\NRFDeferred\">	
<cfset filename = "NRFDeferreddata">
<cfquery name="qryNRFData" datasource="#application.datasource#">
		select
		t.itenant_id 
		,t.csolomonkey 
		,t.cfirstname
		, t.clastname
		, h.cname as housename
		, h.iOpsArea_ID 
		,OPSA.cName	as 'OPSname'
		,OPSA.iRegion_ID
		,reg.cName	as 'Regionname'			
		,convert(varchar, HL.dtCurrentTipsMonth, 126)	as dtCurrentTipsMonth	
		,cast(cast(ts.mBaseNRF as decimal(10,2)) as varchar(10))  as 'BaseNRF'
		,cast(cast((ts.mAdjNRF - ts.mBaseNRF) as decimal(10,2)) as varchar(10))  as 'AdjNRF'
		,cast(cast(abs(rc.mAmount) as decimal(10,2)) as varchar(10))  as 'DeferredNRF'  
		,rc.cdescription
		,ts.cNRFAdjApprovedBy
		,convert(varchar, rc.dtRowStart, 101) as dtRowStart
		,convert(varchar, rc.dtEffectiveStart, 101) as dtEffectiveStart
		,convert(varchar, rc.dtEffectiveEnd, 101) as dtEffectiveEnd
		,rc.dtRowDeleted
		,datediff(m,HL.dtCurrentTipsMonth ,rc.dtEffectiveEnd  ) as 'paymentrem'
 		,datediff(m,rc.dtEffectiveStart,rc.dtEffectiveEnd) + 1 as 'nbrpaymnt'  
		from tenant t
		join tenantstate ts on t.itenant_id = ts.itenant_id
		join house h on t.ihouse_id = h.ihouse_id
		join dbo.OpsArea OPSA on OPSA.iOpsArea_ID  = h.iOpsArea_ID
		join dbo.Region reg on reg.iRegion_ID = OPSA.iRegion_ID
		join dbo.RecurringCharge RC on RC.iTenant_ID = t.iTenant_ID 
		JOIN HouseLog HL ON h.iHouse_ID = HL.iHouse_Id
		join charges chg on chg.iCharge_ID = RC.iCharge_ID and chg.ichargetype_id = 1740
 
		where ts.bIsNRFDeferred = 1
		  and   rc.dtEffectiveEnd >= getdate() 
		  AND rc.mAmount  <> 0
		order by OPSA.iRegion_ID,h.iOpsArea_ID,housename,t.itenant_id,rc.dtRowStart
</cfquery>


	<cfset fileerror = "N">
	<cfset todaysdate = dateformat(now(),'mmddyyyy')>
	<cfset hdrdate = dateformat(now(),'mm/dd/yy')>	
 
	<!--- 	<cfset destFilePath = "\\fs01\ar\Auto Withdrawal EFT\2012\RAW EFT files">	  --->
<!--- 	<cfset firstrec = "Y">
	<cfset grandtotal = Numberformat(getEFTTotal.eftpulltotal,'999999.00')> --->
 
	<cfif FileExists("#destFilePath#\NRFDeferreddata.xls")>
		<cffile   action="rename"  source="#destFilePath#\NRFDeferreddata.xls" destination="#destFilePath#\Old\NRFDeferreddata.xls" >
	</cfif>
	<cfif FileExists("#destFilePath#\NRFDeferreddata.xls")>
		<cffile action="delete"  file="#destFilePath#\NRFDeferreddata.xls" >
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
			  <Style ss:ID="Default" ss:Name="Normal">
			   <Alignment ss:Vertical="Bottom"/>
			   <Borders/>
			   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
			   <Interior/>
			   <NumberFormat/>
			   <Protection/>
			  </Style>		
			<Style  ss:ID="s62" ss:name="Normal">
				<Alignment ss:Vertical="Top" ss:WrapText="1"/>
				<Borders/>
				<Font/>
				<Interior/>
				<NumberFormat/>
				<Protection/>
			</Style>
			<Style ss:ID="s63">
				<Alignment ss:Horizontal="Right" ss:Vertical="Top" ss:WrapText="1"/>
				<Borders/>
				<Font ss:FontName="Arial"/>
				<Interior/>
				<NumberFormat/>
				<Protection/>
			</Style>			
		</Styles>		
						<cfoutput>
							<Worksheet ss:Name="NRFData">
								<Table>
									<Column ss:StyleID="s63" ss:AutoFitWidth="0" ss:Width="50"  /> <!--- A --->
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="125" /> <!--- B --->	
									<Column ss:StyleID="s63" ss:AutoFitWidth="0" ss:Width="60"  /> <!--- C --->
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="150" /> <!--- D --->	
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="175" /> <!--- E --->
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="150" /> <!--- F --->		
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="100" /> <!--- G --->
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="200" /> <!--- H --->		
									<Column ss:StyleID="s63" ss:AutoFitWidth="0" ss:Width="50"  /> <!--- I --->	
									<Column ss:StyleID="s63" ss:AutoFitWidth="0" ss:Width="75"  /> <!--- J --->
									<Column ss:StyleID="s63" ss:AutoFitWidth="0" ss:Width="100" /> <!--- K --->																																								
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="150" /> <!--- L --->
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="100" /> <!--- M --->	
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="75"  /> <!--- N --->
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="100" /> <!--- O --->		
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="100" /> <!--- P --->
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="100" /> <!--- Q --->		
									<Column ss:StyleID="s62" ss:AutoFitWidth="0" ss:Width="100" /> <!--- R --->
									<Column ss:StyleID="s63" ss:AutoFitWidth="0" ss:Width="125" /> <!--- S --->		
									<Column ss:StyleID="s63" ss:AutoFitWidth="0" ss:Width="75"  /> <!--- T --->
									<Column ss:StyleID="s63" ss:AutoFitWidth="0" ss:Width="50"  /> <!--- U --->	
 

									<Row>
										<Cell>
											<Data ss:Type="String">Region ID</Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String">Region Name</Data>
										</Cell> 										 
										<Cell>
											<Data ss:Type="String">OPS Area ID</Data>
										</Cell> 						 
										<Cell>
											<Data ss:Type="String">OPS Area Name</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">House</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">Solomon Key</Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String">Tenant First Name</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">Tenant Last Name</Data>
										</Cell>
										<Cell>
											<Data ss:Type="String">Base NRF</Data>
										</Cell>
 										<Cell>
											<Data ss:Type="String">Adjusted NRF</Data>
										</Cell> 						
										<Cell>
											<Data ss:Type="String">NRF Installment Amt</Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String">Charge Description</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">NRF Adj Approved By</Data>
										</Cell>
										<Cell>
											<Data ss:Type="String">Date Entered</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">Installment Start Date</Data>
										</Cell>
 										<Cell>
											<Data ss:Type="String">Installment End Date</Data>
										</Cell> 						
										<Cell>
											<Data ss:Type="String">Number Payments</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">Payments Remaining</Data>
										</Cell>
										<Cell>
											<Data ss:Type="String">Monthly Payment Amt</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">Accum</Data>
										</Cell>
 										<Cell>
											<Data ss:Type="String">Rem Bal</Data>
										</Cell> 						
									</Row>
 								<cfset totalBaseNRF = 0>
								<cfset totalAdjNRF = 0>
								<cfset totalDeferredNRF = 0>
								<cfset totalmonthlypayment = 0>
								<cfset totalAccum= 0>
								<cfset totalrembal= 0>
								<cfloop query="qryNRFData">
									<cfset monthlypayment =  numberformat(((qryNRFData.DeferredNRF/qryNRFData.nbrpaymnt) * -1),'999999.00')>
									<cfset Accum = numberformat((monthlypayment * qryNRFData.paymentrem),'999999.00')>
									<cfset rembal = numberformat((qryNRFData.DeferredNRF + Accum),'999999.00')>
									<cfset totalBaseNRF = totalBaseNRF + BaseNRF>
									<cfset totalAdjNRF = totalAdjNRF + AdjNRF>							
									<cfset totalDeferredNRF = totalDeferredNRF + DeferredNRF>
									<cfset totalmonthlypayment = totalmonthlypayment + monthlypayment>	
									<cfset totalAccum = totalAccum + Accum>
									<cfset totalrembal = totalrembal+ rembal>	
									 <Row>
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(iRegion_ID))#</Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(Regionname))#</Data>
										</Cell> 										 
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(iOpsArea_ID))#</Data>
										</Cell> 						 
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(OPSname))#</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(housename))#</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(csolomonkey))#</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(cfirstname))#</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(clastname))#</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(BaseNRF))#</Data>
										</Cell> 								
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(AdjNRF))#</Data>
										</Cell> 						
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(DeferredNRF))#</Data>
										</Cell> 						 
 										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(cdescription))#</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(cNRFAdjApprovedBy))#</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(dtRowStart))#</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(dtEffectiveStart))#</Data>
										</Cell> 								
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(dtEffectiveEnd))#</Data>
										</Cell> 						
										<Cell>
											<Data ss:Type="Number">#XmlFormat(trim(nbrpaymnt))#</Data>
										</Cell> 
										<Cell>
											<Data ss:Type="Number">#XmlFormat(trim(paymentrem))#</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(monthlypayment))#</Data>
										</Cell> 								
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(Accum))#</Data>
										</Cell> 						
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(rembal))#</Data>
										</Cell>
									 </Row> 
								</cfloop>
									<cfset totalBaseNRF = NUMBERFORMAT(totalBaseNRF, "999999.00")>
									<cfset totalAdjNRF = NUMBERFORMAT(totalAdjNRF, "999999.00")>							
									<cfset totalDeferredNRF = NUMBERFORMAT(totalDeferredNRF, "999999.00")>
									<cfset totalmonthlypayment = NUMBERFORMAT(totalmonthlypayment, "999999.00")>	
									<cfset totalAccum = NUMBERFORMAT(totalAccum, "999999.00")>
									<cfset totalrembal = NUMBERFORMAT(totalrembal, "999999.00")>
									 <Row>
										<Cell>
											<Data ss:Type="String">Totals:</Data>
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
											<Data ss:Type="String">#XmlFormat(trim(TotalBaseNRF))#</Data>
										</Cell> 								
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(TotalAdjNRF))#</Data>
										</Cell> 						
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(TotalDeferredNRF))#</Data>
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
											<Data ss:Type="Number"></Data>
										</Cell> 
										<Cell>
											<Data ss:Type="Number"></Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(Totalmonthlypayment))#</Data>
										</Cell> 								
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(TotalAccum))#</Data>
										</Cell> 						
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(Totalrembal))#</Data>
										</Cell>
									 </Row>
								</Table>
							</Worksheet>
						</cfoutput>
						</Workbook>
					</cfxml>
				 <cfset xml = ToString(xmlDataDump)> 
 			 	 <cfoutput><cffile action="append" nameconflict="overwrite" file="#destFilePath#\NRFDeferreddata.xls"  output="#xml#"></cfoutput>  
	</cfprocessingdirective>
 
	<body>
	<cfinclude template="../../header.cfm">	
	<h1 class="PageTitle"> Tips 4 - NRF Installment Summary</h1>
	<cfinclude template="../Shared/HouseHeader.cfm">	
	<cfoutput>
	<table>
	<tr>
		<td colspan="2">NRF Installment File  was created in #destFilePath#\NRFDeferreddata.xls</td>
	</tr>
 
 <tr>
 <td>Total Base NRF: </td><TD>#totalBaseNRF#</td>
 </tr>
 <tr>
 <td>Total Adj NRF:</td><TD> #totalAdjNRF#</td>
 </tr>
 <tr>
 <td>Total NRF Instalment:</td><TD> #totalDeferredNRF#</td>
 </tr>
 <tr>
 <td>Total monthly payment:</td><TD> #totalmonthlypayment#</td>
 </tr>
 <tr>
 <td>Total Accum:</td><TD> #totalAccum#</td>
 </tr>
 <tr>
 <td>Total rembal:</td><TD> #totalrembal#</td>
 </tr>     
	</table>	
	</cfoutput>
	</body>
</html>
