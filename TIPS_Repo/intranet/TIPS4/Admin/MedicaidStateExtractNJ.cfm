<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>TIPS4 - Medicaid</title>
</head>
<body>
<h1 class="PageTitle"> Tips 4 - Medicaid New Jersey Payment Extract</h1>
 
<CFINCLUDE TEMPLATE="../../header.cfm">
<!--- <CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm"> --->
	<cfparam name="statecode" default="">
	<cfparam name="actperiod" default=""> 
	<cfparam name="acctperiod" default="">

<!--- <cfoutput><cfdump var="#form#" label="form"></cfoutput> --->
 	
	<cfset FinalIndex = 1>
	<cfset FinalArray=arraynew(2)>	
	<cfif statecode is ''>
		<cfset statecode = 'NJ'>
	</cfif>
	<cfif actperiod is ''> 
		<cfset actperiod = dateadd('m', -1, #now()#)>
		<cfset acctperiod = left(trim(#actperiod#),4) & right(trim(#actperiod#),2)>
	<cfelse> 
		<cfset acctperiod = #actperiod#>
	</cfif>
 
	<cfset dtStart = left(trim(#actperiod#),4) & '-' &  right(trim(#actperiod#),2) & '-' &  '01'>
 	<cfset today = #now()#> 
	<cfset firstOfThisMonth = createDate(year(today), month(today), 1)> 
	<cfif dateformat(#now()#, 'yyyymm') is #actperiod#>
		<cfset dtEnd = Year(#now()#) & '-' &  DateFormat(#now()#,"mm") & '-' & daysinmonth(#now()#)> 
	<cfelse>
		<cfset dtEnd = dateAdd("d", -1, #firstOfThisMonth#)> 
	</cfif>
	<cfset dtEOM = Year(#dtEnd#) & '-' &  DateFormat(#dtEnd#,"mm") & '-' & DateFormat(#dtEnd#,"dd")>
	<cfset idaysinMonth = #daysinmonth(actperiod)#>
 	<cfset idaysinMonth = dtEOM - dtStart + 1> 
<!---   <cfoutput>dtStart #dtStart# ::  #left(actperiod,4)# ::
dtEnd #dtEnd#
dtEOM #dtEOM#
firstOfThisMonth #firstOfThisMonth#
acctperiod #acctperiod#
<cfdump var="#form#" label="form"></cfoutput>  --->
	<cfquery name="qState"  datasource="#APPLICATION.datasource#">
		Select cStateName from StateCode where cStateCode = '#statecode#'
	</cfquery>
	<cfquery name="qryMedicaidResidents"  datasource="#APPLICATION.datasource#">
		SELECT  	distinct (dct.iTenant_ID) 
<!--- 			t.clastname + ', ' + t.cfirstname Name
			,h.cname House
			,h.cstatecode StateCode
			,dct.iTenant_ID, t.csolomonkey
			,ts.iresidencytype_id
			,dct.iLeaveStatus_ID
			,convert(varchar(12),dct.Census_Date,101) CensusDate
			,dct.CurrentStatusInBedAtMidnight
			,dct.NoticeOfDischarge
			,convert(varchar(12),TempStatusOutDate,101) TempStatusOutDate
			,convert(varchar(12),TempStatusInDate,101) TempStatusInDate
			,dct.TempWhere
			,dct.DischargeDate --->
		
		FROM [TIPS4].[dbo].[DailyCensusTrack] dct
			join tenant t on dct.itenant_id = t.itenant_id
			join tenantstate ts on t.itenant_id = ts.itenant_id
			join house h on t.ihouse_id = h.ihouse_id
			where census_date between '#dtStart#' and  '#dtEOM#'   
			and h.cstatecode = '#statecode#'
			and ts.iresidencytype_id = 2
		order by itenant_id 
	</cfquery>
	<cfoutput>
<!--- 	<cfdump var="#qryMedicaidResidents#" label="qryMedicaidResidents"> --->
 	<cfloop query="qryMedicaidResidents">
		<cfset thisresident = #iTenant_ID#>
		<cfset dtBegin = #dtStart#>
		<cfset dtEnd = #dtEOM#>
		<cfinclude  template="MedicaidChargeDaysArray.cfm">
	</cfloop>  
	<cfinclude  template="MedicaidNJCSV.cfm"> 

<!---  <cfoutput><cfdump var="#FinalArray#" label="FinalArray"></cfoutput> ---> 
	 <table>	
		<tr>
			<td>State:  #qState.cStateName#</td>
			<td>Period: #actperiod#</td>
		</tr> 
		<cfif #statecode# is 'NJ'>
			<tr>
				<td colspan="2">
				#qState.cStateName# Medicaid Payment File Extract is complete.
				<p> <span  style="font-style:italic; font-weight:bold"> 
				<a href="#destFilePath#\MedicaidNJ#todaysdate#.xls">Select Here to View File</a>
				</span></p>
				</td>
			</tr>
		<cfelse>
			<tr>
				<td colspan="2">#qState.cStateName# Medicaid Payment File Extract #destFilePath#\#statecode##todaysdate#.xls is complete</td>
			</tr>	
		</cfif>
	</table>
</cfoutput>
</body>
</html>
