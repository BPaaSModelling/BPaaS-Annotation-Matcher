import java.text.MessageFormat;

import ch.fhnw.bpaas.prototype.ontology.FilterAttributes;

public class mainTest {

	public static void main(String[] args) {
//		String a = "http://ikm-group.ch/archimeo/fbpdo#Define";
//		
//		String[] b = a.split("/");
//		
//		System.out.println(b[b.length-1].replace("#",":"));
		
		
//		MessageFormat.format
		
		
		if(FilterAttributes.contains("http://ikm-group.ch/archimeo/bpaas#hasAvailabilityInPercent")){
			
			FilterAttributes a = FilterAttributes.get("http://ikm-group.ch/archimeo/bpaas#hasAvailabilityInPercent");
			a.getVariable();
			
			System.out.println(MessageFormat.format(a.getComparison(), "90"));
		}

	}

}
