package eu.indenica.config.runtime.generator.extensions

import com.google.inject.Inject
import eu.indenica.config.runtime.runtime.Action
import eu.indenica.config.runtime.runtime.CodeElement
import eu.indenica.config.runtime.runtime.Component
import eu.indenica.config.runtime.runtime.Event
import eu.indenica.config.runtime.runtime.EventAttribute
import org.eclipse.xtext.common.types.JvmTypeReference
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.xbase.compiler.ImportManager
import org.eclipse.xtext.xbase.compiler.StringBuilderBasedAppendable
import org.eclipse.xtext.xbase.compiler.TypeReferenceSerializer
import eu.indenica.config.runtime.generator.common.JvmTypeHelper
import java.util.logging.Logger
import eu.indenica.config.runtime.runtime.EventRef
import eu.indenica.config.runtime.runtime.ActionRef

class CodeElementGenerator {
	private static Logger LOG = Logger::getLogger(typeof(CodeElementGenerator).canonicalName)
	
	@Inject extension IQualifiedNameProvider
	@Inject extension TypeReferenceSerializer
	@Inject extension JvmTypeHelper
	
	/**
	 * Java code assets.
	 */		
	def compile(CodeElement it) '''
		«LOG.info("Generating class content for " + toString)»
		«val importManager = new ImportManager(true, createJvmType)»
		«val body = body(importManager)»
		«IF eContainer != null»
			package «eContainer.fullyQualifiedName»;
		«ENDIF»

		«IF !importManager.imports.empty»
		«FOR i : importManager.imports»
			import «i»;
		«ENDFOR»

		«ENDIF»
		«body»
	'''
	
	def dispatch body(CodeElement it, ImportManager importManager) {
		LOG.warning("Cannot compile " + toString);
		if(true) throw new RuntimeException("Cannot compile " + toString)
		""
	}
	
	def dispatch body(Event it, ImportManager importManager) '''
		@javax.xml.bind.annotation.XmlRootElement
		public class «name.toFirstUpper» extends eu.indenica.events.Event {
			«addLogger»
			
			«constructor»
			«FOR a : attributes»
				«a.compile(importManager)»
			«ENDFOR»
		}
	'''

	def dispatch body(Action it, ImportManager importManager) '''
		@javax.xml.bind.annotation.XmlRootElement
		public class «name.toFirstUpper» extends eu.indenica.adaptation.Action {
			«addLogger»
			
			«constructor»
			«FOR p : parameters»
				«p.compile(importManager)»
			«ENDFOR»
		}
	'''
	
	def allElements(Component it) { 
		elements + endpoints.map[elements].flatten
	}
	
	def events(Component it) {
		allElements.filter(typeof(EventRef)).map[e | e.event]
	}
	
	def actions(Component it) {
		allElements.filter(typeof(ActionRef)).map[a | a.action]
	}
	
	def dispatch body(Component it, ImportManager importManager) '''
		«val eventClasses = events.map[e | e.fullyQualifiedName.toString + ".class"]»
		«val actionClasses = actions.map[e | e.fullyQualifiedName.toString + ".class"]»
		import eu.indenica.common.EventListener;
		import eu.indenica.common.RuntimeComponent;
		import eu.indenica.common.PubSub;
		import eu.indenica.common.PubSubFactory;
		import eu.indenica.events.Event;
		import eu.indenica.events.ActionEvent;
		import eu.indenica.integration.AdaptationInterface;
		import eu.indenica.integration.EventReceiver;
		
		@javax.xml.bind.annotation.XmlSeeAlso({«(eventClasses + actionClasses).join(", ")»})
		public class «name» implements EventReceiver, EventListener, RuntimeComponent {
			«addLogger»
			private PubSub pubSub = PubSubFactory.getPubSub();
			
			private AdaptationInterface adaptationInterface;
			
			@org.osoa.sca.annotations.Reference
			public void setAdaptationInterface(AdaptationInterface adaptationInterface) {
				this.adaptationInterface = adaptationInterface;
			}
			
			@org.osoa.sca.annotations.Init
			public void init() {
				pubSub.registerListener(this, null, "«name»_action");
				adaptationInterface.registerCallback();
			}
			
			@org.osoa.sca.annotations.Destroy
			public void destroy() {
				// Maybe de-register callback at component?
			}
			
			public void eventReceived(RuntimeComponent source, Event event) {
				adaptationInterface.performAction(((ActionEvent) event).getAction());
			}
			
			// receiveEvent dispatch for all event types.
			public void receiveEvent(Event event) {
				pubSub.publish(this, event);
			}
		}
	'''
	
	def compile(EventAttribute it, ImportManager importManager) '''
		«val shortType = type.shortName(importManager)»
		
		private «shortType» «name»;
		
		public «shortType» get«name.toFirstUpper»() {
			return «name»;
		}
		
		public void set«name.toFirstUpper»(final «shortType» «name») {
			this.«name» = «name»;
		}
	'''
	
	def dispatch constructor(Event it) '''
		public «name.toFirstUpper»() {
			super("«fullyQualifiedName»");
		}
	'''
	
	def dispatch constructor(Action it) '''
	'''
	
	
	def CharSequence compileActionEvent(Component it) '''
		«LOG.info("Compiling action event for " + toString)»
		«val importManager = new ImportManager(true, createJvmType)»
		«val body = componentActionEventBody(importManager)»
		«IF eContainer != null»
			package «eContainer.fullyQualifiedName»;
		«ENDIF»

		«IF !importManager.imports.empty»
		«FOR i : importManager.imports»
			import «i»;
		«ENDFOR»

		«ENDIF»
		«body»
	'''
	
	def componentActionEventBody(Component it, ImportManager manager) '''
		import eu.indenica.adaptation.Action;
		import eu.indenica.events.ActionEvent;
		
		@javax.xml.bind.annotation.XmlRootElement
		public class «name»ActionEvent extends ActionEvent {
			«addLogger»
			public «name»ActionEvent(final Action action) {
				super(action);
				eventType = "«name»_action";
			}
		}
	'''
	
	def addLogger() '''
		private final static org.slf4j.Logger LOG = eu.indenica.common.LoggerFactory.getLogger();
	'''
	
	def shortName(JvmTypeReference reference, ImportManager importManager) {
		val result = new StringBuilderBasedAppendable(importManager)
		reference.serialize(reference.eContainer, result)
		result.toString
	}
	
	def dispatch createJvmType(CodeElement element) {
		createJvmType(
			element.eContainer.fullyQualifiedName.toString, 
			element.name
		)
	}
	
	def dispatch createJvmType(Component element) {
		createJvmType(
			element.eContainer.fullyQualifiedName.toString, 
			element.name
		)
	}
	
	def dispatch name(CodeElement it) {
		if(true) throw new RuntimeException("Can't get name for " + toString);
		""
	}
	def dispatch name(Event it) { name }
	def dispatch name(Action it) { name }
}