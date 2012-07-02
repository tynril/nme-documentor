package content;

/**
 * Documentation about a method parameter.
 */
class ParamDoc 
{
	/** Method this parameter belongs to. */
	public var method : MethodDoc;
	
	/** Parameter name. */
	public var name : String;
	
	/** Type of the parameter. */
	public var type : String;
	
	/** Description of that parameter. */
	public var description : String;
	
	/** Is it a '...' parameter? */
	public var isRest : Bool;
	
	/** Is it a '*' parameter? */
	public var isAny : Bool;
	
	/** Default or constant value of the parameter. */
	public var data : String;
	
	public function new() {}
}