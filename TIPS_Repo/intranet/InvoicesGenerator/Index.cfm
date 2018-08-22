<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<title>Invoices Generator</title>
<!---
/*                                                                                     */
/*                   CHANGES                                                           */
/* 04-01-2014 S Farmer 113458 removed reference for emailing invoice file to Spectrum  */
 --->
<link href="Styles/Index.css" rel="stylesheet" type="text/css" />
<script src="JavaScript/Functions.js"></script>
<script src="JavaScript/ts_picker.js"></script>
<script>
	window.onload=createhintbox;
</script>
</head>

<body>
	<cfparam name="Form.Period" default="">

	<cfset TotalInvoices = 0>
	<cfset house = ''>
	<cfset Payments = 0>
	<cfset TotalPayments = 0>
	<cfset ABSPayments = 0>
	<cfset ABSTotalPayments = 0>
	<cfset TotalPaymentsCount = 0>
	<cfset NbrOfPayments = 0>
	<cfset Charges = 0>
	<cfset TotalCharges = 0>
	<cfset ABSCharges = 0>
	<cfset ABSTotalCharges = 0>
	<cfset TotalChargesCount = 0>
	<cfset NbrOfCharges = 0>
	<cfset subject = "ALC Invoices statements for ">

	<!--- Get Houses Information for the Drop Down --->
	<cfquery name="GetHouses" datasource="#application.datasource#">
		select cname 
		from House h
		where h.dtrowdeleted is  null
		and h.bIsSandbox = 0
		order by cname 
	</cfquery>
		 
	<center>
	  <img src="../images/ALC%20Logo.jpg" align="top">
	</center>
	
	<cfif dateformat(now(),"MM") eq 12>
	  <cfset CurrentYear = dateformat(now(),"YYYY") + 1>
	<cfelse>
	  <cfset CurrentYear = dateformat(now(),"YYYY")>
	</cfif>
	
	<table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="14%">
		<form name="EFTform" action="EFT_Update.cfm" method="post">
				<tr>
				  <td width="36%" align="center">
				    <b>Period</b>
				  </td>
				  <td width="64%" align="center">
				    <b>
				  	  EFTDate
					  <a href="#" class="hintanchor" onMouseover="showhint('Format: MM/DD/YYYY', this, event, '150px')">[?]</a>
					</b>
				  </td>
				</tr>
				
					<cfquery name="GetEFT" datasource="#application.datasource#">
						select case when dteft like '%1900%' then null else dteft end as dteft
						from EFTCalendar 
						where cAppliesToAcctPeriod like '#CurrentYear#%'
					</cfquery>
					
					<cfoutput query="GetEFT">
					<tr>
					<td width="36%">
						<center>				
							<input name="Period" type="text" class="hintanchor" value="#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#" 
							size="6" maxlength="6" readonly>
						</center>
					</td>
					<td width="64%">
						<input name="EFTDate_#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#" type="text" 
						class="hintanchor" size="8" maxlength="8" VALUE='#DATEFORMAT(GetEFT.dtEFT,"MM/DD/YYYY")#'>
						<center>
							<a href="javascript:show_calendar4('document.EFTform.EFTDate_#CurrentYear##NumberFormat(GetEFT.currentrow,
							 '09')#',document.EFTform.EFTDate_#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#.value);">
							<img src="Images/cal.gif" width="16" height="16" border="0" alt="Click Here to Pick up the timestamp"></a>
						</center>
					</td>					
				</tr>
					</cfoutput>
				<tr>
					<td height="36" colspan="2"><font size="1" color="FF0000">
						<div align="center">
							<input name="run" type="submit" value="Submit">        
							<input type="reset" name="Reset" value="Reset">
					  </div></font>
					</td>
				</tr>
				
		</form>		
	</table>
	
	<p>

<form  name="invoicesform" action="act_GenerateInvoices.cfm" method="post" onSubmit="return validateFields();">
<table width="34%" height="22%" border="1" cellpadding="1" cellspacing="1" bordercolor="gray" bordercolorlight="#C0C0C0" 
bordercolordark="#C0C0C0" style="border-collapse: collapse">
	<tr>
    	<th height="40" colspan="4">
			<b><font face="Arial">Invoices Data Generator</font></b>
			<a href="#" class="hintanchor" onMouseover="showhint('Please select house(s).', this, event, '150px')">[?]</a>
		</th>
  	</tr>
  	<tr>
    	<td width="45%" height="32" nowrap>
			<font face="Arial" size="2" color="#0000FF"><b>Scope</b></font>
		</td>
    	<td width="55%" height="32">
			<select name ="FeatureScope" size="10"  multiple>
				<cfloop query="GetHouses">
					<cfoutput>
						<option value="'#GetHouses.cName#'">#GetHouses.cName#</option>
					</cfoutput>
				</cfloop>
		  </select>
        </td>
        <td align="center" valign="middle">
            <input type="Button" value="Add >>" style="width:100px" onClick="SelectMoveRows(document.invoicesform.FeatureScope,document.invoicesform.Scope)">
			<br><br>
            <input type="Button" value="<< Remove" style="width:100px" onClick="SelectMoveRows(document.invoicesform.Scope,document.invoicesform.FeatureScope)">
        </td>
        <td>
            <select name="Scope" size="10" MULTIPLE>

            </select>
		</td>
  	</tr>
  	<tr>
    	<td width="45%" height="33" nowrap><font face="Arial" size="2" color="#0000FF">
			<b>Accounting Period</b></font>
		</td>
	  <td width="55%" height="33">
			<input name="Period" type="text" size="6" maxlength="6"><a href="#" class="hintanchor" 
			onMouseover="showhint('Please enter Accounting Period (e.g. 200709).', this, event, '150px')">[?]</a>
		 	<input name="EFTdate" type="hidden" value="">
	  </td>
  	</tr>
  	<tr>
    	<td width="45%" height="32" nowrap><font face="Arial" size="2" color="#0000FF">
    		<b>Solomon Key</b></font>
		</td>
    	<td width="55%" height="32" bgcolor="#FFFFFF">
	  		<input name="Solomonkey" type="text" size="9" maxlength="8"><a href="#" class="hintanchor" 
			onMouseover="showhint('Solomon Key is optional.  We can leave it blank.', this, event, '150px')">[?]</a> 
		</td>
  	</tr>
  	<tr>
    	<td width="45%" height="32" nowrap><font face="Arial" size="2" color="#0000FF">
    		<b>Move current files<br>
			to History?</b></font>
		</td>
    	<td width="55%" height="32" bgcolor="#FFFFFF">
	  		<input type="checkbox" name="BackupFiles" value="Yes" checked>
		</td>
  	</tr>
  	<tr>
    	<td height="36" colspan="2"><font size="1" color="#FF0000">
      		<div align="center">
				<input name="run" type="submit" value="Submit">        
				<input type="reset" name="Reset" value="Reset">
   		  </div>
		</td>
	</tr>
</table>
</form>

<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoiceDetails" filter="#fileInvoicesDetails#">

<CFIF qInvoiceDetails.RecordCount GT 0> 
	<cfoutput>
		<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoiceDetails" filter="#fileInvoicesDetailsCSV#">
		<CFIF qInvoiceDetails.RecordCount GT 0>
			<cffile action="read" file="#fileDirectory#\#fileInvoicesDetailsCSV#" variable="csvFile">
			
			<cfset houseArray = ListToArray(csvFile, chr(10))>
            <cfset ArrayDeleteAt(houseArray,1)> <!--- Throws out the Column header as part of the array --->
			<cfset houseNames = Arraynew(1)>
			<cfset houseInvoices = 1>
            <cfset count = 0>
			<cfset currentHouse = houseArray[1]>
            
			<table border="1" cellpadding="1" cellspacing="1" style="border-collapse: collapse" bordercolor="gray" width="22%">
            	<tr><td></td><th>House</th><th>Num of Invoices</th></tr>
            <cfloop from="1" to="#ArrayLen(houseArray)#" index="i">
				<cfif i eq ArrayLen(houseArray) OR  (i lt ArrayLen(houseArray) AND  houseArray[i] neq currentHouse)>
					<cfset temp = ArrayAppend(houseNames,currentHouse)>
					<cfset currentHouse = houseArray[i]>
                    <cfset TotalInvoices = TotalInvoices + houseInvoices>
                    <cfset count = count + 1>
                    <tr><td>#count#</td><td>#houseArray[i-1]#</td><td>#houseInvoices#</td></tr>
                    <cfset houseInvoices = 0>
				</cfif>
                <cfset houseInvoices = houseInvoices + 1>
			</cfloop>
            	<tr><td></td><td>Total</td><td>#TotalInvoices#</td></tr>
            </table>
			
		</CFIF>

		<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoicePayments" filter="#fileInvoicesPaymentsCSV#">
		<CFIF qInvoicePayments.RecordCount GT 0>
			<cffile action="read" file="#fileDirectory#\#fileInvoicesPaymentsCSV#" variable="csvFile">
			<cfloop index="index" list="#csvfile#" delimiters="#chr(10)##chr(13)#"> 
				<cfif #listgetAt('#index#',1)# neq 'AccountNumber'>	
					<cfset NbrOfPayments = #NbrOfPayments# + 1>
					<cfset Payments = #listgetAt('#index#',2)# + #Payments#>
					<cfset ABSPayments = #abs(listgetAt('#index#',2))# + #ABSPayments#>
				</cfif>
			</cfloop>
		</CFIF>
	
		<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoiceCharges" filter="#fileInvoicesChargesCSV#">
		<CFIF qInvoiceCharges.RecordCount GT 0>	
			<cffile action="read" file="#fileDirectory#\#fileInvoicesChargesCSV#" variable="csvFile">
			<cfloop index="index" list="#csvfile#" delimiters="#chr(10)##chr(13)#"> 
				<cfif #listgetAt('#index#',1)# neq 'AccountNumber'>	
					<cfset NbrOfCharges = #NbrOfCharges# + 1>
					<cfset Charges = (#listgetAt('#index#',2)# * #listgetAt('#index#',3)#)>
					<cfset Totalcharges = #Totalcharges# + #Charges#>
					
					<cfset ABSCharges = (#listgetAt('#index#',2)# * #abs(listgetAt('#index#',3))#)>
					<cfset ABSTotalCharges = #ABSTotalCharges# + #ABSCharges#>
				</cfif>
			</cfloop>
		</CFIF>
	</cfoutput>
	
    <BR>
	Houses Not in File<br>
    
    <cfquery name="ZeroInvoices" dbtype="query">
    	Select cName
        from GetHouses
        where cName not in ('#arraytolist(HouseNames,"','")#')
    </cfquery>
    
	<table border="1" cellpadding="1" cellspacing="1" style="border-collapse: collapse" bordercolor="gray" width="22%" bgcolor="##FF0000">
    <cfoutput query="ZeroInvoices">
    	<tr><td>#ZeroInvoices.cName#</td></tr>
    </cfoutput>
    </table>

	<cfoutput>

	<br>	
	<table border="1" cellpadding="1" cellspacing="1" style="border-collapse: collapse" bordercolor="gray" width="22%">
		<tr>
			<th width="100%">
				<strong>View existing data files</strong> 
				<a href="##" class="hintanchor" 
				onMouseover="showhint('You can view the invoices files before you FTP to Spectrum.', this, event, '150px')">[?]</a>
			</th>
		</tr>
		<tr>
			<td width="100%">
				<a href="#fileDirectory#\#fileInvoicesDetails#" target="_blank">Details</a>
			</td>
		</tr>
		<tr>
			<td width="100%">
				<a href="#fileDirectory#\#fileInvoicesPayments#" target="_blank">Payments</a>
			</td>
		</tr>
		<tr>
			<td width="100%">
				<a href="#fileDirectory#\#fileInvoicesCharges#" target="_blank">Charges</a>
			</td>
		</tr>
	</table>

		<br>
	 <form name="FTPform" action="act_FTP.cfm" method="post" onSubmit="return validateDistributionList();">
	  <table border="1" cellpadding="1" cellspacing="1" style="border-collapse: collapse" bordercolor="gray" width="50%">
			<tr>
				<td width="16%" nowrap><strong>Invoices:</strong></td>
					<td width="16%" nowrap>
						<input name="TotalInvoices" type="text" value="#TotalInvoices#" size="9" maxlength="8" readonly> 
					</td>
				<td width="68%" colspan="4" >* Extra Null Invoice added to Total.  Is sent back to Corprate office.</td>
		  	</tr>
		  	<tr>
				<td width="16%" nowrap><strong>Payments:</strong></td>
				<td width="16%" nowrap>
					<input name="NbrOfPayments" type="text" value="#NbrOfPayments#" size="15" maxlength="15" readonly> 
				</td>
				<td width="17%" nowrap><strong>Sum Total:</strong></td>
				<td width="17%" nowrap>
					<input name="Payments" type="text" value="#decimalformat(Payments)#" size="15" maxlength="15" readonly> 
				</td>
				<td width="17%" nowrap><strong>Absolute Total:</strong></td>
				<td width="17%" nowrap>
					<input name="ABSPayments" type="text" value="#decimalformat(ABSPayments)#" size="15" maxlength="15" readonly> 
				</td>
		  	</tr>
		  	<tr>
				<td width="16%" nowrap><strong>Charges:</strong></td>
				<td width="16%" nowrap>
					<input name="NbrOfCharges" type="text" value="#NbrOfCharges#" size="15" maxlength="15" readonly> 
				</td>
				<td width="17%" nowrap><strong>Sum Total:</strong></td>
				<td width="17%" nowrap>
					<input name="Totalcharges" type="text" value="#decimalformat(Totalcharges)#" size="15" maxlength="15" readonly> 
				</td>
				<td width="17%" nowrap><strong>Absolute Total:</strong></td>
				<td width="17%" nowrap>
					<input name="ABSTotalCharges" type="text" value="#decimalformat(ABSTotalCharges)#" size="15" maxlength="15" readonly> 
				</td>
		  	</tr>
	  </table>
  </cfoutput>
  
  <br>        
<!--- 	113458	<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="gray" width="50%">
			<tr>
				<td width="100%" colspan="2">
					<strong>Distribution List: 
						<a href="#" class="hintanchor" 
						onMouseover="showhint('You can edit the distrubution list (use ; to seperate the list)', this, event, '150px')">[?]</a>
					</strong>
				</td>
			</tr>
			<tr>
				<td width="10%">Subject:</td>
				<td width="90%"><cfoutput>
					<input name="EmailSubject" type="text" value="#subject#" size="50" maxlength="200"> 
				</td>
			</tr>
			<tr>
				<td width="10%">To:</td>
				<td width="90%">
					<input name="ToMail" type="text" value="#tomailList#" size="100" maxlength="200"> 
				</td>
			</tr>
			<tr>
				<td width="10%">CC:</td>
				<td width="90%">
                  <input name="CCMail" type="text" value="#ccmailList#" size="100" maxlength="200">
			</td>
				</tr></cfoutput>
			
			<tr>
				<td width="100%" colspan="2">
					<strong>
						FTP to Spectrum 
						<a href="#" class="hintanchor" 
						onMouseover="showhint('If the invoices data files are ready to send, click Go to FTP to Spectrum.', this, event, '150px')">[?]</a>
						<input type="submit" name="run" value="Go">
					</strong>
				</td>
			</tr>
		</table> --->
		</form>	
		<br>
		<form action="act_DeleteInvoices.cfm" method="post" onsubmit="return confirmSubmit()">
		<table width="34%" height="10%" border="0" cellspacing="1" bordercolor="#111111" bordercolorlight="#C0C0C0" 
		bordercolordark="#C0C0C0" style="border-collapse: collapse">
			<tr>
				<td height="37" colspan="2" nowrap>
					<b><font face="Arial">Delete generated data files</font></b>
					<a href="#" class="hintanchor" 
					onMouseover="showhint('If you make a mistake and want to re-generate all invoices, please delete the existing invoices and start over.', this, event, '150px')">[?]</a>
			 		<input name="run" type="submit" class="style1" value="Delete">
				</td>
			</tr>
		  </table>
		</form>
</CFIF>

</body>
</html>
