<CFQUERY NAME="GetUserName" DATASOURCE="DMS">
	select 
		username 
	from 
		dms.dbo.users
	where 
		employeeid = #SESSION.UserID#
</CFQUERY>

<!--- Create an Array --->
<cfset TenantArray = ArrayNew(1)>

<!--- Create a loop --->
<cfloop list="#iTenant_ID#" index="loopvar">
	<cfset TenantStruct = StructNew()>
	<!--- set the tenant structure members --->
	<cfset TenantStruct.tenantId = "">
	<cfset TenantStruct.bIsMedicaidPending = "">
	<cfset TenantStruct.tenantId = loopvar>
	<cfset TenantStruct.bIsMedicaidPending = form["MP#loopvar#"]>
	
	<!--- Check to see if there are records in the system already --->
	<cfquery name="CheckMedicaidPending" datasource="#application.datasource#">	
		select iTenant_ID, bIsMedicaidPending
		from 
			TenantMedicaidPending mp
		where
			mp.itenant_ID = #TenantStruct.tenantId#
		  and
		    dtrowdeleted is NULL	
	</cfquery>
	
	<!--- if there are records, then delete the old records --->
	<cfif CheckMedicaidPending.Recordcount gt 0>
		<cfif CheckMedicaidPending.bIsMedicaidPending neq TenantStruct.bIsMedicaidPending>
		   <cfquery name="UpdateMedicaidPending" datasource="#application.datasource#">
				update TenantMedicaidPending
				set 
					bIsMedicaidPending = #TenantStruct.bIsMedicaidPending#
					, iRowStartUser_ID = #SESSION.UserID#
					, cRowStartUser_ID = '#GetUserName.username#'
					, dtrowstart    = getdate()
				where 
					TenantMedicaidPending.itenant_ID = #TenantStruct.tenantId#
			</cfquery>
		</cfif>
	<cfelse>
		<cfif  TenantStruct.bIsMedicaidPending eq 1>
			<cfquery name="InsertMedicaidPending" datasource="#application.datasource#">
				Insert into TenantMedicaidPending
				(
					itenant_ID
					,bIsMedicaidPending
					,dtAcctStamp
					,iRowStartUser_ID
					,cRowStartUser_ID
					,dtrowstart
				)
				values
				(
					#TenantStruct.tenantId#
					,#TenantStruct.bIsMedicaidPending#
					,getdate()
					,#SESSION.UserID#
					,'#GetUserName.username#'
					,getdate()
				)
			</cfquery>
		</cfif>
	</cfif>
</cfloop>

<html>
	<font color = red>
		<table>
			<tr align="center">
			<td>
				<font color = red>
				<b>Medicaid Pending List has been updated. </b>
				</font>
			</td>
			</tr>
		</table>
		<table>
			<tr align="center">
				<td><INPUT TYPE="button" VALUE="Back To Main Menu" OnClick="window.location.href='../../Admin/Menu.cfm';"></td>
			</tr>
		</table>
	</font>
</html>