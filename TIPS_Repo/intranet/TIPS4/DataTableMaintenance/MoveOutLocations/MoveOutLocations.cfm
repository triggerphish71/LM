<!----------------------------------------------------------------------------------------------
| DESCRIPTION: MO Location Admin initial display                               				   |
|----------------------------------------------------------------------------------------------|
|                                                             		           |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by: 		admin/menu.cfm          												   |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|RSchuette   |03/30/2010  |Created for Project 51267 - MO Codes								   |
|---------------------------------------------------------------------------------------------->
<cfoutput>
	
<!--- Get all MO Locations that are valid --->
<cfquery name="MOLocations" datasource="#application.datasource#">	
	Select * from TenantMOLocation where dtrowdeleted is null order by cdescription
</cfquery>

<!--- Get all locations that are currently in use --->
<cfquery name="GetCurrentIDs" datasource="#application.datasource#">	
	Select iTenantMOLocation_ID 
	from tenantstate ts
	join tenant t on (t.iTenant_ID = ts.iTenant_ID 
						and t.dtRowDeleted is null)
	where ts.dtRowdeleted is null
	and ts.iTenantStateCode_ID in (2,3)
	and ts.iTenantMOLocation_ID = #MOLocations.iTenantMOLocation_ID#
</cfquery>
<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">



<A HREF="../../Admin/Menu.cfm" STYLE="font-size: 14;">
	<B>Exit to the Administration Menu</B>
</A>
<BR>
<BR>

<TABLE>
	<TR>
		<TD COLSPAN="2" STYLE="background: white;">
			<B STYLE="font-size: 20;">Move Out Location Administration</B>
		</TD>
	</TR>
	<TR>
		<TD STYLE="background: white;">
			<A HREF = "MoveOutLocationsEdit.cfm" STYLE="font-size: 15;"> 
				<B>Edit Locations</B>	
			</A>
		</TD>
		
		<TD STYLE="background: white;">
			<A HREF = "NewMoveOutLocation.cfm" STYLE="font-size: 15;"> <B>Add Location</B>	</A>
		</TD>
	</TR>
</TABLE>


	<TABLE>
		<TR>
			<TH> Description	</TH>
			<TH> Notes	</TH>
			<TH></TH>
		</TR>
		<CFLOOP QUERY = "MOLocations">
			<cfquery name="GetCurrentID" datasource="#application.datasource#">	
					Select iTenantMOLocation_ID 
					from tenantstate ts
					join tenant t on (t.iTenant_ID = ts.iTenant_ID 
										and t.dtRowDeleted is null
										and t.iHouse_ID = #session.qSelectedHouse.iHouse_ID#)
					where ts.dtRowdeleted is null
					and ts.iTenantStateCode_ID in (2,3)
					and ts.iTenantMOLocation_ID = #MOLocations.iTenantMOLocation_ID#
				</cfquery>
				<cfif GetCurrentID.RecordCount gt 0>
					<cfset html = "In Use">
				<cfelse>
					<cfset html = "<input class = 'BlendedButton' TYPE='submit' name='Delete' value='Delete Now'>">
				</cfif> 
			<TR>		
				<TD STYLE="width: 45%;">
					<cfif html eq "In Use">
						#MOLocations.cDescription#
					<cfelse>	
						<a href="MoveOutLocationsEdit.cfm?ID=#MOLocations.iTenantMOLocation_ID#">#MOLocations.cDescription#	
					</cfif>
				</TD>
				<TD STYLE="width: 45%;">
					#MOLocations.cNotes#
				</TD>
				<form name="LocationDisp" action="DeleteLocation.cfm?ID=#MOLocations.iTenantMOLocation_ID#" method="POST">
				<TD nowrap STYLE="width: 10%; text-align: center;">
					#html#
				</TD>
				</FORM>
			</TR>
		</CFLOOP>
	</TABLE>
	


</cfoutput>

