<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<!--- 
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|sfarmer     |03/20/2012  |  Added for deferred New Resident Fee project 75019                 |
| sfarmer    |9/5/2012    |  corrected return link                                             |
| sfarmer    |9/25/2012   |  96402 corrected query -qryContactPayer to pull only if date active|
|            |            |    between start & end date                                        |
|sfarmer     |07/19/2013  |  Corrected phone numbers in emails #106456                         |
----------------------------------------------------------------------------------------------->
 
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		
		<title>Generate Secondary Payer Email Notification</title>
		
		<link href="Styles/Index.css" rel="stylesheet" type="text/css" />
		<script src="JavaScript/Functions.js"></script>
		<script src="JavaScript/ts_picker.js"></script>
	</head>
	<cfoutput>
	<!--- <cfdump var="#session#"> --->
	<cfparam name="whichdate" default="">
	<cfparam name="CALDRAWDATE" default="">
	<cfparam name="calDrawDate1" default="">
	<cfparam name="calDrawDate2" default="">
	<cfparam name="calDrawDate3" default="">
	<cfparam name="calDrawDate4" default="">
	<cfparam name="calDrawDate5" default="">
	<cfparam name="amt" default="0">
	<cfparam name="dtnextpullBegin" default="">
	<cfparam name="dtnextpullEnd" default="">	
	<cfparam name="thisdate" default="">
	
	<cfquery name="qryDate" datasource="#application.datasource#">
		select  dtEFT1, dtEFT2, dtEFT3, dtEFT4, dtEFT5
		from   EFTCalendar2 c  
		where  c.cAppliesToAcctPeriod = #session.acctperiod#
	</cfquery>
	
	<cfif 	qryDate.dtEFT5 is not ''>
		<cfset calDrawDate5 = qryDate.dtEFT5>
	</cfif>
	<cfif 	qryDate.dtEFT4 is not ''>
		<cfset calDrawDate4 = qryDate.dtEFT4>
	</cfif>
	<cfif 	qryDate.dtEFT3 is not ''>
		<cfset calDrawDate3 = qryDate.dtEFT3>
	</cfif>
	<cfif 	qryDate.dtEFT2 is not ''>
		<cfset calDrawDate2 = qryDate.dtEFT2>
	</cfif>
	<cfif 	qryDate.dtEFT1 is not ''>
		<cfset calDrawDate1 = qryDate.dtEFT1>
	</cfif>						
 	 calDrawDate: #calDrawDate1# :: #calDrawDate2#  :: #calDrawDate3# :: #calDrawDate4# :: #calDrawDate5# <BR/>  


	<cfset drawdatearray = ArrayNew(1)>
	
 
		<cfset ArrayAppend(drawdatearray, qryDate.dtEFT1)>
		<cfset ArrayAppend(drawdatearray, qryDate.dtEFT2)>
		<cfset ArrayAppend(drawdatearray, qryDate.dtEFT3)>
		<cfset ArrayAppend(drawdatearray, qryDate.dtEFT4)>
		<cfset ArrayAppend(drawdatearray, qryDate.dtEFT5)>				

	<cfif drawdatearray[5] is not ''>
		<cfset CALDRAWDATE  = drawdatearray[5]>
		<cfset whichdate = 5>
		<cfset lastdrawdate = drawdatearray[4]>
	<cfelseif drawdatearray[4] is not ''>
		<cfset CALDRAWDATE  = drawdatearray[4]>
		<cfset whichdate = 4>
		<cfset lastdrawdate = drawdatearray[3]>
	<cfelseif drawdatearray[3] is not ''>
		<cfset CALDRAWDATE  = drawdatearray[3]>
		<cfset whichdate = 3>
		<cfset lastdrawdate = drawdatearray[2]>
	<cfelseif drawdatearray[2] is not ''>
		<cfset CALDRAWDATE  = drawdatearray[2]>
		<cfset whichdate = 2>
		<cfset lastdrawdate = drawdatearray[1]>
	<cfelseif drawdatearray[1] is not ''>
		<cfset CALDRAWDATE  = drawdatearray[1]>
		<cfset whichdate = 1>
		<cfset lastdrawdate = ''>
	</cfif>
	<cfset dtDrawBegin =  #dateadd('d', +1, lastdrawdate)#>
	<cfset dtNotifyDateEnd =  #dateadd('d', +14, CALDRAWDATE)#>
	<cfset dtNotifyDateBegin =  #dateadd('d', +8, CALDRAWDATE)#>	
	<cfset daypullbegin =  #datepart('d',dtNotifyDateBegin)#>
	<cfset daypullend =  #datepart('d',dtNotifyDateEnd)#>
	<cfif 	daypullbegin lt 5>
		<cfset daypullbegin = 6>
		<cfset dtdiff = daypullbegin - #datepart('d',dtNotifyDateBegin)#>
		<cfset dtNotifyDateBegin =  #dateadd('d', dtdiff, dtNotifyDateBegin)#>
	<cfelseif 	((daypullbegin gt 25) and (daypullbegin le 31))>
		<cfset nextpullbeginDD = '01'><!--- #nextpullbeginDD# --->
		<cfset nextpullendDD = '05'><!--- #nextpullbeginDD# --->		
		<cfset nextyear = dateadd('m', 1, CALDRAWDATE)><!--- #nextyear# --->
		<cfset nextpullbeginMM = #datepart('m',(dateadd('m', 1, CALDRAWDATE)))#><!--- #nextpullbeginMM# --->
		<cfset nextpullbeginyy = #datepart('yyyy',#nextyear#)#><!--- #nextpullbeginyy# --->
		<cfset dtNotifyDateBegin = nextpullbeginyy & '-' & nextpullbeginMM & '-'&nextpullbeginDD><!--- #dtNotifyDateBegin# --->
		<cfset dtNotifyDateEnd =  nextpullbeginyy & '-' & nextpullbeginMM & '-'&nextpullendDD><!--- #dtNotifyDateEnd# --->
	</cfif>

	<cfset dtnextpullBegin = datepart('d',dtNotifyDateBegin)>
	<cfset dtnextpullEnd = datepart('d',dtNotifyDateEnd)>	
<!--- 	 Notify Date Range: days to add: #dtdiff# ::: Notify Date Begin:#dtNotifyDateBegin#  ::: Notify Date End:#dtNotifyDateEnd# ::: daypullbegin: #daypullbegin# ::: daypullend: #daypullend#<br/ > 
 ---> 
<!--- 	<cfset daypullbegin = #dateadd('d',  1, lastdrawdate)# >
	<cfset daypullend = CALDRAWDATE> --->
 
	<!--- <br>Pull date range: #daypullbegin# #daypullend# <br> --->
<!--- 		<cfif calDrawDate5 is not ''>
		<cfset thisdate  =  #calDrawDate5#>
	<cfelseif calDrawDate4 is not ''>
		<cfset thisdate  =  #calDrawDate4#>	
	<cfelseif calDrawDate3 is not ''>
		<cfset thisdate  =  #calDrawDate3#>	
	<cfelseif calDrawDate2 is not ''>
		<cfset thisdate  =  #calDrawDate2#>	
	<cfelseif calDrawDate1 is not ''>
		<cfset thisdate  =  #calDrawDate1#>	
	</cfif> ---> 
	<cfswitch   expression="len(datepart('m',dtNotifyDateEnd))"  >
		<cfcase value="2">
			<cfset thisdate = datepart('yyyy', dtNotifyDateEnd) & datepart('m', dtNotifyDateEnd) >
		</cfcase>
		<cfcase value="1">
			<cfset thisdate = datepart('yyyy', dtNotifyDateEnd) & '0' & datepart('m', dtNotifyDateEnd) >
		</cfcase>	
		<cfdefaultcase  >
			<cfset thisdate = datepart('yyyy', dtNotifyDateEnd) & '0' & datepart('m', dtNotifyDateEnd) >
		</cfdefaultcase>		
	</cfswitch>		
		<!--- <br>#dtNotifyDateEnd# #datepart('yyyy', dtNotifyDateEnd)# :: #datepart('m', dtNotifyDateEnd)#<br> --->
</cfoutput>	
 
	 
	<cfquery name="qryContactPayer" datasource="#application.datasource#" >
		SELECT  t.itenant_id,t.cFirstName
			,t.cLastName
			,t.csolomonkey
			,con.cfirstname 'confirstname'
			,con.clastname 'conlastname' 
			,t.bIsPayer 'TenantPayer'
			,ts.bUsesEFT 'TenantEFT'
			,ltc.bIsEFT 'ContactEFT'  
			,ltc.bIsPayer 'ContactPayer', con.cEmail 'ContactEmail' 
			,ltc.bIsPrimaryPayer 'ContactPrimary', ts.bIsPrimaryPayer 'TenantPrimary' 
			,TS.dDeferral 
			,TS.dSocSec 
			,TS.dMiscPayment
			,TS.dMakeUpAmt	
			,h.cname as 'housename'
			,efta.cAccountNumber
			,efta.iDayofFirstPull
			,efta.iDayofSecondPull
			,dAmtFirstPull 
			,dAmtSecondPull 
			,dPctFirstPull 
			,dPctSecondPull	
			,(select	  isNULL(Sum(iQuantity * mAmount),0) 
				from Tenant tn 
				join TenantState tns  on (tns.iTenant_ID = tn.iTenant_ID and tns.dtRowDeleted is null and tns.iTenantStateCode_ID = 2)
				join InvoiceMaster IM  on im.csolomonkey = t.csolomonkey and IM.dtRowDeleted is null 
				and IM.bFinalized = 1 and IM.cAppliesToAcctPeriod =  '#thisdate#'
				and IM.bMoveInInvoice is null and IM.bMoveOutInvoice is null 
				left join InvoiceDetail INV on INV.iinvoicemaster_id = im.iinvoicemaster_id and INV.dtRowDeleted is null
				join ChargeType CT  on INV.iChargeType_ID = Ct.iChargeType_ID and Ct.dtRowDeleted is null
				and Ct.cGLAccount <> 3012 and Ct.cGLAccount <> 3016
				join AptAddress AD  on ad.iAptAddress_ID = ts.iAptAddress_ID and ad.dtRowDeleted is null
				where tn.itenant_id = t.itenant_id
					) as sum	
		FROM tenant t 
		join tenantstate ts on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null
		
		Join  LinkTenantContact LTC on LTC.iTenant_id = t.itenant_id
			  and LTC.dtRowDeleted Is NULL
			  and isNull(LTC.bIsPayer, 0) = 1
		
		Join Contact CON ON LTC.iContact_ID = CON.iContact_ID 
			  and   CON.dtRowDeleted is NULL
		Join house h on t.ihouse_id = h.ihouse_id
		join dbo.EFTAccount EFTA on T.cSolomonKey = EFTA.cSolomonKey and EFTA.iContact_ID = con.iContact_ID
		
		WHERE t.dtrowdeleted is null
		and ts.itenantstatecode_id = 2
		and ltc.bIsPrimaryPayer is null
		and ((iDayofFirstPull between  #dtnextpullBegin# and #dtnextpullEnd#)
		 or (iDayofSecondPull between #dtnextpullBegin# and #dtnextpullEnd#))
 		and getdate() between  isNUll(EFTA.dtBeginEFTDate, getdate()) and IsNUll(EFTA.dtEndEFTDate, getdate()) 

		
		ORDER by   h.cname, t.clastname, t.cfirstname
	</cfquery>
	  <!--- GROUP by t.itenant_id, t.cFirstName, t.cLastName,con.cfirstname, con.clastname,
	t.bIsPayer,ts.bUsesEFT,ltc.bIsEFT,ltc.bIsPayer, con.cEmail 
	, ts.bIsPrimaryPayer, ltc.bIsPrimaryPayer, h.cname,
	efta.cAccountNumber, efta.iDayofFirstPull, efta.iDayofSecondPull
	having count(*) = 1 --->
 
	<body>
			<br/><cfoutput>This Draw Date: #dateformat(dtDrawBegin, 'mm/dd/yyyy')# -  #dateformat(CALDRAWDATE, 'mm/dd/yyyy')#</cfoutput><br/> 
			<br/><cfoutput>EFT Notification list for date pull range:  #dateformat(dtNotifyDateBegin,'mm/dd/yyyy')# thru #dateformat(dtNotifyDateend,'mm/dd/yyyy')#, Day Range:#dtnextpullBegin# - #dtnextpullEnd# AcctPeriod= #thisdate#</cfoutput><br/>
			<br />	
			<cfoutput query="qryContactPayer">
			<br>#cFirstName# #cLastName#<br >
			<cfquery name="sumpaymnt"  datasource="#application.datasource#"> 
				   select  IsNull(sum(isnull(dAmtSecondPull,0) + isnull(dAmtFirstPull,0)),0)  as dollarsum
				 from dbo.EFTAccount efta   
				 where  dtRowDeleted is null and csolomonkey = '#qryContactPayer.csolomonkey#' 
			</cfquery>	
			<cfset netchgamt = sum>      
			<cfif   dDeferral is not "" >
				<cfset netchgamt = netchgamt - dDeferral>
			</cfif>
			<cfif   dSocSec  is not "" >										
				<cfset netchgamt = netchgamt - dSocSec>
			</cfif>
			<cfif   dMiscPayment  is not "" >										
				<cfset netchgamt = netchgamt - dMiscPayment>
			</cfif>
			
			<cfif ((iDayofFirstPull ge daypullbegin) and (iDayofFirstPull le daypullend))>
				<cfif dAmtFirstPull   gt 0  >
					<cfset netchgamt = dAmtFirstPull> 
				<cfelseif  dPctFirstPull gt 0  >	
					<cfset netchgamt = (netchgamt - sumpaymnt.dollarsum) * (dPctFirstPull/100)> 
				</cfif>
			<cfelseif    ((iDayofSecondPull ge  daypullbegin) and (iDayofSecondPull le daypullend))>
				<cfif  dAmtSecondPull gt 0  >
					<cfset netchgamt = dAmtSecondPull> 
				<cfelseif  dPctSecondPull gt 0  >	
					<cfset netchgamt = (netchgamt - sumpaymnt.dollarsum) * (dPctSecondPull/100)> 
				</cfif>
			</cfif>
 			
			<cfif ContactEFT  is 1 and ContactEmail is not "">
				<!--- <cfif IsValid("email", ContactEmail)> --->
		
				<cfif ContactEmail is not "">
					<cfif netchgamt gt 0>
					  <cfmail to="#ContactEmail#" from="DONOTREPLY@alcco.com" subject="EFT Draw Notification"  type="html"> 
						Dear #confirstname# #conlastname#,<br />
						Per your contract with #housename# and Assisted Living Concepts, Inc. for #cFirstName# #cLastName#, an Electronics Funds Transfer on your account
						ending in #right(cAccountNumber,4)# in the amount of #dollarformat(netchgamt)# will be made on #dateformat(dtNotifyDateend,'mm/dd/yyyy')#.
						<br />
						Please contact ALC at (262) 257-8888 or toll free 1-888-252-5001 for questions regarding this account.
						<br />
						Assisted Living Concepts, Inc.<br />
						Accounts Receivable Dept.<br />
						W140 N8981 Lilly Road<br />
						Menomonee Falls , WI 53051
						<br />
					</cfmail>  
					<br>Sent:  #confirstname# #conlastname# for  #dollarformat(netchgamt)# to #ContactEmail#<br>
					</cfif>
					<cfif netchgamt le 0>
						<br/>This account has no draw amount, simulated Email only<br/>
					</cfif>
				TO: #ContactEmail# <br  />
				FROM: DONOTREPLY@alcco.com  <br  />
				Subject: EFT Draw Notification <br  />
				Dear #confirstname# #conlastname#,<br />
				Per your contract with #housename# and Assisted Living Concepts, Inc. for #cFirstName# #cLastName#, an Electronics Funds Transfer on your account
				ending in #right(cAccountNumber,4)# in the amount of #dollarformat(netchgamt)# will be made on #dateformat(dtNotifyDateend,'mm/dd/yyyy')#.
				<br />
				Please contact ALC at (262) 257-8888 or toll free 1-888-252-5001 for questions regarding this account.
				<br />
				Assisted Living Concepts, Inc.<br />
				Accounts Receivable Dept.<br />
				W140 N8981 Lilly Road<br />
				Menomonee Falls , WI 53051 
				<br />Day of First Pull:#iDayofFirstPull#  Day of Second Pull: #iDayofSecondPull# <br/> Contact Pay
				<br /><br />
				<cfelse>
				* * * * NO VALID EMAIL: #confirstname# #conlastname# does not have a valid email<br>
				TO: #ContactEmail# <br  />
				FROM: DONOTREPLY@alcco.com  <br  />
				Subject: EFT Draw Notification <br  />
				Dear #confirstname# #conlastname#,<br />
				Per your contract with #housename# and Assisted Living Concepts, Inc. for #cFirstName# #cLastName#, an Electronics Funds Transfer on your account
				ending in #right(cAccountNumber,4)# in the amount of #dollarformat(netchgamt)# will be made on #dateformat(dtNotifyDateend,'mm/dd/yyyy')#.
				<br />
				Please contact ALC at (262) 257-8888 or toll free 1-888-252-5001 for questions regarding this account.
				<br />
				Assisted Living Concepts, Inc.<br />
				Accounts Receivable Dept.<br />
				W140 N8981 Lilly Road<br />
				Menomonee Falls , WI 53051 
				<br />Day of First Pull:#iDayofFirstPull#  Day of Second Pull: #iDayofSecondPull# <br/> Contact Pay
				<br /><br />
				
				</cfif>
			</cfif>
		</cfoutput>
	
		<cfquery name="qrySelfPayer" datasource="#application.datasource#" >
			SELECT  t.itenant_id
				,t.cFirstName
				,t.csolomonkey				
				,t.cLastName
				,t.bIsPayer 'TenantPayer'
				,ts.bUsesEFT 'TenantEFT'
				,ts.bIsPrimaryPayer 'TenantPrimary'
				,t.cemail
				,TS.dDeferral 
				,TS.dSocSec 
				,TS.dMiscPayment
				,TS.dMakeUpAmt	
				,h.cname as 'housename'
				,efta.cAccountNumber
				,efta.iDayofFirstPull
				,efta.iDayofSecondPull
				,dAmtFirstPull 
				,dAmtSecondPull 
				,dPctFirstPull 
				,dPctSecondPull	
				,(select	  isNULL(Sum(iQuantity * mAmount),0) 
					from Tenant tn 
					join TenantState tns  on (tns.iTenant_ID = tn.iTenant_ID and tns.dtRowDeleted is null and tns.iTenantStateCode_ID = 2)
					join InvoiceMaster IM  on im.csolomonkey = t.csolomonkey and IM.dtRowDeleted is null 
					and IM.bFinalized = 1 and IM.cAppliesToAcctPeriod = '#thisdate#'
					and IM.bMoveInInvoice is null and IM.bMoveOutInvoice is null 
					left join InvoiceDetail INV on INV.iinvoicemaster_id = im.iinvoicemaster_id and INV.dtRowDeleted is null
					join ChargeType CT  on INV.iChargeType_ID = Ct.iChargeType_ID and Ct.dtRowDeleted is null
					and Ct.cGLAccount <> 3012 and Ct.cGLAccount <> 3016
					join AptAddress AD  on ad.iAptAddress_ID = ts.iAptAddress_ID and ad.dtRowDeleted is null
					where tn.itenant_id = t.itenant_id
						) as sum	
			FROM tenant t 
				join tenantstate ts on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null
				Join house h on t.ihouse_id = h.ihouse_id
				join dbo.EFTAccount EFTA on T.cSolomonKey = EFTA.cSolomonKey 
			WHERE t.dtrowdeleted is null
			and ts.itenantstatecode_id = 2
			and ts.bIsPrimaryPayer is null
			and ((iDayofFirstPull between  #dtnextpullBegin# and #dtnextpullEnd#)
		 		or (iDayofSecondPull between #dtnextpullBegin# and #dtnextpullEnd#))
	 		and getdate() between  isNUll(EFTA.dtBeginEFTDate, getdate()) and IsNUll(EFTA.dtEndEFTDate, getdate()) 
			ORDER by h.cname, t.clastname, t.cfirstname
		</cfquery>
		<!--- GROUP by t.itenant_id, t.cFirstName, t.cLastName, 
			t.bIsPayer,ts.bUsesEFT  
			, ts.bIsPrimaryPayer , h.cname,t.cemail,
			efta.cAccountNumber, efta.iDayofFirstPull, efta.iDayofSecondPull
			having count(*) = 1 --->
			
		<cfoutput query="qrySelfPayer">
					<br>#cFirstName# #cLastName#<br >
						<cfquery name="sumpaymnt"  datasource="#application.datasource#"> 
							   select  IsNUll(sum(isnull(dAmtSecondPull,0) + isnull(dAmtFirstPull,0)),0)  as dollarsum
							 from dbo.EFTAccount efta   
							 where  dtRowDeleted is null and csolomonkey = '#qrySelfPayer.csolomonkey#' 
						</cfquery>		
			<cfset netchgamt = sum>
			<cfif   dDeferral is not "" >
				<cfset netchgamt = netchgamt - dDeferral>
			</cfif>
			<cfif   dSocSec  is not "" >										
				<cfset netchgamt = netchgamt - dSocSec>
			</cfif>
			<cfif   dMiscPayment  is not "" >										
				<cfset netchgamt = netchgamt - dMiscPayment>
			</cfif> 
			<cfif ((iDayofFirstPull ge daypullbegin) and (iDayofFirstPull le daypullend))>
				<cfif  dAmtFirstPull gt 0  >
					<cfset netchgamt = dAmtFirstPull> 
				<cfelseif  dPctFirstPull gt 0  >	
					<cfset netchgamt = (netchgamt - sumpaymnt.dollarsum) * (dPctFirstPull/100)>
				</cfif>
			<cfelseif    ((iDayofSecondPull ge  daypullbegin) and (iDayofSecondPull le daypullend))>
				<cfif  dAmtSecondPull gt 0  >
					<cfset netchgamt = dAmtSecondPull> 
				<cfelseif  dPctSecondPull gt 0  >	
					<cfset netchgamt = (netchgamt - sumpaymnt.dollarsum) * (dPctSecondPull/100)>
				</cfif>
			</cfif>	
			<!--- <cfif IsValid("email",cemail)> --->
			<cfif cemail is not "">
				<cfif netchgamt gt 0>
					<cfmail to="#cemail#" from="DONOTREPLY@alcco.com" subject="EFT Draw Notification"  type="html" > 
					Dear #cFirstName# #cLastName#<br />
					Per your contract with #housename# and Assisted Living Concepts, Inc. an Electronics Funds Transfer on your account
					ending in #right(cAccountNumber,4)# in the amount of #dollarformat(netchgamt)# will be made on #dateformat(dtNotifyDateend,'mm/dd/yyyy')#.
					<br />
					Please contact ALC at (262) 257-8888 or toll free 1-888-252-5001 for questions regarding this account.
					<br />
					Assisted Living Concepts, Inc.<br />
					Accounts Receivable Dept.<br />
					W140 N8981 Lilly Road<br />
					Menomonee Falls , WI 53051
					<br />
					</cfmail>  
				</cfif>
				<cfif netchgamt le 0>
					<br/>This account has no draw amount, simulated Email only<br/>
				</cfif>
				TO: #cemail# <br  />
				FROM: DONOTREPLY@alcco.com  <br  />
				Subject: EFT Draw Notification <br  />
				Dear #cfirstname# #clastname#,<br />
				Per your contract with #housename# and Assisted Living Concepts, Inc. an Electronics Funds Transfer on your account
				ending in #right(cAccountNumber,4)# in the amount of #dollarformat(netchgamt)# will be made on #dateformat(dtNotifyDateend,'mm/dd/yyyy')#.
				<br />
				Please contact ALC at (262) 257-8888 or toll free 1-888-252-5001  for questions regarding this account.
				<br />	
				Assisted Living Concepts, Inc.<br />
				Accounts Receivable Dept.<br />
				W140 N8981 Lilly Road<br />
				Menomonee Falls , WI 53051
				<br />Day of First Pull: #iDayofFirstPull# Day of Second Pull: #iDayofSecondPull# <br/>Self Pay
				<br /><br />
			<cfelse>
			* * * NO VALID EMAIL: #cFirstName# #cLastName# does not have a valid email<br  />
				TO: #cemail# <br  />
				FROM: DONOTREPLY@alcco.com  <br  />
				Subject: EFT Draw Notification <br  />
				Dear #cfirstname# #clastname#,<br />
				Per your contract with #housename# and Assisted Living Concepts, Inc. an Electronics Funds Transfer on your account
				ending in #right(cAccountNumber,4)# in the amount of #dollarformat(netchgamt)# will be made on #dateformat(dtNotifyDateend,'mm/dd/yyyy')#.
				<br />
				Please contact ALC at (262) 257-8888 or toll free 1-888-252-5001  for questions regarding this account.
				<br />	
				Assisted Living Concepts, Inc.<br />
				Accounts Receivable Dept.<br />
				W140 N8981 Lilly Road<br />
				Menomonee Falls , WI 53051
				<br />Day of First Pull: #iDayofFirstPull# Day of Second Pull: #iDayofSecondPull# <br/>Self Pay
				<br /><br />			
			</cfif>
 
		</cfoutput>
	
		<table>
			<tr>
				<td><input type="button" name="Return to EFT Pull Process"  title="Return to EFT Pull Process"  value="Return to EFT Pull Process" onclick="location.href='EFTPullcalendar.cfm'"></td>
			</tr>
		</table>
	</body>
</html>
