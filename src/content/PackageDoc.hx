package content;
using Lambda;

/**
 * Documentation about a package and its content.
 */
class PackageDoc 
{
	/** Name of the package. */
	public var name : String;
	
	/** List of classes contained by this package. */
	public var classes : Array<ClassDoc>;
	
	/** List of methods defined in this package. */
	public var methods : Array<MethodDoc>;
	
	/** List of properties defined in this package. */
	public var properties : Array<PropertyDoc>;
	
	public function new() {
		this.classes = [];
		this.methods = [];
		this.properties = [];
	}
	
	/**
	 * Gets the documentation for a given class inside this package.
	 */
	public function getClassDoc(className : String) : ClassDoc
	{
		return classes.filter(function(doc : ClassDoc) : Bool {
			if (doc.name == className) return true;
			return false;
		}).first();
	}
}