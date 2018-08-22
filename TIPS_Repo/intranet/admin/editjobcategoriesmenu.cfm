<!--------------------------------------->
<!--- Programmer: Andy Leontovich        --->
<!--- File: admin/editjobcategories.cfm  --->
<!--- Company: Maxim Group/ALC           --->
<!--- Date: June                         --->
<!--------------------------------------->
<cfparam name="url.page" default="0">
<cfinclude template="/intranet/header.cfm">
 
<cfif url.page is 0>

<cfquery name="getcatagories" datasource="#datasource#" dbtype="ODBC">
Select distinct heading,toc_ndx
From jobtoc
Where user_id = #session.userid#
</cfquery>

<ul>
<cfoutput><form action="editjobcategory.cfm?region2=#url.region#" method="post"></cfoutput>
<table width="490" border="0" cellspacing="0" cellpadding="2">
  <tr bgcolor="#006699"> 
    <td colspan="4">&nbsp;<font face="Arial, Helvetica, sans-serif" color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: medium;">&nbsp;Edit 
      A Job Category</font></td>
  </tr>
<tr bgcolor="#f7f7f7">
	<td><br>
		&nbsp;&nbsp;&nbsp;&nbsp;<select name="tocndx">
			<option value="0" SELECTED>Choose</option>
			<cfoutput query="getcatagories"><option value="#toc_ndx#">#heading#</option></cfoutput>
		</select>
		<input type="hidden" name="tocndx_required" value="Please select a category.">
		<br><br>
	</td>
</tr>
<tr bgcolor="#eaeaea">
	<td>
		&nbsp;<input type="submit" name="submit" value="Retrieve Category">
	</td>
</tr>
      </td>
  </tr>
</table>
</ul>


<input type="hidden" name="function" value="2">
<input type="hidden" name="taskid" value="1">
</form>
</cfif>


<cfinclude template="/intranet/Footer.cfm">
</body>
</html>
