
<cfdump  var="#session#" label="session">
<br />
<cfset ldp="ldap">
<cfset ldpass="paulLDAP939">
<!--- <cfparam name="houseid" default="">
<form name="housetest" action="LDAPTest.cfm" method="post">
<table>
<tr>
<td>LDAP HOUSE EMAIL TEST</td>
</tr>
<!--- <tr>
<td>Input House ID: <input type="text" name="houseid"> </td>
</tr>
<tr>
<td><input type="submit" name="submit" value="submit"></td>
</tr>

<cfif houseid is not ""></cfif> --->
<tr>
<td> HOUSE</td>
<td>EMAIL</td>
</tr>
<cfset ldp="ldap">
<cfset ldpass="paulLDAP939">
<cfquery name="qhouses" datasource="#application.datasource#">
select LEFT(cname, len(cname) -6) housename, cname
from house where dtrowdeleted is null
and ihouse_id not in (200,52,49,124,224,173,209,216,227,147,104,220) 
and dtrowdeleted is null
<!--- and ihouse_id = #houseid# --->
order by housename
</cfquery>
<cfoutput query="qhouses">
<cfldap action="query" name="qLDAP" start="DC=alcco,DC=com" scope="subtree" attributes="mail" server="corpdc01" PORT="389"
	filter="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(!(sn=admin))(!(sn=administrator))(!(sn=account)(!(sn=recovery))) (|(sn=House)(sn=Mail)) (givenName=#trim(qhouses.housename)#)))"
	sort="sn"
	username="#ldp#" password="#ldpass#">

<!--- <tr>
<td>#Cname# </td>
<td><!--- Email #qhouses.housename#: ---> #qldap.mail#</td>
</tr> --->
</cfoutput> --->
 	<cfset u='ldap'>
	<cfset p='paulLDAP939'>		
	<cfoutput>
		<CFLDAP ACTION="query" NAME="GroupSearch" START="DC=alcco,DC=com" SCOPE="subtree" 
		ATTRIBUTES="givenName,sn,displayName,cn,dn,member,memberof,physicalDeliveryOfficeName,Description,organization" 
		SERVER="CORPDC01" PORT="389"  FILTER="sAMAccountName=cbuckalew" USERNAME="#u#" PASSWORD="#p#">
	</cfoutput>
	<cfoutput >
	<tr><td><cfdump var="#GroupSearch#"></td></tr>
	</cfoutput>

	<cfoutput>
		<CFLDAP ACTION="query" NAME="GroupSearch2" START="DC=alcco,DC=com" SCOPE="subtree" 
		ATTRIBUTES="givenName,sn,displayName,cn,dn,member,memberof,physicalDeliveryOfficeName,Description,organization" 
		SERVER="CORPDC01" PORT="389"  FILTER="sAMAccountName=cbuckalew" USERNAME="#u#" PASSWORD="#p#">
	</cfoutput>
	<cfoutput >
	<tr><td><cfdump var="#GroupSearch2#" label="GroupSearch2"></td></tr>
	</cfoutput>	
</table>
</form> 

		<cfntauthenticate username="sfarmer" password="ColdasHell15" domain="ALC" result="authresult">
		<cfdump var="#authresult#"> 
		
		<cfquery name="qhouses" datasource="TIPS4">
		select cname, LEFT(cname, len(cname) -6) housename,ihouse_id,cGLsubaccount
		from house 
		where dtrowdeleted is null
			and ihouse_id not in (200, 52, 49, 124, 224) <!---and ihouse_id = #trim(attributes.ihouse_id)#--->
			and iunitsavailable > 0
		order by housename
	</cfquery>	
		
<!--- <cfloop query="qhouses">

<!--- givenName,sn,displayname,description,sAMAccountName,mail,memberof,physicalDeliveryOfficeName --->
<cfldap action="query" name="qLDAP" start="DC=alcco,DC=com" scope="subtree"   

ATTRIBUTES="givenName,sn,displayName,cn,dn,member,memberof,physicalDeliveryOfficeName,Description"server="corpdc01" PORT="389"
	filter="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(!(sn=admin))(!(sn=administrator))(!(sn=account)(!(sn=recovery))) (|(sn=House)(sn=Mail)) (givenName=#trim(qhouses.housename)#))"
	sort="sn"
	username="#ldp#" password="#ldpass#"
>

<cfoutput>
#qhouses.cname# :: #qhouses.ihouse_id# ::   <!--- #qldap.mail# #qldap.admin# --->   #qldap.memberof#<br />
</cfoutput>

</cfloop> --->
		<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company,userPrincipalName" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#) (userPrincipalName=sawyermail@alcco.com))" USERNAME="ldap" PASSWORD="paulLDAP939">
		
	 <cfoutput>
		<cfdump  var="#FindSubAccount#" label="FindSubAccount">
		</cfoutput>