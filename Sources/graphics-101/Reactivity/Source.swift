protocol Source<T>: Identifiable, AnyObject {
    associatedtype T;
    
    var value: T {
        get
    }
}