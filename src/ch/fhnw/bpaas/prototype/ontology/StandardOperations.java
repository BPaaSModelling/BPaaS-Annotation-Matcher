package ch.fhnw.bpaas.prototype.ontology;

public class StandardOperations {
	
	public static String parseRange(String string) {
		return string.split("\\^\\^")[0];
	}

}
