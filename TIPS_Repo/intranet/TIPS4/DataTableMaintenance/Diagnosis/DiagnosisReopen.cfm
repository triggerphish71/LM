
<!--- Make Sure a Comment was selected for deletion --->
<cfif Form.iDiagnosisType_ID eq ''>

	<script>
		alert('You did not select a Diagnosis Type to Re-Open.  Nothing Re-open.');
		location.replace('DiagnosisType.cfm');
	</script>	

	<cfabort>

</cfif>  

<cftry>
    
   <cfquery name="reDiagnosis" datasource="#Application.Datasource#">
        Update DiagnosisType SET dtRowDeleted = NULL 
        Where iDiagnosisType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#iDiagnosisType_ID#">
    </cfquery>
	
	<cfcatch type="any">
    	<center>
        	<h1>There was an issue with Re-Open this Diagnosis Type, please contact the helpdesk.</h1>
        	<a href="DiagnosisType.cfm">Go Back</a>
        </center>
        <cfabort>
    </cfcatch>

</cftry>

<script>
	location.replace('DiagnosisType.cfm');
</script>
