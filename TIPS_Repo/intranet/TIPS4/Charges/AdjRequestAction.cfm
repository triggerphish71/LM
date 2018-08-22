<!----------------------------------------------------------------------------------------------
| DESCRIPTION   AdjRequestAction.cfm                                                           |
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
| mlaw       | 03/21/2006 | Create Flower Box                                                  | 
| mlaw       | 01/24/2007 | Remove mlaw@alcco.com                                              |
----------------------------------------------------------------------------------------------->
<CFOUTPUT>
#form.fieldnames#<BR>

<CFLOOP INDEX="N" LIST="#form.fieldnames#" DELIMITERS=","> <CFSET Temp = 'form.'> #Evaluate(Temp & N)# #N#<BR> </CFLOOP>

<!--- ==============================================================================
Error Handling for incorrect passing of Tenant ID
=============================================================================== --->
<CFIF NOT IsDefined("form.iTenant_ID")>
	An error has occurred.<BR> <A HREF="#HTTP.REFERER#">Please, re-try your request.</A>
	<CFABORT>
</CFIF>

<!--- ==============================================================================
Set variable for timestamp to record corresponding times for transactions
=============================================================================== --->
<CFQUERY NAME="GetDate" DATASOURCE="#APPLICATION.datasource#">
	SELECT	GetDate() as Stamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(GetDate.Stamp)>


<CFTRANSACTION>
	<CFTRY>
		<!--- ==============================================================================
		Retrieve Tenant Information
		=============================================================================== --->
		<CFQUERY NAME="qTenant" DATASOURCE="#APPLICATION.datasource#">
			SELECT	* 
			FROM	Tenant T
			JOIN	TenantState TS ON (TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted IS NULL)
			WHERE	T.dtRowDeleted IS NULL
			AND		T.iTenant_ID = #form.iTenant_ID#
		</CFQUERY>
			
		<!--- ==============================================================================
		Insert new Record into the request table
		=============================================================================== --->
		<CFQUERY NAME="qInsertRequest" DATASOURCE="#APPLICATION.datasource#">
			INSERT INTO AdjustmentRequest
			( 	iTenant_ID ,dtLeave ,dtReturn ,cReason ,iCurrSPoints ,cCurrSLevelTypeSet ,dtEffective ,cComments ,mCoPay ,mAmount ,iRowStartUser_ID ,dtRowStart
			)VALUES(
				#form.iTenant_ID#, 
				<CFIF IsDefined("form.dtLeave")AND form.dtLeave NEQ "">#CreateODBCDateTime(form.dtLeave)#<CFELSE>NULL</CFIF>, 
				<CFIF IsDefined("form.dtReturn") AND form.dtReturn NEQ "">#CreateODBCDateTime(form.dtReturn)#<CFELSE>NULL</CFIF>, 
				<CFIF IsDefined("form.Reason") AND form.Reason NEQ "">'#form.Reason#'<CFELSE>NULL</CFIF>,
				#qTenant.iSPoints#, 
				'#qTenant.cSLevelTypeSet#', 
				<CFIF IsDefined("form.dtEffective") AND form.dtEffective NEQ "">#CreateODBCDateTime(form.dtEffective)#<CFELSE>NULL</CFIF>, 
				<CFIF IsDefined("form.cComments") AND form.cComments NEQ "">'#form.cComments#'<CFELSE>NULL</CFIF>, 
				<CFIF IsDefined("form.mCoPay") AND form.mCoPay NEQ "">#form.mCoPay#<CFELSE>NULL</CFIF>, 
				<CFIF IsDefined("form.mAmount") AND form.mAmount NEQ "">#form.mAmount#<CFELSE>NULL</CFIF>, 
				#SESSION.USERID#, 
				#TimeStamp#
			)
		</CFQUERY>
		
		<CFCATCH TYPE="Any">
			<CFSET SendErrorEmail = 1>
			<CFSET errormessage = #cfcatch.message#>
			<P>#cfcatch.message#</P>
		    <CFSET errortype = #cfcatch.TYPE#>
			<P>Caught an exception, type = #cfcatch.TYPE# </P>
		    <P>The contents of the tag stack are:</P>
		    <CFLOOP index=i from=1 to = #ArrayLen(cfcatch.TAGCONTEXT)#>
		    	<CFSET sCurrent = #cfcatch.TAGCONTEXT[i]#>
		    	<BR>#i# #sCurrent["ID"]# (#sCurrent["LINE"]#,#sCurrent["COLUMN"]#) #sCurrent["TEMPLATE"]#
		    </CFLOOP>
		</CFCATCH>
		
	</CFTRY>
</CFTRANSACTION>

</CFOUTPUT>

<CFIF IsDefined("SendErrorEmail") AND SendErrorEmail EQ 1>
	<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" SUBJECT="Adjustment Insert Failure">
	Insert Into AdjustmentRequest Failed.<BR>
	Tenant:	#form.iTenant_ID#
	House:	#SESSION.qSelectedHouse.iHouse_ID#<BR>
	By:		#SESSION.FULLNAME#<BR>
	<BR>#errormessage#<BR>#errortype#<BR>
	____________________________________________________
	</CFMAIL>
	<BR>
	<B STYLE="font-size: 20;">An error has occured and an email has been sent to the Administrator</B>
	<BR>
	<CFOUTPUT><A HREF="#HTTP.REFERER#"> Click Here to Return to your last page.</A></CFOUTPUT>
	<CFABORT>
</CFIF>


<CFTRY>
	<!--- ==============================================================================
	Retrieve the corresponding AREmail
	=============================================================================== --->
	<CFQUERY NAME="GetEmail" DATASOURCE="#APPLICATION.datasource#">
		SELECT	Du.EMail as AREmail
		FROM	House	H
		JOIN	#Application.AlcWebDBServer#.ALCWEB.dbo.employees DU	ON	H.iAcctUser_ID = DU.Employee_ndx
		WHERE	H.iHouse_ID = #qTenant.iHouse_ID#
	</CFQUERY>
	
	<CFCATCH TYPE="Any">
		<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" SUBJECT="Adjustment Get Email Failure">
		Tenant:	#form.iTenant_ID#<BR>
		House:	#SESSION.qSelectedHouse.iHouse_ID#<BR>
		By:		#SESSION.FULLNAME#<BR>
		____________________________________________________
		</CFMAIL>
			<P>#cfcatch.message#</P>
		    <P>Caught an exception, type = #cfcatch.TYPE# </P>
		    <P>The contents of the tag stack are:</P>
		    <CFLOOP index=i from=1 to = #ArrayLen(cfcatch.TAGCONTEXT)#>
		          <CFSET sCurrent = #cfcatch.TAGCONTEXT[i]#>
		              <BR>#i# #sCurrent["ID"]# (#sCurrent["LINE"]#,#sCurrent["COLUMN"]#) #sCurrent["TEMPLATE"]#
		    </CFLOOP>
	</CFCATCH>
</CFTRY>


<CFMAIL TYPE="html" FROM="TIPS4-Message@alcco.com" TO="#GetEmail.AREmail#" SUBJECT="Adjustment Request from #SESSION.HouseName#">	
	<TABLE STYLE="background: whitesmoke; border: thin solid gainsboro; width:50%;">
		<TR><TH COLSPAN=100% STYLE="background: indigo; color: white; text-align: center;">Adjustment Request</TH></TR>
		<TR><TD>#qTenant.cLastName#,  #qTenant.cFirstName#</TD><TD>#qTenant.cSolomonKey#</TD></TR>
		<CFIF IsDefined("form.dtLeave")><TR><TD>Date Tenant Left Building:</TD><TD>#DateFormat(form.dtLeave,"mm/dd/yyyy")#</TD></TR></CFIF>
		<CFIF IsDefined("form.dtReturn")><TR><TD>Date Tenant Returned:</TD><TD>#DateFormat(form.dtReturn,"mm/dd/yyyy")#</TD></TR></CFIF>
		<CFIF IsDefined("form.Reason")><TR><TD>Reason(s):</TD><TD>#form.Reason#</TD></TR></CFIF>
		<CFIF IsDefined("form.dtLeave")><TR><TD>OLD Service Points:</TD><TD>#qTenant.iSPoints#</TD></TR></CFIF>
		<CFIF ISDefined("form.dtLeave")><TR><TD>Service Level Set:</TD><TD>#qTenant.cSLevelTypeSet#</TD></TR></CFIF>
		<CFIF IsDefined("form.mCoPay")><TR><TD>Copay:</TD><TD>#form.mCoPay#</TD></TR></CFIF>
		<CFIF IsDefined("form.mAmount")><TR><TD>Amount of the Adjustment:</TD><TD>#form.mAmount#</TD></TR></CFIF>
		<CFIF IsDefined("form.dtEffective")><TR><TD>Date Effective:</TD><TD>#DateFormat(form.dtEffective,"mm/dd/yyyy")#</TD></TR></CFIF>
		<CFIF IsDefined("form.cComments")><TR><TD>Comments:</TD><TD>#form.cComments#</TD></TR></CFIF>
		<TR><TD>Date Time:</TD><TD>#TimeStamp#</TD></TR>
		<TR><TD>Requested By:</TD><TD>#SESSION.FULLNAME#</TD></TR>
	</TABLE>
</CFMAIL>

<CFOUTPUT>
	<CFIF SESSION.USERID EQ 3025><BR><A HREF="#HTTP.REFERER#">Continue</A><CFELSE><CFLOCATION URL="#HTTP.REFERER#"></CFIF>
</CFOUTPUT>	