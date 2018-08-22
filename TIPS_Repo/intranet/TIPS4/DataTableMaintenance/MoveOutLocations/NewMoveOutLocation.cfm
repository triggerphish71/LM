<!----------------------------------------------------------------------------------------------
| DESCRIPTION: MO Location Add Display                            							   |
|----------------------------------------------------------------------------------------------|
| NewMoveOutLocation.cfm                                                       		       |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by: 		Datamaintenance/MoveOutLocations/MoveOutLocations.cfm          			   |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|RSchuette   |03/30/2010  |Created for Project 51267 - MO Codes								   |
|---------------------------------------------------------------------------------------------->
<cfoutput>
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
<form name="LocationDisp" action="NewMoveOutLocationInsert.cfm" method="POST">
	<TABLE>
		<TR>
			<TD COLSPAN="2" STYLE="background: white;">
				<B STYLE="font-size: 20;">Move Out Location Administration</B>
			</TD>
		</TR>
		
		<TR>
			<TD STYLE="background: white;font-size: 15;"> <B>Add Location</B>
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
				<td nowrap  STYLE="width: 45%;">
					<input type="text" name="MOLdesc" maxlength="50" >
				</td>
				<td nowrap STYLE="width: 45%;">
					<input type="text" name="MOLnotes" maxlength="150" >
				</td>
				<td nowrap STYLE="width: 10%;"> 
					<input type="submit" name="Save" value="Save" onmouseover="return Check();">
				</td>
			</tr>
		
	</TABLE>
</form>


</cfoutput>