<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<!--- ------------------------------------------------------------------------------------------
 sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                           |
 sfarmer     | 11/20/2012 |tickets 97882, 95010, 95009, 95468, 97570, 97710 for  misc. updates | 
 sfarmer     | 08/08/2013 |project 106456 EFT Updates                                          |
-----------------------------------------------------------------------------------------------> 
<html xmlns="http://www.w3.org/1999/xhtml">
<cfparam name="closethis" default="">
<cfparam name="thisCID" default="">
<head>
<cfset todaysdate = CreateODBCDateTime(now())>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>TenantEFTEditUpdate</title>
</head>
 
 
<body>
 <cfdump var="#closethis#, #tenantSolomonKey#, #iTenant_ID# , #todaysdate#">
 

<cfoutput>
	<cfquery name="TenantInfo" DATASOURCE="#APPLICATION.datasource#">
	select distinct t.*, TS.*, TC.*, AD.*, AP.cDescription as RoomType, RT.cDescription as Residency, T.cComments as TenantComments, t.bIsBond as BondTenant
	from tenant T
	left outer join tenantstate TS on T.iTenant_ID = TS.iTenant_ID
	left outer join tenantstatecodes TC on TS.iTenantStateCode_ID = TC.iTenantStateCode_ID
	left outer join aptaddress AD on TS.iAptAddress_ID = AD.iAptAddress_ID
	left outer join apttype AP on AP.iAptType_ID = AD.iAptType_ID 
	left outer join ResidencyType RT on RT.iResidencyType_ID = TS.iResidencyType_ID
	where T.iTenant_ID = #iTenant_ID#
	</cfquery>	   
	iEFTAccount_ID=#iEFTAccount_ID#<br />
	iTenant_ID=#iTenant_ID#<br />
	tenantSolomonKey=#tenantSolomonKey#<br />
	closethis=#closethis#<br /> 
	
 	<cfquery name="EFTinfo" datasource="#application.datasource#"> 
		SELECT iEFTAccount_ID 
			,cRoutingNumber 
			,CaCCOUNTnUMBER 
			,cAccountType 
			,iOrderofPull 
			,iDayofFirstPull 
			,dPctFirstPull 
			,dAmtFirstPull 
			,iDayofSecondPull 
			,dPctSecondPull 
			,dAmtSecondPull 
			,iContact_id 
			,dtBeginEFTDate 
			,dtEndEFTDate 
			 
		FROM EFTAccount 
		WHERE cSolomonKey = '#TenantInfo.cSolomonKey#'
			and iEFTAccount_ID=#iEFTAccount_ID#			
	</cfquery>

	<cfif isDefined("closethis") and closethis is "Y">
		
	<cftransaction>
 
			<cfquery name="cLastModifiedBy" datasource="#application.datasource#">
				Update EFTAccount
				set  cLastModifiedBy = '#session.username#' 					 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	
			<!--- <cfquery name="dtRowEnd" datasource="#application.datasource#">
				Update EFTAccount
				set  dtRowEnd = #todaysdate# 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	 --->
			<cfquery name="dtLastModifiedDate" datasource="#application.datasource#">
				Update EFTAccount
				set  dtLastModifiedDate = #todaysdate#  					 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	
			<cfquery name="dtRowDeleted" datasource="#application.datasource#">
				Update EFTAccount
				set  dtRowDeleted = #todaysdate#  					 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	
			<cfquery name="dtEndEFTDate" datasource="#application.datasource#">
				Update EFTAccount
				set  dtEndEFTDate = #todaysdate#  					 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	
			<cfquery name="iRowEndUser_ID" datasource="#application.datasource#">
				Update EFTAccount
				set  iRowEndUser_ID = #session.userid#  					 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	
			<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
				Update EFTAccount
				set  iRowDeletedUser_ID = #session.userid# 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>																			
			<!---Mshah Added this if the EFT inactivated, tenant should drop from busesEFT 12/01/2016---> 
			<cfquery name="EFTActive" datasource="#application.datasource#">
				Select iEFTAccount_ID from EFTAccount
				where   cSolomonKey = '#tenantSolomonKey#'
				and dtrowdeleted is null
			</cfquery>	
				<cfif EFTActive.recordcount is 0 >
					<cfquery name="UsesEFT" datasource="#application.datasource#" result="usesEFT" >
						Update tenantstate
						set bUsesEFT =  null
						where iTenant_ID  = #iTenant_ID#
					</cfquery>	
		    	</cfif>
	</cftransaction>
	<cfelseif isDefined("reopenthis") and reopenthis is "Y">
		
	<cftransaction>
				<cfquery name="UsesEFT" datasource="#application.datasource#">
					Update tenantstate
					set bUsesEFT =  1
					where iTenant_ID  = #iTenant_ID#
				</cfquery>	 
			<cfquery name="cLastModifiedBy" datasource="#application.datasource#">
				Update EFTAccount
				set  cLastModifiedBy = '#session.username#' 					 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	
			<cfquery name="dtRowEnd" datasource="#application.datasource#">
				Update EFTAccount
				set  dtRowEnd = null 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	
			<cfquery name="dtLastModifiedDate" datasource="#application.datasource#">
				Update EFTAccount
				set  dtLastModifiedDate = #todaysdate#  					 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	
			<cfquery name="dtRowDeleted" datasource="#application.datasource#">
				Update EFTAccount
				set  dtRowDeleted = null  					 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	
			<cfquery name="dtEndEFTDate" datasource="#application.datasource#">
				Update EFTAccount
				set  dtEndEFTDate = null  					 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	
			<cfquery name="iRowEndUser_ID" datasource="#application.datasource#">
				Update EFTAccount
				set  iRowEndUser_ID = null  					 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	
			<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
				Update EFTAccount
				set  iRowDeletedUser_ID = null 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>																			
			<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
				Update EFTAccount
				set  bApproved = null 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>	
			<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
				Update EFTAccount
				set cApprovedBy = null 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>
			<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
				Update EFTAccount
				set  dApprovedDate = null 
				where iEFTAccount_ID  = #iEFTAccount_ID#
				and cSolomonKey = '#tenantSolomonKey#'
			</cfquery>								 
	</cftransaction>	
	<cfelse>
	
	<cftransaction>		 				
 
		<cfif form.croutingnumber is not "">
			<cfquery name="croutingnumber" datasource="#application.datasource#">
				Update EFTAccount
				set  croutingnumber = <cfqueryparam  cfsqltype="cf_sql_varchar" 	value="#form.croutingnumber#">	 
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		</cfif>	
		<cfif form.caccountnumber is not "">
			<cfquery name="caccountnumber" datasource="#application.datasource#">
				Update EFTAccount
				set  caccountnumber = <cfqueryparam  cfsqltype="cf_sql_varchar"   	value="#form.caccountnumber#">	 
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		</cfif>		
		<cfif form.caccounttype is not "">
			<cfquery name="caccounttype" datasource="#application.datasource#">
				Update EFTAccount
				set  caccounttype = <cfqueryparam  cfsqltype="cf_sql_char"   	value="#form.caccounttype#">	 
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		</cfif>									   
		<cfif (EFTinfo.iDayofFirstPull is "")>
			<cfif  (form.iDayofFirstPull is not "") >
				<cfquery name="DayofFirstPull" datasource="#application.datasource#">
					Update EFTAccount
					set  iDayofFirstPull = <cfqueryparam  cfsqltype="cf_sql_integer" 	value="#form.iDayofFirstPull#">	 
					where iEFTAccount_ID  = #form.iEFTAccount_ID#
					and cSolomonKey = '#form.tenantSolomonKey#'
				</cfquery>
			<cfelse>
				<cfquery name="DayofFirstPull" datasource="#application.datasource#">
					Update EFTAccount
					set  iDayofFirstPull = 5 
					where iEFTAccount_ID  = #form.iEFTAccount_ID#
					and cSolomonKey = '#form.tenantSolomonKey#'
				</cfquery>			
			</cfif>
		<cfelse>
			<cfif  (form.iDayofFirstPull is   "") >
				<cfquery name="DayofFirstPull" datasource="#application.datasource#">
					Update EFTAccount
						set  iDayofFirstPull = null	 
					where iEFTAccount_ID  = #form.iEFTAccount_ID#
					and cSolomonKey = '#form.tenantSolomonKey#'
				</cfquery>		
			<cfelse>
				<cfquery name="DayofFirstPull" datasource="#application.datasource#">
					Update EFTAccount
						set  iDayofFirstPull = <cfqueryparam  cfsqltype="cf_sql_integer" 	value="#form.iDayofFirstPull#">	 
					where iEFTAccount_ID  = #form.iEFTAccount_ID#
					and cSolomonKey = '#form.tenantSolomonKey#'
				</cfquery>		
			</cfif>		
		</cfif>				
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
		<cfif form.iOrderofPull is not "">
			<cfquery name="OrderofPull" datasource="#application.datasource#">
				Update EFTAccount
				set  iOrderofPull = <cfqueryparam  cfsqltype="cf_sql_integer" 	value="#iOrderofPull#"> 
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		<cfelse>
			<cfquery name="OrderofPull" datasource="#application.datasource#">
				Update EFTAccount
				set  iOrderofPull = null 
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		</cfif>			
		<cfif form.dAmtFirstPull is not "">
			<cfquery name="AmtFirstPulll" datasource="#application.datasource#">
				Update EFTAccount
				set  dAmtFirstPull = <cfqueryparam  cfsqltype="cf_sql_money" 	value="#form.dAmtFirstPull#"> 
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		<cfelse>
			<cfquery name="AmtFirstPulll" datasource="#application.datasource#">
				Update EFTAccount
				set  dAmtFirstPull = null
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>			
		</cfif>
		<cfif form.dpctfirstpull is not "">
			<cfquery name="AmtFirstPulll" datasource="#application.datasource#">
				Update EFTAccount
				set  dPctFirstPull =  #form.dpctfirstpull# 
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		<cfelse>
			<cfquery name="AmtFirstPulll" datasource="#application.datasource#">
				Update EFTAccount
				set  dPctFirstPull = null
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>		
		</cfif>			
		<cfif form.dpctsecondpull is not "">
			<cfquery name="PctSecondPull" datasource="#application.datasource#">
				Update EFTAccount
				set  dPctSecondPull =  #form.dpctsecondpull# 
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
			<cfelse>
			<cfquery name="PctSecondPull" datasource="#application.datasource#">
				Update EFTAccount
				set  dPctSecondPull = null
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		</cfif>	
		<cfif form.damtsecondpull is not "">
			<cfquery name="AmtSecondPull" datasource="#application.datasource#">
				Update EFTAccount
				set  dAmtSecondPull = <cfqueryparam  cfsqltype="cf_sql_money" 	value="#form.damtsecondpull#">
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		<cfelse>
			<cfquery name="AmtSecondPull" datasource="#application.datasource#">
				Update EFTAccount
				set  dAmtSecondPull = null
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		</cfif>
		
		<cfif form.iDayofSecondPull is not "">
			<cfquery name="DayofSecondPull" datasource="#application.datasource#">
				Update EFTAccount
				set iDayofSecondPull = <cfqueryparam  cfsqltype="cf_sql_integer" 	value="#form.iDayofSecondPull#">
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
			<cfelse>
			<cfquery name="DayofSecondPull" datasource="#application.datasource#">
				Update EFTAccount
				set iDayofSecondPull = null
				where iEFTAccount_ID  = #form.iEFTAccount_ID#
				and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		</cfif>

		<cfset thisCID = form.CID>
		<cfif ((IsDefined('form.contactID')) and (form.contactID is not "")) >
 				<cfset thisCID = form.contactID>
		<cfelseif ((IsDefined('form.CID')) and (form.CID is not "")) >
				<cfset thisCID = form.CID>
		</cfif>			
			
		<cfif thisCID is not "">
				<cfquery name="iContactID" datasource="#application.datasource#">
					Update EFTAccount
					set iContact_ID = <cfqueryparam  cfsqltype="cf_sql_char" value="#thisCID#">
					where iEFTAccount_ID  = #form.iEFTAccount_ID#
					and cSolomonKey = '#form.tenantSolomonKey#'
				</cfquery>
 				<cfif IsDefined('PrimAcct') >
 					<cfif  PrimAcct is   "Y">
						<cfquery name="primteftcontact" datasource="#application.datasource#">
							Update LinkTenantContact
							set bIsPrimaryPayer =   1
								where iTenant_ID  = #iTenant_ID#
								and iContact_id = #thisCID#
						</cfquery>			
						<cfelseif  PrimAcct is   "N">
							<cfquery name="primeftn" datasource="#application.datasource#">
								Update LinkTenantContact
								set bIsPrimaryPayer =   null
									where iTenant_ID  = #iTenant_ID#
									and iContact_id = #thisCID#
							</cfquery>
						<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
							Update EFTAccount
							set  bApproved = null 
							where  
							  cSolomonKey = '#form.tenantSolomonKey#'
						</cfquery>	
						<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
							Update EFTAccount
							set cApprovedBy = null 
							where  
							  cSolomonKey = '#form.tenantSolomonKey#'
						</cfquery>
						<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
							Update EFTAccount
							set  dApprovedDate = null 
							where  
							  cSolomonKey = '#form.tenantSolomonKey#'
						</cfquery>	
					</cfif>
				</cfif>		
				<cfif IsDefined("form.cemail") and form.cemail is not "">
					<cfquery name="UsesEFT" datasource="#application.datasource#">
						Update contact 
						set cemail =  '#cemail#'
						where iContact_id = #thisCID#
					</cfquery>		
				</cfif>	
				 	
		<cfelse>
 				<cfif IsDefined('PrimAcct') >		
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
							where  
							  cSolomonKey = '#form.tenantSolomonKey#'
						</cfquery>	
						<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
							Update EFTAccount
							set cApprovedBy = null 
							where  
							  cSolomonKey = '#form.tenantSolomonKey#'
						</cfquery>
						<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
							Update EFTAccount
							set  dApprovedDate = null 
							where  
							  cSolomonKey = '#form.tenantSolomonKey#'
						</cfquery>	
					</cfif>	
				</cfif>
				<cfquery name="UsesEFT" datasource="#application.datasource#">
					Update tenantstate
					set bUsesEFT =  1
					where iTenant_ID  = #iTenant_ID#
				</cfquery>		
				<cfif IsDefined("form.cemail") and form.cemail is not "">
					<cfquery name="UsesEFT" datasource="#application.datasource#">
						Update tenant 
						set cemail =  '#cemail#'
						where iTenant_ID  = #iTenant_ID#
					</cfquery>		
				</cfif>				 
		</cfif>	
		<cfif trim(form.dtendeftdate) is not ''>
			<cfquery name="EndEFTDate" datasource="#application.datasource#">
				Update EFTAccount
				set dtEndEFTDate =  #CreateODBCDateTime(form.dtendeftdate)#  
			where iEFTAccount_ID  = #form.iEFTAccount_ID#
			and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>			
				<cfif datecompare(form.dtendeftdate, #now()#) lt 0> 
					<cfquery name="cLastModifiedBy" datasource="#application.datasource#">
						Update EFTAccount
						set  cLastModifiedBy = '#session.username#' 					 
						where iEFTAccount_ID  = #iEFTAccount_ID#
						and cSolomonKey = '#tenantSolomonKey#'
					</cfquery>	
				<!--- 	<cfquery name="dtRowEnd" datasource="#application.datasource#">
						Update EFTAccount
						set  dtRowEnd = #CreateODBCDateTime(dtendeftdate)# 
						where iEFTAccount_ID  = #iEFTAccount_ID#
						and cSolomonKey = '#tenantSolomonKey#'
					</cfquery> --->	
					<cfquery name="dtLastModifiedDate" datasource="#application.datasource#">
						Update EFTAccount
						set  dtLastModifiedDate = #todaysdate#  					 
						where iEFTAccount_ID  = #iEFTAccount_ID#
						and cSolomonKey = '#tenantSolomonKey#'
					</cfquery>	
					<cfquery name="dtRowDeleted" datasource="#application.datasource#">
						Update EFTAccount
						set  dtRowDeleted = #todaysdate#  					 
						where iEFTAccount_ID  = #iEFTAccount_ID#
						and cSolomonKey = '#tenantSolomonKey#'
					</cfquery>	
					<cfquery name="dtEndEFTDate" datasource="#application.datasource#">
						Update EFTAccount
						set  dtEndEFTDate = #CreateODBCDateTime(dtendeftdate)#  					 
						where iEFTAccount_ID  = #iEFTAccount_ID#
						and cSolomonKey = '#tenantSolomonKey#'
					</cfquery>	
					<cfquery name="iRowEndUser_ID" datasource="#application.datasource#">
						Update EFTAccount
						set  iRowEndUser_ID = #session.userid#  					 
						where iEFTAccount_ID  = #iEFTAccount_ID#
						and cSolomonKey = '#tenantSolomonKey#'
					</cfquery>	
					<cfquery name="iRowDeletedUser_ID" datasource="#application.datasource#">
						Update EFTAccount
						set  iRowDeletedUser_ID = #session.userid# 
						where iEFTAccount_ID  = #iEFTAccount_ID#
						and cSolomonKey = '#tenantSolomonKey#'
					</cfquery>			
				</cfif>			
		<cfelseif trim(form.dtendeftdate) is  ''>
			<cfquery name="EndEFTDate" datasource="#application.datasource#">
				Update EFTAccount
				set dtEndEFTDate =  null
			where iEFTAccount_ID  = #form.iEFTAccount_ID#
			and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>	
		</cfif>
 

 		<cfif IsDefined('dtBeginEFTDate') and dtBeginEFTDate is not "">
		<cfset begineftdate = #CreateODBCDate(dtBeginEFTDate)# >
			<cfquery name="datebegineft" datasource="#application.datasource#">
				Update EFTAccount
				set dtBeginEFTDate =   <cfqueryparam value="#begineftdate#" cfsqltype="cf_sql_date">
					where iEFTAccount_ID  = #form.iEFTAccount_ID#
					and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		<cfelse>
				<cfquery name="datebegineft" datasource="#application.datasource#">
				Update EFTAccount
				set dtBeginEFTDate =   #CreateODBCDateTime(Now())#
					where iEFTAccount_ID  = #form.iEFTAccount_ID#
					and cSolomonKey = '#form.tenantSolomonKey#'
			</cfquery>
		</cfif>
 

	</cftransaction>
	</cfif>	
 	 <cflocation url="TenantEFTEdit.cfm?ID=#iTenant_ID#" >  
</cfoutput>
</body>
</html>
