package {

import bonk_protocol.Network;
import bonk_protocol.events.EventHostDatabase;
import bonk_protocol.events.EventRTMP;
import bonk_protocol.ports.Avatar;
import bonk_protocol.ports.AvatarLayer;
import bonk_protocol.ports.Externalizable;
import bonk_protocol.ports.GameSettings;
import bonk_protocol.ports.Player;

import flash.display.Sprite;

public class Main extends Sprite {

    internal var commands:Array = [];

    public function Main() {
        new Avatar();
        new AvatarLayer();
        new Player();
        new Externalizable();
        new GameSettings();

        commands = commands.concat(new Command("Ping", ".ping", function (network:Network, arguments:String, caller:String):void {
            network.chat("Pong!");
		}));
        commands = commands.concat(new Command("Leave", ".leave", function (network:Network, arguments:String, caller:String):void {
            network.destroy();
        }));
        commands = commands.concat(new Command("Help", ".help", function (network:Network, arguments:String, caller:String):void {
            var names:Array = [];
            for each(var c:Command in commands) {
                names = names.concat(c.name);
            }
            network.chat("Commands: " + names.join(", "));
        }));

        new Externalizable();

        var player:Player = new Player();
        player.name = "DiscoBot";
        player.xp = -1;
        player.bellCount = int.MIN_VALUE;
        var network:Network = new Network(false, player);
        network.events.addEventListener(EventRTMP.ROOM_NOT_FOUND, function (event:EventRTMP):void {
            trace("Room not found :(");
        });
        network.events.addEventListener(EventRTMP.PLAYER_JOINED, function (event:EventRTMP):void {
            trace("A player joined with the id: " + event.peerID);
        });
        network.events.addEventListener(EventRTMP.JOIN_SUCCESS, function (event:EventRTMP):void {
            network.chat("Hello, I'm Discobot - Use .help for commands and .leave to make me leave!");
        });
        network.events.addEventListener(EventHostDatabase.HOST_SUCCESS, function (event:EventHostDatabase):void {
            trace("Successfully hosting a match!")
        });
        network.events.addEventListener(EventRTMP.ON_CHAT, function (event:EventRTMP):void {
            if (event.value.charAt(0) == ".") {
                var arguments:Array = event.value.replace(".", "").split(" ");
                for each(var c:Command in commands) {
                    if (c.name.toLowerCase() == arguments[0].toLowerCase()) {
                        c.action(network, arguments, event.shortID);
                    }
                }
            }
        });

        // network.host("Discobot's Game", "", 8, 88, 0, 0, "GB", 0, "cockney")
        network.connect("380c72b7bff0670c85c07f1088c3e130432a8ce6ab10202ee6d266e3617c4cee", "password", "cockney")
    }
}
}
