
package eu.indenica.config.runtime;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class RuntimeStandaloneSetup extends RuntimeStandaloneSetupGenerated{

	public static void doSetup() {
		new RuntimeStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

