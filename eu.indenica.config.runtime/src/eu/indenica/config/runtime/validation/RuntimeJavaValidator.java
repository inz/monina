package eu.indenica.config.runtime.validation;

import org.eclipse.xtext.validation.Check;

import eu.indenica.config.runtime.runtime.Action;
import eu.indenica.config.runtime.runtime.Component;
import eu.indenica.config.runtime.runtime.EsperMonitoringQuery;
import eu.indenica.config.runtime.runtime.Event;
import eu.indenica.config.runtime.runtime.IndenicaMonitoringQuery;
import eu.indenica.config.runtime.runtime.RuntimePackage;

public class RuntimeJavaValidator extends AbstractRuntimeJavaValidator {

	@Check
	public void checkEventStartsWithCapital(Event event) {
		if(!Character.isUpperCase(event.getName().charAt(0))) {
			error("Name must start with a capital",
					RuntimePackage.Literals.EVENT__NAME);
		}
	}
	
	@Check
	public void checkActionStartsWithCapital(Action action) {
		if(!Character.isUpperCase(action.getName().charAt(0))) {
			error("Name must start with a capital",
					RuntimePackage.Literals.ACTION__NAME);
		}
	}
	
	@Check
	public void checkComponentStartsWithCapital(Component component) {
		if(!Character.isUpperCase(component.getName().charAt(0))) {
			error("Name must start with a capital",
					RuntimePackage.Literals.COMPONENT__NAME);
		}
	}

	@Check
	public void checkMonitoringRuleHasSource(
			IndenicaMonitoringQuery monitoringRule) {
		if(monitoringRule.getSources().isEmpty()) {
			error("Monitoring rule must have at least one source",
					RuntimePackage.Literals.INDENICA_MONITORING_QUERY__SOURCES);
		}
	}

	@Check
	public void
			checkMonitoringRuleHasSource(EsperMonitoringQuery monitoringRule) {
		if(monitoringRule.getSources().isEmpty()) {
			error("Monitoring rule must have at least one source",
					RuntimePackage.Literals.ESPER_MONITORING_QUERY__SOURCES);
		}
	}

	@Check
	public void checkMonitoringRuleHasEmit(
			IndenicaMonitoringQuery monitoringRule) {
		if(monitoringRule.getEmits().isEmpty()) {
			error("Monitoring rule must emit at least one event",
					RuntimePackage.Literals.INDENICA_MONITORING_QUERY__EMITS);
		}
	}
}
