<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!--- ---------------------------------------------------------------------------------|
 | Name       | Date       | Ticket/     |           Description                       |
 |            |            | Project Nbr.|                                             |
 |-------------------------------------------------------------------------------------|
 |Sfarmer     | 09/18/2013 | 102919      |Revise NRF approval process                  |
 |S Farmer    | 2015-01-12 | 116824      | Final Move-in Enhancements                  |
 --------------------------------------------------------------------------------- --->
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>FinalizedAdjNRFInvoice</title>
</head>
<CFQUERY NAME="updMovedInState" datasource = "#APPLICATION.datasource#">
	UPDATE	TenantState
	SET		bNRFPend = null
			,cNRFAdjApprovedBy = '#session.username#'
			,dtNRFAdjApproved = getdate()
	WHERE	iTenant_ID = #url.iTenant_ID# 
</CFQUERY>

<CFQUERY NAME="qryTenant" datasource = "#APPLICATION.datasource#">
	select t.csolomonkey, ts.iNRFMid, ts.dtRentEffective, cChargeSet
	,ts.iresidencytype_id, t.itenant_id,aa.IAPTTYPE_ID  
	,dtMoveIn, t.iHouse_ID, ts.iAptAddress_ID, ts.iSPoints, ts.IPRODUCTLINE_ID 
	from Tenant T
		join TenantState ts on t.itenant_id = ts.itenant_id
		JOIN 	House H on h.ihouse_id = T.ihouse_id	
		join AptAddress AA on ts.iAptAddress_ID = AA.iAptAddress_ID and aa.ihouse_id = t.ihouse_id
 	WHERE	t.iTenant_ID = #url.iTenant_ID#
</CFQUERY>

<cfif qryTenant.iNRFMid is not "">
	<CFQUERY NAME="MovedInState" datasource = "#APPLICATION.datasource#">
		UPDATE	InvoiceMaster
		SET		bFinalized = 1
		WHERE	iInvoiceMaster_ID = #qryTenant.iNRFMid#
	</CFQUERY>
	<cfquery name="updInvAmt" datasource = "#APPLICATION.datasource#">
		update invoicemaster  
		set minvoicetotal = (select sum (inv.iquantity * inv.mamount)
		from invoicedetail inv
		join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id
		where im.iinvoicemaster_id = #qryTenant.iNRFMid#
		and inv.dtrowdeleted is null and ichargetype_id <> 69)
		where iinvoicemaster_id = #qryTenant.iNRFMid#   and csolomonkey = #qryTenant.csolomonkey#	
	</cfquery>
</cfif>
<!---  --->
<CFQUERY NAME='qMIDetails' DATASOURCE='#APPLICATION.datasource#'>
	select *, inv.cdescription
	from invoicemaster im
	join invoicedetail inv on inv.iinvoicemaster_id = im.iinvoicemaster_id and inv.dtrowdeleted is null and im.dtrowdeleted is null
	join chargetype ct on ct.ichargetype_id = inv.ichargetype_id and ct.dtrowdeleted is null and ct.bisrent is not null and bSLevelType_ID is null
	where im.iinvoicemaster_id = #qryTenant.iNRFMid#
	and	inv.cappliestoacctperiod = '#DateFormat(qryTenant.dtRentEffective,"yyyymm")#'
</CFQUERY>
<!--- ==============================================================================
Check how many occupants are currently in this room
Which determines occupancy
=============================================================================== --->
<CFQUERY NAME="RoomOccupancy" DATASOURCE = "#APPLICATION.datasource#">
	SELECT * FROM AptLog WHERE iAptAddress_ID = #qryTenant.iAptAddress_ID# AND dtRowDeleted IS NULL
</CFQUERY>

<CFTRANSACTION>

<CFLOOP QUERY='qMIDetails'>
	<CFQUERY NAME='qChargeID' DATASOURCE="#APPLICATION.datasource#">
		select
			*
		from
			charges
		where
			dtrowdeleted is null
		and getdate() between  dteffectivestart and  dteffectiveend	
		and ichargetype_id = #qMIDetails.iChargetype_ID#
		and ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
		and mamount = #qMIDetails.mAmount#
		and cchargeset <CFIF qryTenant.cChargeSet NEQ "">= '#qryTenant.cChargeSet#'<CFELSE>IS NULL</CFIF>
		and cdescription like <CFIF listlen(qMIDetails.cDescription,":") gt 1>'%#trim(listgetat(qMIDetails.cDescription,2,":"))#%'<CFELSE>'#qMIDetails.cDescription#'</CFIF>
	</CFQUERY>
<!--- 	<cfdump var="#qChargeID#"> --->
	<CFQUERY NAME = "StandardRent" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	*
			FROM	InvoiceDetail INV
			JOIN 	InvoiceMaster IM	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
			JOIN 	ChargeType CT		ON CT.iChargeType_ID = INV.iChargeType_ID
			WHERE	INV.dtRowDeleted IS NOT NULL
			AND		IM.dtRowDeleted IS NOT NULL
			AND		IM.bMoveInInvoice IS NOT NULL
			AND		INV.iTenant_ID = #qryTenant.iTenant_ID#
			AND		CT.bIsMedicaid IS NOT NULL
			AND		CT.bIsRent IS NOT NULL
 
	</CFQUERY>
	
	<CFQUERY NAME = "FindOccupancy" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	T.iTenant_ID, iResidencyType_ID, ST.cDescription as Level, TS.dtMoveIn, TS.dtMoveOut, TS.iSPoints
		FROM	AptAddress AD
		JOIN	TenantState TS	ON (TS.iAptAddress_ID = AD.iAptAddress_ID AND TS.dtRowDeleted IS NULL AND TS.iTenant_ID <> #qryTenant.iTenant_ID#)
		JOIN	Tenant T		ON (T.iTenant_ID = TS.iTenant_ID AND T.dtRowDeleted IS NULL AND	TS.iTenantStateCode_ID = 2 AND AD.iAptAddress_ID = TS.iAptAddress_ID)
		JOIN 	SLevelType ST	ON (ST.cSLevelTypeSet = T.cSLevelTypeSet AND TS.iSPoints between ST.iSPointsMin and ST.iSPointsMax)
		WHERE	AD.dtRowDeleted IS NULL
		AND		T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		AND		AD.iAptAddress_ID = #qryTenant.iAptAddress_ID#
	</CFQUERY>
	<CFIF FindOccupancy.RecordCount GT 0> <CFSET Occupancy = 2> <CFELSE> <CFSET Occupancy = 1> </CFIF>
	
	<CFQUERY NAME="CheckCompanionFlag" DATASOURCE="#APPLICATION.datasource#">
		SELECT	bIsCompanionSuite
		FROM	AptAddress AD
		JOIN	AptType AT ON (AD.iAptType_ID = AT.iAptType_ID AND AT.dtRowDeleted is NULL)
		WHERE	AD.dtRowDeleted IS NULL
		AND		AD.iAptAddress_ID = #qryTenant.iAptAddress_ID#
	</CFQUERY>
	
	<CFIF CheckCompanionFlag.bIsCompanionSuite EQ 1> <CFSET Occupancy = 1> </CFIF>	
	
	<CFQUERY NAME="DailyRent" DATASOURCE="#APPLICATION.datasource#">
		<CFIF Occupancy EQ 1>
			SELECT	C.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
			FROM	Charges C
			JOIN	ChargeType CT ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
			WHERE	C.dtRowDeleted IS NULL
			<CFIF qryTenant.cChargeSet NEQ "" AND qryTenant.iResidencyType_ID NEQ 3> AND	C.cChargeSet = '#qryTenant.cChargeSet#' <CFELSE> AND C.cChargeSet IS NULL </CFIF>
			AND	CT.bIsRent IS NOT NULL
			AND	CT.bIsDiscount IS NULL AND CT.bIsRentAdjustment IS NULL AND CT.bIsMedicaid IS NULL
			<CFIF qryTenant.iResidencyType_ID EQ 3>AND (C.iAptType_ID IS NULL OR C.iAptType_ID = #qryTenant.iAptType_id#)<CFELSE>AND CT.bAptType_ID IS NOT NULL AND CT.bIsDaily IS NOT NULL AND	CT.bSLevelType_ID IS NULL</CFIF>
			AND	C.iResidencyType_ID = #qryTenant.iResidencyType_ID#
			AND	C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND	C.iAptType_ID = #qryTenant.iAptType_ID#
			AND	C.iOccupancyPosition = 1
			AND	dtEffectiveStart <= '#qryTenant.dtMovein#'
			AND dtEffectiveEnd >= '#qryTenant.dtMovein#'
			<CFIF qryTenant.cChargeSet NEQ '' AND qryTenant.iResidencyType_ID NEQ 3>AND C.cChargeSet = '#qryTenant.cChargeSet#'<CFELSE>AND C.cChargeSet IS NULL</CFIF>
			AND C.iProductLine_ID = #qryTenant.iProductLine_ID#
			ORDER BY C.dtRowStart Desc
		<CFELSE>
			SELECT	C.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
			FROM	Charges C
			JOIN	ChargeType CT ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
			WHERE	C.dtRowDeleted IS NULL
			<CFIF qryTenant.cChargeSet NEQ "" AND qryTenant.iResidencyType_ID NEQ 3> AND	C.cChargeSet = '#qryTenant.cChargeSet#' <CFELSE> AND C.cChargeSet IS NULL </CFIF>
			AND	CT.bIsRent IS NOT NULL
			AND	CT.bIsDiscount IS NULL AND CT.bIsRentAdjustment IS NULL AND CT.bIsMedicaid IS NULL
			AND	CT.bAptType_ID IS NOT NULL AND CT.bIsDaily IS NOT NULL 	AND	CT.bSLevelType_ID IS NULL
			<CFIF qryTenant.iResidencyType_ID EQ 3>AND (C.iAptType_ID IS NULL OR C.iAptType_ID = #qryTenant.iAptType_id#)<CFELSE>AND C.iAptType_ID IS NULL</CFIF>
			AND	C.iResidencyType_ID = #qryTenant.iResidencyType_ID#
			AND	C.iOccupancyPosition = 2
			AND	C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND	dtEffectiveStart <= '#qryTenant.dtMovein#'
			AND dtEffectiveEnd >= '#qryTenant.dtMovein#'
			<CFIF qryTenant.cChargeSet NEQ '' AND qryTenant.iResidencyType_ID NEQ 3>AND C.cChargeSet = '#qryTenant.cChargeSet#'<CFELSE>AND C.cChargeSet IS NULL</CFIF>
			AND C.iProductLine_ID = #qryTenant.iProductLine_ID#
			ORDER BY C.dtRowStart Desc
		</CFIF>
	</CFQUERY>
	<CFIF qChargeID.recordcount GT 0 AND len(qChargeID.cDescription) GT 0 and qryTenant.iresidencytype_id neq 3>
		Inserting RandB same as house rate<BR>
	<cfoutput>HERE::	#qryTenant.iTenant_id# ,#qChargeID.iCharge_ID# ,getdate() ,DateAdd("yyyy",10,getdate()) ,1 ,'#TRIM(qChargeID.cDescription)#' ,#qChargeID.mAmount#,
			  'Recurring created at move in' ,#CreateODBCDateTime(SESSION.AcctStamp)# ,#SESSION.USERID# ,getdate()<br /></cfoutput>
 		<CFQUERY NAME='qInsertRecurring' DATASOURCE='#APPLICATION.datasource#'>
			INSERT INTO RecurringCharge
			( iTenant_ID, iCharge_ID, dtEffectiveStart, dtEffectiveEnd, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart)
			VALUES
			( #qryTenant.iTenant_id# ,#qChargeID.iCharge_ID# ,getdate() ,DateAdd("yyyy",10,getdate()) ,1 ,'#TRIM(qChargeID.cDescription)#' ,#qChargeID.mAmount#,
			  'Recurring created at move in' ,#CreateODBCDateTime(SESSION.AcctStamp)# ,#SESSION.USERID# ,getdate() )
		</CFQUERY> 
 
	<cfelse>Not found in charges, going to look for chargetype 89 and description longer than NULL<BR>
		<!--- possibility that there is a recurring charge for R&B but that it differs from the House Rate (found in Charges) because of the new ability to update the R&B rate in the Move In Credits screen. Added by Katie on 11/4/03 --->
	 
		<cfif qMIDetails.iChargeType_ID is "89" AND len(qMIDetails.cDescription) GT 0>Inserting RandB- differs from house rate<BR>
			<CFQUERY NAME='qChargeID' DATASOURCE="#APPLICATION.datasource#">
				select
					*
				from
					charges
				where
					dtrowdeleted is null
				and
					ichargetype_id = #qMIDetails.iChargetype_ID#
				and
					ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
				and
					cchargeset <cfif qryTenant.cChargeSet neq "">= '#qryTenant.cChargeSet#'<cfelse>is null</cfif>
				and
					cdescription like <cfif listlen(qMIDetails.cDescription,":") gt 1> '%#trim(listgetat(qMIDetails.cDescription,2,":"))#%'
															<cfelse>'#trim(qMIDetails.cDescription)#'</cfif>
			</CFQUERY>
			<CFQUERY NAME='qInsertRecurring' DATASOURCE='#APPLICATION.datasource#'>
				INSERT INTO RecurringCharge
				( iTenant_ID, iCharge_ID, dtEffectiveStart, dtEffectiveEnd, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart)
				VALUES
				( #qMIDetails.iTenant_id# ,#qChargeID.iCharge_ID# ,getdate() ,DateAdd("yyyy",10,getdate()) ,1 ,'#TRIM(qChargeID.cDescription)#' ,#qMIDetails.mAmount#,
				  'Recurring created at move in' ,#CreateODBCDateTime(SESSION.AcctStamp)# ,#SESSION.USERID# ,getdate() )
			</CFQUERY>
		<cfelse>
		none found<br />
		</cfif>
	</CFIF>
</CFLOOP>
<!--- ==============================================================================
Create an Apartment Log entry. (dbo.APTLOG)
=============================================================================== --->
<CFQUERY NAME = "AptLogEntry" DATASOURCE = "#APPLICATION.datasource#">
	INSERT INTO	AptLog
	( iTenant_ID, iAptAddress_ID, cAppliesToAcctPeriod, dtActualEffective, cComments, iRoomOccupancy,
	  dtAcctStamp, iRowStartUser_ID, dtRowStart)
	 VALUES
	 ( #qryTenant.iTenant_ID# ,#qryTenant.iAptAddress_ID#
		<CFSET cAppliesToAcctPeriod = Year(SESSION.AcctStamp) & DateFormat(SESSION.AcctStamp, "mm")>
		,'#Variables.cAppliesToAcctPeriod#' ,NULL ,NULL ,#RoomOccupancy.RecordCount# ,#CreateODBCDateTime(SESSION.AcctStamp)# ,#SESSION.UserID#, getdate() )
</CFQUERY>

<!---   ============================================================================== --->
<cfoutput>Create an Activity Log entry (dbo.ACTIVITYLOG) ,#SESSION.UserID#</cfoutput><br />
<!--- ===============================================================================  --->
<CFQUERY NAME="ActivityLogEntry" DATASOURCE="#APPLICATION.datasource#">
	INSERT INTO ActivityLog
	( iActivity_ID, dtActualEffective, iTenant_ID, iHouse_ID, iAptAddress_ID, iSPoints,
		dtAcctStamp, iRowStartUser_ID, dtRowStart)
	VALUES
	( 2 ,#CREATEODBCDateTime(qryTenant.dtMoveIn)# ,#qryTenant.iTenant_ID# ,#qryTenant.iHouse_ID# ,#qryTenant.iAptAddress_ID#
		,#qryTenant.iSPoints# ,#CreateODBCDateTime(SESSION.AcctStamp)# ,#SESSION.UserID# ,getdate() )
</CFQUERY>
<!---  --->
		<cfquery name="GetRecurringRBChargeID" datasource="#application.datasource#">	
			select r.iRecurringCharge_ID 
			from RecurringCharge r
			join Charges c on (c.iCharge_ID = r.iCharge_ID
				and (c.iChargeType_ID = '#StandardRent.iChargeType_ID#' or c.iChargeType_ID = '#DailyRent.iChargeType_ID#'))
			where r.iTenant_ID = #qryTenant.iTenant_ID#
			and r.dtRowDeleted is null
		</cfquery>
		<cfquery name="GetInvoiceDetail" datasource="#application.datasource#">
		Select inv.iinvoicedetail_id
		from invoicedetail inv
		where inv.iinvoicemaster_id =  #qryTenant.iNRFMid# and inv.ichargeType_ID = 89 and dtrowdeleted is null
		</cfquery>
		<cfloop query="GetInvoiceDetail">
			<cfquery name="updInvDetl" datasource="#application.datasource#">
				update invoicedetail
					set irecurringcharge_id = #GetRecurringRBChargeID.iRecurringCharge_ID#
				where iinvoicedetail_id = #GetInvoiceDetail.iinvoicedetail_id#
			</cfquery>
		</cfloop>
</CFTRANSACTION>
<CFLOCATION URL="../MainMenu.cfm" ADDTOKEN="No">

<body>
</body>
</html>
