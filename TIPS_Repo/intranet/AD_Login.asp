<% Dim objADSI, strUsername, strPassword, strDomain
strUsername = request.Form("username")
strPassword = request.Form("password")
strDomain = "ALC"

if strUsername = "kdeborde" then
response.Write("<FORM ACTION='actionlogin.cfm?b=1' METHOD='POST'>")
else 
response.Write("<FORM ACTION='actionlogin.cfm?b=1' METHOD='POST'>")
End if
response.Write("<INPUT TYPE=hidden NAME='UserName' VALUE='" & request.Form("username") &  "'>")
response.Write("<INPUT TYPE=hidden NAME='Password' VALUE='" & request.Form("password") &  "'>")
'you can easily change this to retrieve the domain from a form aswell
Set objADSI = GetObject("WinNT://" & strDomain)
Dim strADsNamespace
Dim objADSINamespace
strADsNamespace = Left("WinNT://" & strDomain, InStr("WinNT://" & strDomain, ":"))
Set objADSINamespace = GetObject(strADsNamespace)
on error resume next
Set objADSI = objADSINamespace.OpenDSObject("WinNT://" & strDomain, strDomain & "\" & strUsername, strPassword, 0)
' If there's no error then the user has been authenticated!
if Err.Number <> 0 Then 
'authentication failed code here for failed authentication
		'response.write "AUTHENTICATION FAILED!"
		response.write ("<INPUT TYPE=hidden NAME='Authentication' VALUE='0'>")
		Session("authenticated") = False
Else
'code here for authentication success
		response.write "Logging In please wait."
		response.write ("<INPUT TYPE=hidden NAME='Authentication' VALUE='1'>")
		Session("authenticated") = True
End if
response.Write("</FORM>")
Set objADSINamespace = Nothing
Set objADSI = Nothing
Set strUsername = Nothing
Set strPassword = Nothing
Set strDomain = Nothing
Set strADsNamespace = Nothing 
response.Write("<SCRIPT>document.forms[0].submit();</SCRIPT>")
%>