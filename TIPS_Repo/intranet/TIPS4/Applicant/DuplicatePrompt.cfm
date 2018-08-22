

<!--- ==============================================================================
This will be used to check for duplicate entries 
When found an exception handling page will be generated
DO AFTER MOVE IN IS FINISHED (DUE TO DEADLINES)
=============================================================================== --->
	<CFQUERY NAME = "DuplicateCheck" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	*
		FROM 	TENANT
		WHERE	cFirstName 	= '#url.first#'
		AND		cLastName 	= '#url.Last#'
	</CFQUERY>

<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->	
<CFINCLUDE TEMPLATE="../../header.cfm">	
	
<CFOUTPUT>	
	<B STYLE="font-weight: bold; font-size: 20;"> There are #DuplicateCheck.RecordCount# tenants with this name. </B>
	<BR>	
</CFOUTPUT>
	<TABLE>
		<TR>	
			<TH> Name			</TH>
			<TH> Account Number	</TH>
			<TH> BirthDate		</TH>
			<TH> Social Security	</TH>
		</TR>	
		
			<CFOUTPUT QUERY="DuplicateCheck">
				<TR>
					<TD>	#DuplicateCheck.cFirstName# #DuplicateCheck.cLastName#	</TD>
					<TD STYLE="text-align: center;"> #DuplicateCheck.cSolomonKey# </TD>
					<TD>	#LSDateFormat(DuplicateCheck.dBirthDate, "mm/dd/yyyy")#		</TD>
					<TD> #LEFT(DuplicateCheck.cSSN,3)#-#MID(DuplicateCheck.cSSN,4,2)#-#RIGHT(DuplicateCheck.cSSN,4)# </TD>
				</TR>		
			</CFOUTPUT>
		
	</TABLE>
<!--- ==============================================================================
Include Intranet footer
=============================================================================== --->	
<CFINCLUDE TEMPLATE="../../footer.cfm">		
<CFABORT>