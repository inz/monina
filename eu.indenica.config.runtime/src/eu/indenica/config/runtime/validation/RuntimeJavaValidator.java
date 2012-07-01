package eu.indenica.config.runtime.validation;

import org.eclipse.xtext.validation.Check;

import eu.indenica.config.runtime.runtime.MonitoringRule;
import eu.indenica.config.runtime.runtime.RuntimePackage;

public class RuntimeJavaValidator extends AbstractRuntimeJavaValidator {

	// @Check
	// public void checkGreetingStartsWithCapital(Greeting greeting) {
	// if (!Character.isUpperCase(greeting.getName().charAt(0))) {
	// warning("Name should start with a capital",
	// MyDslPackage.Literals.GREETING__NAME);
	// }
	// }

	@Check
	public void checkMonitoringRuleHasSource(MonitoringRule monitoringRule) {
		if(monitoringRule.getSources().isEmpty()) {
			error("Monitoring rule must have at least one source",
					RuntimePackage.Literals.MONITORING_RULE__SOURCES);
		}
	}
	
	@Check
	public void checkMonitoringRuleHasEmit(MonitoringRule monitoringRule) {
		if(monitoringRule.getEmits().isEmpty()) {
			error("Monitoring rule must emit at least one event",
					RuntimePackage.Literals.MONITORING_RULE__EMITS);
		}
	}
}
