<cfset page = "Expense SpendDown">
<cfset Page = "Expense Spend Down">
<cfparam name="errorCaught" default="">
<cftry>

<!------------------------------------------------------------------------------------>
<!---<cfset dtperiod = #dateformat(DateToUse, 'yyyymm')#>--->

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
							
	<script language="JavaScript" type="text/javascript">
  		function validate()
			{  						
			if(document.UpdateAcct.OldPRM.value != null && isNaN(document.UpdateAcct.Up_cPRM.value) || document.UpdateAcct.Up_cPRM.value == '') 
				{   				
					document.UpdateAcct.Up_cPRM.style.background = 'Yellow';					
					document.UpdateAcct.Up_cPRM.focus();
					alert("Please Enter valid Amount to proceed!");
					return false;					
				}
			 								
			if(document.UpdateAcct.OldPRD.value != null && isNaN(document.UpdateAcct.Up_cPRD.value) || document.UpdateAcct.Up_cPRD.value == '')
				{     
					document.UpdateAcct.Up_cPRD.style.background = 'Yellow';
					document.UpdateAcct.Up_cPRD.focus();
					alert("Please Enter valid Amount in PRD to proceed!");
					return false;
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
		<cfset dailyCensusBudget = #helperObj.FetchDailyCensusBudget(houseId, currenty, monthforqueries)#>     
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


		<!--- check for duplicate form submissions ---> 
<!---<cfif #form.submissionCheck# EQ "submitted">
Geezo have some patients, you already submitted the form!
</cfif>--->
	<cfif isDefined('form.submit')>	
	 <cfif !isdefined('form.divisionid')> <cfset form.divisionid = 0 >
	 </cfif>
	 <cfif !isdefined('form.regionid')> <cfset form.regionid = 0 >
	 </cfif>
	 <cfif (form.divisionid eq '' or form.divisionid eq 0) AND (form.regionid eq '' or form.regionid eq 0)>
			<cfquery name="AdjustSelect" datasource="FTA">
				SELECT * FROM SpenddownAdj 
				 WHERE iHouseid = #iHouseID# AND cAcctId = #form.Acct#  AND dtRowDeleted is null  <!--- AND cPeriod = '#form.dtperiod#' --->			   		
			</cfquery>
			<cfset  endperiod = #dateformat(DateToUse, 'yyyy')#>
			<cfif isDefined('form.Up_cPRD') AND form.Up_cPRD neq '' AND form.oldPRD neq form.Up_cPRD >		
				<cfif AdjustSelect.RecordCount gt 0> 
				<!---<cfif AdjustSelect.iHouseID eq iHouseID AND AdjustSelect.Acct eq form.Acct AND AdjustSelect.cperiod eq form.dtperiod AND AdjustSelect.cPRD eq form.Up_cPRD>--->				
					<cfquery name="AdjDelete" datasource="FTA">
						Update SpenddownAdj SET <cfif form.dtPeriod eq AdjustSelect.cperiod> dtRowDeleted = getdate()<cfelse> endperiod = '#form.dtperiod#' </cfif>,  cDeletedUser = '#session.username#'
						  WHERE iSpenddownAdjId = #AdjustSelect.iSpenddownAdjId# AND iHouseid = #AdjustSelect.iHouseID# AND cAcctId = #AdjustSelect.cAcctId# 
						   <cfif form.dtPeriod eq AdjustSelect.cperiod> AND cPeriod = '#AdjustSelect.cperiod#' </cfif> 							
					</cfquery>
				</cfif>  <cfoutput>  <cfset new_cPRD = #form.Up_cPRD# *(#helperObj.GetNumberFormat(dailyCensusBudget, false)# * #dtDaysinmonth#)>  </cfoutput>
				<cfquery name="AdjustInsert" datasource="FTA">
					INSERT INTO SpenddownAdj (iHouseid,cAcctId,cDescription,cPRD,cPRM,cPeriod,dtCreateDate,cCreatedUser,cDeletedUser,dtRowDeleted,endperiod) 
					   VALUES(#iHouseID#,#form.Acct#,'#form.cDescription#',#form.Up_cPRD#,#new_cPRD#,'#form.dtperiod#',getdate(),'#session.username#',null,null,#endperiod#12)				
				</cfquery>		
			</cfif>
			<cfset  endperiod = #dateformat(DateToUse, 'yyyy')#> 
			<cfif isDefined('form.Up_cPRM') AND form.Up_cPRM neq '' AND form.oldPRM neq form.Up_cPRM >		
				 <cfif AdjustSelect.RecordCount gt 0>
				 <!---<cfif AdjustSelect.iHouseID eq iHouseID AND AdjustSelect.Acct eq form.Acct AND AdjustSelect.cperiod eq form.dtperiod AND AdjustSelect.cPRM eq form.Up_cPRM>--->
					<cfquery name="AdjDelete" datasource="FTA">
						Update SpenddownAdj SET <cfif form.dtPeriod eq AdjustSelect.cperiod> dtRowDeleted = getdate()<cfelse> endperiod = '#form.dtperiod#' </cfif>,  cDeletedUser = '#session.username#'
						  WHERE iSpenddownAdjId = #AdjustSelect.iSpenddownAdjId# AND iHouseid = #AdjustSelect.iHouseID# AND cAcctId = #AdjustSelect.cAcctId# 
						 <cfif form.dtPeriod eq AdjustSelect.cperiod> AND cPeriod = '#AdjustSelect.cperiod#' </cfif> 					
					</cfquery>
				</cfif>
				<cfquery name="AdjustInsert" datasource="FTA">
					INSERT INTO SpenddownAdj (iHouseid,cAcctId,cDescription,cPRD,cPRM,cPeriod,dtCreateDate,cCreatedUser,cDeletedUser,dtRowDeleted,endperiod) 
					   VALUES(#iHouseID#,#form.Acct#,'#form.cDescription#',null,#form.Up_cPRM#,'#form.dtperiod#',getdate(),'#session.username#',null,null,#endperiod#12)				
				</cfquery>		 
			</cfif> 
	  <cfelse>
			<cfquery name="div_reg_houseid" datasource="FTA">
			 SELECT r.cname as Division,r.iRegion_id as divisionId, oa.cname as region,oa.iOpsArea_id as regionid, h.cname,h.iHouse_id as Houseid
			  FROM dbo.vw_Region R
			    JOIN dbo.vw_OpsArea oa on r.iregion_id = oa.iregion_id AND oa.dtrowdeleted is null
			    JOIN dbo.vw_House h on oa.iOpsArea_id = h.iOpsArea_id AND h.dtrowdeleted is null
			  WHERE  <cfif form.divisionid eq '' OR form.divisionid eq 0> oa.iOpsArea_id = #form.regionid# <cfelse> r.iRegion_id = #form.Divisionid# </cfif> 
			</cfquery>
	       <cfset houselist = #ValueList(div_reg_houseid.houseid)#>
		  
		   <cfquery name="AdjustSelect" datasource="FTA">
				SELECT * FROM SpenddownAdj 
				 WHERE iHouseid IN(#houselist#) AND cAcctId = #form.Acct#  AND dtRowDeleted is null  <!--- AND cPeriod = '#form.dtperiod#' --->			   		
			</cfquery>
			<cfif AdjustSelect.RecordCount gt 0> 
			   <cfquery name="Div_reg_AdjDelete" datasource="FTA">
					Update SpenddownAdj SET <cfif form.dtPeriod eq AdjustSelect.cperiod> dtRowDeleted = getdate()<cfelse> endperiod = '#form.dtperiod#' </cfif>,  cDeletedUser = '#session.username#'
					  WHERE iHouseid IN(#houselist#) AND cAcctId = #AdjustSelect.cAcctId# AND cPeriod = '#AdjustSelect.cperiod#' 							
				</cfquery>
			</cfif>
			 <cfoutput> <cfif form.Up_cPRD neq ''> <cfset new_cPRD = #form.Up_cPRD# *(#helperObj.GetNumberFormat(dailyCensusBudget, false)# * #dtDaysinmonth#)> </cfif>
			<!--- PRD new = #form.Up_cPRD#   -- census = #helperObj.GetNumberFormat(dailyCensusBudget, false)# --- days in month = #dtDaysinmonth# <br/>
			 House List = #houselist# <br/>
			  Acct = #form.Acct#  -  #form.cDescription#<br/>	 cPeriod = '#form.dtperiod#' <br/> PRD = #form.Up_cPRD#  <br/> 
			  <cfif !isdefined('form.Up_cPRM')> <cfset form.Up_cPRM = 'null'> PRM = #form.Up_cPRM#
	             </cfif>  --->  
			  </cfoutput>	
			  	
			<cfquery name="div_reg_Insert" datasource="FTA">			
			 INSERT INTO SpenddownAdj (iHouseid,cAcctId,cDescription,cPRD,cPRM,cPeriod,dtCreateDate,cCreatedUser,cDeletedUser,dtRowDeleted,Endperiod)			
			   SELECT iHouseid,Acct,cDescription,<cfif form.Up_cPRD neq ''>#form.Up_cPRD# as PRD <cfelse> null as PRD</cfif>, 
			      <cfif isDefined('form.Up_cPRM') AND form.Up_cPRM neq ''> #form.Up_cPRM# as PRM<cfelse> <cfif form.Up_cPRD neq ''>#new_cPRD#<cfelse>null as PRM</cfif></cfif>, cPeriod, getdate() as dtCreateDate, '#session.username#' as cCreatedUser, null, null , (fiscyr+''+'12') as Endperiod
			     FROM SpendDownCategoryDetails
				 WHERE ihouseid IN(#houselist#) AND Acct = #form.Acct# AND cPeriod = '#form.dtperiod#'
			</cfquery>
			 <cfoutput> Successfully Updated #form.cDescription# Amount.</cfoutput> 
	  </cfif>
	</cfif>
		

		<cfquery name="SpendDownInfo" datasource="FTA">
			 SELECT spcd.*,spa.cprd as cPRD,spa.cprm as cPRM FROM SpendDownCategoryDetails spcd
         left join spenddownadj SPA   on SPA.cacctid = spcd.acct and spa.ihouseid = spcd.ihouseid and spcd.cperiod = spa.cperiod
	        WHERE  spcd.iHouseId= #iHouse_ID# and spcd.cperiod = '#dtperiod#' and spcd.dtRowDeleted is null AND SPA.dtRowDeleted is null 
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
		
	</cfoutput>
		
		
<!---</cfif>--->
<cfoutput>
<cfset dtperiod = #dateformat(DateToUse, 'yyyymm')#>
	
	<!---<cfquery name="SpendDownInfo" datasource="FTA">
	 SELECT spcd.*,spa.cprd as cPRD,spa.cprm as cPRM FROM SpendDownCategoryDetails spcd
         left join spenddownadj SPA   on SPA.cacctid = spcd.acct and spa.ihouseid = spcd.ihouseid and spcd.cperiod = spa.cperiod
	        WHERE  spcd.iHouseId= #iHouse_ID# and spcd.cperiod = '#dtperiod#' and spcd.dtRowDeleted is null AND SPA.dtRowDeleted is null
	</cfquery>	--->	

</cfoutput>

<!---<CFSILENT>

<!---<cfinvoke component="components.Spenddown"	method="retrievespend"	returnvariable="allspend"></cfinvoke>--->
<form name="Spenddown" action="#CGI.SCRIPT_NAME#" method="post">
		<table id="tbl" cellspacing="0" cellpadding="1" border="1px" style="width:100px">		
				<tr bgcolor="##3333CC">				      
					  <td width="60"><font size=-1 color="White">Account</font></td>
					  <td width="250"><font size=-1 color="White">Description</font></td>
					  <td width="150"><font size=-1 color="White">PRD</font></td>
					  <td width="200"><font size=-1 color="White">$$/Month</font></td>
					 				  
				</tr>
				
				<!--- STRAT result set table for display --->
				<cfoutput query="SpendDownInfo">					
				
					 <TR BGCOLOR="###IIF(SpendDownInfo.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#" >
						
						<td align="right">
							<div align="right">
								#Acct# 
							</div>
							<input type="hidden" name="acct" value="#Acct#">
						</td>						
						<td>
							<div>
							   &nbsp;&nbsp;#cDescription#
							</div>
							<input type="hidden" name="cDescription" value="#cDescription#">
						</td>						
						<td>
							 <div>
								<cfif cCategoryType eq 'PRD'>  
								 <cfset amounttot = #cAmount#/(#helperObj.GetNumberFormat(dailyCensusBudget, false)# * #dtDaysinmonth#)>									
								    $  &nbsp;&nbsp; #NumberFormat(Amounttot, 0.000)#<input align="right" type="text" name="cPRD_#Acct#" id="cPRD" size="6" value="" >																	
								<cfelse>
									$  <input type="hidden" name="cPRD1" size="4" value="0.00" >
								</cfif>
							</div>
						</td> 
						<td>
								<div>
								<cfif cCategoryType eq 'PRM'>								
									$  &nbsp;&nbsp;#NumberFormat(cAmount, 0.000)# <input align="right" type="text" name="cPRM_#Acct#" id="cPRM" size="10" value="" >	
								<cfelse>
									$ <input type="hidden" name="cPRM1" size="4" value="0.00" >
								</cfif>
							 </div>
						</td>				   							
															
					</tr>				   
				</cfoutput>				
				<tr><td>&nbsp;</td></tr>
				<tr><td colspan="7" align="center"></td>
			 </tr>
			 <cfoutput>			
				 <input type="hidden" name="iHouseId" value="#iHouse_ID#"> 
				 <input type="hidden" name="subAccount" value="#subAccount#">
				 <input type="hidden" name="dtperiod" value="#dtperiod#">
			</cfoutput>			
		</table> 
		
		<div align="center"><input type="submit" name="submit" value="Submit"></div>
		
</form>
</CFSILENT>--->

<cfquery name="SpendDownInfo" datasource="FTA">
	SELECT spcd.*,spa.cprd as cPRD,spa.cprm as cPRM FROM SpendDownCategoryDetails spcd
         left join spenddownadj SPA   on SPA.cacctid = spcd.acct and spa.ihouseid = spcd.ihouseid AND '#dtperiod#' between spa.cperiod and spa.endperiod
		   AND spcd.cperiod <> spa.endperiod
	        WHERE  spcd.iHouseId= #iHouse_ID# and spcd.cperiod = '#dtperiod#' and spcd.dtRowDeleted is null AND SPA.dtRowDeleted is null
</cfquery>
<table><tr>&nbsp;&nbsp;</tr></table>

<cfoutput>
<td>&nbsp;&nbsp;&nbsp;</td><a href="ExpenseSpendDown.cfm?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>iHouse_ID=#iHouse_ID#&SubAccount=#subAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>" title="Go Back"><b>Go Back / Previous Page</b></a>
</cfoutput>
<table><tr>&nbsp;&nbsp;</tr></table>
<table>
	<form name="#CGI.SCRIPT_NAME#" method="post" autocomplete="off">
	<cfoutput>	 
		<table id="tblInfo" width="500px" height="50px"  cellspacing="0" cellpadding="1" border="1px">
		<tr> 
			<td align="right" width="300" bgcolor="##2A3FFF"><font size=3 color="##FFFFFF"><b>Select Modified Account : </b></font></td>
			
			<td>
				<select name="acct_Desc" required="yes" onChange="this.form.submit()">
					<option value=""> -- Select Account -- </option>
					<cfloop query="SpendDownInfo">
					<option value="#Acct#">#Acct# - #cDescription#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		</table> 
	</cfoutput>
	</form>


<cfif structKeyExists(form, "acct_Desc") and form.acct_Desc neq "">	
		 
<cfquery name="display" datasource="FTA">
	 <!---Select * from SpendDownCategoryDetails 
	  where Acct = #form.acct_desc# AND iHouseId= #iHouse_ID# and cperiod = '#dtperiod#' and dtRowDeleted is null--->
	  <!---SELECT spcd.*,spa.cprd as cPRD,spa.cprm as cPRM FROM SpendDownCategoryDetails spcd
         left join spenddownadj SPA   on SPA.cacctid = spcd.acct and spa.ihouseid = spcd.ihouseid and spcd.cperiod = spa.cperiod
	        WHERE spcd.Acct = #form.acct_desc# AND spcd.iHouseId= #iHouse_ID# and spcd.cperiod = '#dtperiod#' and spcd.dtRowDeleted is null AND SPA.dtRowDeleted is null--->
		<!---SELECT acct,cdescription,cperiod,ccategorytype,sum(camountnew) as CAMOUNT,cPRM,cPRD
		FROM ( SELECT sdcd.Acct, sdcd.cDescription, sdcd.cperiod,sdcd.cCategorytype,sdcd.cAmount as cAmount,
				case when cPRM is null 
				then camount
				else CPRM
				end as CAmountNew,
				sda.cPRM,sda.cPRD
			   FROM SpendDownCategoryDetails sdcd
			  left Join dbo.SpenddownAdj sda on sdcd.Acct = sda.cacctid AND sdcd.iHouseId = sda.iHouseId <!---AND sdcd.cperiod = sda.cperiod --->
				 AND sda.dtRowDeleted is null
		WHERE  sdcd.Acct = #form.acct_desc# AND sdcd.cperiod = '#dtperiod#' AND sdcd.iHouseId= #iHouse_ID# AND sdcd.dtRowDeleted is null) A
				GROUP BY A.acct,A.cDescription, A.cperiod,A.cCategorytype,A.cprm,A.cprd--->
		SELECT top 1 acct,cdescription,cperiod,ccategorytype,sum(camountnew) as CAMOUNT,cPRM,cPRD,dtcreatedate
		FROM ( SELECT sdcd.Acct, sdcd.cDescription, sdcd.cperiod,sdcd.cCategorytype,sdcd.cAmount as cAmount,
				case when cPRM is null 
				then camount
				else CPRM
				end as CAmountNew,
				sda.cPRM,sda.cPRD,sda.dtcreatedate
			   FROM SpendDownCategoryDetails sdcd
			  left Join dbo.SpenddownAdj sda on sdcd.Acct = sda.cacctid AND sdcd.iHouseId = sda.iHouseId  
			   AND sdcd.cperiod between sda.cperiod and sda.endperiod
				 AND sda.dtRowDeleted is null  
		WHERE  sdcd.Acct = #form.acct_desc# AND sdcd.cperiod = '#dtperiod#' AND sdcd.iHouseId= #iHouse_ID# AND sdcd.dtRowDeleted is null ) A
				GROUP BY A.acct,A.cDescription, A.cperiod,A.cCategorytype,A.cprm,A.cprd,a.dtcreatedate order by a.dtcreatedate desc		
	</cfquery>	
	<cfquery name="Houses_effect" datasource="FTA">
		select r.cname as Division,r.iRegion_id as divisionId, oa.cname as region,oa.iOpsArea_id as regionid, h.cname as House,h.iHouse_id as HouseId
		  from dbo.vw_Region R
		  Join dbo.vw_OpsArea oa on r.iregion_id = oa.iregion_id and oa.dtrowdeleted is null
		  Join dbo.vw_House h on oa.iOpsArea_id = h.iOpsArea_id AND h.dtrowdeleted is null
		 WHERE h.ihouse_id = #iHouse_ID#
	</cfquery>     
	  
        <form name="UpdateAcct" action="##" method="post" onSubmit="return(validate());" autocomplete="off">
          <div id="UpdateAcct">
		  <cfoutput query="display">  <!---<cfoutput> #cAmount# - #helperObj.GetNumberFormat(dailyCensusBudget, false)# - #dtDaysinmonth# </cfoutput>--->
		  <table id="tblInfo" width="700px" height="50px"  cellspacing="0" cellpadding="1" border="1px">
		     <tr bgcolor="##3333CC">
					  <td width="60"><font size=-1 color="White">Account</font></td>
					  <td width="400"><font size=-1 color="White">Description</font></td>					  
					  <td width="120"><font size=-1 color="White">PRD</font></td>					
					  <td width="120"><font size=-1 color="White">$$/Month</font></td>					 
					  <td width="200"><font size=-1 color="White">&##160;</font></td>					  					  
				</tr>
				<tr bgcolor="C0C0C0">
					<td>
					 	#Acct# 
					</td>
					<td>
						#cDescription#
					</td>
					<td>
					<cfif cCategoryType eq 'PRD'>										
					  <cfif cPRD eq '' or cPRD eq 'null'> 
					   <cfset amounttot = #cAmount#/(#helperObj.GetNumberFormat(dailyCensusBudget, false)# * #dtDaysinmonth#)>
						#NumberFormat(Amounttot, 0.000)# <input type="hidden" name="OldPRD" value="#NumberFormat(Amounttot, 0.000)#">
						<cfelse>
						 #cPRD# <input type="hidden" name="OldPRD" value="#cPRD#">
						</cfif>
					<cfelse>
						&##160;						
					</cfif>
					</td>
					<td>					
					<cfif cCategoryType eq 'PRM'>					
					  <cfif cPRM eq '' or cPRM eq 'null'>
						#camount# <input type="hidden" name="OldPRM" value="#camount#">
					  <cfelse>
						 #cPRM# <input type="hidden" name="OldPRM" value="#cPRM#">
						</cfif>
					<cfelse>
					 	&nbsp;<!---<input type="hidden" name="OldPRM" value="">--->					
					</cfif>
					</td>
					<td> Old Values</td>
				</tr>
				<tr>
					<td>
					#Acct# <input type="hidden" name="Acct"  value="#Acct#">
					</td>
					<td>
					#cDescription# <input type="hidden" name="cDescription" value="#cDescription#">
					</td>					
					<td>
					<cfif cCategoryType eq 'PRD'>					
					   <input type="text" name="Up_cPRD" value="">					  
					<cfelse>
					   &##160;<input type="hidden" name="Up_cPRD" value="">
					</cfif>	
					</td>				
					<td>
					<cfif cCategoryType eq 'PRM'>
						   <input type="text" name="Up_cPRM" value="">					   
					<cfelse>
					   &##160; <!---<input type="hidden" name="Up_cPRM" value="">--->
					</cfif>	
					</td>				
					<td> New Values</td>
				</tr>
				</table>	
	        <tr><table>&nbsp;&nbsp;</table>
	      <table><tr>		
			<td align="right">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>	
						
			 <font> How do you wants to effect the change: </font>
			<tr bgcolor="##FFDFFF">
			<td title="whole #Houses_effect.division# Division will effect this new value!"><input type="checkbox" name="divisionid" value="#Houses_effect.divisionid#"></td>
			 <td title="whole #Houses_effect.division# Division will effect this new value!"> &nbsp;&nbsp;#Houses_effect.division# &nbsp;&nbsp;<br/></td><td>Division</td></tr>
			<tr bgcolor="##FFDFFF">
			<td title="Whole #Houses_effect.region# Region will effect this new value!"><input type="checkbox" name="regionid" value="#Houses_effect.regionid#"></td>
			<td title="Whole #Houses_effect.region# Region will effect this new value!">&nbsp;&nbsp;#Houses_effect.region# &nbsp;&nbsp;<br/></td><td>Region</td></tr>
			<tr bgcolor="##FFDFFF">
			<td title="Only House will effect this new value!"><input type="checkbox" name="houseid" value="#iHouse_ID#"></td>
			<td title="Only House will effect this new value!">&nbsp;&nbsp;#Houses_effect.house# &nbsp;&nbsp;</td><td>House</td></tr>
				
			
			<tr>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			 <input type="hidden" name="iHouseId" value="#iHouse_ID#"> 
			 <input type="hidden" name="subAccount" value="#subAccount#">
			 <input type="hidden" name="dtperiod" value="#dtperiod#">
			</td>
			<tr>&nbsp;</tr>
			<td align="right">			  
				<input type="submit" name="submit" value=" Submit ">
			</td>
			</tr>	   
		   </tr>
		  </table>		        
	</tr></div>	
	</cfoutput>	
    </form>
  
</cfif>
</table>
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

