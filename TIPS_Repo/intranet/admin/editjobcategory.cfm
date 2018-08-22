<!--------------------------------------->
<!--- Programmer: Andy Leontovich        --->
<!--- File: admin/editjobcategories.cfm  --->
<!--- Company: Maxim Group/ALC           --->
<!--- Date: June                         --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfinclude template="/intranet/header.cfm">

<cfquery name="getcatagories" datasource="#datasource#" dbtype="ODBC">
Select jobtoc.heading
From jobtoc
</cfquery>

<cfquery name="getcatagory" datasource="#datasource#" dbtype="ODBC">
Select jobtoc.heading
From jobtoc
Where toc_ndx = #tocndx#
</cfquery> 
<ul>
<form action="jobaction.cfm" method="post">
<table width="500" border="0" cellspacing="2" cellpadding="2">
  <tr bgcolor="#FFFFFF"> 
    <td colspan="2" bgcolor="#006699"><font face="Arial, Helvetica, sans-serif" color="#FFFFFF">&nbsp;<font size="4">Edit 
      A Job Category</font></td>
  </tr>
  <tr bgcolor="#eaeaea"> 
    <td height="39" width="234">&nbsp;<b><font size="2" face="Arial, Helvetica, sans-serif" color="#666666">Edit 
      Category Name</b></font>
	 
     <cfoutput><input type="text" name="name" value="#getcatagory.heading#" size="40" maxlength="39"></cfoutput>
	  <input type="hidden" name="name_required" Value="Please enter a name for the category.">
      <br>
      </font>
      &nbsp;<input type="submit" name="Submit" value="Submit Category">
      </td>
    
    <td width="258"> <font size="2"><b><font face="Arial, Helvetica, sans-serif" color="#666666">Current 
      Categories</font><font face="Arial, Helvetica, sans-serif"><br>
      <select name="currentcategories" size="7" multiple>
       <cfoutput query="getcatagories"><option value="">#heading#</option></cfoutput>
      </select>
      </font></b></font></td>
  </tr>
</table>

</ul>
<input type="hidden" name="function" value="2">
<input type="hidden" name="taskid" value="1">
<cfoutput><input type="hidden" name="toc_ndx" value="#tocndx#">
<input type="hidden" name="region" value="#region2#"></cfoutput>
</form>
<cfinclude template="/intranet/Footer.cfm">
