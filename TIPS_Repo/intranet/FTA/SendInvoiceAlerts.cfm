<!--- 
| Author     | Date       | Description                                                         |
| Sfarmer    | 10/08/2013 | 102505 moved to CF01, "gum" reference changed to "CF01"             |
 --->

<cfquery name="dsDocs" datasource="Doclink2">
	EXECUTE dbo.usp_FetchUnprocessedDistributionStampsByActivity NULL;
</cfquery>

<cfquery name="dsDistinctDocs" dbtype="Query">
	SELECT DISTINCT DocumentId FROM dsDocs;
</cfquery>

<cfquery name="dsHouses" datasource="DoclinkALC">
	SELECT
		iHouse_ID,
		cName,
		cGlSubAccount
	FROM
		dbo.vw_House
	WHERE
		dtRowDeleted IS NULL AND
		bIsSandbox = 0;
</cfquery>

<cfset today = DateFormat(Now(), "MM/DD/YYYY")>
<cfloop index="i" from="1" to="#dsDistinctDocs.RecordCount#">
	<cfquery name="dsDoc" dbtype="query">
		SELECT 
			*
		FROM
			dsDocs
		WHERE
			DocumentId = #dsDistinctDocs.DocumentId[i]#
		ORDER BY
			dtlSequence ASC;
	</cfquery>
	<cfquery name="dsHouseName" dbtype="query">
		SELECT
			*
		FROM
			dsHouses
		WHERE
			cGlSubAccount = '#Trim(dsDoc.dtlSubAccount)#';
	</cfquery>
	
	<cfoutput> #dsDoc.ReceivedDate# - #today#  **** date diff -- 
	<cfset days = DateDiff('d',dsDoc.ReceivedDate,today)> #days# </br>
	</cfoutput>
	
	<cfset days = DateDiff('d',dsDoc.ReceivedDate,today)>
	<cfset toAddress = ''>
	<cfset sendMail = false>
	<cfif days eq 3>
		<cfquery name="dsInvoiceAlerts3" datasource="DOCLINKALC">
			SELECT 
				*
			FROM
				vw_UserAccountDetails
			WHERE
				(rTrim(cRole) = 'RD') AND 
				(iHouseId = #dsHouseName.iHouse_ID#);
		</cfquery>
		<cfif dsInvoiceAlerts3.RecordCount Is Not "0">
			<cfset sendMail = true>		
			<cfloop index="j" from="1" to="#dsInvoiceAlerts3.RecordCount#">
				<cfset toAddress = toAddress & dsInvoiceAlerts3.cEmail[j]>
				<cfif j lt dsInvoiceAlerts3.RecordCount>
					<cfset toAddress = toAddress & ",">
				</cfif>
			</cfloop>
		</cfif>
	<cfelseif days eq 7>
		<cfquery name="dsInvoiceAlerts7" datasource="DOCLINKALC">
			SELECT 
				*
			FROM
				vw_UserAccountDetails
			WHERE
				(rTrim(cRole) IN ('RD','RDO')) AND 
				(iHouseId = #dsHouseName.iHouse_ID#);
		</cfquery>
		<cfif dsInvoiceAlerts7.RecordCount Is Not "0">
			<cfset sendMail = true>		
			<cfloop index="j" from="1" to="#dsInvoiceAlerts7.RecordCount#">
				<cfset toAddress = toAddress & dsInvoiceAlerts7.cEmail[j]>
				<cfif j lt dsInvoiceAlerts7.RecordCount>
					<cfset toAddress = toAddress & ",">
				</cfif>
			</cfloop>
		</cfif>
	<cfelseif days eq 10>
		<cfquery name="dsInvoiceAlerts10" datasource="DOCLINKALC">
			SELECT 
				*
			FROM
				vw_UserAccountDetails
			WHERE
				(rTrim(cRole) IN ('RD','RDO','DVP')) AND 
				(iHouseId = #dsHouseName.iHouse_ID#);
		</cfquery>
		<cfif dsInvoiceAlerts10.RecordCount Is Not "0">
			<cfset sendMail = true>		
			<cfloop index="j" from="1" to="#dsInvoiceAlerts10.RecordCount#">
				<cfset toAddress = toAddress & dsInvoiceAlerts10.cEmail[j]>
				<cfif j lt dsInvoiceAlerts10.RecordCount>
					<cfset toAddress = toAddress & ",">
				</cfif>
			</cfloop>
		</cfif>
	<cfelseif days eq 14>
		<cfquery name="dsInvoiceAlerts14" datasource="DOCLINKALC">
			SELECT 
				*
			FROM
				vw_UserAccountDetails
			WHERE
				(rTrim(cRole) = 'AP Supervisor');
		</cfquery>
		<cfif dsInvoiceAlerts14.RecordCount Is Not "0">
			<cfset sendMail = true>		
			<cfloop index="j" from="1" to="#dsInvoiceAlerts14.RecordCount#">
				<cfset toAddress = toAddress & dsInvoiceAlerts14.cEmail[j]>
				<cfif j lt dsInvoiceAlerts14.RecordCount>
					<cfset toAddress = toAddress & ",">
				</cfif>
			</cfloop>
		</cfif>
	</cfif>
<!--- 	<cfif server_name in ( "gum">
	<cfif sendMail eq true>
		<cfmail to="#toAddress#" from="Doclink@alcco.com" subject="Invoice Alert - #days# Days" type="html">  
			<h3>The Invoice has been in the Doclink Invoice Queue for #days# days!  Please navigate to the <a href="http://gum.alcco.com/intranet/applicationlist.cfm">Application List</a> and
			click the "Invoice Approval Process" link.</h3>
			<table border='1'>
				<tr><th colspan='2' align='center' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;">Invoice Details</th></tr>
  				<tr><td align='left'>House:</td><td>#dsHouseName.cName#</td></tr>
				<tr><td align='left'>Company:</td><td>#dsDoc.Company#</td></tr>                
				<tr><td align='left'>Invoice Nbr:</td><td>#dsDoc.InvoiceNumber#</td></tr>
				<tr><td align='left'>Invoice Date:</td><td>#DateFormat(dsDoc.InvoiceDate, "MM/DD/YYYY")#</td></tr>
				<tr><td align='left'>Recieved Date:</td><td>#DateFormat(dsDoc.ReceivedDate, "MM/DD/YYYY")#</td></tr>
				<tr><td align='left'>Vendor Name:</td><td>#dsDoc.VendorName#</td></tr>
				<tr><td align='left'>Vendor Id:</td><td>#dsDoc.VendorCode#</td></tr>
				<tr><td align='left'>Amount:</td><td>#DollarFormat(dsDoc.Amount)#</td></tr>
				<tr><td align='left'>Tax Amount:</td><td>#DollarFormat(dsDoc.TaxAmount)#</td></tr>
				<cfloop query="dsDoc">
					<tr><td colspan='2' align='center' style='font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;'>GL Code - Line #dsDoc.dtlSequence + 1#</td></tr>	
			 		<tr><td align='left'>Company:</td><td>#dsDoc.dtlCompany#</td></tr>
					<tr><td align='left'>Sub Account:</td><td>#dsDoc.dtlSubAccount#</td></tr>
	  				<tr><td align='left'>GL Code Desc:</td><td>#dsDoc.dtlGlAccountName#</td></tr>
					<tr><td align='left'>GL Code:</td><td>#dsDoc.dtlGlAccountCode#</td></tr>
	  				<tr><td align='left'>Amount:</td><td>#DollarFormat(dsDoc.dtlAmount)#</td></tr>
	  			</cfloop>
			</table>
			<br />
			<hr>
			<br />
			Do not reply to this email, as this email box is not monitored.      
		</cfmail> 
	</cfif> 
	<cfelseif server_name in ("cf01" > --->
	<cfif sendMail eq true>
		<!---<cfmail  to="gthota@enlivant.com"  from="Doclink@alcco.com" subject="Invoice Alert - #days# Days" type="html"> ---> 
			<h3>The Invoice has been in the Doclink Invoice Queue for #days# days!  Please navigate to the <a href="http://cf01.alcco.com/intranet/applicationlist.cfm">Application List</a> and
			click the "Invoice Approval Process" link.</h3>
			<table border='1'>
				<tr><th colspan='2' align='center' style="font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;">Invoice Details</th></tr>
  				<tr><td align='left'>House:</td><td>#dsHouseName.cName#</td></tr>
				<tr><td align='left'>Company:</td><td>#dsDoc.Company#</td></tr>                
				<tr><td align='left'>Invoice Nbr:</td><td>#dsDoc.InvoiceNumber#</td></tr>
				<tr><td align='left'>Invoice Date:</td><td>#DateFormat(dsDoc.InvoiceDate, "MM/DD/YYYY")#</td></tr>
				<tr><td align='left'>Recieved Date:</td><td>#DateFormat(dsDoc.ReceivedDate, "MM/DD/YYYY")#</td></tr>
				<tr><td align='left'>Vendor Name:</td><td>#dsDoc.VendorName#</td></tr>
				<tr><td align='left'>Vendor Id:</td><td>#dsDoc.VendorCode#</td></tr>
				<tr><td align='left'>Amount:</td><td>#DollarFormat(dsDoc.Amount)#</td></tr>
				<tr><td align='left'>Tax Amount:</td><td>#DollarFormat(dsDoc.TaxAmount)#</td></tr>
				<cfloop query="dsDoc">
					<tr><td colspan='2' align='center' style='font-weight: bold; background-color: ##D7D7D7; text-decoration: underline;'>GL Code - Line #dsDoc.dtlSequence + 1#</td></tr>	
			 		<tr><td align='left'>Company:</td><td>#dsDoc.dtlCompany#</td></tr>
					<tr><td align='left'>Sub Account:</td><td>#dsDoc.dtlSubAccount#</td></tr>
	  				<tr><td align='left'>GL Code Desc:</td><td>#dsDoc.dtlGlAccountName#</td></tr>
					<tr><td align='left'>GL Code:</td><td>#dsDoc.dtlGlAccountCode#</td></tr>
	  				<tr><td align='left'>Amount:</td><td>#DollarFormat(dsDoc.dtlAmount)#</td></tr>
	  			</cfloop>
			</table>
			<br />
			<hr>
			<br />
			Do not reply to this email, as this email box is not monitored.      
		<!---</cfmail> --->
	</cfif>	
<!--- </cfif> --->		
</cfloop>
