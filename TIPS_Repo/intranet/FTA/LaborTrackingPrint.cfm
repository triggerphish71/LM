<!----------------------------------------------------------------------------------------------
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| bkubly     | 03/27/2009 | Developed Labor Tracking Page.					                   |
----------------------------------------------------------------------------------------------->

<cfoutput>

	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
		<head>
			<title>
				Online FTA- Labor Tracking Print
			</title>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
			<cfheader name='expires' value='#Now()#'> 
			<cfheader name='pragma' value='no-cache'>
			<cfheader name='cache-control' value='no-cache,no-store, must-revalidate'>
			<!--- Instantiate the Helper object. --->
			<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
			
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
</cfoutput>
	

<!--- ------------------------------------------------------------ --->	
<!--- Setup the Color variables. --->
<cfset headerCellColor = "##0066CC">
<cfset totalCellColor="##9CCDCD">
<cfset varianceCellColor = "##ccffff">
<cfset budgetCellColor = "##ffff99">
<cfset emptyCellColor = "f4f4f4">

<!--- Setup the Query variables. --->
<cfset dsLaborTrackingHours = #helperObj.FetchLaborHours(houseId, PtoPFormat)#>
<cfset dsLaborTrackingCategories = #helperObj.FetchLaborTrackingCategories()#>
<cfset dsCensusDetails = #helperObj.FetchCensusDetails(houseId, FromDate, ThruDate)#>

<cfoutput>
	<body>
			<div id="tbl-container">
				<table id="tbl" cellspacing="0" cellpadding="1" border="1px">
					<thead>
						<tr>
</cfoutput>

<!------------------------- COLUMN HEADERS - ROW 1 ------------------------->
<cfoutput>
	<th class="locked" colspan=1 bgcolor="#headerCellColor#">
		&##160;
	</th>
	<cfloop query="dsLaborTrackingCategories">
		<!--- The Nursing Sub-Total columns will be placed before kitchen services. --->
		<cfif cLaborTrackingCategory is "Kitchen">
			<th bgcolor="#headerCellColor#" colspan=3>
				<font size=-1 color="white">
					Nursing Totals
				</font>
			</th>	
		</cfif>
		<!---- Check if the category is Nursing ---->
		<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN" or cLaborTrackingCategory is "Kitchen">
			<!--- Kitchen Services does NOT report "Other" Hours. --->
			<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">	
				<th bgcolor="#headerCellColor#" colspan=3>
			<cfelse>
				<th bgcolor="#headerCellColor#" colspan=2>
			</cfif>
			<font size=-1 color="white">
				#cDisplayName# Hours
			</font>
			</th>
		<cfelse>
			<th bgcolor="#headerCellColor#">
				<font size=-1 color="white">
					#cDisplayName# Hours
				</font>
			</th>
		</cfif>
		<!--- Check if the current category was training and insert the total and variances columns. --->
		<cfif bIsTraining eq true>
			<th bgcolor="#headerCellColor#">
				<font size=-1 color="white">
					Total
				</font>
			</th>
			<th bgcolor="#headerCellColor#">
				<font size=-2 color="white">
					Daily Hours Variance
				</font>
			</th>
		</cfif>
	</cfloop>
</cfoutput>

</tr>
<!------------------------- COLUMN HEADERS - ROW 2 ------------------------->
<tr>
<cfoutput>
	<th class="locked" bgcolor="#emptyCellColor#" align=center>
		&##160;
	</th>
	<cfloop query="dsLaborTrackingCategories">
		<!--- Add the Nursing Sub-Total Column Headers. --->
		<cfif cLaborTrackingCategory is "Kitchen">
			<th bgcolor="#emptyCellColor#" colspan=3 align=center>
				<font size=-2>
					SUB-TOTALS
				</font>
			</th>
		</cfif>
		
		<!--- Check if the current Category is NURSING. --->
		<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN" or cLaborTrackingCategory is "Kitchen">
			<!--- Kitchen Services does NOT report "Other" Hours. --->
			<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">
				<th bgcolor="#emptyCellColor#" colspan=3 align=center>
					<font size=-2>
						HOURS WORKED
					</font>
				</th>
			<cfelse>
				<th bgcolor="#emptyCellColor#" colspan=2 align=center>
					<font size=-2>
						HOURS WORKED
					</font>
				</th>
			</cfif>
		<cfelse>
			<th colspan=1 bgcolor="#emptyCellColor#" align=center>
				<font size=-1>
					&##160;
				</font>
			</th>
		</cfif>
	</cfloop>
	<th bgcolor="#emptyCellColor#">
		&##160;
	</th>
	<th bgcolor="#emptyCellColor#">
		&##160;
	</th>
</cfoutput>
</tr>

<!------------------------- COLUMN HEADERS - ROW 3 ------------------------->
<tr>
<cfoutput>
	<th class="locked" bgcolor="#emptyCellColor#" align="center">
		<font size=-1>
			DAY
		</font>
	</th>
		<cfloop query="dsLaborTrackingCategories">
			<!--- The Nursing Sub-Total columns will be placed before kitchen services. --->
			<!--- Add the Nursing Sub-Total Column Headers. --->
			<cfif cLaborTrackingCategory is "Kitchen">
				<th colspan=1 bgcolor="#budgetcellcolor#">
					<font size=-1>
						Budget
					</font>
				</th>
				<th colspan=1 bgcolor="#emptyCellColor#">
					<font size=-1>
						Actual
					</font>
				</th>
				<th colspan=1 bgcolor="#emptyCellColor#">
					<font size=-1>
						Variance
					</font>
				</th>		
			</cfif>
			<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN" or cLaborTrackingCategory is "Kitchen">
				<th bgcolor="#emptyCellColor#">
					<font size=-1>
						Regular
					</font>
				</th>
				<th bgcolor="#emptyCellColor#">
					<font size=-1>
						Overtime
					</font>
				</th>
				<!--- Kitchen Services does NOT report "Other" Hours. --->
				<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">
					<th bgcolor="#emptyCellColor#">
						<font size=-1>
							Other
						</font>
					</th>
				</cfif>
			<cfelse>
				<th bgcolor="#emptyCellColor#">
					<font size=-1>
						&##160;
					</font>
				</th>
			</cfif>
		</cfloop>

		<th bgcolor="#emptyCellColor#">
			<font size=-1>
				&##160;
			</font>
		</th>
		<th bgcolor="#emptyCellColor#">
			<font size=-1>
				&##160;
			</font>
		</th>
	</tr>
</thead>
<tbody>
<!--- Accumulates the MTD Training Budget. --->
<cfset trainingBudgetMtd = 0>
<!--- SHOW DETAILS - ALL DAYS UP TO THE CURRENT DAY OR THE END OF THE MONTH --->
<cfloop from="1" to="#currentd#" index="currentDay">
	<!--- Fetch the labor data for the current day. --->
	<cfset dsCurrentLaborTrackingData = #helperObj.FetchLaborHoursForDay(dsLaborTrackingHours, currentDay)#>
	<tr>
		<!--- get today's occupancy and multiply it by the budgeted food expense per resident day --->
		<td class="locked" bgcolor="#emptyCellColor#" align="center">
			<font size=-1>
				#currentDay#
			</font>
		</td>
	
		<!--- Stores the total number of hours worked for all Nursing categories, which includes Regular, Overtime, and Other. --->
		<cfset nursingTotalHours = 0>
		<!--- Accumulates the current days budget for all Nursing Categories. --->
		<cfset nursingBudgetTotalHours = 0>	
		<!--- Stores the total number of hours for the current day. --->
		<cfset totalDailyHours = 0>
		<!--- Stores te total budget hours for the current day. --->
		<cfset totalDailyBudgetHours = 0>
		
		<!--- loop through labor categories --->
		<Cfloop query="dsCurrentLaborTrackingData">
				
			<!--- Check if the current column should be displayed. --->
			<cfif bIsVisible eq true>
				<!--- Check if it's a Nursing Category and then update the daily total for the Nursing Budget Sub-Total. --->
				<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">			
					<!--- Add the current category's budget total. --->
					<cfset nursingBudgetTotalHours = #nursingBudgetTotalHours# + #fBudget#>
					<!--- Add the current category's hours to the nursing daily total. --->
					<cfset nursingTotalHours = #nursingTotalHours# + #fRegular# + #fOvertime# + #fOther#>
				
					<!--- Add the current category's hours to the daily total. --->
					<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime# + #fOther#>
					<!--- Add the current category's budget hours to the daily total. --->
					<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fBudget#>					
					
					<!--- Display the Reg/OT/Other columns. --->
					<td align=right>
						<font size=-1>
							#helperObj.LaborNumberFormat(fRegular, "0.0")#
						</font>
					</td>
					<td align=right>
						<font size=-1>
							#helperObj.LaborNumberFormat(fOvertime, "0.0")#
						</font>
					</td>
					<td align=right>
						<font size=-1>
							#helperObj.LaborNumberFormat(fOther, "0.0")#
						</font>
					</td>
				<!--- Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
				<cfelseif cLaborTrackingCategory is "Kitchen">
					<!--- Calculate the Nursing Sub-Total's variance. --->
					<cfset nursingDailyVariance = #nursingBudgetTotalHours# - #nursingTotalHours#>
			
					<!--- Add the current category's hours to the daily total. --->
					<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime#>
					<!--- Add the current category's budget hours to the daily total. --->
					<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fBudget#>							
					
					<!--- Display the Nursing Sub-Totals. --->
					<td align=right bgcolor="#budgetcellcolor#">
						<font size=-1>
							#helperObj.LaborNumberFormat(nursingBudgetTotalHours, "0.00")#
						</font>
					</td>
					<td align=right>
						<font size=-1>
							#helperObj.LaborNumberFormat(nursingTotalHours, "0.0")#
						</font>
					</td>
					<cfif nursingDailyVariance LT 0>
						<td align=right>
							<font size=-1 color="red">
								#helperObj.LaborNumberFormat(nursingDailyVariance, "0.00")#
							</font>
						</td>
					<cfelse>
						<td align=right>
							<font size=-1>
								#helperObj.LaborNumberFormat(nursingDailyVariance, "0.00")#
							</font>
						</td>
					</cfif>
					
					<!--- Display the Kitchen Regular and Overtime Hours. --->
					<td align=right>
						<font size=-1>
							#helperObj.LaborNumberFormat(fRegular, "0.0")#
						</font>
					</td>
					<td align=right>
						<font size=-1>
							#helperObj.LaborNumberFormat(fOvertime, "0.0")#
						</font>
					</td>
										
				<cfelse>	
					<!--- Add the current category's hours to the daily total. --->
					<cfset totalDailyHours = #totalDailyHours# + #fAll#>
				
					<!--- Display the Non-Nursing Hours. --->
					<td align=right>
						<font size=-1>
							#helperObj.LaborNumberFormat(fAll, "0.0")#
						</font>
					</td>
				
					<cfif bIsTraining eq true>
						<!--- Set the current day's training budget. --->
						<cfset currentDayTrainingBudget = #helperObj.GetTrainingHoursForDay(dsCurrentLaborTrackingData)#>
						<!--- Add the current category's budget hours to the daily total. --->
						<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #currentDayTrainingBudget#>		
						<!--- Add to the MTD Training Budget. --->
						<cfset trainingBudgetMtd = #trainingBudgetMtd# + #currentDayTrainingBudget#>
						<!--- Display the TOTAL Hours. --->
						<td align=right>
							<font size=-1>
								<strong>
									#helperObj.LaborNumberFormat(totalDailyHours, "0.0")#
								</strong>
							</font>
						</td>
	
						<!--- Display the Day's Variance. --->
						<cfset currentDaysVariance = #totalDailyBudgetHours# - #totalDailyHours#>
						<!--- Check if the text color should be RED for a negative value. --->
						<cfif currentDaysVariance lt 0>
							<td align=right bgcolor="#varianceCellColor#">
								<font size=-1 color="red">
									<strong>
										#helperObj.LaborNumberFormat(currentDaysVariance, "0.0")#
									</strong>
								</font>
							</td>					
						<cfelse>
							<td align=right bgcolor="#varianceCellColor#">
								<font size=-1>
									<strong>
										#helperObj.LaborNumberFormat(currentDaysVariance, "0.0")#
									</strong>
								</font>
							</td>	
						</cfif>					
					<cfelse>
						<!--- Add the current category's budget hours to the daily total. --->
						<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fBudget#>		
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
	</tr>
</cfloop>



<!------------------------- MTD ACTUAL HOURS - TOTALS ------------------------->
<tfoot>
	<tr>
		<td class="locked" align=right bgcolor="#totalcellcolor#">
			<font size=-1>
				<strong>
					Total
				</strong>
			</font>
		</td>
		<!--- Fetch the labor data totals for the current month. --->
		<cfset dsTotalLaborTrackingData = #helperObj.FetchLaborHoursForMTD(dsLaborTrackingHours)#>
		<!--- Stores the total number of hours worked for all Nursing categories, which includes Regular, Overtime, and Other. --->
		<cfset nursingMtdTotalHours = 0>
		<!--- Stores the total number of hours for the current mtd. --->
		<cfset totalMtdHours = 0>
		<!--- Stores te total budget hours for the current mtd. --->
		<cfset totalMtdBudgetHours = 0>
		<!--- loop through labor categories --->
		<Cfloop query="dsTotalLaborTrackingData">
			<!--- Check if the current column should be displayed. --->
			<cfif bIsVisible eq true>
				<!--- Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total. --->
				<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">			
					<!--- Add the current category's hours to the nursing mtd total. --->
					<cfset nursingMtdTotalHours = #nursingMtdTotalHours# + #fRegular# + #fOvertime# + #fOther#>
				
					<!--- Add the current category's hours to the mtd total. --->
					<cfset totalMtdHours = #totalMtdHours# + #fRegular# + #fOvertime# + #fOther#>
					<!--- Add the current category's budget hours to the mtd total. --->
					<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fBudget#>					
					
					<!--- Display the Reg/OT/Other columns. --->
					<td align=right bgcolor="#totalcellcolor#">
						<font size=-1>
							<strong>
								#helperObj.LaborNumberFormat(fRegular, "0.0")#
							</strong>
						</font>
					</td>
					<td align=right bgcolor="#totalcellcolor#">
						<font size=-1>
							<strong>
								#helperObj.LaborNumberFormat(fOvertime, "0.0")#
							</strong>
						</font>
					</td>
					<td align=right bgcolor="#totalcellcolor#">
						<font size=-1>
							<strong>
								#helperObj.LaborNumberFormat(fOther, "0.0")#
							</strong>
						</font>
					</td>
				<!--- Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
				<cfelseif cLaborTrackingCategory is "Kitchen">

					<!--- Add the current category's hours to the mtd total. --->
					<cfset totalMtdHours = #totalMtdHours# + #fRegular# + #fOvertime#>
					<!--- Add the current category's budget hours to the mtd total. --->
					<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fBudget#>							
					
					<!--- Display the Nursing Sub-Totals. --->
					<td align=right bgcolor="#totalcellcolor#">
						<font size=-1>
							<strong>
								-
							</strong>
						</font>
					</td>
					<td align=right bgcolor="#totalcellcolor#">
						<font size=-1>
							<strong>
								#helperObj.LaborNumberFormat(nursingMtdTotalHours, "0.0")#
							</strong>
						</font>
					</td>
					<td align=right bgcolor="#totalcellcolor#">
						<font size=-1>
							<strong>
								-
							</strong>
						</font>
					</td>

					<!--- Display the Kitchen Regular and Overtime Hours. --->
					<td align=right bgcolor="#totalcellcolor#">
						<font size=-1>
							<strong>
								#helperObj.LaborNumberFormat(fRegular, "0.0")#
							</strong>
						</font>
					</td>
					<td align=right bgcolor="#totalcellcolor#">
						<font size=-1>
							<strong>
								#helperObj.LaborNumberFormat(fOvertime, "0.0")#
							</strong>
						</font>
					</td>
										
				<cfelse>	
					<!--- Add the current category's hours to the daily total. --->
					<cfset totalMtdHours = #totalMtdHours# + #fAll#>
				
					<!--- Display the Non-Nursing Hours. --->
					<td align=right bgcolor="#totalcellcolor#">
						<font size=-1>
							<strong>
								#helperObj.LaborNumberFormat(fAll, "0.0")#
							</strong>
						</font>
					</td>
				
					<cfif bIsTraining eq true>
						<!--- Add the current category's budget hours to the mtd total. --->
						<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #trainingBudgetMtd#>		
						
						<!--- Display the TOTAL Hours. --->
						<td align=right bgcolor="#totalcellcolor#">
							<font size=-1>
								<strong>
									#helperObj.LaborNumberFormat(totalMtdHours, "0.0")#
								</strong>
							</font>
						</td>
						<!--- Display the Day's Variance. --->
						<cfset mtdVariance = #totalMtdBudgetHours# - #totalMtdHours#>
						<!--- Check if the MTD Variance is a negative value and display it in red if it is. --->
						<cfif mtdVariance lt 0>
							<td align=right bgcolor="#totalcellcolor#">
								<font size=-1 color="red">
									<strong>
										#helperObj.LaborNumberFormat(mtdVariance, "0.0")#
									</strong>
								</font>
							</td>					
						<cfelse>
							<td align=right bgcolor="#totalcellcolor#">
								<font size=-1>
									<strong>
										#helperObj.LaborNumberFormat(mtdVariance, "0.0")#
									</strong>
								</font>
							</td>	
						</cfif>					
					<cfelse>
						<!--- Add the current category's budget hours to the daily total. --->
						<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fBudget#>		
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
	</tr>
	
	
	<!------------------------- MTD BUDGET TOTALS ------------------------->
	<tr>
		<td class="locked" align=right bgcolor="#budgetcellcolor#">
			<font size=-1>
				MTD Budget
			</font>
		</td>
		<!--- Fetch the labor data totals for the current month. --->
		<cfset dsTotalLaborTrackingData = #helperObj.FetchLaborHoursForMTD(dsLaborTrackingHours)#>
		<!--- Accumulates the current mtd's budget for all Nursing Categories. --->
		<cfset nursingBudgetMtdTotalHours = 0>	
		<!--- Stores te total budget hours for the current mtd. --->
		<cfset totalMtdBudgetHours = 0>
		<!--- loop through labor categories --->
		<Cfloop query="dsTotalLaborTrackingData">
			<!--- Check if the current column should be displayed. --->
			<cfif bIsVisible eq true>
				<!--- Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total. --->
				<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">			
					<!--- Add the current category's budget total. --->
					<cfset nursingBudgetMtdTotalHours = #nursingBudgetMtdTotalHours# + #fBudget#>
				
					<!--- Add the current category's budget hours to the mtd total. --->
					<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fBudget#>					
					
					<!--- Display the Reg/OT/Other columns. --->
					<td align=right bgcolor="#budgetCellColor#">
						<font size=-1>
							#helperObj.LaborNumberFormat(fBudget, "0.0")#
						</font>
					</td>
					<td align=right bgcolor="#budgetCellColor#">
						<font size=-1>
							-
						</font>
					</td>
					<td align=right bgcolor="#budgetCellColor#">
						<font size=-1>
							-
						</font>
					</td>
				<!--- Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
				<cfelseif cLaborTrackingCategory is "Kitchen">

					<!--- Add the current category's budget hours to the mtd total. --->
					<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fBudget#>							
					
					<!--- Display the Nursing Sub-Totals. --->
					<td align=right bgcolor="#budgetCellColor#">
						<font size=-1>
							#helperObj.LaborNumberFormat(nursingBudgetMtdTotalHours, "0.00")#
						</font>
					</td>
					<td align=right bgcolor="#budgetCellColor#">
						<font size=-1>
							-
						</font>
					</td>
					<td align=right bgcolor="#budgetCellColor#">
						<font size=-1>
							-
						</font>
					</td>
					
					<!--- Display the Kitchen Regular and Overtime Hours. --->
					<td align=right bgcolor="#budgetCellColor#">
						<font size=-1>
							#helperObj.LaborNumberFormat(fBudget, "0.0")#
						</font>
					</td>
					<td align=right bgcolor="#budgetCellColor#">
						<font size=-1>
							-
						</font>
					</td>
										
				<cfelse>	
					<cfif bIsTraining eq true>

						<!--- Add the current category's budget hours to the mtd total. --->
						<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #trainingBudgetMtd#>		
					
						<!--- Display the Training Budget Hours. --->
						<td align=right bgcolor="#budgetCellColor#">
							<font size=-1>
								#helperObj.LaborNumberFormat(trainingBudgetMtd, "0.0")#
							</font>
						</td>
						
						<!--- Display the TOTAL Hours. --->
						<td align=right bgcolor="#budgetCellColor#">
							<font size=-1>
								#helperObj.LaborNumberFormat(totalMtdBudgetHours, "0.0")#
							</font>
						</td>
						
						<!--- Display the empty cells for variance and pto. --->
						<td align=right bgcolor="#emptyCellColor#">
							<font size=-1>
								&##160;
							</font>
						</td>
						<td align=right bgcolor="#emptyCellColor#">
							<font size=-1>
								&##160;
							</font>
						</td>
						
						<!--- Leave the LOOP. --->
						<cfbreak>
						
					<cfelse>
						<!--- Display the Non-Nursing Hours. --->
						<td align=right bgcolor="#budgetCellColor#">
							<font size=-1>
								#helperObj.LaborNumberFormat(fBudget, "0.0")#
							</font>
						</td>
						<!--- Add the current category's budget hours to the daily total. --->
						<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fBudget#>		
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
	</tr>	
	
	
	
	
	
	<!------------------------- MTD VARIANCE TOTALS (BUDGET - ACTUAL) ------------------------->
	<tr>
		<td class="locked" align=right bgcolor="#varianceCellColor#">
			<font size=-1>
				<strong>
					MTD Variance
				</strong>
			</font>
		</td>
		<!--- Fetch the labor data totals for the current month. --->
		<cfset dsTotalLaborTrackingData = #helperObj.FetchLaborHoursForMTD(dsLaborTrackingHours)#>
		<!--- Stores the total accumulated variance for Nursing. --->
		<cfset nursingMtdVariance = 0>
		<!--- Stores the total accumulated variance for all of the visible categories. --->
		<cfset totalMtdVariance = 0>
		<!--- loop through labor categories --->
		<Cfloop query="dsTotalLaborTrackingData">
			<!--- Check if the current column should be displayed. --->
			<cfif bIsVisible eq true>
				<!--- Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total. --->
				<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">								
					<!--- Check if the (Budget - Regular Hours) value should be red (neg number). --->	
					<cfif (fBudget - fRegular) lt 0>				
						<!--- Display the Reg/OT/Other columns. --->
						<td align=right bgcolor="#varianceCellColor#">
							<font size=-1 color="red">
								<strong>
									#helperObj.LaborNumberFormat(fBudget - fRegular, "0.0")#
								</strong>
							</font>
						</td>
					<cfelse>
						<!--- Display the Reg/OT/Other columns. --->
						<td align=right bgcolor="#varianceCellColor#">
							<font size=-1>
								<strong>
									#helperObj.LaborNumberFormat(fBudget - fRegular, "0.0")#
								</strong>
							</font>
						</td>
					</cfif>
					<!--- Add to the variance accumulators (Total Nursing and Total) --->
					<cfset nursingMtdVariance = #nursingMtdVariance# + (#fBudget# - #fRegular#)>
					<cfset totalMtdVariance = #totalMtdVariance# + (#fBudget# - #fRegular#)>
					
					<!--- Check if the OT value shoud be Red (Neg Number). --->
					<cfif fOvertime gt 0>					
						<td align=right bgcolor="#varianceCellColor#">
							<font size=-1 color="red">
								<strong>
									#helperObj.LaborNumberFormat(-fOvertime, "0.0")#
								</strong>
							</font>
						</td>
					<cfelse>
						<td align=right bgcolor="#varianceCellColor#">
							<font size=-1>
								<strong>
									#helperObj.LaborNumberFormat(-fOvertime, "0.0")#
								</strong>
							</font>
						</td>
					</cfif>
					<!--- Add to the variance accumulators (Total Nursing and Total) --->
					<cfset nursingMtdVariance = #nursingMtdVariance# - #fOvertime#>
					<cfset totalMtdVariance = #totalMtdVariance# - #fOvertime#>
					
					<!--- Check if the Other value shoud be Red (Neg Number). --->
					<cfif fOther gt 0>
						<td align=right bgcolor="#varianceCellColor#">
							<font size=-1 color="red">
								<strong>
									#helperObj.LaborNumberFormat(-fOther, "0.0")#
								</strong>
							</font>
						</td>
					<cfelse>
						<td align=right bgcolor="#varianceCellColor#">
							<font size=-1>
								<strong>
									#helperObj.LaborNumberFormat(-fOther, "0.0")#
								</strong>
							</font>
						</td>
					</cfif>
					<!--- Add to the variance accumulators (Total Nursing and Total) --->
					<cfset nursingMtdVariance = #nursingMtdVariance# - #fOther#>
					<cfset totalMtdVariance = #totalMtdVariance# - #fOther#>			
				<!--- Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
				<cfelseif cLaborTrackingCategory is "Kitchen">
					<!--- Display the Nursing Sub-Totals. --->
					<td align=right bgcolor="#varianceCellColor#">
						<font size=-1>
							<strong>
								-
							</strong>
						</font>
					</td>
					<td align=right bgcolor="#varianceCellColor#">
						<font size=-1>
							<strong>
								-
							</strong>
						</font>
					</td>
					<!--- Check if the value should be red. --->
					<cfif nursingMtdVariance lt 0>
						<td align=right bgcolor="#varianceCellColor#">
							<font size=-1 color="red">
								<strong>
									#helperObj.LaborNumberFormat(nursingMtdVariance, "0.00")#
								</strong>
							</font>
						</td>
					<cfelse>
						<td align=right bgcolor="#varianceCellColor#">
							<font size=-1>
								<strong>
									#helperObj.LaborNumberFormat(nursingMtdVariance, "0.00")#
								</strong>
							</font>
						</td>
					</cfif>
					<!--- Check if the value should be red. --->
					<cfif (fBudget - fRegular) lt 0>
						<!--- Display the Kitchen Regular and Overtime Hours. --->
						<td align=right bgcolor="#varianceCellColor#">
							<font size=-1 color="red">
								<strong>
									#helperObj.LaborNumberFormat(fBudget - fRegular, "0.0")#
								</strong>
							</font>
						</td>
					<cfelse>
						<!--- Display the Kitchen Regular and Overtime Hours. --->
						<td align=right bgcolor="#varianceCellColor#">
							<font size=-1>
								<strong>
									#helperObj.LaborNumberFormat(fBudget - fRegular, "0.0")#
								</strong>
							</font>
						</td>
					</cfif>
					<!--- Add to the variance accumulators (Total) --->
					<cfset totalMtdVariance = #totalMtdVariance# + (#fBudget# - #fRegular#)>			
					
					<!--- Check if the value should be red. --->
					<cfif fOvertime gt 0>
						<td align=right bgcolor="#varianceCellColor#">
							<font size=-1 color="red">
								<strong>
									#helperObj.LaborNumberFormat(-fOvertime, "0.0")#
								</strong>
							</font>
						</td>
					<cfelse>
						<td align=right bgcolor="#varianceCellColor#">
							<font size=-1>
								<strong>
									#helperObj.LaborNumberFormat(-fOvertime, "0.0")#
								</strong>
							</font>
						</td>
					</cfif>
					<!--- Add to the variance accumulators (Total) --->
					<cfset totalMtdVariance = #totalMtdVariance# - #fOvertime#>			
	
				<cfelse>	
					<cfif bIsTraining eq true>
						<!--- Check if the training budget minus training actual is a neg value (neg number = red). --->
						<cfif (trainingBudgetMtd - fAll) lt 0>
							<!--- Display the Training Hours. --->
							<td align=right bgcolor="#varianceCellColor#">
								<font size=-1 color="red">
									<strong>
										#helperObj.LaborNumberFormat(trainingBudgetMtd - fAll, "0.0")#
									</strong>
								</font>
							</td>
						<cfelse>
							<!--- Display the Training Hours. --->
							<td align=right bgcolor="#varianceCellColor#">
								<font size=-1>
									<strong>
										#helperObj.LaborNumberFormat(trainingBudgetMtd - fAll, "0.0")#
									</strong>
								</font>
							</td>
						</cfif>
						<!--- Add to the variance accumulators (Total) --->
						<cfset totalMtdVariance = #totalMtdVariance# + (#trainingBudgetMtd# - #fAll#)>
						
						<!--- Check if the MTD Variance is a negative value and display it in red if it is. --->
						<cfif totalMtdVariance lt 0>
							<!--- Display the TOTAL Variance Hours in Red Text. --->
							<td align=right bgcolor="#varianceCellColor#">
								<font size=-1 color="red">
									<strong>
										#helperObj.LaborNumberFormat(totalMtdVariance, "0.0")#
									</strong>
								</font>
							</td>
						<cfelse>
							<!--- Display the TOTAL Variance Hours. --->
							<td align=right bgcolor="#varianceCellColor#">
								<font size=-1>
									<strong>
										#helperObj.LaborNumberFormat(totalMtdVariance, "0.0")#
									</strong>
								</font>
							</td>
						</cfif>

						<!--- Display the empty cells for variance and pto. --->
						<td align=right bgcolor="#emptyCellColor#">
							<font size=-1>
								&##160;
							</font>
						</td>
						<td align=right bgcolor="#emptyCellColor#">
							<font size=-1>
								&##160;
							</font>
						</td>
						
						<!--- Leave the LOOP. --->
						<cfbreak>
		
					<cfelse>
						<!--- Check if the non-nursing Budget minus Actual is less than 0 (neg number = red). --->
						<cfif (fBudget - fAll) lt 0>
							<!--- Display the Non-Nursing Hours. --->
							<td align=right bgcolor="#varianceCellColor#">
								<font size=-1 color="red">
									<strong>
										#helperObj.LaborNumberFormat(fBudget - fAll, "0.0")#
									</strong>
								</font>
							</td>
						<cfelse>
							<!--- Display the Non-Nursing Hours. --->
							<td align=right bgcolor="#varianceCellColor#">
								<font size=-1>
									<strong>
										#helperObj.LaborNumberFormat(fBudget - fAll, "0.0")#
									</strong>
								</font>
							</td>
						</cfif>
						<!--- Add to the variance accumulators (Total) --->
						<cfset totalMtdVariance = #totalMtdVariance# + (#fBudget# - #fAll#)>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
	</tr>	
</tfoot>
</tbody>
</table>
</div>
</cfoutput>
<script language="javascript" type="text/javascript">
	document.getElementById("tbl-container").style.display = 'none';
	document.getElementById("tbl-container").style.display = 'block';
	window.print();
</script>
</body>
</html>