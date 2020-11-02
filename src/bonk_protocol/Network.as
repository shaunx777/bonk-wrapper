package bonk_protocol {
import bonk_protocol.events.EventHostDatabase;
import bonk_protocol.events.EventRTMP;
import bonk_protocol.ports.GameSettings;
import bonk_protocol.ports.Player;
import bonk_protocol.util.MD5;
import bonk_protocol.util.Protocol;

import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.IExternalizable;
import flash.utils.setInterval;

public class Network {

    public var kickId:int = Math.round(Math.random() * 999999999);

    internal var monaReady:Boolean = false;
    public var connection:NetConnection;
    public var localId:int;

    public var events:EventDispatcher = new EventDispatcher();

    internal var peerReady:Boolean = false;
    public var players:Array;
    public var gameSettings:GameSettings;
    public var peerConnection:NetConnection;
    public var peerStream:NetStream;
    public var peerId:String;
    public var sendCounter:int;
    public var peers:Array;

    public var inviteId:Number;
    public var hosting:Boolean = false;
    public var address:String = "";
    public var server:String = "";
    public var password:String = "";
    public var player:Player;

    public function Network(hosting:Boolean, player:Player) {
        this.hosting = hosting;
        this.player = player;
    }

    public function connect(address:String, password:String, server:String):void {
        this.address = address;
        this.password = password;
        this.server = server;
        this.players = [];

        initConnections();
    }

    public function host(roomName:String, password:String, maxPlayers:Number, version:Number, latitude:Number, longitude:Number, country:String, mode:Number, server:String):void {
        events.addEventListener(EventRTMP.HOST_SUCCESS, function (event:EventRTMP):void {
            addRoomToDatabase(roomName, address, password, maxPlayers, version, latitude, longitude, country, mode)
        });

        this.password = password;
        this.server = server;
        hosting = true;

        initConnections();
    }

    private function initConnections():void {
        createConnection();
        setupPeerConnection();
        peers = [];
    }

    private function ready():void {
        if (hosting) {
            address = peerId;
            connection.call("onNewHost", null, address, 8, password);
        } else {
            connection.call("onJoin", null, address, peerId, kickId, password);
        }
    }

    private function createConnection():void {
        connection = new NetConnection();
        connection.client = this;
        connection.connect("rtmp://bonk" + server + ".multiplayer.gg/chazmona11");

        function netHandler(e:NetStatusEvent):void {
            if (e.info["code"] == "NetConnection.Connect.Success") {
                monaReady = true;
                if (monaReady && peerReady) {
                    ready()
                }
            }
        }

        connection.addEventListener(NetStatusEvent.NET_STATUS, netHandler);
        connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,
                // TODO: Handle async error
                function asyncHandler(e:AsyncErrorEvent):void {
                    trace("Error async: " + e.error);
                }
        );
    }

    public function s_roomFull():void {
        events.dispatchEvent(new EventRTMP(EventRTMP.ROOM_FULL));
    }

    public function s_hostSuccess():void {
        localId = 0;
        events.dispatchEvent(new EventRTMP(EventRTMP.HOST_SUCCESS, address, localId));
    }

    private function setupPeerConnection():void {
        peerConnection = new NetConnection();
        peerConnection.client = this;
        peerConnection.connect("rtmfp://bonk" + server + ".multiplayer.gg/");

        function peerNetHandler(e:NetStatusEvent):void {
            if (e.info["code"] == "NetConnection.Connect.Success") {
                peerId = peerConnection.nearID;

                peerStream = new NetStream(peerConnection, NetStream.DIRECT_CONNECTIONS);
                peerStream.publish("media");
                var streamClient:Object = {};
                peerStream.client = streamClient;
                streamClient.onPeerConnect = function (stream:NetStream):Boolean {
                    return true;
                };

                peerReady = true;
                if (monaReady && peerReady) {
                    ready()
                }
            }
        }

        peerConnection.addEventListener(NetStatusEvent.NET_STATUS, peerNetHandler);
    }

    private function sendData(...data):void {
        sendCounter++;
        data.unshift(sendCounter);
        data.unshift(localId);
        data.unshift("recvData");
        peerStream.send.apply(null, data);
        var index:int = 0;
        while (index < data.length) {
            if (data[index] is IExternalizable && data[index]) {
                data[index] = "bodgeserialised" + Protocol.monaSerialise(data[index]);
            } else if (data[index] == null && data[index]) {
                data[index] = "null";
            } else if (data[index] is Array && data[index]) {
                data[index] = data[index].slice();
                var indexTwo:int = 0;
                while (indexTwo < data[index].length) {
                    if (data[index][indexTwo] is IExternalizable && data[index]) {
                        data[index][indexTwo] = "bodgeserialised" + Protocol.monaSerialise(data[index][indexTwo]);
                    } else if (data[index][indexTwo] == null) {
                        data[index][indexTwo] = "null";
                    } else if (data[index][indexTwo] is Array) {
                        data[index][indexTwo] = data[index][indexTwo].slice();
                        var indexThree:int = 0;
                        while (indexThree < data[index][indexTwo].length) {
                            if (data[index][indexTwo][indexThree] is IExternalizable && data[index]) {
                                data[index][indexTwo][indexThree] = "bodgeserialised" + Protocol.monaSerialise(data[index][indexTwo][indexThree]);
                            } else if (data[index][indexTwo][indexThree] == null) {
                                data[index][indexTwo][indexThree] = "null";
                            }
                            indexThree++;
                        }
                    }
                    indexTwo++;
                }
            }
            index++;
        }

        data.unshift(address);
        data.unshift(null);
        data.unshift("mirrorData");
        connection.call.apply(null, data);
    }

    public function kick(shortId:Number):void {
        connection.call("kickPlayer", null, peers[shortId].farID);
    }

    public function chat(message:String):void {
        sendData(-1, "recvChat", message);
    }

    public function me(message:String):void {
        sendData(-1, "recvChatStatus", message);
    }

    public function bell(state:Boolean):void {
        sendData(-1, "recvReady", state);
    }

    public function s_roomNotFound():void {
        events.dispatchEvent(new EventRTMP(EventRTMP.ROOM_NOT_FOUND));
    }

    public function s_joinedRoom(shortId:Number):void {
        localId = shortId;
        sendData(-1, "recvNewPlayerHandshake", player);

        events.dispatchEvent(new EventRTMP(EventRTMP.JOIN_SUCCESS));
    }

    public function s_alreadyInRoom(farId:String, shortId:Number):void {
        connectPeer(shortId, farId);
    }

    private function connectPeer(shortId:Number, farId:String):void {
        peers[shortId] = new Peer(peerConnection, this, farId, shortId);
    }

    public function s_playerLeft(farId:String, shortId:Number):void {
        peers[shortId].destroy();
        events.dispatchEvent(new EventRTMP(EventRTMP.PLAYER_LEFT, farId, shortId));
    }

    public function s_farPlayerJoined(farId:String, shortId:Number):void {
        connectPeer(shortId, farId);
        events.dispatchEvent(new EventRTMP(EventRTMP.PLAYER_JOINED, farId, shortId));
    }

    public function s_recvData(...rest):void {
        rest.shift();
        var index:int = 0;
        while (index < rest.length) {
            if (rest[index] is String) {
                if (rest[index].length > 15 && rest[index].substr(0, 15) == "bodgeserialised") {
                    rest[index] = rest[index].substr(15);
                    rest[index] = Protocol.monaUnserialize(rest[index]);
                } else if (rest[index] == "null") {
                    rest[index] = null;
                }
            } else if (rest[index] is Array) {
                var indexTwo:int = 0;
                while (indexTwo < rest[index].length) {
                    if (rest[index][indexTwo] is String) {
                        if (rest[index][indexTwo].length > 15 && rest[index][indexTwo].substr(0, 15) == "bodgeserialised") {
                            rest[index][indexTwo] = Protocol.monaUnserialize(rest[index][indexTwo].substr(15));
                        } else if (rest[index][indexTwo] == "null") {
                            rest[index][indexTwo] = null;
                        }
                    } else if (rest[index][indexTwo] is Array) {
                        var indexThree:int = 0;
                        while (indexThree < rest[index][indexTwo].length) {
                            if (rest[index][indexTwo][indexThree] is String) {
                                if (rest[index][indexTwo][indexThree].length > 15 && rest[index][indexTwo][indexThree].substr(0, 15) == "bodgeserialised") {
                                    rest[index][indexTwo][indexThree] = rest[index][indexTwo][indexThree].substr(15);
                                    rest[index][indexTwo][indexThree] = Protocol.monaUnserialize(rest[index][indexTwo][indexThree]);
                                } else if (rest[index][indexTwo][indexThree] == "null") {
                                    rest[index][indexTwo][indexThree] = null;
                                }
                            }
                            indexThree++;
                        }
                    }
                    indexTwo++;
                }
            }
            index++;
        }

        processData.apply(null, rest);
    }

    public function s_notifyKicked(farId:String):void {
        events.dispatchEvent(new EventRTMP(EventRTMP.PLAYER_KICKED, farId));
    }

    private function processData(...rest):void {
        rest.shift()
        var shortId:Number = rest.shift();
        var messageId:Number = rest.shift();
        var notSure:Number = rest.shift();
        var command:String = rest.shift();

        if (notSure != -1 && notSure != localId) {
            return;
        }

        if (!peers[shortId]) {
            trace("Received message from " + shortId + " but not connected yet...");
            return;
        }
        if (peers[shortId].receivedMessages[messageId] === true) {
            return;
        }
        peers[shortId].receivedMessages[messageId] = true;
        rest.unshift(shortId);

        if (command.indexOf("doPlayerPing") > -1) {
            return
        }

        if (command == "recvChat") {
            events.dispatchEvent(new EventRTMP(EventRTMP.ON_CHAT, peers[shortId].farId, shortId, rest[1]))
        } else if (command == "recvNewPlayerHandshake") {
            players[shortId] = rest[2];
            if (hosting) {
                sendData(rest[1],"recvInitialDataLobby",players,gameSettings,inviteId);
            }
        } else if (command == "recvInitialDataLobby") {
            recvInitialDataLobby(rest[0], rest[1], rest[2], rest[3])
        }

        // this._clientObject[command].apply(null, rest);
        // TODO: Fix receiving here :)
    }

    private function recvInitialDataLobby(param1:Number, players:Array, gameSettings:GameSettings, inviteId:Number):void {

        var index:int = 0;
        while(index < players.length)
        {
            if(players[index])
            {
                this.players[index] = players[index];
                trace(Player(players[index]).name)
            }
            index++;
        }
        this.inviteId = inviteId;
        this.gameSettings = gameSettings;
    }

    public function recvData(...rest):void {
        if (hosting && rest[2] == -1) {
            peerStream.send.apply(null, rest);
            rest.shift();
        }

        if (rest[0] != localId) {
            processData.apply(null, rest);
        }
    }

    public function destroy():void {
        var index:int = 0;
        if (peers != null) {
            while (index < this.peers.length) {
                if (this.peers[index] && this.peers [index].destroyed == false) {
                    this.peers[index].destroy();
                }
                index++;
            }
        }

        this.peers = null;

        if (peerStream) {
            peerStream.close();
        }
        peerStream = null;

        player = null;

        if (peerConnection) {
            peerConnection.close();
        }

        if (connection) {
            connection.close();
        }
    }

    private function addRoomToDatabase(roomName:String, address:String, password:String, maxPlayers:Number, version:Number, latitude:Number, longitude:Number, country:String, mode:Number):void {
        var retries:int = 0;

        var onDataLoad:Function = function (response:Event):void {
            var checksum:String = response.target.data["id"];
            var loader:URLLoader;
            var request:URLRequest;

            var handleLoaderError:Function = function (error:IOErrorEvent):void {
                if (retries > 5) {
                    events.dispatchEvent(new EventHostDatabase(EventHostDatabase.HOST_FAIL));
                    destroy();
                }
                loader.load(request);
                retries++;
            };

            var onComplete:Function = function (response:Event):void {
                inviteId = Number(response.target.data["newroomid"]);
                events.dispatchEvent(new EventHostDatabase(EventHostDatabase.HOST_SUCCESS, response.target.data["newroomid"], setInterval(continueRoomDatabase, 25000)));
            };

            request = new URLRequest("http://www.multiplayer.gg/physics/scripts/updateroominfo4.php");
            request.method = URLRequestMethod.POST;

            var variables:URLVariables = new URLVariables();
            variables.addressstring = address;
            variables.roomnamestring = roomName;

            if (password != "") {
                variables.passwordstring = MD5.encrypt(password + "saltG5EdxSaJuG");
            } else {
                variables.passwordstring = "";
            }

            variables.maxplayersstring = maxPlayers;
            variables.versionstring = version;
            variables.taskstring = "0";
            variables.gamemode = mode;
            variables.latitude = latitude;
            variables.longitude = longitude;
            variables.country = country;
            variables.basePasswordString = "77564898";
            variables.ingame = 0;
            variables.usernamelist = player.name;
            variables.server = server;
            variables.checksumcode = checksum;
            variables.checksumhash = String(MD5.encrypt(checksum + "checksumsalt343434" + String(variables.maxplayersstring) + variables.usernamelist + "fUj76Gvf$3$gIkmnilOlO"));
            request.data = variables;
            loader = new URLLoader(request);
            loader.addEventListener(Event.COMPLETE, onComplete);
            loader.dataFormat = URLLoaderDataFormat.VARIABLES;
            loader.load(request);
            loader.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderError);
        };

        var loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.VARIABLES;
        var request:URLRequest = new URLRequest("http://www.multiplayer.gg/physics/scripts/getchecksumcode.php");
        request.method = URLRequestMethod.POST;
        var variables:URLVariables = new URLVariables();
        request.data = variables;
        loader.dataFormat = URLLoaderDataFormat.VARIABLES;
        loader.load(request);
        loader.addEventListener(Event.COMPLETE, onDataLoad);
    }

    private function continueRoomDatabase():void {
        var request:URLRequest;
        var loader:URLLoader;
        var handleLoaderError:Function = function (param1:IOErrorEvent):void {
            loader.load(request);
        };

        request = new URLRequest("http://www.multiplayer.gg/physics/scripts/updateroominfo4.php");
        request.method = URLRequestMethod.POST;

        var variables:URLVariables = new URLVariables();
        variables.addressstring = address;
        variables.basePasswordString = "77564898";
        variables.taskstring = 1;
        variables.matchmaking = 0;
        request.data = variables;

        loader = new URLLoader(request);
        loader.dataFormat = URLLoaderDataFormat.VARIABLES;
        loader.load(request);
        loader.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderError);
    }

}
}
