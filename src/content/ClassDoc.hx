package content;
using Lambda;

/**
 * Documentation about a specific class.
 */
class ClassDoc 
{
	/** Package in which this class remains. */
	public var pack : PackageDoc;
	
	/** Name of the class. */
	public var name : String;
	
	/** Short, one-line description of the class. */
	public var shortDesc : String;
	
	/** Full description of the class. */
	public var fullDesc : String;
	
	/** List of events that this class can dispatch. */
	public var events : Array<EventDoc>;
	
	/** Class constructor method. */
	public var constructor : MethodDoc;
	
	/** List of class methods. */
	public var methods : Array<MethodDoc>;
	
	/** List of class properties. */
	public var properties : Array<PropertyDoc>;

	public function new() {
		this.events = [];
		this.methods = [];
		this.properties = [];
	}
	
	/**
	 * Gets the documentation for a given method inside this class.
	 */
	public function getMethodDoc(methodName : String) : MethodDoc
	{
		return methods.filter(function(doc : MethodDoc) : Bool {
			if (doc.name == methodName) return true;
			return false;
		}).first();
	}
	
	/**
	 * Gets the documentation for a given property inside this class.
	 */
	public function getPropertyDoc(propertyName : String) : PropertyDoc
	{
		return properties.filter(function(doc : PropertyDoc) : Bool {
			if (doc.name == propertyName) return true;
			return false;
		}).first();
	}
}