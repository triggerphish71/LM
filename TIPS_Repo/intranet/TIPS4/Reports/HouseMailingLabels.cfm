<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>HouseMailingLabels</title>
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

<cfquery name="spMailingLabels" DATASOURCE="#APPLICATION.datasource#">
		EXEC  rw.sp_MailingLabels
		@HouseID = #HouseData.iHouse_ID# 
</cfquery>

<body>
	<cfdocument  format="PDF" orientation="portrait" margintop=".1" marginbottom=".1" marginleft="1" marginright="1">
		<cfdocumentitem type="header"  evalAtPrint="true">  
			<cfoutput>&nbsp;</cfoutput>
		</cfdocumentitem>
		<cfset addressarray = arraynew(2)>
		<cfloop query="spMailingLabels">
			<cfset addressarray[currentRow][1] = #payerFirstName#>
			<cfset addressarray[currentRow][2] = #PayerLastName#>	
			<cfset addressarray[currentRow][3] = #PayerAddressLine1#>
			<cfset addressarray[currentRow][4] = #payerAddressLine2#>
			<cfset addressarray[currentRow][5] = #PayerCity#>
			<cfset addressarray[currentRow][6] = #PayerStateCode#>		
			<cfset addressarray[currentRow][7] = #PayerZipCode#>				
		</cfloop>
		<cfset total_records = spMailingLabels.recordcount>
		<cfset counter = 0>
		<cfset lncnt = #total_records#/3>
		<cfoutput>

			  <table width="100%">
				<cfloop   index="j"    from="1" to="#lncnt#">
					<tr align="center"> 
						<cfloop index="i" from="1" to="3" >
							<cfif counter  lt #total_records#>
								<cfset counter = counter + 1>	
								<td align="left" width="33%" style="font-size:10px">
									#addressarray[Counter][1]# #addressarray[Counter][2]#<br  />
									#addressarray[Counter][3]#
									<cfif #addressarray[Counter][4]# is not ''><br />
									#addressarray[Counter][4]#</cfif><br />
									#addressarray[Counter][5]#,#addressarray[Counter][6]# #addressarray[Counter][7]#
								</td>
							</cfif>
						 </cfloop>
					</tr>
					<tr>
						<td>&nbsp;</td>
					</tr>
				</cfloop> 
			</table> 
		</cfoutput>
		<cfdocumentitem  type="footer" evalAtPrint="true">
			<cfoutput>
				<table width="100%">
					<tr>
						<td style="font-size:small; ">&nbsp;</td>
					</tr>
				</table>
			</cfoutput>
		</cfdocumentitem>
	
		<cfoutput>  	
			<cfheader name="Content-Disposition"   
			value="attachment;filename=MailingLabels-#HouseData.cname#.pdf"> 
		</cfoutput>			
	</cfdocument>
</body>
</html>
