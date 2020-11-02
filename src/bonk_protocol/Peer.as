package bonk_protocol {
import flash.net.NetConnection;
import flash.net.NetStream;

public class Peer {

    private var netConnection:NetConnection;

    private var stream:NetStream;

    private var clientObject:Object;

    public var farId:String;

    public var shortId:Number;

    public var receivedMessages:Array;

    public var destroyed:Boolean = false;

    public function Peer(netConnection:NetConnection, clientObject:Object, farId:String, shortId:Number) {
        this.shortId = shortId;
        this.netConnection = netConnection;
        this.clientObject = clientObject;
        this.farId = farId;
        receivedMessages = [];
        initRecvStream();
    }

    public function destroy():void {
        if (destroyed) {
            return;
        }
        stream.close();
        stream = null;
        clientObject = null;
        netConnection = null;
        destroyed = true;
    }

    public function initRecvStream():void {
        stream = new NetStream(netConnection, farId);
        stream.play("media");
        stream.bufferTime = 0;
        stream.client = this;
    }

    public function recvData(...rest):void {
        var command:String = rest[3];

        if (command == "recvTeamChange") {
            return;
        }

        clientObject.recvData.apply(null, rest);
    }
}
}
