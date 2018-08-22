<cfset page = "Expense SpendDown">
<cfset Page = "Expense Spend Down">
<cfparam name="errorCaught" default="">
<cftry>

<!------------------------------------------------------------------------------------>
<cfset dtperiod = #dateformat(DateToUse, 'yyyymm')#>

<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html lang="en">
		<head>		    
			<title>
				Online FTA- #page# 
			</title>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
			<cfheader name='expires' value='#Now()#'> 
			<cfheader name='pragma' value='no-cache'>
			<cfheader name='cache-control' value='no-cache,no-store, must-revalidate'>
			<link rel="Stylesheet" href="CSS/ExpenseSpendDown.css" type="text/css">
            
					  <meta charset="utf-8">				 
					  <link rel="stylesheet" href="//code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css">
					  <script src="//code.jquery.com/jquery-1.10.2.js"></script>
					  <script src="//code.jquery.com/ui/1.10.4/jquery-ui.js"></script>
				      <link rel="stylesheet" href="http://jquery.bassistance.de/validate/demo/site-demos.css">							
					  <link rel="stylesheet" href="/resources/demos/style.css">
					 
						  <script>
							  $(function() {
								$( "##datepicker" ).datepicker({startDate: '1m', minDate:"-1M", maxDate: "+1M" });  <!--- MAsk for 1 month:  datepicker({ minDate: -2, maxDate: "+1M" })--->
							  });	
							 							 					  
						  </script>				
				 
				<!---<p>Date: <input type="text" id="datepicker"></p>				 
				</body>
				</html>--->
			
			<!--- Instantiate the Helper object. --->
			<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
			<!---<cfset SpenddownObj = createObject("component","Components/SpendDown").New(FTAds, ComshareDS, application.DataSource)>	--->		
			
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
							
	<!--- field validation script --->		  
<!---<script language="JavaScript" type="text/javascript">
  		function validate()
			{    
				if(document.NewSpendEntry.dropdown_acct.value == "")
				{    
					document.NewSpendEntry.dropdown_acct.style.background = 'Yellow';
					document.NewSpendEntry.dropdown_acct.focus();
					alert("Please Select valid description from the Drop Down List to proceed!");
					document.NewSpendEntry.dropdown_acct.style.background = '';
					return false;
				}				
				if(document.NewSpendEntry.amount.value == "" || document.NewSpendEntry.amount.value == 0 || isNaN(document.NewSpendEntry.amount.value))
				{    
					document.NewSpendEntry.amount.style.background = 'Yellow';
					document.NewSpendEntry.amount.focus();
					alert("Please Enter valid Amount to proceed!");
					return false;
				}
				
				if(document.NewSpendEntry.datepicker.value == "" || document.NewSpendEntry.datepicker.value == 0)
				{    
					document.NewSpendEntry.datepicker.style.background = 'Yellow';
					document.NewSpendEntry.datepicker.focus();
					alert("Please Enter valid date to proceed!");
					return false;
				}
				if(document.NewSpendEntry.notes.value == "")
				{    
					document.NewSpendEntry.notes.style.background = 'Yellow';
					document.NewSpendEntry.notes.focus();
					alert("Please Enter valid text to proceed!");
					return false;
				}
				
			}	
   </script>--->
  
<script type="text/javascript">
//alert("hello your here!");
function validate() {
        var len = document.getElementById("radio").selectedIndex;
		//alert("hello your here!");
        //var len = document.drill.Radio.length;
		for (i=0; i<len; i++) {
		
		alert("hello your here inside 2!");
			if (document.drill.Radio[i].checked == true) {
			   alert(document.drill.Radio[i].value);
			}
			   alert("PLZ select valid select button");
			}
		}   
</script>
	
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
	<cfinclude template="DisplayFiles/Header.cfm">
	<cfif rollup is 0>		
		<cfset dailyCensusBudget = #helperObj.FetchDailyCensusBudget(houseId, currenty, monthforqueries)#>
	</cfif>	     
</cfoutput> 

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
  
<cfif rollup is 0>
  <script language="JavaScript" type="text/javascript">
  		function validation()
			{    
				if(document.NewSpendEntry.dropdown_acct.value == "")
				{    
					document.NewSpendEntry.dropdown_acct.style.background = 'Yellow';
					document.NewSpendEntry.dropdown_acct.focus();
					alert("Please Select valid description from the Drop Down List to proceed!");
					document.NewSpendEntry.dropdown_acct.style.background = '';
					return false;
				}				
				if(document.NewSpendEntry.amount.value == "" || document.NewSpendEntry.amount.value == 0 || isNaN(document.NewSpendEntry.amount.value))
				{    
					document.NewSpendEntry.amount.style.background = 'Yellow';
					document.NewSpendEntry.amount.focus();
					alert("Please Enter valid Amount to proceed!");
					return false;
				}					
				if(document.NewSpendEntry.datepicker.value == "" || document.NewSpendEntry.datepicker.value == 0)
				{    
					document.NewSpendEntry.datepicker.style.background = 'Yellow';
					document.NewSpendEntry.datepicker.focus();
					alert("Please Enter valid date to proceed!");
					return false;
				}
				if(document.NewSpendEntry.notes.value == "")
				{    
					document.NewSpendEntry.notes.style.background = 'Yellow';
					document.NewSpendEntry.notes.focus();
					alert("Please Enter valid text to proceed!");
					return false;
				}
				
			}	
   </script>
   
		<cfif dtperiod eq period2month or dtperiod lt period2month>
		<cfelse>
		<cfif isdefined('form.submit')> 
		  <cfif form.DROPDOWN_ACCT eq '' OR form.AMOUNT eq '' OR form.DROPDOWN_ACCT eq 'null' OR form.AMOUNT eq 'null'>
				<!---<b><font color="red">Please enter valid data in the columns..</font></b>--->
			<cfelse>
			<cfquery name="chknewentry" datasource="FTA">
			SELECT iHouseid,cAccountNum,cAmount,dtTransactionDate,cCreatedUser,cNotes,cperiod,dtcreatedate
			 FROM Spenddown
			 WHERE iHouseid = #iHouseID# AND cAccountNum = #form.DROPDOWN_ACCT# and cAmount = '#form.AMOUNT#' and cCreatedUser= '#session.username#'
				and cNotes = '#form.Notes#' and cperiod= '#form.dtperiod#'
			</cfquery>
			
				<cfif chknewentry.iHouseid eq #iHouseID# AND chknewentry.cAccountNum eq #form.DROPDOWN_ACCT# 
				AND chknewentry.cAmount eq #form.AMOUNT# AND chknewentry.cNotes eq #form.Notes#>
				   <!--- <font color="##CC00CC"><b>Please enter valid information..</b></font>--->
				<cfelse>
					<cfif chknewentry.recordcount EQ 0>
						<cfquery name="SpendDownInfo1" datasource="FTA">
						INSERT INTO Spenddown (iHouseid,cAccountNum,cAmount,dtTransactionDate,cCreatedUser,cNotes,cperiod,dtcreatedate) 
												   VALUES(#iHouseID#,#form.DROPDOWN_ACCT#,#form.AMOUNT#,'#form.datepicker#','#session.username#','#form.Notes#','#form.dtperiod#',getdate())				
						</cfquery>
				   </cfif>
				</cfif>
			</cfif>
		</cfif>
		</cfif>

			<cfquery name="SpendDownInfo" datasource="FTA">
			Select * from SpendDownCategoryDetails 
		    where  iHouseId= #iHouse_ID# and cperiod = '#dtperiod#' and dtRowDeleted is null	 
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
		
		<cfif dtperiod eq period2month or dtperiod lt period2month>
		<cfelse>
		<form name="NewSpendEntry" id="NewSpendEntry" action="#CGI.SCRIPT_NAME#" method="post" onSubmit="return(validation());">   <!--- action="<cfoutput>#CGI.SCRIPT_NAME#</cfoutput>" --->
				<div id="NewSpendEntry">
				<table id="tbls"  border="1px" width="20" height="5">
					<tr>
					<tr bgcolor="##3333CC">
						<td><font size=-1 color="White">New Entry:</td>
						<td><font size=-1 color="White">Amount </td>  
						<td><font size=-1 color="White">Date</td>
						<td><font size=-1 color="White">Notes</td>
					</tr>
					<tr><cfoutput>
						<td>
						<select name="dropdown_acct" id="dropdown_acct">
							   <option value=""> -- Select Account Type -- </option>
							<cfloop query="SpendDownInfo">		
							   <option value="#SpendDownInfo.Acct#" >#SpendDownInfo.Acct# - #SpendDownInfo.cDescription#</option>
							</cfloop>
						</select>				
						</td>
						<!---<input type="text" name="newentry" value="">--->
						<td><input type="text" id="amount" name="amount" value=""></td>
						<td><input type="text" id="datepicker" name="datepicker"></td>
						<td><input type="text" id="notes" name="notes" value=""></td>
										
						<input type="hidden" name="iHouseId" value="#iHouse_ID#"> 
						<input type="hidden" name="subAccount" value="#subAccount#">
						<input type="hidden" name="dtperiod" value="#dtperiod#">
						<td> <input type="submit" name="submit" value="Submit"></td>   <!--- onmouseover="return validation();" --->
						</cfoutput>
					</tr>
					
					</tr>
				</table></div>
		</form>
		</cfif>
</cfif>
<cfoutput>
<cfset dtperiod = #dateformat(DateToUse, 'yyyymm')#>

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
			<cfset regionIds = 	#ValueList(dsGetRegion.iOPSArea_ID)#>
			<cfset dsRegionInfo = #helperObj.FetchRegionInfo(RegionID)#>
	</cfif>
   
	
	<cfquery name="RegionHouse" datasource="FTA">
	 SELECT * from dbo.vw_House 
	   WHERE  iOPSArea_ID <cfif rollup is 2> in(#regionIds#) <cfelse> = #dsRegionInfo.Regionid# </cfif>
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
		WHERE  sdcd.cperiod = '#dtperiod#' AND sdcd.iHouseId in (#houselist#) AND sdcd.dtRowDeleted is null and sda.cdeleteduser is null) A
				GROUP BY A.acct,A.cDescription, A.cperiod,A.cCategorytype,cPRD
	</cfquery>
	<cfoutput>
	<cfset columnCount = #SpendDownInforoll.recordcount#>
	<cfset totalColCount = #columncount# + 5>  
	</cfoutput>
<cfelse>
	<cfquery name="SpendDownInfo" datasource="FTA">
	 <!---Select * from SpendDownCategoryDetails 
	  where  iHouseId= #iHouse_ID# and cperiod = '#dtperiod#' and dtRowDeleted is null--->
	  SELECT spcd.*,spa.cprd as cPRD,spa.cprm as cPRM FROM SpendDownCategoryDetails spcd
         left join spenddownadj SPA   ON SPA.cacctid = spcd.acct and spa.ihouseid = spcd.ihouseid AND '#dtperiod#' between spa.cperiod and spa.endperiod
		    AND  spcd.cperiod <> spa.endperiod AND SPA.dtRowDeleted is null
	        WHERE spcd.iHouseId= #iHouse_ID# AND spcd.cperiod = '#dtperiod#' AND spcd.dtRowDeleted is null 
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
			Select * from SpendDownCategoryDetails 
		    where  iHouseId in (#houselist#) and cperiod = '#dtperiod#' and dtRowDeleted is null	 
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
				<td align="Middle" colspan="1" ><font size=-1>&nbsp;#dtDaysinmonth#	&nbsp;</font></td>
			</tr>
			<tr bgcolor="##E6E6E6">
				<td align="right" colspan=1 ><font size=-1>Projected Resident Days in Month:</font>	</td>
				<td align="Middle" colspan="1">	<font size=-1>#monthcensus# </font></td>
			</tr>	
		</table> 		
	</cfoutput>
</cfif>

<!---<cfinvoke component="components.Spenddown"	method="retrievespend"	returnvariable="allspend"></cfinvoke>--->
<form name="Spenddown" action="#CGI.SCRIPT_NAME#" method="post">
<cfoutput>
<!--
<cfif rollup is 0>
<td align="right"><font face="Arial, Helvetica" size="-1" color="##000000"><a href="SpendDown_Admin.cfm?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>iHouse_ID=#iHouse_ID#&SubAccount=#subAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>" title="Administration"><b>SpendDown Admin</b> <img title="SpendDown_Admin" src="Images/FTadministration.jpg" height="30px" width="30px"/></a></font></td>
</cfif>
-->
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<cfif rollup is not 0>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</cfif>

<cfif rollup is not 0>
 <cfif rollup is 2>
 <td align="right"><font face="Arial, Helvetica" size="-1" color="##000000"><a href="SpendDown_Excel.cfm?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=0&rollup=2&Division_ID=#DivisionID#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>" title="Export to Excel file"><b>Export to Excel file </b><img title="Export to Excel" src="Images/ExcelBig.bmp" height="30px" width="30px"/></a></font></td>
</cfif>
<cfif rollup is 3>
<td align="right"><font face="Arial, Helvetica" size="-1" color="##000000"><a href="SpendDown_Excel.cfm?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=0&rollup=3&Division_ID=#divisionId#&Region_ID=#regionId#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>" title="Export to Excel file"><b>Export to Excel file </b><img title="Export to Excel" src="Images/ExcelBig.bmp" height="30px" width="30px"/></a></font></td>
</cfif>
<cfelse>
<td align="right"><font face="Arial, Helvetica" size="-1" color="##000000"><a href="SpendDown_Excel.cfm?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>iHouse_ID=#iHouse_ID#&SubAccount=#subAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>" title="Export to Excel file">
<b>Export to Excel file</b> <img title="Export to Excel" src="Images/ExcelBig.bmp" height="30px" width="30px"/></a></font></td>
</cfif>
</cfoutput>
		<table id="tbl" cellspacing="0" cellpadding="1" border="1px" style="width:100px">		
				<tr bgcolor="##3333CC">
					  <td width="60"><font size=-1 color="White">Account</font></td>
					  <td width="250"><font size=-1 color="White">Description</font></td>
					  <td width="120"><font size=-1 color="White">PRD</font></td>
					  <td width="120"><font size=-1 color="White">$$/Month</font></td>
					  <td width="120"><font size=-1 color="White">Budget</font></td>
					  <td width="120"><font size=-1 color="White">Actual</font></td>
					  <td width="120"><font size=-1 color="White">Balance</font></td>					  
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
         <cfoutput query="SpendDownInforoll">
								
				<cfquery name="drilldown" datasource="FTA">
					SELECT   * From dbo.Spenddown 
					WHERE cperiod = '#dtperiod#' AND iHouseId in (#houselist#) AND cAccountnum = #SpendDownInforoll.Acct# AND dtrowdeleted is null					  				   
				</cfquery>
				<cfif drilldown.Recordcount gt 0>
					<cfquery name="DrillAmount" datasource="FTA">
						SELECT  IsNull(SUM(cAmount),0) as cAmount From dbo.Spenddown 
						WHERE iHouseId in (#houselist#) AND cperiod = '#dtperiod#' AND cAccountnum = #SpendDownInforoll.Acct# AND dtrowdeleted is null												 				   
					</cfquery>					
				</cfif>
				 <TR BGCOLOR="###IIF(SpendDownInforoll.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#" id="Parent#SpendDownInforoll.currentrow#" onClick="toggle('Child#SpendDownInforoll.currentrow#')">
						<!---<input type="hidden" name="iSpenddownAcctId" value="#iSpenddownAcctId#">--->						
						
						<td align="right">
							<div align="right">
								<cfif drilldown.Recordcount Is Not "0">
									<cfset imageId = "imgDrillDown_" & #Acct#>
									<img id="#imageId#" onClick="showHideRow('#Acct#');" src="../FTA/Images/caretlightblue.png" style="cursor:hand;" border=0>
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
				   <cfset drillDownColSpan = #totalColCount# - 1>
					<!--- Current Account Drilldown information --->
					<cfif drilldown.RecordCount IS NOT "0">
						<cfset rowId = "DrillDown_" & #Acct#>
						<cfset columnA = "##FFE7CE">
						<cfset columnB = "##FFFFE8">
		
						<tr id="#rowId#" style="display:none;">
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
											SELECT iHouse_id,cname,cGLSubAccount From dbo.vw_House
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
													<a href="ExpenseSpendDown.cfm?Role=0&<cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>iHouse_ID=#DrillHouse.iHouse_ID#&SubAccount=#DrillHouse.cGLSubAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>" title="House">#DrillHouse.cname#</a>
												</font>
											</td>											
										</tr>											
									</cfloop> 																			                  									
								</table>
								</cfform>								
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
					<!--- END Dropdown--->
				</cfoutput>
				
				<tr><td>&nbsp;</td></tr>
				<tr><td colspan="7" align="center"></td>
			 </tr>
			 <cfoutput>			   
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
			    <input type="hidden" name="iHouseId" value="#iHouse_ID#"> 
				<input type="hidden" name="subAccount" value="#subAccount#">
			</cfoutput>	 	
<cfelse>
				<!--- STRAT result set table for display --->
				<cfoutput query="SpendDownInfo">
								
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
					 <TR BGCOLOR="###IIF(SpendDownInfo.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#" id="Parent#SpendDownInfo.currentrow#" onClick="toggle('Child#SpendDownInfo.currentrow#')">
						<!---<input type="hidden" name="iSpenddownAcctId" value="#iSpenddownAcctId#">--->						
						
						<td align="right">
							<div align="right">
								<cfif drilldown.Recordcount Is Not "0">
									<cfset imageId = "imgDrillDown_" & #Acct#>
									<img id="#imageId#" onClick="showHideRow('#Acct#');" src="../FTA/Images/caretlightblue.png" style="cursor:hand;" border=0>
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
				  
				   <!--- START dropdown here--->
				   <cfset drillDownColSpan = #totalColCount# - 1>
					<!--- Current Account Drilldown information --->
					<cfif drilldown.RecordCount IS NOT "0">
						<cfset rowId = "DrillDown_" & #Acct#>
						<cfset columnA = "##FFE7CE">
						<cfset columnB = "##FFFFE8">
		
						<tr id="#rowId#" style="display:none;">
							<td class="locked" colspan="1" bgcolor="f4f4f4">
								&##160;
							</td>
							<td align="left" colspan="#drillDownColSpan#">
							
							<cfif not isDefined("FORM.submit1") or isDefined("FORM.submit1") neq 1>
							<cfelse> 
							<cfparam name="form.radio" default="0">
								<cfif isDefined(form.radio) or (form.radio) neq 0>
									<!---<cfelse> <b style="background-color:##FF0055">plz select radio button to proceed!...</b>--->
									 <cfquery name="SpendDownInfo1" datasource="FTA">
										UPDATE Spenddown 
										  SET dtrowdeleted = getdate()
										  WHERE iSpenddownId = #form.radio#										 				
									 </cfquery>
								 </cfif>							   
							 </cfif>  							
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
										<cfif dtperiod eq period2month or dtperiod lt period2month>
                                        <cfelse>
										<td align="Middle" bgcolor="#columnB#" class="bottomBorder" width="200">
											<font size=-1>
												Delete  
											</font>
										</td>
										</cfif>											
									</tr>
																		
									<cfloop query="drilldown">	
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
												  <cfif dtperiod eq period2month or dtperiod lt period2month>
                                    			  <cfelse>
													<cfinput type="radio" name="radio" id="the-terms" value="#drilldown.iSpenddownId#"> 
												  </cfif>
												</font>
											</td>																															
											<!---<td><input type="button" value="Delete"></td>--->		
										</tr>											
									</cfloop> <td></td><td></td><td></td><td></td>
									<td align="right">
									<cfif dtperiod eq period2month or dtperiod lt period2month>
                                    <cfelse>
										<cfinput type="submit" name="submit1" value="Delete" style="background-color:##C0C0C0" onMouseOver="return(validate());">
									</cfif>
										
									</td>	                  									
								</table>
								</cfform>								
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
					<!--- END Dropdown--->
				</cfoutput>
				
				<tr><td>&nbsp;</td></tr>
				<tr><td colspan="7" align="center"></td>
			 </tr>
			 <cfoutput>			   
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
			    <input type="hidden" name="iHouseId" value="#iHouse_ID#"> 
				<input type="hidden" name="subAccount" value="#subAccount#">
			</cfoutput>	 
</cfif>
		</table> <!---<input type="submit" value="Submit">--->
		
</form>
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