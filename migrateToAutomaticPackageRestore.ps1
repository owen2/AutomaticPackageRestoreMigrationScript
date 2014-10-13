########################################
# Regex Patterns for Really Bad Things!
$listOfBadStuff = @(
@"
\s<Import Project="`$(SolutionDir)\.nuget\NuGet.targets" Condition="Exists('`$(SolutionDir)\.nuget\NuGet.targets')" />
"@,
@"
\s.nuget\NuGet.exe = .nuget\NuGet.exe
\s\*.nuget\NuGet.targets = .nuget\NuGet.targets
"@,
@"
\s*<Target Name="EnsureNuGetPackageBuildImports" BeforeTargets="PrepareForBuild">(.|\n)*?</Target>
"@
)


#######################
# Delete NuGet.targets

ls -Recurse -include 'NuGet.exe','NuGet.targets' |
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