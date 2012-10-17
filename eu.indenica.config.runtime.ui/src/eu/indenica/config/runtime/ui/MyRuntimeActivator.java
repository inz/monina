/**
 * 
 */
package eu.indenica.config.runtime.ui;

import org.osgi.framework.BundleContext;

import eu.indenica.config.runtime.ui.internal.RuntimeActivator;

/**
 * @author Christian Inzinger
 *
 */
public class MyRuntimeActivator extends RuntimeActivator {
	/* (non-Javadoc)
	 * @see eu.indenica.config.runtime.ui.internal.RuntimeActivator#start(org.osgi.framework.BundleContext)
	 */
	@Override
	public void start(BundleContext context) throws Exception {
		super.start(context);
//		ModelUtility.setResourceInitializer(new EclipseResourceInitializer(this));
	}
}
