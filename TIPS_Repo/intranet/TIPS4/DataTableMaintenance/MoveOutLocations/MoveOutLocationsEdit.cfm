<!----------------------------------------------------------------------------------------------
| DESCRIPTION: MO Location edit display       		                        				   |
|----------------------------------------------------------------------------------------------|
| MoveOutLocationsEdit.cfm                                                            	       |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by: 		MoveOutLocations.cfm          											   |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|RSchuette   |03/30/2010  |Created for Project 51267 - MO Codes								   |
|SFarmer     | 05/12/2013 |corrected   MoveOutLocationUpdate.cfm to MoveOutLocationsUpdate.cfm |
|---------------------------------------------------------------------------------------------->
<cfif not IsDefined('URL.ID')   >
 
<p> A Move Out Location was not selected for editing.</p>
<p>Return to previous page and re-select Choice to update</p>
<a href="MoveOutLocations.cfm">Return</a>
<cfabort>

</cfif>
<cfoutput>

<!--- Get all MO Locations that are valid --->
<cfquery name="MOLocations" datasource="#application.datasource#">	
	Select * from TenantMOLocation 
	where iTenantMOLocation_ID = #URL.ID#
</cfquery>
	
	
	
	
<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">
<Script language="javascript">
	function Check(){
		if(document.LocationDisp.MOLdesc.value == ''){
			alert("Description of Move Out Location is required.");
			return false;
		}
	}
</Script>


<A HREF="../../Admin/Menu.cfm" STYLE="font-size: 14;">
	<B>Exit to the Administration Menu</B>
</A>
<BR>
<BR>
<form name="LocationDisp" action="MoveOutLocationsUpdate.cfm?ID=#MOLocations.iTenantMOLocation_ID#" method="POST">
	<TABLE>
		<TR>
			<TD COLSPAN="2" STYLE="background: white;">
				<B STYLE="font-size: 20;">Move Out Location Administration</B>
			</TD>
			
		</TR>
		
		<TR>
			<TD STYLE="background: white;font-size: 15;"> <B>Edit Locations</B>
			</TD>
			<TD STYLE="background: white;">
				<A HREF = "MoveOutLocations.cfm" STYLE="font-size: 15;"> 
					<B>Locations Listing</B>	
				</A>
			</TD>
		</TR>
		<TR><TD COLSPAN="100%"><HR></TD> </TR>
	
			<tr>
				<td>
					<u>Description</u>
				</td>
				<td>
					<u>Notes (optional)</u>
				</td>
			</tr>
			<tr>
				<td>
					#MOLocations.cDescription#
				</td>
				<td>
					#MOLocations.cNotes#
				</td>
			</tr>
			<tr>
				<td nowrap  STYLE="width: 45%;">
					<input type="text" name="MOLdesc" maxlength="50" value="#MOLocations.cDescription#">
				</td>
				<td nowrap STYLE="width: 45%;">
					<input type="text" name="MOLnotes" maxlength="150" value="#MOLocations.cNotes#">
				</td>
			
				<td > 
					<input type="submit" name="Save" value="Save" onmouseover="return Check();">
				</td>
			</Tr>	
	</TABLE>
</form>


</cfoutput>