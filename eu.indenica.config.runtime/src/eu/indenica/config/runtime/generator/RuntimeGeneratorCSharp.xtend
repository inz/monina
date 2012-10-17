package eu.indenica.config.runtime.generator

import com.google.inject.Inject
import eu.indenica.config.runtime.runtime.Event
import eu.indenica.config.runtime.runtime.EventAttribute
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider

class RuntimeGeneratorCSharp implements IGenerator {
	@Inject extension IQualifiedNameProvider
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		// Generate Java artifacts
		for(e : resource.allContents.toIterable.filter(typeof(Event))) {
			fsa.generateFile(
				e.name.toFirstUpper + ".cs",
				e.compile
			)
		}
	}
	
	
	def compile(Event it) '''
		«IF eContainer != null»
		namespace «eContainer.fullyQualifiedName.toString.toFirstUpper» {
		«ENDIF»

			using System;
			using System.Xml.Serialization;
			
			using Indenica.Events;
			
			«body»
		
		«IF eContainer != null»
		}
		«ENDIF»
		
	'''	
	
	def body(Event it) '''
		[XmlRoot(ElementName = "«name.toFirstLower»"]
		public class «name» : Event {
			public «name»() : base(«fullyQualifiedName») { }
			«FOR a : attributes»
				«a.compile»
			«ENDFOR»
		}
	'''
	
	def compile(EventAttribute it) '''
		[XmlElement(ElementName = "«name»")]
		public /* ADD Type («type») */ «name.toFirstUpper» { get; set; }
	'''

}