package bonk_protocol.ports {
import flash.net.registerClassAlias;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

public class Player implements IExternalizable {

    private static const ALIAS = registerClassAlias("p", Player);

    public var name:String;
    public var xp:int;
    public var team:Number = 0;
    public var color:Number = 1752220;
    public var ready:Boolean = false;
    public var bellCount:Number = 0;
    public var avatar:Avatar;
    public var ping:Number = 0;

    public function Player() {
    }

    public function writeExternal(output:IDataOutput):void {
        output.writeUTF(this.name);
        output.writeInt(this.xp);
        output.writeShort(this.team);
        output.writeInt(this.color);
        output.writeBoolean(this.ready);
        output.writeShort(this.bellCount);
        output.writeObject(this.avatar);
        output.writeShort(this.ping);
    }

    public function readExternal(input:IDataInput):void {
        this.name = input.readUTF();
        this.xp = input.readInt();
        this.team = input.readShort();
        this.color = input.readInt();
        this.ready = input.readBoolean();
        this.bellCount = input.readShort();
        this.avatar = input.readObject();
        this.ping = input.readShort();
    }
}
}
