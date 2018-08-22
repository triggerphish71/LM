<!----------------------------------------------------------------------------------------------
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| bkubly     | 03/27/2009 | Developed Labor Tracking Page.					                   |
| bkubly 	 | 10/14/2009 | Add Variable Budget Tooltips.									   |
| bkubly	 | 01/14/2011 | Add daily Variable Budget columns - 59563.					  			   |
----------------------------------------------------------------------------------------------->
<cfheader name='expires' value='#Now()#'> 
<cfheader name='pragma' value='no-cache'>
<cfheader name='cache-control' value='no-cache,no-store, must-revalidate'>

<cfset page = "Labor Tracking">
<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
		<head>
			<link rel="stylesheet" href="CSS/LaborTrackingPrint.css" type="text/css" media="print">
			<link rel="stylesheet" href="CSS/LaborTracking.css" type="text/css">
			
			<script src="ScriptFiles/jquery-1.3.2.js" type="text/javascript"></script> 			
			<script src="ScriptFiles/jquery.hoverIntent.js" type="text/javascript"></script>
  			<script src="ScriptFiles/jquery.bgiframe.js" type="text/javascript"></script>
  			<script src="ScriptFiles/jquery.cluetip.js" type="text/javascript"></script>	
			<link rel="stylesheet" href="jquery.cluetip2.css" type="text/css" />
			
			<title>
				Online FTA- #page#
			</title>
			
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

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

			<SCRIPT language="javascript">
				var minTableHeight = 510;
				var overrideTableHeight = false;
				var tableHeightPct = 100;
				if (#currentd# < 12)
				{
					overrideTableHeight = true;
					minTableHeight = (#currentd# * 22) + 224;
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
				$(function()
				{
					// Setup the cluetip.
					$('a.load-local').cluetip(
					{
						local: true, 
						width: "335px",
						hidelocal: true,    
						arrows: true,
						cursor: 'default', 
						dropShadow: false,
  						sticky: true,
  						mouseOutClose: true,
  						activation: 'click',
  						closePosition: 'title',
  						waitImage: true,
  						open: 'slideDown',
  						showTitle: true,
  						titleAttribute: 'titleDisplay',
  						closeText: 'X'		
					});					
					//$('a.load-local').cluetip({local:true, cursor: 'pointer'});			
				});
				
				function mdy() {
					//calls the function mdy why to get our date
					var date = new Date();
					var d  = date.getDate();
					var day = (d < 10) ? '0' + d : d;
					var m = date.getMonth() + 1;
					var month = (m < 10) ? '0' + m : m;
					var yy = date.getYear();
					var year = (yy < 1000) ? yy + 1900 : yy;
					
					return (month + "-" + day-1 + "-" + year);
				}

			</SCRIPT>
		</head>
</cfoutput>
	
</div>	

<!--- ------------------------------------------------------------ --->	
<!--- Setup the Color variables. --->
<cfset headerCellColor = "##0066CC">
<cfset totalCellColor="##9CCDCD">
<cfset varianceCellColor = "##ccffff">
<cfset budgetCellColor = "##ffff99">
<cfset variableBudgetCellColor = "cbe91f">
<cfset variableBudgetVarianceCellColor = "##ccffff">
<cfset emptyCellColor = "f4f4f4">

<!--- Setup the Freeze Pane Borders for the bottom of the header and the right of the left frozen column. --->
<cfset leftPaneStyle = "border-right-style: solid; border-right-width: 2px; border-right-color: gray;">
<cfset topPaneStyle = "border-bottom-style: solid; border-bottom-width: 2px; border-bottom-color: gray;">

<cfset same = 0>
<cfset wds = 0>
<cfset open =0>
<cfset conflict = 0>
<cfset totalvarbgt = 0>
<cfset totalvariance = 0>
<cfset samePeriod = 0>
<cfset WDStermed = 0>
<cfset conditionalTrue = 0>
<cfset conditionalFalse = 0>
<cfset currPeriod = 0>

<cfoutput>
	<body>		
		<font face="arial">
			<form method="post" action="labortracking.cfm">
				<cfinclude template="DisplayFiles/Header.cfm">
				<!--- Setup the Query variables. --->
				<cfset dsLaborTrackingHours = #helperObj.FetchLaborHours(houseId, PtoPFormat)#>
				<cfset dsLaborTrackingCategories = #helperObj.FetchLaborTrackingCategories()#>
				<cfset dsCensusDetails = #helperObj.FetchCensusDetails(houseId, FromDate, ThruDate)#>
				<cfset dailyCensusBudget = #helperObj.FetchDailyCensusBudget(houseId, currenty, monthforqueries)#>
				<cfset censusBudgetDim = #dailyCensusBudget# * #currentdim#>
				<cfset dsLaborVariableBudgets = #helperObj.FetchLaborVariableBudgets(houseId, PtoPFormat)#>		
				<cfset dsTwoPersonAssists = #helperObj.FetchTwoPersonAssists(houseId, FromDate, ThruDate)#>
				
				<cfset dsLaborTrackingWDSInfo = #helperObj.FetchLaborTrackingWDSDaily(houseId, DateFormat(now()-1, "mm/dd/yyyy"),PtoPFormat)#>
				<cfset dsHousesWithWDHAndWDS = #helperObj.FetchHousesWithWDHAndWDS(houseId, PtoPFormat)#>
				<cfset dsHousesWithWD = #helperObj.FetchHousesWithWD(houseId, PtoPFormat)#>
				
					<cfif dsHousesWithWDHAndWDS.recordcount is not 0>	<cfset conflict = 1>
					<cfelse> <cfset conflict = 0> 	</cfif>
					
					<cfif dsLaborTrackingWDSInfo.dTermDate is not "" and (dsLaborTrackingWDSInfo.dTermDate gte dsLaborTrackingWDSInfo.StartDate and dsLaborTrackingWDSInfo.dTermDate lt dsLaborTrackingWDSInfo.EndDate)>
						<cfset WDStermed = 1> <cfset samePeriod = 1><cfset bool = "true1">
					<cfelseif dsLaborTrackingWDSInfo.dTermDate is not "" and (dsLaborTrackingWDSInfo.dTermDate lte dsLaborTrackingWDSInfo.StartDate and dsLaborTrackingWDSInfo.dTermDate lt dsLaborTrackingWDSInfo.EndDate)>
						<cfset WDStermed = 1> <cfset samePeriod = 0><cfset bool = "true2">
					<cfelse> <cfset WDStermed = 0> <cfset bool = "false"></cfif>
				
				<cfset dsWDSHouses = #helperObj.FetchWDSHouses(houseId)#>
				<cfset dsOpenWD = #helperObj.FetchHouseWithOpenWDPosition(houseId, PtoPFormat)#>
					<cfif dsOpenWD.recordcount is not 0>	
						<cfset open = 1>
					<cfelse> 
						<cfset open = 0> 
						<cfif dsWDSHouses.recordcount is not 0>	<cfset wds = 1> <cfelse> <cfset wds = 0> </cfif>
					</cfif>
					
					<cfif (DateFormat(dsLaborTrackingWDSInfo.dHireDate, "yyyymm") eq PtoPFormat)>
						<cfset currPeriod = 1>
					<cfelse> <cfset currPeriod = 0>
					</cfif>
					
					<cfif dsHousesWithWD.recordcount is not 0>
						<cfif dsHousesWithWD.ActiveWDH is 1 and dsHousesWithWD.ActiveWDS is 0 > <cfset WDStermed = 1><cfset samePeriod = 1><cfset bool = "othertrue1">
						<cfelseif dsHousesWithWD.ActiveWDH is 0 and dsHousesWithWD.ActiveWDS is 1> <cfset WDStermed = 0><cfset samePeriod = 1> <cfset bool = "other false1">
						<cfelseif (dsHousesWithWD.ActiveWDS is 1 and dsHousesWithWD.n_Status is "L") and ActiveWDH is 0> <cfset WDStermed = 1><cfset samePeriod = 1><cfset bool = "othertrue2">
						<cfelseif dsHousesWithWD.ActiveWDH is 1 and dsHousesWithWD.ActiveWDS is 1 > <cfset WDStermed = 0> <cfset conflict =1> <cfset samePeriod = 1><cfset bool = "otherfalse2">
						<cfelse> <cfset conflict = 0> <cfset open = 1><cfset samePeriod = 1>
						</cfif>
					</cfif>
		</font>	
		<br />
<br />
<table id="tbl1" cellspacing="0" cellpadding="0" border="0px">
	<tr>
		<td colspan="4" rowspan="3" bgcolor="white">
			<label id="lblExportToExcel" style="cursor: hand; color: blue; text-decoration: underline; font-family: verdana; font-size: 8pt" 
				onClick="javascript:window.open('LaborTracking_ExcelExport.cfm?iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#');">
					Export to Excel Spreadsheet <img title="Export to Excel" src="Images/ExcelBig.bmp" height="30px" width="30px" />
			</label>
		</td>
		<td colspan="4" rowspan="3"><font size="-2" color="white">EmptyCell</font></td>
		<td colspan="6" rowspan="3">
			<cfif PtoPFormat gte '201201'>
			<table id="tbl2" cellspacing="0" cellpadding="1" border="1px">
				<tr>
					<cfif conflict is 1><th class="locked" colspan="6" bgcolor="#headerCellColor#" style="#topPaneStyle#">
					<cfelse><th class="locked" colspan="4" bgcolor="#headerCellColor#" style="#topPaneStyle#"></cfif>
						<font size="-1" color="#headerCellColor#"> WDS -  </font>					
						<font size="-1" color="white"> Salaried Wellness Director - #DateFormat(now(), "mm/dd/yyyy")# </font>
						<font size="-1" color="#headerCellColor#"> - WDS  </font>						
					</th>
				</tr>
				<tr>
					<th colspan="1" bgcolor="#emptyCellColor#" style="#topPaneStyle#">
						<font size="-1">
							Actual
						</font>
					</th>				
					<th colspan="1" bgcolor="#budgetcellcolor#" style="width: 0px; #topPaneStyle#">
						<font size="-1">
							Var Bgt
						</font>
					</th>
					<th colspan="1" bgcolor="#emptyCellColor#" style="width: 0px; #topPaneStyle#">
						<font size="-1">
							Variance
						</font>
					</th>		
					<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
						<font size="-1">
							Allocated WD
						</font>
					</th>
					<cfif conflict is 1>
					<th colspan="1" bgcolor="#emptyCellColor#" style="#topPaneStyle#">
						<font size="-1">
							Status
						</font>
					</th>
					</cfif>
				</tr>	
				<tr>
					<td colspan="1" rowspan="1" align="right" style="padding-right: 5px;">
						<font size="-1">
							<cfif dsLaborTrackingWDSInfo.recordcount is 0> 0
							<cfelse> 
								<cfif WDStermed is 0>#helperObj.LaborNumberFormat(dsLaborTrackingWDSInfo.fWorkWeekAllocation, "0.00")#<cfelse> - </cfif>
							</cfif>
						</font>
					</td>
					<td colspan="1" rowspan="1" bgcolor="#budgetcellcolor#" align="right" style="padding-right: 5px;">
						<font size="-1">
							<cfif dsLaborTrackingWDSInfo.recordcount is 0> -
							<cfelse> 
								<cfif open is 0>
									<cfif WDStermed is 0>
										<cfif conflict is 0> #helperObj.LaborNumberFormat(dsLaborTrackingWDSInfo.VarBdgt, "0.00")#<cfelse> - </cfif> 
									<cfelse> - </cfif> 
								<cfelse> - </cfif> 
							</cfif>
						</font>
					</td>
					<td colspan="1" rowspan="1" align="right" style="padding-right: 5px;">
						<cfif dsLaborTrackingWDSInfo.recordcount is 0> 0
						<cfelse> 
							 <cfif open is 0>
							 	<cfif WDStermed is 0>
									<cfif conflict is 0>  
										<cfset WDSVariance = dsLaborTrackingWDSInfo.VarBdgt - dsLaborTrackingWDSInfo.fWorkWeekAllocation >
										<font size="-1" color="<cfif (WDSVariance) lt 0>Red<cfelse>Black</cfif>">
											#helperObj.LaborNumberFormat(WDSVariance, "0.00")#
										</font> 
									 <cfelse> - </cfif> 
								 <cfelse> - </cfif> 
							<cfelse> - </cfif>
						</cfif>
					</td>
					<td colspan="1" rowspan="1" align="right" style="padding-right: 5px;">
						<font size="-1">
							<cfif dsLaborTrackingWDSInfo.recordcount is 0> 0
							<cfelse> 
							<cfif WDStermed is 0>#helperObj.LaborNumberFormat(dsLaborTrackingWDSInfo.percentage, "0.00")#%<cfelse> - </cfif> 
							</cfif>
						</font>
					</td>
					<cfif conflict is 1>
						<td bgcolor="white" colspan="1" rowspan="1" align="center">
							<font size="3" color="<cfif conflict is 1>Red<cfelse>Black</cfif>"><strong>CONFLICT</strong></font>
						</td>
					</cfif>		
				</tr>			
			</table>
			</cfif> 
		</td>
	</tr>
</table>

			<div id="tbl-container">
				<table id="tbl" cellspacing="0" cellpadding="1" border="1px">
					<thead>
						<tr>

</cfoutput>

<!------------------------- COLUMN HEADERS - ROW 1 ------------------------->
<cfoutput>
	<th class="locked" colspan="1" bgcolor="#headerCellColor#" style="#leftPaneStyle#">
		&##160;
	</th>
	<th align="center" bgcolor="#headerCellColor#" colspan="4">
		<font size="-1" color="white">
			Daily
		</font>
	</th>
	<cfloop query="dsLaborTrackingCategories">
			<cfif cLaborTrackingCategory is not "WD Salary">
				<!--- The WD Hours columns will be placed before kitchen services. --->
				<cfif cLaborTrackingCategory is "Kitchen">
					<th bgcolor="#headerCellColor#" colspan="3">
						<font size="-1" color="white">
							Nursing Totals
						</font>
					</th>	
				</cfif>
		
				<!---- Check if the category is Nursing ---->
				<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN" or cLaborTrackingCategory is "Kitchen" or cLaborTrackingCategory is "WD Hourly">
					<!--- Kitchen Services does NOT report "Other" Hours. --->
					<cfif  cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">	
						<th bgcolor="#headerCellColor#" colspan="3">
					<cfelse>
						<th bgcolor="#headerCellColor#" colspan="5">
					</cfif>
						<font size="-1" color="white">
							#cDisplayName# Hours
						</font>
					</th>
				<cfelseif cLaborTrackingCategory is "PTO">
					<th bgcolor="#headerCellColor#" colspan="1">
						<font size="-1" color="white">
							#cDisplayName# Paid
						</font>
					</th>	
				<cfelseif cLaborTrackingCategory is "PPADJ">
					<th bgcolor="#headerCellColor#" colspan="1">
						<font size="-1" color="white">
							#cDisplayName#
						</font>
					</th>		
				<cfelse>
					<th bgcolor="#headerCellColor#" colspan="3">
						<font size="-1" color="white">
							#cDisplayName# Hours
						</font>
					</th>
				</cfif>
					
				<!--- Check if the current category was training and insert the total and variances columns. --->
				<cfif bIsTraining eq true>
					<th bgcolor="#headerCellColor#" colspan="3">
						<font size="-1" color="white">
							Total
						</font>
					</th>
				</cfif>
		</cfif>
	</cfloop>
</cfoutput>

</tr>
<!------------------------- COLUMN HEADERS - ROW 2 ------------------------->
<tr>
<cfoutput>
	<th class="locked" bgcolor="#emptyCellColor#" align=center style="#leftPaneStyle#">
		&##160;
	</th>
	<th bgcolor="#emptyCellColor#" colspan="2" align="center">
		<font size=-2>
			CENSUS
		</font>
	</th>
	<th bgcolor="#emptyCellColor#" colspan="1" align="center">
		<font size=-2>
			SERVICE
		</font>
	</th>
	<th bgcolor="#emptyCellColor#" colspan="1" align="center">
		<font size=-2>
			2-PERSON
		</font>
	</th>	
	<cfloop query="dsLaborTrackingCategories">
			<cfif cLaborTrackingCategory is not "WD Salary">
				<!--- Add the Nursing Sub-Total Column Headers. --->
				<cfif cLaborTrackingCategory is "Kitchen">
					<th bgcolor="#emptyCellColor#" colspan="3" align=center>
						<font size=-2>
							SUB-TOTALS
						</font>
					</th>
				</cfif>
				
				<!--- Check if the current Category is NURSING. --->
				<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN" or cLaborTrackingCategory is "Kitchen" or cLaborTrackingCategory is "WD Hourly">
					<!--- Kitchen Services does NOT report "Other" Hours. --->
					<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">
						<th bgcolor="#emptyCellColor#" colspan="3" align=center>
							<font size=-2>
								HOURS WORKED
							</font>
						</th>
					<cfelse>
						<th bgcolor="#emptyCellColor#" colspan="5" align=center>
							<font size=-2>
								HOURS WORKED
							</font>
						</th>
					</cfif>
				<cfelseif cLaborTrackingCategory is "PPADJ">
					<th colspan="3" bgcolor="#emptyCellColor#" align=center>
						<font size="-1">
							&##160;
						</font>
					</th>
					<th colspan="1" bgcolor="#emptyCellColor#" align=center>
						<font size="-1">
							&##160;
						</font>
					</th>			
				<cfelseif cLaborTrackingCategory is "PTO">	
					<th colspan="1" bgcolor="#emptyCellColor#" align=center>
						<font size="-1">
							&##160;
						</font>
					</th>			
				<cfelse>
					<th colspan="3" bgcolor="#emptyCellColor#" align=center>
						<font size="-1">
							&##160;
						</font>
					</th>
				</cfif>
			</cfif>
	</cfloop>
</cfoutput>
</tr>

<!------------------------- COLUMN HEADERS - ROW 3 ------------------------->
<tr>
<cfoutput>
	<th class="locked" bgcolor="#emptyCellColor#" align="center" style="#leftPaneStyle# #topPaneStyle#">
		<font size="-1">
			DAY
		</font>
	</th>
	<th colspan="1" bgcolor="#emptyCellColor#" align="center" style="#topPaneStyle#">
		<font size="-1">
			Prd
		</font>
	</th>
	<th colspan="1" bgcolor="#emptyCellColor#" align="center" style="#topPaneStyle#">
		<font size="-1">
			Units
		</font>
	</th>		
	<th colspan="1" bgcolor="#emptyCellColor#" align="center" style="#topPaneStyle#">
		<font size="-1">
			Points
		</font>
	</th>
	<th colspan="1" bgcolor="#emptyCellColor#" align="center" style="#topPaneStyle#">
		<font size="-1">
			Assists
		</font>
	</th>	
		<cfloop query="dsLaborTrackingCategories">
			<cfif cLaborTrackingCategory is not "WD Salary">
					<!--- The Nursing Sub-Total columns will be placed before kitchen services. --->
					<!--- Add the Nursing Sub-Total Column Headers. --->
					<cfif cLaborTrackingCategory is "Kitchen">
						<th colspan="1" bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Actual
							</font>
						</th>				
						<th colspan="1" bgcolor="#budgetcellcolor#" style="width: 0px; #topPaneStyle#">
							<font size="-1">
								Var Bgt
							</font>
						</th>
						<th colspan="1" bgcolor="#emptyCellColor#" style="width: 0px; #topPaneStyle#">
							<font size="-1">
								Variance
							</font>
						</th>		
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Regular
							</font>
						</th>
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Overtime
							</font>
						</th>
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Actual
							</font>
						</th>
						<th bgcolor="#budgetcellcolor#" style="#topPaneStyle#">
							<font size="-1">
								Var Bgt
							</font>
						</th>	
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Variance
							</font>
						</th>							
						<!--- Kitchen Services does NOT report "Other" Hours. --->
					<cfelseif cLaborTrackingCategory is "WD Hourly">
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Regular
							</font>
						</th>
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Overtime
							</font>
						</th>
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Actual
							</font>
						</th>
						<th bgcolor="#budgetcellcolor#" style="#topPaneStyle#">
							<font size="-1">
								Var Bgt
							</font>
						</th>	
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Variance
							</font>
						</th>							
					<cfelseif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Regular
							</font>
						</th>
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Overtime
							</font>
						</th>					
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Other
							</font>
						</th>
					<cfelse>
						<cfif cLaborTrackingCategory is not "PPADJ">
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
								<font size="-1">
									Actual
								</font>
							</th>			
							<th bgcolor="#budgetcellcolor#" style="#topPaneStyle#">
								<font size="-1">
									Var Bgt
								</font>
							</th>	
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
								<font size="-1">
									Variance
								</font>
							</th>	
						</cfif>
					</cfif>
				</cfif>
		</cfloop>
		<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
			<font size="-1">
				&##160;
			</font>
		</th>					
		<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
			<font size="-1">
				&##160;
			</font>
		</th>
	</tr>
</thead>
<tbody>
<!--- Accumulates the MTD Training Budget. --->
<cfset trainingBudgetMtd = 0>
<!--- Accumulates the MTD Census, Occupancy, and Service Points.  The Budget is accumulated as well. --->
<cfset censusMtd = 0.0>
<cfset occupancyMtd = 0.0>
<cfset pointsMtd = 0.0>
<cfset censusBudgetMtd = 0.0>
<cfset twoPersonAssistsMtd = 0.0>
<!--- SHOW DETAILS - ALL DAYS UP TO THE CURRENT DAY OR THE END OF THE MONTH --->
<cfloop from="1" to="#currentd#" index="currentDay">
	<!--- Fetch the labor data for the current day. --->
	<cfset dsCurrentLaborTrackingData = #helperObj.FetchLaborHoursForDay(dsLaborTrackingHours, currentDay)#>
	<tr>
		<!--- get today's occupancy and multiply it by the budgeted food expense per resident day --->
		<td class="locked" bgcolor="#emptyCellColor#" align="center" style="#leftPaneStyle#">
			<font size="-1">
				#currentDay#
			</font>
		</td>
		<td align="right"  style="padding-right: 5px;">
			<font size="-1">
				<cfset currentCensus = #helperObj.FetchTenantsForDay(dsCensusDetails, currentDay)#>
				#helperObj.LaborNumberFormat(currentCensus, "0")#
				<cfset censusMtd = #censusMtd# + #currentCensus#>	
				<cfset censusBudgetMtd = #censusBudgetMtd# + #dailyCensusBudget#>		
			</font>
		</td>		
		<td align="right"  style="padding-right: 5px;">
			<font size="-1">
				<cfset currentOccupancy = #helperObj.FetchOccupancyForDay(dsCensusDetails, currentDay)#>
				#helperObj.LaborNumberFormat(currentOccupancy, "0.0")#
				<cfset occupancyMtd = #occupancyMtd# + #currentOccupancy#>	
			</font>
		</td>			
		<td align="right"  style="padding-right: 5px;">
			<font size="-1">
				<cfset currentPoints = #helperObj.FetchPointsForDay(dsCensusDetails, currentDay)#>
				#helperObj.LaborNumberFormat(currentPoints, "0")#
				<cfset pointsMtd = #pointsMtd# + #currentPoints#>	
			</font>
		</td>		
		<td align="right" style="padding-right: 5px;">
			<font size="-1">
				<cfset twoPersonAssists = #helperObj.FetchTwoPersonAssistsForDay(dsTwoPersonAssists, currentDay)#>
				#helperObj.LaborNumberFormat(twoPersonAssists, "0")#
				<cfset twoPersonAssistsMtd = #twoPersonAssistsMtd# + #twoPersonAssists#>	
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
		<cfloop query="dsCurrentLaborTrackingData">
			<cfif cLaborTrackingCategory is not "WD Salary">
				<!--- Check if the current column should be displayed. --->
				<cfif bIsVisible eq true>
					<!--- --->
					<cfswitch expression="#cLaborTrackingCategory#">
						<!--- Check if the current category is a Nursing Category. --->
						<cfcase value="WD Hourly">
							<!--- Calculate the WD Variance, which gets displayed at the end of this case --->
							<cfif open is 1 or 
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 1 and DateFormat(dsLaborTrackingWDSInfo.dTermdate, "dd") lt currentDay)) or
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 0 and DateFormat(dsLaborTrackingWDSInfo.dHiredate-1, "dd") gte currentDay))>
								<cfset WDVariance = fVariableBudget - (fRegular + fOvertime)>
							<cfelse>
								<cfset WDVariance = 0>
							</cfif>
							
							<!--- Add the current category's hours to the daily total. --->
							<cfif open is 1 or 
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 1 and DateFormat(dsLaborTrackingWDSInfo.dTermdate, "dd") lt currentDay)) or
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 0 and DateFormat(dsLaborTrackingWDSInfo.dHiredate-1, "dd") gte currentDay))>
								<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime#>
							<cfelse>
								<cfset totalDailyHours = #totalDailyHours# + 0>
							</cfif>
							<!--- Add the current category's budget hours to the daily total. --->
							<cfif open is 1 or 
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 1 and DateFormat(dsLaborTrackingWDSInfo.dTermdate, "dd") lt currentDay)) or
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 0 and DateFormat(dsLaborTrackingWDSInfo.dHiredate-1, "dd") gte currentDay))>
								<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>							
							<cfelse>
								<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + 0>							
							</cfif>
							<!--- Display the WD Regular, OT, Total, Budget, and Variance Hours. --->
							<td align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fRegular, "0.0")#
								</font>
							</td>
							<td align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fOvertime, "0.0")#
								</font>
							</td>		
							<td align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fRegular + fOvertime, "0.0")#
								</font>
							</td>		
							<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
								<font size="-1">
							<cfif open is 1 or 
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 1 and DateFormat(dsLaborTrackingWDSInfo.dTermdate, "dd") lt currentDay)) or
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 0 and DateFormat(dsLaborTrackingWDSInfo.dHiredate-1, "dd") gte currentDay))>
									#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
									<cfset totalvarbgt = #totalvarbgt# + #fVariableBudget#>
									<cfset conditionalTrue = 1><cfset conditionalFalse = 0>
							<cfelse>
								-
								<cfif open is 0 and conditionalTrue is 1>
									<cfset conditionalFalse = 0>
								<cfelseif WDStermed is 0>
									<cfset conditionalFalse = 0>
								<cfelse>
									<cfset conditionalFalse = 1>
								</cfif>
							</cfif>
							<cfif conflict is 1> <cfset conditionalTrue = 1> </cfif>
								</font>
							</td>
							<td align="right" style="padding-right: 5px;">
								<font size="-1" color="<cfif WDVariance lt 0>Red<cfelse>Black</cfif>">
									#helperObj.LaborNumberFormat(WDVariance, "0.00")#
									<cfset totalvariance = #totalvariance# + #WDVariance#>
								</font>
							</td>																
						</cfcase>
							<cfcase value="Resident Care,Nurse Consultant,LPN - LVN">
							<!--- Add the current category's budget total. --->
							<cfset nursingBudgetTotalHours = #nursingBudgetTotalHours# + #fVariableBudget#>
							<!--- Add the current category's hours to the nursing daily total. --->
							<cfset nursingTotalHours = #nursingTotalHours# + #fRegular# + #fOvertime# + #fOther#>
						
							<!--- Add the current category's hours to the daily total. --->
							<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime# + #fOther#>
							<!--- Add the current category's budget hours to the daily total. --->
							<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>					
						
							<!--- Display the Reg/OT/Other columns. --->
							<td align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fRegular, "0.0")#
								</font>
							</td>
							<td align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fOvertime, "0.0")#
								</font>
							</td>
							<td align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fOther, "0.0")#
								</font>
							</td>
						</cfcase>
						<!--- Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->			
						<cfcase value="Kitchen">
							<!--- Calculate the Nursing Sub-Total's variance. --->
							<cfset nursingDailyVariance = #nursingBudgetTotalHours# - #nursingTotalHours#>
					
							<!--- Add the current category's hours to the daily total. --->
							<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime#>
							<!--- Add the current category's budget hours to the daily total. --->
							<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>							
							
							<!--- Display the Nursing Sub-Totals. --->
							<td colspan="1" align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(nursingTotalHours, "0.0")#
								</font>
							</td>						
							<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(nursingBudgetTotalHours, "0.00")#
								</font>
							</td>
							<td align="right" style="padding-right: 5px;">
								<font size="-1" color="<cfif nursingDailyVariance lt 0>Red<cfelse>Black</cfif>">
									#helperObj.LaborNumberFormat(nursingDailyVariance, "0.00")#
								</font>
							</td>		
							<!--- Calculate the Kitchen Variance, which gets displayed at the end of this case --->
							<cfset kitchenVariance = fVariableBudget - (fRegular + fOvertime)>
							
							<!--- Display the Kitchen Regular, OT, Total, Budget, and Variance Hours. --->
							<td align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fRegular, "0.0")#
								</font>
							</td>
							<td align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fOvertime, "0.0")#
								</font>
							</td>		
							<td align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fRegular + fOvertime, "0.0")#
								</font>
							</td>		
							<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
								</font>
							</td>
							<td align="right" style="padding-right: 5px;">
								<font size="-1" color="<cfif kitchenVariance lt 0>Red<cfelse>Black</cfif>">
									#helperObj.LaborNumberFormat(kitchenVariance, "0.00")#
								</font>
							</td>																
						</cfcase>
						<cfcase value="PPADJ">
							<td align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fAll, "0.0")#
								</font>
							</td>						
						</cfcase>
						
						<!--- Display the Non-Nursing--->
						<cfdefaultcase>
							<!--- Check if the current Category is PTO and only display Actual if it is. --->
							<cfif cLaborTrackingCategory is "PTO">
								<!--- Display the PTO Hours. --->
								<td align="right" style="padding-right: 5px;">
									<font size="-1">
										#helperObj.LaborNumberFormat(fAll, "0.0")#
									</font>
								</td>						
							<cfelse>
								<!--- Add the current category's hours to the daily total. --->
								<cfset totalDailyHours = #totalDailyHours# + #fAll#>
								<!--- Stores the current Column's Variance, which is Var Bgt minus Actual Hours --->
								<cfset categoryVariance = #fVariableBudget# - #fAll#>						
								<!--- Display the Non-Nursing Hours. --->
								<td align="right" style="padding-right: 5px;"> 
									<font size="-1">
										#helperObj.LaborNumberFormat(fAll, "0.0")#
									</font>
								</td>
								<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
									<font size="-1">
										#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
									</font>
								</td>
								<td align="right" style="padding-right: 5px;">
									<font size="-1" color="<cfif categoryVariance lt 0>Red<cfelse>Black</cfif>">
										#helperObj.LaborNumberFormat(categoryVariance, "0.00")#
									</font>
								</td>						
								<!--- Add the current category's budget hours to the daily total. --->
								<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>										
								<cfif bIsTraining eq true>
									<!--- Add to the MTD Training Budget. --->
									<cfset trainingBudgetMtd = #trainingBudgetMtd# + #fVariableBudget#>
									<!--- Stores the current day's Variance, which is Var Bgt minus Actual Hours --->
									<cfset currentDaysVariance = #totalDailyBudgetHours# - #totalDailyHours#>							
									<!--- Display the TOTAL Hours. --->
	
									<td align="right" style="padding-right: 5px;">
										<font size="-1">
											<strong>
												#helperObj.LaborNumberFormat(totalDailyHours, "0.0")#
											</strong>
										</font>
									</td>
									<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
										<font size="-1">
											#helperObj.LaborNumberFormat(totalDailyBudgetHours, "0.00")#
										</font>
									</td>
									<td align="right" style="padding-right: 5px;">
										<font size="-1" color="<cfif currentDaysVariance lt 0>Red<cfelse>Black</cfif>">
											#helperObj.LaborNumberFormat(currentDaysVariance, "0.00")#
										</font>
									</td>			
								</cfif>
							</cfif>	
						</cfdefaultcase>>	
					</cfswitch>		
				</cfif>
			</cfif>
		</cfloop>
	</tr>
</cfloop>



<!------------------------- MTD ACTUAL HOURS - TOTALS ------------------------->
<tfoot>
	<tr>
		<td class="locked" align="right" bgcolor="#totalcellcolor#" style="#leftPaneStyle#">
			<font size="-1">
				<strong>
					Total
				</strong>
			</font>
		</td>
		<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
			<font size="-1">
				<strong>
					#helperObj.LaborNumberFormat(censusMtd, "0")#
				</strong>
			</font>
		</td>
		<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
			<font size="-1">
				<strong>
					#helperObj.LaborNumberFormat(occupancyMtd, "0")#
				</strong>
			</font>
		</td>			
		<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
			<font size="-1">
				<strong>
					#helperObj.LaborNumberFormat(pointsMtd, "0")#
				</strong>
			</font>
		</td>
		<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
			<font size="-1">
				<strong>
					#helperObj.LaborNumberFormat(twoPersonAssistsMtd, "0")#
				</strong>
			</font>
		</td>
		<!--- Fetch the labor data totals for the current month. --->
		<cfset dsTotalLaborTrackingData = #helperObj.FetchLaborHoursForMTD(dsLaborTrackingHours)#>
		<!--- Stores the total number of hours worked for all Nursing categories, which includes Regular, Overtime, and Other. --->
		<cfset nursingMtdTotalHours = 0.0>
		<!--- Stores the total number of Nursing Variable Budget Hours. --->
		<cfset nursingMtdBudgetHours = 0.0>
		<!--- Stores the total number of hours for the current mtd. --->
		<cfset totalMtdHours = 0.0>
		<!--- Stores te total budget hours for the current mtd. --->
		<cfset totalMtdBudgetHours = 0.0>
		<!--- loop through labor categories --->
		<Cfloop query="dsTotalLaborTrackingData">
			<cfif cLaborTrackingCategory is not "WD Salary">
				<!--- Check if the current column should be displayed. --->
				<cfif bIsVisible eq true>
					<cfif cLaborTrackingCategory is "WD Hourly">
	
						<!--- Add the current category's hours to the mtd total. --->
						<cfif open is 1 or conditionalTrue is 1>
							<cfset totalMtdHours = #totalMtdHours# + #fRegular# + #fOvertime#>
						<cfelse> <cfset totalMtdHours = #totalMtdHours# + 0> </cfif>
						<!--- Add the current category's budget hours to the mtd total. --->
						<cfif open is 1 or conditionalTrue is 1>
							<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #totalvarbgt#>		<!---#fVariableBudget#--->					
						<cfelse> <cfset totalMtdBudgetHours = #totalMtdBudgetHours# + 0> </cfif>
						<!--- Stores the current Categories MTD Variance --->
						<cfif open is 1 or (conditionalTrue is 1 and conflict is 0)>
							<cfset categoryMtdVariance = #totalvarbgt# - (#fRegular# + #fOvertime#)>   <!---#fVariableBudget#--->
						<cfelse> <cfset categoryMtdVariance = 0> </cfif>
						
						<td align="right" bgcolor="#totalcellcolor#"  style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(fRegular, "0.0")#
								</strong>
							</font>
						</td>
						<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(fOvertime, "0.0")#
								</strong>
							</font>
						</td>		
						<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(fRegular + fOvertime, "0.0")#
								</strong>
							</font>
						</td>		
						<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1">
								<strong>
									<cfif open is 1 or conditionalTrue is 1>
										#helperObj.LaborNumberFormat(totalvarbgt, "0.00")#	<!---fVariableBudget--->
									<cfelse>-</cfif>
								</strong>
							</font>
						</td>
						<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1" color="<cfif categoryMtdVariance lt 0>Red<cfelse>Black</cfif>">
								<strong>
									#helperObj.LaborNumberFormat(categoryMtdVariance, "0.00")#
								</strong>
							</font>
						</td>		
					<!--- Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total. --->
					<cfelseif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">			
						<!--- Add the current category's hours to the nursing mtd total. --->
						<cfset nursingMtdTotalHours = #nursingMtdTotalHours# + #fRegular# + #fOvertime# + #fOther#>
						<!--- Add the current category's Variable Budget Hours to the nursing mtd budget total. --->
						<cfset nursingMtdBudgetHours = #nursingMtdBudgetHours# + #fVariableBudget#>
									
						<!--- Add the current category's hours to the mtd total. --->
						<cfset totalMtdHours = #totalMtdHours# + #fRegular# + #fOvertime# + #fOther#>
						<!--- Add the current category's budget hours to the mtd total. --->
						<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fVariableBudget#>					
						
						<!--- Display the Reg/OT/Other columns. --->
						<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(fRegular, "0.0")#
								</strong>
							</font>
						</td>
						<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(fOvertime, "0.0")#
								</strong>
							</font>
						</td>
						<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1">
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
						<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fVariableBudget#>							
					
						<!--- Stores the Nursing Variance, which is Total Variable Budget - Total Actual Hours --->
						<cfset nursingMtdVarianceHours = #nursingMtdBudgetHours# - #nursingMtdTotalHours#>
						
						<!--- Stores the Kitchen Variance, which is Variable Budget - Total Actual --->
						<cfset kitchenMtdVariance = #fVariableBudget# - (#fRegular# + #fOvertime#)>
						
						<!--- Display the Nursing Sub-Totals. --->
						<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(nursingMtdTotalHours, "0.0")#
								</strong>
							</font>
						</td>
						<td colspan="1" align="right"  bgcolor="#totalcellcolor#"  style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(nursingMtdBudgetHours, "0.00")#
								</strong>
							</font>
						</td>
						<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1" color="<cfif nursingMtdVarianceHours lt 0>Red<cfelse>Black</cfif>">
								<strong>
									#helperObj.LaborNumberFormat(nursingMtdVarianceHours, "0.00")#
								</strong>
							</font>
						</td>
						<!--- Display the Kitchen Regular and Overtime Hours. --->
						<td align="right" bgcolor="#totalcellcolor#"  style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(fRegular, "0.0")#
								</strong>
							</font>
						</td>
						<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(fOvertime, "0.0")#
								</strong>
							</font>
						</td>		
						<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(fRegular + fOvertime, "0.0")#
								</strong>
							</font>
						</td>		
						<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
								</strong>
							</font>
						</td>
						<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1" color="<cfif kitchenMtdVariance lt 0>Red<cfelse>Black</cfif>">
								<strong>
									#helperObj.LaborNumberFormat(kitchenMtdVariance, "0.00")#
								</strong>
							</font>
						</td>		
					<cfelseif cLaborTrackingCategory is "PPADJ">
						<!--- Display the Total MTD PPADJ Hours. --->
						<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(fAll, "0.0")#
								</strong>
							</font>
						</td>								
					<!--- Check if the current Category is PTO and only display Actual if it is. --->
					<cfelseif cLaborTrackingCategory is "PTO">
						<!--- Display the Total MTD PTO Hours. --->
						<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(fAll, "0.0")#
								</strong>
							</font>
						</td>								
					<cfelse>					
						<!--- Add the current category's hours to the daily total. --->
						<cfset totalMtdHours = #totalMtdHours# + #fAll#>
						<!--- Stores the current Categories MTD Variance --->
						<cfset categoryMtdVariance = #fVariableBudget# - #fAll#>
						<!--- Check if the current category is Training --->
						<cfif bIsTraining eq true>
							<!--- Add the current category's budget hours to the mtd total. --->
							<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #trainingBudgetMtd#>		
							<!--- Stores the Total MTD Variance, which is Total Variable Budget minus Total Actual Hours --->
							<cfset mtdVariance = #totalMtdBudgetHours# - #totalMtdHours#>
							<!--- Stores the Training MTD Variance, which is Total Training Var Bgt minus Total Training Hours --->
							<cfset trainingMtdVariance = #fVariableBudget# - #fAll#>
							<!--- Display the Training Hours. --->
							<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
								<font size="-1">
									<strong>
										#helperObj.LaborNumberFormat(fAll, "0.0")#
									</strong>
								</font>
							</td>
							<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
								<font size="-1">
									<strong>
										#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
									</strong>
								</font>
							</td>
							<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
								<font size="-1" color="<cfif trainingMtdVariance lt 0>Red<cfelse>Black</cfif>">
									<strong>
										#helperObj.LaborNumberFormat(trainingMtdVariance, "0.00")#
									</strong>
								</font>
							</td>							
							<!--- Display the TOTAL Hours. --->
							<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
								<font size="-1">
									<strong>
										#helperObj.LaborNumberFormat(totalMtdHours, "0.0")#
									</strong>
								</font>
							</td>
							<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
								<font size="-1">
									<strong>
										#helperObj.LaborNumberFormat(totalMtdBudgetHours, "0.00")#
									</strong>
								</font>
							</td>						
							<!--- Display the Day's Variance. --->
							<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
								<font size="-1" color="<cfif mtdVariance lt 0>Red<cfelse>Black</cfif>">
									<strong>
										#helperObj.LaborNumberFormat(mtdVariance, "0.00")#
									</strong>
								</font>
							</td>							
						<cfelse>				
							<!--- Display the Non-Nursing Hours. --->
							<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
								<font size="-1">
									<strong>
										#helperObj.LaborNumberFormat(fAll, "0.0")#
									</strong>
								</font>
							</td>
							<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
								<font size="-1">
									<strong>
										#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
									</strong>
								</font>
							</td>
							<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
								<font size="-1" color="<cfif categoryMtdVariance lt 0>Red<cfelse>Black</cfif>">
									<strong>
										#helperObj.LaborNumberFormat(categoryMtdVariance, "0.00")#
									</strong>
								</font>
							</td>	
							<!--- Add the current category's budget hours to the daily total. --->
							<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fVariableBudget#>								
						</cfif>																	
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
	</tr>
	
	<!---
	<!------------------------- MTD BUDGET TOTALS ------------------------->
	<tr>
		<td class="locked" align="right" bgcolor="#budgetcellcolor#" style="#leftPaneStyle#">
			<font size="-1">
				MTD Budget
			</font>
		</td>
		<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
			<font size="-1">
				#helperObj.LaborNumberFormat(censusBudgetMtd, "0")#
			</font>
		</td>
		<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>
		<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>	
		<!--- Fetch the labor data totals for the current month. --->
		<cfset dsTotalLaborTrackingData = #helperObj.FetchLaborHoursForMTD(dsLaborTrackingHours)#>
		<!--- Accumulates the current mtd's budget for all Nursing Categories. --->
		<cfset nursingBudgetMtdTotalHours = 0>	
		<!--- Stores te total budget hours for the current mtd. --->
		<cfset totalMtdBudgetHours = 0>
		<!--- loop through labor categories --->
		<cfloop query="dsTotalLaborTrackingData">
			<!--- Check if the current column should be displayed. --->
			<cfif bIsVisible eq true>
				<!--- Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total. --->
				<cfif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">			
					<!--- Add the current category's budget total. --->
					<cfset nursingBudgetMtdTotalHours = #nursingBudgetMtdTotalHours# + #fBudget#>
				
					<!--- Add the current category's budget hours to the mtd total. --->
					<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fBudget#>					
					
					<!--- Display the Reg/OT/Other columns. --->
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							#helperObj.LaborNumberFormat(fBudget, "0.0")#
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							-
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							-
						</font>
					</td>
				<!--- Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
				<cfelseif cLaborTrackingCategory is "Kitchen">

					<!--- Add the current category's budget hours to the mtd total. --->
					<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fBudget#>							
					
					<!--- Display the Nursing Sub-Totals. --->
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							#helperObj.LaborNumberFormat(nursingBudgetMtdTotalHours, "0.00")#
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							-
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							-
						</font>
					</td>
					
					<!--- Display the Kitchen Regular and Overtime Hours. --->
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							#helperObj.LaborNumberFormat(fBudget, "0.0")#
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							-
						</font>
					</td>
										
				<cfelse>	
					<cfif bIsTraining eq true>

						<!--- Add the current category's budget hours to the mtd total. --->
						<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #trainingBudgetMtd#>		
					
						<!--- Display the Training Budget Hours. --->
						<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
							<font size="-1">
								#helperObj.LaborNumberFormat(trainingBudgetMtd, "0.0")#
							</font>
						</td>
						
						<!--- Display the TOTAL Hours. --->
						<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
							<font size="-1">
								#helperObj.LaborNumberFormat(totalMtdBudgetHours, "0.0")#
							</font>
						</td>
						
						<!--- Display the empty cells for variance and pto. --->
						<td align="right" bgcolor="#emptyCellColor#" style="padding-right: 5px;">
							<font size="-1">
								&##160;
							</font>
						</td>
						<td align="right" bgcolor="#emptyCellColor#" style="padding-right: 5px;">
							<font size="-1">
								&##160;
							</font>
						</td>
						
						<!--- Leave the LOOP. --->
						<cfbreak>
						
					<cfelse>
						<!--- Display the Non-Nursing Hours. --->
						<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
							<font size="-1">
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
		<td class="locked" align="right" bgcolor="#varianceCellColor#" style="#leftPaneStyle#">
			<font size="-1">
				<strong>
					MTD Variance
				</strong>
			</font>
		</td>		
		<!--- Display the Census Variance column. --->
		<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
			<font size="-1" color="<cfif (censusMtd - censusBudgetMtd) lt 0>Red<cfelse>Black</cfif>">
				<strong>
					#helperObj.LaborNumberFormat(censusMtd - censusBudgetMtd, "0")#
				</strong>
			</font>
		</td>
		<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>
		<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
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
					
					<!--- Add to the variance accumulators (Total Nursing and Total) --->
					<cfset nursingMtdVariance = nursingMtdVariance + (fBudget - fRegular - fOvertime - fOther)>
					<cfset totalMtdVariance = totalMtdVariance + (fBudget - fRegular - fOvertime - fOther)>
					
					<!--- Display the Nursing Regular column. --->
					<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
						<font size="-1" color="<cfif (fBudget - fRegular) lt 0>Red<cfelse>Black</cfif>">
							<strong>
								#helperObj.LaborNumberFormat(fBudget - fRegular, "0.0")#
							</strong>
						</font>
					</td>
					<!--- Display the Nursing Overtime column. --->
					<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
						<font size="-1" color="<cfif fOvertime gt 0>Red<cfelse>Black</cfif>">
							<strong>
								#helperObj.LaborNumberFormat(-fOvertime, "0.0")#
							</strong>
						</font>
					</td>
					<!--- Display the Nursing Other column. --->
					<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
						<font size="-1" color="<cfif fOther gt 0>Red<cfelse>Black</cfif>">
							<strong>
								#helperObj.LaborNumberFormat(-fOther, "0.0")#
							</strong>
						</font>
					</td>
		
				<!--- Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
				<cfelseif cLaborTrackingCategory is "Kitchen">
					<!--- Display the Nursing Sub-Totals. --->
					<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							<strong>
								-
							</strong>
						</font>
					</td>
					<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							<strong>
								-
							</strong>
						</font>
					</td>
					<!--- Check if the value should be red. --->
					<cfif nursingMtdVariance lt 0>
						<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
							<font size="-1" color="red">
								<strong>
									#helperObj.LaborNumberFormat(nursingMtdVariance, "0.00")#
								</strong>
							</font>
						</td>
					<cfelse>
						<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
							<font size="-1">
								<strong>
									#helperObj.LaborNumberFormat(nursingMtdVariance, "0.00")#
								</strong>
							</font>
						</td>
					</cfif>
					<!--- Check if the value should be red. --->
					<cfif (fBudget - fRegular) lt 0>
						<!--- Display the Kitchen Regular and Overtime Hours. --->
						<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
							<font size="-1" color="red">
								<strong>
									#helperObj.LaborNumberFormat(fBudget - fRegular, "0.0")#
								</strong>
							</font>
						</td>
					<cfelse>
						<!--- Display the Kitchen Regular and Overtime Hours. --->
						<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
							<font size="-1">
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
						<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
							<font size="-1" color="red">
								<strong>
									#helperObj.LaborNumberFormat(-fOvertime, "0.0")#
								</strong>
							</font>
						</td>
					<cfelse>
						<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
							<font size="-1">
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
							<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
								<font size="-1" color="red">
									<strong>
										#helperObj.LaborNumberFormat(trainingBudgetMtd - fAll, "0.0")#
									</strong>
								</font>
							</td>
						<cfelse>
							<!--- Display the Training Hours. --->
							<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
								<font size="-1">
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
							<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
								<font size="-1" color="red">
									<strong>
										#helperObj.LaborNumberFormat(totalMtdVariance, "0.0")#
									</strong>
								</font>
							</td>
						<cfelse>
							<!--- Display the TOTAL Variance Hours. --->
							<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
								<font size="-1">
									<strong>
										#helperObj.LaborNumberFormat(totalMtdVariance, "0.0")#
									</strong>
								</font>
							</td>
						</cfif>

						<!--- Display the empty cells for variance and pto. --->
						<td align="right" bgcolor="#emptyCellColor#" style="padding-right: 5px;">
							<font size="-1">
								&##160;
							</font>
						</td>
						<td align="right" bgcolor="#emptyCellColor#" style="padding-right: 5px;">
							<font size="-1">
								&##160;
							</font>
						</td>
						
						<!--- Leave the LOOP. --->
						<cfbreak>
		
					<cfelse>
						<!--- Check if the non-nursing Budget minus Actual is less than 0 (neg number = red). --->
						<cfif (fBudget - fAll) lt 0>
							<!--- Display the Non-Nursing Hours. --->
							<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
								<font size="-1" color="red">
									<strong>
										#helperObj.LaborNumberFormat(fBudget - fAll, "0.0")#
									</strong>
								</font>
							</td>
						<cfelse>
							<!--- Display the Non-Nursing Hours. --->
							<td align="right" bgcolor="#varianceCellColor#" style="padding-right: 5px;">
								<font size="-1">
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
	--->
	
	<!------------------------- MTD VARIABLE BUDGET - TOTALS ------------------------->
	<tr>
		<td class="locked" align="right" bgcolor="#budgetCellColor#" style="#leftPaneStyle#">
			<font size="-1">
				Variable Budget
			</font>
		</td>
		<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>
		<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>				
		<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>
		<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>	
		<!--- Stores the total and nursing variable budget foots for the mtd. --->
		<cfset variableBudgetTotal = 0.0>
		<cfset nursingVariableBudgetTotal = 0.0>
		<!--- loop through labor categories --->
		<cfloop query="dsLaborVariableBudgets">
			<cfif cLaborTrackingCategory is not "WD Salary">
				<!--- Add the current category's var budget hours to the mtd total. --->
				<cfif cLaborTrackingCategory is "WD Hourly">
					<cfif conditionalFalse is 0>
						<cfset variableBudgetTotal = #variableBudgetTotal# + #totalvarbgt#>	<!---#fVariableBudget#--->
					<cfelse>				
						<cfset variableBudgetTotal = #variableBudgetTotal# + #fVariableBudget#>
					</cfif>
				<cfelse> <cfset variableBudgetTotal = #variableBudgetTotal# + #fVariableBudget#>
				</cfif>
				<cfif cLaborTrackingCategory is "WD Hourly">
					<cfif open is 0>	
						<!---<cfif conditionalFalse is 0>--->
							<cfset variableBudgetTotal = #variableBudgetTotal# - #totalvarbgt#>
						<cfelse>				
							<cfset variableBudgetTotal = #variableBudgetTotal# - #fVariableBudget#>
						</cfif>
					<!---</cfif>--->
				</cfif>	
				
				<!--- Stores the name of the current Tooltip Popup Div Element. --->
				<cfset currentTooltipDivName = "divVariableBudgetPopup" & dsLaborVariableBudgets.CurrentRow>
				<!--- Stores all of the styles required for the standard tooltip Div element. --->
				<cfset currentTooltipDivStyles = "font-size: 8pt; font-family: tahoma; z-index: 140; padding: 2px; background-color: ##d9d9c2; display: none;">
				
				<cfif cLaborTrackingCategory is "WD Hourly">
					<cfif conditionalFalse is 0>
						<cfset variableBudgetTotal = #variableBudgetTotal# + #totalvarbgt#>	<!---#fVariableBudget#--->
					<cfelse>				
						<cfset variableBudgetTotal = #variableBudgetTotal# + #fVariableBudget#>
					</cfif>
					
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>		
							
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							<cfif cDescription Is "">
								<cfif open is 1 or conditionalTrue is 1>
									#helperObj.LaborNumberFormat(totalvarbgt, "0.00")#		<!---fVariableBudget--->
								<cfelse> -
								</cfif>
							<cfelse>
								<a style="width: 100%; height: 100%; text-align: right; vertical-align: top; padding-top: 8px; cursor: hand; text-decoration: none; color: black;" title="Click to see Variable Budget Description" titleDisplay="Labor Tracking Variable Budget Formula Description" href='###currentTooltipDivName#' class='load-local' rel='###currentTooltipDivName#'>
								<cfif open is 1 or conditionalTrue is 1>
										#helperObj.LaborNumberFormat(totalvarbgt, "0.00")#		<!---fVariableBudget--->
								<cfelse> -
								</cfif>
								</a>
								<div id="#currentTooltipDivName#" style="#currentTooltipDivStyles#">
									#cDescription#
								</div>
							</cfif>
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>	
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>							
				
				<!--- Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total. --->
				<cfelseif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">			
					<!--- Add the current category's var budget hours to the nursing mtd total. --->
					<cfset nursingVariableBudgetTotal = #nursingVariableBudgetTotal# + #fVariableBudget#>
					<!--- Display the Reg/OT/Other columns. --->
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							<cfif cDescription Is "">
								#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
							<cfelse>
								<a style="width: 100%; height: 100%; text-align: right; vertical-align: top; padding-top: 8px; cursor: hand; text-decoration: none; color: black;" title="Click to see Variable Budget Description" titleDisplay="Labor Tracking Variable Budget Formula Description" href='###currentTooltipDivName#' class='load-local' rel='###currentTooltipDivName#'>
									#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
								</a>
								<div id="#currentTooltipDivName#" style="#currentTooltipDivStyles#">
									#cDescription#
								</div>
							</cfif>
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>
				<!--- Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
				<cfelseif cLaborTrackingCategory is "Kitchen">
					<!--- Display the Nursing Sub-Total columns. --->					
					<td colspan="1" align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							#helperObj.LaborNumberFormat(nursingVariableBudgetTotal, "0.00")#
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>		
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>				
					<!--- Display the Kitchen columns. --->
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>		
							
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							<cfif cDescription Is "">
								#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
							<cfelse>
								<a style="width: 100%; height: 100%; text-align: right; vertical-align: top; padding-top: 8px; cursor: hand; text-decoration: none; color: black;" title="Click to see Variable Budget Description" titleDisplay="Labor Tracking Variable Budget Formula Description" href='###currentTooltipDivName#' class='load-local' rel='###currentTooltipDivName#'>
									#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
								</a>
								<div id="#currentTooltipDivName#" style="#currentTooltipDivStyles#">
									#cDescription#
								</div>
							</cfif>
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>	
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>							
				<cfelse>
					<cfif cLaborTrackingCategory is not "PPADJ">
					<!--- Display the Non-Nursing Hours. --->
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							<cfif cDescription Is "">
								#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
							<cfelse>
								<a style="width: 100%; height: 100%; text-align: right; vertical-align: top; padding-top: 8px; cursor: hand; text-decoration: none; color: black;" title="Click to see Variable Budget Description" titleDisplay="Labor Tracking Variable Budget Formula Description" href='###currentTooltipDivName#' class='load-local' rel='###currentTooltipDivName#'>
									#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
								</a>
								<div id="#currentTooltipDivName#" style="#currentTooltipDivStyles#">
									#cDescription#
								</div>
							</cfif>
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>	
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>		
					</cfif>							
				</cfif>
			</cfif>
		</cfloop>
		<!--- Display the Variable Budget Total. --->
		<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
			<font size="-1">
				#helperObj.LaborNumberFormat(variableBudgetTotal, "0.00")#
			</font>
		</td>
		<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>	
		<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>	
		<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>						
		<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>						
	</tr>
	
	<!------------------------- MTD VARIABLE BUDGET VARIANCE - TOTALS ------------------------->
	<cfset dsVariableBudgetsWithActual = helperObj.FetchLaborVariableBudgetsWithActual(dsLaborVariableBudgets, dsTotalLaborTrackingData)>
	<tr>
		<td class="locked" align="right" bgcolor="#variableBudgetVarianceCellColor#" style="#leftPaneStyle#">
			<font size="-1">
				<strong>
					Var Bgt Variance
				</strong>
			</font>
		</td>
		<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>
		<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>		
		<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>
		<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>		
		<!--- Stores the variable budget variance total. --->
		<cfset variableBudgetVarianceTotal = 0>
		<!--- loop through labor categories --->
		<cfloop query="dsVariableBudgetsWithActual">
			<cfif cLaborTrackingCategory is not "WD Salary">
				<cfif cLaborTrackingCategory is "WD Hourly">
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>						
					<!--- Stores the WDH MTD Variance. --->
					<cfif conflict is 1>
						<cfset WDMtdVariance = 0 - (fRegular + fOvertime)>
					<cfelseif open is 1 or (conditionalTrue is 1 and conflict is 0)>
						<cfset WDMtdVariance = totalvarbgt - (fRegular + fOverTime)>	<!---fVariableBudget--->
					<cfelse>
						<cfset WDMtdVariance = 0>
					</cfif>
					<!--- Update the variable budget variance total for the WDH field. --->
					<cfset variableBudgetVarianceTotal = variableBudgetVarianceTotal + WDMtdVariance>			
					<!--- Display the WDH Reg/OT columns. --->
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
					<cfif open is 1 or (conditionalTrue is 1 and conflict is 0)>
						<font size="-1" color="<cfif WDMtdVariance lt 0>Red<cfelse>Black</cfif>">
							<strong>
								#helperObj.LaborNumberFormat(WDMtdVariance, "0.00")#
							</strong>
						</font>
					<cfelse><font size="-1">&##160;	</font>
					</cfif>
					</td>	
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>		
				
				<!--- Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total. --->
				<cfelseif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" or cLaborTrackingCategory is "LPN - LVN">			
					<!--- Update the variable budget variance total for the current Nursing field. --->
					<cfset variableBudgetVarianceTotal = variableBudgetVarianceTotal + ((fVariableBudget - fRegular) - fOverTime - fOther)>				
					<!--- Display the Reg/OT/Other columns. --->
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1" color="<cfif (fVariableBudget - fRegular) lt 0>Red<cfelse>Black</cfif>">
							<strong>
								#helperObj.LaborNumberFormat(fVariableBudget - fRegular, "0.00")#
							</strong>
						</font>
					</td>	
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1" color="<cfif fOverTime gt 0>Red<cfelse>Black</cfif>">
							<strong>
								#helperObj.LaborNumberFormat(-fOverTime, "0.0")#
							</strong>
						</font>
					</td>
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1" color="<cfif fOther gt 0>Red<cfelse>Black</cfif>">
							<strong>
								#helperObj.LaborNumberFormat(-fOther, "0.0")#
							</strong>
						</font>
					</td>
				<!--- Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
				<cfelseif cLaborTrackingCategory is "Kitchen">
					<!--- Display the Total Nursing Variable Budget Variance. --->
					<td colspan="1" align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1" color="<cfif (nursingVariableBudgetTotal - nursingMtdTotalHours) lt 0>Red<cfelse>Black</cfif>">
							<strong>
									#helperObj.LaborNumberFormat(nursingVariableBudgetTotal - nursingMtdTotalHours, "0.00")#
								</strong>
							</font>
						</font>
					</td>					
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>		
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>				
					<!--- Display the Kitchen columns. --->
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>						
					<!--- Stores the Kitchen Services MTD Variance. --->
					<cfset kitchenServicesMtdVariance = fVariableBudget - (fRegular + fOverTime)>
					<!--- Update the variable budget variance total for the Kitchen field. --->
					<cfset variableBudgetVarianceTotal = variableBudgetVarianceTotal + kitchenServicesMtdVariance>			
					<!--- Display the Kitchen Reg/OT columns. --->
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1" color="<cfif kitchenServicesMtdVariance lt 0>Red<cfelse>Black</cfif>">
							<strong>
								#helperObj.LaborNumberFormat(kitchenServicesMtdVariance, "0.00")#
							</strong>
						</font>
					</td>	
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>		
				<cfelse>
					<cfif cLaborTrackingCategory is not "PPADJ">
					<!--- Update the variable budget variance total for the current non-nursing field. --->
					<cfset variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - fAll)>			
							
					<!--- Display the Non-Nursing Hours. --->
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1" color="<cfif (fVariableBudget - fAll) lt 0>Red<cfelse>Black</cfif>">
							<strong>
								#helperObj.LaborNumberFormat(fVariableBudget - fAll, "0.00")#
							</strong>
						</font>
					</td>	
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>		
					</cfif>						
				</cfif>
			</cfif>
		</cfloop>
		<!--- Display the Variable Budget variance Total. --->
		<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
			<font size="-1" color="<cfif variableBudgetVarianceTotal lt 0>Red<cfelse>Black</cfif>">
				<strong>
					#helperObj.LaborNumberFormat(variableBudgetVarianceTotal, "0.00")#
				</strong>
			</font>
		</td>	
		<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>	
		<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>	
		<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>		
		<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>		
	</tr>
</tfoot>
</tbody>
</table>
</div>
</cfoutput>
<script language="javascript" type="text/javascript">
	if (document.getElementById("tbl-container"))
	{
		document.getElementById("tbl-container").style.display = 'none';
		document.getElementById("tbl-container").style.display = 'block';
	}
</script>
</body>
</html>