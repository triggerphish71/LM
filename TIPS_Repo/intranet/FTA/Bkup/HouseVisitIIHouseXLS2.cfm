<!--- HouseVisitIIHouseXLS.cfm extracts the house visit reports placing each house in a file. --->
<cfsetting requesttimeout="13000">
<cftry>
<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
<cfset thisThruDateF = DateFormat(Dateadd('d',-90, now()), "yyyy-mm-dd")>
<cfprocessingdirective    suppressWhiteSpace = "yes">
<cfset dsAnswers = helperObj.FetchHouseVisitIIQueryAnswers(2)>
<cfset dsHouseList = helperObj.qryHouseVisitIIHouseListA(2)>		
<cfloop query="dsHouseList">
	<cfset thishouseid = dsHouseList.iHouseId>
	<cfset thishouse = dsHouseList.iHouseid> 
	<cfset thishousename = dsHouseList.cHouseName>
	<cfset thisrptname = replace(dsHouseList.cHouseName, " ", "_", "ALL")>
	<cfxml variable="xmlDataDump"> 
	<cfparam name="first6" default="Y">
	<cfparam name="thisentryid" default="">
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
				<Interior ss:Color="Palegoldenrod" ss:Pattern="Solid"/>
			</ss:Style>
		</Styles>
		<cfoutput>
			<cfset old_entry = 0>
			<!--- <cfset RegHouseCount =  dsHouseRegion.recordcount> --->  
			<cfset dsHouseRegion = helperObj.qryHouseVisitIIHouseRegion(#thisHouseid#)> 
			<cfset regionid = dsHouseregion.iRegionId>
			<cfset thisregionname = dsHouseregion.cRegionName>			
			<cfset dsGroups = helperObj.FetchHouseVisitGroupsIIRpt()>
			<cfset GroupCount = dsGroups.recordcount>
			<cfloop query="dsHouseRegion"> 
				<cfset k = 0>
				<Worksheet ss:Name="#thishousename#">			 	 
					<cfset dsRegionHousesEntries = helperObj.qryHouseVisitIIRegonHouseEntry(#regionid#, #thishouseid#, #thisThruDateF#)>
					<cfset itemcount =  dsRegionHousesEntries.recordcount>
					<cfset colcount =  (dsRegionHousesEntries.recordcount * 6) + 10>
					<Table>
						<Column ss:AutoFitWidth="1" ss:Width="275"  />
						<Column ss:AutoFitWidth="1" ss:Width="100" ss:Span="250"/>		
						<Row ss:AutoFitHeight="0" ss:Height="38.25" >
							<Cell ss:StyleID="s2">
								<Data ss:Type="String">House Visits House: #XmlFormat(trim(thishousename))#, Region: #XmlFormat(Trim(thisregionname))#  Thru Date: #XmlFormat(thisThruDateF)#</Data>
							</Cell>
							<cfloop  query="dsRegionHousesEntries"  >
								<cfset k = k + 1>
								<cfset thisentryid = dsRegionHousesEntries.ientryid>
								<cfset maxEntryCount = helperObj.qryHouseVisitIIEntryMax(#thisentryid#)>
								<cfset maxEntry = maxEntryCount.total>
								<cfif IsNumeric(maxEntry)>
									<cfset hdrSize = maxEntry - 1>
								<cfelse>
									<cfset hdrSize =  1>
									<cfset maxEntry = 1>
								</cfif>
									<cfif hdrSize lte 3>
										<cfset hdrSize = 3>
										<cfset maxEntry = 4>
									</cfif>
								<!--- <cfset hdrSize = maxEntry - 1> --->
								<cfset dsEntryDetail = helperObj.FetchHouseVisitAnswersDetail(#thisentryid#)> 
								<cfset UserDisplayName = dsEntryDetail.cUserDisplayName>  
								<cfset dateCreated =  dsEntryDetail.dtCreated>
								<cfset role_Name =  dsEntryDetail.cRoleName>
								<cfif (k MOD 2 neq 0) >
								<Cell   ss:MergeAcross="#hdrSize#"  ss:StyleID="s8">
									<Data ss:Type="String">
									#XmlFormat(trim(UserDisplayName))# #dateformat(dateCreated, "mm/dd/yyyy")# #XmlFormat(trim(role_Name))# 
									</Data>
								</Cell>
								<cfelse>
								<Cell   ss:MergeAcross="#hdrSize#">
									<Data ss:Type="String">
									#XmlFormat(trim(UserDisplayName))# #dateformat(dateCreated, "mm/dd/yyyy")# #XmlFormat(trim(role_Name))# 
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
										<Data ss:Type="String">#thisgroup# - #trim(dsGroups.cTextHeader)#, 
										 Roles: <cfloop query="grouprole">#trim(crolename)#  </cfloop></Data>
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
									<cfswitch expression="#thisgroup#">
										<cfcase value="6">
											<Row ss:AutoFitHeight="0" ss:Height="75">
										</cfcase>
										<cfcase value="8">
											<Row ss:AutoFitHeight="0" ss:Height="50">
										</cfcase>		
										<cfcase value="18">
											<Row ss:AutoFitHeight="0" ss:Height="100">
										</cfcase>																	
										<cfdefaultcase>													 												
											<Row ss:AutoFitHeight="0" ss:Height="38">
										</cfdefaultcase>	  	
									</cfswitch>
									<Cell  >
										<Data ss:Type="String" >#dsGroupQuestionsHdr.cQuestion#</Data>
									</Cell>
									<cfif thisentryid is not "">
										<cfset lastEntryID = thisentryid>
									</cfif>
									<cfset dsRegionHouses = helperObj.qryHouseVisitIIRegonHouseEntry(#regionid#, #thisHouseid#, #thisThruDateF#)> 
									<cfloop  query="dsRegionHouses">
 
									<cfif  i is not last_i and thisEntryID is not lastEntryID>
										<cfif j lt maxEntry>
											<CFSET j = j + 1>
											<cfloop from="#j#" to="#maxEntry#"  index="n"> <!--- fill --->
												<cfif ((thisgroup is 1) and (thisquestion is 1))>
													<cfif (k MOD 2 neq 0) >
														<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> </Data>
														</Cell>
													<cfelseif (thisgroup is 18)>
															<cfset a = 1>
													<cfelseif (thisgroup is 2)>
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
									<cfif IsNumeric(maxEntry)>
										<cfset hdrSize = maxEntry - 1>
									<cfelse>
										<cfset hdrSize =  1>
										<cfset maxEntry = 1>
									</cfif>
									<cfif hdrSize lte 3>
										<cfset hdrSize = 3>
										<cfset maxEntry = 4>
									</cfif>
									<!--- <cfset dsEntryAnswers = helperObj.FetchHouseVisitAnswersIIA(#thisentryid#, #thisgroup#,#thisquestion#)> ---> 
									<cfset dsEntryAnswers = helperObj.FetchHouseVisitIIQAnswers(#thisentryid#, #thisgroup#,#thisquestion#, #dsAnswers#)>
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
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
															<cfcase value="2">
																<cfif j is 1>
																	<cfset maxEntryCount = helperObj.qryHouseVisitIIEntryMax(#thisentryid#)>
																	<cfset maxEntry = maxEntryCount.total>
																	<cfif IsNumeric(maxEntry)>
																		<cfset hdrSize = maxEntry - 1>
																	<cfelse>
																		<cfset hdrSize =  1>
																		<cfset maxEntry = 1>
																	</cfif>
																	<cfif hdrSize lte 3>
																		<cfset hdrSize = 3>
																		<cfset maxEntry = 4>
																	</cfif>
																	<cfset thisroomlist = helperObj.qryHouseVisitIIEmptyRm(#thisentryid#)>
																	<cfif (k MOD 2 neq 0) >
																		<Cell  ss:MergeAcross="#hdrSize#"  ss:StyleID="s8">
																	<cfelse>
																		<Cell  ss:MergeAcross="#hdrSize#">
																	</cfif>
																	<Data ss:Type="String">#XmlFormat(Trim(thisroomlist))#</Data>
																	</Cell> 
																</cfif>	
															<cfset j = hdrsize>	
															</cfcase>
														<cfcase value="3">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
														<cfcase value="4">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"> #XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
														<cfcase value="5">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
														<cfcase value="6">
																																															
															 
																<cfif (k MOD 2 neq 0) >
																	<Cell ss:MergeAcross="1"   ss:StyleID="s8">
																<cfelse>
																	<Cell  ss:MergeAcross="1" >
																</cfif>
																		<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
																	</Cell>
																<cfset j = j + 1>
														</cfcase>
														<cfcase value="7">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String"><cfif #trim(cEntryAnswer)# is "Y">YES	<cfelseif #trim(cEntryAnswer)# is "N">NO<cfelse> </cfif></Data>
															</Cell>	
														</cfcase>
														<cfcase value="8">

															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>														
														</cfcase>
														<cfcase value="9">
														<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															 <Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															 </Cell>
														</cfcase>
														<cfcase value="10">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
														<cfcase value="11">
 
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
														<cfcase value="12">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
														<cfcase value="13">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
														<cfcase value="19">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
														<cfcase value="14">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
														<cfcase value="15">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>	
														</cfcase>
														<cfcase value="16">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>	
														</cfcase>
														<cfcase value="17">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>														
														</cfcase>
														<cfcase value="24">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
														<cfcase value="20">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
														<cfcase value="22">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfcase>
														<cfcase value="23">
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>													
														</cfcase>
															<cfcase value="18">
 
																<cfset maxEntryCount = helperObj.qryHouseVisitIIEntryMax(#thisentryid#)>
																<cfset maxEntry = maxEntryCount.total>
																<cfif IsNumeric(maxEntry)>
																	<cfset hdrSize = maxEntry - 1>
																<cfelse>
																	<cfset hdrSize =  1>
																	<cfset maxEntry = 1>
																</cfif>
																<cfif hdrSize lte 3>
																	<cfset hdrSize = 3>
																	<cfset maxEntry = 4>
																</cfif>
																<cfif (k MOD 2 neq 0) >
																	<Cell ss:MergeAcross="#hdrSize#"   ss:StyleID="s8">
																<cfelse>
																	<Cell ss:MergeAcross="#hdrSize#">
																</cfif>
																		<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
																	</Cell>															
															</cfcase>
														<cfdefaultcase>													 												
															<cfif (k MOD 2 neq 0) >
																<Cell   ss:StyleID="s8">
															<cfelse>
																<Cell>
															</cfif>
															<Data ss:Type="String">#XmlFormat(Trim(cEntryAnswer))#</Data>
															</Cell>
														</cfdefaultcase>	  	
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
	   	</cfloop> 
		</cfoutput>	
</Workbook>	
</cfxml> 
<cfset xml = ToString(xmlDataDump)> 
<cfoutput>
	<cffile action="write" nameconflict="overwrite" file="\\fs01\ALC_IT\HouseVisit\House\#thisrptname#_housevisit.xls" output="#xml#"> 
	<!--- File #thisrptname#_housevisit.xls created.<br/> --->
</cfoutput>
</cfloop> <!--- dsHouseList --->
</cfprocessingdirective>
	<cfcatch type="any">
		<cfmail to="sfarmer@alcco.com" from="FTA_HouseVisit_House_XLS.cfm@alcco.com" subject="House Visit House Div 2 XLS failed" type="html">
			Detail: #cfcatch.Detail#<br><br>
			Message: #cfcatch.Message#<br><br>
			Exception Type: #cfcatch.Type#<br><br>
		</cfmail>
	</cfcatch>
</cftry>