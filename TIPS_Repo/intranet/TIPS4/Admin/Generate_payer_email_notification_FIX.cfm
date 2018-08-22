<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<!--- 
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|sfarmer     |03/20/2012  |  Added for deferred New Resident Fee project 75019                 |
| sfarmer    |9/5/2012    |  corrected return link                                             |
----------------------------------------------------------------------------------------------->
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		
		<title>Generate Secondary Payer Email Notification</title>
		
		<link href="Styles/Index.css" rel="stylesheet" type="text/css" />
		<script src="JavaScript/Functions.js"></script>
		<script src="JavaScript/ts_picker.js"></script>
	</head>
 <cfset earlyweek = 0>
 <cfset lateweek = 0>
	<cfset thisyear = datepart('yyyy',now())>
	<cfset thismonth = datepart('m',now())> 
	<cfset thisdayofweek = datepart('w',now())>	
<cfset earlyweek = 	findoneof('1,2,3' , thisdayofweek)>
<cfset lateweek = 	findoneof('4,5,6,7' , thisdayofweek)>
<br>
early:Late<cfdump var="#earlyweek#, #lateweek#"><br>
<cfif earlyweek is 1>
	<cfif datepart('w',now()) is 2>
		<cfset lastfriday =    dateadd('d', -3, now())  >
	<cfelseif datepart('w',now()) is 3>
		<cfset lastfriday =   dateadd('d', -4, now())  	>
	</cfif>
<cfelse>
	<cfif datepart('w',now()) is 4>
		<cfset lastfriday =    dateadd('d', +2, now())  >
	<cfelseif datepart('w',now()) is 5>
		<cfset lastfriday =   dateadd('d', -1, now())  	>
	<cfelseif datepart('w',now()) is 6>
		<cfset lastfriday =    now()  	>		
	</cfif>
</cfif>
<cfoutput>last friday: #lastfriday#</cfoutput><br>


	<cfset thisdate = thisyear & numberformat(thismonth,'00')>
<!--- 	<cfset thisdate = '201203'> --->
	 <cfoutput>#thisdayofweek# - #thisdate#</cfoutput><br>  
	 
	<cfset dtNotifyDate =  #dateadd('d', +14, lastfriday)#>
	 2 weeks: <cfdump var="#dtNotifyDate#"><br > 
	<cfset thisfriday = datepart('w',dtNotifyDate)>
	<cfset thisfriday = 6 - thisfriday>
	<cfset dtthisfriday = #dateadd('d', + thisfriday, dtNotifyDate)#>
	 2 Weeks friday :<cfdump var="#dtthisfriday#"><br > 
	<cfset dtpastfriday = #dateadd('d', -7, dtthisfriday)# >
	 2 weeks prev friday: <cfdump var="#dtpastfriday#"><br > 
	<cfset daypullbegin = datepart('d',dtpastfriday) + 1>
	<cfset daypullend = datepart('d',dtthisfriday)>
	<cfif   daypullbegin gt 25>
			<cfset daypullbegin = 1>
	</cfif>
	<cfset dtpullbegin = dateadd('d', 1,dtpastfriday) >
	 
		
	<cfset dtpullend = dtthisfriday>
	<cfoutput>#daypullbegin# #daypullend#</cfoutput>
	<cfparam name="amt" default="0">
	
	<cfquery name="qryDate" datasource="#application.datasource#">
		select  dtEFT1, dtEFT2, dtEFT3, dtEFT4, dtEFT5
		from   EFTCalendar2 c  
		where  c.cAppliesToAcctPeriod = 'dtCurrentTipsMonth'
	</cfquery>
	 
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
		and ((iDayofFirstPull between #daypullbegin# and #daypullend#) or (iDayofSecondPull between #daypullbegin# and #daypullend#))
 		and getdate() between  isNUll(EFTA.dtBeginEFTDate, getdate()) and IsNUll(EFTA.dtEndEFTDate, getdate()) 

		
		ORDER by t.itenant_id
	</cfquery>
	  <!--- GROUP by t.itenant_id, t.cFirstName, t.cLastName,con.cfirstname, con.clastname,
	t.bIsPayer,ts.bUsesEFT,ltc.bIsEFT,ltc.bIsPayer, con.cEmail 
	, ts.bIsPrimaryPayer, ltc.bIsPrimaryPayer, h.cname,
	efta.cAccountNumber, efta.iDayofFirstPull, efta.iDayofSecondPull
	having count(*) = 1 --->
 
	<body>
 
		<cfoutput>EFT Notification list for date pull range:  #dateformat(dtpullbegin,'mm/dd/yyyy')# thru #dateformat(dtpullend,'mm/dd/yyyy')#</cfoutput><br>
			<br /><br />	
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
				<cfif IsValid("email", ContactEmail)>
				  <cfmail to="#ContactEmail#" from="DONOTREPLY@alcco.com" subject="EFT Draw Notification" > 
				Dear #confirstname# #conlastname#,<br />
				Per your contract with #housename# and Assisted Living Concepts, Inc. for #cFirstName# #cLastName#, an Electronics Funds Transfer on your account
				ending in #right(cAccountNumber,4)# in the amount of #dollarformat(amt)# will be made on #dateformat(dtthisfriday,'mm/dd/yyyy')#.
				<br />
				Please contact ALC at (888) 252-8991 for questions regarding this account.
				<br />
				Assisted Living Concepts, Inc.<br />
				Accounts Receivable Dept.<br />
				W140 N8981 Lilly Road<br />
				Menomonee Falls , WI 53051
				<br />
				</cfmail>  

				TO: #ContactEmail# <br  />
				FROM: DONOTREPLY@alcco.com  <br  />
				Subject: EFT Draw Notification <br  />
				Dear #confirstname# #conlastname#,<br />
				Per your contract with #housename# and Assisted Living Concepts, Inc. for #cFirstName# #cLastName#, an Electronics Funds Transfer on your account
				ending in #right(cAccountNumber,4)# in the amount of #dollarformat(netchgamt)# will be made on #dateformat(dtthisfriday,'mm/dd/yyyy')#.
				<br />
				Please contact ALC at (888) 252-8991 for questions regarding this account.
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
				ending in #right(cAccountNumber,4)# in the amount of #dollarformat(netchgamt)# will be made on #dateformat(dtthisfriday,'mm/dd/yyyy')#.
				<br />
				Please contact ALC at (888) 252-8991 for questions regarding this account.
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
			and ((iDayofFirstPull between #daypullbegin# and #daypullend#)
			or (iDayofSecondPull between #daypullbegin# and #daypullend#))
			 		and getdate() between  isNUll(EFTA.dtBeginEFTDate, getdate()) and IsNUll(EFTA.dtEndEFTDate, getdate()) 
			ORDER by t.itenant_id
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
			<cfif IsValid("email",cemail)>
			<cfmail to="#cemail#" from="DONOTREPLY@alcco.com" subject="EFT Draw Notification" > 
				Dear #cFirstName# #cLastName#<br />
				Per your contract with #housename# and Assisted Living Concepts, Inc. an Electronics Funds Transfer on your account
				ending in #right(cAccountNumber,4)# in the amount of #dollarformat(amt)# will be made on #dateformat(dtthisfriday,'mm/dd/yyyy')#.
				<br />
				Please contact ALC at (888) 252-8991 for questions regarding this account.
				<br />
				Assisted Living Concepts, Inc.<br />
				Accounts Receivable Dept.<br />
				W140 N8981 Lilly Road<br />
				Menomonee Falls , WI 53051
				<br />
				</cfmail>  
				TO: #cemail# <br  />
				FROM: DONOTREPLY@alcco.com  <br  />
				Subject: EFT Draw Notification <br  />
				Dear #cfirstname# #clastname#,<br />
				Per your contract with #housename# and Assisted Living Concepts, Inc. an Electronics Funds Transfer on your account
				ending in #right(cAccountNumber,4)# in the amount of #dollarformat(netchgamt)# will be made on #dateformat(dtthisfriday,'mm/dd/yyyy')#.
				<br />
				Please contact ALC at (888) 252-8991 for questions regarding this account.
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
				ending in #right(cAccountNumber,4)# in the amount of #dollarformat(netchgamt)# will be made on #dateformat(dtthisfriday,'mm/dd/yyyy')#.
				<br />
				Please contact ALC at (888) 252-8991 for questions regarding this account.
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
