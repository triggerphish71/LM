<CFOUTPUT>
<CFSET rowlist=''>
<CFLOOP INDEX=A LIST='#form.fieldnames#'>
	<CFSCRIPT>
		if (findnocase("row_",A,1) gt 0) { rowlist=listappend(rowlist,gettoken(A,2,"_"),","); }
	</CFSCRIPT>
</CFLOOP>

<CFLOOP INDEX=B LIST='#rowlist#'>
	<CFLOOP INDEX=C LIST='#form.fieldnames#'>
	<CFIF(gettoken(C,2,"_") eq B)> 
		<CFIF(gettoken(C,1,"_") eq 'Action')>
			<CFTRANSACTION>
		
			 <CFSWITCH expression="#evaluate(c)#">
				<CFCASE VALUE='Remove'>
				<CFQUERY NAME='qAction' DATASOURCE='#APPLICATION.datasource#'result="result">
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
				</CFQUERY>
				</CFCASE>
				
				<CFCASE VALUE='Changed'>
				<CFQUERY NAME='qAction' DATASOURCE='#APPLICATION.datasource#'result="result">
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
				</CFQUERY>
				</CFCASE>
					
				<CFCASE VALUE='Add'>
				<CFQUERY NAME='qAction' DATASOURCE='#APPLICATION.datasource#'result="result">
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
				</CFQUERY>
				</CFCASE>
			</CFSWITCH>
	

			</CFTRANSACTION>
		</CFIF>
	</CFIF>
	</CFLOOP>
	<BR>
</CFLOOP>
<CFIF 0 eq 1>
	<A HREF='#HTTP.REFERER#'>#HTTP.REFERER#</A>
<CFELSE>
	<CFLOCATION URL='#HTTP.REFERER#'>
</CFIF>
</CFOUTPUT>