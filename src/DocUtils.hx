package ;
import content.ParamDoc;
import content.ReturnDoc;
import neko.io.FileOutput;
using DocUtils;
using StringTools;

/**
 * Utilities for documentation insertion in Haxe files.
 */
class DocUtils 
{
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
		for (paragraph in paragraphs)
		{
			var words = paragraph.split(" ");
			var line = startingText != null ? startingText : indent;
			for (word in words) {
				if(line.length + word.length + 1 < 80) {
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
	public static function writeDocParam(output : FileOutput, indent : String, param : ParamDoc) : Void
	{
		// Get the length of the longest parameter name in that method.
		var maxLength = 0;
		for (anyParam in param.method.parameters) {
			if (anyParam.name.length > maxLength)
				maxLength = anyParam.name.length;
		}
		
		// Print the parameter header.
		var line = indent + " * @param " + param.name.rpad(' ', maxLength) + " ";
		
		// Print the parameter documentation.
		output.writeDocParagraph(indent + " * " + " ".repeat(8 + maxLength), param.description , line);
	}
	
	/**
	 * Writes the documentation about a return value.
	 */
	public static function writeDocReturn(output : FileOutput, indent : String, returnVal : ReturnDoc) : Void
	{
		output.writeDocParagraph(indent + " *         ",
				returnVal.description, indent + " * @return ");
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