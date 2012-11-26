package eu.indenica.config.runtime.generator.common

import com.google.inject.Inject
import eu.indenica.config.runtime.runtime.Fact
import org.eclipse.xtext.naming.IQualifiedNameProvider

class EsperFactRuleConverter {
	@Inject extension IQualifiedNameProvider
	
	// TODO: fix!
	def convert(Fact it) '''
		insert into «fullyQualifiedName»
			select «it.attributes» from «it.sources»
		select * from «fullyQualifiedName»;
	'''
	def attributes(Fact it) '''
		«val event = source.sources.head.events.head»
		«FOR attr : event.attributes»
			«attr.name» as «attr.name»
		«ENDFOR»
	'''

	def sources(Fact it) '''
		«source.sources.head.events.head.fullyQualifiedName»;
	'''
}