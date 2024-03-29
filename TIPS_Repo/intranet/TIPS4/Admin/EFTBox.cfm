<!--- ---------------------------------------------------------------------------------------------
 sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                              |
 sfarmer     | 9/5/2012   | Project 93488 -  removed approval button.                             |
  S Farmer   | 07-02-2013 | Project 106456 - add movein and moveout to output file  -  EFT Updates|
 mstreigel   | 05/14/2018 | Removed balances and fields per AR request and converted to cfc       | 
--------------------------------------------------------------------------------------------------> 

	<!--- mstriegel 05/14/2018 --->	
	<cfset oEFTServices = CreateObject("component","intranet.TIPS4.CFC.Components.EFT.EFTBoxServices")>	
	<cfset eftInfo = oEFTServices.EFTInfo(solomonKey = TenantInfo.cSolomonKey)>
	
	<cfset goodeft = 0>	
	<cfoutput query="EFTinfo">
		<cfif  dtRowDeleted is "">
			<cfset goodeft = goodeft + 1>
		</cfif>		
		<cfif ((primarypayer is 1) and (dtRowDeleted is ""))>
			<cfset  primpayer = primpayer + 1>
		</cfif>		
		<cfif Email is  "" and primarypayer is 1 and (dtRowDeleted is "")>
			<cfset  Emailcount = Emailcount + 1>
		<cfelseif Email is not "" and (dtRowDeleted is "")>
			<cfset  Emailcount = Emailcount + 1>
		</cfif>			
		 <cfif IsdEFINED('dPctSecondPull') and dPctSecondPull is not ""  and dPctSecondPull is not 0 and (dtRowDeleted is "")>
			<cfset nbrpercent = nbrpercent +1> 
		</cfif>  		
		 <cfif ISdEFINED('dPctFirstPull') and dPctFirstPull is not "" and dPctFirstPull is not 0 AND (dtRowDeleted is "")>
			<cfset nbrpercent = nbrpercent +1>
		</cfif> 
	</cfoutput>	
	<tr>
		<td colspan= "4" align="center">EFT Accounts</td>
	</tr>
	<tr>
		<td class="required" colspan= "4" align="center">To change the details of an EFT account or end using an EFT select on the EFT ID</td>
	</tr> 					
	<cfif goodeft gt 0>
		<cfif Emailcount neq goodeft>
			<tr>
				<td colspan= "4" class="required">There are EFT Accounts that do not have an email.</td>
				<cfset alliswell = "N">
			</tr>	
		</cfif>	
	</cfif>	 
	<tr>
		<td colspan= "4" align="center"> 
			<table>
				<tr>
					<td class="BlendedTextBoxC">EFT ID<br/>(Select to<br/>Edit)</td>
					<td class="BlendedTextBoxC">Routing Number</td>
					<td class="BlendedTextBoxC">Account Number</td>
					<TD class="BlendedTextBoxC">Account Type</TD>
					<td class="BlendedTextBoxC">Order of Draw</td>
					<td class="BlendedTextBoxC">First Draw Date</td>
					<td class="BlendedTextBoxC">First Draw Percent (%)</td>
					<td class="BlendedTextBoxC">First Draw Amount ($)</td>
					<td class="BlendedTextBoxC">Secound Draw Date</td>
					<td class="BlendedTextBoxC">Second Draw Percent (%)</td>
					<td class="BlendedTextBoxC">Second Draw Amount ($)</td>
					<td class="BlendedTextBoxC">EFT Begin Date</td>
					<td class="BlendedTextBoxC">EFT End Date</td>				
				</tr>				
				<cfif IsDefined("EFTInfo") and  EFTinfo.recordcount gt 0>
					<cfoutput query="EFTInfo">
						<tr  style="cursor:hand; bgcolor:<cfif EFTInfo.recordcount MOD 2 EQ 0>##FFFFFF<cfelse>##EEEEEE</cfif>;">
							<td><a href="TenantEFTDetailEdit.cfm?iEFTAccount_ID=#iEFTAccount_ID#&iTenant_ID=#TenantInfo.iTenant_ID#&tenantSolomonKey=#TenantInfo.cSolomonKey#<cfif ContactName is not "">&CID=#iContact_id#</cfif>">#iEFTAccount_ID#</a></td>
							<td>#right(cRoutingNumber,4)#</td>
							<td>#right(CaCCOUNTnUMBER,4)#</td>
							<TD><cfif cAccountType is 'c'>Checking<cfelse>Savings</cfif></TD>
							<td style="text-align:center">#iOrderofPull#</td>
							<td style="text-align:center"><cfif #iDayofFirstPull# is ''> 5 <cfelse>#iDayofFirstPull# </cfif></td>
							<td>#dPctFirstPull#</td>
							<td>#dollarformat(dAmtFirstPull)#</td>
							<td style="text-align:center">#iDayofSecondPull#</td>
							<td>#dPctSecondPull#</td>
							<td>#dollarformat(dAmtSecondPull)#</td>
							<td>#dateformat(dtBeginEFTDate, 'mm/dd/yyyy')#</td>
							<td>#dateformat(dtEndEFTDate, 'mm/dd/yyyy')#</td>							
						</tr>
					</cfoutput>  
				<cfelse>
					<tr>
						<td colspan="17">No Current Tenant EFT's</td>
					</tr>	
				</cfif>					
				<tr> 
					<td colspan="17" >
						<ul >
							<li>If there is more than one EFT account list the order of the draws</li>
							<li>Two draws are allowed per EFT account, Select the day of the month (5 - 25) corresponding to when the draw should be made.</li>
							<li>Enter either the percentage of the draw or the dollar amount of the draw. </li>
							<li>Effective Date, if left blank, will be today.</li>						 
						 	<li>Each EFT provider must have an email.</li>									
						</ul>
					</td>
				</tr>	
				<tr>
					<td colspan="17"> Check box to add EFT account<input type="checkbox" name="setupEFT" ONclick="callsetupeft()" /></td>
				</tr>
			</table>
		</td>
	</tr>
