package ;
import haxe.Http;

/**
 * This class collects and parse the remote documentation index.
 */
class DocIndexer
{
	private var _url : String;
	private var _packages : Array<String>;
	
	/**
	 * Creates a new indexer bound to the given packages list URL.
	 * @param url URL of the packages list.
	 */
	public function new(url : String) {
		_url = url.substr(0, url.lastIndexOf('/') + 1);
		load(url);
	}
	
	/**
	 * Returns an iterator going over all the indexed documentation pages.
	 */
	public function iterator() : Iterator<String> {
		var index = 0;
		return {
			hasNext: function() {
				return index < _packages.length;
			},
			next: function() {
				return _url + _packages[index ++];
			}
		};
	}
	
	/**
	 * Loads the packages list.
	 */
	private function load(url) : Void {
		_packages = [];
		parse(Xml.parse(Http.requestUrl(url)).firstElement());
	}
	
	/**
	 * Recursively parse an elements list.
	 */
	private function parse(parent : Xml) : Void {
		for (element in parent.elements()) {
			_packages.push(element.get("href"));
			parse(element);
		}
	}
}