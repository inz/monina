/*
 * generated by Xtext
 */
package eu.indenica.config.runtime.generator

import com.google.common.collect.Lists
import com.google.inject.Inject
import eu.indenica.config.runtime.runtime.Action
import eu.indenica.config.runtime.runtime.AdaptationRule
import eu.indenica.config.runtime.runtime.CodeElement
import eu.indenica.config.runtime.runtime.CompositeElement
import eu.indenica.config.runtime.runtime.EsperMonitoringQuery
import eu.indenica.config.runtime.runtime.Event
import eu.indenica.config.runtime.runtime.EventAttribute
import eu.indenica.config.runtime.runtime.Fact
import eu.indenica.config.runtime.runtime.IndenicaMonitoringQuery
import eu.indenica.config.runtime.runtime.MonitoringQuery
import eu.indenica.monitoring.esper.EsperMonitoringEngine
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.common.types.JvmTypeReference
import org.eclipse.xtext.common.types.TypesFactory
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.xbase.compiler.ImportManager
import org.eclipse.xtext.xbase.compiler.StringBuilderBasedAppendable
import org.eclipse.xtext.xbase.compiler.TypeReferenceSerializer
import eu.indenica.config.runtime.runtime.Component

class RuntimeGenerator implements IGenerator {
	@Inject extension IQualifiedNameProvider
	@Inject extension TypeReferenceSerializer
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		// Generate Java artifacts
		for(e : resource.allContents.toIterable.filter(typeof(CodeElement))) {
			fsa.generateFile(
				e.fullyQualifiedName.toString("/") + ".java",
				e.compile
			)
		}
		
		for(e : resource.allContents.toIterable.filter(typeof(Component))) {
			fsa.generateFile(
				e.fullyQualifiedName.toString("/") + "ActionEvent.java",
				e.compileActionEvent
			)
		}
		
		// Generate composite artifacts
//		for(e : resource.allContents.toIterable.filter(typeof(CompositeElement))) {
//			fsa.generateFile(
//				e.fullyQualifiedName.toString + ".composite",
//				e.compile
//			)
//		}
		
		// Generate infrastructure composite
		val queries = Lists::newArrayList(resource.allContents.toIterable.filter(typeof(MonitoringQuery)))
		println("queries: " + queries.size)
		val rules = Lists::newArrayList(resource.allContents.toIterable.filter(typeof(AdaptationRule)))
		println("rules: " + rules.size)
		val components = Lists::newArrayList(resource.allContents.toIterable.filter(typeof(Component)))
		fsa.generateFile(
			"runtime.composite", 
			compileRuntimeComposite(queries, rules, components)
		)
	}
	
	/**
	 * Java code assets.
	 */		
	def compile(CodeElement it) '''
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
		if(true) throw new RuntimeException("Cannot compile " + toString)
		""
	}
	
	def dispatch body(Event it, ImportManager importManager) '''
		public class «name.toFirstUpper» extends eu.indenica.events.Event {
			«constructor»
			«FOR a : attributes»
				«a.compile(importManager)»
			«ENDFOR»
		}
	'''

	def dispatch body(Action it, ImportManager importManager) '''
		public class «name.toFirstUpper» extends eu.indenica.adaptation.Action {
			«constructor»
			«FOR p : parameters»
				«p.compile(importManager)»
			«ENDFOR»
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
	
	def dispatch body(Component it, ImportManager importManager) '''
		«val relatedClasses = elements.map[e | e.fullyQualifiedName]»
		@javax.xml.bind.annotation.XmlSeeAlso({«relatedClasses.join(", ")»})
		public class «name.toFirstUpper» 
			implements eu.indenica.common.EventListener {
			private eu.indenica.common.PubSub pubSub = 
				eu.indenica.common.PubSubFactory.getPubSub();
			
			// Reference to endpoint for executing actions.
			private eu.indenica.integration.AdaptationInterface adaptationInterface;
			
			@org.osoa.sca.annotations.Reference
			public void setAdaptationInterface(
				AdaptationInterface adaptationInterface) {
				this.adaptationInterface = adaptationInterface;
			}
			
			@org.osoa.sca.annotations.Init
			public void init() {
				pubSub.registerListener(this, null, "«name.toFirstUpper»_action");
				adaptationInterface.registerCallback();
			}
			
			public void eventReceived(RuntimeComponent source, Event event) {
				adaptationInterface.performAction(((ActionEvent) event).getAction());
			}
			
			// receiveEvent dispatch for all event types.
			public void receiveEvent(eu.indenica.monitoring.Event event) {
				pubSub.publish(this, event);
			}
		}
	'''
	
	def CharSequence compileActionEvent(Component it) '''
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
		public class «name.toFirstUpper»ActionEvent extends eu.indenica.events.ActionEvent {
			public «name.toFirstUpper»ActionEvent(final Action action) {
				super(action);
				eventType = "«name.toFirstUpper»_action";
			}
		}
	'''

	
	
	/**
	 * Composite file assets
	 */

	 
	def compile(CompositeElement it) '''
		«compositeHeader(name)»
			<component name="«name.toFirstUpper»">
				«body»
			</component>
		</composite>
	'''

	def dispatch body(MonitoringQuery it) '''
		<implementation.java class="eu.indenica.monitoring.MonitoringQueryImpl" />
		<property name="statement">
			«new EsperMonitoringQueryConverter().convert(it)»
		</property>
	'''
	
	def dispatch body(AdaptationRule it) '''
		<implementation.java class="eu.indenica.monitoring.AdaptationRuleImpl" />
		<propery name="statement">
			«it»
		</property>
	'''
	
	/**
	 * Runtime Composite
	 */
	def compileRuntimeComposite(
		Iterable<MonitoringQuery> queries, Iterable<AdaptationRule> rules,
		Iterable<Component> components
	) '''					
		«compositeHeader("runtime")»
			<component name="MonitoringEngine">
				<implementation.java 
					class="eu.indenica.monitoring.esper.EsperMonitoringEngine" />
				<property name="queries" many="true" type="eu.indenica.monitoring.MonitoringQueryImpl">
					«FOR query : queries»
						«query.compileProperty»
					«ENDFOR»
				</property>
			</component>
			
			<component name="AdaptationEngine">
				<implementation.java 
					class="eu.indenica.adaptation.DroolsAdaptationEngine" />
				<property name="rules" many="true">
					«FOR rule : rules»
						«rule.compileProperty»
					«ENDFOR»
				</property>
			</component>
			
			«FOR component : components»
				«component.componentDefinition»
			«ENDFOR»
		</composite>
	'''
	
	def componentDefinition(Component it) '''
		<component name="«name»">
			<implementation.java class="«fullyQualifiedName»" />
			<service name="«name»">
				<binding.ws />
			</service>
			<reference name="adaptationInterface" target="«host.host.address + endpointAddress.endpointAddress»" />
		</component>
	'''

	def compileProperty(MonitoringQuery it) '''
		<MonitoringQueryImpl xmlns="">
			«propertyBody»
		</MonitoringQueryImpl>
	'''
	
	def propertyBody(MonitoringQuery it) '''
		«inputEventTypes»
		<statement>
			«new EsperMonitoringQueryConverter().convert(it)»
		</statement>
	'''
	
	def dispatch inputEventTypes(IndenicaMonitoringQuery it) '''
		«FOR inputEvent : sources.map[s | s.sources].flatten.map[t | t.events].flatten»
			<inputEventTypes>«inputEvent.fullyQualifiedName»</inputEventTypes>
		«ENDFOR»
	'''
	
	def dispatch inputEventTypes(EsperMonitoringQuery it) '''
		«FOR inputEvent : sources.map[s | s.sources].flatten.map[t | t.events].flatten»
			<inputEventTypes>«inputEvent.fullyQualifiedName»</inputEventTypes>
		«ENDFOR»
	'''
	
	def compileProperty(AdaptationRule rule) { }


	 

	/**
	 * Utility methods
	 */
	def tuscanyVersion() { 1 }
	
	def compositeHeader(String compositeName) '''
		<?xml version="1.0" encoding="UTF-8"?>
		«IF tuscanyVersion == 1»
		<composite xmlns="http://www.osoa.org/xmlns/sca/1.0"
		«ELSEIF tuscanyVersion == 2»
		<composite xmlns="http://docs.oasis-open.org/ns/opencsa/sca/200912"
		           xmlns:tuscany="http://tuscany.apache.org/xmlns/sca/1.1"
		«ENDIF»
		           targetNamespace="http://indenica.eu"
		           name="«compositeName.toFirstLower»-contribution">
	'''
	 
	def shortName(JvmTypeReference reference, ImportManager importManager) {
		val result = new StringBuilderBasedAppendable(importManager)
		reference.serialize(reference.eContainer, result);
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
	
	def createJvmType(String packageName, String className) {
	    val declaredType = TypesFactory::eINSTANCE.createJvmGenericType
	    declaredType.setSimpleName(className)
	    declaredType.setPackageName(packageName)
	    declaredType
	}	
	def dispatch name(CodeElement it) {
		if(true) throw new RuntimeException("Can't get name for " + toString);
		""
	}
	def dispatch name(Event it) { name }
	def dispatch name(Action it) { name }

	def dispatch name(CompositeElement it) {
		if(true) throw new RuntimeException("Can't get name for " + toString);
		""
	}
	def dispatch name(IndenicaMonitoringQuery it) { name }
	def dispatch name(EsperMonitoringQuery it) { name }
	def dispatch name(AdaptationRule it) { name }
	def dispatch name(Fact it) { name }
}
