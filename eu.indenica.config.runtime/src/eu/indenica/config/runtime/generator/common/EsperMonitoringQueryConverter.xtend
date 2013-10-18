package eu.indenica.config.runtime.generator.common

import eu.indenica.config.runtime.runtime.IndenicaMonitoringQuery
import eu.indenica.config.runtime.runtime.EsperMonitoringQuery
import eu.indenica.config.runtime.runtime.EventEmissionDeclaration

class EsperMonitoringQueryConverter {
	def dispatch String convertQuery(EsperMonitoringQuery it) {
		statement
	}
	
	def dispatch String convertQuery(IndenicaMonitoringQuery it) '''
		select «emits.map[e | e.convertQuery].join(', ')»
		
		
	'''
	def dispatch String convertQuery(EventEmissionDeclaration it) '''
		transpose(new «event.name.toFirstUpper»(/* attributes */))
	'''

}