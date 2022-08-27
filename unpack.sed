/.tar/ {
s,^,bzip2 -d -c ,
s,$, | tar x -C ,
b
}
s,^,bzip2 -d -c ,
s,$, >,
