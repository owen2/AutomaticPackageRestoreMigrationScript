Automatically Upgrading to Automatic Package Restore
====================================================

So, you clicked "Enable Nuget Package Restore" and now your stuff doesn't build. The steps to fix it are painful, but less painful with this script. 

You can use this at your own risk to remove nuget.exe, nuget.targets, and all project and solution references to nuget.targets so you can take advantage of Automatic Package Restore. It more or less automates the process described [here](http://docs.nuget.org/docs/workflows/migrating-to-automatic-package-restore)

It will recurse through the directory you run the script from and do it to any solutions that may be in there somewhere. Be careful and have fun!
