########################################
# Regex Patterns for Really Bad Things!
$errorTag = "\s*<Error Condition=""!Exists\('\$\(SolutionDir\)\\\.nuget\\NuGet\.targets'\)"" Text=""\$\(\[System\.String\]::Format\('\$\(ErrorText\)', '\$\(SolutionDir\)\\\.nuget\\NuGet\.targets'\)\)"" />"	
$listOfBadStuff = @(
	#sln regex
	"\s*(\.nuget\\NuGet\.(exe|targets)) = \1",
	#*proj regexes
	"\s*<Import Project=""\$\(SolutionDir\)\\\.nuget\\NuGet\.targets"".*?/>",
	"\s*<Target Name=""EnsureNuGetPackageBuildImports"" BeforeTargets=""PrepareForBuild"">\s*<PropertyGroup>\s*<ErrorText>.*?</ErrorText>\s*</PropertyGroup>\s*$errorTag\s*</Target>",
    $errorTag,
	"\s*<RestorePackages>\w*</RestorePackages>"
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

ls -Recurse -include *.csproj, *.sln, *.fsproj, *.vbproj, *.wixproj, *.vcxproj |
  foreach {
    sp $_ IsReadOnly $false
    $content = Get-Content -Raw -Path $_.FullName
    $origContent = $content
    foreach($badStuff in $listOfBadStuff){
        $content = $content -replace $badStuff, ""
    }
    if ($origContent -ne $content)
    {	
        $content | Out-File -encoding "UTF8" -NoNewline $_.FullName
        write-host messed with $_.Name
    }		    
}
