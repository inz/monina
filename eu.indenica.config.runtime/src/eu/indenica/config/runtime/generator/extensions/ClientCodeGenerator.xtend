package eu.indenica.config.runtime.generator.extensions

import com.google.inject.Inject
import eu.indenica.config.runtime.generator.common.ScaHelper
import eu.indenica.config.runtime.runtime.Component
import org.eclipse.xtext.xbase.compiler.ImportManager

class ClientCodeGenerator {
	@Inject extension ScaHelper
	
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

}