<!--- 
11/20//2013  Sfarmer   102505  c:/ chg to e:/ for move to CF01
 --->

<title>ALC Info Channel</title>	
<CFOUTPUT>
	<CFIF FindNoCase("TIPS4",getTemplatePath(),1) GT 0>
		<LINK REL=StyleSheet TYPE="Text/css"  HREF="//#SERVER_NAME#/intranet/Tips4/Shared/Style2.css">
		<CFSET DATASOURCE = "DMS">
		<CFSET DATASOURCE2 = "Census">
	<CFELSE>
		<LINK REL="STYLESHEET" TYPE="text/css" HREF="//#SERVER_NAME#/intranet/TIPS/Tip30_Style.css">
		<CFSET DATASOURCE = "DMS">
		<CFSET DATASOURCE2 = "Census">		
	</CFIF>
</CFOUTPUT>
</head>


<cfif FindNoCase("EditDeposits.cfm",getTemplatePath(),1) is not 0>
	<body bgcolor="#ffffff" link="#333399" vlink="#ff9933" text="#000080" onLoad="total4();">
<cfelseif FindNoCase("ARMoveOut.cfm",getTemplatePath(),1) is not 0>
	<body bgcolor="#ffffff" link="#333399" vlink="#ff9933" text="#000080" onLoad="Recalc();">
<cfelse>
	<!--- <body bgcolor="White" link="#333399" vlink="#FF9933" text="Navy"  leftmargin="0" topmargin="0"> --->
</cfif>

<CFOUTPUT>
	<!--- -------------------------------------------------------------------------------------------------------------------------------------------------------------
	Original Code for Andy's exit option from TIPS rather than the menubar
	------------------------------------------------------------------------------------------------------------------------------------------------------------- --->
	<TABLE CLASS='noborder' STYLE="width: 640px; border: none; background: transparent;">
		<tr>
			<TD NOWRAP STYLE="background: white; border: none; background: transparent;">
				<CFIF IsDefined("SESSION.FullName")> #SESSION.FullName#<BR> </CFIF>					
			</TD>
		    <td NOWRAP STYLE="background: white; text-align: center; border: none; background: transparent;">		
				<font style="font-family: sans-serif; font-size: xx-small; font-style: normal;">
					<a href="http://#SERVER_NAME#/intranet/logout.cfm">Click here to Logout</a>
				</font>
			</td>
			<TD NOWRAP STYLE="background: white; border: none; background: transparent; width:30%;">
				<cfif ( isdefined("session.userid") and (session.userid lt 1800 or session.userid gt 2000) ) >
				<!--- or isdefined("session.grouplist") --->
					<font style="font-family: sans-serif; font-size: xx-small; font-style: normal;">
						<A HREF="/intranet/admin/usermgmt/bioentryfirst.cfm">Change Password</A>
					</font>
				</cfif>
				&nbsp;
			</TD>

			<CFIF (IsDefined("session.CodeBlock") AND (ListFindNoCase(session.CodeBlock,13) GT 0))>
				<td NOWRAP STYLE="background: white; border: none; background: transparent;"><CFINCLUDE TEMPLATE="/intranet/headernav.cfm"></td>
			</CFIF>			
		</tr>
	</TABLE>
</CFOUTPUT>
<!---  AND SESSION.application is "TIPS4" --->

<!--- <CFIF IsDefined("AUTH_USER") AND (IsDefined("SESSION.application") 
	and (isDefined("SESSION.qSelectedHouse.iHouse_ID") OR IsDefined("url.SelectedHouse_ID")) 
	and gettemplatepath() neq 'c:\inetpub\wwwroot\intranet\TIPS4\Index.cfm'
	and gettemplatepath() neq 'c:\inetpub\wwwroot\intranet\TIPS4\developer.cfm')><br>
	<!--- include Button Main Menu --->
	<cfinclude template="tips4/buttonmainmenu.cfm"><BR>
</CFIF> --->
<CFIF IsDefined("AUTH_USER") AND (IsDefined("SESSION.application") 
	and (isDefined("SESSION.qSelectedHouse.iHouse_ID") OR IsDefined("url.SelectedHouse_ID")) 
	and gettemplatepath() neq 'e:\inetpub\wwwroot\intranet\TIPS4\Index.cfm'
	and gettemplatepath() neq 'e:\inetpub\wwwroot\intranet\TIPS4\developer.cfm')><br>
	<!--- include Button Main Menu --->
	<cfinclude template="tips4/buttonmainmenu.cfm"><BR>
</CFIF>