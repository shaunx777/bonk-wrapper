package bonk_protocol.events {
import flash.events.Event;

public class EventRTMP extends Event {

    public static const ROOM_NOT_FOUND:String = "eventRoomNotFound";
    public static const JOIN_SUCCESS:String = "eventJoinedRoom";
    public static const PLAYER_LEFT:String = "eventPlayerLeft";
    public static const ON_CHAT:String = "eventOnChat";
    public static const PLAYER_KICKED:String = "eventPlayerKicked";
    public static const ROOM_FULL:String = "eventRoomFull";
    public static const PLAYER_JOINED:String = "eventPlayerJoined";
    public static const HOST_SUCCESS:String = "eventHostSuccess";

    public var peerID:String;
    public var shortID:Number;
    public var value:String;

    public function EventRTMP(type:String, peerId:String = "", shortId:Number = -1, comment:String = "", bubbles:Boolean = false, cancellable:Boolean = false) {
        super(type, bubbles, cancellable);
        this.peerID = peerId;
        this.shortID = shortId;
        this.value = comment;
    }

    override public function clone():Event {
        return new EventRTMP(type, this.peerID, this.shortID, this.value, bubbles, cancelable);
    }
}
}
