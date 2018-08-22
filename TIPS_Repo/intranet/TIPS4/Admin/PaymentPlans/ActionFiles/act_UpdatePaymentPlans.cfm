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
	<cfset TenantStruct.bIsPaymentPlan = "">
	<cfset TenantStruct.tenantId = loopvar>
	<cfset TenantStruct.bIsPaymentPlan = form["PP#loopvar#"]>
	
	<!--- Check to see if there are records in the system already --->
	<cfquery name="CheckPaymentPlan" datasource="#application.datasource#">	
		select iTenant_ID, bIsPaymentPlan
		from 
			TenantPaymentPlan pp
		where
			pp.itenant_ID = #TenantStruct.tenantId#
		  and
		    dtrowdeleted is NULL	
	</cfquery>
	
	<!--- if there are records, then delete the old records --->
	<cfif CheckPaymentPlan.Recordcount gt 0>
		<cfif CheckPaymentPlan.bIsPaymentPlan neq TenantStruct.bIsPaymentPLan>
		   <cfquery name="UpdatePaymentPlan" datasource="#application.datasource#">
				update TenantPaymentPlan
				set 
					bIsPaymentPlan = #TenantStruct.bIsPaymentPlan#
					, iRowStartUser_ID = #SESSION.UserID#
					, cRowStartUser_ID = '#GetUserName.username#'
					, dtrowstart    = getdate()
				where 
					TenantPaymentPlan.itenant_ID = #TenantStruct.tenantId#
			</cfquery>
		</cfif>
	<cfelse>
		<cfif  TenantStruct.bIsPaymentPlan eq 1>
			<cfquery name="InsertPaymentPlan" datasource="#application.datasource#">
				Insert into TenantPaymentPlan
				(
					itenant_ID
					,bIsPaymentPlan
					,dtAcctStamp
					,iRowStartUser_ID
					,cRowStartUser_ID
					,dtrowstart
				)
				values
				(
					#TenantStruct.tenantId#
					,#TenantStruct.bIsPaymentPlan#
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
				<b>Promissory Note has been updated. </b>
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