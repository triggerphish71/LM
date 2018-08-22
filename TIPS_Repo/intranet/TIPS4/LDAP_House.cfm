<cfparam name="houseid" default="">
<form name="housetest" action="LDAPTest.cfm" method="post">
<table>
<tr>
<td>LDAP HOUSE   TEST</td>
</tr>
 
 
<cfset ldp="DEVTIPS">
<cfset ldpass="!A7eburUDETu">
<cfset u="DEVTIPS">
<cfset p="!A7eburUDETu">
 
 
<cfoutput   >
 
			<CFLDAP ACTION="query" NAME="UserSearch" START="DC=alcco,DC=com" SCOPE="subtree" 
			ATTRIBUTES="givenName,sn,displayName,cn,dn,member,memberof,physicalDeliveryOfficeName,Description, companynumber, cGLsubaccount " 
			SERVER="CORPDC01" PORT="389"  FILTER="sAMAccountName=sgraham2" USERNAME="#u#" PASSWORD="#p#">
<cfdump var="#UserSearch#">
 	<cfldap action="query" name="getUserADInfo" start="DC=alcco,DC=com" scope="subtree" attributes="sAMAccountName,Title,DisplayName" 
		filter="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(sAMAccountName=sgraham2))"
		server="#ADserver#" port="389" username="DEVTIPS" password="!A7eburUDETu">
<cfdump var="#getUserADInfo#">
<!--- <cfloop query="UserSearch">
<tr>
<td>givenName: #givenName# </td>
</tr>
<tr>
<td>sn: #sn# </td>
</tr>
<tr>
<td>displayName:  #displayName#  </td>
</tr>
<tr>
<td>cn: #cn#  </td>
</tr>
<tr>
<td>dn: #dn# </td>
</tr>
<tr>
<td>member: #member# </td>
</tr>
<tr>
<td>memberof: #memberof#  </td>
</tr>
<tr>
<tdphysicalDeliveryOfficeName:> #physicalDeliveryOfficeName# </td>
</tr>
<tr>
<td>Description: #Description#  </td>
</tr>
<tr>
<td>companynumber:  #companynumber# </td>
</tr>
<tr>
<td>cGLsubaccount:  #cGLsubaccount# </td>
</tr>

</cfloop>	<cfldap action="query" 
	name="qLDAP" 
	start="DC=alcco,DC=com" 
	scope="subtree" 
	attributes="mail,givenName,sn,displayName,cn,dn,member,memberof,physicalDeliveryOfficeName,Description, companynumber, cGLsubaccount"
	server="corpdc01" 
	PORT="389"
FILTER="sAMAccountName=sgraham2"
	sort="sn"
	username="#ldp#" 
	password="#ldpass#"
>  --->
</cfoutput> 

</table>
</form>