<html> 
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>house visit email file</title>
	</head>
	<body>
											<!---  Region 4 - Midwest/Atlantic --->
	<cfset variables.error = ''>
	<cfsetting requesttimeout="11000">
	<cftry>	
		<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
		<cfoutput>
			<cfset todaydate = #dateformat(now(), "mm-dd-yyyy")#>		
			<cffile action="Write"  nameconflict="overwrite"
					file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#R4.txt" 
					output="House Visit Email Log for #todaydate#">		
	
			<!--- LB ---> 
					<cfset LBfullname= "Bebo, Laurie">
					<cfset LBemail  = "lbebo@ALCCO.com">		
			<!--- KB ---> 
					<cfset dsKBData = helperObj.qryHouseVisitIIEmailListVP('Bucholtz, Kathy')>
					<cfset KBfullname= #Trim(dsKBData.cFullName)#>
					<cfset KBemail  = #Trim(dsKBData.cemail)#>			
			<!--- LW ---> 
					<cfset dsLWData = helperObj.qryHouseVisitIIEmailListVP('Wolfgram, Lynn')>
					<cfset LWfullname= #Trim(dsLWData.cFullName)#>
					<cfset LWemail  = #Trim(dsLWData.cemail)#>														
			<!--- JH --->
					<cfset dsJHData = helperObj.qryHouseVisitIIEmailListVP('Houck, Jared')>
					<cfset JHfullname= #Trim(dsJHData.cFullName)#>
					<cfset JHemail = 	#Trim(dsJHData.cemail)#> 
			<!--- MJ --->
					<cfset dsMJData = helperObj.qryHouseVisitIIEmailListVP('Jacksic, Mike')>
					<cfset MJfullname= #Trim(dsMJData.cFullName)#>
					<cfset MJemail = 	#Trim(dsMJData.cemail)#> 
						
  						<cfset dsEmailList = helperObj.qryHouseVisitIIRegionList(4)>
						<cfset division_name = dsemailList.division_name>
						<cfmail to="#JHemail#" CC="#KBemail#, #LBemail#, #LWemail#" BCC="sfarmer@alcco.com"	from="report@alcco.com" subject="House Visit Report #division_name# Division">
							Attached is the weekly House Visit Report for #division_name# Division.	
							<cfloop query="dsEmailList" >
								<cfset regionfilename = replace(replace(dsEmailList.regionname, " " , "_","All"),"/", "_","All")>
								<cfif FileExists("\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls") is "yes">
									<cfmailparam file="\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls">
								</cfif>
							</cfloop> 
						</cfmail>
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#R4.txt" 
								output="email sent #JHfullname#, #JHemail#, Division: #division_name#"> 
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#R4.txt" 
								output="CC: #LBfullname#, #LBemail#, Division: #division_name#"> 	
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#R4.txt" 
								output="CC: #KBfullname#, #KBemail#, Division: #division_name#"> 	
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#R4.txt" 
								output="CC: #LWfullname#, #LWemail#, Division: #division_name#">
								
 												
		</cfoutput>
	<cfcatch type="any">
		<cfmail to="sfarmer@alcco.com" from="FTA_HouseVisitFileEmail.cfm@alcco.com" subject="House Visit Region 4 email failed" type="html">
			Detail: #cfcatch.Detail#<br><br>
			Message: #cfcatch.Message#<br><br>
			Exception Type: #cfcatch.Type#<br><br>
		</cfmail>
	</cfcatch>
	</cftry>
	</body>
</html>


