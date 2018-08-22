<!----------------------------------------------------------------------------------------------
| DESCRIPTION - MoveOut/PDFinalize.cfm                                                         |
|----------------------------------------------------------------------------------------------|
| Create/Add New room to the house													           |
| Called by: 		MoveoutSummary.cfm														   |
| Calls/Submits:	Main Menu.cfm															   |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|Paul Buendia| 02/07/2002 | Original Authorship												   |
|			 | 03/01/2002 | Changes occupancy to check for same solomonkey				 	   |
|			 |			  |	different tenant id.											   |
| mlaw       | 08/07/2006 | Create an initial PDFinalize page                       	       |
| sathya     | 05/06/2010 | Project 20933 to handle the late fee                               |
| sfarmer    | 10/10/2012 | Project 75019 - added coding to add unpaid NRF deferred bal to     |
|            |            | invoice                                                            |
|S Farmer    | 2015-01-12 | 116824  Final Move-in Enhancements                                 |
|S Farmer    | 2017-01-10 | Add Details for populating iDaysBilled                             |
----------------------------------------------------------------------------------------------->


<!--- 08/07/2006 MLAW show menu button --->
<CFPARAM name="ShowBtn" default="True">

<!--- ==============================================================================
Check TipsMonth Correspondence
=============================================================================== --->
<CFQUERY NAME='qTipsMonth' DATASOURCE='#APPLICATION.datasource#'>
	select * from houselog where dtrowdeleted is null and ihouse_id = #SESSION.qSelectedHouse.iHouse_id#
</CFQUERY>
<CFIF CreateODBCDateTime(qTipsMonth.dtCurrentTipsMonth) NEQ CreateODBCDateTime(SESSION.TipsMonth)>
	<CENTER>
		<STRONG STYLE='color:navy;font-size:medium;'>
			Changes have been detected for this facility.<BR>
			You will be allowed to re-enter this process on the next page.<BR>
			<CFIF ShowBtn>
				<A HREF='../MainMenu.cfm'>Click Here to Continue</A>
			<CFELSE>
				<A HREF='../census/FinalizeMoveOut.cfm'>Click Here to Continue</A>
			</CFIF>
		</STRONG>
	</CENTER>
	<CFABORT>
</CFIF>

<!--- ==============================================================================
Set current period format YYYMM (as from Solomon)
=============================================================================== --->
<CFSET CurrPer = Year(SESSION.TipsMonth) & DateFormat(SESSION.TipsMonth, "mm")>

<!--- ==============================================================================
Set variable for timestamp to record corresponding times for transactions
=============================================================================== --->
<CFQUERY NAME="GetDate" DATASOURCE="#APPLICATION.datasource#">
	SELECT	getDate() as Stamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(GetDate.Stamp)>

<CFTRANSACTION>

<!--- 05/06/2010 Sathya project 20933 added cftry to the entire process so that one error occurs then it will rollback everything --->
  <cftry>   
<!--- project 20933 code end here --->

<!--- ==============================================================================
Retrieve tenant information
=============================================================================== --->
<CFQUERY NAME = "Tenant" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*, (T.cFirstName + ' ' + T.cLastName) as FullName ,ts.mAmtDeferred , ts.mAdjNRF as AdjNRF, ts.mAmtNRFPaid
	FROM	Tenant T
	JOIN 	TenantState TS	ON T.iTenant_ID = TS.iTenant_ID
	WHERE	T.dtRowDeleted IS NULL
	AND TS.dtRowDeleted IS NULL AND T.iTenant_ID = #url.ID#
</CFQUERY>

<!--- ==============================================================================
Retrieve the corresponding AREmail
=============================================================================== --->
<CFQUERY NAME = "GetEmail" DATASOURCE="#APPLICATION.datasource#">
	SELECT	Du.EMail as AREmail
	FROM	House H
	JOIN	#Application.AlcWebDBServer#.ALCWEB.dbo.employees DU ON H.iAcctUser_ID = DU.Employee_ndx
	WHERE	H.iHouse_ID = #Tenant.iHouse_ID#
</CFQUERY>

<!--- ==============================================================================
Change State of the tenant to moved out
=============================================================================== --->
<CFQUERY NAME = "StateChange" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE	TenantState
	SET		iTenantStateCode_ID = 3, iRowStartUser_ID = #SESSION.UserID#, dtRowStart = #TimeStamp#
	WHERE	iTenant_ID = #url.ID#
</CFQUERY>

<!--- ==============================================================================
Query to see if this there are two occupants in this apartment
=============================================================================== --->
<CFQUERY NAME="Occupancy" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	TenantState TS
	JOIN	Tenant T ON (T.iTenant_ID = TS.iTenant_ID AND T.dtRowDeleted IS NULL)
	WHERE	TS.dtRowDeleted IS NULL
	AND		T.itenant_ID <> #Tenant.iTenant_ID#
	AND		T.cSolomonKey = '#Tenant.cSolomonKey#'
	AND		TS.iTenantStateCode_ID = 2
</CFQUERY>

<!--- ==============================================================================
Retrieve normal invoice master id (non moveout)
=============================================================================== --->
<CFQUERY NAME = "CurrentInvoice" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	IM.iInvoiceMaster_ID
	FROM	InvoiceMaster IM
	JOIN	InvoiceDetail INV	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
	WHERE	bFinalized IS NULL
	AND		bMoveInInvoice IS NULL AND bMoveOutInvoice IS NULL AND IM.dtRowDeleted IS NULL and inv.dtrowdeleted is null
	AND		INV.iTenant_ID = #url.ID#
	AND		IM.cSolomonKey = '#Tenant.cSolomonKey#'
	AND		IM.cAppliesToAcctPeriod = '#CurrPer#'
</CFQUERY>
<!---<cfdump var="#CurrentInvoice#" label="CurrentInvoice">--->

<!--- ==============================================================================
	If there is an exising invoice...
	Loop over current non-moveout charges and insert into the moveout invoice
=============================================================================== --->
<CFOUTPUT>

<!--- ==============================================================================
Retrieve the Move Out Invoice Number
=============================================================================== --->
<CFQUERY NAME="InvoiceNumber" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	IM.iInvoiceMaster_ID
	FROM	InvoiceMaster IM
	JOIN 	Tenant T	ON	(T.cSolomonKey = IM.cSolomonKey AND T.dtRowDeleted IS NULL)
	WHERE	iTenant_ID = #url.ID#
	AND bMoveOutInvoice IS NOT NULL AND IM.dtRowDeleted IS NULL AND	IM.bFinalized IS NULL
</CFQUERY>
	
<CFIF CurrentInvoice.RecordCount GT 0> 

<!--- ==============================================================================
Retrieve all existing charges on account (non-move out)
=============================================================================== --->
	<CFQUERY NAME = "GetCharges" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	*, INV.cAppliesToAcctPeriod as DetailPeriod, CT.bIsRent
		<!--- 05/06/2010 Sathya Project 20933 added this --->
		,CT.iChargeType_ID as ChargeType_ID
		<!--- Project 20933 code end here --->
		FROM	InvoiceDetail INV
		JOIN 	InvoiceMaster IM	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
		JOIN 	ChargeType CT	ON CT.iChargeType_ID = INV.iChargeType_ID
		WHERE	iTenant_ID = #url.ID#
		AND bMoveOutInvoice IS NULL AND INV.dtRowDeleted IS NULL AND IM.bFinalized IS NULL AND CT.bIsRent IS NULL and CT.ichargetype_ID not in (1749,1750,8,14,1741,1710,13,1672,1685,1680) <!---Mshah added this to avoid state medicaid charge record insert--->
		                                                                                                                                 <!---Ganga 04/02 added monthly/communityfee (14,1741,1710,13,1672,1680) to avoid charge record insert--->
		AND		INV.iInvoiceMaster_ID = #CurrentInvoice.iInvoiceMaster_ID#
	</CFQUERY>
 <!---<cfdump var="#GetCharges#" label="GetCharges">  --->

	<CFLOOP QUERY = "GetCharges">
	<!--- ==============================================================================
	Insert current non-moveout charges into the moveout invoice
	=============================================================================== --->
	<!--- 05/06/2010 Sathya project 20933 added this field bNoInvoiceDisplay for  --->
		<CFQUERY NAME = "AddCharges" DATASOURCE = "#APPLICATION.datasource#" result="AddCharges">
				INSERT INTO 	InvoiceDetail
				(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
					dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, 
					dtRowStart
					<!--- 05/06/2010 Sathya project 20933 added this field bNoInvoiceDisplay for  --->
					,bNoInvoiceDisplay
					<!--- Project 20933 end of code --->
					,iDaysBilled
				)
					VALUES
				(   
					#InvoiceNumber.iInvoiceMaster_ID#, #url.ID#, #GetCharges.iChargeType_ID#,
					<CFIF GetCharges.cAppliesToAcctPeriod NEQ ""> 
						<CFSET cAppliesToAcctPeriod = #GetCharges.cAppliesToAcctPeriod#>
					<CFELSE>
						<CFSET cAppliesToAcctPeriod = #Year(SESSION.TIPSMonth)# & #DateFormat(SESSION.TIPSMonth, "mm")#>
					</CFIF>
					'#Variables.cAppliesToAcctPeriod#',							
					NULL,
					GetDate(),
					#GetCharges.iQuantity#, 
					'#GetCharges.cDescription#',
					#TRIM(GetCharges.mAmount)#,
					'#GetCharges.cComments#',
					#CreateODBCDateTime(SESSION.AcctStamp)#,
					#SESSION.UserID#,
					#TimeStamp# 
					<!--- 05/06/2010 Sathya project 20933 added this field bNoInvoiceDisplay for  --->
					<CFIF (GetCharges.bNoInvoiceDisplay EQ 1)> 
						<CFSET NoInvoiceDisplay = 1>
					<CFELSE>
						<CFSET NoInvoiceDisplay = 0>
					</cfif>
					, #Variables.NoInvoiceDisplay#
					<!--- Project 20933 end of code --->
					<cfif (GetCharges.iChargeType_ID eq 1748) or (GetCharges.iChargeType_ID eq 1682)>
					,getcharges.iDaysBilled
					<cfelse>
					,Null
					</cfif>
				)
		</CFQUERY> 
		<!---<cfdump var="#AddCharges#" label="AddCharges">--->

		<!--- ==============================================================================
		If the charge is a system charge and it is greater than or equal to the move out month
		then reverse the charge
		=============================================================================== --->
		<!--- 05/06/2010 Sathya Project 20933 Added a if condition do not do this step for late fee --->
		<cfif GetCharges.ChargeType_ID neq 1697 or GetCharges.ChargeType_ID neq 1741> 
		
		<!--- project 20933 code end here --->
	<CFQUERY NAME = "ReverseCharge" DATASOURCE = "#APPLICATION.datasource#" result="ReverseCharge">
				INSERT INTO 	InvoiceDetail
				(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
					dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, 
					dtRowStart,iDaysBilled
				)VALUES(					
					#InvoiceNumber.iInvoiceMaster_ID#, #url.ID#, #GetCharges.iChargeType_ID#,
					<CFIF GetCharges.cAppliesToAcctPeriod NEQ "">
						<CFSET cAppliesToAcctPeriod = #GetCharges.cAppliesToAcctPeriod#>
					<CFELSE>
						<CFSET cAppliesToAcctPeriod = #Year(SESSION.TIPSMonth)# & #DateFormat(SESSION.TIPSMonth, "mm")#>
					</CFIF>
					'#Variables.cAppliesToAcctPeriod#',
					NULL,
					GetDate(),
					#GetCharges.iQuantity#,
					<CFSET description = 'Credit for ' & #GetCharges.cDescription#> 
					'#Variables.Description#',
					#TRIM(GetCharges.mAmount * -1)#,
					'#GetCharges.cComments#',
					#CreateODBCDateTime(SESSION.AcctStamp)#,
					#SESSION.UserID#,
					#TimeStamp# ,
					<cfif (GetCharges.iChargeType_ID eq 1748) or (GetCharges.iChargeType_ID eq 1682)>
					getcharges.iDaysBilled
					<cfelse>
					Null
					</cfif>
				)
		</CFQUERY>	
		
		
		<!--- 05/06/2010 Sathya Project 20933 Added a if condition closing--->
		</cfif>
		<!--- project 20933 code end here --->
	
		<!--- 05/06/2010 sathya project 20933 added this --->
	<cfif GetCharges.ChargeType_ID eq 1697> 
	<!--- Get the Invoicedetail_Id which has been inserted just now in the invoicedetail table for the late fee --->
		<cfquery name="GetCurrentInvoiceDetailIDForLateFee" datasource="#APPLICATION.DataSource#">
			SELECT top 1 *   
			FROM InvoiceDetail
			WHERE iInvoiceMaster_Id = #InvoiceNumber.iInvoiceMaster_ID#
			and cAppliesToAcctPeriod = #GetCharges.cAppliesToAcctPeriod#	
			and iChargeType_ID = #GetCharges.iChargeType_ID#
			and iQuantity = 1
			and mAmount = #TRIM(GetCharges.mAmount)#
			and cDescription = '#GetCharges.cDescription#'
			and iTenant_Id = #url.ID#
			and dtrowdeleted is null
			order by iinvoicedetail_id desc
		</cfquery>
		<!--- 05/06/2010 Sathya project 20933 added the late fee --->
		<CFQUERY NAME = "GetMoveOutInvoiceInfo" DATASOURCE = "#APPLICATION.datasource#">
				SELECT	*
				FROM	InvoiceMaster IM
				JOIN 	Tenant T	ON	(T.cSolomonKey = IM.cSolomonKey AND T.dtRowDeleted IS NULL)
				WHERE	iTenant_ID = #url.ID#
				AND bMoveOutInvoice IS NOT NULL AND IM.dtRowDeleted IS NULL AND	IM.bFinalized IS NULL
			</CFQUERY>
		<!--- 05/06/2010 Sathya project 20933 added the late fee --->
			<CFQUERY NAME = "Getlatefeeinfo" DATASOURCE = "#APPLICATION.datasource#">
				Select *
				From TenantLateFee
				Where iinvoicedetail_id = #GetCharges.iInvoiceDetail_ID#
				and itenant_id = #url.ID#
				and dtrowdeleted is null
			</CFQUERY>
			<!--- 05/06/2010 Sathya project 20933 added the late fee. If the record exisit then update with the new invoicedetailid--->
			<!--- This is for the handling of the tenantlatefee table when the full payments are made --->
			<cfif GetLatefeeinfo.recordcount gt 0> 
			<CFQUERY NAME = "updatelatefeeinfo" DATASOURCE = "#APPLICATION.datasource#">
				UPDATE TenantLateFee
				Set iinvoicemaster_id = #InvoiceNumber.iInvoiceMaster_ID#,
					iinvoicedetail_id = #GetCurrentInvoiceDetailIDForLateFee.Iinvoicedetail_id#,
					iinvoicenumber  = '#GetMoveOutInvoiceInfo.iinvoicenumber#'
				Where iinvoicedetail_id = #GetCharges.iInvoiceDetail_ID#
				and iinvoicelatefee_id = #GetLatefeeinfo.iinvoicelatefee_id#
				and itenant_id = #url.ID#
				and dtrowdeleted is null
			</CFQUERY>
			</cfif>
			<!--- 05/06/2010 Sathya project 20933 deal with Partial payment --->
			<CFQUERY NAME = "Getpartiallatefeeinfo" DATASOURCE = "#APPLICATION.datasource#">
				Select *
				From TenantLateFeeAdjustmentDetail
				Where iinvoicedetail_id = #GetCharges.iInvoiceDetail_ID#
				and itenant_id = #url.ID#
				and dtrowdeleted is null
			</CFQUERY>
			<!--- 05/06/2010 sathya project 20933 deal with the partial payment --->
			<cfif Getpartiallatefeeinfo.recordcount gt 0> 
			<CFQUERY NAME = "updatelatefeeinfo" DATASOURCE = "#APPLICATION.datasource#">
				UPDATE TenantLateFeeAdjustmentDetail
				Set iinvoicemaster_id = #InvoiceNumber.iInvoiceMaster_ID#,
					iinvoicedetail_id = #GetCurrentInvoiceDetailIDForLateFee.Iinvoicedetail_id#,
					iinvoicenumber  = '#GetMoveOutInvoiceInfo.iinvoicenumber#'
				Where iinvoicedetail_id = #GetCharges.iInvoiceDetail_ID#
				and iinvoicelatefee_id = #Getpartiallatefeeinfo.iinvoicelatefee_id#
				and itenant_id = #url.ID#
				and dtrowdeleted is null
			</CFQUERY>
			</cfif>
		</cfif>
			
	<!--- project 20933 code end here --->
		

		
		<!--- ==============================================================================
		Flag the record as deleted
		=============================================================================== --->	
		<CFQUERY NAME = "DeleteRecord" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	InvoiceDetail
			SET		iRowDeletedUser_ID 	= 	#SESSION.UserID#, dtRowDeleted = #TimeStamp#
			WHERE	iInvoiceDetail_ID   = 	#GetCharges.iInvoiceDetail_ID#
		</CFQUERY>
		
	</CFLOOP>
		<!--- ==============================================================================
		Create Invoice detail entry for the unpaid amt of any NRF deferred balance          
		=============================================================================== --->	  
		<CFQUERY NAME = "NRFDefPaymntCnt" DATASOURCE = "#APPLICATION.datasource#">
		 select count (mamount) as dispnbrpaymentmade
			from invoicedetail inv  
			join invoicemaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and	itenant_id = #Tenant.itenant_id# 
			and inv.ichargetype_id  = 1741 
			and im.bMoveOutInvoice is null	
			and im.dtrowdeleted is null						
			and im.bFinalized = 1
		</CFQUERY>			
		<CFQUERY NAME = "NRFDefPaymntAmt" DATASOURCE = "#APPLICATION.datasource#">			
		 select sum (mamount) as Accum
			from invoicedetail inv  
			join invoicemaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and	inv.itenant_id =   #Tenant.itenant_id# 
			and inv.ichargetype_id  in (1741 <cfif NRFDefPaymntCnt.dispnbrpaymentmade EQ 0> ,69</cfif>)                    <!--- = 1741  trying to get Community fee at MOve in time  --->
			and im.bMoveOutInvoice is null
			and im.dtrowdeleted is null	
			and inv.dtrowdeleted is null		
			and im.bFinalized = 1
		</CFQUERY>	

<cfif Tenant.AdjNRF is ""> 
 	<cfset thisadjnrf = 0>
<cfelse>
	<cfset thisadjnrf = Tenant.AdjNRF>
</cfif>

<cfif Tenant.mAmtNRFPaid is "">
 	<cfset thismAmtNRFPaid = 0>
<cfelse>
	<cfset thismAmtNRFPaid = Tenant.mAmtNRFPaid>
</cfif>

<cfif NRFDefPaymntAmt.Accum is "">
 	<cfset thisAccum = 0>
<cfelse>
	<cfset thisAccum= NRFDefPaymntAmt.Accum>
</cfif>

		<cfset NRFrembal =  thisadjnrf - thismAmtNRFPaid - thisAccum >
		<!--- <cfset NRFrembal = numberformat(NRFrembal,'999999.00')> --->		
 		<CFQUERY NAME="qRecordCheck1743" DATASOURCE="#APPLICATION.datasource#">
			SELECT	Count(*) as count1743
			FROM	InvoiceDetail
			WHERE	dtRowDeleted IS NULL AND iInvoiceMaster_ID = #InvoiceNumber.iInvoiceMaster_ID#	
					and ichargetype_id = 1743	
		</CFQUERY>
  	<cfif  (qRecordCheck1743.count1743 is 0) > 
 		<cfif NRFrembal gt 0> 
			<CFQUERY NAME = "AddNrfDefRemainingCharges" DATASOURCE = "#APPLICATION.datasource#" result="AddNrfDefRemainingCharges">
					INSERT INTO 	InvoiceDetail
					(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
						dtTransaction, iQuantity, cDescription, mAmount,  dtAcctStamp, iRowStartUser_ID, 
						dtRowStart, bNoInvoiceDisplay
					)
						VALUES
					(	#InvoiceNumber.iInvoiceMaster_ID#
					, #url.ID#
					, 1743
					<CFIF GetCharges.cAppliesToAcctPeriod NEQ ""> 
						<CFSET cAppliesToAcctPeriod = #GetCharges.cAppliesToAcctPeriod#>
					<CFELSE>
						<CFSET cAppliesToAcctPeriod = #Year(SESSION.TIPSMonth)# & #DateFormat(SESSION.TIPSMonth, "mm")#>
					</CFIF>
					,'#Variables.cAppliesToAcctPeriod#'
					,NULL
					,GetDate()
					,1
					, 'Deferred NRF Unpaid Balance'
					,#TRIM(NRFrembal)#
					,#CreateODBCDateTime(SESSION.AcctStamp)#
					,#SESSION.UserID#,#TimeStamp#
					, 0
					)
			</CFQUERY>
					<!---<cfdump var="#AddNrfDefRemainingCharges#">--->			
		</cfif> 
	</cfif>
	<CFIF Occupancy.RecordCount EQ 0> 
		<!--- ==============================================================================
		Flag the Invoice Header record as Deleted if this is the only occupant
		=============================================================================== --->
		<CFQUERY NAME = "DeletedHeader" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	InvoiceMaster
			SET		iRowDeletedUser_ID = #SESSION.UserID#, dtRowDeleted	= #TimeStamp#
			WHERE	iInvoiceMaster_ID = #CurrentInvoice.iInvoiceMaster_ID#
		</CFQUERY>
	<CFELSE>
		<!--- ==============================================================================
		Calculate the new invoice total
		=============================================================================== --->
		<CFQUERY NAME="NewInvoiceTotal" DATASOURCE="#APPLICATION.datasource#">
			SELECT	SUM(mAmount * iQuantity) as Total
			FROM	InvoiceDetail
			WHERE	iInvoiceMaster_ID = #CurrentInvoice.iInvoiceMaster_ID# AND dtRowDeleted IS NULL
			and ichargetype_id <> 69
		</CFQUERY>
			
		<!--- ==============================================================================
		Update the Invoice Header record with new total 
		=============================================================================== --->
		<CFQUERY NAME = "UpdateHeader" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	InvoiceMaster
			SET		mInvoiceTotal = #isBlank(NewInvoiceTotal.Total,0)#,
					cComments = 'Invoice has been changed due to 2nd tenant moveout.',
					iRowStartUser_ID = #SESSION.UserID#, 
					dtRowStart = #TimeStamp#
			WHERE	iInvoiceMaster_ID 	= #CurrentInvoice.iInvoiceMaster_ID#
		</CFQUERY>			
	</CFIF>
	
</CFIF>

</CFOUTPUT>

<!--- ==============================================================================
Check for prior record
=============================================================================== --->
<CFQUERY NAME="PriorActivity" DATASOURCE="#APPLICATION.datasource#">
	SELECT	* FROM ActivityLog WHERE dtRowDeleted IS NULL AND iTenant_ID = #url.ID# AND	iActivity_ID = 3
</CFQUERY>	
	
<CFIF PriorActivity.RecordCount EQ 0> 
	<!--- ==============================================================================
	Write Activity in the ActivityLog
	=============================================================================== --->
	<CFQUERY NAME = "RecordActivity" DATASOURCE = "#APPLICATION.datasource#">
		INSERT INTO ActivityLog
		( iActivity_ID, dtActualEffective, iTenant_ID, iHouse_ID, iAptAddress_ID, iSPoints, dtAcctStamp, iRowStartUser_ID, dtRowStart )
		VALUES
		( 	3, #CreateODBCDateTime(Tenant.dtChargeThrough)#, #url.ID#, #SESSION.qSelectedHouse.iHouse_ID#, #Tenant.iAptAddress_ID#, #Tenant.iSPoints#,
			'#SESSION.AcctStamp#', #SESSION.UserID#, #TimeStamp# )
	</CFQUERY>
<CFELSE>
	<CFQUERY NAME="UpdateActivity" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	ActivityLog
		SET		iRowStartUser_ID = #SESSION.UserID#,
				dtRowStart = #TimeStamp#,
				iActivity_ID = 3,
				dtActualEffective = #CreateODBCDateTime(Tenant.dtChargeThrough)#,
				iTenant_ID = #url.ID#,
				iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#, 
				iAptAddress_ID = #Tenant.iAptAddress_ID#,
				iSPoints = #Tenant.iSPoints#,
				dtAcctStamp = '#SESSION.AcctStamp#'
		WHERE	iActivityLog_ID = #PriorActivity.iActivityLog_ID#
	</CFQUERY>
</CFIF>
<br>

<CFQUERY NAME="qDeleteDetails" DATASOURCE="#APPLICATION.datasource#">
	update invoicedetail
	set dtrowdeleted=getdate(),irowdeleteduser_id='#SESSION.UserID#',crowdeleteduser_id='sys_pdmoveout'
	from invoicedetail inv
	join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.dtrowdeleted is null
	and inv.dtrowdeleted is null and im.bfinalized is null and im.bmoveoutinvoice is null and im.bmoveininvoice is null
	join tenant t on t.itenant_id = inv.itenant_id and t.dtrowdeleted is null
	join tenantstate ts on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null
	join house h on h.ihouse_id = t.ihouse_id and h.dtrowdeleted is null
	and ts.itenantstatecode_id = 3
	where t.itenant_id = #url.ID#
</CFQUERY>

	<!--- 05/06/2010 Sathya project 20933 added cfcatch to this entire process --->
   	<cfcatch type = "DATABASE" >
			 <cftransaction action = "rollback"/>
			<cfabort showerror="An error has occured when trying to finalize the move out.">
	</cfcatch>
	</cftry>  
	<!--- Project 20933 code end here --->
</CFTRANSACTION>

<!--- ==============================================================================
Create CSV Files For this MoveOut
=============================================================================== --->
  <CF_MoveOut iHouse_ID=#SESSION.qSelectedHouse.iHouse_ID# TipsMonth=#DateFormat(SESSION.TipsMonth,"yyyy-mm-dd")# iTenant_ID = #Tenant.iTenant_ID# DEBUG=0>


<CFIF Tenant.iTenantStateCode_ID EQ 2> 
	<CFSCRIPT>
		momessage =	"#Tenant.FullName# has been moved out of #SESSION.HouseName# by #SESSION.FullName#<BR><BR>";
		momessage = momessage & "Tenant: #Tenant.FullName#<BR>";
		momessage = momessage & "SolomonKey: #Tenant.cSolomonKey#<BR>";
		momessage = momessage & "Sever Time = #now()#<BR>";
		momessage = momessage & "____________________________________________________<BR>";
	</CFSCRIPT>

	<CFIF Tenant.iResidencyType_ID EQ 2> 
		RESIDENCY MEDICAID ************** <BR>
		
			<CFIF SESSION.qSelectedHouse.iHouse_ID NEQ 200> 
				<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="#GetEMail.AREmail#" 
				CC="#medicaidemails#" BCC="#session.developerEmailList#" 
				SUBJECT="New Medicaid Move Out #Tenant.FullName#">
					#momessage#
				</CFMAIL>	
			<CFELSE>
				<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="#GetEMail.AREmail#" 
				BCC="#session.developerEmailList#" 
				SUBJECT="New Medicaid Move Out #Tenant.FullName# test message">
					#momessage# <br> #medicaidemails#
				</CFMAIL>				
			
			</CFIF>
					
	<CFELSE>
		RESIDENCY PRIVATE ************** <BR>
<!--- 		<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="#GetEMail.AREmail#" BCC="#session.developerEmailList#" SUBJECT="New Move Out #Tenant.FullName#">
			#momessage#
		</CFMAIL>  --->	
		<cfif len(GetEMail.AREmail) gt 0>
			<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" 
				TO="#GetEMail.AREmail#" 
				BCC="#session.developerEmailList#" 
				SUBJECT="New Move Out #Tenant.FullName#">
					#momessage#
			</CFMAIL>	
		<cfelse>
			TO="#GetEMail.AREmail#" <br />
			BCC="#session.developerEmailList#" <br />
			SUBJECT="New Move Out #Tenant.FullName#"><br />
				#momessage#<br />
		</cfif>		
	</CFIF>

<!--- <CFDIRECTORY DIRECTORY="C:\Inetpub\wwwroot\intranet\TIPS4\MailLog\" ACTION="list" NAME="qDirList" FILTER="MoveOutMail.txt">
	<CFIF qDirList.RecordCount GT 0>
		<CFFILE ACTION="append" FILE="C:\Inetpub\wwwroot\intranet\TIPS4\MailLog\MoveOutMail.txt" OUTPUT="#momessage#">
	<CFELSE>
		<CFFILE ACTION="append" FILE="C:\Inetpub\wwwroot\intranet\TIPS4\MailLog\MoveOutMail.txt" OUTPUT="#momessage#">
	</CFIF>	--->
	
</CFIF>  

<!--- ==============================================================================
Relocate to the Main menu
=============================================================================== --->
<CFIF isDefined("auth_user") and auth_user eq 'ALC\PaulB'> 
	<CFIF ShowBtn> 
		<A HREF = "../MainMenu.cfm"> Continue </A>
	<CFELSE>
	<!--- 51267 - MO Codes - 4/8/2010 - RTS - Remove any MO links from Census, and going back to census --->
		<!--- <A HREF = "../census/FinalizeMoveOut.cfm"> Continue </A> --->
		<A HREF = "../MainMenu.cfm"> Continue </A>
		<!--- end 51267 --->
	</CFIF>
<CFELSE>
	<CFIF ShowBtn> 
		<CFLOCATION URL="../MainMenu.cfm" ADDTOKEN="No">
	<CFELSE>
	<!--- 51267 - MO Codes - 4/8/2010 - RTS - Remove any MO links from Census, and going back to census --->
	<!--- <CFLOCATION URL="../census/FinalizeMoveOut.cfm?TenantID=#Tenant.iTenant_ID#" ADDTOKEN="No"> --->
	<A HREF = "../MainMenu.cfm"> Continue </A>
	<!--- end 51267 --->
	</CFIF>
</CFIF>	