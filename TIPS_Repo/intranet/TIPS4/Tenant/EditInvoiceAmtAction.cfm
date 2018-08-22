<!---  -----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                               |
|------------|------------|---------------------------------------------------------------------------|
|S Farmer    | 08-1-2013  | Program to allow AR to directly edit mInvoiceTotal and mLastInvoiceTotal  |
|            |            | Ticket#109105                                                             |
-------------------------------------------------------------------------------------------------- --->
 
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
<cfoutput>#csolomonkey#, #iinvoicenumber#, #iinvoicemasterid#, 	#newinvoicetotal#, #newlastinvoicetotal#,
 
 <cfquery name="updInvMaster" datasource="#application.datasource#">
 update invoicemaster
 set mLastInvoiceTotal = <cfqueryparam  value="#newlastinvoicetotal#" cfsqltype="cf_sql_money"> 
 	,mInvoiceTotal = <cfqueryparam value="#newinvoicetotal#" cfsqltype="cf_sql_money">  
where cSolomonKey = '#csolomonkey#'
	and iInvoiceNumber =  <cfqueryparam value="#iinvoicenumber#" cfsqltype="cf_sql_varchar" >
	and iInvoiceMaster_ID = <cfqueryparam value="#iinvoicemasterid#" cfsqltype="cf_sql_integer">  
 </cfquery>
 <cfoutput><cflocation url="EditInvoiceAmts.cfm?solomonid=#csolomonkey#"></cfoutput>
</cfoutput>
</body>
</html>
