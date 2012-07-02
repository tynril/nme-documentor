import content.PackageDoc;
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
	
	/** Path to NME source code. */
	private static inline function NME_SOURCE() {
		return "D:\\svn\\nekonme-read-only";
	}
	
	/**
	 * Entry point of the documentor.
	 */
	public static function main() 
	{
		// Configuring the proxy for HTTP access.
		Http.PROXY = { host: "lil-net-proxy.ubisoft.org", port: 3128, auth: null };
		
		// Get an index of all available documentation.
		var url = DOCUMENTATION_URL().replace("%LOCALE%", DOCUMENTATION_LOCALE()) + "/packages.dita";
		//var indexer = new DocIndexer(url);
		//var indexer = ["http://opensource.adobe.com/svn/opensource/flex/sdk/trunk/frameworks/projects/playerglobal/bundles/en_US/docs/__Global__.xml"];
		var indexer = ["http://opensource.adobe.com/svn/opensource/flex/sdk/trunk/frameworks/projects/playerglobal/bundles/en_US/docs/flash.errors.xml"];
		
		// Fetch all that documentation.
		var docs : Array<PackageDoc> = [];
		indexer.iter(callback(fetch, docs));
		
		// Browse the NME source code to fill the documentation.
		// TODO :)
	}
	
	private static function fetch(docs : Array<PackageDoc>, url : String) : Void
	{
		// Extracting the package name.
		var pack = url.substring(url.lastIndexOf("/") + 1, url.lastIndexOf("."));
		Lib.println("Fetching documentation for package " + pack + "...");
		
		// Download and parse the data.
		docs.push(DocParser.parseFromUrl(url));
	}
}