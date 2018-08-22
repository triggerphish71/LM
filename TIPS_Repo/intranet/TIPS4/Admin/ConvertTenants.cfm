
<CFOUTPUT>
	#SESSION.nHouse#, #SESSION.HouseName#<BR>
</CFOUTPUT>

<CFQUERY NAME="qAptAddress" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	AptAddress
	WHERE	dtRowDeleted IS NULL
	AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</CFQUERY>

<CFQUERY NAME="OLD" DATASOURCE="OLDTIPS">
	SELECT	*, CASE
				WHEN (ACB.Relevance = 'Tenant' AND ACB.guarantor ='Yes') Then 1
				ELSE NULL
				END as bIsPayer
	FROM	Tenants ACT
			Left OUTER JOIN	BillingAddress ACB
			ON		ACT.cTenantID = ACB.cTenantID
	WHERE	ACT.nHouse = '#SESSION.nHouse#'
	AND		ACT.nUnitNumber < 997
	AND		(tenant_status_id = 2003 
				OR (tenant_status_ID IS NULL AND NOT Status IN(
														'Day Respite'
														,'System Acct'
														,'Pending AR'
														,'MovedOut'
														,'Inactive')
					)
			)
	ORDER BY nUnitNumber
</CFQUERY>

<CFOUTPUT>
	<TABLE Border=1>
			<TR>
				<TH>Room Number</TH>
				<TH>Converted Room ID</TH>
				<TH>cSolomonKey</TH>
				<TH>bIsPayer</TH>
				<TH>FirstName</TH>
				<TH>LastName</TH>
				<TH>BirthDate</TH>
				<TH>BirthDate Converted</TH>
				<TH>cSSN</TH>
				<TH>cOutsidePhoneNumber1</TH>
				<TH>cOutsideAddressLine1</TH>
				<TH>cOutsideCity</TH>
				<TH>cOutsideStateCode</TH>
				<TH>cOutsideZipCode</TH>
				<TH>cComments</TH>
				<TH>cChargeSet</TH>
				<TH>cSLevelTypeSet</TH>
			</TR>	
		<CFLOOP QUERY="OLD">
			<CFQUERY NAME="AptInfo" DBTYPE="Query">
				SELECT	*
				FROM	qAptAddress
				WHERE	cAptNumber = #OLD.nUnitNumber#
				ORDER BY cAptNumber
			</CFQUERY>			
			<TR>
				<TD>#AptInfo.cAptNumber#</TD>
				<TD>#AptInfo.iAptAddress_ID#</TD>
				<TD>#OLD.cTenantid#</TD>
				<TD>
					<CFIF OLD.bIsPayer NEQ "">
						#OLD.bIsPayer#
					<CFELSE>
						NULL
					</CFIF>
				</TD>
				<TD>#OLD.Fname#</TD>
				<TD>#OLD.LName#</TD>
				<TD>
					<CFIF TRIM(OLD.cBirthDate) NEQ "">
						#OLD.cBirthDate#
					<CFELSE>
						NULL
					</CFIF>
				</TD>
				<TD NOWRAP>
					<CFIF TRIM(OLD.cBirthDate) NEQ "">
						<CFIF YEAR(TRIM(OLD.cBirthDate)) LTE YEAR(Now())>
							#CreateODBCDateTime(OLD.cBirthDate)#
						<CFELSE>
							<B>#CreateODBCDateTime(OLD.cBirthDate)#</B>
						</CFIF>
					<CFELSE>
						NULL
					</CFIF>
				</TD>
				<TD NOWRAP>
					<CFIF TRIM(OLD.cSSN) NEQ "">
						<CFIF Len(TRIM(OLD.cSSN)) GTE 9>
							#OLD.cSSN#
						<CFELSE>
							<B>#OLD.cSSN#</B>
						</CFIF>
					<CFELSE>
						NULL
					</CFIF>
				</TD>
				<TD>
					<CFIF TRIM(OLD.EPhone) NEQ "">
						#OLD.DPhone#
					<CFELSEIF Len(TRIM(OLD.EPhone)) LT 10 AND TRIM(OLD.EPhone) NEQ "">
						<B>#OLD.DPhone#</B>
					<CFELSE>
						NULL
					</CFIF>
				</TD>
				<TD NOWRAP>
					<CFIF TRIM(OLD.Address) NEQ "">
						#OLD.Address#
					<CFELSE>
						NULL
					</CFIF>
				</TD>
				
				<TD>#OLD.City#</TD>
				<TD>#OLD.State#</TD>
				<TD>#OLD.Zip#</TD>
				<TD>cComments</TD>
				<TD>cChargeSet </TD>
				<TD>cSLevelTypeSet</TD>
			</TR>
		</CFLOOP>
	</TABLE>
</CFOUTPUT>