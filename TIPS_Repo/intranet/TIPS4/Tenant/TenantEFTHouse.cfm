<!---  
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|sfarmer     |03/20/2012  |  Added for deferred New Resident Fee project 75019                 |
|sfarmer     | 9/5/2012   | Project 93488 -  removed approval column.                          |
| sfarmer    | 11/20/2012 |tickets 97882, 95010, 95009, 95468, 97570, 97710 for  misc. updates | 
| sfarmer    | 02/07/2013 |project 97710 corrections for sorting of display & latefee calc     |
| sfarmer    | 08/08/2013 |project 106456 EFT Updates                                          |
| sfarmer    | 09/05/2013 |project 106456 EFT Updates - corrections                            |
|sfarmer     | 11/25/2013 | 110630 - updates for eft draw amt                                  |
|mstriegel   | 05/14/2018 | Converted code to use cfc and cleaned it up                        |
----------------------------------------------------------------------------------------------->
<!--- create the objects we will be using for tis process --->
<cfset oEFTBoxServices = CreateObject("component","intranet.TIPS4.CFC.Components.EFT.EFTBoxServices")>
<cfset oEFTHouseServices = CreateObject("component","intranet.TIPS4.CFC.Components.EFT.EFTServices")>

<!--- Include Intranet Header --->
<cfinclude template="../../header.cfm">
<h1 class="PageTitle"> Tips 4 - Tenant EFT House </h1>

<cfinclude template="../Shared/HouseHeader.cfm">

<!--- declare variables --->
<cfset thisdate = dateformat(#now()#, 'YYYYMM')> 
<cfset eftpulmonth = dateformat( #now()#, 'YYYYMM') >
<cfset view = 'thismonth'>
<cfset compmonth = #now()#>
<cfset strtday = 1>
<cfset endday = 25> 	
<cfset days = "">
<cfset housecount = 0>		
<cfset counter = 0>	
<cfset totalpaymentamt = 0>
<cfparam name="srt" default="cAptNumber"> 
<cfparam name="showall" default="">
<cfparam name="netchgamt" default="0">
<cfparam name="firstpaymntamt" default="0">
<cfparam name="secondpaymntamt" default="0">	

<!--- retrieve the EFT info for the house residents --->
<cfset eftInfo = oEFTHouseServices.getEFTHouseInfo(houseid="#session.qselectedhouse.ihouse_id#",acctPeriod="#thisdate#",showall="#showall#",days="#days#",strtday=#strtday#,endday=#endday#,sortby=srt)>

<!--- css --->
<link href="../Styles/Index.css" rel="stylesheet" type="text/css" /> 
<!--- javascript --->
<script src="..\Assets\Javascript\tenant\tenantEFT.js" type="text/javascript"></script>	
<cfinclude template="../Shared/JavaScript/ResrictInput.cfm" >
<script src="../ScriptFIles/Functions.js"></script>
<script>
	window.onload=createhintbox;
</script>

<!---- display --->
<table border="1" >
	<cfoutput>
		<tr bordercolor="white" >
			<td colspan="14">  Pull Period: #eftpulmonth# </td>
		</tr>
		<tr bordercolor="white" >
			<td colspan="14">  View:All Days </td>
		</tr>		
		<cfif showall  is ""> 
			<tr  bordercolor="white">
				<td colspan="15">Includes expired EFT's</td>
			</tr>
		</cfif>
	
		<tr bordercolor="white">
			<td class="BlendedTextBoxC" nowrap="nowrap"  onMouseOver="hoverdesc('Sort by Apartment Number');" onMouseOut="resetdesc();">
				<a href="TenantEFTHouse.cfm?srt=cAptNumber&ShowAll=#ShowAll#">Apartment Nbr.</a>
			</td>								
			<td class="BlendedTextBoxC" nowrap="nowrap" onMouseOver="hoverdesc('Sort by Tenant Name');" onMouseOut="resetdesc();">
				<a href="TenantEFTHouse.cfm?srt=TenantName&ShowAll=#ShowAll#">Tenant Name</a>
				<br />(Select to edit
				<br /> Tenant information)
			</td>
			<td class="BlendedTextBoxC" nowrap="nowrap"  onMouseOver="hoverdesc('Sort by Resident ID');" onMouseOut="resetdesc();">
				<a href="TenantEFTHouse.cfm?srt=cSolomonkey&ShowAll=#ShowAll#">Resident ID</a>
			</td>	
			<td class="BlendedTextBoxC">Invoice Balance for EFT<br />
				<a href="##" class="hintanchor" onMouseover="showhint('The Final (Adjusted) Invoice amount to be drawn by EFT ', this, event, '150px')">[?]</a>
			</td>																		
			<cfif showall  is "">
				<td class="BlendedTextBoxC">
					Not<br />Active<br />
					<a href="##" class="hintanchor" onMouseover="showhint('An X indicates this EFT account has been turned off, to reactivate click on the link and reprocess ', this, event, '150px')">[?]</a>
				</td>
			</cfif>	
			<td class="BlendedTextBoxC">
				EFT Detail<br />(Select to edit<br /> the EFT Account) 
				<a href="##" class="hintanchor" onMouseover="showhint('Link to Tenant EFT detail page', this, event, '150px')">[?]</a>
			</td>			
			<td class="BlendedTextBoxC">First Draw Day
				<a href="##" class="hintanchor" onMouseover="showhint('First draw day for the account, does not have to be the first of the month. If blank, first of the month.', this, event, '150px')">[?]</a>
			</td>
			<td class="BlendedTextBoxC">First Draw  Amount ($)
				<a href="##" class="hintanchor" onMouseover="showhint('First draw $ amount', this, event, '150px')">[?]</a>
			</td>									
			<td class="BlendedTextBoxC">Secound Draw Day
				<a href="##" class="hintanchor" onMouseover="showhint('2nd Draw date for this account, up to 2 are allowed per account', this, event, '150px')">[?]</a>
			</td>
			<td class="BlendedTextBoxC">Second Draw  Amount ($)
				<a href="##" class="hintanchor" onMouseover="showhint('2nd draw $ amount', this, event, '150px')">[?]</a>
			</td>									
			<td class="BlendedTextBoxC">Late Fees<br />
				<a href="##" class="hintanchor" onMouseover="showhint('Late Fees that will be added to EFT Amount', this, event, '150px')">[?]</a>
			</td>
			<td class="BlendedTextBoxC">EFT Begin Date<br />
				<a href="##" class="hintanchor" onMouseover="showhint('Date to begin EFT draws, if blank currently active', this, event, '150px')">[?]</a>
			</td>
			<td class="BlendedTextBoxC">EFT End Date<br />
				<a href="##" class="hintanchor" onMouseover="showhint('Ending date of EFT draws, if blank; unendng.', this, event, '150px')">[?]</a>
			</td>
		</tr>
	</cfoutput>		
	<cfoutput  query="EFTinfo" group="csolomonkey">
		<cfset totalamt = 0>
		<cfset offset = 0>
		<cfset counter = counter + 1>
		<cfset housecount = housecount + 1>
		
		<cfset qryInvAmt = oEFTHouseServices.getInvAmt(solomonkey=EFTInfo.cSolomonKey,AcctPeriod=#thisdate#,all=0)>
		<cfif isDate(qryInvAmt.dtInvoiceStart) AND isDate(qryInvAmt.dtInvoiceEnd)>		
			<cfset thisSolomonTotal = session.oSolomonServices.getSolomonTotal(custid=EFTInfo.cSolomonKey,invoiceStart=qryInvAmt.dtInvoiceStart,invoiceEnd=qryInvAmt.dtInvoiceEnd).SolomonTotal>
			<cfset offset = session.oSolomonServices.getOffSet(custid=EFTInfo.cSolomonKey,invoiceEnd=qryInvAmt.dtInvoiceEnd).paOffset>
 		<cfelse>
 			<cfset thisSolomonTotal = 0>
 			<cfset offset = 0>
 		</cfif>

 		<cfset sumPaymnt = oEFTBoxServices.sumpaymnt(solomonkey=eftinfo.cSolomonKey)>
		<cfset LateFee = oEFTHouseServices.getlatefee(solomonkey=eftinfo.cSolomonKey,AcctPeriod=#thisdate#).LateFeeAmount>		
	
		<cfif Isnumeric(qryInvAmt.mLastInvoiceTotal)>  
			<cfset LastInvoiceTotal = qryInvAmt.mLastInvoiceTotal>
		<cfelse>
			<cfset LastInvoiceTotal = 0>
		</cfif>				
		<cfif Isnumeric(qryInvAmt.mInvoiceTotal)>  
			<cfset InvoiceTotal = qryInvAmt.mInvoiceTotal>
		<cfelse>
			<cfset InvoiceTotal = 0>
		</cfif>

		<cfset finalamt = LastInvoiceTotal + InvoiceTotal +thisSolomonTotal> 
		<cfset adjfinal = LastInvoiceTotal  + InvoiceTotal+ thisSolomonTotal  + offset +  LateFee>
		<cfset netchgamt = adjfinal >

		<cfif  IsNumeric(dDeferral) >
			<cfset netchgamt = netchgamt - dDeferral>
		</cfif>
		<cfif IsNumeric(dSocSec) >										
			<cfset netchgamt = netchgamt - dSocSec>
		</cfif>
		<cfif IsNumeric(dMiscPayment) >										
			<cfset netchgamt = netchgamt - dMiscPayment>
		</cfif>
		<!--- this is the residient information ---->
		<tr bordercolor="white">
			<td style="text-align:center" >#cAptNumber#</td>										
			<td nowrap="nowrap"><a href="TenantEdit.cfm?iEFTAccount_ID=#iEFTAccount_ID#&ID=#eftinfo.iTenant_ID#&tenantSolomonKey=#eftinfo.cSolomonKey#">#TenantName#</a></td>
			<td nowrap="nowrap">#cSolomonkey#</td>		
			<td style="text-align:right">#dollarformat(netchgamt)#</td>	
		</tr>
		<cfoutput>
			<cfset totaleftpaymentamt  = firstpaymntamt  + secondpaymntamt>
			<!--- this shows the details  for each of the resident. The person may have more then one EFT ---->
			<tr style="background:##EEEEEE" bordercolor="white">
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<cfset dtEndEftCompDate = dateformat(dtEndEFTDate, 'YYYYMM')>
				<cfset dtBeginEFTCompDate = dateformat(dtBeginEFTDate,'YYYYMM')> 
				<cfif iDayofFirstPull is "">
					<cfset pullDay = 1>
				<cfelseif iDayofFirstPull LTE 5>
					<cfset pullDay = 1>
				<cfelse>
					<cfset pullDay = 	iDayofFirstPull>
				</cfif>
							
				<cfif showall  is "">
					<CFIF (dtRowDeleted IS NOT '') OR (bUsesEFT is '') 	 OR ((dtEndEFTDate is not '') and   (dtEndEftCompDate LT eftpulmonth)) OR ((dtEndEFTDate is not '') and   ((dtEndEftCompDate EQ eftpulmonth) and (DatePart('d',dtEndEFTDate) LT pullDay))) OR ((dtBeginEFTDate is not '') and (dtBeginEFTCompDate gt eftpulmonth))>
								 										                 
						<td class="BlendedTextBoxC"> X</td>
					<cfelse>
						<td class="BlendedTextBoxC">&nbsp;</td>
					</cfif>
				</cfif>	
				<cfif isDefined("session.CodeBlock") and ListFindNoCase(session.CodeBlock,25) GT 0>
					<td> <a href="TenantEFTDetailEdit.cfm?iEFTAccount_ID=#iEFTAccount_ID#&iTenant_ID=#eftinfo.iTenant_ID#&tenantSolomonKey=#eftinfo.cSolomonKey#">#iEFTAccount_ID#</a></td>
				<cfelse>
					<td>#iEFTAccount_ID#</td>
				</cfif>	 					
					<td align="center">
						<cfif iDayofFirstPull is not "">
							#iDayofFirstPull#
						<cfelse>
							1
						</cfif>
					</td>								
				<cfif (dPctFirstPull is "") and (dAmtFirstPull is "")>
					<cfset pctfirstpull = 100>
				<cfelse>
					<cfset pctfirstpull = dPctFirstPull>
				</cfif>
					<CFIF IsNumeric(pctfirstpull) and isnumeric(sumpaymnt.dollarsum) and isnumeric(netchgamt)>
					<cfset pctamt = ((netchgamt- sumpaymnt.dollarsum) * (pctfirstpull/100))>
				<CFELSE>
					<cfset pctamt = 0 >
				</CFIF>
				<CFIF (dtRowDeleted IS NOT '') or (bUsesEFT is '') OR ((dtEndEFTDate is not '') and  ( dtEndEFTDate  LE compmonth)) or ((dtBeginEFTDate is not '') and (dtBeginEFTDate GE compmonth))>	
					<td>Not Active</td>
					<td align="center">#iDayofSecondPull#</td>
					<td>N/A</td>
					<td>N/A</td>
				<cfelse>	
					<cfif ((dAmtFirstPull   is '') or  (dAmtFirstPull is 0 ))>
						<td><cfif pctamt lte 0>#dollarformat(0.00)#<cfelse>#dollarformat(pctamt)#</cfif> </td>
					<cfelse>
						<td>#dollarformat(dAmtFirstPull)# </td>
					</cfif>
				 
					<td align="center">#iDayofSecondPull#</td>
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
		</cfoutput>
	</cfoutput> 
	<cfoutput>
		<tr bordercolor="white">
			<td colspan="15">EFT Count: #housecount#</td>
		</tr>
		<cfif showall  is "N">	
			<tr bordercolor="white">
				<td colspan="14">
					<input type="button" name="Show All EFT's"  value="Show all EFT's for this house including non-current EFT's"  onClick="location.href='TenantEFTHouse.cfm?ShowAll=&srt=#srt#'" />
				</td>
			</tr>			
		<cfelse>
			<tr bordercolor="white">
				<td colspan="14">
					<input type="button" name="Show Current EFT's"  value="Show ONLY current EFT's"  onClick="location.href='TenantEFTHouse.cfm?ShowAll=N&srt=#srt#'" />
				</td>
			</tr>
		</cfif> 
		<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
			<tr bordercolor="white">
				<td colspan="14">.<input type="button" name="AllEFT"  value="All Company EFT's"  onClick="location.href='TenantEFTAll.cfm?view=thismonth'" /></td>
			</tr>
		</cfif>
	</cfoutput>
</table>

<!--- Include intranet footer --->
<cfinclude template="../../footer.cfm">	