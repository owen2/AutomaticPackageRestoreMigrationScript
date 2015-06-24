#######################
# Delete Junk

ls -Recurse -include 'bin','obj','packages' |
  foreach {
    $currentItem = $_
    if ((ls $currentItem.Directory | ?{ $_.Name -Like "*.sln" -or $_.Name -Like "*.*proj" }).Length -gt 0) {
      remove-item $currentItem -recurse -force
      write-host deleted $currentItem
    }
}
