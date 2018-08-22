<!---  -----------------------------------------------------------------------------------------
 sfarmer     | 9/5/2012   | Project 93488 -  removed approval button.   added link for download|
 sfarmer     | 11/20/2012 |tickets 97882, 95010, 95009, 95468, 97570, 97710 for  misc. updates |
| sfarmer    | 08/08/2013 |project 106456 EFT Updates                                          |
| sfarmer    | 09/05/2013 |project 106456 EFT Updates - corrections                            |
|sfarmer     | 11/25/2013 | 110630 - updates for eft draw amt                                  |
|mstriegel   | 05/15/2018 | Converted code to use cfc and cleaned it up                        |
----------------------------------------------------------------------------------------------->
<!--- create the objects we will be using for tis process --->
<cfset oEFTAllServices = CreateObject("component","intranet.TIPS4.CFC.Components.EFT.EFTServices")>

<!--- Include Intranet Header --->
<cfinclude template="../../header.cfm">
<h1 class="PageTitle"> Tips 4 - Tenant EFT Information Edit </h1>
<cfinclude template="../Shared/HouseHeader.cfm">
<!--- declare variables --->
<cfset thisdate = dateformat(#now()#, 'YYYYMM')> 
<cfset eftpulmonth = dateformat( #now()#, 'YYYYMM') >
<cfset view = 'thismonth'>
<cfset compmonth =  #now()#>
<cfset strtday = 1>
<cfset endday = 25> 	
<cfset days = "">
<cfset totalcount = 0>
<cfset housecount = 0>
<cfset totalallcount = 0>
<cfset houseallcount = 0>	
<cfset counter = 0>
<cfset thisperson = "">	
<cfset thishouse = "">				
<cfset totalpaymentamt = 0>
<cfparam name="netchgamt" default="0">
<cfparam name="firstpaymntamt" default="0">
<cfparam name="secondpaymntamt" default="0">	
<cfparam name="showall" default="Y">		
<!--- get EFT Information for all houses --->
<cfset eftInfo = oEFTAllServices.getEFTALLInfo(AcctPeriod=thisdate,showall=showall,days=days,strtday=strtday,endday=endday)>

<cfinclude template="../Shared/Queries/StateCodes.cfm">
<cfinclude template="../Shared/Queries/PhoneType.cfm">
<cfinclude template="../Shared/Queries/TenantInformation.cfm"> 
<cfinclude template="../Shared/Queries/SolomonKeyList.cfm">
<cfinclude template="../Shared/Queries/Relation.cfm">

<!--- css --->
<link href="../Styles/Index.css" rel="stylesheet" type="text/css" /> 
<!--- javascript --->
<script src="..\Assets\Javascript\tenant\tenantEFT.js" type="text/javascript"></script>	

<!--- display --->
<table>
	<tr>
		<td colspan="15" align="center">EFT's - All Houses</td>
	</tr>							
	<tr>
		<td colspan="15">  Pull Period: <cfoutput>#eftpulmonth#</cfoutput> </td>
	</tr>
	<cfoutput query="EFTInfo" group="cHouseName">
		<cfset thishouse = #houseID#>
		<cfif housecount gt 0>
			<tr>
				<td colspan="15">Total Active House EFT Count: #housecount#</td>
			<tr>
			<tr>
				<td colspan="15">Total House All EFT Count: #houseallcount#</td>
			<tr>				
		</cfif>
		<cfset housecount = 0>
		<cfset houseallcount = 0>
		<tr style="background:##FFFF99">
			<td colspan="15" >#cHouseName# #houseID#</td>
		</tr>
		<tr>
			<td colspan="2" class="BlendedTextBoxC">Name</td>
			<td colspan="2" class="BlendedTextBoxC">Resident ID</td>
			<td class="BlendedTextBoxC">Not<br />Active</td>
			<td class="BlendedTextBoxC">EFT ID</td>
			<td class="BlendedTextBoxC">R/C</td>				
			<td class="BlendedTextBoxC">First Draw Day</td>	
			<td class="BlendedTextBoxC">First Payment Amt</td>  
			<td class="BlendedTextBoxC">Secound Draw Day</td> 
			<td class="BlendedTextBoxC">Second Payment Amt</td>
			<td class="BlendedTextBoxC">LateFee</td> 
			<td class="BlendedTextBoxC">EFT Begin Date</td>
			<td class="BlendedTextBoxC">EFT End Date</td>
		</tr>
		<cfoutput group="cSolomonkey">  
			<cfif thisperson is not "" and thisperson is not #cSolomonkey#> 
				<cfset totalpaymentamt = 0>
				<cfset thisperson = #cSolomonkey#>
			<cfelse>
				<cfset totalpaymentamt = 0>
				<cfset thisperson = #cSolomonkey#> 	
			</cfif> 
			<cfset sumpaymnt = oEFTAllServices.getSumPaymnt(solomonKey=EFTInfo.cSolomonKey)>
			<cfset qryInvAmt = oEFTAllServices.getInvAmt(solomonKey=EFTInfo.cSolomonKey,AcctPeriod=thisdate,all=1)>
			<cfset LateFee = oEFTAllServices.getlatefee(solomonkey=eftinfo.cSolomonKey,AcctPeriod=#thisdate#).LateFeeAmount>		
			
			<cfif isDate(qryInvAmt.dtInvoiceStart) AND isDate(qryInvAmt.dtInvoiceEnd)>
				<cfset SolomonTotal = session.oSolomonServices.getSolomonTotal(custid=EFTInfo.cSolomonKey,invoiceStart=qryInvAmt.dtInvoiceStart,invoiceEnd=qryInvAmt.dtInvoiceEnd).solomonTotal>
				<cfset offset = session.oSolomonServices.getOffSet(custid=EFTInfo.cSolomonKey,invoiceEnd=qryInvAmt.dtInvoiceEnd).paOffset>
			<cfelse>
				<cfset SolomonTotal = 0>
				<cfset offSet = 0>
			</cfif>					
			<cfif IsNumeric(qryInvAmt.mLastInvoiceTotal) >
				<cfset mLastInvoiceTotal = qryInvAmt.mLastInvoiceTotal>
			<cfelse>
				<cfset mLastInvoiceTotal = 0>
			</cfif>										
			<cfif IsNumeric(qryInvAmt.TipsSum)>
				<cfset TipsSum = qryInvAmt.TipsSum>
			<cfelse>
				<cfset TipsSum = 0>
			</cfif>	
			<cfset invoicechg = Offset + SolomonTotal + mLastInvoiceTotal + TipsSum>						
			<cfset adjfinal = Offset + SolomonTotal + mLastInvoiceTotal + TipsSum + LateFee>
			<cfset sum = adjfinal>
			<cfset netchgamt =0>	
			<cfset firstpaymntamt = 0>	
			<cfset secondpaymntamt = 0>								
			<cfset netchgamt = sum>
			<cfif dDeferral is not "" >
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

			<cfset counter = counter + 1>
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

			<tr style="background:##CCCCCC">
				<td colspan="2" ><a href="TenantEdit.cfm?iEFTAccount_ID=#iEFTAccount_ID#&ID=#eftinfo.iTenant_ID#&tenantSolomonKey=#eftinfo.cSolomonKey#">#TenantName#</a></td>
				<td colspan="2">#cSolomonkey#</td>
				<td colspan="11">&nbsp;</td>				
			</tr>
			<cfoutput> 
				<cfset totalallcount = totalallcount + 1>
				<cfset houseallcount = houseallcount + 1>
				<cfset totaleftpaymentamt  = firstpaymntamt + secondpaymntamt>
				<tr style="background:##EEEEEE">
					<td colspan="2">&nbsp;</td>
					<td colspan="2">&nbsp;</td>							
					<cfif showall  is "Y">								
						<cfif dtRowDeleted IS NOT ''   or bUsesEFT is '' OR ((dtEndEFTDate is not '') and  ( dtEndEFTDate  LE compmonth)) or ((dtBeginEFTDate is not '') and (dtBeginEFTDate GTE compmonth))>
							<td class="BlendedTextBoxC">X</td>
						<cfelse>
							<td class="BlendedTextBoxC">&nbsp;</td>
							<cfset totalcount = totalcount + 1>
							<cfset housecount = housecount + 1>
						</cfif>
					</cfif>	
					<td style="text-align:center;">
						<cfif isDefined("session.CodeBlock") and ListFindNoCase(session.CodeBlock,25) GT 0>
							<a href="TenantEFTDetailEdit.cfm?iEFTAccount_ID=#iEFTAccount_ID#&iTenant_ID=#eftinfo.iTenant_ID#&tenantSolomonKey=#eftinfo.cSolomonKey#">#iEFTAccount_ID#</a>
						<cfelse>
							#iEFTAccount_ID#
						</cfif>
					</td>
					<td>
						<cfif IsContactPayer is 1>C<cfelse>R</cfif>
					</td>
					<td align="center"><cfif iDayofFirstPull is not ""> #iDayofFirstPull#<cfelse>1</cfif></td>
					<cfif (dPctFirstPull is "") and (dAmtFirstPull is "")>
						<cfset pctfirstpull = 100>
					<cfelse>
						<cfset pctfirstpull = dPctFirstPull>
					</cfif>
					<cfif (dtRowDeleted IS NOT '')  or (bUsesEFT is '') OR ((dtEndEFTDate is not '') and  ( dtEndEFTDate  LE compmonth)) or ((dtBeginEFTDate is not '') and (dtBeginEFTDate GE compmonth))>
						<td>Not Active</td>								
						<td>N/A</td>
						<td>N/A</td>
						<td>N/A</td>
					<cfelse>	
						<cfif iSnUMERIC(pctfirstpull) and isnumeric(sumpaymnt.dollarsum) and isnumeric(netchgamt)>
							<cfset pctamt = ((netchgamt- sumpaymnt.dollarsum) * (pctfirstpull/100))>
						<cfelse>
							<cfset pctamt = 0 >
						</cfif>
						<cfif ((dAmtFirstPull   is '') or  (dAmtFirstPull is 0 ))>
							<td>
								<cfif pctamt lte 0>#dollarformat(0.00)#<cfelse>#dollarformat(pctamt)#</cfif>
							</td>
						<cfelse>
							<td style="color:red;">#dollarformat(dAmtFirstPull)#  Fixed </td>
						</cfif>
						<td align="center">#iDayofSecondPull#</td>
						<cfif iSnUMERIC(dPctSecondPull)>
							<cfif not IsNumeric(sumpaymnt.dollarsum)><cfset thisdollarsum = 0> <cfelse> <cfset thisdollarsum = sumpaymnt.dollarsum	> </cfif>	
							<cfif not Isnumeric(netchgamt)> <cfset netchgamt = 0></cfif>
							<cfset pctamt = ((netchgamt- thisdollarsum) * (dPctSecondPull/100))>
						<cfelse>
							<cfset pctamt = 0 >
						</cfif>
						<cfif  ((dAmtSecondPull  is '') or  (dAmtSecondPull  is 0)) >
							<td>#Dollarformat(pctamt)#</td>
						<cfelse>
							<td style="color:red;">#dollarformat(dAmtSecondPull)#  Fixed </td>
						</cfif>
						<cfif LateFee gt 0>
							<cfif (((dAmtSecondPull is not '')  and  (dAmtSecondPull is not 0) ) or  ((dAmtFirstPull is not '')  and  (dAmtFirstPull is not 0 )  )   )>
								<td>Exmpt-Fixed Amt</td>
							<cfelse>
								<td>#dollarformat(LateFee)#</td>
							</cfif>
						<cfelse>
							<td>&nbsp;</td>
						</cfif>
					</cfif>
					<td>#dateformat(dtBeginEFTDate, 'mm/dd/yyyy')#</td>
					<td>#dateformat(dtEndEFTDate, 'mm/dd/yyyy')#</td>
				</tr>
				<cfif  (firstpaymntamt is not "")>
					<cfset totalpaymentamt =  totalpaymentamt + firstpaymntamt>
				</cfif>
				<cfif  (secondpaymntamt is not "")>
					<cfset totalpaymentamt =  totalpaymentamt + secondpaymntamt>
				</cfif>																				
			</cfoutput>
		</cfoutput>
	</cfoutput> 				
	<cfoutput>
		<tr>
			<td colspan="15">Total House Active EFT Count: #housecount#</td>
		<tr>
		<tr>
			<td colspan="15">Total House All EFT Count: #houseallcount#</td>
		<tr>				
		<tr style=" background-color:##66FF66">
			<td colspan="15">Total All Active EFT Count: #totalcount#</td>
		<tr>
		<tr style=" background-color:##66FF66">
			<td colspan="15">Total All EFT Count: #totalallcount#</td>
		<tr>
	</cfoutput>
	<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
		<tr>
			<td colspan="15">
				<cfoutput>
					<input type="button" name="DownloadFile"  value="Create Download File"  onClick="location.href='TenantEFTAllDwnld.cfm?thisdate=#thisdate#&eftpulmonth=#eftpulmonth#&strtday=#strtday#&endday=#endday#&showall=#showall#'" />
				</cfoutput>
			</td>
		</tr>							 
	</cfif>						
</table>

 <!--- Include intranet footer --->
<cfinclude template="../../footer.cfm">		

