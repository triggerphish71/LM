<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>CensusMonthlyReport Excel Download</title>
</head>
<!--- <cfdump var="#form#">
  <cfabort> --->
<cfsetting requesttimeout="11000">
<cfparam name="prompt0" default="">
<cfparam name="prompt1" default="">
<cfparam name="restypAll" default="">
<cfparam name="restypPriv" default="">
<cfparam name="restypMed" default="">
<cfparam name="restypResp" default="">

<cfif IsDefined('form.restypAll') and  form.restypAll is not ''>
	<cfset restypAll = form.restypAll>
<cfelse>
	<cfset restypAll = 'null'>
</cfif>

<cfif IsDefined('form.restypPriv') and  form.restypPriv is not ''>
	<cfset restypPriv = form.restypPriv>
<cfelse>
	<cfset restypPriv = 'null'>
</cfif>

<cfif IsDefined('form.restypMed') and  form.restypMed is not ''>
	<cfset restypMed = form.restypMed>
<cfelse>
	<cfset restypMed = 'null'>
</cfif>

<cfif IsDefined('form.restypResp') and  form.restypResp is not ''>
	<cfset restypResp = form.restypResp>
<cfelse>
	<cfset restypResp = 'null'>
</cfif>
<cfif  IsDefined('restypResp') and  restypResp is  'null' 
		and  IsDefined('restypMed') and  restypMed is   'null'
		and  IsDefined('restypPriv') and  restypPriv is   'null'
		and IsDefined('restypAll') and  restypAll is   'null'>
 	<cfset restypAll = 'All'>
 </cfif>
 
<cfset prompt1 = form.CensusMonth>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID  

	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	<cfif Isdefined("form.selDivision") and form.selDivision is not ''>
		WHERE	r.iregion_id  = #form.selDivision#	
			AND	H.dtrowdeleted is NULL
			AND	H.bisSandbox = 0
	 <cfelseif IsDefined("form.selRegion") and form.selRegion  is not ''>
		WHERE	oa.iopsarea_id   = #form.selRegion#	
			AND	H.dtrowdeleted is NULL
			AND	H.bisSandbox = 0
	<cfelseif IsDefined("form.allHouse") and form.allHouse is 'Yes'>
	where H.dtrowdeleted is NULL
			AND	H.bisSandbox = 0
	<cfelseif IsDefined("selHouse") and selHouse is not ''>
		where 
		h.ihouse_id in (#form.selHouse#)
		and H.dtrowdeleted is NULL
			AND	H.bisSandbox = 0
	<cfelse>
		where 
		h.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
		and H.dtrowdeleted is NULL
			AND	H.bisSandbox = 0	
	</cfif>
</CFQUERY>
<cfset prompt0 = ValueList(Housedata.iHouse_ID)>
<cfset prompt0 = REReplace(prompt0, ",$", "")>  
 
 
<!--- <cfset prompt0 = #HouseData.ihouse_id#> --->
 <cfset ReportDate = dateformat(#now()#,'yyyy-mm-dd') & '-' & timeformat(#now()#,'hh-mm-ss') > 
<!--- <cfoutput> <cfdump var="#form#">
#prompt1#, #prompt0#, #restypAll#, #restypPriv#, #restypMed#, #restypResp#
 </cfoutput>
  <cfabort> --->
<cfquery name="spmonthlycensus" DATASOURCE="#APPLICATION.datasource#">
		EXEC  rw.sp_monthlycensusreportXLS
		@Period = #prompt1#
		,@Scope = '#prompt0#'
		,@restypAll = '#restypAll#'
		,@restypPriv = #restypPriv#
		,@restypMed = #restypMed#
		,@restypResp = #restypResp#

</cfquery>
<cfif spmonthlycensus.recordcount is 0>
	<cfoutput>
		<div style="text-align:center; font-weight:bold; color:##FF0000">
			 There is no information for the time period you requested: #prompt1#<br />
			 OR the Residency type you selected.<br />
			Please select a different time period or Residency Type <br />
			Residency Type(s) Selected:
			<cfif restypAll is not 'null'> All</cfif><br />
			<cfif restypPriv is not 'null'>Private</cfif><br />
			<cfif restypMed is not 'null'> Medicaid</cfif><br />
			<cfif restypResp is not 'null'>Respite</cfif>		
			<A href="CensusMonthlyReportXLSSel.cfm">Return to Monthly Census Download Selection Page</A>
			<cfabort>
		</div>
	</cfoutput>
</cfif>
<cfscript> 
    //Use an absolute path for the files. ---> 
       theDir=GetDirectoryFromPath("\\fs01\ALC_IT\ReportCreation_DEV\CensusMonthlyReport\"); 
    theFile=theDir & "CensusMonthlyReport#ReportDate#.xls"; 
    //Create two empty ColdFusion spreadsheet objects. ---> 
    theSheet = SpreadsheetNew("CensusMonthlyReport"); 
  //  theSecondSheet = SpreadsheetNew("CentersData"); 
    //Populate each object with a query. ---> 
SpreadsheetAddRow(theSheet, "Report Period:,#prompt1#");	
SpreadsheetAddRow(theSheet, 	
"Division,Region,Community,Resident,Residency Type ID,Residency,SLevel,Solomonkey,House Number,Day01,Day02,Day03,Day04,Day06,Day06,Day07,Day08,Day09,Day10,Day11,Day12,Day13,Day14,Day15,Day16,Day17,Day18,Day19,Day20,Day21,Day22,Day23,Day24,Day25,Day26,Day27,Day28,Day29,Day30,Day31,Total,Leave,1st ICD10,2nd ICD10,3rd ICD10,4th ICD10");	
    SpreadsheetAddRows(theSheet,spmonthlycensus); 
 //   SpreadsheetAddRows(theSecondSheet,centers); 
 
</cfscript> 
<body>

 <cfspreadsheet action="write" filename="#theFile#" name="theSheet"  sheetname="CensusMonthlyReport" overwrite="true">


 Done
<cfheader name="Content-Disposition" value="attachment; filename=#theFile#"> 
<cfcontent type="application/vnd.ms-excel" variable="#SpreadsheetReadBinary( theSheet )#">
</body>
</html>
