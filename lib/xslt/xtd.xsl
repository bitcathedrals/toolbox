<?xml version="1.0"?>
<xsl:stylesheet 
  version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xtd="file:///home/mattie/tbox/data/toolbox/tech_doc">

  <!--
       Create a index of all of the features keyed by the heading
       -->

  <xsl:key name="feature_tbl" match="xtd:feature" use="xtd:heading"/>

  <xsl:template match="xtd:synopsis">
    <p class="xtd_synopsis">
      <xsl:copy-of select="child::*|text()"/>
    </p>
  </xsl:template>

  <xsl:template match="xtd:introduction">
    <div class="xtd_introduction">
      <xsl:call-template name="xtd_filter"/>
    </div>
  </xsl:template>

  <xsl:template match="xtd:overview">
    <div class="xtd_overview">
      <xsl:call-template name="xtd_filter"/>
    </div>
  </xsl:template>

  <xsl:template match="xtd:background">
    <div class="xtd_background">
      <div>Background</div>
      <xsl:call-template name="xtd_filter"/>
    </div>
  </xsl:template>

  <xsl:template match="xtd:diagram">
    <div class="xtd_diagram">
    
      <div>
        <xsl:value-of select="text()"/>
      </div>

      <xsl:choose>
        <xsl:when test="@format='dia'">
          <a href="{@basename}.dia">Master Format</a>
        </xsl:when>
      </xsl:choose>

      <!-- currently scaled images are used, looks horrible and the
           text is even worse. Need to switch to SVG ASAP. -->

      <object data="{@basename}.png" type="image/png"/>

      <!-- to support a multitude of diagram files a id string @format
           is used to select the kind of file. -->

    </div>
  </xsl:template>

  <xsl:template name="xtd_filter">

    <!--
         copy a section, processing xtd: elements with templates,
         and copying the rest.

         This can only process xtd: elements that are children of
         other xtd: elements. I cannot copy a node, and modify
         a nested element at the same time with XSLT. -->

    <xsl:for-each select="child::*">
      <xsl:choose>

        <xsl:when test="self::xtd:*">
          <xsl:apply-templates select="."/>
        </xsl:when>

        <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>

      </xsl:choose>
    </xsl:for-each>

  </xsl:template>

</xsl:stylesheet>
