package ch.fhnw.bpaas.prototype.ontology;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;

import org.apache.jena.ontology.OntModel;
import org.apache.jena.ontology.OntModelSpec;
import org.apache.jena.query.ParameterizedSparqlString;
import org.apache.jena.query.Query;
import org.apache.jena.query.QueryExecution;
import org.apache.jena.query.QueryExecutionFactory;
import org.apache.jena.query.QueryFactory;
import org.apache.jena.query.ResultSet;
import org.apache.jena.rdf.model.InfModel;
import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;
import org.apache.jena.riot.Lang;
import org.apache.jena.riot.RDFDataMgr;

import ch.fhnw.bpaas.prototype.GlobalVariable;

public class OntologyManager {

	private OntModel rdfModel;
	private InfModel inferencedModel;
	
	public OntologyManager() {
		setupOntologyEnvironment();
		
	}

	public void setupOntologyEnvironment() {
		rdfModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);
		setNamespaces(rdfModel);
		readExistingModels();
	}

	private void readExistingModels() {
		for(ONTOLOGY ontology : ONTOLOGY.values()){
			System.out.println("loading " +ontology);
			RDFDataMgr.read(rdfModel, this.getClass().getClassLoader().getResourceAsStream(ontology.getRemoteURL()), Lang.TTL);
//			rdfModel.read(ontology.getRemoteURL(),	ontology.getFormat());
			System.out.println(ontology +" loaded.");
		}
		printToFile(rdfModel, GlobalVariable.INITIALMODEL);
	}

	public void setNamespaces(OntModel model) {
		for (NAMESPACE ns : NAMESPACE.values()) {
			model.setNsPrefix(ns.getPrefix(), ns.getURI());
		}
	}

	public ResultSet query(ParameterizedSparqlString queryStr) {
		addNamespacesToQuery(queryStr);

		System.out.println(queryStr.toString());

		writeToFile(queryStr.toString());
		Query query = QueryFactory.create(queryStr.toString());
		QueryExecution qexec = QueryExecutionFactory.create(query, rdfModel);
		
		return qexec.execSelect();
	}

	private void addNamespacesToQuery(ParameterizedSparqlString queryStr) {
		for (NAMESPACE ns : NAMESPACE.values()) {
			queryStr.setNsPrefix(ns.getPrefix(), ns.getURI());
		}
	}

	public void addTransformedData(OntModel value) {
		rdfModel.add(value);
		printToFile(rdfModel, GlobalVariable.TRANSFORMEDMODEL);
	}

	public void printToFile(Model model, String FILENAME) {
		try {
			RDFDataMgr.write(new FileOutputStream(new File(FILENAME)), model, Lang.TTL) ;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}

	public OntModel getModel() {
		return rdfModel;
	}

	//debugging only
	public void writeToFile(String string) {
//		string = string +"\n";
//		try {
//			Files.write(Paths.get(GlobalVariable.OUTPUTFILE), string.getBytes(), StandardOpenOption.APPEND);
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
	}
}
