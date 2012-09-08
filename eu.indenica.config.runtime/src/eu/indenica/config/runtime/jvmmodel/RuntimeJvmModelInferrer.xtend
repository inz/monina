package eu.indenica.config.runtime.jvmmodel

import com.google.inject.Inject
import eu.indenica.config.runtime.runtime.Action
import eu.indenica.config.runtime.runtime.Event
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder

/**
 * <p>Infers a JVM model from the source model.</p> 
 *
 * <p>The JVM model should contain all elements that would appear in the Java code 
 * which is generated from the source model. Other models link against the JVM model rather than the source model.</p>     
 */
class RuntimeJvmModelInferrer extends AbstractModelInferrer {

    /**
     * convenience API to build and initialize JVM types and their members.
     */
	@Inject extension JvmTypesBuilder
	
	@Inject extension IQualifiedNameProvider

	/**
	 * The dispatch method {@code infer} is called for each instance of the
	 * given element's type that is contained in a resource.
	 * 
	 * @param element
	 *            the model to create one or more
	 *            {@link org.eclipse.xtext.common.types.JvmDeclaredType declared
	 *            types} from.
	 * @param acceptor
	 *            each created
	 *            {@link org.eclipse.xtext.common.types.JvmDeclaredType type}
	 *            without a container should be passed to the acceptor in order
	 *            get attached to the current resource. The acceptor's
	 *            {@link IJvmDeclaredTypeAcceptor#accept(org.eclipse.xtext.common.types.JvmDeclaredType)
	 *            accept(..)} method takes the constructed empty type for the
	 *            pre-indexing phase. This one is further initialized in the
	 *            indexing phase using the closure you pass to the returned
	 *            {@link org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor.IPostIndexingInitializing#initializeLater(org.eclipse.xtext.xbase.lib.Procedures.Procedure1)
	 *            initializeLater(..)}.
	 * @param isPreIndexingPhase
	 *            whether the method is called in a pre-indexing phase, i.e.
	 *            when the global index is not yet fully updated. You must not
	 *            rely on linking using the index if isPreIndexingPhase is
	 *            <code>true</code>.
	 */
//   	def dispatch void infer(Event element, IJvmDeclaredTypeAcceptor acceptor, boolean isPreIndexingPhase) {
//   		acceptor.accept(element.toClass(element.fullyQualifiedName)).initializeLater [
//   			documentation = element.documentation
//			// superTypes += Class<eu::indenica::monitoring::Event>
//   			for(attribute : element.attributes) {
//   				members += attribute.toField(attribute.name, attribute.type)
//   				members += attribute.toSetter(attribute.name, attribute.type)
//   				members += attribute.toGetter(attribute.name, attribute.type)
//   			}
//   		]
//   	}
//   	
//   	def dispatch void infer(Action element, IJvmDeclaredTypeAcceptor acceptor, boolean isPreIndexingPhase) {
//   		acceptor.accept(element.toClass(element.fullyQualifiedName)).initializeLater [
//   			documentation = element.documentation
//   			for(attribute : element.parameters) {
//   				members += attribute.toField(attribute.name, attribute.type)
//   				members += attribute.toSetter(attribute.name, attribute.type)
//   				members += attribute.toGetter(attribute.name, attribute.type)
//   			}
//   		]
//   	}
}

