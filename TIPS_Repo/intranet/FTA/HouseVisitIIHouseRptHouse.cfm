<cfxml variable="xmlDataDump"> 
<cfparam name="first6" default="Y">
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:html="http://www.w3.org/TR/REC-html40">
<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
  <WindowHeight>9975</WindowHeight>
  <WindowWidth>18795</WindowWidth>
  <WindowTopX>240</WindowTopX>
  <WindowTopY>270</WindowTopY>
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
	<ss:Style ss:ID="s1">
		<Alignment ss:Vertical="Top"  ss:WrapText="1"/>	
		<ss:Font ss:Bold="1"/>
	</ss:Style>
	<ss:Style ss:ID="s2">
		<Alignment ss:Vertical="Top"  ss:WrapText="1"/>	
		<ss:Font ss:Bold="1"/>
		<Interior ss:Color="Gainsboro" ss:Pattern="Solid"/>		
	</ss:Style>	
	<ss:Style ss:ID="s7">
		<Alignment ss:Vertical="Top" ss:WrapText="1"/>
		<ss:Font ss:Bold="1"/>
		<Interior ss:Color="Olivedrab" ss:Pattern="Solid"/>
	</ss:Style>
	<ss:Style ss:ID="s8">
		<Alignment ss:Vertical="Top" ss:WrapText="1"/>
		<Interior ss:Color="PaleGoldenrod" ss:Pattern="Solid"/>
	</ss:Style>
</Styles>
 
		<cfoutput>
			<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
			<cfset entrysizeArray = ArrayNew(2)>
			<cfset lb = chr(13) & chr(10)>
			<cfset old_entry = 0>
			<cfset thisHouseid = 241>
			<cfset thisThruDateF =   "2012-01-01" >
		<!--- 	<cfset dsHouseRegion = helperObj.qryHouseVisitIIRegon(26)> --->
		<!--- 	<cfset RegHouseCount =  dsHouseRegion.recordcount> ---> 
			<cfset dsHouseRegion = helperObj.FetchDashboardHouseInfo(#thisHouseid#)>
			<cfset dsGroups = helperObj.FetchHouseVisitGroupsIIRpt()>
			<cfset GroupCount = dsGroups.recordcount>
			<!--- <cfloop query="dsHouseRegion"> --->
				<cfset thishouse = thisHouseid>
				<cfset thishousename = dsHouseregion.cHouseName>
				<cfset regionid = dsHouseregion.iRegionId>
 				<cfset thisregionname = dsHouseregion.cRegionName>
				<cfset k = 0>
				<Worksheet ss:Name="#thishousename#">			 	 
					<cfset dsRegionHousesEntries = helperObj.qryHouseVisitIIRegonHouseEntry(#regionid#, #thishouse#, #thisThruDateF#)>
					<cfset itemcount =  dsRegionHousesEntries.recordcount>
					<cfset colcount =  (dsRegionHousesEntries.recordcount * 6) + 10>
					<Table>
						<Column ss:AutoFitWidth="1" ss:Width="275"  />
						<Column ss:AutoFitWidth="1" ss:Width="100" ss:Span="99"/>		
						<Row ss:AutoFitHeight="0" ss:Height="38.25" >
							<Cell ss:StyleID="s2">
								<Data ss:Type="String">House Visits Region: #thisregionname#</Data>
							</Cell>
							<cfloop  query="dsRegionHousesEntries"  >
								<cfset k = k + 1>
								<cfset thisentryid = dsRegionHousesEntries.ientryid>
								<cfset maxEntryCount = helperObj.qryHouseVisitIIEntryMax(#thisentryid#)>
								<cfset maxEntry = maxEntryCount.total>
								<cfset hdrSize = maxEntry - 1>
								<cfset dsEntryDetail = helperObj.FetchHouseVisitAnswersDetail(#thisentryid#)> 
								<cfset UserDisplayName = dsEntryDetail.cUserDisplayName>  
								<cfset dateCreated =  dsEntryDetail.dtCreated>
								<cfset role_Name =  dsEntryDetail.cRoleName>
								<cfif (k MOD 2 neq 0) >
								<Cell   ss:MergeAcross="#hdrSize#"  ss:StyleID="s8">
									<Data ss:Type="String">
									 #trim(UserDisplayName)# #dateformat(dateCreated, "mm/dd/yyyy")# #trim(role_Name)# 
									</Data>
								</Cell>
								<cfelse>
								<Cell   ss:MergeAcross="#hdrSize#">
									<Data ss:Type="String">
									 #trim(UserDisplayName)# #dateformat(dateCreated, "mm/dd/yyyy")# #trim(role_Name)# 
									</Data>
								</Cell>
								</cfif>
							</cfloop> <!--- end of  dsRegionHousesEntries --->
						</Row>				
						<cfloop query="dsGroups" > 
							<cfset thisgroup = dsGroups.iGroupId>						
							<cfset grouprole = helperObj.qryHouseVisitIIGroupRole(#thisgroup#)>
								<Row ss:AutoFitHeight="0" ss:Height="50">
									<Cell ss:StyleID="s7">
										<Data ss:Type="String">#thisgroup# - #trim(dsGroups.cTextHeader)# 
										#lb# Roles: <cfloop query="grouprole">#crolename#  </cfloop></Data>
									</Cell>
								</Row> 
							<cfset ThisIndexMax = dsGroups.IndexMax>
							<cfset dsGroupQuestionsHdr = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
							<cfset i = 0>
							<cfset j = "">
							<cfloop query="dsGroupQuestionsHdr">
								<cfset thisquestion = dsGroupQuestionsHdr.iQuestionId>
								   
								<cfset last_i = i>
								<cfset i = i + 1>
								<cfset k = 0>
								<Row ss:AutoFitHeight="0" ss:Height="38">
									<Cell  >
										<Data ss:Type="String" >#dsGroupQuestionsHdr.cQuestion#</Data>
									</Cell>
									<cfif thisentryid is not "">
										<cfset lastEntryID = thisentryid>
									</cfif>
									<cfset dsRegionHouses = helperObj.qryHouseVisitIIRegonHouseEntry(#regionid#, #thisHouse#, #thisThruDateF#)> 
									<cfloop  query="dsRegionHouses">
 
									<cfif  i is not last_i and thisEntryID is not lastEntryID>
										<cfif j lt maxEntry>
											<CFSET j = j + 1>
											<cfloop from="#j#" to="#maxEntry#"  index="#j#"> <!--- fill --->
												<cfif ((thisgroup is 1) and (thisquestion is 1))>
													<cfif (k MOD 2 neq 0) >
														<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> </Data>
														</Cell>
												<cfelseif (thisgroup is 18)  >
													   	<cfset a = 1>
												<cfelse>
													<cfif (k MOD 2 neq 0) >
														<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> </Data>
														</Cell>
													</cfif>
											</cfloop> <!--- end of fill --->
										</cfif>
									</cfif>  
									<cfset thisentryid = dsRegionHouses.ientryid>
									<cfset first6 = "Y">
									<cfset k = k + 1>
									<cfset maxEntryCount = helperObj.qryHouseVisitIIEntryMax(#thisentryid#)>
									<cfset maxEntry = maxEntryCount.total>
									<cfset dsEntryAnswers = helperObj.FetchHouseVisitAnswersIIA(#thisentryid#, #thisgroup#,#thisquestion#)> 
									<cfset j = 0>
										<cfloop query="dsEntryAnswers"> <!--- start  dsEntryAnswers --->
											 <cfset dsEntryDetail = helperObj.FetchHouseVisitAnswersDetail(#thisentryid#)> 
											 <cfset UserDisplayName = #dsEntryDetail.cUserDisplayName#>  
											 <cfset dateCreated = #dsEntryDetail.dtCreated#>
											 <cfset role_Name = #dsEntryDetail.cRoleName#>
											  <cfset j = j + 1>
												<cfswitch expression="#thisgroup#">
														<cfcase value="1">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="2">
													 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>>
														</cfcase>
														<cfcase value="3">
														 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="4">
														 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="5">
														 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="6">
													 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="7">
														 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"><cfif #trim(cEntryAnswer)# is "Y">YES	<cfelseif #trim(cEntryAnswer)# is "N">NO<cfelse>space</cfif></Data>
															</Cell>	
														</cfcase>
														<cfcase value="8">
														 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>														
														</cfcase>
														<cfcase value="9">
														<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															 <Data ss:Type="String"> #cEntryAnswer#</Data>
															 </Cell>
														</cfcase>
														<cfcase value="10">
													 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="11">
													 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="12">
														 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="13">
													 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="19">
													 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="14">
													 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="15">
													 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>	
														</cfcase>
														<cfcase value="16">
 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>	
														</cfcase>
														<cfcase value="17">
													 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>														
														</cfcase>
														<cfcase value="24">
													 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="20">
														 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="22">
													 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>
														</cfcase>
														<cfcase value="23">
												 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>													
														</cfcase>
														<cfcase value="18">
															<cfset maxEntryCount = helperObj.qryHouseVisitIIEntryMax(#thisentryid#)>
															<cfset maxEntry = maxEntryCount.total>
															<cfset hdrSize = maxEntry - 1>
													 
															<cfif (k MOD 2 neq 0) >
																<Cell ss:MergeAcross="#hdrSize#"   ss:StyleID="s8">
															<cfelse>
																<Cell ss:MergeAcross="#hdrSize#">
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell>															
														</cfcase>
														<cfdefaultcase>													 												
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #cEntryAnswer#</Data>
															</Cell
														 ></cfdefaultcase>	  	
												</cfswitch>
										</cfloop> <!--- dsEntryAnswers --->
									</cfloop> <!---  dsRegionHouses --->
								</Row>	
								</cfloop>  <!--- dsgroupquestionhdr --->	
						</cfloop> <!--- end of dsGroups --->
					</Table>
					<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
					   <Selected/>
					   <DoNotDisplayGridlines/>
					   <FreezePanes/>
					   <FrozenNoSplit/>
					   <SplitHorizontal>1</SplitHorizontal>
					   <TopRowBottomPane>1</TopRowBottomPane>
					   <SplitVertical>1</SplitVertical>
					   <LeftColumnRightPane>1</LeftColumnRightPane>	
					</WorksheetOptions>
				</Worksheet>				
		<!--- 	</cfloop> end of dsHouseRegion --->
		</cfoutput>	
</Workbook>	
</cfxml> 

<cfset xml = ToString(xmlDataDump)> 
<cffile action="write" nameconflict="overwrite" file="\\fs01\ALC_IT\temp\housevisit_house_#thishouseid#_#DateFormat(Now(),'MM-DD-YYYY')#A.xls" output="#xml#">

