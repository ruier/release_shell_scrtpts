# release_shell_scrtpts
some scripts help to release you binaries

##self_extract.sh
add a self extract shell script for release tarball files from [qcom](https://developers.google.com/android/nexus/drivers)
  - you should create your release files into tar files
  - use tar czvf to encrypt
  - append the file to the script
  - use --apend from tar, like tar -rf release.sh mytarfile.tar.gz
