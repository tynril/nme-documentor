import content.MethodDoc;
import content.PackageDoc;
import content.ParamDoc;
import content.PropertyDoc;
import haxe.Http;
import neko.FileSystem;
import neko.io.File;
import neko.Lib;
using StringTools;
using Lambda;
using DocUtils;

/**
 * This project attempts to generate a full-fledged documentation
 * of the NME API by reading the data that comes with the open-source
 * Flex SDK.
 */
class Main 
{
	/** Path to the documentation in the SVN repository. */
	private static inline function DOCUMENTATION_URL() {
		return "http://opensource.adobe.com/svn/opensource/flex/sdk/trunk/" +
			"frameworks/projects/playerglobal/bundles/%LOCALE%/docs";
	}
	
	/** Container for all the Flex documentation. */
	private static var _doc : DocBrowser;
	
	/** Verbose logging. */
	private static var _verbose : Bool;
	
	/** Source input directory. */
	private static var _srcInput : String;
	
	/** Source output directory. */
	private static var _srcOutput : String;
	
	/**
	 * Entry point of the documentor.
	 */
	public static function main() 
	{
		// Program header.
		Lib.println("NME Documentation Generator v0.1 - (c) 2012 Samuel Loretan");
		
		// Default program arguments.
		var locale = "en_US";
		var proxy = null;
		
		// Parse arguments.
		var args = Sys.args();
		var argIndex = 0;
		while (argIndex < args.length) {
			var argName = args[argIndex++];
			switch(argName)
			{
				case "-locale":
					locale = args[argIndex++];
				case "-in":
					_srcInput = args[argIndex++];
				case "-out":
					_srcOutput = args[argIndex++];
				case "-proxy":
					proxy = args[argIndex++];
				case "-verbose":
					_verbose = true;
				default:
					trace("Warning: unknown argument '" + argName + "'.");
			}
		}
		
		// Check for arguments integrity.
		if (_srcInput == null ||
			!FileSystem.exists(_srcInput) ||
			!FileSystem.isDirectory(_srcInput)) {
			trace("Invalid input path '" + _srcInput + "'.");
			return;
		}
		if (_srcOutput == null ||
			(FileSystem.exists(_srcOutput) &&
			!FileSystem.isDirectory(_srcOutput))) {
			trace("Invalid output path '" + _srcOutput + "'.");
			return;
		}
		
		// Cleans the output directory.
		if (FileSystem.exists(_srcOutput)) {
			unlink(_srcOutput);
		}
		FileSystem.createDirectory(_srcOutput);
		
		// Configuring proxy if there's any.
		if (proxy != null) {
			Lib.println("Using proxy " + proxy + "...");
			var proxyData = proxy.split(":");
			Http.PROXY = { host: proxyData[0], port: Std.parseInt(proxyData[1]), auth: null };
		}
		
		// Get an index of all available documentation.
		var url = DOCUMENTATION_URL().replace("%LOCALE%", locale) + "/packages.dita";
		var indexer = new DocIndexer(url);
		
		// Fetch all that documentation.
		Lib.println("Downloading the Flex SDK documentation (locale: " + locale + ")...");
		_doc = new DocBrowser();
		indexer.iter(fetchDocumentation);
		
		// Browse the NME source code to fill the documentation.
		Lib.println("Applying the documentation to NME source...");
		fillDir(_srcInput);
		
		// We're done!
		Lib.println("Completed!");
	}
	
	/**
	 * Download and parse all Flex SDK documentation.
	 */
	private static function fetchDocumentation(url : String) : Void
	{
		// Extracting the package name.
		var pack = url.substring(url.lastIndexOf("/") + 1, url.lastIndexOf("."));
		if(_verbose) Lib.println("  Fetching documentation for package " + pack + "...");
		
		// Download and parse the data.
		_doc.addDocumentation(DocParser.parseFromUrl(url));
	}
	
	/**
	 * Fills the documentation in NME source code in the given directory.
	 */
	private static function fillDir(path : String) : Void
	{
		var files = FileSystem.readDirectory(path);
		for (file in files) {
			if (FileSystem.isDirectory(path + '/' + file))
				fillDir(path + "/" + file);
			else
				fillFile(path + "/" + file);
		}
	}
	
	/**
	 * Fills the documentation in NME source code in the given file.
	 */
	private static function fillFile(path : String) : Void
	{
		// Status display.
		if (_verbose) Lib.println("  Applying documentation to " + path + "...");
		
		// Preparing output directory.
		var relPath = path.substr(_srcInput.length + 1);
		var outPath = _srcOutput + "/" + relPath;
		if (relPath.indexOf("/") > -1) {
			var dirPath = _srcOutput + "/" + relPath.substr(0, relPath.indexOf("/"));
			if(!FileSystem.exists(dirPath))
				FileSystem.createDirectory(dirPath);
		}
		
		// Open input and output files.
		var input = File.read(path, false);
		var output = File.write(outPath, false);
		
		// Documentation containers.
		var currentPackage : PackageDoc = null;
		
		// Reads the input file, writing the output file.
		var isCodeCompletion = false;
		var hadCodeCompletion = false;
		var currentClass = null;
		var isUndocumentedPackage = false;
		var isUndocumentedClass = false;
		while (!input.eof())
		{
			// For some reason, on certain files, an EOF is thrown.
			var line = null;
			try {
				line = input.readLine();
			}
			catch (e : Dynamic) {
				break;
			}
			
			// Replace the tabs by four spaces, for easier indentation coherence.
			line = line.replace("\t", "    ");
			
			// Get the indentation of the current line.
			var indentReg = ~/^(\s*).*$/i;
			var indent = "";
			if (indentReg.match(line)) {
				indent = indentReg.matched(1);
			}
			
			// If we're not in the completion segment, check if it's starting now.
			if (!isCodeCompletion) {
				if (~/#if\s+code_completion/i.match(line)) {
					isCodeCompletion = hadCodeCompletion = true;
				}
			}
			
			// If we're in completion segment, check if we're not leaving it.
			if (isCodeCompletion) {
				if (~/#end|#elseif/i.match(line)) {
					isCodeCompletion = false;
				}
			}
			
			// While whe haven't detected the package, scan for it.
			if (currentPackage == null) {
				var packageReg = ~/package ([a-z\.]+);/;
				if (packageReg.match(line)) {
					var packageName = packageReg.matched(1);
					packageName = packageName.replace("nme", "flash");
					
					// Let's look for the documentation of that package.
					currentPackage = _doc.getPackageDoc(packageName);
					if (currentPackage == null) {
						trace("Warning: no documentation for package '" + packageName + "'.");
						isUndocumentedPackage = true;
					}
					else {
						isUndocumentedPackage = false;
					}
				}
			}
			
			// Scan for a class header.
			var classReg = ~/(?:class|enum) ([A-Z][A-Za-z]+)/;
			if (!isUndocumentedPackage && classReg.match(line)) {
				var className = classReg.matched(1);
				
				// Do we have a documentation for that class?
				if(currentPackage != null) {
					currentClass = currentPackage.getClassDoc(className);
					if (currentClass == null) {
						trace("Warning: no documentation for class " + className + ".");
						isUndocumentedClass = true;
					}
					// We do, let's print the doc.
					else {
						if (_verbose)
							Lib.println("    Adding documentation to class " + className + "...");
						
						// Opening documentation block.
						output.writeLine(indent + "/**");
						
						// Displaying class description.
						output.writeDocParagraph(indent + " * ", currentClass.fullDesc);
						
						// Displaying dispatched events.
						var hadSeparator = false;
						if(currentClass.events.length > 0)
						{
							if (!hadSeparator) {
								output.writeLine(indent + " * ");
								hadSeparator = true;
							}
							output.writeDocEvent(indent, currentClass.events);
						}
						
						// Closing documentation block.
						output.writeLine(indent + " */");
						
						isUndocumentedClass = false;
					}
				}
			}
			
			// Scan for a method declaration.
			var methodReg = ~/function (\w+)\(([^\)]*)/;
			if (!isUndocumentedPackage && !isUndocumentedClass && methodReg.match(line)) {
				var methodName = methodReg.matched(1);
				var methodParams = methodReg.matched(2).splitAsParams();
				
				// Are we inside a class here?
				if (currentClass == null) {
					trace("Warning: definition of method " + methodName + " found outside of class definition.");
				}
				else {
					// Look up for the method documentation.
					var methodDoc : MethodDoc;
					if (methodName == "new") {
						methodDoc = currentClass.constructor;
					}
					else {
						methodDoc = currentClass.getMethodDoc(methodName);
					}
					
					// Do we have something?
					if (methodDoc == null) {
						trace("Warning: undocumented method " + methodName + " in class " + currentClass.name + ".");
					}
					// We do, let's print the doc.
					else {
						if (_verbose)
							Lib.println("      Adding documentation to method " + methodName + "...");
						
						// Starting documentation block.
						output.writeLine();
						output.writeLine(indent + "/**");
						
						// Displaying deprecation status.
						if (methodDoc.isDeprecated) {
							output.writeLine(indent + " * @deprecated");
							output.writeLine();
						}
						
						// Displaying the method description.
						output.writeDocParagraph(indent + " * ", methodDoc.fullDesc);
						
						// Displaying parameters documentation.
						var hadSeparator = false;
						if (methodDoc.parameters.length > 0) {
							// Filter parameters to keep only those that the method has.
							var params = methodDoc.parameters.filter(function(doc : ParamDoc) : Bool { return methodParams.has(doc.name); } );
							
							if (params.length > 0) {
								// Add a separator before the parameters.
								if (!hadSeparator) {
									output.writeLine(indent + " * ");
									hadSeparator = true;
								}
								output.writeDocParams(indent, params);
							}
						}
						
						// Displaying return documentation.
						if (methodDoc.returnVal != null) {
							if (!hadSeparator) {
								output.writeLine(indent + " * ");
								hadSeparator = true;
							}
							output.writeDocReturn(indent, methodDoc.returnVal);
						}
						
						// Displaying throwable exceptions.
						if(methodDoc.exceptions.length > 0)
						{
							if (!hadSeparator) {
								output.writeLine(indent + " * ");
								hadSeparator = true;
							}
							output.writeDocThrows(indent, methodDoc.exceptions);
						}
						
						// Displaying dispatched events.
						if(methodDoc.events.length > 0)
						{
							if (!hadSeparator) {
								output.writeLine(indent + " * ");
								hadSeparator = true;
							}
							output.writeDocEvent(indent, methodDoc.events);
						}
						
						// Closing the documentation block.
						output.writeLine(indent + " */");
					}
				}
			}
			
			// Scan for property declaration.
			var propertyReg = ~/var (\w+)|([A-Z0-9]+);/;
			if (!isUndocumentedPackage && !isUndocumentedClass && propertyReg.match(line)) {
				// Handle both class properties, and enums.
				var propertyName = propertyReg.matched(1);
				if (propertyName == null) propertyName = propertyReg.matched(2);
				
				// Are we inside a class here?
				if (currentClass == null) {
					trace("Warning: property definition found outside of class definition.");
				}
				else {
					// Look up for property documentation.
					var propertyDoc : PropertyDoc = currentClass.getPropertyDoc(propertyName);
					
					// Do we have something?
					if (propertyDoc == null) {
						trace("Warning: undocumented property " + propertyName + " in class " + currentClass.name + ".");
					}
					// We do, let's print the doc.
					else {
						if (_verbose)
							Lib.println("      Adding documentation to property " + propertyName + "...");
						
						// Starting documentation block.
						output.writeLine();
						output.writeLine(indent + "/**");
						
						// Displaying deprecation status.
						if (propertyDoc.isDeprecated) {
							output.writeLine(indent + " * @deprecated");
							output.writeLine();
						}
						
						// Displaying property description.
						output.writeDocParagraph(indent + " * ", propertyDoc.fullDesc);
						
						// Displaying default value.
						var hadSeparator = false;
						if (propertyDoc.defaultValue != null) {
							if (!hadSeparator) {
								output.writeLine(indent + " * ");
								hadSeparator = true;
							}
							output.writeDocDefault(indent, propertyDoc.defaultValue);
						}
						
						// Displaying throwable exceptions.
						if (propertyDoc.exceptions.length > 0)
						{
							if (!hadSeparator) {
								output.writeLine(indent + " * ");
								hadSeparator = true;
							}
							output.writeDocThrows(indent, propertyDoc.exceptions);
						}
						
						// Closing documentation block.
						output.writeLine(indent + " */");
					}
				}
			}
			
			// Write the original line to the output file.
			output.writeLine(line);
		}
		
		// Check if we had the chance to put the documentation in.
		if (!hadCodeCompletion) {
			trace("Warning: no code_completion block in file " + path + ".");
		}
		
		// Closing streams.
		input.close();
		output.close();
	}
	
	private static function unlink(path : String) : Void 
	{ 
		if(FileSystem.exists(path)) { 
			if(FileSystem.isDirectory(path)) 
			{ 
				for(entry in FileSystem.readDirectory(path)) 
					unlink(path + "/" + entry);
				FileSystem.deleteDirectory( path ); 
			} 
			else
				FileSystem.deleteFile(path); 
		} 
	} 
}