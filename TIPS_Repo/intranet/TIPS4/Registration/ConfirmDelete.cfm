


<CFQUERY NAME = "Tenant" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	Tenant
	WHERE	iTenant_ID = 3992
</CFQUERY>


<CFINCLUDE TEMPLATE="../../header.cfm">



<CFOUTPUT>

<TABLE>
	<TH COLSPAN="4"> Confirm Delete</TH>
	
	<TR>
		<TD COLSPAN = "4"> You are chosing to delete...</TD>
	</TR>
	
	<TR>
		<TD>
			#Tenant.cFirstName# #Tenant.cLastName#<BR>
			#Tenant.cOutSideAddressLine1#<BR>
			#Tenant.cOutsideCity#,
			#Tenant.cOutsideStateCode# #Tenant.cOutsideZipCode#<BR>
			
		</TD>
	</TR>
</TABLE>
	
</CFOUTPUT>


<CFINCLUDE TEMPLATE="../../footer.cfm">