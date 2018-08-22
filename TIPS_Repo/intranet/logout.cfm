<CFIF isDefined("session.username")><CFSET structdelete(application,"#replace(session.username, " ", "_", "all")#")></CFIF>
<CFSET session.codeblock=''>
<CFSET structDelete(session,"codeblock")>
<CFSET structdelete(session,"grouplist")>
<CFSET SESSION.dday = 0>
<CFSET SESSION.daycount = 0>
<CFSET SESSION.ddaybit = 0>
<CFSET SESSION.userID = ''>
<CFSET structdelete(session,"UserName")>
<CFSET structdelete(session,"EID")>
<CFSET structdelete(session,"ADdescription")>
<CFSET structdelete(session,"FullName")>
<CFSET SESSION.qSelectedHouse = ''>
<CFSET SESSION.Application = ''>
<CFSET SESSION.AccessRights = ''>
<CFSET structdelete(session,"ad")>
<CFSET structdelete(session,"userid")>
<CFSET structdelete(session,"qSelectedHouse")>
<CFSET StructClear(SESSION)>

<CFOUTPUT>
<B STYLE="text-align: center; font-size: 20;">You have been successfully logged out.</B>

<SCRIPT>
	function gotologin() {
		self.location='http://#server_name#/intranet/loginindex.cfm';
	}
	setTimeout('gotologin()',10000);
</SCRIPT>
</CFOUTPUT>
<!--- ==============================================================================
<cflocation url="/intranet/index.cfm" addtoken="No">
=============================================================================== --->

