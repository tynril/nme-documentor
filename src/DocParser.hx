package ;

import content.ExceptionDoc;
import content.MethodDoc;
import content.ParamDoc;
import content.PropertyDoc;
import content.ReturnDoc;
import haxe.Http;
import content.PackageDoc;
import content.ClassDoc;
import content.EventDoc;

using Lambda;
using StringTools;

class DocParser
{
	public static function parseFromUrl(url : String) : PackageDoc
	{
		var packageDoc = new PackageDoc();
		var data = Xml.parse(Http.requestUrl(url)).firstElement();
		data.iter(callback(parsePackage, packageDoc));
		return packageDoc;
	}
	
	/**
	 * Parse all classes as defined in the root elements of the document.
	 */
	private static function parsePackage(pack : PackageDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiName":
				// Package name.
				pack.name = data.firstChild().toString().trim();
				
				// Special case for the global package.
				if (pack.name == "__Global__") {
					pack.name = "";
				}
			case "apiDetail":
				// Details about the package (usually empty).
			case "apiClassifier":
				// Describes a class contained in this package.
				var classDoc = new ClassDoc();
				data.iter(callback(parseClass, classDoc));
				pack.classes.push(classDoc);
			case "apiOperation":
				// Describes a global function contained in this package.
				var methodDoc = new MethodDoc();
				data.iter(callback(parseMethod, methodDoc));
				pack.methods.push(methodDoc);
			case "apiValue":
				// Describes a global constant contained in this package.
				var propDoc = new PropertyDoc();
				data.iter(callback(parseProperty, propDoc));
				pack.properties.push(propDoc);
			default:
				trace("Warning: unknown package node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse the informations about a class, as described in the 'apiClassifier'
	 * element.
	 */
	private static function parseClass(clazz : ClassDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiName":
				// Name of the class.
				clazz.name = data.firstChild().toString().trim();
			case "shortdesc":
				// Short description of the class meaning.
				clazz.shortDesc = parseDescription(data);
			case "prolog":
				// Informations about the class availability, and keywords.
			case "apiClassifierDetail":
				// Details about the class.
				data.iter(callback(parseClassDetails, clazz));
			case "related-links":
				// Links to stuff related to that class.
			case "adobeApiEvent":
				// Event that can be dispatched by that class.
				var eventDoc = new EventDoc();
				data.iter(callback(parseEvent, eventDoc));
				clazz.events.push(eventDoc);
			case "apiConstructor":
				// Constructor for that class.
				// There might be multiple, but only in edge cases we don't care about.
				var constructorDoc = new MethodDoc();
				data.iter(callback(parseConstructor, constructorDoc));
				clazz.constructor = constructorDoc;
			case "apiOperation":
				// Method on that class.
				var methodDoc = new MethodDoc();
				data.iter(callback(parseMethod, methodDoc));
				clazz.methods.push(methodDoc);
			case "apiValue":
				// Property on that class.
				var propDoc = new PropertyDoc();
				data.iter(callback(parseProperty, propDoc));
				clazz.properties.push(propDoc);
			default:
				trace("Warning: unknown class node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse the details about a class, as described in the 'apiClassifierDetail'
	 * element.
	 */
	private static function parseClassDetails(clazz : ClassDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiClassifierDef":
				// Class accessibility, modifiers and parent, as well as tips
				// texts.
			case "apiDesc":
				// Description of the class.
				clazz.fullDesc = parseDescription(data);
			case "example":
				// Example (in AS3) making usage of the class.
			default:
				trace("Warning: unknown class details node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse an event dispatched by a class, as described in the 'adobeApiEvent'
	 * element.
	 */
	private static function parseEvent(event : EventDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiName":
				// Name of the event.
				event.name = data.firstChild().toString().trim();
			case "shortdesc":
				// Short description of the event behavior.
				event.shortDesc = parseDescription(data);
			case "prolog":
				// Informations about the event availability.
			case "related-links":
				// Links to stuff related to that event.
			case "adobeApiEventDetail":
				// Details about the event.
				data.iter(callback(parseEventDetails, event));
			default:
				trace("Warning: unknown event node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse the details about an event dispatched by a class, as described by
	 * the 'adobeApiEventDetail' element.
	 */
	private static function parseEventDetails(event : EventDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "adobeApiEventDef":
				// Class of the event, and event type.
				data.iter(callback(parseEventDef, event));
			case "apiDesc":
				// Description of the event.
				event.fullDesc = parseDescription(data);
			case "example":
				// Example relating to that event (in AS3).
			default:
				trace("Warning: unknown event details node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse the definition of an event, as described by the 'adobeApiEventDef'
	 * element.
	 */
	private static function parseEventDef(event : EventDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiEventType":
				// Type of event (example: flash.event.Event.ENTER_FRAME)
				event.type = data.firstChild().toString().trim();
			case "adobeApiEventClassifier":
				// Class of the event.
				if(data.firstChild() != null) {
					event.typeClass = data.firstChild().toString().trim();
				}
			case "apiGeneratedEvent":
				// Unknown
			case "apiDefinedEvent":
				// Unknown
			case "apiTipTexts":
				// Tips associated with this event.
			default:
				trace("Warning: unknown event def node '" + data.nodeName + "'.");
		}
	}
	 
	/**
	 * Parses the documentation about a constructor, as described by the
	 * 'apiConstructor' element.
	 */
	private static function parseConstructor(constructor : MethodDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiName":
				// Name of the constructor.
				constructor.name = data.firstChild().toString().trim();
			case "shortdesc":
				// Short description of the constructor.
				constructor.shortDesc = parseDescription(data);
			case "prolog":
				// Informations about the constructor availability.
			case "apiConstructorDetail":
				// Details about the constructor.
				data.iter(callback(parseConstructorDetails, constructor));
			case "related-links":
				// Links related to that constructor.
			case "adobeApiEvent":
				// Event that can be dispatched by that constructor.
				var eventDoc = new EventDoc();
				data.iter(callback(parseEvent, eventDoc));
				constructor.events.push(eventDoc);
			default:
				trace("Warning: unknown constructor node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse the details about a class constructor, as described by the
	 * 'apiConstructorDetail' element.
	 */
	private static function parseConstructorDetails(constructor : MethodDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiConstructorDef":
				// Level of access of the constructor.
				data.iter(callback(parseConstructorDef, constructor));
			case "apiDesc":
				// Full description of the constructor method.
				constructor.fullDesc = parseDescription(data);
			case "example":
				// Example using this constructor (in AS3).
			default:
				trace("Warning: unknown constructor detail node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse the definition of a constructor, as described by the
	 * 'apiConstructorDef' element.
	 */
	private static function parseConstructorDef(constructor : MethodDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiAccess":
				// Method access level.
				constructor.access = data.get("value");
			case "apiParam":
				// Parameter of that constructor.
				var paramDoc : ParamDoc = new ParamDoc();
				data.iter(callback(parseParam, paramDoc));
				constructor.parameters.push(paramDoc);
			case "apiException":
				// Exception that can be raised when calling this constructor.
				var exceptionDoc : ExceptionDoc = new ExceptionDoc();
				data.iter(callback(parseException, exceptionDoc));
				constructor.exceptions.push(exceptionDoc);
			case "apiTipTexts":
				// Tips associated with this constructor.
			default:
				trace("Warning: unknown constructor def node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parses the documentation about a method, as described by the
	 * 'apiOperation' element.
	 */
	private static function parseMethod(method : MethodDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiName":
				// Name of the method.
				method.name = data.firstChild().toString().trim();
			case "shortdesc":
				// Short description of the method.
				method.shortDesc = parseDescription(data);
			case "prolog":
				// Informations about the method availability.
			case "apiOperationDetail":
				// Details about the method.
				data.iter(callback(parseMethodDetails, method));
			case "adobeApiEvent":
				// Event that can be dispatched by that method.
				var eventDoc = new EventDoc();
				data.iter(callback(parseEvent, eventDoc));
				method.events.push(eventDoc);
			case "related-links":
				// Links related to that method.
			default:
				trace("Warning: unknown method node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse the details about a class method, as described by the
	 * 'apiOperationDetail' element.
	 */
	private static function parseMethodDetails(method : MethodDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiOperationDef":
				// Definition of the method.
				data.iter(callback(parseMethodDef, method));
			case "apiDesc":
				// Full description of the method.
				method.fullDesc = parseDescription(data);
			case "example":
				// Example using this method (in AS3).
			default:
				trace("Warning: unknown method detail node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse the definition of a method, as described by the 'apiOperationDef'
	 * element.
	 */
	private static function parseMethodDef(method : MethodDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiAccess":
				// Method access level.
				method.access = data.get("value");
			case "apiException":
				// Exception that can be raised by that method.
				var exceptionDoc : ExceptionDoc = new ExceptionDoc();
				data.iter(callback(parseException, exceptionDoc));
				method.exceptions.push(exceptionDoc);
			case "apiReturn":
				// Return type of the method.
				var returnDoc : ReturnDoc = new ReturnDoc();
				data.iter(callback(parseReturn, returnDoc));
				if (method.returnVal != null)
					throw "A return value was already bound to the method.";
				method.returnVal = returnDoc;
			case "apiParam":
				// Parameter of that method.
				var paramDoc : ParamDoc = new ParamDoc();
				data.iter(callback(parseParam, paramDoc));
				method.parameters.push(paramDoc);
			case "apiTipTexts":
				// Tips associated with this method.
			case "apiStatic":
				// Static method marker.
				method.isStatic = true;
			case "apiIsOverride":
				// Override method marker.
				method.isOverride = true;
			case "apiDeprecated":
				// Deprecation marker.
				method.isDeprecated = true;
			case "apiDefaultValue":
				// Default value for the method (?!)
			default:
				trace("Warning: unknown method def node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse an exception documentation, as described by the 'apiException'
	 * element.
	 */
	private static function parseException(exception : ExceptionDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiDesc":
				// Description of the circumstances in which the exception is raised.
				exception.description = parseDescription(data);
			case "apiItemName":
				// Name of the exception.
				exception.name = data.firstChild().toString().trim();
			case "apiOperationClassifier":
				// Type of the exception.
				exception.type = data.firstChild().toString().trim();
			default:
				trace("Warning: unknown exception node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse a return value documentation, as described by the 'apiReturn'
	 * element.
	 */
	private static function parseReturn(returnVal : ReturnDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiType":
				switch(data.get("name"))
				{
					case "type":
						// Type of the return.
						returnVal.type = data.get("value");
					default:
						trace("Warning: unknown apiType name '" + data.get("name") + "'.");
				}
			case "apiDesc":
				// Description of the return value.
				returnVal.description = parseDescription(data);
			case "apiOperationClassifier":
				// Type of the return.
				returnVal.type = data.firstChild().toString().trim();
			default:
				trace("Warning: unknown return node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse a method parameter documentation, as described by the 'apiParam'
	 * element.
	 */
	private static function parseParam(param : ParamDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiItemName":
				// Name of the parameter.
				param.name = data.firstChild().toString().trim();
			case "apiOperationClassifier":
				// Type of the parameter.
				param.type = data.firstChild().toString().trim();
			case "apiDesc":
				// Parameter description.
				param.description = parseDescription(data);
			case "apiType":
				switch(data.get("name"))
				{
					case "type":
						// Parameter type.
						switch(data.get("value"))
						{
							case "restParam":
								// The parameter is a '...' parameter.
								param.isRest = true;
							case "T":
								// The return type depends on the genericity of the class.
							case "any":
								// The parameter is a '*' parameter.
								param.isAny = true;
							default:
								if (data.get("value").substr(0, 7) == "Vector$") {
									// Type of the vector.
								}
								else
									trace("Warning: unknown parameter type value '" + data.get("value") + "'.");
						}
					default:
						trace("Warning: unknown type name '" + data.get("name") + "'.");
				}
			case "apiData":
				// Value of the parameter.
				if(data.firstChild() != null)
					param.data = data.firstChild().toString().trim();
			default:
				trace("Warning: unknown param node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse a class property documentation, as described by the 'apiValue'
	 * element.
	 */
	private static function parseProperty(property : PropertyDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiName":
				// Name of the property.
				property.name = data.firstChild().toString().trim();
			case "shortdesc":
				// Short description of that property.
				property.shortDesc = parseDescription(data);
			case "prolog":
				// Property availability information.
			case "related-links":
				// Links related to that property.
			case "apiValueDetail":
				// Details about the property.
				data.iter(callback(parsePropertyDetails, property));
			default:
				trace("Warning: unknown property node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse a class property details documentation, as described by the
	 * 'apiValueDetail' element.
	 */
	private static function parsePropertyDetails(property : PropertyDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiDesc":
				// Full description of that property.
				property.fullDesc = parseDescription(data);
			case "apiValueDef":
				// Definition of that property.
				data.iter(callback(parsePropertyDef, property));
			case "example":
				// Example of usage of that property (in AS3).
			default:
				trace("Warning: unknown property details node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse a class property definition documentation, as described by the
	 * 'apiValueDef' element.
	 */
	private static function parsePropertyDef(property : PropertyDoc, data : Xml) : Void
	{
		switch(data.nodeName)
		{
			case "apiProperty":
				// Property marker.
			case "apiAccess":
				// Property access level.
				property.access = data.get("value");
			case "apiStatic":
				// Property static marker.
				property.isStatic = true;
			case "apiDynamic":
				// Property dynamic marker (ie not static).
				property.isStatic = false;
			case "apiIsOverride":
				// Property override marker.
				property.isOverride = true;
			case "apiValueAccess":
				// Value access level.
				property.valueAccess = data.get("value");
			case "apiValueClassifier":
				// Property value type.
				property.type = data.firstChild().toString().trim();
			case "apiException":
				// Exception that can be raised when calling this property.
				var exceptionDoc : ExceptionDoc = new ExceptionDoc();
				data.iter(callback(parseException, exceptionDoc));
				property.exceptions.push(exceptionDoc);
			case "apiData":
				// Constant value of that property.
				if (data.firstChild() != null) {
					property.constantValue = data.firstChild().toString().trim();
				}
			case "apiDefaultValue":
				// Default value of that property.
				if (data.firstChild() != null) {
					property.defaultValue = data.firstChild().toString().trim();
				}
			case "apiTipTexts":
				// Tips associated with this property.
			case "apiType":
				// Special case for the undefined value.
			case "apiDeprecated":
				// Deprecation marker.
				property.isDeprecated = true;
			default:
				trace("Warning: unknown property def node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse a description, as described in the 'apiDesc' element.
	 * <table><tr><td>lol</td><td>lil</td></tr><tr><td>lul</td><td>lal</td></tr></table>
	 */
	private static function parseDescription(data : Xml) : String
	{
		// Concatenate the whole description content in a string.
		var desc : String = "";
		data.iter(function(d) { desc += d.toString(); } );
		
		// Remove XML 'class' arguments.
		desc = ~/ class="[^"]+"/gi.replace(desc, "");
		
		// Replace 'codeph' element by 'code'.
		desc = ~/<(\/?)codeph/gi.replace(desc, "<$1code");
		
		// Replace 'xref' element by 'a'.
		desc = ~/<(\/?)xref/gi.replace(desc, "<$1a");
		
		// Remove 'ph' tags.
		desc = ~/<\/?ph>/g.replace(desc, "");
		
		// Remove images.
		desc = ~/<adobeimage[^>]*\/>/g.replace(desc, "");
		
		// Remove tables.
		desc = ~/<adobetable>.*<\/adobetable>/gs.replace(desc, "");
		
		// Remove codeblocks.
		desc = ~/<codeblock.*<\/codeblock>/gs.replace(desc, "");
		
		// Process HTML entities.
		desc = desc.htmlUnescape();
		
		// Replace tabs by spaces.
		desc = ~/\t/g.replace(desc, " ");
		
		// Remove line breaks.
		desc = ~/\n/g.replace(desc, " ");
		
		// Replace multiple spaces by single space.
		desc = ~/[ ]+/g.replace(desc, " ");
		
		// Remove empty paragraphs.
		desc = ~/<p>\s*<\/p>/g.replace(desc, " ");
		
		// Put line breaks before and after paragraphs.
		desc = ~/<p>/g.replace(desc, "\n<p>");
		desc = ~/<\/p>/g.replace(desc, "</p>\n");
		
		// Format lists
		desc = ~/<(ul|ol|li)>/g.replace(desc, "\n<$1>");
		desc = ~/<\/(ul|ol|li)>/g.replace(desc, "</$1>\n");
		
		// Remove leading spaces.
		desc = ~/\n+/g.replace(desc, "\n");
		desc = ~/^[ ]*(.*)[ ]*$/gm.replace(desc, "$1");
		
		// Indent list elements.
		desc = ~/<li>/g.replace(desc, "  <li>");
		
		// Put proper separation between paragraphs.
		desc = ~/<p>/g.replace(desc, "\n<p>");
		desc = ~/\n\n+/g.replace(desc, "\n\n");
		
		// Trim the whole stuff.
		desc = desc.trim();
		
		return desc;
	}
}