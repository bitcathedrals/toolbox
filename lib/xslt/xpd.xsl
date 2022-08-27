<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xpd="file:///home/mattie/tbox/data/toolbox/prog_doc">

  <xsl:import href="xtd.xsl"/>

  <!-- this template must be called with a xpd:rcs element in context -->

  <xsl:template match="xpd:rcs">

    <!--
         This template serves to document how to fetch the source
         from the repository. The presentation should make it
         quick for experienced users, and possible for novices
         of the revision control system.
         -->

    <div class="xpd_rcs">
      <div>HOWTO use the
        <xsl:choose>
          <xsl:when test="@sys='svn'">
            <a href="http://subversion.tigris.org/">SubVersion</a> 
          </xsl:when>
        </xsl:choose>
        repository to fetch the source.
      </div>

      <p>
        The source is available from the repository by invoking a
        client program to checkout a copy of the source. The
        invocation of the client is described below:
      </p>

      <pre>
        <xsl:choose>
          <xsl:when test="@sys='svn'">
            svn co [repository url + branch] [optional: local path for source]
          </xsl:when>
        </xsl:choose>
      </pre>

      <p>
        The repository URL is given at the head of the release table
        below following the "@" sign. The branch is given under the
        "branch" collumn in the release table. Select a release, type
        the command followed by a space, then the url and the branch
        together, and finally a space seperated local path to place the
        checked out copy in.
      </p>
    </div>
  </xsl:template>

  <!-- this template must be called with the releases, and a branch element
       in the context -->

  <xsl:template name="xpd_ins_rtable">
    <table class="xpd_rtable">
      <caption>
        releases are available @ <xsl:value-of select="xpd:rcs/text()"/>
    </caption>
    <thead>
      <tr>
        <th>synopsis</th>
        <th>version</th>
        <th>Feature List</th>
        <th>branch</th>
      </tr>
    </thead>        

    <!--
         Where there is a branch child of the document root
         hardcode it into the release table as the mainline
         stable, or HEAD release.
         -->

    <xsl:if test="xpd:branch">
      <tr>
        <td class="synopsis">
          Stable mainline of the project development; not a release.</td>
          <td class="version">HEAD</td>
          <td class="feature_list">
            beta quality features planned for the next release
          </td>
          <td class="branch"><xsl:value-of select="xpd:branch/text()"/></td>
        </tr>
      </xsl:if>

      <xsl:for-each select="child::xpd:release">
        <tr>
          <td class="synopsis">
            <xsl:copy-of select="child::synopsis/*|synopsis/text()"/>
          </td>
          <td class="version"><xsl:value-of select="@version"/></td>

          <td class="feature_list">
            <xsl:for-each select="id(@features)">
              <a href="#{@label}"><xsl:value-of select="@label"/></a>
              <xsl:if test="position()!=last()">,</xsl:if>
            </xsl:for-each>
          </td>
          <xsl:if test="branch">
            <td class="branch"><xsl:value-of select="branch/text()"/></td>
          </xsl:if>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>
</xsl:stylesheet>
