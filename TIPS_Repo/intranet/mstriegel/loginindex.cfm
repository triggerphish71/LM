
This is the login index.cfm template
<cfif isdefined("url.mike")>
<Cfdump var="#url#" label="url">
<cfdump var="#form#" label="form">
<cfabort>
</cfif>

<!--- 11/06/2014 Added by Steve Backstrom to eliminate the errors we are getting with house accounts not being able to log in after closing the page with out logging out   ---> 
<CFSET structdelete(session,"UserName")>
<CFSET structdelete(session,"userid")>
<CFSET structdelete(session,"FullName")>
<!--- <cfif IsDefined("url.error")>Login failed please try again...</cfif> --->

<form action="actionlogin.cfm" method="post" name="theform" id="theform">
<cfif FindNoCase("TIPS%204",HTTP.REFERER,1) GT 0 OR (IsDefined("SESSION.APPLICATION") AND SESSION.APPLICATION EQ 'TIPS4')>
	<INPUT TYPE="hidden" NAME="TIPS4" VALUE="TIPS4">
	<cfset SESSION.APPLICATION = 'TIPS4'>
</cfif>

<cfif IsDefined("SESSION.USERID") AND SESSION.USERID NEQ "">
	<cfif IsDefined("SESSION.APPLICATION") AND SESSION.APPLICATION NEQ "" AND NOT isDefined("url.focal")>
		<cfif SESSION.APPLICATION EQ 'TIPS4' OR FindNoCase("TIPS%204",HTTP.REFERER,1) GT 0>
			<cflocation url='TIPS4/index.cfm'>
		<cfelse>
			<cflocation url='ApplicationList.cfm'>
		</cfif>
	</cfif>
</cfif>

<script>
	function required(){
		if (document.forms[0].username.value.length == 0 || document.forms[0].password.value.length == 0) { 
			alert('Please enter both your username and password.'); document.forms[0].username.focus();
		}
		else {
		
		 document.forms[0].submit(); 
		}
		//o='<B style=font-size:medium;color:red>Logging in please wait...</B>'; document.write(o); 
	}
	function entercheck(obj) {
		if (obj.name !== "username"){ 
			if (event.keyCode == 13) { required(); return false; } else { document.forms[0].password.focus(); return false;} 
		}
	}
	function username() {
		if (document.theform.username.value.length == 0 ) { document.theform.username.focus(); }
		else if (document.theform.password.value.length == 0 ) { document.theform.password.focus(); }
	}
	document.onclick=username;
	window.onload=username;
</script>
<ul>
<style>
td { 
padding-left: 10px; 
font-family: verdana; 
font-size: xx-small; 
font-style: normal; 
font-weight: bold; 
color: ##5a5a5a; 
vertical-align:middle;
}
</style>
<table border="0" cellspacing="0" cellpadding="2" style="width: 300px; border: 1px solid black;">
	<tr>    
		<cfif isDefined("url.focal")>
			<td colspan="2" style="background: darkblue; text-align: center; color: white; border-bottom:1px solid navy;">
				<B>Please use your <B style='color:red;'>network</B> UserName and Password to log into Focal Review. </B>
			</td>
		<cfelse>
			<td colspan="2" style="background: darkblue; text-align: center; font-size: x-small; font-family: verdana;">
				<font color="white"><B>Please enter your login information</B></font>
			</td>
		</cfif>
	</tr>
	<tr bgcolor="gainsboro">
	    <td>Username:</td>
	    <td><input type="text" name="username" onKeyDown='entercheck(this); CancelEnter();'></td>
	</tr>
	<tr bgcolor="gainsboro">
	    <td>Password:</td>
	    <td><input type="password" name="password" onKeyDown="entercheck(this); backspace(this); CancelEnter();"></td>
	</tr>
	<tr bgcolor="gainsboro">
		<td colspan=2 style="text-align:center;">
		<input type="button" name="Submit" value="Log In" onClick='required();'>
		</td>
	</tr>
</table>
</ul>
</form>

