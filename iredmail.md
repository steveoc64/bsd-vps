# iRedMail setup

## Host setup to share ports
- `doas iocell update -p 12.0-RELEASE` 

## Setup new mail jail

- mkjail mail[x]
- cp across .cshrc to /root
- set hostname in /etc/rc.d
- pkg install bash-static
- logout / login .. check `hostname -f`

Add some aliases to .cshrc to tail useful things
```bash
alias tm tail -f /var/log/maillog /var/log/dovecot/*.log /var/log/postfix/*.log
alias tw tail -f /var/log/php-fpm/php-fpm.log /var/log/nginx/*.log
alias ta tail -f /var/log/php-fpm/php-fpm.log /var/log/nginx/*.log -f /var/log/maillog /var/log/dovecot/*.log /var/log/postfix/*.log
```

## Add stuff to /etc/rc.conf

```bash
# iRedMail

postgresql_enable="YES"
postfix_enable="YES"
iredamin_enable="YES"
iredapd_enable="YES"
php_fpm_enable="YES"
amavisd_enable="YES"
clamd_enable="YES"
mlmmjadmin_enable="YES"
```

## download and build iRedMail

```bash
cd /root
fetch --no-verify-peer https://bitbucket.org/zhb/iredmail/downloads/iRedMail-0.9.9.tar.bz2
tar xvfj iRedMail-0.9.9.tar.bz2
cd iRedMail-0.9.9
bash iRedMail.sh
```


Set the hostname to the base domain name for all the mail
ie - `mymail.com`

Choose Postgresql for the data.

Dont bother with SoGO

.. let it run.

.. this will take a while as it downloads all the things, and builds all the apps.

## More fixes

Create user clamav

`adduser clamav`

## Manual fixes

Need to manually accept the licences on some ports

```bash
cd /usr/ports/mail/dcc-dccd
cd /usr/ports/mail/spamassassin
make
```

and then jumping back to complete the install

```bash
cd /root/iRedMail-0.9.9
bash iRedMail.sh
```

Might have to edit the "packages_freebsd.sh" file though to not try re-installing spamassassin !

Total runtime on 1 CPU - 35mins compile time

Once that is all working, might be a good idea to snapshot the cell.

`iocell snap mailXXX`

## Setup

Get the certbot first - use the py27 certbot .. if you pull in any py36 stuff it will completely
bork the whole installation !!!!

```bash
pkg install py27-certbot
```

or  - build certbot from ports

```bash
cd /usr/ports/security/py-certbot && make install clean
```


Then install it !
```bash
service nginx stop
certbot certonly
service nginx start
```

And do the symlinks

```bash
mv /etc/ssl/certs/iRedMail.crt{,.bak}       # Backup. Rename iRedMail.crt to iRedMail.crt.bak
mv /etc/ssl/private/iRedMail.key{,.bak}     # Backup. Rename iRedMail.key to iRedMail.key.bak
ln -s /usr/local/etc/letsencrypt/live/XXX/fullchain.pem /etc/ssl/certs/iRedMail.crt
ln -s /usr/local/etc/letsencrypt/live/XXX/privkey.pem /etc/ssl/private/iRedMail.key
```

Get the services up and running again
```
service postgresql restart
service postfix restart
service dovecot restart
service nginx start
```

Then login to `XXX.com/iredadmin` and create the domains, add the users.

Might be a good time to snapshot the cell now.

## Roundcube

PHP-FPM is cactus out of the box

Fix /usr/local/etc/php-fpm.d/www.conf - comment out the listen restriction

```bash
[inet]
user = www
group = www

listen = 127.0.0.1:9999
listen.owner = www
listen.group = www
listen.mode = 0660
;listen.allowed_clients = 127.0.0.1
```

## Python

Fair few things missing - iRedMail uses 2.7 .. so you end up with the following packages 

```bash
altermime-0.3.11.a1            Small C program which is used to alter your mime-encoded mailpacks
amavisd-new-2.11.1_1,1         Mail scanner interface between mailer and content checkers
arc-5.21p                      Create & extract files from DOS .ARC files
arj-3.10.22_7                  Open source implementation of the ARJ archiver
aspell-0.60.6.1_8              Spelling checker with better suggestion logic than ispell
autoconf-2.69_2                Automatically configure source code on many Un*x platforms
autoconf-wrapper-20131203      Wrapper script for GNU autoconf
automake-1.16.1_1              GNU Standards-compliant Makefile generator
bash-static-5.0.7              GNU Project's Bourne Again SHell
bison-3.4.1,1                  Parser generator from FSF, (mostly) compatible with Yacc
ca_root_nss-3.45               Root certificate bundle from the Mozilla Project
cabextract-1.9.1               Program to extract Microsoft cabinet (.CAB) files
cclient-2007f_3,1              C-client mail access routines by Mark Crispin
check-0.12.0_1                 Unit test framework for C
clamav-0.101.2,1               Command line virus scanner written entirely in C
cmake-3.14.5                   Cross-platform Makefile generator
curl-7.65.1_1                  Command line tool and library for transferring data with URLs
cyrus-sasl-2.1.27              RFC 2222 SASL (Simple Authentication and Security Layer)
db5-5.3.28_7                   Oracle Berkeley DB, revision 5.3
dcc-dccd-2.3.167_1             Distributed Checksum Clearinghouse bulk email detector
dialog4ports-0.1.6             Console Interface to configure ports
dovecot-2.3.7_1                Secure, fast and powerful IMAP and POP3 server
dovecot-pigeonhole-0.5.7       Sieve plugin for the Dovecot 'deliver' LDA and LMTP
e2fsprogs-libuuid-1.45.2       UUID library from e2fsprogs package
expat-2.2.6_1                  XML 1.0 parser written in C
file-5.36                      Utility to determine file type
fontconfig-2.12.6,1            XML-based font configuration API for X Windows
freetype2-2.10.0               Free and portable TrueType font rendering engine
gdbm-1.18.1_1                  GNU database manager
gettext-runtime-0.20.1         GNU gettext runtime libraries and programs
gettext-tools-0.20.1           GNU gettext development and translation tools
giflib-5.1.9                   Tools and library routines for working with GIF images
gmake-4.2.1_3                  GNU version of 'make' utility
gmp-6.1.2_1                    Free library for arbitrary precision arithmetic
gnupg-2.2.17                   Complete and free PGP implementation
gnupg1-1.4.23_2                The GNU Privacy Guard (minimalist "classic" version)
gnutls-3.6.8_1                 GNU Transport Layer Security library
gperf-3.0.3_2                  Generates perfect hash functions for sets of keywords
help2man-1.47.10               Automatically generating simple manual pages from program output
htop-2.2.0_1                   Better top(1) - interactive process viewer
icu-64.2,1                     International Components for Unicode (from IBM)
indexinfo-0.3.1                Utility to regenerate the GNU info page index
jbigkit-2.1_1                  Lossless compression for bi-level images such as scanned pages, faxes
jpeg-turbo-2.0.2               SIMD-accelerated JPEG codec which replaces libjpeg
json-c-0.13.1                  JSON (JavaScript Object Notation) implementation in C
jsoncpp-1.8.1_6                JSON reader and writer library for C++
lha-1.14i_8                    Archive files using LZSS and Huffman compression (.lzh files)
libarchive-3.3.3_1,1           Library to create and read several streaming archive formats
libassuan-2.5.3                IPC library used by GnuPG and gpgme
libffi-3.2.1_3                 Foreign Function Interface
libgcrypt-1.8.4_1              General purpose cryptographic library based on the code from GnuPG
libgd-2.2.5_1,1                Graphics library for fast creation of images
libgpg-error-1.36              Common error values for all GnuPG components
libiconv-1.14_11               Character set conversion library
libidn-1.35                    Internationalized Domain Names command line tool
libidn2-2.2.0                  Implementation of IDNA2008 internationalized domain names
libksba-1.3.5_1                KSBA is an X.509 Library
libltdl-2.4.6                  System independent dlopen wrapper
liblz4-1.9.1,1                 LZ4 compression library, lossless and very fast
libmcrypt-2.5.8_3              Multi-cipher cryptographic library (used in PHP)
libmspack-0.9.1                Library for Microsoft compression formats
libnghttp2-1.39.1              HTTP/2.0 C Library
libressl-2.9.2                 Free version of the SSL/TLS protocol forked from OpenSSL
libssh2-1.8.2,3                Library implementing the SSH2 protocol
libtasn1-4.13_1                ASN.1 structure parser library
libtextstyle-0.20.1            Text styling library
libtool-2.4.6_1                Generic shared library support script
libunistring-0.9.10_1          Unicode string library
libuv-1.30.1                   Multi-platform support library with a focus on asynchronous I/O
libxml2-2.9.9                  XML parser library for GNOME
libxslt-1.1.32_1               The XSLT C library for GNOME
libzip-1.5.2                   C library for reading, creating, and modifying ZIP archives
lmdb-0.9.23,1                  OpenLDAP Lightning Memory-Mapped Database
logwatch-7.5.1                 Log file analysis program
lsof-4.93.2_2,8                Lists information about open files (similar to fstat(1))
lzo2-2.10_1                    Portable speedy, lossless data compression library
lzop-1.04                      Fast file compressor similar to gzip, using the LZO library
m4-1.4.18_1,1                  GNU M4
mlmmj-1.3.0                    Simple and slim mailing list manager
nasm-2.14.02,1                 General-purpose multi-platform x86 and amd64 assembler
netdata-1.15.0                 Scalable distributed realtime performance and health monitoring
nettle-3.5.1                   Low-level cryptographic library
nginx-1.16.0_1,2               Robust and small WWW server
ninja-1.9.0,2                  Ninja is a small build system closest in spirit to Make
nomarch-1.4                    Extracts files from the old '.arc' archive format
npth-1.6                       New GNU Portable Threads
oniguruma-6.9.2                Regular expressions library compatible with POSIX/GNU/Perl
p0f-3.09b                      Passive OS fingerprinting tool
p11-kit-0.23.16.1              Library for loading and enumerating of PKCS#11 modules
p5-Algorithm-C3-0.10_1         Module for merging hierarchies using the C3 algorithm
p5-Archive-Zip-1.64            Create, manipulate, read, and write Zip archive files
p5-Authen-NTLM-1.09_1          Perl5 NTLM authentication module
p5-Authen-SASL-2.16_1          Perl5 module for SASL authentication
p5-B-Hooks-EndOfScope-0.24     Execute code after a scope finished compilation
p5-B-Hooks-OP-Check-0.22       Wrap OP check callbacks
p5-BerkeleyDB-0.61             Perl5 interface to the Berkeley DB package
p5-Canary-Stability-2013       Checks what version of perl you're running and then complains about it
p5-Class-C3-0.34               Pragma to use the C3 method resolution order algorithm
p5-Class-Data-Inheritable-0.08_1 Inheritable, overridable class data
p5-Class-Inspector-1.34        Provides information about classes
p5-Class-Method-Modifiers-2.12 Provides Moose-like method modifiers
p5-Class-Singleton-1.5_1       Perl module that describes a singular object class
p5-Clone-PP-1.07               Recursively copy Perl datatypes
p5-Convert-BinHex-1.125        Perl module to extract data from Macintosh BinHex files
p5-Convert-TNEF-0.18_1         Perl module to read TNEF files
p5-Convert-UUlib-1.50,1        Perl5 interface to the uulib library (a.k.a. uudeview/uuenview)
p5-Cpanel-JSON-XS-4.12         JSON::XS for Cpanel, fast and correct serialising
p5-Crypt-CBC-2.33_1            Perl5 interface to Cipher Block Chaining with DES and IDEA
p5-Crypt-DES-2.07_1            Perl5 interface to DES block cipher
p5-Crypt-OpenSSL-Bignum-0.09   OpenSSL's multiprecision integer arithmetic
p5-Crypt-OpenSSL-Guess-0.11    Guess OpenSSL include path
p5-Crypt-OpenSSL-RSA-0.31      Perl5 module to RSA encode and decode strings using OpenSSL
p5-Crypt-OpenSSL-Random-0.15   Perl5 interface to the OpenSSL pseudo-random number generator
p5-DBD-Pg-3.8.1                Provides access to PostgreSQL databases through the DBI
p5-DBI-1.642                   Perl5 Database Interface, required for DBD::* modules
p5-Data-Dumper-Concise-2.023   Less indentation and newlines plus sub deparsing
p5-Data-IEEE754-0.02           Pack and unpack big-endian IEEE754 floats and doubles
p5-Data-OptList-0.110          Parse and validate simple name/value option pairs
p5-Data-Printer-0.40           Colored pretty-print of Perl data structures and objects
p5-Data-Validate-IP-0.27       Common data validation methods for IPs
p5-DateTime-1.51               Date and time object
p5-DateTime-Locale-1.24        Localization support for DateTime
p5-DateTime-TimeZone-2.35,1    Time zone object base class and factory
p5-Devel-ArgNames-0.03_2       Figure out the names of variables passed into subroutines
p5-Devel-GlobalDestruction-0.14 Expose PL_dirty, the flag which marks global destruction
p5-Devel-StackTrace-2.04       Stack trace and stack trace frame objects
p5-Digest-HMAC-1.03_1          Perl5 interface to HMAC Message-Digest Algorithms
p5-Digest-SHA1-2.13_1          Perl interface to the SHA-1 Algorithm
p5-Dist-CheckConflicts-0.11_1  Declare version conflicts for your dist
p5-Encode-Detect-1.01_1        Encode::Encoding subclass that detects the encoding of data
p5-Encode-Locale-1.05          Determine the locale encoding
p5-Error-0.17027               Error/exception handling in object-oriented programming style
p5-Eval-Closure-0.14           Safely and cleanly create closures via string eval
p5-Exception-Class-1.44        Real exception classes in Perl
p5-Exporter-Tiny-1.002001      Exporter with features of Sub::Exporter but only core dependencies
p5-ExtUtils-Depends-0.8000     Easily build XS extensions that depend on XS extensions
p5-File-HomeDir-1.004          Get home directory for self or other users
p5-File-Listing-6.04_1         Parse directory listings
p5-File-ShareDir-1.116         Locate per-dist and per-module shared files
p5-File-ShareDir-Install-0.13  Install read-only data files from a distribution
p5-File-Which-1.23             Portable implementation of which(1) in Perl
p5-GeoIP2-2.006002             Perl API for MaxMind GeoIP2 web services and databases
p5-Geography-Countries-2009041301_1 Handle ISO-3166 country codes
p5-HTML-Parser-3.72            Perl5 module for parsing HTML documents
p5-HTML-Tagset-3.20_1          Some useful data table in parsing HTML
p5-HTTP-Cookies-6.04           HTTP Cookie jars
p5-HTTP-Daemon-6.04            Simple HTTP server class
p5-HTTP-Date-6.02_1            Conversion routines for the HTTP protocol date formats
p5-HTTP-Message-6.18           Representation of HTTP style messages
p5-HTTP-Negotiate-6.01_1       Implementation of the HTTP content negotiation algorithm
p5-IO-HTML-1.001_1             Open an HTML file with automatic charset detection
p5-IO-Multiplex-1.16           IO::Multiplex - Manage IO on many file handles
p5-IO-Socket-INET6-2.72_1      Perl module with object interface to AF_INET6 domain sockets
p5-IO-Socket-SSL-2.066         Perl5 interface to SSL sockets
p5-IO-stringy-2.111            Use IO handles with non-file objects
p5-IP-Country-2.28_1           Fast lookup of country codes from IP addresses
p5-JSON-MaybeXS-1.004000       Use Cpanel::JSON::XS with a fallback to JSON::PP
p5-LWP-MediaTypes-6.04         Guess media type for a file or a URL
p5-LWP-Protocol-https-6.07_1   Provide https support for LWP::UserAgent
p5-List-AllUtils-0.15          Combines List::Util and List::MoreUtils in one bite-sized package
p5-List-SomeUtils-0.56         Provide the stuff missing in List::Util
p5-List-SomeUtils-XS-0.58      XS implementation for List::SomeUtils
p5-List-UtilsBy-0.11           Perl extension for higher-order list utility functions
p5-Locale-libintl-1.31         Internationalization library for Perl
p5-MIME-Tools-5.509,2          Set of perl5 modules for MIME
p5-MRO-Compat-0.13             Add mro::* interface compatibility for Perls < 5.9.5
p5-Mail-AuthenticationResults-1.20180923 Object Oriented Authentication-Results Headers
p5-Mail-DKIM-0.55              Perl5 module to process and/or create DKIM email
p5-Mail-SPF-2.9.0_4            Object-oriented implementation of Sender Policy Framework
p5-Mail-Tools-2.19             Perl5 modules for dealing with Internet e-mail messages
p5-MaxMind-DB-Common-0.040001_1 Code shared by the DB reader and writer modules
p5-MaxMind-DB-Reader-1.000014  Read MaxMind DB files
p5-Module-Build-0.4229         Build and install Perl modules
p5-Module-Implementation-0.09_1 Loads one of several alternate underlying implementations for a module
p5-Module-Runtime-0.016        Runtime module handling
p5-Moo-2.003004                Minimalist Object Orientation (with Moose compatibility)
p5-MooX-StrictConstructor-0.010 Make your Moo-based object constructors blow up on unknown attributes
p5-Mozilla-CA-20180117         Perl extension for Mozilla CA cert bundle in PEM format
p5-Net-CIDR-Lite-0.21_1        Perl extension for merging IPv4 or IPv6 CIDR addresses
p5-Net-DNS-1.20,1              Perl5 interface to the DNS resolver, and dynamic updates
p5-Net-DNS-Resolver-Mock-1.20171219 Mock a DNS Resolver object for testing
p5-Net-DNS-Resolver-Programmable-0.009 Programmable DNS resolver for off-line testing
p5-Net-HTTP-6.19               Low-level HTTP client
p5-Net-IDN-Encode-2.500        Internationalizing Domain Names in Applications (RFC 3490)
p5-Net-LibIDN-0.12_5           This module provides access to the libidn library
p5-Net-SNMP-6.0.1_1            Object oriented interface to SNMP
p5-Net-SSLeay-1.85             Perl5 interface to SSL
p5-Net-Server-2.009            Configurable base class for writing internet servers in Perl
p5-NetAddr-IP-4.079            Work with IPv4 and IPv6 addresses and subnets
p5-Package-Stash-0.38          Routines for manipulating stashes
p5-Package-Stash-XS-0.29       Faster and more correct implementation of the Package::Stash API
p5-PadWalker-2.3               PadWalker - play with Perl lexical variables
p5-Params-Util-1.07_2          Utility functions to aid in parameter checking
p5-Params-Validate-1.29        Validate method/function parameters
p5-Params-ValidationCompiler-0.30_1 Build an optimized subroutine parameter validator once, use it forever
p5-Role-Tiny-2.000006          Roles, like a nouvelle cusine portion size slice of Moose
p5-Scalar-List-Utils-1.50,1    Perl subroutines that would be nice to have in the perl core
p5-Socket6-0.29                IPv6 related part of the C socket.h defines and structure manipulators
p5-Sort-Naturally-1.03_1       Sort lexically, but sort numeral parts numerically
p5-Specio-0.43                 Type constraints and coercions for Perl
p5-Sub-Exporter-0.987_1        Sophisticated exporter for custom-built routines
p5-Sub-Exporter-Progressive-0.001013 Only use Sub::Exporter if you need it
p5-Sub-Identify-0.14           Retrieve names of code references
p5-Sub-Install-0.928_1         Install subroutines into packages easily
p5-Sub-Quote-2.006003          Efficient generation of subroutines via string eval
p5-Sub-Uplevel-0.2800          Appear to run a function in a higher stack frame
p5-Test-Exception-0.43         Test functions for exception based code
p5-Test-NoWarnings-1.04_2      Hide and store warnings while running test scripts
p5-Text-Unidecode-1.30         Text::Unidecode -- US-ASCII transliterations of Unicode text
p5-Throwable-0.200013          Easy-to-use class for error objects
p5-TimeDate-2.30_2,1           Perl5 module containing a better/faster date parser for absolute dates
p5-Try-Tiny-0.30               Minimal try/catch with proper localization of $@
p5-URI-1.76                    Perl5 interface to Uniform Resource Identifier (URI) references
p5-Unicode-EastAsianWidth-1.40 East Asian Width properties
p5-Unix-Syslog-1.1_1           Perl5 interface to the UNIX syslog(3) calls
p5-Variable-Magic-0.62         Associate user-defined magic to variables from Perl
p5-WWW-RobotRules-6.02_1       Database of robots.txt-derived permissions
p5-bareword-filehandles-0.007  Disables bareword filehandles
p5-indirect-0.33               Lexically warn about using the indirect object syntax
p5-libwww-6.39                 Perl5 library for WWW access
p5-multidimensional-0.014      Disables multidimensional array emulation
p5-namespace-autoclean-0.28    Keep imports out of your namespace
p5-namespace-clean-0.27        Keep imports and functions out of your namespace
p5-strictures-2.000006,1       Turn on strict and make all warnings fatal
p7zip-16.02_2                  File archiver with high compression ratio
pcre-8.43_1                    Perl Compatible Regular Expressions library
pcre2-10.32_1                  Perl Compatible Regular Expressions library, version 2
perl5-5.28.2                   Practical Extraction and Report Language
php71-7.1.30                   PHP Scripting Language
php71-bz2-7.1.30               The bz2 shared extension for php
php71-ctype-7.1.30             The ctype shared extension for php
php71-dom-7.1.30               The dom shared extension for php
php71-exif-7.1.30              The exif shared extension for php
php71-fileinfo-7.1.30          The fileinfo shared extension for php
php71-filter-7.1.30            The filter shared extension for php
php71-gd-7.1.30                The gd shared extension for php
php71-gettext-7.1.30           The gettext shared extension for php
php71-hash-7.1.30              The hash shared extension for php
php71-iconv-7.1.30             The iconv shared extension for php
php71-imap-7.1.30              The imap shared extension for php
php71-intl-7.1.30              The intl shared extension for php
php71-json-7.1.30              The json shared extension for php
php71-mbstring-7.1.30          The mbstring shared extension for php
php71-mcrypt-7.1.30            The mcrypt shared extension for php
php71-openssl-7.1.30           The openssl shared extension for php
php71-pdo-7.1.30               The pdo shared extension for php
php71-pdo_pgsql-7.1.30         The pdo_pgsql shared extension for php
php71-pgsql-7.1.30             The pgsql shared extension for php
php71-pspell-7.1.30            The pspell shared extension for php
php71-session-7.1.30           The session shared extension for php
php71-simplexml-7.1.30         The simplexml shared extension for php
php71-xml-7.1.30               The xml shared extension for php
php71-zip-7.1.30               The zip shared extension for php
php71-zlib-7.1.30              The zlib shared extension for php
pinentry-1.1.0_4               Collection of simple PIN or passphrase entry dialogs
pinentry-tty-1.1.0             Console version of the GnuPG password dialog
pkg-1.11.1                     Package manager
pkgconf-1.6.1,1                Utility to help to configure compiler and linker flags
png-1.6.37                     Library for manipulating PNG images
postfix-3.4.6,1                Secure alternative to widely-used Sendmail
postgresql10-contrib-10.9      The contrib utilities from the PostgreSQL distribution
postgresql10-server-10.9       PostgreSQL is the most advanced open-source database available anywhere
postgresql95-client-9.5.18     PostgreSQL database (client)
py27-dns-2.3.6_2               DNS (Domain Name Service) library for Python
py27-dnspython-1.16.0          DNS toolkit for Python
py27-psycopg2-2.8.3            High performance Python adapter for PostgreSQL
py27-pytest-runner-2.11.1      Test support for pytest runner in setup.py
py27-setuptools-41.0.1         Python packages installer
py27-setuptools_scm-3.3.3      Setuptools plugin to manage your versions by scm tags
py27-sqlalchemy13-1.3.5        Python SQL toolkit and Object Relational Mapper 1.3.x
py27-sqlite3-2.7.16_7          Standard Python binding to the SQLite3 library (Python 2.7)
py36-acme-0.35.1,1             ACME protocol implementation in Python
py36-asn1crypto-0.24.0         ASN.1 library with a focus on performance and a pythonic API
py36-certbot-0.35.1,1          Let's Encrypt client
py36-certifi-2019.6.16         Mozilla SSL certificates
py36-cffi-1.12.3               Foreign Function Interface for Python calling C code
py36-chardet-3.0.4_1           Universal encoding detector for Python 2 and 3
py36-configargparse-0.14.0     Drop-in replacement for argparse
py36-configobj-5.0.6_1         Simple but powerful config file reader and writer
py36-cryptography-2.6.1        Cryptographic recipes and primitives for Python developers
py36-idna-2.8                  Internationalized Domain Names in Applications (IDNA)
py36-josepy-1.2.0              JOSE protocol implementation in Python
py36-openssl-18.0.0            Python interface to the OpenSSL library
py36-parsedatetime-2.4_1       Python module for parsing 'human readable' date/time expressions
py36-pycparser-2.19            C parser in Python
py36-pyrfc3339-1.1             Generate and parse RFC 3339 timestamps
py36-pysocks-1.7.0             Python SOCKS module
py36-pytz-2019.1,1             World Timezone Definitions for Python
py36-requests-2.21.0           HTTP library written in Python for human beings
py36-requests-toolbelt-0.8.0   Utility belt for advanced users of python-requests
py36-setuptools-41.0.1         Python packages installer
py36-six-1.12.0                Python 2 and 3 compatibility utilities
py36-urllib3-1.22,1            HTTP library with thread-safe connection pooling, file post, and more
py36-zope.component-4.2.2      Zope Component Architecture
py36-zope.event-4.1.0          Very basic event publishing system
py36-zope.interface-4.6.0      Interfaces for Python
python27-2.7.16_1              Interpreted object-oriented programming language
python36-3.6.9                 Interpreted object-oriented programming language
razor-agents-2.84_1            Distributed, collaborative, spam detection and filtering network
python36-3.6.9                 Interpreted object-oriented programming language
razor-agents-2.84_1            Distributed, collaborative, spam detection and filtering network
re2c-0.14.3                    Compile regular expression to C (much faster final code than flex)
readline-8.0.0                 Library for editing command lines as they are typed
rhash-1.3.5                    Utility and library for computing and checking of file hashes
ripole-0.2.2                   Small program designed to pull attachments out of OLE2 documents
roundcube-php71-1.3.9,1        Fully skinnable XHTML/CSS webmail written in PHP
rpm2cpio-1.4_2                 Convert .rpm files to cpio format
spamassassin-3.4.2_3           Highly efficient mail filter for identifying spam
sqlite3-3.28.0                 SQL database engine in a C library
texinfo-6.6_1,1                Typeset documentation system with multiple format output
tiff-4.0.10_1                  Tools and library routines for working with TIFF images
tinycdb-0.78_2                 Analogous to cdb, but faster
tnef-1.4.12                    Unpack data in MS Outlook TNEF format
tpm-emulator-0.7.4_2           Trusted Platform Module (TPM) emulator
trousers-0.3.14_2              Open-source TCG Software Stack
unarj-2.65_2                   Allows files to be extracted from ARJ archives
unrar-5.71,6                   Extract, view & test RAR archives
unzoo-4.4_2                    ZOO archive extractor
uwsgi-2.0.16_3                 Developer-friendly WSGI server which uses uwsgi protocol
webp-1.0.2                     Google WebP image format conversion tool
webpy-0.39                     Web Framework For Python
zoo-2.10.1_3                   Manipulate archives of files in compressed form
```
## Last Bits

Seem to be some issues with clamav / amavisd with IP addresses here and there

Appending the jail's IP address to places where its expecting 127.0.0.1 seems to be needed to fix it.

Run `freshclam` to update the clamdb ?

Make sure that postgresql client is up to date with version 10

