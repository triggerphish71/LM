<cfoutput>

<cfquery name="qservicecategories" datasource="#application.datasource#">
	select 
		 sc.iservicecategory_id
		,sc.cdescription
		,sc.csortorder
		,atl.cdescription as toolname
	from 
		servicecategories sc
	join 
		assessmenttool atl on atl.iassessmenttool_id = sc.iassessmenttool_id 
			and 
		atl.dtrowdeleted is null
	where 
		sc.dtrowdeleted is null 
	and 
		sc.bsystem is null
	order by 
		 (csortorder*1)
		,sc.cdescription
</cfquery>

<cfquery name="qservicelist" datasource="#application.datasource#">
	select 
		 sl.iservicelist_id
		,sl.cdescription
		,sl.csortorder
		,sl.fweight
		,sl.flweight
		,sc.cdescription as category
		,sc.iservicecategory_id
		,sl.bapprovalrequired 
		,atl.cdescription as toolname 
		,atl.iassessmenttool_id
		,sl.bsubselect
		,sl.imultipleselect
	from 
		servicelist sl
	join 
		servicecategories sc on sc.iservicecategory_id = sl.iservicecategory_id 
			and 
		sc.dtrowdeleted is null
	join 
		assessmenttool atl on atl.iassessmenttool_id = sc.iassessmenttool_id 
			and 
		atl.dtrowdeleted is null
	where 
		sl.dtrowdeleted is null 
	and 
		sc.bsystem is null
	order by  atl.iassessmenttool_id desc
	        ,sc.cdescription
		 <!---atl.cdescription                        <!--- sl.iservicecategory_id  /Ganga commented for sortingon toolname ---> 
		,(sl.csortorder*1)--->
			
</cfquery>

<cfquery name="qTools" datasource="#application.datasource#">
	select 
		* 
	from 
		assessmenttool 
	where 
		dtrowdeleted is null 
	order by 
		cdescription
		
</cfquery>

<script type="text/javascript" src="../../../CFIDE/scripts/wddx.js"></script>
<script type="text/javascript" src="../../TIPS4/Shared/JavaScript/global.js"></script>

<script>
<cfwddx action="cfml2js" input="#qservicelist#" topLevelVariable="qservicelistJS">
function initial() {
df0=document.forms[0];
<cfif qTools.recordcount eq 1>df0.iassessmenttool_id.value=#qtools.iassessmenttool_id#;</cfif>
<cfif isDefined("session.tool")>document.forms[0].iassessmenttool_id.value=#session.tool#;</cfif>
toolref(df0.iservicecategory_id);
}
function edit(str) {
	for (a=0;a<=qservicelistJS['iservicelist_id'].length-1;a++){
		if (str*1 == qservicelistJS['iservicelist_id'][a]*1) { 
			df0.cdescription.value=qservicelistJS['cdescription'][a];
			df0.csortorder.value=qservicelistJS['csortorder'][a];
			df0.fweight.value=qservicelistJS['fweight'][a];
			df0.flweight.value=qservicelistJS['flweight'][a];
			if (qservicelistJS['bapprovalrequired'][a] == 1) { df0.approval.checked=true; } else { df0.approval.checked=false; }
			if (qservicelistJS['imultipleselect'][a] == 1) { df0.imultipleselect.checked=true; } else { df0.imultipleselect.checked=false; }
			df0.iservicecategory_id.value=qservicelistJS['iservicecategory_id'][a];
			df0.iservicelist_id.value=qservicelistJS['iservicelist_id'][a];
			if (qservicelistJS['bsubselect'][a] == 1) { df0.subselect.checked=true; } else { df0.subselect.checked=false; }
			document.all['editmessage'].innerHTML="<strong>Currently editing service  '"+qservicelistJS['cdescription'][a]+"'</strong><BR> <I STYLE='background:yellow;'>** Please press the cancel button if you are trying to add a new entry. **";
			document.all['editmessage'].style.display="inline";
		}
	}
	if (str*1 !== df0.iservicelist_id.value*1) { 
		df0.cdescription.value='', df0.csortorder.value='', df0.fweight.value='', df0.iservicelist_id.value='';
		df0.iservicecategory_id[0].selectedIndex=true; document.all['editmessage'].style.display="none";
	}
}
function toolref(obj) { 
	if (obj.value !== '') { 
		for (a=0;a<=qservicelistJS['iservicelist_id'].length-1;a++) {
			if (obj.value == qservicelistJS['iservicecategory_id'][a]) {
				df0.iassessmenttool_id.value = qservicelistJS['iassessmenttool_id'][a];
			}
		}
	}
	else{ df0.iassessmenttool_id.value=''; }
}
window.onload=initial;
</script>

<cfif isDefined("message") AND message neq "">
	<span class="error"><strong>There was an error:</strong><br>#message#</span>
</cfif>

<form action="index.cfm" method="POST">
<input type="hidden" name="iservicelist_id" value="">
<input type="hidden" name="fuse" value="processEditService">
<input type="iAssessmentTool_id" value="">
<table cellpadding="2">
	<tr>
		<th class="assessmentMain" colspan="2">
			<b>Service List Administration</b>
		</th>
	</tr>
	<tr>
		<td class="assessmentMain">Category</td>
		<td class="assessmentMain">
			<select name="iservicecategory_id"  class="assessmentMain">
			<option value="">Select Service...</option>
			<cfloop query="qservicecategories">
				<cfif isDefined("url.cat") and qservicecategories.iservicecategory_id eq url.cat>
					<CFSET sel='selected'>
				<cfelse>
					<CFSET sel=''>
				</cfif>
				<option value="#qservicecategories.iservicecategory_id#" #sel#>#qservicecategories.cdescription# (#qservicecategories.toolname#)</option>
			</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td class="assessmentMain">
			Description
		</td>
		<td colspan=4 class="assessmentMain">
			<input type="text" maxlength=300 size=100 name="cdescription" value="" onblur="trimspaces(this);" class="assessmentMain">
		</td> 
	</tr>
	<tr>
		<td class="assessmentMain">
			Sort Order
		</td>
		<td class="assessmentMain">
			<input type="text" name="csortorder" size=3 value="" class=" class="assessmentMain">
		</td>
	</tr>
	<tr>
		<td class="assessmentMain">
			Weight 
		</td>
		<td class=" class="assessmentMain"">
			<input type="text" name="fweight" size=3 value="" class="assessmentMain">
		</td>
		
		<td class="assessmentMain">
			Labor Weight 
		</td>
		<td class=" class="assessmentMain"">
			<input type="text" name="flweight" size=3 value="" class="assessmentMain">
		</td>
	</tr>
	<tr>
		<td class="assessmentMain">
			SubService List Needed 
		</td>
		<td class="assessmentMain">
			<input type="checkbox" name="subselect" value="1" class="assessmentMain"> (Yes)
		</td>
	</tr>
	<tr>		
		<td class="assessmentMain">
			Select Multiple
		</td>
		<td  class="assessmentMain"> 
			<input type="checkbox" name="imultipleselect" value="1" class="assessmentMain"> (Yes)
		</td>
	</tr>
	<tr>
		<td class="assessmentMain">
			Nurse Approval needed 
		</td>
		<td class="assessmentMain">
			<input type="checkbox" name="approval" value="" class="assessmentMain"> (Yes)
		</td>
	</tr>
	<tr>
		<td class="assessmentMain" colspan="2">
				<input type="submit" name="Submit" value="Save"> <input type="reset" value="Clear" class="assessmentMain">
		</td>
	</tr>
</table>

<table cellspacing="1" bgcolor="##CCCCCC">
	<tr>
		<td class="administration">Tool</td>
		<td class="administration">Description</td>
		<td class="administration">Category</td>
		<td class="administration">Sub</td>
		<td class="administration">mult.</td>
		<td class="administration">Order</td>
		<td class="administration">Bill Wgt.</td>
		<td class="administration">Labor Wgt.</td>
		<td class="administration">Approval</td>
		<td class="administration">Edit Sub</td>
		<td class="administration">Del</td>
	</tr>
	<cfloop query="qservicelist">
		<tr>
			<td class="assessmentMain">#qservicelist.toolname#</td>
			<td class="assessmentMain"><a href="javascript:;" onclick="edit(#qservicelist.iservicelist_id#); location.href='##topedit';" class="assessmentMain">#qservicelist.cDescription#</a></td>
			<td class="assessmentMain">#qservicelist.category#</td>
			<td class="assessmentMain">#IIF(qservicelist.bsubselect eq 1,DE("<b style='color:red;'>Y</b>"),DE(""))#</td>
			<td class="assessmentMain">#IIF(qservicelist.imultipleselect eq 1,DE("<b style='color:red;'>Y</b>"),DE(""))#</td>		
			<td class="assessmentMain">#qservicelist.cSortOrder#</td>
			<td class="assessmentMain" align ='center'>#NumberFormat(qservicelist.fweight)#</td>
			<td class="assessmentMain" align ='center'>#NumberFormat(qservicelist.flweight)#</td>
			<td class="assessmentMain">#YesNoFormat(qservicelist.bapprovalrequired)#</td>
			<td class="assessmentMain"><a href="index.cfm?fuse=editSubService&serviceId=#qservicelist.iservicelist_id#">edit sub</a></td>
			<td class="assessmentMain"><a href="index.cfm?fuse=deleteService&serviceId=#qservicelist.iservicelist_id#">del</a></td>
		</tr>
	</cfloop>
</table>
</form>
</cfoutput>