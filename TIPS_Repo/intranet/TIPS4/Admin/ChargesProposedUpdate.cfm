
<CFOUTPUT>
<CFSET DSN='TIPS4'>

<CFLOOP INDEX=I LIST="#form.fieldnames#">
	<CFTRANSACTION>
		<!--- ==============================================================================
		Create New Master Record
		=============================================================================== --->
		<CFIF LEFT(I, 4) EQ 'Care'>
			<CFSET cType = 'Care'>
			<CFSET iRecord_ID = MID(I, 6, LEN(I)-5)>
			<CFSET mAmount = Evaluate('Form.Care_' & iRecord_ID)>
			Type: #cType#, LevelID: #iRecord_ID#, Amount: #mAmount#
		</CFIF>
		<CFIF LEFT(I, 4) EQ 'Room'>
			<CFSET cType = 'Rent'>
			<CFSET iRecord_ID = MID(I, 6, LEN(I)-5)>
			<CFSET mAmount = Evaluate('Form.Room_' & iRecord_ID)>
			Type: #cType#, AptTypeID: #iRecord_ID#, Amount: #mAmount#
		</CFIF>
		<CFIF LEFT(I, 8) EQ 'Discount'>
			<CFSET cType = 'Tenant'>
			<CFSET iRecord_ID = MID(I, 10, LEN(I)-9)>
			<CFSET mAmount = Evaluate('Form.Discount_' & iRecord_ID)>
			<CFSET mAmount = mAmount * -1>
			Type: #cType#, AptTypeID: #iRecord_ID#, Amount: #mAmount#
		</CFIF>
		<CFIF LEFT(I, 4) EQ 'Care' OR LEFT(I, 4) EQ 'Room' OR LEFT(I, 8) EQ 'Discount'>
			<cfstoredproc procedure="sp_ChargesProposedUpdate" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">
			  <cfprocparam type="IN" value="#SESSION.qSelectedHouse.iHouse_ID#" DBVARNAME="@iHouse_ID" cfsqltype="CF_SQL_INTEGER">
			  <cfprocparam type="IN" value="#cType#" DBVARNAME="@cType" cfsqltype="CF_SQL_CHAR">
			  <cfprocparam type="IN" value="#iRecord_ID#" DBVARNAME="@iRecord_ID" cfsqltype="CF_SQL_INTEGER">
			  <cfprocparam type="IN" value="#mAmount#" DBVARNAME="@mAmount" cfsqltype="CF_SQL_MONEY">
			  <cfprocparam type="IN" value="#SESSION.UserID#" DBVARNAME="@iUser_ID" cfsqltype="CF_SQL_INTEGER">
			  <cfprocparam type="OUT" variable=iReturn DBVARNAME="@iReturn" cfsqltype="CF_SQL_INTEGER">
			</cfstoredproc>
			; RETURNS: #iReturn#<BR>
		</CFIF>
	</CFTRANSACTION>	
</CFLOOP>


<CFIF REMOTE_ADDR EQ '10.1.0.218'>
	<A NAME="start" HREF="ChargesProposed.cfm">Continue</A>
<CFELSE>
	<CFLOCATION URL="ChargesProposed.cfm" ADDTOKEN="No">
</CFIF>

</CFOUTPUT>