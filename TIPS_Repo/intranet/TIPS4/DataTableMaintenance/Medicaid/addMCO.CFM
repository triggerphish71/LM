<html>
	<head>
		<title> Tips 4-Medicaid</title>
	</head>
	<cfoutput>
		<cfset dtEffStart = createodbcdatetime(#dtEffectiveStart#)>
		<cfset dtEffEnd = createodbcdatetime(#dtEffectiveEnd#)>
		<cfquery name="insertMCOProvider"   DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO dbo.MCOProvider
				   (cMCOProvider
				   ,iMCO_ID
				   ,cStateCode
				   ,dtRowStart
					,iRowStartUser_ID
				   ,dtEffectiveStart
				   ,dtEffectiveEnd)
			 VALUES
				   ('#cMCOProvider#'
				   ,'#iMCO_ID#'
				   ,'#cStateCode#' 
				   ,getdate()
				   ,#session.userid#
				   ,  #CreateODBCDateTime(dtEffectiveStart)#
				   , #CreateODBCDateTime(dtEffectiveEnd)#
				   )
		</cfquery>
		<cflocation url="MCOReview.cfm?cstatecode=#cStateCode#">
	</cfoutput>
	<body>
	</body>
</html>
