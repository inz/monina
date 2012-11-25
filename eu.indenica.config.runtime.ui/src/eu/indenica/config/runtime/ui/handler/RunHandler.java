package eu.indenica.config.runtime.ui.handler;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.IHandler;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.console.ConsolePlugin;
import org.eclipse.ui.console.IConsole;
import org.eclipse.ui.console.IConsoleManager;
import org.eclipse.ui.console.IOConsole;
import org.eclipse.ui.handlers.HandlerUtil;

public class RunHandler extends AbstractHandler implements IHandler {
	ExecutorService consoles = Executors.newCachedThreadPool();

//	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		ISelection selection = HandlerUtil.getCurrentSelection(event);

		System.out.println("selection: " + selection.toString());
		if(selection instanceof IStructuredSelection) {
			IStructuredSelection structuredSelection =
					(IStructuredSelection) selection;
			Object firstElement = structuredSelection.getFirstElement();
			if(firstElement instanceof IFile) {
				IFile file = (IFile) firstElement;
				IProject project = file.getProject();
				final IFolder srcGenFolder = project.getFolder("monina-gen");

				System.out.println("Starting contribution...");
				Job execJob = new Job("Start Infrastructure") {
					private Process process = null;

					@Override
					protected IStatus run(IProgressMonitor monitor) {
						try {
							process =
									new ProcessBuilder(
											"mvn clean compile exec:java"
													.split(" "))
											.directory(
													srcGenFolder.getLocation()
															.toFile()).start();

							redirectToConsole(process, "Indenica Runtime");
							process.waitFor();
						} catch(IOException e) {
							e.printStackTrace();
						} catch(InterruptedException e) {
							e.printStackTrace();
						}

						consoles.shutdownNow();
						return Status.OK_STATUS;
					}

					/*
					 * (non-Javadoc)
					 * 
					 * @see org.eclipse.core.runtime.jobs.Job#canceling()
					 */
					@Override
					protected void canceling() {
						if(process != null)
							process.destroy();
						if(consoles != null)
							consoles.shutdownNow();
					}

				};
				execJob.schedule();
			}
		}
		return null;
	}

	private IOConsole findConsole(String name) {
		ConsolePlugin plugin = ConsolePlugin.getDefault();
		IConsoleManager conMan = plugin.getConsoleManager();
		IConsole[] existing = conMan.getConsoles();
		for(int i = 0; i < existing.length; i++)
			if(name.equals(existing[i].getName()))
				return (IOConsole) existing[i];
		// no console found, so create a new one
		IOConsole myConsole = new IOConsole(name, null);
		conMan.addConsoles(new IConsole[] { myConsole });
		return myConsole;
	}

	private void redirectToConsole(final Process process,
			final String consoleName) {
		final IOConsole console = findConsole(consoleName);

		// process stdin
		consoles.submit(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				final OutputStream processOut = process.getOutputStream();
				final InputStream consoleIn = console.getInputStream();

				while(!consoles.isShutdown()) {
					processOut.write(consoleIn.read());
					processOut.flush();
				}

				processOut.close();
				consoleIn.close();
				return null;
			}
		});

		// process stdout
		consoles.submit(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				final InputStream processIn = process.getInputStream();
				final OutputStream consoleOut = console.newOutputStream();

				int b = 0;
				while(!consoles.isShutdown() && (b = processIn.read()) != -1)
					consoleOut.write(b);

				consoleOut.close();
				processIn.close();
				return null;
			}
		});

		// process stderr
		consoles.submit(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				final InputStream processErr = process.getErrorStream();
				final OutputStream consoleOut = console.newOutputStream();

				int b = 0;
				while(!consoles.isShutdown() && (b = processErr.read()) != -1)
					consoleOut.write(b);

				consoleOut.close();
				processErr.close();
				return null;
			}
		});
	}
}
