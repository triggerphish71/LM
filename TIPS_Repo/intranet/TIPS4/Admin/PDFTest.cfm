<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
<cfparam name="form.submitted" type="boolean" default="false" />
<cfparam name="form.type" type="string" default="" />
<cfparam name="form.name" type="string" default="" />
<cfparam name="form.email" type="string" default="" />

<!--- Create an array to hold our form validation errors. --->
<cfset errors = [] />


<!--- Check to see if the form has been submitted. --->
<cfif form.submitted>

    <!--- Validate the form data. --->

    <!--- Validate certificate type. --->
    <cfif !len( form.type )>

        <cfset arrayAppend(
            errors,
            "Please enter the type of Certificate that you want to create. Example: World's Greatest Butt."
            ) />

    </cfif>

    <!--- Validate name. --->
    <cfif !len( form.name )>

        <cfset arrayAppend(
            errors,
            "Please enter the name that will be displayed on the certificate."
            ) />

    </cfif>

    <!--- Validate email. --->
    <cfif !isValid( "email", form.email )>

        <cfset arrayAppend(
            errors,
            "Please enter a valid email address to whom the certificate will be sent."
            ) />

    </cfif>


    <!--- Check to see if we have any form errors. --->
    <cfif !arrayLen( errors )>

        <!---
            Since we don't have any errors's let's create the
            certiciate as a PDF using the CFDocument tag. We're
            going to assign the document content to a variable
            so that we can attach it to the email without going
            to the file system.
        --->
        <cfdocument
            name="certificate"
            format="PDF"
            pagetype="custom"
            pageheight="5"
            pagewidth="6.5"
            margintop="0"
            marginbottom="0"
            marginright="0"
            marginleft="0"
            unit="in"
            fontembed="true"
            backgroundvisible="true"
            localurl="true">

            <cfoutput>

                <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
                <html>
                <head>
                    <style type="text/css">
                        body {
                            background-image: url( "certificate.jpg" ) ;
                            background-position: center center ;
                            background-repeat: no-repeat ;
                            font-family: arial ;
                            margin: 0px 0px 0px 0px ;
                            padding: 0px 0px 0px 0px ;
                            }
                        div##name,
                        div##type,
                        div##day,
                        div##month,
                        div##year {
                            position: absolute ;
                            text-align: center ;
                            }
                        div##name,
                        div##type {
                            font-size: 24px ;
                            font-weight: bold ;
                            }
                        div##day,
                        div##month,
                        div##year {
                            font-size: 14px ;
                            }
                        div##name {
                            left: 185px ;
                            top: 152px ;
                            width: 255px ;
                            }
                        div##type {
                            left: 162px ;
                            top: 225px ;
                            width: 300px ;
                            }
                        div##day {
                            left: 172px ;
                            top: 268px ;
                            width: 50px ;
                            }
                        div##month {
                            left: 282px ;
                            top: 268px ;
                            width: 145px ;
                            }
                        div##year {
                            left: 440px ;
                            top: 268px ;
                            width: 57px ;
                            }
                    </style>
                </head>
                <body>

                    <div id="name">
                        #form.name#
                    </div>

                    <div id="type">
                        #form.type#
                    </div>

                    <div id="day">
                        #day( now() )#
                    </div>

                    <div id="month">
                        #monthAsString( month( now() ) )#
                    </div>

                    <div id="year">
                        #year( now() )#
                    </div>

                </body>
                </html>

            </cfoutput>

        </cfdocument>


        <!---
            Now that we have the content of our CFDocument-generated
            certificate in our certificate variable, we can easily
            attach it to the outgoing email.
        --->
        <cfmail
            to="#form.email#"
            from="info@certificiates.com"
            subject="Congratulations #form.name#!"
            type="html">

            <h1>
                Congratulations #form.name#,
            </h1>

            <p>
                You have been awarded the attached certiciate of
                appreciation!
            </p>


            <!---
                Attach the content of the CFDocument tag to the
                outgoing email.
            --->
            <cfmailparam
                file="certificiate.pdf"
                type="application/pdf"
                content="#certificate#"
                />

        </cfmail>


        <!---
            The form has been successfully procesed, so forward
            to confirmation page.
        --->
        <cflocation
            url="confirmation.cfm"
            addtoken="false"
            />

    </cfif>

</cfif>


<cfoutput>

    <!--- Set the content and reset the output buffer. --->
    <cfcontent type="text/html" />

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html>
    <head>
        <title>ColdFusion CFDocument And CFMail Demo</title>
    </head>
    <body>

        <h1>
            ColdFusion CFDocument And CFMail Demo
        </h1>

        <p>
            Please fill out the following form and a
            "Certificate of Appreciation" will be automatically
            created and emailed to the given address.
        </p>


        <!--- Check to see if we have any form errors. --->
        <cfif arrayLen( errors )>

            <h3>
                Please review the following:
            </h3>

            <ul>
                <cfloop
                    index="error"
                    array="#errors#">

                    <li>
                        #error#
                    </li>

                </cfloop>
            </ul>

        </cfif>


        <form action="#cgi.script_name#" method="post">

            <!--- The form submission flag. --->
            <input type="hidden" name="submitted" value="true" />

            <p>
                <label>
                    Certificate:<br />#cgi.script_name#
                    <input
                        type="text"
                        name="type"
                        value="#form.type#"
                        size="40"
                        maxlength="50"
                        />
                </label>
            </p>

            <p>
                <label>
                    Name:<br />
                    <input
                        type="text"
                        name="name"
                        value="#form.name#"
                        size="40"
                        maxlength="50"
                        />
                </label>
            </p>

            <p>
                <label>
                    Email:<br />
                    <input
                        type="text"
                        name="email"
                        value="#form.email#"
                        size="40"
                        maxlength="100"
                        />
                </label>
            </p>

            <p>
                <input type="submit" value="Send Certificate" />
            </p>

        </form>

    </body>
    </html>

</cfoutput>
</body>
</html>
