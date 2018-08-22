<!--- ------------------------------------------------------------------------------------------
 sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                           |
 sfarmer     | 11/20/2012 |tickets 97882, 95010, 95009, 95468, 97570, 97710 for  misc. updates |
 sfarmer     | 08/08/2013 |project 106456 EFT Updates                                          |
-----------------------------------------------------------------------------------------------> 
<!--- Include Intranet Header --->
	<cfinclude template="../../header.cfm">
	<h1 class="PageTitle"> Tips 4 - Tenant EFT Information Edit </h1>
	
	<cfinclude template="../Shared/HouseHeader.cfm">
	
	<!--- Retreive list of State Codes, PhoneType, and Tenant Information --->
	<cfinclude template="../Shared/Queries/StateCodes.cfm">
	<cfinclude template="../Shared/Queries/PhoneType.cfm">
	<cfinclude template="../Shared/Queries/TenantInformation.cfm">
	<!--- <cfinclude template="../Shared/Queries/Residency.cfm"> --->
	<cfinclude template="../Shared/Queries/SolomonKeyList.cfm">
	<cfquery name="TenantInfo" DATASOURCE="#APPLICATION.datasource#">
		SELECT  t.cSolomonKey, t.iTenant_ID, t.cemail,
		t.cFirstName, t.cMiddleInitial, t.cLastName,	 
		ts.bIsPrimaryPayer, bExEFTSrvFee, bUsesEFT
		FROM tenant t
		join tenantstate ts on t.itenant_id = ts.itenant_id
		Where t.iTenant_ID = #url.iTenant_ID#
	</cfquery>
	<cfquery name="EFTinfo" datasource="#application.datasource#">
		Select cRoutingNumber, cAccountNumber, cAccountType, dtBeginEFTDate,
			dtEndEFTDate, iOrderofPull, iDayofFirstPull,dPctFirstPull, dAmtFirstPull,
			iDayofSecondPull,dPctSecondPull, dAmtSecondPull, dtRowDeleted 
		FROM EFTAccount where iEFTAccount_ID =   #url.iEFTAccount_ID#  
	</cfquery>
	
	<cfquery name="qryContactPrimary"  datasource="#application.datasource#"> 
		SELECT count(LTC.bIsPrimaryPayer) as 'ContactEFT'
		FROM   linktenantcontact LTC  
		WHere  LTC.itenant_id = #TenantInfo.itenant_id#
		and LTC.bIsPrimaryPayer = 1
	</cfquery>	
	
	<cfquery name="qryContactGuarantor"  datasource="#application.datasource#">  
		SELECT count(LTC.bIsGuarantorAgreement)  'Guarantor'
		FROM   linktenantcontact LTC  
		WHere  LTC.itenant_id = #TenantInfo.itenant_id#
		and   LTC.bIsGuarantorAgreement = 1	
	</cfquery>
	
	<cfif ((IsDefined ('url.cid')) and (url.cid is not ""))>
		<cfquery name="qryContactInfo"  datasource="#application.datasource#"> 
			SELECT C.iContact_ID
			,C.cFirstName
			,C.cLastName
			,C.cPhoneNumber1
			,C.iPhoneType1_ID
			,C.cPhoneNumber2
			,C.iPhoneType2_ID
			,C.cPhoneNumber3
			,C.iPhoneType3_ID
			,C.cAddressLine1
			,C.cAddressLine2
			,C.cCity
			,C.cStateCode
			,C.cZipCode
			,C.cComments
			,C.dtAcctStamp
			,C.iRowStartUser_ID
			,C.dtRowStart
			,C.iRowEndUser_ID
			,C.dtRowEnd
			,C.iRowDeletedUser_ID
			,C.dtRowDeleted
			,C.cRowStartUser_ID
			,C.cRowEndUser_ID
			,C.cRowDeletedUser_ID
			,C.cEmail
			,LTC.bIsEFT
			,LTC.bIsPrimaryPayer
			,LTC.bIsGuarantorAgreement
			
			FROM  Contact	 C
			join linktenantcontact LTC on C.iContact_ID = LTC.iContact_ID and LTC.itenant_id = #TenantInfo.itenant_id#
			WHere C.iContact_ID = #url.cid#
		</cfquery>
	</cfif>
<script language="JavaScript" type="text/javascript" src="../Shared/JavaScript/global.js"></script>
 	
	<script>
		function CloseThis() { 
		// alert(document.getElementById('iEFTAccount_ID').value + " : " + document.getElementById('iTenant_ID').value + " : " + document.getElementById('tenantSolomonKey').value );
		tenantID = document.getElementById('iTenant_ID').value;
		EFTAccountID = document.getElementById('iEFTAccount_ID').value;
		SolomonKey = document.getElementById('tenantSolomonKey').value;
		valdata = 'iEFTAccount_ID=' + document.getElementById('iEFTAccount_ID').value + '&iTenant_ID=' + document.getElementById('iTenant_ID').value + '&tenantSolomonKey=' + document.getElementById('tenantSolomonKey').value + '&closethis=Y';
		newlocation = 'TenantEFTEditUpdate.cfm?' + valdata;
		window.location =  newlocation   ; 
		}
		
		
		function ReopenThis() { 
		// alert(document.getElementById('iEFTAccount_ID').value + " : " + document.getElementById('iTenant_ID').value + " : " + document.getElementById('tenantSolomonKey').value );
		tenantID = document.getElementById('iTenant_ID').value;
		EFTAccountID = document.getElementById('iEFTAccount_ID').value;
		SolomonKey = document.getElementById('tenantSolomonKey').value;
		CID = document.getElementById('CID').value;		
		valdata = 'iEFTAccount_ID=' + document.getElementById('iEFTAccount_ID').value + '&iTenant_ID=' + document.getElementById('iTenant_ID').value + '&CID=' + document.getElementById('CID').value + '&tenantSolomonKey=' + document.getElementById('tenantSolomonKey').value + '&reopenthis=Y';
		newlocation = 'TenantEFTEditUpdate.cfm?' + valdata;
		window.location =  newlocation   ; 
		}
		function LeadingZeroNumbers(string) {
		for (var i=0, output='', valid="1234567890."; i<string.length; i++)
		   if (valid.indexOf(string.charAt(i)) != -1)
			  output += string.charAt(i)
		return output;	
		} 
		function onlyNumbers(evt)
		{
			var e = event || evt; // for trans-browser compatibility
			var charCode = e.which || e.keyCode;
		
			if (charCode > 31 && (charCode < 48 || charCode > 57))
				return false;
		
			return true;
		
		}	
		function required() { 
			if  ( document.getElementById("cRoutingNumber").value == ''
			|| document.getElementById("cRoutingNumber").value.length != 9)  {
				alert('Routing number is required and must be 9 digits long. Please enter or correct routing number.');
				document.getElementById("cRoutingNumber").style.background = 'white';
				document.getElementById("cRoutingNumber").focus();
				return false;
			}	
			if   (document.getElementById("cAccountNumber").value == '')  {
				alert('Account Number is required! Please  enter.');
				document.getElementById("cAccountNumber").style.background = 'white';
				document.getElementById("cAccountNumber").focus();
				return false;
			}
			/* TPecku commented out the email validation block */	
		 	/*if   (document.getElementById("cEmail").value == '' && document.getElementById("PrimAcct").checked == '')  {
		 		alert('Email is required! Please enter.');
		 		document.getElementById("cEmail").style.background = 'white';
		 		document.getElementById("cEmail").focus();
		 		return false;
		 	}		
			if   (document.getElementById("confirmcEmail").value != document.getElementById("cEmail").value)  {
				alert('Email entries must match! Please  correct.');
				document.getElementById("cEmail").style.background = 'white';
				document.getElementById("confirmcEmail").style.background = 'white';				
				document.getElementById("cEmail").focus();
				return false;
			}*/				
	
		}
		function chktoolargefrst(){
			if (document.getElementById("dPctFirstPull").value > 100)
				{
				alert('Pull percentage cannot be greater than 100%');
				document.getElementById("dPctFirstPull").focus();
				}
		} 
		function frstnotboth(){
			if (document.getElementById("dAmtFirstPull").value > 0   && document.getElementById("dPctFirstPull").value > 0)
				{
				alert('Do not enter both a Percentage pull and an Amount Pull');
				document.getElementById("dPctFirstPull").focus();
				}
		} 		
		function chktoolargescnd(){
			if (document.getElementById("dPctSecondPull").value > 100)
				{
				alert('Pull percentage cannot be greater than 100%');
				document.getElementById("dPctSecondPull").focus();
				}
		} 
		function scndnotboth(){
			if (document.getElementById("dAmtSecondPull").value > 0 && document.getElementById("dPctSecondPull").value > 0)
				{
				alert('Do not enter both a Percentage pull and an Amount Pull');
				document.getElementById("dPctSecondPull").focus();
				}
		} 		
	</script>
 
<cfoutput query="EFTinfo">
<!--- iEFTAccount_ID=#iEFTAccount_ID#<br />
iTenant_ID=#iTenant_ID#<br />datebegineft
tenantSolomonKey=#tenantSolomonKey#<br /> --->
	<form name="TenantEFTDetailEdit" method="post" action="TenantEFTEditUpdate.cfm" id="TenantEFTDetailEdit" onSubmit="return required();">
	<input type="hidden"  name="iEFTAccount_ID"   id="iEFTAccount_ID"   value="#iEFTAccount_ID#">
	<input type="hidden"  name="iTenant_ID"       id="iTenant_ID"       value="#iTenant_ID#">
	<input type="hidden"  name="tenantSolomonKey" id="tenantSolomonKey" value="#tenantSolomonKey#">
	<cfif ((  IsDefined('url.CID')) and (url.CID is not ""))>	
		<input type="hidden"  name="CID" 			  id="CID" 				value="#url.CID#">	
	<cfelse>
		<input type="hidden"  name="CID" 			  id="CID" 				value="">	
	</cfif>		
	<table width="100%" cellpadding="0" cellspacing="0" >
		<tr  class="Large">
			<td colspan="3" align="center" >Resident: #TenantInfo.cfirstname# #TenantInfo.clastname#</td>
		</tr>	
		<cfif ((  IsDefined('url.CID')) and (url.CID is not ""))>
		<tr  class="Large">
			<td colspan="3" align="center" >Contact: #qryContactInfo.cfirstname# #qryContactInfo.clastname#</td>
		</tr>	
		</cfif>		
		<tr  class="Large">
			<td colspan="3" align="center" >Make Changes/Corrections as necessary, click the "Save" button to complete the transaction.</td>
		</tr>
		<tr>
			<td colspan="3" id="Message" style="background:white;color:red;text-align:center;font-weight:bold;font-size:x-small;"> 
				Required are listed in red. 
			</td>
		</tr>	
		<cfif eftinfo.dtRowDeleted is "" <!--- and eftinfo.dtRowEnd is ""  ---> and TenantInfo.bUsesEFT is "1">
		<tr class="evenRow">
			<td colspan="3">End/Cancel this EFT transaction <input type="checkbox" name="closethis" value="Y"  onclick="CloseThis()"/></td>
		</tr>	
		<cfelse>
		<tr class="evenRow">
			<td colspan="3"  class="required">This EFT is not current, Select to Reinstate this EFT Transaction <input type="checkbox" name="reopenthis" value="Y"  onclick="ReopenThis()"/></td>
		</tr>	
		</cfif>		
		<cfif ((  IsDefined('url.CID')) and (url.CID is not ""))>
		<tr>
			<td colspan="3" >Contact EFT Information:</td>
		</tr>	
		</cfif>	
		<tr class="oddRow">
			<td class="required">Routing Number</td>
			<td  colspan="2" ><input type="text" name="cRoutingNumber"  id="cRoutingNumber" value="#cRoutingNumber#" onKeyPress="return onlyNumbers();"/></td>
			
			
		</tr>	
		<tr class="evenRow">
			<td class="required">Account Number</td>
			<td  colspan="2" ><input type="text" name="cAccountNumber"  id="cAccountNumber" value="#cAccountNumber#" size=17 maxlength=17 onKeyPress="return onlyNumbers();"/></td>

		</tr>
		<tr class="oddRow">
			<td class="required">Account Type</td>
			<td  colspan="2" ><input type="radio" name="cAccountType" Value="c"<cfif cAccountType is "c"> CHECKED</cfif>>  Checking
				<input type="radio" name="cAccountType" Value="s"<cfif cAccountType is "s"> CHECKED</cfif>> Savings</td>		
		</tr>
		<tr class="evenRow">
			<td>Begin EFT Date</td>
			<td>End EFT Date</td>
			<td>Order of Pull </td>
 
		</tr>
		<tr class="evenRow">
			<td><input  type="text" name="dtBeginEFTDate"  id="dtBeginEFTDate" value="#dateformat( dtBeginEFTDate,'mm-dd-yyyy' )#" />   </td>
			<td><input  type="text" name="dtEndEFTDate"  id="dtEndEFTDate" value="#dateformat( dtEndEFTDate,'mm-dd-yyyy' )#" />  </td>
			<td><input  type="text" name="iOrderofPull"  id="iOrderofPull" value="#iOrderofPull#" size="5"/> </td>
		</tr>
		<tr class="oddRow">
			<td>Day of First Pull</td>
			<td>Pct First Pull</td>
			<td>Amt First Pull</td>
		</tr>		
		<tr class="oddRow">
			<td>
				<select name="iDayofFirstPull" id="iDayofFirstPull">
					<option>#EFTinfo.iDayofFirstPull#</option>
					<cfloop from="5" to="25" index="i">
					<option>#i#</option>
					</cfloop>
				</select>
			</td>
			<td><input  type="text" name="dPctFirstPull"  id="dPctFirstPull" value="#dPctFirstPull#"   size="5"   onkeyup="this.value=LeadingZeroNumbers(this.value);" onblur="chktoolargefrst()"/></td>
			<td><input  type="text" name="dAmtFirstPull"  id="dAmtFirstPull" value="#dAmtFirstPull#"  size="10"   onkeyup="this.value=LeadingZeroNumbers(this.value);" onblur="frstnotboth(); this.value=cent(round(this.value));"/></td>
		</tr>
		<tr class="evenRow">
			<td>Day of Second Pull</td>
			<td>Pct Second Pull</td>
			<td>Amt Second Pull</td>
		</tr>			
		<tr class="evenRow">
			<td>
				<select name="iDayofSecondPull" id="iDayofSecondPull">
					<option>#EFTinfo.iDayofSecondPull#</option>
					<option> </option>
					<cfloop from="5" to="25" index="i">
					<option>#i#</option>
					</cfloop>
				</select>
			</td>
			<td><input  type="text" name="dPctSecondPull"  id="dPctSecondPull" value="#dPctSecondPull#"  size="5"   onkeyup="this.value=LeadingZeroNumbers(this.value);"  onblur="chktoolargescnd()" /></td>
			<td><input  type="text" name="dAmtSecondPull"  id="dAmtSecondPull" value="#dAmtSecondPull#"  size="10"  onkeyup="this.value=LeadingZeroNumbers(this.value);" onblur="scndnotboth(); this.value=cent(round(this.value));"/></td>
		</tr>	

		<cfif ((  IsDefined('url.CID')) and (url.CID is not ""))>	
		<cfif qryContactInfo.bIsPrimaryPayer is 1 and qryContactInfo.bIsEFT is 1>		
		 		<TR>
					<TD colspan="3">This is the Primary Account:
					<br/><input type="checkbox" id="PrimAcct" name="PrimAcct" size="1"   maxlength="1" value="N">Check to drop as primary account"</INPUT>
					</TD>
				</TR>						
			<cfelseif TenantInfo.bIsPrimaryPayer is 1>
			 	<tr>
					<td colspan="3">The tenant is the primary account. To change, remove the tenant as the primary account first.</td>
				</tr>
			<cfelseif qryContactInfo.bIsGuarantorAgreement is "">	
				<tr>
			 		<td colspan="3">A different account is the primary account. To change, remove the account that is the current primary account and file the appropriate guarantor papers first. </td>
				</tr>			
			<cfelse>
			 	<TR>
					<TD colspan="3">Is this Contact the Primary Account?: 
					<br /> <input type="checkbox" id="PrimAcct" name="PrimAcct" size="1"   maxlength="1" value="Y" <cfif qryContactInfo.bIsPrimaryPayer is 1 and qryContactInfo.bIsEFT is 1> checked="checked"</cfif>>Check if "Yes"</INPUT>
					<br/><input type="checkbox" id="PrimAcct" name="PrimAcct" size="1"   maxlength="1" value="N">Check if "No", drop as primary account"</INPUT>
					</TD>
				</TR>
			</cfif>
		<!--- TPecku commented out a reference to email --->
		<!---<TR>
			<TD class="required" colspan="3">Contact Email: <input type="text" id="cEmail" name="cEmail" size="50"   maxlength="70" value="#qryContactInfo.cEmail#"></INPUT></TD>
		</TR>
		<TR>
			<TD class="required" colspan="3">Reenter (confirm) Contact Email: <input type="text" id="confirmcEmail" name="confirmcEmail" size="50"   maxlength="70" value="#qryContactInfo.cEmail#"></INPUT></TD>
		</TR>--->
		<cfelse>			
			<cfif qryContactGuarantor.Guarantor ge 1	>	
				<tr>
					<td colspan="3">The contact is the primary or guarantor account. To change, remove the contact as the primary or guarantor account first.</td>
				<input type="hidden" id="PrimAcct" name="PrimAcct" size="1"   maxlength="1" value="Y"       checked="checked">
				</tr>
			<cfelse>
				<TR>
					<TD colspan="3">Is the Tenant Account the Primary Account?: <!--- tenant account --->
					<br /> <input type="checkbox" id="PrimAcct" name="PrimAcct" size="1"   maxlength="1" value="Y" <cfif tenantinfo.bIsPrimaryPayer is 1> checked="checked"</cfif>>Check if "Yes"</INPUT>
					<br/><input type="checkbox" id="PrimAcct" name="PrimAcct" size="1"   maxlength="1" value="N">Check if "No", drop as primary account"</INPUT>
					</TD>
				</TR>
			</cfif>
<!--- 										<cfif TenantInfo.bExEFTSrvFee is "">
										<tr>
											<td colspan="2">This account is NOT EFT Service Fee Exempt.</td>
										</tr>
										<TR>
											<TD>Exempt from EFT Service Fee: <input type="checkbox" id="ExServiceFee" name="ExServiceFee" size="1" value="Y"   <cfif TenantInfo.bExEFTSrvFee is 1>checked="checked"</cfif>  ></input></TD>
											<TD>&nbsp;</TD>
										</TR>
										</cfif>
										<cfif TenantInfo.bExEFTSrvFee is 1>
										<tr>
											<td colspan="2">This account is EFT Service Fee Exempt.</td>
										</tr>
										<TR>
											<TD>Drop EFT Service Fee Exemption: <input type="checkbox" id="ExServiceFeeDrop" name="ExServiceFeeDrop" size="1" value="Y" ></input></TD>
											<TD>&nbsp;</TD>
										</TR>
										</cfif> --->
	<!--- TPecku commented out a reference to email --->
	<!---<TR>
			<TD class="required" colspan="3">Email: <input type="text" id="cEmail" name="cEmail" size="50"   maxlength="70" value="#TenantInfo.cEmail#"></INPUT></TD>
		</TR>
		<TR>
			<TD class="required" colspan="3">Reenter (Confirm) Email: <input type="text" id="confirmcEmail" name="confirmcEmail" size="50"   maxlength="70" value="#TenantInfo.cEmail#"></INPUT></TD>
		</TR>--->		
		</cfif>
		<tr>
			<td style="text-align: left;"><input class="SaveButton" type="Submit" name="Save" Value="Save"></td>
			<td ><input class="ReturnButton" type="button" name="ReturntoTenantEditPage" Value="Return"   onClick="location.href='TenantEdit.cfm?ID=#iTenant_ID#'"  ></td>
			<td>
				<cfscript>
				if (IsDefined("url.cid") AND url.cid EQ 0) { Script="newcontactdata();"; }
				else { Script=''; }
				</cfscript>
				<input class="DontSaveButton" type="button" name="DontSave" value="Don't Save" onClick="#SCRIPT# location.href='TenantEFTEdit.cfm?ID=#url.iTenant_ID#'">
			</td>
		</tr>
	</table>
</cfoutput>

 
		<!--- Include intranet footer --->
		<cfinclude template="../../footer.cfm">	
 
