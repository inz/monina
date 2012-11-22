package eu.indenica.config.runtime.generator.common

import org.eclipse.xtext.common.types.TypesFactory

class JvmTypeHelper {
	def createJvmType(String packageName, String className) {
	    val declaredType = TypesFactory::eINSTANCE.createJvmGenericType
	    declaredType.setSimpleName(className)
	    declaredType.setPackageName(packageName)
	    declaredType
	}
}