package content;

/**
 * Documentation about a property on a class.
 */
class PropertyDoc 
{
	/** Class on which this property is bound. */
	public var clazz : ClassDoc;
	
	/** Package on which this property is bound. */
	public var pack : PackageDoc;
	
	/** Name of that property. */
	public var name : String;
	
	/** Short description of that property. */
	public var shortDesc : String;
	
	/** Full description of that property. */
	public var fullDesc : String;
	
	/** Access level of that property (public, protected, ...). */
	public var access : String;
	
	/** Value access level (read, read/write, ...). */
	public var valueAccess : String;
	
	/** Is this an instance property, or a static property? */
	public var isStatic : Bool;
	
	/** Is this property an override? */
	public var isOverride : Bool;
	
	/** Is this property deprecated? */
	public var isDeprecated : Bool;
	
	/** Type of that property. */
	public var type : String;
	
	/** Exceptions that can be raised when calling that property. */
	public var exceptions : Array<ExceptionDoc>;
	
	/** Default or constant value of the property. */
	public var data : String;

	public function new() {
		this.exceptions = [];
	}
}