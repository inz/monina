package eu.indenica.config.runtime.generator.common

import eu.indenica.config.runtime.runtime.IndenicaAdaptationRule
import eu.indenica.config.runtime.runtime.DroolsAdaptationRule
import org.eclipse.xtext.naming.IQualifiedNameProvider
import com.google.inject.Inject
import eu.indenica.config.runtime.runtime.AdaptationRule

class DroolsRuleConverter {
	@Inject extension IQualifiedNameProvider
	
	def dispatch convert(IndenicaAdaptationRule it) '''
		«ruleHead»
		
		// TODO: convert indenica adaptation rule
	'''
	
	def dispatch convert(DroolsAdaptationRule it) '''
		«ruleHead»
		
		rule "«name»"
«««			when, then are in <<statement>>
			«statement»
		end
	'''	
	
	def ruleHead(AdaptationRule it) '''
		package «eContainer.fullyQualifiedName»
		
		«FOR inputFact : sources.map[s | s.fact]»
		«IF eContainer.fullyQualifiedName != inputFact.eContainer.fullyQualifiedName»
		import «inputFact.fullyQualifiedName»
		«ENDIF»
		«ENDFOR»
		import eu.indenica.events.ActionEvent
		
		global eu.indenica.adaptation.AdaptationEngine publisher
	'''
}