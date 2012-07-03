package content;

/**
 * Documentation about a particular method in a class.
 */
class MethodDoc 
{
	/** Name of the method. */
	public var name : String;
	
	/** Short, one-line description of the method. */
	public var shortDesc : String;
	
	/** Full description of this method. */
	public var fullDesc : String;
	
	/** Access modifier of that method. */
	public var access : String;
	
	/** Exceptions that can get raised by that method. */
	public var exceptions : Array<ExceptionDoc>;
	
	/** Return type of that method. */
	public var returnVal : ReturnDoc;
	
	/** List of that method parameters. */
	public var parameters : Array<ParamDoc>;
	
	/** Is this method static? */
	public var isStatic : Bool;
	
	/** Is this method an override? */
	public var isOverride : Bool;
	
	/** Is this method deprecated? */
	public var isDeprecated : Bool;
	
	/** List of events that can be dispatched by that method. */
	public var events : Array<EventDoc>;
	
	public function new() {
		this.exceptions = [];
		this.parameters = [];
		this.events = [];
	}
}