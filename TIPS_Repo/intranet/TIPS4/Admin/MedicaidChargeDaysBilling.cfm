<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>

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
	<cfset itenantID = 56815> <!--- 73269> --->
</cfif>
<cfquery name="tenantinfo"  datasource="#APPLICATION.datasource#">
select cfirstname + ' ' + clastname 'Name' from tenant where itenant_id = #itenantID#
</cfquery>
<cfquery name="qryChgPeriod" datasource="#APPLICATION.datasource#">
SELECT  [iTenant_ID]
      ,[iLeaveStatus_ID]
      ,convert(varchar(12),Census_Date,101) Census_Date
      ,[CurrentStatusInBedAtMidnight]
      ,convert(varchar(12),TempStatusOutDate,101) TempStatusOutDate

  FROM [TIPS4].[dbo].[DailyCensusTrack] 

  where itenant_id = #itenantID#
	and census_date between '#dtBegin#' and '#dtEnd#'
  order by census_date
</cfquery>
<body>
<cfoutput>#tenantinfo.name#,    #itenantID#
<br />
</cfoutput>
<cfset ChgDayarray=arraynew(2)> 
<cfset outdays=arraynew(2)>
<cfset indays=arraynew(2)>
<cfloop query="qryChgPeriod"> 
	<cfset ChgDayarray[CurrentRow][1]=currentrow>
    <cfset ChgDayarray[CurrentRow][2]=iTenant_ID> 
    <cfset ChgDayarray[CurrentRow][3]=iLeaveStatus_ID> 
    <cfset ChgDayarray[CurrentRow][4]=Census_Date> 
    <cfset ChgDayarray[CurrentRow][5]=TempStatusOutDate> 
    <cfset ChgDayarray[CurrentRow][6]=CurrentStatusInBedAtMidnight>	
</cfloop> 

<cfset total_records=qryChgPeriod.recordcount> 
<cfset ChgPeriodArray=arraynew(2)>
<!--- <cfloop index="Counter" from=1 to="#Total_Records#"  > 
    <cfoutput> 
		#ChgDayarray[Counter][1]# :: 
        ID: #ChgDayarray[Counter][2]#, 
        Status: #ChgDayarray[Counter][3]#, 
        CensusDate: #ChgDayarray[Counter][4]#, 
        OutDate: #ChgDayarray[Counter][5]# 
		CurrentStatusInBedAtMidnight: #ChgDayarray[Counter][6]# 
		<br> 
    </cfoutput> 
</cfloop> --->
<cfset yesoutdays = 'N'>
 <cfset firstday = #ChgDayarray[1][4]#>
<cfset index = 1>
<cfset j = 1><cfset k = 1>
<cfset indays[1][1] = #ChgDayarray[1][4]#>

<cfloop  condition="index lte total_records" > 
<!---  <cfoutput>
 #ChgDayarray[index][4]# :: #ChgDayarray[index][3]# :: #ChgDayarray[index][6]#<br /> 
 </cfoutput> --->
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
<!--- <cfoutput><cfdump var="#outdays#" label="outdays"></cfoutput>  --->
<cfoutput><cfdump var="#indays#" label="indays"></cfoutput>
<cfset index = 1>
<cfloop  condition="index lte total_records">
<cfquery name="qryMedicaidPymnt" datasource="#APPLICATION.datasource#">
declare @acctperiod varchar(10)
declare @monthtodraw varchar(10)
set @acctperiod = '201503'
set @monthtodraw = '2015-03-01'
declare @lastdayofmonth varchar(10)
--select *
  SELECT @lastdayofmonth =  convert(varchar(10),DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@monthtodraw)+1,0)),101)
----declare @EOM varchar(10)
----set @EOM = (convert(varchar(10),@lastdayofmonth, 101))

 select t.clastname 'Lname', t.cfirstname 'Fname',  t.cMiddleInitial 'Middle Initial' --, t.csolomonkey
,'061009175001' 'NJ HSP'
,'HorizonNJHealth' 'MCO'
,'XXXXX' 'MCO ID'
,'xxxxx' 'Authorization No.'
,convert(varchar(12),inv.dtrowstart, 101) 'Auth FDOS'
,case when (ts.dtmoveout is null ) then ( @lastdayofmonth )
 else convert(varchar(10),ts.dtmoveout, 101)
 end 'Auth TDOS'
 ,convert(varchar(10),t.dbirthdate,101) 'DOB'
 ,replace (t.cssn,'-','' )  'SSNA'
 ,' ' 'Sex'
 ,'250' PICD
 ,'2724' SICD
 ,'401' TICD
 ,convert(varchar(12),inv.dtrowstart, 101) 'FDOS'
,case when (ts.dtmoveout is null ) then ( @lastdayofmonth )
 else convert(varchar(10),ts.dtmoveout, 101)
 end 'TDOS'
,datediff(d,inv.dtrowstart, @lastdayofmonth)'Days'
,convert(DECIMAL(19,2),hm.[mStateMedicaidAmt_BSF_Daily] * datediff(d,inv.dtrowstart, @lastdayofmonth)) 'Gross'
,convert(DECIMAL(19,2),(select mamount from invoicedetail invd where invd.ichargetype_id = 1661 and invd.itenant_id = t.itenant_id and invd.cappliestoacctperiod = @acctperiod and invd.dtrowdeleted is null)) 'Cost Share'
,convert(DECIMAL(19,2),(select mamount from invoicedetail invd where invd.ichargetype_id = 8 and invd.itenant_id = t.itenant_id and invd.cappliestoacctperiod = @acctperiod  and invd.dtrowdeleted is null)) 'Net'
,t.itenant_id
from tenant t 
join tenantstate ts on t.itenant_id = ts.itenant_id and ts.iresidencytype_id = 2 and ts.itenantstatecode_id = 2
join invoicemaster IM on t.csolomonkey = im.csolomonkey
join invoicedetail INV on im.iinvoicemaster_id = inv.iinvoicemaster_id
join house h on t.ihouse_id = h.ihouse_id
join HouseMedicaid hm on h.ihouse_id = hm.ihouse_id

where

   inv.cappliestoacctperiod = @acctperiod
and inv.ichargetype_id = 8
and t.dtrowdeleted is null and ts.dtrowdeleted is null
and inv.dtrowdeleted is null and im.dtrowdeleted is null
and h.cstatecode = 'NJ'
</cfquery>
</body>
</html>
