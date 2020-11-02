package bonk_protocol.ports {
import flash.net.registerClassAlias;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

public class GameSettings implements IExternalizable {

    private static const ALIAS = registerClassAlias("gst", GameSettings);

    public var teams:Boolean = false;
    public var teamsLocked:Boolean = false;
    public var mode:Number = 1;
    public var map:Number = 12;
    public var mapGish:Externalizable;
    public var roundsToWin:Number = 3;
    public var quickPlay:Boolean = false;
    public var gishDamageAmount:Number = 1;
    public var roomName:String;
    public var roomPassword:String;
    public var roomMaxPlayers:Number;
    public var action1AmmoSpend:int = 10;
    public var action1AmmoRecover:int = 5;
    public var advancedGameSettings;
    public var gishKickMode:Boolean = false;
    public var gishKickRange:Number = 6;
    public var gishKickPower:Number = 300;
    public var gishKickDelay:Number = 30;
    public var gishKickReload:Number = 18;
    public var gishKickAngleWidth:Number = 40;
    public var gishShootMode:Boolean = false;
    public var gishWeldMode:Boolean = false;

    public function GameSettings() {
        // this.mapGish = MapGish.classic;
    }

    public function writeExternal(param1:IDataOutput):void {
        param1.writeBoolean(this.teams);
        param1.writeBoolean(this.teamsLocked);
        param1.writeShort(this.mode);
        param1.writeUnsignedInt(this.map);
        param1.writeObject(this.mapGish);
        param1.writeShort(this.roundsToWin);
        param1.writeUTF(this.roomName);
        param1.writeUTF(this.roomPassword);
        param1.writeShort(this.roomMaxPlayers);
        param1.writeDouble(this.gishDamageAmount);
        param1.writeShort(this.action1AmmoSpend);
        param1.writeShort(this.action1AmmoRecover);
        if (this.advancedGameSettings) {
            param1.writeBoolean(true);
            param1.writeObject(this.advancedGameSettings);
        } else {
            param1.writeBoolean(false);
        }
        param1.writeBoolean(this.quickPlay);
        param1.writeBoolean(this.gishKickMode);
        if (this.gishKickMode) {
            param1.writeDouble(this.gishKickPower);
            param1.writeDouble(this.gishKickRange);
            param1.writeShort(this.gishKickDelay);
            param1.writeShort(this.gishKickReload);
            param1.writeShort(this.gishKickAngleWidth);
        }
        param1.writeBoolean(this.gishShootMode);
        param1.writeBoolean(this.gishWeldMode);
    }

    public function readExternal(param1:IDataInput):void {
        this.teams = param1.readBoolean();
        this.teamsLocked = param1.readBoolean();
        this.mode = param1.readShort();
        this.map = param1.readUnsignedInt();
        this.mapGish = param1.readObject();
        this.roundsToWin = param1.readShort();
        this.roomName = param1.readUTF();
        this.roomPassword = param1.readUTF();
        this.roomMaxPlayers = param1.readShort();
        this.gishDamageAmount = param1.readDouble();
        this.action1AmmoSpend = param1.readShort();
        this.action1AmmoRecover = param1.readShort();
        var _loc2_:Boolean = param1.readBoolean();
        if (_loc2_) {
            this.advancedGameSettings = param1.readObject();
        }
        this.quickPlay = param1.readBoolean();
        this.gishKickMode = param1.readBoolean();
        if (this.gishKickMode) {
            this.gishKickPower = param1.readDouble();
            this.gishKickRange = param1.readDouble();
            this.gishKickDelay = param1.readShort();
            this.gishKickReload = param1.readShort();
            this.gishKickAngleWidth = param1.readShort();
        }
        this.gishShootMode = param1.readBoolean();
        this.gishWeldMode = param1.readBoolean();
    }
}
}
