<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| Display FTA summary info.  It is the FTA Dashboard screen.								   |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| bkubly     | 02/23/2009 | Created                                             			   |
| Gthota     | 03/10/2014 | code updated for roll-up                                           |  
----------------------------------------------------------------------------------------------->

<cfset Page = "Dashboard">
<cfparam name="houseId" default="50">
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
			<link rel="Stylesheet" href="CSS/Dashboard.css" type="text/css">

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

			 	function doSel(obj)
			 	{	for (i = 1; i < obj.length; i++)
			   	    	if (obj[i].selected == true)
			           		eval(obj[i].value);
			 	}
			</SCRIPT>
		</head>
</cfoutput>


<!--- Initialize the Color fields. --->
<cfset headerCellColor = "##0066CC">
<cfset budgetcellcolor = "##ffff99">
<cfset actualCellColor = "79bcff">
<cfset varianceCellColor = "b0ffff">
<cfset secondaryCellColor = "f4f4f4">
<cfset dashboardTotalCellColor = "##9CCDCD">
<!--- Display the toolbar and month selection. --->
<cfoutput>
	<body>
		<cfinclude template="DisplayFiles/Header.cfm">

		<cfif rollup is 0><cfif subAccount eq 0><cfexit></cfif></cfif>
		<!--- Initialize all of the required fields. --->
		<cfif rollup is 3>
			<cfset dsDashboardHouseInfo = #helperObj.FetchDashboardRollupInfo(RegionId, rollup)#>
		<cfelseif rollup is 2>
			<cfset dsDashboardHouseInfo = #helperObj.FetchDashboardRollupInfo(DivisionId, rollup)#>
		<cfelseif rollup is 0>
			<cfset dsDashboardHouseInfo = #helperObj.FetchDashboardHouseInfo(houseId)#>
		</cfif>
		
		<cfif rollup is 3>
			<cfset dsDashboardHouseOccupancy = #helperObj.FetchDashboardRollupOccupancy(RegionId, PtoPFormat, rollup)#>
		<cfelseif rollup is 2>
			<cfset dsDashboardHouseOccupancy = #helperObj.FetchDashboardRollupOccupancy(DivisionId, PtoPFormat, rollup)#>
		<cfelseif rollup is 1>
			<cfset dsDashboardHouseOccupancy = #helperObj.FetchDashboardConsolidatedOccupancy(PtoPFormat)#>
		<cfelseif rollup is 0>
			<cfset dsDashboardHouseOccupancy = #helperObj.FetchDashboardHouseOccupancy(houseId, PtoPFormat)#>
		</cfif>
		
		<cfif rollup is 3>
			<cfset ds12MonthTrend = #helperObj.Fetch12MonthPrivateCensusTrend(RegionId, thruDate, rollup)#>
		<cfelseif rollup is 2>
			<cfset ds12MonthTrend = #helperObj.Fetch12MonthPrivateCensusTrend(DivisionId, thruDate, rollup)#>
		<cfelseif rollup is 1>
			<cfset ds12MonthTrend = #helperObj.Fetch12MonthPrivateCensusTrend(12, thruDate, rollup)#>
		<cfelse> <!---rollup is 0--->
			<cfset ds12MonthTrend = #helperObj.Fetch12MonthPrivateCensusTrend(houseId, thruDate, rollup)#>
		</cfif>
	
		<table id="tblDashboardTop" width="1000px"> 
			<tr>
				<td width="600px" valign="top">
					<table id="tblHouseInfo" width="525px" height="240px"  cellspacing="0" cellpadding="1" border="1px">
						<tr>
							<td align="middle" style="font-weight: bold" height="20px" colspan=4 bgcolor="#headerCellColor#">
								<font size=-1 color="White">
								<cfif rollup is 0>
									<cfif ccllcHouse is 0> #dsHouseInfo.cName# #datetouse# <cfelse>	CCLLC - #dsHouseInfo.cName# #datetouse#	</cfif>
								<cfelse> 
									<cfif rollup is 1>
										ALC Consolidated #datetouse#
									<cfelseif rollup is 2>
										<cfset dsDivisionInfo = #helperObj.FetchDivisionInfo(DivisionId)#>
										#dsDivisionInfo.Division# Division #datetouse#
									<cfelseif rollup is 3>
										<cfset dsRegionInfo = #helperObj.FetchRegionInfo(RegionId)#>
										#dsRegionInfo.Region# Region #datetouse#
									</cfif> 
								</cfif>
								</font>
							</td>
						</tr>
						<tr>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>					
									Units Available:
								</font>	
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>
									#helperObj.GetNumberFormat(dsDashboardHouseOccupancy.fUnitsAvailable, false)#
								</font>
							</td>
							<cfif rollup is not 1>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									<cfif rollup is 3 or rollup is 0>Division:<cfelseif rollup is 2>DVP:</cfif>
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>
									<cfif rollup is 3 or rollup is 0>#dsDashboardHouseInfo.cDivisionName#
									<cfelseif rollup is 2>
										<cfif #dsDashboardHouseInfo.DVPFullName# is ""> - <cfelse> #dsDashboardHouseInfo.DVPFullName# </cfif>
									<cfelse>-
									</cfif>
								</font>
							</td>
							</cfif>
						</tr>
						<tr>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									MTD Actual Occupied Units:
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>
									#helperObj.GetNumberFormat(dsDashboardHouseOccupancy.fOccupiedUnits, false)#
								</font>
							</td>
							<cfif rollup is not 1>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									<cfif rollup is 3 or rollup is 0>Region:<cfelseif rollup is 2>Phone Number:</cfif>
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>
									<cfif rollup is 3 or rollup is 0>#dsDashboardHouseInfo.cRegionName#
									<cfelseif rollup is 2>
										<cfset dsDashboardContactInfo = #helperObj.FetchRollupContactInfo(#dsDashboardHouseInfo.DVPFullName#)#>
										<cfif dsDashboardContactInfo.recordcount is not 0>
											<cfif #dsDashboardContactInfo.PhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardContactInfo.PhoneNumber#</cfif>
										<cfelse>
											<cfif #dsDashboardHouseInfo.DVPPhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardHouseInfo.DVPPhoneNumber#</cfif>
										</cfif>
									<cfelse> -
									</cfif>
								</font>
							</td>
							</cfif>
						</tr>
						<tr>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									Budgeted Occupied Units:
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>
									#helperObj.GetNumberFormat(dsDashboardHouseOccupancy.fOccupiedUnitsBudget, false)#
								</font>
							</td>
							<cfif rollup is not 1>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									<cfif rollup is 3>RDO:<cfelseif rollup is 2>DDHR:<cfelse>State:</cfif>
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>
									<cfif rollup is 3> <cfset row3 = #dsDashboardHouseInfo.RDOFullName#	>
									<cfelseif rollup is 2><cfset row3 = #dsDashboardHouseInfo.DDHRFullName# >
									<cfelse><cfset row3 = #dsDashboardHouseInfo.cStateCode#></cfif>
									<cfif row3 is ""> - <cfelse> #row3# </cfif>
								</font>
							</td>
							</cfif>
						</tr>
						<tr>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									Occupied Unit Variance:
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
<!--- 								<cfif IsNumeric("dsDashboardHouseOccupancy.fOccupiedUnits") is "yes" and IsNumeric("dsDashboardHouseOccupancy.fOccupiedUnitsBudget") is "yes"> corrected IsNumeric 09-21-11 S Farmer tkt 78047 --->
								<cfif IsNumeric(dsDashboardHouseOccupancy.fOccupiedUnits) and IsNumeric(dsDashboardHouseOccupancy.fOccupiedUnitsBudget)>
								<font size=-1 color=
									<cfif (dsDashboardHouseOccupancy.fOccupiedUnits - dsDashboardHouseOccupancy.fOccupiedUnitsBudget) lt 0>"Red"<cfelse>"Black"</cfif>>
										#helperObj.GetNumberFormat(dsDashboardHouseOccupancy.fOccupiedUnits - dsDashboardHouseOccupancy.fOccupiedUnitsBudget, false)#
									</font>
								</cfif>								 
							</td>
							<cfif rollup is not 1>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									<cfif rollup is 3>Phone Number:<cfelseif rollup is 2>Phone Number: <!---<cfelse>Residence Director:mshah commented as per requirement---></cfif>
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>
									<cfif rollup is 3>
										<cfset dsDashboardContactInfo = #helperObj.FetchRollupContactInfo(#dsDashboardHouseInfo.RDOFullName#)#>
										<cfif dsDashboardContactInfo.recordcount is not 0>
											<cfif #dsDashboardContactInfo.PhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardContactInfo.PhoneNumber#</cfif>
										<cfelse>
											<cfif #dsDashboardHouseInfo.RDOPhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardHouseInfo.RDOPhoneNumber#</cfif>
										</cfif>
									<cfelseif rollup is 2>
										<cfset dsDashboardContactInfo = #helperObj.FetchRollupContactInfo(#dsDashboardHouseInfo.DDHRFullName#)#>
										<cfif dsDashboardContactInfo.recordcount is not 0>
											<cfif #dsDashboardContactInfo.PhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardContactInfo.PhoneNumber#</cfif>
										<cfelse>
											<cfif #dsDashboardHouseInfo.DDHRPhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardHouseInfo.DDHRPhoneNumber#</cfif>
										</cfif>
									<!---<cfelse>
										#dsDashboardHouseInfo.cResidenceDirector# mshah commented as per requirement--->
									</cfif>
								</font>
							</td>
							</cfif>
						</tr>
						<tr>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									MTD Actual Residents:
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>
									#helperObj.GetNumberFormat(dsDashboardHouseOccupancy.fPhysicalTenants, false)#
								</font>
							</td>
							<cfif rollup is not 1>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									<cfif rollup is 3>RDCS:<cfelseif rollup is 2>DVPSM: <!---<cfelse>Wellness Director:---></cfif>
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>
									<cfif rollup is 3> <cfset row5 = #dsDashboardHouseInfo.RDCSFullName#>
									<cfelseif rollup is 2> <cfset row5 = #dsDashboardHouseInfo.DVPSMFullName#>
									<!---<cfelse> <cfset row5 = #dsDashboardHouseInfo.cWellnessDirector#></cfif>
									<cfif row5 is ""> - <cfelse> #row5#---> </cfif>
								</font>
							</td>
							</cfif>
						</tr>
						<tr>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									MTD Budgeted Residents:
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>
									#helperObj.GetNumberFormat(dsDashboardHouseOccupancy.fTenantsBudget, false)#
								</font>
							</td>
							<cfif rollup is not 1>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									Phone Number:
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<cfif rollup is 3>	
										<cfset dsDashboardContactInfo = #helperObj.FetchRollupContactInfo(#dsDashboardHouseInfo.RDCSFullName#)#>
										<font size=-1>
											<cfif dsDashboardContactInfo.recordcount is not 0>
												<cfif #dsDashboardContactInfo.PhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardContactInfo.PhoneNumber#</cfif>
											<cfelse>
												<cfif #dsDashboardHouseInfo.RDCSPhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardHouseInfo.RDCSPhoneNumber#</cfif>
											</cfif>
										</font>
								<cfelseif rollup is 2> 
										<cfset dsDashboardContactInfo = #helperObj.FetchRollupContactInfo(#dsDashboardHouseInfo.DVPSMFullName#)#>
										<font size=-1>
											<cfif dsDashboardContactInfo.recordcount is not 0>
												<cfif #dsDashboardContactInfo.PhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardContactInfo.PhoneNumber#</cfif>
											<cfelse>
												<cfif #dsDashboardHouseInfo.DVPSMPhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardHouseInfo.DVPSMPhoneNumber#</cfif>
											</cfif>
										</font>
								<cfelse><cfset phone = rereplace(dsDashboardHouseInfo.cPhoneNumber, "[^0-9]", "", "all") />
									<cfif len(phone) is 10>
										<font size=-1>
											#'(' & left(phone, 3) & ') ' & mid(phone, 4, 3) & '-' & right(phone, 4)#
										</font>
									<cfelse>
										<font size=-1>
											#phone#
										</font>
									</cfif>
								</cfif>
							</td>
							</cfif>
						</tr>
						<tr>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									Residents Variance:
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
							<!--- 	<cfif IsNumeric("dsDashboardHouseOccupancy.fPhysicalTenants") and IsNumeric("dsDashboardHouseOccupancy.fTenantsBudget")>  corrected IsNumeric 09-21-11 S Farmer tkt 78047 --->
							<cfif IsNumeric(dsDashboardHouseOccupancy.fPhysicalTenants) and IsNumeric(dsDashboardHouseOccupancy.fTenantsBudget)>
								<font size=-1 color=<cfif (dsDashboardHouseOccupancy.fPhysicalTenants - dsDashboardHouseOccupancy.fTenantsBudget) lt 0>"Red"<cfelse>"Black"</cfif>>
									#helperObj.GetNumberFormat(dsDashboardHouseOccupancy.fPhysicalTenants - dsDashboardHouseOccupancy.fTenantsBudget, false)#
								</font>
							</cfif>
							</td>
							<cfif rollup is not 1>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									<cfif rollup is 3>RDSM:<cfelseif rollup is 2>DVPQCM: <cfelse>Sub Account:</cfif>
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>
								<cfif rollup is 3> <cfif #dsDashboardHouseInfo.RDSMFullName# is ""> - <cfelse> #dsDashboardHouseInfo.RDSMFullName# </cfif>
								<cfelseif rollup is 2> <cfif #dsDashboardHouseInfo.DVPQCMFullName# is ""> - <cfelse> #dsDashboardHouseInfo.DVPQCMFullName# </cfif>
								<cfelse>	<cfif ccllcHouse is 0>
										#dsDashboardHouseInfo.cSubAccount#
									<cfelse> - 
									</cfif>
								</cfif>
								</font>
							</td>
							</cfif>
						</tr>
						<tr>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									House Acuity (from TIPS):
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>#NumberFormat(dsDashboardHouseOccupancy.fPhysicalAcuity, "0.00")# (Res Avg Pts)</font>
								<!---<font size=-1> <b>(Res. Avg Pts)</b></font>
									(Level #dsDashboardHouseOccupancy.cPhysicalAcuityLevel#)--->
							</td>
							<cfif rollup is not 1>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>
									<cfif rollup is 3 or rollup is 2>Phone Number: <cfelse>Bond House:</cfif>
								</font>
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<cfif rollup is 3>
										<cfset dsDashboardContactInfo = #helperObj.FetchRollupContactInfo(#dsDashboardHouseInfo.RDSMFullName#)#>
										<font size=-1>
											<cfif dsDashboardContactInfo.recordcount is not 0>
												<cfif #dsDashboardContactInfo.PhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardContactInfo.PhoneNumber#</cfif>
											<cfelse>
												<cfif #dsDashboardHouseInfo.RDSMPhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardHouseInfo.RDSMPhoneNumber#</cfif>							
											</cfif>
										</font>
								<cfelseif rollup is 2> 
										<cfset dsDashboardContactInfo = #helperObj.FetchRollupContactInfo(#dsDashboardHouseInfo.DVPQCMFullName#)#>
										<font size=-1>
											<cfif dsDashboardContactInfo.recordcount is not 0>
												<cfif #dsDashboardContactInfo.PhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardContactInfo.PhoneNumber#</cfif>
											<cfelse>
												<cfif #dsDashboardHouseInfo.DVPQCMPhoneNumber# is ""> 1-888-252-5001 <cfelse>#dsDashboardHouseInfo.DVPQCMPhoneNumber#</cfif>							
											</cfif>
										</font>	
								<cfelse>	<cfif dsDashboardHouseInfo.bIsBondHouse eq true>
										<font size=-1>
											Yes
										</font>
									<cfelse>
										<font size=-1>
											No
										</font>
									</cfif>
								</cfif>
							</td>
							</cfif>
						</tr>
						<cfif rollup is 2>
						<tr>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>					
									Actual Occupancy Percentage: 
								</font>	
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1>
                                                                  <cfif #dsDashboardHouseOccupancy.fOccupiedUnitsBudget# EQ "" AND #dsDashboardHouseOccupancy.fUnitsAvailable# EQ ""> &nbsp;
								<cfelse> #helperObj.GetNumberFormat((dsDashboardHouseOccupancy.fOccupiedUnits/dsDashboardHouseOccupancy.fUnitsAvailable) * 100, false)#%
								</cfif>  
							<!---		#helperObj.GetNumberFormat((dsDashboardHouseOccupancy.fOccupiedUnits/dsDashboardHouseOccupancy.fUnitsAvailable) * 100, false)#%  --->
								</font>
							</td>
							<td align="Middle" colspan=1 bgcolor="#budgetCellColor#"></td>	<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#"></td>
						</tr>
						<tr>
							<td align="right" colspan=1 bgcolor="#budgetCellColor#">
								<font size=-1>					
									Budgeted Occupancy Percentage:
								</font>	
							</td>
							<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#">
								<font size=-1> 
                                                                  <cfif #dsDashboardHouseOccupancy.fOccupiedUnitsBudget# EQ "" AND #dsDashboardHouseOccupancy.fUnitsAvailable# EQ ""> &nbsp;
								<cfelse> #helperObj.GetNumberFormat((dsDashboardHouseOccupancy.fOccupiedUnitsBudget/dsDashboardHouseOccupancy.fUnitsAvailable) * 100, false)#% 
								</cfif>
							<!---		#helperObj.GetNumberFormat((dsDashboardHouseOccupancy.fOccupiedUnitsBudget/dsDashboardHouseOccupancy.fUnitsAvailable) * 100, false)#%  --->
								</font>
							</td>
							<td align="Middle" colspan=1 bgcolor="#budgetCellColor#"></td>	<td align="Middle" colspan="1" bgcolor="#secondaryCellColor#"></td>
						</tr>
						</cfif>
					</table>
				</td>
				<td valign="top">
				<!---<cfif rollup is 0>--->
					<table width="475" height="240" cellspacing="0" cellpadding="1" border="1px">
						<tr>
							<td align="middle" style="font-weight: bold" height="20px" bgcolor="#headerCellColor#">
								<font size=-1 color="White">
									12 Month Private Physical Census Trend
								</font>
							</td>
						</tr>
						<tr>
							<td height="180" align="middle">
								<cftry>
									<cfset chartLow = Round(helperObj.FetchLowValOfCensusTrend(ds12MonthTrend) - 2)>
									<cfset chartHigh = Round(helperObj.FetchHighValOfCensusTrend(ds12MonthTrend) + 2)>
									<cfset gridLines = (chartHigh - chartLow) / 2>
									<cfif gridLines neq Round(gridLines)>		
										<cfset chartHigh = chartHigh + 1>
										<cfset gridLines = (chartHigh - chartLow) / 2>
									</cfif>									
									<cfset gridLines = gridLines + 1>
									<cfchart backgroundcolor="White" scalefrom="#chartLow#" gridlines="#gridLines#" scaleto="#chartHigh#" 
										showxgridlines="yes" yaxistype="scale" labelformat="number" yoffset=".1" xoffset=".1"  
										xaxistitle="Month" yaxistitle="Physical Residents" format="flash" showlegend="yes" 
										showygridlines="yes" chartheight="215" chartwidth="470">
											something
											<cfchartseries query="ds12MonthTrend" type="line" seriescolor="Blue" paintstyle="raise"  
												serieslabel="Private Census (Avg)" itemcolumn="cMonth" valuecolumn="fPrivateCensus" />
												
											<cfchartseries query="ds12MonthTrend" type="line" seriescolor="Red" paintstyle="raise"  
												serieslabel="Private Budget" itemcolumn="cMonth" valuecolumn="fPrivateBudget" />
									</cfchart>
								<cfcatch>
									There is no available Trend Data.
								</cfcatch>
								</cftry>
							</td>
						</tr>
					</table>
				<!---	</cfif>--->
				</td>
			</tr>
		</table>
		<table id="tblDashboardBottom" width="1000px">
			<tr>
				<td width="430px" valign="top">
					<!--- DISPLAY THE LABOR TRACKING DATA. --->

					<!--- Fetch the labor data totals for the current month. --->
					<cfif rollup is 3>
						<cfset dsTotalLaborTrackingData = #helperObj.FetchLaborHoursRollup(RegionId, PtoPFormat,1,false)#>
					<cfelseif rollup is 2>
						<cfset dsTotalLaborTrackingData = #helperObj.FetchLaborHoursRollup(DivisionId, PtoPFormat,2, false)#>
					<cfelseif rollup is 1>
						<cfset dsTotalLaborTrackingData = #helperObj.FetchLaborHoursConsolidated(PtoPFormat, false)#>
					<cfelse>
						<cfset dsLaborTrackingHours = #helperObj.FetchLaborHours(houseId, PtoPFormat)#>
						<cfset dsTotalLaborTrackingData = #helperObj.FetchLaborHoursForMTD(dsLaborTrackingHours)#>		
					</cfif>
					
					<!--- Create the Labor Nursing Mtd Accumulator variables. --->
					<cfset nursingRegularMtd = 0>
					<cfset nursingNonRegularMtd = 0>
					<cfset nursingAllMtd = 0>
					<cfset nursingBudgetMtd = 0>
					<cfset nursingVarianceMtd = 0>
					<!--- Create the Labor Mtd Accumulator variables. --->
					<cfset laborRegularMtd = 0>
					<cfset laborNonRegularMtd = 0>
					<cfset laborAllMtd = 0>
					<cfset laborBudgetMtd = 0>
					<cfset laborVarianceMtd = 0>		
					<cfset totalkitchenvarbgt = 0>
					<cfset isCCLLC = 0>	
					<cfset kitchenTrngVarBgt = 0>
					<cfset isCCLLC = 0>	
					<cfset PPADJHours = 0>
					<cfset PPADJVariance = 0>
					
					<cfif rollup is 0>
						<cfset dsCCLLCHouses = #helperObj.FetchCCLLCHouses(houseId)#>
						<cfif dsCCLLCHouses.recordcount is not 0>	
							<cfset isCCLLC = 1>
						<cfelse> 
							<cfset isCCLLC = 0>	
						</cfif>
					</cfif>
					<cfif ccllcHouse is 0>
					<table id="tblDashboardLaborPreview" height="350px"  cellspacing="0" cellpadding="1" border="1px">
					<cfelse>
					<table id="tblDashboardLaborPreview" height="80px"  cellspacing="0" cellpadding="1" border="1px">
					</cfif>
						<tr>
							<td colspan=6 align="middle" style="font-weight: bold" height="20px" bgcolor="#headerCellColor#">
								<font size=-1 color="White">
									MTD Hours Worked Compared to MTD Hours Budgeted
								</font>
							</td>
						</tr>
						<tr>
							<td colspan=1 align="middle" width="130px" bgcolor="#secondaryCellColor#">
								<font size=-1>
						
								</font>
							</td>
							<td colspan=1 align="middle" width="60px" bgcolor="#secondaryCellColor#">
								<font size=-1>
									MTD<br />
									Regular
								</font>
							</td>
							<td colspan=1 align="middle" width="60px" bgcolor="#secondaryCellColor#">
								<font size=-1>
									MTD<br />
									OT/Other		
								</font>
							</td>		
							<td colspan=1 align="middle" width="60px" bgcolor="#secondaryCellColor#">
								<font size=-1>
									MTD</br />
									Total			
								</font>
							</td>		
							<td colspan=1 align="middle" width="60px" bgcolor="#secondaryCellColor#">
								<font size=-1>
									MTD<br />
									Var Bgt
								</font>
							</td>	
							<td colspan=1 align="middle" width="60px" bgcolor="#secondaryCellColor#">
								<font size=-1>
									MTD<br />
									Variance		
								</font>
							</td>		
						</tr>
						<!--- loop through labor categories --->
					<!---	<cfdump var="#dsTotalLaborTrackingData#" label="dsTotalLaborTrackingData"> --->
						<cfloop query="dsTotalLaborTrackingData">
						<cfif ccllcHouse is 0>
							<!--- Check if the current column should be displayed. --->
							<cfif dsTotalLaborTrackingData.cLaborTrackingCategory is "PPADJ">
								<cfset PPADJHours = dsTotalLaborTrackingData.fAll>
								<cfset PPADJVariance = dsTotalLaborTrackingData.fVariableBudget - dsTotalLaborTrackingData.fAll>
							</cfif>
							<cfif dsTotalLaborTrackingData.bIsVisible eq true And (dsTotalLaborTrackingData.cLaborTrackingCategory neq "PTO" and dsTotalLaborTrackingData.cLaborTrackingCategory neq "Kitchen Training" and dsTotalLaborTrackingData.cLaborTrackingCategory neq "WD Salary" and dsTotalLaborTrackingData.cLaborTrackingCategory neq "PPADJ")>
								<tr>
									<!--- Display the column name. --->
									<td align=right bgcolor="#secondaryCellColor#">
										<font size=-1>
											#dsTotalLaborTrackingData.cDisplayName#
										</font>
									</td>
									<cfif dsTotalLaborTrackingData.cLaborTrackingCategory is "WD Hourly">			

										<!--- Display the Nursing Data. --->
										<td align=right bgcolor="#actualCellColor#">
											<font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular, "0.0")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fRegular>
												<cfset nursingRegularMtd = nursingRegularMtd + dsTotalLaborTrackingData.fRegular>
											</font>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborNonRegularMtd = laborNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
												<cfset nursingNonRegularMtd = nursingNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
											</font>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>				
												<cfset nursingAllMtd = nursingAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
											</font>
										</td>
										<td align=right bgcolor="#budgetCellColor#">
											<font size=-1>
												<cfif rollup is 2>
													<cfset dsWDHVarBgt = #helperObj.FetchLaborTrackingDivisionalWDHVarBgt(DivisionID, PtoPFormat, false)#>
													#helperObj.LaborNumberFormat(dsWDHVarBgt.varbgt, "0.00")#
													<cfset dsWDHVarBgt.varbgt = #NumberFormat(dsWDHVarBgt.varbgt, "0.00")#>	
													<cfset laborBudgetMtd = laborBudgetMtd + dsWDHVarBgt.varbgt>							
													<cfset nursingBudgetMtd = nursingBudgetMtd + dsWDHVarBgt.varbgt>			
												<cfelseif rollup is 3>
													<cfset dsWDHVarBgt = #helperObj.FetchLaborTrackingDivisionalWDHVarBgt(RegionID, PtoPFormat, true)#>
													#helperObj.LaborNumberFormat(dsWDHVarBgt.varbgt, "0.00")#
													<cfset dsWDHVarBgt.varbgt = #NumberFormat(dsWDHVarBgt.varbgt, "0.00")#>
													<cfset laborBudgetMtd = laborBudgetMtd + dsWDHVarBgt.varbgt>		
													<cfset nursingBudgetMtd = nursingBudgetMtd + dsWDHVarBgt.varbgt>								
												<cfelse>
													#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget, "0.00")#
													<!--- Update the Mtd Accumulators. --->
													<cfset laborBudgetMtd = laborBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>	
													<cfset nursingBudgetMtd = nursingBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>									
												</cfif>
											</font>
										</td>
										
										
										
										<td align=right bgcolor="#varianceCellColor#">
											<cfif rollup is 2 or rollup is 3>
												<cfset currentLaborMtdVariance = dsWDHVarBgt.varbgt - (dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther)>
											<cfelse>
												<cfset currentLaborMtdVariance = dsTotalLaborTrackingData.fVariableBudget - (dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther)>
											</cfif>
											<font size=-1 color=<cfif currentLaborMtdVariance lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.LaborNumberFormat(currentLaborMtdVariance, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset nursingVarianceMtd = nursingVarianceMtd + currentLaborMtdVariance>
												<cfset laborVarianceMtd = laborVarianceMtd + currentLaborMtdVariance>						
											</font>
										</td>
									<!--- Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total. --->
									<cfelseif dsTotalLaborTrackingData.cLaborTrackingCategory is "Resident Care" or 
											dsTotalLaborTrackingData.cLaborTrackingCategory is "Nurse Consultant" or 
											dsTotalLaborTrackingData.cLaborTrackingCategory is "LPN - LVN">			

										<!--- Display the Nursing Data. --->
										<td align=right bgcolor="#actualCellColor#">
											<font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular, "0.0")#
												<!--- Update the Mtd Accumulators. --->
												<cfset nursingRegularMtd = nursingRegularMtd + dsTotalLaborTrackingData.fRegular>
												<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fRegular>
											</font>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")#
												<!--- Update the Mtd Accumulators. --->
												<cfset nursingNonRegularMtd = nursingNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
												<cfset laborNonRegularMtd = laborNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
											</font>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")#
												<!--- Update the Mtd Accumulators. --->
												<cfset nursingAllMtd = nursingAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
												<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>				
											</font>
										</td>
										<td align=right bgcolor="#budgetCellColor#">
											<font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset nursingBudgetMtd = nursingBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>
												<cfset laborBudgetMtd = laborBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>										
											</font>
										</td>
										<td align=right bgcolor="#varianceCellColor#">
											<cfset currentLaborMtdVariance = dsTotalLaborTrackingData.fVariableBudget - (dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther)>
											<font size=-1 color=<cfif currentLaborMtdVariance lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.LaborNumberFormat(currentLaborMtdVariance, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset nursingVarianceMtd = nursingVarianceMtd + currentLaborMtdVariance>
												<cfset laborVarianceMtd = laborVarianceMtd + currentLaborMtdVariance>						
											</font>
										</td>
									<!--- Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
									<cfelseif dsTotalLaborTrackingData.cLaborTrackingCategory is "Kitchen">
										<!--- Display the Kitchen Data. --->
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular, "0.0")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fRegular>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborNonRegularMtd = laborNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>				
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#budgetCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborBudgetMtd = laborBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>	
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#varianceCellColor#">
											<cfif isCCLLC is 0><cfset currentLaborMtdVariance = dsTotalLaborTrackingData.fVariableBudget - (dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther)>
											<font size=-1 color=<cfif currentLaborMtdVariance lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.LaborNumberFormat(currentLaborMtdVariance, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborVarianceMtd = laborVarianceMtd + currentLaborMtdVariance>		
											</font><cfelse> - </cfif>
										</td>
<!--- Gthota  02/26/2018  Added code for Maeningful Pursuit/Housekeeping/Maintenance /MA-CONCRGE of LaborTrackingCategory --->										
							<cfelseif dsTotalLaborTrackingData.cLaborTrackingCategory is "Activities">
										<!--- Display the Kitchen Data. --->
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fRegular>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborNonRegularMtd = laborNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>				
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#budgetCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborBudgetMtd = laborBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>	
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#varianceCellColor#">
											<cfif isCCLLC is 0><cfset currentLaborMtdVariance = dsTotalLaborTrackingData.fVariableBudget - (dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther)>
											<font size=-1 color=<cfif currentLaborMtdVariance lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.LaborNumberFormat(currentLaborMtdVariance, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborVarianceMtd = laborVarianceMtd + currentLaborMtdVariance>		
											</font><cfelse> - </cfif>
										</td>			
									<cfelseif dsTotalLaborTrackingData.cLaborTrackingCategory is "Housekeeping">
										<!--- Display the Kitchen Data. --->
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fRegular>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborNonRegularMtd = laborNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>				
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#budgetCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborBudgetMtd = laborBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>	
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#varianceCellColor#">
											<cfif isCCLLC is 0><cfset currentLaborMtdVariance = dsTotalLaborTrackingData.fVariableBudget - (dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther)>
											<font size=-1 color=<cfif currentLaborMtdVariance lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.LaborNumberFormat(currentLaborMtdVariance, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborVarianceMtd = laborVarianceMtd + currentLaborMtdVariance>		
											</font><cfelse> - </cfif>
										</td>	
										<cfelseif dsTotalLaborTrackingData.cLaborTrackingCategory is "Maintenance">
										<!--- Display the Kitchen Data. --->
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fRegular>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborNonRegularMtd = laborNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>				
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#budgetCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborBudgetMtd = laborBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>	
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#varianceCellColor#">
											<cfif isCCLLC is 0><cfset currentLaborMtdVariance = dsTotalLaborTrackingData.fVariableBudget - (dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther)>
											<font size=-1 color=<cfif currentLaborMtdVariance lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.LaborNumberFormat(currentLaborMtdVariance, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborVarianceMtd = laborVarianceMtd + currentLaborMtdVariance>		
											</font><cfelse> - </cfif>
										</td>	
										<cfelseif dsTotalLaborTrackingData.cLaborTrackingCategory is "MA - AA">
										<!--- Display the Kitchen Data. --->
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fRegular>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborNonRegularMtd = laborNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>				
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#budgetCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborBudgetMtd = laborBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>	
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#varianceCellColor#">
											<cfif isCCLLC is 0><cfset currentLaborMtdVariance = dsTotalLaborTrackingData.fVariableBudget - (dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther)>
											<font size=-1 color=<cfif currentLaborMtdVariance lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.LaborNumberFormat(currentLaborMtdVariance, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborVarianceMtd = laborVarianceMtd + currentLaborMtdVariance>		
											</font><cfelse> - </cfif>
										</td>
										<cfelseif dsTotalLaborTrackingData.cLaborTrackingCategory is "Other">
										<!--- Display the Kitchen Data. --->
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fRegular>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborNonRegularMtd = laborNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>   <!--- Gthota 2/26/2018 replace fOther to fregular --->
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>				
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#budgetCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborBudgetMtd = laborBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>	
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#varianceCellColor#">
											<cfif isCCLLC is 0><cfset currentLaborMtdVariance = dsTotalLaborTrackingData.fVariableBudget - (dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther)>
											<font size=-1 color=<cfif currentLaborMtdVariance lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.LaborNumberFormat(currentLaborMtdVariance, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborVarianceMtd = laborVarianceMtd + currentLaborMtdVariance>		
											</font><cfelse> - </cfif>
										</td>
												
										<cfelseif dsTotalLaborTrackingData.cLaborTrackingCategory is "Training">
										<!--- Display the Kitchen Data. --->
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fRegular>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborNonRegularMtd = laborNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>   <!--- Gthota 2/26/2018 replace fOther to fregular --->
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")# 
												<!--- Update the Mtd Accumulators. --->
												<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>				
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#budgetCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborBudgetMtd = laborBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>	
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#varianceCellColor#">
											<cfif isCCLLC is 0><cfset currentLaborMtdVariance = dsTotalLaborTrackingData.fVariableBudget - (dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther)>
											<font size=-1 color=<cfif currentLaborMtdVariance lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.LaborNumberFormat(currentLaborMtdVariance, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborVarianceMtd = laborVarianceMtd + currentLaborMtdVariance>		
											</font><cfelse> - </cfif>
										</td>		
										
<!--- Gthota  02/26/2018  Code end --->
									<cfelseif dsTotalLaborTrackingData.cLaborTrackingCategory is "CRM">
										<!--- Display the Kitchen Data. --->
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular, "0.0")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fRegular>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborNonRegularMtd = laborNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#actualCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>				
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#budgetCellColor#">
											<cfif isCCLLC is 0><font size=-1>
												#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborBudgetMtd = laborBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>	
											</font><cfelse> - </cfif>
										</td>
										<td align=right bgcolor="#varianceCellColor#">
											<cfif isCCLLC is 0><cfset currentLaborMtdVariance = dsTotalLaborTrackingData.fVariableBudget - (dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther)>
											<font size=-1 color=<cfif currentLaborMtdVariance lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.LaborNumberFormat(currentLaborMtdVariance, "0.00")#
												<!--- Update the Mtd Accumulators. --->
												<cfset laborVarianceMtd = laborVarianceMtd + currentLaborMtdVariance>		
											</font><cfelse> - </cfif>
										</td>
<!---  --->
									<cfelse>	
										<cfif bIsTraining eq true>
												<cfset trainingBudgetMtd = dsTotalLaborTrackingData.fVariableBudget>	
												<!--- Display the training data. --->
												<td align=right bgcolor="#actualCellColor#">
													<font size=-1>
														#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fAll, "0.0")#
														<!--- Update the Mtd Accumulators. --->
														<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fAll>
													</font>
												</td>
												<td align=right bgcolor="#actualCellColor#">
													<font size=-1>
														#helperObj.LaborNumberFormat(0, "0.0")#
													</font>
												</td>
												<td align=right bgcolor="#actualCellColor#">
													<font size=-1>
														#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fAll, "0.0")#
														<!--- Update the Mtd Accumulators. --->
														<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fAll>				
													</font>
												</td>
												<td align=right bgcolor="#budgetCellColor#">
													<font size=-1>
														#helperObj.LaborNumberFormat(trainingBudgetMtd, "0.00")#
														<!--- Update the Mtd Accumulators. --->
														<cfset laborBudgetMtd = laborBudgetMtd + trainingBudgetMtd>										
													</font>
												</td>
												<td align=right bgcolor="#varianceCellColor#">
													<font size=-1 color=<cfif (trainingBudgetMtd - dsTotalLaborTrackingData.fAll) lt 0>"Red"<cfelse>"Black"</cfif>>
														#helperObj.LaborNumberFormat(trainingBudgetMtd - dsTotalLaborTrackingData.fAll, "0.00")#
														<!--- Update the Mtd Accumulators. --->
														<cfset laborVarianceMtd = laborVarianceMtd + (trainingBudgetMtd - dsTotalLaborTrackingData.fAll)>						
													</font>
												</td>							
										<cfelse>
											<cfif dsTotalLaborTrackingData.cLaborTrackingCategory is not "PPADJ">
												<!--- Display the non-nursing data. --->
												<td align=right bgcolor="#actualCellColor#">
													<font size=-1>
														#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fAll, "0.0")#
														<!--- Update the Mtd Accumulators. --->
														<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fAll>
													</font>
												</td>
												<td align=right bgcolor="#actualCellColor#">
													<font size=-1>
														#helperObj.LaborNumberFormat(0, "0.0")#
													</font>
												</td>
												<td align=right bgcolor="#actualCellColor#">
													<font size=-1>
														#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fAll, "0.0")#
														<!--- Update the Mtd Accumulators. --->
														<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fAll>				
													</font>
												</td>
												<td align=right bgcolor="#budgetCellColor#">
													<font size=-1>
														#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget, "0.00")#
														<!--- Update the Mtd Accumulators. --->
														<cfset laborBudgetMtd = laborBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>										
													</font>
												</td>
												<td align=right bgcolor="#varianceCellColor#">
													<font size=-1 color=<cfif (dsTotalLaborTrackingData.fVariableBudget - dsTotalLaborTrackingData.fAll) lt 0>"Red"<cfelse>"Black"</cfif>>
														#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget - dsTotalLaborTrackingData.fAll, "0.00")#
														<!--- Update the Mtd Accumulators. --->
														<cfset laborVarianceMtd = laborVarianceMtd + (dsTotalLaborTrackingData.fVariableBudget - dsTotalLaborTrackingData.fAll)>						
													</font>
												</td>	
											</cfif>
										</cfif>
									</cfif>
								</tr>
								<cfif dsTotalLaborTrackingData.cLaborTrackingCategory is "Nurse Consultant">
									<tr>
										<!--- Display the Nursing Totals. --->
										<td align=right style="font-weight: bold" bgcolor="#secondaryCellColor#">
											<font size=-1>
												Sub-Total Nursing
											</font>
										</td>
										<td align=right style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
											<font size=-1>
												#helperObj.LaborNumberFormat(nursingRegularMtd, "0.0")#
											</font>
										</td>
										<td align=right style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
											<font size=-1>
												#helperObj.LaborNumberFormat(nursingNonRegularMtd, "0.0")#
											</font>
										</td>
										<td align=right style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
											<font size=-1>
												#helperObj.LaborNumberFormat(nursingAllMtd, "0.0")#
											</font>
										</td>
										<td align=right style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
											<font size=-1>
												#helperObj.LaborNumberFormat(nursingBudgetMtd, "0.00")#
											</font>
										</td>
										<td align=right style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
											<font size=-1 color=<cfif nursingVarianceMtd lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.LaborNumberFormat(nursingVarianceMtd, "0.00")#
											</font>
										</td>	
									</tr>	
								</cfif>
							</cfif>
						<cfelse><!--- ccllcHouse is 1 --->
						<tr>
							<cfif dsTotalLaborTrackingData.cLaborTrackingCategory is "Kitchen">
								<!--- Display the Kitchen Data. --->
								<td align=right bgcolor="#secondaryCellColor#">
									<font size=-1>
										Kitchen Services
									</font>
								</td>
								<td align=right bgcolor="#actualCellColor#">
									<font size=-1>
										#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular, "0.0")#
										<!--- Update the Mtd Accumulators. --->
										<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fRegular>
									</font>
								</td>
								<td align=right bgcolor="#actualCellColor#">
									<font size=-1>
										#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")#
										<!--- Update the Mtd Accumulators. --->
										<cfset laborNonRegularMtd = laborNonRegularMtd + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>
									</font>
								</td>
								<td align=right bgcolor="#actualCellColor#">
									<font size=-1>
										#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther, "0.0")#
										<!--- Update the Mtd Accumulators. --->
										<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther>				
									</font>
								</td>
								<td align=right bgcolor="#budgetCellColor#">
									<font size=-1>
										#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fVariableBudget, "0.00")#
										<!--- Update the Mtd Accumulators. --->
										<cfset laborBudgetMtd = laborBudgetMtd + dsTotalLaborTrackingData.fVariableBudget>										
										<!---<cfset kitchenTrngVarBgt = (dsTotalLaborTrackingData.fVariableBudget * 0.2) / 10>--->
									</font>
								</td>
								<td align=right bgcolor="#varianceCellColor#">
									<cfset currentLaborMtdVariance = dsTotalLaborTrackingData.fVariableBudget - (dsTotalLaborTrackingData.fRegular + dsTotalLaborTrackingData.fOvertime + dsTotalLaborTrackingData.fOther)>
									<font size=-1 color=<cfif currentLaborMtdVariance lt 0>"Red"<cfelse>"Black"</cfif>>
										#helperObj.LaborNumberFormat(currentLaborMtdVariance, "0.00")#
										<!--- Update the Mtd Accumulators. --->
										<cfset laborVarianceMtd = laborVarianceMtd + currentLaborMtdVariance>		
									</font>
								</td>
							</cfif>
							<cfif dsTotalLaborTrackingData.cLaborTrackingCategory is "Kitchen Training">
								<cfset trainingBudgetMtd = dsTotalLaborTrackingData.fVariableBudget> <!---kitchenTrngVarBgt>--->	
								<!--- Display the training data. --->
								<td align=right bgcolor="#secondaryCellColor#">
									<font size=-1>
										Kitchen Training
									</font>
								</td>
								<td align=right bgcolor="#actualCellColor#">
									<font size=-1>
										#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fAll, "0.0")#
										<!--- Update the Mtd Accumulators. --->
										<cfset laborRegularMtd = laborRegularMtd + dsTotalLaborTrackingData.fAll>
									</font>
								</td>
								<td align=right bgcolor="#actualCellColor#">
									<font size=-1>
										#helperObj.LaborNumberFormat(0, "0.0")#
									</font>
								</td>
								<td align=right bgcolor="#actualCellColor#">
									<font size=-1>
										#helperObj.LaborNumberFormat(dsTotalLaborTrackingData.fAll, "0.0")#
										<!--- Update the Mtd Accumulators. --->
										<cfset laborAllMtd = laborAllMtd + dsTotalLaborTrackingData.fAll>				
									</font>
								</td>
								<td align=right bgcolor="#budgetCellColor#">
									<font size=-1>
										#helperObj.LaborNumberFormat(trainingBudgetMtd, "0.00")#
										<!--- Update the Mtd Accumulators. --->
										<cfset laborBudgetMtd = laborBudgetMtd + trainingBudgetMtd>										
									</font>
								</td>
								<td align=right bgcolor="#varianceCellColor#">
									<font size=-1 color=<cfif (trainingBudgetMtd - dsTotalLaborTrackingData.fAll) lt 0>"Red"<cfelse>"Black"</cfif>>
										#helperObj.LaborNumberFormat(trainingBudgetMtd - dsTotalLaborTrackingData.fAll, "0.00")#
										<!--- Update the Mtd Accumulators. --->
										<cfset laborVarianceMtd = laborVarianceMtd + (trainingBudgetMtd - dsTotalLaborTrackingData.fAll)>						
									</font>
								</td>							
							</cfif>
							</tr>
						</cfif>
						</cfloop>
						<tr>
							<!--- Display the Totals. --->
							<td align=right style="font-weight: bold" bgcolor="#secondaryCellColor#">
								<font size=-1>
									Total
								</font>
							</td>
							<td align=right style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
								<font size=-1>
									#helperObj.LaborNumberFormat(laborRegularMtd, "0.0")#
								</font>
							</td>
							<td align=right style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
								<font size=-1>
									#helperObj.LaborNumberFormat(laborNonRegularMtd, "0.0")#
								</font>
							</td>
							<td align=right style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
								<font size=-1>
									#helperObj.LaborNumberFormat(laborAllMtd, "0.0")#
								</font>
							</td>
							<td align=right style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
								<font size=-1>
								 	#helperObj.LaborNumberFormat(laborBudgetMtd, "0.00")#
								</font>
							</td>
							<td align=right style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
								<font size=-1 color=<cfif laborVarianceMtd lt 0>"Red"<cfelse>"Black"</cfif>>
									#helperObj.LaborNumberFormat(laborVarianceMtd, "0.00")#
								</font>
							</td>	
						</tr>	
						<tr>
							<!--- PPADJ Hours Excluded from total just like Labor Tracking. --->
							<td align=right bgcolor="#secondaryCellColor#">
								<font size=-1>
									Prior Pd. Adj.
								</font>
							</td>
							<td align=right bgcolor="#actualCellColor#">
								<font size=-1>
									#helperObj.LaborNumberFormat(PPADJHours, "0.0")#
								</font>
							</td>
							<td align=right bgcolor="#actualCellColor#">
								<font size=-1>
									-
								</font>
							</td>
							<td align=right bgcolor="#actualCellColor#">
								<font size=-1>
									#helperObj.LaborNumberFormat(PPADJHours, "0.0")#
								</font>
							</td>
							<td align=right bgcolor="#budgetCellColor#">
								<font size=-1>
								 	-
								</font>
							</td>
							<td align=right bgcolor="#varianceCellColor#">
								<font size=-1 color=<cfif PPADJVariance lt 0>"Red"<cfelse>"Black"</cfif>>
									#helperObj.LaborNumberFormat(PPADJVariance, "0.00")#
								</font>
							</td>	
						</tr>	
					</table>
				</td>
				<td valign="top">
				
				<!--- DISPLAY THE EXPENSE SPENDING (AP) DATA --->
				<!---<cfif rollup is 3>
					<cfset MtdActuals = helperObj.FetchActualRollupSummary(RegionID, PtoPFormat, FromDate, ThruDate, rollup)>
					<cfset dsBudgetSummary = helperObj.FetchBudgetRollupSummary(RegionID, currentY, monthForQueries, rollup)>
					<cfset foodBudgetAccumulator = #helperObj.FetchRollupFoodBudgetAccumulator(RegionID, currenty, monthforqueries, rollup)#>
					<cfset CensusMtd = #helperObj.FetchRollupCensusDetailsMTD(RegionID, FromDate, ThruDate, rollup)#>						
				<cfelseif rollup is 2>
					<cfset MtdActuals = helperObj.FetchActualRollupSummary(DivisionID, PtoPFormat, FromDate, ThruDate, rollup)>
					<cfset dsBudgetSummary = helperObj.FetchBudgetRollupSummary(DivisionID, currentY, monthForQueries, rollup)>
					<cfset CensusMtd = #helperObj.FetchRollupCensusDetailsMTD(DivisionID, FromDate, ThruDate, rollup)#>	
					<cfset foodBudgetAccumulator = #helperObj.FetchRollupFoodBudgetAccumulator(DivisionID, currenty, monthforqueries, rollup)#>
				<cfelseif rollup is 1>
					<cfset MtdActuals = helperObj.FetchActualConsolidatedSummary(PtoPFormat, FromDate, ThruDate)>
					<cfset dsBudgetSummary = helperObj.FetchBudgetConsolidatedSummary(currentY, monthForQueries)>
					<cfset CensusMtd = #helperObj.FetchConsolidatedCensusDetailsMTD(FromDate, ThruDate)#>	
					<cfset foodBudgetAccumulator = #helperObj.FetchConsolidatedFoodBudgetAccumulator(currenty, monthforqueries)#>
				<cfelse>
					<cfset dsActualDetails = helperObj.FetchActualDetails(houseId, PtoPFormat, FromDate, ThruDate)>
					<cfset dsActualSummary = helperObj.FetchActualSummary(houseId, PtoPFormat, FromDate, ThruDate, dsActualDetails)>
					<cfset MtdActuals = helperObj.FetchActualSummaryMtd(dsActualSummary)>
					<cfset dsBudgetSummary = helperObj.FetchBudgetSummary(houseId, currentY, monthForQueries)>
					<cfset foodBudgetAccumulator = #helperObj.FetchFoodBudgetAccumulator(houseId, currenty, monthforqueries)#>
					<cfset dsCensusDetails = #helperObj.FetchCensusDetails(houseId, FromDate, ThruDate)#>		
					<cfset CensusMtd = helperObj.FetchTenantsMTD(dsCensusDetails)>
				</cfif>
				<cfset dsColumns = #helperObj.FetchColumns()#>
				<cfset actualsTotal = 0>
				<cfset budgetMtdTotal = 0>
				<cfset varianceMtdTotal = 0>
				<cfset budgetTotal = 0>
				<cfset varianceTotal = 0>--->

			<!---<cfif ccllcHouse is 0>
			<table id="tblDashboardExpensePreview" width="570px" height="380px" cellspacing="0" cellpadding="1" border="1px">
			<cfelse>
			<table id="tblDashboardExpensePreview" width="570px" height="100px" cellspacing="0" cellpadding="1" border="1px">
			</cfif>

				<cfif MtdActuals.RecordCount is "0" or dsBudgetSummary.RecordCount is "0">
					<tr>
						<td align="middle">
							<font size=-1>
								There is no available Expense Data.
							</font>
						</td>
					</tr>
				
				<cfelse>						
					<tr>
					<cfif currentd lt currentDim>
						<td colspan=6 align="middle" height="20px" style="font-weight: bold" bgcolor="#headerCellColor#">
						<font size=-1 color="White">
						Expense Spending MTD Totals Compared to MTD & #UCase(monthforqueries)# Spending Budgets
						</font>
						</td>				
					<cfelse>
						<td colspan=4 align="middle" height="20px" style="font-weight: bold" bgcolor="#headerCellColor#">
						<font size=-1 color="White">
						Expense Spending MTD Totals Compared to MTD Spending Budget  
						</font>
						</td>
					</cfif>
					</tr>		
					<cfloop query="MtdActuals">
						<cfloop query="dsBudgetSummary">
						<cfif ccllcHouse is 0>
							<cfif MtdActuals.iSortOrder[MtdActuals.CurrentRow] eq dsBudgetSummary.iSortOrder>
								<cfif MtdActuals.CurrentRow eq 1>
									<tr>
										<td colspan=1 align="middle" width="140px" bgcolor="#secondaryCellColor#">
											<font size=-1>
											
											</font>
										</td>
										<td colspan=1 align="middle" bgcolor="#secondaryCellColor#">
											<font size=-1>
												MTD Actuals
											</font>
										</td>
										<td colspan=1 align="middle" bgcolor="#secondaryCellColor#">
											<font size=-1>
												MTD Budget			
											</font>
										</td>		
										<td colspan=1 align="middle" bgcolor="#secondaryCellColor#">
											<font size=-1>
												MTD Variance			
											</font>
										</td>		
										<cfif currentd lt currentDim>
											<td colspan=1 align="middle" bgcolor="#secondaryCellColor#">
												<font size=-1>
													#UCase(monthforqueries)# Budget	
												</font>
											</td>		
											<td colspan=1 align="middle" bgcolor="#secondaryCellColor#">
												<font size=-1>
													#UCase(monthforqueries)# Variance	
												</font>
											</td>	
										</cfif>
									</tr>
								</cfif>
								<cfset displayName = helperObj.FetchColumnDisplayName(dsColumns, MtdActuals.iExpenseCategoryId[MtdActuals.CurrentRow])>
								<tr>
									<td colspan=1 align="right" bgcolor="#secondaryCellColor#">
										<font size=-1>
											#displayName#
										</font> 
									</td>
									<td colspan=1 align="right" bgcolor="#actualCellColor#">
										<font size=-1>
											#helperObj.GetNumberFormat(MtdActuals.mAmount[MtdActuals.CurrentRow], true)#
											<cfset actualsTotal = actualsTotal + MtdActuals.mAmount[MtdActuals.CurrentRow]>
										</font>
									</td>
									<td colspan=1 align="right" bgcolor="#budgetCellColor#">
										<font size=-1>
											<cfif MtdActuals.CurrentRow eq 1>
												<cfset currentBudgetMtd = #censusMtd# * #foodBudgetAccumulator#>
												#helperObj.GetNumberFormat(currentBudgetMtd, true)#	
												<cfset budgetMtdTotal = budgetMtdTotal + currentBudgetMtd>					
											<cfelse>
												<cfset currentBudgetMtd = ((#dsBudgetSummary.mAmount# / #currentdim#) * #currentd#)>
												#helperObj.GetNumberFormat(currentBudgetMtd, true)#				
												<cfset budgetMtdTotal = budgetMtdTotal + currentBudgetMtd>
											</cfif>
										</font>
									</td>		
									<td colspan=1 align="right" bgcolor="#varianceCellColor#">
										<cfset currentVarianceMtd = (currentBudgetMtd - MtdActuals.mAmount[MtdActuals.CurrentRow])>
										<font size=-1 color=<cfif currentVarianceMtd lt 0>"Red"<cfelse>"Black"</cfif>>
											#helperObj.GetNumberFormat(currentVarianceMtd, true)#				
										<cfset varianceMtdTotal = varianceMtdTotal + currentVarianceMtd>
									</font>
									</td>		
									<cfif currentd lt currentDim>
										<td colspan=1 align="right" bgcolor="#budgetCellColor#">
											<font size=-1>
												<cfif MtdActuals.CurrentRow eq 1>
													<cfif rollup is 3 or rollup is 1>
														<cfset currentCensus = helperObj.FetchRollupCensusDetailsPerDay(RegionID, FromDate, ThruDate, currentD)>
													<cfelseif rollup is 2 or rollup is 1>
													<cfelse>
														<cfset currentCensus = #helperObj.FetchTenantsForDay(dsCensusDetails, currentD)#>
													</cfif>
													<cfset censusDim = ((#currentDim# - #currentD#) * (#currentCensus#)) + #censusMtd#>
													<cfset currentBudgetTotal = (#censusDim# * #foodBudgetAccumulator#)>
													#helperObj.GetNumberFormat(currentBudgetTotal, true)#				
													<cfset budgetTotal = budgetTotal + currentBudgetTotal>
												<cfelse>
													<cfset currentBudgetTotal = dsBudgetSummary.mAmount>
													#helperObj.GetNumberFormat(currentBudgetTotal, true)#				
													<cfset budgetTotal = budgetTotal + currentBudgetTotal>
												</cfif>
											</font>
										</td>		
										<td colspan=1 align="right" bgcolor="#varianceCellColor#">
											<cfset currentVarianceTotal = (currentBudgetTotal - MtdActuals.mAmount[MtdActuals.CurrentRow])>
											<font size=-1 color=<cfif currentVarianceTotal lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.GetNumberFormat(currentVarianceTotal, true)#				
												<cfset varianceTotal = varianceTotal + currentVarianceTotal>
											</font>
										</td>								
									</cfif>
								</tr>
								<cfif MtdActuals.CurrentRow eq MtdActuals.RecordCount>
									<tr>
										<td colspan=1 align="right" style="font-weight: bold" bgcolor="#secondaryCellColor#">
											<font size=-1>
												Total
											</font>
										</td>
										<td colspan=1 align="right" style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
											<font size=-1>
												#helperObj.GetNumberFormat(actualsTotal, true)#
											</font>
										</td>
										<td colspan=1 align="right" style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
											<font size=-1>
												#helperObj.GetNumberFormat(budgetMtdTotal, true)#				
											</font>
										</td>		
										<td colspan=1 align="right" style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
											<font size=-1 color=<cfif varianceMtdTotal lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.GetNumberFormat(varianceMtdTotal, true)#				
											</font>
										</td>		
										<cfif currentd lt currentDim>
											<td colspan=1 align="right" style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
												<font size=-1>
													#helperObj.GetNumberFormat(budgetTotal, true)#				
												</font>
											</td>		
											<td colspan=1 align="right" style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
												<font size=-1 color=<cfif varianceTotal lt 0>"Red"<cfelse>"Black"</cfif>>
													#helperObj.GetNumberFormat(varianceTotal, true)#				
												</font>
											</td>	
										</cfif>
									</tr>
								</cfif>
								<cfbreak>
							</cfif>
						<cfelse><!--- ccllchouse is 1 --->
							<cfset currentRow = 0>
							<cfif MtdActuals.CurrentRow eq 1>
								<cfif MtdActuals.iExpenseCategoryId is 1 and dsBudgetSummary.iExpenseCategoryId is 1>
									<tr>
										<td colspan=1 align="middle" width="140px" bgcolor="#secondaryCellColor#">
											<font size=-1>
											
											</font>
										</td>
										<td colspan=1 align="middle" bgcolor="#secondaryCellColor#">
											<font size=-1>
												MTD Actuals
											</font>
										</td>
										<td colspan=1 align="middle" bgcolor="#secondaryCellColor#">
											<font size=-1>
												MTD Budget			
											</font>
										</td>		
										<td colspan=1 align="middle" bgcolor="#secondaryCellColor#">
											<font size=-1>
												MTD Variance			
											</font>
										</td>		
										<cfif currentd lt currentDim>
											<td colspan=1 align="middle" bgcolor="#secondaryCellColor#">
												<font size=-1>
													#UCase(monthforqueries)# Budget	
												</font>
											</td>		
											<td colspan=1 align="middle" bgcolor="#secondaryCellColor#">
												<font size=-1>
													#UCase(monthforqueries)# Variance	
												</font>
											</td>	
										</cfif>
									</tr>
									<!---</cfif>--->
									<cfset displayName = helperObj.FetchColumnDisplayName(dsColumns, 1)>
									<tr>
										<td colspan=1 align="right" bgcolor="#secondaryCellColor#">
											<font size=-1>
												#displayName#
											</font>
										</td>
										<td colspan=1 align="right" bgcolor="#actualCellColor#">
											<font size=-1>
												#helperObj.GetNumberFormat(MtdActuals.mAmount[MtdActuals.CurrentRow], true)#
												<cfset actualsTotal = actualsTotal + MtdActuals.mAmount[MtdActuals.CurrentRow]>
											</font>
										</td>
										<td colspan=1 align="right" bgcolor="#budgetCellColor#">
											<font size=-1>
												<cfif MtdActuals.CurrentRow eq 1>
													<cfset currentBudgetMtd = (#censusMtd# * #foodBudgetAccumulator#)>
													#helperObj.GetNumberFormat(currentBudgetMtd, true)#				
													<cfset budgetMtdTotal = budgetMtdTotal + currentBudgetMtd>								
												<cfelse>
													<cfset currentBudgetMtd = ((#dsBudgetSummary.mAmount# / #currentdim#) * #currentd#)>
													#helperObj.GetNumberFormat(currentBudgetMtd, true)#				
													<cfset budgetMtdTotal = budgetMtdTotal + currentBudgetMtd>
												</cfif>
											</font>
										</td>		
										<td colspan=1 align="right" bgcolor="#varianceCellColor#">
											<cfset currentVarianceMtd = (currentBudgetMtd - MtdActuals.mAmount[MtdActuals.CurrentRow])>
											<font size=-1 color=<cfif currentVarianceMtd lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.GetNumberFormat(currentVarianceMtd, true)#				
											<cfset varianceMtdTotal = varianceMtdTotal + currentVarianceMtd>
										</font>
										</td>		
										<cfif currentd lt currentDim>
											<td colspan=1 align="right" bgcolor="#budgetCellColor#">
												<font size=-1>
													<cfif MtdActuals.CurrentRow eq 1>
														<cfset currentCensus = #helperObj.FetchTenantsForDay(dsCensusDetails, currentD)#>
														<cfset censusDim = ((#currentDim# - #currentD#) * (#currentCensus#)) + #censusMtd#>
														<cfset currentBudgetTotal = (#censusDim# * #foodBudgetAccumulator#)>
														#helperObj.GetNumberFormat(currentBudgetTotal, true)#				
														<cfset budgetTotal = budgetTotal + currentBudgetTotal>
													<cfelse>
														<cfset currentBudgetTotal = dsBudgetSummary.mAmount>
														#helperObj.GetNumberFormat(currentBudgetTotal, true)#				
														<cfset budgetTotal = budgetTotal + currentBudgetTotal>
													</cfif>
												</font>
											</td>		
											<td colspan=1 align="right" bgcolor="#varianceCellColor#">
												<cfset currentVarianceTotal = (currentBudgetTotal - MtdActuals.mAmount[MtdActuals.CurrentRow])>
												<font size=-1 color=<cfif currentVarianceTotal lt 0>"Red"<cfelse>"Black"</cfif>>
													#helperObj.GetNumberFormat(currentVarianceTotal, true)#				
													<cfset varianceTotal = varianceTotal + currentVarianceTotal>
												</font>
											</td>								
										</cfif>
									</tr>
									<tr>
										<td colspan=1 align="right" style="font-weight: bold" bgcolor="#secondaryCellColor#">
											<font size=-1>
												Total
											</font>
										</td>
										<td colspan=1 align="right" style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
											<font size=-1>
												#helperObj.GetNumberFormat(actualsTotal, true)#
											</font>
										</td>
										<td colspan=1 align="right" style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
											<font size=-1>
												#helperObj.GetNumberFormat(budgetMtdTotal, true)#				
											</font>
										</td>		
										<td colspan=1 align="right" style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
											<font size=-1 color=<cfif varianceMtdTotal lt 0>"Red"<cfelse>"Black"</cfif>>
												#helperObj.GetNumberFormat(varianceMtdTotal, true)#				
											</font>
										</td>		
										<cfif currentd lt currentDim>
											<td colspan=1 align="right" style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
												<font size=-1>
													#helperObj.GetNumberFormat(budgetTotal, true)#				
												</font>
											</td>		
											<td colspan=1 align="right" style="font-weight: bold" bgcolor="#dashboardTotalCellColor#">
												<font size=-1 color=<cfif varianceTotal lt 0>"Red"<cfelse>"Black"</cfif>>
													#helperObj.GetNumberFormat(varianceTotal, true)#				
												</font>
											</td>	
										</cfif>
									</tr>
								</cfif>
							</cfif>
						</cfif>
						</cfloop>
					</cfloop>
				</cfif>	
				</td>
				</tr>
			</table>--->
		</body>
	</cfoutput>
</html>