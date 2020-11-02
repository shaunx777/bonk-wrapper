package bonk_protocol.util {
import flash.utils.ByteArray;

public class Protocol {

    public static function monaSerialise(obj:Object):String {
        var bytes:ByteArray = new ByteArray();
        bytes.writeObject(obj);
        return Base64.encodeByteArray(bytes);
    }

    public static function monaUnserialize(str:String):Object {
        return Base64.decodeToByteArray(str).readObject();
    }

}
}
