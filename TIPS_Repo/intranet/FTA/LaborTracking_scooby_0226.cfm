<!----------------------------------------------------------------------------------------------
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| bkubly     | 03/27/2009 | Developed Labor Tracking Page.					                   |
| bkubly 	 | 10/14/2009 | Add Variable Budget Tooltips.									   |
| bkubly	 | 01/14/2011 | Add daily Variable Budget columns - 59563.					 	   |
| sfarmer    | 01/02/2015 | added CRM - community Relations manager                            |
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
			
			<cfif isDefined("url.Division_ID")>
				<cfset divisionId = #url.Division_ID#>  
			</cfif>
						
			<cfif isDefined("url.RegionID")>
				<cfset RegionId = #url.regionID#>
			</cfif>

			<cfif isDefined("url.rollup")>
				<cfset rollup = #url.rollup#>
			<cfelse> 
				<cfset rollup = 0>
			</cfif>

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

<cfset loop = 0>
<cfset same = 0>
<cfset wds = 0>
<cfset open =0>
<cfset conflict = 0>
<cfset totalvarbgt = 0>
<cfset totalvariance = 0>
<cfset samePeriod = 0>
<cfset pastPeriod = 0>
<cfset WDStermed = 0>
<cfset conditionalTrue = 0>
<cfset conditionalFalse = 0>
<cfset currPeriod = 0>
<cfset isCCLLCHouse = 0>
<cfset isCCLLC = 0>
<cfset kitchenTrngVarBgt = 0>
<cfset totalKitchenTrngVarBgt = 0>
<cfset ccllcSalEmp = 0>
<cfset sunday = 0>
<cfset totalRegular = 0>
<cfset totalActual = 0>
<cfset totalVariance = 0>

<cfoutput>
	<body>		
		<font face="arial">
			<form method="post" action="labortracking.cfm">
				<cfinclude template="DisplayFiles/Header.cfm">
				<!--- Setup the Query variables. --->
				<cfif rollup is 0>
					<cfset dsCCLLCHouses = #helperObj.FetchCCLLCHouses(houseId)#>
					<cfif dsCCLLCHouses.recordcount is not 0>	
						<cfif ccllcHouse is 1>
							<cfset isCCLLCHouse = 1>
						<cfelse>
							<cfset isCCLLCHouse = 0>
						</cfif>
						<cfset isCCLLC = 1>
					<cfelse> 
						<cfset isCCLLCHouse = 0> 
						<cfset isCCLLC = 0>	
					</cfif>
				</cfif>
				
				<cfset dsLaborTrackingCategories = #helperObj.FetchLaborTrackingCategories()#>

				<cfif rollup is 0>
					<cfset dsLaborTrackingHours = #helperObj.FetchLaborHours(houseId, PtoPFormat)#>
					<cfset dsCensusDetails = #helperObj.FetchCensusDetails(houseId, FromDate, ThruDate)#>
					<cfset dailyCensusBudget = #helperObj.FetchDailyCensusBudget(houseId, currenty, monthforqueries)#>
					<cfset censusBudgetDim = #dailyCensusBudget# * #currentdim#>
					<cfset dsLaborVariableBudgets = #helperObj.FetchLaborVariableBudgets(houseId, PtoPFormat)#>		

					<cfset dsTwoPersonAssists = #helperObj.FetchTwoPersonAssists(houseId, FromDate, ThruDate)#>
					
					<cfset dsLaborTrackingWDSInfo = #helperObj.FetchLaborTrackingWDSDaily(houseId, DateFormat(now()-1, "mm/dd/yyyy")
					,PtoPFormat,rollup)#>
					<cfset dsHousesWithWDHAndWDS = #helperObj.FetchHousesWithWDHAndWDS(houseId, PtoPFormat)#>
					<cfset dsHousesWithWD = #helperObj.FetchHousesWithWD(houseId, PtoPFormat)#>
					
						<cfif dsHousesWithWDHAndWDS.recordcount is not 0>	<cfset conflict = 1>
						<cfelse> <cfset conflict = 0> 	</cfif>
						
						<cfif dsLaborTrackingWDSInfo.dTermDate is not "" and 
						(dsLaborTrackingWDSInfo.dTermDate gte dsLaborTrackingWDSInfo.StartDate 
						and dsLaborTrackingWDSInfo.dTermDate lt dsLaborTrackingWDSInfo.EndDate)>
							<cfset WDStermed = 1> <cfset samePeriod = 1><cfset pastPeriod = 0>
						<cfelseif dsLaborTrackingWDSInfo.dTermDate is not "" 
						and (dsLaborTrackingWDSInfo.dTermDate lte dsLaborTrackingWDSInfo.StartDate 
						and dsLaborTrackingWDSInfo.dTermDate lt dsLaborTrackingWDSInfo.EndDate)>
							<cfset WDStermed = 1> <cfset samePeriod = 0><cfset pastPeriod = 1>
						<cfelseif dsLaborTrackingWDSInfo.nStatus is "L" 
						and dsLaborTrackingWDSInfo.dTermDate is "" 
						and (dsLaborTrackingWDSInfo.dDateCreated gte dsLaborTrackingWDSInfo.StartDate 
						and dsLaborTrackingWDSInfo.dDateCreated lte dsLaborTrackingWDSInfo.EndDate)>
							<cfset WDStermed = 1> <cfset samePeriod = 1>
						<cfelse> <cfset WDStermed = 0> <cfset bool = "false"></cfif>
					
					<cfset dsWDSHouses = #helperObj.FetchWDSHouses(houseId)#>
					<cfset dsOpenWD = #helperObj.FetchHouseWithOpenWDPosition(houseId, PtoPFormat)#>
						<cfif dsOpenWD.recordcount is not 0>	
							<cfset open = 1>
						<cfelse> 
							<cfset open = 0> 
							<cfif dsWDSHouses.recordcount is not 0>	
							<cfset wds = 1> 
							<cfelse> 
							<cfset wds = 0> 
							</cfif>
						</cfif>
						
						<cfif (DateFormat(dsLaborTrackingWDSInfo.dHireDate, "yyyymm") eq PtoPFormat)>
							<cfset currPeriod = 1>
						<cfelse> 
							<cfset currPeriod = 0>
						</cfif>
						
						<cfif dsHousesWithWD.recordcount is not 0>
							<cfif dsHousesWithWD.ActiveWDH is 1 and dsHousesWithWD.ActiveWDS is 0 > 
								<cfset WDStermed = 1><cfset samePeriod = 1>
								<cfset bool = "othertrue1">
							<cfelseif dsHousesWithWD.ActiveWDH is 0 and dsHousesWithWD.ActiveWDS is 1> 
								<cfset WDStermed = 0><cfset samePeriod = 1> 
								<cfset bool = "other false1">
							<cfelseif (dsHousesWithWD.ActiveWDS is 1 and dsHousesWithWD.n_Status is "L") and ActiveWDH is 0> 
								<cfset WDStermed = 1><cfset samePeriod = 1>
								<cfset bool = "othertrue2">
							<cfelseif dsHousesWithWD.ActiveWDH is 1 and dsHousesWithWD.ActiveWDS is 1 > 
								<cfset WDStermed = 0> 
								<cfset conflict =1> 
								<cfset samePeriod = 1>
								<cfset bool = "otherfalse2">
							<cfelse> 
								<cfset conflict = 0> 
								<cfset open = 1>
							<cfset samePeriod = 1>
							</cfif>
						</cfif>
				</cfif>
				</font>	
		<br />
<br />

<table id="tbl1" cellspacing="0" cellpadding="0" border="0px">
	<tr>
		<!---<cfif rollup is 0>--->
			<td colspan="4" rowspan="3" bgcolor="white">
				<label id="lblExportToExcel" style="cursor: hand; color: blue; text-decoration: underline; font-family: verdana; font-size: 8pt" 
					onClick="javascript:window.open('LaborTracking_ExcelExport.cfm?ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#divisionID#&Region_ID=#RegionID#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#');">
						Export to Excel Spreadsheet <img title="Export to Excel" src="Images/ExcelBig.bmp" height="30px" width="30px" />
				</label>
			</td>
		<!---</cfif>--->
		<cfif rollup is 0>
		<cfif ccllcHouse is 0>
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
									<cfif WDStermed is 0>
										#helperObj.LaborNumberFormat(dsLaborTrackingWDSInfo.fWorkWeekAllocation, "0.00")#
									<cfelse> - 
									</cfif>
								</cfif>
							</font>
						</td>
						<td colspan="1" rowspan="1" bgcolor="#budgetcellcolor#" align="right" style="padding-right: 5px;">
							<font size="-1">
								<cfif dsLaborTrackingWDSInfo.recordcount is 0> -
								<cfelse> 
									<cfif open is 0>
										<cfif WDStermed is 0>
											<cfif conflict is 0> 
											#helperObj.LaborNumberFormat(dsLaborTrackingWDSInfo.VarBdgt, "0.00")#
											<cfelse> - 
											</cfif> 
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
		</cfif></cfif>
	</tr>
</table>
<br/>
<cfif rollup is 0>
	<cfif ccllcHouse is 1> 
		<div id="tbl-container">
			<table id="tbl" cellspacing="0" cellpadding="1" border="1px" style="width: expression(screen.availWidth - 105);">
			<!--- style="width: 920px;">--->
	<cfelse>
		<div id="tbl-container">
			<table id="tbl" cellspacing="0" cellpadding="1" border="1px">
	</cfif>
<cfelse>
	<cfif rollup is 2>
		<div id="tbl-container" style="height:auto;">
			<!---expression(screen.availHeight - 300);" style="height:expression(getReportTableHeight()-100);"--->
			<table id="tbl" cellspacing="0" cellpadding="1" border="1px" style="width: 3200px; height:auto;">
	<cfelseif rollup is 1>
		<div id="tbl-container" style="height:auto;">
			<!--- style="height:expression(getReportTableHeight()-50);">--->
			<table id="tbl" cellspacing="0" cellpadding="1" border="1px" style="width: 3200px; height:auto;">
	<cfelse>
		<div id="tbl-container" style="height:auto;">
			<table id="tbl" cellspacing="0" cellpadding="1" border="1px" style="width: 3200px; height:auto;">
	</cfif>
</cfif>
					<thead>
						<tr>

</cfoutput>

<!------------------------- COLUMN HEADERS - ROW 1 ------------------------->
<cfoutput>
<cfif rollup is 0>
	<th class="locked" colspan="1" align="center" bgcolor="#headerCellColor#" style="#leftPaneStyle#">
<cfelse>
	<th class="locked" colspan="4" align="center" bgcolor="#headerCellColor#" style="#leftPaneStyle#">
</cfif>
		<font size="-1" color="white">
			<cfif rollup is 0>&##160;<cfelseif rollup is 3>Houses<cfelseif rollup is 2>Regions<cfelseif rollup is 1>Divisions </cfif>
		</font>
	</th>
	<th align="center" bgcolor="#headerCellColor#" colspan="4">
		<font size="-1" color="white">
			<cfif rollup is 0> Daily <cfelse> Average Daily </cfif>
		</font>
	</th>
	<cfloop query="dsLaborTrackingCategories">
		<cfif rollup is 0>
			<cfif ccllcHouse is 0>
				<cfif cLaborTrackingCategory is not "WD Salary" and cLaborTrackingCategory is not "Kitchen Training">			
					<!--- The WD Hours columns will be placed before kitchen services. --->
					<cfif cLaborTrackingCategory is "Kitchen">
						<th bgcolor="#headerCellColor#" colspan="3">
							<font size="-1" color="white">
								Nursing Totals
							</font>
						</th>	
					</cfif>
			
					<!---- Check if the category is Nursing ---->
					<cfif cLaborTrackingCategory is "Resident Care" 
						or cLaborTrackingCategory is "Nurse Consultant" 
						or cLaborTrackingCategory is "LPN - LVN" 
						or cLaborTrackingCategory is "Kitchen" 
						or cLaborTrackingCategory is "WD Hourly"
						or cLaborTrackingCategory is "CRM">
						<!--- Kitchen Services does NOT report "Other" Hours. --->
						<cfif  cLaborTrackingCategory is "Resident Care" 
							or cLaborTrackingCategory is "Nurse Consultant" 
							or cLaborTrackingCategory is "LPN - LVN" 
							or cLaborTrackingCategory is "WD Hourly">	
							<th bgcolor="#headerCellColor#" colspan="3">
						<cfelse>
							<th bgcolor="#headerCellColor#" colspan="5">
						</cfif>
							<font size="-1" color="white">
								<cfif cLaborTrackingCategory is "WD Hourly">
									<cfif PtoPFormat gte '201303'> Var Bud Hrs for Open WD <cfelse> #cDisplayName# Hours </cfif>
								<cfelse>
									#cDisplayName# Hours
								</cfif>
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
			<cfelse> <!----ccllcHouse is 1---->
				<cfif cLaborTrackingCategory is "Kitchen">
					<th bgcolor="#headerCellColor#" colspan="5">
						<font size="-1" color="white">
							Kitchen Hours
						</font>
					</th>	
				</cfif>			
				<cfif cLaborTrackingCategory is "Kitchen Training">
					<th bgcolor="#headerCellColor#" colspan="3">
						<font size="-1" color="white">
							Training Hours
						</font>
					</th>
					<th bgcolor="#headerCellColor#" colspan="3">
						<font size="-1" color="white">
							Total
						</font>
					</th>
				</cfif>
			</cfif>		
		<cfelse> <!--- rollup is not 0 --->
			<cfif cLaborTrackingCategory is not "Kitchen Training" and cLaborTrackingCategory is not "WD Salary">
				<!--- The WD Hours columns will be placed before kitchen services. --->
				<cfif cLaborTrackingCategory is "Kitchen">
					<th bgcolor="#headerCellColor#" colspan="3">
						<font size="-1" color="white">
							Nursing Totals
						</font>
					</th>	
				</cfif>
		
				<!---- Check if the category is Nursing ---->
				<cfif cLaborTrackingCategory is "Resident Care" 
				or cLaborTrackingCategory is "Nurse Consultant" 
				or cLaborTrackingCategory is "LPN - LVN" 
				or cLaborTrackingCategory is "Kitchen"
				or cLaborTrackingCategory is "CRM"> 
					<!---or cLaborTrackingCategory is "WD Hourly">--->
					<!--- Kitchen Services does NOT report "Other" Hours. --->
					<cfif  cLaborTrackingCategory is "Resident Care" 
					or cLaborTrackingCategory is "Nurse Consultant" 
					or cLaborTrackingCategory is "LPN - LVN">	
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
				<cfelseif cLaborTrackingCategory is "WD Hourly">
					<th bgcolor="#headerCellColor#" colspan="3">
						<font size="-1" color="white">
							<cfif PtoPFormat gte '201303'> Var Bud Hrs for Open WD <cfelse> #cDisplayName# Hours </cfif>
						</font>
					</th>		
<!---				<cfelseif cLaborTrackingCategory is "WD Salary">
					<th bgcolor="#headerCellColor#" colspan="4">
						<font size="-1" color="white">
							WD Salaried Hours
						</font>
					</th>		
--->				 <cfelse>
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
							Total Actual Hours
						</font>
					</th>
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
</cfoutput>

</tr>
<!------------------------- COLUMN HEADERS - ROW 2 ------------------------->
<tr>
<cfoutput>
<cfif rollup is 0>
	<th class="locked" bgcolor="#emptyCellColor#" align="center" style="#leftPaneStyle#" colspan="1">
<cfelse>
	<th class="locked" bgcolor="#emptyCellColor#" align="center" style="#leftPaneStyle#" colspan="4">
</cfif>
		<font size=-1>
			<cfif rollup is 0>&##160;<cfelse>As of #DateFormat(ThruDate, "mmmm dd, yyyy")#</cfif>
		</font>
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
		<cfif rollup is 0>
			<cfif ccllcHouse is 0>
				<cfif cLaborTrackingCategory is not "WD Salary" and cLaborTrackingCategory is not "Kitchen Training">
					<!--- Add the Nursing Sub-Total Column Headers. --->
					<cfif cLaborTrackingCategory is "Kitchen">
						<th bgcolor="#emptyCellColor#" colspan="3" align=center>
							<font size=-2>
								SUB-TOTALS
							</font>
						</th>
					</cfif>
					
					<!--- Check if the current Category is NURSING. --->
					<cfif cLaborTrackingCategory is "Resident Care" 
					or cLaborTrackingCategory is "Nurse Consultant" 
					or cLaborTrackingCategory is "LPN - LVN" 
					or cLaborTrackingCategory is "Kitchen" 
					or cLaborTrackingCategory is "WD Hourly"
					or cLaborTrackingCategory is "CRM">
						<!--- Kitchen Services does NOT report "Other" Hours. --->
						<cfif cLaborTrackingCategory is "Resident Care" 
						or cLaborTrackingCategory is "Nurse Consultant" 
						or cLaborTrackingCategory is "LPN - LVN" 
						or cLaborTrackingCategory is "WD Hourly">
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
			<cfelse> <!---- ccllcHouse is 1 ---->
				<cfif cLaborTrackingCategory is "Kitchen">
					<th bgcolor="#emptyCellColor#" colspan="5" align=center>
							<font size=-2>
								HOURS WORKED
							</font>
					</th>	
				</cfif>			
				<cfif cLaborTrackingCategory is "Kitchen Training">
					<th colspan="3" bgcolor="#emptyCellColor#" align=center>
						<font size="-1">
							&##160;
						</font>
					</th>
					<th colspan="3" bgcolor="#emptyCellColor#" align=center>
						<font size="-1">
							&##160;
						</font>
					</th>
				</cfif>
			</cfif>
		<cfelse> <!--- rollup is not 0 --->
			<cfif cLaborTrackingCategory is not "Kitchen Training" and cLaborTrackingCategory is not "WD Salary">
				<!--- Add the Nursing Sub-Total Column Headers. --->
				<cfif cLaborTrackingCategory is "Kitchen">
					<th bgcolor="#emptyCellColor#" colspan="3" align=center>
						<font size=-2>
							Total Actual Hours vs Variable Budget
						</font>
					</th>
				</cfif>
				<!---<cfif cLaborTrackingCategory is "WD Salary">
					<th bgcolor="#emptyCellColor#" colspan="4" align=center>	</th>
				</cfif>--->
				<!--- Check if the current Category is NURSING. --->
				<cfif cLaborTrackingCategory is "Resident Care" 
				or cLaborTrackingCategory is "Nurse Consultant" 
				or cLaborTrackingCategory is "LPN - LVN" 
				or cLaborTrackingCategory is "Kitchen"
				or cLaborTrackingCategory is "CRM"> <!---or cLaborTrackingCategory is "WD Hourly">--->
					<!--- Kitchen Services does NOT report "Other" Hours. --->
					<cfif cLaborTrackingCategory is "Resident Care" 
					or cLaborTrackingCategory is "Nurse Consultant" 
					or cLaborTrackingCategory is "LPN - LVN" 
					or cLaborTrackingCategory is "WD Hourly">
						<th bgcolor="#emptyCellColor#" colspan="3" align=center>
							<font size=-2>
								HOURS WORKED
							</font>
						</th>
					<cfelse>
						<th bgcolor="#emptyCellColor#" colspan="5" align=center>
							<font size=-2>
								Total Actual Hours vs Variable Budget
							</font>
						</th>
					</cfif>
				<cfelseif cLaborTrackingCategory is "PPADJ">
					<th colspan="3" bgcolor="#emptyCellColor#" align=center>
						<font size="-2">
							Total Actual Hours vs Variable Budget
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
<!---				<cfelseif cLaborTrackingCategory is "WD Salary">	
					<th colspan="4" bgcolor="#emptyCellColor#" align=center>
						<font size="-1">
							&##160;
						</font>
					</th>			
--->			<cfelse>
					<th colspan="3" bgcolor="#emptyCellColor#" align=center>
						<font size="-2">
							Total Actual Hours vs Variable Budget
						</font>
					</th>
			</cfif>
			</cfif>		
		</cfif>
	</cfloop>
</cfoutput>
</tr>

<!------------------------- COLUMN HEADERS - ROW 3 ------------------------->
<tr>
<cfoutput>
<cfif rollup is 0>
	<th class="locked" colspan="1" bgcolor="#emptyCellColor#" align="center" style="#leftPaneStyle# #topPaneStyle#">
<cfelse>
	<th class="locked" colspan="4" bgcolor="#emptyCellColor#" align="center" style="#leftPaneStyle# #topPaneStyle#">
</cfif>
		<font size="-1">
			<cfif rollup is 0> 
				DAY 
			<cfelseif rollup is 3>
				<font size="-1">Click on any House to view to the Labor Tracking page of that House.</font>
			<cfelseif rollup is 2>
				<font size="-1">Click on any Region to view to the Labor Tracking page of that Region.</font>
			<cfelseif rollup is 1>
				<font size="-1">Click on any Division to view to the Labor Tracking page of that Division.</font>
			<cfelse> &##160; 
			</cfif>
		</font>
	</th>
	<th colspan="1" bgcolor="#emptyCellColor#" align="center" style="#topPaneStyle#">
		<font size="-1">
			<cfif rollup is 0>Prd <cfelse> PRD </cfif>
		</font>
	</th>
	<th colspan="1" bgcolor="#emptyCellColor#" align="center" style="#topPaneStyle#">
		<font size="-1">
			<cfif rollup is 0>Units <cfelse> PUD </cfif>
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
		<cfif rollup is 0>
			<cfif ccllcHouse is 0>
				<cfif cLaborTrackingCategory is not "WD Salary" and cLaborTrackingCategory is not "Kitchen Training">
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
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle# padding-right:2px;" colspan="1">
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
						<cfelseif cLaborTrackingCategory is "CRM">
		
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
								<font size="-1">
									Regular
								</font>
							</th>
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle# padding-right:2px;" colspan="1">
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
						<cfelseif cLaborTrackingCategory is "WD Hourly">
							<!---<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
								<font size="-1">
									Regular
								</font>
							</th>
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
								<font style="font-weight:bold; width:inherit; font-size:x-small">
									Overtime
								</font>
							</th>--->
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
								<font size="-1">
									Actual
								</font>
							</th>
							<th bgcolor="#budgetcellcolor#" style="#topPaneStyle#">
								<cfif PtoPFormat gte "201303">
									<font size="-1">
										<!--- Stores the name of the current Tooltip Popup Div Element. --->
										<cfset TooltipDivName = "divWDVariableBudgetPopup2">
										<!--- Stores all of the styles required for the standard tooltip Div element. --->
										<cfset TooltipDivStyles = "font-size: 8pt; font-family: tahoma; z-index: 140; padding: 2px;
										 background-color: ##d9d9c2; display: none;">
										<a style="width: 100%; height: 100%; text-align: center; vertical-align: top; padding-top: 8px
										; cursor: hand; text-decoration: none; color: black;" title="Click to see the Description" 
										titleDisplay="Variable Budget for Open WD Description"
										 href='###TooltipDivName#' class='load-local' rel='###TooltipDivName#'>
											Var Bgt  
										</a>
										<div id="#TooltipDivName#" style="#TooltipDivStyles#">
											"Variable Budget for Open WD Position" are additional hours allotted to the Nursing Total when a vacancy exists in the Wellness Director position.
										</div>
									</font>
								<cfelse> <font size="-1">Var Bgt </font></cfif>
							</th>	
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
								<font size="-1">
									Variance
								</font>
							</th>							
						<cfelseif cLaborTrackingCategory is "Resident Care" 
							or cLaborTrackingCategory is "Nurse Consultant" 
							or cLaborTrackingCategory is "LPN - LVN">
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
								<font size="-1">
									Regular
								</font>
							</th>
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle#" colspan="1">
								<font size="-1">
									Overtime
								</font>
							</th>					
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
								<font size="-1">
									Other
								</font>
							</th>
						<cfelse><!--- these are the default headings --->
							<cfif cLaborTrackingCategory is not "PPADJ">
								<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
									<font size="-1">
										Regular                          <!--- Gthota 2/26/2018  replace heading from 'Actual' to Regular text  --->
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
				<cfelse> <!---- ccllcHouse is 1 ---->	
					<cfif cLaborTrackingCategory is "Kitchen">
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Regular
							</font>
						</th>
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle# padding-right:2px;" colspan="1">
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
					</cfif>
					<cfif cLaborTrackingCategory is "Kitchen Training">
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
			<cfelse> <!--- rollup is not 0 --->
				<cfif cLaborTrackingCategory is not "Kitchen Training" and cLaborTrackingCategory is not "WD Salary" >
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
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle# padding-right:2px;" colspan="1">
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
					<!---<cfelseif cLaborTrackingCategory is "WD Salary">
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
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Allocated WD
							</font>
						</th>	--->
						<cfelseif cLaborTrackingCategory is "CRM">
		
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
								<font size="-1">
									Regular
								</font>
							</th>
							<th bgcolor="#emptyCellColor#" style="#topPaneStyle# padding-right:2px;" colspan="1">
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
					<cfelseif cLaborTrackingCategory is "WD Hourly">
						<!---<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Regular
							</font>
						</th>
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font style="font-weight:bold; width:inherit; font-size:x-small">
								Overtime
							</font>
						</th>--->
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Actual
							</font>
						</th>
						<th bgcolor="#budgetcellcolor#" style="#topPaneStyle#">
							<cfif PtoPFormat gte "201303">
								<font size="-1">
									<!--- Stores the name of the current Tooltip Popup Div Element. --->
									<cfset TooltipDivName = "divWDVariableBudgetPopup1">
									<!--- Stores all of the styles required for the standard tooltip Div element. --->
									<cfset TooltipDivStyles = "font-size: 8pt; font-family: tahoma; z-index: 140; padding: 2px; 
									background-color: ##d9d9c2; display: none;">
									<a style="width: 100%; height: 100%; text-align: center; vertical-align: top; padding-top: 8px; 
									cursor: hand; text-decoration: none; color: black;" title="Click to see the Description" 
									titleDisplay="Variable Budget for Open WD Description" href='###TooltipDivName#' 
									class='load-local' rel='###TooltipDivName#'>
										Var Bgt  
									</a>
									<div id="#TooltipDivName#" style="#TooltipDivStyles#">
										"Variable Budget for Open WD Position" are additional hours allotted to the Nursing Total when a vacancy exists in the Wellness Director position.
									</div>
								</font>
							<cfelse> <font size="-1">Var Bgt </font></cfif>
						</th>	
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Variance
							</font>
						</th>							
					<cfelseif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant" 
					or cLaborTrackingCategory is "LPN - LVN">
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#">
							<font size="-1">
								Regular
							</font>
						</th>
						<th bgcolor="#emptyCellColor#" style="#topPaneStyle#" colspan="1">
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
									Regular                          <!--- Gthota 2/26/2018  replace heading from 'Actual' to Regular text  --->
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
			</cfif>
		</cfloop>

	<cfif ccllcHouse is 0>		
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
	</cfif>
	</tr>
</thead>
<tbody>

<!--- Accumulates the MTD Training Budget. --->
<cfset trainingBudgetMtd = 0>
<cfset WDSActual = 0>
<cfset WDSVarBgt = 0>
<cfset WDSTotalVariance = 0>
<cfset WDHVarBgt = 0>
<cfset WDHVariance = 0>
<cfset TotalActualHours = 0>
<cfset TotalBudgetHours = 0>
<cfset TotalVariance = 0>
<cfset NursingActualHours = 0>
<cfset NursingBudgetHours = 0>
<cfset NursingVariance = 0>
<cfset NursingVarBgtDesc = "">

<cfset totalTenants = 0>
<cfset totalOccupants = 0>

<cfif rollup is not 0>

	<cfif rollup is 3>
		<cfset dsCensusDetails = #helperObj.FetchDashboardRollupOccupancyDetails(RegionId, PtoPFormat, FromDate, ThruDate, rollup)#>
									<!---FetchAverageDailyCensusDetailsRollup(RegionID, FromDate, ThruDate,monthforqueries)#>--->
	<cfelseif rollup is 2>
		<cfset dsCensusDetails = #helperObj.FetchAverageDailyCensusDetailsDivisionalRollup(DivisionID, FromDate, ThruDate,monthforqueries, true)#>
	<cfelseif rollup is 1>
		<cfset dsCensusDetails = #helperObj.FetchAverageDailyCensusDetailsConsolidatedRollup(FromDate, ThruDate,monthforqueries)#>
	</cfif>
	
	<cfloop query="dsCensusDetails">
		<tr>
		 	<td class="locked" colspan="4" bgcolor="#emptyCellColor#" align="right" style="#leftPaneStyle#">
				<font size="-1">
				<cfif rollup is 3>
					<a href="labortracking.cfm?<cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif>&ccllcHouse=#ccllcHouse#&rollup=0&Division_ID=#DivisionID#&Region_ID=#RegionID#&iHouse_ID=#dsCensusDetails.iHouse_ID#&SubAccount=#dsCensusDetails.cGLSubAccount#
					<cfif isDefined("url.datetouse")>
						<cfset datetouse = #url.datetouse#>
					</cfif>
						&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
					</cfif>"> <strong>#dsCensusDetails.cName# </strong></a>
				<cfelseif rollup is 2>
					<a href="labortracking.cfm?<cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif>&ccllcHouse=#ccllcHouse#&rollup=3&Division_ID=#DivisionID#&Region_ID=#dsCensusDetails.iOPSArea_ID#
					<cfif isDefined("url.datetouse")>
						<cfset datetouse = #url.datetouse#>
					</cfif>
						&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
					</cfif>"> <strong>#dsCensusDetails.cName# </strong></a>
				<cfelseif rollup is 1>
					<a href="labortracking.cfm?<cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&Role=
					<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif>
					&ccllcHouse=#ccllcHouse#&rollup=2&Division_ID=#dsCensusDetails.iRegion_ID#
					<cfif isDefined("url.datetouse")>
						<cfset datetouse = #url.datetouse#>
					</cfif>
						&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
					</cfif>"> <strong>#dsCensusDetails.cName# </strong>
					</a>
				</cfif>									
				</font>
			</td>

			<cfif rollup is 2>
				<cfset dsRegionalCensusDetails = #helperObj.FetchAverageDailyCensusDetailsRollup(#dsCensusDetails.iOPSArea_ID#
				, FromDate, ThruDate,monthforqueries)#>
				<cfset dsTenantCensus = #helperObj.FetchAverageMTDCensusDetailsRollup(dsRegionalCensusDetails, 3, false)#>	
			</cfif>

			<td align="right"  style="padding-right: 5px;">
			 	<font size="-1">
					<cfif rollup is 2>#helperObj.LaborNumberFormat(dsTenantCensus.TotalTenants, "0.0")#	
						<cfset totalTenants = #totalTenants# + #dsTenantCensus.TotalTenants#>
					<cfelse>#helperObj.LaborNumberFormat(fTenants, "0.0")#	</cfif>
				</font>
			</td>		
			<td align="right"  style="padding-right: 5px;">
				 <font size="-1">
					<cfif rollup is 2>#helperObj.LaborNumberFormat(dsTenantCensus.TotalOccupancy, "0.0")#	
						<cfset totalOccupants = #totalOccupants# + #dsTenantCensus.TotalOccupancy#>											
					<cfelse>#helperObj.LaborNumberFormat(fOccupancy, "0.0")#</cfif>
						
				</font>
			</td>			
			<td align="right"  style="padding-right: 5px;">
				 <font size="-1">
					#helperObj.LaborNumberFormat(fPoints, "0.0")#
					
				</font>
			</td>		
			<td align="right" style="padding-right: 5px;">
				 <font size="-1">
					#helperObj.LaborNumberFormat(iTwoPersonAssists, "0.0")#	
					
				</font>
			</td>				
			
			<cfif rollup is 3>
				<cfset totalDailyHours = 0>
				<cfset totalDailyBudgetHours = 0>
				<cfset nursingTotalHours = 0>
				<cfset nursingBudgetTotalHours = 0>	
				<cfset dsLaborTrackingHours = #helperObj.FetchLaborHoursRollup(dsCensusDetails.iHouse_ID, PtoPFormat, 3, true)#>
			<cfelseif rollup is 2>
				<cfset totalDailyHours = 0>
				<cfset totalDailyBudgetHours = 0>
				<cfset nursingTotalHours = 0>
				<cfset nursingBudgetTotalHours = 0>	
			<!---	<cfparam name="nursingBudgetTotalHours" default ="0">	--->
				<cfset dsLaborTrackingHours = #helperObj.FetchLaborHoursRollup(dsCensusDetails.iOPSArea_ID, PtoPFormat, 1, true)#>
			<cfelseif rollup is 1>
				<cfset totalDailyHours = 0>
				<cfset totalDailyBudgetHours = 0>
				<cfset nursingTotalHours = 0>
				<cfset nursingBudgetTotalHours = 0>	
				<cfset dsLaborTrackingHours = #helperObj.FetchLaborHoursRollup(dsCensusDetails.iRegion_ID, PtoPFormat, 2, true)#>
			</cfif>
			
			<!--- loop through labor categories --->
			<cfloop query="dsLaborTrackingHours">

				<!--- Stores the name of the current Tooltip Popup Div Element. --->
				<cfset houseTooltipDivName = "divVariableBudgetPopupRegional" & #cLaborTrackingCategory#>
				<!--- Stores all of the styles required for the standard tooltip Div element. --->
				<cfset houseTooltipDivStyles = "font-size: 8pt; font-family: tahoma; z-index: 140; padding: 2px; 
				background-color: ##d9d9c2; display: none;">

				<cfif cLaborTrackingCategory is not "Kitchen Training" and cLaborTrackingCategory is not "WD Salary">
					<!--- Check if the current column should be displayed. --->
					<cfif bIsVisible eq true>
						<cfif rollup is 3>
							<cfset dsLaborTrackingWDSInfo = #helperObj.FetchLaborTrackingWDSDaily(dsCensusDetails.iHouse_ID
							, DateFormat(ThruDate, "mm/dd/yyyy"),PtoPFormat,rollup)#> 
						<cfelseif rollup is 2>
							<cfset dsLaborTrackingWDSInfo = #helperObj.FetchLaborTrackingWDSDaily(dsCensusDetails.iOPSArea_ID
							, DateFormat(ThruDate, "mm/dd/yyyy"),PtoPFormat,rollup)#>
						<cfelseif rollup is 1>
							<cfset dsLaborTrackingWDSInfo = #helperObj.FetchLaborTrackingWDSDaily(dsCensusDetails.iRegion_ID
							, DateFormat(ThruDate, "mm/dd/yyyy"),PtoPFormat,rollup)#>
						</cfif>
						<!--- ==> #isCCLLCHouse# #isCCLLC#<br> --->
						<cfswitch expression="#cLaborTrackingCategory#">
							<!---<cfcase value = "WD Salary">
					
								<!---<cfif dsLaborTrackingWDSInfo.recordcount is not 0 and dsLaborTrackingWDSInfo.nStatus is not "T">
									<cfset totalDailyHours = #totalDailyHours# + #dsLaborTrackingWDSInfo.fWorkWeekAllocation#>
									<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #dsLaborTrackingWDSInfo.VarBdgt#>	
								</cfif>--->

								<td align="right" style="padding-right: 5px;">
									<cfif dsLaborTrackingWDSInfo.recordcount is 0> -
										<cfset WDSActual = #WDSActual# + 0>
									<cfelse>
										<cfif dsLaborTrackingWDSInfo.nStatus is "T"> - 
										<cfelse>
										<font size="-1">
											#helperObj.LaborNumberFormat(dsLaborTrackingWDSInfo.fWorkWeekAllocation, "0.0")#
											<cfset WDSActual = #WDSActual# + #dsLaborTrackingWDSInfo.fWorkWeekAllocation#>
										</font></cfif>
									</cfif>
								</td>		
								<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
									<cfif dsLaborTrackingWDSInfo.recordcount is 0> -
										<cfset WDSVarBgt = #WDSVarBgt# + 0>
									<cfelse>
										<cfif dsLaborTrackingWDSInfo.nStatus is "T"> - 
										<cfelse>
										<font size="-1">
											#helperObj.LaborNumberFormat(dsLaborTrackingWDSInfo.VarBdgt, "0.00")#
											<cfset WDSVarBgt = #WDSVarBgt# + #dsLaborTrackingWDSInfo.VarBdgt#>
										</font>
										</cfif>
										
									</cfif>
								</td>
								<td align="right" style="padding-right: 5px;">
									<cfif dsLaborTrackingWDSInfo.recordcount is 0> -
									<cfelse>
										<cfif dsLaborTrackingWDSInfo.nStatus is "T"> - <cfelse>
										<cfset WDSVariance = dsLaborTrackingWDSInfo.VarBdgt - dsLaborTrackingWDSInfo.fWorkWeekAllocation >
										<cfset WDSTotalVariance = #WDSTotalVariance# + (#WDSVariance#)>
										<font size="-1" color="<cfif (WDSVariance) lt 0>Red<cfelse>Black</cfif>">
											#helperObj.LaborNumberFormat(WDSVariance, "0.00")#
										</font> </cfif>
									</cfif>
									
								</td>																
								<td align="right" style="padding-right: 5px;">
									<cfif dsLaborTrackingWDSInfo.recordcount is 0> -
									<cfelse>
										<cfif dsLaborTrackingWDSInfo.nStatus is "T"> - <cfelse>
											<font size="-1">
												#helperObj.LaborNumberFormat(dsLaborTrackingWDSInfo.percentage, "0.0")# %
											</font>
										</cfif>
									</cfif>
								</td>									
							</cfcase>--->
							<!--- Check if the current category is a Nursing Category. --->
							<cfcase value="WD Hourly">
								<cfif rollup is 2>
									<cfset dsWDHVarBgt = #helperObj.FetchLaborTrackingDivisionalWDHVarBgt(dsCensusDetails.iOPSArea_ID, PtoPFormat
									, true)#>
								</cfif>
								<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime#>
								
								


								<!--- Display the WD Regular, OT, Total, Budget, and Variance Hours. --->
								<!---<td align="right" style="padding-right: 5px;">
									<font size="-1">.
										#helperObj.LaborNumberFormat(fRegular, "0.0")#
										
									</font>
								</td>
								<td align="right" style="padding-right: 5px;">
									<font size="-1">
										#helperObj.LaborNumberFormat(fOvertime, "0.0")#
										
									</font>
								</td>		--->
								<td align="right" style="padding-right: 5px;">
								 	<font size="-1">
										#helperObj.LaborNumberFormat(fRegular + fOvertime, "0.0")#
										
									</font>
								</td>		
								<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
								 	<font size="-1">
										
										<cfif dsLaborTrackingWDSInfo.recordcount is 0 or dsLaborTrackingWDSInfo.nStatus is "T">
											<cfif rollup is 3>
												<cfif cDescription Is "">
														#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
												<cfelse>
													<a style="width: 100%; height: 100%; text-align: right; vertical-align: top; padding-top: 8px;
													 cursor: hand; text-decoration: none; 
													 color: black;" 
													 title="Click to see Variable Budget Description" 
													 titleDisplay="Labor Tracking Variable Budget Formula Description" 
													 href='###houseTooltipDivName#' class='load-local' rel='###houseTooltipDivName#'> 
														#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
													</a>
													<div id="#houseTooltipDivName#" style="#houseTooltipDivStyles#">
														#cDescription#
													</div>
												</cfif>
											<cfelse>#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#</cfif>											

											<cfset WDHVarBgt = #WDHVarBgt# + #fVariableBudget#>
								
											<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>
											<cfset nursingBudgetTotalHours = #nursingBudgetTotalHours# + #fVariableBudget#>	
											<cfset nursingTotalHours = #nursingTotalHours# + #fRegular# + #fOvertime#>
										<cfelse> 
											<cfif rollup is 2>
													#helperObj.LaborNumberFormat(dsWDHVarBgt.varbgt, "0.00")# 
													<cfset WDHVarBgt = #WDHVarBgt# + #dsWDHVarBgt.varbgt#>
													
													<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #dsWDHVarBgt.varbgt#>	
													<cfset nursingBudgetTotalHours = #nursingBudgetTotalHours# + #fVariableBudget#>
													
											<cfelse> -
												<!---<cfset totalDailyBudgetHours = #totalDailyBudgetHours# - #fVariableBudget#>--->	
											</cfif>
										</cfif>
									</font>
								</td>
								<td align="right" style="padding-right: 5px;">
								 	<cfif rollup is 2>
									   <cfset dsWDHVarBgt.varbgt =  #NumberFormat(dsWDHVarBgt.varbgt, "0.00")#>
										<cfset WDVariance = #dsWDHVarBgt.varbgt# - (#fRegular# + #fOvertime#)>
										<font size="-1" color="<cfif WDVariance lt 0>Red<cfelse>Black</cfif>">
											#helperObj.LaborNumberFormat(WDVariance, "0.00")#
											<cfset WDHVariance = #WDHVariance# + WDVariance>
										</font>
									<cfelse>
								 		<cfset WDVariance = #fVariableBudget# - (#fRegular# + #fOvertime#)>
										<font size="-1" color="<cfif WDVariance lt 0>Red<cfelse>Black</cfif>">
											<cfif dsLaborTrackingWDSInfo.recordcount is 0 or dsLaborTrackingWDSInfo.nStatus is "T">
												#helperObj.LaborNumberFormat(WDVariance, "0.00")#
												<cfset WDHVariance = #WDHVariance# + WDVariance>
											<cfelse> - </cfif>
										</font>
									</cfif>
								</td>																
							</cfcase>
							<cfcase value="Resident Care,Nurse Consultant,LPN - LVN">
								<!--- Add the current category's hours to the nursing daily total. --->
								<cfset nursingBudgetTotalHours = #nursingBudgetTotalHours# + #fVariableBudget#>
								<cfset nursingTotalHours = #nursingTotalHours# + #fRegular# + #fOvertime# + #fOther#>
							
								<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime# + #fOther#>
								<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>					
								
								<cfset NursingVarBgtDesc = "To see variable budget formulas for Nursing categories, refer to house FTA.">
													
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
								
								<cfset houseTooltipNursingDivName = "divVariableBudgetPopupRegional123">
								<cfset houseTooltipNursingDivStyles = "font-size: 8pt; font-family: tahoma; z-index: 140;
								 padding: 2px; background-color: ##d9d9c2; display: none;">

								<!--- Display the Nursing Sub-Totals. --->
								<td colspan="1" align="right" style="padding-right: 5px;">
								 	<font size="-1">
										#helperObj.LaborNumberFormat(nursingTotalHours, "0.0")#
										<cfset NursingActualHours = NursingActualHours + #nursingTotalHours#>
									</font>
								</td>						
								<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
								 	<font size="-1">
										<cfif rollup is 3>
											<a style="width: 100%; height: 100%; text-align: right; vertical-align: top;
											 padding-top: 8px; cursor: hand; text-decoration: none; color: black;" 
											 title="Click to see Variable Budget Description" 
											 titleDisplay="Labor Tracking Variable Budget Formula Description"
											  href='###houseTooltipNursingDivName#' class='load-local' rel='###houseTooltipNursingDivName#'> 
												#helperObj.LaborNumberFormat(nursingBudgetTotalHours, "0.00")#
											</a>
											<div id="#houseTooltipNursingDivName#" style="#houseTooltipNursingDivStyles#">
												#NursingVarBgtDesc#
											</div>
										<cfelse>#helperObj.LaborNumberFormat(nursingBudgetTotalHours, "0.00")#</cfif>											
										
										<cfset NursingBudgetHours = NursingBudgetHours + #nursingBudgetTotalHours#>
									</font>
								</td>
								<td align="right" style="padding-right: 5px;">
								 	<font size="-1" color="<cfif nursingDailyVariance lt 0>Red<cfelse>Black</cfif>">
										#helperObj.LaborNumberFormat(nursingDailyVariance, "0.00")#
										<cfset NursingVariance = NursingVariance + #nursingDailyVariance#>
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
										<cfif rollup is 3>
											<cfif cDescription Is "">
													#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
											<cfelse>
												<a style="width: 100%; height: 100%; text-align: right; vertical-align: top;
												 padding-top: 8px; cursor: hand; text-decoration: none; color: black;" 
												 title="Click to see Variable Budget Description" 
												 titleDisplay="Labor Tracking Variable Budget Formula Description" 
												 href='###houseTooltipDivName#' class='load-local' rel='###houseTooltipDivName#'> 
													#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
												</a>
												<div id="#houseTooltipDivName#" style="#houseTooltipDivStyles#">
													#cDescription#
												</div>
											</cfif>
										<cfelse>#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#</cfif>											
									</font>
								</td>
								<td align="right" style="padding-right: 5px;">
								 	<font size="-1" color="<cfif kitchenVariance lt 0>Red<cfelse>Black</cfif>">
										#helperObj.LaborNumberFormat(kitchenVariance, "0.00")#
										
									</font>
								</td>	
							</cfcase>
							<cfcase value="CRM">
							<!--- Calculate the CRM Sub-Total's variance. --->
							<cfset nursingDailyVariance = #nursingBudgetTotalHours# - #nursingTotalHours#>
							
						  	<cfif isCCLLCHouse is 0 or isCCLLC is 0>  
								<!--- Add the current category's hours to the daily total. --->
								<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime#>
								<!--- Add the current category's budget hours to the daily total. --->
								<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>							
							 </cfif> 
							
							<!--- Display the CRM Sub-Totals. --->
<!--- 							  <td colspan="1" align="right" style="padding-right: 5px;">
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
							</td> --->	 	
							
							<!--- Calculate the Kitchen Variance, which gets displayed at the end of this case --->
							<cfset kitchenVariance = fVariableBudget - (fRegular + fOvertime)>
							
							<!--- Display the Kitchen Regular, OT, Total, Budget, and Variance Hours. --->
							<cfif isCCLLCHouse is 1 or isCCLLC is 1>
								<td align="right" style="padding-right: 5px;">-</td>
								<td align="right" style="padding-right: 5px;">-</td>		
								<td align="right" style="padding-right: 5px;">-</td>		
								<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">-</td>
								<td align="right" style="padding-right: 5px;">-</td>	
							<cfelse>
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
							</cfif>															
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
									<cfif cLaborTrackingCategory is not "Kitchen Training">
										<!--- Add the current category's hours to the daily total. --->
										<cfset totalDailyHours = #totalDailyHours# + #fAll#>
										<!--- Stores the current Column's Variance, which is Var Bgt minus Actual Hours --->
										<cfset categoryVariance = #fVariableBudget# - #fRegular#>
									<!---	<cfset categoryVariance = #fVariableBudget# - #fAll#>	 ---> <!--- Gthota 2/26/2018  replace with fRegular  --->						
										<!--- Display the Non-Nursing Hours. --->
										<td align="right" style="padding-right: 5px;"> 
										 	<font size="-1">
										 		#helperObj.LaborNumberFormat(fRegular, "0.0")# 
												<!--- #helperObj.LaborNumberFormat(fAll, "0.0")# -R2  ---> <!--- Gthota 02/26/2018  replaced code with fregular instead of fAll--->
											</font>
										</td>
										<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
										 	<font size="-1">
											<cfif rollup is 3>
												<cfif cDescription Is "">
														#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
												<cfelse>
													<a style="width: 100%; height: 100%; text-align: right; vertical-align: top; 
													padding-top: 8px; cursor: hand; text-decoration: none; color: black;" 
													title="Click to see Variable Budget Description" 
													titleDisplay="Labor Tracking Variable Budget Formula Description"
													 href='###houseTooltipDivName#' class='load-local' rel='###houseTooltipDivName#'> 
														#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
													</a>
													<div id="#houseTooltipDivName#" style="#houseTooltipDivStyles#">
														#cDescription#
													</div>
												</cfif>
											<cfelse>#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#</cfif>	
											</font>
										</td>
										<td align="right" style="padding-right: 5px;">
										 	<font size="-1" color="<cfif categoryVariance lt 0>Red<cfelse>Black</cfif>">
												#helperObj.LaborNumberFormat(categoryVariance, "0.00")#
												
											</font>
										</td>						
									</cfif>
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
													<cfset TotalActualHours = TotalActualHours + #totalDailyHours#>
												</strong>
											</font>
										</td>
										<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
										 	<font size="-1">
												#helperObj.LaborNumberFormat(totalDailyBudgetHours, "0.00")#
												<cfset TotalBudgetHours = TotalBudgetHours + #totalDailyBudgetHours#>
											</font>
										</td>
										<td align="right" style="padding-right: 5px;">
										 	<font size="-1" color="<cfif currentDaysVariance lt 0>Red<cfelse>Black</cfif>">
												#helperObj.LaborNumberFormat(currentDaysVariance, "0.00")#
												<cfset TotalVariance = TotalVariance + #currentDaysVariance#>												
											</font>
										</td>			
									</cfif>
								</cfif>	
							</cfdefaultcase>	
						</cfswitch>		
					</cfif>
				</cfif>
			</cfloop>
		</tr>
	</cfloop>
	<tr></tr>
	<tr>
		<cfset dsCensusDetailsMTD = #helperObj.FetchAverageMTDCensusDetailsRollup(dsCensusDetails, rollup, false)#>
		<cfif rollup is 3>
			<cfset dsLaborHours = #helperObj.FetchLaborHoursRollup(RegionID, PtoPFormat, 1,true)#>
		<cfelseif rollup is 2>
			<cfset dsLaborHours = #helperObj.FetchLaborHoursRollup(DivisionID, PtoPFormat, 2,true)#>
		<cfelseif rollup is 1>
			<cfset dsLaborHours = #helperObj.FetchLaborHoursConsolidated(PtoPFormat)#>
		</cfif>
		<cfset dsMTDLaborCtgyHours = #helperObj.FetchMTDLaborHoursRollup(dsLaborHours, 1)#>
		<cfset dsMTDLaborNursingHours = #helperObj.FetchMTDLaborHoursRollup(dsLaborHours, 2)#>
		<cfset dsMTDLaborHours = #helperObj.FetchMTDLaborHoursRollup(dsLaborHours, 3)#>

		<td class="locked" colspan="4" bgcolor="#totalcellcolor#" align="right" style="#leftPaneStyle#">
		 	<cfif rollup is 3>
				<cfset dsRegionInfo = #helperObj.FetchRegionInfo(RegionID)#>
					<font size="-1"><strong>Total #dsRegionInfo.Region# Region </strong></font>
			<cfelseif rollup is 2>
				<cfset dsDivisionInfo = #helperObj.FetchDivisionInfo(DivisionID)#>
					<font size="-1"><strong>Total #dsDivisionInfo.Division# Division </strong></font>
			<cfelseif rollup is 1>
				<font size="-1"><strong>ALC Consolidated </strong></font>
			</cfif>
		</td>
		<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
		 	<font size="-1">
				<cfif rollup is 2><strong>#helperObj.LaborNumberFormat(totalTenants, "0.0")#</strong>
				<cfelse><strong>#helperObj.LaborNumberFormat(dsCensusDetailsMTD.TotalTenants, "0.0")#</strong></cfif>
			</font>
		</td>		
		<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
		 	<font size="-1">
				<cfif rollup is 2><strong>#helperObj.LaborNumberFormat(totalOccupants, "0.0")#</strong>
				<cfelse><strong>#helperObj.LaborNumberFormat(dsCensusDetailsMTD.TotalOccupancy, "0.0")#</strong></cfif>
			</font>
		</td>			
		<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
		 	<font size="-1">
				<strong>#helperObj.LaborNumberFormat(dsCensusDetailsMTD.TotalPoints, "0.0")#</strong>
			</font>
		</td>		
		<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
		 	<font size="-1">
				<strong>#helperObj.LaborNumberFormat(dsCensusDetailsMTD.TotalTwoPersonAssists, "0.0")#	</strong>
			</font>
		</td>				
		<!--- loop through labor categories --->
		<cfloop query="dsMTDLaborCtgyHours">
			<!---	<!--- Stores the name of the current Tooltip Popup Div Element. --->
				<cfset currentTooltipDivName = "divVariableBudgetPopup" & dsMTDLaborCtgyHours.CurrentRow>
				<!--- Stores all of the styles required for the standard tooltip Div element. --->
				<cfset currentTooltipDivStyles = "font-size: 8pt; font-family: tahoma; z-index: 140; padding: 2px; background-color: ##d9d9c2; display: none;">--->
			<cfif dsMTDLaborCtgyHours.cLaborTrackingCategory is not "Kitchen Training" 
				and dsMTDLaborCtgyHours.cLaborTrackingCategory is not "WD Salary">
				<!--- Check if the current column should be displayed. --->
					<cfswitch expression="#dsMTDLaborCtgyHours.cLaborTrackingCategory#">
						<!---<cfcase value = "WD Salary">
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
								<font size="-1">
									<strong>#helperObj.LaborNumberFormat(WDSActual, "0.0")#</strong>
								</font>
							</td>		
							<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
								<font size="-1">
									<!---<cfif cDescription Is "">
										<strong>#helperObj.LaborNumberFormat(WDSVarBgt, "0.00")#</strong>
									<cfelse>
										<a style="width: 100%; height: 100%; text-align: right; vertical-align: top; padding-top: 8px; cursor: hand; text-decoration: none; color: black;" title="Click to see Variable Budget Description" titleDisplay="Labor Tracking Variable Budget Formula Description" href='###currentTooltipDivName#' class='load-local' rel='###currentTooltipDivName#'>--->
											<strong>#helperObj.LaborNumberFormat(WDSVarBgt, "0.00")#</strong>
										<!---</a>
										<div id="#currentTooltipDivName#" style="#currentTooltipDivStyles#">
											#cDescription#
										</div>
									</cfif>	--->								
								</font>
							</td>
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
								<font size="-1" color="<cfif (WDSTotalVariance) lt 0>Red<cfelse>Black</cfif>">
									<strong>#helperObj.LaborNumberFormat(WDSTotalVariance, "0.00")#</strong>
								</font>
							</td>																
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
								<font size="-1">
									<strong>&##160; - </strong>
								</font>
							</td>									
						</cfcase>
--->						<cfcase value="WD Hourly">							
							<!---<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
								<font size="-1">
									<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fRegular, "0.0")#</strong>
								</font>
							</td>
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
								<font size="-1">
									<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fOvertime, "0.0")#</strong>
								</font>
							</td>		--->
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
							 	<font size="-1">
									<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fActual, "0.0")#</strong>
								</font>
							</td>		
							<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							 	<font size="-1">
									<!---<cfif cDescription Is "">
										<strong>#helperObj.LaborNumberFormat(WDHVarBgt, "0.0")#</strong>
									<cfelse>
										<a style="width: 100%; height: 100%; text-align: right; vertical-align: top; padding-top: 8px; cursor: hand; text-decoration: none; color: black;" title="Click to see Variable Budget Description" titleDisplay="Labor Tracking Variable Budget Formula Description" href='###currentTooltipDivName#' class='load-local' rel='###currentTooltipDivName#'>--->
											<strong>#helperObj.LaborNumberFormat(WDHVarBgt, "0.0")#</strong>
										<!---</a>
										<div id="#currentTooltipDivName#" style="#currentTooltipDivStyles#">
											#cDescription#
										</div>
									</cfif>--->
								</font>
							</td>
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
							 	<font size="-1" color="<cfif WDHVariance lt 0>Red<cfelse>Black</cfif>">
									<strong>#helperObj.LaborNumberFormat(WDHVariance, "0.0")#</strong>
								</font>
							</td>																
						</cfcase>
						<cfcase value="Resident Care,Nurse Consultant,LPN - LVN">
							<!--- Display the Reg/OT/Other columns. --->
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
							 	<font size="-1">
									<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fRegular, "0.0")#</strong>
								</font>
							</td>
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
							 	<font size="-1">
									<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fOvertime, "0.0")#</strong>
								</font>
							</td>
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
							 	<font size="-1">
									<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fOther, "0.0")#</strong>
								</font>
							</td>
						</cfcase>
						<!--- Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->			
						<cfcase value="Kitchen">
							
							<!--- Display the Nursing Sub-Totals. --->
							<td colspan="1" align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
							 	<font size="-1">
									<strong>#helperObj.LaborNumberFormat(NursingActualHours, "0.0")#</strong>
								</font>
							</td>						
							<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							 	<font size="-1">
								<!---	<cfif cDescription Is "">
										<strong>#helperObj.LaborNumberFormat(NursingBudgetHours, "0.00")#</strong>
									<cfelse>
										<a style="width: 100%; height: 100%; text-align: right; vertical-align: top; padding-top: 8px; cursor: hand; text-decoration: none; color: black;" title="Click to see Variable Budget Description" titleDisplay="Labor Tracking Variable Budget Formula Description" href='###currentTooltipDivName#' class='load-local' rel='###currentTooltipDivName#'>--->
											<strong>#helperObj.LaborNumberFormat(NursingBudgetHours, "0.00")#</strong>
										<!---</a>
										<div id="#currentTooltipDivName#" style="#currentTooltipDivStyles#">
											#cDescription#
										</div>
									</cfif>--->
								</font>
							</td>
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
							 	<font size="-1" color="<cfif NursingVariance lt 0>Red<cfelse>Black</cfif>">
									<strong>#helperObj.LaborNumberFormat(NursingVariance, "0.00")#</strong>
								</font>
							</td>		
							
							<!--- Display the Kitchen Regular, OT, Total, Budget, and Variance Hours. --->
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
							 	<font size="-1">
									<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fRegular, "0.0")#</strong>
								</font>
							</td>
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
							 	<font size="-1">
									<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fOvertime, "0.0")#</strong>
								</font>
							</td>		
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
							 	<font size="-1">
									<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fActual, "0.0")#</strong>
								</font>
							</td>		
							<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
							 	<font size="-1">
									<!---<cfif cDescription Is "">
										<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fVariableBudget, "0.00")#</strong>
									<cfelse>
										<a style="width: 100%; height: 100%; text-align: right; vertical-align: top; padding-top: 8px; cursor: hand; text-decoration: none; color: black;" title="Click to see Variable Budget Description" titleDisplay="Labor Tracking Variable Budget Formula Description" href='###currentTooltipDivName#' class='load-local' rel='###currentTooltipDivName#'>--->
											<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fVariableBudget, "0.00")#</strong>
										<!---</a>
										<div id="#currentTooltipDivName#" style="#currentTooltipDivStyles#">
											#cDescription#
										</div>
									</cfif>--->
								</font>
							</td>
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
							 	<font size="-1" color="<cfif dsMTDLaborCtgyHours.Variance lt 0>Red<cfelse>Black</cfif>">
									<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.Variance, "0.00")#</strong>
								</font>
							</td>	
						</cfcase>
						<cfcase value="CRM">
							<!--- Calculate the CRM Sub-Total's variance. --->
							<cfset nursingDailyVariance = #nursingBudgetTotalHours# - #nursingTotalHours#>
							
							<!--- <cfif isCCLLCHouse is 0 or isCCLLC is 0> --->
								<!--- Add the current category's hours to the daily total. --->
								<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime#>
								<!--- Add the current category's budget hours to the daily total. --->
								<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>							
							<!--- </cfif> --->
							
							<!--- Display the CRM Sub-Totals. --->
							<!--- <td colspan="1" align="right" style="padding-right: 5px;">
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
							</td>	 --->	
							
							<!--- Calculate the Kitchen Variance, which gets displayed at the end of this case --->
							<cfset kitchenVariance = fVariableBudget - (fRegular + fOvertime)>
							
							<!--- Display the Kitchen Regular, OT, Total, Budget, and Variance Hours. --->
							<cfif isCCLLCHouse is 1 or isCCLLC is 1>
								<td align="right" style="padding-right: 5px;">-</td>
								<td align="right" style="padding-right: 5px;">-</td>		
								<td align="right" style="padding-right: 5px;">-</td>		
								<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">-</td>
								<td align="right" style="padding-right: 5px;">-</td>	
							<cfelse>
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
							</cfif>															
						</cfcase>
						<cfcase value="PPADJ">
							<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
								<font size="-1">
							 		<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fAll, "0.0")#</strong>
								</font>
							</td>						
						</cfcase>
						
						<!--- Display the Non-Nursing--->
						<cfdefaultcase>
							<!--- Check if the current Category is PTO and only display Actual if it is. --->
							<cfif cLaborTrackingCategory is "PTO">
								<!--- Display the PTO Hours. --->
								<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
								 	<font size="-1">
										<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fAll, "0.0")#</strong>
									</font>
								</td>						
							<cfelse>
								<cfif cLaborTrackingCategory is not "Kitchen Training">
									<!--- Display the Non-Nursing Hours. --->
									<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" > 
									 	<font size="-1">
											<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fActual, "0.0")#</strong>
										</font>
									</td>
									<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
									 	<font size="-1">
											<!---<cfif cDescription Is "">
													<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fVariableBudget, "0.00")#</strong>
											<cfelse>
												<a style="width: 100%; height: 100%; text-align: right; vertical-align: top; padding-top: 8px; cursor: hand; text-decoration: none; color: black;" title="Click to see Variable Budget Description" titleDisplay="Labor Tracking Variable Budget Formula Description" href='###currentTooltipDivName#' class='load-local' rel='###currentTooltipDivName#'>--->
													<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.fVariableBudget, "0.00")#</strong>
												<!---</a>
												<div id="#currentTooltipDivName#" style="#currentTooltipDivStyles#">
													#cDescription#
												</div>
											</cfif>---->
										</font>
									</td>
									<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
									 	<font size="-1" color="<cfif dsMTDLaborCtgyHours.Variance lt 0>Red<cfelse>Black</cfif>">
											<strong>#helperObj.LaborNumberFormat(dsMTDLaborCtgyHours.Variance, "0.00")#</strong>
										</font>
									</td>						
								</cfif>
								<cfif dsMTDLaborCtgyHours.bIsTraining eq true>
									<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
									 	<font size="-1">
											<strong>
												#helperObj.LaborNumberFormat(TotalActualHours, "0.0")#
											</strong>
										</font>
									</td>
									<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
									 	<font size="-1">
											<strong>#helperObj.LaborNumberFormat(TotalBudgetHours, "0.00")#</strong>	
										</font>
									</td>
									<td align="right" style="padding-right: 5px;" bgcolor="#totalcellcolor#" >
									 	<font size="-1" color="<cfif TotalVariance lt 0>Red<cfelse>Black</cfif>">
											<strong>#helperObj.LaborNumberFormat(TotalVariance, "0.00")#</strong>								
										</font>
									</td>	
								</cfif>		
							</cfif>	
						</cfdefaultcase>>	
					</cfswitch>		
			</cfif>
		</cfloop>
	</tr> <tr style="height:12px;"></tr>
	
<!---------------------------
	 elseif rollup is 0 which means houselevel.
-------------------------------->	
<cfelse> 

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
		
<!--- Stores the total number of hours for the current day. --->
<cfset totalDailyHours = 0>
<!--- Stores te total budget hours for the current day. --->
<cfset totalDailyBudgetHours = 0>
<!--- Stores the total number of hours worked for all Nursing categories, which includes Regular, Overtime, and Other. --->
<cfset nursingTotalHours = 0>
<!--- Accumulates the current days budget for all Nursing Categories. --->
<cfset nursingBudgetTotalHours = 0>	
<cfset nursingDailyActual = 0>
<cfset nursingDailyBudget = 0>

<!---- Ganga Thota 08/01/2017  all ccllc houses by default going to be set 'zreo' --->
<cfif isCCLLCHouse is 1 or isCCLLC is 1>
 <cfset isCCLLCHouse = 0>
 <cfset isCCLLC = 0>
</cfif>
		<!--- loop through labor categories --->
		<cfloop query="dsCurrentLaborTrackingData">
		<cfif ccllcHouse is 0>
			<cfif cLaborTrackingCategory is not "WD Salary" and cLaborTrackingCategory is not "Kitchen Training">
				<!--- Check if the current column should be displayed. --->
				<cfif bIsVisible eq true>
					<!--- --->
					<cfswitch expression="#cLaborTrackingCategory#">
						<!--- Check if the current category is a Nursing Category. --->
						<cfcase value="WD Hourly">
							<!--- Calculate the WD Variance, which gets displayed at the end of this case --->
							<cfif open is 1 or 
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 1 
								and DateFormat(dsLaborTrackingWDSInfo.dTermdate, "dd") lt currentDay)) or
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 0 
								and DateFormat(dsLaborTrackingWDSInfo.dHiredate-1, "dd") gte currentDay)) or
								(WDStermed is 1 and (samePeriod is 0 and currPeriod is 0))>
								<cfset WDVariance = fVariableBudget - (fRegular + fOvertime)>
							<cfelse>
								<cfset WDVariance = 0>
							</cfif>
							
							<!--- Add the current category's hours to the daily total. --->
							<cfif open is 1 or 
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 1 
								and DateFormat(dsLaborTrackingWDSInfo.dTermdate, "dd") lt currentDay)) or
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 0 
								and DateFormat(dsLaborTrackingWDSInfo.dHiredate-1, "dd") gte currentDay)) or
								(WDStermed is 1 and (samePeriod is 0 and currPeriod is 0))>
								<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime#>
								<!---<cfset nursingTotalHours = #nursingTotalHours# + #fRegular# + #fOvertime#>--->
							<cfelse>
								<cfset totalDailyHours = #totalDailyHours# + 0>
							</cfif>
							<!--- Add the current category's budget hours to the daily total. --->
							<cfif open is 1 or 
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 1 
								and DateFormat(dsLaborTrackingWDSInfo.dTermdate, "dd") lt currentDay)) or
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 0 
								and DateFormat(dsLaborTrackingWDSInfo.dHiredate-1, "dd") gte currentDay)) or
								(WDStermed is 1 and (samePeriod is 0 and currPeriod is 0))>
								<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>	
								<cfset nursingBudgetTotalHours = #nursingBudgetTotalHours# + #fVariableBudget#>						
							<cfelse>
								<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + 0>							
							</cfif>
							<!--- Display the WD Regular, OT, Total, Budget, and Variance Hours. --->
							<!---<td align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fRegular, "0.0")#
								</font>
							</td>
							<td align="right" style="padding-right: 5px;">
								<font size="-1">
									#helperObj.LaborNumberFormat(fOvertime, "0.0")#
								</font>
							</td>		--->
							<td align="right" style="padding-right: 5px;">
							 	 <font size="-1">
									#helperObj.LaborNumberFormat(fRegular + fOvertime, "0.0")#
									<cfset nursingTotalHours = #nursingTotalHours# + #fRegular# + #fOvertime#>
								</font>
							</td>		
							<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
								  <font size="-1">
							<cfif open is 1 or 
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 1 
								and DateFormat(dsLaborTrackingWDSInfo.dTermdate, "dd") lt currentDay)) or
								((samePeriod is 1 or currPeriod is 1) and (WDStermed is 0 
								and DateFormat(dsLaborTrackingWDSInfo.dHiredate-1, "dd") gte currentDay)) or
								(WDStermed is 1 and (samePeriod is 0 and currPeriod is 0))>
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
							
							<cfif isCCLLCHouse is 0 or isCCLLC is 0>
								<!--- Add the current category's hours to the daily total. --->
								<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime#>
								<!--- Add the current category's budget hours to the daily total. --->
								<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>							
							</cfif>
							
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
							<cfif isCCLLCHouse is 1 or isCCLLC is 1>
								<td align="right" style="padding-right: 5px;">  -1</td>
								<td align="right" style="padding-right: 5px;">  -2</td>		
								<td align="right" style="padding-right: 5px;">  -3</td>		
								<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">10z -4</td>
								<td align="right" style="padding-right: 5px;">  -5</td>	
							<cfelse>  
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
							</cfif>															
						</cfcase>
						<cfcase value="CRM">
							<!--- Calculate the CRM Sub-Total's variance. --->
							<cfset nursingDailyVariance = #nursingBudgetTotalHours# - #nursingTotalHours#>
							
							<!--- <cfif isCCLLCHouse is 0 or isCCLLC is 0> --->
								<!--- Add the current category's hours to the daily total. --->
								<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime#>
								<!--- Add the current category's budget hours to the daily total. --->
								<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>							
							<!--- </cfif> --->
							
							<!--- Display the CRM Sub-Totals. --->
							<!--- <td colspan="1" align="right" style="padding-right: 5px;">
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
							</td>	 --->	
							
							<!--- Calculate the Kitchen Variance, which gets displayed at the end of this case --->
							<cfset kitchenVariance = fVariableBudget - (fRegular + fOvertime)>
							
							<!--- Display the Kitchen Regular, OT, Total, Budget, and Variance Hours. --->
							<cfif isCCLLCHouse is 1 or isCCLLC is 1>
								<td align="right" style="padding-right: 5px;">-</td>
								<td align="right" style="padding-right: 5px;">-</td>		
								<td align="right" style="padding-right: 5px;">-</td>		
								<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">-</td>
								<td align="right" style="padding-right: 5px;">-</td>	
							<cfelse>
								<td align="right" style="padding-right: 5px;">
								  <!--- 	#isCCLLCHouse# #isCCLLC# ---><font size="-1"> 
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
							</cfif>															
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
							<!---	<cfset totalDailyHours = #totalDailyHours# + #fAll#>  --->  <!--- Gthota 02/26/2018  Replace code with fAll to fRegular  --->	
								<cfset totalDailyHours = #totalDailyHours# + #fRegular#>
								<!--- Stores the current Column's Variance, which is Var Bgt minus Actual Hours --->
								<!--- <cfset categoryVariance = #fVariableBudget# - #fAll#>	--->  <!--- Gthota 02/26/2018  Replace code with fAll to fRegular  --->	
								<cfset categoryVariance = #fVariableBudget# - #fRegular#>				
								<!--- Display the Non-Nursing Hours. --->
								<td align="right" style="padding-right: 5px;"> 
								 	 <font size="-1"> 
								 	 <!---	<cfif cLaborTrackingCategory is "Training">
										#helperObj.LaborNumberFormat(fAll, "0.0")#     <!--- Gthota 02/26/2018  Replace code with fAll to fRegular  --->
									<cfelse>  --->
										#helperObj.LaborNumberFormat(fRegular, "0.0")#
								<!---	</cfif> --->
										<!--- #helperObj.LaborNumberFormat(fAll, "0.0")#  --->
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
		<cfelse> <!---ccllchouse is 1 --->
			<cfset dsCCLLCSalariedEmpInfo = #helperObj.FetchCCLLCSalariedInfo(houseId)#>
			<cfif dsCCLLCSalariedEmpInfo.recordcount is not 0>	
				<cfset ccllcSalEmp = 1>
				<cfset sunday = 0>
				<cfset dsSundaysOfMonth = #helperObj.FetchSundaysOfMonth(currentDay, PtoPFormat)#>
					<cfif dsSundaysOfMonth.name eq "Sunday">	
						<cfset sunday = 1>
					<cfelse>	
						<cfset sunday is 0>		
					</cfif>
			<cfelse>
				<cfset ccllcSalEmp = 0>
			</cfif>
		
			<cfif cLaborTrackingCategory is "Kitchen">
				<cfif ccllcSalEmp is 1>
					<cfif sunday is 1>
						<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime# + #dsCCLLCSalariedEmpInfo.iWorkWeekHours#>
						<cfset kitchenVariance = fVariableBudget - (fRegular + fOvertime + dsCCLLCSalariedEmpInfo.iWorkWeekHours)>
					<cfelse>
						<!--- Add the current category's hours to the daily total. --->
						<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime#>
						<!--- Calculate the Kitchen Variance, which gets displayed at the end of this case --->
						<cfset kitchenVariance = fVariableBudget - (fRegular + fOvertime)>
					</cfif>
				<cfelse>
					<!--- Add the current category's hours to the daily total. --->
					<cfset totalDailyHours = #totalDailyHours# + #fRegular# + #fOvertime#>
					<!--- Calculate the Kitchen Variance, which gets displayed at the end of this case --->
					<cfset kitchenVariance = fVariableBudget - (fRegular + fOvertime)>
				</cfif>

				<!--- Add the current category's budget hours to the daily total. --->
				<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>							
				
				<!--- Display the Kitchen Regular, OT, Total, Budget, and Variance Hours. --->
				<td align="right" style="padding-right: 5px;">
				 	<font size="-1">
						<cfif ccllcSalEmp is 1>
							<cfif sunday is 1>
								#helperObj.LaborNumberFormat(fRegular + dsCCLLCSalariedEmpInfo.iWorkWeekHours, "0.0")#
								<cfset totalRegular = totalRegular+ fRegular + dsCCLLCSalariedEmpInfo.iWorkWeekHours>
							<cfelse>
								#helperObj.LaborNumberFormat(fRegular, "0.0")#
								<cfset totalRegular = totalRegular + fRegular>
							</cfif>
						<cfelse>
							#helperObj.LaborNumberFormat(fRegular, "0.0")#
							<cfset totalRegular = totalRegular + fRegular>
						</cfif>
					</font>
				</td>
				<td align="right" style="padding-right: 5px;">
					 <font size="-1">
						#helperObj.LaborNumberFormat(fOvertime, "0.0")#
					</font>
				</td>		
				<td align="right" style="padding-right: 5px;">
					 <font size="-1">
						<cfif ccllcSalEmp is 1>
							<cfif sunday is 1>
								#helperObj.LaborNumberFormat(fRegular + fOvertime + dsCCLLCSalariedEmpInfo.iWorkWeekHours, "0.0")#
								<cfset totalActual = totalActual + fRegular + fOvertime + dsCCLLCSalariedEmpInfo.iWorkWeekHours>
							<cfelse>
								#helperObj.LaborNumberFormat(fRegular + fOvertime, "0.0")#
								<cfset totalActual = totalActual + fRegular + fOvertime>
							</cfif>
						<cfelse>
							#helperObj.LaborNumberFormat(fRegular + fOvertime, "0.0")#
							<cfset totalActual = totalActual + fRegular + fOvertime>
						</cfif>
					</font>
				</td>		
				<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
				 	<font size="-1">
						#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
						<cfset kitchenTrngVarBgt = (2/100 * fVariableBudget)>
						<cfset totalKitchenTrngVarBgt = #totalKitchenTrngVarBgt# + #kitchenTrngVarBgt#>
					</font>
				</td>
				<td align="right" style="padding-right: 5px;">
				 	<font size="-1" color="<cfif kitchenVariance lt 0>Red<cfelse>Black</cfif>">
						#helperObj.LaborNumberFormat(kitchenVariance, "0.00")#
					</font>
				</td>																
			</cfif>
			<cfif cLaborTrackingCategory is "Kitchen Training">
				<!--- Add the current category's hours to the daily total. --->
				<cfset totalDailyHours = #totalDailyHours# + #fAll#>
				<!--- Stores the current Column's Variance, which is Var Bgt minus Actual Hours --->
				<!---<cfset categoryVariance = #fVariableBudget# - #fAll#>						--->
				<cfset categoryVariance = #fVariableBudget# - #fAll#> <!---#kitchenTrngVarBgt#--->
				<!--- Add the current category's budget hours to the daily total. --->
				<cfset totalDailyBudgetHours = #totalDailyBudgetHours# + #fVariableBudget#>						
				
				<!--- Display the Non-Nursing Hours. --->
				<td align="right" style="padding-right: 5px;"> 
				 	<font size="-1">
						#helperObj.LaborNumberFormat(fAll, "0.0")#
					</font>
				</td>
				<td colspan="1" align="right"  bgcolor="#budgetcellcolor#"  style="padding-right: 5px;">
					 <font size="-1">
						#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
						<!---#helperObj.LaborNumberFormat(kitchenTrngVarBgt, "0.00")#--->
					</font>
				</td>
				<td align="right" style="padding-right: 5px;">
					 <font size="-1" color="<cfif categoryVariance lt 0>Red<cfelse>Black</cfif>">
						#helperObj.LaborNumberFormat(categoryVariance, "0.00")#
					</font>
				</td>						
				<!--- Add to the MTD Training Budget. --->
				<cfset trainingBudgetMtd = #trainingBudgetMtd# + #fVariableBudget#> <!---#kitchenTrngVarBgt#>--->
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
		<cfif ccllcHouse is 0>
			<cfif cLaborTrackingCategory is not "WD Salary" and cLaborTrackingCategory is not "Kitchen Training">
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
						<!--- Add the current category's Actual and Variable Budget Hours to the nursing mtd totals. --->
						<cfset nursingMtdTotalHours = #nursingMtdTotalHours# + #fRegular# + #fOvertime#>
						<cfset nursingMtdBudgetHours = #nursingMtdBudgetHours# + #totalvarbgt#>
						<!--- Stores the current Categories MTD Variance --->
						<cfif open is 1 or (conditionalTrue is 1 and conflict is 0)>
							<cfset categoryMtdVariance = #totalvarbgt# - (#fRegular# + #fOvertime#)>   <!---#fVariableBudget#--->
						<cfelse> <cfset categoryMtdVariance = 0> </cfif>
						
						<!---<td align="right" bgcolor="#totalcellcolor#"  style="padding-right: 5px;">
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
						</td>		--->
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
					<cfelseif cLaborTrackingCategory is "Resident Care" or cLaborTrackingCategory is "Nurse Consultant"
					 or cLaborTrackingCategory is "LPN - LVN">			
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
						<cfif isCCLLC is 0>
							<!--- Add the current category's hours to the mtd total. --->
							<cfset totalMtdHours = #totalMtdHours# + #fRegular# + #fOvertime#>
							<!--- Add the current category's budget hours to the mtd total. --->
							<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fVariableBudget#>							
						</cfif>
					
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
						<cfif isCCLLCHouse is 1 or isCCLLC is 1>
							<td align="right" bgcolor="#totalcellcolor#"  style="padding-right: 5px;">  -</td>
							<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">  -</td>		
							<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">  -</td>		
							<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">  -</td>
							<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;"> -</td>	
						<cfelse>
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
						</cfif>
					<!--- CRM --->
					<cfelseif cLaborTrackingCategory is "CRM">
						<cfif isCCLLC is 0>
							<!--- Add the current category's hours to the mtd total. --->
							<cfset totalMtdHours = #totalMtdHours# + #fRegular# + #fOvertime#>
							<!--- Add the current category's budget hours to the mtd total. --->
							<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fVariableBudget#>							
						</cfif>
					
						<!--- Stores the Nursing Variance, which is Total Variable Budget - Total Actual Hours --->
						<cfset nursingMtdVarianceHours = #nursingMtdBudgetHours# - #nursingMtdTotalHours#>
						
						<!--- Stores the Kitchen Variance, which is Variable Budget - Total Actual --->
						<cfset kitchenMtdVariance = #fVariableBudget# - (#fRegular# + #fOvertime#)>
						
						<!--- Display the Nursing Sub-Totals. --->
<!--- 						<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">
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
						</td> --->
						<!--- Display the Kitchen Regular and Overtime Hours. --->
						<cfif isCCLLCHouse is 1 or isCCLLC is 1>
							<td align="right" bgcolor="#totalcellcolor#"  style="padding-right: 5px;">    -</td>
							<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">  -</td>		
							<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">  -</td>		
							<td colspan="1" align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">  -</td>
							<td align="right" bgcolor="#totalcellcolor#" style="padding-right: 5px;">  -</td>	
						<cfelse>
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
						</cfif>
						<!--- end CRM --->
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
						<cfset totalMtdHours = #totalMtdHours# + #fRegular#>     <!---GThota 02/26/2018  replaced code with fAll to fRegular  --->
						<!--- Stores the current Categories MTD Variance --->
						<cfset categoryMtdVariance = #fVariableBudget# - #fregular#>   <!---GThota 02/26/2018  replaced code with fAll to fRegular  --->
						<!--- Check if the current category is Training --->
						<cfif bIsTraining eq true>
							<!--- Add the current category's budget hours to the mtd total. --->
							<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #trainingBudgetMtd#>		
							<!--- Stores the Total MTD Variance, which is Total Variable Budget minus Total Actual Hours --->
							<cfset mtdVariance = #totalMtdBudgetHours# - #totalMtdHours#>
							<!--- Stores the Training MTD Variance, which is Total Training Var Bgt minus Total Training Hours --->
							<cfset trainingMtdVariance = #fVariableBudget# - #fRegular#>    <!---GThota 02/26/2018  replaced code with fAll to fRegular  --->
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
		<cfelse> <!--- ccllchouse is 1 --->
			<cfset dsCCLLCSalariedEmpInfo = #helperObj.FetchCCLLCSalariedInfo(houseId)#>
			<cfif dsCCLLCSalariedEmpInfo.recordcount is not 0>	
				<cfset ccllcSalEmp = 1>
			<cfelse>
				<cfset ccllcSalEmp = 0>
			</cfif>
					
			<cfif cLaborTrackingCategory is "Kitchen">
				<cfif ccllcSalEmp is 1>
						<cfset totalMtdHours = #totalMtdHours# + #totalActual#>
						<cfset kitchenMtdVariance = #fVariableBudget# - (#totalActual#)>
				<cfelse>
					<cfset totalMtdHours = #totalMtdHours# + #fRegular# + #fOvertime#>
					<cfset kitchenMtdVariance = #fVariableBudget# - (#fRegular# + #fOvertime#)>
				</cfif>

				<!--- Add the current category's budget hours to the mtd total. --->
				<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #fVariableBudget#>							
					
				<!--- Display the Kitchen Regular and Overtime Hours. --->
				<td align="right" bgcolor="#totalcellcolor#"  style="padding-right: 5px;">
				 	<font size="-1">
						<strong>
							<cfif ccllcSalEmp is 1>
									#helperObj.LaborNumberFormat(totalRegular, "0.0")#
							<cfelse>
								#helperObj.LaborNumberFormat(fRegular, "0.0")#
							</cfif>
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
							<cfif ccllcSalEmp is 1>
									#helperObj.LaborNumberFormat(totalActual, "0.0")#
							<cfelse>
								#helperObj.LaborNumberFormat(fRegular + fOvertime, "0.0")#
							</cfif>
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
			</cfif>		
			<cfif cLaborTrackingCategory is "Kitchen Training">
				<!--- Add the current category's hours to the mtd total. --->
				<cfset totalMtdHours = #totalMtdHours# + #fAll#>
				<!--- Add the current category's budget hours to the mtd total. --->
				<cfset totalMtdBudgetHours = #totalMtdBudgetHours# + #trainingBudgetMtd#>		
				<!--- Stores the Total MTD Variance, which is Total Variable Budget minus Total Actual Hours --->
				<cfset mtdVariance = #totalMtdBudgetHours# - #totalMtdHours#>
				<!--- Stores the Training MTD Variance, which is Total Training Var Bgt minus Total Training Hours --->
				<cfset trainingMtdVariance = #fVariableBudget# - #fAll#>
				<!---<cfset trainingMtdVariance = #totalKitchenTrngVarBgt# - #fAll#>--->
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
							<!---#helperObj.LaborNumberFormat(totalKitchenTrngVarBgt, "0.00")#--->
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
		
		<cfloop query="dsTotalLaborTrackingData"><!---Mshah changed here--->
		
		<cfif ccllcHouse is 0>
			<cfif cLaborTrackingCategory is not "WD Salary" and cLaborTrackingCategory is not "Kitchen Training">
				<!--- Add the current category's var budget hours to the mtd total. --->
				<cfif cLaborTrackingCategory is "WD Hourly">
					<cfif conditionalFalse is 0>
						<cfset variableBudgetTotal = #variableBudgetTotal# + #totalvarbgt#>	<!---#fVariableBudget#--->
					<cfelse>				
						<cfset variableBudgetTotal = #variableBudgetTotal# + #fVariableBudget#>
					</cfif>
				<cfelse> 
					<cfset variableBudgetTotal = #variableBudgetTotal# + #fVariableBudget#>					
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
						<cfset nursingVariableBudgetTotal = #nursingVariableBudgetTotal# + #totalvarbgt#>
					<cfelse>				
						<cfset variableBudgetTotal = #variableBudgetTotal# + #fVariableBudget#>
					</cfif>
					
					<!---<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>		--->
							
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
								<cfif dsLaborVariableBudgets.cDescription Is ""> <!---Mshah changed here--->
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
								<cfif dsLaborVariableBudgets.cDescription Is ""> <!---Mshah changed here--->
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
								<cfif dsLaborVariableBudgets.cDescription Is ""> <!---Mshah changed here--->
									<cfif isCCLLCHouse is 1 or isCCLLC is 1> - 
										<cfset variableBudgetTotal = #variableBudgetTotal# - #fVariableBudget#>					
									<cfelse>
										 #helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
									</cfif>
								<cfelse>
									<a style="width: 100%; height: 100%; text-align: right; vertical-align: top; padding-top: 8px; cursor: hand; text-decoration: none; color: black;" title="Click to see Variable Budget Description" titleDisplay="Labor Tracking Variable Budget Formula Description" href='###currentTooltipDivName#' class='load-local' rel='###currentTooltipDivName#'>
									<cfif isCCLLCHouse is 1 or isCCLLC is 1> - 
										<cfset variableBudgetTotal = #variableBudgetTotal# - #fVariableBudget#>					
									<cfelse>
										#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#
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
				<!---Mshah added td to align total--->	
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
				<!---end--->					
				<cfelse>
					<cfif cLaborTrackingCategory is not "PPADJ" and cLaborTrackingCategory is not "Resident Care Training" and cLaborTrackingCategory is not "PTO"> <!---Mshah added here--->
					<!--- Display the Non-Nursing Hours. --->
					<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
						<font size="-1">
							<cfif dsLaborVariableBudgets.cDescription Is ""> <!---Mshah changed here--->
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
		<cfelse> <!--- ccllchouse is 1 --->
			<!--- Stores the name of the current Tooltip Popup Div Element. --->
			<cfset currentTooltipDivName = "divVariableBudgetPopup" & dsLaborVariableBudgets.CurrentRow>
			<!--- Stores all of the styles required for the standard tooltip Div element. --->
			<cfset currentTooltipDivStyles = "font-size: 8pt; font-family: tahoma; z-index: 140; padding: 2px; background-color: ##d9d9c2;
			 display: none;">
			
			<cfif cLaborTrackingCategory is "Kitchen">
				<cfset variableBudgetTotal = #variableBudgetTotal# + #fVariableBudget#>	
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
						<cfif dsLaborVariableBudgets.cDescription Is ""> <!---Mshah changed here--->
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
			<cfif cLaborTrackingCategory is "Kitchen Training">
				<cfset variableBudgetTotal = #variableBudgetTotal# + #fVariableBudget#> <!---#totalKitchenTrngVarBgt#>	--->
				<!--- Display the Non-Nursing Hours. --->
				<td align="right" bgcolor="#budgetCellColor#" style="padding-right: 5px;">
					<font size="-1"><!---#helperObj.LaborNumberFormat(fVariableBudget, "0.00")#--->
						<cfif dsLaborVariableBudgets.cDescription Is ""> <!---Mshah changed here--->
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
<cfif ccllcHouse is 0>		
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
	</tr>

	<!------------------------- MTD VARIABLE BUDGET VARIANCE - TOTALS ------------------------->
	<!---<cfdump var="#dsTotalLaborTrackingData#">
	<cfset dsVariableBudgetsWithActual = helperObj.FetchLaborVariableBudgetsWithActual(dsLaborVariableBudgets, dsTotalLaborTrackingData)> Mshah Commented here to get the correct sort order--->
		
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
		<!---<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>
		<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
			<font size="-1">
				&##160;
			</font>
		</td>
		Mshah Added to align the column
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
		</td>--->	
		<!---MshahS--->	
		<!--- Stores the variable budget variance total. --->
		<cfset variableBudgetVarianceTotal = 0>
		<!--- loop through labor categories --->
		<cfloop query="dsTotalLaborTrackingData">
		<cfif ccllcHouse is 0>
			<cfif cLaborTrackingCategory is not "WD Salary" and cLaborTrackingCategory is not "Kitchen Training" and cLaborTrackingCategory is not "Resident Care Training">
				<cfif cLaborTrackingCategory is "WD Hourly">
					<!---<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1">
							&##160;
						</font>
					</td>			--->			
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
					<cfelse><font size="-1"> &##160;	</font>
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
				<cfelseif cLaborTrackingCategory is "Resident Care" 
				or cLaborTrackingCategory is "Nurse Consultant" 
				or cLaborTrackingCategory is "LPN - LVN">			
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
					<cfif isCCLLC is 0>
						<cfset variableBudgetVarianceTotal = variableBudgetVarianceTotal + kitchenServicesMtdVariance>			
					</cfif>
					<!--- Display the Kitchen Reg/OT columns. --->
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<cfif isCCLLCHouse is 1 or isCCLLC is 1>-
						<cfelse>
							<font size="-1" color="<cfif kitchenServicesMtdVariance lt 0>Red<cfelse>Black</cfif>">
								<strong>
									#helperObj.LaborNumberFormat(kitchenServicesMtdVariance, "0.00")#
								</strong>
							</font>
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
					<!---Mshah added here to align column--->
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
					<cfif cLaborTrackingCategory is not "PPADJ" and cLaborTrackingCategory is not "Resident Care Training" and cLaborTrackingCategory is not "PTO" >
					<!--- Update the variable budget variance total for the current non-nursing field. --->
					<cfset variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - fAll)>			
					<cfset Factual= (dsTotalLaborTrackingData.fregular+ dsTotalLaborTrackingData.fovertime)>
					<!--- Display the Non-Nursing Hours. --->
					<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
						<font size="-1" color="<cfif (fVariableBudget - Factual) lt 0 or (fVariableBudget - fall) LT 0>Red<cfelse>Black</cfif>">
							<strong>
								<cfif cLaborTrackingCategory is "CRM"> 
								#helperObj.LaborNumberFormat(fVariableBudget - Factual , "0.00")# 
								<cfelse>
								#helperObj.LaborNumberFormat(fVariableBudget - fall , "0.00")#<!---Mshah changed here--->
								</cfif>
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
		<cfelse> <!--- ccllchouse is 1 --->
		<cfif ccllchouse is 1>
			<cfset dsCCLLCSalariedEmpInfo = #helperObj.FetchCCLLCSalariedInfo(houseId)#>
			<cfif dsCCLLCSalariedEmpInfo.recordcount is not 0>	
				<cfset ccllcSalEmp = 1>
			<cfelse>
				<cfset ccllcSalEmp = 0>
			</cfif>

			<cfif cLaborTrackingCategory is "Kitchen">
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
				<cfif ccllcSalEmp is 1>
						<cfset kitchenServicesMtdVariance = fVariableBudget - (totalActual)>
				<cfelse>
					<cfset kitchenServicesMtdVariance = fVariableBudget - (fRegular + fOverTime)>
				</cfif>
				
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
			</cfif>
			<cfif loop is 0>
			<cfif cLaborTrackingCategory is "Kitchen Training">
				<cfset loop = 1>
				<!--- Update the variable budget variance total for the current non-nursing field. --->
				<cfset variableBudgetVarianceTotal = variableBudgetVarianceTotal + <!---(totalKitchenTrngVarBgt - fAll)>---> (fVariableBudget - fAll)>			
				<td align="right" bgcolor="#variableBudgetVarianceCellColor#" style="padding-right: 5px;">
					<font size="-1" color="<cfif (fVariableBudget - fAll) lt 0>Red<cfelse>Black</cfif>">
						<strong>
							#helperObj.LaborNumberFormat(fVariableBudget - fAll, "0.00")#
							<!---#helperObj.LaborNumberFormat(totalKitchenTrngVarBgt - fAll, "0.00")#--->
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
<cfif ccllcHouse is 0>		
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
	</tr>
</cfif>
</tfoot>
</tbody>
</table>
</div>
</cfoutput>
<!---<cfdump var="#dsLaborVariableBudgets#" label="dsLaborVariableBudgets">
<cfdump var="#dsTotalLaborTrackingData#" label="dsTotalLaborTrackingData">
<cfdump var="#dsCurrentLaborTrackingData#" label="dsCurrentLaborTrackingData">--->

<script language="javascript" type="text/javascript">
	if (document.getElementById("tbl-container"))
	{
		document.getElementById("tbl-container").style.display = 'none';
		document.getElementById("tbl-container").style.display = 'block';
	}
</script>
</body>
</html>