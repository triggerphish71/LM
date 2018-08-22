<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 

<!--- ------------------------------------------------------------------------------------------
 sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                           |
 sfarmer     | 11/20/2012 |tickets 97882, 95010, 95009, 95468, 97570, 97710 for  misc. updates |
 sfarmer     | 08/08/2013 |project 106456 EFT Updates                                          |

-----------------------------------------------------------------------------------------------> 

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>TenantEFTUpdate</title>
</head>

	<cfparam name="nextorderpull" default="">
	<cfparam name="iChargeId" default="">		
	<cfparam name="commentDetail" default="">
	<cfparam name="chgAmount" default="">	
	<cfparam name="contactcEmail" default="">
	<cfparam name="variable.icontactID" default="">
 
<cfif (IsDefined('url.cid')  and (url.cid is not ""))>
	<cfset   variable.icontactID  = url.cid>		
<cfelseif  IsDefined('form.CONTACTID')  or (form.CONTACTID is not "") >
 	<cfset   variable.icontactID  = form.CONTACTID>	
</cfif>	

	<cfquery name="EFTinfo" datasource="#application.datasource#">
		select max(iOrderofPull) maxorder 
		from EFTAccount where cSolomonKey = '#form.tenantSolomonKey#'
				and dtRowDeleted is  null
	</cfquery>
 
<body>
<cfset todaysdate = CreateODBCDateTime(now())>
<cfset appliestoYear = datepart('YYYY', now())>
<cfset appliestoMonth = datepart('M', now())> 
<cfset appytoAcctngPeriod = #appliestoYear# & #NumberFormat(appliestoMonth, "09")#>

	<cfoutput>
		<cfif form.dtbegineftdate is ''>
			<cfset  datebegineft  = todaysdate>
			dtbegineftdate:		#datebegineft#<br/>
		<cfelse>
			<cfset  datebegineft  = #CreateODBCDateTime(form.dtbegineftdate)#>
			dtbegineftdate:		#datebegineft#<br/>					
		</cfif>	
			
 		<cftransaction>
			<cfquery name="addneweft" datasource="#application.datasource#">
			  INSERT INTO   EFTAccount   
					   (cSolomonKey
					   ,cRoutingNumber
					   ,cAccountNumber
					   ,cAccountType
							)  
				 VALUES  
					   ('#form.tenantSolomonKey#' 
					   ,'#form.croutingnumber#'
					   ,'#form.caccountnumber#'
					   ,'#trim(form.caccounttype)#'
					 )		
			</cfquery> 
 
			<cfquery name="EFTID" datasource="#application.datasource#">
				select max(iEFTAccount_ID) maxID 
				from EFTAccount where cSolomonKey = '#trim(form.tenantSolomonKey)#'
			</cfquery>

				<cfquery name="iRowStartUse" datasource="#application.datasource#">
					Update EFTAccount
					set  iRowStartUser_ID = <cfqueryparam  cfsqltype="cf_sql_integer" value="#session.UserID#">
					where iEFTAccount_ID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#EFTID.maxID#">
				</cfquery>		 
				<cfquery name="RowStart" datasource="#application.datasource#">
					Update EFTAccount
					set  dtRowStart =  #todaysdate# ,
					iRowStartUser_ID =  #session.UserID#  
					where iEFTAccount_ID  = #EFTID.maxID#
				</cfquery>
			 				
			
			<cfif trim(form.iOrderofPull) is not "">
				<cfquery name="OrderofPull" datasource="#application.datasource#">
					Update EFTAccount
					set  iOrderofPull = <cfqueryparam  cfsqltype="cf_sql_integer" value="#trim(iOrderofPull)#"> 
					where iEFTAccount_ID  = #EFTID.maxID#
				</cfquery>
			</cfif>			
			
			
			<cfif ((form.damtfirstpull is not "") or (form.dpctfirstpull is not ""))>
				<cfif form.damtfirstpull is not "">
					<cfquery name="AmtFirstPull" datasource="#application.datasource#">
						Update EFTAccount
						set  dAmtFirstPull = <cfqueryparam cfsqltype="cf_sql_money"  value="#trim(form.damtfirstpull)#">  
						where iEFTAccount_ID  = #EFTID.maxID#
					</cfquery>
 				</cfif>
				<cfif form.iDayofFirstPull is not "">
					<cfquery name="DayofFirstPull" datasource="#application.datasource#">
						Update EFTAccount
						set  iDayofFirstPull = <cfqueryparam  cfsqltype="cf_sql_integer" value="#trim(form.iDayofFirstPull)#">	 
						where iEFTAccount_ID  = #EFTID.maxID#
					</cfquery>
				<cfelse>
					<cfquery name="DayofFirstPull" datasource="#application.datasource#">
						Update EFTAccount
						set  iDayofFirstPull = 5	 
						where iEFTAccount_ID  = #EFTID.maxID#
					</cfquery>
				</cfif>
 				<cfif  form.dpctfirstpull is not "" >
					<cfquery name="PctFirstPull" datasource="#application.datasource#">
						Update EFTAccount
						set  dPctFirstPull = #form.dpctfirstpull#
						where iEFTAccount_ID  = #EFTID.maxID#
					</cfquery>
				</cfif>
			<cfelseif ((form.damtfirstpull is   "") or (form.dpctfirstpull is   ""))>
					<cfquery name="PctFirstPull" datasource="#application.datasource#">
						Update EFTAccount
						set  dPctFirstPull = 100
						where iEFTAccount_ID  = #EFTID.maxID#
					</cfquery>			
				<cfif form.iDayofFirstPull is not "">
					<cfquery name="DayofFirstPull" datasource="#application.datasource#">
						Update EFTAccount
						set  iDayofFirstPull = <cfqueryparam  cfsqltype="cf_sql_integer" value="#trim(form.iDayofFirstPull)#">	 
						where iEFTAccount_ID  = #EFTID.maxID#
					</cfquery>
				<cfelse>
					<cfquery name="DayofFirstPull" datasource="#application.datasource#">
						Update EFTAccount
						set  iDayofFirstPull = 5	 
						where iEFTAccount_ID  = #EFTID.maxID#
					</cfquery>
				</cfif>
			</cfif>			
			
			
			<cfif ((form.damtsecondpull is not "") or  (form.dPctSecondPull is not ""))> 
				<cfif (form.damtsecondpull is not "")>
					<cfquery name="AmtSecondPull" datasource="#application.datasource#">
					Update EFTAccount
					set  dAmtSecondPull = <cfqueryparam  cfsqltype="cf_sql_money" value="#form.damtsecondpull#">
					where iEFTAccount_ID  = #EFTID.maxID#
					</cfquery>
				</cfif>
				<cfif (form.dPctSecondPull is not "")>
					<cfquery name="PctSecondPull" datasource="#application.datasource#">
					Update EFTAccount
					set dPctSecondPull = #form.dPctSecondPull#
					where iEFTAccount_ID  = #EFTID.maxID#
					</cfquery>
				</CFIF>				
				<cfquery name="DayofSecondPull" datasource="#application.datasource#">
					Update EFTAccount
					set iDayofSecondPull = <cfqueryparam  cfsqltype="cf_sql_integer" value="#trim(form.iDayofSecondPull)#">
					where iEFTAccount_ID  = #EFTID.maxID#
				</cfquery>
			</cfif>	
			 		
			
			<cfif variable.icontactID is not "">
				<cfif IsDefined("contactcEmail") and contactcEmail is not "">
					<cfquery name="ContactLink" datasource="#application.datasource#">
						Update Contact
						set cemail ='#contactcEmail#'
						where iContact_id = #variable.icontactID#
 
					</cfquery>			
				<cfquery name="ContactLink" datasource="#application.datasource#">
					Update LinkTenantContact
					set bIsEFT = 1
					where iContact_id = <cfqueryparam  cfsqltype="cf_sql_char" value="#variable.icontactID#">
					and iTenant_id = #form.itenant_id#
				</cfquery>
				 		
				<cfquery name="icontactID" datasource="#application.datasource#">
					Update EFTAccount
					set iContact_ID = <cfqueryparam  cfsqltype="cf_sql_char" value="#variable.icontactID#"> 
					where iEFTAccount_ID  = #EFTID.maxID#
				</cfquery>
			 

<!--- 				<cfif IsDefined("PrimAcct") and PrimAcct is "Y">
					<cfquery name="ContactLink" datasource="#application.datasource#">
						Update LinkTenantContact
						set bIsPrimaryPayer = 1
						where iContact_id = #contactID#
						and iTenant_id = #form.itenant_id#
					</cfquery>				
				</cfif> --->
				
				</cfif>				
			</cfif>			

 		<cfif IsDefined('PrimAcct') >
			<cfif (variable.icontactID is not "")>
				<cfif  PrimAcct is   "Y">
					<cfquery name="primteftcontact" datasource="#application.datasource#">
						Update LinkTenantContact
						set bIsPrimaryPayer =   1
							where iTenant_ID  = #iTenant_ID#
							and iContact_id = <cfqueryparam  cfsqltype="cf_sql_char" value="#variable.icontactID#">
					</cfquery>			
				<cfelseif  PrimAcct is   "N">
						<cfquery name="primeftn" datasource="#application.datasource#">
						Update LinkTenantContact
						set bIsPrimaryPayer =   null
							where iTenant_ID  = #iTenant_ID#
							and iContact_id = <cfqueryparam  cfsqltype="cf_sql_char" value="#variable.icontactID#">
						</cfquery>
						<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
							Update EFTAccount
							set  bApproved = null 
							where iEFTAccount_ID  = #EFTID.maxID#
							and cSolomonKey = '#form.tenantSolomonKey#'
						</cfquery>	
						<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
							Update EFTAccount
							set cApprovedBy = null 
							where iEFTAccount_ID  = #EFTID.maxID#
							and cSolomonKey = '#form.tenantSolomonKey#'
						</cfquery>
						<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
							Update EFTAccount
							set  dApprovedDate = null 
							where iEFTAccount_ID  = #EFTID.maxID#
							and cSolomonKey = '#form.tenantSolomonKey#'
						</cfquery>	

				</cfif>
			<cfelse>
				<cfif  PrimAcct is   "Y">
					<cfquery name="primeft" datasource="#application.datasource#">
						Update tenantstate
						set bIsPrimaryPayer =   1
							where iTenant_ID  = #iTenant_ID#
					</cfquery>
				<cfelseif  PrimAcct is   "N">
						<cfquery name="primeftn" datasource="#application.datasource#">
						Update tenantstate
						set bIsPrimaryPayer =  null
							where iTenant_ID  = #iTenant_ID#
						</cfquery>
						<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
							Update EFTAccount
							set  bApproved = null 
							where iEFTAccount_ID  = #EFTID.maxID#
							and cSolomonKey = '#form.tenantSolomonKey#'
						</cfquery>	
						<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
							Update EFTAccount
							set cApprovedBy = null 
							where iEFTAccount_ID  = #EFTID.maxID#
							and cSolomonKey = '#form.tenantSolomonKey#'
						</cfquery>
						<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
							Update EFTAccount
							set  dApprovedDate = null 
							where iEFTAccount_ID  = #EFTID.maxID#
							and cSolomonKey = '#form.tenantSolomonKey#'
						</cfquery>						

				</cfif>	
			</cfif>		
		</cfif>	

			<cfquery name="cEnteredBy" datasource="#application.datasource#">
				Update EFTAccount
				set cEnteredBy = <cfqueryparam  cfsqltype="cf_sql_char" value="#trim(session.UserName)#">
				where iEFTAccount_ID  = #EFTID.maxID#
			</cfquery>
			
			<cfquery name="dtEnteredDate" datasource="#application.datasource#">
				Update EFTAccount
				set dtEnteredDate =  #CreateODBCDateTime(todaysdate)# 
				where iEFTAccount_ID  = #EFTID.maxID#
			</cfquery>	
			
			<cfif form.dtendeftdate is not ''>
				<cfquery name="EndEFTDate" datasource="#application.datasource#">
					Update EFTAccount
					set dtEndEFTDate =  #CreateODBCDateTime(form.dtendeftdate)#  
					where iEFTAccount_ID  = #EFTID.maxID#
				</cfquery>			
			<cfelse>
				<cfquery name="EndEFTDate" datasource="#application.datasource#">
					Update EFTAccount
					set dtEndEFTDate = null
					where iEFTAccount_ID  = #EFTID.maxID#
				</cfquery>	
			</cfif>
			
			<cfif datebegineft is not "">	
				<cfset thistime = CreateODBCDateTime(#datebegineft#)>
				<cfquery name="datebegineft" datasource="#application.datasource#">
					Update EFTAccount
					set dtBeginEFTDate =  #thistime#
					where iEFTAccount_ID  = #EFTID.maxID#
				</cfquery>		
			<cfelse>
				<cfset thistime = CreateODBCDateTime(#todaysdate#)>			
				<cfquery name="datebegineft" datasource="#application.datasource#">
					Update EFTAccount
					set dtBeginEFTDate =  #thistime#
					where iEFTAccount_ID  = #EFTID.maxID#
				</cfquery>
			</cfif>	 		
				<cfquery name="UsesEFT" datasource="#application.datasource#">
					Update tenantstate
					set bUsesEFT =  1
					where iTenant_ID  = #iTenant_ID#
				</cfquery>			
<!--- 			<cfif IsDefined("form.ExServiceFee") and form.ExServiceFee is "Y">	
				<cfquery name="ExEFT" datasource="#application.datasource#">
					Update tenantstate
					set bExEFTSrvFee =  1
					where iTenant_ID  = #iTenant_ID#
				</cfquery>							
			</cfif>	 --->
<!--- 			<cfif IsDefined("form.ExServiceFeeDrop") and form.ExServiceFeeDrop is "Y">	
				<cfquery name="ExEFT" datasource="#application.datasource#">
					Update tenantstate
					set bExEFTSrvFee =  null
					where iTenant_ID  = #iTenant_ID#
				</cfquery>							
			</cfif>	 --->			
			
<!--- 			<cfif IsDefined("PrimAcct") and PrimAcct is "Y">
				<cfquery name="PrimAcct" datasource="#application.datasource#">
					Update tenantstate
						set bIsPrimaryPayer = 1
						where  iTenant_id = #form.itenant_id#
				</cfquery>							
			</cfif>	 --->			
			<cfif IsDefined("form.cemail") and form.cemail is not "">	
				<cfquery name="email" datasource="#application.datasource#">
					Update tenant 
					set cemail =  '#form.cemail#'
					where iTenant_ID  = #iTenant_ID#
				</cfquery>							
			</cfif>				
<!--- Invoice Detail Update --->
			<cfset iChargeTypeID = 0>
<!---  	<cfif IsDefined("form.ExServiceFee") and form.ExServiceFee is "Y">	
			<cfset iChargeTypeID = 0>	
	<cfelse>		
		<cfif form.iDayofFirstPull lt 6>
			<cfset iChargeTypeID = 0>				
		<cfelse>
		<cfquery name="qryEFTFee" 		DATASOURCE = "#APPLICATION.datasource#">
			select mFeeAmount
			From EFTFees
			where #form.iDayofFirstPull# between ifromday  and iThruDay
		 </cfquery>
			<cfset iChargeTypeID = 1739>
			<cfset chgAmount = qryEFTFee.mFeeAmount>
			<cfset commentDetail = 'EFT Service Charge'>
		</cfif>
	</cfif>	 ---> 			

	<cfif iChargeTypeID gt 0>
		<CFQUERY NAME="ChargeInfo" DATASOURCE = "#APPLICATION.datasource#">
				SELECT cDescription, iChargeType_ID FROM ChargeType WHERE iChargeType_ID = #iChargeTypeID#
		</CFQUERY>
			<CFQUERY NAME = "DuplicateCheck" DATASOURCE = "#APPLICATION.datasource#">
				SELECT	id.* 
				FROM InvoiceDetail id
				Join InvoiceMaster im on (im.iInvoiceMaster_ID = id.iInvoiceMaster_ID and im.bFinalized <> 1)
				WHERE id.dtrowdeleted is null 
				AND	id.iTenant_ID = #form.iTenant_ID# AND id.iQuantity = 1
				AND id.cDescription = '#ChargeInfo.cDescription#' 
				AND id.mAmount =  1 
				AND id.cComments = '#commentDetail#' 
			</CFQUERY>		
			<cfif 	DuplicateCheck.recordcount is 0>
			<CFQUERY NAME = "DuplicateCheck" DATASOURCE = "#APPLICATION.datasource#">
				SELECT	max (im.iInvoiceMaster_ID) as  iInvoiceMaster_ID
				FROM InvoiceDetail id
				Join InvoiceMaster im on (im.iInvoiceMaster_ID = id.iInvoiceMaster_ID )
				WHERE id.dtrowdeleted is null 
				AND	id.iTenant_ID = #form.iTenant_ID#  
				and im.bFinalized IS NULL
			</CFQUERY>					
			</cfif>
			<CFQUERY NAME="qTenant" DATASOURCE="#APPLICATION.datasource#"> 
				SELECT	T.*, H.cStateCode,H.iHouse_ID, ts.iResidencyType_ID
				FROM Tenant T 
				INNER JOIN House H ON T.iHouse_ID = H.iHouse_ID 
				join tenantstate ts on (ts.iTenant_ID = t.iTenant_ID)
				WHERE T.dtRowDeleted IS NULL AND H.dtRowDeleted IS NULL AND T.iTenant_ID = #form.iTenant_ID#
			</CFQUERY>

			<cfquery name="findCharges" DATASOURCE = "#APPLICATION.datasource#">
				SELECT iCharge_ID, iChargeType_ID, iHouse_ID, cDescription, mAmount, iQuantity
				FROM Charges
				Where iChargeType_ID = #iChargeTypeID#
					and iHouse_ID = #qTenant.iHouse_ID#
 			</cfquery>
			<cfif findCharges.recordcount is 0>
			<CFQUERY NAME = "ChargesInsertDetail" DATASOURCE = "#APPLICATION.datasource#">			
				INSERT INTO  Charges 
						   (iChargeType_ID
						   ,iHouse_ID
						   ,cDescription
						   ,mAmount
						   ,iQuantity
						   ,dtEffectiveStart
						   ,iRowStartUser_ID
						   ,dtRowStart
					  )
					 VALUES
						   (#iChargeTypeID#
						   ,#qTenant.iHouse_ID#
						   ,'EFT Service Fee'
						   ,#chgAmount#
						   ,1
						   ,#todaysdate#
						   ,#SESSION.UserID#
						   ,#todaysdate#
						 )		
					 	
				</cfquery>
				<cfquery name="findCharges" DATASOURCE = "#APPLICATION.datasource#">
					SELECT iCharge_ID, iChargeType_ID, iHouse_ID, cDescription, mAmount, iQuantity
					FROM Charges
					Where iChargeType_ID = #iChargeTypeID#
						and iHouse_ID = #qTenant.iHouse_ID#
				</cfquery>
			</cfif>
			<CFQUERY name="qryChkRecurringChg"  DATASOURCE = "#APPLICATION.datasource#">
				Select  iRecurringCharge_ID,iCharge_id, mAmount
				from RecurringCharge
				WHERE iCharge_ID = #findCharges.iCharge_ID#
				and iTenant_ID  = #form.iTenant_ID#
			</CFQUERY>
			<cfif qryChkRecurringChg.recordcount gt 0>here1 #chgAmount#
				<CFIF qryChkRecurringChg.mAmount lt chgAmount>here2 #chgAmount#
					<CFQUERY name="UpdRecurringChg"  DATASOURCE = "#APPLICATION.datasource#">
						UPDATE RecurringCharge
							set mAMount = #chgAmount#
						where  iRecurringCharge_ID = 	#qryChkRecurringChg.iRecurringCharge_ID#	
					</CFQUERY>	
					<CFQUERY name="UpdInvDetail"  DATASOURCE = "#APPLICATION.datasource#">
						UPDATE InvoiceDetail
							set mAMount = #chgAmount#
						where iInvoiceMaster_ID =  #DuplicateCheck.iInvoiceMaster_ID#	
						and iTenant_ID = #form.iTenant_ID#
						and iChargeType_ID = #iChargeTypeID#
					</CFQUERY>					
				</CFIF>
			<cfelse>here3
			<CFQUERY NAME = "RecurringChargeInsertDetail" DATASOURCE = "#APPLICATION.datasource#">
				INSERT INTO  RecurringCharge
						   (iTenant_ID
						   ,iCharge_ID
						   ,dtEffectiveStart
						   ,iQuantity
						   ,cDescription
						   ,mAmount
						   ,cComments
						   ,dtAcctStamp
						   ,iRowStartUser_ID
						   ,dtRowStart
						   ,bIsDaily  
						  )
					 VALUES
						   (#form.iTenant_ID#
						   ,#findCharges.iCharge_ID#
						   ,#todaysdate#
						   ,1
						   ,'EFT Service Fee'
						   ,#chgAmount#
						   ,'#commentDetail#'
						   ,#CreateODBCDateTime(SESSION.AcctStamp)#
						   ,#SESSION.UserID#
						   ,#todaysdate#
						    ,0
						  )			
			</CFQUERY>			

			<cfquery name="qryRecurringChg" datasource= "#APPLICATION.datasource#">
				Select iRecurringCharge_ID
				from RecurringCharge
				where  iTenant_ID  = #form.iTenant_ID#
						and iCharge_ID = #findCharges.iCharge_ID#
						
			</cfquery>			
	 		<CFQUERY NAME = "InsertDetail" DATASOURCE = "#APPLICATION.datasource#">
				INSERT INTO InvoiceDetail
				(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, dtTransaction, 
					iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart, iRecurringCharge_ID )
				VALUES
				(
				 	#DuplicateCheck.iInvoiceMaster_ID#,
			 		#form.iTenant_ID#,
		 			#iChargeTypeID#,
	 				#appytoAcctngPeriod#,
 					NULL,  
		 			#todaysdate#,
		 			1,  
		 			'#TRIM(ChargeInfo.cDescription)#', 
		 			#chgAmount#,	 
		 			'#commentDetail#',
		 			#CreateODBCDateTime(SESSION.AcctStamp)#,
		 			0,
		 			#todaysdate#,
					#qryRecurringChg.iRecurringCharge_ID#
				)
			  </CFQUERY>
			  </cfif>	 
			</cfif>			
		</cftransaction> 
	</cfoutput> 
  
  	 <cfif variable.icontactID is not "">
	 	<cflocation url="TenantEFTEdit.cfm?ID=#iTenant_ID#&CID=#variable.icontactID#">
	 <cfelse>
	 	<cflocation url="TenantEFTEdit.cfm?ID=#iTenant_ID#">
	 </cfif> 

</body>
</html>
