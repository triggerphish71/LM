<!----------------------------------------------------------------------------------------------
| DESCRIPTION   PDClose.cfm                                                                    |
|----------------------------------------------------------------------------------------------| 
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------| 
|Ganga Thota | 09/20/2017 | Created for missing houses notification                            |
|ganga       |04/05/2018  | Added is not null to isAssetClass                                  |
----------------------------------------------------------------------------------------------->
<CFINCLUDE TEMPLATE="../../header.cfm">
<H1 CLASS="PageTitle"> Tips 4 - Administrative Tasks </H1>

<!---
<cfset now = #now()#>
<cfset month = #MonthAsString(Month(Now()))#>
<cfset month1 = #MonthAsString(Month(Now())+1)#>
--->

<!--- <CFIF #housemonth# NEQ #month1# > --->


<!---   Ganga Thota finding missing houses in the region         --->
 <CFQUERY NAME = "qmissinghouse" DATASOURCE = "#APPLICATION.datasource#">
		SELECT iHouse_ID,iOpsArea_ID,cName,dtAcctStamp FROM House 
			WHERE ihouse_id not in (select ihouse_id from houseClose_audit where iopsArea_id = #iOpsArea_id#)
			and dtrowdeleted is null AND iopsArea_id = #iOpsArea_id# 
			<!--- ganga 4/5/18 --->
			 AND AssetClass is not null
			 and bisSandbox = 0 
			 <!---- end ganga --->
	</CFQUERY>
 <cfif qmissinghouse.RecordCount GT 0>
 <cfset email = #session.username# >
 
   <CFMAIL TYPE="html" FROM="TIPS4-HouseClosing@Enlivant.com" to = "#email#@enlivant.com" cc="gthota@enlivant.com" SUBJECT="The region close missing houses.">
	  	<TABLE style="width:500" border ="2">
	
		<TR bgcolor ="DarkCyan">	
		 <td>&nbsp; House Id's &nbsp;</td>
		 <td>&nbsp; House Names &nbsp;</td>
		 <td>&nbsp; Region Name &nbsp;</td>
		 <td>&nbsp; Closing Period &nbsp;</td>
		  <td>&nbsp;  &nbsp;</td>			
		 </TR>
		 <cfloop query ='qmissinghouse'> 	 	
			<TR>
			<td>#iHouse_id# </td>					
			<td> #cName# </td>
			<CFQUERY NAME = "qregion" DATASOURCE = "#APPLICATION.datasource#">
				SELECT	cname FROM OpsArea
			    WHERE iOpsArea_ID = #iOpsArea_ID# AND dtRowDeleted IS NULL
			</CFQUERY>
			<TD>#qregion.cname# </TD>
			<TD>#month1# </TD>
			<TD>Pending </TD>		
			</TR>		
		 </cfloop>	
		</TABLE>
		____________________________________________________
	</CFMAIL>
<CFELSE>
 <CFOUTPUT>
<CFQUERY NAME = "qname" DATASOURCE = "#APPLICATION.datasource#">
		SELECT cName FROM OpsArea WHERE  iopsArea_id = #iOpsArea_id#
</CFQUERY>
	<CENTER>
	<A HREF="http://#server_name#/intranet/tips4/admin/rdoClose_mainpage.cfm">
	<P STYLE="color: red; font-size: medium;">	
	#qname.cname# Region Communities has been already closed for:</font><font size ="5" color ="slateblue">&nbsp;&nbsp; </font>&nbsp;<BR>#DateFormat(SESSION.TIPSMonth,"mm/yyyy")#<br><br/>
		
	<B>Click Here to Continue</B>
	</P>
	</A>
	</CENTER>
	<CFABORT>
</CFOUTPUT>	
 </cfif>

<CFOUTPUT>
	<CENTER>
	<A HREF="http://#server_name#/intranet/tips4/mainmenu.cfm">
	<P STYLE="color: red; font-size: medium;">
	Email sent to your Enlivant id about TIPS invoice close<br/>
	Missing houses Information <BR>	
	<B>Click Here to Continue</B>
	</P>
	</A>
	<CFLOCATION URL='http://#server_name#/intranet/TIPS4/admin/rdoClose_mainpage.cfm' addtoken="no">
	</CENTER>
	
</CFOUTPUT>


<!--- ==============================================================================
Return to Administration Page
=============================================================================== --->
<CFLOCATION URL="../MainMenu.cfm" ADDTOKEN="yes">
