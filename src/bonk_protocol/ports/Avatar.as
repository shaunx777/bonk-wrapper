package bonk_protocol.ports {
import flash.net.registerClassAlias;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

public class Avatar implements IExternalizable {

    private static const ALIAS = registerClassAlias("a", Avatar);

    public var layerList:Array;
    public var version:Number = 2;
    public var baseColor:Number = 1752220;

    public function Avatar(param1:Boolean = false) {
        this.layerList = [];
        if (param1) {
            this.randomizeBaseColor();
        }
    }

    public function randomizeBaseColor():* {
        var _loc1_:Number = Math.random();
        var _loc2_:Array = [1752220, 4492031, 13840175, 16757504, 15684432, 9489145];
        var _loc3_:* = 1 / _loc2_.length;
        var _loc4_:* = 1;
        while (_loc4_ <= _loc2_.length) {
            if (_loc1_ <= _loc4_ * _loc3_) {
                this.baseColor = _loc2_[_loc4_ - 1];
                return;
            }
            _loc4_++;
        }
    }

    public function writeExternal(output:IDataOutput):void {
        output.writeShort(2);
        output.writeObject(this.layerList);
        output.writeUnsignedInt(this.baseColor);
    }

    public function readExternal(input:IDataInput):void {
        this.version = input.readShort();
        this.layerList = input.readObject();
        if (this.version >= 2) {
            this.baseColor = input.readUnsignedInt();
        }
    }
}
}
