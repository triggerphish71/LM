<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
<!--- 11/20/2013 Sfarmer 102505 c:\ chg to e:\ for move to CF01 --->
<!--- <SCRIPT> window.open("loading.htm","InvoiceReport","toolbar=no,resizable=yes"); </SCRIPT> --->

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN 	OPSArea OA ON (OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
	JOIN 	Region R ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
	WHERE	H.dtRowDeleted IS NULL	
	AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>	

<!--- you have to register the COM object by invoking (from the command line) regsvr32 craxdrt.dll where craxdrt.dll lives in the winnt\system32 directory 
Open the crystalRuntime application --->
<cfobject type="COM" name="CR" class="CrystalRuntime.Application"
action="Create" context="inproc"> 

<!--- to set some of the database fields, and form a selection formula --->
<cfset selection_formula = "(prompt0 = #url.HouseName#) AND (prompt1 = #url.TipsMonth#)">

<!---  <cfoutput>#selection_formula#</cfoutput>	<cfabort>  --->	
<!--- open the crystal report --->
<cfset report=cr.openreport('e:\inetpub\wwwroot\intranet\tips4\SimpleReportExport\EFTnotice.rpt')>

<!--- pass the selection formula as a record selection --->
<cfset report.recordselectionformula = #selection_formula#>

<!--- now export the file as an PDF file, to the correct folder --->
<cfset oExportoptions=report.exportoptions>
<cfset oExportoptions.formattype=1>
<cfset oExportoptions.destinationtype=1> 
<cfset oExportoptions.DiskFilename="e:\inetpub\wwwroot\intranet\test\testreport.pdf">
<cfset report.export("false")> 

<!--- email the file --->
<cfmail to="kdeborde@alcco.com" from="kdeborde@alcco.com" cc="EFT@alcco.com" MIMEATTACH="e:\inetpub\wwwroot\intranet\test\testreport.pdf" SUBJECT="House EFT Report">Attached you will find a PDF file of all the Residents using EFT.  Please look over the list and make sure the totals are correct.  Then report back to your accounting rep with any changes or to confirm that everything is correct.
</cfmail>

<!--- display the file for testing purposes --->
<cflocation url="e:\inetpub\wwwroot\intranet\test\testreport.pdf">