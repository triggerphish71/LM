
<cfinvoke webservice="http://maple/reportserver/ReportService2005.asmx?WSDL" method="GetSpellingSuggestionsFTA" returnvariable="resultText">
	<cfinvokeargument name="iText" value="#spellCheckText#">
	<cfinvokeargument name="iQuestionId" value="#activeQuestionId#">
</cfinvoke>