########################################
# Regex Patterns for Really Bad Things!

$reallyBadStuff = @"
<Import Project="`$(SolutionDir)\.nuget\NuGet.targets" Condition="Exists('`$(SolutionDir)\.nuget\NuGet.targets')" />
"@

$kindaBadStuff = @"
\s.nuget\NuGet.exe = .nuget\NuGet.exe
\s*.nuget\NuGet.targets = .nuget\NuGet.targets
"@

$badStuff = @"
\s*<Target Name="EnsureNuGetPackageBuildImports" BeforeTargets="PrepareForBuild">
\s*<PropertyGroup>
\s*<ErrorText>This project references NuGet package(s) that are missing on this computer. Enable NuGet Package Restore to download them.  For more information, see http://go.microsoft.com/fwlink/?LinkID=322105. The missing file is {0}.</ErrorText>
\s*</PropertyGroup>
\s*<Error Condition="!Exists('`$(SolutionDir)\.nuget\NuGet.targets')" Text="`$([System.String]::Format('`$(ErrorText)', '`$(SolutionDir)\.nuget\NuGet.targets'))" />
\s*</Target>
"@

$hintPathPattern = @"
<HintPath>(\d|\w|\s|\.|\\)*packages
"@

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
    $content = cat $_.FullName -Raw
    $origContent = $content
    $content = $content.Replace($kindaBadStuff, "")
    $content = $content.Replace($reallyBadStuff, "")
    $content = $content.Replace($badStuff, "")
    $content = $content -replace $hintPathPattern, "<HintPath>`$(SolutionDir)packages"
    if ($origContent -ne $content)
    {	
        $content | out-file -encoding "UTF8" $_.FullName
        write-host messed with $_.Name
    }		    
}
