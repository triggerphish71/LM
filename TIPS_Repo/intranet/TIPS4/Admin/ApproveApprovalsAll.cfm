<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!--- 
|Sfarmer     |01/27/2017  | Create report of items being updated in Invoices   |
 --->
<!---  <cfoutput><cfdump var="#form#"></cfoutput>
 <cfabort> --->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>CustomerTrialBalanceReport</title>
</head>
 
<CFOUTPUT>
Process begin  time #CreateODBCDateTime(Now())#<br />
<CFSET rowlist=''>
<CFLOOP INDEX=A LIST='#form.fieldnames#'>
	<CFSCRIPT>
		if (findnocase("row_",A,1) gt 0) { rowlist=listappend(rowlist,gettoken(A,2,"_"),","); }
	</CFSCRIPT>
</CFLOOP>
<!---   #rowlist#  #findnocase("row_",A,1)# A #A# form.fieldnames #form.fieldnames#<BR>
test  --->  
<body>
<cfdocument  format="PDF" orientation="portrait" margintop="1" marginbottom="1" marginleft=".5" marginright=".5">
	<cfdocumentitem type="header"  evalAtPrint="true">  
		<cfoutput>
			<table width="100%">
				<tr>
					<td style="text-align:left;"> <img src="../images/Enlivant_logo.jpg" width="115" height="75" ></td>
					<td align="center">
						<h3 style="text-align:center;">Approved Selected BSF and Care Changes</h3>
					</td>
					<td  nowrap="nowrap" style="text-align:right;">Date: <br />#dateformat(now(),'mm/dd/yyyy')#</td>
				</tr>
			</table>
		</cfoutput>
	</cfdocumentitem>
<table>
<tr>
<th>Row</th>
<!--- <th>SubmitChoice</th> --->
<th>House</th>
<th>InvoiceMasterID</th>
<th>TenantID</th>
<th>ChargeTypeID</th>
<th>Description</th>
<th>Action</th>
<th>AppliestoAcctPeriod</th>
<th>New Quantity</th>
<th>Old Quantity</th>
<th>New Amount</th>
<th>Old Amount</th>
<th>Comments</th>
<th>NewDetailID</th>
<th>OldDetailID</th>
<!--- <th>HouseID</th> --->
<th>AcctStamp</th>
</tr>

<CFLOOP INDEX=B LIST='#rowlist#'>
<!---  <CFLOOP INDEX=C LIST='#form.fieldnames#'>  --->
 	<!--- <CFIF(gettoken(C,2,"_") eq B)>  --->
 				<tr>	<td>#B#</td>
					 <!--- <td> #SUBMITCHOICES#</td> --->
					 <td> #evaluate("House_" & B)#</td>
					<td> #evaluate("invoicemasterid_" & B)#</td>
					<td>#evaluate("itenantid_" & B)#</td>
					<td>#evaluate("ichargetypeid_" & B)#</td>
					<td>#evaluate("description_" & B)#</td>
					<td>#evaluate("Action_" & B)#</td>
					<td>#evaluate("cappliestoacctperiod_" & B)#</td>
					<td>#evaluate("inewquantity_" & B)#</td>
					<td> #evaluate("ioldQuantity_" & B)#</td>
					<td> #evaluate("mnewamount_" & B)#</td>
					<td> #evaluate("moldamount_" & B)#</td>
					<td>#evaluate("comments_" & B)#</td>
					<td>#evaluate("newdetailID_" & B)# </td>
					<td>#evaluate("OldDetailID_" & B)# </td>
					<td>#dateformat(SESSION.AcctStamp,'yyyy-mm-dd')#</td></tr>
					<!--- <td>#SESSION.userid#</td> --->
				<!--- </CFIF>	 --->				
<!---  </CFLOOP> ---> 
</CFLOOP>
</table>	
	<cfdocumentitem type="footer"  evalAtPrint="true">
 		<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>
			<table width="100%">
			<tr>
				<td>Approved Selected BSF and Care Changes</td>
				<td style="text-align:center">Enlivant</td>
				<td style="text-align:right">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
			</tr>
			</table>
		<cfelse>
			<table width="100%">
			<tr>
				<td>Approved
				 Selected BSF and Care Changes</td>
				<td a style="text-align:center">Enlivant</td>
				<td style="text-align:right">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
			</tr>
			</table>		
		</cfif>
	</cfdocumentitem>

	<cfheader name="Content-Disposition"   
		value="attachment;filename=ApprovedSelectedBSFandCareChanges-#Now()#.pdf"> 
	
</cfdocument>			
<!--- 
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
<!--- 			<cfdump var="#result#">
			<cfdump var="#session#">
			<cfdump var="#form#"> --->
<!--- 			<cfoutput> time #CreateODBCDateTime(Now())# B #B# rowlist #rowlist#</cfoutput> --->
			</CFTRANSACTION>
		</CFIF>
	</CFIF>
	</CFLOOP>
	<BR>
</CFLOOP> --->
<!--- <CFIF 0 eq 1>
	<A HREF='#HTTP.REFERER#'>#HTTP.REFERER#</A>
<CFELSE>
	<CFLOCATION URL='#HTTP.REFERER#'>
</CFIF> --->
Process end time #CreateODBCDateTime(Now())#<br />
</body>
</CFOUTPUT>

</html>