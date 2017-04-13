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
# imports: http://cloudsocket.eu/cloudsocket
# prefix: data

@prefix archi: &lt;http://ikm-group.ch/archiMEO/archimate#&gt; .
@prefix bpaas: &lt;http://cloudsocket.eu/cloudsocket#&gt; .
@prefix bpmn: &lt;http://ikm-group.ch/archiMEO/BPMN#&gt; .
@prefix data: &lt;http://cloudsocket.eu/data#&gt; .
@prefix media-types: &lt;http://www.iana.org/assignments/media-types#&gt; .
@prefix owl: &lt;http://www.w3.org/2002/07/owl#&gt; .
@prefix rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#&gt; .
@prefix rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#&gt; .
@prefix xsd: &lt;http://www.w3.org/2001/XMLSchema#&gt; .

&lt;http://cloudsocket.eu/data&gt;
  rdf:type owl:Ontology ;
  owl:imports &lt;http://cloudsocket.eu/cloudsocket&gt; ;
  owl:versionInfo "transformed!"^^xsd:string ;
  .
</xsl:text>
		<xsl:apply-templates
			select="//MODEL[@modeltype='Business process diagram (BPMN 2.0)']"
			mode="BPMN" />
		<xsl:apply-templates
			select="//MODEL[@modeltype='Workflow diagram (BPMN 2.0)']"
			mode="AWF" />
	</xsl:template>

<!-- ============== ==============  Abstarct Workflow (BPMN 2.0) ============== ==============  -->
	<xsl:template match="MODEL" mode="AWF">
data:<xsl:value-of select="@id"/>
  rdf:type bpaas:AbstractWorkflow ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
.
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Not specified']" mode="WFTask">
		<xsl:with-param name="taskType">Task</xsl:with-param>
		<xsl:with-param name="relatedWorkflow"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Business rule']" mode="WFTask">
		<xsl:with-param name="taskType">BusinessRuleTask</xsl:with-param>
		<xsl:with-param name="relatedWorkflow"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Manual']" mode="WFTask">
		<xsl:with-param name="taskType">ManualTask</xsl:with-param>
		<xsl:with-param name="relatedWorkflow"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Script']" mode="WFTask">
		<xsl:with-param name="taskType">ScriptTask</xsl:with-param>
		<xsl:with-param name="relatedWorkflow"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Service']" mode="WFTask">
		<xsl:with-param name="taskType">ServiceTask</xsl:with-param>
		<xsl:with-param name="relatedWorkflow"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='User']" mode="WFTask">
		<xsl:with-param name="taskType">UserTask</xsl:with-param>
		<xsl:with-param name="relatedWorkflow"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Send']" mode="WFTask">
		<xsl:with-param name="taskType">SendTask</xsl:with-param>
	<xsl:with-param name="relatedWorkflow"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Receive']" mode="WFTask">
		<xsl:with-param name="taskType">ReceiveTask</xsl:with-param>
	<xsl:with-param name="relatedWorkflow"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Call activity']" mode="WFTask">
		<xsl:with-param name="taskType">CallActivity</xsl:with-param>
	<xsl:with-param name="relatedWorkflow"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Data Object']" mode="DataObject"/>
	 
	<xsl:apply-templates select=".//CONNECTOR[@class='Data Association']" mode="FlowElementConnector"/>
	
	</xsl:template>
<!-- ============== Task ============== -->
	<xsl:template match="INSTANCE" mode="WFTask">
	<xsl:param name="taskType"/>
	<xsl:param name="relatedWorkflow"/>
data:<xsl:value-of select="@id"/>
  rdf:type bpmn:<xsl:value-of select="$taskType"/> ;
  bpaas:taskIsContainedInWorkflow data:<xsl:value-of select="$relatedWorkflow"/> ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
<xsl:call-template name="elementPostProcessing"/>
	</xsl:template>
	
<!-- ============== ============== Business process diagram (BPMN 2.0) ============== ============== -->
	<xsl:template match="MODEL" mode="BPMN">
data:<xsl:value-of select="@id"/>
  rdf:type archi:BusinessProcess ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
.
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Not specified']" mode="Task">
		<xsl:with-param name="taskType">Task</xsl:with-param>
		<xsl:with-param name="relatedProcess"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Business rule']" mode="Task">
		<xsl:with-param name="taskType">BusinessRuleTask</xsl:with-param>
		<xsl:with-param name="relatedProcess"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Manual task']" mode="Task">
		<xsl:with-param name="taskType">ManualTask</xsl:with-param>
		<xsl:with-param name="relatedProcess"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Script task']" mode="Task">
		<xsl:with-param name="taskType">ScriptTask</xsl:with-param>
		<xsl:with-param name="relatedProcess"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Service task']" mode="Task">
		<xsl:with-param name="taskType">ServiceTask</xsl:with-param>
		<xsl:with-param name="relatedProcess"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='User task']" mode="Task">
		<xsl:with-param name="taskType">UserTask</xsl:with-param>
		<xsl:with-param name="relatedProcess"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Send']" mode="Task">
		<xsl:with-param name="taskType">SendTask</xsl:with-param>
	<xsl:with-param name="relatedProcess"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Receive']" mode="Task">
		<xsl:with-param name="taskType">ReceiveTask</xsl:with-param>
	<xsl:with-param name="relatedProcess"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Task'][./ATTRIBUTE[@name='Task type']='Call activity']" mode="Task">
		<xsl:with-param name="taskType">CallActivity</xsl:with-param>
	<xsl:with-param name="relatedProcess"><xsl:value-of select="@id"/></xsl:with-param>
	</xsl:apply-templates>
	<xsl:apply-templates select=".//INSTANCE[@class='Data Object']" mode="DataObject"/>
	
	<xsl:apply-templates select=".//CONNECTOR[@class='Data Association']" mode="FlowElementConnector"/>
	
	</xsl:template>
<!-- ============== Task ============== -->
	<xsl:template match="INSTANCE" mode="Task">
	<xsl:param name="taskType"/>
	<xsl:param name="relatedProcess"/>
data:<xsl:value-of select="@id"/>
  rdf:type bpmn:<xsl:value-of select="$taskType"/> ;
  bpaas:taskIsContainedInProcess data:<xsl:value-of select="$relatedProcess"/> ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
<xsl:call-template name="elementPostProcessing"/>
	</xsl:template>
	
	
	
<!-- ~~~~~~~~~~~~~~~~~~~~~~~~ GENERIC TEMPLATES ~~~~~~~~~~~~~~~~~~~~~~~~ -->
<!-- ============== Connector ============== -->
	<xsl:template match="CONNECTOR" mode="FlowElementConnector">

data:<xsl:value-of select="@id"/>
  rdf:type bpmn:DataAssociation ;
  rdfs:label "Connector from <xsl:value-of select="./FROM/@instance"/> to <xsl:value-of select="./TO/@instance"/>"^^xsd:string ;
  bpaas:fromFlowElement data:<xsl:value-of select="..//INSTANCE[@name=current()/FROM/@instance and @class=current()/FROM/@class]/@id"/>;
  bpaas:toFlowElement data:<xsl:value-of select="..//INSTANCE[@name=current()/TO/@instance and @class=current()/TO/@class]/@id"/>;
<xsl:call-template name="elementPostProcessing"/>
	</xsl:template>
	
<!-- ============== Data Input ============== -->
	<xsl:template match="INSTANCE" mode="DataObject">
	
data:<xsl:value-of select="@id"/>
  rdf:type media-types:<xsl:value-of select=".//ATTRIBUTE[@name='Media Type']"/> ;
  rdfs:label "<xsl:value-of select="@name"/>"^^xsd:string ;
<xsl:call-template name="elementPostProcessing"/>
	</xsl:template>
<xsl:template name="elementPostProcessing">.</xsl:template>
</xsl:stylesheet>