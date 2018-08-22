<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Omniweb Verification Test</title>
</head>
<cfinvoke webservice="http://maple.alcco.com/OmniwebServices/ActiveDirectoryRoleService.asmx?WSDL" method="userHasRights" returnvariable="canViewOmniweb">
               <cfinvokeargument name="iUserName" value="Mchars">
               <cfset reason="Webservice">
</cfinvoke>
<cfoutput>canViewOmniweb #canViewOmniweb#</cfoutput>

<!--- <cfinvoke webservice="http://maple.alcco.com/OmniwebServices/ActiveDirectoryRoleService.asmx?WSDL" method="userHasRights" returnvariable="canViewOmniweb">
               <cfinvokeargument name="iUserName" value="Mchars">
               <cfset reason="Webservice">
</cfinvoke>
<cfoutput>canViewOmniweb #canViewOmniweb#</cfoutput> --->
<body>
</body>
</html>
