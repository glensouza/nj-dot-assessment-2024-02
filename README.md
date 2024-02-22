# New Jersey Department of Transportation (DOT) Assessment

NJ DOT is a large organization with a variety of applications and services. The following is an assessment of the current state of the organization's IT infrastructure and applications.

Traffic data:

![traffic-data](./traffic-data.png)

## Servers On Prem

![servers on prem](./servers-onprem.png)

## Public website

Department exposure, explains what purpose of department is.

- Bootstrap
- HTML
- CSS
- JavaScript

A job runs overnight at interval to update the website with the latest information. The job is written in SQL Agent activeX and VBScript and PowerShell runs read database. The job then updates the website with the latest information injecting HTML and CSS.

Currently hosted in Azure for lower environments and PROD is on prem.

![public website](./public-internet.png)

### Infrastructure

Cloud infranstructure is hosted on Virtual Machines with tight network.

![azure-portal-vms](./azure-portal-vms.png)

Naming convention:

- TP = Transportantion
- AZ = Azure
- S = Non-Prod
- E = Prod

They all share the same file share.

## Intranet website hosted on prem

Has access to series of aplications and services.

- HTML
- Bootstrap
- CSS
- JavaScript
- ASP Classic back end

![intranet website](./intranet-website.png)

Has a login experience with usernames and password stored in a databases. Would like to move to Microsoft Entra SSO. Application keeps user state in database, so when I log in next time it knows where I was and takes me there.

![intranet-looged-in](./intranet-logged-in.png)

Has personalized information for each user. Each application is written in different technology: asp classic or .net framework. Some applications display a Crystal Report.

![crystal-report-request](./crystal-report-request.png)

Crystal report page is written in .net framework version 4.5 aspx. Potentially move to PowerBI.

![crystal-report](./crystal-report.png)

There are 5 COM+ components. Written in VB, still have source code, very old havent touched them in a while.

There is a version of it in C# done in WCF. This is utilized in reports.

![intranet-wcf](./intranet-wcf.png)

Sample report with chart plugin:

![net-chart-plugin-report](./net-chart-plugin-report.png)

## Library Server

New documents are uploaded to library server via web page:

![upload-to-library-server](./upload-to-library-server.png)

Those files are used in both intranet and internet sites for things like press releases, etc. in PDF format. It's a multi-step process that could be improved with dynamic site hitting an API instead. A SQL Stored Procedure is used to produce the dynamic HTML for the page. Then a sync job runs to update the website with the latest information.
