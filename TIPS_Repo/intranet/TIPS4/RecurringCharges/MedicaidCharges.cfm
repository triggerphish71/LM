<CFOUTPUT>
<HTML>
<HEAD>
<TITLE>Medicaid Edit</TITLE>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
</HEAD>

<LINK REL='stylesheet' TYPE='TEXT/CSS' HREF='http://gum/intranet/tips4/shared/style2.css'>

<BODY>

<CFQUERY NAME='qMedicaidCharges' DATASOURCE='#APPLICATION.datasource#'>
	SELECT	T.iTenant_ID, (T.cLastName+', '+T.cFirstName) as FullName, AD.cAptNumber, CT.cDescription, count(INV.iInvoiceDetail_ID) as reccount, SUM(INV.mAmount * INV.iQuantity) as Total, INV.iChargeType_ID, 
			CT.bIsRent, CT.bIsMedicaid, CT.bIsModifiableAmount, CT.bIsModifiableDescription, CT.bIsModifiableQty, INV.iInvoiceDetail_ID, INV.iInvoiceDetail_ID
	FROM	InvoiceDetail INV (NOLOCK)
	JOIN	InvoiceMaster IM (NOLOCK) ON (INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND IM.dtRowDeleted IS NULL)
	JOIN 	Tenant T (NOLOCK) ON (INV.iTenant_ID = T.iTenant_ID AND T.dtRowDeleted IS NULL)
	JOIN	TenantState TS (NOLOCK) ON (T.iTenant_ID = TS.iTenant_ID AND TS.dtRowDeleted IS NULL)
	JOIN 	AptAddress AD (NOLOCK) ON (TS.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
	JOIN 	ChargeType CT (NOLOCK) ON (CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL)
	WHERE	INV.dtRowDeleted IS NULL 
	AND	T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	AND	IM.cAppliesToAcctPeriod = '#DateFormat(SESSION.TipsMonth,"yyyymm")#'
	AND	IM.bMoveInInvoice IS NULL
	AND CT.bIsMedicaid is not null
	AND IM.bMoveOutInvoice IS NULL
	GROUP BY INV.iChargeType_ID, T.cLastName, T.cFirstName, Ad.cAptNumber, CT.cDescription,T.cSolomonKey, T.iTenant_ID, CT.bIsRent, CT.bIsMedicaid, CT.bIsModifiableAmount, CT.bIsModifiableDescription, CT.bIsModifiableQty, INV.iInvoiceDetail_ID
	ORDER BY T.cLastName,INV.iChargeType_ID, T.cSolomonKey, CT.bIsRent, CT.bIsMedicaid, CT.bIsModifiableAmount, CT.bIsModifiableDescription, CT.bIsModifiableQty, INV.iInvoiceDetail_ID
</CFQUERY>

<CFQUERY NAME='qTenants' DBTYPE='QUERY'>
	select distinct itenant_id, fullname from qMedicaidCharges
</CFQUERY>

<CFQUERY NAME='qChargeTypes' DBTYPE='QUERY'>
	select distinct ichargetype_id, cdescription from qMedicaidCharges
</CFQUERY>

<FORM ACTION='MedicaidUpdate.cfm' METHOD='POST'>
<A HREF='#HTTP.REFERER#'>Click here to go back.</A><BR>
<TABLE>
	<TR><TH>Full Name</TH><CFLOOP QUERY='qChargeTypes'><TH>#qChargeTypes.cDescription#</TH></CFLOOP></TR>
	<CFLOOP QUERY='qTenants'>
		<CFQUERY NAME='qDetails' DBTYPE='QUERY'>
			select * from qMedicaidCharges where itenant_id = #qTenants.itenant_id#
		</CFQUERY>
		<TR>
			<TD>#qDetails.fullname#</TD>
			<CFLOOP QUERY='qChargeTypes'>
				<CFQUERY NAME='qTenantCharges' DBTYPE='QUERY'>
					select * from qDetails where ichargetype_id = #qChargeTypes.iChargeType_Id#
				</CFQUERY>
				<TD STYLE='#right#'>
					<INPUT TYPE='text' NAME='Charge_#isBlank(qTenantCharges.iinvoicedetail_id,qChargeTypes.iChargeType_ID&'_'&qDetails.itenant_id)#' SIZE=7 VALUE='#TRIM(NumberFormat(qTenantCharges.Total,'999999.99-'))#' STYLE='#right#'>
					<INPUT TYPE='hidden' NAME='OLD_#isBlank(qTenantCharges.iinvoicedetail_id,qChargeTypes.iChargeType_ID&'_'&qDetails.itenant_id)#' SIZE=7 VALUE='#TRIM(NumberFormat(qTenantCharges.Total,'999999.99-'))#'>
				</TD>
			</CFLOOP>
		</TR>
	</CFLOOP>
	<TR><TD COLSPAN=100%><INPUT TYPE='submit' NAME='save' VALUE='Save'></TD></TR>
</TABLE>
</FORM>

</BODY>
</HTML>
</CFOUTPUT>