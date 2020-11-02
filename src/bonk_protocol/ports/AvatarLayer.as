package bonk_protocol.ports {
import flash.net.registerClassAlias;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

public class AvatarLayer implements IExternalizable {

    private static const ALIAS = registerClassAlias("al", AvatarLayer);


    public var id:Number;
    public var scale:Number = 0.25;
    public var angle:Number = 0;
    public var x:Number = 0;
    public var y:Number = 0;
    public var flipX:Boolean = false;
    public var flipY:Boolean = false;
    public var color:Number = 0;
    public var version:Number = 1;

    public function AvatarLayer() {
    }

    public function writeExternal(output:IDataOutput):void {
        output.writeShort(this.version);
        output.writeShort(this.id);
        output.writeFloat(this.scale);
        output.writeFloat(this.angle);
        output.writeFloat(this.x);
        output.writeFloat(this.y);
        output.writeBoolean(this.flipX);
        output.writeBoolean(this.flipY);
        output.writeInt(this.color);
    }

    public function readExternal(input:IDataInput):void {
        this.version = input.readShort();
        this.id = input.readShort();
        this.scale = input.readFloat();
        this.angle = input.readFloat();
        this.x = input.readFloat();
        this.y = input.readFloat();
        this.flipX = input.readBoolean();
        this.flipY = input.readBoolean();
        this.color = input.readInt();
    }
}
}
