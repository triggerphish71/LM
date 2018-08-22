<CFOUTPUT>

<CFQUERY NAME="qBankOne" DATASOURCE="TIPS4">
SELECT	H.cName, T.cSolomonKey, Sum(INV.mAmount * INV.iQuantity) as InvoiceTotal
FROM	Tenant T
JOIN	TenantState TS ON (T.iTenant_ID = TS.iTenant_ID AND TS.dtRowDeleted IS NULL AND T.dtRowDeleted IS NULL AND TS.iTenantStateCode_ID = 2)
JOIN	House H ON (H.iHouse_ID = T.iHouse_ID AND H.dtRowDeleted IS NULL)
JOIN	InvoiceDetail INV ON (INV.iTenant_ID = T.iTenant_ID AND INV.dtRowDeleted IS NULL)
JOIN	InvoiceMaster IM ON (IM.iInvoicemaster_ID = INV.iInvoiceMaster_ID AND IM.dtRowDeleted IS NULL)
WHERE	IM.bFinalized IS NULL
AND	IM.bMoveInInvoice IS NULL
AND	IM.bMoveOutInvoice IS NULL
AND	T.iHouse_ID <> 200
GROUP BY H.cName, T.cSolomonKey
ORDER BY H.cName
</CFQUERY>

</CFOUTPUT>