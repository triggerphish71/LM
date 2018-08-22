<cfcomponent displayname="utility Services" output="false" hint="I provide miscelanious services">

	<cffunction access="public" name="spreadSheetNewFromQuery" output="false" returntype="string" hint="I creaete an excel file from a query">
		<cfargument name="theData" type="query" required="true">
		<cfargument name="sheetName" type="string" default="Sheet1">
		<cfargument name="filename" type="string" default="test">
		<cfargument name="removeHeaderRow" type="boolean" default="false">
		<cfargument name="outputToBrowser" type="boolean" required="false" default="true">
		<cfargument name="folder" type="string" required="true">
	
		<cfset var tempPath = session.tempDocPath &"#arguments.folder#\#filename#.xls">
		<cfspreadsheet action="write" filename="#tempPath#" query="theData" sheetname="#arguments.sheetname#" overwrite="true">
		
		<cfif arguments.outputToBrowser>	
			<cffile action="readbinary" file="#tempPath#" variable="theSheet">
			<cfheader name="Content-Disposition" value="inline; filename=#filename#.xls"> 
			<cfcontent variable="#theSheet#" type="application/msexcel">	
		<cfelse>
			<cfreturn tempPath>
		</cfif>
	</cffunction>
	
	<cffunction access="public" name="getSignatures" output="false" returntype="query" hint="I return a query with information on esignature fields in a pdf">
		<cfargument name="filePath" type="string" required="true" hint="The full directory path to where the pdf resides example(C:\mypdfs)">
		<cfargument name="fileName" type="string" required="true" hint="the name of the pdf example(mypdf.pdf)">  

		<cfif fileExists("#arguments.filePath#\#arguments.filename#") AND isPDFFile("#arguments.filepath#\#arguments.filename#")>
			<cfpdf action="readsignaturefields" name="theResults" source="#arguments.filepath#\#arguments.filename#"></cfpdf>
		<cfelse>
			<cfset theResults = queryNew("id","integer")>
		</cfif>
		<cfreturn theResults>
	</cffunction>

	<cffunction access="public" name="validateSignatures" output="false" returntype="struct" hint="I return a struct that contains invalid signature and success keys">
		<cfargument name="filePath" type="string" required="true" hint="The full directory path to where the pdf resides example(C:\mypdfs)">
		<cfargument name="fileName" type="string" required="true" hint="the name of the pdf example(mypdf.pdf)">  
		
		<cfif fileExists("#arguments.filepath#\#arguments.filename#") AND isPDFFile("#arguments.filepath#\#arguments.filename#")>
			<cfpdf action="validatesignature" source="#arguments.filepath#\#arguments.filename#" name="signatureValidation"></cfpdf>			
		<cfelse>
			<cfset signatureValidation = {success="no",message="File does not exists or is not a pdf"}>
		</cfif>
		<cfreturn signatureValidation>		
	</cffunction>

	<cffunction access="public" name="signPDF" output="false" returntype="void" hint="I e-sign a pdf">
		<cfargument name="filepath" type="string" required="true" hint="The full directory path to where the pdf resides example(C:\mypdfs)">
		<cfargument name="filename" type="string" required="true" hint="the name of the pdf example(mypdf.pdf)">  
		<cfargument name="keyStorePath" type="string" required="true" hint="The full directory path to  where the key store example(C:\jre)">
		<cfargument name="keystoreName" type="string" required="true" hint="The name of the keystore including file extension example(myKeyStore.jks)">
		<cfargument name="ksPassword" type="string" required="true" hint="the keystore password">
		<cfargument name="destPath" type="string" required="false" hint="The full directory path to where you want to save the file(C:\jre)">
		<cfargument name="destName" type="string" required="false" hint="The name of the keystore including file extension example(myKeyStore.jks)">
		<cfargument name="fieldName" type="string" required="false" hint="The esignature field name. If this is not supplied then all eSingature fields will be signed">

		<!--- build the absolute path --->
		<cfif Right(arguments.filepath,1) EQ "\">
			<cfset local.fullPath = arguments.filepath & arguments.filename>
		<cfelse>
			<cfset local.fullPath = arguments.filepath & "\" & arguments.filename>
		</cfif>

		<!--- check if destination path exists or does it need to be created --->

		<!--- check if file exists and if its a pdf --->
		<cfif fileExists(local.fullpath) AND isPDFFile(local.fullpath)>
			<cfpdf action="sign" signaturefieldname="#arguments.fieldname#" source="#local.fullpath#" destination="#local.fullpath#" keystore="#arguments.keyStorepath#\#arguments.keyStoreName#" keystorepassword="#arguments.ksPassword#" overwrite="true" author="false"></cfpdf> 
		</cfif>
	</cffunction>


	<cffunction access="public" name="createDir" output="false" returntype="void" hint="I create a directory based on the input">
		<cfargument name="filepath" type="string" required="true" hint="The full directory path example(C:\mypdfs)">
		<cfdirectory action="create" directory="#aruments.filePath#">
	</cffunction>



	<cffunction access="public" name="getCatchInfo" output="true" returntype="void" hint="I output all the cfcatch variables">
		<cfargument name="theData" type="struct" required="true" hint="The cfcatch struct that is generated">
		<cfoutput>
			<p>
			<strong>cfcatch varibles</strong><br />
			CFCATCH.Type:<cfif isdefined("arguments.theData.type")><br /><#arguments.theData.type#</cfif><br /><br />
			CFCATCH.Message:<cfif isdefined("arguments.theData.message")><br />#arguments.theData.message#</cfif><br /><br />
			CFCATCH.Detail:<cfif isdefined("arguments.theData.detail")><br />#arguments.theData.detail#</cfif> <br /><br />
			CFCATCH.ErrNumber:<cfif isdefined("arguments.theData.ErrNumber")><br />#arguments.theData.errNumber#</cfif> <br /><br />
			CFCATCH.NativeErrorCode:<cfif isdefined("arguments.theData.NativeErrorCode")><br />#arguments.theData.NativeErrorCode#</cfif><br /><br />
			CFCATCH.SQLState:<cfif isdefined("arguments.theData.SQLState")><br />#arguments.theData.SQLState#</cfif><br /><br />
			CFCATCH.LockName:<cfif isdefined("arguments.theData.LockName")><br />#arguments.theData.LockName#</cfif><br /><br />
			CFCATCH.LockOperation:<cfif isdefined("arguments.theData.LockOperation")><br />#arguments.theData.LockOperation#</cfif><br /><br />
			CFCATCH.MissingFileName:<cfif isdefined("arguments.theData.MissingFileName")><br />#arguments.theData.MissingFileName#</cfif><br /><br />
			CFCATCH.TagContext:<cfif isdefined("arguments.theData.TagContext")><br /><cfdump var="#arguments.theData.TagContext#" label="arguments.theData.tagContext"></cfif><br /><br />
			CFCATCH.ErrorCode:<cfif isdefined("arguments.theData.ErrorCode")><br />#arguments.theData.ErrorCode#</cfif><br /><br />
			CFCATCH.ExtendedInfo:<cfif isdefined("arguments.theData.ExtendedInfo")><br />#arguments.theData.ExtendedInfo#</cfif><br /><br />
			CFCATCH.QueryError:<cfif isdefined("arguments.theData.QueryError")><br />#arguments.theData.QueryError#</cfif><br /><br />
			CFCATCH.SQL:<cfif isdefined("arguments.theData.SQL")><br />#arguments.theData.SQL#</cfif><br /><br />
			CFCATCH.Where:<cfif isdefined("arguments.theData.Where")><br />#arguments.theData.Where#</cfif><br /><br />
			CFCATCH.Datasource:<cfif isdefined("arguments.theData.Datasource")><br />#arguments.theData.Datasource#</cfif><br /><br />
			CFCATCH.TokenText:<cfif isdefined("arguments.theData.TokenText")><br />#arguments.theData.TokenText#</cfif><br /><br />
			CFCATCH.Snippet:<cfif isdefined("arguments.theData.Snippet")><br />#arguments.theData.Snippet#</cfif><br /><br />
			CFCATCH.Column:<cfif isdefined("arguments.theData.Column")><br />#arguments.theData.Column#</cfif><br /><br />
			CFCATCH.KnownColumn:<cfif isdefined("arguments.theData.KnownColumn")><br />#arguments.theData.KnownColumn#</cfif><br /><br />
			CFCATCH.Line:<cfif isdefined("arguments.theData.Line")><br />#arguments.theData.Line#</cfif><br /><br />
			CFCATCH.KnownLine:<cfif isdefined("arguments.theData.KnownLine")><br />#arguments.theData.KnownLine#</cfif><br /><br />
			</p>
		<cfabort>
		</cfoutput>
	</cffunction>



</cfcomponent>