package bonk_protocol.ports {
import flash.net.registerClassAlias;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

public class Externalizable implements IExternalizable {

    private static const j = registerClassAlias("j", Externalizable);
    private static const gmp = registerClassAlias("gmp", Externalizable);
    private static const gg = registerClassAlias("gg", Externalizable);

    public function Externalizable() {
    }

    public function writeExternal(output:IDataOutput):void {
    }

    public function readExternal(input:IDataInput):void {
    }
}
}
