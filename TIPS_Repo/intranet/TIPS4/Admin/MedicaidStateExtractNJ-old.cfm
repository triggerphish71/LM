<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
<cfparam name="statecode" default="">
<cfparam name="actperiod" default="">
<cfparam name="acctperiod" default="">

<cfif statecode is ''>
	<cfset statecode = 'NJ'>
</cfif>
<cfif actperiod is ''>
	<cfset actperiod = dateadd('m', -1, #now()#)>
	<cfset acctperiod = Year(#actperiod#) & DateFormat(#actperiod#,"mm")>

</cfif>
	<cfset dtStart = Year(#actperiod#) & '-' &  DateFormat(#actperiod#,"mm") & '-' &  '01'>
 	<cfset today = now()> 
	<cfset firstOfThisMonth = createDate(year(today), month(today), 1)> 
	<cfset dtEnd = dateAdd("d", -1, #firstOfThisMonth#)> 
  <cfset dtEOM = Year(#dtEnd#) & '-' &  DateFormat(#dtEnd#,"mm") & '-' & DateFormat(#dtEnd#,"dd")>
	<cfquery name="qryMedicaidResidents"  datasource="#APPLICATION.datasource#">
		SELECT  
			t.clastname + ', ' + t.cfirstname Name
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
			,dct.DischargeDate
		
		FROM [TIPS4].[dbo].[DailyCensusTrack] dct
			join tenant t on dct.itenant_id = t.itenant_id
			join tenantstate ts on t.itenant_id = ts.itenant_id
			join house h on t.ihouse_id = h.ihouse_id
			where census_date between '#dtStart#' and  '#dtEOM#'   
			and h.cstatecode = '#statecode#'
		order by itenant_id, census_date
	</cfquery>
	<cfoutput>
	<cfset ChgDayarray=arraynew(2)> 
	<cfset outdays=arraynew(2)>
	<cfset indays=arraynew(2)>
	<cfloop query="qryMedicaidResidents"> 
		<cfset ChgDayarray[CurrentRow][1]=currentrow>
		<cfset ChgDayarray[CurrentRow][2]=iTenant_ID> 
		<cfset ChgDayarray[CurrentRow][3]=iLeaveStatus_ID> 
		<cfset ChgDayarray[CurrentRow][4]=CensusDate> 
		<cfset ChgDayarray[CurrentRow][5]=TempStatusOutDate> 
		<cfset ChgDayarray[CurrentRow][6]=CurrentStatusInBedAtMidnight>	
	</cfloop> 	

	<cfset total_records=qryMedicaidResidents.recordcount> 
	<cfset ChgPeriodArray=arraynew(2)>
	<cfdump var="#ChgDayarray#" label="ChgDayarray">
 	<cfset yesoutdays = 'N'>
	<cfset tenantID = #ChgDayarray[1][2]#>
	 <cfset firstday = #ChgDayarray[1][4]#>
	<cfset index = 1>
	<cfset j = 1><cfset k = 1>
	<cfset indays[1][1] = #ChgDayarray[1][4]#>
	<cfset indays[1][3] = #ChgDayarray[1][2]#>	
	
	<cfset counter = #qryMedicaidResidents.recordcount#>
	<cfloop  condition="index lte total_records" > 
	<cfset indays[k][3] = #ChgDayarray[#index#][2]#>	
	<cfloop condition="ChgDayarray[index][4] eq indays[k][3]">
		<cfset lastday = #ChgDayarray[#index#][4]#>
		<cfset StoppedatCount = #Counter#>	
		<cfif ChgDayarray[index][3]is 0>
			<cfif yesoutdays is 'Y' >
				<cfset k = k + 1>
				<cfset indays[k][1] = #ChgDayarray[index][4]# >
				<cfset yesoutdays = 'N'>
			</cfif>
			<cfset indays[k][2] = #ChgDayarray[index][4]#>
			
 		<cfelseif #ChgDayarray[index][3]# gt 0>
			<cfset outdays[j][1] = index>
			<cfset outdays[j][2] = #ChgDayarray[index][4]#>
			<cfset j = j + 1>
			<cfset yesoutdays = 'Y'>
		</cfif>
		<cfset index = index + 1>	
		</cfloop>
	</cfloop>
	<cfset index = 1>
	<cfset maxlines = arraylen(indays)>

	<cfloop  condition="#index# lte #maxlines#" > 
		<cfset tenantid = indays[index][3]>	
		<cfset startdate = indays[index][1]>
		<cfset enddate = indays[index][2]>
		<cfset index = index + 1>
		<br />#startdate# :: #enddate# ::  #DateDiff('d',startdate, enddate)  +1#
	</cfloop> --->
 
	<table>

	<tr>
		<td>From Date: #dtStart#</td>
		<td>End Date: #dtEnd#</td>
	</tr>
	<cfloop query="qryMedicaidResidents"	>
		<tr>
			<td>#Name#</td>
			<td>#House#</td>
			<td>#statecode#</td>
			<td>#iTenant_ID#</td>
			<td>#csolomonkey#</td>
			<td>#iresidencytype_id#</td>
			<td>#iLeaveStatus_ID#</td>
			<td>#CensusDate#</td>
			<td>#CurrentStatusInBedAtMidnight#</td>
			<td>#NoticeOfDischarge#</td>
			<td>#TempStatusOutDate#</td>
			<td>#TempStatusInDate#</td>
			<td>#TempWhere#</td>
			<td>#DischargeDate#</td>
			
		</tr>
	</cfloop>
	</table>
</cfoutput>
</body>
</html>
