<html> 
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>house visit email file</title>
	</head>
	<body>
											<!---  Region 11 - Heartland --->	
	<cfset variables.error = ''>
	<cfsetting requesttimeout="11000">
	<cftry>	
		<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
		<cfoutput>
			<cfset todaydate = #dateformat(now(), "mm-dd-yyyy")#>		
			<cffile action="Write"  nameconflict="overwrite"
					file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#R11.txt" 
					output="House Visit Email Log for #todaydate#">		
 
 			<!--- SH ---> 
					<cfset dsSHData = helperObj.qryHouseVisitIIEmailListVP('Hamm, Sara')>
					<cfset SHfullname= #Trim(dsSHData.cFullName)#>
					<cfset SHemail  = #Trim(dsSHData.cemail)#> 
 		
			<!--- KB ---> 
					<cfset dsKBData = helperObj.qryHouseVisitIIEmailListVP('Bucholtz, Kathy')>
					<cfset KBfullname= #Trim(dsKBData.cFullName)#>
					<cfset KBemail  = #Trim(dsKBData.cemail)#>			
 														
			<!--- JH --->
					<cfset dsJHData = helperObj.qryHouseVisitIIEmailListVP('Houck, Jared')>
					<cfset JHfullname= #Trim(dsJHData.cFullName)#>
					<cfset JHemail = 	#Trim(dsJHData.cemail)#> 
 			<!--- MJ --->
					<cfset dsMJData = helperObj.qryHouseVisitIIEmailListVP('Jacksic, Mike')>
					<cfset MJfullname= #Trim(dsMJData.cFullName)#>
					<cfset MJemail = 	#Trim(dsMJData.cemail)#>
 				
			<!--- TS --->
					<cfset TSfullname= "Supchak, Tamela"> 
					<cfset TSemail  = "tsupchak@ALCCO.com">
						
						<cfset dsEmailList = helperObj.qryHouseVisitIIRegionList(11)>
						<cfset division_name = dsemailList.division_name>
						<cfmail to="#TSemail#"   BCC="sfarmer@alcco.com"	from="report@alcco.com" subject="House Visit Report #division_name# Division">				  	
							Attached is the weekly House Visit Report for #division_name# Division.
							<cfloop query="dsEmailList" >
								<cfset regionfilename = replace(replace(dsEmailList.regionname, " " , "_","All"),"/", "_","All")>
								<cfif FileExists("\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls") is "yes">
									<cfmailparam file="\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls">
								</cfif>
							</cfloop>
						</cfmail>
						
						<cfmail to="#KBemail#"  BCC="sfarmer@alcco.com"	from="report@alcco.com" subject="House Visit Report #division_name# Division">				  	
							Attached is the weekly House Visit Report for #division_name# Division.
							<cfloop query="dsEmailList" >
								<cfset regionfilename = replace(replace(dsEmailList.regionname, " " , "_","All"),"/", "_","All")>
								<cfif FileExists("\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls") is "yes">
									<cfmailparam file="\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls">
								</cfif>
							</cfloop>
						</cfmail>
 		
														
						<cfmail to="#SHemail#"  BCC="sfarmer@alcco.com"	from="report@alcco.com" subject="House Visit Report #division_name# Division">				  	
							Attached is the weekly House Visit Report for #division_name# Division.
							<cfloop query="dsEmailList" >
								<cfset regionfilename = replace(replace(dsEmailList.regionname, " " , "_","All"),"/", "_","All")>
								<cfif FileExists("\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls") is "yes">
									<cfmailparam file="\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls">
								</cfif>
							</cfloop>
						</cfmail>	
						
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#R11.txt" 
								output="emailsent #TSfullname#, #TSemail#, Division: #division_name#">
 
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#R11.txt" 
								output="CC: #KBfullname#, #KBemail#, Division: #division_name#">
												
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#R11.txt" 
								output="CC: #SHfullname#, #SHemail#, Division: #division_name#">
		</cfoutput>
	<cfcatch type="any">
		<cfmail to="sfarmer@alcco.com" from="FTA_HouseVisitFileEmail.cfm@alcco.com" subject="House Visit Region 11 email failed" type="html">
			Detail: #cfcatch.Detail#<br><br>
			Message: #cfcatch.Message#<br><br>
			Exception Type: #cfcatch.Type#<br><br>
		</cfmail>
	</cfcatch>
	</cftry>
	</body>
</html>


