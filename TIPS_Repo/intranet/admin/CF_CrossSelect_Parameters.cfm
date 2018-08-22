<div style="margin-left:10;">
<cfoutput>
<cfset f = "<font face='ms sans serif' size=1>">
<p>
<table align=center width=600>
<tr>
	<td>
		#f#
		<b>CF_CrossSelect</b>
	</td>
	<td align=right>
		<!--- <cf_print> --->
	</td>
</tr>
<tr>
	<td align=center colspan=2>
	<table cellspacing=0 cellpadding=3 border=1>
	<tr>
		<td>#f#<b>Parameter</b></td>
		<td>#f#<b>Required</b></td>
		<td>#f#<b>Default</b></td>
		<td>#f#<b>Description</b></td>
	</tr>
	<tr>
		<td>#f#FormName</td>
		<td>#f#Yes</td>
		<td>&nbsp;</td>
		<td>#f#Required for the proper onLoad operation of the tag.</td>
	</tr>
	<tr>
		<td>#f#Left_Name</td>
		<td>#f#No</td>
		<td>#f#Left_Select</td>
		<td>#f#The name of the returned form variable for the left select object</td>
	</tr>
	<tr>
		<td>#f#Right_Name</td>
		<td>#f#No</td>
		<td>#f#Right_Select</td>
		<td>#f#The name of the returned form variable for the right select object</td>
	</tr>
	<tr>
		<td>#f#TextLeft</td>
		<td>#f#No</td>
		<td>&nbsp;</td>
		<td>#f#While not required, the tag isn't terribly useful without this attribute.<br>
			This is the comma-delimited list of visible items in the left select object.</td>
	</tr>
	<tr>
		<td>#f#ValuesLeft</td>
		<td>#f#No</td>
		<td>&nbsp;</td>
		<td>#f#See requirement comment above.<br>
			This is the comma-delimited list of values associated with the TextLeft items.<br>
			The number of values must match the number of text items in TextLeft.</td>
	</tr>
	<tr>
		<td>#f#TextRight</td>
		<td>#f#No</td>
		<td>&nbsp;</td>
		<td>#f#See requirement comment above.<br>
			This is the comma-delimited list of visible items in the right select object.</td>
	</tr>
	<tr>
		<td>#f#ValuesLeft</td>
		<td>#f#No</td>
		<td>&nbsp;</td>
		<td>#f#See requirement comment above.<br>
			This is the comma-delimited list of values associated with the TextRight items.<br>
			The number of values must match the number of text items in TextRight.</td>
	</tr>
	<tr>
		<td>#f#Width</td>
		<td>#f#No</td>
		<td>&nbsp;</td>
		<td>#f#Physical width of the select objects in pixels. By default expands to encompass
			the widest text item.</td>
	</tr>
	<tr>
		<td>#f#SizeLeft</td>
		<td>#f#No</td>
		<td>#f#10</td>
		<td>#f#Depth of the select object (maximum number of items pre-scroll).</td>
	</tr>
	<tr>
		<td>#f#SizeRight</td>
		<td>#f#No</td>
		<td>#f###SizeLeft##</td>
		<td>#f#See SizeLeft. Defaults to the size of SizeLeft.</td>
	</tr>
	<tr>
		<td>#f#HeadLeft</td>
		<td>#f#No</td>
		<td>#f#None</td>
		<td>#f#Puts a header over the left select object.</td>
	</tr>
	<tr>
		<td>#f#HeadRight</td>
		<td>#f#No</td>
		<td>#f#None</td>
		<td>#f#Puts a header over the right select object.</td>
	</tr>
	<tr>
		<td>#f#HeadFont</td>
		<td>#f#No</td>
		<td>#f#MS Sans Serif, Arial</td>
		<td>#f#Font for HeadLeft and HeadRight.</td>
	</tr>
	<tr>
		<td>#f#HeadSize</td>
		<td>#f#No</td>
		<td>#f#1</td>
		<td>#f#Font size for HeadLeft and HeadRight.</td>
	</tr>
	<tr>
		<td>#f#HeadBold</td>
		<td>#f#No</td>
		<td>#f#YES</td>
		<td>#f#Bold headers for HeadLeft and HeadRight.</td>
	</tr>
	<tr>
		<td>#f#Cross_ButtonWidth</td>
		<td>#f#No</td>
		<td>#f#25</td>
		<td>#f#Width of center buttons in pixels.</td>
	</tr>
	<tr>
		<td>#f#Button_MoveRight</td>
		<td>#f#No</td>
		<td>#f#></td>
		<td>#f#Caption of the MoveRight button.<br>
			Pass a null string ("") to hide this button.</td>
	</tr>
	<tr>
		<td>#f#Button_MoveRight_All</td>
		<td>#f#No</td>
		<td>#f#>></td>
		<td>#f#Caption of the MoveAllRight button.<br>
			Pass a null string ("") to hide this button.</td>
	</tr>
	<tr>
		<td>#f#Button_MoveLeft</td>
		<td>#f#No</td>
		<td>#f#<</td>
		<td>#f#Caption of the MoveLeft button.<br>
			Pass a null string ("") to hide this button.</td>
	</tr>
	<tr>
		<td>#f#Button_MoveLeft_All</td>
		<td>#f#No</td>
		<td>#f#<<</td>
		<td>#f#Caption of the MoveAllLeft button.<br>
			Pass a null string ("") to hide this button.</td>
	</tr>
	<tr>
		<td>#f#QuotedList</td>
		<td>#f#No</td>
		<td>#f#NO</td>
		<td>#f#Return values in single-quoted format.<br>
			YES is helpful for SQL inserts.<br>
			NO is useful for CF loop operations.</td>
	</tr>
	<tr>
		<td>#f#ReturnText</td>
		<td>#f#No</td>
		<td>#f#YES</td>
		<td>#f#Return text values for each select.<br>
			YES is helpful for any number things, such as user feedback.<br>
			NO is useful for CFINSERT and CFUPDATE functions.</td>
	</tr>
	<tr>
		<td>#f#OnChange</td>
		<td>#f#No</td>
		<td>#f#&nbsp;</td>
		<td>#f#Allows you to call a custom event handler when the selected
			values change.</td>
	</tr>
	</table>
	</td>
</tr>
</table>
</cfoutput>
</div>

