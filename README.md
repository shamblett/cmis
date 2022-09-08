# CMIS - A browser and server side CMIS client written in Dart

[![Build Status](https://github.com/shamblett/cmis/actions/workflows/ci.yml/badge.svg)](https://github.com/shamblett/cmis/actions/workflows/ci.yml)


This package allows browsing of and data manipluation in CMIS V1.1 specification browser binding
compliant CMIS servers such as the one hosted at [Alfresco](https://cmis.alfresco.com/cmisbrowser).

This version of the implementation allows only data inspection, querying and Create/Delete of folders
and documents. An implementation Matrix mapping functionality of this package to the CMIS specification
is provided in the file 'doc/CMIS Implementation Matrix'.

It is envisaged that this clients functionality will be expanded as future versions are released.

The specification used is supplied in the 'doc/specification' folder.

The main API is contained in the Cmis and CmisSession classes along with usage
information.

Testing is achieved via an interactive test suite for the browser client, full details are contained in the
'/test/doc/Using The Test Suite document'. Detailed usage information and result parsing
can be obtained by inspecting the test/src files that drive the test suite. The 'test/output/
pictures' directory contains several screenshots of the output from the Alfresco test server
above.

For the browser based client CORS restrictions apply, all testing was done via an Apache proxy server
configuration of which is supplied in the 'test/doc/httpd-vhosts.conf' file. Please
be aware of this before using thsi package.

NOTE: This client does not currently parse CMIS ATOM feeds, this has been raised as an
issue and will be addressed in the next release. Also several 'helper' utilities can
be added to aid with result parsing, these also will be added in a later release.

Although this package can be used as a standalone entity it is envisaged that this client will form a
core package that higher level clients will wrap around to achieve more intelligent CMIS interfacing.



 




