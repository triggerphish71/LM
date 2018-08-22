<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|  Catch all cold fusion errors and send email of error to cold fusion administrator           |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| pbuendia   | 04/26/2002 | Original Authorship                                                |
| ranklam    | 09/05/2005 | Added ranklam@vcpi to the error e-mails.  We need to make this     |
|                         | dynamic by creating a developers e-mail list or soemethign!        |
| ranklam    | 01/25/2006 | Added fzahir and nryali to the error e-mails in replace of katie   |
|            |            | and steve.                                                         |
| ranklam    | 05/31/2006 | Added check foir ix_tenant in error and run fix stored proc.       |
| sfarmer    | 11/20/2013 | 102505 c:\ changed to e:\    for move to CF01                      |
----------------------------------------------------------------------------------------------->

<!--- ranklam - added (see header for more information)- 5/31/06 --->
<cfif isDefined("error.message")>
	<cfif FIND("duplicate key",error.Diagnostics) neq 0>
		<cfquery name="ExecuteStoredProc" datasource="#application.datasource#">
			exec sp_FixDuplicateKeys 1
		</cfquery>
		<font color="red"><b>The error has likely been automatically fixed, please try to refresh the page.<br>If the error is not fixed please create a help desk ticket.</b></font>
	</cfif>
</cfif>

<!--- Create error message for email and display --->
<CFSCRIPT>
	message = "***BEGIN***<BR>";
	if (isDefined("server_name")) 
	{ 
		message = message & "Server Name: #server_name#<BR>"; 
	}
	
	if (IsDefined("SESSION.Application")) 
	{ 
		message = message & "#SESSION.application#<BR>"; 
	} 
	
	if (IsDefined("Error.Diagnostics")) 
	{ 
		message = message & "#Error.Diagnostics#<BR>"; 
	}
	
	if (isDefined("AUTH_USER")) 
	{ 
		message = message & "AUTH_USER: #AUTH_USER#<BR>"; 
	}
	
	message = message & "Remote Address: #REMOTE_ADDR#<BR>";
	
	message = message & "Referer: [#HTTP.REFERER#]<BR>";
	
	if (IsDefined("Error.Type")) 
	{
		message = message & "Catch Type: #ERROR.Type#<BR>"; 
	}
	
	if (IsDefined("SESSION.USERID") AND SESSION.USERID NEQ "" ) 
	{
		message = message & "UserID : #SESSION.USERID#<BR>";
	}
	else 
	{ 
		message = message & "**USERID IS NULL **<BR>"; 
	} 
	
	if (IsDefined("SESSION.FULLNAME")) 
	{ 
		message = message & "User: <B>#SESSION.FULLNAME#</B><BR>"; 
	}
	
	if (IsDefined("SESSION.qSelectedHouse.iHouse_ID") AND SESSION.qSelectedHouse.iHouse_ID NEQ "") 
	{ 
		message = message & "iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#<BR>"; 
	}
	
	if (IsStruct("url") AND YesNoFormat(StructIsEmpty(url)) EQ 'NO') 
	{ 
		message = message & "URL VARIABLES: <BR>";
		for( l=1; l LTE len(url); l=l+1)
		{ 
			message = message & l & '==' &  Evaluate(url[l]) & '<BR>'; 
		} 		
	}
	
	if (IsDefined("form.fieldnames")) 
	{
		for( i=1; i LTE Listlen(form.fieldnames); i=i+1)
		{ 
			message = message & "#ListGetAt(form.fieldnames,i,',')# == #Evaluate(ListGetAt(form.fieldnames,i,','))# <BR>";
		} 
	}
	
	if (isDefined("iTenant_id") AND iTenant_ID NEQ "") 
	{ 
		message = message & "TenantID = " & iTenant_ID; 
	}
	
	message = message & 'Template path=' & gettemplatepath();
	message = message & 'Time=' & now() & '<BR>***END***<BR><BR>';
</CFSCRIPT>

	<CFIF IsDefined("Error.Diagnostics") AND 
		 (FIND("dead",Error.Diagnostics,1) GT 0 
		 	OR 
		 FIND("Serialization",Error.Diagnostics,1) GT 0)> 
		 
		<CFSCRIPT>
			message = message & 'Serialization=' & now() & '<BR>***DEADLOCK***<BR><BR>';
		</CFSCRIPT>
		
		<CFOUTPUT>
		<!--- Show deadlock error notification page --->
		<CENTER>
			<TABLE STYLE="font-size: 18; background: whitesmoke; border: thin solid navy;">
				<TR>
					<TH STYLE="background: Navy; font-size: 20; color: white;">Alert: Server Busy</TH>
				</TR>
				<TR>
					<TD>The Database is currently in use by another process.</TD>
				</TR>
				<TR>
					<TD>Please retry your process again.</TD>
				</TR>
				<TR>
					<TD>A notification has been sent to the web administrator.</TD>
				</TR>
				<TR>
					<TD><HR></TD>
				</TR>
				<TR>
					<TD><A HREF="http://#server_name#">Click Here to the #server_name# Site</A></TD>
				</TR>
				<CFIF IsDefined("SESSION.qSelectedHouse.iHouse_ID")> 
					<TR>
						<TD>
							<A HREF="http://#server_name#/intranet/TIPS4/Index.cfm">Click Here to Go back to the main TIPS Summary.</A>
						</TD>
					</TR> 
				</CFIF>
			</TABLE>
		</CENTER>
		<CFIF IsDefined("SESSION.USERID") AND SESSION.USERID EQ 3025> #message#<BR> </CFIF>		
		</CFOUTPUT>
	<CFELSE>
		<CFOUTPUT>
		<!--- Show error notification page --->
		<CENTER>
			<TABLE STYLE="font-size: small; background: white; border: thin solid navy;">
				<TR>
					<TH STYLE="background: Navy; font-size: 20; color: white;">Problem Detected</TH>
				</TR>
				<TR>
					<TD>A problem has been detected. Please retry your request.</TD>
				</TR>
				<!--- <TR><TD>A notification has been sent to the web administrator.</TD></TR> --->
				<TR>
					<TD><hr></TD>
				</TR>
				<TR>
					<TD><A HREF="http://#server_name#">Click Here to the #server_name# Site</A></TD>
				</TR>
				<CFIF IsDefined("SESSION.qSelectedHouse.iHouse_ID")> 
					<TR>
						<TD><A HREF="http://#server_name#/intranet/TIPS4/Index.cfm">Click Here to Go back to the main TIPS Summary.</A></TD>
					</TR> 
				</CFIF>
			</TABLE>
		</CENTER>
		<CFIF IsDefined("SESSION.USERID") AND SESSION.USERID EQ 3025 OR (isDefined("Auth_user") AND (Auth_User eq 'ALC\jcruz'))> 
			#message#<BR> 
		</CFIF>
		</CFOUTPUT>
	</CFIF>

<!--- hard coded by me, ranklam, but this will have to do until i can create some session vars for developers --->
<cfif session.username eq 'jcruz'>
	<strong>Error</strong>
	<cfdump var="#error#">
	<cfif isDefined("FORM")>
	<strong>Form</strong>
	<cfdump var="#Form#">
	</cfif>
	<strong>Session</strong>
	<cfdump var="#session#">
	<strong>Application</strong>
	<cfdump var="#application#">
</cfif>

<!--- Mail error to Cold Fusion Administrator  --->
<CFIF remote_addr neq '10.100.1.20' and (isDefined("Auth_user") AND (Auth_User neq 'ALC\jcruz'))>
	<!--- added fiaz and nag in place of katie and steve --->
	<CFMAIL TYPE="HTML" FROM="TIPS4_CFSERVER@alcco.com" TO="#session.developeremaillist#" SUBJECT="SiteWideError"> 
		#message# 
		Error:
		<cfdump var="#error#">
		<cfif IsDefined("FORM")>
		Form:
		<cfdump var="#FORM#">
		</cfif>
		Session:
		<cfdump var="#session#">
		Application:
		<cfdump var="#application#">
	</CFMAIL>
	<CFOUTPUT>
<!--- 	<CFDIRECTORY DIRECTORY="C:\Inetpub\wwwroot\intranet\TIPS4\MailLog\" ACTION="list" NAME="qDirList" FILTER="devmail.txt">
	<CFIF qDirList.RecordCount GT 0>
		<CFFILE ACTION="append" FILE="C:\Inetpub\wwwroot\intranet\TIPS4\MailLog\sitewidemail.txt" OUTPUT="#message#">
	<CFELSE>
		<CFFILE ACTION="append" FILE="C:\Inetpub\wwwroot\intranet\TIPS4\MailLog\sitewidemail.txt" OUTPUT="#message#">
	</CFIF> --->
	<CFDIRECTORY DIRECTORY="E:\Inetpub\wwwroot\intranet\TIPS4\MailLog\" ACTION="list" NAME="qDirList" FILTER="devmail.txt">
	<CFIF qDirList.RecordCount GT 0>
		<CFFILE ACTION="append" FILE="E:\Inetpub\wwwroot\intranet\TIPS4\MailLog\sitewidemail.txt" OUTPUT="#message#">
	<CFELSE>
		<CFFILE ACTION="append" FILE="E:\Inetpub\wwwroot\intranet\TIPS4\MailLog\sitewidemail.txt" OUTPUT="#message#">
	</CFIF>	
	<!--- <CFDUMP VAR="#qDirList#"> --->
	</CFOUTPUT>
<CFELSE>
	<CFSCRIPT>
		if (isDefined("Auth_user") AND Auth_User eq 'ALC\jcruz') { email='#session.developerEmailList#'; }
	</CFSCRIPT>
	<CFIF (isDefined("Auth_user") AND Auth_User neq 'ALC\jcruz')>
		<CFMAIL TYPE="HTML" FROM="TIPS4_CFSERVER@alcco.com" TO="#email#" SUBJECT="Developer Site WideError"> #message# </CFMAIL>
		<CFOUTPUT>
<!--- 			<CFDIRECTORY DIRECTORY="C:\Inetpub\wwwroot\intranet\TIPS4\MailLog\" ACTION="list" NAME="qDirList" FILTER="devmail.txt">
			<CFIF qDirList.RecordCount GT 0>
				<CFFILE ACTION="append" FILE="C:\Inetpub\wwwroot\intranet\TIPS4\MailLog\devmail.txt" OUTPUT="#message#">
				**** #qDirList.Name#<BR>
			<CFELSE>
				<CFFILE ACTION="append" FILE="C:\Inetpub\wwwroot\intranet\TIPS4\MailLog\devmail.txt" OUTPUT="#message#">
			</CFIF> --->
			<CFDIRECTORY DIRECTORY="E:\Inetpub\wwwroot\intranet\TIPS4\MailLog\" ACTION="list" NAME="qDirList" FILTER="devmail.txt">
			<CFIF qDirList.RecordCount GT 0>
				<CFFILE ACTION="append" FILE="E:\Inetpub\wwwroot\intranet\TIPS4\MailLog\devmail.txt" OUTPUT="#message#">
				**** #qDirList.Name#<BR>
			<CFELSE>
				<CFFILE ACTION="append" FILE="E:\Inetpub\wwwroot\intranet\TIPS4\MailLog\devmail.txt" OUTPUT="#message#">
			</CFIF>			
			<!--- <CFDUMP VAR="#qDirList#"> --->
		</CFOUTPUT> 
	</CFIF>
</CFIF>

