<!---  -----------------------------------------------------------------------------------------------
| Author      | Date       | Ticket      | Description                                                |
|             |            | Project Nbr.|                                                            |
|  sfarmer    | 4/10/2012  |   75019     | EFT Update/NRF Deferral.                                   |
|  sfarmer    | 06/09/2012 | 75019       | NRF/Deferred Installation                                  |
|  sfarmer    | 06/09/2012 | 75019       | Adjustments for 2nd opp, respite, Idaho                    |
|  Sfarmer    | 09/18/2013 | 102919      |Revise NRF approval process                                 |
|S Farmer     | 05/20/2014 | 116824      |Move-In update  - Allow ED to adjust BSF rate               |
|S Farmer     | 05/20/2014 | 116824      |Phase 2 Allow different move-in and rent-effective dates    |
|             |            |             |allow respite to adjust BSF rates                           |
|S Farmer     | 08/20/2014 | 116824      | back-off different move-in rent-effective dates            |
|             |            |             |allow adjustment of rates by all regions                    |
|S Farmer     | 09/08/2014 | 116824      | Allow all houses edit BSF and Community Fee Rates          |
|S Farmer     | 2015-01-12 | 116824      | Final Move-in Enhancements                                 |
|SFarmer,     | 2015-09-28 |             | Medicaid, Memory Care Updates                              |
|MShah        |            |             |                                                            |
|SFarmer      | 05/02/2017 | Remove extraneous displays, comments & dumps,use error routine           |
|             |            |and display page                                                          |
 ------------------------------------------------------------------------------------------------  --->
<cfoutput>
<cfparam name="formatenddate" default="">
<cfparam name="formatbgndate" default="">
<cfset todaysdate = CreateODBCDateTime(now())>
<cfparam  name="chargeID" default="" >
<cfparam name="recurringtimes" default="1">
 
<!--- <cfdump var="#form#"> --->

 
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
	SELECT	*, t.cfirstname + ' ' + t.clastname as 'ResidentName'
	FROM	Tenant T
	JOIN	TenantState TS	ON	T.iTenant_ID = TS.iTenant_ID
	WHERE	T.dtRowDeleted IS NULL
	AND		TS.dtRowDeleted IS NULL
	AND		T.iTenant_ID = #form.iTenant_ID#
</CFQUERY>

<cfset dtrecchgstart = #CreateODBCDateTime(Tenant.dtmovein)#>
<CFSET MoveInPeriod = Year(Tenant.dtMoveIn) & DateFormat(Tenant.dtMoveIn,"mm")>
<!---  <br />MoveInPeriod:: #MoveInPeriod#<br />--->
<!--- ==============================================================================
Retrieve complete information for the selected charge
=============================================================================== --->
<CFQUERY NAME = "ChargeDetail" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*, C.cDescription as ChargeDescription, c.iCharge_ID, ct.iChargeType_ID
	FROM	Charges C
	JOIN	ChargeType CT	ON	C.iChargeType_ID = CT.iChargeType_ID
	WHERE	iCharge_ID = <CFIF isDefined("form.iCharge_ID") 
	and form.iCharge_ID NEQ ""> #form.iCharge_ID# <CFELSE> 0</CFIF>
	AND		C.dtRowDeleted IS NULL
</CFQUERY>


<!--- ==============================================================================
Retrieve the move in invoice number
=============================================================================== --->
<CFQUERY NAME="MoveInInvoice" DATASOURCE="#APPLICATION.datasource#">
	SELECT	distinct IM.iInvoiceMaster_ID, IM.cappliestoacctperiod
	FROM	InvoiceMaster IM
	LEFT JOIN 	InvoiceDetail INV	ON	(IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID 	
		AND INV.dtRowDeleted IS NULL 
		AND iTenant_ID = #form.iTenant_ID#)
	JOIN	Tenant T	ON	(T.iTenant_ID = #form.iTenant_ID#	
		AND T.cSolomonKey = IM.cSolomonKey	
		AND	T.dtRowDeleted is null)
	WHERE	IM.bMoveInInvoice IS NOT NULL
		AND	IM.dtRowDeleted IS NULL
		AND	IM.bFinalized IS NULL
</CFQUERY>
<cfset tipsperiod = year(session.tipsmonth) & dateformat(session.tipsmonth, 'mm')>
<cfif Isdefined("DEFENDDATE") and (DEFENDDATE is not "")>
	<cfset monthend = left(DEFENDDATE,2)>
	<cfset yearend = right(DEFENDDATE,4)>
	<cfset enddate = monthend & "-01-" &  yearend>
	<cfset lastday = #DaysInMonth(enddate)#>
	<cfset formatenddate =  monthend & "/" &  lastday  & "/" &yearend>
	<cfset formatenddate = #CreateODBCDateTime(formatenddate)#>	
</cfif>
	<cfset monthbgn =  #form.ApplyToMonth# >
	<cfset yearbgn =  #form.ApplyToYear# >
	<cfset bgndate = #monthbgn# & "-01-" &  #yearbgn#>
	<cfset formatbgndate =  #monthbgn# & "/01/" &#yearbgn#>
	<cfset formatbgndate =  #CreateODBCDateTime(formatbgndate)#>
	
<!--- 
	Begin Date: <cfif Isdefined('formatbgndate')>#formatbgndate# </cfif>
	End Date:: <cfif isdefined('formatenddate')>#formatenddate#</cfif>
   ---> 
   
	<cfif IsDefined("ChargeIsRecurring") and ChargeIsRecurring is "Yes"> 
		<CFQUERY NAME="BSFInvoiceCount" DATASOURCE="#APPLICATION.datasource#">
		SELECT	cappliestoacctperiod
		FROM	InvoiceDetail INV
		WHERE	INV.iInvoiceMaster_ID = #MoveInInvoice.iInvoiceMaster_ID#
		AND	 INV.dtRowDeleted IS NULL and INV.ichargetype_id in (1682, 89,1748,1756)
 		and INV.cappliestoacctperiod >= #MoveInPeriod#  
		</CFQUERY>
<!--- 		<cfdump var="#BSFInvoiceCount#"> --->
		<cfset recurringtimes = BSFInvoiceCount.recordCount>
	<cfelse>
		<cfset recurringtimes = 1> 
	</cfif>
 
<!--- 
<cfdump var="#BSFInvoiceCount#" label="BSFInvoiceCount">  
<br />recurringtimes:: #recurringtimes#  BSFInvoiceCount::#BSFInvoiceCount.cappliestoacctperiod# >= #MoveInPeriod#
<br />tipsperiod:: #tipsperiod#
  --->
 

 
<CFIF isDefined("form.iCharge_ID") and form.iCharge_ID NEQ "" and ChargeDetail.iChargeType_ID is not 89> 
<!--- <br /> not 89 --->
		<cfset acctperiod = #applytoyear#&#applytomonth# >
		<cfset chgstart = #applytoyear#&'-'&#applytomonth#&'-01' >	
		<!--- <cfset acctperiodstart = #MoveInPeriod#> --->	
<!--- <br /> #MoveInPeriod# gte #acctperiod#  --->
		<cfif IsDefined("ChargeIsRecurring") and ChargeIsRecurring is "Yes"> 
<!--- <br />recurring chg	 --->
			<cfloop  query="BSFInvoiceCount"> 
	<!--- 			 <br />BSFInvoiceCount.cappliestoacctperiod::#BSFInvoiceCount.cappliestoacctperiod#  
						acctperiod:: #acctperiod#  gte MoveInPeriod:#MoveInPeriod#   
						and #acctperiod# gte #MoveInPeriod# and #acctperiod# lt  #tipsperiod# --->
			 
				<cfif (#BSFInvoiceCount.cappliestoacctperiod# gte #acctperiod#)><!--- acctperiod --->
			<!--- 	  #BSFInvoiceCount.cappliestoacctperiod# gte #acctperiod# <br /> --->
					<cfif (#acctperiod# gte #MoveInPeriod#) >
				<!---  (#acctperiod# gte #MoveInPeriod#) <br /> --->
				 		<cfif (#acctperiod# lt  #tipsperiod#)> 
						<!--- 	 (#acctperiod# lt  #tipsperiod#) <br /> --->
					<cftry >	
					<CFQUERY NAME = "InvoiceDetail" DATASOURCE = "#APPLICATION.datasource#" result="InvoiceDetail">
						INSERT INTO 	InvoiceDetail
							( iInvoiceMaster_ID 
							,iTenant_ID 
							,iChargeType_ID 
							,cAppliesToAcctPeriod 
							,bIsRentAdj 
							,dtTransaction 
							,iQuantity 
							,cDescription
							,mAmount 
							,cComments ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart, dtRowEnd,iDaysBilled)
						VALUES
							( #MoveInInvoice.iInvoiceMaster_ID#,
							#form.iTenant_ID#,
							#ChargeDetail.iChargeType_ID#,
							#BSFInvoiceCount.cappliestoacctperiod#,
							1,
							#todaysdate#,
							<CFIF NOT IsDefined("form.iQuantity")>
								#ChargeDetail.iQuantity#, 
							<CFELSE> 
								#TRIM(form.iQuantity)#, 
							</CFIF>
							<CFIF NOT IsDefined("form.cDescription")>
								'#ChargeDetail.ChargeDescription#', 
							<CFELSE>
								'#TRIM(form.cDescription)#', 
							</CFIF>
							<cfif NOT IsDefined("form.mAmount")>
								#ChargeDetail.mAmount#, 
							<CFELSE>
								#TRIM(form.mAmount)#,
							</CFIF>
							<CFIF (IsDefined("cComments") and (cComments is not ""))>
								'#TRIM(form.cComments)# MICI #BSFInvoiceCount.cappliestoacctperiod# #acctperiod#   #MoveInPeriod#',
							<CFELSE>
								'recurring #acctperiod#' gte #MoveInPeriod#  ,
							</CFIF>
							#CreateODBCDateTime(SESSION.AcctStamp)#,
							#SESSION.UserID#,
							<CFIF (IsDefined("formatbgndate") 
								and (formatbgndate is not ""))>#formatbgndate#,
							<CFELSE>
							NULL,
							</CFIF>
							<CFIF (IsDefined("formatenddate") 
								and (formatenddate is not ""))>#formatenddate#
							<CFELSE>
							NULL
							</CFIF>  			
						,#Daysinmonth(Tenant.dtRentEffective)#) 
					</CFQUERY>	
		<cfcatch type="any" >
          <cfset processname = "Resident Move In Recurring Charge" >
           <cfset residentID = #form.iTenant_ID#>
		   <cfset residentname = #tenant.ResidentName#>
          <cfset Formname = "MoveInCreditInsert.cfm">
          <CFSCRIPT>
				Msg1 = "Invoice Detail Charge Insert.<BR>";
				Msg1 = Msg1 & "Charge Description: #ChargeDetail.ChargeDescription#<br>";
				Msg1 = Msg1 & "Charge Type: #ChargeDetail.iChargeType_ID#<BR>";
				Msg1 = Msg1 & "Invoice Master: #MoveInInvoice.iInvoiceMaster_ID#";
			</CFSCRIPT>
          <cfset wherefrom = 'MoveIn'>
          <cflocation url="../Shared/ErrorTemplate.cfm?processname=#processname#&Formname=#Formname#&wherefrom=#wherefrom#&residentID=#residentID#&residentname=#residentname#&Msg1=#Msg1#">					
		</cfcatch>
		</cftry>
					<!--- <cfdump var="#InvoiceDetail#">  --->
					</cfif> </cfif></cfif> <!--- acctperiod --->
				</cfloop>
			<cfelse><!--- <br />non recurring --->
			<cftry>
				<CFQUERY NAME = "InvoiceDetail" DATASOURCE = "#APPLICATION.datasource#" result="InvoiceDetail">
				INSERT INTO 	InvoiceDetail
				( iInvoiceMaster_ID 
				,iTenant_ID 
				,iChargeType_ID 
				,cAppliesToAcctPeriod 
				,bIsRentAdj 
				,dtTransaction ,iQuantity ,cDescription
				,mAmount ,cComments ,dtAcctStamp ,iRowStartUser_ID 
				,dtRowStart, dtRowEnd,iDaysBilled)
				VALUES
				( #MoveInInvoice.iInvoiceMaster_ID#,
				#form.iTenant_ID#,
				#ChargeDetail.iChargeType_ID#,
				#acctperiod#,
				1,
				#todaysdate#,
				<CFIF NOT IsDefined("form.iQuantity")>
					#ChargeDetail.iQuantity#, 
				<CFELSE> 
					#TRIM(form.iQuantity)#, 
				</CFIF>
				<CFIF NOT IsDefined("form.cDescription")>
					'#ChargeDetail.ChargeDescription#', 
				<CFELSE>
					'#TRIM(form.cDescription)#', 
				</CFIF>
				<cfif NOT IsDefined("form.mAmount")>
					#ChargeDetail.mAmount#, 
				<CFELSE>
					#TRIM(form.mAmount)#,
				</CFIF>
				<CFIF (IsDefined("cComments") and (cComments is not ""))>
					'#TRIM(form.cComments)# , 2, #MoveInPeriod# gte #acctperiod#',
				<CFElse>'non-recurring',
				</CFIF>
					#CreateODBCDateTime(SESSION.AcctStamp)#,
					#SESSION.UserID#,
				<CFIF (IsDefined("formatbgndate") 
					and (formatbgndate is not ""))>#formatbgndate#,
					<CFELSE>
					NULL,
					</CFIF>
				<CFIF (IsDefined("formatenddate") 
					and (formatenddate is not ""))>#formatenddate#
					<CFELSE>
					NULL
					</CFIF>  			
				,#Daysinmonth(Session.Tipsmonth)#) 
				</CFQUERY>
		<cfcatch type="any" >
          <cfset processname = "Resident Move In Non-Recurring Charge" >
           <cfset residentID = #form.iTenant_ID#>
		   <cfset residentname = #tenant.ResidentName#>
          <cfset Formname = "MoveInCreditInsert.cfm">
          <CFSCRIPT>
				Msg1 = "Invoice Detail Charge Insert.<BR>";
				Msg1 = Msg1 & "Charge Description: #ChargeDetail.ChargeDescription#<br>";
				Msg1 = Msg1 & "Charge Type: #ChargeDetail.iChargeType_ID#<BR>";
				Msg1 = Msg1 & "Invoice Master: #MoveInInvoice.iInvoiceMaster_ID#";
			</CFSCRIPT>
          <cfset wherefrom = 'MoveIn'>
          <cflocation url="../Shared/ErrorTemplate.cfm?processname=#processname#&Formname=#Formname#&wherefrom=#wherefrom#&residentID=#residentID#&residentname=#residentname#&Msg1=#Msg1#">					
		</cfcatch>
		</cftry>				
				<!--- <cfdump var="#InvoiceDetail#"> --->	 
			</cfif>	  <!--- recurring/not recurring --->   
		  </CFIF>  <!--- not 89 --->

	<cfif IsDefined("ChargeIsRecurring") and ChargeIsRecurring is "Yes"> 
	<!--- ==============================================================================
	Retrieve the number of BSF charges to match ancillary recurring charges             
	=============================================================================== --->
<cftry>
	<CFQUERY NAME = "InsertRecurringCharge" DATASOURCE = "#APPLICATION.datasource#" result="InsertRecurringCharge">
	 INSERT INTO [TIPS4].[dbo].[RecurringCharge]
			   ([iTenant_ID]
			   ,[iCharge_ID]
			   ,[dtEffectiveStart]
			   ,[dtEffectiveEnd]
			   ,[iQuantity]
			   ,[cDescription]
			   ,[mAmount]
				,[cComments]
			   ,[dtAcctStamp]
			   ,[iRowStartUser_ID]
			   ,[dtRowStart]
			   ,[iRowEndUser_ID]
			  )
		 VALUES
		 (
		 #form.iTenant_ID#
		 ,#ChargeDetail.iCharge_id#
		 ,#CreateODBCDateTime(chgstart)# <!--- #dtrecchgstart# --->
		 ,'2020-12-31'
		 ,1
		 ,<CFIF NOT IsDefined("form.cDescription")>
		  '#ChargeDetail.ChargeDescription#' 
		 <CFELSE>
		  '#TRIM(form.cDescription)#'
		  </CFIF>
		 ,<cfif NOT IsDefined("form.mAmount")>
		  #ChargeDetail.mAmount# 
		 <CFELSE>
		  #TRIM(form.mAmount)#
		   </CFIF>
		 ,<CFIF (IsDefined("cComments") and (cComments is not ""))>
		 '#TRIM(form.cComments)#'
		 <CFELSE>
		 NULL
		 </CFIF>	
		 ,#CreateODBCDateTime(SESSION.AcctStamp)#
		 ,#SESSION.UserID#
		 ,<CFIF (IsDefined("formatbgndate") and (formatbgndate is not ""))>
		 #formatbgndate#
		 <CFELSE>
		 NULL
		 </CFIF>
		 ,<CFIF (IsDefined("formatenddate") and (formatenddate is not ""))>
		 #formatenddate#
		 <CFELSE>
		 NULL
		 </CFIF>  
		 )
		 </CFQUERY>
			<cfcatch type="any" >
          <cfset processname = "Resident Move In Recurring Charge" >
           <cfset residentID = #form.iTenant_ID#>
		   <cfset residentname = #tenant.ResidentName#>
          <cfset Formname = "MoveInCreditInsert.cfm">
          <CFSCRIPT>
				Msg1 = "Recurring Charge Insert.<BR>";
				Msg1 = Msg1 & "Charge Description: #ChargeDetail.ChargeDescription#<br>";
			</CFSCRIPT>
          <cfset wherefrom = 'MoveIn'>
          <cflocation url="../Shared/ErrorTemplate.cfm?processname=#processname#&Formname=#Formname#&wherefrom=#wherefrom#&residentID=#residentID#&residentname=#residentname#&Msg1=#Msg1#">					
		</cfcatch>
		</cftry>
	<!--- <cfdump var="#InsertRecurringCharge#"> --->
		 <cfquery name="getRecurrinChargeID"  DATASOURCE = "#APPLICATION.datasource#">
			 Select iRecurringCharge_ID from recurringcharge
			 where itenant_id =  #form.iTenant_ID#
			 and icharge_id =  #ChargeDetail.iCharge_id# and dtrowdeleted is null
		 </cfquery>
		 <cfquery name="getRecurrinChargeID"  DATASOURCE = "#APPLICATION.datasource#">
			 update InvoiceDetail
			 set irecurringcharge_id = #getRecurrinChargeID.iRecurringCharge_ID#
			 where   itenant_id =  #form.iTenant_ID#
			 and iChargeType_id =  #ChargeDetail.iChargeType_ID# 
			 and dtrowdeleted is null
		 </cfquery>
	</cfif>	 
	<cfif IsDefined('CommFeePayment') and CommFeePayment is not ''>
		<cfquery name="updCommPaymnt"  DATASOURCE = "#APPLICATION.datasource#">
		Update tenantstate
		set iMonthsDeferred = CommFeePayment
		where itenant_id = #form.iTenant_ID#
		</cfquery>
	</cfif>
 
</CFTRANSACTION>
 
<!---   <CFIF SESSION.USERID IS 3863 or  SESSION.USERID IS 3506>
	<cfdump var="#session#" label="session">	
	<cfdump var="#FORM#" label="form">
		<A HREF="MoveInCredits.cfm?ID=#form.iTenant_ID#&MID=#MoveInInvoice.iInvoiceMaster_ID#&NrfDiscApprove=#NrfDiscApprove#">Continue</A>
	<CFELSE>  --->  
<CFLOCATION URL="MoveInCredits.cfm?ID=#form.iTenant_ID#&MID=#MoveInInvoice.iInvoiceMaster_ID#&NrfDiscApprove=#NrfDiscApprove#" 
		ADDTOKEN="No">
<!---  	</CFIF>  --->   
</CFOUTPUT>  
