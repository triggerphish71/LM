
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Diagnosis Type Administration</title>

<style type="text/css">     
    select {
        width:375px;
    }
</style>

</head>

<cfquery name="GetDiagnosis" datasource="#Application.DataSource#">
    Select iDiagnosisType_ID, cDescription
    From DiagnosisType
	where dtRowDeleted is null
    Order By cDescription
</cfquery>
<cfquery name="ReDiagnosis" datasource="#Application.DataSource#">
    Select iDiagnosisType_ID, cDescription
    From DiagnosisType
	where dtRowDeleted is not null
    Order By cDescription
</cfquery>

<cfinclude template="../../../header.cfm">
<body>

	<P class="PAGETITLE"><h4> Create New Diagnosis Types : </h4></P> 
<!---<A Href="../../Admin/Menu.cfm" style="Font-size: 14;">Click Here to Go Back To Administration Screen.</a>
<BR><BR>--->
<!---<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm"></br></br>--->
<TABLE><TR>
<TH COLSPAN="4" STYLE="CENTER"> DIAGNOSIS TYPES ADMINISTRATION </TH>
    <div id="NewCommentDisplay" style="position:absolute;left:200px;top:250px;z-index:1">
        <form name="AddDiagnosis" action="DiagnosisInsert.cfm" method="post">
          <TABLE>			
			<TR> <tr><td>&nbsp;</td></tr>
				<TD>Create New Diagnosis : 
				</TD>
				<td> <input type="text" name="cDescription" maxlength="50" size="57" /> <br />
				</td>
				<td>
					<input type="submit" name="Add" value=" Add " />   
				</td>
			</TR>
			<TR><td></td>&nbsp;</TR><TR><td>&nbsp;</td></TR><TR><td></td></TR><TR></TR>
			<TR></TR>			
		</TABLE>            
       </form>    
    <!---<div id="DelCommentDisplay" style="position:absolute;left:200px;top:350px;z-index:1">--->
        <form name="DeleteDiagnosis" action="DiagnosisDelete.cfm" method="post">
           <TABLE>			
			<TR><tr><td>&nbsp;</td></tr>
				<TD>Delete Existing Diagnosis : 
				</TD>
				<td> 
				 <select name="iDiagnosisType_ID" style="size:50EOM">
                    <option value=""></option>
                     <cfoutput query="GetDiagnosis">
                    <option value="#iDiagnosisType_ID#">#cDescription#</option>
                     </cfoutput>
                 </select> <br />
				</td>
				<td>
					 <input type="submit" name="Delete" value="Delete" />   
				</td>
			</TR>
			<TR><td>&nbsp;</td></TR><TR></TR>		
		 </TABLE> 
       </form>
	   <form name="ReopenDiagnosis" action="DiagnosisReopen.cfm" method="post">
           <TABLE>			
			<TR><tr><td>&nbsp;</td></tr>
				<TD>Re-Open Unused Diagnosis : 
				</TD>
				<td> 
				 <select name="iDiagnosisType_ID" style="size:50EOM">
                    <option value=""></option>
                     <cfoutput query="ReDiagnosis">
                    <option value="#iDiagnosisType_ID#">#cDescription#</option>
                     </cfoutput>
                 </select> <br />
				</td>
				<td>
					 <input type="submit" name="Re-Open" value="Re-Open" />   
				</td>
			</TR>
			<TR><td>&nbsp;</td></TR><TR></TR>		
		 </TABLE> 
       </form>
    </div>
</TR>
<TR>
 <td>"***Available Diagnosis Types record Count! - &nbsp;<font color="red"><cfoutput>#GetDiagnosis.RecordCount#</cfoutput></font></td>
</TR>
</TABLE>
<br />
<br />
<A Href="../../Admin/Menu.cfm" style="Font-size: 14;">Click Here to Go Back To Administration Screen.</a>

</body>
</html>
<CFINCLUDE TEMPLATE="../../../footer.cfm">
