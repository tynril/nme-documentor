import haxe.Http;
import neko.Lib;
using StringTools;
using Lambda;

/**
 * This project attempts to generate a full-fledged documentation
 * of the NME API by reading the data that comes with the open-source
 * Flex SDK.
 */
class Main 
{
	/** Version of the documentation generator. */
	private static inline function VERSION() { return "0.1b"; }
	
	/** Path to the documentation in the SVN repository. */
	private static inline function DOCUMENTATION_URL() {
		return "http://opensource.adobe.com/svn/opensource/flex/sdk/trunk/" +
			"frameworks/projects/playerglobal/bundles/%LOCALE%/docs";
	}
	
	/** Locale of the documentation to fetch. */
	private static inline function DOCUMENTATION_LOCALE() {
		return "en_US";
	}
	
	/**
	 * Entry point of the documentor.
	 */
	public static function main() 
	{
		// Generates the full documentation index URL.
		var url = DOCUMENTATION_URL().replace("%LOCALE%", DOCUMENTATION_LOCALE()) + "/packages.dita";
		//var indexer = new DocIndexer(url);
		//var indexer = ["http://opensource.adobe.com/svn/opensource/flex/sdk/trunk/frameworks/projects/playerglobal/bundles/en_US/docs/__Global__.xml"];
		var indexer = ["http://opensource.adobe.com/svn/opensource/flex/sdk/trunk/frameworks/projects/playerglobal/bundles/en_US/docs/flash.sensors.xml"];
		
		// Fetch each page.
		indexer.iter(fetch);
	}
	
	private static function fetch(url : String)
	{
		// Extracting the package name.
		var pack = url.substring(url.lastIndexOf("/") + 1, url.lastIndexOf("."));
		Lib.println("Fetching documentation for package " + pack + "...");
		
		// Parse the data.
		DocParser.parseFromUrl(url);
		//trace(Http.requestUrl(url));
	}
	
	/**
	 * Displays usage information and copyright.
	 */
	private static function printNotice()
	{
		Lib.println("NME Documentor " + VERSION() + " - (c)2012 Samuel Loretan");
		Lib.println(" Options:");
		Lib.println("  -");
	}
}