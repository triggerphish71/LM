
<!--- Make Sure a Comment was selected for deletion --->
<cfif Form.iDiagnosisType_ID eq ''>

	<script>
		alert('You did not select a Diagnosis Type to delete.  Nothing deleted.');
		location.replace('DiagnosisType.cfm');
	</script>	

	<cfabort>

</cfif>  

<cftry>

    <!---<cfquery name="AddDiagnosis" datasource="#Application.Datasource#">
        Delete From DiagnosisType
        Where iDiagnosisType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#iDiagnosisType_ID#">
    </cfquery>--->

   <cfquery name="AddDiagnosis" datasource="#Application.Datasource#">
        Update DiagnosisType SET dtRowDeleted = getdate() 
        Where iDiagnosisType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#iDiagnosisType_ID#">
    </cfquery>
	
	<cfcatch type="any">
    	<center>
        	<h1>There was an issue with deleting this Diagnosis Type, please contact the helpdesk.</h1>
        	<a href="DiagnosisType.cfm">Go Back</a>
        </center>
        <cfabort>
    </cfcatch>

</cftry>

<script>
	location.replace('DiagnosisType.cfm');
</script>