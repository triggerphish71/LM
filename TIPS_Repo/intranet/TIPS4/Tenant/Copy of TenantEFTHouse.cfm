<!---  
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|sfarmer     |03/20/2012  |  Added for deferred New Resident Fee project 75019                 |
|sfarmer     | 9/5/2012   | Project 93488 -  removed approval column.                          |
| sfarmer    | 11/20/2012 |tickets 97882, 95010, 95009, 95468, 97570, 97710 for  misc. updates | 
----------------------------------------------------------------------------------------------->
<!--- Include Intranet Header --->
	<cfinclude template="../../header.cfm">
	<h1 class="PageTitle"> Tips 4 - Tenant EFT House </h1>
	
	<cfinclude template="../Shared/HouseHeader.cfm">
	
	<cfset eftpulmonth = dateadd('m', -1,  #session.TIPSMonth#) >
	<cfset thisdate = dateformat(eftpulmonth, 'YYYYMM')>

	<cfparam name="nextorderpull" default="">
	<cfparam name="CID" default="">
 	<cfparam name="netchgamt" default="0">
 	<cfparam name="firstpaymntamt" default="0">
 	<cfparam name="secondpaymntamt" default="0">		
	<cfparam name="showall" default="">
	<cfparam name="srt" default="TenantName">
	
  	<cfparam name="AcctPeriod" default="#SESSION.TIPSMonth#"> 
  	<cfset AcctPeriod = dateformat(AcctPeriod ,'yyyymm')>	
 	<cfquery name="EFTinfo" datasource="#application.datasource#">
  		SELECT 
			t.clastname + ', ' + t.cfirstname as 'TenantName'
			,t.csolomonkey
			,''  as 'ContactName'
			,t.itenant_id
			,t.cEmail  as 'Email' 
			,ts.bUsesEFT
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
			,EFTA.dtRowEnd				
			,h.cname as 'cHouseName'
			,h.ihouse_id  
			,TS.dDeferral 
			,TS.dSocSec 
			,TS.dMiscPayment
			,TS.dMakeUpAmt	
			,t.bIsPayer	as 'IsPayer'
			,TS.bIsPrimaryPayer as 'IsPrimPayer'
			,'' as 'IsContactPayer'
			,'' as 'IsContactPrimPayer'
			,'' as 'isLTC'
 		 ,AD.cAptNumber  
		FROM  
		dbo.tenant t join dbo.tenantstate ts on  t.iTenant_ID = ts.iTenant_ID
		join dbo.house h on t.ihouse_id = h.ihouse_id and h.ihouse_id = #session.qselectedhouse.ihouse_id#
		join EFTAccount EFTA on  EFTA.cSolomonKey = T.cSolomonKey
		join dbo.InvoiceMaster IM on IM.cSolomonKey = T.cSolomonKey
 
		join AptAddress AD  on ad.iAptAddress_ID = ts.iAptAddress_ID and ad.dtRowDeleted is null  
		WHERE 
			EFTA.iContact_id is  null
			<cfif showall is  "N">
				and EFTA.dtRowDeleted is  null 
				and  EFTA.dtRowEnd  is  null   
		 		and ts.bUsesEFT =  1
			</cfif>	
			and IM.dtRowDeleted is null
			and IM.bMoveInInvoice is null			
			and ts.iTenantStateCode_ID = 2
	  		
			UNION     
			
			SELECT 
				t.clastname + ', ' + t.cfirstname	as 'TenantName'	
				,t.csolomonkey			
				,C.cFirstName + ' ' +  C.cLastName as   'ContactName'  
				,t.itenant_id
 				,C.cEmail as  'Email' 
				,LTC.bIsEFT  as 'ContactEFT'
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
				,EFTA.dtRowEnd
				,h.cname as 'cHouseName'
				,h.ihouse_id  
				,TS.dDeferral 
				,TS.dSocSec 
				,TS.dMiscPayment
				,TS.dMakeUpAmt	
				,'' as 'IsPayer'
				,'' as 'IsPrimPayer'
				,LTC.bIsPayer as 'IsContactPayer'
				,LTC.bIsPrimaryPayer as 'IsContactPrimPayer'				
				,'Y' as 'isLTC'
 		 		 ,AD.cAptNumber  
		FROM 
			dbo.tenant t join dbo.tenantState TS on t.iTenant_ID = ts.iTenant_ID
			   	join dbo.LinkTenantContact LTC on  t.iTenant_ID = LTC.iTenant_ID 
					join dbo.Contact C on LTC.iContact_ID = C.iContact_ID
						join dbo.EFTAccount EFTA  on EFTA.cSolomonKey = T.cSolomonKey 
						join dbo.InvoiceMaster IM on IM.cSolomonKey = T.cSolomonKey
							join dbo.house h on t.ihouse_id = h.ihouse_id and h.ihouse_id = #session.qselectedhouse.ihouse_id#
						 		  join AptAddress AD  on ad.iAptAddress_ID = ts.iAptAddress_ID and ad.dtRowDeleted is null  
			WHERE 
				LTC.bIsEFT = 1 
				<cfif showall is  "N">
					and EFTA.dtRowDeleted is  null   
					and  EFTA.dtRowEnd  is  null  
					and ts.bUsesEFT =  1 
				</cfif>  
				and ts.iTenantStateCode_ID = 2
				and IM.dtRowDeleted is null
				and IM.bMoveInInvoice is null				
				and EFTA.iContact_ID = LTC.iContact_ID

			order by #srt#  
	</cfquery>	
<link href="../Styles/Index.css" rel="stylesheet" type="text/css" />
 
<cfinclude template="../Shared/JavaScript/ResrictInput.cfm" >
<script src="../ScriptFIles/Functions.js"></script>
<script>
	window.onload=createhintbox;
</script>
			<cfset counter = 0>
 			<cfset thisperson = "">		
			<cfset totalpaymentamt = 0>
			<cfset pullacctperiod = #dateformat(eftpulmonth,'YYYYMM')#>			
 
							<table>
								<tr>
									<td colspan="14"><cfoutput>  Pull Period: #dateformat(eftpulmonth,'YYYYMM')# <!--- House: #session.qselectedhouse.ihouse_id# acct: #AcctPeriod# ---></cfoutput></td>
								</tr>
 								<cfif showall  is ""> 
									<tr>
										<td colspan="14">Includes expired EFT's</td>
									</tr>
								</cfif>
								<tr>
									<td class="BlendedTextBoxC" nowrap="nowrap"  onMouseOver="hoverdesc('Sort by Apartment Number');" onMouseOut="resetdesc();"><a href="TenantEFTHouse.cfm?srt=cAptNumber">Apartment Nbr.</a></td>								
									<td class="BlendedTextBoxC" nowrap="nowrap"  onMouseOver="hoverdesc('Sort by Tenant Name');" onMouseOut="resetdesc();"><a href="TenantEFTHouse.cfm?srt=TenantName">Tenant Name</a><br />(Select to edit<br /> Tenant information)</td>
									<td class="BlendedTextBoxC" nowrap="nowrap"  onMouseOver="hoverdesc('Sort by Resident ID');" onMouseOut="resetdesc();"><a href="TenantEFTHouse.cfm?srt=cSolomonkey">Resident ID</a></td>
									<!--- <td class="BlendedTextBoxC">Last Invoice<br /> Total <a href="#" class="hintanchor" onMouseover="showhint('Last Invoice Total', this, event, '150px')">[?]</a></td> 							
									<td class="BlendedTextBoxC">Solomon <a href="#" class="hintanchor" onMouseover="showhint('Solomon Activity', this, event, '150px')">[?]</a></td>
									<td class="BlendedTextBoxC">Tips(Invoice)<br /> Total<a href="#" class="hintanchor" onMouseover="showhint('Current TIPS Invoice Total', this, event, '150px')">[?]</a></td>
									<td class="BlendedTextBoxC">Final Amount <a href="#" class="hintanchor" onMouseover="showhint('Last Invoice Total <br/>+  Solomon Total<br/> + Current TIPS Invoice', this, event, '150px')">[?]</a></td>
									<td class="BlendedTextBoxC">Offset <a href="#" class="hintanchor" onMouseover="showhint('Solomon Payments after House closed', this, event, '150px')">[?]</a></td>
									<td class="BlendedTextBoxC">Current<br /> LateFee<a href="#" class="hintanchor" onMouseover="showhint('Late Fees', this, event, '150px')">[?]</a></td>
									<td class="BlendedTextBoxC">Adjusted<br />Final<a href="#" class="hintanchor" onMouseover="showhint('Last Invoice Total +  Solomon Total + Current TIPS Invoice + Offset', this, event, '150px')">[?]</a></td>
									<td class="BlendedTextBoxC">Direct Payments <a href="#" class="hintanchor" onMouseover="showhint('Direct Payments from Tenant Page; Social Security, etc.', this, event, '150px')">[?]</a></td>
									<td class="BlendedTextBoxC">Misc Payments<a href="#" class="hintanchor" onMouseover="showhint('From Tenat Page, any other direct payment', this, event, '150px')">[?]</a></td> --->

									<td class="BlendedTextBoxC">Invoice Balance for EFT<br />  <a href="#" class="hintanchor" onMouseover="showhint('The Final (Adjusted) Invoice amount to be drawn by EFT ', this, event, '150px')">[?]</a></td>																		
 									<cfif showall  is "">
										<td class="BlendedTextBoxC">Not<br />Active<br />  <a href="#" class="hintanchor" onMouseover="showhint('An X indicates this EFT account has been turned off, to reactivate click on the link and reprocess ', this, event, '150px')">[?]</a></td>
									</cfif>	
									<!--- <td class="BlendedTextBoxC" nowrap="nowrap">Contact<br/>Name<a href="#" class="hintanchor" onMouseover="showhint('If EFT is from Contact', this, event, '150px')">[?]</a></td> --->
									<td class="BlendedTextBoxC">EFT Detail<br />(Select to edit<br /> the EFT Account) <a href="#" class="hintanchor" onMouseover="showhint('Link to Tenant EFT detail page', this, event, '150px')">[?]</a></td>
									<!--- <td class="BlendedTextBoxC">Payer<a href="#" class="hintanchor" onMouseover="showhint('T - Tenant, C - Contact', this, event, '150px')">[?]</a></td>
									<td class="BlendedTextBoxC">Primary<br />Payer<a href="#" class="hintanchor" onMouseover="showhint('Who is Primary Payer - T - Tenant, C - Contact', this, event, '150px')">[?]</a></td>  --->
									<td class="BlendedTextBoxC">Routing Number<br />(Last 4 Digits)<a href="#" class="hintanchor" onMouseover="showhint('Bank Routing Number', this, event, '150px')">[?]</a></td>
									<td class="BlendedTextBoxC">Account Number<br />(Last 4 Digits)<a href="#" class="hintanchor" onMouseover="showhint('Checking/Savings Account Number', this, event, '150px')">[?]</a></td>
									<!--- <TD class="BlendedTextBoxC">Account<br /> Type<a href="#" class="hintanchor" onMouseover="showhint('Account Type  C - Checking, S - Savings', this, event, '150px')">[?]</a></TD> --->
									<!--- <td class="BlendedTextBoxC">Order of Draw<a href="#" class="hintanchor" onMouseover="showhint('Order of the EFT draws', this, event, '150px')">[?]</a></td> --->
									<td class="BlendedTextBoxC">First Draw Day<a href="#" class="hintanchor" onMouseover="showhint('First draw day for the account, does not have to be the first of the month. If blank, first of the month.', this, event, '150px')">[?]</a></td>
									<!--- <td class="BlendedTextBoxC">First Draw Percent (%)<a href="#" class="hintanchor" onMouseover="showhint('First draw %, if blank 100%', this, event, '150px')">[?]</a></td> --->
									 <td class="BlendedTextBoxC">First Draw  Amount ($)<a href="#" class="hintanchor" onMouseover="showhint('First draw $ amount', this, event, '150px')">[?]</a></td>									
								<!---	<td class="BlendedTextBoxC">First Draw Fixed Amount ($)<a href="#" class="hintanchor" onMouseover="showhint('Fixed $ amount of the draw (when not a %)', this, event, '150px')">[?]</a></td> --->
									<td class="BlendedTextBoxC">Secound Draw Day<a href="#" class="hintanchor" onMouseover="showhint('2nd Draw date for this account, up to 2 are allowed per account', this, event, '150px')">[?]</a></td>
									<!--- <td class="BlendedTextBoxC">Second Draw Percent (%)<a href="#" class="hintanchor" onMouseover="showhint('2nd draw percentage. ', this, event, '150px')">[?]</a></td> --->
									<td class="BlendedTextBoxC">Second Draw  Amount ($)<a href="#" class="hintanchor" onMouseover="showhint('2nd draw $ amount', this, event, '150px')">[?]</a></td>									
									<!--- <td class="BlendedTextBoxC">Second Draw Fixed Amount ($<a href="#" class="hintanchor" onMouseover="showhint('2nd draw fixed $ amount', this, event, '150px')">[?]</a>)</td> --->
									<td class="BlendedTextBoxC">EFT Begin Date<br /><a href="#" class="hintanchor" onMouseover="showhint('Date to begin EFT draws, if blank currently active', this, event, '150px')">[?]</a></td>
									<td class="BlendedTextBoxC">EFT End Date<br /><a href="#" class="hintanchor" onMouseover="showhint('Ending date of EFT draws, if blank; unendng.', this, event, '150px')">[?]</a></td>
									<!--- <td class="BlendedTextBoxC">EFT Email<a href="#" class="hintanchor" onMouseover="showhint('Email of the account owner or someone responsible for the account, secondary EFT draws will get email notification of EFT draw in place of invoice.', this, event, '150px')">[?]</a></td> --->
																																																	
 								</tr>
						<cfoutput  query="EFTinfo" group="csolomonkey">
									<cfset totaldue = 0>
									<cfset netamtdue = 0>
									<cfset EFTBalance = 0>
									<cfset totalamt = 0>
									<cfset offset = 0>
									<cfset counter = counter + 1>
						<cfquery name="qryInvAmt" datasource="#application.datasource#"> 
							Select IM.mLastInvoiceTotal
								,IM.dtInvoiceStart 
								,IM.dtInvoiceEnd 
								,IM.iInvoiceMaster_ID
								,(select sum (inv.iquantity * inv.mamount) from  InvoiceDetail INV 
								where IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID and INV.dtrowdeleted is null) as 'TipsSum'
							from
							InvoiceMaster IM
							 where  IM.cSolomonKey =  '#cSolomonKey#'
								and IM.bMoveInInvoice is null 
								and IM.bMoveOutInvoice is null						 
								  and IM.bFinalized = 1 
								and im.cAppliesToAcctPeriod =  '#thisdate#'	
						</cfquery>
 
						<cfquery name="qrysolomon" datasource="#application.datasource#">	
							select  isNull(Sum(amount ) , 0) as  'SolomonTotal'  
							from rw.vw_Get_Trx
							where custid = '#cSolomonkey#' 
							and	rlsed = 1
							and	user7 > '#qryInvAmt.dtInvoiceStart#'
							and	user7 <=  '#qryInvAmt.dtInvoiceEnd#' 
						</cfquery>
						
						<cfquery name="qryOffset" datasource="#application.datasource#"> 
							SELECT 	IsNull(Sum(amount), 0) as 'paOffset'
							from rw.vw_Get_Trx
							where custid = '#cSolomonkey#' 
							and	rlsed = 1
							and	user7 > '#qryInvAmt.dtInvoiceEnd#'
							and	user7 <=  #Now()# 
							and doctype in ('PA', 'CM',  'RP', 'NS', 'NC') 						
						</cfquery> 
						
						<cfquery name="sumpaymnt"  datasource="#application.datasource#"> 
							 select sum(isnull(dAmtSecondPull,0) + isnull(dAmtFirstPull,0)) as dollarsum
							 from dbo.EFTAccount efta   
							 where  dtRowDeleted is null and csolomonkey = '#EFTinfo.csolomonkey#' 
						</cfquery>	
 					
				<cfinclude template="latefeecalc.cfm">	
				<cfif qryOffset.paOffset is "">
					<cfset offset = 0>
				<cfelse>
					<cfset offset = qryOffset.paOffset>
				</cfif>
				
				<cfif qryInvAmt.mLastInvoiceTotal is "">  
					<cfset  LastInvoiceTotal = 0>
				<cfelse>
					<cfset  LastInvoiceTotal = qryInvAmt.mLastInvoiceTotal>		
				</cfif>
				<cfif qrysolomon.SolomonTotal is "">  
					<cfset qrysolomon.SolomonTotal = 0>
					<cfelse>
					<cfset thisSolomonTotal = qrysolomon.SolomonTotal >		
				</cfif> 
				<cfif qryInvAmt.TipsSum is ""> 
					<cfset thisTipsSum = 0>
				<cfelse>
					<cfset thisTipsSum =  qryInvAmt.TipsSum  >		
				</cfif> 	
 												 

				<cfset finalamt = LastInvoiceTotal + thisSolomonTotal +thisTipsSum> 
				<cfset adjfinal = LastInvoiceTotal + thisSolomonTotal  + thisTipsSum  + offset +  LateFee>
				<tr>
					<td style="text-align:center" >#cAptNumber#</td>										
					<td nowrap="nowrap"><a href="TenantEdit.cfm?iEFTAccount_ID=#iEFTAccount_ID#&ID=#eftinfo.iTenant_ID#&tenantSolomonKey=#eftinfo.cSolomonKey#">#TenantName#</a></td>
					<td nowrap="nowrap">#cSolomonkey#</td>
					<!--- <td style="text-align:right">#dollarformat(qryInvAmt.mLastInvoiceTotal)#</td> last invoice --->
					<!--- <td style="text-align:right">#dollarformat(qrysolomon.SolomonTotal)#</td> solomon --->
					<!--- <td style="text-align:right">#dollarformat(qryInvAmt.TipsSum)# </td> <!--- tips --->

					<td style="text-align:right">#dollarformat(finalamt)#</td><!--- final amount --->
					<td style="text-align:right">#dollarformat(offset)#</td><!--- offset --->
					<td style="text-align:right">#dollarformat(LateFee)#</td><!--- LateFee --->
					<td style="text-align:right">#dollarformat(adjfinal)#</td>
					<td style="text-align:right">#dollarformat(dSocSec)#</td> 
					<td style="text-align:right">#dollarformat(dMiscPayment)#</td> --->
					<cfset netchgamt = adjfinal>
					<cfif   dDeferral is not "" >
						<cfset netchgamt = netchgamt - dDeferral>
					</cfif>
					<cfif   dSocSec  is not "" >										
						<cfset netchgamt = netchgamt - dSocSec>
					</cfif>
					<cfif   dMiscPayment  is not "" >										
						<cfset netchgamt = netchgamt - dMiscPayment>
					</cfif>
					<td style="text-align:right">#dollarformat(netchgamt)# </td>	
				</tr>
				<cfoutput>
					<cfset totaleftpaymentamt  =    firstpaymntamt  + secondpaymntamt>
					<tr style="background:##EEEEEE">
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<!--- <td>&nbsp;</td>
								<td>&nbsp;</td>	
								<td>&nbsp;</td>		
								<td>&nbsp;</td>	
								<td>&nbsp;</td>	
								<td>&nbsp;</td>	
								<td>&nbsp;</td>
								<td>&nbsp;</td>	
								<td>&nbsp;</td>	 --->																				 																				
								<!--- <td nowrap="nowrap">#ContactName#</td> --->

								<cfif showall  is "">
									<CFIF dtRowDeleted IS NOT "" OR dtRowEnd IS NOT "" or bUsesEFT is "">
										<td class="BlendedTextBoxC">X</td>
									<cfelse>
										<td class="BlendedTextBoxC">&nbsp;</td>
									</CFIF>
								</cfif>	
								<cfif isDefined("session.CodeBlock") and ListFindNoCase(session.CodeBlock,25) GT 0>
									<td> <a href="TenantEFTDetailEdit.cfm?iEFTAccount_ID=#iEFTAccount_ID#&iTenant_ID=#eftinfo.iTenant_ID#&tenantSolomonKey=#eftinfo.cSolomonKey#">#iEFTAccount_ID#</a></td>
								<cfelse>
									<td>#iEFTAccount_ID#</td>
								</cfif>
								
								<!--- <td><cfif (isLTC is "Y") and (IsContactPayer is 1)>C<cfelseif (isLTC is "") and (IsPayer is 1) >T<cfelse>&nbsp;</cfif></td>
								<td><cfif (isLTC is "Y") and (IsContactPrimPayer is 1)>C<cfelseif (isLTC is "") and (IsPrimPayer is 1) >T<cfelse>&nbsp;</cfif></td> --->
								<td>#right(cRoutingNumber,4)#</td>
								<td>#right(CaCCOUNTnUMBER,4)#</td>
								<!--- <TD><cfif ((cAccountType is 'C') or  (cAccountType is 'c'))>C<cfelse>S</cfif></TD>
								<td>#iOrderofPull#</td> --->
								<td align="center"><cfif iDayofFirstPull is not ""> #iDayofFirstPull#<cfelse>1</cfif></td>
								
								 <cfif (dPctFirstPull is "") and (iDayofFirstPull is "") and (dAmtFirstPull is "")>
									<cfset pctfirstpull = 100>
								<cfelse>
									<cfset pctfirstpull = dPctFirstPull>
								</cfif>
								<!--- <td>#pctfirstpull#</td> --->
								<CFIF iSnUMERIC(pctfirstpull) and isnumeric(sumpaymnt.dollarsum) and isnumeric(netchgamt)>
									<cfset pctamt = ((netchgamt- sumpaymnt.dollarsum) * (pctfirstpull/100))>
								<CFELSE>
									<cfset pctamt = 0 >
								</CFIF>
								<cfif ((dAmtFirstPull   is '') or  (dAmtFirstPull is 0 ))>
									<td><cfif pctamt lte 0>#dollarformat(0.00)#<cfelse>#dollarformat(pctamt)#</cfif> </td>
								<cfelse>
									<td>#dollarformat(dAmtFirstPull)# </td>
								</cfif>
								<td align="center">#iDayofSecondPull#</td>
								<!--- <td>#dPctSecondPull#</td> --->
								<CFIF iSnUMERIC(dPctSecondPull)>
									<cfset pctamt = ((netchgamt- sumpaymnt.dollarsum) * (dPctSecondPull/100))>
								<CFELSE>
									<cfset pctamt = 0 >
								</CFIF>
								<cfif  ((dAmtSecondPull  is '') or  (dAmtSecondPull  is 0)) >
									<td>#Dollarformat(pctamt)#</td>
								<cfelse>
									<td>#dollarformat(dAmtSecondPull)#</td>
								</cfif>
								<td>#dateformat(dtBeginEFTDate, 'mm/dd/yyyy')#</td>
								<td>#dateformat(dtEndEFTDate, 'mm/dd/yyyy')#</td>
								<!--- <td>#Email#</td> --->
					</tr>
				</cfoutput>
			</cfoutput> 
	   		<cfif showall  is "N">	
				 <tr>
					<td colspan="14"><input type="button" name="Show All EFT's"  value="Show all EFT's for this house including non-current EFT's"  onClick="location.href='TenantEFTHouse.cfm?ShowAll='" /></td>
				 </tr>			

			<cfelse>
				 <tr>
					<td colspan="14"><input type="button" name="Show Current EFT's"  value="Show ONLY current EFT's"  onClick="location.href='TenantEFTHouse.cfm?ShowAll=N'" /></td>
				 </tr>
			</cfif> 
			<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
				<tr>
					<td colspan="14">. <input type="button" name="AllEFT"  value="All Company EFT's"  onClick="location.href='TenantEFTAll.cfm?'" /></td>
				</tr>
			</cfif>
			</table>
		<!--- Include intranet footer --->
		<cfinclude template="../../footer.cfm">		
	
 
