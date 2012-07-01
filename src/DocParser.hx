package ;

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
			case "apiDetail":
				// Details about the package (usually empty).
			case "apiClassifier":
				// Describes a class contained in this package.
				var classDoc = new ClassDoc();
				classDoc.pack = pack;
				data.iter(callback(parseClass, classDoc));
				pack.classes.push(classDoc);
			/*case "apiOperation":
				// Describes a global function contained in this package.
			case "apiValue":
				// Describes a global constant contained in this package.*/
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
				eventDoc.clazz = clazz;
				data.iter(callback(parseEvent, eventDoc));
				clazz.events.push(eventDoc);
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
				// Informations about the event availability, and keywords.
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
				event.typeClass = data.firstChild().toString().trim();
			case "apiGeneratedEvent":
				// Unknown
			default:
				trace("Warning: unknown event def node '" + data.nodeName + "'.");
		}
	}
	
	/**
	 * Parse the a description, as described in the 'apiDesc' element.
	 */
	private static function parseDescription(data : Xml) : String
	{
		// Concatenate the whole description content in a string.
		var desc : String = "";
		data.iter(function(d) { desc += d.toString(); } );
		
		// Remove XML 'class' arguments.
		desc = ~/ class="[^"]+"/gi.replace(desc, "");
		
		// Replace 'codeph' element by 'tt'.
		desc = ~/<(\/?)codeph/gi.replace(desc, "<$1tt");
		
		// Replace 'xref' element by 'a'.
		desc = ~/<(\/?)xref/gi.replace(desc, "<$1a");
		return desc;
	}
}