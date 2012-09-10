package eu.indenica.config.runtime.tests

import com.google.inject.Inject
import eu.indenica.config.runtime.RuntimeInjectorProvider
import eu.indenica.config.runtime.runtime.AbstractElement
import eu.indenica.config.runtime.runtime.ActionRef
import eu.indenica.config.runtime.runtime.BatchWindow
import eu.indenica.config.runtime.runtime.BinaryExpression
import eu.indenica.config.runtime.runtime.CompareOperator
import eu.indenica.config.runtime.runtime.Component
import eu.indenica.config.runtime.runtime.ComponentElement
import eu.indenica.config.runtime.runtime.ConditionalExpression
import eu.indenica.config.runtime.runtime.EsperMonitoringQuery
import eu.indenica.config.runtime.runtime.Event
import eu.indenica.config.runtime.runtime.EventAttribute
import eu.indenica.config.runtime.runtime.EventEmissionDeclaration
import eu.indenica.config.runtime.runtime.EventRef
import eu.indenica.config.runtime.runtime.EventSource
import eu.indenica.config.runtime.runtime.EventSourceDeclaration
import eu.indenica.config.runtime.runtime.FeatureCall
import eu.indenica.config.runtime.runtime.IndenicaMonitoringQuery
import eu.indenica.config.runtime.runtime.MonitoringConditionDeclaration
import eu.indenica.config.runtime.runtime.MonitoringQuery
import eu.indenica.config.runtime.runtime.NumberLiteral
import eu.indenica.config.runtime.runtime.Operator
import eu.indenica.config.runtime.runtime.RuntimeModel
import eu.indenica.config.runtime.runtime.TimeWindow
import eu.indenica.config.runtime.runtime.UnaryExpression
import eu.indenica.config.runtime.runtime.UnaryOperator
import eu.indenica.config.runtime.runtime.WindowDeclaration
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@InjectWith(typeof(RuntimeInjectorProvider))
@RunWith(typeof(XtextRunner))
class RuntimeDslParserTest {
	@Inject ParseHelper<RuntimeModel> parser
	@Inject extension ValidationTestHelper
	
	@Test
	def void parseRuntimeDsl() {
		val model = parser.parse('''
			event eventOne {
				attr1 : String
			}

			component sOne {
				event eventOne
			}	
		''')
		val e = model.elements.head as Event
		val s = model.elements.get(1) as Component
		assertEquals(s.name, 'sOne')
		assertEquals(e.name, 'eventOne')
		assertSame((s.elements.head as EventRef).event, e)
	}
	
	def String sampleModel() {
				'''
			event EventOne {
				attr1 : String
			}

			event EventTwo {
				attr2 : String
			}
			
			event EventThree {
				attr3 : String
				attrThree : String
				attributeThree : String
			}
			
			action ActionOne {
				attr1 : String
			}
			
			host hostOne {
				address "one"
			}
			
			component sOne {
				event EventOne
				host hostOne
			}
			
			component sTwo {
				event EventOne
				event EventTwo
				action ActionOne
			}
			
			query ruleOne {
				emit EventThree(attr1 * 987 as attr3)
				from source sOne, sTwo event EventOne as event1
				window 10s
				where -2 > attr1
			}
			
			query ruleTwo {
				from sources sOne, sTwo events EventTwo, EventOne
				from source sTwo event EventTwo
				emit EventThree(1234 * 2453 as attrThree)
				window 500
			}
			
			fact factOne {
				from source ruleTwo event EventThree
				by attributeThree
			}
			
			rule ruleOne {
				from factOne
				when EventThree.attr3 = 4 then sTwo ActionOne
			}
		'''
	}
	
	@Test
	def void checkSyntax() {
		val model = sampleModel.checkModel
		
		for(AbstractElement e : model.elements) {
			e.print
		}
	}
	
	def dispatch void print(AbstractElement element) { 
		println("abstract element " + element)
	}

	
	def dispatch void print(Event e) {
		println("event "+ e.name)
		for(ea : e.attributes) ea.print
	}
	
	def dispatch void print(EventAttribute attribute) {
		println("  attribute " + attribute.name + " : " + attribute.type)
	}
	
	def dispatch void print(Component s) {
		println("component " + s.name)
		for(e : s.elements) e.print
	}
	
	def dispatch void print(ComponentElement element) { println(element) }
	def dispatch void print(EventRef ref) {
		println("  event ref " + ref.event.name)
	}
	
	def dispatch void print(ActionRef ref) {
		println("  action ref " + ref.action.name)
	}
	
	def dispatch void print(IndenicaMonitoringQuery query) {
		println("query " + query.name)
		for(s : query.sources) s.print
		println()
		for(e : query.emits) e.print
		query.window?.print
		query.condition?.print
	}
	
	def dispatch void print(EsperMonitoringQuery it) {
		println("esper query " + name)
		println("  " + statement)
	}
	
	def dispatch void print(WindowDeclaration declaration) { 
		print("  window ") 
		declaration.expression.print
	}
	
	def dispatch void print(BatchWindow w) {
		println(w.value + " events")
	}
	
	def dispatch void print(TimeWindow w) {
		println(w.value + " " + w.unit)
	}

	def dispatch void print(MonitoringConditionDeclaration declaration) {
		print("  where ")
		declaration.expression.print
		println()
	}

	def dispatch void print(ConditionalExpression e) {
		print(e)
	}
	
	def dispatch void print(BinaryExpression e) {
		print("(")
		e.leftOperand.print
		print(" ") e.operator.print print(" ")
		e.rightOperand.print
		print(")")
	}
	
	def dispatch void print(Operator o) { print(o.operator) }
	def dispatch void print(CompareOperator o) { print(o.operator) }
	
	def dispatch void print(UnaryExpression e) {
		e.operator.print
		e.operand.print
	}
	
	def dispatch void print(UnaryOperator o) { print(o.operator) }
	
	def dispatch void print(FeatureCall f) {
		print(f.attribute.name)
	}
	
	def dispatch void print(NumberLiteral n) { print(n.value) }
	
	def dispatch void print(EventEmissionDeclaration declaration) {
		print("  emit " + declaration.event.name)
		print("(")
		for(a : declaration.attributes) {
			a.expr.print
			if(a.attribute != null) print(" as " + a.attribute.name)
		} 
		print(")")
		println()
	}

	
	def dispatch void print(EventSourceDeclaration declaration) {
		print("  from ")
		declaration.sources.forEach[s | s.print]
		print(" ")
	}

	def dispatch void print(EventSource source) {
		print("sources ")
		print(source.sources.map[s |
			switch s { 
				Component: (s as Component).name
			    IndenicaMonitoringQuery: (s as IndenicaMonitoringQuery).name
			    EsperMonitoringQuery: (s as EsperMonitoringQuery).name
			    default: s.getClass().getSimpleName()
			}
		].join(", "))
		print(" events ")
		print(source.events.map[e | e.name].join(", "))
		if(source.sourceName != null)
			print(" as " + source.sourceName)
	}
	
	def checkModel(CharSequence prog) {
        val model = parser.parse(prog)
        Assert::assertNotNull(model)
        model.assertNoErrors
        model
    }
}