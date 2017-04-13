package ch.fhnw.bpaas.prototype;

public class GlobalVariable {

	public static final String RESOURCEPATH 						=	"main/resources/";
	public static final String TRANSFORMATIONTEMPLATENAMEANDPATH 	= 	RESOURCEPATH	+	"TransformationTemplate.xsl";
	
	public static final String TRANSFORMEDOUTPUTFILE 				= 	"00_output_transformationData.ttl";
	public static final String INITIALMODEL		 					= 	"01_output_InitialModelData.ttl";
	public static final String TRANSFORMEDMODEL 					= 	"02_output_TransformedData.ttl";
	public static final String INFERENCEDMODEL 						= 	"03_output_InferencedData.ttl";
	
	public static final String INFERENCEDMODELCOMBINED = "04_output_InferencedModelCombined.ttl";
	public static final String OUTPUTFILE = "output.txt";

}
