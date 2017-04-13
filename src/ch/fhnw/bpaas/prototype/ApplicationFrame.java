package ch.fhnw.bpaas.prototype;

import java.io.File;
import org.apache.jena.query.ParameterizedSparqlString;
import org.apache.jena.query.QuerySolution;
import org.apache.jena.query.ResultSet;
import org.controlsfx.glyphfont.FontAwesome;
import org.controlsfx.glyphfont.Glyph;
import ch.fhnw.bpaas.prototype.ontology.OntologyManager;
import ch.fhnw.bpaas.prototype.ui.CenterPane;
import ch.fhnw.bpaas.prototype.ui.UIMode;
import ch.fhnw.bpaas.prototype.ui.elements.SemanticObject;
import javafx.concurrent.Task;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Orientation;
import javafx.scene.control.Button;
import javafx.scene.control.ProgressBar;
import javafx.scene.control.ToolBar;
import javafx.scene.layout.BorderPane;
import javafx.stage.FileChooser;

public class ApplicationFrame extends BorderPane implements EventHandler<ActionEvent> {

	private ToolBar toolBar;
	private Button btnOpenXML;
	private StartPrototype startEnvironment;
	private ProgressBar progressBar = new ProgressBar();
	private OntologyManager ontology;
	private CenterPane centerPanel;

	public ApplicationFrame(StartPrototype startEnvironment, OntologyManager ontology) {
		this.startEnvironment = startEnvironment;
		this.ontology = ontology;
		createAndAddToolBar();
		createAndAddCenterPanel();
	}

	private void createAndAddCenterPanel() {
		this.centerPanel = new CenterPane(this,ontology);
		this.setCenter(centerPanel);
	}

	private void createAndAddToolBar() {
		toolBar = new ToolBar();
		toolBar.setOrientation(Orientation.HORIZONTAL);
		btnOpenXML = new Button("", new Glyph("FontAwesome", FontAwesome.Glyph.FOLDER_OPEN_ALT));
		btnOpenXML.setOnAction(this);

		toolBar.getItems().addAll(btnOpenXML);
		this.setTop(toolBar);
	}

	@Override
	public void handle(ActionEvent event) {
		if (event.getSource() == btnOpenXML) {
			FileChooser fileChooser = new FileChooser();
			fileChooser.setTitle("Open Resource File");
			File file = fileChooser.showOpenDialog(startEnvironment.getStage());
			if (file != null) {
				ontology.setupOntologyEnvironment();
				centerPanel.setup();
				startEnvironment.createAndStartParseTask(file);
			}
		}
	}

	public void bindProgress(Task task) {
		this.setCenter(progressBar);
		progressBar.progressProperty().bind(task.progressProperty());
	}

	public void setUIMode(UIMode value) {
		switch (value) {
		case QUERYBUSINESSPROCESSES:
			unbindTask();
			queryAllBusinessProcessesAndSendToComboBox();
			break;
		case READY:
			this.setCenter(centerPanel);
			break;
		case REASONING:
			unbindTask();
			startEnvironment.createAndStartReasoningTask();
			break;
		default:
			break;
		}
	}

	private void unbindTask() {
		progressBar.progressProperty().unbind();
	}

	private void queryAllBusinessProcessesAndSendToComboBox() {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString();
		queryStr.append("SELECT ?subject ?name  WHERE {");
		queryStr.append("?subject rdf:type archi:BusinessProcess;");
		queryStr.append("rdfs:label ?name .");
		queryStr.append("FILTER NOT EXISTS { ?subject rdf:type bpmn:SubProcess }");
		queryStr.append("}");

		ResultSet results = ontology.query(queryStr);

		while (results.hasNext()) {
			QuerySolution soln = results.next();
			String name = soln.get("name").toString();
			String uri = soln.get("subject").toString();
			
			centerPanel.addBusinessProcess(new SemanticObject(uri, name));
		}
		setUIMode(UIMode.READY);
	}
}
