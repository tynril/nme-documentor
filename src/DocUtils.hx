package ;
import content.EventDoc;
import content.ExceptionDoc;
import content.ParamDoc;
import content.ReturnDoc;
import haxe.Stack;
import neko.io.FileOutput;
using DocUtils;
using StringTools;

/**
 * Utilities for documentation insertion in Haxe files.
 */
class DocUtils 
{
	private static inline var LINE_WIDTH : Int = 80;
	private static inline var MAX_INDENT : Int = 30;
	
	/**
	 * Write a text and a linebreak to the output.
	 */
	public static function writeLine(output : FileOutput, ?line : String) : Void
	{
		output.writeString((line != null ? line : "") + "\n");
	}
	
	/**
	 * Writes a documentation paragraph, line broken at 80 characters.
	 */
	public static function writeDocParagraph(output : FileOutput, indent : String, text : String, ?startingText : String) : Void
	{
		if (text == null) {
			trace("Warning: null text given to writeDocParagraph.");
			return;
		}
		
		var paragraphs = text.split("\n");
		var hadStartingText = false;
		for (paragraph in paragraphs)
		{
			var words = paragraph.split(" ");
			var line = null;
			if (startingText != null) {
				if (!hadStartingText) {
					line = startingText;
					hadStartingText = true;
				}
				else {
					line = indent + " ".repeat(startingText.length - indent.length);
				}
			}
			else {
				line = indent;
			}
			for (word in words) {
				if(line.length + word.length + 1 < LINE_WIDTH) {
					line += word + " ";
				}
				else {
					output.writeLine(line.rtrim());
					line = indent + word + " ";
				}
			}
			output.writeLine(line.rtrim());
		}
	}
	
	/**
	 * Writes the documentation about a parameter.
	 */
	public static function writeDocParams(output : FileOutput, indent : String, params : List<ParamDoc>) : Void
	{
		// Get the length of the longest parameter name in that method.
		var maxLength = 0;
		for (anyParam in params) {
			if (anyParam.name.length > maxLength)
				maxLength = anyParam.name.length;
		}
		
		for(anyParam in params) {
			// Print the parameter header.
			var line = indent + " * @param " + anyParam.name.rpad(' ', maxLength) + " ";
			
			// Print the parameter documentation.
			output.writeDocParagraph(indent + " * " + " ".repeat(8 + maxLength), anyParam.description , line);
		}
	}
	
	/**
	 * Writes the documentation about a return value.
	 */
	public static function writeDocReturn(output : FileOutput, indent : String, returnVal : ReturnDoc) : Void
	{
		// Do not output return without description.
		if (returnVal.description == null) return;
		output.writeDocParagraph(indent + " *         ",
				returnVal.description, indent + " * @return ");
	}
	
	/**
	 * Writes the documentation about a thrown exception.
	 */
	public static function writeDocThrows(output : FileOutput, indent : String, throws : Array<ExceptionDoc>) : Void
	{
		// Get the length of the longest throwable name in that method.
		var maxLength = 0;
		for (anyException in throws) {
			if (anyException.name.length > maxLength)
				maxLength = anyException.name.length;
		}
		
		// Sort the exceptions list.
		throws.sort(function(a : ExceptionDoc, b : ExceptionDoc) : Int {
			if (a.name > b.name) return 1;
			else if (a.name < b.name) return -1;
			return 0;
		});
		
		for (anyException in throws) {
			// Print the throwable header.
			var line = indent + " * @throws " + anyException.name.rpad(' ', maxLength) + " ";
			
			// Print the exception documentation.
			output.writeDocParagraph(indent + " * " + " ".repeat(9 + maxLength), anyException.description , line);
		}
	}
	
	/**
	 * Writes the documentation about a dispatchable event.
	 */
	public static function writeDocEvent(output : FileOutput, indent : String, events : Array<EventDoc>) : Void
	{
		// Sort the events list.
		events.sort(function(a : EventDoc, b : EventDoc) : Int {
			if (a.name > b.name) return 1;
			else if (a.name < b.name) return -1;
			return 0;
		});
		
		// Get the length of the longest event name in that method.
		var maxLength = 0;
		for (anyEvent in events) {
			if (anyEvent.name.length > maxLength)
				maxLength = anyEvent.name.length;
		}
		
		for (anyEvent in events) {
			// Print the event header.
			var line = indent + " * @event " + anyEvent.name.rpad(' ', maxLength) + " ";
			
			// Print the event documentation.
			output.writeDocParagraph(indent + " * " + " ".repeat(8 + maxLength), anyEvent.fullDesc, line);
		}
	}
	
	/**
	 * Writes the documentation about a default value of a property.
	 */
	public static function writeDocDefault(output : FileOutput, indent : String, defaultText : String) : Void
	{
		// Print the event header.
		var line = indent + " * @default ";
		
		// Print the event documentation.
		output.writeDocParagraph(indent + " * " + " ".repeat(10), defaultText, line);
	}
	
	/**
	 * Split a parameters list and returns the name of each parameters.
	 */
	public static function splitAsParams(list : String) : Array<String>
	{
		var paramsReg = ~/\??(\w+)\s?:?\s?[\w\.]*\s?=?\s?[\w'"]*,?\s?/g;
		return paramsReg.replace(list, "|$1").substr(1).split("|");
	}
	
	/**
	 * Repeat a string.
	 */
	public static function repeat(text : String, count : Int) : String
	{
		var t = "";
		for (i in 0...count) t += text;
		return t;
	}
}