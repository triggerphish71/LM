
<!--- <CFLOCATION URL="Loginindex.cfm" ADDTOKEN="No"> --->


<!--- ==============================================================================
<!--- *********************************************************************************************************************
	Starting page for the Intranet
	Uses CFINCLUDE to bring in the main content of the first page called HOME_TEMPLATE.CFM
********************************************************************************************************************* --->

<CFIF IsDefined	("session.codeblock") IS "FALSE">
	<CFLOCK TIMEOUT = "2" 	THROWONTIMEOUT = "No" 	NAME = "startsession" TYPE = "EXCLUSIVE">
		<CFSET 	session.codeblock = 0>
	</CFLOCK>
</cfif>


<CFINCLUDE TEMPLATE="/intranet/header.cfm">&nbsp;&nbsp;


	<FONT STYLE="font-family: Arial, Helvetica, sans-serif; font-size: xx-small;">
		<CFOUTPUT>	#DayofWeekAsString(dayofWeek(Now()))#, #dateFormat(Now(),"mmm dd, yyyy")#	</CFOUTPUT>
	</FONT>

<CFINCLUDE TEMPLATE	= "/intranet/home/home_template.cfm"> 

<CFINCLUDE TEMPLATE	= "/intranet/Footer.cfm">
=============================================================================== 
---> <A HREF="index.cfm">index</A>