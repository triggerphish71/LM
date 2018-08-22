<!--- -------------------------------------------------------------------------------------------
 | sfarmer    | 11/20/2012 |tickets 97882, 95010, 95009, 95468, 97570, 97710 for  misc. updates |
 | sfarmer    | 08/08/2013 |project 106456 EFT Updates                                          |
 | mstriegel  | 05/16/2018 | converted to use cfc and cleaned up code                           |
------------------------------------------------------------------------------------------------>
<!--- create the objects we will be using for tis process --->
<cfset oEFTAllServices = CreateObject("component","intranet.TIPS4.CFC.Components.EFT.EFTServices")>


<cfparam name="showall" default="Y">
<cfparam name="View" default="">
<cfparam name="days" default="">
<cfparam name="strtday" default="1">
<cfparam name="endday" default="25">  
<CFPARAM name="thisdate" default="">
<CFPARAM name="eftpulmonth" default="">

<cfset eftpulmonth = dateadd('m', -1,  #session.TIPSMonth#) >
<cfoutput>#eftpulmonth#</cfoutput>
<cfset thisyy = mid(eftpulmonth,6,4)>
<cfset thismm = mid(eftpulmonth,11,2)>
<cfset pullacctperiod = #dateformat(eftpulmonth,'YYYYMM')#>	
<cfset thisdate = #thisdate#>
<br /><cfoutput> #thisdate# -- #pullacctperiod# </cfoutput><br />
  

<cfset destFilePath = "\\fs01\ALC_IT\EFTPull">
<cfset filename = "EFTUserData">
<cfoutput>
	<cfif FileExists("#destFilePath#\#filename#.csv")>
		<cffile action="delete"  file="#destFilePath#\#filename#.csv" >
		<br />Deleted #destFilePath#\#filename#.csv<br />
	</cfif>
</cfoutput>	

<cfset EFTInfo = oEFTAllServices.getEFTAllInfo(acctperiod=thisdate,showall=showall,days=days,strtday=strtday,endday=endday)>
  
<cfset delim = 44>  
	<!---
		<cfset destFilePath = getTempDirectory() & "\EFT">
	--->
<cfoutput>
	<cfset TempFile =  #destFilePath# & "\" & #filename#  & ".csv"  >
	<cfset QueryOutput = CreateObject("java","java.lang.StringBuffer").Init() >
 	<cfset QueryOutput.Append("House Name#chr(delim)#Tenant Name#chr(delim)#Solomon Key#chr(delim)#EFTAccount_ID#chr(delim)#RoutingNumber#chr(delim)#Account_Number#chr(delim)#Day of First Pull#chr(delim)#First Pull Total Payment Amount#chr(delim)#Day of Second Pull#chr(delim)#Second Pull Total Payment Amount#chr(delim)# BeginEFTDate#chr(delim)#End EFT Date#chr(delim)#" & chr(13) & chr(10))>
	<cfset Queryid = -1 >
 	<cfloop  query="EFTinfo">	
		<cfif bDeferredPayment  is 1><cfset DeferredPymnt = "Y"><cfelse><cfset DeferredPymnt = ""></cfif> 
		<cfset TenantNames = replace(TenantName, "," ,"  ", "All" )>
		<cfset Emails = replace(Email, "," ," ", "All" )>
		<cfif eftuser is 1><cfset Thiseftuser = "Y"><cfelse><cfset Thiseftuser = "N"></cfif>
		<cfif IsPayer is 1><cfset ThisIsPayer = "Y"><cfelse><cfset ThisIsPayer = ""></cfif>
		<cfif IsPrimPayer is 1><cfset ThisIsPrimPayer = "Y"><cfelse><cfset ThisIsPrimPayer = ""></cfif>
		<cfif IsContactPayer is 1><cfset ThisIsContactPayer = "Y"><cfelse><cfset ThisIsContactPayer = ""></cfif>
		<cfif IsContactPrimPayer is 1><cfset ThisIsContactPrimPayer = "Y"><cfelse><cfset ThisIsContactPrimPayer = ""></cfif>
		<cfset qryInvAmt = oEFTAllServices.getInvAmt(solomonKey=eftinfo.cSolomonKey,acctPeriod=thisdate,All=1)>
	
		<cfif isDate(qryInvAmt.dtInvoiceStart) AND isDate(qryInvAmt.dtInvoiceEnd)>
			<cfset SolomonTotal = session.oSolomonServices.getSolomonTotal(custid=eftinfo.cSolomonKey,invoiceStart=qryInvAmt.dtInvoiceStart,invoiceEnd=qryInvAmt.dtInvoiceEnd).SolomonTotal>
			<cfset paOffset = session.oSolomonServices.getOffSet(custid=eftinfo.cSolomonKey,invoiceEnd=qryInvAmt.dtInvoiceEnd).paOffset>
		<cfelse>
			<cfset SolomonTotal = 0>
			<cfset paOffSet = 0>
		</cfif>
		
		<cfif qryInvAmt.mLastInvoiceTotal is ''>
			<cfset mLastInvoiceTotal = 0>
		<cfelse>
			<cfset mLastInvoiceTotal = qryInvAmt.mLastInvoiceTotal>
		</cfif>										
		<cfif qryInvAmt.TipsSum is ''>
			<cfset TipsSum = 0>
		<cfelse>
			<cfset TipsSum = qryInvAmt.TipsSum>
		</cfif>	
		
		<cfset sum = paOffset + SolomonTotal + mLastInvoiceTotal + TipsSum>
		<cfset netchgamt =0>	
		<cfset firstpaymntamt = 0>	
		<cfset secondpaymntamt = 0>								
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
 		<cfset tcsolomonkey = '`'&#csolomonkey#>
 		<cfset tcRoutingNumber = '`'&#cRoutingNumber#>
 		<cfset tCaCCOUNTnUMBER = '`'&#CaCCOUNTnUMBER#>
		<cfset QueryOutput.Append("#cHouseName##chr(delim)##TenantNames##chr(delim)##tcsolomonkey##chr(delim)##iEFTAccount_ID##chr(delim)##tcRoutingNumber##chr(delim)##tCaCCOUNTnUMBER##chr(delim)##iDayofFirstPull##chr(delim)##firstpaymntamt##chr(delim)##iDayofSecondPull##chr(delim)##secondpaymntamt##chr(delim)##dtBeginEFTDate##chr(delim)##dtEndEFTDate##chr(delim)#"  & chr(13) & chr(10))>	 
	</cfloop>
</cfoutput>
<cfoutput>
	<cffile action="write" file="#TempFile#" output="#QueryOutput.ToString()#">
</cfoutput>
<div><cfoutput>File Created at: #destFilePath#\#filename#.csv :: #TempFile#</cfoutput></div>		  