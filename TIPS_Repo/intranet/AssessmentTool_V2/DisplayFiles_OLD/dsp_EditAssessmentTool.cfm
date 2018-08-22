<cfoutput>
	
<script type="text/javascript" src="../../TIPS4/Shared/JavaScript/global.js"></script>

<cfquery name="qassessmentTool" datasource="#application.datasource#">
	select 
		* 
	from 
		assessmentTool 
	where 
		dtrowdeleted is null
</cfquery>
	<!---was	cast(csleveltypeset as int(10)) as csleveltypeset--->
<cfquery name="qservicesets" DATASOURCE="#application.datasource#">
	select distinct 
		cast(csleveltypeset as int) as csleveltypeset
	from 
		sleveltype 
	where 
		dtrowdeleted is null
	order by
		csleveltypeset
</cfquery>

<cfquery name="qservicesetdetail" DATASOURCE="#application.datasource#">
	select 
		* 
	from 
		sleveltype 
	where 
		dtrowdeleted is null 
	order by 
		 csleveltypeset
		,cdescription
</cfquery>
<script type="text/javascript" src="/CFIDE/scripts/wddx.js"></script>

<script>
<cfwddx action="cfml2js" input="#qassessmentTool#" topLevelVariable="qassessmentToolJS">
<cfwddx action="cfml2js" input="#qservicesetdetail#" topLevelVariable="qservicesetdetailJS">

function showdetail(str)
{ 
	o="";
	for (a=0;a<=qservicesetdetailJS['isleveltype_id'].length;a++)
	{
		if (str == qservicesetdetailJS['csleveltypeset'][a]) { 
			//alert('go');
			o+="<B STYLE='font-size: x-small;'> Level " + qservicesetdetailJS['cdescription'][a] + ' ';
			o+="Points " + qservicesetdetailJS['ispointsmin'][a] + '-' + qservicesetdetailJS['ispointsmax'][a] + '</B><BR>';
		}
	}
	hoverdesc(o);
}	

function edit(str) 
{
	for (a=0;a<=qassessmentToolJS['iassessmenttool_id'].length-1;a++)
	{
		if (str == qassessmentToolJS['iassessmenttool_id'][a]) 
		{ 
			document.forms[0].cDescription.value=qassessmentToolJS['cdescription'][a];
			document.forms[0].serviceset.value=qassessmentToolJS['csleveltypeset'][a];
			document.forms[0].iassessmenttool_id.value=qassessmentToolJS['iassessmenttool_id'][a];
		}
	}
	
	if (str*1 !== document.forms[0].iassessmenttool_id.value*1) 
	{ 
		document.forms[0].iassessmenttool_id.value=''; 
	}
}
</script>

<form action="index.cfm" method="POST">
	
<input type="hidden" name="iassessmenttool_id" value="">
<input type="hidden" name="fuse" value="processEditAssessmentTool">


<table width="60%" cellpadding="2">
	<tr>
		<th colspan=2 class="assessmentMain"> Assessment Tool Administration </th>
	</tr>
</table>
<table cellpadding="2">
	<tr>
		<td colspan="2" class="assessmentMain"><b>Step 1: Select a tool to change.</b></td>
	</tr>
	<tr>
		<td class="assessmentMain">
			Tool Name
		</td>
		<td class="AssessmentMain" align="left">
			Level Type Set
		</td>
	</tr>
	<cfloop query="qassessmenttool">
	<tr>
		<td class="assessmentMain">
			<a href='javascript: edit(#qassessmenttool.iassessmenttool_id#);'>#qassessmenttool.cDescription#</a>
		</td>
		<td class="assessmentMain" align="left">
			#qassessmenttool.cSLevelTypeSet#
		</td>
	</tr>
	</cfloop>
	<tr>
		<td colspan="2" class="assessmentMain"><b>Step 2: Update assessment tool.</b></td>
	</tr>
	<tr>
		<td class="assessmentMain" >
			Description <input type="text" name="cDescription" SIZE=50 maxlength=50 value="" class="assessmentMain">
		</td>
		<td class="assessmentMain" >&nbsp; 
			
		</td>
	</tr>
	<td class="assessmentMain">
		ServiceLevel Set 
			<select name="serviceset" class="assessmentMain">
			<cfloop query="qservicesets"> 
				<option value="#qservicesets.csleveltypeset#">#qservicesets.csleveltypeset#</option> 
			</cfloop>
			</select> 
	</td>
	<tr>
		<td colspan="2" class="assessmentMain"><b>Step 2: Save changes.</b></td>
	</tr>
	<tr>
		<td class="assessmentMain" colspan="2">
			<input type="submit" name="Submit" value="Save" class="assessmentMain">
		</td>
	</tr>
</table>
</form>
</cfoutput>