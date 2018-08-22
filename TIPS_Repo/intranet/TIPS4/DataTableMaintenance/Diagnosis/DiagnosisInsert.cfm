
<!--- Make Sure the Comment is not all spaces and is at least 3 charaters long --->
<cfif trim(form.cDescription) eq '' or len(trim(form.cDescription)) LT 3>

	<script>
		alert('The Diagnosis Type you entered is to small.  It must have a length of at least 3 characters.');
		location.replace('DiagnosisType.cfm');
	</script>	

	<cfabort>

</cfif>  


<!--- Make Sure the Diagnosis doesn't already exist --->

<cftry>

    <cfquery name="DiagnosisCheck" datasource="#Application.Datasource#">
        Select cDescription
        From DiagnosisType
        Where cDescription = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#Form.cDescription#" maxlength="50">
    </cfquery>
    
	<cfcatch type="any">
    	<center>
        	<h1>There was an issue with validating this Diagnosis, please contact the helpdesk.</h1>
        	<a href="DiagnosisType.cfm">Go Back</a>
        </center>
        <cfabort>
    </cfcatch>
    
</cftry>

<cfif DiagnosisCheck.RecordCount GT 0>

	<script>
		alert('The Diagnosis Type you entered already exists');
		location.replace('DiagnosisType.cfm');
	</script>	

	<cfabort>

</cfif> 

<cftry>
    <cfquery name="AddDiagnosis" datasource="#Application.Datasource#">
        Insert Into DiagnosisType
        (cDescription, cRowStartUser_ID, dtRowStart)
        Values
        (<cfqueryparam cfsqltype="cf_sql_varchar" value="#Form.cDescription#" maxlength="50">, #SESSION.UserID#, getDate() )
    </cfquery>
    
	<cfcatch type="any">
    	<center>
        	<h1>There was an issue with adding this Diagnosis, please contact the helpdesk.</h1>
        	<a href="DiagnosisType.cfm">Go Back</a>
        </center>
        <cfabort>
    </cfcatch>
    
</cftry>

<script>
	location.replace('DiagnosisType.cfm');
</script>