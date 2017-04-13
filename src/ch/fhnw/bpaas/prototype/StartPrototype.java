package ch.fhnw.bpaas.prototype;
	
import java.io.File;
import ch.fhnw.bpaas.prototype.ontology.OntologyManager;
import ch.fhnw.bpaas.prototype.task.OpenParseAndTransformTask;
import ch.fhnw.bpaas.prototype.task.ReasoningTask;
import ch.fhnw.bpaas.prototype.ui.UIMode;
import javafx.application.Application;
import javafx.concurrent.WorkerStateEvent;
import javafx.event.EventHandler;
import javafx.stage.Stage;
import javafx.scene.Scene;

public class StartPrototype extends Application {
	
	private ApplicationFrame root;
	private Stage primaryStage;
	private OntologyManager ontology;
	
	@Override
	public void start(Stage primaryStage) {
		ontology = new OntologyManager();
		root = new ApplicationFrame(this, ontology);
		this.primaryStage = primaryStage;
				
		try {
			Scene scene = new Scene(root,1200,300);
			primaryStage.setScene(scene);
			primaryStage.show();
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		//for development only
//		createAndStartParseTask(new File("/Users/ben/vmtest/cs/cs_new.xml"));
	}
	
	public static void main(String[] args) {
		launch(args);
	}

	public Stage getStage() {
		return primaryStage;
	}

	public void createAndStartParseTask(File file) {
		OpenParseAndTransformTask task = new OpenParseAndTransformTask(file);
		task.setOnSucceeded(new EventHandler<WorkerStateEvent>() {

			@Override
            public void handle(WorkerStateEvent t) {
            	ontology.addTransformedData(task.getValue());
            	root.setUIMode(UIMode.REASONING);
            }
        });
		new Thread(task).start();
		root.bindProgress(task);
	}

	public void createAndStartReasoningTask() {
		ReasoningTask task = new ReasoningTask(ontology);
		task.setOnSucceeded(new EventHandler<WorkerStateEvent>() {

			@Override
            public void handle(WorkerStateEvent t) {
				ontology.printToFile(ontology.getModel(), GlobalVariable.INFERENCEDMODELCOMBINED);
            	root.setUIMode(UIMode.QUERYBUSINESSPROCESSES);
            }
        });
		root.bindProgress(task);
		new Thread(task).start();
	}
}
