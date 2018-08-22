<!--- 11/20/2013 Sfarmer 102505 c:\ chg to e:\ for move to CF01 --->

<!---
<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.UserId EQ "" OR NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") OR SESSION.qSelectedHouse.iHouse_ID EQ "">
	<CFLOCATION URL="http://gum/alc">
</CFIF>
--->


<CFOUTPUT>
	<CFSCRIPT>
		if (IsDefined("url.prompt0")){ form.prompt0 = url.prompt0; form.prompt2 = url.prompt2; form.cComments = ''; }
		if (IsDefined("url.bUsesEFT") AND url.bUsesEFT EQ '1') { form.bUsesEFT = 1; } else { form.bUsesEFT = 0; }
		if (form.prompt0 EQ 'ALL') { form.prompt0 = ''; }
	
		if (SESSION.UserID IS 3146) {
			if (IsDefined("form.fieldnames")) { WriteOutPut(form.fieldnames &'<BR>'& form.prompt0 &'<BR>'& form.prompt2 &'<BR>'& form.bUsesEFT &'<BR>'); }
		}
	</CFSCRIPT>
	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
</CFOUTPUT>

<SCRIPT> window.open("loading.htm","InvoiceReport","toolbar=no,resizable=yes"); </SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN 	OPSArea OA ON (OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
	JOIN 	Region R ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
	WHERE	H.dtRowDeleted IS NULL	
	AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>	

<!--- you have to register the COM object by invoking (from the command line)
regsvr32 craxdrt.dll
where craxdrt.dll lives in the winnt\system32 directory 

the code expects the 'valuen' variables to be passed from a form

//to open the crystalRuntime application --->
<cfobject type="COM" name="CR" class="CrystalRuntime.Application"
action="Create" context="inproc"> 

<!--- //to set some of the database fields, and form a selection formula --->
<cfset operator_symbol="=">
<cfset field="{init}">
<cfset field2="{promptOnRefresh}">
<cfset field3="{user0}">
<cfset field4="{password0}">
<cfset field5="{user0@InvoiceContactSubRpt.rpt}">
<cfset field6="{password0@InvoiceContactSubRpt.rpt}">
<cfset field7="{user0@Prev_Trx2.rpt}">
<cfset field8="{password0@Prev_Trx2.rpt}">
<cfset field9="{user0@ChargesSubRpt.rpt}">
<cfset field10="{password0@ChargesSubRpt.rpt">
<cfset field11="{user0@TenantNames}">
<cfset field12="{password0@TenantNames}">
<cfset field13="{user0@HeartLetter}">
<cfset field14="{password0@HeartLetter}">
<cfset field15="{prompt0}">
<cfset field16="{prompt1}">
<cfset field17="{prompt2}">
<cfset field18="{prompt3}">
<cfset field19="{prompt4}">
<cfset selection_formula= "(" & field & operator_symbol & " " & 'actx' & ")" & " AND " & 
"(" & field2 & operator_symbol & " " & '0' & ")" & " AND " & 
"(" & field3 & operator_symbol & " " & 'rw' & ")" & " AND " & 
"(" & field4 & operator_symbol & " " & '4rwriter' & ")" & " AND " & 
"(" & field5 & operator_symbol & " " & 'rw' & ")" & " AND " & 
"(" & field6 & operator_symbol & " " & '4rwriter' & ")" & " AND " & 
"(" & field7 & operator_symbol & " " & 'rw' & ")" & " AND " & 
"(" & field8 & operator_symbol & " " & '4rwriter' & ")" & " AND " & 
"(" & field9 & operator_symbol & " " & 'rw' & ")" & " AND " & 
"(" & field10 & operator_symbol & " " & '4rwriter' & ")" & " AND " & 
"(" & field11 & operator_symbol & " " & 'rw' & ")" & " AND " & 
"(" & field12 & operator_symbol & " " & '4rwriter' & ")" & " AND " & 
"(" & field13 & operator_symbol & " " & 'rw' & ")" & " AND " & 
"(" & field14 & operator_symbol & " " & '4rwriter' & ")" & " AND " & 
"(" & field15 & operator_symbol & " " & #form.cComments# & ")" & " AND " & 
"(" & field16 & operator_symbol & " " & #form.bUsesEFT# & ")" & " AND " & 
"(" & field17 & operator_symbol & " " & #HouseData.cNumber# & ")" & " AND " & 
"(" & field18 & operator_symbol & " " & #form.prompt2# & ")" & " AND " & 
"(" & field19 & operator_symbol & " " & #form.prompt0# & ")" >

	<!--- <cfoutput>#selection_formula#</cfoutput>	<cfabort>  --->	
<!--- //open a crystal report --->
<cfset report=cr.openreport('e:\inetpub\wwwroot\intranet\documentimaging\invoice.rpt')>

<!--- //pass the selection formula as a record selection --->
<cfset report.recordselectionformula = #selection_formula#>

<!--- //now export the file as an PDF file, to the subdirectory exports --->
<cfset oExportoptions=report.exportoptions>
<cfset oExportoptions.formattype=1>
<cfset oExportoptions.destinationtype=1> 
<cfset oExportoptions.DiskFilename="e:\inetpub\wwwroot\intranet\test\testreport.pdf">
<cfset report.export(isBinary('s'))> 

<!--- email the file --->
<!--- <cfmail to="kdeborde@alcco.com" from="kdeborde@alcco.com" cc="EFT@alcco.com" MIMEATTACH="C:\inetpub\wwwroot\intranet\test\testreport.pdf" SUBJECT="House EFT Report">Attached you will find a PDF file of all the Residents using EFT.  Please look over the list and make sure the totals are correct.  Then report back to your accounting rep with any changes or to confirm that everything is correct.
</cfmail> --->

<!--- //display the file --->
<!--- <cflocation url="C:\inetpub\wwwroot\intranet\test\testreport.pdf"> --->

<!--- <cfreport report = '//CEDAR/Reports/tips/tips4/invoice.rpt' datasource="#application.datasource#" type="microsoft">
     {Departments.Department} = 'International'
	 {init}='actx'
	{promptOnRefresh}='0'
		{user0}='rw'
		{password0}='4rwriter'
		{user0@InvoiceContactSubRpt.rpt}='rw'
		{password0@InvoiceContactSubRpt.rpt}='4rwriter'
		{user0@Prev_Trx2.rpt}='rw'
		{password0@Prev_Trx2.rpt}='4rwriter'
		{user0@ChargesSubRpt.rpt}='rw'
		{password0@ChargesSubRpt.rpt}='4rwriter'				
		{user0@TenantNames}='rw'
		{password0@TenantNames}='4rwriter'				
		{user0@HeartLetter}='rw'
		{password0@HeartLetter}='4rwriter'				
			{prompt0}"='#form.cComments#'
 			{prompt1}='#form.bUsesEFT#'
			{prompt2}='#HouseData.cNumber#'
			{prompt3}='#form.prompt2#'
			{prompt4}='#form.prompt0#'
</cfreport> --->

		
<CFOUTPUT>		
<!--- 	<FORM NAME="Invoice" ACTION = "//#crserver#/reports/tips/tips4/invoice.rpt" METHOD="POST" TARGET="InvoiceReport" onSubmit="opennew();">
	<CFSET FileToWrite = "Report_Date#dateformat(Now(),'dd-mm-yyy')#.doc"> 
		<cfcontent type="application/msword"> 
		<cfheader name="Content-Disposition" value="attachment; filename=#filetowrite#"> 
			<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
			<input type=hidden name="promptOnRefresh" value=0>
			<INPUT TYPE = "Hidden" NAME="user0" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0" VALUE="4rwriter">
			<INPUT TYPE = "Hidden" NAME="user0@InvoiceContactSubRpt.rpt" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0@InvoiceContactSubRpt.rpt" VALUE="4rwriter">
			<INPUT TYPE = "Hidden" NAME="user0@Prev_Trx2.rpt" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0@Prev_Trx2.rpt" VALUE="4rwriter">
			<INPUT TYPE = "Hidden" NAME="user0@ChargesSubRpt.rpt" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0@ChargesSubRpt.rpt" VALUE="4rwriter">				
			<INPUT TYPE = "Hidden" NAME="user0@TenantNames" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0@TenantNames" VALUE="4rwriter">				
			<INPUT TYPE = "Hidden" NAME="user0@HeartLetter" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0@HeartLetter" VALUE="4rwriter">				

			<INPUT TYPE = "Hidden" NAME="prompt0" VALUE="#form.cComments#">
 			<INPUT TYPE = "Hidden" NAME="prompt1" VALUE=#form.bUsesEFT#>
			<INPUT TYPE = "Hidden" NAME="prompt2" VALUE="#HouseData.cNumber#">
			<INPUT TYPE = "Hidden" NAME="prompt3" VALUE="#form.prompt2#">
			<INPUT TYPE = "Hidden" NAME="prompt4" VALUE="#form.prompt0#">
		<!--- <SCRIPT>location.href='#HTTP_REFERER#'; document.Invoice.submit(); </SCRIPT> --->
	</FORM> --->
	<CENTER><B STYLE="font-size: 30;"> Please, wait while the report is loading.... </B></CENTER>
</CFOUTPUT>