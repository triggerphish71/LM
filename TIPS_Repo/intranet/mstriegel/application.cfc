<cfcomponent displayname="application" 	output="true" hint="Handle the application.">

	<!--- Set up the application. --->
	<cfset this.Name = "MSApplicationCFCTest">
	<cfset this.ApplicationTimeout = createTimeSpan(1,10,0,0) /> 
	<cfset this.SessionManagement = true>
	<cfset this.sessionTimeout = createTimeSpan(1,0,0,0)>
	<cfset this.SetClientCookies = true>
	<cfset this.clientmanagement = true>


	<cfset this.mappings["/local"] = getDirectoryFromPath(getCurrentTemplatePath())>
	<cfset this.mappings["/FileServer"] = "FS01">
	<cfset this.TipsDBServer = "BigMuddy">
	<cfset this.SolomonDBServer = "Krishna">
	<cfset this.DoclinkServer = "Shaggy">
	<cfset this.publicPages = "loginindex.cfm,logout.cfm">
	<cfset this.devlopersEmail = "CFDevelopers@alcco.com">

	<!--- Define the page request properties. --->
	<cfsetting requesttimeout="20"	showdebugoutput="false"	enablecfoutputonly="false"/>


	<cffunction name="initAppObjects" returntype="void" access="public" output="false">
		<cfset application.system_path = getDirectoryFromPath(getCurrentTemplatePath())>
		<cfset application.public_templates = "login.cfm,logout.cfm,actionlogin.cfm,applicationlist.cfm">
		<!--- initialize and app objects --->
	</cffunction>

	<cffunction name="initSessionObjects" returntype="void" access="public" output="false">
		<!--- initialize all session variables --->
		<cfset session.tempDocPath = "">
		<cfloop list="#getTempDirectory()#" index="itm" delimiters="\">
			<cfif itm IS NOT "Catalina">
				<cfset session.tempDocPath = ListAppend(session.tempDocPath,itm,"\")>
			<cfelse>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfset session.oExport2Solomon = createobject("component","intranet.TIPS4.CFC.components.export2Solomon")>	
		<cfset session.oUtilityServices = createObject("component","intranet.TIPS4.CFC.utils.utilityServices")>
		<cfif !isDefined("session.oSolomonServices")>
			<cfset session.oSolomonServices = createObject("component","intranet.TIPS4.CFC.Components.SolomonServices")>
		</cfif>
		<cfset session.oChargeServices = CreateObject("component","intranet.TIPS4.CFC.components.ChargeServices")>
		<cfset oMoveOutUpdate = createobject('component',"intranet.TIPS4.CFC.components.MoveOut.MoveoutUpdate")>
		
		<cfscript>
			function IsBlank(string1,string2){ if (TRIM(string1) neq "") value = TRIM(string1); else value = TRIM(string2); return value; }
			function PhoneFormat(string){ if (len(string) eq 10) value =  Left(string,3) &'-'& Mid(string,4,3) &'-'& Right(string,4); return value; }
			function SSNFormat(string){
				if (len(string) eq 9) { ssn =  Left(string,3) &'-'& Mid(string,4,2) &'-'& Right(string,4); return ssn; }
				else return string;
			}
			if (isDefined("session.Application") and session.Application eq 'TIPS4') { medicaidemails="nansay@ALCCO.COM"; }
		</cfscript>
	</cffunction>


	<cffunction	name="OnApplicationStart"access="public" returntype="boolean" output="false"hint="Fires when the application is first created.">
		<cfloop collection="#application#" item="akey">
			<cfset structDelete(application,akey)>
		</cfloop>
		<cfset application.datasource="TIPS4">
		<cfset application.alcWebDBServer = this.TipsDBServer>
		<cfset application.DmsDBServer = this.TipsDBServer>
		<cfset application.HOUSES_APPDBServer = this.SolomonDBServer>
		<cfset application.TimeCardDBServer = "vm08db08dev">
		<cfset application.DocLinkDBServer = this.SolomonDBServer>
		<cfset application.HRizonDBServer = "ALDER">
		<cfset application.ADserver = "CORPDC01">
		<cfset application.SolomonCorpDS = "Solomon-Corp">
		<cfset application.SolomonHousesDS = "Solomon-Houses">
		<cfset application.ComshareDS = "ELMALC">
		<cfset application.DLtifLocation = "FS01">
		<cfset application.doclinkALCds = "DoclinkALC">
		<cfset application.FTAds = "FTA">
		<cfset application.doclinkProd = "doclink2">
		<cfset application.HouseApprw = "HOUSES_APP">
		<cfset application.FileServer = "FS01">
		<cfset application.TimeCard = "TimeCard">
		<cfset initAppObjects()>

		<!--- Return out. --->
		<cfreturn true />
	</cffunction>


	<cffunction name="OnSessionStart" access="public" returntype="void" output="false" 	hint="Fires when the session is first created.">
		<cfset session.developers = "ALC Application Developers">
		<cfset session.developerEmailList = "CFDevelopers@alcco.com">
		<cfset initSessionObjects()>


		<cfquery name="AcctStamp" datasource="#application.SolomonHousesDS#"  CACHEDWITHIN="#CreateTimeSpan(0,0,5,0)#">
			SELECT cast(Right(CurrPerNbr,2) + '/01/' + LEFT(CurrPerNbr,4) as datetime) as CurrPerNbr from	ARSETUP (NOLOCK)
		</cfquery>
		<cfset session.AcctStamp = AcctStamp.CurrPerNbr>
		<cfset session.AcctPeriod = YEAR(AcctStamp.CurrPerNbr) & Dateformat(AcctStamp.CurrPerNbr,"mm")>
		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction	name="OnRequestStart" access="public"	returntype="boolean" output="false"	hint="Fires at first part of page processing.">
		<cfargument name="TargetPage" type="string"	required="true"/>


		<!--- If we're reinitializing the app --->
		<cfif isDefined("url.reInitApp") and url.reInitApp eq true>
			<cfset onApplicationStart()>
			<cfdump var="#application#">
			<cfabort>
		</cfif>

		<!--- If we're reinitializing the session --->
		<cfif isDefined("url.reInitSession") and url.reInitSession eq true>
			<cfset initSessionObjects(force=true)>
			<cfdump var="#session#">
			<cfabort>
		</cfif>

		<!--- dump scopes --->
		<cfif isDefined("url.dumpscopes") and url.dumpscopes eq true>
			<cfdump var="#url#" label="URL"><br/>
			<cfdump var="#form#" label="FORM"><br/>
			<cfdump var="#request#" label="REQUEST"><br/>
			<cfdump var="#session#" label="SESSION"><br/>
			<cfdump var="#cookie#" label="COOKIE"><br/>
			<cfdump var="#client#" label="CLIENT"><br/>
			<cfdump var="#cgi#" label="CGI">
			<cfabort>
		</cfif>
		<cfset application.system_path = getDirectoryFromPath(getCurrentTemplatePath())>
		<cfset application.public_templates = "login.cfm,logout.cfm,password_forgot.cfm,actionlogin.cfm,applicationlist.cfm">
		<!--- Get the target (script_name) directory path based on expanded script name. --->
		<cfset local.target_path = getDirectoryFromPath(expandPath(arguments.targetpage))>
		<!--- Now that we have both paths, find the difference in the paths. --->
		<cfset local.request_depth = (listLen(local.target_path, "\/") - listLen(application.system_path, "\/"))>
		<!--- With the request depth, we can easily create our web root by repeating "../" the appropriate number of times. --->
		<cfset request.web_root = repeatString("../", local.request_depth)>

		<cfif NOT listFindNoCase(application.public_templates, listLast(cgi.script_name, "/"))>
		
			<!--- If the user is not logged in --->
			<cfif NOT isdefined('session.user_id')>      
				<cfif isAjaxRequest()>
					<!--- Send unauthenticated code --->
					<cfheader statusCode="401" statusText="Application Error">
					<cfabort>
				<cfelse>
					<!--- if we're not logged in, include the login template --->
					
					<cfinclude template="loginindex.cfm">
					<!--- <cfinclude template="login.cfm"> --->
					<cfabort>
					<!--- The login template will take them back to where they were --->
				</cfif>
			</cfif>			
		</cfif>

		<!--- Return out. --->
		<cfreturn true />
	</cffunction>


	<cffunction	name="OnRequest" access="public" returntype="void"	output="true" hint="Fires after pre page processing is complete.">

		<!--- Define arguments. --->
		<cfargument	name="TargetPage" type="string" required="true" />

		<!--- Include the requested page. --->
		<cfinclude template="#ARGUMENTS.TargetPage#" />

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction name="OnRequestEnd"	access="public"	returntype="void" output="true"	hint="Fires after the page processing is complete.">

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction name="OnSessionEnd" access="public"	returntype="void" output="false" hint="Fires when the session is terminated.">

		<!--- Define arguments. --->
		<cfargument	name="SessionScope"	type="struct" required="true"/>
		<cfargument name="ApplicationScope" type="struct" required="false"	default="#StructNew()#"/>

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction	name="OnApplicationEnd"	access="public"	returntype="void" output="false" hint="Fires when the application is terminated.">

		<!--- Define arguments. --->
		<cfargument name="ApplicationScope"	type="struct" required="false"	default="#StructNew()#"/>

		<!--- Return out. --->
		<cfreturn />
	</cffunction>


	<cffunction	name="OnError"	access="public"	returntype="void" output="true"	hint="Fires when an exception occures that is not caught by a try/catch.">
		<!--- Define arguments. --->
		<cfargument	name="Exception" type="any"	required="true"/>
		<cfargument	name="EventName" type="string" required="false"	default=""/>
		<cfset local.protocol = "http://">
		<cfset errorObj = {}>
		
		<cfset errorObj.location = '#local.protocol##cgi.server_name##cgi.script_name#?#cgi.query_string#'>
		<cfset errorObj.exception = arguments.exception>
		<cfset errorObj.url = url>
		<cfset errorObj.form = form>
		<cfif isDefined("session")>
			<cfset errorObj.session = session />
		<cfelse>
			<cfset errorObj.session = {} />
			<cfset session.show_errors = true />
		</cfif>
		<cfset errorObj.cookie = cookie>
		<cfset errorObj.cgi = cgi>

		<cfsavecontent variable="errortext">
			<cfoutput>
				<cfdump var="#errorObj.location#" label="LOCATION"><hr/>
				<cfdump var="#errorObj.exception#" label="EXCEPTION"><br/>
				<cfdump var="#errorObj.url#" label="URL"><br/>
				<cfdump var="#errorObj.form#" label="FORM"><br/>
				<cfdump var="#errorObj.session#" label="SESSION"><br/>
				<cfdump var="#errorObj.cookie#" label="COOKIE"><br/>
				<cfdump var="#errorObj.cgi#" label="CGI">
			</cfoutput>
		</cfsavecontent>
		<cfoutput>#errortext#</cfoutput>
		<!--- Return out. --->
		<cfreturn />
	</cffunction>

	<cffunction name="isAjaxRequest" output="false" returntype="boolean" access="public"> 
		<cfset var headers = getHttpRequestData().headers /> 
		<cfreturn structKeyExists(headers, "X-Requested-With") and (headers["X-Requested-With"] eq "XMLHttpRequest") /> 
	</cffunction>

</cfcomponent>
