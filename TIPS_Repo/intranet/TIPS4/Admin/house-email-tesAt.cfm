<cfset ldp="ldap">
<cfset ldpass="paulLDAP939">
<!--- <cfparam name="qldap.mail" default="mlaw@alcco.com">
<!---<cfset attributes.ihouse_id  = 191> ---> 
<cfset today = now()> 
<cfset date = #DateFormat(now(), "yyyy-mmm-dd")#>
<cfset Lastdate = #DateAdd( 'd', -1, now())#>
<cfset period = #DateFormat(now(), "yyyymm")#>


<cfoutput>

<!---<cfif attributes.ihouse_id eq 212 or attributes.ihouse_id eq 216 or attributes.ihouse_id eq 224> 
	<cfquery name="qhouses" datasource="TIPS4">
		select LEFT(cname, len(cname) ) housename
		from house where dtrowdeleted is null
		and ihouse_id not in (200,52) and ihouse_id = #trim(attributes.ihouse_id)#
		order by housename
	</cfquery>
<cfelse>--->
	<cfquery name="qhouses"  datasource="#application.datasource#">
		select LEFT(cname, len(cname) -6) housename,ihouse_id,cGLsubaccount, cname, dtrowdeleted, iunitsavailable
		from house 
		where dtrowdeleted is null
		and ihouse_id not in (200, 52, 49, 124, 224)
		 <!---and ihouse_id = #trim(attributes.ihouse_id)#--->
		order by housename
	</cfquery>
<!---</cfif>--->
<!---<cfset qhouses.housename = 'blanchard'>--->
<cfloop query="qhouses" >

<!--- givenName,sn,displayname,description,sAMAccountName,mail,memberof,physicalDeliveryOfficeName --->
<cfldap action="query" name="qLDAP" start="DC=alcco,DC=com" scope="subtree" attributes="mail" server="corpdc01" PORT="389"
	filter="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(!(sn=admin))(!(sn=administrator))(!(sn=account)(!(sn=recovery))) (|(sn=House)(sn=Mail)) (givenName=#trim(qhouses.housename)#))"
	sort="sn"
	username="#ldp#" password="#ldpass#"
>

<cfif qldap.recordcount eq 0>
<cfset h = "#trim(gettoken(qhouses.housename,1," "))##trim(gettoken(qhouses.housename,2," "))#">
<!--- <cfif left(h,2) eq 'CL' and left(h,3) neq 'CLE'><cfset h=trim(gettoken(qhouses.housename,2," "))></cfif> --->
<cfif left(h,2) eq 'CL' and left(h,3) neq 'CLE'><cfset h="Colonial*"&trim(gettoken(qhouses.housename,2," "))></cfif>
<cfldap action="query" NAME="qLDAP1" start="DC=alcco,DC=com" scope="subtree" attributes="mail" server="corpdc01" port="389" 
	filter="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(!(sn=admin))(!(sn=administrator))(!(sn=account)(!(sn=recovery))) (|(sn=House)(sn=Mail)) (givenName=*#h#))"
	sort="sn"
	username="#ldp#" password="#ldpass#"
>
</cfif>
<p> #qLDAP.mail#, #qhouses.ihouse_id#, #qhouses.cname#, #qhouses.dtrowdeleted#, #qhouses.iunitsavailable#</p>
</cfloop>
</cfoutput> --->

<cfldap action="query" name="qLDAP" start="DC=alcco,DC=com" scope="subtree" attributes="mail, house" server="corpdc01" PORT="389"
	filter="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(!(sn=admin))(!(sn=administrator))(!(sn=account)(!(sn=recovery))) (|(sn=House)(sn=Mail)) (givenName=Barnes Place))"
	sort="sn"
	username="#ldp#" password="#ldpass#"
>

<cfdump var="#qLDAP#">