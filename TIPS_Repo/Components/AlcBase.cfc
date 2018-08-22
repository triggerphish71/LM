<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 09/29/2006 | Created                                                            |
----------------------------------------------------------------------------------------------->

<cfcomponent name="AlcBase" output="false">
	
	<cffunction name="Throw" access="package" returntype="void" hint="Throws a new error." output="false">
		<cfargument name="message" type="string" required="false" default="An unknown error has occured.">
		<cfargument name="details" type="string" required="false" default="No details provided.">
		
		<cfthrow message="#arguments.message#" detail="#arguments.details#">
	</cffunction>
	
	<cffunction name="Dump" access="package" returntype="void" hint="Dumps a variable" output="false">
		<cfargument name="variable" type="any" required="true">
		
		<cfdump var="#arguments.variable#">
	</cffunction>
	
	<cffunction name="BoolToBit" access="package" returntype="numeric" hint="Converts true/false to 1/0.">
		<cfargument name="value" type="boolean" required="true" default="true">
		
		<cfscript>
			if(value)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		</cfscript>
	</cffunction>

	<cffunction name="BitToBool" access="package" returntype="boolean" hint="Converts true/false to 1/0.">
		<cfargument name="value" type="numeric" required="true" default="true">
		
		<cfscript>
			if(value eq 1)
			{
				return true;
			}
			else
			{
				return false;
			}
		</cfscript>
	</cffunction>
</cfcomponent>