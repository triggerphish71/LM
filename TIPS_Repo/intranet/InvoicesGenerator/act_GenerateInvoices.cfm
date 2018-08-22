<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!--- 
TICKET / Project          Date       BY             DESCRIPTION
90720					05/17/2012	SFarmer			Corrected output line for rs3 query type
 --->
<html>
<head>
    <title>act_GenerateInvoices</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    
    <link href="Styles/Index.css" rel="stylesheet" type="text/css" />
    <script src="JavaScript/Functions.js"></script>
</head>

<body>

<cfset LineCount = 0>
<cfset HouseName = ''>
		
<cfset subject = "ALC Invoices statements for ">
<cfparam name="form.BackupFiles" default="No">

<!--- For Dev Use Only:  --->
   <cfset filedirectory = "\\fs01\ALC_IT\ReportCreation_DEV">  

<!--- Call Backup function to move files to Backup Directory --->
<cfif form.BackupFiles eq 'Yes'>
		
		<cfinvoke component="InvoiceGenerator" method="BackupFiles">
			<cfinvokeargument name="FiletoCheck" value="#fileInvoicesDetails#">
			<cfinvokeargument name="FileDirectory" value="#fileDirectory#">
		</cfinvoke>

		<cfinvoke component="InvoiceGenerator" method="BackupFiles">
			<cfinvokeargument name="FiletoCheck" value="#fileInvoicesPayments#">
			<cfinvokeargument name="FileDirectory" value="#fileDirectory#">
		</cfinvoke>

		<cfinvoke component="InvoiceGenerator" method="BackupFiles">
			<cfinvokeargument name="FiletoCheck" value="#fileInvoicesCharges#">
			<cfinvokeargument name="FileDirectory" value="#fileDirectory#">
		</cfinvoke>
		
		<cfinvoke component="InvoiceGenerator" method="BackupFiles">
			<cfinvokeargument name="FiletoCheck" value="#fileInvoicesDetailsCSV#">
			<cfinvokeargument name="FileDirectory" value="#fileDirectory#">
		</cfinvoke>
		
		<cfinvoke component="InvoiceGenerator" method="BackupFiles">
			<cfinvokeargument name="FiletoCheck" value="#fileInvoicesPaymentsCSV#">
			<cfinvokeargument name="FileDirectory" value="#fileDirectory#">
		</cfinvoke>
		
		<cfinvoke component="InvoiceGenerator" method="BackupFiles">
			<cfinvokeargument name="FiletoCheck" value="#fileInvoicesChargesCSV#">
			<cfinvokeargument name="FileDirectory" value="#fileDirectory#">
		</cfinvoke>

</cfif>

<cfsetting requesttimeout="900">

<CFTRY>
	<CFSTOREDPROC PROCEDURE="rw.sp_Invoices" DATASOURCE="#APPLICATION.datasource#" returncode="yes">
		<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_VARCHAR" VALUE="#form.Scope#" null="no" >
		<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_CHAR"  VALUE="#form.Period#" null="no" >
		<CFPROCRESULT name="rs1" resultset="1">
		<CFPROCRESULT name="rs2" resultset="2">
		<CFPROCRESULT name="rs3" resultset="3">
	</CFSTOREDPROC>
	
	<CFCATCH TYPE="Any">
		<CFMAIL TYPE ="HTML" FROM="TIPS4-Message@alcco.com" TO="cfdevelopers@alcco.com" 
        SUBJECT="STOREDPROC STATUS CODE ERROR - Invoices Generator">
			<b><#CFCATCH.Message#><br>
			   <#CFCATCH.Detail#></b>
		</CFMAIL>	
	</CFCATCH>
</CFTRY>

<cfoutput>

	<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoiceDetails" filter="#fileInvoicesDetails#">
  
	<CFIF qInvoiceDetails.RecordCount EQ 0>
    	<!--- Spaces and formating removed to limit amount of whitespace written to file ---->
		<cffile action="write" addnewline="yes" file="#fileDirectory#\#fileInvoicesDetails#" output = "<table border=1>
		<tr><td><b>HouseName</b></td><td><b>HouseAddress1</b></td><td><b>HouseAddress2</b></td><td><b>HouseCity</b></td>
		<td><b>HouseState</b></td><td><b>HouseZip</b></td><td><b>HousePhone</b></td><td><b>Apt Number</b></td><td><b>TenantName</b></td>
        <td><b>AccountNumber</b></td><td><b>InvoiceStart</b></td><td><b>InvoiceEnd (InvoiceDate)</b></td><td><b>InvoiceNumber</b></td>
        <td><b>Period</b></td><td><b>PreviousInvoice</b></td><td><b>ContactFName</b></td><td><b>ContactLName</b></td><td><b>ContactAddress1</b></td>
		<td><b>ContactAddress2</b></td><td><b>ContactCity</b></td><td><b>ContactState</b></td><td><b>ContactZip</b></td><td><b>ContactPhoneNumber1</b></td>
		<td><b>ContactRelationship</b></td><td><b>DueDate</b></td><td><b>ARPhone</b></td><td><b>BalanceDueString</b></td>
		</tr></table>">
	
		<cffile action="write" addnewline="yes" file="#fileDirectory#\#fileInvoicesDetailsCSV#" output = "HouseName">
	</CFIF>
</cfoutput>

<cfset tempstring = ''>
<cfset tempstringCSV = ''>

<cfoutput query="rs1">
    <!--- Spaces and formating removed to limit amount of whitespace written to file ---->
 
	<cfset tempstring = tempstring & "<table border=1><tr><td>#HouseName#</td>
    <td>#HouseAddress1#</td><td>#HouseAddress2#</td><td>#HouseCity#</td><td>#HouseState#</td><td style='mso-number-format:\@'>#HouseZip#</td>
    <td>#HousePhone#</td><td>#AptNumber#</td><td>#TenantName#</td><td>'#AccountNumber#'</td><td>#InvoiceStart#</td><td>#InvoiceEnd#</td>
    <td>#InvoiceNumber#</td><td>#cAppliesToAcctPeriod#</td><td>#decimalformat(PreviousInvoice)#</td><td>#ContactFName#</td>
    <td>#ContactlName#</td><td>#ContactAddress1#</td><td>#ContactAddress2#</td><td>#ContactCity#</td><td>#ContactState#</td>
    <td style='mso-number-format:\@'>#ContactZip#</td><td>#ContactPhoneNumber1#</td><td>#ContactRelationship#</td><td>#DueDate#</td>
    <td>#ARPhone#</td><td>#BalanceDueString#</td></tr></table>">

    <cfset tempstringCSV = tempstringCSV & HouseName & chr(10) >
 
	<cfif rs1.currentRow mod 50 eq 0>
        <cffile action="append" addnewline="yes"  file="#fileDirectory#\#fileInvoicesDetails#" output = "#tempstring#">	
        
        <cffile action="append" addnewline="no" file="#fileDirectory#\#fileInvoicesDetailsCSV#" output = "#tempstringCSV#">
        
        <cfset tempstring = ''>
        <cfset tempstringCSV = ''>
    </cfif>
    
	<cfif rs1.currentRow eq rs1.recordcount>
        <cffile action="append" addnewline="yes"  file="#fileDirectory#\#fileInvoicesDetails#" output = "#tempstring#">
        
        <cffile action="append" addnewline="no" file="#fileDirectory#\#fileInvoicesDetailsCSV#" output = "#tempstringCSV#">
        <cfset TempHouse = HouseName>
    </cfif>    
      
</CFoutput>
    
    
 <cfoutput>   
    <CFFILE ACTION="READ" file="#fileDirectory#\#fileInvoicesDetailsCSV#" variable="Details">
    
	<cfset LineCount = listlen(Details,(chr(10) & chr(13)) )  -1 > <!--- Minus 1 for Header row --->   

	<cfif rs1.RecordCount GT 0 and (rs1.RecordCount eq LineCount)>
		<!--- Spaces and formating removed to limit amount of whitespace written to file ---->
        <!--- This record send dummy letter to Corporate so they know letters are going out in proper time --->
        <cffile action="append" addnewline="yes" file="#fileDirectory#\#fileInvoicesDetails#" output = 
		"<table border = 1><tr><td>#TempHouse#</td><td>330 North Wabash Ave</td>
		<td> Suite 3700 </td><td>Chicago</td><td>IL</td><td style='mso-number-format:\@'>53051</td><td>(262)257-8760</td>
		<td>199</td><td>Justin Gedelman</td><td>'10128099'</td><td>1/30/2020</td><td>2/30/2020</td><td>10128072</td>
		<td>202001</td><td>0.00</td><td>Justin</td><td>Gedelman</td><td>330 North Wabash Ave</td>
		<td> Suite 3700 </td><td>Chicago</td><td>IL</td><td style='mso-number-format:\@'>53051</td><td>(262)257-8760</td>
		<td>Other</td><td>1/30/2020</td><td>(312)725-7000</td><td>0.00</td></tr></table>">	
         
         <!--- CSV files are used to generate stats on Index.cfm  --->
		<cffile action="append" addnewline="yes" file="#fileDirectory#\#fileInvoicesDetailsCSV#" output = "#TempHouse#">
	</cfif>
</cfoutput>
	
<!-- Payments -->
<cfoutput>
	<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoicePayments" filter="#fileInvoicesPayments#">

	<CFIF qInvoicePayments.RecordCount EQ 0>
    	<!--- Spaces and formating removed to limit amount of whitespace written to file ---->
		<cffile action="write" addnewline="yes" file="#fileDirectory#\#fileInvoicesPayments#" output = 
		"<table border=1><tr><td><b>AccountNumber</b></td><td><b>CheckNumber</b></td>
		<td><b>CheckDate</b></td><td><b>Description</b></td><td><b>CheckAmount</b></td></tr>">
		
        <!--- CSV files are used to generate stats on Index.cfm  --->
		<cffile action="write" addnewline="yes" file="#fileDirectory#\#fileInvoicesPaymentsCSV#" output = "AccountNumber,CheckAmount">
	</CFIF>
</cfoutput>

<cfset tempstring = ''>
<cfset tempstringCSV = ''>

<CFoutput QUERY="rs2">

	<cfset tempstring = tempstring & "<table border=1><tr><td>'#AccountNumber#'</td><td>#CheckNumber#</td><td>#dateFormat(CheckDate,'MM/DD/YYYY')#</td><td>#Description#</td><td>#decimalformat(CheckAmount)#</td></tr></table>">

    <cfset tempstringCSV = tempstringCSV & AccountNumber & "," & CheckAmount & chr(10) >
 
	<cfif rs2.currentRow mod 50 eq 0>
        <cffile action="append" addnewline="yes"  file="#fileDirectory#\#fileInvoicesPayments#" output = "#tempstring#">	
        
        <cffile action="append" addnewline="no" file="#fileDirectory#\#fileInvoicesPaymentsCSV#" output = "#tempstringCSV#">
        
        <cfset tempstring = ''>
        <cfset tempstringCSV = ''>
    </cfif>
    
	<cfif rs2.currentRow eq rs2.recordcount>
        <cffile action="append" addnewline="yes"  file="#fileDirectory#\#fileInvoicesPayments#" output = "#tempstring#">
        
        <cffile action="append" addnewline="no" file="#fileDirectory#\#fileInvoicesPaymentsCSV#" output = "#tempstringCSV#">
    </cfif>
      
</CFoutput>

<!-- Charges -->


<cfset tempstring = ''>
<cfset tempstringCSV = ''>
<cfoutput>
	<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoiceCharges" filter="#fileInvoicesCharges#">
	<CFIF qInvoiceCharges.RecordCount EQ 0>
		<!--- Spaces and formating removed to limit amount of whitespace written to file ---->
        <cffile action="write" addnewline="yes" file="#fileDirectory#\#fileInvoicesCharges#" output = 
		"<table border=1><tr><td><b>AccountNumber</b></td><td><b>Quantity</b></td><td><b>ChargeDescription</b></td>
		<td><b>ChargeAmount</b></td><td><b>AccountingPeriod</b></td><td><b>Comments</b></td></tr></table>">
		
		<cffile action="write" addnewline="yes" file="#fileDirectory#\#fileInvoicesChargesCSV#" output = "AccountNumber,Quantity,ChargeAmount">
	</CFIF>
</cfoutput>
	
	<CFoutput QUERY="rs3" >
    	
    	<!--- Spaces and formating removed to limit amount of whitespace written to file ---->
        <cfset tempstring = tempstring & "<table border=1><tr><td>'#AccountNumber#'</td><td>#Quantity#</td><td>#ChargeDescription#</td><td>#decimalformat(ChargeAmount)#</td><td>#AccountingPeriod#</td><td>#Comments#</td></tr></table>">

        <cfset tempstringCSV = tempstringCSV & AccountNumber & "," & Quantity & "," & ChargeAmount &  chr(10) >
        
        <cfif rs3.currentRow mod 50 eq 0>
            <cffile action="append" addnewline="yes"  file="#fileDirectory#\#fileInvoicesCharges#" output = "#tempstring#">	
            
            <cffile action="append" addnewline="no" file="#fileDirectory#\#fileInvoicesChargesCSV#" output = "#tempstringCSV#">
            
            <cfset tempstring = ''>
			<cfset tempstringCSV = ''>
        </cfif>
        
        <cfif rs3.currentRow eq rs3.recordcount>
        	<cffile action="append" addnewline="yes"  file="#fileDirectory#\#fileInvoicesCharges#" output = "#tempstring#">
            <cffile action="append" addnewline="no" file="#fileDirectory#\#fileInvoicesChargesCSV#" output = "#tempstringCSV#">				
        </cfif>
	</CFoutput>

<form name="BackToMain" action="Index.cfm" method="post">
	<cfoutput>
		<input type="hidden" name="Period" value="#form.Period#">
    </cfoutput>
</form>

<script>
	BackToMain.submit();
</script>
</body>
</html>