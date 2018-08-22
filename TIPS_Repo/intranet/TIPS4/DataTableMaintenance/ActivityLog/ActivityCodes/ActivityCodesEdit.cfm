



<!--- ==============================================================================
Check to see if url.insert is given signifying that we are adding a region.
Thus, calling HouseInsert.cfm instead of HouseUpdate.cfm
=============================================================================== --->
<CFIF IsDefined("Url.Insert")>

	<CFSET Variables.Action = 'ActivityCodesInsert.cfm'>

<CFELSE>

	<CFSET Variables.Action = 'ActivityCodesUpdate.cfm'>
		
</CFIF>

<CFIF SESSION.UserID IS 3025>
	<CFOUTPUT>
		#Variables.Action#
	</CFOUTPUT>
</CFIF>




<SCRIPT>
	
	
	function LettersNoSpaces(string) {
	for (var i=0, output='', valid="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"; i<string.length; i++)
       if (valid.indexOf(string.charAt(i)) != -1)
          output += string.charAt(i)
    return output;	
	} 

</SCRIPT>


<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../../header.cfm">


<!--- =============================================================================================
JavaScript to redirect user to specified template if the Don't save button is pressed
============================================================================================= --->
<SCRIPT>	
	function redirect() {
		window.location = "ActivityCodes.cfm";
	}
</SCRIPT>



<!--- ==============================================================================
Include JavaScript Error Checking
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../Shared/JavaScript/ResrictInput.cfm">



<CFQUERY NAME = "ActivityCodes" DATASOURCE = "#APPLICATION.datasource#">
	SELECT 	*
	FROM	ACTIVITYTYPECODES

	<CFIF IsDefined("url.ID")>	
		WHERE	iActivity_ID = #url.ID#
	</CFIF>
	
	<CFIF IsDefined("url.Insert")>
		WHERE	iActivity_ID = 0
	</CFIF>

</CFQUERY>

<CFOUTPUT>
	<FORM ACTION = "#Variables.Action#" METHOD = "POST">
</CFOUTPUT>

	<TABLE STYLE = "width: 50%; text-align: center;">
		<TH COLSPAN = "2">	Activity Code Types Edit		</TH>
		
		<TR>
			<TD>	System ID				</TD>
			<TD>	Description	(no spaces)	</TD>
			
		</TR>

	<CFIF IsDefined("Url.ID")>
		<CFOUTPUT QUERY = "ActivityCodes">		
			<TR>
				<TD>#ActivityCodes.iActivity_ID#</TD>
				<TD><INPUT TYPE="Text" NAME="cDescription" Value="#ActivityCodes.cDescription#" maxlength="10" onKeyDown="this.value=LettersNoSpaces(this.value);"></TD>
				<input type="hidden" name ="aid" value="#ActivityCodes.iActivity_ID#">
			</TR>
		</CFOUTPUT>
	<CFELSE>
			<TR>
				<TD><input type="hidden" name ="aid" value="#ActivityCodes.iActivity_ID#"></TD>
				<TD><INPUT TYPE="Text" NAME="cDescription" Value="" onKeyDown="this.value=LettersNoSpaces(this.value);" onKeyUp="this.value=LettersNoSpaces(this.value);"></TD>
			</TR>
	</CFIF>
	<TR>
		<TD style="text-align: left;"><INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save"	VALUE="Save"></TD>
		<TD STYLE="Text-align: Right;"><INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" onClick="redirect()"></TD>
	</TR>
	<TR><TD COLSPAN="2" style="font-weight: bold; color: red;"> <U>NOTE:</U> You must SAVE to keep information which you have entered! </TD></TR>
	
	</TABLE>


</FORM>


<!--- ==============================================================================
Include Intranet Footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../../footer.cfm">
