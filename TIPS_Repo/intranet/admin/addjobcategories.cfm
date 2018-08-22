<!--------------------------------------->
<!--- Programmer: Andy Leontovich        --->
<!--- File: admin/librarycategories.cfm  --->
<!--- Company: Maxim Group/ALC           --->
<!--- Date: June                         --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfinclude template="/intranet/header.cfm">

<cfquery name="getcatagories" datasource="#datasource#" dbtype="ODBC">
Select heading
From jobtoc
Where nregionnumber = #url.region#
</cfquery>

<cfquery name="getregions2" datasource="#datasource#" dbtype="ODBC">
Select RegionName
From VW_regions
Where nregionnumber = #url.region#
</cfquery>


<ul>
<form action="jobaction.cfm" method="post">
<table width="500" border="0" cellspacing="2" cellpadding="2">
  <tr bgcolor="#FFFFFF"> 
    <td colspan="2" bgcolor="#006666"><cfoutput><font face="Arial, Helvetica, sans-serif" color="##FFFFFF">&nbsp;<font size="4">Add 
      A Job Category for the #getregions2.regionname# Region</font></cfoutput></td>
  </tr>
  <tr bgcolor="#eaeaea"> 
    <td width="234">&nbsp;<b><font size="2" face="Arial, Helvetica, sans-serif" color="#666666">New 
      Category</b></font>
	 
     <input type="text" name="name" size="40" maxlength="39">
	  <input type="hidden" name="name_required" Value="Please enter a name for the category.">
      <br>
      </font>
      &nbsp;<input type="submit" name="Submit" value="Submit Category">
      </td>
    
    <td width="258"> <font size="2"><b><font face="Arial, Helvetica, sans-serif" color="#666666">Current 
      Categories</font><br>
      <select name="currentcategories" size="7" multiple>
	  <cfif IsDefined("getcatagories.heading") is "False">
			  <option value="" selected>None</option>
		<cfelse>
		  <cfoutput query="getcatagories"><option value="">#heading#</option></cfoutput>
		</cfif>
      </select>
      </td>
  </tr>
</table>

</ul>
<input type="hidden" name="function" value=1>
<input type="hidden" name="taskid" value=1>
<cfoutput><input type="hidden" name="region" value="#url.region#"></cfoutput>
</form>
<cfinclude template="/intranet/Footer.cfm">

