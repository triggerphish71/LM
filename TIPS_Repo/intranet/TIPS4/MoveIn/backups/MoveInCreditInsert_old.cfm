 <!--- 
  sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                           |
  sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                 |
  --->
<cfparam name="formatenddate" default="">
<cfparam name="formatbgndate" default="">
<cfset todaysdate = CreateODBCDateTime(now())>
<cfparam  name="chargeID" default="" >
 
<CFIF IsDefined("form.MAMOUNTINVOICEDETAILID") AND NOT IsDefined("form.itenant_id")>
	<CFQUERY NAME="qGetTenantFromDetail" DATASOURCE="#APPLICATION.datasource#">
		select itenant_id from invoicedetail where iinvoicedetail_id = #form.MAMOUNTINVOICEDETAILID#
	</CFQUERY>
	<CFSET form.iTenant_id=qGetTenantFromDetail.iTenant_id>
</CFIF>
 
<CFTRANSACTION>

<!--- ==============================================================================
Retrieve the move in date for this tenant
=============================================================================== --->
<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	Tenant T
	JOIN	TenantState TS	ON	T.iTenant_ID = TS.iTenant_ID
	WHERE	T.dtRowDeleted IS NULL
	AND		TS.dtRowDeleted IS NULL
	AND		T.iTenant_ID = #form.iTenant_ID#
</CFQUERY>

<CFSET MoveInPeriod = Year(Tenant.dtMoveIn) & DateFormat(Tenant.dtMoveIn,"mm")>

<!--- ==============================================================================
Retrieve complete information for the selected charge
=============================================================================== --->
<CFQUERY NAME = "ChargeDetail" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*, C.cDescription as ChargeDescription
	FROM	Charges C
	JOIN	ChargeType CT	ON	C.iChargeType_ID = CT.iChargeType_ID
	WHERE	iCharge_ID = <CFIF isDefined("form.iCharge_ID") and form.iCharge_ID NEQ ""> #form.iCharge_ID# <CFELSE> 0</CFIF>
	AND		C.dtRowDeleted IS NULL
</CFQUERY>

<!--- ==============================================================================
Retrieve the move in invoice number
=============================================================================== --->
<CFQUERY NAME="MoveInInvoice" DATASOURCE="#APPLICATION.datasource#">
	SELECT	distinct IM.iInvoiceMaster_ID
	FROM	InvoiceMaster IM
	LEFT JOIN 	InvoiceDetail INV	ON	(IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID 	AND INV.dtRowDeleted IS NULL 	AND iTenant_ID = #form.iTenant_ID#)
	JOIN	Tenant T	ON	(T.iTenant_ID = #form.iTenant_ID#	AND T.cSolomonKey = IM.cSolomonKey	AND	T.dtRowDeleted is null)
	WHERE	IM.bMoveInInvoice IS NOT NULL
	AND	IM.dtRowDeleted IS NULL
	AND	IM.bFinalized IS NULL
</CFQUERY>
<cfif Isdefined("DEFENDDATE") and (DEFENDDATE is not "")>
	<cfset monthend = left(DEFENDDATE,2)>
	<cfset yearend = right(DEFENDDATE,4)>
	<cfset enddate = monthend & "-01-" &  yearend>
	<cfset lastday = #DaysInMonth(enddate)#>
	<cfset formatenddate =  monthend & "/" &  lastday  & "/" &yearend>
	<cfset formatenddate = #CreateODBCDateTime(formatenddate)#>	
  <cfoutput>End Date:: #CreateODBCDateTime(formatenddate)#</cfoutput>
	<cfset monthbgn =  ApplyToMonth >
	<cfset yearbgn =  ApplyToYear >
	<cfset bgndate = monthbgn & "-01-" &  yearbgn>
	<cfset formatbgndate =  monthbgn & "/01/" &yearbgn>
	<cfset formatbgndate =  #CreateODBCDateTime(formatbgndate)#>	
  <cfoutput>Begin Date: #formatbgndate#  </cfoutput>  
</cfif>
 
<CFIF isDefined("form.iCharge_ID") and form.iCharge_ID NEQ "">
	<cfoutput>
<!--- 	<cfif form.ichargetype_id is 1740>
		<cfset mamount = mamount - nrfamount  >
	<CFQUERY NAME = "InvoiceDetail" DATASOURCE = "#APPLICATION.datasource#">
		INSERT INTO 	InvoiceDetail
		( iInvoiceMaster_ID ,iTenant_ID ,iChargeType_ID ,cAppliesToAcctPeriod ,bIsRentAdj ,dtTransaction ,iQuantity ,cDescription
			,mAmount ,cComments ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart, dtRowEnd,bNoInvoiceDisplay)
		VALUES
 		( #MoveInInvoice.iInvoiceMaster_ID#,
			#form.iTenant_ID#,
			#ChargeDetail.iChargeType_ID#,
			<CFIF IsDefined("form.ApplyToMonth") AND IsDefined("form.ApplyToYear")>'#form.ApplyToYear##form.ApplyToMonth#',<CFELSE>'#MoveInPeriod#',</CFIF>
			1,
			#todaysdate#,
			<CFIF NOT IsDefined("form.iQuantity")> #ChargeDetail.iQuantity#, <CFELSE> #TRIM(form.iQuantity)#, </CFIF>
			<CFIF NOT IsDefined("form.cDescription")> '#ChargeDetail.ChargeDescription#', <CFELSE> '#TRIM(form.cDescription)#', </CFIF>
			<cfif IsDefined("form.NRFAmount") >#amtDeferred#,<CFelseIF NOT IsDefined("form.mAmount")> #ChargeDetail.mAmount#, <CFELSE> #TRIM(form.mAmount)#, </CFIF>	
			<CFIF (IsDefined("cComments") and (cComments is not ""))>'#TRIM(form.cComments)#',<CFELSE>NULL,</CFIF>
			#CreateODBCDateTime(SESSION.AcctStamp)#,
			#SESSION.UserID#,
			 <CFIF (IsDefined("formatbgndate") and (formatbgndate is not ""))>#formatbgndate#,<CFELSE>NULL,</CFIF>
			 <CFIF (IsDefined("formatenddate") and (formatenddate is not ""))>#formatenddate#,<CFELSE>NULL,</CFIF> 
			 0  			
		) 
	 </CFQUERY>
	<cfelse> --->
		<CFQUERY NAME = "InvoiceDetail" DATASOURCE = "#APPLICATION.datasource#">
			INSERT INTO 	InvoiceDetail
			( iInvoiceMaster_ID ,iTenant_ID ,iChargeType_ID ,cAppliesToAcctPeriod ,bIsRentAdj ,dtTransaction ,iQuantity ,cDescription
				,mAmount ,cComments ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart, dtRowEnd)
			VALUES
			( #MoveInInvoice.iInvoiceMaster_ID#,
				#form.iTenant_ID#,
				#ChargeDetail.iChargeType_ID#,
				<CFIF IsDefined("form.ApplyToMonth") AND IsDefined("form.ApplyToYear")>'#form.ApplyToYear##form.ApplyToMonth#',<CFELSE>'#MoveInPeriod#',</CFIF>
				1,
				#todaysdate#,
				<CFIF NOT IsDefined("form.iQuantity")> #ChargeDetail.iQuantity#, <CFELSE> #TRIM(form.iQuantity)#, </CFIF>
				<CFIF NOT IsDefined("form.cDescription")> '#ChargeDetail.ChargeDescription#', <CFELSE> '#TRIM(form.cDescription)#', </CFIF>
			<!--- 	<cfif IsDefined("form.NRFAmount") >#amtDeferred#,<CFelseIF NOT IsDefined("form.mAmount")> #ChargeDetail.mAmount#, <CFELSE> #TRIM(form.mAmount)#, </CFIF>	 --->
			<cfif   NOT IsDefined("form.mAmount")> #ChargeDetail.mAmount#, <CFELSE> #TRIM(form.mAmount)#, </CFIF>
				<CFIF (IsDefined("cComments") and (cComments is not ""))>'#TRIM(form.cComments)#',<CFELSE>NULL,</CFIF>
				#CreateODBCDateTime(SESSION.AcctStamp)#,
				#SESSION.UserID#,
				 <CFIF (IsDefined("formatbgndate") and (formatbgndate is not ""))>#formatbgndate#,<CFELSE>NULL,</CFIF>
				 <CFIF (IsDefined("formatenddate") and (formatenddate is not ""))>#formatenddate#<CFELSE>NULL</CFIF>  			
			) 
		 </CFQUERY>	 
	 <!--- </cfif> --->
	 </cfoutput> 
	 
<!--- 	<cfif (iChargeType_ID is 1740)>
	<cfset thisamount = dollarformat(abs(amtDeferred) / ( month(formatenddate) - month(formatbgndate) +1))>
	 
 		<CFQUERY NAME = "queryChargeID1741" DATASOURCE = "#APPLICATION.datasource#"> 
			select c.icharge_id as chargeID, c.cDescription 
			from Charges c 
			join ChargeType ct on (ct.iChargeType_ID = c.iChargeType_ID)
			where c.iHouse_ID =#session.qSelectedHouse.iHouse_ID#
			and c.dtRowDeleted is null
			and   c.iChargeType_ID = 1741
		</cfquery>	
		
		<cfoutput>	
			<CFQUERY NAME = "InvoiceDetail" DATASOURCE = "#APPLICATION.datasource#">
			INSERT INTO 	InvoiceDetail
			( iInvoiceMaster_ID ,iTenant_ID ,iChargeType_ID ,cAppliesToAcctPeriod ,bIsRentAdj ,dtTransaction ,iQuantity ,cDescription
				,mAmount ,cComments ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart, dtRowEnd)
			VALUES 
			( #MoveInInvoice.iInvoiceMaster_ID#,
				#form.iTenant_ID#,
				1741,
				<CFIF IsDefined("form.ApplyToMonth") AND IsDefined("form.ApplyToYear")>'#form.ApplyToYear##form.ApplyToMonth#',<CFELSE>'#MoveInPeriod#',</CFIF>
				1,
				#todaysdate#,
				1,
				'#queryChargeID1741.cDescription#',
				#thisamount#,	
				<CFIF (IsDefined("cComments") and (cComments is not ""))>'#TRIM(form.cComments)#',<CFELSE>NULL,</CFIF>
				#CreateODBCDateTime(SESSION.AcctStamp)#,
				#SESSION.UserID#,
				 <CFIF (IsDefined("formatbgndate") and (formatbgndate is not ""))>  #formatbgndate# , <CFELSE>NULL,</CFIF>
				 <CFIF (IsDefined("formatenddate") and (formatenddate is not ""))> #formatenddate#  <CFELSE>NULL</CFIF>  			
			)  
		   </CFQUERY>
	   </cfoutput>	
 
		<cfif iChargeType_ID is 1737>
 		<CFQUERY NAME = "queryChargeID" DATASOURCE = "#APPLICATION.datasource#">
			select c.icharge_id as chargeID 
			from Charges c 
			join ChargeType ct on (ct.iChargeType_ID = c.iChargeType_ID)
			where c.iHouse_ID =#session.qSelectedHouse.iHouse_ID#
			and c.dtRowDeleted is null
			and   c.iChargeType_ID = 1737
			</cfquery>
		<cfelseif iChargeType_ID is 1740>
 		<CFQUERY NAME = "queryChargeID" DATASOURCE = "#APPLICATION.datasource#">
			select c.icharge_id as chargeID 
			from Charges c 
			join ChargeType ct on (ct.iChargeType_ID = c.iChargeType_ID)
			where c.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
			and c.dtRowDeleted is null
			and   c.iChargeType_ID  = 1740 
			</cfquery>
		</cfif>

	 	<cfset datestart =  CreateODBCDateTime(#ApplyToMonth#  & '/01/' & #ApplyToYear#) > 
	 <!---  	<cfset dateendmo = #left(defEndDate,2)#>  
		<cfset dateendyr = #right(defEndDate,4)#> --->	
<!---  --->
<!--- <cfset dtThisMonth = CreateDate(Year( dateendyr ), Month( dateendmo ),1) /> --->
<!---  <cfoutput>dtThisMonth: #dtThisMonth#</cfoutput> --->
 
<!--- <cfset dtLastDay = (DateAdd( "m", 1, dtThisMonth ) -1) />  --->

<!---  --->	
		<cfset dateend  = #CreateODBCDateTime(formatenddate)#>			
		<cfoutput>
 			<CFQUERY NAME = "RecurringChargeInsertDetail" DATASOURCE = "#APPLICATION.datasource#">
				INSERT INTO  RecurringCharge
						   (iTenant_ID
						   ,iCharge_ID
						   ,dtEffectiveStart
						   ,dtEffectiveEnd						
						   ,iQuantity
						   ,cDescription
						   ,mAmount
						   ,cComments
						   ,dtAcctStamp
						   ,iRowStartUser_ID
						   ,dtRowStart
						   ,bIsDaily  
						  )  
		 			 VALUES
						   (#form.iTenant_ID#
						   ,#queryChargeID.chargeID#
						   ,#datestart#
						   ,#dateend#
						   ,#iQuantity#
						   ,'#cDescription#'
						   ,#amtDeferred#
						   ,<cfif IsDefined('cComments')>'#cComments#'<cfelse>null</cfif>
						   ,#CreateODBCDateTime(SESSION.AcctStamp)#
						   ,#SESSION.UserID#
						   ,#todaysdate#
						    ,0
						  )	 
			  </CFQUERY> 
		</cfoutput>		
	<cfoutput> 		
			  <cfquery  name="qryIMID"  DATASOURCE = "#APPLICATION.datasource#">
			  select max ( iInvoicedetail_ID ) as   'maxIMID'
			  from  InvoiceDetail   
			  where   iInvoiceMaster_ID = #MoveInInvoice.iInvoiceMaster_ID#
			  </cfquery>	
		<CFQUERY NAME = "RecurringChargeInsertDetail" DATASOURCE = "#APPLICATION.datasource#">
				INSERT INTO  RecurringCharge
						   (iTenant_ID
						   ,iCharge_ID
						   ,dtEffectiveStart
						   ,dtEffectiveEnd						
						   ,iQuantity
						   ,cDescription
						   ,mAmount
						   ,cComments
						   ,dtAcctStamp
						   ,iRowStartUser_ID
						   ,dtRowStart
						   ,bIsDaily  
						  )  
		 			 VALUES
						   (#form.iTenant_ID#
						   ,#queryChargeID1741.chargeID#
						   ,#datestart#
						   ,#dateend#
						   ,#iQuantity#
						   ,'#queryChargeID171.cDescription#'
						   ,#thisamount#
						   ,<cfif IsDefined('cComments')>'#cComments#'<cfelse>null</cfif>
						   ,#CreateODBCDateTime(SESSION.AcctStamp)#
						   ,#SESSION.UserID#
						   ,#todaysdate#
						    ,0
						  )	 
			  </CFQUERY>
 
			  <cfquery  name="qryRCID"  DATASOURCE = "#APPLICATION.datasource#">
			  select max (iRecurringCharge_ID) as 'maxRCID'
			  from  RecurringCharge   
			  where  iTenant_ID = #form.iTenant_ID#
			  and iCharge_ID = #queryChargeID1741.chargeID#
			  </cfquery>	
			  <cfquery name="updIMD" DATASOURCE = "#APPLICATION.datasource#">
			  update dbo.InvoiceDetail
			  set iRecurringCharge_ID = #qryRCID.maxRCID#
			  where iInvoiceDetail_ID =  #qryIMID.maxIMID#
			  </cfquery>	  

		</cfoutput>	
	</cfif> --->

</CFIF>

</CFTRANSACTION>
 <CFOUTPUT>
	<CFIF SESSION.USERID IS 3025>
		<A HREF="MoveInCredits.cfm?ID=#form.iTenant_ID#&MID=#MoveInInvoice.iInvoiceMaster_ID#">Continue</A>
	<CFELSE>
		<CFLOCATION URL="MoveInCredits.cfm?ID=#form.iTenant_ID#&MID=#MoveInInvoice.iInvoiceMaster_ID#" ADDTOKEN="No">
	</CFIF>
</CFOUTPUT>  

 

