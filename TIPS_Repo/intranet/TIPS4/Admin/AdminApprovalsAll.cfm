<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!--- 
|Sfarmer     |01/27/2017  | Create report of items being updated in Invoices   |
 --->

	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Admin Approval - LOC - BSF</title>
	</head>

<cfoutput>
	Process begin  time #CreateODBCDateTime(Now())#<br />
	<CFSET rowlist=''>
	<CFLOOP INDEX=A LIST='#form.fieldnames#'>
		<CFSCRIPT>
			if (findnocase("row_",A,1) gt 0) { rowlist=listappend(rowlist,gettoken(A,2,"_"),","); }
		</CFSCRIPT>
	</CFLOOP>
	<cfset ListCntSt = find('_',#A#) + 1>
	<cfset ListCnt = mid( #A#,#ListCntSt#,4) >
	<cfset thisdate = #now()#>
<!---
 hello - #ListCntSt#  / #ListCnt#  <br/>
 <A Href="../../../intranet/Tips4/admin/Menu.cfm" style="Font-size: 18;">Click Here to Go Back To Main Screen</a>
<cfabort>   --->





	<CFTRANSACTION>			
	<CFLOOP INDEX=B LIST='#rowlist#'>
		<CFLOOP INDEX=C LIST='#form.fieldnames#'>
		<CFIF(gettoken(C,2,"_") eq B)> 
			<CFIF(gettoken(C,1,"_") eq 'Action')>
 			<CFQUERY NAME='qAction' DATASOURCE='#APPLICATION.datasource#'result="result">
			INSERT INTO [dbo].[AccountingApprovalChanges]
           ([iAccountingPeriod]
           ,[cDivision]
           ,[cRegion]
           ,[cCommunityName]
           ,[cTenantName]
           ,[iTenant_id]
           ,[cSolomonkey]
           ,[iInvoicemaster_ID]
           ,[iChargetype_id]
           ,[cDescription]
           ,[cAction]
           ,[iNewQuantity]
           ,[iOldQuantity]
           ,[mNewAmount]
           ,[mOldAmount]
           ,[mNewAmtTotal]
           ,[cComments]
           ,[iNewDetailID]
           ,[iOldDetailID]
           ,[iHouse_id]
           ,[cAppliestoacctperiod]
           ,[dtRowStart]
           ,[dtRowEnd]
		   ,[dtentered]
		   ,[ienteredBy])
     	VALUES  
           (#isblank(evaluate("cappliestoacctperiod_" & B),'NULL')#
           ,'#evaluate("cDivision_" & B)#' 
           ,'#evaluate("cRegion_" & B)#' 
           ,'#evaluate("House_" & B)#'
		   ,'#evaluate("cTenantName_" & B)#'
           ,#isblank(evaluate("itenantid_" & B),'NULL')#
           ,'#evaluate("cSolomonKey_" & B)#'
           ,#isblank(evaluate("invoicemasterid_" & B),'NULL')#
           ,#isblank(evaluate("ichargetypeid_" & B),'NULL')#
           ,'#isblank(evaluate("description_" & B),'NULL')#'
           ,'#evaluate("Action_" & B)#'
           ,#isblank(evaluate("iNewQuantity_" & B),'NULL')#
           ,#isblank(evaluate("iOldQuantity_" & B),'NULL')#
           ,#isblank(evaluate("mNewAmount_" & B),'NULL')#
           ,#isblank(evaluate("mOldAmount_" & B),'NULL')#
           ,#evaluate("newamount_" & B)#
           ,'#evaluate("comments_" & B)#'
           ,#isblank(evaluate("newdetailid_" & B),'NULL')#
           ,#isblank(evaluate("olddetailid_" & B),'NULL')#
           ,#isblank(evaluate("iHouseid_" & B),'NULL')#
           ,'#isblank(evaluate("cappliestoacctperiod_" & B),'NULL')#'
           ,'#isblank(evaluate("dtRowStart_" & B),'NULL')#'
           ,#isblank(evaluate("dtRowEnd_" & B),'NULL')#
			,#thisdate#
			,#session.userid#)
		 </CFQUERY> 

			</CFIF>
		</CFIF>
		</CFLOOP>
	</CFLOOP>  	
	</CFTRANSACTION>		
 
	<CFLOOP INDEX=B LIST='#rowlist#'>
		<CFLOOP INDEX=C LIST='#form.fieldnames#'>
		<CFIF(gettoken(C,2,"_") eq B)> 
			<CFIF(gettoken(C,1,"_") eq 'Action')>
				<CFTRANSACTION>
				<CFQUERY NAME='qAction' DATASOURCE='#APPLICATION.datasource#'result="result">
				 <CFSWITCH expression="#evaluate(c)#">
					<CFCASE VALUE='Remove'>
						rw.sp_EOM4 
						@iInvoiceMaster_ID=#isblank(evaluate("invoicemasterid_" & B),'NULL')#
						,@iInvoiceDetail_ID=#isblank(evaluate("olddetailid_" & B),'NULL')#
						,@iTenant_ID=#isblank(evaluate("itenantid_" & B),'NULL')#
						,@iChargeType_ID=#isblank(evaluate("ichargetypeid_" & B),'NULL')#
						,@cDescription='#isblank(evaluate("description_" & B),'NULL')#'
						,@cAction='Remove'
						,@mAmount=#isblank(evaluate("mnewamount_" & B),'NULL')#
						,@iQuantity=#isblank(evaluate("ioldquantity_" & B),'NULL')#
						,@cAppliesToAcctPeriod=#isblank(evaluate("cappliestoacctperiod_" & B),'NULL')# 
						,@cComments='#isblank(evaluate("comments_" & B),'NULL')#'
						,@dtAcctStamp='#SESSION.AcctStamp#'
						,@iRowUser=#SESSION.userid#
						,@bCommitChanges = 1
						<!---,@iDaysbilled='#isblank(evaluate("iDaysbilled" & B),'NULL')#'--->
					</CFCASE>
					
					<CFCASE VALUE='Changed'>
						rw.sp_EOM4 
						@iInvoiceMaster_ID=#isblank(evaluate("invoicemasterid_" & B),'NULL')#
						,@iInvoiceDetail_ID=#isblank(evaluate("olddetailid_" & B),'NULL')#
						,@iTenant_ID=#isblank(evaluate("itenantid_" & B),'NULL')#
						,@iChargeType_ID=#isblank(evaluate("ichargetypeid_" & B),'NULL')#
						,@cDescription='#isblank(evaluate("description_" & B),'NULL')#'
						,@cAction='Changed'
						,@mAmount=#isblank(evaluate("mnewamount_" & B),'NULL')#
						,@iQuantity=#isblank(evaluate("inewquantity_" & B),'NULL')#
						,@cAppliesToAcctPeriod=#isblank(evaluate("cappliestoacctperiod_" & B),'NULL')# 
						,@cComments='#isblank(evaluate("comments_" & B),'NULL')#'
						,@dtAcctStamp='#SESSION.AcctStamp#'
						,@iRowUser=#SESSION.userid#
						,@bCommitChanges = 1
						<!---,@iDaysbilled='#isblank(evaluate("iDaysbilled" & B),'NULL')#'--->
					</CFCASE>
						
					<CFCASE VALUE='Add'>
						rw.sp_EOM4 
						@iInvoiceMaster_ID=#isblank(evaluate("invoicemasterid_" & B),'NULL')#
						,@iInvoiceDetail_ID=#isblank(evaluate("olddetailid_" & B),'NULL')#
						,@iTenant_ID=#isblank(evaluate("itenantid_" & B),'NULL')#
						,@iChargeType_ID=#isblank(evaluate("ichargetypeid_" & B),'NULL')#
						,@cDescription='#isblank(evaluate("description_" & B),'NULL')#'
						,@cAction='Add'
						,@mAmount=#isblank(evaluate("mnewamount_" & B),'NULL')#
						,@iQuantity=#isblank(evaluate("inewquantity_" & B),'NULL')#
						,@cAppliesToAcctPeriod=#isblank(evaluate("cappliestoacctperiod_" & B),'NULL')# 
						,@cComments='#isblank(evaluate("comments_" & B),'NULL')#'
						,@dtAcctStamp='#SESSION.AcctStamp#'
						,@iRowUser=#SESSION.userid#
						,@bCommitChanges = 1
						<!---,@iDaysbilled='#isblank(evaluate("iDaysbilled" & B),'NULL')#'--->
					</CFCASE>
				</CFSWITCH>
				</CFQUERY>
	<!--- 			<cfoutput> time #CreateODBCDateTime(Now())# B #B# rowlist #rowlist#</cfoutput> --->
				</CFTRANSACTION>
			</CFIF>
		</CFIF>
		</CFLOOP>
		<BR>
	</CFLOOP>   

		<cfcontent type="text/html" />
 		<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		<html>
			<head>
				<title>Approvals</title>
			</head>
			<body>  
<!--- 				<form action="AdminApprovalPrint.cfm"  name="printRpt" id="printRpt"method="post">
				<table width="100%" align="center">

					<CFLOOP INDEX=B LIST='#rowlist#' >
					<input type="hidden" name="row_#B#" value='#evaluate("row_" & B)#' />
						<input type="hidden" name="cDivision_#B#" value='#evaluate("cDivision_" & B)#' />
						<input type="hidden" name="cRegion_#B#" value='#evaluate("cRegion_" & B)#' / >
						<input type="hidden" name="House_#B#" value='#evaluate("House_" & B)#' />
						<input type="hidden" name="cTenantName_#B#" value='#evaluate("cTenantName_" & B)#' />
						<input type="hidden" name="cSolomonKey_#B#" value='#evaluate("cSolomonKey_" & B)#' />
						<input type="hidden" name="description_#B#" value='#evaluate("description_" & B)#' />
						<input type="hidden" name="Action_#B#" value='#evaluate("Action_" & B)#' />
						<input type="hidden" name="newamount_#B#" value='#evaluate("newamount_" & B)#' />
						<input type="hidden" name="comments_#B#" value='#evaluate("comments_" & B)#' />
						<input type="hidden" name="cappliestoacctperiod_#B#" value='#evaluate("cappliestoacctperiod_" & B)#' />
					</CFLOOP>
					<input type="hidden" name='row' value = '#listcnt#' />
					<tr>
						<td style="text-align:center">
						Approval Update Complete<br />
						To view report click 'View Report' Button<br />
						Or Close this tab to return to Main Screen
						</td>
					</tr>
		 			<tr>
						<td style="text-align:center"><input  type="submit" name="Print Report" value="View Report" /></td>
					</tr> 
				</table>
				</form> --->
				<cflocation url="AdminApprovals.cfm">
			</body>
		</html>  
	<!--- 	 	
	<script language="javascript1.1">
	//	window.open('AdminApprovals.cfm', '_blank');
	//	    var a = document.createElement("a");    
	// a.href = "AdminApprovals.cfm";    
	//window.open('AdminApprovals.cfm', '_blank'); 
	//  var evt = document.createEvent("MouseEvents");    
	//the tenth parameter of initMouseEvent sets ctrl key    
	//   evt.initMouseEvent("click", true, true, window, 0, 0, 0, 0, 0,true, false, false, false, 0, null);    
	//   a.dispatchEvent(evt);
	//	</script>
	 --->
</cfoutput>
</html>