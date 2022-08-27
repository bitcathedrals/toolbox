<!--
A short stylesheet to extract all of the snippets with the name
of zshrc, or shorthands.
-->
<xsl:stylesheet version="1.0"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes"/>
<xsl:template match="/">
  <xsl:apply-templates select="//env/variable"/>
</xsl:template>

<xsl:template match="env/variable">
<xsl:value-of select="@name"/>:<xsl:value-of select="."/>
<xsl:text>
</xsl:text>
</xsl:template>

</xsl:stylesheet>
