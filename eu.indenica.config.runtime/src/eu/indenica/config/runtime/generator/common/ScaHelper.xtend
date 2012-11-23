package eu.indenica.config.runtime.generator.common

import java.util.Date

class ScaHelper {
	def tuscanyVersion() { 1 }
	
	def compositeHeader(String compositeName) '''
		<?xml version="1.0" encoding="UTF-8"?>
		<!-- Generated on «new Date().toString» -->
		«IF tuscanyVersion == 1»
		<composite xmlns="http://www.osoa.org/xmlns/sca/1.0"
				   xmlns:tuscany="http://tuscany.apache.org/xmlns/sca/1.0"
		«ELSEIF tuscanyVersion == 2»
		<composite xmlns="http://docs.oasis-open.org/ns/opencsa/sca/200912"
		           xmlns:tuscany="http://tuscany.apache.org/xmlns/sca/1.1"
		«ENDIF»
				   xmlns:m="http://monitoring.indenica.eu"
				   xmlns:a="http://adaptation.indenica.eu"
		           targetNamespace="http://indenica.eu"
		           name="«compositeName.toFirstLower»-contribution">
	'''
}