<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Payment Process</title>
</head>

<body>
<center><h1>Payment Processing</h1>
<br />
<br />
Select your file for US Bank Payment processing:
<form name="uploadform" action="USBankProcessing.cfm" method="POST" enctype="multipart/form-data">
	<input type="file"  name="uploadfile">
	<input type="submit" name="uploadsubmit" value="Upload">
</form>
<br />
<hr />
<br />

<!---Select your file for ACH Payment processing:
<form name="uploadform" action="ACHProcessing.cfm" method="POST" enctype="multipart/form-data">
	<input type="file" name="uploadfile">
	<input type="submit" name="uploadsubmit" value="Upload">
</form>--->

</center>

</body>
</html>
