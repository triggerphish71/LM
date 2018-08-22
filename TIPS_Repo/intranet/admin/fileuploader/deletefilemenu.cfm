
<cfset datasource = "DMS">

<cfinclude template="/intranet/header.cfm">

<cfquery name="getregion" datasource="Census" dbtype="ODBC">
Select region_ndx, regionname
From regions
</cfquery>

<cfquery name="getdepartments" datasource="ALCweb" dbtype="ODBC">
Select Department_Ndx,department
From Departments
</cfquery>

<cfquery name="getlocationtype" datasource="#datasource#" dbtype="ODBC">
Select *
from locationtype
</cfquery>

<cfquery name="getlibrarycategories" datasource="#datasource#" dbtype="ODBC">
Select distinct categories.name,cattopicassgn.uniqueid
From Categories,cattopicassgn
Where cattopicassgn.categoryid = Categories.uniqueid
</cfquery>

<script language="JavaScript1.2" type="text/javascript">
<!--
	function fieldset(searchtypefield)
	{
			if (searchtypefield == 1){
			document.resourcerec.searchtype[0].checked = true;}
			
			if (searchtypefield == 2){
			document.resourcerec.searchtype[1].checked = true;}
			
			if (searchtypefield == 3){
			document.resourcerec.searchtype[2].checked = true;}
			
			if (searchtypefield == 4){
			document.resourcerec.searchtype[3].checked = true;}
			
			if (searchtypefield == 5){
			document.resourcerec.searchtype[4].checked = true;}
			
			if (searchtypefield == 6){
			document.resourcerec.searchtype[5].checked = true;}
			
			//if (searchtypefield == 7){
			//document.resourcerec.searchtype[6].checked = true;}
	}
//-->
</script>
<form method="post" action="deletefilelisting.cfm" name="resourcerec">
  <ul>
    <table width="435" border="0" cellspacing="1" cellpadding="2">
      <tr> 
        <td colspan="3" bgcolor="#663300"><font face="Arial, Helvetica, sans-serif" size="4" color="White"">&nbsp;Locate Media to Delete</font></td>
      </tr>
      <tr bgcolor="#eaeaea"> 
        <td colspan="2"><font face="Arial, Helvetica, sans-serif" size="2"><b><font size="3">Find 
          By Location</font></b></font></td>
        <td width="215">&nbsp;</td>
      </tr>
      <tr bgcolor="#eaeaea"> 
        <td width="14"> 
          <div align="right"> </div>
        </td>
        <td width="186" valign="middle"> 
          <input type="radio" name="searchtype" value="regions">
          <b><font size="2" face="Arial, Helvetica, sans-serif">Region</font></b> 
        </td>
        <td width="215"><b> 
			<select name="region" onChange="fieldset(1)">
            <option value="">Choose</option>
          <cfoutput query="getregion"> <option value="#region_ndx#">#regionname#</option></cfoutput>
		  </select>
          </b></td>
      </tr>
      <tr bgcolor="#eaeaea"> 
        <td width="14"> 
          &nbsp;
        </td>
        <td width="186" valign="middle"> 
          <input type="radio" name="searchtype" value="departments">
          <b><font size="2" face="Arial, Helvetica, sans-serif">Department</font></b> 
        </td>
        <td width="215"><b> 
          <select name="department" onChange="fieldset(2)">
            <option value="0">Choose</option>
			<cfoutput query="getdepartments"> <option value="#department_ndx#">#department#</option></cfoutput>
          </select>
          </b></td>
      </tr>
	  <tr bgcolor="#eaeaea"> 
        <td width="14"> 
          &nbsp;
        </td>
        <td width="186" valign="middle"> 
          <input type="radio" name="searchtype" value="library">
          <b><font size="2" face="Arial, Helvetica, sans-serif">Library</font></b> 
        </td>
        <td width="215"><b> 
          <select name="categoryid" onChange="fieldset(3)">
            <option value="0">Choose</option>
			<cfoutput query="getlibrarycategories"><option value="#uniqueid#">#name#</option></cfoutput>
          </select>
          </b></td>
      </tr>
	  <!--- comment: The other row has been removed because it was deemed unnecessary--->
      <!--- <tr bgcolor="#eaeaea"> 
        <td width="14"> 
          &nbsp;
        </td>
        <td width="186" valign="middle"> 
          <input type="radio" name="searchtype" value="other">
          <b><font size="2" face="Arial, Helvetica, sans-serif">Other</font></b> 
        </td>
        <td width="215"><b> 
          <select name="other" onChange="fieldset(4)">
            <option value="0">Choose</option>
			<cfoutput query="getlocationtype">
				<cfif locationtypename is not "regions">
					<cfif locationtypename is not "departments">
					<cfif locationtypename is not "library">
						<option value="#uniqueid#">#locationtypename#</option>
						</cfif>
					</cfif>
				</cfif>
			</cfoutput>
          
		  </select>
          </b></td>
      </tr> --->
      <tr bgcolor="#CCCCCC"> 
        <td colspan="2" valign="middle"> 
          <div align="left"> 
            <input type="radio" name="searchtype" value="postdate">
            <b><font size="2" face="Arial, Helvetica, sans-serif">Find By Post 
            Date</font></b></div>
        </td>
        <td width="215"><A href="javascript:calendar(1)"><img src="../../pix/calendaricon.gif" width="19" height="20" border="0" alt=""></A>&nbsp; 
          <input type="text" name="postdate" size="10" maxlength="10" onFocus="fieldset(4)">
        </td>
      </tr>
      <tr bgcolor="#CCCCCC"> 
        <td colspan="2" valign="middle"> 
          <div align="left"> 
            <input type="radio" name="searchtype" value="expirationdate">
            <b><font size="2" face="Arial, Helvetica, sans-serif">Find By Expiration 
            Date</font></b></div>
        </td>
        <td width="215"><A href="javascript:calendar(2)"><img src="../../pix/calendaricon.gif" width="19" height="20" border="0" alt=""></A>&nbsp; 
          <input type="text" name="expirationdate" size="10" maxlength="10" onFocus="fieldset(5)">
        </td>
      </tr>
      <tr bgcolor="#CCCCCC"> 
        <td colspan="2" valign="middle"> 
          <div align="left"> 
            <input type="radio" name="searchtype" value="filename">
            <b><font size="2" face="Arial, Helvetica, sans-serif">Find By File 
            Name</font></b></div>
        </td>
        <td width="215"> 
          <input type="text" name="filename" size="30" maxlength="30" onClick="fieldset(6)">
        </td>
      </tr>
	  	  <!--- comment: Decided that since the queries return the archived data anyway, there is really no need to an 'archive' toggle--->
  <!---     <tr bgcolor="#999999"> 
        <td width="14">&nbsp;</td>
        <td width="186" valign="middle" bgcolor="#999999"> <b><font size="2" face="Arial, Helvetica, sans-serif"> 
          <font color="#FFFFFF"> 
          <input type="checkbox" name="archives" value="1">
          <font size="1">Search in Archives</font></font></font></b></td>
        <td width="215">&nbsp;</td>
      </tr> --->
      <tr bgcolor="#eaeaea"> 
        <td colspan="3" height="2"> &nbsp;&nbsp; &nbsp; 
          <input type="submit" name="Submit" value="Locate Media">
        </td>
      </tr>
    </table>
  </ul>
</form>
</body>
</html>
<cfinclude template="/intranet/Footer.cfm">