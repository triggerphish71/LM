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
	<cfparam name="dtBegin" default="">
	<cfparam name="dtEnd" default="">

 
	<cfif isDefined('url.itenant_id')>
		<cfset itenantID = #url.itenant_id#>
	<cfelseif isDefined('form.itenant_id')>
		<cfset itenantID = #form.itenant_id#>
	<cfelse>  
	<cfset itenantID = #thisresident#>
 	</cfif> 
	
	<cfquery name="tenantinfo"  datasource="#APPLICATION.datasource#">
	select cfirstname + ' ' + clastname 'Name', cSolomonkey from tenant where itenant_id = #itenantID#
	</cfquery>
	<cfquery name="qryChgPeriod" datasource="#APPLICATION.datasource#">
		SELECT  iTenant_ID
			,iLeaveStatus_ID
			,convert(varchar(12),Census_Date,101) Census_Date
			,CurrentStatusInBedAtMidnight
			,convert(varchar(12),TempStatusOutDate,101) TempStatusOutDate
		FROM [TIPS4].[dbo].[DailyCensusTrack] 
		where itenant_id = #itenantID#
		and census_date between '#dtBegin#' and '#dtEnd#'
		order by census_date
	</cfquery>
<!---  <cfoutput>
 <tr><td> #tenantinfo.name#</td><td>#tenantinfo.cSolomonkey#</td></tr>
 </cfoutput> --->
  

	
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
	<cfloop index="Counter" from=1 to="#Total_Records#"  > 
			<!---     <cfoutput>  --->
			<!--- 		#ChgDayarray[Counter][1]# :: 
			ID: #ChgDayarray[Counter][2]#, 
			Status: #ChgDayarray[Counter][3]#, 
			CensusDate: #ChgDayarray[Counter][4]#, 
			OutDate: #ChgDayarray[Counter][5]# 
			CurrentStatusInBedAtMidnight: #ChgDayarray[Counter][6]#  --->
		<cfset thisTenID = #ChgDayarray[Counter][2]#>
			<!--- 		<br> 	</cfoutput>  --->
	</cfloop> 
	<cfset yesoutdays = 'N'>
	<cfset firstday = #ChgDayarray[1][4]#>
	<cfset index = 1>
	<cfset j = 1><cfset k = 1>
	<cfset indays[1][1] = #ChgDayarray[1][4]#>

	<cfset counter = #qryChgPeriod.recordcount#>
	<cfloop  condition="index lte total_records" > 
	<!---  <cfoutput>#ChgDayarray[index][4]# :: #ChgDayarray[index][3]# :: #ChgDayarray[index][6]#<br /></cfoutput> --->
		<cfset lastday = #ChgDayarray[#index#][4]#>
		<cfset StoppedatCount = #Counter#>	
		<cfif ChgDayarray[index][3]is 0>
			<cfif yesoutdays is 'Y' >
				<cfset k = k + 1>
				<cfset indays[k][1] = #ChgDayarray[index][4]# >
				<cfset indays[k][3] = #ChgDayarray[index][2]#>
				<cfset yesoutdays = 'N'>
			</cfif>
			<cfset indays[k][2] = #ChgDayarray[index][4]#>
			<cfset indays[k][3] = #ChgDayarray[index][2]#>			
		<cfelseif #ChgDayarray[index][3]# gt 0>
			<cfset outdays[j][1] = index>
			<cfset outdays[j][2] = #ChgDayarray[index][4]#>
			<cfset j = j + 1>
			<cfset yesoutdays = 'Y'>
		</cfif>
		<cfset index = index + 1>	
	</cfloop>

	<cfoutput  > 
					<!---  <cfdump var="#outdays#" label="outdays">
					 <cfdump var="#indays#" label="indays">      --->
					<cfset index = 1>
					<cfset maxlines = arraylen(indays)>
					<!---  <cfoutput>maxlines: #maxlines# , #thisTenID#, #ArrayFindNoCase(indays,67037)#<br /></cfoutput> --->

					<cfloop  condition="#index# lte #maxlines#" >
							<!--- <br /><cfoutput>yes1,#arrayfind(indays,thisTenID)#,</cfoutput> --->
						<cfset mylist = ArrayToList(indays[index],",")>
								<!---  <br /><cfoutput>mylist:: <cfdump var="#mylist#" label="mylist"> :: #thisTenID#</cfoutput><br/> --->
						
						<cfif find(#thisTenID#,mylist) >   
								<!--- <br />yes2, --->
							<cfset tenantID = indays[index][3]>
							<cfset startdate = indays[index][1]>
							<cfset enddate = indays[index][2]>
							<cfset totaldays = #DateDiff('d',startdate, enddate)#  +1>
							
							<cfset FinalArray[FinalIndex][1] = #indays[index][3]#>
							<cfset FinalArray[FinalIndex][2] = #indays[index][1]#>
							<cfset FinalArray[FinalIndex][3] = #indays[index][2]#>							
							<cfset FinalIndex = #FinalIndex# + 1>
							<!---  <cfoutput><br />#startdate# :: #enddate# ::  #totaldays#<br /></cfoutput> --->  
<!--- 							<cfquery name="qryMedicaidChg"  datasource="#APPLICATION.datasource#">
								select t.clastname as  'Lname'
								, t.cfirstname as 'Fname'
								,  t.cMiddleInitial as  'MiddleInitial' 
								,'061009175001' as  'NJHSP'
								,'HorizonNJHealth' as  'MCO'
								,iMCOProvider as  'MCOID'
								,ts.cMedicaidAuthorizationNbr 
								,ts.dtAuthFDOS  
								,ts.dtAuthTDOS  
								,convert(varchar(10),t.dbirthdate,101) as  'DOB'
								,t.cssn as  'SSNA'  
								,ts.cSex  
								,ts.iPICD as  PICD
								,ts.iSICD as  SICD
								,ts.iTICD as  TICD
								<!--- ,#startdate# as   'FDOS'
								,#enddate# as  'TDOS'
								,#totaldays# as 'Days' --->
								,convert(DECIMAL(19,2),hm.mStateMedicaidAmt_BSF_Daily * #totaldays#) as  'Gross'
								,convert(DECIMAL(19,2),ts.mMedicaidCopay * #totaldays#/#idaysinMonth#) as  'CostShare'
								,convert(DECIMAL(19,2),hm.mStateMedicaidAmt_BSF_Daily * #totaldays# - ts.mMedicaidCopay * #totaldays#/#idaysinMonth#) 
									as  'Net'
								,t.itenant_id
								, mco.cMCOProvider, mco.iMCO_id
								from tenant t 
								join tenantstate ts on t.itenant_id = ts.itenant_id  
								join house h on t.ihouse_id = h.ihouse_id
								join HouseMedicaid hm on h.ihouse_id = hm.ihouse_id
								join MCOProvider MCO on ts.iMCOProvider = MCO.iMCOProvider_ID
								
								where
								t.itenant_id = #tenantID#
								and t.dtrowdeleted is null and ts.dtrowdeleted is null 
							</cfquery> --->
							
							
							<!--- <cfloop query="qryMedicaidChg"> ---> 
 
						</cfif>  
						<cfset index = index + 1> 
<!--- 					  #qryMedicaidChg.Lname#
					,#qryMedicaidChg.Fname#
					,#qryMedicaidChg.MiddleInitial#
					,#qryMedicaidChg.NJHSP#
					,#qryMedicaidChg.cMCOProvider# 
					,#qryMedicaidChg.iMCO_id#
					,#qryMedicaidChg.cMedicaidAuthorizationNbr#
					,#dateformat(qryMedicaidChg.dtAuthFDOS, 'mm/dd/yyyy')#
					,#dateformat(qryMedicaidChg.dtAuthTDOS, 'mm/dd/yyyy')#
					,#qryMedicaidChg.DOB#
					,#qryMedicaidChg.SSNA#
					,#qryMedicaidChg.CSex#
					,#qryMedicaidChg.PICD#
					,#qryMedicaidChg.SICD#
					,#qryMedicaidChg.TICD#
					,#dateformat(startdate, 'mm/dd/yyyy')#
					,#dateformat(enddate, 'mm/dd/yyyy')#
					,#totaldays#
					,#qryMedicaidChg.Gross#
					,#qryMedicaidChg.CostShare#
					,#qryMedicaidChg.Net#
					,#qryMedicaidChg.itenant_id#
					<br />  --->	
					</cfloop> 
			
				</Table>
 
			<!--- </cfoutput> --->
 
<!---  <br /> --->

 
<!--- <cfif StoppedatCount lt Total_Records>
 <cfset restartAt = #StoppedatCount# + 1>
   	<cfset firstday2 = #ChgDayarray[#restartAt#][3]#>
	<cfloop index="Counter" from="#restartAt#" to="#Total_Records#"  > 

	<cfif  ChgDayarray[Counter][2]  is not 0>
		<cfset lastday2= #ChgDayarray[Counter - 1][3]#>
		<cfset StoppedatCount2 = #Counter#>		
	</cfif>

	</cfloop>
</cfif>

<cfif lastday2 is ''>
	<cfset lastday2 = #ChgDayarray[#Total_Records#][3]#>
	<cfset StoppedatCount2 =  #Total_Records# >
</cfif> --->

<!--- <cfoutput>
	<br />
	Beginning Day: #firstday# Ending Day: #lastday# Stopped At: #index#
	<br />
	2nd Beginning Day: #firstday2# Ending Day: #lastday2# Stopped At: #StoppedatCount2#
</cfoutput> --->
 
</cfoutput>

</body>
</html>
