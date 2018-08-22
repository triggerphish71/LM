<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfquery name="qryRecurringUpdate" datasource="#APPLICATION.datasource#">
SELECT  
     RCRED.[iRecurringCharge_ID]
      ,RCRED.[dtEffectiveEnd]
	   ,RCRED.[itenant_id]
  FROM [TIPS4].[dbo].[RecurringChgResetEndDate$]  RCRED 
</cfquery>
<body>
	<cfset reccount = 0>
	<cftransaction>
		<cfoutput>
			<cfloop query="qryRecurringUpdate"><br />
			<cfset reccount  = reccount + 1>
			<cfif dtEffectiveEnd is not "">
			<cfset thisdate = #createODBCDateTime(dtEffectiveEnd)#>
				 <cfquery name="updRecRate" datasource="#APPLICATION.datasource#"> 
					update recurringcharge 
					set  dtEffectiveEnd  = #thisdate#
					where  iRecurringCharge_ID = #iRecurringCharge_ID#
						and itenant_id = #itenant_id#
				  </cfquery>   #reccount#<br />
			</cfif>	
			</cfloop>
		</cfoutput>
	</cftransaction>
</body>
</html>
