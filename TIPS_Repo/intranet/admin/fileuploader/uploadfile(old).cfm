<cfinclude template="/intranet/header.cfm">
<cfset datasource = "ALCWeb">
<cfset datasource1 = "DMS">

<cfquery name="getdepartment" datasource="#datasource1#" dbtype="ODBC">
Select Department,directory
From vw_Departments
</cfquery>

<cfquery name="getregion" datasource="#datasource1#" dbtype="ODBC">
Select regionname,region_ndx
From vw_regions
</cfquery>

<cfquery name="getmediatype" datasource="#datasource1#" dbtype="ODBC">
Select *
From MediaType
</cfquery>

<cfquery name="getlibrarycategories" datasource="#datasource1#" dbtype="ODBC">
Select distinct categories.name,cattopicassgn.uniqueid
From Categories,cattopicassgn
Where cattopicassgn.categoryid = Categories.uniqueid
</cfquery>

<cfquery name="getlibrarycategories2" datasource="#datasource1#" dbtype="ODBC">
Select name,uniqueid
From Categories
</cfquery>


<script language="JavaScript1.2" type="text/javascript">
<!--
	function getcatid()
	{
		var catid = window.document.resourcerec.categoryid.value;
		//alert(catid);
		
		assign('fileassign.cfm?categoryid=' + catid,500,500)
	}
	
	
	function fieldset(searchtypefield)
	{
			if (searchtypefield == 1){
			document.resourcerec.location[0].checked = true;}
			
			if (searchtypefield == 2){
			document.resourcerec.location[1].checked = true;}
			
			if (searchtypefield == 3){
			document.resourcerec.location[2].checked = true;}
	}
//-->
</script>

<form action="fileuploadaction.cfm" method="post" enctype="multipart/form-data" name="resourcerec">
  <ul>
    <table width="650" border="0" cellspacing="2" cellpadding="2">
      <tr bgcolor="#006666"> 
        <td colspan="4"><font face="Arial, Helvetica, sans-serif" color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;"> 
          &nbsp;File Upload</font></td>
      </tr>
      <tr bgcolor="#f7f7f7"> 
        <td colspan="2"><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;Location:</font></b></td>
        <td colspan="2" width="441">&nbsp; </td>
      </tr>
      <tr bgcolor="#f7f7f7"> 
        <td width="16">&nbsp;</td>
        <td width="89"><b><font size="2" face="Arial, Helvetica, sans-serif">&nbsp;Departments:</font></b></td>
        <td colspan="2" width="441"> 
          <input type="radio" name="location" value="departments">
          <select name="department" onChange="fieldset(1)">
			<option value="1" SELECTED>Choose</option>
			<cfoutput query="getdepartment"><option value="#department#">#Department#</option></cfoutput>
          </select>
        </td>
      </tr>
      <tr bgcolor="#f7f7f7"> 
        <td width="16">&nbsp;</td>
        <td width="89"><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;Regions:</font></b></td>
        <td colspan="2" width="441"> 
          <input type="radio" name="location" value="Regions">
          <select name="region" onChange="fieldset(2)">
            <option value="0" SELECTED>Choose</option>
            <cfoutput query="getregion"><option value="#regionName#">#regionName#</option></cfoutput>
          </select>
        </td>
      </tr>
   <!---    <tr bgcolor="#f7f7f7"> 
        <td width="16">&nbsp;</td>
        <td width="89"><b><font size="2" face="Arial, Helvetica, sans-serif">&nbsp;Operations:</font></b></td>
        <td colspan="2" width="441"> 
          <input type="radio" name="location" value="Operations">
          &nbsp;</td>
      </tr> --->
      <tr bgcolor="#f7f7f7"> 
        <td width="16">&nbsp;</td>
        <td width="89"><b><font size="2" face="Arial, Helvetica, sans-serif">&nbsp;Library:</font></b></td>
        <td colspan="2" valign="middle"> 
          <input type="radio" name="location" value="Library">
          &nbsp;&nbsp;&nbsp;<b><font size="2" face="Arial, Helvetica, sans-serif">Assign to Category:</font> 
		  &nbsp;&nbsp;<select name="categoryid" onChange="fieldset(3)">
		  <option value="" SELECTED>Choose</option>
		<cfoutput query="getlibrarycategories2"><option value="#uniqueid#">#name#</option></cfoutput>
</select>
</td>
      </tr>
	   <tr bgcolor="#f7f7f7"> 
        <td width="16">&nbsp;</td>
        <td width="89">&nbsp;</td>
        <td colspan="2" valign="middle">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b><font size="2" face="Arial, Helvetica, sans-serif">Associate File:</font>&nbsp;&nbsp;<input type="text" name="childname">&nbsp;<input type="button" name="assign" value="Select File" onClick="getcatid();">
        
		</td>
      </tr>
	   <tr bgcolor="#ffffff"> 
        <td height="4" colspan="3"></td> 
      </tr>
	  <tr bgcolor="#eaeaea"> 
        <td colspan="2"><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;Heading:</font></b></td>
        <td colspan="2" width="441"> 
			<input type="text" name="heading" size="50" maxlength="50">
        </td>
      </tr>
	  <tr bgcolor="#eaeaea"> 
        <td colspan="2"><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;Subheading:</font></b></td>
        <td colspan="2" width="441"> 
			<input type="text" name="subheading" size="50" maxlength="50">
        </td>
      </tr>
	  <tr bgcolor="#eaeaea"> 
        <td colspan="2"><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;Notes:</font></b></td>
        <td colspan="2" width="441"> 
		<input type="text" name="notes" size="50" maxlength="50">
        </td>
      </tr>
      <tr bgcolor="#eaeaea"> 
        <td colspan="2"><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;File:</font></b></td>
        <td colspan="2" width="441"> 
          <input type="file" name="docfile" size="50" accept="application/msword,application/pdf,image/jpeg,image/GIF,video/quicktime,application/x-msexcel,image/pjpeg">
        </td>
      </tr>
	   <tr bgcolor="#eaeaea"> 
        <td colspan="4"><font color="#CC0033" size="1" face="Arial, Helvetica, sans-serif">  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*</font><font size="1" face="Arial, Helvetica, sans-serif"> 
        You can only upload: jpeg,(jpg), gif, pdf, and MS Word files.</font></td>
      </tr>
	  <tr bgcolor="#eaeaea"> 
        <td colspan="2"><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;Media Type:</font></b></td>
        <td colspan="2" width="441">
         <select name="mediatypeid">
		<option value="" SELECTED>Choose</option>
		<cfoutput query="getmediatype"><option value="#uniqueid#">#name#</option></cfoutput>
</select>
        </td>
      </tr>
	   <tr bgcolor="#ffffff"> 
        <td height="4" colspan="3"></td> 
      </tr>
      <tr bgcolor="#c6c6c6"> 
        <td colspan="2"><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;Post 
          Date:</font></b></td>
        <td colspan="2" width="441"><A href="javascript:calendar(1)"><img src="../../pix/calendaricon.gif" width="19" height="20" border="0"></A>
          <input type="text" name="postdate" size="10" maxlength="10">
        </td>
      </tr>
      <tr bgcolor="#c6c6c6"> 
        <td colspan="2"><b><font face="Arial, Helvetica, sans-serif" size="2">&nbsp;Expiration 
          Date:</font></b></td>
        <td colspan="2" width="441"><A href="javascript:calendar(2)"><img src="../../pix/calendaricon.gif" width="19" height="20" border="0"></A>
          <input type="text" name="expirationdate" size="10" maxlength="10">
        </td>
      </tr>
	   <tr bgcolor="#ffffff"> 
        <td height="4" colspan="3"></td> 
      </tr>
      <tr bgcolor="#f7f7f7"> 
        <td colspan="2"> 
		<cfoutput> <input type="hidden" name="uploadedby" value="#session.userid#" size="20" maxlength="20"></cfoutput>
		<input type="hidden" name="childfile">
		<input type="hidden" name="location_required">
		<input type="hidden" name="docfile_required">
		<input type="hidden" name="postdate_required">
		<input type="hidden" name="mediatypeid_required">
		<input type="hidden" name="heading_required">
		<input type="hidden" name="expirationdate_required">
          <input type="submit" name="Submit" value="Begin Upload">
        </td>
        <td colspan="2" width="441">&nbsp;</td>
      </tr>
    </table>
  </ul>
</form>
</body>
</html>
<cfinclude template="/intranet/Footer.cfm">