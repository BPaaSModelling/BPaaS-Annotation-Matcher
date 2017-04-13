package ch.fhnw.bpaas.prototype.ui.elements;

public class SemanticObject {

	private String uri;
	private String name;

	public SemanticObject(String uri, String name) {
		this.uri = uri;
		this.name = name;
	}

	public String getURI() {
		return uri;
	}

	public String getName() {
		return name;
	}
	
	public String toString(){
		return getName();
	}

}
