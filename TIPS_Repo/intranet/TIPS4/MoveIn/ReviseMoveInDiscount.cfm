<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>ReviseMoveInDiscount</title>
</head>
<!---  --------------------------------------------------------------------------------------------
 |   NAME     |  DATE      | Project/Ticket Nbr.|       DESCRIPTION                               |
 --------------------------------------------------------------------------------------------------
 |sfarmer     | 4/10/2012  | 75019              | EFT Update/NRF Deferral.                        |
 |sfarmer     | 06/09/2012 | 75019              | NRF/Deferred Installation                       |
 |Sfarmer     | 09/18/2013 | 102919             | Revise NRF approval process                     |
 |S Farmer    | 09/08/2014 | 116824             | Allow all houses edit BSF and Community Fee Rates |
 --------------------------------------------------------------------------------------------- --->  
	<cfset todaysdate = CreateODBCDateTime(now())>
	
	<cfif isDefined('url.iTenant_ID')>
		<cfset tenantID = url.iTenant_ID>
	<cfelseif isDefined('form.iTenant_ID')>
		<cfset tenantID = form.iTenant_ID>
	</cfif>
<cfdump var="#form#" >
		<cfquery name="qryInvoice" datasource="#application.datasource#">
		select * from invoicemaster where iinvoicemaster_id = #form.Inrfmid#
		</cfquery>
<cftransaction>
	<cfoutput>
	   
	<!--- Update the amount of the   NRF - Invoice Detail --->
	<cfif IsDefined('form.NRFDISC')>
		<cfif IsDefined('form.MPDID69')>
			<cfquery name="updIMNRF"  datasource="#application.datasource#"> 
			update InvoiceDetail
			set mamount = #form.NRFDISC#
			where iInvoiceDetail_id = #form.MPDID69#
			</cfquery>
		<cfelse>
                <cfquery name="InsertAutoApplyCharge" datasource="#application.datasource#">
                insert into InvoiceDetail
                (iInvoiceMaster_ID
				 ,iTenant_ID 
				,iChargeType_ID 
                ,cAppliesToAcctPeriod 
				,dtTransaction 
                ,iQuantity 
                ,cDescription
                , mAmount 
                ,dtAcctStamp 
                ,iRowStartUser_ID 
                ,dtRowStart
                ,ccomments)
                values
                (#form.Inrfmid# 
                ,#tenantID# 
                ,69
                ,#qryInvoice.cappliestoacctperiod#
                ,getdate()
                ,1 
                ,'Community Fee'
                ,#form.NRFDISC#
                 ,#CreateODBCDateTime(session.AcctStamp)#
                ,#session.userid#
                ,getdate()
                ,'Community Fee')
                </cfquery>		
		</cfif>
		<cfquery name="updtnantstate" datasource="#APPLICATION.datasource#">
			update tenantstate
			set mAdjNRF = #NRFDisc#
			,bNRFPend = Null
			where itenant_id = #tenantID#
		</cfquery> 
	</cfif> 
	</cfoutput>
</cftransaction>
<body>
<cfoutput>
<cflocation url="FinalizeAdjNRF.cfm?iTenant_ID=#tenantID#">
</cfoutput>
</body>


<cfoutput>
		<CFLOCATION URL="../MainMenu.cfm" ADDTOKEN="No">
</cfoutput> 
</html>
