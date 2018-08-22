<!---  
S Farmer     | 05/20/2014 | 116824 - Move-In update - Allow ED to adjust BSF rate               |
|S Farmer    | 05/20/2014 | 116824 - Phase 2 Allow different move-in and rent-effective dates   |
|            |            | allow respite to adjust BSF rates                                   |
|S Farmer    | 08/20/2014 | 116824 - back-off different move-in rent-effective dates            |
|            |            | allow adjustment of rates by all regions                            |
|S Farmer    | 2015-01-12 | 116824  Final Move-in Enhancements                                  |
|S Farmer    | 2015-02-23 | changed date for payments (solomon) to be invoice end date          |
|            |            | replacing ts.dtmovein                                               |
|S Farmer    | 09-08-2015 | Make correction so appropirate residents display text 'Security Deposit' |
|            |            | instead of 'Community Fee'          
|M Shah      | 05-05-2016 | Make correction to not print WI medicaid charge 1749, 1750           |
|sfarmer     | 2017-05-09 | 'move out date' changed to 'physical move out date'                 |                                 
|Mshah		 | 2017-11-27 | 'MoveInSummary' change	                               				 |
|mstriegel   | 2018-03-05 | added single ticks around the coldfusion variable for the solomonkey so that old tenant will not be returned|
 --->
 	<cfparam name="prompt0" default="">
 	<cfparam name="COMMPYMNT2 " default="0">	
 	<cfparam name="COMMPYMNT3 " default="0">		
<!--- Mshah commented here 11/16 as two query-qresident is there
	<cfquery name="qResident" datasource="#application.datasource#">
		Select top 1  t.cfirstname  + ' ' + t.clastname Name , t.csolomonkey
		, ts.ispoints, ts.iResidencyType_ID
		,ts.dtmovein, ts.dtrenteffective, at.cdescription Apartmenttype, aptadd.captnumber
		,ts.iMonthsDeferred, ts.mBaseNrf, ts.mAdjNRF
		,restyp.cdescription restype,
		ltc.bispayer as contactpayer, 
		t.bispayer as tenantpayer, 
		ts.cSecDepCommFee,
		cont.cfirstname + ' ' + cont.clastname as 'ContactName'
		, cont.cAddressLine1 as ContactAddr1 , cont.cAddressLine2 as ContactAddr2
		, cont.cCity as ContactCity, cont.cStateCode as ContactState
		, cont.cZipCode as ContactZipcode, cont.cphonenumber1 as COntactPhone
		 from tenant t with (NOLOCK) 
		 join tenantstate ts with (NOLOCK) on t.itenant_id = ts.itenant_id
		 join aptaddress aptadd with (NOLOCK) on ts.iaptaddress_id = aptadd.iaptaddress_id
		 join apttype at with (NOLOCK) on at.iapttype_id = aptadd.iapttype_id
		join residencytype  restyp with (NOLOCK) on restyp.iResidencyType_ID  = ts.iResidencyType_ID
		left join linktenantcontact ltc with (NOLOCK) on t.itenant_id = ltc.itenant_id 
		and ltc.bIsPayer = 1 and ltc.dtrowdeleted is null
		left join contact cont with (NOLOCK) on ltc.icontact_id = cont.icontact_id
		 where t.itenant_id = #prompt0#
	</cfquery> --->	
	<!---<cfquery name="qResidentPointsAtMoveIn" datasource="#application.datasource#">
		select  top 1 ispoints from tenant t
		join p_tenantstate ts on ts.itenant_id  =t.itenant_id 
		and t.itenant_id = #prompt0#
		where ts.dtmovein is not null  
		   and left(ts.dtrowend,11) <= left(ts.dtmovein,11) 
		   
		 order by ts.dtrowend	
	</cfquery>

    <cfquery name="qryAptatMoveIn"  datasource="#application.datasource#">
		select top 1 t.cfirstname, t.clastname,  at.cdescription Apartmenttype, aptadd.captnumber 
		from tenant t
			join p_tenantstate ts on t.itenant_id = ts.itenant_id 
			join aptaddress aptadd on ts.iaptaddress_id = aptadd.iaptaddress_id
			join apttype at on at.iapttype_id = aptadd.iapttype_id
		where t.itenant_id =  #prompt0#
		and ts.iaptaddress_id is not null
		order by ts.dtrowstart	
	</cfquery>--->

<cfquery name="qryAptaddressatMoveIn"  datasource="#application.datasource#">
		select top 1 t.cfirstname, t.clastname,  apt.cdescription Apartmenttype, ad.captnumber, ts.ispoints, ts.dtrowstart
		,ts.dtMoveIn,ts.dtrenteffective, rt.cdescription,dtMoveOutProjectedDate,ts.iaptaddress_ID,ts.iproductline_ID,ts.iresidencytype_ID
		from P_tenantstate ts with (NOLOCK) 
		join tenant t with (NOLOCK) on t.itenant_ID= ts.itenant_ID and t.dtrowdeleted is null and ts.dtrowdeleted is null
		join aptaddress ad with (NOLOCK) on ad.iaptaddress_ID = ts.iaptaddress_ID and ad.dtrowdeleted is null
		join apttype apt with (NOLOCK) on apt.iAptType_ID= ad.iAptType_ID and apt.dtrowdeleted is null
		join residencytype rt with (NOLOCK) on ts.iresidencytype_ID= rt.iresidencytype_ID
		where ts.itenantstatecode_ID=2 and 
		ts.iTenant_ID= #prompt0# order by ts.dtRowStart
	</cfquery>
	<cfif qryAptaddressatMoveIn.recordcount eq 0>
	 <cfquery name="qryAptaddressatMoveIn"  datasource="#application.datasource#">
		select top 1 t.cfirstname, t.clastname,  apt.cdescription Apartmenttype, ad.captnumber,ts.ispoints, ts.dtrowstart
		,ts.dtMoveIn,ts.dtrenteffective,rt.cdescription,dtMoveOutProjectedDate,ts.iaptaddress_ID,ts.iproductline_ID,ts.iresidencytype_ID
		from tenantstate ts with (NOLOCK) 
		join tenant t with (NOLOCK) on t.itenant_ID= ts.itenant_ID and t.dtrowdeleted is null and ts.dtrowdeleted is null
		join aptaddress ad with (NOLOCK) on ad.iaptaddress_ID = ts.iaptaddress_ID and ad.dtrowdeleted is null
		join apttype apt with (NOLOCK) on apt.iAptType_ID= ad.iAptType_ID and apt.dtrowdeleted is null
		join residencytype rt with (NOLOCK) on ts.iresidencytype_ID= rt.iresidencytype_ID
		where ts.itenantstatecode_ID=2 and 
		ts.iTenant_ID= #prompt0# order by ts.dtRowStart
	</cfquery>	
	</cfif>
	<cfset moveindatetime= #qryAptaddressatMoveIn.dtrowstart#>
	<cfquery name="qryNameAtMoveIn"  datasource="#application.datasource#">
	   select  * from P_tenant with (NOLOCK) where iTenant_ID= #prompt0# and dtrowstart < '#moveindatetime#' 
		order by dtrowstart desc
	</cfquery>
	<!---query apt type on move in if apttype changes of that aptaddress--->
	<cfquery name="qryApttypeAtMoveIn"  datasource="#application.datasource#">
		select top 1 apt.cdescription from P_AptAddress ad with (NOLOCK) join apttype apt with (NOLOCK)  on ad.iAptType_ID= apt.iAptType_ID 
		where ad.iaptaddress_ID= #qryAptaddressatMoveIn.iaptaddress_ID#
		and ad.dtRowEnd > '#moveindatetime#'
		order by ad.dtRowStart 
	</cfquery>
	<!---find payer is tenant is not payer--->
	<cfif #qryNameAtMoveIn.bispayer# eq ''>
			<!---query payer if not changed contact record------>
		<cfquery name="qryPayerAtMoveIn"  datasource="#application.datasource#">	
			select cont.cfirstname + ' ' + cont.clastname as 'ContactName'
				, cont.cAddressLine1 as ContactAddr1
				 , cont.cAddressLine2 as ContactAddr2
				, cont.cCity as ContactCity, cont.cStateCode as ContactState
				, cont.cZipCode as ContactZipcode
				, cont.cphonenumber1 as COntactPhone from LinkTenantContact ltc with (NOLOCK) 
			join contact cont with (NOLOCK)  on cont.iContact_ID= ltc.iContact_ID
			where ltc.iTenant_ID= #prompt0#
			and cont.dtRowStart < '#moveindatetime#'
			and ltc.bIsPayer = 1
		</cfquery>
		<cfif qryPayerAtMoveIn.recordcount eq 0> <!---if contact record is changed then dtrowstart will change, go find P_--->
			<cfquery name="qryPayerAtMoveIn"  datasource="#application.datasource#">	
				select top 1 cont.cfirstname + ' ' + cont.clastname as 'ContactName'
				, cont.cAddressLine1 as ContactAddr1
				 , cont.cAddressLine2 as ContactAddr2
				, cont.cCity as ContactCity, cont.cStateCode as ContactState
				, cont.cZipCode as ContactZipcode
				, cont.cphonenumber1 as COntactPhone
				from P_LinkTenantContact ltc with (NOLOCK) 
				join P_Contact cont with (NOLOCK) on cont.iContact_ID= ltc.iContact_ID
				where ltc.iTenant_ID= #prompt0#
				and cont.dtRowStart < '#moveindatetime#'
				and ltc.bIsPayer = 1
				order by cont.dtRowStart
			</cfquery>
		</cfif>	
	</cfif>
<cfsavecontent variable="PDFhtml">
<cfheader name="Content-Disposition" value="attachment;filename=MoveInReport-#qryNameAtMoveIn.CfirstName# #qryNameAtMoveIn.ClastName#.pdf">
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<!--- <html xmlns="http://www.w3.org/1999/xhtml"> --->
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Resident Move In Summary</title>
		 <style>
			table{ 
				font-size:0em;
				border-collapse: collapse;
			}
		</style>
	</head>

			<cfquery name="HouseDetail" datasource="#application.datasource#">
				select cname HouseName, caddressline1
				,caddressline2, ccity
				,cstatecode, czipcode, cphonenumber1 
				from house where ihouse_id = #session.qselectedhouse.ihouse_id#
			</cfquery>			  
			
			<cfquery name="qResident" datasource="#application.datasource#">
				Select top 1 t.cfirstname  + ' ' + t.clastname Name , t.csolomonkey
				, ts.ispoints
				, ts.iResidencyType_ID
				,ts.iproductline_ID <!---Mshah added here for MC respite Move in summary--->
				, ts.dtMoveOutProjectedDate
				,ts.iMonthsDeferred, ts.mBaseNrf, ts.mAdjNRF
				,ts.dtmovein, ts.dtrenteffective
				, at.cdescription Apartmenttype
				, aptadd.captnumber
				,restyp.cdescription restype,
				ltc.bispayer as contactpayer, 
				t.bispayer as tenantpayer,
				ts.cSecDepCommFee,
				cont.cfirstname + ' ' + cont.clastname as 'ContactName'
				, cont.cAddressLine1 as ContactAddr1
				 , cont.cAddressLine2 as ContactAddr2
				, cont.cCity as ContactCity, cont.cStateCode as ContactState
				, cont.cZipCode as ContactZipcode
				, cont.cphonenumber1 as COntactPhone
				 from tenant t with (NOLOCK)
				 join tenantstate ts with (NOLOCK) on t.itenant_id = ts.itenant_id
				 join aptaddress aptadd with (NOLOCK) on ts.iaptaddress_id = aptadd.iaptaddress_id
				 join apttype at with (NOLOCK) on at.iapttype_id = aptadd.iapttype_id
				join residencytype  restyp with (NOLOCK) on restyp.iResidencyType_ID  = ts.iResidencyType_ID
				left join linktenantcontact ltc with (NOLOCK) on t.itenant_id = ltc.itenant_id 
				and ltc.bIsPayer = 1 and ltc.dtrowdeleted is null
				left join contact cont on ltc.icontact_id = cont.icontact_id
				 where t.itenant_id = #prompt0#
			</cfquery> 		
		<cfif qResident.dtmovein gte '2015-01-13'>
			<cfquery name="MoveInInvoice"  datasource="#application.datasource#">
				select im.*, inv.* , inv.cappliestoacctperiod as acctperiod
				,case when ichargetype_id in (89, 7, 91, 31,1661,1682, 1748 ) then '1MonthlyFee'
						when ichargetype_id not in (69,7,89,91,83, 53, 1741,8,1682, 1748,1763,1764) then '2AncillaryFee' 
						when ichargetype_id   in ( 83,69, 53, 1741)  then  '3OneTimeFee' else '4MiscFee' end as 'Feetype'
				<!--- 		when ichargetype_id = 69 then '3OneTimeFee'
						else '4MiscFee' end as 'Feetype' --->
				, inv.cRowStartUser_ID as 'respiteperiod', im.dtinvoiceend as dtInvoiceEnd
				from invoicemaster im with (NOLOCK)
				join invoicedetail inv with (NOLOCK) on im.iinvoicemaster_id = inv.iinvoicemaster_id
				<!--- mstriegel 03/05/2018 --->
				where im.csolomonkey = '#qResident.csolomonkey#'
				<!--- end: mstriegel --->
					and im.dtrowdeleted is null
					and inv.dtrowdeleted is null
					and im.bmoveininvoice = 1
					and inv.iquantity > 0
					and ichargetype_id not in (8,1749,1750) 
					order by Feetype, inv.cappliestoacctperiod,	ichargetype_id	 
			</cfquery>	
			<cfquery name="MoveInInvoiceTotal"  datasource="#application.datasource#"> 
				select sum(inv.mamount * inv.iquantity) as Invoicetotal
				from invoicemaster im with (NOLOCK)
				join invoicedetail inv with (NOLOCK) on im.iinvoicemaster_id = inv.iinvoicemaster_id
				<!--- mstriegel 03/05/2018 --->
				where im.csolomonkey = '#qResident.csolomonkey#'
				<!--- end mstriegel --->
					and im.dtrowdeleted is null
					and inv.dtrowdeleted is null
					and im.bmoveininvoice = 1
					and inv.iquantity > 0
					and inv.ichargetype_id not in (8, 69,1749,1750)
				  
			</cfquery>	
		<cfelse>
			<cfquery name="MoveInInvoice"  datasource="#application.datasource#">
				select im.*, inv.* , inv.cappliestoacctperiod as acctperiod
				,case when ichargetype_id in (89, 7, 91,1682, 1748) then '1MonthlyFee'
						when ichargetype_id not in (69,7,89,91, 53,83, 1741,1682, 1748) then '2AncillaryFee'
				 		when ichargetype_id in (69,83,53) then '3OneTimeFee'
						else '4MiscFee' end as 'Feetype'  
				, inv.cRowStartUser_ID as 'respiteperiod', im.dtinvoiceend as dtInvoiceEnd
				from invoicemaster im with (NOLOCK)
				join invoicedetail inv with (NOLOCK) on im.iinvoicemaster_id = inv.iinvoicemaster_id
				<!--- mstriegel 03/05/2018 --->
				where im.csolomonkey = '#qResident.csolomonkey#'
				<!--- end mstriegel --->
					and im.dtrowdeleted is null
					and inv.dtrowdeleted is null
					and im.bmoveininvoice = 1
					and inv.iquantity > 0
					order by Feetype, inv.cappliestoacctperiod,	ichargetype_id	 
			</cfquery>	
			<cfquery name="MoveInInvoiceTotal"  datasource="#application.datasource#"> 
				select sum(inv.mamount * inv.iquantity) as Invoicetotal
				from invoicemaster im with (NOLOCK)
				join invoicedetail inv with (NOLOCK) on im.iinvoicemaster_id = inv.iinvoicemaster_id
				<!--- mstriegel 03/05/2018 --->
				where im.csolomonkey = '#qResident.csolomonkey#'
				<!--- end mstriegel --->
					and im.dtrowdeleted is null
					and inv.dtrowdeleted is null
					and im.bmoveininvoice = 1
					and inv.iquantity > 0
					 and inv.ichargetype_id <> 1741
				  
			</cfquery>			
		</cfif>			

	
			<cfquery name="qryRecurring" datasource="#application.datasource#">
			select rc.dteffectiveend 
			from recurringcharge rc  with (NOLOCK)
			join charges chg with (NOLOCK) on rc.icharge_id = chg.icharge_id
			where itenant_id = #prompt0#  and chg.ichargetype_id = 1741 and rc.dtrowdeleted is null
			</cfquery>
			
			<cfquery name="Solomonbalance" datasource="#application.datasource#">
				SELECT   IsNull( CASE WHEN doctype IN ('PA') 
							THEN - ard.origdocamt 
							ELSE ard.origdocamt
							 END ,0) as payments 
							 , ard.refnbr as chknbr
							  , ard.docdate  as paymentdt
							  ,ard.user7 as chkdate
				FROM        #SolomonDBServer#.Houses_APP.dbo.ARDoc ard with (NOLOCK)
				join tenant t with (NOLOCK) on t.csolomonkey = ard.custid
				join tenantstate ts with (NOLOCK) on t.itenant_id = ts.itenant_id
				WHERE		custid = '#qResident.csolomonkey#'	
				and 		ard.user7 <=   '#MoveInInvoice.dtInvoiceEnd#' and doctype = 'PA' 
				order by docdate
			</cfquery>
			
		<cfif qResident.recordcount is 0>
			<cfquery name="qResident" datasource="#application.datasource#">
				Select t.clastname, t.cfirstname , t.csolomonkey from tenant t with (NOLOCK)
				where t.itenant_id = #prompt0#
			</cfquery> 

			<body>
			
				<table width="95%"  cellspacing="2" cellpadding="2" > 
					<tr> 
						<td style="text-align:center">New Resident Fees</td> 
					</tr> 	
					<tr> 
						<td style="text-align:center">&nbsp;</td> 
					</tr> 								
					<tr>
						<td><cfoutput>No information found for
						 #qResident.cfirstname# #qResident.clastname#
						, Resident ID #t.csolomonkey# please review your selection</cfoutput></td>
					</tr>
				</table>
			</body>
		<cfelse> 
			<cfset MSFsubtotal  = 0>
			<cfset ancillarysubtotal  = 0>
			<cfset onetimesubtotal  = 0>		
			<cfset 	CommFeePaymnt = 0>
			<cfset sumSolmnpymnt = 0>
			<cfset CFinstallment = 0>
			<body >
			 	<cfoutput query="HouseDetail">
 					<table width="100%"  cellpadding="0" cellspacing="0">
						<tr> 
							
							<td   style="text-align:left; font-weight:bold; 
							font:'Times New Roman', Times, serif; font-size:10px;">
							#HouseName#
							</td> 
							
						</tr>
 						<tr> 
							
							<td   style="text-align:left; font-weight:bold;
							 font:'Times New Roman', Times, serif; font-size:10px;">
							#caddressline1#
							</td> 
							
						</tr>	
						<cfif caddressline2 is not ''>	
 						<tr> 
							
							<td   style="text-align:left;  font-weight:bold;
							 font:'Times New Roman', Times, serif; font-size:10px;">
							#caddressline2#
							</td> 
							
						</tr>		
						</cfif>	
 						<tr> 
							
							<td   style="text-align:left;  font-weight:bold;
							 font:'Times New Roman', Times, serif; font-size:10px;">
							#ccity#, #cstatecode# #czipcode#
							</td> 
							
						</tr>	
 						<tr> 
							
							<td   style="text-align:left;  font-weight:bold;
							 font:'Times New Roman', Times, serif; font-size:10px;">
							(#left(cphonenumber1,3)#) #mid(cphonenumber1,4,3)#-#right(cphonenumber1,4)# 
							</td> 
							
						</tr>	
					</table>
		 		</cfoutput>
 				<table width="100%">		
					<table width="95%"  cellspacing="2" cellpadding="2" > 
						<cfoutput query="HouseDetail"   >
							<tr> 
								
								<td style="text-align:left; font-weight:bold;
								 font-size:18px; font-family:"Times New Roman", Times, serif">
								MOVE-IN SUMMARY OF CHARGES 
								</td> 
								
							</tr>			

																								
						</cfoutput>
					</table>			
					<table width="95%"  cellspacing="2" cellpadding="2"  > 
						<cfoutput query="qResident">
							<tr> 
								<td colspan="5" style="text-align:left; font-size:13px; ">Below is a summary of agreed upon fees for your apartment, care and ancillary services. Your Payor will be responsible for providing full payment at the time you become financially responsible for your apartment on #dateformat(qryAptaddressatMoveIn.dtrenteffective, 'mm/dd/yyyy')#. </td> 
								
							</tr> 
							<tr> 
								
									<td colspan="5" style="text-align:center; font-size:14px; ">&nbsp;
									
									</td> 
								
							</tr>
							<tr> 
								
									<td   style="text-align:left;  font-weight:bold">Resident ID:</td> 							
									<td   style="text-align:left">#csolomonkey#</td> 
									<td  >&nbsp;</td> 							
									<td   style="text-align:left;  font-weight:bold">Apartment Type:</td> 
									<td   style="text-align:left">				 
                                    <cfif #qryApttypeAtMoveIn.cdescription# is not ''>#qryApttypeAtMoveIn.cdescription#
									<cfelse> #qryAptaddressatMoveIn.Apartmenttype#</cfif></td>
							</tr> 
							<tr> 
								<td   style="text-align:left; font-weight:bold">Resident Name:</td> 							
								<td   style="text-align:left;" >#qryNameAtMoveIn.cfirstname# #qryNameAtMoveIn.clastname#</td> 
								<td  >&nbsp;</td> 							
								<td   style="text-align:left; font-weight:bold">Apartment Number:</td> 
								<td   style="text-align:left">
								<cfif qryAptaddressatMoveIn.captnumber is not ''>#qryAptaddressatMoveIn.captnumber#
								<cfelse>#captnumber#</cfif></td> 
                            </tr> 	
							<tr> 
								<td   style="text-align:left; font-weight:bold">Financial Possession Date:</td> 							
								<td   style="text-align:left">#dateformat(qryAptaddressatMoveIn.dtrenteffective, "mm/dd/yyyy")#</td>  
								<td  >&nbsp;</td> 							
								<td   style="text-align:left; font-weight:bold">Service Points:</td> 
								<td   style="text-align:left">
								<!---<cfif qResidentPointsAtMoveIn.recordcount is 0>
									#ispoints#
								<cfelse>
									<cfif #qResidentPointsAtMoveIn.ispoints# is ''>
										0
									<cfelse>
										#qResidentPointsAtMoveIn.ispoints#
									</cfif>
								</cfif>--->
								#qryAptaddressatMoveIn.ispoints#
								</td>						
								
							</tr> 
							<tr> 
								
									<td   style="text-align:left; font-weight:bold">
									Physical Move-In Date:
									</td> 							
									<td   style="text-align:left">
									#dateformat(qryAptaddressatMoveIn.dtmovein, "mm/dd/yyyy")#
									</td>
									<td  >&nbsp;</td> 							
									<td   style="text-align:left; font-weight:bold">
									Residency Type:
									</td> 
									<td   style="text-align:left">
									#qryAptaddressatMoveIn.cdescription#
									</td> 	
								
							</tr>  
			
							<cfif iResidencyType_ID is 3>
							<tr> 
								
									<td   style="text-align:left; font-weight:bold">
									Respite Physical Move Out Date:
									</td> 							
									<td   style="text-align:left">
									#dateformat(qryAptaddressatMoveIn.dtMoveOutProjectedDate, "mm/dd/yyyy")#
									</td> 
									<td  >&nbsp;</td> 							
									<td   style="text-align:left">&nbsp;</td> 
									<td   style="text-align:left">&nbsp;</td> 							
								
							</tr>		
							</cfif>		
							<tr>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td> 
								<td   style="text-align:left; font-weight:bold">Move-In Invoice Number: </td>
								<td   style="text-align:left">#MoveInInvoice.iInvoiceNumber#</td><!--- #MoveInInvoice.iinvoiceMaster_id# --->
							</tr>						
						</cfoutput>	
						</table>
					
					<table width="95%"  cellspacing="2" cellpadding="2"  >
 						<tr> 
							
							<td colspan="6" style="text-align:left; font-size:20px;
							 font-weight:bold ">&nbsp;
							 
							 </td> 
							
						</tr>						
 					<cfoutput query="MoveInInvoice" group="Feetype" >
						<cfif Feetype is "1MonthlyFee">
						<TR>
						<td colspan="6">
						<hr style="height:3px;border-width:0;color:black;background-color:black" />
						</td>
						</TR>
							<tr>
								
									<!--- <td style="text-align:center; font-weight:200; font:berkeleystd-book,BerkeleyStd-Book">
									DESCRIPTION</td> --->
									<td style="text-align:center; font-size:12px ;
									font-weight:200; font-family:">
									DESCRIPTION</td>
									<td style="text-align:center; font-size:12px ;
									font-weight:200;">START DATE</td>
									<td style="text-align:center; font-size:12px; 
									font-weight:200;">END DATE</td>
									<Td style="text-align:center;font-size:12px; 
									 font-weight:200;">DAYS / UNITS</Td>
									<td style="text-align:center;font-size:12px; 
									 font-weight:200;">RATE</td>
									<td style="text-align:center;font-size:12px ;
									 font-weight:200;">TOTAL</td>
								
							</tr>						
						<TR>
						<td colspan="6"><hr style="height:1px;border-width:0;
						color:black;background-color:black" /></td>
						</TR>
							<tr>
								
									<td style=" text-align:left;  font-size:14px; font-weight:bold">
										Monthly Service Fees
									</td>
									<td style="text-align:center; font-weight:bold">&nbsp;
									</td>
									<td style="text-align:center; font-weight:bold">&nbsp;
									</td>
									<Td style="text-align:center; font-weight:bold">&nbsp;
									</Td>
									<td style="text-align:center; font-weight:bold">&nbsp;
									</td>
									<td style="text-align:center; font-weight:bold">&nbsp;
									</td>
								
							</tr>
						<cfoutput >
							
							<tr>
								<td  style=" font-size:12px;">#cdescription#</td>
								
								
								<cfif ichargetype_id is 91>
								<td  style="text-align:center; font-size:12px;">
										<cfif datepart("m",qryAptaddressatMoveIn.dtMoveIn)is right(acctperiod,2)>
											#dateformat(qryAptaddressatMoveIn.dtMoveIn, 'mm/dd/yyyy')#
										<cfelse>
											<cfset monthstart =  left(acctperiod,4) & '-' &
											 right(acctperiod,2) & '-' & '01'>
											#dateformat(monthstart, 'mm/dd/yyyy')#
										</cfif>
								</td>
								<cfelse>
									<td  style="text-align:center; font-size:12px;">
										<cfif datepart("m",qryAptaddressatMoveIn.dtRentEffective)is 
										right(acctperiod,2)>
											#dateformat(qryAptaddressatMoveIn.dtRentEffective, 'mm/dd/yyyy')#
										<cfelse>
											<cfset monthstart =  left(acctperiod,4) & '-' &
											 right(acctperiod,2) & '-' & '01'>
											#dateformat(monthstart, 'mm/dd/yyyy')#
										</cfif>
									</td>
								</cfif>								
								<!--- #DaysInMonth(CreateDate(left(acctperiod,4), right(acctperiod,2), 1))# --->
 
								<!--- <cfset eomdate = daysinmonth(dtInvoiceStart)> --->
								<!--- <cfif iquantity lt eomdate> --->
								<!--- <cfif left(dtInvoiceend, 10) is left(dtInvoiceStart,10)> --->
								
									
									<td  style="text-align:center; font-size:12px;"  >
									<cfif (FIndNoCase('ending period', #respiteperiod#))>
									<!---<cfoutput>test going her #iquantity# #MoveInInvoice.idaysbilled#</cfoutput> Mshah Added here for MC respite--->
									   <cfif qryAptaddressatMoveIn.iproductline_ID eq 2 and qryAptaddressatMoveIn.iResidencytype_ID eq 3>
									    #numberformat(right(acctperiod,2),00)#/#MoveInInvoice.idaysbilled#/#left(acctperiod,4)#	
									   <cfelse>
									   	#numberformat(right(acctperiod,2),00)#/#iquantity#/#left(acctperiod,4)#
									   </cfif>							
									<cfelse>
										#numberformat(right(acctperiod,2),00)#/#DaysInMonth(CreateDate(left(acctperiod,4), 
									right(acctperiod,2), 1))#/#left(acctperiod,4)#
									</cfif>
  									</td>
									
<!--- 								<cfelse>
									
									<td  style="text-align:center"  >#dateformat(dtInvoiceend, 'mm/dd/yyyy')#</td>
									
								</cfif> --->
								
								<td  style="text-align:center; font-size:12px;">
							<cfif qResident.iproductline_ID eq 2 and qResident.iResidencytype_ID eq 3>	
								#MoveInInvoice.idaysbilled#
							<cfelse>	
								#iquantity#
							</cfif></td>
								
								
								<td style="text-align:right; font-size:12px;">
								#dollarformat(mamount)#</td>
								
								
								<td   style="text-align:right; font-size:12px;" >
								#dollarformat(mamount *iquantity )#</td>
											
							</tr>
							<cfset MSFsubtotal = MSFsubtotal + (mamount *iquantity )>
						</cfoutput>
							<tr>
								<td colspan="4">&nbsp;</td>
								<td style="font-style:italic; font-size:12px; text-align:center;">
								Subtotal</td>
								<td style="text-decoration:overline;  font-size:12px;
								text-align:right;">#dollarformat(MSFsubtotal)#</td> 
							</tr>						
						<cfelseif   Feetype is "2AncillaryFee">
							<tr>
								<td style="text-align:left;  font-size:14px;font-weight:bold">
									Ancillary Fees
								</td>
								<td style="text-align:center; font-weight:bold">&nbsp;
								</td>
								<td style="text-align:center; font-weight:bold">&nbsp;
								</td>
								<Td style="text-align:center; font-weight:bold">&nbsp;
								</Td>
								<td style="text-align:center; font-weight:bold">&nbsp;
								</td>
								<td style="text-align:center; font-weight:bold">&nbsp;
								</td>
								
							</tr>
						<cfoutput>			
						<cfif 	right(acctperiod, 2) is 1>
							<cfset descmonth = 'January'>
						<cfelseif 	right(acctperiod, 2) is 2>
							<cfset descmonth = 'February'>
						<cfelseif 	right(acctperiod, 2) is 3>
							<cfset descmonth = 'March'>
						<cfelseif 	right(acctperiod, 2) is 4>
							<cfset descmonth = 'April'>
						<cfelseif 	right(acctperiod, 2) is 5>
							<cfset descmonth = 'May'>
						<cfelseif 	right(acctperiod, 2) is 6>
							<cfset descmonth = 'June'>
						<cfelseif 	right(acctperiod, 2) is 7>
							<cfset descmonth = 'July'>
						<cfelseif 	right(acctperiod, 2) is 8>
							<cfset descmonth = 'August'>
						<cfelseif 	right(acctperiod, 2) is 9>
							<cfset descmonth = 'September'>
						<cfelseif 	right(acctperiod, 2) is 10>
							<cfset descmonth = 'October'>
						<cfelseif 	right(acctperiod, 2) is 11>
							<cfset descmonth = 'November'>
						<cfelseif 	right(acctperiod, 2) is 12>
							<cfset descmonth = 'December'>
						</cfif>	
							<tr>
								<td colspan="2" style=" font-size:12px;" >
								#cdescription# - #descmonth#</td>
								<td >&nbsp;</td>
								
							<!--- 	
									<td   >									#numberformat(right(acctperiod,2),00)#/#DaysInMonth(CreateDate(left(acctperiod,4), right(acctperiod,2), 1))#/#left(acctperiod,4)#</td>
								  --->
								
									<td  style="text-align:center; font-size:12px;">
									#iquantity#</td>
								
								
									<td style="text-align:right; font-size:12px;">
									#dollarformat(mamount)#</td>
								
								
									<td   style="text-align:right; font-size:12px;" >
									#dollarformat(mamount *iquantity )#</td>
											
							</tr>
							<cfset ancillarysubtotal = ancillarysubtotal + (mamount *iquantity )>
						</cfoutput> 			
							<tr>
								<td colspan="4">&nbsp;</td>
								<td style="font-style:italic; text-align:center; 
								font-size:12px;">Subtotal</td>
								<td style="text-decoration:overline;text-align:right;
								 font-size:12px; " >#dollarformat(ancillarysubtotal)#</td> 
							</tr>		 
						<cfelseif   Feetype is "3OneTimeFee">
						<!--- <cfset onetimesubtotal =  (mamount *iquantity ) + onetimesubtotal> --->
 						<tr> 
							
							<td colspan="6" style="text-align:left; font-size:20px;
							 font-weight:bold; font-size:12px; ">&nbsp;</td> 
							
						</tr>
							<tr>
								
								<td style="text-align:left;  font-size:14px;
								font-weight:bold; font-size:12px;">One Time Fee</td>
								<td style="text-align:center;font-size:smaller">&nbsp;</td>
								<td style="text-align:center;font-size:smaller">&nbsp;</td>
								<Td style="text-align:center;font-size:smaller">&nbsp;</Td>
								<td style="text-align:center;font-size:smaller">&nbsp;</td>
								<td style="text-align:center;font-size:smaller">&nbsp;</td>
								
							</tr>		
							
							<cfoutput>	
						<!--- <cfif ichargetype_ID neq 69> --->	
							 <cfif (
							 <!--- (cdescription is 'Community Fee') or --->
								 (cdescription is 'Monthly Deferral Charge')
								or (cdescription is 'Community Fee Installment Charge')
								or (cdescription is 'Security Deposit')
								or (cdescription is 'Security Deposits')
								or (cdescription is 'Oregon Bond Security Deposit')
								or (cdescription is 'Security')
								or (cdescription is 'Security Dep')
								or (cdescription is 'Community Fee- Non Refundable')
								or (cdescription is 'SecurityDeposit(2210)')
								and (ichargetype_ID neq 69))
								or ((cdescription is 'New Resident Fee') and (ichargetype_ID is 69))>  
								
									<!--- 	<cfif 	mamount is 0>
									<tr>
										<td   style=" font-size:12px;" >
											<cfif qResident.cSecDepCommFee is 'SC'>
											Security Deposit
											<cfelse>
											Community Fee (non-refundable)
											</cfif>
										</td>
										<td  style="text-align:center;font-size:12px;"  >
											#numberformat(right(acctperiod,2),00)#/01/#left(acctperiod,4)#
										</td>
										<td   style="text-align:center;font-size:12px;"  >
												#numberformat(right(acctperiod,2),00)#/#DaysInMonth(CreateDate(left(acctperiod,4),
												 right(acctperiod,2), 1))#/#left(acctperiod,4)#
										</td>
										<td style="text-align:center;font-size:12px;" >
											#iquantity#
										</td>
										<td style="text-align:right;font-size:12px;">
											#dollarformat(mamount)#
										</td>
										<td   style="text-align:right;font-size:12px;" >
										#dollarformat(mamount *iquantity )#
										</td>
									</tr>	
								<cfelse> --->
								<cfif 	mamount gt 0>
									<tr>
										<td colspan="6" style=" font-size:12px;" >
											<cfif qResident.cSecDepCommFee is 'SC'>
											Security Deposit
											<cfelseif ((cdescription is 'Security Deposit')
								or (cdescription is 'Security Deposits')
								or (cdescription is 'Oregon Bond Security Deposit')
								or (cdescription is 'Security')
								or (cdescription is 'Security Dep')
								or (cdescription is 'SecurityDeposit(2210)'))>
									Security Deposit
											<cfelse>
											Community Fee (non-refundable)
											</cfif>
										</td>
									</tr>
									<cfif qResident.dtmovein lt '2015-01-13'>
  
										  <cfset CFinstallment = mamount>
										<tr>
											<td  colspan="1"  style=" font-size:12px;" >
												Installment (Month 1)</td>
											<td  style="text-align:center;font-size:12px;"  >
												#numberformat(right(acctperiod,2),00)#/01/#left(acctperiod,4)#
											</td>
											<td   style="text-align:center;font-size:12px;"  >										
											#numberformat(right(acctperiod,2),00)#/#DaysInMonth(CreateDate(left(acctperiod,4), 
												right(acctperiod,2), 1))#/#left(acctperiod,4)#
											</td>
											<td style="text-align:center;font-size:12px;" >#iquantity#</td>
											<td style="text-align:right;font-size:12px;">#dollarformat(mamount)#</td>
											<td   style="text-align:right;font-size:12px;" >#dollarformat(mamount *iquantity )#</td>
										</tr>									
									  <cfelseif  (qResident.iMonthsDeferred is   0) or (qResident.iMonthsDeferred is '') or (qResident.iMonthsDeferred is   1)>  
										  <cfset CFinstallment = mamount>
										<tr>
											<td  colspan="1"  style=" font-size:12px;" >
											Installment (Month 1)</td>
											<td  style="text-align:center;font-size:12px;"  >
												#numberformat(right(acctperiod,2),00)#/01/#left(acctperiod,4)#
											</td>
											<td   style="text-align:center;font-size:12px;"  >										#numberformat(right(acctperiod,2),00)#/#DaysInMonth(CreateDate(left(acctperiod,4), right(acctperiod,2), 1))#/#left(acctperiod,4)#
											</td>
											<td style="text-align:center;font-size:12px;" >#iquantity#</td>
											<td style="text-align:right;font-size:12px;">#dollarformat(mamount)#</td>
											<td   style="text-align:right;font-size:12px;" >#dollarformat(mamount *iquantity )#</td>
										</tr>							
									<cfelseif qResident.iMonthsDeferred is 2>  
										 <!--- <cfset CFinstallment = mamount/2> --->
									    	<cfset CFinstallment = mamount>
											<cfset lastpaymentdatestart = 
											dateformat(qryRecurring.dteffectiveend, 'mm/dd/yyyy')>
											 
											<cfset lastpaymentdateend  = 
											ToString(month(qryRecurring.dteffectiveend)) & '/' & 
											ToString(daysinmonth(qryRecurring.dteffectiveend)) & '/'
											 & ToString(year(qryRecurring.dteffectiveend))>
										<tr>	
										<td colspan="1" style="font-size:12px;" >Installment (Month 1)</td>
										<cfset CommPymnt2 = (mamount)>
											<td  style="text-align:center;font-size:12px;" >
											#numberformat(right(acctperiod,2),00)#/01/#left(acctperiod,4)#
											</td>
											<td   style="font-size:12px;text-align:center"  >
		#numberformat(right(acctperiod,2),00)#/#DaysInMonth(CreateDate(left(acctperiod,4), right(acctperiod,2), 1))#/#left(acctperiod,4)#
											</td>
										<td style="text-align:center;font-size:12px;" >#iquantity#</td>
										<td style="text-align:right;font-size:12px;">
										#dollarformat(mamount)#
										</td>
										<td   style="text-align:right;font-size:12px;" >
										#dollarformat(mamount)#</td>
									</tr>
									<tr>	
										<td colspan="1" style="font-size:12px;" >Installment (Month 2)</td>
										<cfset CommFeePaymnt = CommFeePaymnt + (mamount)>
											<td  style="text-align:center;font-size:12px;" >
											#lastpaymentdatestart#
																				</td>
											<td  style="font-size:12px;text-align:center"  >	
											#lastpaymentdateend#	
											</td>
											<td style="text-align:center;font-size:12px;" >
											#iquantity#
											</td>
											<td style="text-align:right;font-size:12px;">
											#dollarformat(mamount)#
											</td>
											<td   style="text-align:right;font-size:12px;" >
											#dollarformat(mamount)#
											</td>
										</tr>
									<cfelseif qResident.iMonthsDeferred is 3> 	
											<cfset CFinstallment = mamount>
												<cfset midpaymentdatestart = 
													dateformat(dateadd('m',-1,qryRecurring.dteffectiveend), 'mm/dd/yyyy')>
												<cfset midpaymentdateend = 
													dateadd('m',-1,qryRecurring.dteffectiveend)>
												<cfset midpaymentdateend = month(midpaymentdateend) & '/' & 
													daysinmonth(midpaymentdateend) & '/' & year(midpaymentdateend)>					 			 
												<cfset lastpaymentdatestart = 
													dateformat(qryRecurring.dteffectiveend, 'mm/dd/yyyy')>
												<cfset lastpaymentdateend = 
													month(qryRecurring.dteffectiveend) & '/' & 
													daysinmonth(qryRecurring.dteffectiveend) & '/' & 
													year(qryRecurring.dteffectiveend)>
																		   
										<tr>	
											<td colspan="1"  style="font-size:12px;">Installment (Month 1 Included with Move-in Charges)</td>
												<td  style="text-align:center;font-size:12px;"  >
												#numberformat(right(acctperiod,2),00)#/01/#left(acctperiod,4)#
												</td>
												<td  style="font-size:12px;text-align:center"   >
				#numberformat(right(acctperiod,2),00)#/#DaysInMonth(CreateDate(left(acctperiod,4), right(acctperiod,2), 1))#/#left(acctperiod,4)#
												</td>
												<td style="text-align:center;font-size:12px;" >#iquantity#</td>
												<cfset CommPymnt1 = (Round((mamount) * 100) / 100)>
												<td style="text-align:right;font-size:12px;">
													#dollarformat((Round((mamount) * 100)) / 100)#
												</td> 
												<td   style="text-align:right; font-size:12px;" >
												#dollarformat((Round((mamount) * 100)) / 100)#
												</td>
											</tr>
										<tr>	
											<td  colspan="1" style="font-size:12px;">Installment (Month 2)</td>
											
											<cfset CommFeePaymnt = CommFeePaymnt + 
												 (Round((mamount/3) * 100) / 100) >
												<cfset CommPymnt2 = (Round((mamount) * 100) / 100)>
			
												<td  style="text-align:center;font-size:12px;" >
												#dateformat(midpaymentdatestart, 'mm/dd/yyyy')#
												</td>
																			
											
												<td  style="font-size:12px;text-align:center"  >
													#dateformat(midpaymentdateend, 'mm/dd/yyyy')#								
												</td>
											 
											
											<td style="text-align:center;font-size:12px;" >
											#iquantity#
											</td>
											
											
											<td style="text-align:right;font-size:12px;">
											 #dollarformat(mamount)#
											</td>
											
			
											
											<td   style="text-align:right;font-size:12px;" >
											#dollarformat(mamount)#
											</td>
														
										</tr>
										<tr>	
											<td  colspan="1" style="font-size:12px;">Installment (Month 3)</td>
											
											<cfset CommFeePaymnt = CommFeePaymnt + (mamount)>
											<cfset CommFeePymntRnd = ((Round(CommFeePaymnt * 100)) / 100)>	
											<cfif qResident.mAdjNrf gt 0>
												<cfset CommPymnt3 = qResident.mAdjNrf - CommPymnt1 - CommPymnt2>
											<cfelse>
												<cfset CommPymnt3 = qResident.mBaseNrf - CommPymnt1 - CommPymnt2>
											</cfif>			
															
												<td   style="text-align:center;font-size:12px;"  >
												#dateformat(lastpaymentdatestart, 'mm/dd/yyyy')#
												<!--- #numberformat(right(acctperiod,2),00)#/01/#left(acctperiod,4)# --->
												</td>
																			
											
												<td style="font-size:12px; text-align:center"   >
													#dateformat(lastpaymentdateend, 'mm/dd/yyyy')#								<!--- #numberformat(right(acctperiod,2),00)#/#DaysInMonth(CreateDate(left(acctperiod,4), right(acctperiod,2), 1))#/#left(acctperiod,4)# --->
												</td>
											 
											
											<td style="text-align:center;font-size:12px;" >
											#iquantity#
											</td>
											
											
											<td style="text-align:right;font-size:12px;"> 
											#dollarformat(CommPymnt3)# <!--- mamount-CommFeePymntRnd ---> 
											</td>
											
			
											
											<td   style="text-align:right;font-size:12px;" >
											#dollarformat(CommPymnt3)# <!--- mamount-CommFeePymntRnd) --->
											</td>
														
										</tr>
									</cfif>
								</cfif>  
							</cfif>	
						</cfoutput>
						<cfelse>
							<cfset onetimesubtotal =  (mamount *iquantity ) + onetimesubtotal>
 									<cfset lastpaymentdatestart = 
									dateformat(MoveInInvoice.dtrowstart, 'mm/dd/yyyy')>
									 
									<cfset lastpaymentdateend  = 
									ToString(month(MoveInInvoice.dtrowstart)) & '/' & 
									ToString(daysinmonth(MoveInInvoice.dtrowstart)) & '/'
									 & ToString(year(MoveInInvoice.dtrowstart))>
							<cfoutput>
							<tr>
								<td style="font-size:12px;">
								#cdescription#
								</td>
								<td style="text-align:center;font-size:12px;">
								#dateformat(lastpaymentdatestart, 'mm/dd/yyyy')#
								</td>
								<td style="font-size:12px; text-align:center">
								#dateformat(lastpaymentdateend, 'mm/dd/yyyy')#
								</td>
								<td style="text-align:center;font-size:12px;">
								#iquantity#
								</td>
								<td style="text-align:right;font-size:12px;">
								#dollarformat(mamount)#
								</td>
								<td style="text-align:right;font-size:12px;">
								#dollarformat(mamount)#
								</td>
							</tr>

											<tr><td></td></tr>
<!--- 							<tr>
								<td colspan="4">&nbsp;</td>
								<td style="font-style:italic;font-size:12px; text-align:center;">
								Subtotal </td>
								<td style="text-decoration:overline;text-align:right; font-size:12px;">
								#dollarformat(onetimesubtotal)#</td> 
							</tr>	 --->			
						</cfoutput>
 						</cfif>
					
					</cfoutput> 
					<cfoutput>

							<tr><cfset invcorrection =  MoveInInvoiceTotal.Invoicetotal>
							  <!---MoveInInvoice.mInvoicetotal   - CommPymnt2 - CommPymnt3 --->
								<td colspan="3">&nbsp;</td>
								<td colspan="2" style="  font-size:12px;text-align:right">
								TOTAL DUE:
								</td>
								<td style=" font-size:12px; text-align:right; text-decoration:overline" >
									#dollarformat(invcorrection)#
						 		</td>
							</tr>
							<cfif Solomonbalance.recordcount gt 0>
								<tr>
									<td style="text-align:left;  font-size:14px;font-weight:bold">Payments</td>
									<td colspan="2" style=" font-size:12px;" >Check Nbr.</td>
									<td colspan="2" style=" font-size:12px;" >Check Date.</td>	
									<td>&nbsp;</td>							
								</tr>
								<cfloop query="Solomonbalance">
									<tr>
										<td colspan="1" style="  font-size:12px;text-align:right">&nbsp;</td>
										<td colspan="2" style=" font-size:12px; ">#Solomonbalance.chknbr#</td>
										<td colspan="2" style=" font-size:12px; ">#dateformat(Solomonbalance.paymentdt, 'mm/dd/yyyy')#</td>
										<td style=" font-size:12px; text-align:right;" > #dollarformat(Solomonbalance.payments)# 
										</td>
									</tr>
									<cfset sumSolmnpymnt = Solomonbalance.payments + sumSolmnpymnt>
								</cfloop>	
							</cfif>							
							<tr>
								<td colspan="3">&nbsp;</td>
								<td colspan="2" style="  font-size:12px;text-align:right">
								BALANCE DUE:
								</td>
								<cfif sumSolmnpymnt is ''><cfset sumSolmnpymnt = 0></cfif>
								<cfif invcorrection is ''> <cfset invcorrection = 0> </cfif>
								<td style=" font-size:12px; text-align:right; 
								 text-decoration:overline" >
								  #dollarformat(invcorrection+sumSolmnpymnt)#  
								</td>
							</tr>
					</cfoutput>		
			
				</table> 


		</cfif>

</cfsavecontent>

 <cfsavecontent variable="PDFhtml2">
				<cfoutput>
				<table width="100%">
				<tr>
					<td colspan="2">
						<hr style="height:3px;border-width:0;color:black;background-color:black" />
					</td>
				</tr>
				
				<tr>
					<td width="40%">
					<table width="100%">
						<tr>
							<td style="text-align:left; font-weight:bold; 
							font:'Times New Roman', Times, serif; font-size:10px;" 
								nowrap="nowrap">
							CONFIRMATION OF PAYOR INFORMATION: 
							</td>
						</tr>
						<cfif qryNameAtMoveIn.bispayer is 1>
							<tr>
								<td style="font:'Times New Roman', Times, serif; font-size:10px;">
								#qryNameAtMoveIn.cfirstname# #qryNameAtMoveIn.clastname#</td>
							</tr>
							<tr>
								<td style="font:'Times New Roman', Times, serif; font-size:10px;">
								#HouseDetail.caddressline1# Apt. #qResident.captnumber#</td>
							</tr>
							<cfif HouseDetail.caddressline2 is not ''>
								<tr>
									<td style="font:'Times New Roman', Times, serif; font-size:10px;">
									#HouseDetail.caddressline2#
									</td>
								</tr>
							</cfif>
							<tr>
								<td style="font:'Times New Roman', Times, serif; font-size:10px;">
								#HouseDetail.ccity#, #HouseDetail.cstatecode# #HouseDetail.czipcode#
								</td>
							</tr>
							<tr>
								<td style="font:'Times New Roman', Times, serif; font-size:10px;">
								(#left(HouseDetail.cphonenumber1,3)#)
								 #mid(HouseDetail.cphonenumber1,4,3)#-#right(HouseDetail.cphonenumber1,4)#</td>
							</tr>
						<cfelse>
							<tr>
								<td style="font:'Times New Roman', Times, serif; font-size:10px;">
								#qryPayerAtMoveIn.ContactName#</td>
							</tr>
							<tr>
								<td style="font:'Times New Roman', Times, serif; font-size:10px;">
								#qryPayerAtMoveIn.ContactAddr1#</td>
							</tr>
							<cfif qryPayerAtMoveIn.ContactAddr2 is not ''>
								<tr>
									<td style="font:'Times New Roman', Times, serif; font-size:10px;">
									#qryPayerAtMoveIn.ContactAddr2#</td>
								</tr>
							</cfif>
							<tr>
								<td style="font:'Times New Roman', Times, serif; font-size:10px;">
								#qryPayerAtMoveIn.ContactCity#, #qryPayerAtMoveIn.contactstate# #qryPayerAtMoveIn.contactzipcode#</td>
							</tr>
							<tr>
								<td style="font:'Times New Roman', Times, serif; font-size:10px;">
								(#left(qryPayerAtMoveIn.ContactPhone,3)#) #mid(qryPayerAtMoveIn.ContactPhone,4,3)#-#right(qryPayerAtMoveIn.ContactPhone,4)#</td>
							</tr>					
						</cfif>					
	 
				 
				  
				<tr><td>&nbsp;</td><tr>
				<TR><td style="text-align:left; font-size: 10px;">FOR OFFICE USE ONLY: </td></tr>
			
				<TR><td style=" text-align:left;  font-size:10px; ">
				Last Updated: #dateformat(moveindatetime, "mm/dd/yyyy")# #Timeformat(moveindatetime,  "short")#
				</td></tr>
				<TR><td style="  text-align:left; font-size: 10px;"  >
				By: #HouseDetail.HouseName#
				</td></tr>
				</cfoutput>
				</table>
			</td>
			<td>
			<table  width="100%"  style="border:thin; border-bottom:none; border-left:none; border-right:none; border-top:none"  >
				<tr style="border:none">
					<td  >&nbsp;</td>
				</tr>
				<!--- <tr><td  ><hr style="border:thin solid"  /></td></tr> --->
				
				<tr><td colspan="2"><hr style="height:1px;border-width:0;color:black;background-color:black" /></td></tr>	
				<tr  >
					<td style="font:'Times New Roman', Times, serif; font-size:10px;   width:80% ; text-align:left  ">
					LEASOR SIGNATURE </td>
					<td style="font:'Times New Roman', Times, serif; font-size:10px; text-align:right  ">  DATE</td>
				</tr> 
			
 				<tr><td colspan="12">&nbsp;</td></tr>
				<tr><td colspan="2"><hr style="height:1px;border-width:0;color:black;background-color:black" /></td></tr>				
				<tr>
				<td style="font:'Times New Roman', Times, serif; font-size:10px;  width:80% ; text-align:left ">
				CARE MANAGER SIGNATURE</td>
	
				<td style="font:'Times New Roman', Times, serif; font-size:10px; text-align:right ">DATE</td>
				</tr>  
 
 				<tr><td colspan="12">&nbsp;</td></tr>
				<tr><td colspan="2"><hr style="height:1px;border-width:0;color:black;background-color:black" /></td></tr>				
				<tr>
				<td style="font:'Times New Roman', Times, serif; font-size:10px;  width:80% ; text-align:left ">
				EXECUTIVE DIRECTOR SIGNATURE</td>
	
				<td style="font:'Times New Roman', Times, serif; font-size:10px; text-align:right ">DATE</td>
				</tr>  	 
					
			</table>
			</td>
			</tr>
			</body>
			</html>	
</cfsavecontent> 			
<cfdocument format="PDF" orientation="portrait" margintop="1" >	
	<cfdocumentitem type="header">
		<!--- <div  style="text-align:center; height:350px"> --->
	<!--- 		<div  style="text-align:center; ">
	<img src="../../images/V9_AddressOnly/AddisonPlace_Addressonly_Medium.jpg" /> --->
<!---  	<img src="../../images/V9_AddressOnly/#Replace(HouseDetail.HouseName, ' ', '')#_Addressonly_Medium.jpg"  height="333"  width="500" />
 ---> 		
 
		 <table width="100%" >
			<tr>
			<!--- 	<td  style="line-height:1px; font-size:0.0em;">height:300px --->
					<td>
					<div  style="text-align:left;">
						<!---<img src="../../images/Enlivant_logo.jpg"  height="300"  width="450"  /> ---> 
						<!--- <img src="../../images/AddisonPlace_Addressonly.jpg"/> ---> 
<!--- 					<cfif FileExists("../../images/House_images/#Replace(HouseDetail.HouseName, ' ', '')#.jpeg")>
						<H1>Image Exists</H1>
						<img src="../../images/House_images/#Replace(HouseDetail.HouseName, ' ', '')#.jpeg" />
					<cfelse>
					<br><cfoutput><H1>#Replace(HouseDetail.HouseName, ' ', '')#.jpeg</H1></cfoutput>
						<img src="../../images/House_images/AlleghenyPlace.jpeg"  /><br>
						<img src="../../images/Enlivant_logo.jpg"  height="300"  width="450"  />
					</cfif> --->
						<img src="../../images/Enlivant_logo.jpg"  height="300"  width="450"  />
						</div>
				</td>
			</tr>
				
		 		<!--- <img src="../../images/V9_AddressOnly/#Replace(HouseDetail.HouseName, ' ', '')#_Addressonly_Medium.jpg" ---> 
		 	
				    
		
			<!---  title="../../images/V9_AddressOnly/#Replace(HouseDetail.HouseName, ' ', '')#_Addressonly_Medium.jpg" 
				  alt="../../images/V9_AddressOnly/#Replace(HouseDetail.HouseName, ' ', '')#_Addressonly_Medium.jpg"/>  --->
		 
		</table>
 
	</cfdocumentitem>
	<cfoutput>
		#variables.PDFhtml#
<!---  <cfdocumentitem type="pagebreak"></cfdocumentitem>	 --->
		#variables.PDFhtml2#  	
	</cfoutput>
 	<cfdocumentitem  type="footer">
		<cfoutput>
			<div style="text-align:center;font-size:11px;">Page: #cfdocument.currentpagenumber#
		</cfoutput>
	</cfdocumentitem>
</cfdocument>
 
