<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Set Up SLevelType</title>
	</head>
	<body>
		<cfset descCount = 0>		 
		<cfset todaysdate = #createODBCDateTime(now())#>
		<cfloop from="1"  to="250" index="i">
		<cfquery name="SLevelType" datasource="#application.datasource#">
			select top 1  *
			from  dbo.SLevelType
			where  csleveltypeset = 11 
			order by ispointsmax desc
		</cfquery>

		
			<cfoutput>
				<cfloop  query="SLevelType">
					#cSLevelTypeSet# #iSPointsMin# #iSPointsMax# #cDescription# #cComments# #dtAcctStamp# #iRowStartUser_ID#
					#dtRowStart# #iRowEndUser_ID# #dtRowEnd# #iRowDeletedUser_ID# #dtRowDeleted# #cRowStartUser_ID# 
					#cRowEndUser_ID# #cRowDeletedUser_ID# <br/>
					
					<!--- <cfset newDescription = LSParseNumber(SLevelType.cDescription) + 1> --->
					<cfset descCount = descCount + 1>
					<cfset newDescription = "6+" & descCount & " pts">
					<cfset newpointmin = iSPointsMax + 1>
					<cfset newpointmax = iSPointsMax + 1>
			 	  	 <cfquery name="addsleveltype" datasource="#application.datasource#">
					  INSERT INTO [TIPS4].[dbo].[SLevelType]
							   ([cSLevelTypeSet]
							   ,[iSPointsMin]
							   ,[iSPointsMax]
							   ,[cDescription]
							   ,[dtRowStart]
							   ,cRowStartUser_ID )   
						 VALUES
							   ('11'
							   ,#newpointmin#
							   ,#newpointmax#
							   ,'#NewDescription#'
								,#todaysdate#
							   ,'sfarmer_newlevel_12352'
								)   
				    </cfquery>    
								 
					 
				</cfloop>
			</cfoutput>
		</cfloop>
	</body>
</html>
