package {
public class Command {

    public var name:String;
    public var usage:String;
    public var action:Function;

    public function Command(name:String, usage:String, action:Function) {
        this.name = name;
        this.usage = usage;
        this.action = action;
    }

}
}
