$env:Path += ";$pwd\bin"
unison lua ssh://gmodserver@devserver.pointshop2.com/~/serverfiles/garrysmod/addons/pointshop2/lua -sshargs "-i $env:USERPROFILE\\.ssh\\gmodserver" -repeat watch
