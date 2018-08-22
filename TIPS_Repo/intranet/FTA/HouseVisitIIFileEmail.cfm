<html> 
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>house visit email file</title>
	</head>
	<body>
	<cftry>	
		<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
		<cfoutput>
			<cfset todaydate = #dateformat(now(), "mm-dd-yyyy")#>		
			<cffile action="Write"  nameconflict="overwrite"
					file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
					output="House Visit Email Log for #todaydate#">		
			<!--- REGION --->
 			<cfloop list="RDO,RDQCS,RDSM" delimiters=","  index="roletype">	
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
			<!--- LB ---> 
					 
						<cfset LBfullname= "Bebo, Laurie">
						<cfset LBfirstname = "Laurie">
						<cfset LBlastname  = "Bebo">
						<cfset LBemail  = "lbebo@ALCCO.com">		
			<!--- KB ---> 
					<cfset dsKBData = helperObj.qryHouseVisitIIEmailListVP('Bucholtz, Kathy')>
						<cfset KBfullname= #Trim(dsKBData.cFullName)#>
						<cfset KBfirstname = listgetat(KBfullname,2)>
						<cfset KBlastname  = listgetat(KBfullname,1)>
						<cfset KBemail  = #Trim(dsKBData.cemail)#>			
			<!--- LW ---> 
					<cfset dsLWData = helperObj.qryHouseVisitIIEmailListVP('Wolfgram, Lynn')>
						<cfset LWfullname= #Trim(dsLWData.cFullName)#>
						<cfset LWfirstname = listgetat(LWfullname,2)>
						<cfset LWlastname  = listgetat(LWfullname,1)>
						<cfset LWemail  = #Trim(dsLWData.cemail)#>														
			<!--- JH --->
					<cfset dsJHData = helperObj.qryHouseVisitIIEmailListVP('Houck, Jared')>
						<cfset JHfullname= #Trim(dsJHData.cFullName)#>
						<cfset JHfirstname = listgetat(JHfullname,2)>
						<cfset JHlastname  = listgetat(JHfullname,1)>
  						<cfset dsEmailList = helperObj.qryHouseVisitIIRegionList(4)>
						<cfset division_name = dsemailList.division_name>
						<cfmail to="#dsJHData.cemail#" CC="#KBemail#, #LBemail#, #LWemail#" BCC="sfarmer@alcco.com"	from="report@alcco.com" subject="House Visit Report #division_name# Division">
							Attached is the weekly House Visit Report for #division_name# Division.	
							<cfloop query="dsEmailList" >
								<cfset regionfilename = replace(replace(dsEmailList.regionname, " " , "_","All"),"/", "_","All")>
								<cfif FileExists("\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls") is "yes">
									<cfmailparam file="\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls">
								</cfif>
							</cfloop> 
						</cfmail>
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="email sent #dsJHData.cFullName#, #dsJHData.cemail#, Division: #division_name#"> 
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="CC: #LBfullname#, #LBemail#, Division: #division_name#"> 	
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="CC: #KBfullname#, #KBemail#, Division: #division_name#"> 	
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="CC: #LWfullname#, #LWemail#, Division: #division_name#">
								
						<cfset dsEmailList = helperObj.qryHouseVisitIIRegionList(1)>
						<cfset division_name = dsemailList.division_name>
						<cfmail to="#dsJHData.cemail#"  CC="#KBemail#, #LBemail#"  BCC="sfarmer@alcco.com"	from="report@alcco.com" subject="House Visit Report #division_name# Division">				  	
							Attached is the weekly House Visit Report for #division_name# Division.
							<cfloop query="dsEmailList" >
								<cfset regionfilename = replace(replace(dsEmailList.regionname, " " , "_","All"),"/", "_","All")>
								<cfif FileExists("\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls") is "yes">
									<cfmailparam file="\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls">
								</cfif>
							</cfloop>
						</cfmail>
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="emailsent #dsJHData.cFullName#, #dsJHData.cemail#, Division: #division_name#"> 
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="CC: #KBfullname#, #KBemail#, Division: #division_name#"> 
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="CC: #LBfullname#, #LBemail#, Division: #division_name#">
			<!--- TD --->
							<cfset dsTDData = helperObj.qryHouseVisitIIEmailListVP('Dunne, Tim')>
							<cfset TDfullname= #Trim(dsTDData.cFullName)#>
							<cfset TDfirstname = listgetat(TDfullname,2)>
							<cfset TDlastname  = listgetat(TDfullname,1)>
							<cfset dsEmailList = helperObj.qryHouseVisitIIRegionList(1)>
							<cfset division_name = dsemailList.division_name>
						<cfmail to="#dsTDData.cemail#"   BCC="sfarmer@alcco.com"	from="report@alcco.com" subject="House Visit Report #division_name# Division">				  	
							Attached is the weekly House Visit Report for #division_name# Division.
							<cfloop query="dsEmailList" >
								<cfset regionfilename = replace(replace(dsEmailList.regionname, " " , "_","All"),"/", "_","All")>
								<cfif FileExists("\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls") is "yes">
									<cfmailparam file="\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls">
								</cfif>
							</cfloop>
						</cfmail>
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="emailsent #dsTDData.cFullName#, #dsTDData.cemail#, Division: #division_name#">
 
			<!--- TS --->
							<!--- <cfset dsTSData = helperObj.qryHouseVisitIIEmailListVP('Supchak, Tamela')> --->
						 <cfset TSfullname= "Supchak, Tamela"> 
						<cfset TSfirstname = "Tamela">
						<cfset TSlastname  = "Supchak">
						<cfset TSemail  = "tsupchak@ALCCO.com">
						<cfset dsEmailList = helperObj.qryHouseVisitIIRegionList(11)>
						<cfset division_name = dsemailList.division_name>
						<cfmail to="#TSemail#"    CC="#KBemail#, #LBemail#"  BCC="sfarmer@alcco.com"	from="report@alcco.com" subject="House Visit Report #division_name# Division">				  	
							Attached is the weekly House Visit Report for #division_name# Division.
							<cfloop query="dsEmailList" >
								<cfset regionfilename = replace(replace(dsEmailList.regionname, " " , "_","All"),"/", "_","All")>
								<cfif FileExists("\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls") is "yes">
									<cfmailparam file="\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls">
								</cfif>
							</cfloop>
						</cfmail>
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="emailsent #TSfullname#, #TSemail#, Division: #division_name#">
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="CC: #LBfullname#, #LBemail#, Division: #division_name#">
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="CC: #KBfullname#, #KBemail#, Division: #division_name#">
			<!--- MJ --->
							<cfset dsMJData = helperObj.qryHouseVisitIIEmailListVP('Jacksic, Mike')>
							<cfset MJfullname= #Trim(dsMJData.cFullName)#>
							<cfset MJfirstname = listgetat(MJfullname,2)>
							<cfset MJlastname  = listgetat(MJfullname,1)>
							<cfset dsEmailList = helperObj.qryHouseVisitIIRegionList(2)>
							<cfset division_name = dsemailList.division_name>
						<cfmail to="#dsMJData.cemail#"    CC="#KBemail#, #LBemail#"  BCC="sfarmer@alcco.com"	from="report@alcco.com" subject="House Visit Report #division_name# Division">				  	
							Attached is the weekly House Visit Report for #division_name# Division.
							<cfloop query="dsEmailList" >
								<cfset regionfilename = replace(replace(dsEmailList.regionname, " " , "_","All"),"/", "_","All")>
								<cfif FileExists("\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls") is "yes">
									<cfmailparam file="\\fs01\ALC_IT\HouseVisit\Region\reg_#regionfilename#_housevisit.xls">
								</cfif>
							</cfloop>
						</cfmail>
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="emailsent #dsMJData.cFullName#, #dsMJData.cemail#, Division: #division_name#">
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="CC: #KBfullname#, #KBemail#, Division: #division_name#">
						        <cffile action="Append" 
								file="\\fs01\ALC_IT\HouseVisit\housevisit_email_#todaydate#.txt" 
								output="CC: #LBfullname#, #LBemail#, Division: #division_name#">												
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


