<cfquery name="updMCO"  DATASOURCE="#APPLICATION.datasource#">
UPDATE dbo.MCOProvider
   SET cMCOProvider = '#cMCOProvider#'
      ,iMCO_ID = '#iMCO_ID#'
      ,cStateCode = '#cStateCode#'
      <cfif isDefined('dtRowDeleted') and dtRowDeleted is not ''>
		  ,dtRowDeleted = odbcdate#dtRowDeleted#
		  ,iRowDeletedUser_id = #session.userid#
	  </cfif>
      ,dtEffectiveStart = #CreateODBCDateTime(dtEffectiveStart)#
	   <cfif isDefined('dtEffectiveEnd') and dtEffectiveEnd is not ''>
      	,dtEffectiveEnd = #CreateODBCDateTime(dtEffectiveEnd)#
	  </cfif>
 WHERE iMCOProvider_ID = #iMCOProvider_ID#
</cfquery>
<cflocation url="MCOHome.cfm">
 
