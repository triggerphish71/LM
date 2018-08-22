 <!--- 
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|sfarmer     |03/20/2012  |  Added for deferred New Resident Fee project 75019                 |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
| sfarmer    | 11/20/2012 |tickets 97882, 95010, 95009, 95468, 97570, 97710 for  misc. updates |
| sfarmer    | 08/08/2013 |project 106456 EFT Updates                                          |
----------------------------------------------------------------------------------------------->
<!--- Include Intranet Header --->
	<cfinclude template="../../header.cfm">
	<h1 class="PageTitle"> Tips 4 - Tenant EFT Information Edit </h1>
	
	<cfinclude template="../Shared/HouseHeader.cfm">
 

 <cfset thisdate = dateformat(#session.TIPSMonth#, 'YYYYMM')>
 
	<cfinclude template="../Shared/Queries/StateCodes.cfm">
	<cfinclude template="../Shared/Queries/PhoneType.cfm">
	<cfinclude template="../Shared/Queries/TenantInformation.cfm">
 
	<cfinclude template="../Shared/Queries/SolomonKeyList.cfm">
	<cfinclude template="../Shared/Queries/Relation.cfm">
	
	<cfparam name="nextorderpull" default="">
	<cfparam name="CID" default="">
 	<cfparam name="netchgamt" default="0">
 	<cfparam name="firstpaymntamt" default="0">
 	<cfparam name="secondpaymntamt" default="0">	
	<cfparam name="showall" default="">		
 	  <cfparam name="AcctPeriod" default="#session.acctperiod#"> 
 
 	<cfquery name="EFTinfo" datasource="#application.datasource#">
  		SELECT 
			t.clastname + ', ' + T.cfirstname as 'TenantName'
			,t.csolomonkey
			,''  as 'ContactName'
			,T.itenant_id
			,T.cEmail  as 'Email' 
			,ts.bUsesEFT
			,ts.dVAChampsAmt	 as 'VAChampsAmt'	
			,EFTA.iEFTAccount_ID 
			,EFTA.cRoutingNumber 
			,EFTA.CaCCOUNTnUMBER 
			,EFTA.cAccountType 
			,EFTA.iOrderofPull 
			,EFTA.iDayofFirstPull 
			,EFTA.dPctFirstPull 
			,EFTA.dAmtFirstPull 
			,EFTA.iDayofSecondPull 
			,EFTA.dPctSecondPull 
			,EFTA.dAmtSecondPull 
			,EFTA.iContact_id 
			,EFTA.dtBeginEFTDate 
			,EFTA.dtEndEFTDate 
			,EFTA.bApproved 
			,EFTA.dtRowDeleted 
			<!--- ,EFTA.dtRowEnd	 --->						
			,h.cname as 'cHouseName'
			,h.ihouse_id  AS 'houseID'
			,IM.mInvoiceTotal
			,TS.dDeferral 
			,TS.dSocSec 
			,TS.dMiscPayment
			,TS.dMakeUpAmt		
			,T.bIsPayer	as 'IsPayer'
			,TS.bIsPrimaryPayer as 'IsPrimPayer'
			,'' as 'IsContactPayer'
			,'' as 'IsContactPrimPayer'
			,'' as 'isLTC'
			, (arb.currbal + arb.futurebal) as currbal
			 
		FROM  
		dbo.tenant T join dbo.tenantstate ts on  t.iTenant_ID = ts.iTenant_ID
		 join dbo.house h on t.ihouse_id = h.ihouse_id
		 join dbo.InvoiceMaster IM on IM.cSolomonKey = T.cSolomonKey 
		left join EFTAccount EFTA on  EFTA.cSolomonKey = T.cSolomonKey
		 			left join #Application.HOUSES_APPDBServer#.HOUSES_APP.dbo.ar_balances arb on (arb.custid = t.cSolomonKey)
		
		WHERE 
			 EFTA.iContact_id is  null
			  and EFTA.dtRowDeleted is  null 
			  <!--- and  EFTA.dtRowEnd  is  null  --->  
			and ts.iTenantStateCode_ID = 2
			and im.cAppliesToAcctPeriod =   '#AcctPeriod#'
			and IM.bMoveInInvoice is null 	
			and IM.bMoveOutInvoice is null					 
	 			
			UNION     
			
			SELECT 
				t.clastname + ', ' + T.cfirstname	as 'TenantName'	
				,t.csolomonkey			
				,C.cFirstName + ' ' +  C.cLastName as   'ContactName'  
				,T.itenant_id
 				,C.cEmail as  'Email' 
				,LTC.bIsEFT 
				,''	 as 'VAChampsAmt'
				,EFTA.iEFTAccount_ID 
				,EFTA.cRoutingNumber 
				,EFTA.CaCCOUNTnUMBER 
				,EFTA.cAccountType 
				,EFTA.iOrderofPull 
				,EFTA.iDayofFirstPull 
				,EFTA.dPctFirstPull 
				,EFTA.dAmtFirstPull 
				,EFTA.iDayofSecondPull 
				,EFTA.dPctSecondPull 
				,EFTA.dAmtSecondPull 
				,EFTA.iContact_id 
				,EFTA.dtBeginEFTDate 
				,EFTA.dtEndEFTDate 
				,EFTA.bApproved 
			,EFTA.dtRowDeleted 
			<!--- ,EFTA.dtRowEnd	 --->			
				,h.cname as 'cHouseName'
				,h.ihouse_id  AS 'houseID'
				,IM.mInvoiceTotal
				,TS.dDeferral 
				,TS.dSocSec 
				,TS.dMiscPayment
				,TS.dMakeUpAmt	
				,'' as 'IsPayer'
				,'' as 'IsPrimPayer'
				,LTC.bIsPayer as 'IsContactPayer'
				,LTC.bIsPrimaryPayer as 'IsContactPrimPayer'				
				,'Y' as 'isLTC'
				, (arb.currbal + arb.futurebal) as currbal
			 			
			FROM 
			dbo.tenant T join dbo.tenantState TS on T.iTenant_ID = ts.iTenant_ID
			   	join dbo.LinkTenantContact LTC on  T.iTenant_ID = LTC.iTenant_ID and ltc.bIsPayer = 1
					join dbo.Contact C on LTC.iContact_ID = C.iContact_ID
					left	join dbo.EFTAccount EFTA  on EFTA.cSolomonKey = T.cSolomonKey 
							join dbo.house h on t.ihouse_id = h.ihouse_id
								join dbo.InvoiceMaster IM on IM.cSolomonKey = T.cSolomonKey
								left join #Application.HOUSES_APPDBServer#.HOUSES_APP.dbo.ar_balances arb on (arb.custid = t.cSolomonKey)			
			WHERE 
 			  EFTA.dtRowDeleted is  null 
			   <!---  and  EFTA.dtRowEnd  is  null  --->  
				and ts.iTenantStateCode_ID = 2
  				and im.cAppliesToAcctPeriod =   '#AcctPeriod#'  
				and IM.bMoveInInvoice is null 	
				and IM.bMoveOutInvoice is null						 
				
			order by cHouseName, TenantName, EFTA.iOrderofPull
	</cfquery>		<!---   and IM.bFinalized = 1 and EFTA.iContact_ID = LTC.iContact_ID --->

			<cfset counter = 0>
 			<cfset thisperson = "">	
 			<cfset thishouse = "">				
			<cfset totalpaymentamt = 0>
 							<table>
								<tr>
									<cfoutput>
										<td colspan="25" align="center">Payers - All Houses</td>
									</cfoutput>
								</tr>							
								<tr>
									<cfoutput>
										<td colspan="29">  Accounting Period: #thisdate# </td>
									</cfoutput>
								 <TR>

							 
								 <cfoutput query="EFTInfo" group="cHouseName">
 	<cfquery name="TotalCharges" datasource="#application.datasource#">
		select	ad.cAptNumber, t.iTenant_ID, isNULL(Sum(iQuantity * mAmount),0) as sum
		from Tenant t 
		join TenantState ts  on (ts.iTenant_ID = t.iTenant_ID and ts.dtRowDeleted is null and ts.iTenantStateCode_ID = 2)
		and t.iHouse_ID = #houseID#
		join InvoiceMaster IM  on im.csolomonkey = t.csolomonkey and IM.dtRowDeleted is null 
		and IM.bFinalized is null and IM.cAppliesToAcctPeriod = '#Year(session.TIPSMonth)##DateFormat(session.TIPSMonth, "mm")#'
		and IM.bMoveInInvoice is null and IM.bMoveOutInvoice is null 
		left join InvoiceDetail INV on INV.iinvoicemaster_id = im.iinvoicemaster_id and INV.dtRowDeleted is null
		join ChargeType CT  on INV.iChargeType_ID = Ct.iChargeType_ID and Ct.dtRowDeleted is null
		and Ct.cGLAccount <> 3012 and Ct.cGLAccount <> 3016
		join AptAddress AD  on ad.iAptAddress_ID = ts.iAptAddress_ID and ad.dtRowDeleted is null
		group by t.iTenant_ID, ad.cAptNumber
		order by cAptNumber
	</cfquery>
	<cfset TenantList=ValueList(TotalCharges.iTenant_ID)>
	<cfset TenantTotal=ValueList(TotalCharges.sum)>										 
										<cfset thishouse = #houseID#>
								
								<tr   style="background:##FFFF99">
									<td colspan="25" >#cHouseName#</td>
								</tr>

								<tr>
									<td colspan="25"   >Tenant Name - Resident ID</td>								
								</tr>
								<tr>
									<td class="BlendedTextBoxC">EFT ID</td>
									<td class="BlendedTextBoxC">Routing Number <br />(Last 4 Digits) </td>
									<td class="BlendedTextBoxC">Account Number <br />(Last 4 Digits)</td>
									<TD class="BlendedTextBoxC">Account Type</TD>
									<td class="BlendedTextBoxC">Order of Draw</td>
									<td class="BlendedTextBoxC">First Draw Day</td>
									<td class="BlendedTextBoxC">First Draw Percent (%)</td>
									<td class="BlendedTextBoxC">First Draw Amount ($)</td>
									<td class="BlendedTextBoxC">Secound Draw Day</td>
									<td class="BlendedTextBoxC">Second Draw Percent (%)</td>
									<td class="BlendedTextBoxC">Second Draw Amount ($)</td>
									<td class="BlendedTextBoxC">EFT Begin Date</td>
									<td class="BlendedTextBoxC">EFT End Date</td>
									<td class="BlendedTextBoxC">Email</td>
									<!--- <td class="BlendedTextBoxC">VA-Champs Amt</td> --->
									<td class="BlendedTextBoxC">Invoice Total</td>  
									<td class="BlendedTextBoxC">Direct Payments</td>
									<td class="BlendedTextBoxC">Misc Payments</td>	
								 	<td class="BlendedTextBoxC">Net Payment</td>  	
									<td class="BlendedTextBoxC">First Payment Amt</td>  
									<td class="BlendedTextBoxC">Second Payment Amt</td> 																																											
									<td class="BlendedTextBoxC" nowrap="nowrap">Contact<br/>Name</td> 
									<td class="BlendedTextBoxC">Payer</td>
									<td class="BlendedTextBoxC">Primary<br />Payer</td>
									<td class="BlendedTextBoxC" nowrap="nowrap">Approved</td> 
									<cfif showall  is "Y">
									<td class="BlendedTextBoxC">Not<br />Active</td>
									</cfif>										
 								</tr>
								<cfoutput group="cSolomonkey">

									<cfif thisperson is not "" and thisperson is not #cSolomonkey#> 
										<cfset totalpaymentamt = 0>
										<cfset thisperson = #cSolomonkey#>
									<cfelse>
										<cfset totalpaymentamt = 0>
										<cfset thisperson = #cSolomonkey#> 	
									</cfif> 	
										<TR style="background:##CCCCCC">
											<td colspan="25"><a href="TenantEdit.cfm?iEFTAccount_ID=#iEFTAccount_ID#&ID=#eftinfo.iTenant_ID#&tenantSolomonKey=#eftinfo.cSolomonKey#">#TenantName#</a> 
											 #cSolomonkey#</td>
										</TR>
										
									<cfoutput>	
 
												 
 	
																																						
										<cfset counter = counter + 1>
										<!--- <cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE"> --->
										<TR>
											<td><a href="TenantEFTDetailEdit.cfm?iEFTAccount_ID=#iEFTAccount_ID#&iTenant_ID=#eftinfo.iTenant_ID#&tenantSolomonKey=#eftinfo.cSolomonKey#">#iEFTAccount_ID#</a></td>
											<td>#right(cRoutingNumber, 4)#</td>
											<td>#right(CaCCOUNTnUMBER, 4)#</td>
											<TD><cfif ((cAccountType is 'c') or (cAccountType is 'C' ))>C<cfelseif ((cAccountType is 's') or (cAccountType is 'S' ))>S<cfelse>&nbsp;</cfif></TD>
											<td>#iOrderofPull#</td>
											<cfif cRoutingNumber is not "">
											<td><cfif ((iDayofFirstPull is "") and (iDayofSecondPull is ""))> 1<cfelse>#iDayofFirstPull#</cfif></td>
											<td><cfif ((dPctFirstPull is "") and (dAmtFirstPull is "") and (dPctSecondPull is "") and (dAmtSecondPull is "")) > 100 <cfelse>#dPctFirstPull#</cfif></td>

											<td>#dollarformat(dAmtFirstPull)#</td>
											<td>#iDayofSecondPull#</td>
											<td>#dPctSecondPull#</td>
											<td>#dollarformat(dAmtSecondPull)#</td>
											<td>#dateformat(dtBeginEFTDate, 'mm/dd/yyyy')#</td>
											<td>#dateformat(dtEndEFTDate, 'dd/mm/yyyy')#</td>
											<cfelse>
											<td>&nbsp;</td>
											<td>&nbsp;</td>
											<td>&nbsp;</td>
											<td>&nbsp;</td>											
											<td>&nbsp;</td>
											<td>&nbsp;</td>
											<td>&nbsp;</td>
											<td>&nbsp;</td>
											</cfif>
											<td>#Email#</td>
											<!--- <td> #dollarformat(VAChampsAmt)# </td> --->
					<cfif ListFindNoCase(TenantList, eftinfo.iTenant_ID, ",") gt 0>
					<cfset pos=ListFindNoCase(TenantList, eftinfo.iTenant_ID, ",")>
						<td style="text-align: right;">
					 <cftry>	<cfset netchgamt =  ListGetAt(TenantTotal, pos, ",") > <cfcatch type="ANY"> #Len(TenantTotal)# == #TenantTotal# </cfcatch> </cftry>  
						#LSCurrencyFormat(netchgamt)#
						</td>
					<cfelse>
						<td style="text-align: right;"> #LSCurrencyFormat(0.00)# </td>
					</cfif>
 								<cfif cRoutingNumber is not "">  		 	
										<cfset firstpaymntamt = 0>	
										<cfset secondpaymntamt = 0>								
 									 
										<cfif   dDeferral is not "" >
											<cfset netchgamt = netchgamt - dDeferral>
										 
										</cfif>
										<cfif   dSocSec  is not "" >										
											<cfset netchgamt = netchgamt - dSocSec>
											 
										</cfif>
										<cfif   dMiscPayment  is not "" >										
											<cfset netchgamt = netchgamt - dMiscPayment>
										</cfif>										
 										
										<cfif (dPctFirstPull is not "") and  dPctFirstPull is not 0>
											<cfset firstpaymntamt = (dPctFirstPull/100) * netchgamt>
										<cfelseif  (dAmtFirstPull is not "") and  dPctFirstPull is not 0>
											<cfset firstpaymntamt = dAmtFirstPull>									 	
										</cfif>	 	

										<cfif  (dPctSecondPull is not "") and  dPctSecondPull is not 0>
											<cfset secondpaymntamt = (dPctSecondPull/100) * netchgamt>										 
										<cfelseif  (dAmtSecondPull is not "") and dAmtSecondPull is not 0>
											<cfset secondpaymntamt = dAmtSecondPull>
										</cfif>	 
										
										<cfif dPctFirstPull is "" and dPctSecondPull is "" and dAmtFirstPull is "" and dAmtSecondPull is "">
											<cfset firstpaymntamt = netchgamt>
										</cfif>					
											<td>#dollarformat(dDeferral)#</td> 
											<td>#dollarformat(dSocSec)#</td> 
											<td>#dollarformat(dMiscPayment)#</td>
										 	<td>#dollarformat(netchgamt)#</td>  	
											<td>#dollarformat(firstpaymntamt)#</td>	 
											<td>#dollarFormat(secondpaymntamt)#</td> 
										<cfelse>
											<td>&nbsp;</td> 
											<td>&nbsp;</td> 
											<td>&nbsp;</td>
										 	<td>&nbsp;</td>  	
											<td>&nbsp;</td>	 
											<td>&nbsp;</td>
										</cfif>
											<td nowrap="nowrap">#ContactName#</td> 		
											<td><cfif (isLTC is "Y") and (IsContactPayer is 1)>C<cfelseif (isLTC is "") and (IsPayer is 1) >T<cfelse>&nbsp;</cfif></td>
											<td><cfif (isLTC is "Y") and (IsContactPrimPayer is 1)>C<cfelseif (isLTC is "") and (IsPrimPayer is 1) >T<cfelse>&nbsp;</cfif></td>

											<td nowrap="nowrap"><cfif bApproved is 1>Y</cfif></td> 	
											<cfif showall  is "Y">
											<!--- <CFIF ((dtRowDeleted IS NOT "") OR (dtRowEnd IS NOT ""))> --->
												<CFIF  (dtRowDeleted IS NOT "") >
													<td class="BlendedTextBoxC">X</td>
												<cfelse>
													<td class="BlendedTextBoxC">&nbsp;</td>
												</CFIF>
											</cfif>																													
 										</tr>

										<cfif  (firstpaymntamt is not "")>
 											<cfset totalpaymentamt =  totalpaymentamt     + firstpaymntamt>
										</cfif>
										<cfif  (secondpaymntamt is not "")>
 											<cfset totalpaymentamt =  totalpaymentamt  +  secondpaymntamt>
										</cfif>																				

 
 								</cfoutput></cfoutput></cfoutput>
 							 <tr>
							 	<td colspan="29">Show all EFT's  including non-current EFT's. <input type="button" name="Show All EFT's"  value="ShowAll"  onClick="location.href='TenantEFTAll.cfm?ShowAll=Y'" /></td>
							 </tr>
							</table>								
							</table>
			 
 
		<!--- Include intranet footer --->
		<cfinclude template="../../footer.cfm">		

