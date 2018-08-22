<HTML>
<HEAD>
<TITLE>Untitled Document</TITLE>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
</HEAD>

<BODY>

<CFQUERY NAME='qMedicaidCharges' DATASOURCE='#APPLICATION.datasource#'>
	SELECT	T.iTenant_ID, (T.cLastName+', '+T.cFirstName) as FullName, AD.cAptNumber, CT.cDescription, count(INV.iInvoiceDetail_ID) as reccount, SUM(INV.mAmount * INV.iQuantity) as Total, INV.iChargeType_ID, 
			CT.bIsRent, CT.bIsMedicaid, CT.bIsModifiableAmount, CT.bIsModifiableDescription, CT.bIsModifiableQty, INV.iInvoiceDetail_ID
	FROM	InvoiceDetail INV (NOLOCK)
	JOIN	InvoiceMaster IM (NOLOCK) ON (INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND IM.dtRowDeleted IS NULL)
	JOIN 	Tenant T (NOLOCK) ON (INV.iTenant_ID = T.iTenant_ID AND T.dtRowDeleted IS NULL)
	JOIN	TenantState TS (NOLOCK) ON (T.iTenant_ID = TS.iTenant_ID AND TS.dtRowDeleted IS NULL)
	JOIN 	AptAddress AD (NOLOCK) ON (TS.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
	JOIN 	ChargeType CT (NOLOCK) ON (CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL)
	WHERE	INV.dtRowDeleted IS NULL 
	AND	T.iHouse_ID = 81
	AND	IM.cAppliesToAcctPeriod = '200302'
	AND	IM.bMoveInInvoice IS NULL
	AND CT.bIsMedicaid is not null
	AND IM.bMoveOutInvoice IS NULL
	GROUP BY INV.iChargeType_ID, T.cLastName, T.cFirstName, Ad.cAptNumber, CT.cDescription,T.cSolomonKey, T.iTenant_ID, CT.bIsRent, CT.bIsMedicaid, CT.bIsModifiableAmount, CT.bIsModifiableDescription, CT.bIsModifiableQty, INV.iInvoiceDetail_ID
	ORDER BY T.cLastName,INV.iChargeType_ID, T.cSolomonKey, CT.bIsRent, CT.bIsMedicaid, CT.bIsModifiableAmount, CT.bIsModifiableDescription, CT.bIsModifiableQty, INV.iInvoiceDetail_ID
</CFQUERY>



</BODY>
</HTML>
