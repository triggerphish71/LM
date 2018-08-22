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
<cfset dtBegin = #qryChgPeriod[1][3]#>
<cfoutput query="qryChgPeriod">
	<cfif ileaveststus_id is 0>
		

</cfoutput>
</body>
</html>
