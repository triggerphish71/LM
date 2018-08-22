<!--- 
12/21/2015  sfarmer   added ldap query for FindSubAccount if company is blank and have a house ID
02/07/2018  mstriegel Added a condition not to display the view for FTA on the excel report
03/07/2018  mstriegel Added .cGLSubAccount to the email variable dsSubAccount. This throws an error because it is a complex variable being called as a simple variable.
 --->

<cfoutput>
	<div id="dvHeader">
</cfoutput>
<!--- <cfif session.username is "sfarmer">
  <cfparam name="iHouse_Id" default="50">
<cfparam name="session.eid" default="A8W999999">
<cfparam name="EHSIFacilityID" default="0">
<cfparam name="debug" default="false">   

   <cfparam name="session.username" default="sfarmer"> 
<cfparam name="session.developers" default="">
<cfparam name="datetouse" default="#NOW()#">
<cfparam name="SubAccountNumber" default="0">
<cfparam name="session.ADDescription" default="RDQCS - Washington Region (Greenway)">  
</cfif> --->
<!---  <cfparam name="session.username" default="dhollingsworth"> ---> 
<!---
<cfparam name="iHouse_Id" default="0">
<cfparam name="session.eid" default="A8W999098">
<cfparam name="EHSIFacilityID" default="0">
<cfparam name="debug" default="false">
<cfparam name="session.username" default="jkiperash">
<cfparam name="session.developers" default="">
<cfparam name="datetouse" default="#NOW()#">
<cfparam name="SubAccountNumber" default="010103098">
<cfparam name="session.ADDescription" default="Windriver House - Administrator">

<cfparam name="iHouse_Id" default="0">
<cfparam name="session.eid" default="A8W999999">
<cfparam name="EHSIFacilityID" default="0">
<cfparam name="debug" default="false">
<cfparam name="session.username" default="tusher">
<cfparam name="session.developers" default="">
<cfparam name="datetouse" default="#NOW()#">
<cfparam name="SubAccountNumber" default="0">
<cfparam name="session.ADDescription" default="VP Division Operations - Midwest/Atlantic">

<cfparam name="iHouse_Id" default="0">
<cfparam name="session.eid" default="A8W999999">
<cfparam name="EHSIFacilityID" default="0">
<cfparam name="debug" default="false">
<cfparam name="session.username" default="ktuma">
<cfparam name="session.developers" default="">
<cfparam name="datetouse" default="#NOW()#">
<cfparam name="SubAccountNumber" default="0">
<cfparam name="session.ADDescription" default="RDSM - PA">
--->


<cfparam name="iHouse_Id" default="0">
<cfparam name="EHSIFacilityID" default="0">
<cfparam name="debug" default="false">   
<cfparam name="datetouse" default="#NOW()#">
<cfparam name="SubAccountNumber" default="0">
<cfparam name="Rollup" default="0">  
<!--- Fetch any records in the impersonation table that have the current user's identity. --->
<cfquery name="dsUserNameImpersonation" datasource="#FtaDs#">
	SELECT TOP 1
		cNewIdentity
	FROM
		dbo.Impersonation
	WHERE
		cIdentity = '#session.userName#' AND
		bIsDescriptionIdentity = 0 AND
		dtRowDeleted IS NULL;
</cfquery>


<!--- Fetch any records in the impersonation table that have the current user's description field as an identity. --->
 <cfif IsDefined('session.ADDescription')>
 
	<cfquery name="dsUserDescImpersonation" datasource="#FtaDs#">
		SELECT TOP 1
			cNewIdentity
		FROM
			dbo.Impersonation
		WHERE
			cIdentity = '#session.ADDescription#' AND
			bIsDescriptionIdentity = 1 AND
			dtRowDeleted IS NULL;
	</cfquery>

	
	<!--- Check if the current User Name needs to be impersonated. --->
	<cfif dsUserNameImpersonation.RecordCount gt 0>
		<!--- Impersonate the current User Name. --->
		<cfset session.userName = dsUserNameImpersonation.cNewIdentity>
	</cfif>
	<!--- Check if the current User Description needs to be impersonated. --->
	<cfif dsUserDescImpersonation.RecordCount gt 0>
		<!--- Impersonate the current User Description. --->
		<cfset session.ADDescription = dsUserDescImpersonation.cNewIdentity>
	</cfif>
	<!--- Check if there is an Query String parameter with the name dateToUse? --->
	<cfif isDefined("url.datetouse")>
		<cfset datetouse = #url.datetouse#>
	</cfif>
</cfif>
<!--- eid presnet in session but empty, user not set up in ad properly --->
<cfif session.eid eq "">
	<center><H3><font color="red" face="arial">You do not have a EID set up in Active Directory and cannot access this application.<BR>
	If you need access to the Online FTA, please contact the Help Desk and have them enter your EID in your network account.
	</font></H3></center>
	<cfabort>
<!--- session.eid = 0, this page created it, they are not logged in --->
<cfelseif session.eid eq 0>
	<center><H3><font color="red" face="arial">You must be logged in with your network name and password to access the Online FTA.<BR>
	<A href="/intranet/loginindex.cfm">Please try again</A>
	</font></H3></center>
	<cfabort>
<!--- they are logged in with an ad eid set up --->
<cfelse>
	<!--- no house id was passed into this page --->
	<cfif iHouse_ID eq 0>
		<!--- get subaccount from AD --->
 		<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company,sAMAccountName" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#) (sAMAccountName=#session.username#))" USERNAME="DEVTIPS" PASSWORD="!A7eburUDETu"> 
 		
<!--- 		<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company,userPrincipalName" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#) (sAMAccountName=#session.username#))" USERNAME="ldap" PASSWORD="paulLDAP939"> --->
		<cfset SubAccountNumber = #FindSubAccount.company#>
		<cfset subAccount = #SubAccountNumber#>
		<cfset useHouseId = false>
		
		<cfif session.userName eq "sholloway">
			<cfif subAccount eq "">
				<cfset subAccount = 010104063>
			</cfif>
		<cfelseif session.userName eq "teresathompson">
			<cfif subAccount eq "">
				<cfset subAccount = 010305505>
			</cfif>
		</cfif>
  <!---<cfif (session.EID is '') or (SESSION.EID neq "temp") or (FindSubAccount.recordcount eq 0) OR (FindSubAccount.company is "")>
  <cfdump var="#session#"><br>
 subaccount = <cfdump var="#FindSubAccount#"><br />		
SubAccountNumber = <cfdump var="#SubAccountNumber#"><br />
username = <cfdump var="#session.userName#"><br />
ADdescription = <cfdump var="#SESSION.ADdescription#"><br />
EID = <cfdump var="#session.eid#"><br /> 
<!---	<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" 
	SUBJECT="FTA EID Error">
		subaccount = <cfdump var="#FindSubAccount#"><br />		
		SubAccountNumber = <cfdump var="#SubAccountNumber#"><br />
		username = <cfdump var="#session.userName#"><br />
		ADdescription = <cfdump var="#SESSION.ADdescription#"><br />
		EID = <cfdump var="#session.eid#"><br />  
		<cfdump var="#session#"><br>
	</CFMAIL> --->
</cfif> --->  
		<cfset FindSubAccount.company = subAccount>

		<cfset dsSubAccount = helperObj.FetchSubAccount(false, subAccount)>
	
		<cfset EHSIFacilityID = #trim(dsSubAccount.EHSIFacilityID)#>
		
		<cfset dsHouseInfo = #helperObj.FetchHouseInfo(subAccount)#>
		<cfset unitId = #dsHouseInfo.unitId#>
		<cfset houseId = #dsHouseInfo.iHouse_ID#>			
		<cfset HouseNumber = #trim(dsHouseInfo.EHSIFacilityID)#>
	<cfelse>
		<!--- iHouse_ID is defined, so this is an AP person coming in pretending to be a house --->
		<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company,Name" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#))" USERNAME="DEVTIPS" PASSWORD="!A7eburUDETu">
  	
		<!--- if above FindSubAccount returns listing with company blank (usually the first person out of the group that belongs to that EID) it will fail the below test, retry with username this is because we are changing from house accounts to individual accounts --->
		<cfif FindSubAccount.company is ''>
			<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" 
			ATTRIBUTES="physicalDeliveryOfficeName,company,sAMAccountName" SERVER="#ADserver#" PORT="389"  
			FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#) (sAMAccountName=#session.username#))" 
			USERNAME="DEVTIPS" PASSWORD="!A7eburUDETu">
		</cfif>	
	
		<cfif isDefined("url.rollup")>
			<cfset rollup = #url.rollup#>
		</cfif>

		<cfif rollup is 0>
			<cfset dsSubAccount = helperObj.FetchSubAccount(true, iHouse_ID)>
			<cfset SubAccountNumber = trim(dsSubAccount.cGLsubaccount)>
			<cfset subAccount = #SubAccountNumber#>
			
			<cfif session.userName eq "sholloway">
				<cfif subAccount eq "">
					<cfset subAccount = 010104063>
				</cfif>
			<cfelseif session.userName eq "teresathompson">
				<cfif subAccount eq "">
					<cfset subAccount = 010305505>
				</cfif>
			</cfif>
	
			<cfif session.userName eq "sholloway" or session.userName eq "teresathompson">
				<cfif FindSubAccount.company is "">
					<cfset FindSubAccount.company = subAccount>
				</cfif>
			</cfif>
	
			<cfset dsHouseInfo = #helperObj.FetchHouseInfo(subAccount)#>
			<cfset unitId = #dsHouseInfo.unitId#>
			<cfset houseId = #dsHouseInfo.iHouse_ID#>			
			<cfset HouseNumber = #trim(dsHouseInfo.EHSIFacilityID)#>
			<cfset EHSIFacilityID = trim(dsSubAccount.EHSIFacilityID)>
		</cfif>
	</cfif>

	<!--- if session.eid is not temp (what does that mean) or there was no subaccount found in the lookup --->
	<cfif SESSION.EID neq "temp" AND (FindSubAccount.recordcount eq 0 OR FindSubAccount.company is "")>
		<center><H3><font color="red" face="arial">Sorry, your Active Directory Account has not yet been set up with a SubAccount.  Please contact IT.</font></H3></center>
		<cfoutput>
 
			<cfmail to="CFDevelopers@alcco.com" from="TIPS4-Message@alcco.com"
			subject="FTA Abort Active Directory Account" type="html">
				Active Directory Account failure<br />
				session.username: #session.username#<br />
				session.userid: #session.userid#<br />
				SESSION.EID = #SESSION.EID#<br />
				FindSubAccount.recordcount: #FindSubAccount.recordcount#<br />
				FindSubAccount.company: #FindSubAccount.company#
				dsSubAccount: #dsSubAccount.cGLSubAccount#
				EHSIFacilityID: #EHSIFacilityID# 
				unitId: #unitId# 
				houseId: #houseId# 
				HouseNumber: #HouseNumber# 
			</cfmail>
 		 
		 </cfoutput>		
		<cfabort>
	</cfif>
</cfif>

<!--- user is not a RDO (they do not have RDO in their ad dscription --->
<cfif find("RDO", session.ADdescription) neq 0>

	<cfset RDOposition = Find("RDO",SESSION.ADdescription)>

	<cfset endposition = rdoposition + 5>

	<cfset regionname = removechars(SESSION.ADdescription,1,endposition)>

	<cfquery name="findOpsAreaID" datasource="Tips4">
		select
			 iOpsArea_ID
			,cName
		from
			OpsArea
		where
			dtRowDeleted IS NULL
		and
			cName = '#Trim(RegionName)#'                                                                                                                                                                                                                                                          
	</cfquery>

	<cfif findOpsAreaID.recordcount gt 0>
		<cfset RDOrestrict = findOpsAreaID.iOpsArea_ID>
	</cfif>
</cfif>

<!--- Show the House Drop-down list. --->
<cfinclude template="HouseSelect.cfm">

<cfif isDefined("url.ccllcHouse")>
	<cfset ccllcHouse = #url.ccllcHouse#>
</cfif>
<cfif isDefined("url.rollup")>
	<cfset rollup = #url.rollup#>
</cfif>
 
<cfif rollup is 2>
	<cfif isdefined("url.Division_ID") and url.Division_ID is not "">
		  <cfset DivisionID = #url.Division_ID#>
		  <cfset dsDivisionInfo = #helperObj.FetchDivisionInfo(DivisionID)#>
	<cfelse> <cfset DivisionID = "">
	</cfif>
<cfelseif rollup is 3>
	<cfif isdefined("url.Region_ID") and url.Region_ID is not "">
		  <cfset RegionID = #url.Region_ID#>
		  <cfset dsRegionInfo = #helperObj.FetchRegionInfo(RegionID)#>
	<cfelse> <cfset RegionID = "">
	</cfif>
<cfelseif rollup is 1>
	<cfif isdefined("url.Division_ID") and url.Division_ID is not "">
		  <cfset DivisionID = #url.Division_ID#>
		  <cfset dsDivisionInfo = #helperObj.FetchDivisionInfo(DivisionID)#>
	<cfelse>	<cfset DivisionID = "">
	</cfif>
	 <cfset RegionID = "">
</cfif>

<cfif rollup is 2> <!---DivisionID neq "" and RegionID eq "" and subaccount eq 0>--->
	<cfoutput>
		<!--- Display the FTA name, page name, and selected date. --->
		<h3>Online FTA- 
			<font color="##C88A5B">
				#Page#-
			</font> 
			<font color="##0066CC">
				#dsDivisionInfo.Division# Division Summary- 
			</font> 
			<font color="##7F7E7E">
				#DateFormat(datetouse,'mmmm yyyy')#
			</Font>
		</h3>
	</cfoutput>
	<!--- Show the Month selection along with the Toolbar Menu. --->
	<cfinclude template="MonthSelect.cfm">
<cfelseif rollup is 3><!---DivisionID neq "" and RegionID neq "" and subaccount eq 0>--->
	<cfoutput>
		<!--- Display the FTA name, page name, and selected date. --->
		<h3>Online FTA- 
			<font color="##C88A5B">
				#Page#-
			</font> 
			<font color="##0066CC">
				#dsRegionInfo.Region# Region Summary- 
			</font> 
			<font color="##7F7E7E">
				#DateFormat(datetouse,'mmmm yyyy')#
			</Font>
		</h3>
	</cfoutput>
	<!--- Show the Month selection along with the Toolbar Menu. --->
	<cfinclude template="MonthSelect.cfm">
<cfelseif rollup is 1><!---DivisionID eq "" and RegionID eq "" and subaccount eq 0>--->
	<cfoutput>
		<!--- Display the FTA name, page name, and selected date. --->
		<h3>Online FTA- 
			<font color="##C88A5B">
				#Page#-
			</font> 
			<font color="##0066CC">
				ALC Consolidated Summary- 
			</font> 
			<font color="##7F7E7E">
				#DateFormat(datetouse,'mmmm yyyy')#
			</Font>
		</h3>
	</cfoutput>
	<!--- Show the Month selection along with the Toolbar Menu. --->
	<cfinclude template="MonthSelect.cfm">

<!--- Check if there is an active sub account number. --->
<cfelseif subAccount neq 0>
	<cfoutput>
		<!--- Display the FTA name, page name, and selected date. --->
		<h3>Online FTA- 
			<font color="##C88A5B">
				#Page#-
			</font> 
			<font color="##0066CC">
			<cfif ccllcHouse is 0>
					#dsHouseInfo.cName#-
			<cfelse>
					CCLLC - #dsHouseInfo.cName#-
			</cfif>
			</font> 
			<font color="##7F7E7E">
				#DateFormat(datetouse,'mmmm yyyy')#
			</Font>
		</h3>
	</cfoutput>
	<!--- Show the Month selection along with the Toolbar Menu. --->
	<cfinclude template="MonthSelect.cfm">
<cfelse>
	<h3>
		Online FTA 
	</h3>
</cfif>
<cfoutput>
	</div>
</cfoutput>