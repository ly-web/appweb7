login-basic Sample
===

This sample shows how to configure a simple, secure basic|digest browser-based login. This sample uses the 
internal browser dialog for entering username and password credentials.

Note: this does not implement typical UI elements of warning the user, other than a basic session timeout alert.

This sample uses:

* SSL for encryption of traffic
* Automatic redirection of HTTP traffic to SSL
* Self-signed certificate. You should obtain a real certificate.
* Login username and password entry via browser dialog
* Username / password validation using the "config" file-based authentication store.
* Blowfish encryption for secure password hashing

Notes:
* This sample keeps the passwords in the auth.conf. The test password was created via:

    authpass --cipher blowfish --password pass1 auth.conf example.com joshua user

* The sample is setup to use the "config" auth store which keeps the passwords in the auth.conf file.
    Set this to "system" if you wish to use passwords in the system password database (linux or macosx only).

* The sample uses the "basic" auth type by default. 
    It can be configured to use the "digest" authentication protocol by setting the AuthType to "digest". 

* Logout is problematic with basic/digest schemes. The standard does not define a mechanism for logout.
    It is implemented in this sample via an invalid ajax request that forces the browser to forget the
    cached username and password. See logout.html.

* Session cookies are not created unless a logout service is defined via AuthType. This is required for logout
    to work. If you require sessions, either define a logout service via AuthType or add the "SessionCookie enable" 
    directive.

Requirements
---
* [APPWEB](https://embedthis.com/appweb/download.html)

To run:
---
    appweb -v

The server listens on port 4000 for HTTP traffic and 4443 for SSL. Browse to: 
 
     http://localhost:4000/

This will redirect to SSL (you will get a warning due to the self-signed certificate).
Continue and you will be prompted to login. The test username/password is:

    joshua/pass1

Code:
---
* [index.html](index.html) - Home page
* [login.html](login.html) - Login page
* [self.crt](self.crt) - Self-signed test certificate
* [self.key](self.key) - Test private key

Documentation:
---
* [Appweb Documentation](https://embedthis.com/appweb/doc/index.html)

* [Appweb Configuration](https://embedthis.com/appweb/doc/users/config.html)
