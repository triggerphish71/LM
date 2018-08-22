

<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../../header.cfm">

<CFQUERY NAME = "ActivityCodes" DATASOURCE = "#APPLICATION.datasource#">
	SELECT 	*
	FROM	ACTIVITYTYPECODES
	ORDER BY	iActivity_ID
</CFQUERY>



<A HREF = "ActivityCodesEdit.cfm?Insert=1" CLASS = "summary">	Create New Activity Code </A>
<BR><BR>


	<TABLE STYLE = "width: 50%;">
		<TH COLSPAN = "2">	Activity Code Types Administration		</TH>
		
		<TR>
			<TD>	System ID			</TD>
			<TD>	Description			</TD>
			
		</TR>
<CFOUTPUT QUERY = "ActivityCodes">		
		<TR>
			<TD>	#ActivityCodes.iActivity_ID#	</TD>
			<TD>
					<A HREF="ActivityCodesEdit.cfm?ID=#ActivityCodes.iActivity_ID#">	#ActivityCodes.cDescription#	</A>
			</TD>
		</TR>
</CFOUTPUT>	
	</TABLE>

	
<CFOUTPUT>
<BR><BR>
	<A HREF="../../../Admin/Menu.cfm" STYLE="Font-size: 18;">Click Here to Go Back To Administration Page.</A>
</CFOUTPUT>


<!--- ==============================================================================
Include Intranet Footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../../footer.cfm">
