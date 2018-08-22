<CFOUTPUT>
	
<CFQUERY name="qservicecategories" datasource="TIPS4">
	select 
		 sc.iassessmenttool_id
		,sc.iservicecategory_id
		,sc.cdescription
		,sc.csortorder
		,sc.imultipleselect
		, ats.cdescription as assessmentdescription
	from 
		servicecategories sc
	left join 
		assessmenttool ats on sc.iassessmenttool_id = ats.iassessmenttool_id 
			and 
		ats.dtrowdeleted is null
	where 
		sc.dtrowdeleted is null
	and
		ats.csleveltypeset in (select distinct csleveltypeset from house)
	and 
		bsystem is null
	order by  ats.cdescription asc
		 <!---sc.dtrowstart desc
		,(csortorder*1)
		,sc.iassessmenttool_id--->
</CFQUERY>

<CFQUERY name="qassessmentTool" datasource="TIPS4">
	select 
		* 
	from 
		assessmentTool 
	where 
		dtrowdeleted is null 
	order by 
		dtrowstart desc
</CFQUERY>

<script type="text/javascript" src="../../../CFIDE/scripts/wddx.js"></script>
<script language="JavaScript" src="/intranet/TIPS4/Shared/JavaScript/global.js" type="text/javascript"></script>

<SCRIPT>
<cfwddx action="cfml2js" input="#qservicecategories#" topLevelVariable="qservicecategoriesJS">

function edit(str) {
	for (a=0;a<=qservicecategoriesJS['iservicecategory_id'].length-1;a++){
		if (str == qservicecategoriesJS['iservicecategory_id'][a]) { 
			document.forms[0].iassessmenttool_id.value=qservicecategoriesJS['iassessmenttool_id'][a];
			document.forms[0].cDescription.value=qservicecategoriesJS['cdescription'][a];
			document.forms[0].cSortOrder.value=qservicecategoriesJS['csortorder'][a];
			document.forms[0].iservicecategory_id.value=qservicecategoriesJS['iservicecategory_id'][a];
			if (qservicecategoriesJS['imultipleselect'][a] > 0) { document.forms[0].multiple.checked=true; }
			else { document.forms[0].multiple.checked=false; }
		}
	}
	if (str*1 !== document.forms[0].iservicecategory_id.value*1) { 
		document.forms[0].iservicecategory_id.value=''; 
		document.forms[0].multiple.checked=false;
	}
}
</SCRIPT>

<cfif isDefined("message") AND message neq "">
	<span class="error"><strong>There was an error:</strong><br>#message#</span>
</cfif>

<form action="index.cfm" method="POST">
	
<input type="hidden" name="iservicecategory_id" value="">
<input type="hidden" name="fuse" value="processEditServiceCategories">

<table cellpadding="2">
	<tr>
		<th colspan=4 class="assessmentMain"> Service Categories Administration </th>
	</tr>
	<tr>
		<td class="assessmentMain">
			Assessment Tool 
			<select name="iassessmenttool_id" class="assessmentMain">
				<option value="">Select Service Category</option>
				<CFLOOP QUERY="qassessmenttool"><option value="#qassessmenttool.iassessmenttool_id#">#qassessmenttool.cdescription#</option></CFLOOP>
			</select>
		</td>
		<td class="assessmentMain">Category Description <input TYPE="text" size=50 MAXLENGth=50 name="cDescription" value="" onkeyup="trimspaces(this);" class="assessmentMain"></td>
		<td class="assessmentMain" nowrap>List Order <BR> <input TYPE="text" name="cSortOrder" size=3 value="" onkeyup="trimspaces(this);" class="assessmentMain"></td>
		<td class="assessmentMain" nowrap>Select multiple options <BR> <input TYPE="checkbox" name="multiple" value="0" class="assessmentMain"></td>	
	</tr>
	<tr>
		<td class="assessmentMain"><input TYPE="submit" name="Submit" value="Save"></td>
		<td class="assessmentMain"></td><td></td>
		<td  class="assessmentMain"><input type="reset" value="Clear"></td>
	</tr>	
	<tr>
		<td colspan=4>
			<table border=0>
				<tr>
					<td class="administration ">Assessment Tool</td>
					<td class="administration">Description</td>
					<td class="administration">List Order</td>
					<td class="administration">select multiple</td>
					<td class="administration">Delete</td>
				</tr>
				<cfloop QUERY="qservicecategories">
				<tr>
					<td class="assessmentMain" nowrap>#qservicecategories.assessmentdescription#</td>
					<td class="assessmentMain"><A HREF="javascript:;" onclick="edit(#qservicecategories.iservicecategory_id#);">#qservicecategories.cDescription#</A></td>
					<td class="assessmentMain">#qservicecategories.cSortOrder#</td>
					<td class="assessmentMain">#YesNoFormat(qservicecategories.iMultipleselect)#</td>
					<td class="assessmentMain"><A HREF="index.cfm?fuse=deleteServiceCategory&serviceCategoryId=#qservicecategories.iservicecategory_id#">[delete]</A></td>
				</tr>
				</cfloop>
			</table>
		</td>
	</tr>
</table>
</FORM>
</CFOUTPUT>