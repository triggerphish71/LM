<form name="TrackPaymentPlans" action="../PaymentPLans/index.cfm" method="post">
	<table border="1">
		<tr align="center">
			<td><b>Room</b> </td>
			<td><b>Resident Name</b> </td>
			<td><b>Payor Type</b> </td>
			<td><b>Promissory Note (Y/N) </td>
			
		</tr>
		<cfoutput query="GetAllTenants">
			<input type="hidden" name="iTenant_ID" value="#iTenant_ID#" />
			<tr align="center">
				<td width="30"> 
					#cAptNumber# 
				</td>
				<cfif #iTenant_ID# neq ''>
				<td> 
					#cLastName#, #cFirstName# 
				</td>
				<td> 
					#cDescription# 
				</td>
				<td>
				<select name="PP#iTenant_ID#">
					<cfif GetAllTenants.PaymentPlan eq 1>
						<option value="0">N </option>
						<option value="1" selected>Y </option>
					<cfelse>
						<option value="0" selected>N </option>
						<option value="1">Y </option>
					</cfif>
				</select>
				</td>
		</cfif>
		</tr>
		</cfoutput>
	</table>
	<table>
		<tr align="center">
			<td>
				<input type="submit" value="Submit">
				<input type="reset" value="Clear">
			</td>
		</tr>
	</table>
	<input type="hidden" name="fuse" value="AddPaymentPlans">
</form>
