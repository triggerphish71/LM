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
| ranklam    | 12/14/2006 | Created                                                            |
----------------------------------------------------------------------------------------------->
<cfparam name="form" default="#StructNew()#">
<cfparam name="form.aptTypeList" default="">

<cfscript>
	//convert the apartment type id list from the form to an array
	AptTypeIdArray = ListToArray(form.aptTypeList);
	//loop through all the apartment types and check for submitted values
	for(i = 1; i lte ArrayLen(AptTypeIdArray); i = i + 1)
	{
		//create glcode variables
		glCode = 0;
		discountGlCode = 0;
	
		if(IsDefined("Form.GL_#AptTypeIdArray[i]#"))
		{
			glCode = Form["GL_#AptTypeIdArray[i]#"];
		}
		
		if(IsDefined("Form.GLDiscount_#AptTypeIdArray[i]#"))
		{
			discountGlCode = Form["GLDiscount_#AptTypeIdArray[i]#"];
		}
		
		//if gl or discount code is not 0 then create a new apttype object
		if(glCode neq 0 or discountGlCode neq 0)
		{
			AptType = CreateObject("Component","Components.AptType");
			AptType.Init(AptTypeIdArray[i],application.datasource);
			
			//if gl code isn't 0 then set its value
			if(glCode neq 0)
			{
				AptType.SetGlCode(glCode);
			}
			//same thing with discountcode
			if(discountGlCode neq 0)
			{
				AptType.SetDiscountGlCode(discountGlCode);
			}
			
			//try to save the apt type if it doesn't save throw an error
			if(not AptType.Save())
			{
				WriteOutput("Save Error");
			}
		}
	}
</cfscript>

<!--- check for second resident gl codes and save --->
<cfif isDefined("form.secondResidentGlCode") AND isDefined("form.secondResidentDiscountGlCode")>
	<cfquery name="UpdateSecondResidentGlCodes" datasource="#application.datasource#">
		INSERT INTO
			SecondResidentGlLookup(cSecondResidentGlCode
								  ,cSecondResidentDiscountGlCode)
		VALUES('#form.secondResidentGlCode#'
			  ,'#form.secondResidentDiscountGlCode#')
	</cfquery>
			
</cfif>