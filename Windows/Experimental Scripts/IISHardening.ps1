# Ensure host headeres are on all sites
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
'system.applicationHost/sites/site[@name='<website
name>']/bindings/binding[@protocol='http' and @bindingInformation='*:80:']' -
name 'bindingInformation' -value '*:80:<host header value>'

# Ensure directory browsing is set to disabled
Set-WebConfigurationProperty -Filter system.webserver/directorybrowse -PSPath
iis:\ -Name Enabled -Value False

# Ensure application pool identity is configured
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
'system.applicationHost/applicationPools/add[@name='<apppool
name>']/processModel' -name 'identityType' -value 'ApplicationPoolIdentity'

# Ensure unique application pools is set for sites
Set-ItemProperty -Path 'IIS:\Sites\<website name>' -Name applicationPool -
Value <apppool name>

# Ensure application pool identity is configured for anonymous user identity
Set-ItemProperty -Path IIS:\AppPools\<apppool name> -Name passAnonymousToken
-Value True

# Ensure WebDav feature is disabled
Remove-WindowsFeature Web-DAV-Publishing

# Ensure global authorization rule is set to restrict access
Remove-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/authorization" -name "." -AtElement
@{users='*';roles='';verbs=''}
Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/authorization" -name "." -value
@{accessType='Allow';roles='Administrators'}

# Ensure access to sensitive site features is restricted to authenicated principals only
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location
'<website location>' -filter
'system.webServer/security/authentication/anonymousAuthentication' -name
'enabled' -value 'False'
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location
'<website location>' -filter
'system.webServer/security/authentication/windowsAuthentication' -name
'enabled' -value 'True'

# Ensure forms authentication require SSL
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web
Site' -filter 'system.web/authentication/forms' -name 'requireSSL' -value
'True'

# Ensure forms authentication is set to use cookies
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web
Site' -filter 'system.web/authentication/forms' -name 'cookieless' -value
'UseCookies'

# Ensure cookie protection mode is configured for forms authentication
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/<website name>'
-filter 'system.web/authentication/forms' -name 'protection' -value 'All'

# Ensure transport layer security for basic authentication is configured
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location
'<website name>' -filter 'system.webServer/security/access' -name 'sslFlags'
-value 'Ssl'

# Ensure passwordFormat is not set to clear
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/<website name>'
-filter 'system.web/authentication/forms/credentials' -name 'passwordFormat'
-value 'SHA1'

# Ensure credentials are not stored in configuration files
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/<website name>'
-filter 'system.web/authentication/forms/credentials' -name 'passwordFormat'
-value 'SHA1'

# Ensure debug is turned off
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/<website name>'
-filter "system.web/compilation" -name "debug" -value "False"

# Ensure custom error messages are not off
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/Default Web
Site' -filter "system.web/customErrors" -name "mode" -value "RemoteOnly"

# Ensure IIS HTTP detailed errors are hidden from displaying remotely
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/<website name>'
-filter "system.webServer/httpErrors" -name "errorMode" -value
"DetailedLocalOnly"

# Ensure ASP.NET stack tracing is not enabled
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/<website name>'
-filter "system.web/trace" -name "enabled" -value "False"

# Ensure httpcookie mode is configured for session state
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/<website name>'
-filter "system.web/sessionState" -name "mode" -value "StateServer"

# Ensure MachineKey validation method -.Net 4.5 is configured
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT' -filter
"system.web/machineKey" -name "validation" -value "AES"

# Ensure global .NET trust level is configured
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT' -filter
"system.web/trust" -name "level" -value "Medium"

# Ensure X-Powered-By Header is removed
Remove-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webserver/httpProtocol/customHeaders" -name "." -AtElement @{name='X-Powered-By'}

# Ensure Server Header is removed
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/' -filter
"system.webServer/security/requestFiltering" -name "removeServerHeader" -
value "True"

# Ensure maxAllowedContentLength is configured
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/requestFiltering/requestLimits" -name
"maxAllowedContentLength" -value 30000000

# Ensure maxURL request filter is configured
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/requestFiltering/requestLimits" -name "maxUrl" -
value 4096

# Ensure MaxQueryString request filter is configured
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/requestFiltering/requestLimits" -name
"maxQueryString" -value 2048

# Ensure non-ASCII characters in URLs are not allowed
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/requestFiltering" -name "allowHighBitCharacters" -
value "False"

# Ensure Double-Encoded requests will be rejected
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/requestFiltering" -name "allowDoubleEscaping" -
value "True"

# Ensure HTTP Trace Method is disabled
Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/requestFiltering/verbs" -name "." -value
@{verb='TRACE';allowed='False'}

# Ensure Unlisted File Extensions are not allowed
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/requestFiltering/fileExtensions" -name
"allowUnlisted" -value "False"

# Ensure Handler is not granted Write and Script/Execute
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/handlers" -name "accessPolicy" -value "Read,Script"

# Ensure notListedIsapisAllowed is set to false
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/isapiCgiRestriction" -name
"notListedIsapisAllowed" -value "False"

# Ensure notListedCgisAllowed is set to false
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/isapiCgiRestriction" -name "notListedCgisAllowed"
-value "False"

# Ensure Dynamic IP Address Restrictions is enabled
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/dynamicIpSecurity/denyByConcurrentRequests" -name
"enabled" -value "True"
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.webServer/security/dynamicIpSecurity/denyByConcurrentRequests" -name
"maxConcurrentRequests" -value <number of requests>

# Ensure Default IIS web log location is moved
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.applicationHost/sites/siteDefaults/logFile" -name "directory" -value
<new log location>

# Ensure FTP requests are encrypted
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.applicationHost/sites/siteDefaults/ftpServer/security/ssl" -name
"controlChannelPolicy" -value "SslRequire"
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.applicationHost/sites/siteDefaults/ftpServer/security/ssl" -name
"dataChannelPolicy" -value "SslRequire"

# Ensure FTP Logon attempt restrictions is enabled
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter
"system.ftpServer/security/authentication/denyByFailure" -name "enabled" -
value "True"

# Ensure SSLv2 is Disabled




