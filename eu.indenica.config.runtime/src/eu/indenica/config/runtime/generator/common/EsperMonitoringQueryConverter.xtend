package eu.indenica.config.runtime.generator.common

import eu.indenica.config.runtime.runtime.IndenicaMonitoringQuery
import eu.indenica.config.runtime.runtime.EsperMonitoringQuery
import eu.indenica.config.runtime.runtime.EventEmissionDeclaration

class EsperMonitoringQueryConverter {
	def dispatch convert(EsperMonitoringQuery it) {
		statement
	}
	
	def dispatch convert(IndenicaMonitoringQuery it) '''
		select «emits.map[e | e.convert].join(', ')»
		
		
	'''
	def dispatch convert(EventEmissionDeclaration it) '''
		transpose(new «event.name.toFirstUpper»(/* attributes */))
	'''

}