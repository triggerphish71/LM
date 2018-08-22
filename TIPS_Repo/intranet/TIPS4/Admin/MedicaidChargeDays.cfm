<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfparam name="itenantID" default="">
<cfparam name="cperiod" default="">
<cfparam name="firstday" default="">
<cfparam name="lastday" default="">
<cfparam name="StoppedatCount" default="">
<cfparam name="lastday2" default="">
<cfparam name="StoppedatCount2" default="">
<cfparam name="firstday2" default="">
<cfparam name="dtBegin" default="2015-03-01">
<cfparam name="dtEnd" default="2015-03-31">

<cfif isDefined('url.itenant_id')>
	<cfset itenantID = #url.itenant_id#>
<cfelseif isDefined('form.itenant_id')>
	<cfset itenantID = #form.itenant_id#>
<cfelse>
	<cfset itenantID = 73269>
</cfif>

<cfquery name="qryChgPeriod" datasource="#APPLICATION.datasource#">
SELECT  [iTenant_ID]
      ,[iLeaveStatus_ID]
      ,[Census_Date]
      ,[CurrentStatusInBedAtMidnight]
      ,[TempStatusOutDate]

  FROM [TIPS4].[dbo].[DailyCensusTrack] 

  where itenant_id = #itenantID#
	and census_date between '#dtBegin#' and '#dtEnd#'
  order by census_date
</cfquery>
<body>
<cfset ChgDayarray=arraynew(2)> 
<cfset EndDayArray=arraynew(2)> 
<cfloop query="qryChgPeriod"> 
    <cfset ChgDayarray[CurrentRow][1]=iTenant_ID> 
    <cfset ChgDayarray[CurrentRow][2]=iLeaveStatus_ID> 
    <cfset ChgDayarray[CurrentRow][3]=Census_Date> 
    <cfset ChgDayarray[CurrentRow][4]=TempStatusOutDate> 
</cfloop> 

<cfset total_records=qryChgPeriod.recordcount> 

<cfset endcount = 1>
<cfset EndDayArray[endcount][1]=ChgDayarray[1][3]>

<cfloop index="Counter" from=1 to="#Total_Records#"  > 
    <cfoutput> 
	#Counter#,
        ID: #ChgDayarray[Counter][1]#, 
        Status: #ChgDayarray[Counter][2]#, 
        CensusDate: #ChgDayarray[Counter][3]#, 
        OutDate: #ChgDayarray[Counter][4]#  
		<cfif ChgDayarray[Counter][2] is 1>
			<cfset EndDayArray[endcount][2] = #ChgDayarray[Counter][3]#>
			<cfset endcount = endcount + 1>
			<cfelse> '&&&'
		</cfif>
		<br>
    </cfoutput> 
</cfloop>

<cfset firstday = #ChgDayarray[1][3]#>
<cfset counter = 1>
<cfloop index="Counter" from=1 to="#Total_Records#"  > 
<!--- <cfloop condition="#ChgDayarray[Counter][2]# is not 0"> --->
	<cfif  ChgDayarray[Counter][2] is 1>
		<cfset lastday = #ChgDayarray[#Counter#][3]#>
		<cfset StoppedatCount = #Counter#>		
	</cfif>
	<cfset counter = counter + 1>
</cfloop>

<!--- <cfif StoppedatCount lt Total_Records>
 <cfset restartAt = #StoppedatCount# + 1>
   	<cfset firstday2 = #ChgDayarray[#restartAt#][3]#>
	<cfloop index="Counter" from="#restartAt#" to="#Total_Records#"  > 

	<cfif  ChgDayarray[Counter][2]  is not 0>
		<cfset lastday2= #ChgDayarray[Counter - 1][3]#>
		<cfset StoppedatCount2 = #Counter#>		
	</cfif>

	</cfloop>
</cfif> --->

<cfif lastday2 is ''>
	<cfset lastday2 = #ChgDayarray[#Total_Records#][3]#>
	<cfset StoppedatCount2 =  #Total_Records# >
</cfif>

<cfoutput>
	<br />
	Beginning Day: #firstday# Last Day: #lastday# Stopped At: #StoppedatCount#
	<br />
	2nd Beginning Day: #firstday2# Ending Day: #lastday2# Stopped At: #StoppedatCount2#
</cfoutput>



</body>
</html>
