#! /bin/sh
#----------------------------------------------------------------------
# tool
# version: a written by: Mike Mattie
#----------------------------------------------------------------------

tmp=${TMPDIR:-/tmp/}

# HACKING: switching is not going to work with a simple variable assignment.
#          a real fix will require a invoke generator function.
#          debugging opt support could also be cleanly encapsulated in this
#          helper

xsl="xsltproc"
xsl_opts=""

#xsl="
#java org.apache.xalan.xslt.Process \
#-IN archive/toolbox/toolbox.xml \
#-XSL archive/toolbox/toolbox.xsl \
#-OUT toolbox.html"

toolbox="archive/toolbox/toolbox.xml"

function help {
  cat >/dev/stderr <<HELP
tool version: a written by: Mike Mattie
usage: tool [command] [arguements]
help                        : display this screen.

gen                         : generate the toolbox user interface
                              (currently HTML)

env  [shell | package dist] : The shell option will extract the
                              shell configuration writing zshrc
                              and zshenv files to the CWD.

                              The package option will extract the
                              package list for distribution [dist]
                              (required) with a optional section set 
                              to restrict the list returned to specific
                              sections.

unpack [set]                : unpack the documentation

pack [set]                  : pack the documentation by removing the
                              uncompressed documents

---[contributer functions]---

verify                      : verify the toolbox, adjusting paths, files, 
                              and archives for consistency, and format 
                              correctness.

HELP
}

function generate_ui {
  echo >/dev/stderr "generating the HTML interface"
#  java org.apache.xalan.xslt.Process -IN archive/toolbox/toolbox.xml \
#  -XSL archive/toolbox/toolbox.xsl \
#  -OUT toolbox.html

  $xsl $xsl_opts archive/toolbox/toolbox.xsl $toolbox 2>tool-gui.log | tidy -i >toolbox.html;
}

function verify {
  # this does not yet do a save command, a dry run.
  echo 'cd toolbox; call sec_walker . "sec"; save' |\
        xsh -t -l scripts/verify.xsh -I $toolbox 2>&1 | tee verify.log;
}

selection="";

function mk_xslt_filter { # the notation

                          # varadic set of element children to output -
                          # attributes must be prepended by a '@'

# make a xslt filter for extracting data from chosen elements and
# attributes into line deliniated form for processing with the unix
# toolbox.

  # [step] generate the top half of the stylesheet

  cat >${tmp}select.xsl <<EOF
<?xml version="1.0" encoding="US-ASCII"?>
<!--
StyleSheet: for extracting attributes
related: toolbox.dtd
written by: Mike Mattie
-->
<xsl:stylesheet version="1.0"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text"/>
EOF

  # [STEP] generate the middle of the stylesheet with XSLT template
  #        match, and apply-templates elements.

  selection="";

  notation=$1;
  shift;

  #----------------------------------------------------------------------
  # if a selective notation is in use, generate sed code to rewrite
  # the notation into apply-templates elements. If the whole document
  # is being processed, create the apply-templates in the "$selection"
  # variable, so insertion can be postponed until the match elements
  # have been generated.
  #----------------------------------------------------------------------

  # BUG: if there is a "," character in the notation we need to
  #      append a trailing comma.

  if [[ "all" != "$notation" ]]
  then
    #----------------------------------------------------------------------
    # here we take the arguements, prepend a section seperator, and then
    # replace the first comma and newline with brackets for shell brace
    # expansion. 
    #----------------------------------------------------------------------
    input=`echo "$notation" | sed -e 's,^,::,; s/,/::{/; s/,$/}/'`

    #----------------------------------------------------------------------
    # Shell brace expansion is used here to duplicate the notation with
    # whitespace converted to newlines. This is a cheap way to simplify
    # the sed script "section2xpath.sed"
    #----------------------------------------------------------------------
    eval echo "$input" | tr ' ' '\n' >${tmp}selections

    cat >${tmp}section2xpath.sed <<EOF
s,^::,<xsl:apply-templates select="/toolbox/section[@name=',
s,::,']/section[@name=',g
h
EOF
  fi

  i=1
  while [[ $i -le $# ]]
  do
    cat >>${tmp}select.xsl <<EOF
<xsl:template match="${!i}"><xsl:value-of select="."/>
<xsl:text>
</xsl:text>
</xsl:template>
EOF

    if [[ "all" != "$notation" ]]
    then
      # The end of the array as the special case for generating sed code
      if [[ $i -lt $# ]]
      then      
        cat >>${tmp}section2xpath.sed <<EOF
s,\$,']//${!i}"/>,
p
g
EOF
      else
        echo >>${tmp}section2xpath.sed "s,\$,']//${!i}\"/>,"
      fi
    else
      selections=`echo "${selections}<xsl:apply-templates select=\"//${!i}\"/>"`
    fi

    i=$(($i + 1))
  done

  # [STEP] generate the bottom half of the stylesheet

  test "$notation" != "all" &&\
  selections=`sed -f ${tmp}section2xpath.sed <${tmp}selections`;

#  echo >/dev/stderr "selections value: $selections"

  cat >>${tmp}select.xsl <<EOF
<xsl:template match="/">
$selections
</xsl:template>
</xsl:stylesheet>
EOF

  # [STEP] extract the data with XSLT filtering out null values. 
  selections=$(echo "$selections" | $xsl $xsl_opts ${tmp}select.xsl $toolbox | grep -v null);
}

function environment {
  if [[ $# -lt 1 ]]
  then
    echo >/dev/stderr "environment requires an arguement see help below"
    echo >/dev/stderr;
    help;
    exit 1;
  fi

  choose=$1;
  shift;

  case $choose in
    "shell")
      echo >/dev/stderr "extracting shell configuration to zshenv and zshrc"

      $xsl $xsl_opts >zshrc - $toolbox <<EOF
<?xml version="1.0" encoding="US-ASCII"?>
<!--
A short stylesheet to extract all of the snippets with the name
of zshrc, or shorthands.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes"/>

<xsl:template match="/">
  <xsl:value-of select="//snippets/snippet[@name='zshrc']"/>
  <xsl:value-of select="//snippets/snippet[@name='shorthands']"/>
</xsl:template>
</xsl:stylesheet>
EOF

#----------------------------------------------------------------------
# Extract the environment.
#
# Zap the output file, iterate through the line deliniated variable list;
# packing multiple values into a single key. 
#
# The sort routine was used to simplify this algorithm greatly.
#----------------------------------------------------------------------
      echo -n >zshenv;
      current="";
      packed=""
      list=""

      old_ifs=$IFS;
      IFS=$'\012';

      for line in `$xsl $xsl_opts archive/toolbox/variables.xsl $toolbox | sort`
      do
	IFS=$old_ifs;

	variable=`expr "$line" : '\(.*\):'`
	path=`expr "$line" : '.*:\(.*\)'`
	echo "line $line - variable \[$variable\] path \[$path\]"

	if [ "$variable" == "$current" ]
	then
	    packed="${packed}${path}:"
	else
	    test -n "$current" && echo "$current=\`echo \"${packed}\$${current}\" | tr -s ":"\`" >>zshenv;

	    list="${list}${current} "
	    current=$variable
	    packed="${path}:";
	fi
      done

      echo "$current=\`echo \"${packed}\$${current}\" | tr -s ":"\`" >>zshenv;
      echo "export $list $current" >>zshenv
    ;;

    "package")
      if [[ $# -lt 1 ]]
      then
        echo >/dev/stderr "the required distribution arguement is missing."
        echo >/dev/stderr "please examine the command or tool help"
        return;
      fi

      dist=$1; shift;
     
      if [[ $# -gt 0 ]]
      then
        sel=$1;
      else
        sel="all"
      fi

      echo >/dev/stderr "extracting $dist package lists for $sel sections"

      eval elem="package[@distribution=\'$dist\']/main"
      mk_xslt_filter $sel $elem;

      case $dist in
        "debian") dist="apt-get update; apt-get install ";;
        *) dist="";;
      esac

      echo -n "$dist"

      echo "$selections" | tr '\n' ' '
      echo;
    ;;
    *)
      echo >/dev/stderr "unkown env parameter $1 please check the help";
    ;;
  esac;
}

function is_tree {
  basename=`expr "$1" : '.*/\(.*\)\..*\.bz2.*'`
  expr "$1" : ".*\.tar\.bz2" >/dev/null;
  return $?;
}

function mk_doc_src_trg {
  mk_xslt_filter "$1" '@archive' '@expanded';


  local middle=$(echo "$selections" | wc -l | tr -s ' ' | cut -d' ' -f 2)
  local check=$(($middle % 2))

  if [[ $check -gt 0 ]]
  then
   echo >/dev/stderr "internal error, selection list line count from \
mk_doc_src_trg should be even, is odd"
   echo >/dev/stderr "[begin selections]"
   echo >/dev/stderr "$selections";
   echo >/dev/stderr "[end selections]"

   exit 1;
  fi

  local upper=$(($middle / 2))
  local lower=$(($upper + 1))
#  echo "middle adjusted is $middle"

  echo "$selections" | cut -d$'\012' -f -${upper} >${tmp}doc_sources
  echo "$selections" | cut -d$'\012' -f ${lower}- >${tmp}doc_targets;
}

function unpack {
  if [[ $# -lt 1 ]]
  then
    sel="all"
  else
    sel=$1;
  fi;

  echo >/dev/stderr "unpacking sections: $sel"

  mk_doc_src_trg $sel;

  local old_ifs=$IFS;
  IFS=$'\012';

  3<>${tmp}doc_targets

  for line in `sed -f archive/toolbox/unpack.sed <${tmp}doc_sources`
  do
    IFS=$old_ifs;

    read target <&3

    if [[ -e $target ]]
    then
      echo >/dev/stderr "skipping archive $target which seems to exist"
      continue;
    fi

    if is_tree "$line"
    then
      echo "unpacking archive tree $target"

      # remove the trailing file and the basename of the archive from
      # the path
      target=`expr "$target" : "\(.*\)${basename}.*"`
      dir=$target

      line="$line $target"
    else
      echo "unpacking archive file $target"
      dir=`dirname $target`
      line="$line $target"
    fi

    test -d $dir || mkdir -p $dir
    echo "command is $line"
    eval "$line"
  done;
}

function pack {
  if [[ $# -lt 1 ]]
  then
    sel="all"
  else
    sel=$1;
  fi;

  echo >/dev/stderr "packing sections: $sel"
  mk_doc_src_trg $sel;

  local old_ifs=$IFS;
  IFS=$'\012';

  3<>${tmp}doc_targets

  for line in `cat ${tmp}doc_sources`
  do
    IFS=$old_ifs;

    read target <&3

    test -e $target || continue;

    if is_tree "$line"
    then
      echo "removing uncompressed archive tree $target"
      # remove any trailing file path within the archive
      target=`expr "$target" : "\(.*${basename}\).*"`

      line="rm -rf $target"
    else
      echo "removing uncompressed archive file $target"
      line="rm $target"
    fi

#    echo "command is $line"
    eval "$line"
  done;
}

test $# -lt 1 && help;

cmd="$1"
shift;

case $cmd in
  "help") help;;

  "gen") generate_ui;;
  "env") environment $@;;
  "unpack") unpack $@;;
  "pack") pack $@;;

  "verify") verify;;
  *)
   echo >/dev/stderr "unrecognized command $cmd\n"
   help
 ;;
esac





