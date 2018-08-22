


<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">



<SCRIPT>
	function Letters(string) {
	for (var i=0, output='', valid="1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ -()/"; i<string.length; i++)
       if (valid.indexOf(string.charAt(i)) != -1)
          output += string.charAt(i)
    return output;	
	} 
</SCRIPT>


<!--- ==============================================================================
Retrieve all reason types
=============================================================================== --->
<CFQUERY NAME = "Reasons" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	MoveReasonType
	WHERE	dtRowDeleted IS NULL
	ORDER BY bIsVoluntary
</CFQUERY>


<CFOUTPUT>



<B STYLE="font-size: 18;">Move Reason Type Edit</B>
<BR>
<BR>

	<TABLE>
		<TR>
			<TH> Description	</TH>
			<TH> Display Order	</TH>
			<TH> Voluntary		</TH>
			<TH> Comments		</TH>
			<TH> Save			</TH>
			<TH> Delete			</TH>
		</TR>
		
		<CFLOOP QUERY = "Reasons"> 
			<FORM NAME="MoveOutReasonsEdit#Reasons.iMoveReasonType_ID#" ACTION="" METHOD="POST">	
					
				<TR>		
					<TD STYLE="width: 10%;">
						<INPUT TYPE="TEXT" NAME="cDescription" VALUE="#TRIM(Reasons.cDescription)#" onBlur="this.value=Letters(this.value);">
						<INPUT TYPE="Hidden" NAME="iMoveReasonType_ID" VALUE="#Reasons.iMoveReasonType_ID#">
					</TD>
					
					<TD STYLE="width: 10%; text-align: center;">
						<SELECT NAME="iDisplayOrder">
							<CFLOOP INDEX="N" FROM="1" TO="#Reasons.RecordCount#">
								<CFIF Reasons.iDisplayOrder EQ #N#>
									<CFSET Selected = 'Selected'>
								<CFELSE>
									<CFSET Selected =''>
								</CFIF>
								<OPTION Value="#N#" #SELECTED#> #N# </OPTION>
							</CFLOOP>
						</SELECT>
					</TD>
					
					<TD STYLE="width: 10%; text-align: center;">
						<SELECT Name="bIsVoluntary">
								<CFIF Reasons.bIsVoluntary GT 0>
									<CFSET Selected = 'Selected'>
								<CFELSE>
									<CFSET Selected =''>
								</CFIF>
							<OPTION VALUE = ""	#SELECTED#> No </OPTION>
							<OPTION VALUE = "1" #SELECTED#> Yes </OPTION>
						</SELECT>
					</TD>
					
					<TD STYLE="width: 25%;">
						<TEXTAREA COLS="30" ROWS="1" NAME="cComments">#TRIM(Reasons.cComments)#</TEXTAREA>
					</TD>
					
					<TD STYLE="width: 10%; text-align: center;">
						<INPUT CLASS="BlendedButton" TYPE="button" NAME="Save" VALUE="Save" STYLE="color: green;" onClick="document.MoveOutReasonsEdit#Reasons.iMoveReasonType_ID#.action='MoveOutReasonsUpdate.cfm'; submit();">
					</TD>
					
					<TD STYLE="width: 10%; text-align: center;">
						<INPUT CLASS="BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete"  onClick="location.href='DeleteMoveReason.cfm?ID=#Reasons.iMoveReasonType_ID#';">
					</TD>
				</TR>
				
				<TR>
					<TD HEIGHT="10" COLSPAN="6">  </TD>
				</TR>
			
			</FORM>
		</CFLOOP>
		
		<TR>
			<TD COLSPAN="6" STYLE="text-align: center;">
				<A HREF = "MoveOutReasons.cfm" STYLE="font-size: 18; color: red;">
					Click Here to exit the edit screen.
				</A>
			</TD>
		</TR>
	</TABLE>	
	
</CFOUTPUT>





<!--- ==============================================================================
Include Intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE = "../../../footer.cfm">