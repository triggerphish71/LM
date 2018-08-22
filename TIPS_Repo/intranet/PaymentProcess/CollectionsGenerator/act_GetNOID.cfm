<!----------------------------------------------------------------------------------------------
| DESCRIPTION - act_GetNOID.cfm                                                                |
|----------------------------------------------------------------------------------------------|
| Records all the Tenants			 	                                                       |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
| Called by dsp_NOIDMain.cfm														      	   |     
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| mlaw       | 10/11/2007 | 																   | 
| mlaw       | 11/19/2007 | Add Sort Options                                                   |
| rschuette  | 08/04/2009 | Prj 36359 - Deferred Payment                                       |
----------------------------------------------------------------------------------------------->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>Action Page</title>

<style type="text/css">
<!--
.style1 {
	color: #FF0000;
	font-weight: bold;
}
-->
</style>
<style type="text/css">
<!--
.style2 {
	font-family: Arial, Helvetica, sans-serif;
	font-weight: bold;
}
-->
</style>

<SCRIPT LANGUAGE="JavaScript">
function DisBox(objName, csolomonkey) 
{
	var box = document.getElementsByName('thirdletter_' + csolomonkey)[0];
	var issuedate = document.getElementsByName('issuedate_' + csolomonkey)[0];
	var thirddate = document.getElementsByName('thirdletterdate_' + csolomonkey)[0];
	var calendatbtn = document.getElementsByName('calendar_' + csolomonkey)[0];
	
	//alert (box);
	if(box.checked == 0 )
	{
		//otherbox.disabled=true
		//dischargedate.disabled=true
		//alert ('hi');
		//alert (thirddate.value);
		issuedate.disabled=false;
		calendatbtn.style.visibility = 'visible';;
	}
	else{
		//otherbox.disabled=false
		//dischargedate.disabled=false
		//alert ('ho');
		//alert (thirddate.value);
		issuedate.disabled=true;
		issuedate.value ="";
		calendatbtn.style.visibility = 'hidden';
	}
}

function DisDeleteBox(objName, csolomonkey) 
{
	var box = document.getElementsByName('delete_' + csolomonkey)[0];
	var notes = document.getElementsByName('notes_' + csolomonkey)[0];
	var exemptdate = document.getElementsByName('exemptdate_' + csolomonkey)[0]; 
	var thirdbox = document.getElementsByName('thirdletter_' + csolomonkey)[0];
	var issuedate = document.getElementsByName('issuedate_' + csolomonkey)[0];
	var thirddate = document.getElementsByName('thirdletterdate_' + csolomonkey)[0];
	var calendatbtn = document.getElementsByName('calendar_' + csolomonkey)[0];
	var mydate=new Date()
	var theyear=mydate.getYear()
	if (theyear < 1000)
	theyear+=1900
	var theday=mydate.getDay()
	var themonth=mydate.getMonth()+1
	if (themonth<10)
	themonth="0"+themonth
	var theday=mydate.getDate()
	if (theday<10)
	theday="0"+theday

	//////EDIT below three variable to customize the format of the date/////
	
	var displayfirst=themonth
	var displaysecond=theday
	var displaythird=theyear
	
	if(box.checked == 1)
	{
		thirdbox.disabled=true;
		issuedate.disabled=true;
		calendatbtn.style.visibility = 'hidden';
		if(notes.value == "")
		{
			alert ("Please enter Notes");
			//exemptdate.value=displayfirst+"/"+displaysecond+"/"+displaythird
			//return (false);
		}
		if(thirddate.value == "" && thirdbox.checked == 1)
		{
			//alert ("Remove thirdbox");
			thirdbox.checked = false;
			thirdbox.disabled=true;
			issuedate.disabled=true;
			calendatbtn.style.visibility = 'hidden';
		}

		exemptdate.value=displayfirst+"/"+displaysecond+"/"+displaythird
		//otherbox.disabled=true
		//dischargedate.disabled=true
		
		//alert (thirddate);
		//issuedate.disabled=false;
	}
	else
	{
		issuedate.disabled=false;
		exemptdate.value='';
		thirdbox.disabled=false;
		calendatbtn.style.visibility = 'visible';
	}
}

function SubmitForm()
{
	//alert ("Submit Now");
	//create a var for the form
	var theForm = document.getElementsByName('SubmitNOID')[0];
	var arrayInputItems = theForm.getElementsByTagName('input');
	
	//loop through the select items
	for(i = 0; i < arrayInputItems.length; i++)
	{			
		if(arrayInputItems[i].name.indexOf('delete_') != -1) 
		{
			var box = arrayInputItems[i]
			if (box.checked == true)
			{
				var solKey = box.name.substr(box.name.indexOf('_') + 1,box.name.length);
				
				if (document.getElementsByName('notes_' + solKey)[0].value == '')
				{
					alert ("Please enter Notes for the exempted records");
					return false;
				}
			}
		}
		//if the function hasn't exited by this point nothing is wrong, submit the form
		theForm.submit();
	}
}
</SCRIPT>

</head>
<!--- This is for the calendar --->
<script language="JavaScript" src="ts_picker4.js"></script>

<body>
<cfoutput>
	<!--- Set paramenters --->
	<cfparam name="sortBy" default="cdescription">
	<cfparam name="scope" default="">
	<cfparam name="period" default="">
	<cfparam name="LetterType" default="">
	<cfparam name="Deferred" default="">
	
	<cfif isdefined("form.Scope") is "true">
	  <cfset scope = form.Scope>
	</cfif>
	<cfif isdefined("url.Scope") is "true">
	  <cfset scope = url.Scope>
	</cfif>

	<cfif isdefined("form.period") is "true">
	  <cfset period = form.period>
	</cfif>
	<cfif isdefined("url.period") is "true">
	  <cfset period = url.period>
	</cfif>
	
	<cfif isdefined("form.LetterType") is "true">
	  <cfset LetterType = form.LetterType>
	</cfif>
	
	<cfif isdefined("url.LetterType") is "true">
	  <cfset LetterType = url.LetterType>
	</cfif>
	
	<!--- Project 36359 - rts - 7-31-2009  Deferred Payment option --->
	 <cfif isdefined("form.cboDeferredPayment") and form.cboDeferredPayment neq ''> 
		 <cfif "#form.cboDeferredPayment#" eq 1>		
				<cfset Deferred = "YES">
		 <cfelse>
				<cfset Deferred = "NO">
		</cfif>
	<cfelse>
				<cfset Deferred = "NO">
	</cfif> 
	<!--- End 36359 --->
		
	<cfset thirdletter = 0>
	
	<CFTRY>
		<CFSTOREDPROC PROCEDURE="rw.sp_CollectionRegister" DATASOURCE="#APPLICATION.datasource#" returncode="yes">
			<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_VARCHAR"  DBVARNAME="@Scope" VALUE="#Scope#" >
-- 			<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_CHAR"  DBVARNAME="@Period" VALUE="#Period#" null="no" >
			<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_CHAR"  DBVARNAME="@Stage" VALUE="#LetterType#" null="no" >	
			<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_CHAR"  DBVARNAME="@thirdletter" VALUE="#thirdletter#" null="no" >
			<!--- Project 36359 - rts - 7-31-2009  Deferred Payment option --->
			<CFPROCPARAM TYPE="In" cfsqltype="CF_SQL_BIT" DBVARNAME="@Deferred" VALUE="#Deferred#" null="no" >
			<!--- End 36359 --->	
			<CFPROCRESULT name="rs1" resultset="1">
		</CFSTOREDPROC>
		
		<CFCATCH TYPE="Any">
			<CFMAIL TYPE ="HTML" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" SUBJECT="STOREDPROC STATUS CODE ERROR - Collection Letters Generator">
	
			</CFMAIL>	
		</CFCATCH>
	</CFTRY>
	<table style="BORDER-COLLAPSE: collapse" borderColor="gray" height="27" cellSpacing="1" borderColorDark="##c0c0c0" cellPadding="1" width="26%" borderColorLight="##c0c0c0" border="1">
	  <tr>
		<td noWrap width="45%" height="24">
		<font face="Arial" color="##0000ff" size="2"><b>Accounting Period</b></font>
		</td>
		<td width="55%" height="24"><cfoutput>#period#</cfoutput></td>
	  </tr>
	  <tr>
		<td noWrap width="45%" height="1">
		<font face="Arial" color="##0000ff" size="2"><b>List Type </b></font>
		</td>
		<td width="55%" bgColor="##ffffff" height="1"><cfif #LetterType# eq 1> Letter 1 <cfelseif #LetterType# eq 2> Letter 2 <cfelseif #LetterType# eq 3> NOID LIST</cfif></td>
	  </tr>
	</table>
	
	<cfquery dbtype="query" name="TenantList"> 
		select * from rs1 order by #sortBy#
	</cfquery>

	<form  name="SubmitNOID" action="act_SubmitNOID.cfm" method="post" class="cssform">
		<table cellSpacing="0" border="1" style="font-family: Arial; color: ##000000; border-collapse: collapse; font-size: 10pt; border: 1px solid ##C0C0C0; padding-left: 4; padding-right: 4; padding-top: 1; padding-bottom: 1" bordercolor="##000000" cellpadding="0" bordercolorlight="##C0C0C0" bordercolordark="##C0C0C0">
		<tr>
			<td width="198"><b>
				<a href="act_GETNOID.cfm?sortBy=cHouseName&scope=#scope#&period=#period#&lettertype=#lettertype#">
					House Name
				</a>
			</b></td>
			<td width="85"><b>
				<a href="act_GETNOID.cfm?sortBy=csolomonkey&scope=#scope#&period=#period#&lettertype=#lettertype#">
					Account Number
				</a>
			</b></td>
			<td width="89"><b>
				<a href="act_GETNOID.cfm?sortBy=cTenantName&scope=#scope#&period=#period#&lettertype=#lettertype#">
					Tenant Name
				</a>
			</b></td>
			<td width="84"><b>
				<a href="act_GETNOID.cfm?sortBy=cdescription&scope=#scope#&period=#period#&lettertype=#lettertype#">
					Pay type
				</a>
			</b></td>
			<td width="86"><b>
				<a href="act_GETNOID.cfm?sortBy=Total&scope=#scope#&period=#period#&lettertype=#lettertype#">
					Outstanding Balance
				</a>
			</b></td>
			<td width="86"><b>Deferred Payment</b></td>
			<cfif #LetterType# eq 3>
				<td width="108"><b>Letter 3 sent </b></td>
				<td width="108"><b>NOID Process initiated MM/DD/YYYY</b></td>
			</cfif>
			<td width="107"><span class="style1">Exempt</span></td>
			<td width="481"><b>Notes</b></td>
		</tr>
		<input type="hidden" name="Stage" value="#LetterType#" />
		<input type="hidden" name="Period" value="#Period#" />
		<CFLOOP QUERY="TenantList">
				<tr>
					<input type="hidden" name="cSolomonkey" value="#csolomonkey#" />
					
					<td <cfif #dtexempt# neq '1900-01-01 00:00:00.000' and #dtexempt#  neq ''> bgcolor="##FFCC66"</cfif>>
						#cHouseName#
					</td>
					<td <cfif #dtexempt# neq '1900-01-01 00:00:00.000' and #dtexempt#  neq ''> bgcolor="##FFCC66"</cfif>>
						#csolomonkey#
					</td>
					<td <cfif #dtexempt# neq '1900-01-01 00:00:00.000' and #dtexempt#  neq ''> bgcolor="##FFCC66"</cfif>>
						#cTenantName#
					</td>
					<td <cfif #dtexempt# neq '1900-01-01 00:00:00.000' and #dtexempt#  neq ''> bgcolor="##FFCC66"</cfif>>
						#cdescription#
					</td>
					<td <cfif #dtexempt# neq '1900-01-01 00:00:00.000' and #dtexempt#  neq ''> bgcolor="##FFCC66"</cfif>>
						#dollarformat(Total)#
					</td>
					<!--- Proj 36359 - 8/3/2009 - rts - Deferred Payment display --->
						<cfif #bDeferredPayment# eq '1'>
							<cfset DeferredPymnt = 'Yes'>
						<cfelseif #bDeferredPayment# eq '0'>
							<cfset DeferredPymnt = 'No'>
						<cfelseif #bDeferredPayment# eq ''>
							<cfset DeferredPymnt = 'No Data Provided'>
						</cfif>
					<td>
						#DeferredPymnt#
					</td>
					<!--- End #36359# --->
					<cfif #LetterType# eq 3>
					<td nowrap <cfif #dtexempt# neq '1900-01-01 00:00:00.000' and #dtexempt#  neq ''> bgcolor="##FFCC66"</cfif>>
						<input name="thirdletter_#csolomonkey#" type="checkbox"  onClick="DisBox('thirdletter_#csolomonkey#','#csolomonkey#')" value="1" 
							<cfif #bIsLetterSent# eq 1>
								checked 
							</cfif> 
							<cfif (#dtthirdletter# neq '1900-01-01 00:00:00.000' and #dtthirdletter#  neq '') or ( #dtissue# neq '1900-01-01 00:00:00.000' and #dtissue#  neq '')>  
								disabled="true"
							</cfif>
						>
						<input name="thirdletterdate_#csolomonkey#" type="text" size="10" maxlength="10" readonly="true" <cfif #dtthirdletter# eq '' or #dtthirdletter# eq '1900-01-01 00:00:00.000'> Value="" <cfelse>Value="#dateformat(dtthirdletter,"MM/DD/YYYY")#" readonly="true" </cfif>>
						<!---<a href="javascript:show_calendar4('document.SubmitNOID.issuedate_#csolomonkey#', document.SubmitNOID.issuedate_#csolomonkey#.value);"><img src="cal.gif" width="16" height="16" border="0" alt="Click Here to Pick up the timestamp"></a>--->
					</td>
					<td nowrap <cfif #dtexempt# neq '1900-01-01 00:00:00.000' and #dtexempt#  neq ''> bgcolor="##FFCC66"</cfif>>
						<input name="issuedate_#csolomonkey#" type="text"  SIZE=10 maxlength=10  
						<cfif #dtissue# eq '' or #dtissue# eq '1900-01-01 00:00:00.000'> Value="" <cfelse>Value="#dateformat(dtissue,"MM/DD/YYYY")#" readonly="true" </cfif>
						
						>
						<a href="javascript:show_calendar4('document.SubmitNOID.issuedate_#csolomonkey#', document.SubmitNOID.issuedate_#csolomonkey#.value);"><img src="cal.gif" alt="Click Here to Pick up the timestamp" name="calendar_#csolomonkey#" width="16" height="16" border="0"></a>
					</td>
					</cfif>
					<td nowrap <cfif #dtexempt# neq '1900-01-01 00:00:00.000' and #dtexempt#  neq ''> bgcolor="##FFCC66"</cfif>>
						<input name="delete_#csolomonkey#" type="checkbox" value="1" style="border: 1px solid ##FF0000" onClick="DisDeleteBox('delete_#csolomonkey#','#csolomonkey#')" 
							<cfif #dtexempt# neq '1900-01-01 00:00:00.000' and #dtexempt#  neq ''>
								checked 
							</cfif> 			
						>
						<input name="exemptdate_#csolomonkey#" type="text" size="10" maxlength="10" readonly="true" <cfif #dtexempt# eq '' or #dtexempt# eq '1900-01-01 00:00:00.000'> Value="" <cfelse>Value="#dateformat(dtexempt,"MM/DD/YYYY")#" readonly="true" </cfif>>
				  </td>
					<td <cfif #dtexempt# neq '1900-01-01 00:00:00.000' and #dtexempt#  neq ''> bgcolor="##FFCC66"</cfif>><input name="notes_#csolomonkey#" type="text" size="75" maxlength="100" <cfif #cNotes# eq ''> Value="" <cfelse>Value="#cNotes#"</cfif>>
					</td>
				</tr>
			</CFLOOP>
				<tr>
				<cfif ListFindNoCase(session.groupid, 240, ",") gt 0> 
				<td>
					<!---<input type="button" value="Submit" onClick="SubmitForm(this)">--->
					<input name="SubmitButton" type="submit">
					<input type="reset" value="Clear" />
				</td>
				</cfif>
				</tr>
		</TABLE>
	</form>
	<p class="style2">  
		<a href="dsp_NOIDMain.cfm">
			Back
		</a>
	</p>	 	
</cfoutput>
</body>
</html>

