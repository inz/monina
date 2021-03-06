package eu.indenica.config.runtime.validation;

import org.eclipse.xtext.validation.Check;

import eu.indenica.config.runtime.runtime.AbstractElement;
import eu.indenica.config.runtime.runtime.IndenicaMonitoringQuery;
import eu.indenica.config.runtime.runtime.MonitoringQuery;
import eu.indenica.config.runtime.runtime.RuntimePackage;
import eu.indenica.config.runtime.runtime.UpcaseNamedElement;
import eu.indenica.config.runtime.services.RuntimeGrammarAccess.PackageDeclarationElements;

public class RuntimeJavaValidator extends AbstractRuntimeJavaValidator {

	// @Check
	// public void checkEventStartsWithCapital(Event event) {
	// if(!Character.isUpperCase(event.getName().charAt(0))) {
	// error("Name must start with a capital",
	// RuntimePackage.Literals.EVENT__NAME);
	// }
	// }
	//
	// @Check
	// public void checkActionStartsWithCapital(Action action) {
	// if(!Character.isUpperCase(action.getName().charAt(0))) {
	// error("Name must start with a capital",
	// RuntimePackage.Literals.ACTION__NAME);
	// }
	// }
	//
	// @Check
	// public void checkComponentStartsWithCapital(Component component) {
	// if(!Character.isUpperCase(component.getName().charAt(0))) {
	// error("Name must start with a capital",
	// RuntimePackage.Literals.COMPONENT__NAME);
	// }
	// }

	@Check
	public void checkElementNameStartsWithCapital(AbstractElement element) {
		if(!(element instanceof UpcaseNamedElement)) {
			return;
		}
		if (!Character.isUpperCase(element.getName().charAt(0))) {
			error("Name must start with a capital",
					RuntimePackage.Literals.ABSTRACT_ELEMENT__NAME);
		}
	}

	@Check
	public void checkMonitoringRuleHasSource(MonitoringQuery monitoringRule) {
		if (monitoringRule.getSources().isEmpty()) {
			error("Monitoring rule must have at least one source",
					RuntimePackage.Literals.MONITORING_QUERY__SOURCES);
		}
	}

	// @Check
	// public void
	// checkMonitoringRuleHasSource(EsperMonitoringQuery monitoringRule) {
	// if(monitoringRule.getSources().isEmpty()) {
	// error("Monitoring rule must have at least one source",
	// RuntimePackage.Literals.ESPER_MONITORING_QUERY__SOURCES);
	// }
	// }

	@Check
	public void checkMonitoringRuleHasEmit(
			IndenicaMonitoringQuery monitoringRule) {
		if (monitoringRule.getEmits().isEmpty()) {
			error("Monitoring rule must emit at least one event",
					RuntimePackage.Literals.INDENICA_MONITORING_QUERY__EMITS);
		}
	}
}
