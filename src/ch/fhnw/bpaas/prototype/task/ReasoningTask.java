package ch.fhnw.bpaas.prototype.task;

import org.apache.jena.ontology.OntModelSpec;
import org.apache.jena.rdf.model.InfModel;
import org.apache.jena.rdf.model.ModelFactory;
import org.topbraid.spin.inference.SPINInferences;
import org.topbraid.spin.system.SPINModuleRegistry;

import ch.fhnw.bpaas.prototype.GlobalVariable;
import ch.fhnw.bpaas.prototype.ontology.OntologyManager;
import javafx.concurrent.Task;

public class ReasoningTask extends Task<Void> {

	private OntologyManager ontology;
//	private InfModel inferedModel;
	private InfModel inferedModel;

	public ReasoningTask(OntologyManager ontology) {
		this.ontology = ontology;
	}

	@Override
	protected Void call() /* throws Exception */ {
		updateProgress(-1, -1);
		updateMessage("Applying Reasoning Rules");
		try {
			inferedModel = ModelFactory.createOntologyModel(OntModelSpec.OWL_MEM);
//			inferedModel = ModelFactory.createOntologyModel(OntModelSpec.RDFS_MEM_RDFS_INF);
		    SPINModuleRegistry.get().init();
		    ontology.getModel().addSubModel(inferedModel);
		    
		    SPINModuleRegistry.get().registerAll(ontology.getModel(), null);
			SPINInferences.run(ontology.getModel(), inferedModel, null, null, true, null);
			
			//Workaround: will be replaced by SPIN Rules			
//			Reasoner reasoner = new GenericRuleReasoner(Rule.rulesFromURL("src/main/resources/rules.ttl"));
//			reasoner.setDerivationLogging(true);
//			
//			inferedModel = ModelFactory.createInfModel(reasoner, ontology.getModel());
//			ontology.setInfModel(inferedModel);
			
//			ontology.startInferencing();

			ontology.printToFile(inferedModel, GlobalVariable.INFERENCEDMODEL);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	@Override
	protected void succeeded() {
		super.succeeded();
		updateMessage("Done!");
	}
}
