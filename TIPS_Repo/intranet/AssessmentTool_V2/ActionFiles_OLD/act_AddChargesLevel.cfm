<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Add Charges Level</title>
	</head>
	<body>
		<cfset todaysdate = #createODBCDateTime(now())#>
		<!--- <cfset swanhouse = "45,48,93,116,144,147,150,201,237"> --->
		<cfset swanhouse = "">
		<cfquery name="qryHouse" datasource="#application.datasource#">
			SELECT 
				R.cname Division
				,OPA.cName Region
				,H.cName HouseName
				,H.iHouse_ID
				,H.cNumber
				,H.cSLevelTypeSet
				,H.iOpsArea_ID
				,R.iRegion_ID
				,HL.dtCurrentTipsMonth
			  FROM  dbo.House H, dbo.OpsArea OPA, dbo.Region R, dbo.HouseLog HL
			  where H.cSLevelTypeSet = 11
			  and H.dtrowdeleted is null
			  and H.iOpsArea_ID = OPA.iOpsArea_ID
			  and OPA.iRegion_ID  = R.iRegion_ID
			  and H.iHouse_ID = HL.iHouse_ID

			  and H.iHouse_ID = 245		  
			  order by R.iRegion_ID,H.iOpsArea_ID, h.cname
		</cfquery>
		<cfoutput>
		<cftransaction>
			<cfloop query="qryHouse">
				<cfset thishouseid = iHouse_ID>New
				 #iHouse_ID# , #HouseName#, #Region#, #Division#  #qryHouse.dtCurrentTipsMonth#

				<cfset tipsmonth = dateformat(#qryHouse.dtCurrentTipsMonth#, "yyyy-mm-dd")>
				<cfquery name="qryAmount" datasource="#application.datasource#">
					select  mamount as maxamount,
					cChargeSet, dtEffectiveStart, dtEffectiveEnd
					from dbo.charges 
					where ichargetype_id = 91
					and ihouse_id = #qryHouse.ihouse_id#
					and dtrowdeleted is null
					and '#tipsmonth#' between dtEffectiveStart and dtEffectiveEnd
					and cchargeset = '2012Jan'
					order by mamount desc
				</cfquery>
				<cfquery name="qrySLevel" datasource="#application.datasource#">
					Select * 
					FROM  dbo.SLevelType
					where csleveltypeset = 11 
					and cdescription like '%6+%'
					order by ispointsmin
				</cfquery>
				#tipsmonth# :: #qryAmount.maxamount# 

				<cfset qamount = #qryAmount.maxamount#>
				<cfif qamount is not "">
					<cfset descincrement = 0>
					<cfloop query="qrySLevel">
					
						<cfset descincrement = descincrement + 1>	
						<cfif listcontains(#swanhouse#, #thishouseid#, ",")>
							<cfset rescare = "Swan Personal Care - L6 + " & descincrement & ' points'>						
						<cfelse>
							<cfset rescare = "Resident Care - Level 6 + " & descincrement & ' points'>
						</cfif>
						<cfset lvldesc = "6 + " & descincrement>	
						<cfset qamount = qamount + 1.75>
					::: #qrySLevel.iSpointsMin#	, #qrySLevel.iSpointsMax# :::: #qamount# <br/>
 		    	          <cfquery name="addchargetype" datasource="#application.datasource#">
						INSERT INTO [Tips4].[dbo].[Charges]                           
								   ([iChargeType_ID]
								   ,[iHouse_ID]
								   ,[cChargeSet]
								   ,[cDescription]
								   ,[mAmount]
								   ,[iQuantity]
								 
								   ,[iResidencyType_ID]
								   
								   ,[cSLevelDescription]
								   ,[iSLevelType_ID]
								   
								   ,[dtAcctStamp]
								   ,[dtEffectiveStart]
								   ,[dtEffectiveEnd]
								   ,[iRowStartUser_ID]
								   ,[dtRowStart]
								 
								   ,[cRowStartUser_ID] )   
							 
							 VALUES     
								   (91
								   ,#thishouseid#
								   ,'#qryAmount.cChargeSet#'
								   ,'#rescare#'
								   ,#trim(qamount)#
								   ,1
								   
								   ,1
								   
								   ,#lvldesc#
								   ,#IsLevelType_ID#
								   
								   ,#todaysdate#
								   ,'#qryAmount.dtEffectiveStart#'
								   ,'#qryAmount.dtEffectiveEnd#'
								   ,3816
								   ,#todaysdate#
							  
								   ,'SFarmer-2011NovManualInsert'
								  )    </cfquery>           
					</cfloop>
				</cfif>
			</cfloop>
			</cftransaction>
		</cfoutput>
	</body>
</html>
