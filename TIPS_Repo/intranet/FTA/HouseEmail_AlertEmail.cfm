<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 10/03/2006 | Added Flowerbox                                                    |
| ranklam    | 10/03/2006 | Added qldap.mail param.                                            |
| gthota    | 04/16/2014 | qhouses looking for house firstname to pass in to ldap.. ldap pulling house email id   |
----------------------------------------------------------------------------------------------->

<!--- create a param for qldap.mail because this function always excpets it to be populated --->
<!--- <cfparam name="qldap.mail" default="mlaw@alcco.com"> --->
<cfparam name="qldap.mail" default="cfdevelopers@enlivant.com">
<!---<cfset attributes.ihouse_id  = 191> ---> 
<cfset today = now()> 
<cfset date = #DateFormat(now(), "yyyy-mmm-dd")#>
<cfset Lastdate = #DateAdd( 'd', -1, now())#>
<cfset period = #DateFormat(now(), "yyyymm")#>

<cfset ldp="DEVTIPS">
<cfset ldpass="!A7eburUDETu">
<cfoutput>

<!---<cfif attributes.ihouse_id eq 212 or attributes.ihouse_id eq 216 or attributes.ihouse_id eq 224> 
	<cfquery name="qhouses" datasource="TIPS4">
		select LEFT(cname, len(cname) ) housename
		from house where dtrowdeleted is null
		and ihouse_id not in (200,52) and ihouse_id = #trim(attributes.ihouse_id)#
		order by housename
	</cfquery>
<cfelse>--->
	<cfquery name="qhouses" datasource="TIPS4">
		select LEFT(cname, len(cname) -6) housename,ihouse_id,cGLsubaccount
		from house where dtrowdeleted is null
		and ihouse_id not in (200,52) <!---and ihouse_id = #trim(attributes.ihouse_id)#--->
		order by housename
	</cfquery>
<!---</cfif>--->
<!---<cfset qhouses.housename = 'blanchard'>--->
<cfloop query="qhouses">

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
<!---name - #qhouses.housename# / #qhouses.ihouse_id# <br/>
email - #qldap.mail# <br/>--->

<cfquery name="days_prev_OT" datasource="FTA">
SELECT  *	        
	  FROM  
	       EmailAlertsData_Prev
	 WHERE  cAlertDesc IN('OverTime Hours')	 AND iHouseId = #qhouses.ihouse_id#    
	      AND dtRowDeleted is null 
		  AND cflag = 1 
		  AND fovertime60 is not null 
	 ORDER BY  
	       cDivisionName, cRegionName,chousename ,cAlertDesc,cdisplayname
</cfquery>
<cfquery name="days_prev_OB" datasource="FTA">
SELECT  *	        
	  FROM  
	       EmailAlertsData_prev
	 WHERE  cAlertDesc IN('Over Budget') AND iHouseId = #qhouses.ihouse_id#	      
	      AND dtRowDeleted is null 
		  AND cflag = 1 
		  AND fovertime60 is not null 
	 ORDER BY  
	       cDivisionName, cRegionName,chousename ,cAlertDesc,cdisplayname
</cfquery>
<cfif qldap.mail NEQ 0> 
<!---<cfmail to="#qldap.mail#" from="FTA@enlivant.com" subject="FTA Labor Alerts." type="html">--->
<cfif days_prev_OB.recordcount NEQ 0>
 <h3> <font color="##0000FF"> FTA Labor Over Budget Alerts prev day. - #days_prev_OB.cHouseName#  </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	   <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Previous day Over Budget. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td> <td><b>To Date</b>   <td><b>Prev Day</b></td>
			  </tr>
			
			  <cfloop query="days_prev_OB"> 
				<tr BGCOLOR="###IIF(days_prev_OB.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#days_prev_OB.cDivisionName#</td>
					<td>#days_prev_OB.cRegionName# &nbsp;</td>                
					<td>#days_prev_OB.cHouseName# &nbsp;</td>
					<td>#days_prev_OB.cDisplayname# &nbsp;</td>
					<td>#days_prev_OB.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(days_prev_OB.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td>#DateFormat(days_prev_OB.dttoDate, "yyyy-mm-dd")# &nbsp;</td>					
					<td align="center"><font color="##CC0000">#numberformat(days_prev_OB.fActual, "0.00")#</font></td>
				 </tr>
			 </cfloop>			
	  </table> 
	  <hr><br/>
	</cfif> 
<cfif days_prev_OT.recordcount NEQ 0>
<h3> <font color="##0000FF"> FTA Labor Over Time Alerts prev day. - #days_prev_OT.cHouseName# </font></h3>
		<font color="##3399CC"><b> Today's Date : #date# </b></font>
	   <table border="1">
			  <tr>
				  <td colspan='3' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;"><font color="##3399CC"> FTA Previous day Over Time. </font></td>
			  </tr>
			  <tr bgcolor="##FFFF66"> 
				  <td><b>Division </b></td> <td><b>Region</b></td>  <td><b>Community</b></td>  <td><b>Department</b></td>  <td><b>Alert Type</b></td>
				  <td><b>From Date</b></td> <td><b>To Date</b>   <td><b>Prev Day</b></td>
			  </tr>
			
			  <cfloop query="days_prev_OT"> 
				<tr BGCOLOR="###IIF(days_prev_OT.currentrow MOD 2, DE('E6E6E6'), DE('C0C0C0'))#">
					<td>#days_prev_OT.cDivisionName#</td>
					<td>#days_prev_OT.cRegionName# &nbsp;</td>                
					<td>#days_prev_OT.cHouseName# &nbsp;</td>
					<td>#days_prev_OT.cDisplayname# &nbsp;</td>
					<td>#days_prev_OT.cAlertDesc# &nbsp;</td>
					<td>#DateFormat(days_prev_OT.dtFromDate, "yyyy-mm-dd")# &nbsp;</td>
					<td>#DateFormat(days_prev_OT.dttoDate, "yyyy-mm-dd")# &nbsp;</td>
					<td align="center"><font color="##CC0000">#numberformat(days_prev_OT.fActual, "0.00")#</font></td>
				 </tr>
			 </cfloop>			
	  </table> 
	  <hr><br/>
	  <font color="##FF0000"> Do not reply to this email, as this email box is not monitored. </font>
	 </cfif>
	 
<!---</cfmail>--->
</cfif>
</cfloop>


</cfoutput>
