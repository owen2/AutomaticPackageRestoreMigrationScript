# Owen's bag of nuget related scripts!

## migateToAutomaticPackageRestore.ps1

In short, it reverses "Enable Nuget Package Restore", allowing the newer package restore method to work. 

In Visual Studio 2013, automatic package restore part of the IDE (and the TFS build process). This method is way more reliable than the older, msbuild integrated package restore. It does not require you to have nuget.exe checked in to each soluation and does not require and additional msbuild targets. However, if you have the files related to the old package restore method in your project, Visual Studio will skip automatic package restore. This script will reverse the changes that happen when you click "Enable Nuget Package Restore", allowing the newer Automatic Package Restore to work.

You can use this at your own risk to remove nuget.exe, nuget.targets, and all project and solution references to nuget.targets so you can take advantage of Automatic Package Restore. It more or less automates the process described [here](http://docs.nuget.org/docs/workflows/migrating-to-automatic-package-restore)

It will recurse through the directory you run the script from and do it to any solutions that may be in there somewhere. Be careful and have fun!

## FixHintPaths.ps1

There are some intersting scenarios where you might end up with troubles with incorrect hintpaths in the project files that reference nuget-packaged assemblies that were created while the project was loaded as part of a different solution than the one that is being built. This script is a quick fix for those situations. It replaces the incorrect paths with a reference to the $(SolutionDir) variable. If you find yourself needing this script often, it may be a smell indicating that you may have problems with how your source code is organized. 

Again, this script will recurse down and do this to all project files it finds.

## clean.ps1

This will quickly recurse from the current directory to search for and delete bin, obj, and other junk. It's like doing a "Clean Solution" on a bunch of solutions. I use it to diagnose issues where something might build fine for a developer in visual studio, but is missing something on when it gets built on a continous integration server. I left it in this repository because I use it to diagnose nuget problems (or rule out nuget as the culprit).

Like the other two, it just recurses through the current directory.
