<cfset page = "Expense SpendDown">
<cfset Page = "Expense Spend Down">
<cfsetting enablecfoutputonly="yes">
<cfparam name="errorCaught" default="">
<cftry>
<!------------------------------------------------------------------------------------>
<cfheader name="Content-Disposition" value="attachment; filename=SpenddownExportFile.xls">
<cfcontent  type="application/vnd.ms-excel">
<!---<cfcontent type="application/msexcel">--->
<cfoutput>

	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html lang="en">
		<head>		    
			<title>
				Online FTA- #page#
			</title>						
			<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
			<cfif isDefined("url.Division_ID")>
				<cfset divisionId = #url.Division_ID#>
			</cfif>
						
			<cfif isDefined("url.Region_ID")>
				<cfset RegionId = #url.region_ID#>
			</cfif>

			<cfif isDefined("url.rollup")>
				<cfset rollup = #url.rollup#>
			<cfelse> <cfset rollup = 0>
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


<cfoutput>
	<body> 
  <!---<cfset pageName = listFirst(listLast(CGI.HTTP_Referer, 'iHouse_ID'), '=')>   your here -- #CGI.HTTP_REFERER# -  #houseId# 
	<cfset Houseid = #cgi.HTTP_REFERER#> hello - #CGI.iHouse_ID# -/- #CGI.HTTP_REFERER.NumberOfMonths#  -- #pageName#--->
		<cfset dtperiod = #dateformat(DateToUse, 'yyyymm')#>
	<cfif rollup is 0>		
		<cfset dailyCensusBudget = #helperObj.FetchDailyCensusBudget(houseId, currenty, monthforqueries)#>
	</cfif>	
<cfif rollup is not 0>
	<cfif rollup is 3>
		<cfset dsCensusDetails = #helperObj.FetchAverageDailyCensusDetailsRollup(RegionID, FromDate, ThruDate,monthforqueries)#>  
	<cfelseif rollup is 2>
		<cfset dsCensusDetails = #helperObj.FetchAverageDailyCensusDetailsDivisionalRollup(DivisionID, FromDate, ThruDate,monthforqueries,true)#>
	</cfif>
	<cfif rollup is 3>
		<cfset dailyCensusBudget = #helperObj.FetchDailyCensusBudget(dsCensusDetails.ihouse_Id, currenty, monthforqueries)#>
	<cfelseif rollup is 2>
		<cfset dailyCensusBudget = #helperObj.FetchDivisionalCensusBudgetRollup(dsCensusDetails.iOPSArea_Id, currenty, monthforqueries)#>
	</cfif>
</cfif>


<!--- Date and month manipulating according to program level --->
<cfset dtperiod = #dateformat(DateToUse, 'yyyymm')#>
<cfset dtDaysinmonth = #DaysInMonth(DateToUse)# >
<cfset today = now()> 
<cfset firstOfMonth = createDate(year(DateToUse), month(DateToUse), 1)> 
<cfset lastOfMonth = dateAdd("d", -1, dateAdd("m", 1, firstOfMonth))> 
<cfset dtPrePeriod = #dateformat(today, 'yyyymm')#>

<cfset pre2monthsdate = createDate(year(today), month(today), 1)>
<cfset Pre2months = dateAdd("d", -1, dateAdd("m", -1, pre2monthsdate))>
<cfset period2month = #dateformat(Pre2months, 'yyyymm')#>



<cfoutput>
<cfif rollup is not 0>
    <cfif rollup is 2>
		    <cfquery name="dsGetDivisions" datasource="FTA">
				select cName as Division, iRegion_ID as DivisionID from dbo.vw_Region where iRegion_ID = cast('#divisionId#' as Int)
			</cfquery>
			<!---</cfif>	
		<cfif rollup is 3>--->
		    <cfquery name="dsGetRegion" datasource="FTA">
				select iOPSArea_ID from dbo.vw_OpsArea where iRegion_ID = cast('#divisionId#' as Int)
			</cfquery>	
				 <cfset regionIds = #ValueList(dsGetRegion.iOPSArea_ID)#>
			     <cfset dsRegionInfo = #helperObj.FetchRegionInfo(RegionID)#>  <!--- --->
	</cfif>
	  
	<cfquery name="RegionName" datasource="FTA">
	 SELECT cname from dbo.vw_OpsArea
	   WHERE  iOPSArea_ID <cfif rollup is 2> in(#regionIds#) <cfelse> = #RegionId# </cfif>
	</cfquery>
	
	<cfquery name="RegionHouse" datasource="FTA">
	 SELECT * from dbo.vw_House 
	   WHERE  iOPSArea_ID <cfif rollup is 2> in(#regionIds#) <cfelse> = #RegionId# </cfif>
	</cfquery>
	<cfset houselist = #ValueList(RegionHouse.ihouse_id)#>

	<cfquery name="SpendDownInforoll" datasource="FTA">
	<!--- SELECT Acct, cDescription, cperiod,cCategorytype,SUM(cAmount) as cAmount
	   FROM SpendDownCategoryDetails 
	   WHERE  cperiod = '#dtperiod#' AND iHouseId in (#houselist#) AND dtRowDeleted is null
	    GROUP BY acct,cDescription, cperiod,cCategorytype--->
		SELECT acct,cdescription,cperiod,ccategorytype,sum(camountnew) as CAMOUNT,sum(cPRD) as cPRD
		  FROM (	SELECT sdcd.Acct, sdcd.cDescription, sdcd.cperiod,sdcd.cCategorytype,sdcd.cAmount as cAmount,
					case when cPRM is null 
					then camount
					else CPRM
					end as CAmountNew,
					sda.cPRM,sda.cPRD
			   		FROM SpendDownCategoryDetails sdcd
			 	 left Join dbo.SpenddownAdj sda on sdcd.Acct = sda.cacctid AND sdcd.iHouseId = sda.iHouseId <!---AND sdcd.cperiod = sda.cperiod---> 
				 AND sda.dtRowDeleted is null
		WHERE  sdcd.cperiod = '#dtperiod#' AND sdcd.iHouseId in (#houselist#) AND sdcd.dtRowDeleted is null) A
				GROUP BY A.acct,A.cDescription, A.cperiod,A.cCategorytype,cPRD
	</cfquery>
	<cfoutput>
	<cfset columnCount = #SpendDownInforoll.recordcount#>
	<cfset totalColCount = #columncount# + 5>  
	</cfoutput>
<cfelse>
	<cfquery name="SpendDownInfo" datasource="FTA">
	<!--- Select * from SpendDownCategoryDetails 
	  where  iHouseId= #iHouse_ID# and cperiod = '#dtperiod#' and dtRowDeleted is null--->
	  SELECT spcd.*,spa.cprd as cPRD,spa.cprm as cPRM FROM SpendDownCategoryDetails spcd
         left join spenddownadj SPA   ON SPA.cacctid = spcd.acct and spa.ihouseid = spcd.ihouseid AND '#dtperiod#' between spa.cperiod and spa.endperiod
		    AND  spcd.cperiod <> spa.endperiod
	        WHERE spcd.iHouseId= #iHouse_ID# AND spcd.cperiod = '#dtperiod#' AND spcd.dtRowDeleted is null AND SPA.dtRowDeleted is null
	</cfquery>
	
	<cfoutput>
	<cfset columnCount = #SpendDownInfo.recordcount#>
	<cfset totalColCount = #columncount# + 5>
	</cfoutput>
</cfif>
</cfoutput>

<cfif rollup is not 0>
<cfoutput> 
	<cfif rollup is 2>
	<cfquery name="dsGetDivisions" datasource="FTA">
			select cName as Division, iRegion_ID as DivisionID from dbo.vw_Region where iRegion_ID = cast('#DivisionId#' as Int)
		</cfquery>		
	</cfif>
	
         <cfquery name="SpendDownInfo" datasource="FTA">
			<!---Select * from SpendDownCategoryDetails 
		    where  iHouseId in (#houselist#) and cperiod = '#dtperiod#' and dtRowDeleted is null	---> 
		 SELECT spcd.*,spa.cprd as cPRD,spa.cprm as cPRM FROM SpendDownCategoryDetails spcd
         left join spenddownadj SPA   ON SPA.cacctid = spcd.acct and spa.ihouseid = spcd.ihouseid AND '#dtperiod#' between spa.cperiod and spa.endperiod
		    AND  spcd.cperiod <> spa.endperiod
	        WHERE spcd.iHouseId in (#houselist#) AND spcd.cperiod = '#dtperiod#' AND spcd.dtRowDeleted is null AND SPA.dtRowDeleted is null
		 </cfquery>
			
			<!--- Census records values calculation query --->
			<cfquery name="SP_CensusDay" datasource="FTA">
				 SELECT (DateDiff(Day, '#dateformat(firstOfMonth, 'yyyy-mm-dd')#', dtOccupancy) + 1) AS iDay,  SUM(ftenants) as fTenants,ctype  
				   FROM HouseTenantCensus 
				  WHERE  ihouseid in(#houselist#) and ctype='P' 
				   AND dtOccupancy Between '#dateformat(firstOfMonth, 'yyyy-mm-dd')#' AND '#dateformat(lastOfMonth, 'yyyy-mm-dd')#'
				   <cfif dtPrePeriod eq dtperiod>
				   AND dtOccupancy = '#dateformat(today-1, 'yyyy-mm-dd')#'
				   <cfelse> AND dtOccupancy = '#dateformat(lastOfMonth, 'yyyy-mm-dd')#'
				   </cfif>
				   GROUP BY dtOccupancy, ctype
			</cfquery>
			<cfquery name="SP_censusSum" datasource="FTA">
				 SELECT SUM(fTenants) as fTenants 
				  FROM HouseTenantCensus 
				  WHERE  ihouseid in(#houselist#) and ctype='P' 
					AND dtOccupancy Between '#dateformat(firstOfMonth, 'yyyy-mm-dd')#' AND '#dateformat(lastOfMonth, 'yyyy-mm-dd')#'
				   <!---group by fTenants--->
			</cfquery>
		
				
		<!--- Projected Resident Days in Month calculation --->
		<cfset daynum = #numberformat(SP_CensusDay.iDay, 0)#>
		<cfset fTenantsval = #numberformat(SP_CensusDay.fTenants, 0.0)#>
		
		<cfset monthleft = "#dtDaysinmonth#"-#daynum#>
		<cfset summonth = #monthleft# * #fTenantsval#>
		<cfset monthcensus = #numberformat(SP_censusSum.fTenants, 0.00)# + #summonth#>
			
		<table>&##160;</table>
		
		<table id="tblInfo" width="300px" height="50px"  cellspacing="0" cellpadding="1" border="1px">
			<tr bgcolor="##E6E6E6">
				<td align="right" colspan=1 ><font size=-1>Census:</font></td>
				<td align="Middle" colspan="1">	<font size=-1> #numberformat(SP_CensusDay.fTenants, 0)# </font></td>
			</tr>
			<tr bgcolor="##E6E6E6">
				<td align="right" colspan=1><font size=-1>Calendar Days in Month:</font></td>
				<td align="Middle" colspan="1" ><font size=-1>&nbsp;	#dtDaysinmonth#	&nbsp;</font></td>
			</tr>
			<tr bgcolor="##E6E6E6">
				<td align="right" colspan=1 ><font size=-1>Projected Resident Days in Month:</font>	</td>
				<td align="Middle" colspan="1">	<font size=-1>#monthcensus# </font></td>
			</tr>	
		</table> 		
	</cfoutput>
<cfelse>
            <cfquery name="SpendDownInfo" datasource="FTA">
			<!---Select * from SpendDownCategoryDetails 
		    where  iHouseId= #iHouse_ID# and cperiod = '#dtperiod#' and dtRowDeleted is null--->	
			SELECT spcd.*,spa.cprd as cPRD,spa.cprm as cPRM FROM SpendDownCategoryDetails spcd
         left join spenddownadj SPA   ON SPA.cacctid = spcd.acct and spa.ihouseid = spcd.ihouseid AND '#dtperiod#' between spa.cperiod and spa.endperiod
		    AND  spcd.cperiod <> spa.endperiod
	        WHERE spcd.iHouseId= #iHouse_ID# AND spcd.cperiod = '#dtperiod#' AND spcd.dtRowDeleted is null AND SPA.dtRowDeleted is null 
			</cfquery>
			
			<!--- Census records values calculation query --->
			<cfquery name="SP_CensusDay" datasource="FTA">
				 SELECT (DateDiff(Day, '#dateformat(firstOfMonth, 'yyyy-mm-dd')#', dtOccupancy) + 1) AS iDay, *  
				   FROM HouseTenantCensus 
				  WHERE  ihouseid = #iHouse_ID# and ctype='P' 
				   AND dtOccupancy Between '#dateformat(firstOfMonth, 'yyyy-mm-dd')#' AND '#dateformat(lastOfMonth, 'yyyy-mm-dd')#'
				   <cfif dtPrePeriod eq dtperiod>
				   AND dtOccupancy = '#dateformat(today-1, 'yyyy-mm-dd')#'
				   <cfelse> AND dtOccupancy = '#dateformat(lastOfMonth, 'yyyy-mm-dd')#'
				   </cfif>
			</cfquery>
			<cfquery name="SP_censusSum" datasource="FTA">
				 SELECT SUM(fTenants) as fTenants 
				  FROM HouseTenantCensus 
				  WHERE  ihouseid = #iHouse_ID# and ctype='P' 
					AND dtOccupancy Between '#dateformat(firstOfMonth, 'yyyy-mm-dd')#' AND '#dateformat(lastOfMonth, 'yyyy-mm-dd')#'
				   <!---group by fTenants--->
			</cfquery>
		
	<cfoutput>			
		<!--- Projected Resident Days in Month calculation --->
		<cfset daynum = #numberformat(SP_CensusDay.iDay, 0)#>
		<cfset fTenantsval = #numberformat(SP_CensusDay.fTenants, 0.0)#>
		
		<cfset monthleft = "#dtDaysinmonth#"-#daynum#>
		<cfset summonth = #monthleft# * #fTenantsval#>
		<cfset monthcensus = #numberformat(SP_censusSum.fTenants, 0.00)# + #summonth#>
			
		<table>&##160;</table>
		
		<table id="tblInfo" width="250px" height="50px"  cellspacing="0" cellpadding="1" border="1px">
			<tr bgcolor="##E6E6E6">
				<td align="right" colspan=1 ><font size=-1>Census:</font></td>
				<td align="Middle" colspan="1">	<font size=-1> &nbsp; #numberformat(SP_CensusDay.fTenants, 0)# &nbsp;</font></td>
			</tr>
			<tr bgcolor="##E6E6E6">
				<td align="right" colspan=1><font size=-1>Calendar Days in Month:</font></td>
				<td align="Middle" colspan="1" ><font size=-1>&nbsp;	#dtDaysinmonth#	&nbsp;</font></td>
			</tr>
			<tr bgcolor="##E6E6E6">
				<td align="right" colspan=1 ><font size=-1>Projected Resident Days in Month:</font>	</td>
				<td align="Middle" colspan="1">	<font size=-1>&nbsp;#monthcensus# &nbsp;</font></td>
			</tr>	
		</table> 		
		</cfoutput>
</cfif>
<table>&nbsp;</table>
  <cfif rollup is 0>
     <cfquery name="HouseName" datasource="FTA">				
			SELECT cname FROM dbo.vw_House
	        WHERE iHouse_Id= #iHouse_ID# 
			</cfquery> 
	</cfif>
<!---<cfinvoke component="components.Spenddown"	method="retrievespend"	returnvariable="allspend"></cfinvoke>--->
<font face="Times New Roman, Times, serif"><b>Expense Spend Down Details:&nbsp;
<font color="##7F1FFF"><cfif rollup is not 0><cfif rollup is 2>#UCase(dsGetDivisions.division)# DIvision Level <cfelse> #UCase(RegionName.cname)# Region Level</cfif><cfelse> #UCase(HouseName.cname)# Level </cfif></font>Report </b></font>
	<table id="tbl" cellspacing="0" cellpadding="1" border="1px">		
				<tr bgcolor="##3333CC">
					  <td ><font size=-1 color="White">Account</font></td> 
					  <td ><font size=-1 color="White">Description</font></td>
					  <td ><font size=-1 color="White">PRD</font></td>
					  <td ><font size=-1 color="White">$$/Month</font></td>
					  <td ><font size=-1 color="White">Budget</font></td>
					  <td ><font size=-1 color="White">Actual</font></td>
					  <td ><font size=-1 color="White">Balance</font></td>					  
				</tr>
				
				<!--- Initialize the values for calculation --->
				<cfset PRDsumall = 0>
				<cfset PRMsumall = 0>
				<cfset BudgetsumPRD = 0>
				<cfset BudgetsumPRM = 0>
				<cfset Actualsum = 0>
				<cfset BalsumPRD = 0>
				<cfset BalsumPRM = 0>
				
<cfif rollup is not 0>
         <cfoutput>
         <cfloop query="SpendDownInforoll">
								
				<cfquery name="drilldown" datasource="FTA">
					SELECT   * From dbo.Spenddown 
					WHERE cperiod = '#dtperiod#' AND iHouseId in (#houselist#) AND cAccountnum = #SpendDownInforoll.Acct# AND dtrowdeleted is null					  				   
				</cfquery>
				<cfif drilldown.Recordcount gt 0>
					<cfquery name="DrillAmount" datasource="FTA">
						SELECT  SUM(cAmount) as cAmount From dbo.Spenddown 
						WHERE iHouseId in (#houselist#) AND cperiod = '#dtperiod#' AND cAccountnum = #SpendDownInforoll.Acct# AND dtrowdeleted is null						 				   
					</cfquery>
				</cfif>
				 <TR id="Parent#SpendDownInforoll.currentrow#" onClick="toggle('Child#SpendDownInforoll.currentrow#')">
						<!---<input type="hidden" name="iSpenddownAcctId" value="#iSpenddownAcctId#">--->						
						
						<td align="right">
							<div align="right">
								<cfif drilldown.Recordcount Is Not "0">
									<cfset imageId = "imgDrillDown_" & #Acct#>									
								</cfif>
									#Acct#
							</div>
						</td>										
						<td>
							<div>
							&nbsp;&nbsp;#cDescription#
							</div>
						</td>						
						<td>
							<div>
								<cfif cCategoryType eq 'PRD'>  
								 <cfset amounttot = #cAmount#/(#helperObj.GetNumberFormat(dailyCensusBudget, false)# * #dtDaysinmonth#)> <!--- #helperObj.GetNumberFormat(dailyCensusBudget, false)#--->
									<cfif cPRD eq '' OR cPRD eq 'null'>
									$  &nbsp;&nbsp; #NumberFormat(Amounttot, 0.00)#
									<cfelse> <cfset Amounttot = #cPRD#>
									$  &nbsp;&nbsp; #NumberFormat(Amounttot, 0.00)#
									</cfif>
									<!---$  &nbsp;&nbsp; #NumberFormat(Amounttot, 0.00)#--->
									<cfset PRDsumall = PRDsumall +(#NumberFormat(Amounttot, 0.00)#)>
								<cfelse>
									$ 
								</cfif>
							</div>
						</td> 
						<td>
							<div>	
								<cfif cCategoryType eq 'PRM'>
									$  &nbsp;&nbsp;#NumberFormat(cAmount, 0.00)#
								    <cfset PRMsumall = PRMsumall + (#NumberFormat(cAmount, 0.00)#)> 
								<cfelse>
									$ 
								</cfif>
							</div>
						</td>				   							
						<td>
							<div>
							<cfif cCategoryType eq 'PRD'>
							 <!--- <cfset prdtotal = #NumberFormat(Amounttot, 0.00)# * #monthcensus# >--->							  
							    $&nbsp;&nbsp;#NumberFormat(cAmount, 0.00)#	
								<cfset BudgetsumPRD = BudgetsumPRD + (#NumberFormat(cAmount, 0.00)#)>															
							<cfelse>
								$&nbsp;&nbsp;#NumberFormat(cAmount, 0.00)#
								<cfset BudgetsumPRM = BudgetsumPRM + (#NumberFormat(cAmount, 0.00)#)>								
							</cfif>
							</div>
						</td>
						<td>
							<div> 
							<cfif drilldown.Recordcount gt 0>
							   <cfset Subamount = #NumberFormat(DrillAmount.cAmount, 0.00)#>
							   <cfif Subamount gt 0>
								$&nbsp;&nbsp;#Subamount#
								<cfset Actualsum = Actualsum + (#NumberFormat(Subamount, 0.00)#)>
								<cfelse> $
								</cfif>
							<cfelse>
							<cfset Subamount = #NumberFormat(drilldown.cAmount, 0.00)#>
							   <cfif Subamount gt 0>
								$&nbsp;&nbsp;#Subamount#
								<cfset Actualsum = Actualsum + (#NumberFormat(Subamount, 0.00)#)>
								<cfelse> $
								</cfif>
							</cfif>
							</div>
						</td>
						<td>
							<div>
							<cfif cCategoryType eq 'PRD'>
							   <cfset balanceprd = #NumberFormat((cAmount - Subamount), 0.00)#>
								<font color="<cfif balanceprd lt 0>red<cfelse>Black</cfif>">$&nbsp;&nbsp;<b>#balanceprd#</b></font>
								<cfset BalsumPRD = BalsumPRD + (#NumberFormat(balanceprd, 0.00)#)>
							<cfelse>
							<cfset balanceprm = #NumberFormat((cAmount - Subamount), 0.00)#>
							    <font color="<cfif balanceprm lt 0>red<cfelse>Black</cfif>">$&nbsp;&nbsp;<b>#balanceprm#</b></font>
								<cfset BalsumPRM = BalsumPRM + (#NumberFormat(balanceprm, 0.00)#)>
							</cfif>
							</div>
						</td>
												
					</tr>
				  
				   <!--- START dropdown here--->
				   <cfset drillDownColSpan = 6 - 1>
					<!--- Current Account Drilldown information --->
					<cfif drilldown.RecordCount IS NOT "0">
						<cfset rowId = "DrillDown_" & #Acct#>
						<cfset columnA = "##FFE7CE">
						<cfset columnB = "##FFFFE8">
		
						<tr id="#rowId#" style="display:true;">
							<td class="locked" colspan="1" bgcolor="f4f4f4">
								&##160;
							</td>
							<td align="left" colspan="#drillDownColSpan#">							
													
								<cfform name="drill" method="post">
								<table cellpaddding="50px" cellspacing="0" style="border-style: solid; border-width: 1px; border-color: Black">
									<tr style="text-decoration: underline; font-weight: bold;">
										<td align="Middle" bgcolor="#columnA#" class="bottomBorder" >
											<font size=-1>
												Acct 
											</font>
										</td>
										<td align="Middle" bgcolor="#columnB#" class="bottomBorder" width="300">
											<font size=-1>
												Notes 
											</font>
										</td>
										<td align="Middle" bgcolor="#columnA#" class="bottomBorder" width="200">
											<font size=-1>
												Date 
											</font>
										</td>			
										<td align="Middle" bgcolor="#columnB#" class="bottomBorder" width="200">
											<font size=-1>
												Amount  
											</font>
										</td>																				
									</tr>
																		
									<cfloop query="drilldown">	
									<cfquery name="DrillHouse" datasource="FTA">
											SELECT cname From dbo.vw_House
											WHERE iHouse_Id = #drilldown.iHouseid# AND dtrowdeleted is null												 				   
										</cfquery>
										<tr> <cfinput type="hidden" name="iSpenddownId" value="#drilldown.iSpenddownId#">
											<td align="Middle" bgcolor="#columnA#">
												<font size=-1>
												&nbsp;&nbsp;#drilldown.caccountnum# &nbsp;&nbsp;
												</font>												
											</td>											
											<td align="Middle" bgcolor="#columnB#">
												<font style="color: blue" size=-1>
													#drilldown.cnotes#		
												</font>													
											</td>
											<td align="Middle" bgcolor="#columnA#">
												<font size=-1>
													#dateformat(drilldown.dtTransactionDate, 'yyyy-mm-dd')# 
												</font>
											</td>			
											<td align="Middle" bgcolor="#columnB#">
												<font size=-1>
													$ &nbsp;#Numberformat(drilldown.cAmount, 0.00)# 
												</font>
											</td>
											<td align="Middle" bgcolor="#columnB#">
												<font size=-1>
													 &nbsp;#DrillHouse.cname# 
												</font>
											</td>
										</tr>											
									</cfloop> 										                  									
								</table>
								</cfform>								
							</td>
						</tr>	
					</cfif>
					<!--- END Dropdown--->
				 </cfloop>
				</cfoutput>
				
			
<cfelse>
				<!--- STRAT result set table for display --->
				<cfoutput>
				<cfloop query="SpendDownInfo">
				
				<cfquery name="drilldown" datasource="FTA">
					SELECT   * From dbo.Spenddown 
					WHERE iHouseId= #iHouse_ID# AND cperiod = '#dtperiod#' AND cAccountnum = #SpendDownInfo.Acct# AND dtrowdeleted is null					  				   
				</cfquery>
				<cfif drilldown.Recordcount gt 0>
					<cfquery name="DrillAmount" datasource="FTA">
						SELECT  SUM(cAmount) as cAmount From dbo.Spenddown 
						WHERE iHouseId= #iHouse_ID# AND cperiod = '#dtperiod#' AND cAccountnum = #SpendDownInfo.Acct# AND dtrowdeleted is null											   
					</cfquery>
				</cfif>	
				<!---<input type="hidden" name="recordid" value="#SpendDownInfo.recordcount#">--->
					 <!---<TR BGCOLOR="###IIF(SpendDownInfo.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#" id="Parent#SpendDownInfo.currentrow#" onClick="toggle('Child#SpendDownInfo.currentrow#')">--->								
						<tr id="Parent#SpendDownInfo.currentrow#" onClick="toggle('Child#SpendDownInfo.currentrow#')">
						<td align="right">
							<div align="right">
								<cfif drilldown.Recordcount Is Not "0">
									<cfset imageId = "imgDrillDown_" & #Acct#>									
								</cfif>
									#Acct#
							</div>
						</td>						
						<td>
							<div>
							&nbsp;&nbsp;#cDescription#
							</div>
						</td>						
						<td>
							<div>
								<cfif cCategoryType eq 'PRD'> 								 
								 <cfset amounttot = #cAmount#/(#helperObj.GetNumberFormat(dailyCensusBudget, false)# * #dtDaysinmonth#)>
									<cfif cPRD eq '' OR cPRD eq 'null'>
									$  &nbsp;&nbsp; #NumberFormat(Amounttot, 0.00)#
									<cfelse> <cfset Amounttot = #cPRD#>
									$  &nbsp;&nbsp; #NumberFormat(Amounttot, 0.00)#
									</cfif>
									<cfset PRDsumall = PRDsumall +(#NumberFormat(Amounttot, 0.00)#)>
								<cfelse>
									$ 
								</cfif>
							</div>
						</td> 
						<td>
							<div>	
								<cfif cCategoryType eq 'PRM'>
								  <cfif cPRM eq '' OR cPRM eq 'null'>
									$  &nbsp;&nbsp;#NumberFormat(cAmount, 0.00)#
								  <cfelse> <cfset cAmountPRM = #cPRM#>
								  $  &nbsp;&nbsp;#cAmountPRM#<!--- <cfset cAmount = #cAmountPRM#>--->
								  </cfif>
								    <cfset PRMsumall = PRMsumall + (#NumberFormat(cAmount, 0.00)#)> 
								<cfelse>
									$ 
								</cfif>
							</div>
						</td>				   							
						<td>
							<div>
							<cfif cCategoryType eq 'PRD'>
							  <cfset prdtotal = #NumberFormat(Amounttot, 0.00)# * #monthcensus# >							  
							    $&nbsp;&nbsp;#NumberFormat(prdtotal, 0.00)#	
								<cfset BudgetsumPRD = BudgetsumPRD + (#NumberFormat(cAmount, 0.00)#)>															
							<cfelse>
							   <cfif cPRM eq '' OR cPRM eq 'null'>
								$&nbsp;&nbsp;#NumberFormat(cAmount, 0.00)#
							   <cfelse> <cfset cAmountPRM = #cPRM#>
								  $  &nbsp;&nbsp;#cAmountPRM# <!---<cfset cAmount = #cAmountPRM#>--->
							   </cfif>	
								<cfset BudgetsumPRM = BudgetsumPRM + (#NumberFormat(cAmount, 0.00)#)>								
							</cfif>
							</div>
						</td>
						<td>
							<div> 
							<cfif drilldown.Recordcount gt 0>
							   <cfset Subamount = #NumberFormat(DrillAmount.cAmount, 0.00)#>
							   <cfif Subamount gt 0>
								$&nbsp;&nbsp;#Subamount#
								<cfset Actualsum = Actualsum + (#NumberFormat(Subamount, 0.00)#)>
								<cfelse> $
								</cfif>
							<cfelse>
							<cfset Subamount = #NumberFormat(drilldown.cAmount, 0.00)#>
							   <cfif Subamount gt 0>
								$&nbsp;&nbsp;#Subamount#
								<cfset Actualsum = Actualsum + (#NumberFormat(Subamount, 0.00)#)>
								<cfelse> $
								</cfif>
							</cfif>
							</div>
						</td>
						<td>
							<div>
							<cfif cCategoryType eq 'PRD'>
							   <cfset balanceprd = #NumberFormat((prdtotal - Subamount), 0.00)#>
								<font color="<cfif balanceprd lt 0>red<cfelse>Black</cfif>">$&nbsp;&nbsp;<b>#balanceprd#</b></font>
								<cfset BalsumPRD = BalsumPRD + (#NumberFormat(balanceprd, 0.00)#)>
							<cfelse>
							  <cfif cPRM eq '' OR cPRM eq 'null'>
							<cfset balanceprm = #NumberFormat((cAmount - Subamount), 0.00)#>
							  <cfelse>
							  <cfset balanceprm = #NumberFormat((cAmountPRM - Subamount), 0.00)#>
							  </cfif>
							    <font color="<cfif balanceprm lt 0>red<cfelse>Black</cfif>">$&nbsp;&nbsp;<b>#balanceprm#</b></font>
								<cfset BalsumPRM = BalsumPRM + (#NumberFormat(balanceprm, 0.00)#)>
							</cfif>
							
							</div>
						</td>											
					</tr>
					
				   <cfset drillDownColSpan = 6 - 1>					
				   <cfif drilldown.RecordCount IS NOT "0">
						<cfset rowId = "DrillDown_" & #Acct#>
						<cfset columnA = "##FFE7CE">
						<cfset columnB = "##FFFFE8">
		
						<tr id="#rowId#" style="display:true;">
							<td class="locked" colspan="1" bgcolor="f4f4f4">
								&##160;
							</td>
							<td align="left" colspan="#drillDownColSpan#">
												
								<cfform name="drill" method="post">
								<table border="1px">
									<tr style="text-decoration: underline; font-weight: bold;">
										<td align="Middle" bgcolor="#columnA#" class="bottomBorder" >
											<font size=-1>
												Acct 
											</font>
										</td>
										<td colspan="2" align="Middle" bgcolor="#columnB#" class="bottomBorder" width="300">
											<font size=-1>
												Notes 
											</font>
										</td>
										<td align="Middle" bgcolor="#columnA#" class="bottomBorder" width="200">
											<font size=-1>
												Date 
											</font>
										</td>			
										<td align="Middle" bgcolor="#columnB#" class="bottomBorder" width="200">
											<font size=-1>
												Amount  
											</font>
										</td>																				
									</tr>
																		
									<cfloop query="drilldown">	
										<tr> 
											<td align="Middle" bgcolor="#columnA#">
												<font size=-1>
												&nbsp;&nbsp;#drilldown.caccountnum# &nbsp;&nbsp;
												</font>												
											</td>											
											<td colspan="2" align="Middle" bgcolor="#columnB#">
												<font style="color: blue" size=-1>
													#drilldown.cnotes#		
												</font>													
											</td>
											<td align="Middle" bgcolor="#columnA#">
												<font size=-1>
													#dateformat(drilldown.dtTransactionDate, 'yyyy-mm-dd')# 
												</font>
											</td>			
											<td align="Middle" bgcolor="#columnB#">
												<font size=-1>
													$ &nbsp;#Numberformat(drilldown.cAmount, 0.00)# 
												</font>
											</td>	
										</tr>											
									</cfloop> 									                  									
								</table>
								</cfform>								
							</td>
						</tr>					
					</cfif>					
				  		</cfloop>		  
				</cfoutput>
</cfif>				
				<tr><td>&nbsp;</td></tr>
				<tr><td colspan="7" align="center"></td>
			 </tr>
			 <cfoutput>
			    <!---<cfset Bugsumall = (#BudgetsumPRM# + #BudgetsumPRD#)>--->
			    <cfset Balsumall = (#BalsumPRD# + #BalsumPRM#)>
				<cfset Budsum = (#Balsumall# + #Actualsum#)>
			 <tr>			    
			  <td><font size=-1>&##160;</font></td>
			  <td align="right" bgcolor="##FFE7CE"><b style="color:##0000FF">Total :&nbsp;&nbsp;</b></td>
			  <td bgcolor="##FFE7CE"><b style="color:##0000FF"> <!---#PRDsumall#---></b></td>
			  <td bgcolor="##FFE7CE"><b style="color:##0000FF"> <!---#PRMsumall#---></b></td>
			  <td bgcolor="##FFE7CE"><b style="color:##0000FF">$  &nbsp;&nbsp; #Budsum#</b></td>
			  <td bgcolor="##FFE7CE"><b style="color:##0000FF">$  &nbsp;&nbsp; #Actualsum#</b></td>
			  <td bgcolor="##FFE7CE"><b style="color:##0000FF">$  &nbsp;&nbsp; #Balsumall#</b></td>
			 </tr>
			 </cfoutput>
			
		</table> <!---<input type="submit" value="Submit">--->
 </cfoutput>
<cfcatch type="Any">
        <cfoutput>
            <hr>
            <h1>Other Error: #cfcatch.Type#</h1>
            <ul>
                <li><b>Message:</b> #cfcatch.Message#
                <li><b>Detail:</b> #cfcatch.Detail#
            </ul>
        </cfoutput>
        <cfset errorCaught = "General Exception">
    </cfcatch>
 </body>

</html>
</cftry>
