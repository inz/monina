/**
 * 
 */
package eu.indenica.config.runtime.scoping;

import org.eclipse.xtext.scoping.IScopeProvider;
import org.eclipse.xtext.xbase.scoping.XbaseScopeProvider;

import com.google.inject.Inject;
import com.google.inject.name.Named;

/**
 * @author Christian Inzinger
 * 
 */
@SuppressWarnings("restriction")
public class RuntimeXbaseScopeProvider extends XbaseScopeProvider {
	public final static String NAMED_DELEGATE =
			"eu.indenica.config.runtime.scoping.RuntimeXbaseScopeProvider.delegate";

	@Inject
	@Named(NAMED_DELEGATE)
	private IScopeProvider delegate;

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.xtext.xbase.scoping.XtypeScopeProvider#getDelegate()
	 */
	@Override
	public IScopeProvider getDelegate() {
		return delegate;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.eclipse.xtext.xbase.scoping.XtypeScopeProvider#setDelegate(org.eclipse
	 * .xtext.scoping.IScopeProvider)
	 */
	@Override
	public void setDelegate(IScopeProvider delegate) {
		this.delegate = delegate;
	}
}
