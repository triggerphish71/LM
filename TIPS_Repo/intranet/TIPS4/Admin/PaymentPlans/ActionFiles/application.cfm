<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| Application.cfm for the payment plan application.  imports tips application.dsn              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| ../application.cfm                                                                           |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| mlaw       | 01/01/2006 | Created                                                            |
----------------------------------------------------------------------------------------------->

<!--- import tips dsn --->
<cfinclude template="../../../application.cfm">

<!--- since we aren't using session variables keep global shared variables here --->
<cfset debug = false>
<cfset bIsAdmin = false>
<cfset bIsSuperAdmin = false>

<!--- <cfset currentYear = DatePart("yyyy",NOW())>
<cfset nextYear = DatePart("yyyy",DateAdd("yyyy",1,NOW()))>

<cfset adminList = "wlevonowich,rschweer,lbebo,croy,ranklam,mlaw,tbates,rthiel,jbrink,lwolfgr,ftaylor">
<cfset superAdminList = "lbebo,ranklam,mlaw,tbates,rthiel,jbrink,lwolfgr,ftaylor">

<!--- if the user is in the admin list let them save houses --->
<cfif ListFind("#adminList#",session.username) neq 0 OR ListFind("#session.grouplist#","RDO") neq 0 OR ListFind("#session.grouplist#","DVP")>
	<cfset bIsAdmin = true>
</cfif>

<cfif ListFind("#superAdminList#",session.username) neq 0 OR ListFind("#session.grouplist#","RDO") neq 0 OR ListFind("#session.grouplist#","DVP")>
	<cfset bIsSuperAdmin = true>
</cfif>
 --->