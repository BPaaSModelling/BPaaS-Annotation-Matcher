package ch.fhnw.bpaas.prototype.ui;

import java.util.ArrayList;
import org.apache.jena.query.ParameterizedSparqlString;
import org.apache.jena.query.QuerySolution;
import org.apache.jena.query.ResultSet;
import ch.fhnw.bpaas.prototype.ApplicationFrame;
import ch.fhnw.bpaas.prototype.ontology.OntologyManager;
import ch.fhnw.bpaas.prototype.ui.elements.ComparisonAnalysis;
import ch.fhnw.bpaas.prototype.ui.elements.SemanticObject;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.geometry.Pos;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.TableCell;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.cell.MapValueFactory;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.scene.paint.Color;
import javafx.util.Callback;

public class CenterPane extends BorderPane {

	private ComboBox<SemanticObject> comboBox;
	private ObservableList<SemanticObject> options;
	private ApplicationFrame applicationFrame;
	
	private TableView table;
	
	private OntologyManager ontology;
	private ObservableList<TableColumn> columnList;
	private SemanticObject chosenBusinessProcess;
	
	public CenterPane(ApplicationFrame applicationFrame, OntologyManager ontology) {
		this.applicationFrame = applicationFrame;
		this.ontology = ontology;
		
		setup();
	}

	private void createAndAddTableViewAtCenter() {
		table = new TableView();
        this.setCenter(table);
	}

	private void createAndAddComboBoxAtTop() {
		options = FXCollections.observableArrayList();
		comboBox = new ComboBox<SemanticObject>(options);
		comboBox.valueProperty().addListener(new ChangeListener<SemanticObject>() {
			@Override
			public void changed(ObservableValue<? extends SemanticObject> observable, SemanticObject oldValue,
					SemanticObject newValue) {
				clearTable();
				setSelectedBusinessProcess(newValue);
			}
		});
		Label text = new Label("Select a Business Process: ");
		HBox layout = new HBox();

		layout.setAlignment(Pos.CENTER);
		layout.getChildren().addAll(text, comboBox);
		this.setTop(layout);
	}
	
	public void setup() {
		createAndAddComboBoxAtTop();
		createAndAddTableViewAtCenter();
	}
	
	private void setSelectedBusinessProcess(SemanticObject selectedBusinessProcess) {
		this.chosenBusinessProcess = selectedBusinessProcess;
		
		ArrayList<SemanticObject> workflowList = queryWorkflows();
		ComparisonAnalysis analysisResults = new ComparisonAnalysis(ontology, chosenBusinessProcess, workflowList);
		
		clearBuildAndShowTableColumns(analysisResults);
		fillTableWithData(analysisResults);
	}
	
	private void fillTableWithData(ComparisonAnalysis analysisResults) {
		table.setItems(analysisResults.getAnalysisData());
	}

	private void clearBuildAndShowTableColumns(ComparisonAnalysis analysisResults) {
		clearTable();
		for(SemanticObject bpr : analysisResults.getBusinessProcessRequirements()){
			TableColumn<String, String> temp = new TableColumn<String, String>(bpr.getName());
			temp.setCellValueFactory(new MapValueFactory(bpr.getURI()));
			temp.setCellFactory(new Callback<TableColumn<String, String>, TableCell<String, String>>() {
	            @Override
	            public TableCell<String, String> call(TableColumn<String, String> param) {
	                return new TableCell<String, String>() {
	                    @Override
	                    public void updateItem(String item, boolean empty) {
	                        super.updateItem(item, empty);
	                        if (!isEmpty()) {
	                        	if(item.equals("[]")){
	                        		setText("no match");
	                        		this.setTextFill(Color.WHITE);
		                        	setStyle("-fx-background-color: red");
		                        }else{
		                        	setText(item.replace("[", "").replace("]", ""));
		                        	setStyle("-fx-background-color: green");
		                        }
	                        }
	                    }
	                };
	            }
	        });
			columnList.add(temp);
		}
		table.getColumns().addAll(columnList);
	}

	private ArrayList<SemanticObject> queryWorkflows() {
		ArrayList<SemanticObject> workflowList = new ArrayList<SemanticObject>();
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString();
		queryStr.append("SELECT ?object ?name  WHERE {");
		queryStr.append("?object rdf:type bpaas:Workflow .");
		queryStr.append("?object rdfs:label ?name .");
		queryStr.append("}");

		ResultSet results = ontology.query(queryStr);

		while (results.hasNext()) {
			QuerySolution soln = results.next();
			String name = soln.get("name").toString();
			String uri = soln.get("object").toString();
			workflowList.add(new SemanticObject(uri, name));
			ontology.writeToFile("WF found: " +name +" :: " +uri);
		}
		return workflowList;
	}

	private void clearTable() {
		table.getColumns().clear();
		this.columnList = FXCollections.observableArrayList();
		this.columnList.clear();
		createStandardtableColumn();
	}
	
	private void createStandardtableColumn(){
		TableColumn temp = new TableColumn("Workflow");
		temp.setCellValueFactory(new MapValueFactory("wf"));
		this.columnList.add(temp);
	}
	
	public void addBusinessProcess(SemanticObject object) {
		options.add(object);
	}
}
