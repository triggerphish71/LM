<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Census Monthly Report Excel Selection Page</title>
</head>
<cfinclude template="../../header.cfm">
<cfparam name="CensusMonth" default="">
<cfparam name="residentselect" default="">
<!--- #SESSION.qSelectedHouse.iHouse_ID# --->
<CFQUERY NAME="qryCommunity" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, h.cName 'Community', H.cNumber,oa.cname as 'Region', OA.cNumber as OPS, r.cname as 'Division', R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	 	H.dtrowdeleted is NULL
	  AND	H.bisSandbox = 0
	  order by Community
</CFQUERY>
<CFQUERY NAME="qryRegion" DATASOURCE="#APPLICATION.datasource#">
	SELECT	Distinct (oa.cname) as 'Region'  , oa.iOPSArea_ID, r.cname as Division
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	 	H.dtrowdeleted is NULL
	  AND	H.bisSandbox = 0
	  order by Division,Region
</CFQUERY>
<CFQUERY NAME="qryDivision" DATASOURCE="#APPLICATION.datasource#">
	SELECT	Distinct (r.cname) as 'Division'  , r.iRegion_ID
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	 	H.dtrowdeleted is NULL
	  AND	H.bisSandbox = 0
	  order by Division
</CFQUERY>
<script type="text/javascript">

 

/***********************************************
* Limit number of checked checkboxes script- by JavaScript Kit (www.javascriptkit.com)
* This notice must stay intact for usage
* Visit JavaScript Kit at http://www.javascriptkit.com/ for this script and 100s more
***********************************************/

function checkboxlimit(checkgroup, limit){
	var checkgroup=checkgroup
	var limit=limit
	for (var i=0; i<checkgroup.length; i++){
		checkgroup[i].onclick=function(){
		var checkedcount=0
		for (var i=0; i<checkgroup.length; i++)
			checkedcount+=(checkgroup[i].checked)? 1 : 0
		if (checkedcount>limit){
			alert("You can only select a maximum of "+limit+" Communities for Combined Monthly Census Report")
			this.checked=false
			}
		}
	}
}
 
function checkboxone(){
	var checkgroupHouse=document.forms.CensusSelect.selHouse;
	var checkgroupRegion=document.forms.CensusSelect.selRegion;	
	var checkedcountHouse=0;
	var checkedcountRegion=0;	
//		alert('Houses ' + checkgroupHouse.length);
//		alert('Regions ' + checkgroupRegion.length);		
		for (var i=0; i<checkgroupHouse.length; i++)
			checkedcountHouse+=(checkgroupHouse[i].checked)? 1 : 0
//			alert(checkedcountHouse);
		for (var i=0; i<checkgroupRegion.length; i++)
			checkedcountRegion+=(checkgroupRegion[i].checked)? 1 : 0
//			alert(checkedcountRegion);			
			
		if (checkedcountHouse==0 && checkedcountRegion==0){
 			alert("Select at least 1 Community or a Region")
			   return false;
			}
} 

function valthisform()
{
   if(!this.CensusSelect.restypAll.checked &&
     !this.CensusSelect.restypPriv.checked &&
    !this.CensusSelect.restypResp.checked&&
    !this.CensusSelect.restypMed.checked){
   alert("You must select \'All\' Resident types or any combination of Private, Respite, Medicaid");
   return false;
   }

 	var checkgroupHouse=document.forms.CensusSelect.selHouse;
	var checkgroupRegion=document.forms.CensusSelect.selRegion;	
	var checkedcountHouse=0;
	var checkedcountRegion=0;	
//		alert('Houses ' + checkgroupHouse.length);
//		alert('Regions ' + checkgroupRegion.length);		
		for (var i=0; i<checkgroupHouse.length; i++)
			checkedcountHouse+=(checkgroupHouse[i].checked)? 1 : 0
//			alert(checkedcountHouse);
		for (var i=0; i<checkgroupRegion.length; i++)
			checkedcountRegion+=(checkgroupRegion[i].checked)? 1 : 0
//			alert(checkedcountRegion);			
			
		if (checkedcountHouse==0 && checkedcountRegion==0){
 			alert("Select at least 1 Community or a Region")
			   return false;
			}
}
</script>
<body>
<cfoutput>
	<form action="CensusMonthlyReportXLSSel2.cfm" name="CensusSelect" method="post" onsubmit="return valthisform();">

		<input type="hidden" name="residentselect" id="residentselect" value="Yes" />
	<table width="100%">
		<tr>
			<th colspan="4">Monthly Census Report Excel Download</th>
		</tr>

		
		<cfif len(month(#now()#)) is 1>
			<cfset CensusMonth =  year(#now()#)&  0 & month(#now()#)>
		 <cfelse>
		 	<cfset CensusMonth =  year(#now()#)&  month(#now()#)>
		 </cfif> 
		<tr>
			<td>&nbsp;</td>
			<td colspan="2" style="color:##FF0000; font-weight:bold; text-align:left">
			<li>Enter Date of Report Selection
			<!--- <li> Enter 'YYYYMM' for the year and month required for the report --->
			<!--- < />Select Region OR Select up to 5 individual Communities. --->
			<li />Select Resident Types: All, Private, Medicaid, Respite.
			<li />Click Submit 
			<li />House Selection page is next screen</td>
			<td>&nbsp;</td>
		</tr>		 

		<tr>
			<td colspan="4" style="text-align:center">Enter date for Report as 'YYYYMM' (Current Month is default)<br />
			<input type="text" name="CensusMonth" value="#CensusMonth#" /></td>
		</tr>
		<tr style="background-color:##CCCCCC">
			<td>Select Resident Type(s):</td>
			<td colspan="3">
			<input type="checkbox" name="restypAll" value="All" >All<br />
			<input type="checkbox" name="restypPriv" value="1">Private<br />
			<input type="checkbox" name="restypMed"  value="2">Medicaid<br /> 
			<input type="checkbox" name="restypResp" value="3">Respite<br />
			</td>
		</tr>
		<tr>
			<td colspan="4" style="text-align:center"><input type="submit"  name="submit" value="Submit" /></td>
		</tr>
		
<!--- 		<tr style="color:##CC9933; font-weight:bold">
			<td colspan="4">Select by Division</td>	
		</tr>
		<cfloop query="qryDivision"> 
		<tr>
			<td>&nbsp;</td>
			<td colspan="3"><input type="checkbox" name="selDivision" value="#iRegion_ID#">#Division#</td>
		</tr>	
		</cfloop> --->	
<!--- 		<div id="regionsel" style="display:block"> --->
</table>
</form>
</cfoutput>
<cfif residentselect is 'Yes'>
<cfoutput>
<form>
<table width="100%">
		<tr style="color:##CC9933; font-weight:bold">
			<td colspan="4">Select by Region For a Monthly Census Report of all Communities in that Region</td>	
		</tr>	
		<tr>
			<th style="text-align:right" >Select</th>
			<th>Region</th>
			<th>Division</th>
			<th>&nbsp;</th>
		</tr>
		<cfloop query="qryRegion">
			<tr style="background-color:##CCFF66;"  >  
				<td style="text-align:right" ><input  type="radio" 
				id="selRegionID" name="selRegion" 
				value="#iopsarea_ID#" 
				></td>			
				<td colspan="1">#Region#</td>
				<td colspan="1">#Division#</td>
				<td>&nbsp;</td>
			</tr>
		</cfloop>	
	<!--- onclick="viewthisRegion()"	</div> --->
<!--- 		<tr style="color:##CC9933; font-weight:bold">
			<td>Select all Houses</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td  colspan="3"><input type="checkbox" name="allHouse" value="Yes">All Houses</td>
		<tr/> --->
<!--- 		<div id="housesel" style="display:block"> --->
		<tr style="color:##CC9933; font-weight:bold">
			<td colspan="4">Select up to Five (5) Individual Communities for Monthly Census Report</td>
		</tr> 
		<tr>
			<th style="text-align:right" >Select</th>
			<th>Community</th>
			<th>Region</th>
			<th>Division</th>
		</tr>
 		<cfloop query="qryCommunity" >

		<tr style="background-color: lightblue;">
			<td style="text-align:right" >
			<input type="checkbox" 
			 id="selHouseID"
			name="selHouse" 
			value="#ihouse_id#"  />
			</td>
			<td>#Community#</td>
			<td>#Region#</td>
			<td>#Division#</td>
		</tr>

		</cfloop>  


<!--- </div> onclick="viewthisHouse(this,document.page_form.selHouse)">--->
		<tr>
			<td colspan="4" style="text-align: center">
			<input type="submit"  name="submit" value="Submit"/>
			</td>
		</tr>
		</table>
</cfoutput>
</cfif>
<script type="text/javascript">

//Syntax: checkboxlimit(checkbox_reference, limit)
checkboxlimit(document.forms.CensusSelect.selHouse, 5);
//checkboxone(document.forms.CensusSelect.selHouse, 1);
</script>
</form>
<!--- <cflocation url="CensusMonthlyReportXLS.cfm?prompt1=201705"> --->

</body>
<cfinclude template="../../Footer.cfm">
