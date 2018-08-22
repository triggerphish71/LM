<!---  
S Farmer     | 05/20/2014 | 116824 - Move-In update - Allow ED to adjust BSF rate               |
|S Farmer    | 05/20/2014 | 116824 - Phase 2 Allow different move-in and rent-effective dates   |
|            |            | allow respite to adjust BSF rates                                   |
|S Farmer    | 08/20/2014 | 116824 - back-off different move-in rent-effective dates            |
|            |            | allow adjustment of rates by all regions                            |
|S Farmer    | 09/08/2014 | 116824 - Allow all houses edit BSF and Community Fee Rates          |
|S Farmer    | 04/04/2017 | change "Respite Move Out Date" to "Respite Physical Move Out Date"  |
 --->
 	<cfparam name="prompt0" default="">
	<cfquery name="qResident" datasource="#application.datasource#">
		Select  t.cfirstname  + ' ' + t.clastname Name 
		, t.csolomonkey
		, ts.ispoints, ts.iResidencyType_ID
		,ts.dtmovein, ts.dtrenteffective
		, at.cdescription Apartmenttype, aptadd.captnumber
		,restyp.cdescription restype 
 		,t.bispayer as tenantpayer 
 		 from tenant t 
		 join tenantstate ts on t.itenant_id = ts.itenant_id
		 join aptaddress aptadd on ts.iaptaddress_id = aptadd.iaptaddress_id
		 join apttype at on at.iapttype_id = aptadd.iapttype_id
		join residencytype  restyp on restyp.iResidencyType_ID  = ts.iResidencyType_ID
 
		 where t.itenant_id = #prompt0#
	</cfquery> 		
	
	<cfquery name="qResidentPointsAtMoveIn" datasource="#application.datasource#">
		select  top 1 ispoints from tenant t
		join p_tenantstate ts on ts.itenant_id  =t.itenant_id 
		and t.itenant_id = #prompt0#
		where ts.dtmovein is not null  
		   and left(ts.dtrowend,10) <= left('#qResident.dtmovein#',10) 
		   
		 order by ts.dtrowend	
	</cfquery>
<cfsavecontent variable="PDFhtml">
	<cfheader name="Content-Disposition" value="attachment;filename=MoveInReport-#qResident.Name#.pdf">
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<!--- <html xmlns="http://www.w3.org/1999/xhtml"> --->
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Resident Move In Summary</title>
	</head>
 
<!--- 		EXEC rw.sp_ActivityLog_Detail
			@iTenant_ID =   '#prompt0#' , 
			@cPeriod =   ''   --->
			<cfquery name="HouseDetail" datasource="#application.datasource#">
				select cname HouseName, caddressline1, caddressline2, ccity
				,  cstatecode, czipcode, cphonenumber1 
				from house where ihouse_id = #session.qselectedhouse.ihouse_id#
			</cfquery>			  
			
			<cfquery name="qResident" datasource="#application.datasource#">
				Select  t.cfirstname  + ' ' + t.clastname Name 
				, t.csolomonkey
				, ts.ispoints
				, ts.iResidencyType_ID
				, ts.dtMoveOutProjectedDate
				,ts.dtmovein
				, ts.dtrenteffective
				, at.cdescription Apartmenttype
				, aptadd.captnumber
				,restyp.cdescription restype 
				,t.bispayer as tenantpayer 
				 from tenant t 
				 join tenantstate ts on t.itenant_id = ts.itenant_id
				 join aptaddress aptadd on ts.iaptaddress_id = aptadd.iaptaddress_id
				 join apttype at on at.iapttype_id = aptadd.iapttype_id
				 join residencytype  restyp on restyp.iResidencyType_ID  = ts.iResidencyType_ID
				 where t.itenant_id = #prompt0#
			</cfquery> 		
			<cfquery name="qPayor" datasource="#application.datasource#">
				Select top 1 t.cfirstname  + ' ' + t.clastname Name , t.csolomonkey, ts.ispoints
				, ts.iResidencyType_ID, ts.dtMoveOutProjectedDate
				,ts.dtmovein, ts.dtrenteffective, at.cdescription Apartmenttype, aptadd.captnumber
				,restyp.cdescription restype,
				ltc.bispayer as contactpayer, 
				t.bispayer as tenantpayer,
				cont.cfirstname + ' ' + cont.clastname as 'ContactName', cont.cAddressLine1 as ContactAddr1 , 
				cont.cAddressLine2 as ContactAddr2
				, cont.cCity as ContactCity, cont.cStateCode as ContactState, cont.cZipCode as ContactZipcode, 
				cont.cphonenumber1 as COntactPhone
				 from tenant t 
				 join tenantstate ts on t.itenant_id = ts.itenant_id
				 join aptaddress aptadd on ts.iaptaddress_id = aptadd.iaptaddress_id
				 join apttype at on at.iapttype_id = aptadd.iapttype_id
				join residencytype  restyp on restyp.iResidencyType_ID  = ts.iResidencyType_ID
				left join linktenantcontact ltc on t.itenant_id = ltc.itenant_id and ltc.bIsPayer = 1 and ltc.dtrowdeleted is null
				left join contact cont on ltc.icontact_id = cont.icontact_id
				 where t.itenant_id = #prompt0#
			</cfquery> 			
			<cfquery name="MoveInInvoice"  datasource="#application.datasource#">
				select im.*, inv.* , inv.cappliestoacctperiod as acctperiod
				,case when ichargetype_id in (89, 7, 91) then '1MonthlyFee'
						when ichargetype_id not in (69,7,89,91,66) then '2AncillaryFee'
						when ichargetype_id = 69 then '3OneTimeFee'
						else '4MiscFee' end as 'Feetype'
				, inv.cRowStartUser_ID as 'respiteperiod'
				from invoicemaster im
				join invoicedetail inv on im.iinvoicemaster_id = inv.iinvoicemaster_id
				
				where im.csolomonkey = #qResident.csolomonkey#
					and im.dtrowdeleted is null
					and inv.dtrowdeleted is null
					and im.bmoveininvoice = 1
					and inv.iquantity > 0
					order by Feetype, inv.cappliestoacctperiod,	ichargetype_id	 
			</cfquery>	
 
		<cfif qResident.recordcount is 0>
			<cfquery name="qResident" datasource="#application.datasource#">
				Select t.clastname, t.cfirstname , t.csolomonkey from tenant t where t.itenant_id = #prompt0#
			</cfquery> 

			<body>
			
				<table width="95%"  cellspacing="2" cellpadding="2" > 
					<tr> 
						<div><td style="text-align:center">New Resident Fees</td> </div>
					</tr> 	
					<tr> 
						<div><td style="text-align:center">&nbsp;</td> </div>
					</tr> 								
					<tr>
						<td><cfoutput>No information found for #qResident.cfirstname# #qResident.clastname#
						, Resident ID #t.csolomonkey# please review your selection</cfoutput></td>
					</tr>
				</table>
			</body>
		<cfelse> 
			<cfset MSFsubtotal  = 0>
			<cfset ancillarysubtotal  = 0>
			<body>
				<table width="95%"  cellspacing="2" cellpadding="2" > 
					<cfoutput query="HouseDetail"   >
						<tr> 
							<div><td style="text-align:center;  font-size:18px; font-family:Georgia, "Times New Roman", Times, serif">Move In Invoice</td> </div>
						</tr>			
						<tr> 
							<div><td style="text-align:center">&nbsp;</td> </div>
						</tr> 								
 						<tr> 
							<div>
							<td   style="text-align:center; font-size:16px; ">#HouseName#</td> 
							</div>
						</tr>
 						<tr> 
							<div>
							<td   style="text-align:center; font-size:16px; ">#caddressline1#</td> 
							</div>
						</tr>	
						<cfif caddressline2 is not ''>	
 						<tr> 
							<div>
							<td   style="text-align:center; font-size:16px; ">#caddressline2#</td> 
							</div>
						</tr>		
						</cfif>	
 						<tr> 
							<div>
							<td   style="text-align:center; font-size:16px; ">#ccity#, #cstatecode# #czipcode#</td> 
							</div>
						</tr>	
 						<tr> 
							<div>
							<td   style="text-align:center; font-size:16px; ">
							(#left(cphonenumber1,3)#) #mid(cphonenumber1,4,3)#-#right(cphonenumber1,4)# 
							</td> 
							</div>
						</tr>		
 						<tr> 
							<div>
							<td   style="text-align:center; font-size:16px; ">&nbsp;</td> 
							</div>
						</tr>																							
					</cfoutput>
				</table>			
				<table width="95%"  cellspacing="2" cellpadding="2" > 
					<cfoutput query="qResident">
 						<tr> 
							<div>
								<td colspan="5" style="text-align:center; font-size:13px; ">Below is a summary of agreed upon fees for your apartment, care and ancillary services. Your Payor will be responsible for providing full payment at the time you become financially responsible for your apartment #dateformat(dtrenteffective, 'mm/dd/yyyy')#. </td> 
							</div>
						</tr> 
 						<tr> 
							<div>
								<td colspan="5" style="text-align:center; font-size:14px; ">&nbsp;</td> 
							</div>
						</tr>
						<tr> 
							<div>
								<td   style="text-align:left">Resident ID:</td> 							
								<td   style="text-align:left">#csolomonkey#</td> 
								<td  >&nbsp;</td> 							
								<td   style="text-align:left">Apartment Type:</td> 
								<td   style="text-align:left">#Apartmenttype#</td> 							
							</div>
						</tr> 
						<tr> 
							<div>
								<td   style="text-align:left">Resident Name:</td> 							
								<td   style="text-align:left; font-weight:bold" >#Name#</td> 
								<td  >&nbsp;</td> 							
								<td   style="text-align:left">Apartment Number:</td> 
								<td   style="text-align:left">#captnumber#</td> 							
							</div>
						</tr> 	
						<tr> 
							<div>
								<td   style="text-align:left">
								Financial Possession Date:
								</td> 							
								<td   style="text-align:left">
								#dateformat(dtrenteffective, "mm/dd/yyyy")#
								</td> 
								<td  >&nbsp;</td> 							
								<td   style="text-align:left">
								Residency Type:
								</td> 
								<td   style="text-align:left">
								#restype#
								</td> 							
							</div>
						</tr> 
						<tr> 
							<div>
								<td   style="text-align:left">
								Physical Move-In Date:
								</td> 							
								<td   style="text-align:left">
									#dateformat(dtmovein, "mm/dd/yyyy")#
								</td> 
								<td  >&nbsp;</td> 							
								<td   style="text-align:left">
								Service Points:
								</td> 
								<td   style="text-align:left">
								<cfif qResidentPointsAtMoveIn.recordcount is 0>
									#ispoints#
								<cfelse>
									<cfif #qResidentPointsAtMoveIn.ispoints# is ''>
										0
									<cfelse>
										#qResidentPointsAtMoveIn.ispoints#
									</cfif>
								</cfif>
								</td> 							
							</div>
						</tr>  
		
						<cfif iResidencyType_ID is 3>
						<tr> 
							<div>
								<td  style="text-align:left">Respite Physical Move Out Date:</td> 							
								<td  style="text-align:left">
									#dateformat(dtMoveOutProjectedDate, "mm/dd/yyyy")#
								</td> 
								<td>&nbsp;</td> 							
								<td  style="text-align:left">&nbsp;</td> 
								<td  style="text-align:left">&nbsp;</td> 							
							</div>
						</tr>		
						</cfif>								
					</cfoutput>	
					</table>
					
					<table width="95%"  cellspacing="2" cellpadding="2" >
 						<tr> 
							<div>
							<td colspan="6" style="text-align:left; font-size:20px;
							 font-weight:bold ">&nbsp;</td> 
							</div>
						</tr>						
 						<tr> 
							<div>
							<td colspan="6" style="text-align:left; font-size:20px;
							 font-weight:bold ">Summary of Charges:</td> 
							</div>
						</tr> 					
 					<cfoutput query="MoveInInvoice" group="Feetype" >
						<cfif Feetype is "1MonthlyFee">
							<tr>
								<div>
									<td ><div>&nbsp;</div></td>
									<td style="text-decoration:underline;text-align:center;
									 font-weight:bold"><div>Start Date</div></td>
									<td style="text-decoration:underline;text-align:center;
									 font-weight:bold"><div>End Date</div></td>
									<Td style="text-decoration:underline;text-align:center;
									 font-weight:bold"><div>Days Charged</div></Td>
									<td style="text-decoration:underline;text-align:center;
									 font-weight:bold"><div>Rate</div></td>
									<td style="text-decoration:underline;text-align:center; 
									font-weight:bold"><div>Total</div></td>
								</div>
							</tr>						
							<tr>
								<div>
									<td style=" font-style:italic; text-align:center;
									 font-weight:bold">
										<div>Monthly Service Fees</div>
									</td>
									<td style="text-align:center; font-weight:bold">
									<div>&nbsp;</div></td>
									<td style="text-align:center; font-weight:bold">
									<div>&nbsp;</div></td>
									<Td style="text-align:center; font-weight:bold">
									<div>&nbsp;</div></Td>
									<td style="text-align:center; font-weight:bold">
									<div>&nbsp;</div></td>
									<td style="text-align:center; font-weight:bold">
									<div>&nbsp;</div></td>
								</div>
							</tr>
						<cfoutput >
							
							<tr><div>
								<td >#cdescription#</td>
								</div>
								<div>
								<cfif ichargetype_id is 91>
								<td  style="text-align:center">
										<cfif datepart("m",qResident.dtMoveIn)is right(acctperiod,2)>
											#dateformat(qResident.dtMoveIn, 'mm/dd/yyyy')#
										<cfelse>
											<cfset monthstart =  left(acctperiod,4) & '-' &
											 right(acctperiod,2) & '-' & '01'>
											#dateformat(monthstart, 'mm/dd/yyyy')#
										</cfif>
								</td>
								<cfelse>
									<td  style="text-align:center">
										<cfif datepart("m",qResident.dtRentEffective)is 
										right(acctperiod,2)>
											#dateformat(qResident.dtRentEffective, 'mm/dd/yyyy')#
										<cfelse>
											<cfset monthstart =  left(acctperiod,4) & '-' & 
											right(acctperiod,2) & '-' & '01'>
											#dateformat(monthstart, 'mm/dd/yyyy')#
										</cfif>
									</td>
								</cfif>								
								</div><!--- #DaysInMonth(CreateDate(left(acctperiod,4), right(acctperiod,2), 1))# --->
 
								<!--- <cfset eomdate = daysinmonth(dtInvoiceStart)> --->
								<!--- <cfif iquantity lt eomdate> --->
								<!--- <cfif left(dtInvoiceend, 10) is left(dtInvoiceStart,10)> --->
								
									<div>
									<td  style="text-align:center"  >
									<cfif   ( FIndNoCase('ending period', respiteperiod))>
#numberformat(right(acctperiod,2),00)#/#iquantity#/#left(acctperiod,4)#									
									<cfelse>
#numberformat(right(acctperiod,2),00)#/#DaysInMonth(CreateDate(left(acctperiod,4), 
									right(acctperiod,2), 1))#/#left(acctperiod,4)#
									</cfif>
									</td>
									</div>
<!--- 								<cfelse>
									<div>
									<td  style="text-align:center"  >#dateformat(dtInvoiceend, 'mm/dd/yyyy')#</td>
									</div>
								</cfif> --->
								<div>
								<td  style="text-align:center">#iquantity#</td>
								</div>
								<div>
								<td style="text-align:right">#dollarformat(mamount)#</td>
								</div>
								<div>
								<td   style="text-align:right" >
								#dollarformat(mamount *iquantity )#</td>
								</div>			
							</tr>
							<cfset MSFsubtotal = MSFsubtotal + (mamount *iquantity )>
						</cfoutput>
							<tr>
								<td colspan="4">&nbsp;</td>
								<td style="font-style:italic; text-align:center;">Subtotal</td>
								<td style="text-decoration:overline;
								 text-align:right;">#dollarformat(MSFsubtotal)#</td> 
							</tr>						
						<cfelseif   Feetype is "2AncillaryFee">
							<tr>
								<div>
									<td><div>&nbsp;</div></td>
									<td><div>&nbsp;</div></td>
								 	<td style="text-decoration:underline;
									text-align:center; font-weight:bold">
										<div>End Date</div></td>
									<Td  colspan="1" style="text-decoration:underline;
									text-align:right; font-weight:bold">
										<div>Units Charged</div>
									</Td>
									<td style="text-decoration:underline;text-align:center;
									 font-weight:bold"><div>Rate</div></td>
									<td style="text-decoration:underline;text-align:center;
									 font-weight:bold"><div>Total</div></td>
								</div>
							</tr>			
							<tr>
								<div>
									<td style=" font-style:italic; text-align:center;font-weight:bold">
										<div>Ancillary Fees</div>
									</td>
									<td style="text-align:center; font-weight:bold">
									<div>&nbsp;</div></td>
									<td style="text-align:center; font-weight:bold">
									<div>&nbsp;</div></td>
									<Td style="text-align:center; font-weight:bold">
									<div>&nbsp;</div></Td>
									<td style="text-align:center; font-weight:bold">
									<div>&nbsp;</div></td>
									<td style="text-align:center; font-weight:bold">
									<div>&nbsp;</div></td>
								</div>
							</tr>
						<cfoutput>				
							<tr>
								<div>
									<td >#cdescription#</td>
								</div>
								<div>
									<td >&nbsp;</td>
								</div>
								<div>
									<td   >									#numberformat(right(acctperiod,2),00)#/#DaysInMonth(CreateDate(left(acctperiod,4), right(acctperiod,2), 1))#/#left(acctperiod,4)#</td>
								</div>
								<div>
									<td  style="text-align:center">#iquantity#</td>
								</div>
								<div>
									<td style="text-align:right">
									#dollarformat(mamount)#
									</td>
								</div>
								<div>
									<td   style="text-align:right" >
									#dollarformat(mamount *iquantity )#
									</td>
								</div>			
							</tr>
							<cfset ancillarysubtotal = ancillarysubtotal + (mamount *iquantity )>
						</cfoutput> 			
							<tr>
								<td colspan="4">&nbsp;</td>
								<td style="font-style:italic; text-align:center;">Subtotal</td>
								<td style="text-decoration:overline;text-align:right; ">
								#dollarformat(ancillarysubtotal)#</td> 
							</tr>		 
						<cfelseif   Feetype is "3OneTimeFee">
 						<tr> 
							<div>
							<td colspan="6" style="text-align:left; font-size:20px; 
							font-weight:bold ">&nbsp;</td> 
							</div>
						</tr>
							<tr>
								<div>
								<td style=" font-style:italic; text-align:center;
								 font-weight:bold"><div>One Time Fees</div></td>
								<td style="text-align:center;font-size:smaller"><div>&nbsp;</div></td>
								<td style="text-align:center;font-size:smaller"><div>&nbsp;</div></td>
								<Td style="text-align:center;font-size:smaller"><div>&nbsp;</div></Td>
								<td style="text-align:center;font-size:smaller"><div>&nbsp;</div></td>
								<td style="text-align:center;font-size:smaller"><div>&nbsp;</div></td>
								</div>
							</tr>		
							
							<cfoutput>			
							<tr><div>
								<td ><cfif cdescription is 'New Resident Fee'>
								 Community Fee
								 <cfelse>
								 #cdescription#
								 </cfif>
								 </td>
								</div>
								<div>
								<td >&nbsp;</td>
								</div>
								<div>
								<td   >&nbsp;</td>
								</div>
								<div>
								<td style="text-align:center" >#iquantity#</td>
								</div>
								<div>
								<td style="text-align:right">#dollarformat(mamount)#</td>
								</div>

								<div>
								<td   style="text-align:right" >
								#dollarformat(mamount *iquantity )#
								</td>
								</div>			

							</tr>
						</cfoutput>
 						</cfif>
					</cfoutput> 
					<cfoutput>
							<tr>
								<td colspan="3">&nbsp;</td>
								<td colspan="2" style="font-weight:bold; text-align:right">
								Total Due:</td>
								<td style="font-weight:bold; text-align:right;
								 text-decoration:underline; text-decoration:overline" >
								#dollarformat(MoveInInvoice.mInvoicetotal)#
								</td>
							</tr>
					</cfoutput>					
				</table> 


		</cfif>

</cfsavecontent>
<cfsavecontent variable="PDFhtml2">
				<cfoutput query="qPayor">
				<table>
					<tr>
						<td style="text-align:left; text-decoration:underline;
						 font-weight:bold">Confirmation of Payer Information </td>
					</tr>
					<cfif qPayor.tenantpayer is 1>
						<tr>
							<td>#qPayor.Name#</td>
						</tr>
						<tr>
							<td>#HouseDetail.caddressline1# Apt. #qPayor.captnumber#</td>
						</tr>
						<cfif HouseDetail.caddressline2 is not ''>
							<tr>
								<td>#HouseDetail.caddressline2#</td>
							</tr>
						</cfif>
						<tr>
							<td>#HouseDetail.ccity#
							, #HouseDetail.cstatecode# #HouseDetail.czipcode#
							</td>
						</tr>
						<tr>
							<td>(#left(HouseDetail.cphonenumber1,3)#)
														 #mid(HouseDetail.cphonenumber1,4,3)#-#right(HouseDetail.cphonenumber1,4)#
														 </td>
						</tr>
					<cfelse>
						<tr>
							<td>#qPayor.ContactName#</td>
						</tr>
						<tr>
							<td>#qPayor.ContactAddr1#</td>
						</tr>
						<cfif qPayor.ContactAddr2 is not ''>
							<tr>
								<td>#qPayor.ContactAddr2#</td>
							</tr>
						</cfif>
						<tr>
							<td>#qPayor.ContactCity#, 
							#qPayor.contactstate# 
							#qPayor.contactzipcode#
							</td>
						</tr>
						<tr>
							<td>(#left(qPayor.ContactPhone,3)#) #mid(qPayor.ContactPhone,4,3)#-#right(qPayor.ContactPhone,4)#</td>
						</tr>					
					</cfif>					
				</table>
				</cfoutput>
			 <br /><br /><br /><br /><br />
				<cfoutput>
			<div   style="width:250px;   text-align:center; font-size: medium; border:2px solid; width:100px">For Office Use Only </div>
 		
			<div   style="width:250px;  text-align:center;  background:##CCCCCC; font-size:medium; border:2px solid; width:100px">
			Last Update: #dateformat(now(), "mm/dd/yyyy")# #Timeformat(now(),  "short")#<br />By: #HouseDetail.HouseName#</div>
			</cfoutput>
 
			</body>
			</html>	
</cfsavecontent>			
<cfdocument format="PDF" orientation="portrait" margintop="1" >	
	<cfdocumentitem type="header">
		<cfoutput>
		<div  style="text-align:center; height:350px">
			<img src="../../images/HouseImage/HouseImageNew/#Replace(HouseDetail.HouseName, ' ', '', 'all')#_Addressonly_Medium.jpeg" 
			 alt="#Replace(HouseDetail.HouseName, ' ', '', 'all')#"    />
		</div>
		<div  style="text-align:center; height:350px">
			<img src="../../images/Enlivant_logo.jpg"  height="333"  width="500" />
		</div>
		#Replace(HouseDetail.HouseName, ' ', '', 'all')#_Addressonly_Medium.jpeg  
		</cfoutput>
	</cfdocumentitem>
	<cfoutput>
		#variables.PDFhtml#
	<cfdocumentitem type="pagebreak"></cfdocumentitem>	
		#variables.PDFhtml2#	
	</cfoutput>
 	<cfdocumentitem  type="footer">
		<cfoutput>
			<div style="text-align:center;font-size:11px;">Page: #cfdocument.currentpagenumber#</div>
		</cfoutput>
	</cfdocumentitem>
</cfdocument>
 
