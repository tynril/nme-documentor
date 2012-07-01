package content;

/**
 * Documentation about a package and its content.
 */
class PackageDoc 
{
	/** Name of the package. */
	public var name : String;
	
	/** List of classes contained by this package. */
	public var classes : Array<ClassDoc>;
	
	public function new() {
		this.classes = [];
	}
}