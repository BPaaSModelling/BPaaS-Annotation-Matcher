package ch.fhnw.bpaas.prototype.task;

import java.io.File;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.apache.jena.ontology.OntModel;
import org.apache.jena.rdf.model.ModelFactory;
import ch.fhnw.bpaas.prototype.GlobalVariable;
import javafx.concurrent.Task;

public class OpenParseAndTransformTask extends Task<OntModel> {

	private File file;
	private OntModel rdfData;

	private int MAX = 2;
	private int CURRENT = 1;

	public OpenParseAndTransformTask(File file) {
		rdfData = ModelFactory.createOntologyModel();
		this.file = file;
	}

	@Override
	protected OntModel call() throws Exception {
		nextTask();
		updateMessage("Parsing and transforming file");

		TransformerFactory factory = TransformerFactory.newInstance();
        Source xslt = new StreamSource(this.getClass().getClassLoader().getResourceAsStream(GlobalVariable.TRANSFORMATIONTEMPLATENAMEANDPATH));
        Transformer transformer = factory.newTransformer(xslt);

		Source text = new StreamSource(file);
		transformer.transform(text, new StreamResult(new File(GlobalVariable.TRANSFORMEDOUTPUTFILE)));

		nextTask();
		updateMessage("adding to ontology");

		try {
			rdfData.read(GlobalVariable.TRANSFORMEDOUTPUTFILE, "TTL");
		} finally {

		}

		return rdfData;
	}

	private void nextTask() {
//		updateProgress(CURRENT++, MAX);
		updateProgress(-1, -1);
	}

	@Override
	protected void succeeded() {
		super.succeeded();
		updateMessage("Done!");
	}

}