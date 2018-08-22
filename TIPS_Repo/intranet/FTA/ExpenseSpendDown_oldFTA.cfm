                                                                                                                                                     <cfset page = "Expense SpendDown">
<cfset Page = "Expense Spend Down">
<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
		<head>
			<title>
				Online FTA- #page#
			</title>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
			<cfheader name='expires' value='#Now()#'> 
			<cfheader name='pragma' value='no-cache'>
			<cfheader name='cache-control' value='no-cache,no-store, must-revalidate'>
			<link rel="Stylesheet" href="CSS/ExpenseSpendDown.css" type="text/css">

			<!--- Instantiate the Helper object. --->
			<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
			
			<cfif isDefined("url.ccllcHouse")>
				<cfset ccllcHouse = #url.ccllcHouse#>
			<cfelse> <cfset ccllcHouse = 0>
			</cfif>

			<cfif isDefined("url.iHouse_ID")>
				<cfset houseId = #url.iHouse_ID#>
			</cfif>
			
			<cfif isDefined("url.SubAccount")>
				<cfset subAccount = #url.SubAccount#>
							
				<cfset dsHouseInfo = #helperObj.FetchHouseInfo(subAccount)#>
				<cfset unitId = #dsHouseInfo.unitId#>
				<cfset houseId = #dsHouseInfo.iHouse_ID#>
				<cfset HouseNumber = #trim(dsHouseInfo.EHSIFacilityID)#>
			</cfif>
	
			<cfinclude template="Common/DateToUse.cfm">
			
			<SCRIPT language="javascript">
				var minTableHeight = 510;
				var overrideTableHeight = false;
				var tableHeightPct = 100;
				if (#currentd# < 12)
				{
					overrideTableHeight = true;
					minTableHeight = (#currentd# * 24) + 244;
					tableHeightPct = (tableHeightPct - 12) + #currentd#;
				}
			
				var aw = screen.availWidth;
				var ah = screen.availHeight;
				window.moveTo(0, 0);
				window.resizeTo(aw, ah);
			        
			 	function doSel(obj)
			 	{
			 	    for (i = 1; i < obj.length; i++)
			   	    	if (obj[i].selected == true)
			           		eval(obj[i].value);
			 	}
			 	function showHideRow(iRow)
			 	{
			 		var collapsedImg = "Images/caretlightblue.png";
			 		var expandedImg = "Images/caretpeach.png";
			 		
			 		var row = document.getElementById("DrillDown_" + iRow);
			 		row.style.display = (((row.style.display == null) || (row.style.display == "block")) ? "none" : "block");
			
			 		var img = document.getElementById("imgDrillDown_" + iRow);
			 		img.src = ((row.style.display == "none") ? collapsedImg : expandedImg);
				 
			 	}
			 	function getFooterTop()
				{
					if (document.getElementById("tbl-container").scrollWidth > document.getElementById("tbl-container").offsetWidth)
						return (document.getElementById("tbl-container").scrollTop + document.getElementById("tbl-container").offsetHeight - document.getElementById("tbl-container").scrollHeight - 16);
					else
						return (document.getElementById("tbl-container").scrollTop + document.getElementById("tbl-container").offsetHeight - document.getElementById("tbl-container").scrollHeight);			
				}
				function getReportTableHeight()
				{
					var tableHeight = screen.availHeight - 240;
					
					if (overrideTableHeight == false)
					{
						if (tableHeight > minTableHeight)
						{
							return (tableHeight);
						}
						else 
						{
							return (minTableHeight);
						}
					}
					else
					{
						return (minTableHeight);
					}
				}
				function getReportTablePct()
				{
					return ((tableHeightPct) + "%");
				}
			</SCRIPT>
		</head>
</cfoutput>


<!--- Initialize the Color fields. --->
<cfset columnHeaderCellColor1 = "##0066CC">
<cfset columnHeaderCellColor2 = "##0066CC">
<cfset budgetcellcolor = "##ffff99">
<cfset actualCellColor = "79bcff">
<cfset varianceCellColor = "b0ffff">
<cfset secondaryCellColor = "f4f4f4">


<!--- Display the toolbar and month selection. --->
<cfoutput>
	<body>
		<cfinclude template="DisplayFiles/Header.cfm">
		<!--- Initialize all of the required fields. --->
<cfset dsColumns = #helperObj.FetchColumns()#>
<cfset columnCount = #dsColumns.recordcount#>
<cfset dsBudgetSummary = #helperObj.FetchBudgetSummary(houseId, currenty, monthforqueries)#>
<cfset dsActualDetails = #helperObj.FetchActualDetails(houseId, PtoPFormat, FromDate, ThruDate)#>
<cfset dsActualSummary = #helperObj.FetchActualSummary(houseId, PtoPFormat, FromDate, ThruDate, dsActualDetails)#>
<cfset dsDssiInvoices = #helperObj.FetchDssiInvoices(ThruDate, houseId)#>

<cfif ccllcHouse is 1>
	<BR>
	<BR>
	There is no Expense Data to display.
	<cfexit method="exittemplate">
<cfelse>
	<cfif dsActualDetails.RecordCount is "0" or dsBudgetSummary.RecordCount is "0">
		There is no Expense Data for the current period.
		<cfexit method="exittemplate">
	</cfif>
	<cfset dsCensusDetails = #helperObj.FetchCensusDetails(houseId, FromDate, ThruDate)#>
	<cfset foodBudgetAccumulator = #helperObj.FetchFoodBudgetAccumulator(houseId, currenty, monthforqueries)#>
	<cfset dailyCensusBudget = #helperObj.FetchDailyCensusBudget(houseId, currenty, monthforqueries)#>
	<cfset censusBudgetDim = #dailyCensusBudget# * #currentdim#>
	<cfset totalColCount = #columncount# + 5>
	<cfset dsExpenseCategoryGlCodes = #helperObj.FetchAllExpenseCategoryGLCodes()#>
			<font face="arial">
				<p>
				<font size=-1>
					Click on any Day's blue arrow to view Invoice Details for that Day. &##160;
					<label id="lblExportToExcel" style="cursor: hand; color: blue; text-decoration: underline; font-family: verdana; font-size: 8pt" 
					onClick="javascript:window.open('ExpenseSpendDown_ExcelExport.cfm?iHouse_ID=#houseID#&SubAccount=#subAccount#&DateToUse=#dateToUse#');">
						Export to Excel Spreadsheet <img title="Export to Excel" src="Images/ExcelBig.bmp" height="30px" width="30px" />
					</label>	
				</font>
				<BR>
				<BR>
</cfif>				
</cfoutput>
<cfif ccllcHouse is 0>
	<cfoutput>
		<div id="tbl-container">
			<table id="tbl" cellspacing="0" cellpadding="1" border="1px">
				<thead>
					<tr>
						<th class="locked" colspan="3" align="Left" bgcolor="#budgetCellColor#">
							<font size=-1 color="Black">
								Food Budget Managed by a PRD of:
							</font>
						</th>
						<th class="locked" colspan="1" align="Middle" bgcolor="#budgetCellColor#">
							<font size=-1 color="Black">
								#helperObj.GetNumberFormat(foodBudgetAccumulator, true)#
							</font>
						</th>
						<th align="Left" colspan="#columnCount + 1#" bgcolor="#secondaryCellColor#">
							<font size=-2 style="font-family: Verdana;" color="Black" bgcolor="White">
								- Place cursor over category to display GL accounts included in category.
							</font>
						</th>
					</tr>
					<!--- COLUMN HEADERS --->
					<tr>
						<th class="locked" align="middle" colspan=1 bgcolor="f4f4f4">
							DAY
						</th>
						<th bgcolor="#columnHeaderCellColor1#" align="middle"><font size=-1 color="White">
							Budget<br />Census
						</th>
						<th bgcolor="#columnHeaderCellColor1#" align="middle"><font size=-1 color="White">
							Actual<br />Census
						</th>
								
						<th bgcolor="#columnHeaderCellColor1#"  
								style="border-top-style: solid; border-top-width: 2px; border-top-color: Black; border-left-style: solid; border-left-width: 2px; border-left-color: Black;"
								align="middle"><font size=-1 color="White">
							Food Daily<br />Budget
						</th>
						<cfset runOnce4Food = true>
						<cfloop query="dsColumns">
							<cfset glCodeList = "">
							<cfset dsCurrentCategoryGlCodes = #helperObj.FetchSingleExpenseCategoryGLCodes(dsExpenseCategoryGlCodes, dsColumns.iExpenseCategory_ID)#>
							<cfloop query="dsCurrentCategoryGlCodes">
								<cfset glCodeList = #glCodeList# & 
										#dsCurrentCategoryGLCodes.cGlCode# & " - " &
										#dsCurrentCategoryGLCodes.cGlCodeDesc# & 
										Chr(13) & Chr(10)>
							</cfloop>
							<cfif runOnce4Food eq true>
								<th colspan=1 title="#glCodeList#" 
										style="border-top-style: solid; border-top-width: 2px; border-top-color: Black; border-right-style: solid; border-right-width: 2px; border-right-color: Black;"
										bgcolor="#columnHeaderCellColor2#" align="middle">
									<label>	
										<font size=-1 color="White">
											#dsColumns.vcDisplayName#
										</font>
									</label>
								</th>						
								<cfset runOnce4Food = false>
							<cfelse>
								<th colspan=1 title="#glCodeList#" bgcolor="#columnHeaderCellColor2#" align="middle">
									<label>	
										<font size=-1 color="White">
											#dsColumns.vcDisplayName#
										</font>
									</label>
								</th>
							</cfif>
						</cfloop>
						<th bgcolor="#columnHeaderCellColor2#" align="middle"><font size=-1 color="White">
							Total
						</th>
					</tr>
				</thead>
				
				<tbody>	
					<!--- Occupancy and Census Accumulators.  --->
					<cfset censusBudgetMtd = 0>
					<cfset censusMtd = 0>
				
					<!--- CURRENT DAY'S ACTUALS (INCLUDING FOOD BUDGET) --->
					<cfloop from="1" to="#currentd#" index="currentMtdDay">
						
						<cfset currentMtdDayDrillDown = #helperObj.FetchActualsDrillDown(dsActualDetails, currentMtdDay)#>
						
						<tr>
							<cfset MtdDayActuals = #helperObj.FetchActualSummaryMtdDay(dsActualSummary, currentMtdDay)#>
							<td class="locked" align="middle" colspan=1 bgcolor="f4f4f4">
								<table width="100%">
									<tr>
										<td width="50%" align="left">
											<cfif currentMtdDayDrillDown.RecordCount Is Not "0">
												<cfset imageId = "imgDrillDown_" & #currentMtdDay#>
												<img id="#imageId#" onClick="showHideRow('#currentMtdDay#');" src="Images/caretlightblue.png" style="cursor:hand;" border=0>
											</cfif>
										</td>
										<td align="left">
											<font size=-1 color="Black">
												#currentMtdDay# 
											</font>
										</td>
									</tr>
								</table>
							</td>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1 color="Black">
									#helperObj.GetNumberFormat(dailyCensusBudget, false)#
									<cfset censusBudgetMtd = #censusBudgetMtd# + #dailyCensusBudget#>
								</font>
							</td>
							<td align="right" colspan=1 bgcolor="White">
								<font size=-1 color="Black">
									<cfset currentCensus = #helperObj.FetchTenantsForDay(dsCensusDetails, currentMtdDay)#>
									#helperObj.GetNumberFormat(currentCensus, false)#
									<cfset censusMtd = #censusMtd# + #currentCensus#>
								</font>
							</td>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#"
								style="border-left-style: solid; border-left-width: 2px; border-left-color: Black;">
								<font size=-1 color="Black">
									#helperObj.GetNumberFormat(currentCensus * foodBudgetAccumulator, true)#
								</font>
							</td>		
							<cfset runOnce4Food = true>
							<cfset actualDailyTotal = 0>
							<cfloop query="MtdDayActuals">
								<cfif runOnce4Food eq true>
									<td align="right" colspan=1 bgcolor="White"
										style="border-right-style: solid; border-right-width: 2px; border-right-color: Black;">
										<font size=-1 color="Black">
											#helperObj.GetNumberFormat(MtdDayActuals.mAmount, true)#
											<cfset actualDailyTotal = #actualDailyTotal# + #MtdDayActuals.mAmount#>
										</font>
									</td>								
									<cfset runOnce4Food = false>
								<cfelse>
									<td align="right" colspan=1 bgcolor="White">
										<font size=-1 color="Black">
											#helperObj.GetNumberFormat(MtdDayActuals.mAmount, true)#
											<cfset actualDailyTotal = #actualDailyTotal# + #MtdDayActuals.mAmount#>
										</font>
									</td>
								</cfif>
							</cfloop>	
							<td align="right" colspan=1 bgcolor="White">
								<font size=-1 color="Black">
									#helperObj.GetNumberFormat(actualDailyTotal, true)#
								</font>
							</td>		
						</tr>		
						<cfset drillDownColSpan = #totalColCount# - 1>
						<!--- CURRENT DAYS INVOICE DRILL DOWN --->
						<cfif currentMtdDayDrillDown.RecordCount IS NOT "0">
							<cfset rowId = "DrillDown_" & #currentMtdDay#>
							<cfset columnA = "##FFE7CE">
							<cfset columnB = "##FFFFE8">
			
							<tr id="#rowId#" style="display:none;">
								<td class="locked" colspan="1" bgcolor="f4f4f4">
									&##160;
								</td>
								<td align="left" colspan="#drillDownColSpan#">
									<table cellpaddding="5px" cellspacing="0" style="border-style: solid; border-width: 1px; border-color: Black">
										<tr style="text-decoration: underline; font-weight: bold;">
											<td align="Middle" bgcolor="#columnA#" class="bottomBorder">
												<font size=-1>
													Category
												</font>
											</td>
											<td align="Middle" bgcolor="#columnB#" class="bottomBorder">
												<font size=-1>
													Doc ID
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnA#" class="bottomBorder">
												<font size=-1>
													Check 
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnB#" class="bottomBorder">
												<font size=-1>
													Vendor Name
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnA#" class="bottomBorder">
												<font size=-1>
													Vendor ID 
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnB#" class="bottomBorder">
												<font size=-1>
													Invoice 
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnA#" class="bottomBorder">
												<font size=-1>
													Inv. Date
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnB#" class="bottomBorder">
												<font size=-1>
													GL Acct.
												</font>
											</td>										
											<td align="Middle" bgcolor="#columnA#" class="bottomBorder">
												<font size=-1>
													Amount
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnB#" class="bottomBorder">
												<font size=-1>
													Processed?
												</font>
											</td>		
										</tr>
										
										<cfset categoryInvoiceTotal = 0>
										<cfset lastInvoiceCategoryId = 0>
										<cfloop query="currentMtdDayDrillDown">
											<cfif lastInvoiceCategoryId neq 0 And lastInvoiceCategoryId neq currentMtdDayDrillDown.iExpenseCategoryId>
												<!--- Display the Category's Sub-Total row --->
												<tr>
													<td align="Right" bgcolor="#columnA#" class="bottomBorder">
														<font size=-1>
															<strong>
																#helperObj.GetNumberFormat(categoryInvoiceTotal, true)#
															</strong>
														</font>
													</td>
													<td align="Middle" bgcolor="#columnB#" class="bottomBorder">
														<font size=-1>
															&##160;
														</font>
													</td>		
													<td align="Middle" bgcolor="#columnA#" class="bottomBorder">
														<font size=-1>
															&##160;
														</font>
													</td>		
													<td align="Middle" bgcolor="#columnB#" class="bottomBorder">
														<font size=-1>
															&##160;
														</font>
													</td>		
													<td align="Middle" bgcolor="#columnA#" class="bottomBorder">
														<font size=-1>
															&##160;
														</font>
													</td>		
													<td align="Middle" bgcolor="#columnB#" class="bottomBorder">
														<font size=-1>
															&##160;
														</font>
													</td>		
													<td align="Middle" bgcolor="#columnA#" class="bottomBorder">
														<font size=-1>
															&##160;
														</font>
													</td>		
													<td align="Middle" bgcolor="#columnB#" class="bottomBorder">
														<font size=-1>
															&##160;
														</font>
													</td>										
													<td align="Right" bgcolor="#columnA#" class="bottomBorder">
														<font size=-1>
															<strong>
																#helperObj.GetNumberFormat(categoryInvoiceTotal, true)#
															</strong>
														</font>
													</td>		
													<td align="Middle" bgcolor="#columnB#" class="bottomBorder">
														<font size=-1>
															&##160;
														</font>
													</td>		
												</tr>
												
												<cfset categoryInvoiceTotal = 0>
											</cfif>
											
											<cfset categoryInvoiceTotal = #categoryInvoiceTotal# + #currentMtdDayDrillDown.mAmount#>
											<cfset lastInvoiceCategoryId = #currentMtdDayDrillDown.iExpenseCategoryId#>
											
											<tr>
												<td align="Middle" bgcolor="#columnA#">
													<font size=-1>
														#currentMtdDayDrillDown.cExpenseCategory#
													</font>
													
												</td>
												<td align="Middle" bgcolor="#columnB#">
													<cfif currentMtdDayDrillDown.cDocLinkImage neq "">
														<cfset docLinkImagePath = #currentMtdDayDrillDown.cDocLinkRoot# & "\" & 
																	#mid(currentMtdDayDrillDown.cDocLinkImage, 1, 3)# & "\" &
																	#mid(currentMtdDayDrillDown.cDocLinkImage, 4, 3)# & "\" &
																	#currentMtdDayDrillDown.cDocLinkImage#>
														<cfset docLinkImagePath = Replace(docLinkImagePath, "\", "%5C", "all")>
														<label style="cursor: hand;" onClick="window.open('http://cf01/intranet/doclink/Image.cfm?ImagePath=#docLinkImagePath#')">
															<font style="text-decoration: underline; color: blue" size=-1>
																#currentMtdDayDrillDown.cDocLinkId#
															</font>
														</label>
													<cfelseif currentMtdDayDrillDown.bIsDSSI eq true>
														<cfif helperObj.DoesDssiInvoiceExist(dsDssiInvoices, Trim(currentMtdDayDrillDown.cInvoiceNumber)) eq true>
															<label style="cursor: hand;" onClick="window.open('DssiInvoiceViewer.cfm?Invoice=#rTrim(currentMtdDayDrillDown.cInvoiceNumber)#&HouseId=#houseId#');">
																<font title="Click to display DSSI Invoice." style="text-decoration: underline; color: blue" size=-1>
																	DSSI
																</font>
															</label>
														</cfif>
													<cfelse>
														<label>
															<font size=-1>
																&##160;
															</font>
														</label>
													</cfif>
												</td>		
												<td align="Middle" bgcolor="#columnA#">
													<cfif currentMtdDayDrillDown.cCheckImage neq "">
														<cfset checkImagePath = #currentMtdDayDrillDown.cDocLinkRoot# & "\" & 
																	#mid(currentMtdDayDrillDown.cCheckImage, 1, 3)# & "\" &
																	#mid(currentMtdDayDrillDown.cCheckImage, 4, 3)# & "\" &
																	#currentMtdDayDrillDown.cCheckImage#>
														<cfset checkImagePath = Replace(checkImagePath, "\", "%5C", "all")>
														<label style="cursor: hand;" onClick="window.open('http://cf01/intranet/doclink/Image.cfm?ImagePath=#checkImagePath#')">
															<font style="text-decoration: underline; color: blue" size=-1>
																#currentMtdDayDrillDown.cCheckNumber#
															</font>
														</label>
													<cfelse>
														<label>
															<font style="color: blue" size=-1>
																#currentMtdDayDrillDown.cCheckNumber#
															</font>
														</label>
													</cfif>
												</td>		
												<td align="Middle" bgcolor="#columnB#">
													<font size=-1>
														#currentMtdDayDrillDown.cVendorName#
													</font>
												</td>		
												<td align="Middle" bgcolor="#columnA#">
													<font size=-1>
														#currentMtdDayDrillDown.cVendorId#
													</font>
												</td>		
												<td align="Middle" bgcolor="#columnB#">
													<font size=-1>
														#currentMtdDayDrillDown.cInvoiceNumber#
													</font>
												</td>		
												<td align="Middle" bgcolor="#columnA#">
													<font size=-1>
														#DateFormat(currentMtdDayDrillDown.dtInvoice, "MM/DD/YYYY")#
													</font>
												</td>		
												<td align="Middle" bgcolor="#columnB#">
													<font size=-1>
														<cfset glInvoiceDesc = #currentMtdDayDrillDown.cGlCode# & ' ' & #currentMtdDayDrillDown.cGlCodeDesc#>
														#glInvoiceDesc#
													</font>
												</td>										
												<td align="Right" bgcolor="#columnA#">
													<font size=-1>
														#helperObj.GetNumberFormat(currentMtdDayDrillDown.mAmount, true)#
													</font>
												</td>		
												<td align="Middle" bgcolor="#columnB#">
													<font size=-1>
														<cfif currentMtdDayDrillDown.bIsProcessed eq true>
															<img src="Images/checkmark3.gif" alt="Yes">
														<cfelse>
															&##160;
														</cfif>
													</font>
												</td>		
											</tr>
										</cfloop>
										<!--- Display the Last Category's Sub-Total row --->
										<tr style="font-weight: bold;">
											<td align="Right" bgcolor="#columnA#">
												<font size=-1>
													#helperObj.GetNumberFormat(categoryInvoiceTotal, true)#
												</font>
											</td>
											<td align="Middle" bgcolor="#columnB#">
												<font size=-1>
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnA#">
												<font size=-1>
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnB#">
												<font size=-1>
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnA#">
												<font size=-1>
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnB#">
												<font size=-1>
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnA#">
												<font size=-1>
												</font>
											</td>		
												<td align="Middle" bgcolor="#columnB#">
												<font size=-1>
												</font>
											</td>										
											<td align="Right" bgcolor="#columnA#">
												<font size=-1>
													#helperObj.GetNumberFormat(categoryInvoiceTotal, true)#
												</font>
											</td>		
											<td align="Middle" bgcolor="#columnB#">
												<font size=-1>
												</font>
											</td>		
										</tr>
											
										<cfset categoryInvoiceTotal = 0>	
									</table>
								</td>
							</tr>
						<cfelse>
							<tr style="display:none;">
								<td class="locked" colspan="1" bgcolor="f4f4f4">
								</td>
								<td align="left" colspan="#drillDownColSpan#">
								</td>
							</tr>
						</cfif>
						
					</cfloop>
				</tbody>
				<tfoot>
					
					<!--- MTD ACTUALS --->
					<tr>
						<cfset MtdActuals = #helperObj.FetchActualSummaryMtd(dsActualSummary)#>
						<td class="locked" align="middle" colspan=1 bgcolor="#actualCellColor#">
							<font size=-1 color="Black">
								MTD Total
							</font>
						</td>
						<td align="right" colspan=2 bgcolor="#actualCellColor#">
							<font size=-1 color="Black">
								#helperObj.GetNumberFormat(censusMtd, false)#
							</font>
						</td>
						<cfset actualTotal = 0>
						<cfset actualCounter = 0>
						<cfloop query="MtdActuals">
							<cfif actualCounter eq 0>
								<td align="right" colspan=2 bgcolor="#actualCellColor#">
									<font size=-1 color="Black">
										#helperObj.GetNumberFormat(MtdActuals.mAmount, true)#
									</font>
								</td>
							<cfelse>
								<td align="right" colspan=1 bgcolor="#actualCellColor#">
									<font size=-1 color="Black">
										#helperObj.GetNumberFormat(MtdActuals.mAmount, true)#
									</font>
								</td>
							</cfif>
							<cfset actualTotal = #actualTotal# + #MtdActuals.mAmount#>
							<cfset actualCounter = #actualCounter# + 1>
						</cfloop>	
						<td align="right" colspan=1 bgcolor="#actualCellColor#">
							<font size=-1 color="Black">
								#helperObj.GetNumberFormat(actualTotal, true)#
							</font>
						</td>		
					</tr>		
					
					<!--- MTD BUDGET --->
					<tr>
						<td class="locked" align="middle" colspan=1 bgcolor="#budgetCellColor#">
							<font size=-1 color="Black">
								MTD Budget
							</font>
						</td>
						<td align="right" colspan=2 bgcolor="#budgetCellColor#">
							<font size=-1 color="Black">
								#helperObj.GetNumberFormat(censusBudgetMtd, false)#
							</font>
						</td>
						<cfset budgetTotal = 0>
						<cfset budgetCounter = 0>
						<cfloop query="dsBudgetSummary">
							<cfif budgetCounter eq 0>
								<td align="right" colspan=2 bgcolor="#budgetCellColor#">
									<font size=-1 color="Black">
										#helperObj.GetNumberFormat(censusMtd * foodBudgetAccumulator, true)#
										<cfset budgetTotal = #budgetTotal# + (#censusMtd# * #foodBudgetAccumulator#)>
									</font>
								</td>
							<cfelse>
								<td align="right" colspan=1 bgcolor="#budgetCellColor#">
									<font size=-1 color="Black">
										<cfset currentBudgetMtdDay = ((#dsBudgetSummary.mAmount# / #currentdim#) * #currentd#)>
										#helperObj.GetNumberFormat(currentBudgetMtdDay, true)#
										<cfset budgetTotal = #budgetTotal# + #currentBudgetMtdDay#>
									</font>
								</td>
							</cfif>
							<cfset budgetCounter = #budgetCounter# + 1>
						</cfloop>	
						<td align="right" colspan=1 bgcolor="#budgetCellColor#">
							<font size=-1 color="Black">
								#helperObj.GetNumberFormat(budgetTotal, true)#
							</font>
						</td>		
					</tr>	
					
					<!--- MTD VARIANCE --->
					<tr>
						<td class="locked" align="middle" colspan=1 bgcolor="#varianceCellColor#">
							<font size=-1 style="font-family: Arial Narrow;" color="Black">
								MTD Variance
							</font>
						</td>
						<td align="right" colspan=2 bgcolor="#varianceCellColor#">
							<font size=-1 color="Black">
								#helperObj.GetNumberFormat(censusMtd - censusBudgetMtd, false)#
							</font>
						</td>
						<cfset varianceTotal = 0>
						<cfset varianceCounter = 0>
						<cfloop query="MtdActuals">
							<cfset currentVarianceAmount = 0>
							<cfloop query="dsBudgetSummary">
								<cfif MtdActuals.iSortOrder[MtdActuals.CurrentRow] eq dsBudgetSummary.iSortOrder>
									<cfif currentd lt currentDim>
										<cfset currentBudgetMtdDay = ((#dsBudgetSummary.mAmount# / #currentdim#) * #currentd#)>
									<cfelse>
										<cfset currentBudgetMtdDay = #dsBudgetSummary.mAmount#>
									</cfif>
									<cfset currentVarianceAmount = #currentBudgetMtdDay# - #MtdActuals.mAmount[MtdActuals.CurrentRow]#>
									<cfif varianceCounter eq 0>
										<td align="right" colspan=2 bgcolor="#varianceCellColor#">
											<font size=-1 color="Black">
												<cfset currentVarianceAmount = (#censusMtd# * #foodBudgetAccumulator#) - #MtdActuals.mAmount[MtdActuals.CurrentRow]#>
												#helperObj.GetNumberFormat(currentVarianceAmount, true)#
											</font>
										</td>
									<cfelse>
										<td align="right" colspan=1 bgcolor="#varianceCellColor#">
											<font size=-1 color="Black">
												#helperObj.GetNumberFormat(currentVarianceAmount, true)#
											</font>
										</td>
									</cfif>
									<cfbreak>
								</cfif>
							</cfloop>
							<cfset varianceTotal = #varianceTotal# + #currentVarianceAmount#>
							<cfset varianceCounter = #varianceCounter# + 1>
						</cfloop>	
						<td align="right" colspan=1 bgcolor="#varianceCellColor#">
							<font size=-1 color="Black">
								#helperObj.GetNumberFormat(varianceTotal, true)#
							</font>
						</td>		
					</tr>	
	
					<!--- only show MONTH (JAN, FEB, etc...) BUDGET & VARIANCE, if the current day is less than days in the month. --->
					<cfif currentd lt currentdim>
						<tr><td colspan="totalColCount" height="6px"></tr>
						<tr>
							<td class="locked" align="middle" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1 color="Black">
									#UCase(monthforqueries)# Budget
								</font>
							</td>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1 color="Black">
									#helperObj.GetNumberFormat(censusBudgetDim, false)#
								</font>
							</td>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1 color="Black">
									<cfset censusDim = ((#currentDim# - #currentD#) * (#currentCensus#)) + #censusMtd#>
									#helperObj.GetNumberFormat(censusDim, false)#
								</font>
							</td>
							<cfset budgetTotal = 0>
							<cfset budgetCounter = 0>
							<cfloop query="dsBudgetSummary">
								<cfif budgetCounter eq 0>
									<td align="right" colspan=2 bgcolor="#budgetCellColor#">
										<font size=-1 color="Black">
											#helperObj.GetNumberFormat(censusDim * foodBudgetAccumulator, true)#
											<cfset budgetTotal = #budgetTotal# + (#censusDim# * #foodBudgetAccumulator#)>
										</font>
									</td>
								<cfelse>
									<td align="right" colspan=1 bgcolor="#budgetCellColor#">
										<font size=-1 color="Black">
											#helperObj.GetNumberFormat(dsBudgetSummary.mAmount, true)#
											<cfset budgetTotal = #budgetTotal# + #dsBudgetSummary.mAmount#>
										</font>
									</td>
								</cfif>
								<cfset budgetCounter = #budgetCounter# + 1>
							</cfloop>	
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1 color="Black">
									#helperObj.GetNumberFormat(budgetTotal, true)#
								</font>
							</td>		
						</tr>	
						
						<!--- MONTH Variance (example: FEB Variance)  --->
						<tr>
							<td class="locked" align="middle" colspan=1 bgcolor="#varianceCellColor#">
								<font size=-1 style="font-family: Arial Narrow;" color="Black">
									#UCase(monthforqueries)# Variance
								</font>
							</td>
							<td align="right" colspan=2 bgcolor="#varianceCellColor#">
								<font size=-1 color="Black">
									#helperObj.GetNumberFormat(censusDim - censusBudgetDim, false)#
								</font>
							</td>
							<cfset varianceTotal = 0>
							<cfset varianceCounter = 0>
							<cfloop query="MtdActuals">
								<cfset currentVarianceAmount = 0>
								<cfloop query="dsBudgetSummary">
									<cfif MtdActuals.iSortOrder[MtdActuals.CurrentRow] eq dsBudgetSummary.iSortOrder>
										<cfset currentVarianceAmount = #dsBudgetSummary.mAmount# - #MtdActuals.mAmount[MtdActuals.CurrentRow]#>
										<cfif varianceCounter eq 0>
											<td align="right" colspan=2 bgcolor="#varianceCellColor#">
												<font size=-1 color="Black">
													<cfset currentVarianceAmount = (#censusDim# * #foodBudgetAccumulator#) - #MtdActuals.mAmount[MtdActuals.CurrentRow]#>
													#helperObj.GetNumberFormat(currentVarianceAmount, true)#
												</font>
											</td>
										<cfelse>
											<td align="right" colspan=1 bgcolor="#varianceCellColor#">
												<font size=-1 color="Black">
													#helperObj.GetNumberFormat(currentVarianceAmount, true)#
												</font>
											</td>
										</cfif>
										<cfbreak>
									</cfif>
								</cfloop>
								<cfset varianceTotal = #varianceTotal# + #currentVarianceAmount#>
								<cfset varianceCounter = #varianceCounter# + 1>
							</cfloop>	
							<td align="right" colspan=1 bgcolor="#varianceCellColor#">
								<font size=-1 color="Black">
									#helperObj.GetNumberFormat(varianceTotal, true)#
								</font>
							</td>		
						</tr>	
					</cfif>
				</tfoot>
			</table>
		</div>
		<script language="javascript" type="text/javascript">
			// Redraws the DIV, becuase IE sometimes does not draw it correctly when the page loads.
			document.getElementById("tbl-container").style.display = 'none';
			document.getElementById("tbl-container").style.display = 'block';
		</script>
</cfoutput>
</cfif>	
</body>
</html>
<!---  --->
