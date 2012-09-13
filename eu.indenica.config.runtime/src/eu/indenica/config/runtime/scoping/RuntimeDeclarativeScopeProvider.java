/*
 * generated by Xtext
 */
package eu.indenica.config.runtime.scoping;

import java.io.File;
import java.util.Collection;
import java.util.List;

import org.apache.log4j.Logger;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.Scopes;
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider;

import com.google.common.collect.Lists;

import de.uni_hildesheim.sse.ModelUtility;
import de.uni_hildesheim.sse.model.varModel.IvmlDatatypeVisitor;
import de.uni_hildesheim.sse.model.varModel.ModelQuery;
import de.uni_hildesheim.sse.model.varModel.ProgressObserver;
import de.uni_hildesheim.sse.model.varModel.Project;
import de.uni_hildesheim.sse.model.varModel.ProjectInfo;
import de.uni_hildesheim.sse.model.varModel.VarModel;
import de.uni_hildesheim.sse.model.varModel.VarModelException;
import de.uni_hildesheim.sse.model.varModel.datatypes.QualifiedNameMode;
import de.uni_hildesheim.sse.model.varModel.search.SearchContext;
import eu.indenica.config.runtime.runtime.AttributeEmissionDeclaration;
import eu.indenica.config.runtime.runtime.Event;
import eu.indenica.config.runtime.runtime.EventEmissionDeclaration;
import eu.indenica.config.runtime.runtime.EventSource;
import eu.indenica.config.runtime.runtime.EventSourceDeclaration;
import eu.indenica.config.runtime.runtime.Fact;
import eu.indenica.config.runtime.runtime.IndenicaMonitoringQuery;

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#scoping on
 * how and when to use it
 * 
 */
public class RuntimeDeclarativeScopeProvider extends
		AbstractDeclarativeScopeProvider {

	private final static Logger logger = Logger
			.getLogger(RuntimeDeclarativeScopeProvider.class);

	// IScope scope_EventAttribute(EventEmissionDeclaration ctx, EReference ref)
	// {
	// logger.info("event attributes: " +
	// ctx.getEvent().getAttributes().toString());
	// return Scopes.scopeFor(ctx.getEvent().getAttributes());
	// }

	/**
	 * Looks up valid event attributes for rename statements in event attribute
	 * emit statement.
	 * 
	 * @param ctx
	 *            the attribute emit statement
	 * @param ref
	 *            the reference to the event attribute
	 * @return a scope containing all valid event attributes
	 */
	IScope scope_AttributeEmissionDeclaration_attribute(
			final AttributeEmissionDeclaration ctx, final EReference ref) {
		return Scopes.scopeFor(((EventEmissionDeclaration) ctx.eContainer())
				.getEvent().getAttributes());
	}

	/**
	 * Looks up generally available event attributes within a monitoring rule
	 * 
	 * @param ctx
	 *            the monitoring rule
	 * @param ref
	 * @return a scope containing all valid event attributes
	 */
	IScope scope_EventAttribute(final IndenicaMonitoringQuery ctx,
			final EReference ref) {
		Collection<EObject> elements = Lists.newArrayList();
		Collection<EventSource> sources = Lists.newArrayList();

		for(EventSourceDeclaration source : ctx.getSources())
			sources.addAll(source.getSources());

		for(EventSource source : sources) {
			for(Event event : source.getEvents()) {
				// elements.add(event);
				elements.addAll(event.getAttributes());
			}
		}
		if(logger.isInfoEnabled()) {
			logger.info("Scope: ");
			for(EObject o : elements)
				logger.info("  " + o.toString());
		}
		return Scopes.scopeFor(elements);
	}

	/**
	 * Looks up event attributes available for partitioning in Fact rules
	 * 
	 */
	IScope scope_EventAttribute(final Fact ctx, final EReference ref) {
		Collection<EObject> elements = Lists.newArrayList();
		Collection<EventSource> sources = Lists.newArrayList();

		sources.addAll(ctx.getSource().getSources());

		for(EventSource source : sources) {
			for(Event event : source.getEvents()) {
				elements.addAll(event.getAttributes());
			}
		}
		if(logger.isInfoEnabled()) {
			logger.info("Scope: ");
			for(EObject o : elements)
				logger.info("  " + o.toString());
		}
		return Scopes.scopeFor(elements);
	}

	/**
	 * Looks up event attributes available for partitioning in Fact rules
	 * @throws VarModelException 
	 * 
	 */
	IScope scope_IvmlReference(final Fact ctx, final EReference ref) throws VarModelException {
		VarModel.INSTANCE.addLocation(new File("EASy/"), ProgressObserver.NO_OBSERVER);
		VarModel.INSTANCE.registerLoader(ModelUtility.INSTANCE, ProgressObserver.NO_OBSERVER);
		List<ProjectInfo> projectInfoList = VarModel.INSTANCE.getProjectInfo((Project) null);
		Project projectRootElement = VarModel.INSTANCE.load(projectInfoList.get(0));
		String namePrefix = "";
		ModelQuery.getElementsByNamePrefix(projectRootElement, namePrefix, 
				IvmlDatatypeVisitor.getInstance(QualifiedNameMode.QUALIFIED), 
				SearchContext.ID);
		
		return null;
	}
}
