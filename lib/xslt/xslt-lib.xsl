<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:template name="strip_hanging_ws">
    <!--
         strip_hanging_ws: Strips leading and trailing whitespace from
         a string passed as a parameter. Unlike builtin whitespace
         normalization, the whitespace is removed entirely including
         newline and tabs characters. -->

    <xsl:param name="data"/>

    <xsl:variable 
      name="remainder" 
      select="substring($data,2)"/>

    <xsl:variable 
      name="stripped" 
      select="substring($data,1,1)"/>

    <xsl:choose>

      <xsl:when test="contains($stripped,'&#x20;') 
                      or contains($stripped,'&#x9;') 
                      or contains($stripped,'&#xa;') 
                      or contains($stripped,'&#xd;')">

        <xsl:call-template name="strip_hanging_ws">
          <xsl:with-param name="data" select="$remainder"/>
        </xsl:call-template>

      </xsl:when>

      <xsl:otherwise>

        <xsl:call-template name="strip_trailing_ws">
          <xsl:with-param name="data" select="$data"/>
        </xsl:call-template>

      </xsl:otherwise>

    </xsl:choose>  

  </xsl:template>

  <xsl:template name="strip_trailing_ws">

    <!-- strip_trailing_ws: Strips trailing whitespace from a string
         including newline and tab. Can be called independantly as well
         as being a helper for strip_hanging_ws. -->

    <xsl:param name="data"/>

    <xsl:variable 
      name="remainder" 
      select="substring($data,1,string-length($data) - 1)"/>

    <xsl:variable 
      name="stripped" 
      select="substring($data,string-length($data))"/>

    <xsl:choose>

      <xsl:when test="contains($stripped,'&#x20;') 
                      or contains($stripped,'&#x9;') 
                      or contains($stripped,'&#xa;') 
                      or contains($stripped,'&#xd;')">

        <xsl:call-template name="strip_trailing_ws">
          <xsl:with-param name="data" select="$remainder"/>
        </xsl:call-template>

      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$data"/>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
