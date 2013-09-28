package eu.indenica.config.runtime.generator.common

import com.google.inject.Inject
import eu.indenica.config.runtime.runtime.AdaptationRule
import eu.indenica.config.runtime.runtime.BinaryExpression
import eu.indenica.config.runtime.runtime.DroolsAdaptationRule
import eu.indenica.config.runtime.runtime.IndenicaAdaptationRule
import org.eclipse.xtext.naming.IQualifiedNameProvider
import eu.indenica.config.runtime.runtime.UnaryExpression
import eu.indenica.config.runtime.runtime.BooleanLiteral
import eu.indenica.config.runtime.runtime.NumberLiteral
import eu.indenica.config.runtime.runtime.NullLiteral
import eu.indenica.config.runtime.runtime.StringLiteral
import eu.indenica.config.runtime.runtime.FeatureCall
import eu.indenica.config.runtime.runtime.Operator
import eu.indenica.config.runtime.runtime.EqualityOperator
import eu.indenica.config.runtime.runtime.AdaptationStatement
import eu.indenica.config.runtime.runtime.ActionExpression

class DroolsRuleConverter {
	@Inject extension IQualifiedNameProvider
	
	def dispatch convertRule(IndenicaAdaptationRule it) '''
		«ruleHead»
		
		«FOR stmt : stmts»
			rule "«name»_«stmt.fullyQualifiedName»"
			«stmt.convert»
		«ENDFOR»
	'''
	
	def dispatch convertRule(DroolsAdaptationRule it) '''
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
		
		global eu.indenica.adaptation.AdaptationEngine engine
	'''
	
	def dispatch convert(AdaptationStatement it) '''
		when «convert(conditon)» then «convert(action)»
	'''
	
	def dispatch convert(BinaryExpression it) '''
		«convert(leftOperand)» «convert(operator)» «convert(rightOperand)»
	'''
	
	def dispatch convert(UnaryExpression it) '''
		«convert(operator)»«convert(operand)»
	'''
	
	/* Operators */
	def dispatch convert(EqualityOperator it) { 
		if(operator == "=") "==" else "!="
	}
	// TODO: convert to correct drools representation!
	// see http://docs.jboss.org/drools/release/5.2.0.Final/drools-expert-docs/html/ch05.html#d0e2785
	def dispatch convert(Operator it) { operator }
	
	/* Primary Expressions */
	
	def dispatch convert(FeatureCall it) { attribute.name }
	
	/* Literals  */
	
	def dispatch convert(BooleanLiteral it) { if(isTrue) "true" else "false" }
	def dispatch convert(NumberLiteral it) { value }
	def dispatch convert(NullLiteral it) { "null" }
	def dispatch convert(StringLiteral it) { value }
//	def dispatch convert(IvmlReference it) {
//		// TODO: resolve ivml reference!
//		ref
//	}
	
	/* Action Expression */
	def dispatch convert(ActionExpression it) '''
		//TODO: convert action expression!
	'''
}