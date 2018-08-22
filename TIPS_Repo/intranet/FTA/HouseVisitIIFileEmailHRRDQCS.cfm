<html> 
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>house visit email file</title>
	</head>
	<body>
											<!--- House and Regions --->	
	<cfset variables.error = ''>
	<cfsetting requesttimeout="11000">
	<cftry>	
		<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
		<cfoutput>
			<cfset todaydate = #dateformat(now(), "mm-dd-yyyy")#>		
			<cffile action="Write"  nameconflict="overwrite"
					file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
					output="House Visit Email Log for #todaydate#">		
			<!--- REGION --->
 			<cfloop list="RDQCS" delimiters=","  index="roletype">	
				<cfset dsEmailList = helperObj.qryHouseVisitIIEmailListReg(roletype)>
				<cfloop query="dsEmailList" >
					<cfset fullname= #Trim(cFullname)#>
					<cfset firstname = listgetat(fullname,2)>
					<cfset lastname  = listgetat(fullname,1)>
					<cfset thisRegionName = dsEmailList.regionname>
					<cfset regionfilename = replace(replace(dsEmailList.regionname, " " , "_","All"),"/", "_","All")>
					<cfif FileExists("\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls") is "yes">
						<cfmail to="#cemail#"  	from="report@alcco.com" subject="House Visit Report #thisRegionName# Region">
						#firstname# #lastname#,	Attached is the weekly House Visit Report for #thisRegionName# Region.
							<cfmailparam file="\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls">
						</cfmail>
						<cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="emailsent #cFullName#, #cemail#, #thisRegionName# Region, #roletype#"> 
					</cfif>
				</cfloop>  
			</cfloop>  
			<!--- House --->
  			<cfloop list="WD,RD,RSM" delimiters=","  index="roletype">	
				<cfset dsEmailList = helperObj.qryHouseVisitIIEmailListHouse(#roletype#)>
				<cfloop query="dsEmailList" >
					<cfset fullname= #Trim(cFullname)#>
					<cfset firstname = listgetat(fullname,2)>
					<cfset lastname  = listgetat(fullname,1)>
					<cfset  housename = replace(chousename, " " , "_" , "All")  >	 
					<cfif FileExists("\\fs01\ALC_IT\HouseVisit\House\#housename#_housevisit.xls") is "yes">
						<cfmail to="#cemail#"  	from="report@alcco.com" subject="House Visit Report #chousename# House">
						#firstname# #lastname#,	Attached is the weekly House Visit Report for #REPLACE(housename, "_", " ")# house.
							<cfmailparam file="\\fs01\ALC_IT\HouseVisit\House\#housename#_housevisit.xls">
						</cfmail>
							<cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="emailsent #cFullName#, #cemail#, #housename# #roletype#"> 
					</cfif>
				</cfloop>  
			</cfloop> 
												
		</cfoutput>
	<cfcatch type="any">
		<cfmail to="sfarmer@alcco.com" from="FTA_HouseVisitFileEmail.cfm@alcco.com" subject="House Visit Region/House email failed" type="html">
			Detail: #cfcatch.Detail#<br><br>
			Message: #cfcatch.Message#<br><br>
			Exception Type: #cfcatch.Type#<br><br>
		</cfmail>
	</cfcatch>
	</cftry>
	</body>
</html>


