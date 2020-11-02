package bonk_protocol.events {
import flash.events.Event;

public class EventHostDatabase extends Event {

    public static const HOST_SUCCESS:String = "eventHostingSuccess";
    public static const HOST_FAIL:String = "eventHostingFail";

    public var deleteId:Number;
    public var inviteId:Number;
    public var interval:uint;

    public function EventHostDatabase(type:String, deleteId:Number = -1, interval:uint = -1, bubbles:Boolean = false, cancellable:Boolean = false) {
        super(type, bubbles, cancellable);
        this.deleteId = deleteId;
        this.inviteId = (deleteId + 777) * 4;
        this.interval = interval;
    }

    override public function clone():Event {
        return new EventHostDatabase(type, this.deleteId, this.interval, bubbles, cancelable);
    }
}
}
