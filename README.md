All-in Signing Service (AIS) - Workshop
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
