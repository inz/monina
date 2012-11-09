/*
 * generated by Xtext
 */
package eu.indenica.config.runtime.generator

import com.google.common.collect.Lists
import com.google.inject.Inject
import eu.indenica.config.runtime.runtime.Action
import eu.indenica.config.runtime.runtime.ActionRef
import eu.indenica.config.runtime.runtime.AdaptationRule
import eu.indenica.config.runtime.runtime.CodeElement
import eu.indenica.config.runtime.runtime.Component
import eu.indenica.config.runtime.runtime.EsperMonitoringQuery
import eu.indenica.config.runtime.runtime.Event
import eu.indenica.config.runtime.runtime.EventAttribute
import eu.indenica.config.runtime.runtime.EventRef
import eu.indenica.config.runtime.runtime.Fact
import eu.indenica.config.runtime.runtime.IndenicaMonitoringQuery
import eu.indenica.config.runtime.runtime.MonitoringQuery
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.common.types.JvmTypeReference
import org.eclipse.xtext.common.types.TypesFactory
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.xbase.compiler.ImportManager
import org.eclipse.xtext.xbase.compiler.StringBuilderBasedAppendable
import org.eclipse.xtext.xbase.compiler.TypeReferenceSerializer
import eu.indenica.config.runtime.runtime.Endpoint
import eu.indenica.config.runtime.runtime.EndpointAddress
import java.util.logging.Logger
import java.util.regex.Pattern
import eu.indenica.config.runtime.runtime.IndenicaMonitoringQuery

class RuntimeGenerator implements IGenerator {
	private static Logger log = Logger::getLogger(typeof(RuntimeGenerator).canonicalName)
	@Inject extension IQualifiedNameProvider
	@Inject extension TypeReferenceSerializer
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		val srcPrefix = "src/main/"
		val javaPrefix = srcPrefix + "java/"
		val resourcePrefix = srcPrefix + "resources/"
		// Generate Java artifacts
		for(e : resource.allContents.toIterable.filter(typeof(CodeElement))) {
			log.info("Generating class for " + e.fullyQualifiedName)
			fsa.generateFile( 
				javaPrefix + e.fullyQualifiedName.toString("/") + ".java",
				e.compile
			)
		}
		
		for(e : resource.allContents.toIterable.filter(typeof(Component))) {
			log.info("Generating files for " + e.fullyQualifiedName)
			fsa.generateFile(
				javaPrefix +
				e.fullyQualifiedName.toString("/") + "ActionEvent.java",
				e.compileActionEvent
			)

			if(e.generateClient) {
				log.info("Generating client for " + e.name)
				fsa.generateFile(
					"clients/" + e.name + "/" + e.name + "EventEmitter.java",
					e.compileClientEmitter
				)				
				fsa.generateFile(
					"clients/" + e.name + "/" + e.name + "ActionReceiver.java",
					e.compileActionReceiver
				)
				fsa.generateFile(
					"clients/" + e.name + "/" + e.name + "client.composite",
					e.compileClientComposite
				)
			}
		}
		
		// TODO: Generate client composite and Launcher.
		
		
		// Generate infrastructure composite
		val queries = Lists::newArrayList(resource.allContents.toIterable.filter(typeof(MonitoringQuery)))
		println("queries: " + queries.size)
		val rules = Lists::newArrayList(resource.allContents.toIterable.filter(typeof(AdaptationRule)))
		println("rules: " + rules.size)
		val components = Lists::newArrayList(resource.allContents.toIterable.filter(typeof(Component)))
		fsa.generateFile(
			resourcePrefix + "runtime.composite", 
			compileRuntimeComposite(queries, rules, components)
		)
		
//		fsa.generateFile(
//			javaPrefix + "eu/indenica/runtime/Launcher.java",
//			compileLauncher
//		)
		
		// Generate launcher pom.xml
		fsa.generateFile(
			"pom.xml",
			compilePom
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
		@javax.xml.bind.annotation.XmlRootElement
		public class «name.toFirstUpper» extends eu.indenica.events.Event {
			«constructor»
			«FOR a : attributes»
				«a.compile(importManager)»
			«ENDFOR»
		}
	'''

	def dispatch body(Action it, ImportManager importManager) '''
		@javax.xml.bind.annotation.XmlRootElement
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
		import eu.indenica.adaptation.Action;
		import eu.indenica.events.ActionEvent;
		
		@javax.xml.bind.annotation.XmlRootElement
		public class «name»ActionEvent extends ActionEvent {
			public «name»ActionEvent(final Action action) {
				super(action);
				eventType = "«name»_action";
			}
		}
	'''

	
	
	/**
	 * Composite file assets
	 */

	 
//	def compile(CompositeElement it) '''
//		«compositeHeader(name)»
//			<component name="«name.toFirstUpper»">
//				«body»
//			</component>
//		</composite>
//	'''
//
//	def dispatch body(MonitoringQuery it) '''
//		<implementation.java class="eu.indenica.monitoring.MonitoringQueryImpl" />
//		<property name="statement">
//			«new EsperMonitoringQueryConverter().convert(it)»
//		</property>
//	'''
//	
//	def dispatch body(AdaptationRule it) '''
//		<implementation.java class="eu.indenica.monitoring.AdaptationRuleImpl" />
//		<propery name="statement">
//			«it»
//		</property>
//	'''
	
	/**
	 * Runtime Composite
	 */
	def compileRuntimeComposite(
		Iterable<MonitoringQuery> queries, Iterable<AdaptationRule> rules,
		Iterable<Component> components
	) '''
		«log.info("Creating runtime composite...")»
		«compositeHeader("runtime")»
			<component name="MonitoringEngine">
				<implementation.java 
					class="eu.indenica.monitoring.esper.EsperMonitoringEngine" />
				<property name="queries" many="true"  type="m:MonitoringQueryImpl">
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
		«log.info("Creating component definition for " + toString)»
		<component name="«name»">
			<implementation.java class="«fullyQualifiedName»" />
			«log.info("Endpoints: " + endpoints.toString)»
			«FOR endpoint : endpoints»
				«endpoint.monitoringReceiverDeclaration»
				«endpoint.adaptationReferenceDeclaration»
			«ENDFOR»
«««			<service name="EventReceiver">
«««				<interface.java interface="eu.indenica.integration.EventReceiver" />
«««				<binding.ws />
«««			</service>
«««			<reference name="adaptationInterface">
«««				<interface.java interface="eu.indenica.integration.AdaptationInterface" />
«««				<binding.ws uri="«hostRef?.host.address.value»" />
«««			</reference>
		</component>
	'''
	
	def monitoringReceiverDeclaration(Endpoint it) {
		if(!isMonitoringEndpoint) {
			log.finer(toString + " is no monitoring event receiver") 
			return ""
		}
		log.info("Generating monitoring receiver for endpoint " + toString)
		'''
			<service name="EventReceiver">
«««				<interface.java interface="eu.indenica.integration.EventReceiver" />
		''' + bindingDeclaration + '''
			</service>
		'''
	}

	def adaptationReferenceDeclaration(Endpoint it) {
		if(!isAdaptationEndpoint) { 
			log.finer(toString + " is no adaptation reference")
			return ""
		}
		log.info("Generating adaptation reference for endpoint " + toString)
		'''				
			<reference name="adaptationInterface">
«««				<interface.java interface="eu.indenica.integration.AdaptationInterface" />
		''' + bindingDeclaration +
		'''
			</reference>
		'''
	}
	
	def String indent(String source) {
		indent(source, "	")
	}

	def String indent(String source, String indent) {
		var result = new StringBuilder
		for(String line : Pattern::compile("^", Pattern::MULTILINE).split(source))
			if(!line.empty) result.append(indent).append(line)
		result.toString
	}
	
	def bindingDeclaration(Endpoint it) {
		switch(address.protocol?.split("[+/]")?.head) {
			case "ws": wsBindingDeclaration 
			case "rest": restBindingDeclaration
			case "jms": jmsBindingDeclaration
			default: wsBindingDeclaration
		}.toString.indent
	}
	
	def wsBindingDeclaration(Endpoint it) '''
		<binding.ws uri="«address.toProtocol("http")»://«address.toURI»" />
	'''
	
	def restBindingDeclaration(Endpoint it) '''
		<!-- TODO: implement rest binding -->
	'''
	
	def jmsBindingDeclaration(Endpoint it) '''
		<binding.jms 
			initialContextFactory="org.apache.activemq.jndi.ActiveMQInitialContextFactory"
			jndiURL="«address.toProtocol("tcp")»://«address.toJndiURI»">
			<destination name="«address.uri»" />
			<tuscany:wireFormat.jmsTextXML />
		</binding.jms>
	'''
	
	def toProtocol(EndpointAddress it, String defaultProtocol) {
		var result = defaultProtocol
		val split = protocol?.split("[+/]") 
		if(split != null && split.size > 1)
			result = split.last
		
		result
	}
	
	def toURI(EndpointAddress it) {
		val endpointHost = (
			if(hostRef != null) hostRef else (eContainer.eContainer as Component).hostRef
		).host 
		var result = endpointHost.address.value
		val rPort = if(port != 0) port else endpointHost.port?.port
		if(rPort != null && rPort != 0) result = result + ":" + rPort
		result = result + uri
		if(params != null) result = result + "?" + params
		result
	}
	
	def toJndiURI(EndpointAddress it) {
		val endpointHost = (
			if(hostRef != null) hostRef else (eContainer.eContainer as Component).hostRef
		).host
		var result = endpointHost.address.value
		var rPort = if(port != 0) port else endpointHost.port?.port
		if(rPort == 0 && toProtocol('').equals('tcp')) rPort = 61616
		if(rPort != null && rPort != 0) result = result + ":" + rPort
		result
	}
	
	def isMonitoringEndpoint(Endpoint it) {
		if(elements.filter(typeof(EventRef)).size > 0) { 
			return true
		}
		if(elements.size == 0 && 
			(eContainer as Component).elements.filter(typeof(EventRef)).size > 0
		) {
			return true
		}
		return false;
	}
	
	def isAdaptationEndpoint(Endpoint it) {
		if(elements.filter(typeof(ActionRef)).size > 0) { 
			return true
		}
		if(elements.size == 0 && 
			(eContainer as Component).elements.filter(typeof(ActionRef)).size > 0
		) {
			return true
		}
		return false;
	}

	def compileProperty(MonitoringQuery it) '''
		«IF it instanceof IndenicaMonitoringQuery»
		<!-- IndenicaMonitoringQuery support coming up -->
		«ELSE»
		<MonitoringQueryImpl xmlns="">
			«propertyBody»
		</MonitoringQueryImpl>
		«ENDIF»
	'''
	
	def propertyBody(MonitoringQuery it) '''
		«inputEventTypes»
		<statement><![CDATA[
			«new EsperMonitoringQueryConverter().convert(it)»
		]]></statement>
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
	
	def compileProperty(AdaptationRule it) '''
		<!-- TODO (compileProperty) -->
	'''


	/**
	 * Component client generation
	 */
    def compileClientEmitter(Component it) '''
		«val importManager = new ImportManager(true)»
		«val body = componentClientEmitterBody(importManager)»
«««		«IF eContainer != null»
«««			package «eContainer.fullyQualifiedName»;
«««		«ENDIF»

		«IF !importManager.imports.empty»
		«FOR i : importManager.imports»
			import «i»;
		«ENDFOR»

		«ENDIF»
		«body»
    '''
    
    def compileActionReceiver(Component it) '''
		«val importManager = new ImportManager(true)»
		«val body = componentActionReceiverBody(importManager)»
«««		«IF eContainer != null»
«««			package «eContainer.fullyQualifiedName»;
«««		«ENDIF»

		«IF !importManager.imports.empty»
		«FOR i : importManager.imports»
			import «i»;
		«ENDFOR»

		«ENDIF»
		«body»
    '''
    
    def compileClientComposite(Component it) '''
    	«compositeHeader(name + "_client")»
«««    		Add Monitoring and Adaptation components/bindings
    		<component name="EventEmitter">
    			<implementation.java class="«name»EventReceiver" />
    			<reference name="monitoringInterface">
    				<interface.java interface="eu.indenica.integration.EventReceiver" />
    				<binding.ws uri="server-uri" />
    			</reference>
    		</component>
    		
    		<component name="ActionReceiver">
    			<implementation.java class="«name»ActionReceiver" />
    			<service name="AdaptationInterface">
    				<binding.ws uri="«hostRef.host.address.value»" />
    			</service>
    		</component>
    	</composite>
    '''
    
    def componentClientEmitterBody(Component it, ImportManager importManager) '''
    	import eu.indenica.integration.EventReceiver;
    	import eu.indenica.events.Event;
    	import org.osoa.sca.annotations.Reference;
    
    	public class «name»EventEmitter {
    		private EventReceiver monitoringInterface;
    		
    		@Reference
    		public setEventReceiver(EventReceiver monitoringInterface) {
    			this.monitoringInterface = monitoringInterface;
    		}
    		
    		public sendEvent(Event event) {
    			monitoringInterface.receiveEvent(event);
    		}
    	}
    '''
	
	def componentActionReceiverBody(Component it, ImportManager importManager) '''
		import eu.indenica.integration.AdaptationInterface;
		import eu.indenica.adaptation.Action;
		
		public class «name»ActionReceiver implements AdaptationInterface {
			public void performAction(Action action) {
				System.out.println("Performing action: " + action.toString());
			}
			
			public void registerCallback() {}
		}
	'''
	
	def compilePom() '''
		«var id=System::currentTimeMillis»
		<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
			<modelVersion>4.0.0</modelVersion>
		
			<groupId>eu.indenica.runtime</groupId>
			<artifactId>control-infrastructure-«id»</artifactId>
			<version>0.0.1-SNAPSHOT</version>
			<packaging>jar</packaging>
		
			<name>VSP Monitoring and Adaptation Infrastructure</name>
			
			<properties>
				<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
			</properties>
			
		
			«pomDependencies»
			«pomBuildPlugins»
			«pomRepositories»
		</project>
	'''
	def pomDependencies() '''
		<dependencies>
			<dependency>
				<groupId>org.slf4j</groupId>
				<artifactId>slf4j-api</artifactId>
				<version>1.7.2</version>
			</dependency>
			<dependency>
				<groupId>eu.indenica.runtime</groupId>
				<artifactId>core</artifactId>
				<version>0.0.1-SNAPSHOT</version>
			</dependency>
			<dependency>
				<groupId>org.apache.activemq</groupId>
				<artifactId>activemq-core</artifactId>
				<version>5.5.1</version>
			</dependency>
			<dependency>
				<groupId>org.apache.activemq</groupId>
				<artifactId>activemq-optional</artifactId>
				<version>5.5.1</version>
			</dependency>
		</dependencies>
	'''

	
	def pomRepositories() '''
		<repositories>
			<repository>
				<id>maven-repo</id>
				<name>maven-repo</name>
				<url>http://repo2.maven.org/maven2</url>
			</repository>
			<repository>
				<id>jboss-repo</id>
				<name>jboss-repo</name>
				<url>https://repository.jboss.org/nexus</url>
			</repository>
			<repository>
				<id>indenica-tuv-snapshots</id>
				<url>https://raw.github.com/indenicatuv/snapshots/master/</url>
				<snapshots>
					<enabled>true</enabled>
				</snapshots>
			</repository>
			<repository>
				<id>indenica-tuv-releases</id>
				<url>https://raw.github.com/indenicatuv/releases/master/</url>
				<snapshots>
					<enabled>true</enabled>
				</snapshots>
			</repository>
		</repositories>
	'''
		
	def pomBuildPlugins() '''
		<build>
			<plugins>
				<plugin>
					<groupId>org.codehaus.mojo</groupId>
					<artifactId>exec-maven-plugin</artifactId>
					<version>1.2.1</version>
					<executions>
						<execution>
							<goals>
								<goal>java</goal>
							</goals>
						</execution>
					</executions>
					<configuration>
						<mainClass>eu.indenica.runtime.Launch</mainClass>
						<!--
						<arguments>
							<argument>argument1</argument>
						</arguments>
						<systemProperties>
							<systemProperty>
								<key>myproperty</key>
								<value>myvalue</value>
							</systemProperty>
						</systemProperties>
						-->
					</configuration>
				</plugin>
			</plugins>
		</build>
	'''

	/**
	 * Utility methods
	 */
	def tuscanyVersion() { 1 }
	
	def compositeHeader(String compositeName) '''
		<?xml version="1.0" encoding="UTF-8"?>
		«IF tuscanyVersion == 1»
		<composite xmlns="http://www.osoa.org/xmlns/sca/1.0"
				   xmlns:tuscany="http://tuscany.apache.org/xmlns/sca/1.0"
		«ELSEIF tuscanyVersion == 2»
		<composite xmlns="http://docs.oasis-open.org/ns/opencsa/sca/200912"
		           xmlns:tuscany="http://tuscany.apache.org/xmlns/sca/1.1"
		«ENDIF»
				   xmlns:m="http://monitoring.indenica.eu"
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

	def dispatch name(IndenicaMonitoringQuery it) { name }
	def dispatch name(EsperMonitoringQuery it) { name }
	def dispatch name(AdaptationRule it) { name }
	def dispatch name(Fact it) { name }
}
