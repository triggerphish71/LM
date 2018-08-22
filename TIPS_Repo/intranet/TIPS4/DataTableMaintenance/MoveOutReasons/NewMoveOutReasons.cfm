


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
	SELECT	Max(iDisplayOrder) as Number
	FROM	MoveReasonType
	WHERE	dtRowDeleted IS NULL
</CFQUERY>


<CFSET NextDisplayNumber = #Reasons.Number# + 1>


<CFOUTPUT>



<B STYLE="font-size: 18;">Add New Move Reason Type</B>
<BR>
<BR>

	<TABLE>
		<TR>
			<TH> Description	</TH>
			<TH> Display Order	</TH>
			<TH> Voluntary		</TH>
			<TH> Comments		</TH>
			<TH> Save			</TH>
		</TR>
		
		
			<FORM NAME="NewMoveOutReasons" ACTION="" METHOD="POST">	
					
				<TR>		
					<TD STYLE="width: 10%;">
						<INPUT TYPE="TEXT" NAME="cDescription" VALUE="" onBlur="this.value=Letters(this.value);">
					</TD>
					
					<TD STYLE="width: 10%; text-align: center;">
						<SELECT NAME="iDisplayOrder">
							<CFLOOP INDEX="N" FROM="1" TO="#NextDisplayNumber#">
								<OPTION Value="#N#"> #N# </OPTION>
							</CFLOOP>
						</SELECT>
					</TD>
					
					<TD STYLE="width: 10%; text-align: center;">
						<SELECT Name="bIsVoluntary">
							<OPTION VALUE = "0"> No </OPTION>
							<OPTION VALUE = "1"> Yes </OPTION>
						</SELECT>
					</TD>
					
					<TD STYLE="width: 25%;">
						<TEXTAREA COLS="30" ROWS="1" NAME="cComments"></TEXTAREA>
					</TD>
					
					<TD STYLE="width: 10%; text-align: center;">
						<INPUT CLASS="BlendedButton" TYPE="button" NAME="Save" VALUE="Save" STYLE="color: green;" onClick="document.NewMoveOutReasons.action='MoveOutReasonsInsert.cfm'; submit();">
					</TD>
				</TR>
			
			</FORM>
		
		<TR>
			<TD COLSPAN="5" STYLE="text-align: center;">
				<A HREF="MoveOutReasons.cfm" STYLE="font-size: 18;" >
					Exit to the edit screen
				</A>
			</TD>
		</TR>
	</TABLE>	
	
</CFOUTPUT>





<!--- ==============================================================================
Include Intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE = "../../../footer.cfm">