
<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|--------------------------------------------------------------------------------------------------|
| INCLUDES                                                                                         |
|--------------------------------------------------------------------------------------------------|
|  none                                                                                            |
|--------------------------------------------------------------------------------------------------|
| HISTORY                                                                                          |
|--------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                            |
|------------|------------|------------------------------------------------------------------------|
| sfarmer    |  01/27/2017  | Select report period of items being updated in Invoices for Report   |
| mstriegel  |  01/05/2018  | Modified the display so that it uses the new columns from the sp     |
|                             Replaced the Solomon Key column header with Resident ID              |
--------------------------------------------------------------------------------------------------->
<head>
<META http-EQUIV="Pragma" CONTENT="no-cache">  
<META http-EQUIV="cache-control" CONTENT="no-cache, no-store, must-revalidate">
<META http-EQUIV="Expires" CONTENT="0">
<!--- 
|Sfarmer     |02/17/2017  | Create process for bulk approvals of items being updated in Invoices   |
 --->
<TITLE> Tips 4-Admin Approvals </TITLE>	

</head>
<CFINCLUDE TEMPLATE="../../header.cfm">
<cfinclude template="../Shared/JavaScript/ResrictInput.cfm">

<BODY>
<H1 CLASS="PageTitle"> Tips 4 - Accounting Approval Changes</H1>
<!---  <cfinclude template="../Shared/HouseHeader.cfm"> --->
<cfoutput>


<cfparam name="sortorder" default="">
 
	<cfstoredproc procedure="rw.sp_AssessmentApproval" 
		datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">	
        <cfprocparam type="IN" value="#sortorder#" DBVARNAME="@sortorder"  cfsqltype="CF_SQL_VARCHAR">		
		<cfprocresult NAME="MidMonth" resultset="1">
		<cfprocparam type="OUT" variable=iCnt DBVARNAME="@iChangeCount" cfsqltype="CF_SQL_INTEGER">
	</cfstoredproc>
 


<!--- Retrieve House Month Information--->
<CFQUERY NAME = "HouseLog" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	bIsPDClosed, bIsCentralized,dtCurrentTipsMonth FROM HouseLog WITH (NOLOCK)
    WHERE iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# AND dtRowDeleted IS NULL
</CFQUERY>


<cfoutput>
	<cfset tipsmonth = #dateformat(HouseLog.dtCurrentTipsMonth,'yyyymm')#>

	<FORM ACTION='AdminApprovalsAll.cfm' METHOD='POST' name="AdminApproval" id="AdminApproval" >
	<TABLE STYLE="text-align: right; width:90%">
		<TR>
			<td  colspan="2"STYLE='text-align:left;'>#now()#</td>
			<TD  colspan="8" STYLE='text-align:center;'>
				<INPUT TYPE='submit' NAME='SubmitChoices' VALUE='Approve Selected Changes'>
			</TD>
			<!--- Gthota 10/06/2017 Added to display recordcount on page  --->	
			<td colspan="2">           
	              <Cfif #midmonth.Recordcount# EQ 0> 
	                  <font color ="red"><b> - No records - </b></font>				    
				  <cfelseif #midmonth.Recordcount# LT 100> 
				     <font color ="red"><b>Your selected 1-#midmonth.Recordcount# of #midmonth.Recordcount#</b></font>
				  <cfelseif #midmonth.Recordcount# GT 100>
				      <font color ="red"><b>Your selected 1-100 of #midmonth.Recordcount#</b></font>   
				  </cfif> 	
			</td>
		<!--- Gthota - Rcordcount code END  --->
			<td colspan="2">&nbsp;</td>
		</TR>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td colspan="8" align="center">
				<a href="AdminApprovalPrint.cfm?SelPeriod=#tipsmonth#">
				View Report for #dateformat(HouseLog.dtCurrentTipsMonth,'yyyymm')#
				</a>
			</td>
			<td colspan="2">&nbsp;</td>			
		</tr>
		
		<TR>
			<th NOWRAP STYLE="text-align:left;"> Trx </th>
<!--- 			<th NOWRAP STYLE="text-align:left;" >
				<a href="AdminApprovals.cfm?sortorder=Division"  
				STYLE="color: white;"  
				onMouseOver="hoverdesc('Sort by Chargetype');" 
				onMouseOut="resetdesc();">Division</A>
			</th> --->	
			<th NOWRAP STYLE="text-align:left;">Division</th>			
			<th NOWRAP STYLE="text-align:left;">Region</th>							
			<th NOWRAP STYLE="text-align:left;">Community</th>			
			<th NOWRAP STYLE="text-align:left;">Resident</th>
			<!--- mstriegel 01/05/18 ---->
			<th NOWRAP STYLE="text-align:left;">Resident Id</th>
			<!--- end mstriegel --->
<!--- 			<th NOWRAP STYLE="text-align:left;">
				<a href="AdminApprovals.cfm?sortorder=chargetype" 
				STYLE="color: white;"  
				onMouseOver="hoverdesc('Sort by Chargetype');" 
				onMouseOut="resetdesc();">Charge Type Description</A>
			</th> --->
			<th NOWRAP STYLE="text-align:left;">Charge Type Description</th>				
			<th NOWRAP STYLE="text-align:left;">Daily Rate</th>			
			<th NOWRAP STYLE="text-align:left;">New Qty</th>
			<th NOWRAP STYLE="text-align:left;">New Amt</th>
			<th NOWRAP STYLE="text-align:left;">Period</th>
			<th NOWRAP STYLE="text-align:left;">Action</th>
		</TR>
        
		<CFLOOP QUERY="MidMonth" >
	<!---	<Cfif #midmonth.currentrow# LT 101 and #MidMonth.cDisplayDescription# NEQ ''>  ---><!--- Ganga added to exclude null description --->
	<Cfif #midmonth.currentrow# LT 101>
			<CFSCRIPT>
				backcolor='';
				if (MidMonth.RecordCount GT 2) {
					if (Evaluate(MidMonth.currentRow MOD 2) EQ 1) { backcolor="STYLE='background: white;'"; }
				}
			</CFSCRIPT>

			<INPUT TYPE='hidden' NAME='house_#midmonth.currentrow#' 			VALUE='#midmonth.cname#'>
			<INPUT TYPE='hidden' NAME='cTenantName_#midmonth.currentrow#' 		VALUE='#midmonth.cTenantName#'>			
			<INPUT TYPE='hidden' NAME='invoicemasterid_#midmonth.currentrow#' 	VALUE='#midmonth.iInvoiceMaster_ID#'>
			<INPUT TYPE='hidden' NAME='cSolomonKey_#midmonth.currentrow#' 		VALUE='#midmonth.cSolomonKey#'>
			<INPUT TYPE='hidden' NAME='ichargetypeid_#midmonth.currentrow#' 	VALUE='#midmonth.ichargetype_ID#'>
			<INPUT TYPE='hidden' NAME='description_#midmonth.currentrow#' 		VALUE='#midmonth.cdescription#'>
			<INPUT TYPE='hidden' NAME='action_#midmonth.currentrow#' 			VALUE='#midmonth.caction#'>
			<INPUT TYPE='hidden' NAME='inewquantity_#midmonth.currentrow#' 		VALUE='#midmonth.inewquantity#'>
			<INPUT TYPE='hidden' NAME='ioldquantity_#midmonth.currentrow#' 		VALUE='#midmonth.ioldquantity#'>
			<INPUT TYPE='hidden' NAME='mnewamount_#midmonth.currentrow#' 		VALUE='#midmonth.mnewamount#'>
			<INPUT TYPE='hidden' NAME='moldamount_#midmonth.currentrow#' 		VALUE='#midmonth.moldamount#'>
			<INPUT TYPE='hidden' NAME='newamount_#midmonth.currentrow#' 		VALUE='#midmonth.newamount#'>
			<INPUT TYPE='hidden' NAME='comments_#midmonth.currentrow#' 			VALUE='#midmonth.ccomments#'>
			<INPUT TYPE='hidden' NAME='newdetailid_#midmonth.currentrow#' 		VALUE='#midmonth.newdetailid#'>
			<INPUT TYPE='hidden' NAME='olddetailid_#midmonth.currentrow#' 		VALUE='#midmonth.olddetailid#'>
 			<INPUT TYPE='hidden' NAME='iHouseid_#midmonth.currentrow#' 				VALUE='#midmonth.iHouse_ID#'> 
			<INPUT TYPE='hidden' NAME='cappliestoacctperiod_#midmonth.currentrow#' VALUE='#midmonth.cappliestoacctperiod#'>
 			<INPUT TYPE='hidden' NAME='dtRowStart_#midmonth.currentrow#' 			VALUE='#midmonth.dtRowStart#'> 
 			<INPUT TYPE='hidden' NAME='dtRowEnd_#midmonth.currentrow#' 				VALUE='#midmonth.dtRowEnd#'> 	
			<INPUT TYPE='hidden' NAME='cregion_#midmonth.currentrow#' VALUE='#midmonth.cregion#'>
			<INPUT TYPE='hidden' NAME='cdivision_#midmonth.currentrow#' VALUE='#midmonth.cdivision#'>
 			<INPUT TYPE='hidden' NAME='itenantid_#midmonth.currentrow#' VALUE='#midmonth.itenant_id#'> 
 			<TR>  <!--- <cfif #TRIM(MidMonth.cDisplayDescription)# NEQ ''> --->
				<TD #backcolor# STYLE="text-align: left">#midmonth.currentrow#
				<INPUT TYPE='checkbox' 
					NAME='row_#midmonth.currentrow#' VALUE='#midmonth.currentrow#' 
						checked onClick='approvebutton();'></TD>
				<TD #backcolor# NOWRAP STYLE="text-align: left">#MidMonth.cDivision#</TD>
				<TD #backcolor# NOWRAP STYLE="text-align: left">#MidMonth.cRegion#</TD>					
				<TD #backcolor# NOWRAP STYLE="text-align: left">#MidMonth.cName#</TD>
				<TD #backcolor# NOWRAP STYLE="text-align: left">#MidMonth.cTenantName#</TD>
				<TD #backcolor# STYLE="text-align: left">#MidMonth.cSolomonKey#</TD>
				<!--- mstriegel 01/05/18 ---->				
				<TD #backcolor# STYLE="text-align: left">#TRIM(MidMonth.cDisplayDescription)#</TD>				
				<!--- end mstriegel --->
				<TD #backcolor# style="text-align:left;" >#LSCurrencyFormat(MidMonth.mNewAmount)#</TD>				
				<TD #backcolor# style="text-align:left;">#MidMonth.inewquantity#</TD>
				<TD #backcolor# style="text-align:left;" >#LSCurrencyFormat(MidMonth.NewAmount)#</TD>
				<TD #backcolor# STYLE="text-align: left">#MidMonth.cAppliesToAcctPeriod#</TD>
				<TD #backcolor# NOWRAP STYLE="text-align: left">#MidMonth.cAction#</TD>
				<!--- </cfif> --->
			</TR>
			</cfif>
		</CFLOOP>

		<TR>
			<td  colspan="2"STYLE='text-align:left;'>&nbsp;</td>
			<TD  colspan="8" STYLE='text-align:center;'>
				<INPUT TYPE='submit' NAME='SubmitChoices' VALUE='Approve Selected Changes'>
			</TD>
			<td colspan="2">&nbsp;</td>
		</TR>
	</TABLE>
	</FORM>

 
	<BR>
	<A Href="../../../intranet/Tips4/MainMenu.cfm" style="Font-size: 18;">Click Here to Go Back To Main Screen</a>
</CFOUTPUT>

<SCRIPT>
function confirmbutton(){
   var strconfirm = confirm("I have reviewed current charges and this change will NOT create any duplicates");
		if (strconfirm == true)
            {
                return true;
            }
		else
		{ alert('Review that new charges do not create duplicates');
		return false;}
    }


function approvebutton() {

 	counter=0;
	for (t=0;t<=document.forms[0].elements.length-1;t++){
		if (document.forms[0].elements[t].checked == true) { counter=counter+1; }
	}
	if (counter == 0) { document.forms[0].SubmitChoices.disabled = true; }
	else { document.forms[0].SubmitChoices.disabled = false; }

}
</SCRIPT>

<CFINCLUDE TEMPLATE='../../Footer.cfm'>
</cfoutput>