
<CFQUERY NAME = "DepositTypeTable"	DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	DEPOSITTYPE
	WHERE	dtRowDeleted is null
	ORDER BY cDepositTypeSet, bIsFee, mAmount desc
</CFQUERY>



<!--- =============================================================================================
Include the intranet header
============================================================================================= --->
<CFINCLUDE TEMPLATE = "../../../header.cfm">
<H1	CLASS = "PAGETITLE">Deposit Type Administration</H1>
<HR>
<BR>
	<A HREF = "DepositTypeEdit.cfm?Insert=1" CLASS = "Summary">	Create New Deposit	</A>
<BR><BR>

<TABLE STYLE = "width: 800;">

<TH>	Last Changed	</TH>
<TH>	Category		</TH>
<TH>	Description		</TH>
<TH>	Amount			</TH>
<TH>	Display <BR> Order	</TH>		
<TH>	Refundable		</TH>
<TH STYLE="width: 25%;"> Comments </TH>
<TH> Delete	</TH>


<CFOUTPUT QUERY="DepositTypeTable" STARTROW="1" MAXROWS="#DepositTypeTable.RecordCount#">
	<TR STYLE = "text-align: center;">
		<TD> #DateFormat(DepositTypeTable.dtRowStart,"mm/dd/yyy")# </TD>
		<TD> #DepositTypeTable.cDepositTypeSet# </TD>
		<TD STYLE = "text-align: left;">
			<A HREF = "DepositTypeEdit.cfm?typeID=#DepositTypeTable.iDepositType_ID#">	
				#DepositTypeTable.cDescription#
			</A>
		</TD>
		
		<TD STYLE = "text-align: right;">
			#LSCurrencyFormat(DepositTypeTable.mAmount)#
		</TD>
		
		<TD>
			#DepositTypeTable.iDisplayOrder#
		</TD>
	
		<TD>
			<CFIF DepositTypeTable.bIsFee GTE 1>	No		<CFELSE>	Yes	</CFIF>
		</TD>				
		
		<TD>
			#DepositTypeTable.cComments#
		</TD>
		
		<TD>
			<INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Now" onClick="self.location.href='DeleteDepositType.cfm?typeID=#DepositTypeTable.iDepositType_ID#'">
		</TD>		
	</TR>
</CFOUTPUT>
</TABLE>
<BR>
<BR>
<CFOUTPUT>
	<A Href="../../Admin/Menu.cfm" style="Font-size: 18;">Click Here to Go Back To Administration Screen.</a>
</CFOUTPUT>
<!--- =============================================================================================
Include the intranet footer
============================================================================================= --->
<CFINCLUDE TEMPLATE = "../../../footer.cfm">
