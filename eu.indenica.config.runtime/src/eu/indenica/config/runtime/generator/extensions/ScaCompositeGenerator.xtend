package eu.indenica.config.runtime.generator.extensions

import com.google.common.collect.Lists
import com.google.inject.Inject
import eu.indenica.config.runtime.generator.common.DroolsRuleConverter
import eu.indenica.config.runtime.generator.common.EsperMonitoringQueryConverter
import eu.indenica.config.runtime.generator.common.ScaHelper
import eu.indenica.config.runtime.runtime.ActionRef
import eu.indenica.config.runtime.runtime.AdaptationRule
import eu.indenica.config.runtime.runtime.Component
import eu.indenica.config.runtime.runtime.Endpoint
import eu.indenica.config.runtime.runtime.EndpointAddress
import eu.indenica.config.runtime.runtime.EsperMonitoringQuery
import eu.indenica.config.runtime.runtime.EventRef
import eu.indenica.config.runtime.runtime.Fact
import eu.indenica.config.runtime.runtime.IndenicaMonitoringQuery
import eu.indenica.config.runtime.runtime.MonitoringQuery
import java.util.logging.Logger
import java.util.regex.Pattern
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.naming.IQualifiedNameProvider

import static eu.indenica.config.runtime.generator.extensions.ScaCompositeGenerator.*
import eu.indenica.config.runtime.generator.common.EsperFactRuleConverter

class ScaCompositeGenerator {
	private static Logger LOG = Logger::getLogger(typeof(ScaCompositeGenerator).canonicalName)
	
	@Inject extension IQualifiedNameProvider
	@Inject extension ScaHelper
	@Inject extension EsperMonitoringQueryConverter
	@Inject extension DroolsRuleConverter
	@Inject extension EsperFactRuleConverter
	
	def compileRuntimeComposite(Resource resource) {
		LOG.info("Compiling runtime composite for " + resource.toString)
		val queries = Lists::newArrayList(resource.allContents.toIterable.filter(typeof(MonitoringQuery)))
		println("queries: " + queries.size)
		val rules = Lists::newArrayList(resource.allContents.toIterable.filter(typeof(AdaptationRule)))
		println("rules: " + rules.size)
		val facts = Lists::newArrayList(resource.allContents.toIterable.filter(typeof(Fact)))
		val components = Lists::newArrayList(resource.allContents.toIterable.filter(typeof(Component)))
		
		compileRuntimeComposite(queries, facts, rules, components)
	}
	
	def compileRuntimeComposite(
		Iterable<MonitoringQuery> queries,
		Iterable<Fact> facts, 
		Iterable<AdaptationRule> rules,
		Iterable<Component> components
	) '''
		«LOG.info("Creating runtime composite...")»
		«compositeHeader("runtime")»
			<component name="MonitoringEngine">
				<implementation.java 
					class="eu.indenica.monitoring.esper.EsperMonitoringEngine" />
				<property name="queries" many="true" type="m:MonitoringQueryImpl">
					«FOR query : queries»
						«query.compileProperty»
					«ENDFOR»
				</property>
			</component>
			
			<component name="FactBase">
				<implementation.java
					class="eu.indenica.adaptation.EsperFactTransformer" />
				<property name="factRules" many="true" type="a:FactRuleImpl">
					«FOR fact : facts»
						«fact.compileProperty»
					«ENDFOR»
				</property>
			</component>
			
			<component name="AdaptationEngine">
				<implementation.java 
					class="eu.indenica.adaptation.drools.DroolsAdaptationEngine" />
				<property name="rules" many="true" type="a:AdaptationRuleImpl">
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
	
	def compileProperty(MonitoringQuery it) '''
		«IF it instanceof IndenicaMonitoringQuery»
		<!-- IndenicaMonitoringQuery support coming up -->
		«ELSE»
		<MonitoringQueryImpl xmlns="">
			«propertyBody»
		</MonitoringQueryImpl>
		«ENDIF»
	'''
	
	def dispatch propertyBody(MonitoringQuery it) '''
		«inputEventTypes»
		<statement><![CDATA[
			«convertQuery(it)»
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
	
	def dispatch inputEventTypes(Fact it) '''
		«FOR inputEvent : source.sources.map[t | t.events].flatten»
			<inputEventTypes>«inputEvent.fullyQualifiedName»</inputEventTypes>
		«ENDFOR»
	'''
	
	def dispatch inputEventTypes(AdaptationRule it) '''
		«FOR inputEvent : sources.map[t | t.fact]»
			<inputEventTypes>«inputEvent.fullyQualifiedName»</inputEventTypes>
		«ENDFOR»
	'''
	
	def compileProperty(Fact it) '''
		<FactRuleImpl xmlns="">
			«propertyBody»
		</FactRuleImpl>
	'''

	def dispatch propertyBody(Fact it) '''
		«inputEventTypes»
		<statement><![CDATA[
			«convert(it)»
		]]></statement>
	'''
	
	def compileProperty(AdaptationRule it) '''
		<AdaptationRuleImpl xmlns="">
			«propertyBody»
		</AdaptationRuleImpl>
	'''
	
	def dispatch propertyBody(AdaptationRule it) '''
		«inputEventTypes»
		<statement><![CDATA[
			«convertRule(it)»
		]]></statement>
	'''
	
		
	def componentDefinition(Component it) '''
		«LOG.info("Creating component definition for " + toString)»
		<component name="«name»">
			<implementation.java class="«fullyQualifiedName»" />
			«LOG.info("Endpoints: " + endpoints.toString)»
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
			LOG.finer(toString + " is no monitoring event receiver") 
			return ""
		}
		LOG.info("Generating monitoring receiver for endpoint " + toString)
		'''
			<service name="EventReceiver">
«««				<interface.java interface="eu.indenica.integration.EventReceiver" />
		''' + bindingDeclaration + '''
			</service>
		'''
	}

	def adaptationReferenceDeclaration(Endpoint it) {
		if(!isAdaptationEndpoint) { 
			LOG.finer(toString + " is no adaptation reference")
			return ""
		}
		LOG.info("Generating adaptation reference for endpoint " + toString)
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
		var rPort = 0
		if(port != 0) rPort = port 
		if(endpointHost.port != null) rPort = endpointHost.port.port
		if(rPort != 0) result = result + ":" + rPort
		result = result + uri
		if(params != null) result = result + "?" + params
		result
	}
	
	def toJndiURI(EndpointAddress it) {
		val endpointHost = (
			if(hostRef != null) hostRef else (eContainer.eContainer as Component).hostRef
		).host
		var result = endpointHost.address.value
		var rPort = 0
		if(port != 0) rPort = port
		if(rPort == 0 && endpointHost.port != null) rPort = endpointHost.port.port
		if(rPort == 0 && toProtocol('').equals('tcp')) rPort = 61616
		if(rPort != 0) result = result + ":" + rPort
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

}