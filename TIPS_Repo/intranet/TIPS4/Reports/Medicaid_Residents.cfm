<!----------------------------------------------------------------------------------------------
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| TPecku 	 |10/20/16    |		Created to generate the Medicaid Residents report			   |																				   |
|---------------------------------------------------------------------------------------------->

<cfif Not IsDefined ("form.choice")>
<cflocation url="menu.cfm?radio=no" addtoken="no">
</cfif>

<cfif IsDefined ("form.choice")>
	<cfif form.choice EQ 2 AND  Not IsDefined ("form.stateprompt1")>
<cflocation url="menu.cfm?choice=2" addtoken="no">
	<cfelseif form.choice EQ 3 AND Not IsDefined ("form.houseprompt1")>
<cflocation url="menu.cfm?choice=3" addtoken="no">
	</cfif>
</cfif>

<cfif isDefined ("form.houseprompt1")>
<cfquery name="Medicaid_Houses" datasource="#application.datasource#"> 
SELECT distinct ihouse_id, Community
FROM rw.vw_Medicaid_Residents_Data
where iHouse_id IN (#form.houseprompt1#)
order by Community asc
</cfquery>
<cfif Medicaid_Houses.recordcount EQ 1>
<cfset medicaid_house_list = Medicaid_Houses.Community>
<cfelse>
<cfset medicaid_house_list = valuelist(Medicaid_Houses.Community,", ")>
</cfif>
</cfif>


<CFQUERY NAME="Medicaid_Residents_Data" DATASOURCE="#APPLICATION.datasource#">
	select Division, Region, Community, State_Code, iTenant_ID, Resident_Name, Diagnosis_1, ICD10_Code_1, Diagnosis_2,
	Diagnosis_3, Diagnosis_4, Diagnosis_5, Diagnosis_6, Diagnosis_7, Billing_Date 
	FROM rw.vw_Medicaid_Residents_Data
	<cfif form.choice EQ 1>
	where Billing_Date between <cfqueryparam value=#form.dateprompt1# cfsqltype="CF_SQL_Date"> and <cfqueryparam value=#form.dateprompt2# cfsqltype="CF_SQL_Date">
	<cfelseif form.choice EQ 2>
	where State_Code in (<cfqueryparam value=#form.stateprompt1# cfsqltype="CF_SQL_VARCHAR" list="yes">) 
	and Billing_Date between <cfqueryparam value=#form.dateprompt1# cfsqltype="CF_SQL_Date"> and <cfqueryparam value=#form.dateprompt2# cfsqltype="CF_SQL_Date">
	<cfelse>
	where iHouse_ID in (#form.houseprompt1#)
	and Billing_Date between <cfqueryparam value=#form.dateprompt1# cfsqltype="CF_SQL_Date"> and <cfqueryparam value=#form.dateprompt2# cfsqltype="CF_SQL_Date">
	</cfif>
	order by division, Region, Community, State_Code, Billing_date
	</cfquery>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
 
<body>
<cfsavecontent variable="PDFhtml">
<cfheader name="Content-Disposition" 
value="attachment;filename=MedicaidResidentsList.pdf">
<table width="95%" border="0" style="table-layout: fixed">
<cfif Medicaid_Residents_Data.recordcount eq 0>
<div style="font-size:xx-large; color:##FF0000">
There are no Medicaid Residents  
</div>
<cfelse>

<cfoutput>			
	<cfloop query="Medicaid_Residents_Data">		
		<tr>
			<td style="text-align:left;font-size:8px"><div style="width: 30px">#Division#</div></td>
			<td style="text-align:left;font-size:8px"><div style="width: 30px">#trim(Region)#</div></td>  
			<td style="text-align:left;font-size:8px"><div style="width: 30px">#Community#</div></td>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#State_code#</div</td> 
			<td style="text-align:left;font-size:8px"><div style="width: 30px">#iTenant_ID#</div></td>			
			<td style="text-align:left;font-size:8px"><div style="width: 40px">#Resident_Name#</div></td>
			<cfif Diagnosis_1 EQ 0>
			<td style="text-align:left;font-size:8px"><div style="width: 30px">&nbsp;</div></td>
			<cfelse>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#Diagnosis_1#</div></td>
			</cfif>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#ICD10_code_1#</div></td>
			<cfif Diagnosis_2 EQ 0>
			<td style="text-align:left;font-size:7px"><div style="width: 60px">&nbsp;</div></td>
			<cfelse>
			<td style="text-align:cenetr;font-size:8px"><div style="width: 30px">#Diagnosis_2#</div></td>
			</cfif>
			<CFQUERY NAME="ICD10_2" DATASOURCE="#APPLICATION.datasource#">
			select ICD10 from diagnosistype
			where cDescription = <cfoutput>'#Diagnosis_2#'</cfoutput>
		</cfquery>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#ICD10_2.ICD10#</div></td>
			<cfif Diagnosis_3 EQ 0>
			<td style="text-align:center;font-size:8px"><div style="width: 40px">&nbsp;</div></td>
			<cfelse>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#Diagnosis_3#<div></td>
			</cfif>
			<CFQUERY NAME="ICD10_3" DATASOURCE="#APPLICATION.datasource#">
			select ICD10 from diagnosistype
			where cDescription ='#Diagnosis_3#'
		</cfquery>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#ICD10_3.ICD10#</div></td>
			<cfif Diagnosis_4 EQ 0>
			<td style="text-align:center;font-size:8px"><div style="width: 40px">&nbsp;</div></td>
			<cfelse>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#Diagnosis_4#</div></td>
			</cfif>
			<CFQUERY NAME="ICD10_4" DATASOURCE="#APPLICATION.datasource#">
			select ICD10 from diagnosistype
			where cDescription ='#Diagnosis_4#'
		</cfquery>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#ICD10_4.ICD10#</div></td>
			<cfif Diagnosis_5 EQ 0>
			<td style="text-align:center;font-size:8px"><div style="width: 40px">&nbsp;</div></td>
			<cfelse>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#Diagnosis_5#</div></td>
			</cfif>
			<CFQUERY NAME="ICD10_5" DATASOURCE="#APPLICATION.datasource#">
			select ICD10 from diagnosistype
			where cDescription = '#Diagnosis_5#'
		</cfquery>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#ICD10_5.ICD10#</div></td>
			<cfif Diagnosis_6 EQ 0>
			<td style="text-align:center;font-size:8px"><div style="width: 40px">&nbsp;</div></td>
			<cfelse>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#Diagnosis_6#</div></td>
			</cfif>
			<CFQUERY NAME="ICD10_6" DATASOURCE="#APPLICATION.datasource#">
			select ICD10 from diagnosistype
			where cDescription = '#Diagnosis_6#'
		</cfquery>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#ICD10_6.ICD10#</div></td>
			<cfif Diagnosis_7 EQ 0>
			<td style="text-align:center;font-size:8px"><div style="width: 40px">&nbsp;</div></td>
			<cfelse>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#Diagnosis_7#</div></td>
			</cfif>
			<CFQUERY NAME="ICD10_7" DATASOURCE="#APPLICATION.datasource#">
			select ICD10 from diagnosistype
			where cDescription = '#Diagnosis_7#'
		</cfquery>
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#ICD10_7.ICD10#</div></td> 
			<td style="text-align:center;font-size:8px"><div style="width: 30px">#dateformat(Billing_Date, 'mm/dd/yyyy')#</div></td>
		</tr>
	</cfloop>
	</cfoutput>
</table>
</cfif>
</cfsavecontent>

<cfdocument format="PDF" orientation="landscape" margintop="4" marginleft=".3" marginright=".5" unit="cm">
<cfdocumentsection>
<cfdocumentitem type="header" >  
	<table width="100%">
	<tr>
		<td>
			<h1 style="text-decoration:underline; text-align:center">Medicaid Residents List</h1>
		</td>
	</tr>
</table>

<table width="100%">		
	<tr>
		<td nowrap="nowrap" style="text-align:left; font-size:7px" width="33%">
		<h1><img src="../images/Enlivant_logo.jpg" /></h1></td>
	
		<td style="text-align:center; font-size:7px" width="33%">
		<h1>
		<cfif form.choice EQ 1>
		All Medicaid States and Houses
		<cfelseif form.choice EQ 2>
		Selected States:&nbsp;<cfoutput>#form.stateprompt1#</cfoutput>
		<cfelse>
		Selected Houses:<br><cfoutput>#medicaid_house_list#</cfoutput>
		</cfif>
		</h1>
		</td>
		<td nowrap="nowrap" style="text-align:center;font-size:7px">
		<h1>From:&nbsp;&nbsp;<cfoutput>#DateFormat(form.dateprompt1, "mmmm dd, yyyy")#</cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;To:&nbsp;&nbsp;<cfoutput>#DateFormat(form.dateprompt2, "mmmm dd, yyyy")#</cfoutput> </h1></td>
		</tr>						
</table>

<table width="95%">
<tr>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:4%;">
<h1>Div</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:4%;">
<h1>Region</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:4%;">
<h1>House</td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:4%;">
<h1>State</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:4%;">
<h1>Tenant<br>ID</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:4%;">
<h1>Resident<br>Name</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:6%;">
<h1>D 1</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:4%;">
<h1>ICD10<br>1</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:6%;">
<h1>D 2</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:4%;">
<h1>ICD10<br>2</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:7%;">
<h1>D 3</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:4%;">
<h1>ICD10<br>3</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:6%;">
<h1>D 4</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:4%;">
<h1>ICD10<br>4</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:7%;">
<h1>D 5</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:4%;">
<h1>ICD10<br>5</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:5%;">
<h1>D 6</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:5%;">
<h1>ICD10<br>6</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:5%;">
<h1>D 7</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:4%;">
<h1>ICD10<br>7</h1></td>
<td  style="border-bottom: .3px solid black;text-align:center;font-size:4px;font-weight:bold;width:auto">
<h1>Billing<br>Date</h1></td>
</tr>
</table>
	
</cfdocumentitem> 
<cfoutput>
	#variables.PDFhtml#
</cfoutput>		
	<cfdocumentitem  type="footer"  evalAtPrint="true">
		<cfoutput>
			<table  width="95%">
				<tr>
					<td colspan="3" style="font-size:small;text-align:right">
					Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
					</td>
				</tr>
				<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>
					<tr>
						<td style="font-size:small; text-align:left" >
						Medicaid Residents List
						</td>
						<td style="font-size:small; text-align:center">
						Use only as authorized by Enlivant&trade;
						</td>
						<td style="font-size:small; text-align:right">
						Printed: #dateformat(now(), 'mm/dd/yyyy')#
						</td>
					</tr> 
				</cfif>			
			</table>		
		</cfoutput>
	</cfdocumentitem>
</cfdocumentsection>
</cfdocument>
</body>
</html>
