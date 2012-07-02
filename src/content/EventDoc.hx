package content;

/**
 * Documentation about an event as dispatched by a particular class.
 */
class EventDoc 
{
	/** Class that can dispatch that event. */
	public var clazz : ClassDoc;
	
	/** Method that can dispatch that event. */
	public var method : MethodDoc;
	
	/** Name of the event. */
	public var name : String;
	
	/** Short, one-line description of the event. */
	public var shortDesc : String;
	
	/** Full description of the event. */
	public var fullDesc : String;
	
	/** Fully qualified type of event. */
	public var type : String;
	
	/** Class of the event dispatched. */
	public var typeClass : String;
	
	public function new() {}
}