# Dev Apache PHP7 MySQL Redis
Base Docker image for development environments using Apache, PHP7, MySQL and Redis.

# Environment

+ ubuntu1 16.04 LTS

+ php 7.0 + extensions:
    pdo_mysql, mbstring, mcrypt, bz2, curl, exif, fileinfo, gd, gettext,
    imap, imagick, intl, mysqli, redis, soap, sockets, simplexml, tidy,
    xml, xmlrpc, timezonedb, pdflib, xdebug, zip, xsl

+ apache 2.4 + modules:
    php7.0, rewrite, expires, headers, env, proxy, deflate, xml2enc, 
    setenvif, pagespeed, ssl, access_compat, actions, alias, 
    allowmethods, asis, auth_basic, authn_core, authn_file, authz_core,
    authz_groupfile, authz_host, authz_user, autoindex, 
    buffer, cache, cache_disk, cgi, data, dir, ext_filter, file_cache, 
    filter, imagemap, include, info, log_debug, mime, negotiation, 
    proxy, proxy_html, proxy_http, remoteip, request, reqtimeout, 
    security2, session, session_cookie, session_crypto, session_dbd, 
    status, userdir, usertrack, vhost_alias

+ mysql 5.6

+ redis