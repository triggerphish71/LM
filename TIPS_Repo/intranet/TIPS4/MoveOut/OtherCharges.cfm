
<CFQUERY NAME="ChargeTypes" DATASOURCE="#APPLICATION.datasource#">
	SELECT	iChargeType_ID, cGLAccount, cDescription
	FROM	ChargeType
	WHERE	dtRowDeleted IS NULL
</CFQUERY>

<CFIF IsDefined("form.iChargeType_ID")>
	<CFQUERY NAME="ChargeList" DATASOURCE="#APPLICATION.datasource#">
		SELECT	C.*
		FROM	Charges C
		JOIN	ChargeType CT	ON		C.iChargeType_ID = CT.iChargeType_ID
		WHERE	C.iChargeType_ID = #form.iChargeType_ID#
	</CFQUERY>
</CFIF>

<CFIF IsDefined("form.iCharge_ID")>
	<CFQUERY NAME="Charge" DATASOURCE="#APPLICATION.datasource#">
		SELECT	C.iCharge_ID, C.cDescription, C.mAmount, C.iQuantity,
				CT.bIsModifiableDescription, CT.bIsModifiableQty, CT.bIsModifiableAmount
		FROM	Charges C
		JOIN	ChargeType CT	ON		C.iChargeType_ID = CT.iChargeType_ID
		WHERE	iCharge_ID = #form.iCharge_ID#
	</CFQUERY>
</CFIF>


<CFOUTPUT>

	<TABLE STYLE="width: 100%;">	
	<FORM ACTION="OtherCharges.cfm" METHOD="POST">
	
		<CFIF NOT IsDefined("form.iChargeType_ID") AND NOT IsDefined("form.iCharge_ID")>
			<TR>
				<TD STYLE="width: 100%; text-align: left;">	
					<B>Select a Charge Type</B>
					<SELECT NAME="iChargeType_ID" onChange="submit()">
						<CFLOOP QUERY="ChargeTypes">
							<OPTION VALUE="#ChargeTypes.iChargeType_ID#">
								#ChargeTypes.cGLAccount# : #ChargeTypes.cDescription#
							</OPTION>
						</CFLOOP>
					</SELECT>
				</TD>
			</TR>
		<CFELSEIF NOT IsDefined("form.iCharge_ID")>
			<TR>
				<TD>
					<B>Select a Charge</B>
					<SELECT NAME="iCharge_ID" onChange="submit()">
						<OPTION VALUE=""> Select from List	</OPTION>
						<CFLOOP QUERY="ChargeList">
							<OPTION VALUE="#ChargeList.iCharge_ID#">
								#ChargeList.cDescription#
							</OPTION>
						</CFLOOP>
					</SELECT>
				</TD>
			</TR>
		</CFIF>
		
		<CFIF IsDefined("form.iCharge_ID")>
			<TR>
				<TD STYLE="width: 8%;">$<INPUT TYPE="text" NAME="OtherAmount" VALUE="#LSCurrencyFormat(Charge.mAmount, "none")#" SIZE="7" STYLE="text-align: right; border: none; color: navy;" READONLY=""></TD>
				<TD STYLE="width: 5%;">#Charge.iQuantity#</TD>				
				<TD STYLE="width: 25%;">#Charge.cDescription#</TD>
			</TR>
		</CFIF>
	</FORM>
	</TABLE>	
</CFOUTPUT>