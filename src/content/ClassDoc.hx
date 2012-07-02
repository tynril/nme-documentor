package content;

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
	
	/** List of class constructors. */
	public var constructors : Array<MethodDoc>;
	
	/** List of class methods. */
	public var methods : Array<MethodDoc>;
	
	/** List of class properties. */
	public var properties : Array<PropertyDoc>;

	public function new() {
		this.events = [];
		this.constructors = [];
		this.methods = [];
		this.properties = [];
	}
}