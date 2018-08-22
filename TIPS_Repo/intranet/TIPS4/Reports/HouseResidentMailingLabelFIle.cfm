<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>MailingLabelDownload</title>
</head>
<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, h.cName, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	  AND	H.dtrowdeleted is NULL
	  AND	H.bisSandbox = 0
</CFQUERY>

<cfquery name="getResidentData" DATASOURCE="#APPLICATION.datasource#">
		EXEC  rw.sp_MailingLabels
		@HouseID = #HouseData.iHouse_ID# 
</cfquery>
	<cfprocessingdirective suppresswhitespace="Yes">
		<!--- <cfcontent type="text/xml; charset=utf-16"> --->
	<cfxml variable="xmlDataDump"> 
		<?mso-application progid="Excel.Sheet"?>
		<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
		 xmlns:o="urn:schemas-microsoft-com:office:office"
		 xmlns:x="urn:schemas-microsoft-com:office:excel"
		 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
		 xmlns:html="http://www.w3.org/TR/REC-html40">
		<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
			<ActiveSheet>1</ActiveSheet>
			<ProtectStructure>False</ProtectStructure>
			<ProtectWindows>False</ProtectWindows>
		</ExcelWorkbook>
		<Styles>
			<ss:Style ss:ID="Default" ss:name="Normal">
			<Alignment ss:Vertical="Top"  ss:WrapText="1"/>
			<Borders/>
			<Font/>
			<Interior/>
			<NumberFormat/>
			<Protection/>
			</ss:Style>
		</Styles>		
						<cfoutput>
							<Worksheet ss:Name="mailinglabeldata">
								<Table>
									<Column ss:AutoFitWidth="0" ss:Width="50"  />		
									<Column ss:AutoFitWidth="0" ss:Width="50"  />
									<Column ss:AutoFitWidth="0" ss:Width="50"  />																																																
									<Column ss:AutoFitWidth="0" ss:Width="50"  />
									<Column ss:AutoFitWidth="0" ss:Width="50"  />	
									<Column ss:AutoFitWidth="0" ss:Width="50"  />
									<Column ss:AutoFitWidth="0" ss:Width="50"  />									
<!--- 									<Row>
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 										 
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 						 
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String"></Data>
										</Cell> 	
									</Row> --->
								<cfloop query="getResidentData">
									 <Row>
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(PayerFirstName))#</Data>
										</Cell> 
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(PayerlastName))#</Data>
										</Cell> 										 
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(PayerAddressLine1))#</Data>
										</Cell> 						 
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(payerAddressLine2))#</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(PayerCity))#</Data>
										</Cell> 					
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(PayerStateCode))#</Data>
										</Cell> 							
										<Cell>
											<Data ss:Type="String">#XmlFormat(trim(PayerZipCode))#</Data>
										</Cell> 				

									 </Row> 
<!--- 									 <cfquery name="UpdTransLog" datasource="#APPLICATION.datasource#">
									 Insert into MailingLabels (
										  cfirstname
										,clastname
										,cAddress1  
										,cAddress2 
										,cCity 
										,cState 
										,cZip
							
										 )
										values
										( ##
										,##
										,'##'
										,'##'
										,'##'
										,'##'
										,'##'
											)							 
									 </cfquery> --->
								</cfloop>
								</Table>
							</Worksheet>
						</cfoutput>
						</Workbook>
					</cfxml>
				 <cfset xml = ToString(xmlDataDump)> 
 			 	 <cfoutput><cffile action="append" nameconflict="overwrite" file="#MailingLabels#todaysdate#.xls"  output="#xml#"></cfoutput>  
	</cfprocessingdirective>
<body>
</body>
</html>
