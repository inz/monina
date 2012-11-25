package eu.indenica.config.runtime.generator.common

import eu.indenica.config.runtime.runtime.Fact
import org.eclipse.xtext.naming.IQualifiedNameProvider
import com.google.inject.Inject

class EsperFactRuleConverter {
	@Inject extension IQualifiedNameProvider
	
	// TODO: fix!
	def convert(Fact it) '''
		insert into «fullyQualifiedName»
			select * from «source.sources.head.events.head.fullyQualifiedName»;
		select * from «fullyQualifiedName»;
	'''
}