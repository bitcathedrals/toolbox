<?xml version="1.0" encoding="US-ASCII"?>
<!--
StyleSheet: for transforming the toolbox xml data into the HTML front-end
related: toolbox.dtd
version: a2
written by: Mike Mattie
-->
<xsl:stylesheet 
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output 
	method="xml" 
	omit-xml-declaration="no"
	doctype-public="-//W3C//DTD XHTML 1.0"
        doctype-system=
"Strict//EN http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<!--
The document root, generate HTML boilerplate
-->

<xsl:key name="sec_tbl" match="section" use="@name"/>

<xsl:template match="section" mode="toc">
  <div>
    <a href="#{generate-id(key('sec_tbl', ./@name))}">
    <xsl:value-of select="./@name"/></a>
    <xsl:if test="./library">
       <div>
          <a href="#{generate-id(key('sec_tbl', ./@name))}lib">library</a>
       </div>                   
    </xsl:if>
    <xsl:if test="./snippets">
       <div>
          <a href="#{generate-id(key('sec_tbl', ./@name))}snip">snippets</a>
       </div>                   
    </xsl:if>

    <xsl:if test="document">
       <div>
          <a href="#{generate-id(key('sec_tbl', ./@name))}bib">bibliography</a>
       </div>                   
    </xsl:if>
  </div>
</xsl:template>

<xsl:template match="/">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<link rel="stylesheet" href="archive/toolbox/toolbox.css" title="toolbox"/>
<META http-equiv="Content-Style-Type" content="toolbox"/>
<title>ToolBox</title>
</head>
<body>

<div class="toc">
<xsl:for-each select="key('sec_tbl',//section/@name)">
   <xsl:apply-templates select="." mode="toc"/>
</xsl:for-each>
</div>

<div class="body">
<h1>Tools</h1>

<pre class="quote">
Heaven endures; Earth lasts a long time.
The reason why heaven and Earth can endure and last a long time -
Is that they do not live for themselves.
Therefore they can long endure.

Therefore the Sage:
Puts himself in the background yet finds himself in the 
  foreground;
Puts self concern out of his mind, yet find that his self-concern
  is preserved. 
Is it not because he has no self-interest,
that he is therefore able to realize his self-interest?

Tao Te Ching : Lao Tzu - translated by Robert G Henricks.
</pre>

<xsl:apply-templates select="//section"/>
</div>
</body>
</html>
</xsl:template>

<xsl:template match="section">
<h1><a name="{generate-id(key('sec_tbl', ./@name))}"><xsl:value-of select="@name"/></a></h1>
<div class="section">
  <xsl:if test="count(child::tool) > 0">
    <div class="toolpane">
      <xsl:apply-templates select="child::tool"/>
    </div>
  </xsl:if>

  <xsl:if test="child::document">
    <div class="docpane">
      <xsl:apply-templates select="child::document"/>
    </div>
  </xsl:if>

  <xsl:apply-templates select="library"/>

  <xsl:apply-templates select="snippets"/>

  <xsl:if test="child::document">
<h3><a name="{generate-id(key('sec_tbl', ./@name))}bib">Bibliography</a></h3>
  <div class="bibliography">
  <xsl:apply-templates select="descendant::document" mode="bib"/>
  </div>
  </xsl:if>

</div>
</xsl:template>

<!-- 
The Document tree
-->

<xsl:template match="document" mode="bib">
<xsl:if test="url/@master!='null'">
<div class="bibcite">

<div class="credit">
<span class="author"><xsl:value-of select="url/author"/></span>
<span class="title"><xsl:value-of select="url/title"/></span>
</div>

<div class="ref">
<span><xsl:value-of select="url/modified"/></span>
<span class="url"><xsl:value-of select="url/@master"/></span>
</div>

</div>
</xsl:if>
</xsl:template>

<xsl:template match="document">
<div class="document">
<span><xsl:value-of select="@name"/></span>

<div>
<xsl:choose>
  <xsl:when test="url/@master='null'">
  <div class="null">Remote Master Not Available</div>
  </xsl:when>
  <xsl:otherwise>
<div class="link"><a href="{url/@master}">Remote Master</a></div>
  </xsl:otherwise>
</xsl:choose>

<div class="link"><a href="{@archive}">Local Archive</a></div>
<div class="link"><a href="{@expanded}">Expanded</a></div>
</div>

<p>
<xsl:value-of select="text()"/>
</p>


<xsl:if test="outline">
  <div class="heading">Outline</div>
  <xsl:if test="outline/@top">
     <div class="link"><a href="{@expanded}/{outline/@top}">Document Top</a></div>
  </xsl:if>
</xsl:if>

<xsl:if test="bkmark">
<div class="heading">BookMarks</div>
<xsl:apply-templates select="bkmark"/>
</xsl:if>

</div>
</xsl:template>

<xsl:template match="document/bkmark">
<div class="link"><a href="{../@expanded}/{@ref}"><xsl:value-of select="text()"/></a></div>
</xsl:template>

<!--
The tool tree
-->

<xsl:template match="tool">
<div class="tool">
  <div class="header">
  <span><xsl:value-of select="@name"/></span>
  <span><xsl:value-of select="@version"/></span>
  <span><a href="{@devsite}">tool</a></span>

  <xsl:if test="@buglist">
  <span><a href="{@buglist}">buglist</a></span>
  </xsl:if>

  <xsl:if test="@news">
  <span><a href="{@news}">NEWS</a></span>
  </xsl:if>

  <xsl:if test="@changelog">
  <span><a href="{@changelog}">changelog</a></span>
  </xsl:if>
  </div>

  <xsl:apply-templates select="support"/>

  <p><xsl:value-of select="text()"/></p>

<xsl:apply-templates select="filters"/>
<xsl:apply-templates select="manual"/>

<xsl:apply-templates select="package | install | dist"/>
<xsl:apply-templates select="env"/>
</div>
</xsl:template>

<xsl:template match="support">
<ul>
<xsl:apply-templates select="feature"/>
</ul>
</xsl:template>

<xsl:template match="feature">
<li>
<xsl:value-of select="text()"/>
</li>
</xsl:template>

<xsl:template match="filters">
<table class="tool">
<tr><th colspan="2">Filters</th></tr>
<xsl:apply-templates select="filter"/>
</table>
</xsl:template>

<xsl:template match="filter">
<tr><th class="tool"><xsl:value-of select="@description"/></th><td class="paste"><xsl:value-of select="text()"/></td></tr>
</xsl:template>

<xsl:template match="manual">
<table class="tool">
<tr><th colspan="3"><xsl:value-of select="text()"/></th></tr>

<tr>
<xsl:choose>
  <xsl:when test="@expanded='null'">
  <td class="null">!broken!</td>
  </xsl:when>
  <xsl:otherwise>
  <td class="tool"><a href="{@expanded}">expanded</a></td>
  </xsl:otherwise>
</xsl:choose>

<xsl:choose>
  <xsl:when test="@archive='null'">
  <td class="null">!broken!</td>
  </xsl:when>
  <xsl:otherwise>
  <td class="tool"><a href="{@archive}">archived</a></td>
  </xsl:otherwise>
</xsl:choose>

<xsl:choose>
  <xsl:when test="@master='null'">
  <td class="null">Master N/A</td>
  </xsl:when>
  <xsl:otherwise>
  <td class="tool"><a href="{@master}">master</a></td>
  </xsl:otherwise>
</xsl:choose>
</tr>

<xsl:if test="./tab">
<xsl:apply-templates select="tab"/>
</xsl:if>

</table>
</xsl:template>

<xsl:template match="package">
<table class="tool">
<tr>
  <th><xsl:value-of select="@distribution"/> Packages</th>
  <td class="paste"><xsl:value-of select="main"/></td>
  <xsl:apply-templates select="related"/>
</tr>
</table>
</xsl:template>

<xsl:template match="related">
<th>Add-Ons</th><td class="paste"><xsl:value-of select="text()"/></td>
</xsl:template>

<xsl:template match="dist">
<table class="tool">
<tr><th colspan="2"><a href="{@master}">Distribution</a> [<a href="{@dist}">Archive</a>]</th></tr>
<tr><td class="tool">notes</td><td><xsl:value-of select="text()"/></td></tr>
<tr><td class="tool">dist</td><td><xsl:value-of select="@dist"/></td></tr>
</table>
</xsl:template>

<xsl:template match="env">
<table class="tool">
<tr><th colspan="3">Environment</th></tr>
<xsl:apply-templates select="variable"/>
</table>
</xsl:template>

<xsl:template match="variable">
<tr><th>variable</th>
<td class="paste"><xsl:value-of select="@name"/></td>
<td class="paste"><xsl:value-of select="."/></td>
</tr>
</xsl:template>

<!-- [library] -->

<xsl:template match="library">

<h3><a name="{generate-id(key('sec_tbl', ../@name))}lib">Library</a></h3>
<div class="library">
<xsl:apply-templates/>
</div>
</xsl:template>

<xsl:template match="module">
<h4>Module [<xsl:value-of select="@name"/>]</h4>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="snippets">
<h3><a name="{generate-id(key('sec_tbl', ../@name))}snip">Snippets</a></h3>
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="snippet">
<div class="snippet">
<span><xsl:value-of select="@name"/> : <xsl:value-of select="@description"/></span>
<pre>
<xsl:value-of select="text()"/>
</pre>
</div>
</xsl:template>


</xsl:stylesheet>
