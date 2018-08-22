
<CFOUTPUT>
<!---- create order by variable --->
<CFSCRIPT>
	if (IsDefined("url.sort") AND url.Sort EQ 'Description') { orderby="ORDER BY cDescription, cGLAccount"; }
	else if (IsDefined("url.sort") AND url.Sort EQ 'GLAccount') { orderby="ORDER BY cGLAccount, cDescription"; }
	else { orderby="ORDER BY cDescription, cGLAccount"; }
</CFSCRIPT>
<!--- ==============================================================================
Retreive all entries from the ChargeType Table that have not been deleted
=============================================================================== --->
<CFQUERY NAME = "ChargeTypes" DATASOURCE = "#APPLICATION.datasource#">
	SELECT 	iChargeType_ID ,cDescription ,cGLAccount ,bIsOpsControlled
			,bIsModifiableDescription ,bIsModifiableAmount ,bIsModifiableQty
			,bIsPrePay ,bIsDeposit ,bOccupancyPosition ,bResidencyType_ID
			,biHouse_ID ,bAptType_ID ,bSLevelType_ID ,iRowStartUser_ID ,dtRowStart
	FROM ChargeType WHERE dtRowDeleted IS NULL #orderby#
</CFQUERY>

<CFQUERY NAME="qCurrentInvoices" DATASOURCE="#APPLICATION.datasource#">
	select distinct inv.ichargetype_id
	from invoicedetail inv
	join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id 
	and im.dtrowdeleted is null and im.bfinalized is null
	and inv.dtrowdeleted is null
	and im.cappliestoacctperiod >= '#DateFormat(now(),"yyyymm")#'		
</CFQUERY>

<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">

<H1	CLASS="PAGETITLE"> Charge Type Administration </H1>
<HR>

<A Href="../../Admin/Menu.cfm" style="Font-size: 14;">Click Here to Go Back To Administration Screen.</a>
<BR><BR>

<A HREF="ChargeTypeEdit.cfm?Insert=1" CLASS="Summary"> Create New Charge Type </A>
<TABLE>
	<TH COLSPAN = "4">	Current Charge Types </TH>
	
	<TR STYLE = "text-align: center;">
		<TD STYLE="font-weight: bold;"> <A HREF="ChargeType.cfm?sort=Description">Description</A> </TD>
		<TD STYLE="font-weight: bold;"> <A HREF="ChargeType.cfm?sort=GLAccount">GLAccount</A></TD>
		<TD></TD>
		<TD STYLE="font-weight: bold;"> Delete </TD> 
	</TR>
	<CFLOOP QUERY="ChargeTypes">
		<TR>
			<TD> 
				<A HREF = "ChargeTypeEdit.cfm?ID=#ChargeTypes.iChargeType_ID#">	
					#ChargeTypes.cDescription#	<CFIF ChargeTypes.bIsDeposit NEQ "">(Deposit)</CFIF>
				</A> 
			</TD>
			<TD STYLE = "text-align: center;">	#ChargeTypes.cGLAccount# </TD>
			<TD></TD>
		<!--- ==============================================================================
				Check for associated Charges to this Charge Type.
				If Charges exist display message to deleted charges first
		=============================================================================== --->
		<CFQUERY NAME = "ChargeCheck" DATASOURCE = "#APPLICATION.datasource#">
			select count(icharge_id) as counter from Charges C left join house h on h.ihouse_id = c.ihouse_id and h.dtrowdeleted is null
			WHERE c.iChargeType_ID = #ChargeTypes.iChargeType_ID# AND c.dtRowDeleted IS NULL
			and getdate() between c.dteffectivestart and c.dteffectiveend
		</CFQUERY>		
	
		<CFQUERY NAME="qCurrentCheck" DBTYPE="QUERY">
			select count(iChargeType_id) as counter from qcurrentinvoices where ichargetype_id = #ChargeTypes.iChargeType_ID#		
		</CFQUERY>
		<CFIF ChargeCheck.counter EQ 0 AND qCurrentCheck.counter EQ 0 AND ChargeTypes.cGLAccount NEQ 2211>
			<TD STYLE = "text-align: center;">
				<INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Now" onClick="self.location.href='DeleteChargeType.cfm?typeID=#ChargeTypes.iChargeType_ID#'">
			</TD>
		<CFELSE>
			<TD STYLE="text-align: left; color: red;">
				All associated charges must be deleted first.<BR>
				<!---
				<CFIF SESSION.UserID IS 3025> <INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" VALUE="Admin. Delete" onClick="self.location.href='DeleteChargeType.cfm?typeID=#ChargeTypes.iChargeType_ID#'"> </CFIF>
				--->
			</TD>
		</CFIF>
		</TR>
	
	</CFLOOP>
</TABLE>
<BR>


<A Href="../../Admin/Menu.cfm" style="Font-size: 18;">Click Here to Go Back To Administration Screen.</a>
</CFOUTPUT>

<!--- ==============================================================================
Include Intranet Footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../footer.cfm">