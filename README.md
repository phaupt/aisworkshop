AIS Workshop - Script Overview
===========
```
Workshop Script to produce a detached trusted timestamp
Arguments: <infile> <outfile>
Example:   ./wks-01.sh sample.pdf sample.p7s
```
```
Workshop Script to sign a PDF document (timestamp only)
Arguments: <infile> <outfile>
Example:   ./wks-02.sh sample.pdf sample-timestamp.pdf
```
```
Workshop Script to produce a detached signature (ElDI-V static certificate)
Arguments: <infile> <outfile>
Example:   ./wks-03.sh sample.pdf sample.p7s
```
```
Workshop Script to sign a PDF document (ElDI-V static certificate)
Arguments: <infile> <outfile>
Example:   ./wks-04.sh sample.pdf sample-static.pdf
```
```
Workshop Script to produce a detached signature (OnDemand certificate)
Arguments: <infile> <outfile> <dn> <msisdn> <message> <en|de|fr|it>
Example:   ./wks-05.sh sample.pdf sample.p7s "cn=Hans Muster,o=ACME,c=CH" 41797895164 "Sign sample.pdf ?" en
```
```
Workshop Script to sign a PDF document (OnDemand certificate)
Arguments: <infile> <outfile> <dn> <msisdn> <message> <en|de|fr|it>
Example:   ./wks-06.sh sample.pdf sample-ondemand.pdf "cn=Hans Muster,o=ACME,c=CH" 41797895164 "Sign sample.pdf ?" en
```
```
Workshop Script to produce a batch of detached trusted timestamps
Arguments: <infile1> <infile2> <infile3>
Example:   ./wks-07.sh sample.pdf sample2.pdf sample3.pdf
```
```
Workshop Script to produce a detached signature (OnDemand certificate)
Based on wks-05.sh but using asynchronous mode
Arguments: <infile> <outfile> <dn> <msisdn> <message> <en|de|fr|it>
Example:   ./wks-08a.sh sample.pdf sample.p7s "cn=Hans Muster,o=ACME,c=CH" 41797895164 "Sign sample.pdf ?" en
```
```
Workshop Script to poll a Response ID (asynchronous mode)
Arguments: <ResponseID>
Example:   ./wks-08b.sh bb6035f7-6ef4-419c-a6a4-bf2f6fa476aa
```
