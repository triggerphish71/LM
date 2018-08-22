<!----------------------------------------------------------------------------------------------
| DESCRIPTION   KeyChange.cfm                                                                    |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| Parameter Name   																			   |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                     												   |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| mlaw       | 01/24/2007 | Create Flower Box                                                  |
| mlaw       | 01/24/2007 | Remove mlaw@alcco.com                                              |
----------------------------------------------------------------------------------------------->
<!--- ==============================================================================
Include intranet header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../header.cfm">

<CFTRY>
	<CFSTOREDPROC PROCEDURE="rw.sp_SolomonKeyChange" DATASOURCE="#APPLICATION.datasource#">
		<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_CHAR" DBVARNAME="@oldSolomonKey" VALUE="#form.cSolomonKey#" NULL="No">
		<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_CHAR" DBVARNAME="@newSolomonKey" VALUE="#form.AssociateTo#" NULL="No">	
		<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_BIT" DBVARNAME="@bCommitChanges" VALUE="1" NULL="No">	
		<CFPROCRESULT NAME="KeyResults" resultset="1">
	</CFSTOREDPROC>
	
	<CFCATCH TYPE="Any">
		<CFMAIL TYPE ="html" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" SUBJECT="STOREDPROC STATUS CODE ERROR">
			#SESSION.qSelectedHouse.iHouse_ID#<BR>
			Error in rw.sp_SolomonKeyChange<BR>
			<CFIF isDefined("session.fullname")>#SESSION.fullname#</CFIF>
			<CFIF isDefined("form.csolomonkey") AND isDefined("form.AssociateTo")> from key #form.cSolomonKey# to #form.AssociateTo#</CFIF>
			#server_name#<BR>
			____________________________________________________
		</CFMAIL>	
	</CFCATCH>
	
</CFTRY>
	
<CFOUTPUT>
	<CFIF IsDefined("KeyResults.cMessage")>
		<BR><BR>
		<TABLE>
			<TR><TH>Key Change Result Summary</TH></TR>
			<CFLOOP QUERY="KeyResults">
				<TR><TD>#KeyResults.cMessage#</TD></TR>
			</CFLOOP>
			<TR>
				<TD STYLE="text-align: center; font-size: 18;">
					<INPUT TYPE="Button" NAME="Redirect" VALUE="Click Here To Continue" onClick="location.href='#HTTP_REFERER#'" STYLE="color: blue;">
				</TD>
			</TR>
		</TABLE>
	<CFELSE>
		<CFIF SESSION.UserID EQ 3025>
			<A HREF="#HTTP_REFERER#"> Continue </A>
		<CFELSE>
			<CFLOCATION URL="#HTTP_REFERER#">
		</CFIF>
	</CFIF>
</CFOUTPUT>
<!--- ==============================================================================
Include intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">

