# Reporting security issues

To report a security issue, please file a "Koha security" bug on the Koha community's ["Bugzilla"](https://bugs.koha-community.org/bugzilla3/) bug tracking system.

### Steps to file a "Koha security" bug
1. Go to [Bugzilla](https://bugs.koha-community.org/bugzilla3/).
2. Click "File a Bug".
3. Choose "Koha security" as the product.
4. Enter a summary of the problem in the "Summary" field.
5. Provide as much detail as you can in the "Description field".
    1. Typical information to include is the Koha version and the steps you took to encounter the bug that you are experiencing.
    2. You may choose to include screenshots to help illustrate the bug.
    3. NOTE: Do not include any personal information about you or your system in the "Summary" or "Description". While a "Koha security" bug is private to the security team while the bug is active, once the bug is fixed (in all supported versions) it will become a "Koha" bug which is publicly viewable by anyone.
6. If you would like to provide a patch, consider reading through the [Koha developer handbook](https://wiki.koha-community.org/wiki/Developer_handbook). It will help guide you on the tools and processes that Koha developers use to write and submit patches.

### After the bug is submitted
The Koha security team endeavour to acknowledge security bug reports as quickly as possible. If someone does not post a comment on your bug, please be patient. The team appreciates your report, and a member of the team will respond to you.

After your bug is acknowledged, a member of the team will try to reproduce the bug and then rate the severity. For many cases, the team member will write a patch and upload it to Bugzilla for review by the rest of the security team. Once it has been independently tested by either the reporter or another member of the team, another member of the team will QA test it, and then the Release Manager will work with the Release Maintainers to push the patch to the main code branch and all stable code branches. Once the patch has been pushed, it will be scheduled to go out in the next monthly release of Koha.

Since the process involves a number of different people, it can take some time to complete. However, the security team is determined to apply security patches to all stable/maintained branches, so the team appreciates your patience.

### After the bug fix is released
Once the bug fix is released in the monthly update, the bug report will be moved from the "Koha security" product and into the "Koha" product where it is globally visible.

You will be listed as the bug reporter and all the information you provided will be visible. If you do want us to hide any of your comments, let us know and we can mark them as private. Note again that this does not apply to the "Summary" or "Description", so be careful with the information you disclose.

### Resources on securing Koha
* [Koha coding guidelines](https://wiki.koha-community.org/wiki/Coding_Guidelines)
* [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
