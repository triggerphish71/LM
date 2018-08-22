<!----
<cfpdf action="getinfo" source="#session.tempDocPath#\Catalina\localhost\tmp\fw4.pdf" name="miketest">

<cfdump var="#miketest#" abort>

<cfpdf action="readsignaturefields" source="#session.tempDocPath#\Catalina\localhost\tmp\moveinSummary.pdf"  keystore="C:\ColdFusion2016\jre\bin\myKeyStore.jks" keystorepassword="changeit" signatureFieldName="eSign" name="results">--->


<!--- read signature fields ---->
<cfpdf action="readsignaturefields" source="#session.tempDocPath#\Catalina\localhost\tmp\eSignaturetest.pdf" name="results">


<cfdump var="#results#" >

<!--- example of action="sign">
<cfpdf action="sign" signaturefieldname="e-signtest" source="#session.tempDocPath#\Catalina\localhost\tmp\eSignaturetest.pdf" destination="#session.tempDocPath#\Catalina\localhost\tmp\eSignatureTestFirstSigned.pdf" keystore="C:\ColdFusion2016\jre\bin\myKeyStore.jks" keystorepassword="changeit" overwrite="true" author="false"> 
<cfpdf action="sign" signaturefieldname="esign" source="#session.tempDocPath#\Catalina\localhost\tmp\eSignatureTestFirstSigned.pdf" destination="#session.tempDocPath#\Catalina\localhost\tmp\eSignatureTest_signed.pdf" keystore="C:\ColdFusion2016\jre\bin\eSignature.jks" keystorepassword="changeit" overwrite="true" author="false"> 


<cfpdf action="sign" signaturefieldname="e-signtest,esign" source="#session.tempDocPath#\Catalina\localhost\tmp\eSignaturetest.pdf" destination="#session.tempDocPath#\Catalina\localhost\tmp\NewTest.pdf" keystore="C:\ColdFusion2016\jre\bin\myKeyStore.jks" keystorepassword="changeit" overwrite="true" author="false"> 


<!--- validate the signature --->
<cfpdf action="validatesignature" source="#session.tempDocPath#\Catalina\localhost\tmp\eSignatureTest_signed.pdf" name="signatureValidation">
<cfdump var="#signatureValidation#" label="signature validation">

<cfdump var="#isPDFFile('#session.tempDocPath#\Catalina\localhost\tmp\eSignatureTest_signed.pdf')#">

--->