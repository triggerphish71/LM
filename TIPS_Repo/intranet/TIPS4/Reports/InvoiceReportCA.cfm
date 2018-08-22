 	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
	<!--- <html xmlns="http://www.w3.org/1999/xhtml"> ---><head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Resident Invoice</title>
		 <style>
			table{ 
				font-size:0em;
				border-collapse: collapse;
			}
		</style>
	</head>
 	<cfparam  NAME="prompt0" default="">
 	<cfparam  NAME="prompt1" default="">
	<cfparam  NAME="prompt2" default="">
	<cfparam  NAME="prompt3" default="">
	<cfparam  NAME="prompt4" default="">
 
	<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
		SELECT	H.cNumber
		, h.caddressline1
		, h.ccity
		, h.cstatecode
		,h.czipcode
		, h.cname
		,h.cphonenumber1
		, OA.cNumber as OPS
		, R.cNumber as Region
		FROM	House H
		JOIN 	OPSArea OA ON (OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
		JOIN 	Region R ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
		WHERE	H.dtRowDeleted IS NULL	
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	</CFQUERY>	

 
		<cfquery name="SelectAll"  datasource="#application.datasource#">
		select t.csolomonkey  from tenant t
		join tenantstate ts on t.itenant_id = ts.itenant_id
		join invoicemaster im on im.csolomonkey = t.csolomonkey 
		join AptAddress aa on ts.iAptAddress_id = aa.iAptAddress_id
		and im.cappliestoacctperiod = '#prompt2#'
		where t.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID# 
		and im.dtrowdeleted is null  
		and 	im.bMoveInInvoice is null 
		and 	im.bMoveOutInvoice is null
		order by aa.cAptNumber
		</cfquery>
 	<cfset count = 0>
 
<cfloop query="SelectAll"  >
<CFOUTPUT>
<cfset count = count + 1>
<cfif count gt 1>
 
</cfif>
 
	<cfset prompt0 = #csolomonkey#>
	
	<cfquery name="sp_Invoices_report" datasource="#application.datasource#">
		EXEC rw.sp_Invoices_report
			  @HouseNumber =   '#HouseData.cnumber#' , 
			@AcctPeriod =   '#prompt2#' ,
			@SolomonKey =   '#prompt0#'  
	</cfquery> 

	<cfquery name="qryTenant"  datasource="#application.datasource#">
		select t.itenant_id, t.cfirstname, t.clastname, t.bisPayer , t.csolomonkey
		,ts.dtmovein, ts.dtrenteffective, ts.dtmoveout, t.cbillingtype, t.cchargeset
		,t.cfirstname + ' ' + t.clastname as Residentname
		 from tenant t
		 join tenantstate ts on t.itenant_id = ts.itenant_id
			where t.csolomonkey = '#sp_Invoices_report.csolomonkey#'
	</cfquery>
	#sp_Invoices_report.csolomonkey# ::
 #qrytenant.itenant_id# ::<br /> 
	<cfquery name="qryTenantContact"  datasource="#application.datasource#">
		select top 1 *
		from linktenantcontact ltc
		join contact cont on  ltc.icontact_id = cont.icontact_id
		and ltc.bispayer = 1
		where ltc.itenant_id = #qrytenant.itenant_id#
		and cont.dtrowdeleted is null and ltc.dtrowdeleted is null
		order by ltc.dtrowstart
	</cfquery>
	#qryTenantContact.clastname#<br />
</CFOUTPUT>
</cfloop>