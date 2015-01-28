########################################
# Regex Patterns for Really Bad Things!
$listOfBadStuff = @(
    #sln regex
    "\s*Project.+.nuget(.|\n)*?EndProject(\b)",
    #*proj regexes
    "\s*<Import Project=""\$\(SolutionDir\)\\\.nuget\\NuGet\.targets"".*?/>",
    "\s*<Target Name=""EnsureNuGetPackageBuildImports"" BeforeTargets=""PrepareForBuild"">(.|\n)*?</Target>"
)

#######################
# Delete .nuget folder

ls -Recurse -include .nuget |
  foreach { 
    remove-item $_ -recurse -force
    write-host deleted $_
}

#########################################################################################
# Fix Project and Solution Files to reverse damage done by "Enable NuGet Package Restore

ls -Recurse -include *.csproj, *.sln, *.fsproj, *.vbproj |
  foreach {
    $content = cat $_.FullName | Out-String
    $origContent = $content
    foreach($badStuff in $listOfBadStuff){
        $content = $content -replace $badStuff, ""
    }
    if ($origContent -ne $content)
    {   
        $content | out-file -encoding "UTF8" $_.FullName
        write-host messed with $_.Name
    }           
}