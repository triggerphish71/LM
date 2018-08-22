


<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">


<!--- ==============================================================================
Retrieve all reason types
=============================================================================== --->
<CFQUERY NAME = "Reasons" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	MoveReasonType
	WHERE	dtRowDeleted IS NULL
	ORDER BY bIsVoluntary, iDisplayOrder
</CFQUERY>


<CFOUTPUT>

<A HREF="../../Admin/Menu.cfm" STYLE="font-size: 14;">
	<B>Exit to the Administration Menu</B>
</A>
<BR>
<BR>


<TABLE>
	<TR>
		<TD COLSPAN="2" STYLE="background: white;">
			<B STYLE="font-size: 20;">Move Reason Type Administration</B>
		</TD>
	</TR>
	<TR>
		<TD STYLE="background: white;">
			<A HREF = "MoveOutReasonsEdit.cfm" STYLE="font-size: 20;"> 
				<B>Edit Reasons</B>	
			</A>
		</TD>
		
		<TD STYLE="background: white;">
			<A HREF = "NewMoveOutReasons.cfm" STYLE="font-size: 20;"> <B>Add Reasons</B>	</A>
		</TD>
	</TR>
</TABLE>


	<TABLE>
		<TR>
			<TH> Description	</TH>
			<TH> Display Order	</TH>
			<TH> Voluntary		</TH>
			<TH> Comments		</TH>
		</TR>
		
		<CFLOOP QUERY = "Reasons"> 
			<TR>		
				<TD STYLE="width: 25%;">	
					#Reasons.cDescription#	
				</TD>
				
				<TD STYLE="width: 10%; text-align: center;">
					#Reasons.iDisplayOrder#
				</TD>
				
				<TD STYLE="width: 10%; text-align: center;">
					<CFIF Reasons.bIsVoluntary GT 0>
						<CFSET Voluntary = 'Yes'>
					<CFELSE>
						<CFSET Voluntary = 'No'>
					</CFIF>
					#Variables.Voluntary#
				</TD>
				
				<TD STYLE="width: 25%;">
					#Reasons.cComments#
				</TD>
			</TR>
		</CFLOOP>
		
	</TABLE>	

	
</CFOUTPUT>


<A HREF="../../Admin/Menu.cfm" STYLE="font-size: 18;">
	<B>Exit to the Administration Menu</B>
</A>




<!--- ==============================================================================
Include Intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE = "../../../footer.cfm">