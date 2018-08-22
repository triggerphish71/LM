<cfprocessingdirective  suppresswhitespace="true">
<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| Gets the tenants information for a house for xls output.  User is given a Save prompt,
| file is created in a folder (name: TIPS_Transport), and once the user gets the file, it
| is programmatically deleted from the folder.
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| rschuette  | 05/12/2009 | Created as part of Project 36359 to go on reports cfm page         
----------------------------------------------------------------------------------------------->
<cfquery name="qTimeStamp" datasource="#application.datasource#">
select CONVERT(VARCHAR(10), GETDATE(), 112) as timestamp
,CONVERT(VARCHAR(20), GETDATE(), 100) as timestamp2 
,REPLACE((CONVERT(VARCHAR(12), GETDATE(), 114)),':','-') as timestamp3  
</cfquery>
<cfset TimeStamp = qTimeStamp.timestamp>
<cfset TimeStamp2 = qTimeStamp.timestamp2>
<cfset TimeStamp3 = qTimeStamp.timestamp3>

<cfquery name="GetMICheckInfo" datasource="#APPLICATION.datasource#">
select 
	r.cName as 'Region'
	,o.cname as 'Division'
	,h.cName as 'House'
	,(t.cFirstName + ' '  
	+(case when t.cMiddleInitial is null then
		+''
	else
		+ t.cMiddleInitial + ' '
	end)
	+ t.cLastName) as 'TenantName'
	,t.iTenant_ID
	,aa.cAptNumber as 'AptNumber'
	,convert(varchar(2),month(ts.dtMoveIn))+'/'+convert(varchar(2),day(ts.dtMoveIn))+'/'+convert(varchar(4),year(ts.dtMoveIn)) as 'MoveInDt'
	,isnull(convert(varchar(2),month(ts.dtMoveOut))+'/'+convert(varchar(2),day(ts.dtMoveOut))+'/'+convert(varchar(4),year(ts.dtMoveOut)),'') as 'dtMoveOut'
	,isnull(convert(varchar(2),month(ts.dtChargeThrough))+'/'+convert(varchar(2),day(ts.dtChargeThrough))+'/'+convert(varchar(4),year(ts.dtChargeThrough)),'') as 'dtChargeThrough'
	,case ts.bMICheckReceived 
		when '1' then
			'Move In Check Received'
	else
			'Move In Check Not Received'
	end MICheckReceived	
	,isnull(convert(varchar(2),month(ts.dtMICheckReceived))+'/'+convert(varchar(2),day(ts.dtMICheckReceived))+'/'+convert(varchar(4),year(ts.dtMICheckReceived)),'') as 'dtMICheckReceived'
from tenant t
join TenantState ts on (ts.iTenant_ID = t.iTenant_ID and ts.dtRowDeleted is null)
join AptAddress aa on (aa.iAptAddress_ID = ts.iAptAddress_ID and aa.dtRowDeleted is null)
join House h on (h.iHouse_ID = t.iHouse_ID and h.dtRowDeleted is null and h.iHouse_ID <> 200)
join OpsArea o on (o.iOpsArea_ID = h.iOpsArea_ID and o.dtRowDeleted is null)
join Region r on (r.iRegion_ID = o.iRegion_ID and r.dtRowDeleted is null)
where ((ts.dtMoveIn >= '#form.MICheckInfoStart#') and (ts.dtMoveIn <= '#form.MICheckInfoEnd#'))
and t.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
order by ts.dtMoveIn asc,aa.cAptNumber,t.cLastName

</cfquery>
<cfset HouseName = GetMICheckInfo.House>

<cfset ArrayTenantCheckInfo = ArrayNew(1)>


<cfoutput query="GetMICheckInfo">

	<cfset tenantId = #iTenant_ID#>
	
	<cfscript>
		StructTenantCheckInfo = StructNew();
		
		StructTenantCheckInfo.Region = "";
		StructTenantCheckInfo.Division = "";
		StructTenantCheckInfo.House = "";
		StructTenantCheckInfo.TenantName = "";
		StructTenantCheckInfo.AptNumber = "";
		StructTenantCheckInfo.dtMoveIn = "";
		StructTenantCheckInfo.dtMoveOut = "";
		StructTenantCheckInfo.dtChargeThrough = "";
		StructTenantCheckInfo.MICheckReceived = 0;
		StructTenantCheckInfo.dtMICheckReceived = "";
		
		StructTenantCheckInfo.Region = GetMICheckInfo.Region;
		StructTenantCheckInfo.Division = GetMICheckInfo.Division;
		StructTenantCheckInfo.House = GetMICheckInfo.House;
		StructTenantCheckInfo.TenantName = GetMICheckInfo.TenantName;
		StructTenantCheckInfo.AptNumber = GetMICheckInfo.AptNumber;
		StructTenantCheckInfo.dtMoveIn = GetMICheckInfo.MoveInDt;
		StructTenantCheckInfo.dtMoveOut = GetMICheckInfo.dtMoveOut;
		StructTenantCheckInfo.dtChargeThrough = GetMICheckInfo.dtChargeThrough;
		StructTenantCheckInfo.MICheckReceived = GetMICheckInfo.MICheckReceived;
		StructTenantCheckInfo.dtMICheckReceived = GetMICheckInfo.dtMICheckReceived;
		
		ArrayAppend(ArrayTenantCheckInfo,StructTenantCheckInfo);
	</cfscript>
</cfoutput>	

<cfset xml = "<?xml version=""1.0""?><?mso-application progid=""Excel.Sheet""?><Workbook xmlns=""urn:schemas-microsoft-com:office:spreadsheet"" xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns:html=""http://www.w3.org/TR/REC-html40"">">
<cfset xml = xml & "<DocumentProperties xmlns=""urn:schemas-microsoft-com:office:spreadsheet""><Author>rschuette</Author><LastAuthor>rschuette</LastAuthor><Created>2009-07-20</Created><LastSaved></LastSaved><Company>Assisted Living Concepts</Company><Version>12.00</Version></DocumentProperties>">
<CFSET xml = xml & "<ExcelWorkbook xmlns=""urn:schemas-microsoft-com:office:excel""><WindowHeight>14505</WindowHeight><WindowWidth>27615</WindowWidth><WindowTopX>360</WindowTopX><WindowTopY>60</WindowTopY><ProtectStructure>False</ProtectStructure><ProtectWindows>False</ProtectWindows></ExcelWorkbook>">
<cfset xml = xml & "<Styles>">
<cfset xml = xml & "<Style ss:ID=""Default"" ss:Name=""Normal""><Alignment ss:Vertical=""Bottom""/><Borders/><Font ss:FontName=""Calibri"" x:Family=""Swiss"" ss:Size=""11"" ss:Color=""##000000""/><Interior/><NumberFormat/><Protection/></Style>">
<!--- <cfset xml = xml & "<Style ss:ID=""m45487444""><Alignment ss:Horizontal=""Left"" ss:Vertical=""Bottom""/><Borders><Border ss:Position=""Bottom"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Left"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Right"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Top"" ss:LineStyle=""Continuous"" ss:Weight=""1""/></Borders><Font ss:FontName=""Calibri"" x:Family=""Swiss"" ss:Size=""11"" ss:Color=""##000000"" ss:Bold=""1""/><Interior ss:Color=""##8DB4E3"" ss:Pattern=""Solid""/></Style>">
<cfset xml = xml & "<Style ss:ID=""m45487464""><Alignment ss:Horizontal=""Center"" ss:Vertical=""Bottom""/><Borders><Border ss:Position=""Bottom"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Left"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Right"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Top"" ss:LineStyle=""Continuous"" ss:Weight=""1""/></Borders><Font ss:FontName=""Calibri"" x:Family=""Swiss"" ss:Size=""11"" ss:Color=""##000000"" ss:Bold=""1""/><Interior ss:Color=""##8DB4E3"" ss:Pattern=""Solid""/></Style>">
<cfset xml = xml & "<Style ss:ID=""m45487484""><Alignment ss:Horizontal=""Center"" ss:Vertical=""Bottom""/><Borders><Border ss:Position=""Bottom"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Left"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Right"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Top"" ss:LineStyle=""Continuous"" ss:Weight=""1""/></Borders><Font ss:FontName=""Calibri"" x:Family=""Swiss"" ss:Size=""11"" ss:Color=""##000000"" ss:Bold=""1""/><Interior ss:Color=""##8DB4E3"" ss:Pattern=""Solid""/></Style>">
 --->
<cfset xml = xml & "<Style ss:ID=""s63""><Alignment ss:Horizontal=""Left"" ss:Vertical=""Bottom""/><Font ss:FontName=""Calibri"" x:Family=""Swiss"" ss:Size=""20"" ss:Color=""##000000"" ss:Bold=""1""/></Style>">
<!--- <cfset xml = xml & "<Style ss:ID=""s78""><Borders><Border ss:Position=""Bottom"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Left"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Right"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Top"" ss:LineStyle=""Continuous"" ss:Weight=""1""/></Borders><Font ss:FontName=""Calibri"" x:Family=""Swiss"" ss:Size=""11"" ss:Color=""##000000"" ss:Bold=""1""/><Interior ss:Color=""##8DB4E3"" ss:Pattern=""Solid""/></Style>">
<cfset xml = xml & "<Style ss:ID=""s80""><Alignment ss:Vertical=""Bottom"" ss:WrapText=""1""/></Style>">
<cfset xml = xml & "<Style ss:ID=""s81""><Alignment ss:Vertical=""Bottom"" ss:WrapText=""1""/><NumberFormat ss:Format=""Short Date""/></Style>">
<cfset xml = xml & "<Style ss:ID=""s82""><NumberFormat ss:Format=""Fixed""/></Style>">
 --->
<!--- <Borders><Border ss:Position=""Bottom"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Left"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Right"" ss:LineStyle=""Continuous"" ss:Weight=""1""/><Border ss:Position=""Top"" ss:LineStyle=""Continuous"" ss:Weight=""1""/></Borders> --->
<cfset xml = xml & "<Style ss:ID=""s83""><Alignment ss:Horizontal=""Center"" ss:Vertical=""Bottom"" ss:WrapText=""1""/><Font ss:FontName=""Calibri"" x:Family=""Swiss"" ss:Size=""11""  ss:Bold=""1""/><Interior ss:Color=""##FFFF00"" ss:Pattern=""Solid""/></Style>">
<!--- <cfset xml = xml & "<Style ss:ID=""s84""><Alignment ss:Vertical=""Bottom"" ss:WrapText=""1""/><Protection ss:Protected=""0""/></Style>">
<cfset xml = xml & "<Style ss:ID=""s86""><Protection ss:Protected=""0""/></Style>">
 --->
<cfset xml = xml & "<Style ss:ID=""s88""><Alignment ss:Vertical=""Bottom"" ss:WrapText=""1""/><Protection/></Style>">
<cfset xml = xml & "<Style ss:ID=""s89""><Alignment ss:Vertical=""Bottom"" ss:WrapText=""1""/><NumberFormat ss:Format=""Short Date""/><Protection/></Style>">
<!--- <cfset xml = xml & "<Style ss:ID=""s90""><Protection/></Style>">
<cfset xml = xml & "<Style ss:ID=""s91""><NumberFormat ss:Format=""Fixed""/> <Protection/></Style>"> --->
<cfset xml = xml & "</Styles>">
<cfset xml = xml & "<Worksheet ss:Name=""Sheet1"" ss:Protected=""1"">"> 

<!--- <cfset xml = xml & "<Table ss:ExpandedColumnCount=""1"" ss:ExpandedRowCount=""#ArrayLen(ArrayTenantCheckInfo)#"" x:FullColumns=""9"" ss:DefaultRowHeight=""15"">"> --->
<cfset xml = xml & "<Table ss:DefaultRowHeight=""15"">">
<cfset xml = xml & "<Column ss:AutoFitWidth=""0"" ss:Width=""115""/>">
<cfset xml = xml & "<Column ss:Width=""150""/>">
<cfset xml = xml & "<Column ss:Width=""115""/>">
<cfset xml = xml & "<Column ss:Width=""115""/>">
<cfset xml = xml & "<Column ss:Width=""50""/>">
<cfset xml = xml & "<Column ss:Width=""55""/>">
<cfset xml = xml & "<Column ss:Width=""55""/>">
<cfset xml = xml & "<Column ss:Width=""63""/>">
<cfset xml = xml & "<Column ss:Width=""150""/>">
<cfset xml = xml & "<Column ss:Width=""70""/>"> 
<cfset xml = xml & "<Row ss:AutoFitHeight=""0"" ss:Height=""26.25"">">
<cfset xml = xml & "<Cell ss:MergeAcross=""2"" ss:StyleID=""s63""><Data ss:Type=""String"">#GetMICheckInfo.House#</Data></Cell>">
<cfset xml = xml & "</Row>">
<cfset xml = xml & "<Row ss:AutoFitHeight=""0"" ss:Height=""26.25"">">
<cfset xml = xml & "<Cell ss:MergeAcross=""1"" ss:StyleID=""s88""><Data ss:Type=""String"">Period : #form.MICheckInfoStart# - #form.MICheckInfoEnd#</Data></Cell>">
<cfset xml = xml & "</Row>">
<cfset xml = xml & "<Row ss:AutoFitHeight=""0"" ss:Height=""26.25"">">
<cfset xml = xml & "<Cell ss:MergeAcross=""1"" ss:StyleID=""s88""><Data ss:Type=""String"">Move In Check Received Data</Data></Cell>">
<cfset xml = xml & "</Row>">
   

<cfset xml = xml & "<Row ss:AutoFitHeight=""0"" ss:Height=""45"">">
    <cfset xml = xml & "<Cell ss:StyleID=""s83""><Data ss:Type=""String"">Division</Data></Cell>">
    <cfset xml = xml & "<Cell ss:StyleID=""s83""><Data ss:Type=""String"">Region</Data></Cell>">
    <cfset xml = xml & "<Cell ss:StyleID=""s83""><Data ss:Type=""String"">House</Data></Cell>">
    <cfset xml = xml & "<Cell ss:StyleID=""s83""><Data ss:Type=""String"">Resident Name</Data></Cell>">
    <cfset xml = xml & "<Cell ss:StyleID=""s83""><Data ss:Type=""String"">Apt Number</Data></Cell>">
    <cfset xml = xml & "<Cell ss:StyleID=""s83""><Data ss:Type=""String"">MI Date</Data></Cell>">
    <cfset xml = xml & "<Cell ss:StyleID=""s83""><Data ss:Type=""String"">MO Date</Data></Cell>">
    <cfset xml = xml & "<Cell ss:StyleID=""s83""><Data ss:Type=""String"">Charge Through Date</Data></Cell>">
    <cfset xml = xml & "<Cell ss:StyleID=""s83""><Data ss:Type=""String"">MI Check Received</Data></Cell>">
    <cfset xml = xml & "<Cell ss:StyleID=""s83""><Data ss:Type=""String"">MI Check Received Date</Data></Cell>">
   <cfset xml = xml & "</Row>">

<cfloop from="1" to="#ArrayLen(ArrayTenantCheckInfo)#" index="i">

		<cfset xml = xml & "<Row ss:AutoFitHeight=""0"">">
			<cfset xml = xml & "<Cell ss:StyleID=""s88""><Data ss:Type=""String"">#ArrayTenantCheckInfo[i].Region#</Data></Cell>">
		    <cfset xml = xml & "<Cell ss:StyleID=""s88""><Data ss:Type=""String"">#ArrayTenantCheckInfo[i].Division#</Data></Cell>">
		    <cfset xml = xml & "<Cell ss:StyleID=""s88""><Data ss:Type=""String"">#ArrayTenantCheckInfo[i].House#</Data></Cell>">
		    <cfset xml = xml & "<Cell ss:StyleID=""s88""><Data ss:Type=""String"">#ArrayTenantCheckInfo[i].TenantName#</Data></Cell>">
		    <cfset xml = xml & "<Cell ss:StyleID=""s88""><Data ss:Type=""String"">#ArrayTenantCheckInfo[i].AptNumber#</Data></Cell>">
		    <cfset xml = xml & "<Cell ss:StyleID=""s88""><Data ss:Type=""String"">#ArrayTenantCheckInfo[i].dtMoveIn#</Data></Cell>">
		    <cfset xml = xml & "<Cell ss:StyleID=""s88""><Data ss:Type=""String"">#ArrayTenantCheckInfo[i].dtMoveOut#</Data></Cell>">
		    <cfset xml = xml & "<Cell ss:StyleID=""s88""><Data ss:Type=""String"">#ArrayTenantCheckInfo[i].dtChargeThrough#</Data></Cell>">
		    <cfset xml = xml & "<Cell ss:StyleID=""s88""><Data ss:Type=""String"">#ArrayTenantCheckInfo[i].MICheckReceived#</Data></Cell>">
		    <cfset xml = xml & "<Cell ss:StyleID=""s88""><Data ss:Type=""String"">#ArrayTenantCheckInfo[i].dtMICheckReceived#</Data></Cell>">
		<cfset xml = xml & "</Row>">
</cfloop>
<cfset xml = xml & "<Row ss:AutoFitHeight=""0"" ss:Height=""26.25"">">
<cfset xml = xml & "</Row>">
<cfset xml = xml & "<Row ss:AutoFitHeight=""0"" ss:Height=""26.25"">">
<cfset xml = xml & "<Cell ss:MergeAcross=""1"" ss:StyleID=""s88""><Data ss:Type=""String"">Created : #timestamp2#</Data></Cell>">
<cfset xml = xml & "</Row>">
<!---  <Header x:Margin=""0.3""/><Footer x:Margin=""0.3""/> --->
<cfset xml = xml & "</Table><WorksheetOptions xmlns=""urn:schemas-microsoft-com:office:excel"">">
<cfset xml = xml & "<PageSetup><PageMargins x:Bottom=""0.75"" x:Left=""0.7"" x:Right=""0.7"" x:Top=""0.75""/></PageSetup>">
<cfset xml = xml & "<Unsynced/><Print><ValidPrinterInfo/><HorizontalResolution>600</HorizontalResolution><VerticalResolution>0</VerticalResolution></Print>">
<cfset xml = xml & "<Selected/><Panes><Pane><Number>3</Number><ActiveRow>150</ActiveRow><ActiveCol>10</ActiveCol></Pane></Panes>">
<cfset xml = xml & "<ProtectObjects>True</ProtectObjects><ProtectScenarios>True</ProtectScenarios></WorksheetOptions>">
<cfset xml = xml & "</Worksheet>">
<!--- <cfset xml = xml & "<Worksheet ss:Name=""Sheet2""> <Table ss:ExpandedColumnCount=""1"" ss:ExpandedRowCount=""1"" x:FullColumns=""1"" x:FullRows=""1"" ss:DefaultRowHeight=""15""><Row ss:AutoFitHeight=""0""/></Table>">
<cfset xml = xml & "<WorksheetOptions xmlns=""urn:schemas-microsoft-com:office:excel""><PageSetup><Header x:Margin=""0.3""/><Footer x:Margin=""0.3""/><PageMargins x:Bottom=""0.75"" x:Left=""0.7"" x:Right=""0.7"" x:Top=""0.75""/></PageSetup><Unsynced/>">
<cfset xml = xml & "<ProtectObjects>False</ProtectObjects><ProtectScenarios>False</ProtectScenarios></WorksheetOptions></Worksheet><Worksheet ss:Name=""Sheet3""><Table ss:ExpandedColumnCount=""1"" ss:ExpandedRowCount=""1"" x:FullColumns=""1"" x:FullRows=""1"" ss:DefaultRowHeight=""15""><Row ss:AutoFitHeight=""0""/></Table>">
<cfset xml = xml & "<WorksheetOptions xmlns=""urn:schemas-microsoft-com:office:excel""><PageSetup><Header x:Margin=""0.3""/><Footer x:Margin=""0.3""/><PageMargins x:Bottom=""0.75"" x:Left=""0.7"" x:Right=""0.7"" x:Top=""0.75""/></PageSetup><Unsynced/>">
<cfset xml = xml & "<ProtectObjects>False</ProtectObjects><ProtectScenarios>False</ProtectScenarios></WorksheetOptions></Worksheet>"> --->
<cfset xml = xml & "</Workbook>"> 


<cffile action="write" file="\\gum\c$\Inetpub\wwwroot\TIPS_Transport\MICheckInfo_#HouseName#_#TimeStamp#-#timestamp3#_by_#session.userid#.xls" output="#xml#"> 
<cfcontent reset="true" file="\\gum\c$\Inetpub\wwwroot\TIPS_Transport\MICheckInfo_#HouseName#_#TimeStamp#-#timestamp3#_by_#session.userid#.xls" type="application/vnd.ms-excel" deletefile="yes"> >
<!--- <cffile action="write" file="\\fs01\ar\MICheck_Exports\MICheckInfo_#HouseName#_#TimeStamp#.xls" output="#xml#">  --->

<!--- fs01\ar\MICheck_Exports --->
</cfprocessingdirective>

<cflocation url="Menu.cfm" ADDTOKEN="No">




