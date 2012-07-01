package eu.indenica.config.runtime.tests

import com.google.inject.Inject
import eu.indenica.config.runtime.RuntimeInjectorProvider
import eu.indenica.config.runtime.runtime.RuntimeModel
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith
import eu.indenica.config.runtime.runtime.System

import static org.junit.Assert.*
import org.junit.Assert;
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import eu.indenica.config.runtime.runtime.Event
import eu.indenica.config.runtime.runtime.EventRef

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

			system sOne {
				event eventOne
			}	
		''')
		val e = model.elements.head as Event
		val s = model.elements.get(1) as System
		assertEquals(s.name, 'sOne')
		assertEquals(e.name, 'eventOne')
		assertSame((s.elements.head as EventRef).name, e)
	}
	
	@Test
	def void checkSyntax() {
		println("foo")
		'''
			event eventOne {
				attr1 : String
			}

			event eventTwo {
				attr2 : String
			}
			
			event eventThree {
				attr3 : String
				attrThree : String
			}
			
			system sOne {
				event eventOne
			}
			
			system sTwo {
				event eventOne
				event eventTwo
			}
			
			monitoringrule ruleOne {
				emit eventThree(foo as attr3)
				from sources sOne, sTwo event eventOne as attr1
				window 10s
				where foo
			}
			
			monitoringrule ruleTwo {
				from source sOne, sTwo events eventTwo, eventOne
				from source sTwo event eventTwo
				emit eventThree(foo as attrThree)
				window 500
			}
		'''.checkModel
	}
	
	def checkModel(CharSequence prog) {
        val model = parser.parse(prog)
        Assert::assertNotNull(model)
        model.assertNoErrors
        model
    }
}