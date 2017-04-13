package ch.fhnw.bpaas.prototype.ui.elements;

public class Attribute {

	private String property;
	private String value;

	public Attribute(String property, String value) {
		this.property = property;
		this.value = value;
	}

	public String getProperty() {
		return property;
	}

	public String getValue() {
		return value;
	}
	
	public String toString(){
		return "property: " +property +" value: " +value +"\n";
	}

}
