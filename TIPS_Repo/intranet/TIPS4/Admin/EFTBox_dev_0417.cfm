<!--- ---------------------------------------------------------------------------------------------
 sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                              |
 sfarmer     | 9/5/2012   | Project 93488 -  removed approval button.                             |
  S Farmer   | 07-02-2013 | Project 106456 - add movein and moveout to output file  -  EFT Updates|
--------------------------------------------------------------------------------------------------> 

				<!--- 	<cfset adjInvTotal = getAmt.InvoiceTotal - TenantInfo.dDeferral - TenantInfo.dSocSec  - TenantInfo.dMiscPayment + TenantInfo.dMakeupAmt> --->
					<!--- <cfif IsNumeric(getAmt.InvoiceTotal)><cfset adjInvTotal = getAmt.InvoiceTotal></cfif> --->
					<cfset adjInvTotal = adjfinal>
					<!--- <cfif IsNumeric(TenantInfo.dDeferral)><cfset adjInvTotal = adjInvTotal - TenantInfo.dDeferral></cfif> --->
					<cfif IsNumeric(TenantInfo.dSocSec)><cfset adjInvTotal = adjInvTotal - TenantInfo.dSocSec> </cfif>
					<cfif IsNumeric(TenantInfo.dMiscPayment)><cfset adjInvTotal = adjInvTotal - TenantInfo.dMiscPayment></cfif>					
					 <!--- <cfif IsNumeric(TenantInfo.dMakeupAmt)><cfset MakeupAmt = TenantInfo.dMakeupAmt ><cfelse><cfset MakeupAmt = 0></cfif> ---> 				
					<cfparam name="totaldue" default="0">
					<cfparam name="totalpymnt" default="0">
					<cfparam name="totalmisc" default="0">
					<cfparam name="netpercent" default="0">
					<cfset goodeft = 0>
					<cfset totalpymnt = 0>
					
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
				 
					<cfif IsDefined('sumpayment.sumfirstamt') and  sumpayment.sumfirstamt IS NOT "">
						<cfset totalpymnt = totalpymnt + sumpayment.sumfirstamt>
					</cfif>						 
					<cfif IsDefined('sumpayment.sumsecondamt') and  sumpayment.sumsecondamt IS NOT "">
						<cfset totalpymnt = totalpymnt + sumpayment.sumsecondamt>
					</cfif>
					<cfset totalpercent = 	0>	 
					<cfif sumpayment.sumsecondpull is not "">
						<cfset totalpercent = totalpercent + sumpayment.sumsecondpull>
					</cfif>						 
					<cfif sumpayment.sumfirstpull is not "">
						<cfset totalpercent = totalpercent + sumpayment.sumfirstpull>
					</cfif>
			
 						
						<cfif IsNumeric(adjInvTotal) and IsNumeric(totalpercent)>
							<cfset netpercent = (adjInvTotal * totalpercent)/100>
						<cfelse>
							<cfset netpercent = 0>
						</cfif>
					 
<!--- 						<cfif IsNumeric(TenantInfo.dSocSec)>
							<CFSET adjInvTotal = adjInvTotal - TenantInfo.dSocSec>
							<cfset totalmisc = totalmisc + TenantInfo.dSocSec>
						</cfif>			
						 
						<cfif IsNumeric(TenantInfo.dMiscPayment)>
							<CFSET adjInvTotal = adjInvTotal - TenantInfo.dMiscPayment>
							<cfset totalmisc = totalmisc + TenantInfo.dMiscPayment>
						</cfif>	 --->	
				 
						<cfif IsNumeric(totalpymnt)>
							<CFSET adjInvTotal = (#adjInvTotal# - #totalpymnt#)><!--- totalpymnt total $payment either prepaid or $$eft adjInvTotal invoice - $payment--->
						</cfif>	
						 
						 <cfif IsNumeric(sumpayment.eftcount) and (sumpayment.eftcount gt 0 )>
						 	<cfset eftcnt = sumpayment.eftcount> 
						 <cfelse>
						 	<cfset eftcnt = 0>
						 </cfif>

				 	<cfif IsNumeric(adjInvTotal) and IsNumeric(sumpayment.eftcount) and (sumpayment.eftcount gt 0 )and (adjInvTotal gt 0 ) >
							<cfif  nbrpercent gt 0>
								<cfset eachpercent = (adjInvTotal/eftcnt) * 100>
							<cfelseif eftcount gt 0>
								<cfset eachpercent = (adjInvTotal/eftcnt) * 100>
							<cfelse>
								<cfset eachpercent = 0>
							</cfif>
						<cfelse>
							<cfset eachpercent = 0>
						</cfif> 
						<cfif IsNumeric(adjInvTotal)>
							<cfset eachpayment = (adjInvTotal * eachpercent)/100>
						<cfelse>
							<cfset eachpayment = 0>
						</cfif>
						
						<cfif IsNumeric(totalmisc)>
						<!--- 	<cfset totpayment = netpercent + totalmisc + totalpymnt>	
						<cfelse> --->
							<cfset totpayment = netpercent + totalmisc>
						</cfif>
	 					
						 <cfif Isnumeric(getAmt.InvoiceTotal)>
							<cfset totaldue =   getAmt.InvoiceTotal>
						<cfelse>
							<cfset totaldue = MakeupAmt >
						</cfif>  
					<tr>
						<td  colspan= "4" align="center">EFT Accounts</td>
					</tr>
					<tr>
						<td   class="required" colspan= "4" align="center">To change the details of an EFT account or end using an EFT select on the EFT ID</td>
					</tr> 					
				<cfif goodeft gt 0>
<!--- 					<cfif round(totaldue) neq round(totpayment)>
						<tr>
							<td colspan="4" class="required" style=" text-decoration:underline; font-size:14px">PAYMENT DOES NOT EQUAL 100% OF THE CHARGES, ADJUST PAYMENTS OR APPROVAL IS REQUIRED	</td>
						</tr>
						<cfset alliswell = "N">	
					</cfif>	 --->					
	

					<cfif Emailcount neq goodeft>
						<tr>
							<td colspan= "4" class="required">There are EFT Accounts that do not have an email.</td>
							<cfset alliswell = "N">
						</tr>	
					</cfif>	
<!--- 					<cfif ((primpayer is 0) and (goodeft gt 0)<!---  and (EFTinfo.dtRowDeleted is "") --->)>
						<tr class="required">
							<td colspan="4">This account does not have a Primary Payer listed, Please Correct.</td>
						</tr>
						<cfset alliswell = "N">
 					</cfif> --->
<!--- 					<cfif   alliswell is "N">	
						<tr CLASS="required">
							<td colspan="4" style="text-align:LEFT" >One or more of these items are out of compliance:
								<UL>
									<LI> Payments do not Equal Charges</LI>
									<LI> OR  Emails are missing</LI> 
									<LI> OR Primary EFT Account has not been designated</LI>
								</UL>
							</td>
						</tr>
					</cfif>	 --->
				</cfif>
				 <!---	<cfif (((round(totaldue) neq round(totpayment)) or  (alliswell is "N")) and (goodeft gt 0))>	
						<tr>
							<td colspan="4" >    <cfoutput>A:#alliswell# D:#totaldue# P:#totpayment# </cfoutput>    EFT and Direct Payments do not equal Total Balance,   Supervisor Approval is required. Contact your AR Analyst.</td>
						</tr>	--->
<!--- 						<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)> 
							<tr>
								<td colspan="4" >Approval is required: <cfoutput><input class="ReturnButton" type="button" name="Approval of EFT" Value="Approval of EFT's"   onClick="location.href='EFTApprovalSupr.cfm?SelectedHouse_ID=#session.qselectedhouse.ihouse_id#&cSolomonKey=#TenantInfo.cSolomonKey#&apprv=super&ID=#TenantInfo.iTenant_ID#'"  ></cfoutput> </td>
							</tr>		
						</cfif>	 --->	  				
				<!--- 	<cfelseif ((alliswell is "") and (goodeft gt 0))>
						<tr>
							<td colspan="4" style="text-align:center" ><cfoutput><input class="ReturnButton" type="button" name="Approval of EFT" Value="Approval of EFT's"   onClick="location.href='EFTApprovalSupr.cfm?SelectedHouse_ID=#session.qselectedhouse.ihouse_id#&cSolomonKey=#TenantInfo.cSolomonKey#&ID=#TenantInfo.iTenant_ID#&apprv=user'"  ></cfoutput> </td>
						</tr>	 --->
						<!--- <cfelse>
						<cfoutput><tr><td>#alliswell# #totaldue# #totpayment#</td></tr></cfoutput> --->					
					<!--- </cfif>	 --->						
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
									<td class="BlendedTextBoxC">Contact<br/>Name</td>
								    <td class="BlendedTextBoxC">Primary<br/>Payer</td> 
									<td class="BlendedTextBoxC">Guarantor</td>	
									<td class="BlendedTextBoxC">Email</td>																
									<!--- <td class="BlendedTextBoxC">Approved</td> --->
									<td class="BlendedTextBoxC">Not<br />Active</td>
								</tr>
								<cfoutput>
								<cfif IsDefined("EFTInfo") and  EFTinfo.recordcount gt 0>
									<cfloop query="EFTinfo">
										  <cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE"> 
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
											<td nowrap="nowrap">#ContactName#</td>
											 <td style="text-align:center"><cfif PrimaryPayer is 1>X</cfif></td> 
											<td style="text-align:center"><cfif bIsGuarantorAgreement is 1>X</cfif></td>
											<td style="text-align:center">#Email#</td>			
											<!--- <td style="text-align:center"><cfif bApproved is 1>Y</cfif></td> --->
											<!--- <td style="text-align:center"><CFIF dtRowDeleted IS NOT "" OR dtRowEnd IS NOT "" or bUsesEFT is "">X</cfif></td> --->
											<td style="text-align:center"><CFIF dtRowDeleted IS NOT "" or bUsesEFT is "">X</cfif></td>
										</cf_cttr>
									</cfloop>  
										
									<cfelse>
										<tr>
											<td colspan="17">No Current Tenant EFT's</td>
										</tr>	
									 
									</cfif>
									</cfoutput>
							<tr >
							
							<tr> 
								<td colspan="17"><cfoutput>Invoice Total for AcctPeriod  #AcctPeriod#: #dollarformat(adjfinal)# </cfoutput>
									<br />** Solomon and  TIPS Charges
								</td> <!---  = Total Due #dollarformat(totaldue)# <cfif MakeupAmt gt 0> + Makeup Amount  #dollarformat(MakeupAmt)#</cfif> --->
							</tr>
							<tr>
<!--- 							<cfif totpayment is 0>
								<td colspan="17"  class="required" ><cfoutput>No Active EFT Payments scheduled  </cfoutput></td>
							<cfelse>	 
									<td colspan="17"  class="required" >
										<cfoutput>Remaining balance for EFT is:#dollarformat(adjInvTotal)#
									    <br/>  
									  	EFT Payment Calculation:  (#totalpercent#% of #dollarformat(adjInvTotal)#) #dollarformat(netpercent)# <cfif totalmisc   gt 0> +   #dollarformat(totalmisc)# </cfif> <cfif totalpymnt gt 0> + #dollarformat(totalpymnt)#</cfif> = #dollarformat(totpayment)# 
										</cfoutput>
									</td>
							  </cfif> --->
							</tr>
<!--- 							<tr>
								<cfif eachpercent is 0>
								<td colspan="17"><cfoutput>The withdrawal percent for 1 EFT account should total 100%</cfoutput></td>
								
								<cfelse>
								<td colspan="17"><cfoutput>For equal EFT payments, each EFT account percent should be: #numberformat(eachpercent,"999.9999")#%  (#dollarformat(eachpayment)#)</cfoutput></td>
								</cfif>
							</tr> --->
							<tr> 
							<td colspan="17" >
								<ul >
									<li>If there is more than one EFT account list the order of the draws</li>
									<li>Two draws are allowed per EFT account, Select the day of the month (5 - 25) corresponding to when the draw should be made.</li>
									<li>Enter either the percentage of the draw or the dollar amount of the draw. </li>
									<li>Effective Date, if left blank, will be today.</li>
								 	<!--- <li>One of the payer's must be marked as the Primary Payer.</li>  --->
								 	<li>Each EFT provider must have an email.</li>									
								</ul>
							</td>
						</tr>	
						<tr>
							<td colspan="17"> Check box to add EFT account<input type="checkbox" name="setupEFT" ONclick="callsetupeft()" /></td>
						</tr>
<!--- 						<tr>
							<td colspan="17"><cfoutput>Exempt from EFT Service Fee: <cfif TenantInfo.bExEFTSrvFee is ""> No<cfelse>Yes</cfif>  </cfoutput></td>
						</tr>	 --->
					</table>
						</td>
					</tr>
