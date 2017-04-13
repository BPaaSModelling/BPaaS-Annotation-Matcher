import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import org.apache.jena.ontology.OntModel;
import org.apache.jena.ontology.OntModelSpec;
import org.apache.jena.query.ParameterizedSparqlString;
import org.apache.jena.query.Query;
import org.apache.jena.query.QueryExecution;
import org.apache.jena.query.QueryExecutionFactory;
import org.apache.jena.query.QueryFactory;
import org.apache.jena.query.QuerySolution;
import org.apache.jena.query.ResultSet;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;
import org.apache.jena.riot.Lang;
import org.apache.jena.riot.RDFDataMgr;
import org.topbraid.spin.inference.SPINInferences;
import org.topbraid.spin.system.SPINModuleRegistry;

import ch.fhnw.bpaas.prototype.GlobalVariable;

public class InferencingTestMain {
	
	private OntModel model;

	public InferencingTestMain(){
		model = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);
		model.read("/Users/ben/Documents/workspaces2/master/CloudSocketAlignmentPrototype/ontologies/bpaas.ttl", "TTL");
		model.read(GlobalVariable.TRANSFORMEDOUTPUTFILE, "TTL");
//		model.read("https://raw.githubusercontent.com/ikm-group/ArchiMEO/master/ARCHIMEO/BPMN/BPMN.ttl", "TTL");
//		model.read("https://raw.githubusercontent.com/ikm-group/ArchiMEO/master/ARCHIMEO/ARCHIMATE/ArchiMate.ttl", "TTL");
//		model.read("https://raw.githubusercontent.com/ikm-group/ArchiMEO/master/ARCHIMEO/ARCHIMATE/ArchiMate.ttl", "TTL");
//		model.read("https://raw.githubusercontent.com/ikm-group/ArchiMEO/master/ARCHIMEO/TOP/TOP.ttl", "TTL");
		
		model.setNsPrefix("bpaas", "http://ikm-group.ch/archimeo/bpaas#");
		model.setNsPrefix("archi", "http://ikm-group.ch/archiMEO/archimate#");
		model.setNsPrefix("bpmn", "http://ikm-group.ch/archiMEO/BPMN#");
		model.setNsPrefix("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
		model.setNsPrefix("bpaasrules", "http://ikm-group.ch/archimeo/BPAASRULES#");
		model.setNsPrefix("data", "http://cloudsocket.eu/data#");
		model.setNsPrefix("top", "http://ikm-group.ch/archiMEO/top#");
		
		printToFile(model, "help.txt");
		
		 OntModel inferedModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);
	        inferedModel.setNsPrefix("bpaas", "http://ikm-group.ch/archimeo/bpaas#");
	        inferedModel.setNsPrefix("archi", "http://ikm-group.ch/archiMEO/archimate#");
	        inferedModel.setNsPrefix("bpmn", "http://ikm-group.ch/archiMEO/BPMN#");
	        inferedModel.setNsPrefix("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
	        inferedModel.setNsPrefix("bpaasrules", "http://ikm-group.ch/archimeo/BPAASRULES#");
	        inferedModel.setNsPrefix("data", "http://cloudsocket.eu/data#");
		
		SPINModuleRegistry.get().init();
       
        
        model.addSubModel(inferedModel);
        SPINModuleRegistry.get().registerAll(model, null);
        SPINInferences.run(model, inferedModel, null, null, true, null);
        
        query("archi:BusinessProcess");
        query("bpmn:SubProcess");
        
        query("bpaas:Workflow");
        query("bpaasrules:BusinessProcessAsAServiceRules");
        
        query("bpaas:Cat1");
        query("bpaas:Cat2");
	}
	
	public void printToFile(Model model, String FILENAME) {
		try {
			RDFDataMgr.write(new FileOutputStream(new File(FILENAME)), model, Lang.TTL) ;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}

	private void query(String string) {
		System.out.println("========" +string +"=======");

		ParameterizedSparqlString queryStr = new ParameterizedSparqlString();
		queryStr.append("SELECT ?item WHERE {");
		queryStr.append("?item rdf:type "+string +" .");
		queryStr.append("}");
		queryStr.setNsPrefix("bpaas", "http://ikm-group.ch/archimeo/bpaas#");
		queryStr.setNsPrefix("archi", "http://ikm-group.ch/archiMEO/archimate#");
		queryStr.setNsPrefix("bpmn", "http://ikm-group.ch/archiMEO/BPMN#");
		queryStr.setNsPrefix("rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
		queryStr.setNsPrefix("bpaasrules", "http://ikm-group.ch/archimeo/BPAASRULES#");
		queryStr.setNsPrefix("data", "http://cloudsocket.eu/data#");


		Query query = QueryFactory.create(queryStr.toString());
		QueryExecution qexec = QueryExecutionFactory.create(queryStr.toString(), model);
		
		ResultSet results = qexec.execSelect();

		while (results.hasNext()) {
			QuerySolution soln = results.next();
			String name = soln.get("item").toString();
			
			System.out.println(name);
		}
		
	}

	public static void main(String[] args) {
		new InferencingTestMain();

	}

}
