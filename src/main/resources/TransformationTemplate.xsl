<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" />
	<xsl:param name="modelSetVersion">
		CloudSocketData
	</xsl:param>

	<xsl:template match="/">
		<xsl:text>
# baseURI: http://cloudsocket.eu/data
# imports: http://ikm-group.ch/archimeo/bpaas
# prefix: data

@prefix apqc: &lt;http://ikm-group.ch/archimeo/apqc#&gt; .
@prefix archi: &lt;http://ikm-group.ch/archiMEO/archimate#&gt; .
@prefix bpaas: &lt;http://ikm-group.ch/archimeo/bpaas#&gt; .
@prefix bpmn: &lt;http://ikm-group.ch/archiMEO/BPMN#&gt; .
@prefix data: &lt;http://cloudsocket.eu/data#&gt; .
@prefix fbpdo: &lt;http://ikm-group.ch/archimeo/fbpdo#&gt; .
@prefix media-types: &lt;http://www.iana.org/assignments/media-types#&gt; .
@prefix owl: &lt;http://www.w3.org/2002/07/owl#&gt; .
@prefix rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#&gt; .
@prefix rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#&gt; .
@prefix xsd: &lt;http://www.w3.org/2001/XMLSchema#&gt; .

&lt;http://cloudsocket.eu/data&gt;
  rdf:type owl:Ontology ;
  owl:imports &lt;http://ikm-group.ch/archimeo/bpaas&gt; ;
  owl:versionInfo "transformed!"^^xsd:string ;
  .
</xsl:text>
		<xsl:apply-templates
			select="//MODEL[@modeltype='Business process diagram (BPMN 2.0)']"
			mode="BPMN" />			
		<xsl:apply-templates
			select="//MODEL[@modeltype='Workflow diagram (BPMN 2.0)']" mode="Workflow" />
		<xsl:apply-templates
			select="//MODEL[@modeltype='Service description model']"
			mode="ServiceDescriptionModel" />
	</xsl:template>

<!-- ============== ==============  Workflow (BPMN 2.0) ============== ==============  -->
	<xsl:template match="MODEL" mode="Workflow">
data:<xsl:value-of select="@id"/>
  rdf:type bpaas:Workflow ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
<xsl:call-template name="elementPostProcessing"/>
	<xsl:apply-templates select=".//INSTANCE[@class='Task']" mode="WorkflowTask" />
	<xsl:apply-templates select=".//INSTANCE[@class='Workflow Annotation Group']" mode="WorkflowAnnotationGroup" />
	<xsl:apply-templates select=".//INSTANCE[@class='Lane']" mode="WorkflowLane" />
	
	</xsl:template>

<!-- ============== Workflow Task ============== -->
	<xsl:template match="INSTANCE" mode="WorkflowTask">
data:<xsl:value-of select="@id"/>
  rdf:type bpaas:WorkflowTask ;
  data:isPartOfWorkflow data:<xsl:value-of select="../@id"/> ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
<xsl:call-template name="elementPostProcessing"/>
	</xsl:template>

<!-- ============== Lane ============== -->
	<xsl:template match="INSTANCE" mode="WorkflowLane">
data:<xsl:value-of select="@id"/>
  rdf:type bpmn:Lane ;
  bpaas:hasReferencedWorkflow data:<xsl:value-of select="../@id"/> ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
  <xsl:apply-templates select="./INTERREF/IREF[@type='objectreference'][@tmodeltype='Service description model']" mode="referencedWorkflowDescription"/>
<xsl:call-template name="elementPostProcessing"/>
	</xsl:template>

<!-- ============== Workflow Annotation Group ============== -->
	<xsl:template match="INSTANCE" mode="WorkflowAnnotationGroup">
data:<xsl:value-of select="@id"/>
  rdf:type bpaas:WorkflowAnnotationGroup ;
  bpaas:hasReferencedWorkflow data:<xsl:value-of select="../@id"/> ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
  <xsl:apply-templates select="./INTERREF/IREF[@type='objectreference'][@tmodeltype='Service description model']" mode="referencedWorkflowDescription"/>
<xsl:call-template name="elementPostProcessing"/>
	</xsl:template>
<xsl:template name="addReferencedWorkflowDescription">		            
<xsl:param name="targetId"/>
bpaas:hasReferencedWorkflowDescription data:<xsl:value-of select="$targetId"/> ;
</xsl:template>	 
<xsl:template match="IREF" mode="referencedWorkflowDescription">
<xsl:call-template name="addReferencedWorkflowDescription">
<xsl:with-param name="targetId" select="//MODEL[@modeltype=current()/@tmodeltype][@name=current()/@tmodelname][@name=current()/@tmodelname]/INSTANCE[@class=current()/@tclassname][@name=current()/@tobjname]/@id" />
</xsl:call-template>
</xsl:template>

<!-- ============== ==============  Service description model ============== ==============  -->
	<xsl:template match="MODEL" mode="ServiceDescriptionModel">
	<xsl:apply-templates select=".//INSTANCE[@class='Business Process Requirement']" mode="BusinessProcessRequirement" />
	<xsl:apply-templates select=".//INSTANCE[@class='Workflow Description']" mode="WorkflowDescription" />
	</xsl:template>

<!-- ============== Workflow Description ============== -->
	<xsl:template match="INSTANCE" mode="WorkflowDescription">
data:<xsl:value-of select="@id"/>
  rdf:type bpaas:WorkflowDescription ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
  <xsl:if test="./ATTRIBUTE[@name='Availability in %'] !='0'">bpaas:hasAvailabilityInPercent <xsl:value-of select="./ATTRIBUTE[@name='Availability in %']"/> ;</xsl:if> 
  <xsl:if test="./ATTRIBUTE[@name='Maximum Simultaneous Service Users'] !='0'">bpaas:hasSimultaneousUsers <xsl:value-of select="./ATTRIBUTE[@name='Maximum Simultaneous Service Users']"/> ;</xsl:if> 
  <xsl:if test="./ATTRIBUTE[@name='Maximum Simultaneous Connections'] !='0'">bpaas:WFDhasMaxiumSimultaneousConnections <xsl:value-of select="./ATTRIBUTE[@name='Maximum Simultaneous Connections']"/> ;</xsl:if>
  <xsl:if test="./ATTRIBUTE[@name='Max Available Data Storage in GB per Month'] !='0'">bpaas:hasDataStorage <xsl:value-of select="./ATTRIBUTE[@name='Max Available Data Storage in GB per Month']"/> ;</xsl:if> 
  <xsl:if test="./ATTRIBUTE[@name='Max Average Response Time'] !='00:000:00:00:00'">bpaas:hasResponseTime  "<xsl:value-of select="substring(./ATTRIBUTE[@name='Max Average Response Time'],8,13)"/>"^^xsd:time ;</xsl:if>
  
  <xsl:if test="./ATTRIBUTE[@name='Type of Encryption Annotation'] !=''">
			<xsl:call-template name="EnumerationListParser">
    			<xsl:with-param name="input" select="concat(./ATTRIBUTE[@name='Type of Encryption Annotation'], ';')"/>
    			<xsl:with-param name="propertyname" select="'bpaas:WFDhasEncryptionType'"/>
    			<xsl:with-param name="objectPrefix" select="''"/>
			</xsl:call-template>
		</xsl:if> 
  
  <xsl:if test="./ATTRIBUTE[@name='Retention Time in Years'] !='0'">bpaas:hasRetentionTimeInYears <xsl:value-of select="./ATTRIBUTE[@name='Retention Time in Years']"/> ;</xsl:if>
  <xsl:if test="./ATTRIBUTE[@name='Retention Time in Months'] !='0'">bpaas:hasRetentionTimeInMonths <xsl:value-of select="./ATTRIBUTE[@name='Retention Time in Months']"/> ;</xsl:if>
  <xsl:if test="./ATTRIBUTE[@name='Retention Time in Weeks'] !='0'">bpaas:hasRetentionTimeInWeeks <xsl:value-of select="./ATTRIBUTE[@name='Retention Time in Weeks']"/> ;</xsl:if>
 
  <xsl:if test="./ATTRIBUTE[@name='Max Restore Time in min'] !='0'">bpaas:hasRestoreTime <xsl:value-of select="./ATTRIBUTE[@name='Max Restore Time in min']"/> ;</xsl:if>

  <xsl:if test="./ATTRIBUTE[@name='Backup Frequency Annotation'] !=''">
			<xsl:call-template name="EnumerationListParser">
    			<xsl:with-param name="input" select="concat(./ATTRIBUTE[@name='Backup Frequency Annotation'], ';')"/>
    			<xsl:with-param name="propertyname" select="'bpaas:hasBackupFrequency'"/>
    			<xsl:with-param name="objectPrefix" select="''"/>
			</xsl:call-template>
		</xsl:if> 
  
  <xsl:if test="./ATTRIBUTE[@name='Offered Payment Plan Annotation'] !=''">
			<xsl:call-template name="EnumerationListParser">
    			<xsl:with-param name="input" select="concat(./ATTRIBUTE[@name='Offered Payment Plan Annotation'], ';')"/>
    			<xsl:with-param name="propertyname" select="'bpaas:hasPaymentPlan'"/>
    			<xsl:with-param name="objectPrefix" select="''"/>
			</xsl:call-template>
		</xsl:if>
  
  <xsl:if test="./ATTRIBUTE[@name='Offered User Target Annotation'] !=''">
			<xsl:call-template name="EnumerationListParser">
    			<xsl:with-param name="input" select="concat(./ATTRIBUTE[@name='Offered User Target Annotation'], ';')"/>
    			<xsl:with-param name="propertyname" select="'bpaas:hasTargetMarket'"/>
    			<xsl:with-param name="objectPrefix" select="''"/>
			</xsl:call-template>
		</xsl:if>
  
  <xsl:if test="./ATTRIBUTE[@name='Data Processing Location Annotation'] !=''">bpaas:refersToALocation <xsl:value-of select="./ATTRIBUTE[@name='Data Processing Location Annotation']"/> ;</xsl:if>
  <xsl:if test="./ATTRIBUTE[@name='Data Storage Location Annotation'] !=''">bpaas:refersToALocation <xsl:value-of select="./ATTRIBUTE[@name='Data Storage Location Annotation']"/> ;</xsl:if>
	
	
	<xsl:if test="./ATTRIBUTE[@name='24/7 Support'] ='false'">
		<xsl:if test="./ATTRIBUTE[@name='Support Days Coverage'] !=''">
			<xsl:call-template name="EnumerationListParser">
    			<xsl:with-param name="input" select="concat(./ATTRIBUTE[@name='Support Days Coverage'], ';')"/>
    			<xsl:with-param name="propertyname" select="'bpaas:SupportServiceHasServiceSupportPeriod'"/>
    			<xsl:with-param name="objectPrefix" select="'bpaas:'"/>
			</xsl:call-template>
			
    			<xsl:if test="./ATTRIBUTE[@name='Support Start Hour'] !=''">bpaas:serviceSupportStartHour  "<xsl:value-of select="substring(./ATTRIBUTE[@name='Support Start Hour'],8,13)"/>"^^xsd:time ;</xsl:if>
    			<xsl:if test="./ATTRIBUTE[@name='Support End Hour'] !='00:000:00:00:00'">bpaas:serviceSupportEndHour  "<xsl:value-of select="substring(./ATTRIBUTE[@name='Support End Hour'],8,13)"/>"^^xsd:time ;</xsl:if>
		</xsl:if> 
	</xsl:if>
	<xsl:if test="./ATTRIBUTE[@name='24/7 Support'] ='true'">
		bpaas:SupportServiceHasServiceSupportPeriod bpaas:24-7 ;
	</xsl:if>
	
	<xsl:call-template name="APQCAnnotation"/>
	<xsl:call-template name="ObjectAnnotation"/>
	<xsl:call-template name="ActionAnnotation"/>
<xsl:call-template name="elementPostProcessing"/>
	</xsl:template>
	
	
<xsl:template name="EnumerationListParser">
    <xsl:param name="input"/>
    <xsl:param name="propertyname"/>
    <xsl:param name="objectPrefix"/>
    <xsl:if test="string-length($input) &gt; 0">
      <xsl:variable name="v" select="substring-before($input, ';')"/>
      <xsl:value-of select="$propertyname"/><xsl:text> </xsl:text><xsl:value-of select=" $objectPrefix"/><xsl:value-of select="$v"/> ;
      <xsl:call-template name="EnumerationListParser">
        <xsl:with-param name="input" select="substring-after($input, ';')"/>
        <xsl:with-param name="propertyname" select="$propertyname"/>
        <xsl:with-param name="objectPrefix" select="$objectPrefix"/>
      </xsl:call-template>
    </xsl:if> 
</xsl:template>


<!-- ============== Business Process Requirement ============== -->
	<xsl:template match="INSTANCE" mode="BusinessProcessRequirement">
data:<xsl:value-of select="@id"/>
  rdf:type bpaas:BusinessProcessRequirement ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
  
  <xsl:if test="./ATTRIBUTE[@name='Downtime in min/month'] !='0'">bpaas:hasDowntimePerMonthInMin <xsl:value-of select="./ATTRIBUTE[@name='Downtime in min/month']"/> ;</xsl:if> 
  
  <xsl:if test="./ATTRIBUTE[@name='Data Location Annotation'] !=''">bpaas:refersToALocation <xsl:value-of select="./ATTRIBUTE[@name='Data Location Annotation']"/> ;</xsl:if>
  <xsl:if test="./ATTRIBUTE[@name='Number of Simultaneous Users'] !='0'">bpaas:hasSimultaneousUsers <xsl:value-of select="./ATTRIBUTE[@name='Number of Simultaneous Users']"/> ;</xsl:if> 
  <xsl:if test="./ATTRIBUTE[@name='Response Time Level'] !=''">bpaas:BPRhasResponseTimeLevel <xsl:value-of select="./ATTRIBUTE[@name='Response Time Level']"/> ;</xsl:if>
  <xsl:if test="./ATTRIBUTE[@name='Payment Plan Annotation'] !=''">bpaas:hasPaymentPlan  <xsl:value-of select="./ATTRIBUTE[@name='Payment Plan Annotation']"/> ;</xsl:if> 
  <xsl:if test="./ATTRIBUTE[@name='What would you like to upload?'] !=''">bpaas:BPRhasMediaType <xsl:value-of select="./ATTRIBUTE[@name='What would you like to upload?']"/> ;</xsl:if> 
  <xsl:if test="./ATTRIBUTE[@name='Number of Process Execution per Year'] !='0'">bpaas:BPRhasNumberOfProcessExecution <xsl:value-of select="./ATTRIBUTE[@name='Number of Process Execution per Year']"/> ;</xsl:if>
  <xsl:if test="./ATTRIBUTE[@name='Access Period'] !=''">bpaas:hasBackupAccessPeriod <xsl:value-of select="./ATTRIBUTE[@name='Access Period']"/> ;</xsl:if>
  
  <xsl:if test="./ATTRIBUTE[@name='Backup Frequency Annotation'] !=''">
			<xsl:call-template name="EnumerationListParser">
    			<xsl:with-param name="input" select="concat(./ATTRIBUTE[@name='Backup Frequency Annotation'], ';')"/>
    			<xsl:with-param name="propertyname" select="'bpaas:hasBackupFrequency'"/>
    			<xsl:with-param name="objectPrefix" select="''"/>
			</xsl:call-template>
		</xsl:if> 
  
  
  
  <xsl:if test="./ATTRIBUTE[@name='Restore Time in min'] !='0'">bpaas:hasRestoreTime <xsl:value-of select="./ATTRIBUTE[@name='Restore Time in min']"/> ;</xsl:if>	
  <xsl:if test="./ATTRIBUTE[@name='Retention Time in Years'] !='0'">bpaas:hasRetentionTimeInYears <xsl:value-of select="./ATTRIBUTE[@name='Retention Time in Years']"/> ;</xsl:if>
  <xsl:if test="./ATTRIBUTE[@name='Retention Time in Months'] !='0'">bpaas:hasRetentionTimeInMonths <xsl:value-of select="./ATTRIBUTE[@name='Retention Time in Months']"/> ;</xsl:if>
  <xsl:if test="./ATTRIBUTE[@name='Retention Time in Weeks'] !='0'">bpaas:hasRetentionTimeInWeeks <xsl:value-of select="./ATTRIBUTE[@name='Retention Time in Weeks']"/> ;</xsl:if>
  <xsl:if test="./ATTRIBUTE[@name='Data Encryption Annotation'] !=''">bpaas:hasEncryptionLevel <xsl:value-of select="./ATTRIBUTE[@name='Data Encryption Annotation']"/> ;</xsl:if> 
 <!-- 
 <xsl:if test="./ATTRIBUTE[@name='User Target Annotation'] !=''">bpaas:hasTargetMarket <xsl:value-of select="./ATTRIBUTE[@name='User Target Annotation']"/> ;</xsl:if>
  -->
 <xsl:if test="./ATTRIBUTE[@name='User Target Annotation'] !=''">
			<xsl:call-template name="EnumerationListParser">
    			<xsl:with-param name="input" select="concat(./ATTRIBUTE[@name='User Target Annotation'], ';')"/>
    			<xsl:with-param name="propertyname" select="'bpaas:hasTargetMarket'"/>
    			<xsl:with-param name="objectPrefix" select="''"/>
			</xsl:call-template>
		</xsl:if> 
 
 <xsl:if test="./ATTRIBUTE[@name='24/7 Support'] ='false'">
		<xsl:if test="./ATTRIBUTE[@name='Support Service'] !=''">
			<xsl:call-template name="EnumerationListParser">
    			<xsl:with-param name="input" select="concat(./ATTRIBUTE[@name='Support Service'], ';')"/>
    			<xsl:with-param name="propertyname" select="'bpaas:BPRhasSupportServicePeriod'"/>
    			<xsl:with-param name="objectPrefix" select="'bpaas:'"/>
			</xsl:call-template>
			
    			<xsl:if test="./ATTRIBUTE[@name='Support Start Hour'] !=''">bpaas:BPRhasSupportStartHour  "<xsl:value-of select="substring(./ATTRIBUTE[@name='Support Start Hour'],8,13)"/>"^^xsd:time ;</xsl:if>
    			<xsl:if test="./ATTRIBUTE[@name='Support End Hour'] !='00:000:00:00:00'">bpaas:BPRhasSupportEndHour  "<xsl:value-of select="substring(./ATTRIBUTE[@name='Support End Hour'],8,13)"/>"^^xsd:time ;</xsl:if>
		</xsl:if> 
	</xsl:if>
	<xsl:if test="./ATTRIBUTE[@name='24/7 Support'] ='true'">
		bpaas:BPRhasSupportServicePeriod bpaas:24-7 ;
	</xsl:if>
 
 
 	
	<xsl:call-template name="APQCAnnotation"/>
	<xsl:call-template name="ObjectAnnotation"/>
	<xsl:call-template name="ActionAnnotation"/>
  
<xsl:call-template name="elementPostProcessing"/>
	</xsl:template>
	
<!-- ============== ==============  Business process diagram (BPMN 2.0) ============== ==============  -->
	<xsl:template match="MODEL" mode="BPMN">
data:<xsl:value-of select="@id"/>
  rdf:type archi:BusinessProcess ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
<xsl:call-template name="elementPostProcessing"/>
	<xsl:apply-templates select=".//INSTANCE[@class='Task']" mode="BusinessProcessTask" />
	<xsl:apply-templates select=".//INSTANCE[@class='Sub-Process']" mode="BusinessProcessSubProcess" />
	<xsl:apply-templates select=".//INSTANCE[@class='Business Process Annotation Group']" mode="BusinessProcessAnnotationGroup" />
	</xsl:template>
	
<!-- ============== Business Process Task ============== -->
	<xsl:template match="INSTANCE" mode="BusinessProcessTask">
data:<xsl:value-of select="@id"/>
  rdf:type bpmn:Task ;
  data:isPartOfBusinessProcess data:<xsl:value-of select="../@id"/> ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
<xsl:call-template name="elementPostProcessing"/>
	</xsl:template>
	
<!-- ============== Business Process Sub-Process ============== -->
	<xsl:template match="INSTANCE" mode="BusinessProcessSubProcess">
data:<xsl:value-of select="@id"/>
  rdf:type bpmn:SubProcess ;
  data:isPartOfBusinessProcess data:<xsl:value-of select="../@id"/> ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
  <xsl:apply-templates select="./INTERREF/IREF[@type='modelreference'][@tmodeltype='Business process diagram (BPMN 2.0)']" mode="referencedSubProcess"/>
<xsl:call-template name="elementPostProcessing"/>
	</xsl:template>
<xsl:template name="addReferencedSubProcessConnection">		            
<xsl:param name="targetId"/>
bpaas:hasReferencedSubBusinessProcess data:<xsl:value-of select="$targetId"/> ;<xsl:text>&#10;</xsl:text>
</xsl:template>	 
<xsl:template match="IREF" mode="referencedSubProcess">
<xsl:call-template name="addReferencedSubProcessConnection">
<xsl:with-param name="targetId" select="//MODEL[@modeltype=current()/@tmodeltype][@name=current()/@tmodelname][@name=current()/@tmodelname][@name=current()/@tmodelname]/@id"/>
</xsl:call-template>
</xsl:template>

<!-- ============== Business Process Annotation Group ============== -->
	<xsl:template match="INSTANCE" mode="BusinessProcessAnnotationGroup">
data:<xsl:value-of select="@id"/>
  rdf:type bpaas:BusinessProcessAnnotationGroup ;
  bpaas:hasReferencedBusinessProcess data:<xsl:value-of select="../@id"/> ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
  <xsl:apply-templates select="./INTERREF/IREF[@type='objectreference'][@tmodeltype='Service description model']" mode="referencedBusinessProcessRequirement"/>
<xsl:call-template name="elementPostProcessing"/>
	</xsl:template>
<xsl:template name="addReferencedBusinessProcessRequirement">		            
<xsl:param name="targetId"/>
bpaas:hasReferencedBusinessProcessRequirement data:<xsl:value-of select="$targetId"/> ;
</xsl:template>	 
<xsl:template match="IREF" mode="referencedBusinessProcessRequirement">
<xsl:call-template name="addReferencedBusinessProcessRequirement">
<xsl:with-param name="targetId" select="//MODEL[@modeltype=current()/@tmodeltype][@name=current()/@tmodelname][@name=current()/@tmodelname]/INSTANCE[@class=current()/@tclassname][@name=current()/@tobjname]/@id" />
</xsl:call-template>
</xsl:template>

<!-- ============== APQC Annotation ============== -->
<xsl:template name="APQCAnnotation">
	<xsl:if test="./ATTRIBUTE[@name='APQC Annotation'] !=''">
  rdf:type <xsl:value-of select="./ATTRIBUTE[@name='APQC Annotation']"/> ;
	</xsl:if> 
</xsl:template>
<!-- ============== Object Annotation ============== -->
<xsl:template name="ObjectAnnotation">
	<xsl:if test="./ATTRIBUTE[@name='Object Annotation'] !=''">
  rdf:type <xsl:value-of select="./ATTRIBUTE[@name='Object Annotation']"/> ;
	</xsl:if> 
</xsl:template>
<!-- ============== Action Annotation ============== -->
<xsl:template name="ActionAnnotation">
	<xsl:if test="./ATTRIBUTE[@name='Action Annotation'] !=''">
  rdf:type <xsl:value-of select="./ATTRIBUTE[@name='Action Annotation']"/> ;
	</xsl:if> 
</xsl:template>

	<!-- ============== Post Processing ============== -->
	<xsl:template name="elementPostProcessing">
		.
	</xsl:template>
</xsl:stylesheet>