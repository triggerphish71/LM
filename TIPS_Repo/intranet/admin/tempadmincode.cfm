<cfset locate = FindNoCase("devweb",#CGI.HTTP_REFERER#,1) >
			
	<cfif locate is 0>
		<cflocation url="/intranet/index.cfm" addtoken="No">
	</cfif>
	
	
	 <cfif FindNoCase("admin",#CGI.HTTP_REFERER#,1) GT 0>
	<cfset backlink = 1 >
<cfelseif FindNoCase("departments",#CGI.HTTP_REFERER#,1) GT 0>
	<cfset backlink = 1 >
<cfelseif FindNoCase("regions",#CGI.HTTP_REFERER#,1) GT 0>
	<cfset backlink = 1 >
<cfelseif FindNoCase("documentmgt",#CGI.HTTP_REFERER#,1) GT 0>
	<cfset backlink = 1 >
</cfif>

<cfparam name="groupid2" default="">

		<!--- recreate grouplist --->
		<!--- <cfloop query="getuserprofile">
			<cfset groupid2 = groupid2&groupid&",">
		</cfloop> --->
		
		<!--- <cfset groupid2len = len(groupid2)>
		<cfset grouplisting = removechars(groupid2,groupid2len,1)>
		<cfset session.usersgroups = grouplisting> --->
		
		<!---  sessiongroups: <cfoutput>#session.usersgroups#</cfoutput><BR>
Codeblock:<cfoutput>#codeblock#</cfoutput><BR>
Uniqueid:<cfoutput query="getsecurity">#uniqueid#,</cfoutput>  --->

<cfparam name="backlink" default="1">

<cfif FindNoCase("log",getTemplatePath(),1) is 0>
		<cfif IsDefined("session.codeblock") is "FALSE"> 
			<cflocation url="/intranet/logout.cfm" addtoken="No"> 
		</cfif>
	</cfif>
	
	
	<cfparam name="loginpage" default="0">
	
	<cfif loginpage is 1>
	<cflocation url="/intranet/logout.cfm" addtoken="No">
<cfelse>

</cfif>