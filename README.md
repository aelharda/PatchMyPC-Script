# PatchMyPC-Script
A PowerShell script to automate the installation of PatchMyPC updates based on their 3rdparty specific KB article pattern without installing default Windows KBs. The script handles downloading, extracting, and importing the PSWindowsUpdate module, and filters and installs updates without requiring a system reboot.

Example: You have Windows KBXXXXX, SQL updates and 7zip updates from PMPC pending, you only want to install 7zip updates and others pushed via PMPC without installing SQL updates, then this script does just that, ignoring everything else and only installing pending updates from PMPC.
