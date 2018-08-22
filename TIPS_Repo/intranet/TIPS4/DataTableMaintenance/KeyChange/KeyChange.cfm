
<!--- ==============================================================================
Retrieve list of Current Tenants for this House
=============================================================================== --->
<CFQUERY NAME="TenantList" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*, (T.cLastName + ', ' + T.cFirstName) as FullName
	FROM	Tenant T
		JOIN	TenantState TS
		ON	TS.iTenant_ID = T.iTenant_ID
	WHERE	T.dtRowDeleted IS NULL
	AND	TS.dtRowDeleted IS NULL
	AND	TS.iTenantStateCode_ID < 3
	AND	T.iHouse_ID = 200
	AND	T.bIsMedicaid IS NULL
	AND	T.bIsMisc IS NULL
	AND T.bIsDayRespite IS NULL
	ORDER BY T.cLastName
</CFQUERY>

<!--- ==============================================================================
Include Intranet header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">


<CFOUTPUT>

<FORM ACTION="KeyChangeSummary.cfm" METHOD="POST">
	<TABLE>
		<TR>
			<TH COLSPAN=4> Key Change for #SESSION.HouseName#</TH>
		</TR>
		<TR>
			<TD COLSPAN=2 STYLE="width: 50%;">
				Please, Select the person for Key Change 
			</TD>
			<TD COLSPAN=2 STYLE="width: 50%;">
				Please enter desired new Number.
			</TD>
		</TR>	
		<TR>	
			<TD COLSPAN=2>
				<SELECT NAME="iTenant_ID"> 
					<CFLOOP QUERY="TenantList">
						<OPTION VALUE="#TenantList.iTenant_ID#">
							#TenantList.FullName# #TenantList.cSolomonKey#
						</OPTION>
					</CFLOOP>
				</SELECT>				
			</TD>
		
			<TD COLSPAN=2>
				<INPUT TYPE="Text" NAME="cSolomonKey" VALUE="">
			</TD>
		</TR>	

		<TR>
			<TD COLSPAN=4 STYLE="text-align: center;">
				<INPUT TYPE="Submit" NAME="Submit" VALUE="Next" STYLE="width: 250px; color: green;">
			</TD>
		</TR>
	</TABLE>
</FORM>

</CFOUTPUT>


<!--- ==============================================================================
Include Intranet header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../footer.cfm">