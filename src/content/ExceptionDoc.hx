package content;

/**
 * Documentation about an exception as raised by a method.
 */
class ExceptionDoc 
{
	/** Method that can raise this exception. */
	public var method : MethodDoc;
	
	/** Property that can raise this exception. */
	public var property : PropertyDoc;
	
	/** Exception name. */
	public var name : String;
	
	/** Circumstances in which the exception is raised. */
	public var description : String;
	
	/** Exception type. */
	public var type : String;
	
	public function new() { }
}