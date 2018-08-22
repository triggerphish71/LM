<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cftransaction>
	<cfquery name="EFTinfo" datasource="#application.datasource#">
		SELECT 
			 EFTA.iEFTAccount_ID 
		FROM    dbo.EFTAccount EFTA
		WHERE	EFTA.cSolomonKey = '#URL.cSolomonKey#'	
				and EFTA.dtRowDeleted is null	
		ORDER BY  EFTA.iOrderofPull 				
	</cfquery>
	<cfloop query="EFTInfo">
		<cfoutput>#EFTinfo.iEFTAccount_ID#  #URL.cSolomonKey#<br/></cfoutput>
		<cfquery name="updEFTApproval" datasource="#application.datasource#">
			UPDATE dbo.EFTAccount
			SET bApproved  = 1,
				cApprovedBy = '#session.username#',
				dApprovedDate= #CreateODBCDateTime(Now())#
			WHERE cSolomonKey = '#URL.cSolomonKey#'
		</cfquery>
	</cfloop>
</cftransaction>
	Updated<br/>
			<CFLOCATION URL="TenantEdit.cfm?ID=#url.ID#" ADDTOKEN="No">
<body>
</body>
</html>
